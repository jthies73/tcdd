import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "qrCode", "participantName"]

  connect() {
    // Controller is ready
  }

  open(event) {
    event.preventDefault()
    event.stopPropagation()

    const button = event.currentTarget
    const qrImage = button.dataset.qrImage
    const participantName = button.dataset.participantName

    // Set participant name
    this.participantNameTarget.textContent = participantName

    // Display QR code image (server-generated via rqrcode)
    this.displayQrCode(qrImage)

    // Show the modal
    this.modalTarget.classList.remove("hidden")
  }

  displayQrCode(imageSrc) {
    // Clear previous QR code
    this.qrCodeTarget.innerHTML = ""

    // Create and display the QR code image
    const img = document.createElement("img")
    img.src = imageSrc
    img.alt = "QR Code"
    img.className = "w-48 h-48"
    this.qrCodeTarget.appendChild(img)
  }

  close() {
    this.modalTarget.classList.add("hidden")
  }

  // Close on escape key
  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  // Close when clicking outside
  closeOnOutsideClick(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }
}
