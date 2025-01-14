import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    klass: String,
    open: Boolean,
  };

  connect() {
    if (!this.openValue) {
      return;
    }
    this.element.classList.add(this.klassValue);
  }

  toggle(event) {
    this.element.classList.toggle(this.klassValue);
  }
}
