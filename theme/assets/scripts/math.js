// Inline formulas are SVG, and browsers may break the line between one and
// the comma or full stop after it, starting the next line with punctuation.
// Each formula followed by closing punctuation is wrapped with it in a span
// that does not break (site.css `.math-nobreak`).
// Idempotent: safe to run more than once on the same page.
(() => {
  const punct = /^[,.;:!?)\]}”’，。；：！？、）」』》]+/;
  for (const el of document.querySelectorAll(".math-inline")) {
    if (el.parentElement.classList.contains("math-nobreak")) continue;
    const next = el.nextSibling;
    const run = next?.nodeType === Node.TEXT_NODE && next.data.match(punct);
    if (!run) continue;
    const wrap = Object.assign(document.createElement("span"), { className: "math-nobreak" });
    el.before(wrap);
    next.data = next.data.slice(run[0].length);
    wrap.append(el, run[0]);
  }
})();
