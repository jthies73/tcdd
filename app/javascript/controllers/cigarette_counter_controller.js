import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "display", "incrementButton", "decrementButton"]
  static values = {
    participationId: Number,
    currentCount: { type: Number, default: 0 },
    debounceTimer: { type: Number, default: 2000 }
  }

  connect() {
    this.timeout = null
    this.updateDisplay()
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  increment() {
    this.currentCountValue += 1
    this.updateDisplay()
    this.debouncedUpdate()
  }

  decrement() {
    if (this.currentCountValue > 0) {
      this.currentCountValue -= 1
      this.updateDisplay()
      this.debouncedUpdate()
    }
  }

  updateValue(event) {
    const newValue = parseInt(event.target.value, 10)
    if (!isNaN(newValue) && newValue >= 0) {
      this.currentCountValue = newValue
      this.updateDisplay()
      this.debouncedUpdate()
    } else if (event.target.value === "") {
      this.currentCountValue = 0
      this.updateDisplay()
      this.debouncedUpdate()
    }
  }

  updateDisplay() {
    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = this.currentCountValue
    }
    if (this.hasInputTarget) {
      this.inputTarget.value = this.currentCountValue
    }
  }

  debouncedUpdate() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
    this.timeout = setTimeout(() => {
      this.saveToServer()
    }, this.debounceTimerValue)
  }

  async saveToServer() {
    const url = `/participations/${this.participationIdValue}/update_cigarettes`
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      const response = await fetch(url, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        },
        body: JSON.stringify({ cigarettes_count: this.currentCountValue })
      })

      if (!response.ok) {
        const data = await response.json()
        console.error("Failed to save cigarettes count:", data.error)
      }
    } catch (error) {
      console.error("Error saving cigarettes count:", error)
    }
  }

  handleTurboStream(event) {
    // This method handles Turbo Stream updates from other clients
    // The actual update is handled by Turbo automatically
    // We just need to sync our local state
    if (this.hasInputTarget) {
      const newValue = parseInt(this.inputTarget.value, 10)
      if (!isNaN(newValue) && newValue !== this.currentCountValue) {
        this.currentCountValue = newValue
        this.updateDisplay()
      }
    }
  }
}
