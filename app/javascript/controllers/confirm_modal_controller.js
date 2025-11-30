import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "message"]
  static values = {
    message: { type: String, default: "Sind Sie sicher?" }
  }

  connect() {
    // Store the form reference when opening
    this.pendingForm = null
  }

  open(event) {
    event.preventDefault()
    event.stopPropagation()

    // Store the button that triggered this
    const button = event.currentTarget
    const form = button.closest("form")
    this.pendingForm = form

    // Get custom message from data attribute or use default
    const message = button.dataset.confirmMessage || this.messageValue
    this.messageTarget.textContent = message

    // Show the modal
    this.modalTarget.classList.remove("hidden")
  }

  confirm() {
    if (this.pendingForm) {
      this.pendingForm.requestSubmit()
    }
    this.close()
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.pendingForm = null
  }

  // Close on escape key
  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  // Close when clicking outside
  closeOnOutsideClick(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }
}
