// Footnote and term previews: hovering or focusing a note ref or a term
// (`term` in utils/ui.typ) shows the note or definition in a popover. Touch
// screens skip it; the link still leads down to the Notes or Terms section.
// Idempotent: safe to run more than once on the same page.
(() => {
  const refs = [...document.querySelectorAll(":is(.fn-ref a, a.term-ref):not([data-bound])")];
  if (!refs.length || matchMedia("(hover: none)").matches) return;

  let tip = document.querySelector(".fn-tip");
  if (!tip) {
    tip = Object.assign(document.createElement("div"), { className: "fn-tip", hidden: true });
    tip.setAttribute("role", "tooltip");
    document.body.append(tip);
  }
  let hideTimer;

  const show = (a) => {
    const note = document.getElementById(decodeURIComponent(a.hash.slice(1)));
    if (!note) return;
    clearTimeout(hideTimer);
    const head = Object.assign(document.createElement("div"), { className: "label accent" });
    const isTerm = a.classList.contains("term-ref");
    head.textContent = isTerm ? `Term / ${a.textContent}` : `Note ${a.textContent}`;
    // A term's entry is a <dt> and a <dd>: the popover shows the <dd>'s text.
    const body = (isTerm ? note.querySelector("dd") : note).cloneNode(true);
    body.removeAttribute("id");
    body.querySelector(".fn-back")?.remove();
    tip.replaceChildren(head, ...body.childNodes);
    tip.hidden = false;

    // Below the ref, clamped to the viewport; above it if there is no room.
    const r = a.getBoundingClientRect();
    const w = tip.offsetWidth;
    const h = tip.offsetHeight;
    const left = Math.min(Math.max(r.left - 16, 16), innerWidth - w - 16);
    const top = r.bottom + 8 + h > innerHeight ? r.top - 8 - h : r.bottom + 8;
    tip.style.left = `${left + scrollX}px`;
    tip.style.top = `${top + scrollY}px`;
  };
  // A short delay lets the pointer travel from the ref into the popover.
  const hide = () => {
    hideTimer = setTimeout(() => (tip.hidden = true), 120);
  };

  for (const a of refs) {
    a.dataset.bound = "1";
    a.addEventListener("mouseenter", () => show(a));
    a.addEventListener("focus", () => show(a));
    a.addEventListener("mouseleave", hide);
    a.addEventListener("blur", hide);
  }
  tip.addEventListener("mouseenter", () => clearTimeout(hideTimer));
  tip.addEventListener("mouseleave", hide);
})();
