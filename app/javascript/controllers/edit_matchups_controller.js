import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="edit-matchups"
export default class extends Controller {
  static targets = [ "modal" ];

  connect() {
  }

  showForm() {
    this.modalTarget.style.display = "block";
  }

  closeForm() {
    this.modalTarget.style.display = "none";
  }
}
