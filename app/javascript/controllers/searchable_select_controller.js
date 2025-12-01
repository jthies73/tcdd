import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list", "item", "hiddenField", "noResults"]
  static values = {
    placeholder: { type: String, default: "Suchen..." }
  }

  connect() {
    this.selectedId = this.hiddenFieldTarget.value || ""
    this.updateInputFromSelection()
  }

  filter() {
    const query = this.inputTarget.value.toLowerCase().trim()
    let visibleCount = 0

    this.itemTargets.forEach(item => {
      const name = item.dataset.name.toLowerCase()
      const matches = query === "" || name.includes(query)
      item.classList.toggle("hidden", !matches)
      if (matches) visibleCount++
    })

    // Show/hide the "no results" message
    if (this.hasNoResultsTarget) {
      this.noResultsTarget.classList.toggle("hidden", visibleCount > 0 || query === "")
    }

    // Show the list when filtering
    if (query !== "") {
      this.showList()
    }
  }

  select(event) {
    const item = event.currentTarget
    const id = item.dataset.id
    const name = item.dataset.name

    this.selectedId = id
    this.hiddenFieldTarget.value = id
    this.inputTarget.value = name
    this.hideList()

    // Mark the selected item
    this.itemTargets.forEach(i => {
      i.classList.toggle("bg-indigo-50", i.dataset.id === id)
      i.classList.toggle("border-indigo-300", i.dataset.id === id)
    })
  }

  showList() {
    this.listTarget.classList.remove("hidden")
  }

  hideList() {
    // Small delay to allow click events to fire
    setTimeout(() => {
      this.listTarget.classList.add("hidden")
    }, 150)
  }

  focusInput() {
    this.showList()
  }

  clearSelection() {
    this.selectedId = ""
    this.hiddenFieldTarget.value = ""
    this.inputTarget.value = ""
    this.itemTargets.forEach(i => {
      i.classList.remove("bg-indigo-50", "border-indigo-300")
      i.classList.remove("hidden")
    })
    if (this.hasNoResultsTarget) {
      this.noResultsTarget.classList.add("hidden")
    }
    this.inputTarget.focus()
  }

  updateInputFromSelection() {
    if (this.selectedId) {
      const selectedItem = this.itemTargets.find(item => item.dataset.id === this.selectedId)
      if (selectedItem) {
        this.inputTarget.value = selectedItem.dataset.name
        selectedItem.classList.add("bg-indigo-50", "border-indigo-300")
      }
    }
  }
}
