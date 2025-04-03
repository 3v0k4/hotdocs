def source_paths # used by copy() & template()
  [ File.expand_path("../..", __dir__) ]
end

def gem?(name)
  gemfile_path = Pathname(destination_root).join("Gemfile")

  regex = /gem ["']#{name}["']/
  if File.readlines(gemfile_path).grep(regex).any?
    say "#{name} already bundled"
    false
  else
    run("bundle add #{name}") || abort("Failed to add #{name} to the bundle")
    true
  end
end

def pin?(name)
  importmap_path = Pathname(destination_root).join("config/importmap.rb")

  regex = /pin ["']#{name}["']/
  if File.readlines(importmap_path).grep(regex).any?
    say "#{name} already pinned"
    false
  else
    run("bin/importmap pin #{name}") || abort("Failed to pin #{name} to the importmap")
    true
  end
end

unless system("command -v deno > /dev/null 2>&1")
  abort "Install deno before running this task. Read more: https://deno.com"
end

if File.exist?("app/assets/config/manifest.js")
  abort "Migrate to Propshaft before running this task. Read more: https://github.com/rails/propshaft/blob/main/UPGRADING.md#3-migrate-from-sprockets-to-propshaft"
end

gem?("importmap-rails") && run("bin/rails importmap:install")
gem?("turbo-rails") && run("bin/rails turbo:install")
gem?("stimulus-rails") && run("bin/rails stimulus:install")

pin?("lunr")

create_file(Pathname(destination_root).join("app/controllers/hotdocs_controller.rb"), <<~CONTROLLER)
  class HotdocsController < ApplicationController
    helper Hotdocs::Engine.helpers
    layout "hotdocs"
  end
CONTROLLER

create_file(Pathname(destination_root).join("app/views/layouts/hotdocs.html.erb"), <<~LAYOUT)
  <% content_for :head do %>
    <%= content_for(:title, "HotDocs") unless content_for?(:title) %>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= stylesheet_link_tag :app %>
    <%= javascript_importmap_tags %>
  <% end %>

  <%= render template: "layouts/hotdocs/application" %>
LAYOUT

create_file(Pathname(destination_root).join("app/views/hotdocs/index.html.mderb"), <<~VIEW)
  <%= content_for(:title, "Welcome") %>

  # Welcome to HotDocs

  Find this markdown in `app/views/hotdocs/index.html.mderb`.

  ## Todos

  <input type="checkbox" id="first">
  <label for="first"> Update <code>app/views/layouts/hotdocs.html.erb</code></label><br>
  <input type="checkbox" id="second">
  <label for="second"> Update <code>app/helpers/hotdocs_helper.rb</code></label><br>
  <input type="checkbox" id="third">
  <label for="third"> Maybe read the docs: <a href="https://hotdocsrails.com/" target="_blank">hotdocsrails.com</a></label>
VIEW

copy_file("app/assets/images/hotdocs/icon.svg", Pathname(destination_root).join("app/assets/images/hotdocs.svg"))

inject_into_module(Pathname(destination_root).join("app/helpers/application_helper.rb"), "ApplicationHelper", "  include HotdocsHelper\n\n")
create_file(Pathname(destination_root).join("app/helpers/hotdocs_helper.rb"), <<~HELPER)
  module HotdocsHelper
    def logo
      Struct.new(:src, :alt).new(asset_path("hotdocs.svg"), "A humanized and happy hot dog")
    end

    def nav_left_items(classes)
      [
        active_link_to("Docs", root_path, class: Array(classes))
      ]
    end

    def nav_right_items(classes)
      [
        external_link_to("GitHub", "https://github.com/3v0k4/hotdocs", class: Array(classes))
      ]
    end

    # { label: "", url: *_path, children: [], expanded: false/true }
    def menu_items
      [
        { label: "Welcome", url: root_path },
      ]
    end

    def repository_base_url
      "https://github.com/3v0k4/hotdocs/blob/main"
    end

    def footer_items
      [
        {
          heading: "Contribute",
          items: [
            external_link_to("Source Code", "https://github.com/3v0k4/hotdocs", class: "footer__link")
          ]
        },
        {
          heading: "Community",
          items: [
            external_link_to("GitHub Discussions", "https://github.com/3v0k4/hotdocs/discussions", class: "footer__link")
          ]
        },
        {
          heading: "(il)Legal",
          items: [
            "Nothing to see here."
          ]
        },
        {
          heading: "HotDocs",
          items: [
            "Write your docs with Ruby on Rails."
          ]
        }
      ]
    end
  end
HELPER

create_file(Pathname(destination_root).join("app/assets/stylesheets/prism.css"), <<~CSS)
  /* Find more themes on: https://github.com/PrismJS/prism-themes */

  /*
     Darcula theme

     Adapted from a theme based on:
     IntelliJ Darcula Theme (https://github.com/bulenkov/Darcula)

     @author Alexandre Paradis <service.paradis@gmail.com>
     @version 1.0
  */

  code[class*="language-"],
  pre[class*="language-"] {
    color: #a9b7c6;
    font-family: Consolas, Monaco, 'Andale Mono', monospace;
    direction: ltr;
    text-align: left;
    white-space: pre;
    word-spacing: normal;
    word-break: normal;
    line-height: 1.5;

    -moz-tab-size: 4;
    -o-tab-size: 4;
    tab-size: 4;

    -webkit-hyphens: none;
    -moz-hyphens: none;
    -ms-hyphens: none;
    hyphens: none;
  }

  pre[class*="language-"]::-moz-selection, pre[class*="language-"] ::-moz-selection,
  code[class*="language-"]::-moz-selection, code[class*="language-"] ::-moz-selection {
    color: inherit;
    background: rgba(33, 66, 131, .85);
  }

  pre[class*="language-"]::selection, pre[class*="language-"] ::selection,
  code[class*="language-"]::selection, code[class*="language-"] ::selection {
    color: inherit;
    background: rgba(33, 66, 131, .85);
  }

  /* Code blocks */
  pre[class*="language-"] {
    padding: 1em;
    margin: .5em 0;
    overflow: auto;
  }

  :not(pre) > code[class*="language-"],
  pre[class*="language-"] {
    background: #2b2b2b;
  }

  /* Inline code */
  :not(pre) > code[class*="language-"] {
    padding: .1em;
    border-radius: .3em;
  }

  .token.comment,
  .token.prolog,
  .token.cdata {
    color: #808080;
  }

  .token.delimiter,
  .token.boolean,
  .token.keyword,
  .token.selector,
  .token.important,
  .token.atrule {
    color: #cc7832;
  }

  .token.operator,
  .token.punctuation,
  .token.attr-name {
    color: #a9b7c6;
  }

  .token.tag,
  .token.tag .punctuation,
  .token.doctype,
  .token.builtin {
    color: #e8bf6a;
  }

  .token.entity,
  .token.number,
  .token.symbol {
    color: #6897bb;
  }

  .token.property,
  .token.constant,
  .token.variable {
    color: #9876aa;
  }

  .token.string,
  .token.char {
    color: #6a8759;
  }

  .token.attr-value,
  .token.attr-value .punctuation {
    color: #a5c261;
  }

  .token.attr-value .punctuation:first-child {
    color: #a9b7c6;
  }

  .token.url {
    color: #287bde;
    text-decoration: underline;
  }

  .token.function {
    color: #ffc66d;
  }

  .token.regex {
    background: #364135;
  }

  .token.bold {
    font-weight: bold;
  }

  .token.italic {
    font-style: italic;
  }

  .token.inserted {
    background: #294436;
  }

  .token.deleted {
    background: #484a4a;
  }

  code.language-css .token.property,
  code.language-css .token.property + .token.punctuation {
    color: #a9b7c6;
  }

  code.language-css .token.id {
    color: #ffc66d;
  }

  code.language-css .token.selector > .token.class,
  code.language-css .token.selector > .token.attribute,
  code.language-css .token.selector > .token.pseudo-class,
  code.language-css .token.selector > .token.pseudo-element {
    color: #ffc66d;
  }
CSS

empty_directory "app/assets/builds"
keep_file "app/assets/builds"
if Pathname(destination_root).join(".gitignore").exist?
  append_to_file(".gitignore", %(\n/app/assets/builds/*\n!/app/assets/builds/.keep\n))
  append_to_file(".gitignore", %(\n/node_modules/\n))
end

routes_path = Pathname(destination_root).join("config/routes.rb")
routes = File.readlines(routes_path)
unless routes.grep(/hotdocs#index/).any?
  if routes.grep(/^\s*(?!#)root/).any?
    route "get '/hotdocs', to: 'hotdocs#index'"
  else
    route "root to: 'hotdocs#index'"
  end
end
