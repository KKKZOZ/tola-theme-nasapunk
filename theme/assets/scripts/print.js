// Printing, or saving as PDF: the page prints in the day theme, with folded
// panels (`fold`) open, as the print styles in site.css expect, and a post
// gets a running header and footer: its number and title at the top, its
// address at the bottom (the page count is in site.css). All goes back as it
// was once the print dialog closes.
// Idempotent: safe to run more than once on the same page.
(() => {
  if (document._printBound) return;
  document._printBound = true;

  const root = document.documentElement;
  let theme, opened = [], margins;

  // A CSS string: margin boxes take their text from `content`.
  const str = (s) => JSON.stringify(s.replace(/\s+/g, " ").trim());

  const runningHead = () => {
    const post = document.querySelector("article.post");
    if (!post) return null;
    const title = post.querySelector("h1")?.textContent ?? "";
    const site = document.title.split(" | ").pop();
    const head = [post.dataset.doc, title].filter(Boolean).join(" / ");
    const box = 'font: 500 8pt/1 "IBM Plex Mono", monospace; letter-spacing: .08em; color: #65716f;';
    const style = document.createElement("style");
    style.textContent = `@media print { @page {
      @top-left { content: ${str(head)}; ${box} text-transform: uppercase; }
      @top-right { content: ${str(site)}; ${box} text-transform: uppercase; color: #cb4b22; }
      @bottom-left { content: ${str(location.href.split("#")[0])}; ${box} letter-spacing: 0; }
    } }`;
    return document.head.appendChild(style);
  };

  addEventListener("beforeprint", () => {
    theme = root.dataset.theme;
    root.dataset.theme = "light";
    opened = [...document.querySelectorAll("details.fold:not([open])")];
    for (const d of opened) d.open = true;
    margins ??= runningHead();
  });

  addEventListener("afterprint", () => {
    if (theme) root.dataset.theme = theme;
    for (const d of opened) d.open = false;
    opened = [];
    margins?.remove();
    margins = null;
  });
})();
