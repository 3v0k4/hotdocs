import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("click", this._checkNextInput);
  }

  disconnect() {
    this.element.removeEventListener("click", this._checkNextInput);
  }

  _checkNextInput = (event) => {
    event.preventDefault()
    const inputs = Array.from(this.element.querySelectorAll('input'))
    const i = inputs.findIndex(input => input.checked)
    const j = (i+1) % inputs.length
    inputs[j].checked = true
  }
}
