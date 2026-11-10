// Reading aids on post pages: the top progress bar, and the ToC as a
// checklist (sections already passed are done, the current one is active).
// Idempotent: safe to run more than once on the same page.
(() => {
  const bar = document.querySelector(".read-progress");
  const prose = document.querySelector(".post .prose");
  // [link, heading] pairs in document order.
  const entries = [...document.querySelectorAll(".toc-list a[href^='#']")]
    .map((a) => [a, document.getElementById(decodeURIComponent(a.hash.slice(1)))])
    .filter(([, h]) => h);
  if (!(bar && prose) && !entries.length) return;

  const update = () => {
    if (bar && prose) {
      // 0 when the text starts at the top edge, 1 when its end reaches the bottom.
      const r = prose.getBoundingClientRect();
      const span = r.height - innerHeight;
      const p = span > 0 ? Math.min(Math.max(-r.top / span, 0), 1) : 1;
      bar.style.transform = `scaleX(${p})`;
    }
    if (entries.length) {
      // Last heading above the top fifth of the viewport wins.
      const line = innerHeight * 0.2;
      let current = 0;
      entries.forEach(([, h], i) => {
        if (h.getBoundingClientRect().top <= line) current = i;
      });
      // Short final sections never reach the line; at the bottom, pick the last.
      const root = document.documentElement;
      if (innerHeight + scrollY >= root.scrollHeight - 2) current = entries.length - 1;
      entries.forEach(([a], i) => {
        a.classList.toggle("is-active", i === current);
        a.classList.toggle("is-done", i < current);
      });
    }
  };

  // A handful of getBoundingClientRect calls per scroll event is cheap enough.
  addEventListener("scroll", update, { passive: true });
  addEventListener("resize", update, { passive: true });
  update();
})();
