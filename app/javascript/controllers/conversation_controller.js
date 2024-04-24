import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    // Scroll to the bottom of the conversation window automatically
    this.element.scrollTop = this.element.scrollHeight;
  }
}
