import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message", "dismissButton"]

  connect() {
    // Auto-dismiss messages after 5 seconds
    this.timeout = setTimeout(() => {
      this.dismissAll()
    }, 5000)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss(event) {
    event.preventDefault()
    const message = event.target.closest('[data-flash-messages-target="message"]')
    if (message) {
      this.fadeOut(message)
    }
  }

  dismissAll() {
    this.messageTargets.forEach(message => {
      this.fadeOut(message)
    })
  }

  fadeOut(element) {
    element.style.transition = 'opacity 0.3s ease-out, transform 0.3s ease-out'
    element.style.opacity = '0'
    element.style.transform = 'translateX(100%)'
    
    setTimeout(() => {
      element.remove()
      // If no more messages, clean up the controller
      if (this.messageTargets.length === 0) {
        this.element.remove()
      }
    }, 300)
  }
}