<script lang="ts">
  import windowStore, { handleResize } from '$lib/stores/windowStore'
  import * as THREE from 'three'
  import { OrbitControls, RGBELoader } from 'three/examples/jsm/Addons.js'
  import GUI from 'lil-gui'
  import gsap from 'gsap'

  import doorColorTextureUrl from '$lib/assets/textures/door/color.jpg'
  import doorAlphaTextureUrl from '$lib/assets/textures/door/alpha.jpg'
  import doorAmbientOcclusionTextureUrl from '$lib/assets/textures/door/ambientOcclusion.jpg'
  import doorHeightTextureUrl from '$lib/assets/textures/door/height.jpg'
  import doorNormalTextureUrl from '$lib/assets/textures/door/normal.jpg'
  import doorMetalnessTextureUrl from '$lib/assets/textures/door/metalness.jpg'
  import doorRoughnessTextureUrl from '$lib/assets/textures/door/roughness.jpg'
  import matcapTextureUrl from '$lib/assets/textures/matcaps/4.png'
  import gradientTextureUrl from '$lib/assets/textures/gradients/3.jpg'

  import enviromentMap from '$lib/assets/textures/environmentMap/2k.hdr?url'

  const textureLoader = new THREE.TextureLoader()

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
    const doorColorTexture = textureLoader.load(doorColorTextureUrl)
    const doorAlphaTexture = textureLoader.load(doorAlphaTextureUrl)
    const doorAmbientOcclusionTexture = textureLoader.load(doorAmbientOcclusionTextureUrl)
    const doorHeightTexture = textureLoader.load(doorHeightTextureUrl)
    const doorNormalTexture = textureLoader.load(doorNormalTextureUrl)
    const doorMetalnessTexture = textureLoader.load(doorMetalnessTextureUrl)
    const doorRoughnessTexture = textureLoader.load(doorRoughnessTextureUrl)
    const matcapTexture = textureLoader.load(matcapTextureUrl)
    const gradientTexture = textureLoader.load(gradientTextureUrl)

    doorColorTexture.colorSpace = THREE.SRGBColorSpace
    matcapTexture.colorSpace = THREE.SRGBColorSpace

    const gui = new GUI()

    gui.hide()

    const config = {
      color: '#1100ff',
      spin: () => {},
    }

    // gui.hide()

    const scene = new THREE.Scene()
    const camera = new THREE.PerspectiveCamera(75, $windowStore.innerWidth / $windowStore.innerHeight, 0.1, 100)

    // const ambientLight = new THREE.AmbientLight(0xffffff, 1)
    // scene.add(ambientLight)

    // const pointLight = new THREE.PointLight(0xffffff, 30)

    // pointLight.position.set(2, 3, 4)
    // scene.add(pointLight)

    const renderer = new THREE.WebGLRenderer({ antialias: true })

    const clock = new THREE.Clock()
    const orbitControls = new OrbitControls(camera, node)

    orbitControls.enableDamping = true

    const material = new THREE.MeshMatcapMaterial({ matcap: matcapTexture })
    const torusGeometry = new THREE.TorusGeometry(0.3, 0.2, 64, 128)

    const group = Array.from({ length: 100 }).map(() => {
      const torus = new THREE.Mesh(torusGeometry, material)

      torus.position.x = (Math.random() - 0.5) * 10
      torus.position.y = (Math.random() - 0.5) * 10
      torus.position.z = (Math.random() - 0.5) * 10

      torus.rotation.x = Math.random() * Math.PI
      torus.rotation.y = Math.random() * Math.PI
      torus.rotation.z = Math.random() * Math.PI

      const scale = (Math.random() + 1) * 0.2

      torus.scale.set(scale, scale, scale)

      gsap.to(torus.rotation, { x: Math.random() * Math.PI, y: Math.random() * Math.PI * 30, duration: 120 })

      return torus
    })

    scene.add(...group)

    camera.position.z = 5

    const animate = () => {
      const elapsedTime = clock.getElapsedTime()

      // const rotationY = elapsedTime * 0.1
      // const rotationX = elapsedTime * -0.15

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
