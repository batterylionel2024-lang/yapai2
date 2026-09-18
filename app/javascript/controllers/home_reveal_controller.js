import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.element.classList.add("yr-js")

    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.itemTargets.forEach((item) => item.classList.add("is-visible"))
      return
    }

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return

        entry.target.classList.add("is-visible")
        this.observer.unobserve(entry.target)
      })
    }, { threshold: 0.12, rootMargin: "0px 0px -7% 0px" })

    this.itemTargets.forEach((item, index) => {
      item.style.transitionDelay = `${Math.min(index % 4, 3) * 70}ms`
      this.observer.observe(item)
    })
  }

  disconnect() {
    this.observer?.disconnect()
  }
}
