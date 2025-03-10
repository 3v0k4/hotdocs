// Run with:
// deno --allow-read --allow-env --node-modules-dir=auto config/initializers/markdown.mjs

import remarkParse from "npm:remark-parse";
import remarkPrism from "npm:remark-prism";
import remarkRehype from "npm:remark-rehype";
import rehypeStringify from "npm:rehype-stringify";
import { unified } from "npm:unified";

process.stdin.on("data", async (data) => {
  try {
    const file = await unified()
      .use(remarkParse)
      .use(remarkDirective)
      .use(remarkAdmonitions)
      .use(remarkPrism)
      // `allowDangerousHtml` to avoid sanitizing the raw Html from `data`
      .use(remarkRehype, { allowDangerousHtml: true })
      .use(rehypeStringify, { allowDangerousHtml: true })
      .process(data);
    process.stdout.write(String(file));
  } catch (error) {
    console.error(`Error: ${error.message}\nStack trace:\n${error.stack}`);
    process.stdout.write(
      `Error: ${error.message}<br />Stack trace:\n${error.stack}`
    );
  }
});

const ADMONITIONS = {
  tip: {
    svg: {
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewBox: "0 0 24 24",
      strokeWidth: "1.5",
      stroke: "currentColor",
    },
    paths: [
      {
        strokeLinecap: "round",
        strokeLinejoin: "round",
        d: "M12 18v-5.25m0 0a6.01 6.01 0 0 0 1.5-.189m-1.5.189a6.01 6.01 0 0 1-1.5-.189m3.75 7.478a12.06 12.06 0 0 1-4.5 0m3.75 2.383a14.406 14.406 0 0 1-3 0M14.25 18v-.192c0-.983.658-1.823 1.508-2.316a7.5 7.5 0 1 0-7.517 0c.85.493 1.509 1.333 1.509 2.316V18",
      },
    ],
  },
  info: {
    svg: {
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewBox: "0 0 24 24",
      strokeWidth: "1.5",
      stroke: "currentColor",
    },
    paths: [
      {
        strokeLinecap: "round",
        strokeLinejoin: "round",
        d: "m11.25 11.25.041-.02a.75.75 0 0 1 1.063.852l-.708 2.836a.75.75 0 0 0 1.063.853l.041-.021M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9-3.75h.008v.008H12V8.25Z",
      },
    ],
  },
  warning: {
    svg: {
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewBox: "0 0 24 24",
      strokeWidth: "1.5",
      stroke: "currentColor",
    },
    paths: [
      {
        strokeLinecap: "round",
        strokeLinejoin: "round",
        d: "M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z",
      },
    ],
  },
  danger: {
    svg: {
      xmlns: "http://www.w3.org/2000/svg",
      fill: "none",
      viewBox: "0 0 24 24",
      strokeWidth: "1.5",
      stroke: "currentColor",
    },
    paths: [
      {
        strokeLinecap: "round",
        strokeLinejoin: "round",
        d: "M15.362 5.214A8.252 8.252 0 0 1 12 21 8.25 8.25 0 0 1 6.038 7.047 8.287 8.287 0 0 0 9 9.601a8.983 8.983 0 0 1 3.361-6.867 8.21 8.21 0 0 0 3 2.48Z",
      },
      {
        strokeLinecap: "round",
        strokeLinejoin: "round",
        d: "M12 18a3.75 3.75 0 0 0 .495-7.468 5.99 5.99 0 0 0-1.925 3.547 5.975 5.975 0 0 1-2.133-1.001A3.75 3.75 0 0 0 12 18Z",
      },
    ],
  },
};

import { directiveFromMarkdown } from "npm:mdast-util-directive";
import { directive } from "npm:micromark-extension-directive";

function remarkDirective() {
  const self = this;
  const data = self.data();

  const micromarkExtensions =
    data.micromarkExtensions || (data.micromarkExtensions = []);
  const fromMarkdownExtensions =
    data.fromMarkdownExtensions || (data.fromMarkdownExtensions = []);

  const directiveContainer = directive();
  // From:
  // {
  //   text: {[codes.colon]: directiveText},
  //   flow: {[codes.colon]: [directiveContainer, directiveLeaf]}
  // }
  // To:
  // {
  //   text: {},
  //   flow: {[codes.colon]: [directiveContainer]}
  // }
  directiveContainer.text = {};
  directiveContainer.flow[Object.keys(directiveContainer.flow)[0]].pop();

  micromarkExtensions.push(directiveContainer);
  fromMarkdownExtensions.push(directiveFromMarkdown());
}

import { h, s } from "npm:hastscript";
import { visit } from "npm:unist-util-visit";

function remarkAdmonitions() {
  return (tree) => {
    visit(tree, (node) => {
      if (node.type === "containerDirective") {
        const level = node.name;
        const admonition = ADMONITIONS[level];
        if (!admonition) return;

        const svg = s(
          "svg.admonition__icon",
          admonition.svg,
          admonition.paths.map((path) => s("path", path))
        );

        const label = h("span.admonition__label", level.toLocaleUpperCase());
        const header = h("div", { class: "admonition__header" }, [svg, label]);
        const content = h("div", { class: "admonition__content" }, [
          ...node.children,
        ]);

        node.tagName = "div";
        node.properties = h("div", {
          class: `admonition admonition--${level}`,
        }).properties;
        node.children = [header, content];

        const decorateHast = (node) => {
          Object.assign(node.data ?? (node.data = {}), {
            hName: node.tagName,
            hProperties: node.properties,
          });

          if (node.children && Array.isArray(node.children)) {
            node.children.forEach(decorateHast);
          }
        };

        decorateHast(node);
      }
    });
  };
}
