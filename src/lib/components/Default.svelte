<script lang="ts">
  import windowStore, { handleResize } from '$lib/stores/windowStore'
  import * as THREE from 'three'
  import { OrbitControls } from 'three/examples/jsm/Addons.js'
  import GUI from 'lil-gui'
  import gsap from 'gsap'

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
    // Debug
    const gui = new GUI()

    // Scene
    const scene = new THREE.Scene()

    /**
     * Camera
     */
    const camera = new THREE.PerspectiveCamera(75, $windowStore.innerWidth / $windowStore.innerHeight, 0.1, 100)
    camera.position.z = 3
    scene.add(camera)

    /**
     * Renderer
     */

    const renderer = new THREE.WebGLRenderer({ antialias: true })

    // Controls
    const orbitControls = new OrbitControls(camera, node)
    orbitControls.enableDamping = true

    /**
     * Animate
     */
    const clock = new THREE.Clock()
    const animate = () => {
      const elapsedTime = clock.getElapsedTime()

      renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
      orbitControls.update()
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
