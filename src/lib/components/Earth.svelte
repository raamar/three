<script lang="ts">
	import windowStore, { handleResize } from '$lib/stores/windowStore';
	import * as THREE from 'three';
	import earthTexture from '$lib/assets/textures/world.jpg?url';
	import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
	import Shaders from '$lib/shaders/shaders';

	const appMount = async (container: HTMLElement) => {
		const textureLoader = new THREE.TextureLoader();
		const scene = new THREE.Scene();
		const sceneAtmosphere = new THREE.Scene();
		const camera = new THREE.PerspectiveCamera(
			30,
			$windowStore.innerWidth / $windowStore.innerHeight,
			1,
			1000
		);

		const renderer = new THREE.WebGLRenderer();
		const controls = new OrbitControls(camera, renderer.domElement);

		{
			const geometry = new THREE.SphereGeometry(0.5, 32, 32);

			const shader = Shaders['earth'];

			const material = new THREE.ShaderMaterial({
				uniforms: {},
				vertexShader: shader.vertexShader,
				fragmentShader: shader.fragmentShader
			});

			const mesh = new THREE.Mesh(geometry, material);
			scene.add(mesh);
		}

		{
			const geometry = new THREE.SphereGeometry(0.5, 32, 32);
			const shader = Shaders['atmosphere'];
			var uniforms = THREE.UniformsUtils.clone(shader.uniforms);

			const material = new THREE.ShaderMaterial({
				uniforms: uniforms,
				vertexShader: shader.vertexShader,
				fragmentShader: shader.fragmentShader
			});

			const mesh = new THREE.Mesh(geometry, material);
			mesh.scale.x = mesh.scale.y = mesh.scale.z = 1.1;
			sceneAtmosphere.add(mesh);
		}

		const animate = () => {
			controls.update();
			renderer.render(scene, camera);
			renderer.render(sceneAtmosphere, camera);
		};

		camera.position.z = 3;

		windowStore.subscribe((store) => {
			renderer.setSize(store.innerWidth, store.innerHeight);
			camera.aspect = store.innerWidth / store.innerHeight;
			camera.updateProjectionMatrix();
		});

		handleResize(window);
		renderer.setAnimationLoop(animate);
		container.appendChild(renderer.domElement);
	};
</script>

<div class="scene"></div>
