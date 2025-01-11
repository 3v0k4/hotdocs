import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    toggleClass: String,
  };

  open(event) {
    this.opener = event.currentTarget;
    this.opener.ariaExpanded = true;
    this._toggle();
  }

  close(event) {
    this.opener.ariaExpanded = false;
    this._toggle();
  }

  _toggle(event) {
    document.body.classList.toggle(this.toggleClassValue);
  }
}
