import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["valueInput", "valueDisplay"]

  connect() {
    console.log(`connected`)
    this.step = parseFloat(this.element.dataset.step)
    this.minValue = parseFloat(this.element.dataset.minValue)
    this.maxValue = parseFloat(this.element.dataset.maxValue)

    console.log(this.element.dataset.step)
    console.log(this.minValue)
    console.log(this.maxValue)
  }

  increment() {
    let newValue = parseFloat(this.valueInputTarget.value) + this.step
    if (newValue <= this.maxValue) {
      this.valueInputTarget.value = newValue
      this.valueDisplayTarget.innerHTML = newValue
    }
  }

  decrement() {
    let newValue = parseFloat(this.valueInputTarget.value) - this.step
    if (newValue >= this.minValue) {
      this.valueInputTarget.value = newValue
      this.valueDisplayTarget.innerHTML = newValue
    }
  }
}
