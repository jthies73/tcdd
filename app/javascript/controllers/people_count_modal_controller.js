import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["countInput", "error"]

  connect() {
    this.form = null
  }

  open(event) {
    event.preventDefault()
    event.stopPropagation()

    // Get the form that triggered this
    const trigger = event.currentTarget
    this.form = trigger.closest("form")

    // Get participant info from the searchable select
    const hiddenInput = this.form.querySelector('input[name="participant_id"]')
    if (!hiddenInput || !hiddenInput.value) {
      this.showError()
      return
    }

    this.hideError()
    
    // Get the people count from the hidden input's data attribute (set by searchable-select controller)
    const peopleCount = hiddenInput.dataset.peopleCount || "1"
    this.countInputTarget.value = peopleCount

    // Show the modal
    this.element.classList.remove("hidden")
  }

  confirm() {
    const peopleCount = parseInt(this.countInputTarget.value) || 1

    // Add the people count to the form
    if (this.form) {
      // Remove any existing people count input
      const existingInput = this.form.querySelector('input[name="participant_people_count"]')
      if (existingInput) {
        existingInput.remove()
      }

      // Create and append the people count input
      const peopleCountInput = document.createElement('input')
      peopleCountInput.type = 'hidden'
      peopleCountInput.name = 'participant_people_count'
      peopleCountInput.value = peopleCount
      this.form.appendChild(peopleCountInput)

      // Submit the form
      this.form.requestSubmit()
    }

    this.close()
  }

  close() {
    this.element.classList.add("hidden")
    this.hideError()
    this.form = null
  }

  showError() {
    if (this.hasErrorTarget) {
      this.errorTarget.classList.remove("hidden")
    }
  }

  hideError() {
    if (this.hasErrorTarget) {
      this.errorTarget.classList.add("hidden")
    }
  }
}
