import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    host: String,
    path: String,
    fallback: String,
  };

  connect() {
    if (!this.element.id) {
      throw new Error("Element must have an id.");
    }
    this.element.innerHTML = this.fallbackValue || "Loading...";
    this.element.style.visibility = "";
    this.fetchElement();
  }

  fetchElement() {
    fetch(`${this.hostValue}${this.pathValue}`)
      .then((response) => response.text())
      .then((text) => {
        const parser = new DOMParser();
        const doc = parser.parseFromString(text, "text/html");
        const fetchedElement = doc.querySelector(`#${this.element.id}`);
        this.element.innerHTML = fetchedElement.innerHTML;
      });
  }
}
