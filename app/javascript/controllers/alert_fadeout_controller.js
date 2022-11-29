import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="alert-fadeout"
export default class extends Controller {
  static targets = ["flash"]

  connect() {
    setTimeout(() => {
      this.flashTarget.classList.add("hide-flash");
    }, 2500
  )}
}
