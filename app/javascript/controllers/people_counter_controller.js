import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  increment() {
    const currentValue = this.getCurrentValue()
    this.updateValue(currentValue + 1)
  }

  decrement() {
    const currentValue = this.getCurrentValue()
    if (currentValue > 1) {
      this.updateValue(currentValue - 1)
    }
  }

  updateValue(newValue) {
    this.inputTarget.value = newValue
  }

  getCurrentValue() {
    return parseInt(this.inputTarget.value) || 1
  }
}
