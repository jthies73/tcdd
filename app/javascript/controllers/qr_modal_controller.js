import { Controller } from "@hotwired/stimulus"

// QR code generation constants
const QR_TYPE_AUTO = 0 // Auto-detect QR code type number
const QR_ERROR_CORRECTION = "M" // Medium error correction level (~15% recovery)
const QR_CELL_SIZE = 6 // Cell size in pixels
const QR_MARGIN = 0 // Margin size in modules

export default class extends Controller {
  static targets = ["modal", "qrCode", "participantName"]

  connect() {
    // Controller is ready
  }

  open(event) {
    event.preventDefault()
    event.stopPropagation()

    const button = event.currentTarget
    const url = button.dataset.qrUrl
    const participantName = button.dataset.participantName

    // Set participant name
    this.participantNameTarget.textContent = participantName

    // Generate QR code
    this.generateQrCode(url)

    // Show the modal
    this.modalTarget.classList.remove("hidden")
  }

  generateQrCode(url) {
    // Clear previous QR code
    this.qrCodeTarget.innerHTML = ""

    // Check if qrcode-generator is available
    if (typeof qrcode === "undefined") {
      console.error("qrcode-generator library not loaded")
      const errorMessage = document.createElement("p")
      errorMessage.className = "text-red-500"
      errorMessage.textContent = "QR Code library not loaded"
      this.qrCodeTarget.appendChild(errorMessage)
      return
    }

    // Generate QR code using qrcode-generator library
    const qr = qrcode(QR_TYPE_AUTO, QR_ERROR_CORRECTION)
    qr.addData(url)
    qr.make()

    // Create the QR code image
    this.qrCodeTarget.innerHTML = qr.createImgTag(QR_CELL_SIZE, QR_MARGIN)
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
