import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="generate-pairings"
export default class extends Controller {
  static targets = [ "modal" ];

  connect() {
    console.log("connected");
  }

  showForm() {
    this.modalTarget.style.display = "block";
  }

  closeForm() {
    this.modalTarget.style.display = "none";
  }
}
