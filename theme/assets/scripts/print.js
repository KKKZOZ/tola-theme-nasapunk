// Printing, or saving as PDF: the page prints in the day theme, with folded
// panels (`fold`, a series' "All parts") open, as the print styles in
// site.css expect. Both go back as they were once the print dialog closes.
// Idempotent: safe to run more than once on the same page.
(() => {
  if (document._printBound) return;
  document._printBound = true;

  const root = document.documentElement;
  let theme, opened = [];

  addEventListener("beforeprint", () => {
    theme = root.dataset.theme;
    root.dataset.theme = "light";
    opened = [...document.querySelectorAll("details:is(.fold, .series-all):not([open])")];
    for (const d of opened) d.open = true;
  });

  addEventListener("afterprint", () => {
    if (theme) root.dataset.theme = theme;
    for (const d of opened) d.open = false;
    opened = [];
  });
})();
