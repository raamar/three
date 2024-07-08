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
  import matcapTextureUrl from '$lib/assets/textures/matcaps/15.png'
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

    // Objects

    // const material = new THREE.MeshBasicMaterial({ map: doorColorTexture })
    // const material = new THREE.MeshNormalMaterial({ flatShading: true })

    // const material = new THREE.MeshMatcapMaterial()

    // const material = new THREE.MeshStandardMaterial()

    // material.map = doorColorTexture
    // material.aoMap = doorAmbientOcclusionTexture
    // material.aoMapIntensity = 1
    // material.displacementMap = doorHeightTexture
    // material.displacementScale = 0.1
    // material.metalnessMap = doorMetalnessTexture
    // material.roughnessMap = doorRoughnessTexture
    // material.normalMap = doorNormalTexture
    // material.normalScale.x = 0.5
    // material.normalScale.y = 0.5
    // material.alphaMap = doorAlphaTexture
    // material.transparent = true

    // material.metalness = 1
    // material.roughness = 1

    // gui.add(material, 'aoMapIntensity').min(0).max(10).step(0.01)
    // gui.add(material, 'displacementScale').min(0).max(3).step(0.01)
    // gui.add(material, 'metalness').min(0).max(1).step(0.0001)
    // gui.add(material, 'roughness').min(0).max(1).step(0.0001)
    // gui.add(material.normalScale, 'x').min(0).max(1).step(0.0001)
    // gui.add(material.normalScale, 'y').min(0).max(1).step(0.0001)

    const material = new THREE.MeshPhysicalMaterial()

    // material.map = doorColorTexture
    // material.aoMap = doorAmbientOcclusionTexture
    // material.aoMapIntensity = 1
    // material.displacementMap = doorHeightTexture
    // material.displacementScale = 0.1
    // material.metalnessMap = doorMetalnessTexture
    // material.roughnessMap = doorRoughnessTexture
    // material.normalMap = doorNormalTexture
    // material.normalScale.x = 0.5
    // material.normalScale.y = 0.5
    // material.alphaMap = doorAlphaTexture
    // material.transparent = true

    material.metalness = 0
    material.roughness = 0

    // material.clearcoat = 1
    // material.clearcoatRoughness = 0

    // gui.add(material, 'clearcoat').min(0).max(1).step(0.0001)
    // gui.add(material, 'clearcoatRoughness').min(0).max(1).step(0.0001)

    // material.sheen = 1
    // material.sheenRoughness = 0.25
    // material.sheenColor.set(1, 1, 1)

    // gui.add(material, 'sheen').min(0).max(1).step(0.0001)
    // gui.add(material, 'sheenRoughness').min(0).max(1).step(0.0001)
    // gui.addColor(material, 'sheenColor')

    material.iridescence = 1
    material.iridescenceIOR = 1
    material.iridescenceThicknessRange = [100, 800]

    gui.add(material, 'iridescence').min(0).max(1).step(0.01)
    gui.add(material, 'iridescenceIOR').min(1).max(2.333).step(0.01)
    gui.add(material.iridescenceThicknessRange, '0').min(1).max(1000).step(1)
    gui.add(material.iridescenceThicknessRange, '1').min(1).max(1000).step(1)

    material.transmission = 1
    material.ior = 1.5
    material.thickness = 0.5

    gui.add(material, 'transmission').min(0).max(1).step(0.0001)
    gui.add(material, 'ior').min(1).max(10).step(0.0001)
    gui.add(material, 'thickness').min(0).max(1).step(0.0001)

    // gui.add(material, 'aoMapIntensity').min(0).max(10).step(0.01)
    // gui.add(material, 'displacementScale').min(0).max(3).step(0.01)
    // gui.add(material, 'metalness').min(0).max(1).step(0.0001)
    // gui.add(material, 'roughness').min(0).max(1).step(0.0001)
    // gui.add(material.normalScale, 'x').min(0).max(1).step(0.0001)
    // gui.add(material.normalScale, 'y').min(0).max(1).step(0.0001)

    // material.side = THREE.DoubleSide
    // material.matcap = matcapTexture

    const sphere = new THREE.Mesh(new THREE.SphereGeometry(0.5, 64, 64), material)

    sphere.position.x = -1.5

    const plane = new THREE.Mesh(new THREE.PlaneGeometry(1, 1, 100, 100), material)

    const torus = new THREE.Mesh(new THREE.TorusGeometry(0.3, 0.2, 64, 128), material)
    scene.add(sphere, plane, torus)

    torus.position.x = 1.5

    camera.position.z = 2

    const rgbeLoader = new RGBELoader()

    rgbeLoader.load(enviromentMap, (enviromentMap) => {
      enviromentMap.mapping = THREE.EquirectangularReflectionMapping

      scene.background = enviromentMap
      scene.environment = enviromentMap
    })

    const animate = () => {
      const elapsedTime = clock.getElapsedTime()

      const rotationY = elapsedTime * 0.1
      const rotationX = elapsedTime * -0.15

      sphere.rotation.y = rotationY
      plane.rotation.y = rotationY
      torus.rotation.y = rotationY
      sphere.rotation.x = rotationX
      plane.rotation.x = rotationX
      torus.rotation.x = rotationX

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
