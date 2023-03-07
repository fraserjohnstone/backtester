import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "options", "collectionButton" ]
  connect() {
    console.log(`connected`)
  }

  optionClicked() {
    event.srcElement.classList.toggle("option-select-btn__active")
    event.srcElement.querySelector("#option-select-field").checked = !event.srcElement.querySelector("#option-select-field").checked
  }

  assetGroupBtnClicked() {
    const subset = event.srcElement.dataset.optionSubsetValue
    const subsetEnabled = event.srcElement.dataset.optionSubsetEnabled

    for (let i = 0; i < subset.length; i++) {
      let value = JSON.parse(subset)[i]

      let element = document.querySelector(`#option-${value}`);
      if (element !== undefined && element !== null ) {
        if (subsetEnabled === "true") {
          event.srcElement.dataset.optionSubsetEnabled = "false"
          event.srcElement.classList.remove("option-select-btn__active")
          element.classList.remove("option-select-btn__active")
          element.querySelector("#option-select-field").checked = false
        } else {
          event.srcElement.dataset.optionSubsetEnabled = "true"
          element.classList.add("option-select-btn__active")
          event.srcElement.classList.add("option-select-btn__active")

          element.querySelector("#option-select-field").checked = true
        }
      }
    }
  }
}
