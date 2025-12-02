import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  increment() {
    const currentValue = this.getCurrentValue()
    const newValue = Math.min(currentValue + 1, 999) // Cap at 999
    this.updateValue(newValue)
  }

  decrement() {
    const currentValue = this.getCurrentValue()
    if (currentValue > 1) {
      this.updateValue(currentValue - 1)
    }
  }

  // Handle manual input changes
  validateInput() {
    let value = parseInt(this.inputTarget.value) || 1
    
    // Enforce minimum of 1
    if (value < 1) {
      value = 1
    }
    
    // Enforce maximum of 999
    if (value > 999) {
      value = 999
    }
    
    this.updateValue(value)
  }

  updateValue(newValue) {
    this.inputTarget.value = newValue
  }

  getCurrentValue() {
    return parseInt(this.inputTarget.value) || 1
  }
}
