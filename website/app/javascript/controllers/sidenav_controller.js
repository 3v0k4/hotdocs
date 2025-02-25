import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["sections"];

  static values = {
    openClass: String,
    mainSectionClass: String,
  };

  open(event) {
    this.opener = event.currentTarget;
    this.opener.ariaExpanded = true;
    this._toggleOpen();
  }

  close() {
    this._toggleOpen();
    this.opener.ariaExpanded = false;
    if (this.resetSection) {
      this.resetSection();
      this.resetSection = null;
    }
  }

  back() {
    this.sectionsTarget.classList.add(this.mainSectionClassValue);
    this.resetSection = () => {
      setTimeout(
        () => this.sectionsTarget.classList.remove(this.mainSectionClassValue),
        200 // Give time to the CSS transition to finish
      );
    };
  }

  _toggleOpen(event) {
    document.body.classList.toggle(this.openClassValue);
  }
}
