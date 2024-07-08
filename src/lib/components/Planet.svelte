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
  import worldTextureUrl from '$lib/assets/textures/world.jpg?url'
  import { points as data } from '$lib/data/points'

  const cursor = {
    x: 0,
    y: 0,
  }

  const handleMouseMove = (event: MouseEvent) => {
    cursor.x = event.clientX / $windowStore.innerWidth - 0.5
    cursor.y = -(event.clientY / $windowStore.innerHeight - 0.5)
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
    camera.position.set(0, 0, 1500)
    gsap.to(camera.position, { z: 900, duration: 1.5 })
    scene.add(camera)

    const renderer = new THREE.WebGLRenderer({ antialias: true })

    const clock = new THREE.Clock()
    const orbitControls = new OrbitControls(camera, node)

    orbitControls.enablePan = false
    orbitControls.enableDamping = true
    // orbitControls.minDistance = 900
    orbitControls.maxDistance = 1500

    /**
     * Textures
     */

    const textureLoader = new THREE.TextureLoader()
    const worldTexture = textureLoader.load(worldTextureUrl)

    /**
     * Objects
     */

    // Earth

    const earthGeometry = new THREE.SphereGeometry(200, 40, 30)
    const earthMaterial = new THREE.ShaderMaterial({
      vertexShader: earthVertexShader,
      fragmentShader: earthFragmentShader,
      uniforms: {
        uTexture: {
          value: worldTexture,
        },
      },
    })

    const earthMesh = new THREE.Mesh(earthGeometry, earthMaterial)
    scene.add(earthMesh)

    // Atmosphere
    const atmosphereMaterial = new THREE.ShaderMaterial({
      vertexShader: atmosphereVertexShader,
      fragmentShader: atmosphereFragmentShader,
      side: THREE.DoubleSide,
      transparent: true,
      depthWrite: false,
      blending: THREE.AdditiveBlending,
    })

    const atmosphereMesh = new THREE.Mesh(earthGeometry, atmosphereMaterial)
    atmosphereMesh.scale.set(1.1, 1.1, 1.1)

    scene.add(atmosphereMesh)

    // Point
    const pointsGeometry = new THREE.SphereGeometry(2)
    const material = new THREE.MeshBasicMaterial({ color: 'red' })

    const point = new THREE.Mesh(pointsGeometry, material)
    const fix = {
      lat: -68,
      lon: 16,
    }

    let [lat, lon] = [44.386971, 33.7768]

    lat = ((lat + fix.lat) * Math.PI) / 180
    lon = ((lon + fix.lon) * Math.PI) / 180

    point.position.set(200 * Math.cos(lat) * Math.cos(lon), 200 * Math.cos(lat) * Math.sin(lon), 200 * Math.sin(lat))

    scene.add(point)
    /**
     *
     */

    const animate = () => {
      const elapsedTime = clock.getElapsedTime()

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
