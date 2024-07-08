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

    const scene = new THREE.Scene()
    const camera = new THREE.PerspectiveCamera(75, $windowStore.innerWidth / $windowStore.innerHeight, 0.1, 100)
    camera.position.x = 1
    camera.position.y = 1
    camera.position.z = 2
    scene.add(camera)

    const renderer = new THREE.WebGLRenderer({ antialias: true })
    renderer.shadowMap.enabled = true
    renderer.shadowMap.type = THREE.PCFSoftShadowMap

    const clock = new THREE.Clock()
    const orbitControls = new OrbitControls(camera, node)

    orbitControls.enableDamping = true

    /**
     * Lights
     */
    // Ambient light
    const ambientLight = new THREE.AmbientLight(0xffffff, 1)
    gui.add(ambientLight, 'intensity').min(0).max(3).step(0.001)
    scene.add(ambientLight)

    // Directional light
    const directionalLight = new THREE.DirectionalLight(0xffffff, 1.5)
    directionalLight.position.set(2, 2, -1)
    gui.add(directionalLight, 'intensity').min(0).max(3).step(0.001)
    gui.add(directionalLight.position, 'x').min(-5).max(5).step(0.001)
    gui.add(directionalLight.position, 'y').min(-5).max(5).step(0.001)
    gui.add(directionalLight.position, 'z').min(-5).max(5).step(0.001)
    scene.add(directionalLight)

    directionalLight.castShadow = true

    directionalLight.shadow.mapSize.set(1024, 1024)

    directionalLight.shadow.camera.near = 1
    directionalLight.shadow.camera.far = 6

    // gui.add(directionalLight.shadow.camera, 'near').min(0.1).max(20).step(0.001)
    // gui.add(directionalLight.shadow.camera, 'far').min(0.1).max(20).step(0.001)
    // gui.add(directionalLight.shadow.camera, 'top').min(-20).max(20).step(0.1)
    // gui.add(directionalLight.shadow.camera, 'right').min(-20).max(20).step(0.1)
    // gui.add(directionalLight.shadow.camera, 'left').min(-20).max(20).step(0.1)
    // gui.add(directionalLight.shadow.camera, 'bottom').min(-20).max(20).step(0.1)

    // gui.add(directionalLight.shadow, 'radius').min(0).max(150).step(0.1)

    const spotLight = new THREE.SpotLight(0xffffff, 3.6, 10, Math.PI * 0.3)
    spotLight.castShadow = true
    spotLight.position.set(0, 2, 2)
    spotLight.shadow.camera.fov = 30
    spotLight.shadow.camera.far = 5
    spotLight.shadow.camera.near = 1
    spotLight.shadow.mapSize.set(1024, 1024)
    scene.add(spotLight.target)
    scene.add(spotLight)

    /**
     * Helpers
     */

    // const spotLightCameraHelper = new THREE.CameraHelper(spotLight.shadow.camera)
    // scene.add(spotLightCameraHelper)

    // const directionalLightHelper = new THREE.DirectionalLightHelper(directionalLight)
    // scene.add(directionalLightHelper)

    // const directionalLightCameraHelper = new THREE.CameraHelper(directionalLight.shadow.camera)
    // scene.add(directionalLightCameraHelper)

    /**
     * Materials
     */
    const material = new THREE.MeshStandardMaterial()
    material.roughness = 0.7
    gui.add(material, 'metalness').min(0).max(1).step(0.001)
    gui.add(material, 'roughness').min(0).max(1).step(0.001)

    /**
     * Objects
     */
    const sphere = new THREE.Mesh(new THREE.SphereGeometry(0.5, 32, 32), material)
    sphere.castShadow = true

    const plane = new THREE.Mesh(new THREE.PlaneGeometry(5, 5), material)
    plane.receiveShadow = true
    plane.rotation.x = -Math.PI * 0.5
    plane.position.y = -0.5

    scene.add(sphere, plane)

    const animate = () => {
      const elapsedTime = clock.getElapsedTime()

      renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
      orbitControls.update()
      renderer.render(scene, camera)
      directionalLight.shadow.camera.updateProjectionMatrix()
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
