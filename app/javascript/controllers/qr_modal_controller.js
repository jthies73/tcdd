import { Controller } from "@hotwired/stimulus"
import { QRCode } from "qrcode"

// QR code generation constants
const QR_SIZE = 200 // Size of QR code in pixels

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

    try {
      // Generate QR code using our ES module library
      const qr = new QRCode(url, { errorCorrectionLevel: 'M' })
      
      // Create the QR code SVG
      const svgElement = qr.toSVGElement({ size: QR_SIZE })
      this.qrCodeTarget.appendChild(svgElement)
    } catch (error) {
      console.error("Error generating QR code:", error)
      const errorMessage = document.createElement("p")
      errorMessage.className = "text-red-500"
      errorMessage.textContent = "Error generating QR code"
      this.qrCodeTarget.appendChild(errorMessage)
    }
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
