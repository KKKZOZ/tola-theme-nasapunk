// `npm test`: runs the cases in tests/latex.typ, which check the LaTeX a
// copied formula carries (templates/latex.typ), and lists the ones that fail.
// Needs the Typst CLI, the version the supported Tola release builds with.
import { execFileSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

// The theme's root: its files import each other by package-absolute paths.
const theme = join(dirname(fileURLToPath(import.meta.url)), "..");

let cases;
try {
  const out = execFileSync(
    "typst",
    ["eval", "query(<case>).map(it => it.value)", "--in", join(theme, "tests", "latex.typ"), "--root", theme],
    { encoding: "utf8", stdio: ["ignore", "pipe", "inherit"] },
  );
  cases = JSON.parse(out);
} catch (e) {
  console.error(e.code === "ENOENT" ? "The Typst CLI is not installed: https://github.com/typst/typst" : e.message);
  process.exit(1);
}

const show = ({ latex, issues }) => (issues.length ? `${latex}  (issues: ${issues.join(", ")})` : latex);
const failed = cases.filter((c) => !c.ok);
for (const c of failed) {
  console.log(`FAIL [${c.section}] ${c.src}\n  want: ${show(c.want)}\n  got:  ${show(c.got)}\n`);
}
console.log(`${cases.length - failed.length} passed, ${failed.length} failed`);
process.exit(failed.length ? 1 : 0);
