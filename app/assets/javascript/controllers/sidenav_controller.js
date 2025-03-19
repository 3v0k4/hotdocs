import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["sections"];

  static values = {
    openClass: String,
    mainMenuClass: String,
  };

  open(event) {
    this.opener = event.currentTarget;
    this.opener.ariaExpanded = true;
    this._toggleOpen();
  }

  close() {
    this._toggleOpen();
    this.opener.ariaExpanded = false;
    if (this.reset) {
      this.reset();
      this.reset = null;
    }
  }

  back() {
    this.sectionsTarget.classList.add(this.mainMenuClassValue);
    this.reset = () => {
      setTimeout(
        () => this.sectionsTarget.classList.remove(this.mainMenuClassValue),
        200 // Give time to the CSS transition to finish
      );
    };
  }

  _toggleOpen(event) {
    document.body.classList.toggle(this.openClassValue);
  }
}
