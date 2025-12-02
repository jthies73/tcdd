import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row"]

  connect() {
    this.highlightCurrentParticipant()
  }

  highlightCurrentParticipant() {
    const participationId = this.getParticipationIdFromUrl()
    if (!participationId) return

    this.rowTargets.forEach(row => {
      const rowParticipationId = row.dataset.participationId
      const nameCell = row.querySelector("[data-name]")
      const badge = row.querySelector("[data-badge]")

      if (rowParticipationId === participationId) {
        // Highlight the row
        row.classList.add("bg-yellow-50")

        // Style the name
        if (nameCell) {
          nameCell.classList.add("font-bold", "text-indigo-700")
        }

        // Show the "Du" badge
        if (badge) {
          badge.classList.remove("hidden")
        }
      } else {
        // Remove highlight from other rows
        row.classList.remove("bg-yellow-50")

        // Remove name styling
        if (nameCell) {
          nameCell.classList.remove("font-bold", "text-indigo-700")
        }

        // Hide the badge
        if (badge) {
          badge.classList.add("hidden")
        }
      }
    })
  }

  getParticipationIdFromUrl() {
    // Extract participation ID from URL - the ID is the last numeric segment
    // Handles /participations/123 and /go/123 URLs
    const pathSegments = window.location.pathname.split("/").filter(Boolean)
    const lastSegment = pathSegments[pathSegments.length - 1]

    // Only return if the last segment is numeric (a valid ID)
    if (lastSegment && /^\d+$/.test(lastSegment)) {
      return lastSegment
    }

    return null
  }
}
