<script lang="ts">
  import windowStore, { handleResize } from '$lib/stores/windowStore'
  import * as THREE from 'three'
  import { OrbitControls, RectAreaLightHelper } from 'three/examples/jsm/Addons.js'
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

    const scene = new THREE.Scene()

    const camera = new THREE.PerspectiveCamera(75, $windowStore.innerWidth / $windowStore.innerHeight, 0.1, 100)
    camera.position.x = 1
    camera.position.y = 1
    camera.position.z = 2
    scene.add(camera)

    const renderer = new THREE.WebGLRenderer({ antialias: true })

    const orbitControls = new OrbitControls(camera, node)
    orbitControls.enableDamping = true

    /**
     * Lights
     */
    const ambientLight = new THREE.AmbientLight(0xffffff, 1)
    scene.add(ambientLight)
    gui.add(ambientLight, 'intensity').min(0).max(3).step(0.001).name('Ambient intensity')

    const directionalLight = new THREE.DirectionalLight(0x00fffc, 0.9)
    scene.add(directionalLight)
    directionalLight.position.set(1, 0.25, 0)
    gui.add(directionalLight.position, 'x').min(-10).max(10).step(0.001).name('Directional Light X')
    gui.add(directionalLight.position, 'y').min(-10).max(10).step(0.001).name('Directional Light Y')
    gui.add(directionalLight.position, 'z').min(-10).max(10).step(0.001).name('Directional Light Z')

    const hemisphereLight = new THREE.HemisphereLight(0xff00000, 0x0000ff, 0.9)
    scene.add(hemisphereLight)

    const pointLight = new THREE.PointLight(0xff9000, 1.5)
    scene.add(pointLight)
    pointLight.position.set(1, 2, 1)
    gui.add(pointLight.position, 'x').min(-10).max(10).step(0.001).name('Point Light X')
    gui.add(pointLight.position, 'y').min(-10).max(10).step(0.001).name('Point Light Y')
    gui.add(pointLight.position, 'z').min(-10).max(10).step(0.001).name('Point Light Z')
    gui.add(pointLight, 'intensity').min(0).max(15).step(0.01).name('Point Light Intensity')
    gui.add(pointLight, 'distance').min(0).max(15).step(0.01).name('Point Light Disctance')

    const rectAreaLight = new THREE.RectAreaLight(0x4e00ff, 6, 1, 1)
    scene.add(rectAreaLight)
    gui.add(rectAreaLight.position, 'x').min(-10).max(10).step(0.001).name('Rect area ligh X')
    gui.add(rectAreaLight.position, 'y').min(-10).max(10).step(0.001).name('Rect area ligh Y')
    gui.add(rectAreaLight.position, 'z').min(-10).max(10).step(0.001).name('Rect area ligh Z')
    gui.add(rectAreaLight, 'intensity').min(0).max(10).step(0.001).name('Rect area ligh intensity')
    gui.add(rectAreaLight, 'width').min(0).max(10).step(0.001).name('Rect area ligh width')
    gui.add(rectAreaLight, 'height').min(0).max(10).step(0.001).name('Rect area ligh height')
    rectAreaLight.position.set(-1.5, 0, 1.5)

    const spotLight = new THREE.SpotLight(0x78ff00, 4.5, 10, Math.PI * 0.1, 0.25, 1)
    spotLight.position.set(0, 2, 3)
    scene.add(spotLight)

    // Helpers

    const hemisphereLightHelper = new THREE.HemisphereLightHelper(hemisphereLight, 0.2)
    scene.add(hemisphereLightHelper)

    const directionalLightHelper = new THREE.DirectionalLightHelper(directionalLight, 0.2)
    scene.add(directionalLightHelper)

    const pointLightHelper = new THREE.PointLightHelper(pointLight, 0.2)
    scene.add(pointLightHelper)

    const spotLightHelper = new THREE.SpotLightHelper(spotLight)
    scene.add(spotLightHelper)

    const rectAreaLightHelper = new RectAreaLightHelper(rectAreaLight)
    scene.add(rectAreaLightHelper)

    /**
     * Objects
     */
    // Material
    const material = new THREE.MeshStandardMaterial()
    material.roughness = 0.4

    // Objects
    const sphere = new THREE.Mesh(new THREE.SphereGeometry(0.5, 32, 32), material)
    sphere.position.x = -1.5

    const cube = new THREE.Mesh(new THREE.BoxGeometry(0.75, 0.75, 0.75), material)

    const torus = new THREE.Mesh(new THREE.TorusGeometry(0.3, 0.2, 32, 64), material)
    torus.position.x = 1.5

    const plane = new THREE.Mesh(new THREE.PlaneGeometry(5, 5), material)
    plane.rotation.x = -Math.PI * 0.5
    plane.position.y = -0.65

    scene.add(sphere, cube, torus, plane)

    const clock = new THREE.Clock()

    const animate = () => {
      const elapsedTime = clock.getElapsedTime()

      // Update objects
      sphere.rotation.y = 0.1 * elapsedTime
      cube.rotation.y = 0.1 * elapsedTime
      torus.rotation.y = 0.1 * elapsedTime

      sphere.rotation.x = 0.15 * elapsedTime
      cube.rotation.x = 0.15 * elapsedTime
      torus.rotation.x = 0.15 * elapsedTime

      // Update controls
      orbitControls.update()

      // Render
      renderer.render(scene, camera)
      renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
    }

    renderer.setAnimationLoop(animate)

    windowStore.subscribe((store) => {
      renderer.setSize(store.innerWidth, store.innerHeight)
      camera.aspect = store.innerWidth / store.innerHeight
      camera.updateProjectionMatrix()
    })

    handleResize(window)

    node.appendChild(renderer.domElement)
  }
</script>

<div class="scene" use:appMount on:mousemove={handleMouseMove} role="navigation" on:dblclick={handleDblClick}></div>
