import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]
  static values = {
    startTime: String
  }

  connect() {
    this.startTimer()
  }

  disconnect() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
    }
  }

  startTimer() {
    this.updateDisplay()
    this.timerInterval = setInterval(() => {
      this.updateDisplay()
    }, 1000)
  }

  updateDisplay() {
    const startTime = new Date(this.startTimeValue)
    const now = new Date()
    const elapsedSeconds = Math.floor((now - startTime) / 1000)
    
    // Handle case where start time is in the future
    if (elapsedSeconds < 0) {
      this.displayTarget.textContent = "00:00:00"
      return
    }

    const hours = Math.floor(elapsedSeconds / 3600)
    const minutes = Math.floor((elapsedSeconds % 3600) / 60)
    const seconds = elapsedSeconds % 60

    this.displayTarget.textContent = this.formatTime(hours, minutes, seconds)
  }

  formatTime(hours, minutes, seconds) {
    const pad = (num) => num.toString().padStart(2, '0')
    return `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`
  }
}
