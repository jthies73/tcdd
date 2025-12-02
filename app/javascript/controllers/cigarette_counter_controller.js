import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "display"]
  static values = {
    participationId: Number,
    debounceDelay: { type: Number, default: 2000 }
  }

  connect() {
    this.debounceTimer = null
  }

  disconnect() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }
  }

  increment10() {
    this.updateValue(this.getCurrentValue() + 10)
  }

  increment20() {
    this.updateValue(this.getCurrentValue() + 20)
  }

  increment50() {
    this.updateValue(this.getCurrentValue() + 50)
  }

  inputChanged() {
    let value = this.getCurrentValue()
    if (value < 0) value = 0
    this.inputTarget.value = value
    this.scheduleUpdate()
  }

  updateValue(newValue) {
    this.inputTarget.value = newValue
    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = newValue
    }
    this.scheduleUpdate()
  }

  scheduleUpdate() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }

    this.debounceTimer = setTimeout(() => {
      this.sendUpdate()
    }, this.debounceDelayValue)
  }

  sendUpdate() {
    const value = this.getCurrentValue()
    const participationId = this.participationIdValue

    fetch(`/participations/${participationId}/update_cigarettes_count`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "text/vnd.turbo-stream.html, text/html, application/xhtml+xml"
      },
      body: JSON.stringify({ cigarettes_count: value })
    })
    .then(response => {
      if (!response.ok) {
        console.error("Failed to update cigarettes count")
      }
    })
    .catch(error => {
      console.error("Error updating cigarettes count:", error)
    })
  }

  getCurrentValue() {
    return parseInt(this.inputTarget.value) || 0
  }
}
