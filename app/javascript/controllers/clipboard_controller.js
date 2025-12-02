import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button", "successIcon", "copyIcon"]
  static values = {
    successDuration: { type: Number, default: 2000 }
  }

  copy() {
    const text = this.sourceTarget.value || this.sourceTarget.textContent
    navigator.clipboard.writeText(text).then(() => {
      this.showSuccess()
    })
  }

  showSuccess() {
    if (this.hasSuccessIconTarget && this.hasCopyIconTarget) {
      this.copyIconTarget.classList.add("hidden")
      this.successIconTarget.classList.remove("hidden")
      
      setTimeout(() => {
        this.successIconTarget.classList.add("hidden")
        this.copyIconTarget.classList.remove("hidden")
      }, this.successDurationValue)
    }
  }
}
