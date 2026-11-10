// The `search` build hook (tola-module.toml): Pagefind indexes the compiled
// pages for /search/. Runs through Pagefind's Node API rather than a shell
// command, so the same hook works on Linux, macOS and Windows.
import { existsSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { pathToFileURL } from "node:url";

const fail = (message) => {
  console.error(message);
  process.exit(1);
};

const {
  TOLA_HOOK_INPUT_DIR: site,
  TOLA_HOOK_OUTPUT_DIR: out,
  TOLA_PROJECT_ROOT: root,
  TOLA_MODULE_OPTIONS: optionsFile,
} = process.env;
if (!site || !out || !root) fail("Run by Tola as the theme's `search` build hook; use `tola build`.");

// Pagefind detects the language from each page's `lang`. The
// `search-language` option, an ISO 639-1 code such as "zh", indexes the whole
// site as that one language instead.
const options = optionsFile ? JSON.parse(readFileSync(optionsFile, "utf8")) : {};
const forceLanguage = options["search-language"] || undefined;

// Pagefind belongs to the site, not the theme: the theme may be read from
// Tola's module cache, which has no node_modules. Looked up the way Node
// resolves a bare import from the site root; Pagefind is an ES module only.
const findPagefind = () => {
  for (let dir = root; ; dir = dirname(dir)) {
    const pkg = join(dir, "node_modules", "pagefind");
    if (existsSync(join(pkg, "package.json"))) {
      const manifest = JSON.parse(readFileSync(join(pkg, "package.json"), "utf8"));
      const entry = manifest.exports?.["."]?.import ?? manifest.main ?? "index.js";
      return join(pkg, entry);
    }
    if (dirname(dir) === dir) return null;
  }
};
const entry = findPagefind();
if (!entry) fail("Pagefind is not installed: run `npm install pagefind` in the site root, or set `search = false` in the theme options.");
const pagefind = await import(pathToFileURL(entry).href);

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
