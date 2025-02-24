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
