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
  import particleVertexShader from '$lib/shaders/particle/vertex.glsl?raw'
  import particleFragmentShader from '$lib/shaders/particle/fragment.glsl?raw'
  import { points as data } from '$lib/data/points'
  import logoTextureUrl from '$lib/assets/textures/logo.png?url'
  import rayTextureUrl from '$lib/assets/textures/rays/lightray.jpg?url'
  import { blur } from 'svelte/transition'

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
    const gui = new GUI()

    gui.hide()

    const scene = new THREE.Scene()

    const camera = new THREE.PerspectiveCamera(30, $windowStore.innerWidth / $windowStore.innerHeight, 0.1, 10000)
    camera.position.set(0, 0, 3)
    gsap.to(camera.position, { z: 9, duration: 3.5 }).eventCallback('onComplete', () => {
      orbitControls.minDistance = 5
    })
    const orbitControls = new OrbitControls(camera, node)

    orbitControls.enablePan = false
    orbitControls.enableDamping = true
    orbitControls.maxDistance = 9

    scene.add(camera)

    const renderer = new THREE.WebGLRenderer({
      antialias: true,
      alpha: true,
    })

    /**
     * Textures
     */

    const textureLoader = new THREE.TextureLoader()
    const logoTexture = textureLoader.load(logoTextureUrl)
    // const pointTexture = textureLoader.load(pointTextureUrl)
    const rayTexture = textureLoader.load(rayTextureUrl)

    /**
     * Objects
     */

    // Earth

    const startRotation = { x: Math.PI * 0.62, y: Math.PI * -0.25, z: Math.PI * 0.2 }
    const ratitionAnimationObject = { x: Math.PI * 0.2, y: Math.PI * -0.4, z: Math.PI * 0.1, duration: 4.5 }

    // const startRotation = { x: 0, y: 0, z: 0 }
    // const ratitionAnimationObject = { x: 0, y: 0, z: 0 }
    const earthGeometry = new THREE.SphereGeometry(2, 64, 64)
    const earthMaterial = new THREE.ShaderMaterial({
      vertexShader: earthVertexShader,
      fragmentShader: earthFragmentShader,
      uniforms: {
        uColor: {
          value: new THREE.Color('#474747'),
        },
        uIntencity: {
          value: 1.05,
        },

        uIntencityX: {
          value: 0.1,
        },
        uIntencityY: {
          value: -0.19,
        },
        uIntencityZ: {
          value: 0.78,
        },
        uAtmosphereR: {
          value: 1.0,
        },
        uAtmosphereG: {
          value: 1.0,
        },
        uAtmosphereB: {
          value: 1.0,
        },
        uAtmospherePow: {
          value: 3.85,
        },

        uFragColorA: {
          value: 1.0,
        },
      },
    })

    const config = {
      uColor: '#474747',
    }

    const earth_folder = gui.addFolder('Earth')
    earth_folder.close()
    earth_folder.add(earthMaterial.uniforms.uIntencity, 'value').min(0).max(10).step(0.01).name('uIntencity')
    earth_folder.add(earthMaterial.uniforms.uIntencityX, 'value').min(-10).max(10).step(0.01).name('uIntencityX')
    earth_folder.add(earthMaterial.uniforms.uIntencityY, 'value').min(-10).max(10).step(0.01).name('uIntencityY')
    earth_folder.add(earthMaterial.uniforms.uIntencityZ, 'value').min(-10).max(10).step(0.01).name('uIntencityZ')
    earth_folder.add(earthMaterial.uniforms.uAtmosphereR, 'value').min(0).max(1).step(0.01).name('uAtmosphereR')
    earth_folder.add(earthMaterial.uniforms.uAtmosphereG, 'value').min(0).max(1).step(0.01).name('uAtmosphereG')
    earth_folder.add(earthMaterial.uniforms.uAtmosphereB, 'value').min(0).max(1).step(0.01).name('uAtmosphereB')
    earth_folder.add(earthMaterial.uniforms.uAtmospherePow, 'value').min(-10).max(10).step(0.01).name('uAtmospherePow')
    earth_folder.add(earthMaterial.uniforms.uFragColorA, 'value').min(0).max(1).step(0.001).name('uFragColorA')
    earth_folder
      .addColor(config, 'uColor')
      .onChange(() => (earthMaterial.uniforms.uColor.value = new THREE.Color(config.uColor)))

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
      uniforms: {
        uIntencity: {
          value: 0.8,
        },
        uIntencityX: {
          value: 0.02,
        },
        uIntencityY: {
          value: -0.02,
        },
        uIntencityZ: {
          value: 1.0,
        },
        uIntencityPow: {
          value: 12.0,
        },
        uIntencityR: {
          value: 1.0,
        },
        uIntencityG: {
          value: 1.0,
        },
        uIntencityB: {
          value: 1.0,
        },
        uIntencityA: {
          value: 0.8,
        },
      },
    })

    const atmosphere_folder = gui.addFolder('Atmosphere')
    atmosphere_folder.close()
    atmosphere_folder.add(atmosphereMaterial.uniforms.uIntencity, 'value').min(0).max(3).step(0.001).name('uIntencity')
    atmosphere_folder
      .add(atmosphereMaterial.uniforms.uIntencityX, 'value')
      .min(0)
      .max(3)
      .step(0.001)
      .name('uIntencityX')
    atmosphere_folder
      .add(atmosphereMaterial.uniforms.uIntencityY, 'value')
      .min(-10)
      .max(10)
      .step(0.001)
      .name('uIntencityY')
    atmosphere_folder
      .add(atmosphereMaterial.uniforms.uIntencityZ, 'value')
      .min(-10)
      .max(10)
      .step(0.001)
      .name('uIntencityZ')
    atmosphere_folder
      .add(atmosphereMaterial.uniforms.uIntencityPow, 'value')
      .min(-10)
      .max(20)
      .step(0.001)
      .name('uIntencityPow')
    atmosphere_folder
      .add(atmosphereMaterial.uniforms.uIntencityR, 'value')
      .min(0)
      .max(1)
      .step(0.001)
      .name('uIntencityR')
    atmosphere_folder
      .add(atmosphereMaterial.uniforms.uIntencityG, 'value')
      .min(0)
      .max(1)
      .step(0.001)
      .name('uIntencityG')
    atmosphere_folder
      .add(atmosphereMaterial.uniforms.uIntencityB, 'value')
      .min(0)
      .max(1)
      .step(0.001)
      .name('uIntencityB')
    atmosphere_folder
      .add(atmosphereMaterial.uniforms.uIntencityA, 'value')
      .min(0)
      .max(1)
      .step(0.001)
      .name('uIntencityA')

    const atmosphereMesh = new THREE.Mesh(earthGeometry, atmosphereMaterial)
    atmosphereMesh.scale.set(1.1, 1.1, 1.1)

    scene.add(atmosphereMesh)

    /**
     * Dots Texture
     */

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
    const alphas = new Float32Array(positions.length / 3)

    for (let i = 0; i < alphas.length; i++) {
      alphas[i] = 0.8
    }

    const intersections = new Float32Array(positions.length / 3)

    for (let i = 0; i < alphas.length; i++) {
      intersections[i] = 0
    }

    particlesGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3))
    particlesGeometry.setAttribute('alpha', new THREE.BufferAttribute(alphas, 1))
    particlesGeometry.setAttribute('intersections', new THREE.BufferAttribute(intersections, 1))

    const particlesMaterial = new THREE.ShaderMaterial({
      transparent: true,
      vertexShader: particleVertexShader,
      fragmentShader: particleFragmentShader,
      uniforms: {
        uColor: { value: new THREE.Color('#ffffff') },
        uSize: { value: 1.5 },
        uHeight: { value: 0.999 },
        alphaTest: { value: 0.9 },
      },
    })

    const particles_folder = gui.addFolder('Particles')
    particles_folder.close()
    particles_folder.add(particlesMaterial.uniforms.uSize, 'value').min(0).max(20).step(0.001).name('uSize')
    particles_folder.add(particlesMaterial.uniforms.uHeight, 'value').min(0.5).max(1).step(0.001).name('uHeight')

    const particles = new THREE.Points(particlesGeometry, particlesMaterial)
    scene.add(particles)

    particles.rotation.set(startRotation.x, startRotation.y, startRotation.z)
    gsap.to(particles.rotation, ratitionAnimationObject)

    // Projects

    const projectsPoints = [
      [44.500237, 34.171698],
      [59.938367, 30.298518],
      [20.452013, 0.888921],
      [17.966516, 47.252022],
      [40.599914, 16.578645],
      [38.078267, 22.811702],
      [42.176262, 3.090772],
      [49.899965, 14.844719],
      [-6.814316, -39.744845],
      [-8.814316, -35.744845],
      [61.33452, -43.989966],
      [30.538418, 3.070963],
      [36.14164, 9.497045],
      [-3.866223, 25.688004],
      [29.849821, 26.865197],
      [36.918434, -58.141933],
      [17.052948930924412, 18.331350638816033],
    ]

    rayTexture.wrapT = THREE.ClampToEdgeWrapping

    const rotationFix = { lat: -10, lon: -88 }
    const h = 0.8

    const raysMap: Record<string, number> = {}

    const rayBaseGeometry = new THREE.CircleGeometry(0.015, 16, 16)
    const rayClickAreaGeometry = new THREE.CircleGeometry(0.5, 16, 16)

    const rayClickMaterial = new THREE.MeshBasicMaterial({
      color: 'white',
      transparent: true,
      side: THREE.DoubleSide,
      opacity: 0,
    })

    const rayGroups = projectsPoints.map(([lat, lon], index) => {
      const rayGroup = new THREE.Group()

      const light_material = new THREE.MeshBasicMaterial({
        transparent: true,
        opacity: 0.9,

        blending: THREE.AdditiveBlending,
        side: THREE.DoubleSide,
        map: rayTexture,
        depthWrite: false,
      })
      const rayBaseMaterial = new THREE.MeshBasicMaterial({
        color: 'white',
        side: THREE.DoubleSide,
        transparent: true,
      })
      const rayBase = new THREE.Mesh(rayBaseGeometry, rayBaseMaterial)
      const rayClickArea = new THREE.Mesh(rayClickAreaGeometry, rayClickMaterial)
      const height = (Math.random() * h) / 2 + h / 2
      const rayGeometry = new THREE.PlaneGeometry(0.02, height, 2)
      const rayPlane = new THREE.Mesh(rayGeometry, light_material)
      var positionAttribute = rayGeometry.getAttribute('position')
      var vertex = new THREE.Vector3()

      for (var i = 0; i < positionAttribute.count; i++) {
        vertex.fromBufferAttribute(positionAttribute, i)
        vertex.applyMatrix4(new THREE.Matrix4().makeRotationX(Math.PI / 2))
        vertex.add(new THREE.Vector3(0, 0, -height / 2))
        positionAttribute.setXYZ(i, vertex.x, vertex.y, vertex.z)
      }

      positionAttribute.needsUpdate = true

      const rayPlane2 = rayPlane.clone()
      rayPlane.add(rayPlane2)
      rayPlane2.rotation.z = Math.PI / 2
      rayPlane2.updateMatrix()

      rayPlane.position.copy(new THREE.Vector3(...getVec3Point(lat + rotationFix.lat, lon + rotationFix.lon)))
      rayPlane.lookAt(new THREE.Vector3())

      rayBase.position.copy(rayPlane.position)
      rayClickArea.position.copy(rayPlane.position)
      rayClickArea.translateZ(-0.3)
      rayBase.lookAt(new THREE.Vector3())
      rayClickArea.lookAt(new THREE.Vector3())
      const startPos = rayPlane.position.clone()
      rayPlane.material.opacity = 0
      rayPlane.translateZ(3)
      rayBase.material.opacity = 0

      const delay = Math.random() * 2 + 4.5
      gsap.to(rayPlane.material, { opacity: 0.3, duration: 2.5, delay: delay, ease: 'sine' })
      gsap.to(rayBase.material, { opacity: 1, duration: 1, delay: delay, ease: 'sine' })
      gsap.to(rayPlane.position, {
        x: startPos.x,
        y: startPos.y,
        z: startPos.z,
        duration: 3,
        delay: delay - 1,
        ease: 'sine',
      })

      rayGroup.add(rayBase, rayPlane, rayClickArea)

      raysMap[rayBase.uuid] = index
      raysMap[rayClickArea.uuid] = index
      raysMap[rayPlane.uuid] = index
      raysMap[rayPlane2.uuid] = index

      return rayGroup
    })

    scene.add(...rayGroups)

    /**
     * Logo
     */

    const logo = new THREE.Sprite(
      new THREE.SpriteMaterial({
        map: logoTexture,
        depthWrite: false,
      })
    )
    0
    logo.position.set(0, 0, 2.2)
    logo.scale.set(0.128, 0.1, 1)
    scene.add(logo)

    /**
     * Raycaster
     */
    const raycaster = new THREE.Raycaster()

    raycaster.params.Points.threshold = 5
    raycaster.params.Line.threshold = 5

    /**
     * Animate
     */

    const quaternion = new THREE.Quaternion().setFromAxisAngle(new THREE.Vector3(0.1, -0.05, 0), 0.05)
    const clock = new THREE.Clock()
    let prevTime = clock.getElapsedTime()

    const animate = () => {
      const elapsedTime = clock.getElapsedTime()
      const tick = elapsedTime - prevTime
      prevTime = elapsedTime

      // raycaster.setFromCamera(cursor, camera)
      raycaster.setFromCamera(new THREE.Vector2(0, 0), camera)

      const rayIntersects = raycaster.intersectObjects(rayGroups, true)
      const rayIntersectsMap: Record<number, boolean> = {}

      //@ts-expect-error
      rayGroups.forEach((group) => group.children.forEach((child) => child.material.color.set('white')))
      if (rayIntersects.length) {
        rayIntersects.map((item) => (rayIntersectsMap[raysMap[item.object.uuid]] = true))
        Object.keys(rayIntersectsMap).forEach((key) =>
          //@ts-expect-error
          rayGroups[Number(key)]?.children?.forEach((child) => child.material.color.set('#fe5b00'))
        )
      }

      // const test = raycaster.intersectObject(particles)

      // particles.geometry.attributes.intersections.array.forEach((_, index) => {
      //   particles.geometry.attributes.intersections.array[index] = 0
      // })

      // if (test.length) {
      //   test.forEach((item) => {
      //     if (!item.index) {
      //       return
      //     }

      //     particles.geometry.attributes.intersections.array[item.index] = 1
      //   })
      // }

      // particles.geometry.attributes.intersections.needsUpdate = true

      logo.position.applyQuaternion(quaternion)

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
    mount = true
  }

  let mount = false
</script>

<div class="container">
  {#key mount}
    <div
      class="scene"
      use:appMount
      on:mousemove={handleMouseMove}
      role="navigation"
      on:dblclick={handleDblClick}
      in:blur={{ duration: 2000, amount: 50 }}
    ></div>
  {/key}
</div>

<style>
  .container {
    background: rgb(24, 24, 24);
    background: linear-gradient(151deg, rgba(24, 24, 24, 1) 0%, rgb(27, 27, 27) 100%);
  }
</style>
