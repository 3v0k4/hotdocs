import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    expanded: Boolean,
    expandedClass: String,
    collapsedAriaLabel: String,
    expandedAriaLabel: String,
  };

  static targets = ["toggle"];

  connect() {
    this._setStatus();

    if (this.expandedValue) {
      this.element.classList.add(this.expandedClassValue);
    }
  }

  toggle() {
    this.expandedValue = !this.expandedValue;
    this._setStatus();
    this.element.classList.toggle(this.expandedClassValue);
  }

  _setStatus() {
    if (this.expandedValue) {
      this.toggleTarget.ariaExpanded = true;
      this.toggleTarget.ariaLabel = this.expandedAriaLabelValue;
    } else {
      this.toggleTarget.ariaExpanded = false;
      this.toggleTarget.ariaLabel = this.collapsedAriaLabelValue;
    }
  }
}
