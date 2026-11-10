// Site search on /search/, backed by the Pagefind index that `npm run build`
// writes to /pagefind/ after the Tola build. The query lives in ?q= so
// searches can be linked.
const input = document.getElementById("search-input");
const status = document.getElementById("search-status");
const list = document.getElementById("search-results");
const LIMIT = 30;

const pad = (n) => String(n).padStart(2, "0");

const row = ({ url, meta, excerpt }) => {
  const li = document.createElement("li");
  const a = Object.assign(document.createElement("a"), { href: url });
  const side = Object.assign(document.createElement("div"), { className: "label" });
  side.textContent = meta.date || "";
  const body = Object.assign(document.createElement("div"), { className: "search-body" });
  const title = Object.assign(document.createElement("div"), { className: "index-title" });
  title.textContent = meta.title || url;
  const doc = Object.assign(document.createElement("div"), { className: "label accent" });
  doc.textContent = meta.doc || "";
  // Pagefind escapes the page text and only adds <mark> around hits.
  const text = Object.assign(document.createElement("p"), { className: "search-excerpt", innerHTML: excerpt });
  body.append(doc, title, text);
  a.append(side, body);
  li.append(a);
  return li;
};

const main = async () => {
  let pagefind;
  try {
    // Relative to this page (<base>/search/), so a base-path still resolves.
    pagefind = await import(new URL("../pagefind/pagefind.js", location.href).href);
    await pagefind.options({ excerptLength: 28 });
    pagefind.init();
  } catch {
    status.textContent = "No carrier: search index not built (npm run build)";
    input.disabled = true;
    return;
  }

  const run = async (q) => {
    const url = new URL(location.href);
    if (q) url.searchParams.set("q", q);
    else url.searchParams.delete("q");
    history.replaceState(null, "", url);

    if (!q.trim()) {
      list.replaceChildren();
      status.textContent = "Standing by";
      return;
    }
    const search = await pagefind.debouncedSearch(q, {}, 150);
    if (search === null) return; // superseded by a newer keystroke
    const data = await Promise.all(search.results.slice(0, LIMIT).map((r) => r.data()));
    const n = search.results.length;
    status.textContent = n
      ? `${pad(n)} match${n === 1 ? "" : "es"}${n > LIMIT ? ` / showing ${LIMIT}` : ""}`
      : "No signal: nothing matches";
    list.replaceChildren(...data.map(row));
  };

  input.addEventListener("input", () => run(input.value));
  const q = new URLSearchParams(location.search).get("q");
  if (q) {
    input.value = q;
    run(q);
  }
  input.focus();
};

main();
