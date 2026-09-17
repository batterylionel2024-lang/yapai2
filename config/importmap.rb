# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "@rails/activestorage", to: "activestorage.esm.js"
pin "gsap/dist/gsap", to: "gsap--dist--gsap.js", preload: false # @3.15.0
pin "gsap/dist/ScrollTrigger", to: "gsap--dist--ScrollTrigger.js", preload: false # @3.15.0
