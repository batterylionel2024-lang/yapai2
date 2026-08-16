import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "slide", "content", "counter", "image" ]

  connect() {
    this.index = 0
    this.showSlide(0)
    this.startInterval()
  }

  disconnect() {
    this.stopInterval()
  }

  startInterval() {
    this.interval = setInterval(() => {
      this.next()
    }, 6000)
  }

  stopInterval() {
    if (this.interval) {
      clearInterval(this.interval)
    }
  }

  next() {
    this.showSlide((this.index + 1) % this.slideTargets.length)
  }

  prev() {
    this.showSlide((this.index - 1 + this.slideTargets.length) % this.slideTargets.length)
  }

  goTo(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.showSlide(index)
    this.stopInterval()
    this.startInterval()
  }

  showSlide(index) {
    const isNext = index > this.index || (this.index === this.slideTargets.length - 1 && index === 0);
    
    // Hide current
    if (this.slideTargets[this.index]) {
      this.slideTargets[this.index].classList.remove('opacity-100', 'z-10', 'scale-100')
      this.slideTargets[this.index].classList.add('opacity-0', 'z-0', 'scale-110')
    }
    
    if (this.contentTargets[this.index]) {
      this.contentTargets[this.index].classList.remove('opacity-100', 'translate-y-0', 'pointer-events-auto')
      this.contentTargets[this.index].classList.add('opacity-0', 'translate-y-12', 'pointer-events-none')
    }

    this.index = index

    // Show new
    if (this.slideTargets[this.index]) {
      this.slideTargets[this.index].classList.remove('opacity-0', 'z-0', 'scale-110')
      this.slideTargets[this.index].classList.add('opacity-100', 'z-10', 'scale-100')
    }

    if (this.contentTargets[this.index]) {
      setTimeout(() => {
        this.contentTargets[this.index].classList.remove('opacity-0', 'translate-y-12', 'pointer-events-none')
        this.contentTargets[this.index].classList.add('opacity-100', 'translate-y-0', 'pointer-events-auto')
      }, 300)
    }
  }
}
