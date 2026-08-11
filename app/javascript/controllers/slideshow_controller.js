import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "slide", "content", "indicator", "counter" ]

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
    // Hide current
    if (this.slideTargets[this.index]) {
      this.slideTargets[this.index].classList.remove('opacity-100', 'z-10')
      this.slideTargets[this.index].firstElementChild?.classList.remove('scale-100')
      this.slideTargets[this.index].firstElementChild?.classList.add('scale-105')
      this.slideTargets[this.index].classList.add('opacity-0', 'z-0')
    }
    
    if (this.contentTargets[this.index]) {
      this.contentTargets[this.index].classList.remove('opacity-100', 'translate-y-0', 'pointer-events-auto')
      this.contentTargets[this.index].classList.add('opacity-0', 'translate-y-8', 'pointer-events-none')
    }

    if (this.indicatorTargets[this.index]) {
      this.indicatorTargets[this.index].classList.remove('bg-white', 'h-10', 'w-1.5')
      this.indicatorTargets[this.index].classList.add('bg-white/20', 'h-1', 'w-full')
    }

    this.index = index

    // Show new
    if (this.slideTargets[this.index]) {
      this.slideTargets[this.index].classList.remove('opacity-0', 'z-0')
      this.slideTargets[this.index].classList.add('opacity-100', 'z-10')
      // Ken Burns effect start
      setTimeout(() => {
        this.slideTargets[this.index].firstElementChild?.classList.remove('scale-105')
        this.slideTargets[this.index].firstElementChild?.classList.add('scale-100')
      }, 50)
    }

    if (this.contentTargets[this.index]) {
      this.contentTargets[this.index].classList.remove('opacity-0', 'translate-y-8', 'pointer-events-none')
      this.contentTargets[this.index].classList.add('opacity-100', 'translate-y-0', 'pointer-events-auto')
    }

    if (this.indicatorTargets[this.index]) {
      this.indicatorTargets[this.index].classList.remove('bg-white/20', 'h-1', 'w-full')
      this.indicatorTargets[this.index].classList.add('bg-white', 'h-10', 'w-1.5')
    }

    if (this.hasCounterTarget) {
      this.counterTarget.textContent = (this.index + 1).toString().padStart(2, '0')
    }
  }
}
