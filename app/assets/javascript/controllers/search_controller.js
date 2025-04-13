import { Controller } from "@hotwired/stimulus";
import lunr from "lunr";

export default class extends Controller {
  static targets = ["search", "dialog", "results", "resultTemplate", "data"];

  connect() {
    this._allowOpening();
  }

  disconnect() {
    document.removeEventListener("keydown", this.keydownOpen);
    document.removeEventListener("click", this._clickClose);
  }

  open() {
    if (this.searchTarget.open) return;
    this._allowClosing();
    this._initSearch();
    this.searchTarget.showModal();
  }

  search = debounce(this._search, 200);

  _allowOpening() {
    this.keydownOpen = (event) => {
      if (this.searchTarget.open || event.key !== "/") return;
      event.preventDefault();
      this.open();
    };

    document.addEventListener("keydown", this.keydownOpen);
  }

  _clickClose = (event) => {
    if (!this.searchTarget.open) return;
    if (this.dialogTarget.contains(event.target)) return;
    this.searchTarget.close();
    document.removeEventListener("click", this._clickClose);
  };

  _allowClosing() {
    document.removeEventListener("click", this._clickClose);
    document.addEventListener("click", this._clickClose);
  }

  _initSearch() {
    if (this.documents) {
      this.searchTarget.classList.add("loaded");
      return;
    }
    this._createSearchIndex();
    this.searchTarget.classList.add("loaded");
  }

  _createSearchIndex() {
    const documents = this._getDocuments();
    if (documents.length === 0) return;
    this.documents = documents;
    this.searchIndex = lunr(function () {
      this.ref("title");
      this.field("title", { boost: 5 });
      this.field("text");
      this.metadataWhitelist = ["position"];
      documents.forEach(function (doc) {
        this.add(doc);
      }, this);
    });
  }

  _getDocuments() {
    const searchData = JSON.parse(this.dataTarget.textContent);
    if (searchData.length === 0) {
      console.warn(
        [
          "The search data is not present in the HTML.",
          "If you are in development, run `bundle exec rails hotdocs:index`.",
          "If you are in production, assets compilation should have taken care of it.",
        ].join(" ")
      );
    }
    return searchData.map((data) => {
      const div = document.createElement("div");
      div.innerHTML = data.html;
      return { ...data, text: div.innerText };
    });
  }

  _search(event) {
    if (!this.searchIndex) return;
    const query = event.target.value;
    const results = this.searchIndex.search(query).slice(0, 10);
    this._displayResults(results);
  }

  _displayResults(results) {
    this.resultsTarget.innerHTML = null;

    results.forEach((result) => {
      const matches = Object.keys(result.matchData.metadata);
      const excerpt = this._withExcerpt(matches, result)[0];
      if (!excerpt) return;
      this.resultsTarget.appendChild(this._createResultElement(excerpt));
    });
  }

  _withExcerpt(matches, result) {
    return matches.flatMap((match) => {
      return Object.keys(result.matchData.metadata[match]).map((key) => {
        const position = result.matchData.metadata[match][key].position[0];
        const [sliceStart, sliceLength] = key === "text" ? position : [0, 0];
        const doc = this.documents.find((doc) => doc.title === result.ref);
        const excerpt = this._excerpt(doc.text, sliceStart, sliceLength);
        return { ...doc, excerpt };
      });
    });
  }

  _excerpt(doc, sliceStart, sliceLength) {
    const startPos = Math.max(sliceStart - 80, 0);
    const endPos = Math.min(sliceStart + sliceLength + 80, doc.length);
    return [
      startPos > 0 ? "..." : "",
      doc.slice(startPos, sliceStart),
      "<strong>" +
        escapeHtmlEntities(doc.slice(sliceStart, sliceStart + sliceLength)) +
        "</strong>",
      doc.slice(sliceStart + sliceLength, endPos),
      endPos < doc.length ? "..." : "",
    ].join("");
  }

  _createResultElement(excerpt) {
    const clone = this.resultTemplateTarget.content.cloneNode(true);
    const li = clone.querySelector("li");
    li.querySelector("h1").innerHTML = `${excerpt.parent} > ${excerpt.title}`;
    li.querySelector("a").innerHTML = excerpt.excerpt;
    li.querySelector("a").href = excerpt.url;
    return clone;
  }
}

function debounce(func, wait) {
  let timeoutId;

  return function (...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => func.apply(this, args), wait);
  };
}

function escapeHtmlEntities(string) {
  return String(string)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}
