// Click-to-enlarge for pictures in the post text: images and drawn figures
// (inline SVG from cetz, diagrams, ...) show a zoom-in cursor, and a click,
// Enter or Space opens them scaled to the window. A click anywhere or Esc
// closes them. Equations, and images that are links, are left alone.
// Idempotent: safe to run more than once on the same page.
(() => {
  const targets = [
    ...document.querySelectorAll(".prose img, .prose :is(.svg-frame, .cetz) > svg, .prose figure svg"),
  ].filter(
    (el) =>
      !el.dataset.zoom &&
      !el.closest("a, .math-inline, .math-block") &&
      // Only the outermost <svg> of a drawing.
      !el.parentElement.closest("svg"),
  );
  if (!targets.length) return;

  let box = document.querySelector(".zoom");
  if (!box) {
    box = Object.assign(document.createElement("dialog"), { className: "zoom" });
    box.setAttribute("aria-label", "Enlarged figure");
    box.addEventListener("click", () => box.close());
    box.addEventListener("close", () => box.replaceChildren());
    document.body.append(box);
  }

  const open = (el) => {
    // Fit the window. Drawings scale freely; images stop at their own
    // resolution, but never shrink below their size on the page.
    const r = el.getBoundingClientRect();
    if (!r.width || !r.height) return;
    let scale = Math.min((innerWidth * 0.94) / r.width, (innerHeight * 0.88) / r.height);
    if (el instanceof HTMLImageElement && el.naturalWidth) {
      scale = Math.min(scale, Math.max(1, el.naturalWidth / r.width));
    }

    const copy = el.cloneNode(true);
    for (const a of ["data-zoom", "tabindex", "role", "aria-label", "loading"]) copy.removeAttribute(a);
    copy.style.width = `${r.width * scale}px`;
    copy.style.height = `${r.height * scale}px`;
    const close = Object.assign(document.createElement("button"), { type: "button", className: "zoom-close label" });
    close.textContent = "Close ✕";
    box.replaceChildren(close, copy);
    box.showModal();
  };

  for (const el of targets) {
    el.dataset.zoom = "1";
    el.setAttribute("tabindex", "0");
    el.setAttribute("role", "button");
    const alt = el.getAttribute("alt");
    el.setAttribute("aria-label", alt ? `Enlarge: ${alt}` : "Enlarge figure");
    el.addEventListener("click", () => open(el));
    el.addEventListener("keydown", (e) => {
      if (e.key !== "Enter" && e.key !== " ") return;
      e.preventDefault();
      open(el);
    });
  }
})();
