<script lang="ts">
  import windowStore, { handleResize } from '$lib/stores/windowStore'
  import * as THREE from 'three'
  import { OrbitControls } from 'three/examples/jsm/Addons.js'
  import GUI from 'lil-gui'
  import gsap from 'gsap'

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
    // Debug
    const gui = new GUI()

    // Scene
    const scene = new THREE.Scene()

    /**
     * Objects
     */
    const object1 = new THREE.Mesh(
      new THREE.SphereGeometry(0.5, 16, 16),
      new THREE.MeshBasicMaterial({ color: '#ff0000' })
    )
    object1.position.x = -2

    const object2 = new THREE.Mesh(
      new THREE.SphereGeometry(0.5, 16, 16),
      new THREE.MeshBasicMaterial({ color: '#ff0000' })
    )

    const object3 = new THREE.Mesh(
      new THREE.SphereGeometry(0.5, 16, 16),
      new THREE.MeshBasicMaterial({ color: '#ff0000' })
    )
    object3.position.x = 2

    scene.add(object1, object2, object3)

    /**
     * Camera
     */
    const camera = new THREE.PerspectiveCamera(75, $windowStore.innerWidth / $windowStore.innerHeight, 0.1, 100)
    camera.position.z = 6
    scene.add(camera)

    /**
     * Renderer
     */

    const renderer = new THREE.WebGLRenderer({ antialias: true })

    // Controls
    const orbitControls = new OrbitControls(camera, node)
    orbitControls.enableDamping = true

    /**
     * Raycaster
     */
    const raycaster = new THREE.Raycaster()
    // const rayOrigin = new THREE.Vector3(-3, 0, 0)
    // const rayDirection = new THREE.Vector3(10, 0, 0).normalize()
    // raycaster.set(rayOrigin, rayDirection)

    /**
     * Animate
     */
    const clock = new THREE.Clock()

    let currentIntersects: THREE.Intersection<THREE.Object3D<THREE.Object3DEventMap>> | null = null

    const animate = () => {
      const elapsedTime = clock.getElapsedTime()

      /**
       * Animate objects
       */
      object1.position.y = Math.sin(elapsedTime + Math.PI) * 3
      object2.position.y = Math.sin(elapsedTime + (Math.PI * 2) / 3) * 3
      object3.position.y = Math.sin(elapsedTime + Math.PI / 2) * 3

      /**
       * Raycaster
       */

      raycaster.setFromCamera(cursor, camera)

      const objectToTest = [object1, object2, object3]
      const intersects = raycaster.intersectObjects(objectToTest)

      if (intersects.length) {
        if (!currentIntersects) {
          console.log('enter')
        }

        currentIntersects = intersects[0]
      } else {
        if (currentIntersects) {
          console.log('leave')
        }

        currentIntersects = null
      }

      for (const object of objectToTest) {
        object.material.color.set('red')
      }

      for (const intersect of intersects) {
        //@ts-ignore
        intersect.object.material.color.set(0x0000ff)
      }

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
