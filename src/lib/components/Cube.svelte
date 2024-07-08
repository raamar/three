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
    const gui = new GUI()

    const config = {
      color: '#1100ff',
      spin: () => {},
    }

    const scene = new THREE.Scene()
    const camera = new THREE.PerspectiveCamera(75, $windowStore.innerWidth / $windowStore.innerHeight, 0.1, 100)

    const renderer = new THREE.WebGLRenderer({ antialias: true })

    const geomerty = new THREE.BoxGeometry(1, 1, 1, 5, 5, 5)

    const material = new THREE.MeshBasicMaterial({ color: config.color, wireframe: true })
    const cube = new THREE.Mesh(geomerty, material)

    const clock = new THREE.Clock()
    const orbitControls = new OrbitControls(camera, node)

    orbitControls.enableDamping = true

    // const acesHelper = new THREE.AxesHelper(4)

    camera.position.z = 3
    // camera.lookAt(cube.position)

    gui.add(cube.position, 'x', -3, 3)
    gui.add(cube.position, 'y', -1.3, 1.3)
    gui.add(material, 'wireframe')
    gui.addColor(config, 'color').onChange(() => {
      material.color.set(config.color)
    })

    config.spin = () => {
      gsap.to(cube.rotation, { y: cube.rotation.y + Math.PI * 2, duration: 2 })
    }

    gui.add(config, 'spin')

    const animate = () => {
      const elapsedTime = clock.getElapsedTime()
      // cube.rotation.y = elapsedTime
      // cube.rotation.x = elapsedTime

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

    scene.add(cube)
    // scene.add(acesHelper)

    node.appendChild(renderer.domElement)
  }
</script>

<div class="dev">
  <pre>{JSON.stringify(cursor, null, 2)}</pre>
</div>
<div class="scene" use:appMount on:mousemove={handleMouseMove} role="navigation" on:dblclick={handleDblClick}></div>

<style>
  .dev {
    position: fixed;
    top: 0;
    left: 0;
    background-color: rgba(255, 255, 255, 1);
    pointer-events: none;
    opacity: 0.5;
  }
</style>
