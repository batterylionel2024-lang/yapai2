import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "canvas",
    "darkWorld",
    "fallback",
    "progress",
    "stateLabel",
    "chargeLabel",
    "scene",
    "sceneDot",
    "counter",
    "magnetic"
  ]

  static values = { reducedMotion: Boolean }

  connect() {
    this.connected = true
    this.reducedMotion = this.reducedMotionValue || window.matchMedia("(prefers-reduced-motion: reduce)").matches
    this.visual = {
      charge: this.reducedMotion ? 0.86 : 0.28,
      scroll: 0,
      intensity: 0.58,
      phase: this.reducedMotion ? 2.0 : 0,
      explode: 0,
      side: this.reducedMotion ? -0.54 : 0.54
    }
    this.pointer = { x: 0, y: 0, easedX: 0, easedY: 0 }
    this.startedAt = performance.now()
    this.rendering = true
    this.raf = null
    this.webglReady = false

    this.handlePointerMove = this.handlePointerMove.bind(this)
    this.handleResize = this.handleResize.bind(this)
    this.handleWindowLoad = this.handleWindowLoad.bind(this)
    this.handleVisibilityChange = this.handleVisibilityChange.bind(this)

    window.addEventListener("pointermove", this.handlePointerMove, { passive: true })
    window.addEventListener("resize", this.handleResize, { passive: true })
    window.addEventListener("load", this.handleWindowLoad, { once: true })
    document.addEventListener("visibilitychange", this.handleVisibilityChange)

    this.setDarkActive(this.isDarkWorldVisible())
    this.initWebGL()
    this.loadAnimationLibraries()
  }

  disconnect() {
    this.connected = false
    window.removeEventListener("pointermove", this.handlePointerMove)
    window.removeEventListener("resize", this.handleResize)
    window.removeEventListener("load", this.handleWindowLoad)
    document.removeEventListener("visibilitychange", this.handleVisibilityChange)

    if (this.raf) cancelAnimationFrame(this.raf)
    if (this.motionContext) this.motionContext.revert()
    if (this.sectionObserver) this.sectionObserver.disconnect()

    this.magneticCleanups?.forEach((cleanup) => cleanup())
    this.tiltCleanups?.forEach((cleanup) => cleanup())
    this.disposeWebGL()
  }

  async loadAnimationLibraries() {
    try {
      await import("gsap/dist/gsap")
      await import("gsap/dist/ScrollTrigger")
      if (!this.connected) return

      this.initMotion()
      this.initMagneticButtons()
      this.initTiltCards()
    } catch (error) {
      console.warn("Yapai GSAP animations could not be initialized.", error)
    }
  }

  initWebGL() {
    if (!this.hasCanvasTarget) return

    try {
      const gl = this.canvasTarget.getContext("webgl", {
        alpha: false,
        antialias: false,
        depth: false,
        powerPreference: "high-performance"
      })

      if (!gl) throw new Error("WebGL is not available")

      this.gl = gl
      this.program = this.createProgram(gl, this.vertexShaderSource(), this.fragmentShaderSource())
      this.positionBuffer = gl.createBuffer()

      gl.bindBuffer(gl.ARRAY_BUFFER, this.positionBuffer)
      gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 3, -1, -1, 3]), gl.STATIC_DRAW)
      gl.useProgram(this.program)

      const position = gl.getAttribLocation(this.program, "aPosition")
      gl.enableVertexAttribArray(position)
      gl.vertexAttribPointer(position, 2, gl.FLOAT, false, 0, 0)

      this.uniforms = {
        resolution: gl.getUniformLocation(this.program, "uResolution"),
        time: gl.getUniformLocation(this.program, "uTime"),
        mouse: gl.getUniformLocation(this.program, "uMouse"),
        scroll: gl.getUniformLocation(this.program, "uScroll"),
        charge: gl.getUniformLocation(this.program, "uCharge"),
        intensity: gl.getUniformLocation(this.program, "uIntensity"),
        phase: gl.getUniformLocation(this.program, "uPhase"),
        explode: gl.getUniformLocation(this.program, "uExplode"),
        side: gl.getUniformLocation(this.program, "uSide")
      }

      this.webglReady = true
      this.element.classList.add("is-webgl-ready")
      this.resizeWebGL()
      this.drawFrame(performance.now())

      if (!this.reducedMotion) this.raf = requestAnimationFrame((time) => this.render(time))
    } catch (error) {
      this.element.classList.add("no-webgl")
      this.webglReady = false
      console.warn("Yapai WebGL experience is using its CSS fallback.", error)
    }
  }

  createProgram(gl, vertexSource, fragmentSource) {
    const vertex = this.compileShader(gl, gl.VERTEX_SHADER, vertexSource)
    const fragment = this.compileShader(gl, gl.FRAGMENT_SHADER, fragmentSource)
    const program = gl.createProgram()

    gl.attachShader(program, vertex)
    gl.attachShader(program, fragment)
    gl.linkProgram(program)

    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      const message = gl.getProgramInfoLog(program)
      gl.deleteProgram(program)
      throw new Error(`WebGL link error: ${message}`)
    }

    gl.deleteShader(vertex)
    gl.deleteShader(fragment)
    return program
  }

  compileShader(gl, type, source) {
    const shader = gl.createShader(type)
    gl.shaderSource(shader, source)
    gl.compileShader(shader)

    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      const message = gl.getShaderInfoLog(shader)
      gl.deleteShader(shader)
      throw new Error(`WebGL shader error: ${message}`)
    }

    return shader
  }

  vertexShaderSource() {
    return `
      attribute vec2 aPosition;

      void main() {
        gl_Position = vec4(aPosition, 0.0, 1.0);
      }
    `
  }

  fragmentShaderSource() {
    return `
      precision highp float;

      uniform vec2 uResolution;
      uniform float uTime;
      uniform vec2 uMouse;
      uniform float uScroll;
      uniform float uCharge;
      uniform float uIntensity;
      uniform float uPhase;
      uniform float uExplode;
      uniform float uSide;

      #define MAX_STEPS 64
      #define CORE_STEPS 40
      #define MAX_DIST 9.0
      #define SURFACE_DIST 0.0014

      mat2 rotate2d(float angle) {
        float s = sin(angle);
        float c = cos(angle);
        return mat2(c, -s, s, c);
      }

      float hash21(vec2 p) {
        p = fract(p * vec2(123.34, 456.21));
        p += dot(p, p + 45.32);
        return fract(p.x * p.y);
      }

      float noise21(vec2 p) {
        vec2 i = floor(p);
        vec2 f = fract(p);
        f = f * f * (3.0 - 2.0 * f);
        return mix(
          mix(hash21(i), hash21(i + vec2(1.0, 0.0)), f.x),
          mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0)), f.x),
          f.y
        );
      }

      float roundedBox(vec3 p, vec3 b, float r) {
        vec3 q = abs(p) - b + r;
        return min(max(q.x, max(q.y, q.z)), 0.0) + length(max(q, 0.0)) - r;
      }

      vec3 toBatterySpace(vec3 p) {
        float turn = 0.18 + uScroll * 0.43 + sin(uPhase * 0.82) * 0.1 + uMouse.x * 0.19;
        float tilt = -0.08 + sin(uScroll * 1.22) * 0.14 - uMouse.y * 0.14;
        p.xz = rotate2d(turn) * p.xz;
        p.yz = rotate2d(tilt) * p.yz;

        float slice = floor((p.y + 1.55) * 4.0);
        p.x += sin(slice * 2.14 + uPhase) * uExplode * 0.055;
        p.z += cos(slice * 1.73 - uPhase) * uExplode * 0.035;
        return p;
      }

      float outerDistance(vec3 p) {
        vec3 q = toBatterySpace(p);
        return roundedBox(q, vec3(0.73, 1.27, 0.35), 0.19);
      }

      float coreDistance(vec3 p) {
        vec3 q = toBatterySpace(p);
        return roundedBox(q + vec3(0.0, 0.02, 0.0), vec3(0.57, 1.06, 0.235), 0.13);
      }

      float terminalDistance(vec3 p) {
        vec3 q = toBatterySpace(p);
        float neck = roundedBox(q - vec3(0.0, 1.34, 0.0), vec3(0.31, 0.1, 0.255), 0.055);
        float cap = roundedBox(q - vec3(0.0, 1.47, 0.0), vec3(0.22, 0.08, 0.19), 0.045);
        return min(neck, cap);
      }

      float batteryDistance(vec3 p) {
        float glassShell = abs(outerDistance(p)) - 0.012;
        float terminal = terminalDistance(p);
        float microTexture = sin(p.y * 37.0 + p.x * 17.0 + uTime * 0.25) * 0.00055 * uIntensity;
        return min(glassShell + microTexture, terminal);
      }

      vec3 glassNormal(vec3 p) {
        vec2 e = vec2(0.003, 0.0);
        float d = batteryDistance(p);
        return normalize(vec3(
          batteryDistance(p + e.xyy) - d,
          batteryDistance(p + e.yxy) - d,
          batteryDistance(p + e.yyx) - d
        ));
      }

      vec3 coreNormal(vec3 p) {
        vec2 e = vec2(0.003, 0.0);
        float d = coreDistance(p);
        return normalize(vec3(
          coreDistance(p + e.xyy) - d,
          coreDistance(p + e.yxy) - d,
          coreDistance(p + e.yyx) - d
        ));
      }

      float raymarch(vec3 origin, vec3 direction) {
        float distanceTravelled = 0.0;
        for (int i = 0; i < MAX_STEPS; i++) {
          vec3 point = origin + direction * distanceTravelled;
          float distanceToScene = batteryDistance(point);
          distanceTravelled += max(distanceToScene, 0.001);
          if (distanceToScene < SURFACE_DIST || distanceTravelled > MAX_DIST) break;
        }
        return distanceTravelled;
      }

      float raymarchCore(vec3 origin, vec3 direction) {
        float distanceTravelled = 0.0;
        for (int i = 0; i < CORE_STEPS; i++) {
          vec3 point = origin + direction * distanceTravelled;
          float distanceToCore = coreDistance(point);
          distanceTravelled += max(distanceToCore, 0.001);
          if (distanceToCore < SURFACE_DIST || distanceTravelled > 3.2) break;
        }
        return distanceTravelled;
      }

      vec3 energyBackground(vec2 uv, vec2 batteryUv) {
        vec3 color = mix(vec3(0.019, 0.058, 0.04), vec3(0.004, 0.016, 0.011), smoothstep(-0.9, 0.9, uv.y));

        float halo = exp(-length(batteryUv * vec2(0.78, 1.0)) * 1.45);
        color += vec3(0.025, 0.38, 0.17) * halo * (0.34 + uCharge * 0.5);

        float angle = atan(batteryUv.y, batteryUv.x);
        float radius = length(batteryUv * vec2(0.84, 1.0));
        float ringRadius = 0.94 + sin(uTime * 0.48 + angle * 3.0) * 0.018 + sin(uPhase) * 0.025;
        float ring = 0.004 / (abs(radius - ringRadius) + 0.007);
        float arcGate = smoothstep(0.18, 0.92, sin(angle * 5.0 - uTime * 1.5 + noise21(vec2(angle * 3.0, uTime * 0.4))));
        color += mix(vec3(0.17, 0.9, 0.42), vec3(1.0, 0.48, 0.08), step(0.72, arcGate)) * ring * (0.045 + arcGate * 0.06);

        float innerRing = 0.003 / (abs(length(batteryUv * vec2(1.0, 0.78)) - 0.72) + 0.007);
        color += vec3(0.16, 0.58, 0.31) * innerRing * 0.035;

        vec2 movingUv = uv * vec2(15.0, 9.0) + vec2(uTime * 0.11, -uTime * 0.06);
        vec2 cell = floor(movingUv);
        vec2 local = fract(movingUv) - 0.5;
        float random = hash21(cell);
        vec2 offset = vec2(hash21(cell + 3.1), hash21(cell + 7.7)) - 0.5;
        float spark = (1.0 - smoothstep(0.0, 0.045, length(local - offset * 0.72))) * step(0.72, random);
        float flicker = 0.35 + 0.65 * sin(uTime * (1.0 + random * 2.0) + random * 18.0);
        color += mix(vec3(0.15, 0.82, 0.42), vec3(1.0, 0.56, 0.12), step(0.93, random)) * spark * flicker;

        float beam = exp(-abs(uv.y + uv.x * 0.12 + 0.3) * 18.0) * smoothstep(-1.2, 0.8, uv.x);
        color += vec3(0.16, 0.62, 0.3) * beam * 0.06;
        return color;
      }

      void main() {
        vec2 screen = (2.0 * gl_FragCoord.xy - uResolution.xy) / uResolution.y;
        float desktop = smoothstep(720.0, 1100.0, uResolution.x);
        float desktopShift = desktop * (uSide + sin(uPhase * 0.9) * 0.018);
        vec2 view = screen;
        view.x -= desktopShift;

        vec3 color = energyBackground(screen, view);
        vec3 origin = vec3(0.0, 0.0, 4.7 + sin(uPhase * 0.7) * 0.08);
        vec3 direction = normalize(vec3(view, -2.25));
        float distanceTravelled = raymarch(origin, direction);

        if (distanceTravelled < MAX_DIST) {
          vec3 point = origin + direction * distanceTravelled;
          vec3 normal = glassNormal(point);
          vec3 local = toBatterySpace(point);
          vec3 lightDirection = normalize(vec3(-0.65, 1.0, 0.85));
          float diffuse = max(dot(normal, lightDirection), 0.0);
          float fresnel = pow(1.0 - max(dot(normal, -direction), 0.0), 2.3);
          float specular = pow(max(dot(reflect(-lightDirection, normal), -direction), 0.0), 34.0);
          float terminal = smoothstep(1.24, 1.34, local.y);

          vec3 innerColor = color;
          float coreTravel = raymarchCore(point + direction * 0.055, direction);
          if (coreTravel < 3.2 && terminal < 0.5) {
            vec3 corePoint = point + direction * (0.055 + coreTravel);
            vec3 coreLocal = toBatterySpace(corePoint);
            vec3 coreN = coreNormal(corePoint);
            float coreDiffuse = max(dot(coreN, lightDirection), 0.0);
            float coreFresnel = pow(1.0 - max(dot(coreN, -direction), 0.0), 2.0);
            float fillTop = -1.02 + uCharge * 2.04;
            float charged = 1.0 - smoothstep(fillTop - 0.055, fillTop + 0.055, coreLocal.y);
            float fillLine = 1.0 - smoothstep(0.018, 0.062, abs(coreLocal.y - fillTop));
            float flow = pow(0.5 + 0.5 * sin(coreLocal.y * 38.0 - uTime * 3.2 + coreLocal.x * 8.0), 12.0);
            float rib = smoothstep(0.43, 0.49, abs(fract((coreLocal.y + 1.06) * 3.35) - 0.5));

            vec3 depleted = mix(vec3(0.025, 0.07, 0.045), vec3(0.08, 0.16, 0.1), coreDiffuse);
            vec3 energy = mix(vec3(0.02, 0.46, 0.2), vec3(0.72, 1.0, 0.17), 0.22 + coreDiffuse * 0.78);
            innerColor = mix(depleted, energy, charged * 0.94);
            innerColor += vec3(0.68, 1.0, 0.2) * (fillLine * 1.15 + flow * charged * 0.12 + coreFresnel * 0.25);
            innerColor = mix(innerColor, vec3(0.02, 0.12, 0.07), rib * 0.34);
          }

          vec3 glass = mix(vec3(0.035, 0.12, 0.075), vec3(0.22, 0.68, 0.36), diffuse * 0.45 + fresnel * 0.55);
          glass += vec3(0.72, 1.0, 0.82) * specular * 1.25;
          glass += vec3(0.34, 1.0, 0.52) * fresnel * 0.48;
          float glassOpacity = 0.12 + fresnel * 0.7 + specular * 0.24;
          vec3 surface = mix(innerColor, glass, clamp(glassOpacity, 0.0, 0.88));
          surface = mix(surface, vec3(0.98, 0.5, 0.075) + specular * 0.5, terminal * 0.92);

          float scanLine = pow(0.5 + 0.5 * sin(local.y * 54.0 - uTime * 2.0), 22.0);
          surface += vec3(0.42, 1.0, 0.58) * scanLine * 0.055 * (1.0 - terminal);

          float edgeFade = 1.0 - smoothstep(7.5, MAX_DIST, distanceTravelled);
          color = mix(color, surface, edgeFade);
          color += vec3(0.25, 0.95, 0.43) * fresnel * 0.15;
        }

        float vignette = 1.0 - smoothstep(0.28, 1.72, length(screen * vec2(0.7, 0.92)));
        color *= 0.56 + vignette * 0.55;
        color = pow(color, vec3(0.9));
        gl_FragColor = vec4(color, 1.0);
      }
    `
  }

  render(time) {
    this.raf = null
    if (!this.webglReady || !this.rendering) return

    this.pointer.easedX += (this.pointer.x - this.pointer.easedX) * 0.055
    this.pointer.easedY += (this.pointer.y - this.pointer.easedY) * 0.055
    this.drawFrame(time)
    this.raf = requestAnimationFrame((nextTime) => this.render(nextTime))
  }

  drawFrame(time) {
    if (!this.webglReady) return

    const gl = this.gl
    this.resizeWebGL()
    gl.viewport(0, 0, this.canvasTarget.width, this.canvasTarget.height)
    gl.useProgram(this.program)
    gl.uniform2f(this.uniforms.resolution, this.canvasTarget.width, this.canvasTarget.height)
    gl.uniform1f(this.uniforms.time, this.reducedMotion ? 0 : (time - this.startedAt) / 1000)
    gl.uniform2f(this.uniforms.mouse, this.pointer.easedX, this.pointer.easedY)
    gl.uniform1f(this.uniforms.scroll, this.visual.scroll)
    gl.uniform1f(this.uniforms.charge, this.visual.charge)
    gl.uniform1f(this.uniforms.intensity, this.visual.intensity)
    gl.uniform1f(this.uniforms.phase, this.visual.phase)
    gl.uniform1f(this.uniforms.explode, this.visual.explode)
    gl.uniform1f(this.uniforms.side, this.visual.side)
    gl.drawArrays(gl.TRIANGLES, 0, 3)

    if (this.hasChargeLabelTarget) this.chargeLabelTarget.textContent = `${Math.round(this.visual.charge * 100)}%`
    this.element.style.setProperty("--yp-battery-left", `${50 + (this.visual.side / 0.54) * 20}%`)
  }

  resizeWebGL() {
    if (!this.webglReady) return

    const pixelRatioCap = window.innerWidth < 768 ? 1.2 : 1.5
    const pixelRatio = Math.min(window.devicePixelRatio || 1, pixelRatioCap)
    const width = Math.max(1, Math.floor(this.canvasTarget.clientWidth * pixelRatio))
    const height = Math.max(1, Math.floor(this.canvasTarget.clientHeight * pixelRatio))

    if (this.canvasTarget.width !== width || this.canvasTarget.height !== height) {
      this.canvasTarget.width = width
      this.canvasTarget.height = height
    }
  }

  initMotion() {
    const gsap = window.gsap
    const ScrollTrigger = window.ScrollTrigger

    if (!gsap || !ScrollTrigger) {
      this.element.classList.add("is-dark-active")
      return
    }

    gsap.registerPlugin(ScrollTrigger)

    this.motionContext = gsap.context(() => {
      ScrollTrigger.create({
        trigger: this.darkWorldTarget,
        start: "top 75%",
        end: "bottom 25%",
        onToggle: ({ isActive }) => this.setDarkActive(isActive)
      })

      this.setDarkActive(this.isDarkWorldVisible())
      this.setScene("hero")

      if (!this.reducedMotion) {
        gsap.fromTo(
          this.element.querySelectorAll("[data-hero-reveal]"),
          { autoAlpha: 0, y: 34 },
          { autoAlpha: 1, y: 0, duration: 1.05, stagger: 0.11, ease: "power3.out", delay: 0.12 }
        )

        gsap.timeline({
          scrollTrigger: {
            trigger: this.darkWorldTarget,
            start: "top top",
            end: "bottom bottom",
            scrub: 1.1
          }
        })
          .to(this.visual, { charge: 0.48, scroll: 0.8, intensity: 0.7, phase: 1.0, explode: 0.04, side: 0.54, ease: "none", duration: 1 })
          .to(this.visual, { charge: 0.66, scroll: 1.7, intensity: 0.84, phase: 2.0, explode: 0.12, side: -0.54, ease: "none", duration: 1 })
          .to(this.visual, { charge: 0.81, scroll: 2.7, intensity: 0.98, phase: 3.0, explode: 0.28, side: 0.54, ease: "none", duration: 1 })
          .to(this.visual, { charge: 0.9, scroll: 3.8, intensity: 1.08, phase: 4.0, explode: 0.92, side: 0.42, ease: "none", duration: 1.1 })
          .to(this.visual, { charge: 0.96, scroll: 5.0, intensity: 0.96, phase: 5.0, explode: 0.42, side: -0.42, ease: "none", duration: 1 })
          .to(this.visual, { charge: 1.0, scroll: 6.15, intensity: 1.12, phase: 6.0, explode: 0.02, side: 0.5, ease: "none", duration: 1 })

        this.sceneTargets.slice(1).forEach((scene, index) => {
          const card = scene.querySelector("[data-chapter-reveal]")
          if (!card) return

          gsap.fromTo(card,
            { autoAlpha: 0, y: 64, rotateX: 4 },
            {
              autoAlpha: 1,
              y: 0,
              rotateX: 0,
              duration: 0.9,
              ease: "power3.out",
              scrollTrigger: {
                trigger: scene,
                start: "top 68%",
                toggleActions: "play none none reverse"
              },
              delay: index * 0.03
            }
          )
        })

        const sectionElements = this.element.querySelectorAll("[data-section-reveal]:not([data-tilt-card])")
        sectionElements.forEach((element) => {
          gsap.fromTo(element,
            { autoAlpha: 0, y: 48 },
            {
              autoAlpha: 1,
              y: 0,
              duration: 0.9,
              ease: "power3.out",
              scrollTrigger: { trigger: element, start: "top 84%", once: true }
            }
          )
        })

        const productCards = this.element.querySelectorAll("[data-tilt-card]")
        if (productCards.length) {
          gsap.set(productCards, { autoAlpha: 0, y: 70, rotateY: -4 })
          ScrollTrigger.batch(productCards, {
            start: "top 86%",
            once: true,
            onEnter: (batch) => gsap.to(batch, {
              autoAlpha: 1,
              y: 0,
              rotateY: 0,
              duration: 0.95,
              stagger: 0.11,
              ease: "power3.out"
            })
          })
        }

        const factoryImage = this.element.querySelector(".yp-factory-visual img")
        if (factoryImage) {
          gsap.fromTo(factoryImage,
            { scale: 1.16, yPercent: -4 },
            {
              scale: 1.03,
              yPercent: 4,
              ease: "none",
              scrollTrigger: {
                trigger: ".yp-factory",
                start: "top bottom",
                end: "bottom top",
                scrub: 1
              }
            }
          )
        }

        gsap.to(".yp-energy-reticle", {
          rotation: 145,
          scale: 0.86,
          ease: "none",
          scrollTrigger: {
            trigger: this.darkWorldTarget,
            start: "top top",
            end: "bottom bottom",
            scrub: 1.4
          }
        })

        gsap.to(".yp-battery-signature", {
          yPercent: -36,
          opacity: 0.12,
          ease: "none",
          scrollTrigger: {
            trigger: this.darkWorldTarget,
            start: "top top",
            end: "bottom bottom",
            scrub: 1.2
          }
        })

        gsap.to(this.progressTarget, {
          scaleX: 1,
          ease: "none",
          scrollTrigger: {
            trigger: this.element,
            start: "top top",
            end: "bottom bottom",
            scrub: 0.2
          }
        })

        this.animateCounters(gsap)
      } else {
        gsap.set(this.element.querySelectorAll("[data-hero-reveal], [data-chapter-reveal], [data-section-reveal]"), {
          autoAlpha: 1,
          x: 0,
          y: 0
        })
      }

      this.sceneTargets.forEach((scene) => {
        ScrollTrigger.create({
          trigger: scene,
          start: "top center",
          end: "bottom center",
          onEnter: () => this.setScene(scene.dataset.scene),
          onEnterBack: () => this.setScene(scene.dataset.scene)
        })
      })
    }, this.element)
  }

  animateCounters(gsap) {
    this.counterTargets.forEach((counter) => {
      const endValue = Number(counter.dataset.value)
      const suffix = counter.dataset.suffix || ""
      const state = { value: 0 }

      gsap.to(state, {
        value: endValue,
        duration: 1.5,
        delay: 0.62,
        ease: "power2.out",
        onUpdate: () => {
          counter.textContent = `${Math.round(state.value).toLocaleString("en-US")}${suffix}`
        }
      })
    })
  }

  initMagneticButtons() {
    if (this.reducedMotion || !window.gsap) return

    this.magneticCleanups = this.magneticTargets.map((button) => {
      const onMove = (event) => {
        const bounds = button.getBoundingClientRect()
        const x = event.clientX - bounds.left - bounds.width / 2
        const y = event.clientY - bounds.top - bounds.height / 2
        window.gsap.to(button, { x: x * 0.13, y: y * 0.16, duration: 0.35, ease: "power2.out" })
      }

      const onLeave = () => window.gsap.to(button, { x: 0, y: 0, duration: 0.65, ease: "elastic.out(1, 0.35)" })
      button.addEventListener("pointermove", onMove)
      button.addEventListener("pointerleave", onLeave)

      return () => {
        button.removeEventListener("pointermove", onMove)
        button.removeEventListener("pointerleave", onLeave)
      }
    })
  }

  initTiltCards() {
    if (this.reducedMotion || !window.gsap || !window.matchMedia("(pointer: fine)").matches) return

    const cards = Array.from(this.element.querySelectorAll("[data-tilt-card]"))
    this.tiltCleanups = cards.map((card) => {
      const image = card.querySelector(".yp-product-image")
      const rotateX = window.gsap.quickTo(card, "rotationX", { duration: 0.42, ease: "power3.out" })
      const rotateY = window.gsap.quickTo(card, "rotationY", { duration: 0.42, ease: "power3.out" })
      const cardY = window.gsap.quickTo(card, "y", { duration: 0.42, ease: "power3.out" })
      const imageX = image ? window.gsap.quickTo(image, "x", { duration: 0.55, ease: "power3.out" }) : null
      const imageY = image ? window.gsap.quickTo(image, "y", { duration: 0.55, ease: "power3.out" }) : null

      window.gsap.set(card, { transformPerspective: 900, transformOrigin: "center" })

      const onMove = (event) => {
        const bounds = card.getBoundingClientRect()
        const x = (event.clientX - bounds.left) / bounds.width - 0.5
        const y = (event.clientY - bounds.top) / bounds.height - 0.5
        rotateX(y * -8)
        rotateY(x * 9)
        cardY(-8)
        imageX?.(x * -8)
        imageY?.(y * -8)
        card.style.setProperty("--yp-card-x", `${(x + 0.5) * 100}%`)
        card.style.setProperty("--yp-card-y", `${(y + 0.5) * 100}%`)
      }

      const onLeave = () => {
        rotateX(0)
        rotateY(0)
        cardY(0)
        imageX?.(0)
        imageY?.(0)
      }

      card.addEventListener("pointermove", onMove)
      card.addEventListener("pointerleave", onLeave)

      return () => {
        card.removeEventListener("pointermove", onMove)
        card.removeEventListener("pointerleave", onLeave)
      }
    })
  }

  setScene(name) {
    const scene = this.sceneTargets.find((item) => item.dataset.scene === name)
    const label = scene?.dataset.stateLabel

    this.sceneDotTargets.forEach((dot) => {
      const active = dot.dataset.sceneName === name
      dot.classList.toggle("is-active", active)
      if (active) dot.setAttribute("aria-current", "true")
      else dot.removeAttribute("aria-current")
    })

    if (label && this.hasStateLabelTarget && window.gsap && !this.reducedMotion) {
      window.gsap.to(this.stateLabelTarget, {
        autoAlpha: 0,
        y: -5,
        duration: 0.16,
        onComplete: () => {
          this.stateLabelTarget.textContent = label
          window.gsap.fromTo(this.stateLabelTarget, { autoAlpha: 0, y: 5 }, { autoAlpha: 1, y: 0, duration: 0.25 })
        }
      })
    } else if (label && this.hasStateLabelTarget) {
      this.stateLabelTarget.textContent = label
    }
  }

  setDarkActive(active) {
    this.element.classList.toggle("is-dark-active", active)
    this.rendering = active

    if (active && this.webglReady && !this.reducedMotion && !this.raf) {
      this.raf = requestAnimationFrame((time) => this.render(time))
    } else if (!active && this.raf) {
      cancelAnimationFrame(this.raf)
      this.raf = null
    }
  }

  isDarkWorldVisible() {
    if (!this.hasDarkWorldTarget) return false
    const bounds = this.darkWorldTarget.getBoundingClientRect()
    return bounds.bottom > 0 && bounds.top < window.innerHeight
  }

  handlePointerMove(event) {
    this.pointer.x = (event.clientX / window.innerWidth - 0.5) * 2
    this.pointer.y = (event.clientY / window.innerHeight - 0.5) * 2
    this.element.style.setProperty("--yp-mouse-x", `${this.pointer.x * 16}px`)
    this.element.style.setProperty("--yp-mouse-y", `${this.pointer.y * 16}px`)
  }

  handleResize() {
    this.resizeWebGL()
    if (this.webglReady && this.reducedMotion) this.drawFrame(performance.now())
    window.ScrollTrigger?.refresh()
  }

  handleWindowLoad() {
    window.ScrollTrigger?.refresh()
  }

  handleVisibilityChange() {
    if (document.hidden) {
      if (this.raf) cancelAnimationFrame(this.raf)
      this.raf = null
      return
    }

    if (this.rendering && this.webglReady && !this.reducedMotion && !this.raf) {
      this.raf = requestAnimationFrame((time) => this.render(time))
    }
  }

  disposeWebGL() {
    if (!this.gl) return
    if (this.positionBuffer) this.gl.deleteBuffer(this.positionBuffer)
    if (this.program) this.gl.deleteProgram(this.program)
    this.gl = null
    this.program = null
    this.webglReady = false
  }
}
