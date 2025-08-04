def source_paths # used by copy_file()
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

def pin(name)
  importmap_path = Pathname(destination_root).join("config/importmap.rb")

  regex = /pin ["']#{name}["']/
  if File.readlines(importmap_path).grep(regex).any?
    say "#{name} already pinned"
  else
    run("bin/importmap pin #{name}") || abort("Failed to pin #{name} to the importmap")
    gsub_file importmap_path, /(pin ["']#{name}["'])(.*)/, '\1, preload: "hotdocs"\2'
  end
end

if File.exist?("app/assets/config/manifest.js")
  abort "Migrate to Propshaft before running this task. Read more: https://github.com/rails/propshaft/blob/main/UPGRADING.md#3-migrate-from-sprockets-to-propshaft"
end

gem?("importmap-rails") && run("bin/rails importmap:install")
gem?("turbo-rails") && run("bin/rails turbo:install")
gem?("stimulus-rails") && run("bin/rails stimulus:install")

create_file(Pathname(destination_root).join("app/javascript/hotdocs.js"), <<~FILE)
  import "@hotwired/turbo-rails";
  import "controllers";

  import { application } from "controllers/application"
  import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
  eagerLoadControllersFrom("hotdocs/controllers", application)
FILE

importmap_path = Pathname(destination_root).join("config/importmap.rb")
append_to_file(importmap_path, %(pin "hotdocs", preload: "hotdocs"\n))
pin("lunr")

create_file(Pathname(destination_root).join("app/controllers/hotdocs_controller.rb"), <<~FILE)
  class HotdocsController < ApplicationController
    helper Hotdocs::Engine.helpers
    layout "hotdocs"
  end
FILE

create_file(Pathname(destination_root).join("app/views/layouts/hotdocs.html.erb"), <<~FILE)
  <% content_for :head do %>
    <%= content_for(:title, "HotDocs") unless content_for?(:title) %>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= stylesheet_link_tag "hotdocs/application" %>
    <%= stylesheet_link_tag "hotdocs/custom" %>
    <%= stylesheet_link_tag "hotdocs/rouge" %>
    <%= javascript_importmap_tags "hotdocs" %>
  <% end %>

  <%= content_for(:announcement) do %>
    <div class="announcement">This is an announcement at the top of the page</div>
  <% end if false %>

  <%= render template: "layouts/hotdocs/application" %>
FILE

create_file(Pathname(destination_root).join("app/views/hotdocs/index.html.mderb"), <<~FILE)
  <%= content_for(:title, "Welcome") %>

  # Welcome to HotDocs

  Find this markdown in `app/views/hotdocs/index.html.mderb`.

  ## Todos

  <input type="checkbox" id="first"><label for="first"> Update <code>app/views/layouts/hotdocs.html.erb</code></label>
  <input type="checkbox" id="second"><label for="second"> Update <code>app/helpers/hotdocs_helper.rb</code></label>
  <input type="checkbox" id="third"><label for="third"> Maybe read the docs: <a href="https://hotdocsrails.com/" target="_blank">hotdocsrails.com</a></label>
FILE

empty_directory "app/assets/images/hotdocs"
copy_file("app/assets/images/hotdocs/icon.svg", Pathname(destination_root).join("app/assets/images/hotdocs/hotdocs.svg"))

route "get '/hotdocs', to: 'hotdocs#index'"

create_file(Pathname(destination_root).join("app/helpers/hotdocs_helper.rb"), <<~FILE)
  module HotdocsHelper
    # @return [Logo, nil]
    def logo
      Struct.new(:src, :alt).new(asset_path("hotdocs/hotdocs.svg"), "A humanized and happy hot dog")
    end

    def title
      "HotDocs"
    end

    def nav_left_items(classes)
      [
        active_link_to("Docs", hotdocs_path, class: Array(classes))
      ]
    end

    def nav_right_items(classes)
      [
        external_link_to("GitHub", "https://github.com/3v0k4/hotdocs", class: Array(classes))
      ]
    end

    # { label: String, url?: [String, nil], children?: Array, expanded: Boolean }
    def menu_items
      [
        { label: "Welcome", url: hotdocs_path },
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

    def fetcher_host
      "http://127.0.0.1:3000"
    end

    def search_provider
      "lunr"
    end
  end
FILE

empty_directory "app/assets/stylesheets/hotdocs"

create_file(Pathname(destination_root).join("app/assets/stylesheets/hotdocs/custom.css"), <<~FILE)
  :root {
    --docs-code-background-color: #eee;
    --docs-code-border-color: #00000022;
    --docs-text-color: #1c1e21;
  }

  [data-theme=dark]:root {
    --docs-code-background-color: #2b2b2b;
    --docs-code-border-color: #ffffff22;
    --docs-text-color: #e3e1de;
  }

  .article {
    color: var(--docs-text-color);

    a {
      color: var(--docs-text-color);

      &:has(code) {
        text-underline-position: under;
        text-decoration-thickness: 1px;
      }
    }

    pre {
      -webkit-overflow-scrolling: touch;
      border-radius: .375rem;
      box-sizing: border-box;
      overflow-x: auto;
      width: 100%;
    }

    code:not(pre code) {
      background: var(--docs-code-background-color);
      border-radius: 0.375rem;
      border: .1rem solid var(--docs-code-border-color);
      display: inline;
      overflow-x: auto;
      overflow: auto;
      padding: 0.1rem 0.2rem;
      word-break: break-word;
    }
  }
FILE

create_file(Pathname(destination_root).join("app/assets/stylesheets/hotdocs/rouge.css"), <<~FILE)
  .article {
    .highlight .hll { background-color: #6e7681 }
    .highlight { background: #0d1117; color: #e6edf3 }
    .highlight .c { color: #8b949e; font-style: italic } /* Comment */
    .highlight .err { color: #f85149 } /* Error */
    .highlight .esc { color: #e6edf3 } /* Escape */
    .highlight .g { color: #e6edf3 } /* Generic */
    .highlight .k { color: #ff7b72 } /* Keyword */
    .highlight .l { color: #a5d6ff } /* Literal */
    .highlight .n { color: #e6edf3 } /* Name */
    .highlight .o { color: #ff7b72; font-weight: bold } /* Operator */
    .highlight .x { color: #e6edf3 } /* Other */
    .highlight .p { color: #e6edf3 } /* Punctuation */
    .highlight .ch { color: #8b949e; font-style: italic } /* Comment.Hashbang */
    .highlight .cm { color: #8b949e; font-style: italic } /* Comment.Multiline */
    .highlight .cp { color: #8b949e; font-weight: bold; font-style: italic } /* Comment.Preproc */
    .highlight .cpf { color: #8b949e; font-style: italic } /* Comment.PreprocFile */
    .highlight .c1 { color: #8b949e; font-style: italic } /* Comment.Single */
    .highlight .cs { color: #8b949e; font-weight: bold; font-style: italic } /* Comment.Special */
    .highlight .gd { color: #ffa198; background-color: #490202 } /* Generic.Deleted */
    .highlight .ge { color: #e6edf3; font-style: italic } /* Generic.Emph */
    .highlight .ges { color: #e6edf3; font-weight: bold; font-style: italic } /* Generic.EmphStrong */
    .highlight .gr { color: #ffa198 } /* Generic.Error */
    .highlight .gh { color: #79c0ff; font-weight: bold } /* Generic.Heading */
    .highlight .gi { color: #56d364; background-color: #0f5323 } /* Generic.Inserted */
    .highlight .go { color: #8b949e } /* Generic.Output */
    .highlight .gp { color: #8b949e } /* Generic.Prompt */
    .highlight .gs { color: #e6edf3; font-weight: bold } /* Generic.Strong */
    .highlight .gu { color: #79c0ff } /* Generic.Subheading */
    .highlight .gt { color: #ff7b72 } /* Generic.Traceback */
    .highlight .g-Underline { color: #e6edf3; text-decoration: underline } /* Generic.Underline */
    .highlight .kc { color: #79c0ff } /* Keyword.Constant */
    .highlight .kd { color: #ff7b72 } /* Keyword.Declaration */
    .highlight .kn { color: #ff7b72 } /* Keyword.Namespace */
    .highlight .kp { color: #79c0ff } /* Keyword.Pseudo */
    .highlight .kr { color: #ff7b72 } /* Keyword.Reserved */
    .highlight .kt { color: #ff7b72 } /* Keyword.Type */
    .highlight .ld { color: #79c0ff } /* Literal.Date */
    .highlight .m { color: #a5d6ff } /* Literal.Number */
    .highlight .s { color: #a5d6ff } /* Literal.String */
    .highlight .na { color: #e6edf3 } /* Name.Attribute */
    .highlight .nb { color: #e6edf3 } /* Name.Builtin */
    .highlight .nc { color: #f0883e; font-weight: bold } /* Name.Class */
    .highlight .no { color: #79c0ff; font-weight: bold } /* Name.Constant */
    .highlight .nd { color: #d2a8ff; font-weight: bold } /* Name.Decorator */
    .highlight .ni { color: #ffa657 } /* Name.Entity */
    .highlight .ne { color: #f0883e; font-weight: bold } /* Name.Exception */
    .highlight .nf { color: #d2a8ff; font-weight: bold } /* Name.Function */
    .highlight .nl { color: #79c0ff; font-weight: bold } /* Name.Label */
    .highlight .nn { color: #ff7b72 } /* Name.Namespace */
    .highlight .nx { color: #e6edf3 } /* Name.Other */
    .highlight .py { color: #79c0ff } /* Name.Property */
    .highlight .nt { color: #7ee787 } /* Name.Tag */
    .highlight .nv { color: #79c0ff } /* Name.Variable */
    .highlight .ow { color: #ff7b72; font-weight: bold } /* Operator.Word */
    .highlight .pm { color: #e6edf3 } /* Punctuation.Marker */
    .highlight .w { color: #6e7681 } /* Text.Whitespace */
    .highlight .mb { color: #a5d6ff } /* Literal.Number.Bin */
    .highlight .mf { color: #a5d6ff } /* Literal.Number.Float */
    .highlight .mh { color: #a5d6ff } /* Literal.Number.Hex */
    .highlight .mi { color: #a5d6ff } /* Literal.Number.Integer */
    .highlight .mo { color: #a5d6ff } /* Literal.Number.Oct */
    .highlight .sa { color: #79c0ff } /* Literal.String.Affix */
    .highlight .sb { color: #a5d6ff } /* Literal.String.Backtick */
    .highlight .sc { color: #a5d6ff } /* Literal.String.Char */
    .highlight .dl { color: #79c0ff } /* Literal.String.Delimiter */
    .highlight .sd { color: #a5d6ff } /* Literal.String.Doc */
    .highlight .s2 { color: #a5d6ff } /* Literal.String.Double */
    .highlight .se { color: #79c0ff } /* Literal.String.Escape */
    .highlight .sh { color: #79c0ff } /* Literal.String.Heredoc */
    .highlight .si { color: #a5d6ff } /* Literal.String.Interpol */
    .highlight .sx { color: #a5d6ff } /* Literal.String.Other */
    .highlight .sr { color: #79c0ff } /* Literal.String.Regex */
    .highlight .s1 { color: #a5d6ff } /* Literal.String.Single */
    .highlight .ss { color: #a5d6ff } /* Literal.String.Symbol */
    .highlight .bp { color: #e6edf3 } /* Name.Builtin.Pseudo */
    .highlight .fm { color: #d2a8ff; font-weight: bold } /* Name.Function.Magic */
    .highlight .vc { color: #79c0ff } /* Name.Variable.Class */
    .highlight .vg { color: #79c0ff } /* Name.Variable.Global */
    .highlight .vi { color: #79c0ff } /* Name.Variable.Instance */
    .highlight .vm { color: #79c0ff } /* Name.Variable.Magic */
    .highlight .il { color: #a5d6ff } /* Literal.Number.Integer.Long */
  }
FILE

empty_directory "app/assets/builds"
keep_file "app/assets/builds"
if Pathname(destination_root).join(".gitignore").exist?
  append_to_file(".gitignore", %(\n/app/assets/builds/*\n!/app/assets/builds/.keep\n))
end
