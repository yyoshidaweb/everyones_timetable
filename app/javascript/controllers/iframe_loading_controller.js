import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="iframe-loading"
export default class extends Controller {
  static targets = ["spinner"]

  hide() {
    if (!this.hasSpinnerTarget) return

    this.spinnerTarget.classList.add("hidden")
  }
}
