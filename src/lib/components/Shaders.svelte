<script lang="ts">
  import windowStore, { handleResize } from '$lib/stores/windowStore'
  import * as THREE from 'three'
  import { OrbitControls } from 'three/examples/jsm/Addons.js'
  import testVertexShader from '$lib/shaders/test/vertex.glsl?raw'
  import testFragmentShader from '$lib/shaders/test/fragment.glsl?raw'
  import GUI from 'lil-gui'
  import russianFlagTextureUrl from '$lib/assets/textures/flags/russian_flag.jpg?url'
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
    camera.position.set(0.25, -0.25, 1)
    scene.add(camera)

    const renderer = new THREE.WebGLRenderer({ antialias: true })

    const clock = new THREE.Clock()
    const orbitControls = new OrbitControls(camera, node)

    orbitControls.enableDamping = true

    /**
     * Textures
     */
    const textureLoader = new THREE.TextureLoader()

    const reussianFlagTexture = textureLoader.load(russianFlagTextureUrl)

    /**
     * Test mesh
     */
    // Geometry
    const geometry = new THREE.PlaneGeometry(1, 1, 32, 32)
    const count = geometry.attributes.position.count
    const randoms = new Float32Array(count)

    for (let i = 0; i < count; i++) {
      randoms[i] = Math.random()
    }

    geometry.setAttribute('aRandom', new THREE.BufferAttribute(randoms, 1))

    // Material
    const material = new THREE.ShaderMaterial({
      vertexShader: testVertexShader,
      fragmentShader: testFragmentShader,
      uniforms: {
        uFrequency: {
          value: new THREE.Vector2(10, 5),
        },
        uTime: {
          value: 0,
        },
        uColor: {
          value: new THREE.Color('red'),
        },
        uTexture: {
          value: reussianFlagTexture,
        },
      },
      // wireframe: true,
    })

    gui.add(material.uniforms.uFrequency.value, 'x').min(0).max(20).step(0.01).name('frequencyX')
    gui.add(material.uniforms.uFrequency.value, 'y').min(0).max(20).step(0.01).name('frequencyY')

    // Mesh
    const mesh = new THREE.Mesh(geometry, material)
    mesh.scale.y = 2 / 3

    scene.add(mesh)

    const animate = () => {
      const elapsedTime = clock.getElapsedTime()

      material.uniforms.uTime.value = elapsedTime

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
