// Keyboard palette: one dialog, three lists, picked by how the query starts,
// as in an editor's quick-open box.
//   Cmd/Ctrl + K          search the site (Pagefind, as on /search/)
//   Cmd/Ctrl + Shift + P  ">" commands: go to a page, switch theme, ...
//   Cmd/Ctrl + Shift + O  "@" sections of this page, and its captioned figures
//   ?                     "?" the keys themselves
// A shortcut the browser keeps for itself never reaches the page; the other
// lists are still a prefix away.
//
// Single keys, outside the palette and any text box:
//   j / k   next / previous entry of a list (home, archive, tags, search)
//   [ / ]   previous / next post, or page of the home list
(() => {
  // This file is <base>/assets/scripts/palette.js: the site root is two up.
  const root = new URL("../../", document.currentScript.src);
  const mac = /Mac|iPhone|iPad/.test(navigator.platform);
  const LIMIT = 8;
  const MODES = {
    // The prompt is a bare word; a rule drawn in CSS divides it from the
    // input, so no character in it reads like the `>` prefix.
    ">": { prompt: "Command", placeholder: "go to, switch theme …", empty: "No such command" },
    "@": { prompt: "Section", placeholder: "heading or figure on this page …", empty: "No sections match" },
    "?": { prompt: "Keys", placeholder: "shortcut …", empty: "No such key" },
    "": { prompt: "Query", placeholder: "keywords, 关键词 …", empty: "No signal: nothing matches" },
  };

  const el = (tag, props, ...children) => {
    const node = Object.assign(document.createElement(tag), props);
    node.append(...children);
    return node;
  };

  let dialog, input, prompt, list, status;
  let items = [];
  let active = 0;
  let pagefind; // promise of the Pagefind module, or of null without an index
  let ticket = 0; // drops search results a newer keystroke has overtaken

  const modeOf = (value) => (">@?".includes(value[0] ?? " ") ? value[0] : "");

  // --------------------------------------------------------------------------
  // Lists
  // --------------------------------------------------------------------------

  /// Rank of `text` for `query`: a substring beats letters in order; -1 is no match.
  const rank = (text, query) => {
    const [t, q] = [text.toLowerCase(), query.toLowerCase()];
    if (!q) return 0;
    const at = t.indexOf(q);
    if (at >= 0) return at;
    let from = 0;
    for (const ch of q) {
      from = t.indexOf(ch, from) + 1;
      if (!from) return -1;
    }
    return 1000 + from;
  };

  const filter = (all, query) =>
    all
      .map((item) => ({ item, score: rank(item.title, query) }))
      .filter((x) => x.score >= 0)
      .sort((a, b) => a.score - b.score)
      .map((x) => x.item);

  /// Headings, and the figures and tables that have a caption, in page order.
  const sections = () =>
    [...document.querySelectorAll("main :is(h2, h3, h4, h5, h6)[id], main figure:has(> figcaption > .figure-num)")].map((h) => {
      if (h.tagName === "FIGURE") {
        const text = h.querySelector("figcaption").cloneNode(true);
        const num = text.querySelector(".figure-num");
        num.remove();
        const title = text.textContent.replace(/^[\s—]+/, "").trim();
        if (!title) return null;
        return { title, hint: num.textContent, run: () => h.scrollIntoView() };
      }
      const text = h.cloneNode(true);
      // The number of a post section, or the code of a listing one ("CH-01").
      const num = text.querySelector(".heading-num, .index-heading-code")?.textContent ?? "";
      text.querySelectorAll(".heading-num, .index-heading-code, .heading-anchor, .label").forEach((x) => x.remove());
      return {
        title: text.textContent.trim() || h.id,
        hint: num,
        run: () => {
          history.pushState(null, "", "#" + h.id);
          h.scrollIntoView();
        },
      };
    }).filter(Boolean);

  /// Copy the text at `url`. The clipboard write starts in the keypress's own
  /// task with the text still loading, as a ClipboardItem of a promise:
  /// Safari refuses a write that only starts after an `await`.
  const copyFrom = (url) => {
    const text = fetch(url).then((r) => (r.ok ? r.text() : Promise.reject(new Error(`${r.status} ${url}`))));
    const write =
      window.ClipboardItem && navigator.clipboard?.write
        ? navigator.clipboard
            .write([new ClipboardItem({ "text/plain": text.then((t) => new Blob([t], { type: "text/plain" })) })])
            .catch(() => text.then((t) => navigator.clipboard.writeText(t)))
        : text.then((t) => navigator.clipboard?.writeText(t));
    write.catch((e) => console.warn("Copy failed:", e));
  };

  const commands = () => {
    const out = [];
    const post = document.querySelector("article.post");
    if (post) {
      const near = (cls, name) => {
        const a = post.querySelector(".post-nav a." + cls);
        const title = a?.querySelector(".post-nav-title")?.textContent;
        if (a) out.push({ title: `${name} post: ${title}`, hint: "Post", href: a.href });
      };
      near("next", "Next");
      near("prev", "Previous");
    }
    if (sections().length) out.push({ title: "Go to section …", hint: "@", run: () => reopen("@"), stay: true });
    out.push({ title: "Search the site …", hint: mac ? "⌘K" : "Ctrl K", run: () => reopen(""), stay: true });
    for (const a of document.querySelectorAll(".site-nav a")) {
      out.push({ title: "Go to " + a.textContent.trim(), hint: "Page", href: a.href });
    }
    const toggle = document.querySelector(".theme-toggle");
    if (toggle && document.documentElement.dataset.theme) {
      const next = document.documentElement.dataset.theme === "dark" ? "day" : "night";
      out.push({ title: `Switch to ${next} theme`, hint: "View", run: () => toggle.click() });
    }
    out.push({ title: "Back to top", hint: "View", run: () => scrollTo({ top: 0 }) });
    out.push({
      title: "Copy link to this page",
      hint: "Share",
      run: () => navigator.clipboard?.writeText(location.href.split("#")[0]),
    });
    // The page's Typst source, when the site publishes it (templates/agents.typ).
    const source = document.querySelector('link[rel="alternate"][type="text/plain"]');
    if (source) {
      out.push({ title: "Copy Typst source of this page", hint: "Share", run: () => copyFrom(source.href) });
      // `href` of the element is absolute: a link to hand to an agent.
      out.push({ title: "Copy link to Typst source", hint: "Share", run: () => navigator.clipboard?.writeText(source.href) });
    }
    if (post) {
      const cite = (format) => () => document.dispatchEvent(new CustomEvent("nasapunk:cite", { detail: format }));
      out.push({ title: "Copy citation", hint: "Share", run: cite("text") });
      out.push({ title: "Copy citation as BibTeX", hint: "Share", run: cite("bibtex") });
      out.push({ title: "Print this post", hint: "Share", run: () => setTimeout(() => print(), 50) });
    }
    out.push({ title: "Keyboard shortcuts …", hint: "?", run: () => reopen("?"), stay: true });
    return out;
  };

  const mod = mac ? "⌘" : "Ctrl ";
  const keys = () => [
    { title: "Search the site", hint: mod + "K", run: () => reopen(""), stay: true },
    { title: "Commands", hint: mod + (mac ? "⇧P" : "Shift P"), run: () => reopen(">"), stay: true },
    { title: "Sections and figures of this page", hint: mod + (mac ? "⇧O" : "Shift O"), run: () => reopen("@"), stay: true },
    { title: "Next / previous entry of a list", hint: "J / K", run: () => step(1) },
    { title: "Previous / next post or page", hint: "[ / ]", run: () => {} },
    { title: "This list", hint: "?", run: () => {}, stay: true },
  ];

  // --------------------------------------------------------------------------
  // Single keys
  // --------------------------------------------------------------------------

  /// Move the focus `by` entries along the page's list of posts.
  const step = (by) => {
    const links = [...document.querySelectorAll(".entry-item > a, .index-list li > a, .search-results li > a")];
    if (!links.length) return;
    const at = links.indexOf(document.activeElement);
    const next = links[at < 0 ? 0 : Math.min(Math.max(at + by, 0), links.length - 1)];
    next.focus({ focusVisible: true });
    next.scrollIntoView({ block: "nearest" });
  };

  /// Follow the page's link to the previous (-1) or next (1) post or page.
  const turn = (by) => {
    const a = document.querySelector(by < 0 ? ".post-nav a.prev, .pager a.prev" : ".post-nav a.next, .pager a.next");
    if (a) location.href = a.href;
  };

  const search = async (query) => {
    pagefind ??= import(new URL("pagefind/pagefind.js", root).href).then(
      async (m) => (await m.init(), m),
      () => null,
    );
    const engine = await pagefind;
    if (!engine) return { note: "No carrier: search index not built (npm run build)" };
    const found = await engine.search(query);
    const data = await Promise.all(found.results.slice(0, LIMIT).map((r) => r.data()));
    const out = data.map(({ url, meta, excerpt }) => ({
      title: meta.title || url,
      hint: meta.doc || meta.date || "",
      excerpt, // Pagefind escapes the page text and only adds <mark> around hits.
      href: url,
    }));
    const n = found.results.length;
    if (n > LIMIT) {
      const all = new URL("search/", root);
      all.searchParams.set("q", query);
      out.push({ title: `All ${n} matches …`, hint: "Search", href: all.href });
    }
    return { items: out };
  };

  // --------------------------------------------------------------------------
  // Dialog
  // --------------------------------------------------------------------------

  const select = (i) => {
    active = items.length ? (i + items.length) % items.length : 0;
    [...list.children].forEach((li, j) => li.setAttribute("aria-selected", String(j === active)));
    const li = list.children[active];
    li?.scrollIntoView({ block: "nearest" });
    if (li) input.setAttribute("aria-activedescendant", li.id);
    else input.removeAttribute("aria-activedescendant");
  };

  const show = (next, note) => {
    items = next;
    list.replaceChildren(
      ...items.map((item, i) => {
        const body = el("div", { className: "palette-body" }, el("div", { className: "palette-title", textContent: item.title }));
        if (item.excerpt) body.append(el("div", { className: "palette-excerpt", innerHTML: item.excerpt }));
        const li = el("li", { id: "palette-item-" + i, role: "option" }, body, el("span", { className: "label", textContent: item.hint ?? "" }));
        li.addEventListener("click", (e) => choose(i, e.metaKey || e.ctrlKey));
        li.addEventListener("mousemove", () => i !== active && select(i));
        return li;
      }),
    );
    status.textContent = note ?? "";
    status.hidden = !note;
    select(0);
  };

  const refresh = async () => {
    const mode = modeOf(input.value);
    const query = input.value.slice(mode.length).trim();
    const { prompt: name, placeholder, empty } = MODES[mode];
    prompt.textContent = name;
    input.placeholder = placeholder;
    const mine = ++ticket;
    if (mode) {
      const found = filter(mode === ">" ? commands() : mode === "@" ? sections() : keys(), query);
      const none = mode === "@" && !query ? "No sections on this page" : empty;
      return show(found, found.length ? null : none);
    }
    if (!query) return show([], "Standing by / > commands / @ sections / ? keys");
    // Let a burst of keystrokes settle before asking the index.
    await new Promise((done) => setTimeout(done, 120));
    if (mine !== ticket) return;
    const { items: found = [], note } = await search(query);
    if (mine !== ticket) return;
    show(found, note ?? (found.length ? null : empty));
  };

  const choose = (i, newTab = false) => {
    const item = items[i];
    if (!item) return;
    if (item.href) {
      if (newTab) return void open(item.href, "_blank", "noopener");
      dialog.close();
      location.href = item.href;
    } else {
      if (!item.stay) dialog.close();
      item.run();
    }
  };

  const build = () => {
    prompt = el("span", { className: "search-prompt", ariaHidden: "true" });
    input = el("input", { type: "text", autocomplete: "off", spellcheck: false });
    input.setAttribute("role", "combobox");
    input.setAttribute("aria-label", "Search, or type > for commands, @ for sections, ? for keys");
    input.setAttribute("aria-controls", "palette-list");
    input.setAttribute("aria-expanded", "true");
    list = el("ol", { id: "palette-list", className: "palette-list" });
    list.setAttribute("role", "listbox");
    status = el("div", { className: "label palette-status" });
    status.setAttribute("aria-live", "polite");
    const keys = el("div", { className: "label palette-keys" }, "↑↓ select / ↵ open / esc close");
    dialog = el("dialog", { className: "palette" }, el("label", { className: "search-bar" }, prompt, input), status, list, keys);
    dialog.setAttribute("aria-label", "Command palette");
    dialog.dataset.pagefindIgnore = "";
    document.body.append(dialog);

    input.addEventListener("input", refresh);
    input.addEventListener("keydown", (e) => {
      if (e.isComposing) return; // Enter and arrows belong to the input method
      if (e.key === "ArrowDown") select(active + 1);
      else if (e.key === "ArrowUp") select(active - 1);
      else if (e.key === "Enter") choose(active, e.metaKey || e.ctrlKey);
      else return;
      e.preventDefault();
    });
    // A click on the backdrop lands on the dialog itself.
    dialog.addEventListener("click", (e) => e.target === dialog && dialog.close());
  };

  /// Show the list for `mode`, keeping the dialog open.
  const reopen = (mode) => {
    input.value = mode;
    input.focus();
    refresh();
  };

  const toggle = (mode) => {
    if (!dialog) build();
    if (dialog.open && modeOf(input.value) === mode) return dialog.close();
    if (!dialog.open) dialog.showModal();
    reopen(mode);
  };

  /// Search: on the search page, its own box; elsewhere the palette.
  const find = () => {
    const box = document.getElementById("search-input");
    if (box && !dialog?.open) return void (box.focus(), box.select());
    toggle("");
  };

  document.addEventListener("keydown", (e) => {
    if (e.isComposing) return;
    if (!e.metaKey && !e.ctrlKey && !e.altKey) {
      // Typing belongs to the text box, and to the palette while it is open.
      if (dialog?.open || e.target.closest?.("input, textarea, select, [contenteditable]")) return;
      const act = { j: () => step(1), k: () => step(-1), "[": () => turn(-1), "]": () => turn(1), "?": () => toggle("?") }[e.key];
      if (act) (e.preventDefault(), act());
      return;
    }
    if ((mac ? !e.metaKey || e.ctrlKey : !e.ctrlKey || e.metaKey) || e.altKey) return;
    const key = e.key.toLowerCase();
    const mode = !e.shiftKey && key === "k" ? "" : e.shiftKey && key === "p" ? ">" : e.shiftKey && key === "o" ? "@" : null;
    if (mode === null) return;
    e.preventDefault();
    if (mode === "") find();
    else toggle(mode);
  });

  // The mark in the header names the search shortcut and opens it on a click.
  const mark = document.querySelector(".palette-mark");
  if (mark) {
    if (!mac) mark.textContent = "Ctrl K";
    mark.addEventListener("click", find);
  }
})();
