import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="matchups"
export default class extends Controller {
  static targets = [ "modal", "edit" ];

  connect() {
    console.log("connecteeeed");
  }

  showForm() {
    this.modalTarget.style.display = "block";
    console.log(this);
  }

  closeForm() {
    this.modalTarget.style.display = "none";
  }
}
