import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["countInput"]
  static values = {
    participantId: Number,
    participantName: String,
    initialCount: Number
  }

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
      alert("Bitte wähle einen Namen aus der Liste")
      return
    }

    this.participantIdValue = hiddenInput.value

    // Reset the count to the initial value
    this.countInputTarget.value = this.initialCountValue

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
    this.form = null
  }
}
