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
    // const gui = new GUI()

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
    const worldTexture = textureLoader.load(worldTextureUrl)

    /**
     * Objects
     */

    // Earth

    const startRotation = { x: Math.PI * 0.62, y: Math.PI * -0.25, z: Math.PI * 0.2 }
    const ratitionAnimationObject = { x: 0, y: Math.PI * -0.8, z: Math.PI * -0.05, duration: 4.5 }
    const earthGeometry = new THREE.SphereGeometry(2, 40, 30)
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
    })

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

    particlesGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3))

    const particlesMaterial = new THREE.PointsMaterial({
      size: 0.03,
      sizeAttenuation: true,
      // map: particleTexture,
      transparent: true,
      opacity: 0.9,
      // alphaMap: particleTexture,
      // depthWrite: false,

      // vertexColors: true,
      // color: '#ffffff',
    })

    const particles = new THREE.Points(particlesGeometry, particlesMaterial)
    scene.add(particles)

    particles.rotation.set(startRotation.x, startRotation.y, startRotation.z)
    gsap.to(particles.rotation, ratitionAnimationObject)

    // data.forEach(([size, lat, lon]) => {
    //   const point = new THREE.Mesh(pointsGeometry, material)
    //   const phi = ((90 - lat) * Math.PI) / 180
    //   const theta = (lon * Math.PI) / 180
    //   point.position.x = 200 * Math.sin(phi) * Math.cos(theta)
    //   point.position.y = 200 * Math.cos(phi)
    //   point.position.z = 200 * Math.sin(phi) * Math.sin(theta)
    //   // scene.add(point)
    // })

    /**
     * Raycaster
     */
    const raycaster = new THREE.Raycaster()

    /**
     * Animate
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
