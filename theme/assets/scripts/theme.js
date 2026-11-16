// Day / night toggle in the header. The inline script in <head> (layout.typ)
// sets data-theme on <html> before the first paint; this wires the button,
// remembers the reader's pick, and follows the system setting until then.
(() => {
  const root = document.documentElement;
  const button = document.querySelector(".theme-toggle");
  const system = matchMedia("(prefers-color-scheme: dark)");
  const stored = () => {
    try { return localStorage.getItem("theme"); } catch { return null; }
  };

  const apply = (theme) => {
    root.dataset.theme = theme;
    button?.setAttribute("aria-pressed", String(theme === "dark"));
  };

  apply(root.dataset.theme === "dark" ? "dark" : "light");
  system.addEventListener("change", (e) => {
    if (!stored()) apply(e.matches ? "dark" : "light");
  });
  button?.addEventListener("click", () => {
    const theme = root.dataset.theme === "dark" ? "light" : "dark";
    try { localStorage.setItem("theme", theme); } catch {}
    // Cross-fade where the browser can, unless the reader asked for less motion.
    const still = matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (document.startViewTransition && !still) document.startViewTransition(() => apply(theme));
    else apply(theme);
  });
})();
