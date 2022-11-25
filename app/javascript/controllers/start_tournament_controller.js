import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="start-tournament"
export default class extends Controller {

  static targets = [ "form" ];

  connect() {
    console.log("connecteddd");
  }

  toggleForm(event) {
    console.log(event);
    this.formTarget.classList.toggle("d-none");
  }
}
