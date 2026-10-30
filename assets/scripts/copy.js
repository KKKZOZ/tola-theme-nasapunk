// Copy buttons on code blocks, click-to-copy heading anchors, and LaTeX
// for formulas in a copied selection.
// Idempotent: safe to run more than once on the same page.
(() => {
  const copy = async (text) => {
    try {
      await navigator.clipboard.writeText(text);
    } catch {
      // Clipboard API needs a secure context; fall back to a hidden textarea.
      const t = Object.assign(document.createElement("textarea"), { value: text });
      t.style.cssText = "position:fixed;opacity:0";
      document.body.append(t);
      t.select();
      document.execCommand("copy");
      t.remove();
    }
  };

  // Flag an element as copied for a moment (CSS shows the feedback);
  // `label` temporarily replaces its text.
  const flash = (el, label) => {
    el._label ??= el.textContent;
    if (label) el.textContent = label;
    el.classList.add("is-copied");
    clearTimeout(el._copyTimer);
    el._copyTimer = setTimeout(() => {
      el.classList.remove("is-copied");
      el.textContent = el._label;
    }, 1500);
  };

  for (const btn of document.querySelectorAll(".code-copy")) {
    if (btn.dataset.bound) continue;
    btn.dataset.bound = "1";
    btn.hidden = false;
    btn.addEventListener("click", () => {
      // innerText turns the <br> line breaks of highlighted code into "\n".
      copy(btn.closest(".code-block").querySelector("pre").innerText);
      flash(btn, "Copied");
    });
  }

  // Formulas render as SVG, which has no text to copy: a selection that
  // touches one copies its LaTeX (`data-latex`) instead. Typst formulas carry
  // LaTeX made from them (templates/latex.typ); a formula from
  // utils/mitex.typ sits in a wrapper with its own source, which wins.
  // A formula with parts LaTeX has no counterpart for copies as a placeholder
  // (`data-latex-issues` names the parts), and a tip at the foot of the
  // window says so.
  if (!document._latexCopy) {
    document._latexCopy = true;
    // The element a formula copies from: a mitex wrapper around it wins.
    const outermost = (el) => {
      while (el.parentElement?.closest("[data-latex]")) el = el.parentElement.closest("[data-latex]");
      return el;
    };
    let copied;
    const tex = (el) => {
      copied.push(el);
      return el.tagName === "DIV" ? `$$${el.dataset.latex}$$` : `$${el.dataset.latex}$`;
    };

    let tip, hideTimer;
    const warn = (rough) => {
      if (!tip) {
        tip = Object.assign(document.createElement("div"), { className: "latex-tip", hidden: true });
        tip.setAttribute("role", "status");
        tip.addEventListener("click", () => (tip.hidden = true));
        document.body.append(tip);
      }
      const issues = [...new Set(rough.flatMap((el) => el.dataset.latexIssues.split(", ")))];
      const head = Object.assign(document.createElement("div"), { className: "label accent" });
      head.textContent = "LaTeX / unsupported";
      const body = document.createElement("p");
      const count = rough.length === 1 ? "1 formula" : `${rough.length} formulas`;
      body.textContent = `${count} could not be converted to LaTeX (${issues.join(", ")}) and copied as ${rough[0].dataset.latex}.`;
      tip.replaceChildren(head, body);
      tip.hidden = false;
      clearTimeout(hideTimer);
      hideTimer = setTimeout(() => (tip.hidden = true), 6000);
    };

    document.addEventListener("copy", (e) => {
      const sel = getSelection();
      if (!sel.rangeCount || sel.isCollapsed) return;
      const range = sel.getRangeAt(0);
      const node = range.commonAncestorContainer;
      let within = (node.nodeType === 1 ? node : node.parentElement).closest("[data-latex]");
      if (within) within = outermost(within);
      const box = document.createElement("div");
      copied = [];
      if (within) {
        box.textContent = tex(within);
      } else {
        box.append(range.cloneContents());
        const maths = box.querySelectorAll("[data-latex]");
        if (!maths.length) return;
        // Partly selected formulas are cloned with their attribute too. In
        // document order, an outer formula is replaced before its inner one.
        for (const m of maths) if (box.contains(m)) m.replaceWith(tex(m));
      }
      // innerText needs the box laid out to turn blocks into line breaks.
      box.style.cssText = "position:fixed;left:-9999px;top:0";
      document.body.append(box);
      e.clipboardData.setData("text/plain", box.innerText);
      e.clipboardData.setData("text/html", box.innerHTML);
      box.remove();
      e.preventDefault();
      const rough = copied.filter((el) => el.dataset.latexIssues);
      if (rough.length) warn(rough);
    });

    // Browsers paint no selection over SVG, so formulas in the selection get
    // `is-selected` (site.css) instead.
    let marked = [];
    document.addEventListener("selectionchange", () => {
      for (const el of marked) el.classList.remove("is-selected");
      marked = [];
      const sel = getSelection();
      if (!sel.rangeCount || sel.isCollapsed) return;
      const range = sel.getRangeAt(0);
      marked = [...document.querySelectorAll('[role="math"]')].filter((el) => range.intersectsNode(el));
      for (const el of marked) el.classList.add("is-selected");
    });

    // A double click selects the whole formula, ready to copy.
    document.addEventListener("dblclick", (e) => {
      const math = e.target.closest?.('[role="math"]');
      if (!math) return;
      const range = document.createRange();
      range.selectNode(outermost(math));
      getSelection().removeAllRanges();
      getSelection().addRange(range);
    });
  }

  // Anchors still navigate as plain links; the full URL is copied on top.
  for (const a of document.querySelectorAll(".heading-anchor")) {
    if (a.dataset.bound) continue;
    a.dataset.bound = "1";
    a.addEventListener("click", () => {
      copy(a.href);
      flash(a);
    });
  }
})();
