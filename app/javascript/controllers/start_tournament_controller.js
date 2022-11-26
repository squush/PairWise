import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="start-tournament"
export default class extends Controller {
  static targets = [ "form", "modal", "close" ];

  connect() {
    console.log("connecteddd");
  }

  showForm() {
    this.modalTarget.style.display = "block";
  }

  closeForm() {
    this.modalTarget.style.display = "none";
  }
}
