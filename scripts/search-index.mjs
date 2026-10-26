// The `search` build hook (tola.toml): Pagefind indexes the compiled pages
// for /search/. Runs through Pagefind's Node API rather than a shell command,
// so the same hook works on Linux, macOS and Windows.
import { join } from "node:path";

// Pagefind detects the language from each page's `lang`; set an ISO 639-1
// code such as "zh" to index the whole site as one language instead.
const forceLanguage = undefined;

const fail = (message) => {
  console.error(message);
  process.exit(1);
};

let pagefind;
try {
  pagefind = await import("pagefind");
} catch {
  fail("Pagefind is not installed: run `npm install` in the site root, then run tola again.");
}

const { TOLA_HOOK_INPUT_DIR: site, TOLA_HOOK_OUTPUT_DIR: out } = process.env;
if (!site || !out) fail("Run by Tola as the `search` build hook; use `tola build`.");

const check = ({ errors }) => {
  if (errors.length) fail(errors.join("\n"));
};

try {
  const created = await pagefind.createIndex({ forceLanguage });
  check(created);
  const { index } = created;
  const added = await index.addDirectory({ path: site });
  check(added);
  check(await index.writeFiles({ outputPath: join(out, "pagefind") }));
  console.log(`Indexed ${added.page_count} pages`);
} finally {
  await pagefind.close();
}
