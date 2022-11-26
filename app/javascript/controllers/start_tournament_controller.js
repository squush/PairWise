import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="start-tournament"
export default class extends Controller {

  static targets = [ "form", "modal", "close" ];

  connect() {
    console.log("connecteddd");
  }

  showForm() {
    // console.log(event);
    // this.formTarget.classList.toggle("d-none");
    // this.modalTarget.classList.toggle("none")
    // console.log(this.modalTarget);
    // console.log(this.formTarget);
    // console.log("hello")
    this.modalTarget.style.display = "block";

    // let modalBtn = document.getElementById("modal-btn");
    // let modal = document.querySelector(".modal");
    // let closeBtn = document.querySelector(".close-btn");
    // modalBtn.onclick = function(){
    //   modal.style.display = "block";
    // }
    // closeBtn.onclick = function(){
    //   modal.style.display = "none";
    // }
    // window.onclick = function(e){
    //   if(e.target == modal){
    //     modal.style.display = "none";
    //   }
    // }
  }

  closeForm() {
    this.modalTarget.style.display = "none";
  }


}
