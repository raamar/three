<script lang="ts">
  import windowStore, { handleResize } from '$lib/stores/windowStore'
  import * as THREE from 'three'
  import { OrbitControls } from 'three/examples/jsm/Addons.js'
  import GUI from 'lil-gui'
  import gsap from 'gsap'
  import earthVertexShader from '$lib/shaders/earth/vertex.glsl?raw'
  import earthFragmentShader from '$lib/shaders/earth/fragment.glsl?raw'
  import atmosphereVertexShader from '$lib/shaders/atmosphere/vertex.glsl?raw'
  import atmosphereFragmentShader from '$lib/shaders/atmosphere/fragment.glsl?raw'
  import particleVertexShader from '$lib/shaders/particle/vertex.glsl?raw'
  import particleFragmentShader from '$lib/shaders/particle/fragment.glsl?raw'
  import { points as data } from '$lib/data/points'

  const cursor = new THREE.Vector2()

  const handleMouseMove = (event: MouseEvent) => {
    cursor.x = (event.clientX / $windowStore.innerWidth) * 2 - 1
    cursor.y = -((event.clientY / $windowStore.innerHeight) * 2 - 1)
  }

  const handleDblClick = () => {
    if (document.fullscreenElement) {
      document.exitFullscreen()
      return
    }

    document.documentElement.requestFullscreen()
  }

  const appMount = (node: HTMLElement) => {
    const gui = new GUI()

    const scene = new THREE.Scene()

    const camera = new THREE.PerspectiveCamera(30, $windowStore.innerWidth / $windowStore.innerHeight, 0.1, 10000)
    camera.position.set(0, 0, 3)
    gsap.to(camera.position, { z: 9, duration: 3.5 }).eventCallback('onComplete', () => {
      orbitControls.minDistance = 5
    })

    const clock = new THREE.Clock()
    const orbitControls = new OrbitControls(camera, node)

    orbitControls.enablePan = false
    orbitControls.enableDamping = true
    orbitControls.maxDistance = 9

    scene.add(camera)

    const renderer = new THREE.WebGLRenderer({
      antialias: true,
    })

    /**
     * Textures
     */

    const textureLoader = new THREE.TextureLoader()

    /**
     * Objects
     */

    // Earth

    const startRotation = { x: Math.PI * 0.62, y: Math.PI * -0.25, z: Math.PI * 0.2 }
    const ratitionAnimationObject = { x: Math.PI * 0.2, y: Math.PI * -0.4, z: Math.PI * 0.1, duration: 4.5 }
    const earthGeometry = new THREE.SphereGeometry(2, 64, 64)
    const earthMaterial = new THREE.ShaderMaterial({
      vertexShader: earthVertexShader,
      fragmentShader: earthFragmentShader,
      uniforms: {
        uColor: {
          value: new THREE.Color('#474747'),
        },
        uIntencity: {
          value: 1.05,
        },

        uIntencityX: {
          value: 0.1,
        },
        uIntencityY: {
          value: -0.19,
        },
        uIntencityZ: {
          value: 0.78,
        },
        uAtmosphereR: {
          value: 1.0,
        },
        uAtmosphereG: {
          value: 1.0,
        },
        uAtmosphereB: {
          value: 1.0,
        },
        uAtmospherePow: {
          value: 3.85,
        },

        uFragColorA: {
          value: 1.0,
        },
      },
    })

    const config = {
      uColor: '#474747',
    }

    const earth_folder = gui.addFolder('Earth')
    earth_folder.close()
    earth_folder.add(earthMaterial.uniforms.uIntencity, 'value').min(0).max(10).step(0.01).name('uIntencity')
    earth_folder.add(earthMaterial.uniforms.uIntencityX, 'value').min(-10).max(10).step(0.01).name('uIntencityX')
    earth_folder.add(earthMaterial.uniforms.uIntencityY, 'value').min(-10).max(10).step(0.01).name('uIntencityY')
    earth_folder.add(earthMaterial.uniforms.uIntencityZ, 'value').min(-10).max(10).step(0.01).name('uIntencityZ')
    earth_folder.add(earthMaterial.uniforms.uAtmosphereR, 'value').min(0).max(1).step(0.01).name('uAtmosphereR')
    earth_folder.add(earthMaterial.uniforms.uAtmosphereG, 'value').min(0).max(1).step(0.01).name('uAtmosphereG')
    earth_folder.add(earthMaterial.uniforms.uAtmosphereB, 'value').min(0).max(1).step(0.01).name('uAtmosphereB')
    earth_folder.add(earthMaterial.uniforms.uAtmospherePow, 'value').min(-10).max(10).step(0.01).name('uAtmospherePow')
    earth_folder.add(earthMaterial.uniforms.uFragColorA, 'value').min(0).max(1).step(0.001).name('uFragColorA')
    earth_folder
      .addColor(config, 'uColor')
      .onChange(() => (earthMaterial.uniforms.uColor.value = new THREE.Color(config.uColor)))

    const earthMesh = new THREE.Mesh(earthGeometry, earthMaterial)
    scene.add(earthMesh)
    earthMesh.rotation.set(startRotation.x, startRotation.y, startRotation.z)
    gsap.to(earthMesh.rotation, ratitionAnimationObject)

    // Atmosphere
    const atmosphereMaterial = new THREE.ShaderMaterial({
      vertexShader: atmosphereVertexShader,
      fragmentShader: atmosphereFragmentShader,
      side: THREE.DoubleSide,
      transparent: true,
      depthWrite: false,
      blending: THREE.AdditiveBlending,
      uniforms: {
        uIntencity: {
          value: 0.8,
        },
        uIntencityX: {
          value: 0.02,
        },
        uIntencityY: {
          value: -0.02,
        },
        uIntencityZ: {
          value: 1.0,
        },
        uIntencityPow: {
          value: 12.0,
        },
        uIntencityR: {
          value: 1.0,
        },
        uIntencityG: {
          value: 1.0,
        },
        uIntencityB: {
          value: 1.0,
        },
        uIntencityA: {
          value: 0.8,
        },
      },
    })

    const atmosphere_folder = gui.addFolder('Atmosphere')
    atmosphere_folder.close()
    atmosphere_folder.add(atmosphereMaterial.uniforms.uIntencity, 'value').min(0).max(3).step(0.001).name('uIntencity')
    atmosphere_folder
      .add(atmosphereMaterial.uniforms.uIntencityX, 'value')
      .min(0)
      .max(3)
      .step(0.001)
      .name('uIntencityX')
    atmosphere_folder
      .add(atmosphereMaterial.uniforms.uIntencityY, 'value')
      .min(-10)
      .max(10)
      .step(0.001)
      .name('uIntencityY')
    atmosphere_folder
      .add(atmosphereMaterial.uniforms.uIntencityZ, 'value')
      .min(-10)
      .max(10)
      .step(0.001)
      .name('uIntencityZ')
    atmosphere_folder
      .add(atmosphereMaterial.uniforms.uIntencityPow, 'value')
      .min(-10)
      .max(20)
      .step(0.001)
      .name('uIntencityPow')
    atmosphere_folder
      .add(atmosphereMaterial.uniforms.uIntencityR, 'value')
      .min(0)
      .max(1)
      .step(0.001)
      .name('uIntencityR')
    atmosphere_folder
      .add(atmosphereMaterial.uniforms.uIntencityG, 'value')
      .min(0)
      .max(1)
      .step(0.001)
      .name('uIntencityG')
    atmosphere_folder
      .add(atmosphereMaterial.uniforms.uIntencityB, 'value')
      .min(0)
      .max(1)
      .step(0.001)
      .name('uIntencityB')
    atmosphere_folder
      .add(atmosphereMaterial.uniforms.uIntencityA, 'value')
      .min(0)
      .max(1)
      .step(0.001)
      .name('uIntencityA')

    const atmosphereMesh = new THREE.Mesh(earthGeometry, atmosphereMaterial)
    atmosphereMesh.scale.set(1.1, 1.1, 1.1)

    scene.add(atmosphereMesh)

    // Point
    // const pointsGeometry = new THREE.SphereGeometry(1, 5, 5)
    // const material = new THREE.MeshBasicMaterial({ color: 'red' })

    const getVec3Point = (lat: number, lon: number) => {
      const phi = ((90 - lat) * Math.PI) / 180
      const theta = (-lon * Math.PI) / 180

      return [
        distance * Math.sin(phi) * Math.cos(theta),
        distance * Math.cos(phi),
        distance * Math.sin(phi) * Math.sin(theta),
      ]
    }

    const particlesGeometry = new THREE.BufferGeometry()
    const distance = 2.001
    const positions = new Float32Array(
      data
        .map(([_, lat, lon]) => {
          if ((lon > -2 && lon < 0) || (lon > 150 && lon < 155)) {
            return [...getVec3Point(lat, lon), ...getVec3Point(lat, lon - 3)]
          }
          return getVec3Point(lat, lon)
        })
        .flat()
    )

    const alphas = new Float32Array(positions.length / 3)

    for (let i = 0; i < alphas.length; i++) {
      alphas[i] = 0.8
    }

    particlesGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3))
    particlesGeometry.setAttribute('alpha', new THREE.BufferAttribute(alphas, 1))

    const particlesMaterial = new THREE.ShaderMaterial({
      transparent: true,
      vertexShader: particleVertexShader,
      fragmentShader: particleFragmentShader,
      uniforms: {
        uColor: { value: new THREE.Color('0xffffff') },
        uSize: { value: 1.8 },
        uHeight: { value: 1.0 },
      },
    })

    const particles_folder = gui.addFolder('Particles')
    // particles_folder.close()
    particles_folder.add(particlesMaterial.uniforms.uSize, 'value').min(0).max(20).step(0.001).name('uSize')
    particles_folder.add(particlesMaterial.uniforms.uHeight, 'value').min(0.5).max(1).step(0.001).name('uHeight')

    const particles = new THREE.Points(particlesGeometry, particlesMaterial)
    scene.add(particles)

    particles.rotation.set(startRotation.x, startRotation.y, startRotation.z)
    gsap.to(particles.rotation, ratitionAnimationObject)

    /**
     * Raycaster
     */
    const raycaster = new THREE.Raycaster()

    /**
     * Animate
     */

    const animate = () => {
      const elapsedTime = clock.getElapsedTime()

      // const alphas = particlesGeometry.attributes.alpha
      // for (let i = 0; i < alphas.count; i++) {
      //   alphas.array[i] *= 0.5
      //   if (alphas.array[i] < 0.01) {
      //     alphas.array[i] = 1.0
      //   }
      // }

      // alphas.needsUpdate = true

      renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
      orbitControls.update()

      renderer.clear()
      renderer.render(scene, camera)
    }

    windowStore.subscribe((store) => {
      renderer.setSize(store.innerWidth, store.innerHeight)
      camera.aspect = store.innerWidth / store.innerHeight
      camera.updateProjectionMatrix()
    })

    handleResize(window)
    renderer.setAnimationLoop(animate)
    node.appendChild(renderer.domElement)
  }
</script>

<div class="scene" use:appMount on:mousemove={handleMouseMove} role="navigation" on:dblclick={handleDblClick}></div>
