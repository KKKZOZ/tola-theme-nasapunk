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
    // The note already sits in the margin beside this line (below).
    if (a.sidenote?.offsetParent) return;
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

  // Sidenotes: on windows with a left margin (assets/styles/toc-float.css
  // shows the container), each footnote is also set beside the line that
  // cites it, moved down past the note or the section number above it.
  const body = document.querySelector(".post-body");
  const notes = refs.filter((a) => !a.classList.contains("term-ref") && a.closest(".post-body"));
  if (body && notes.length) {
    const side = Object.assign(document.createElement("aside"), { className: "sidenotes" });
    side.setAttribute("aria-hidden", "true"); // the Notes section has them
    for (const a of notes) {
      const note = document.getElementById(decodeURIComponent(a.hash.slice(1)));
      if (!note) continue;
      const el = Object.assign(document.createElement("div"), { className: "sidenote" });
      const num = Object.assign(document.createElement("span"), { className: "sidenote-num" });
      num.textContent = a.textContent;
      const copy = note.cloneNode(true);
      copy.querySelector(".fn-back")?.remove();
      for (const n of copy.querySelectorAll("[id]")) n.removeAttribute("id");
      el.append(num, ...copy.childNodes);
      side.append(el);
      a.sidenote = el;
    }
    body.append(side);
    const place = () => {
      if (getComputedStyle(side).display === "none") return;
      const top = body.getBoundingClientRect().top;
      // Hanging section numbers share the margin: [top, bottom] of each.
      const taken = [...body.querySelectorAll(".prose > h2 > .heading-num")].map((n) => {
        const r = n.getBoundingClientRect();
        return [r.top - top - 8, r.bottom - top + 8];
      });
      let floor = 0;
      for (const a of notes) {
        const el = a.sidenote;
        if (!el) continue;
        // A ref inside a shut fold has no box: its note waits for the fold.
        el.hidden = !a.getClientRects().length;
        if (el.hidden) continue;
        let y = Math.max(a.getBoundingClientRect().top - top - 4, floor);
        for (const [t, b] of taken) if (y < b && y + el.offsetHeight > t) y = b;
        el.style.top = `${y}px`;
        floor = y + el.offsetHeight + 10;
      }
    };
    place();
    addEventListener("resize", place, { passive: true });
    addEventListener("load", place);
    document.addEventListener("toggle", place, true);
    document.fonts?.ready.then(place);
  }

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
