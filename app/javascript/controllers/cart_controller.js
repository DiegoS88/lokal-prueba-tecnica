import { Controller } from "@hotwired/stimulus"

// Recalcula subtotales por proveedor, total por línea y total general del carrito
// cuando cambia una cantidad, y persiste el cambio en la sesión sin recargar.
export default class extends Controller {
  static targets = ["quantity", "providerTotal", "grandTotal"]
  static values = { updateUrl: String }

  connect() {
    this.render()
  }

  changed(event) {
    const input = event.currentTarget
    const clamped = this.clamp(input)
    if (clamped !== input.value) {
      input.value = clamped
    }
    this.render()
    this.persist(input)
  }

  clamp(input) {
    const value = parseInt(input.value, 10) || 0
    const stock = parseInt(input.dataset.cartMaxStock, 10)
    return Math.min(Math.max(value, 1), stock)
  }

  render() {
    const providerTotals = {}

    this.quantityTargets.forEach((input) => {
      const quantity = this.clamp(input)
      const unitPrice = parseInt(input.dataset.cartUnitPrice, 10)
      const providerId = input.dataset.cartProviderGroup
      const total = quantity * unitPrice

      const lineTotal = input.closest("tr").querySelector('[data-cart-target="lineTotal"]')
      if (lineTotal) lineTotal.textContent = this.currency(total)

      providerTotals[providerId] = (providerTotals[providerId] || 0) + total
    })

    this.providerTotalTargets.forEach((node) => {
      node.textContent = this.currency(providerTotals[node.dataset.providerGroup] || 0)
    })

    const grand = Object.values(providerTotals).reduce((sum, value) => sum + value, 0)
    this.grandTotalTarget.textContent = this.currency(grand)
  }

  persist(input) {
    const body = new FormData(input.closest("form"))
    const token = document.querySelector('meta[name="csrf-token"]').content
    fetch(this.updateUrlValue, {
      method: "POST",
      headers: { "X-CSRF-Token": token },
      body
    })
  }

  currency(amount) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD", minimumFractionDigits: 3, maximumFractionDigits: 3 }).format(amount / 1000)
  }
}