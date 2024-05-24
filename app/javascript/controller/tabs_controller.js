// app/javascript/controllers/tabs_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["content", "account"];

  connect() {
    this.showAll();
  }

  select(event) {
    const target = event.target.getAttribute("data-tabs-target");
    this.showContent(target);
  }

  showContent(target) {
    this.contentTargets.forEach((element) => {
      element.style.display = element.getAttribute("data-tabs-target") === target ? "block" : "none";
    });
  }

  showAll() {
    this.contentTargets.forEach((element) => {
      element.style.display = "block";
    });
  }

  selectAllInquiries() {
    document.querySelectorAll('input[name="inquiry_ids[]"]').forEach((checkbox) => {
      checkbox.checked = true;
    });
  }

  selectAllAccounts() {
    this.accountTargets.forEach((account) => {
      account.classList.add("border-red-500");
    });
  }

  toggleSelection(event) {
    const account = event.currentTarget;
    account.classList.toggle("border-red-500");
  }
}
