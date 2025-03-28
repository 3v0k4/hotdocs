import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  EMPTY = " ";

  static targets = ["typewrite"];

  static values = {
    phrases: Array,
  };

  connect() {
    this.typewriteTarget.innerHTML = this.phrasesValue[0];
    this.typed = this.phrasesValue[0];
    this.phrase = this.phrasesValue[0];
    this.timeout = setTimeout(() => this._delete(), 2000);
  }

  disconnect() {
    clearTimeout(this.timeout);
  }

  _type() {
    if (this.typed === this.EMPTY) {
      this.typed = this.phrase.substring(0, 1);
    } else {
      this.typed = this.phrase.substring(0, this.typed.length + 1);
    }

    this.typewriteTarget.innerHTML = this.typed;

    if (this.typed === this.phrase) {
      this.timeout = setTimeout(() => this._delete(), 2000);
    } else {
      const delay = 200 - Math.random() * 100;
      this.timeout = setTimeout(() => this._type(), delay);
    }
  }

  _delete() {
    this.typed = this.phrase.substring(0, this.typed.length - 1);
    if (this.typed.length === 0) this.typed = this.EMPTY;
    this.typewriteTarget.innerHTML = this.typed;

    if (this.typed === this.EMPTY) {
      this._nextPhrase();
      this.timeout = setTimeout(() => this._type(), 500);
    } else {
      const delay = (200 - Math.random() * 100) / 2;
      this.timeout = setTimeout(() => this._delete(), delay);
    }
  }

  _nextPhrase() {
    const currentIndex = this.phrasesValue.findIndex((x) => this.phrase === x);
    const nextIndex = (currentIndex + 1) % this.phrasesValue.length;
    this.phrase = this.phrasesValue[nextIndex];
  }
}
