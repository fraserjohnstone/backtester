import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "valueInput", "radioButton" ]

  connect() {
    console.log(`connected`)
  }

  radioClicked() {
    let newValue = event.srcElement.dataset.radioValue

    for (let i = 0; i < this.radioButtonTargets.length; i++) {
      this.radioButtonTargets[i].classList.remove("option-select-btn__active")
    }

    this.valueInputTarget.value = newValue
    event.srcElement.classList.add("option-select-btn__active")

    if (newValue !== "market") {
      console.log("pending type chosen")
    }
  }
}
