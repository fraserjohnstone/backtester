import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "value"]
  connect() {
    console.log(`connected`)
    this.updateLabel()
  }

  updateLabel() {
    this.valueTarget.innerHTML =  `£${this.inputTarget.value}.00`;
    this.inputTarget.setAttribute('value', this.inputTarget.value);
  }
}
