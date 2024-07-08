<script lang="ts">
	import windowStore, { handleResize } from '$lib/stores/windowStore';
	import * as THREE from 'three';
	import { GLTFLoader } from 'three/examples/jsm/Addons.js';
	import shiba from '$lib/assets/models/shiba/scene.gltf?url';
	import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

	const loader = new GLTFLoader();

	const appMount = (node: HTMLElement) => {
		const scene = new THREE.Scene();

		const camera = new THREE.PerspectiveCamera(
			75,
			$windowStore.innerWidth / $windowStore.innerHeight,
			0.1,
			500
		);

		const renderer = new THREE.WebGLRenderer({ antialias: true });

		const controls = new OrbitControls(camera, renderer.domElement);
		const animate = () => {
			controls.update();
			renderer.render(scene, camera);
		};

		renderer.setAnimationLoop(animate);

		loader.load(
			shiba,
			(gltf) => {
				scene.add(gltf.scene);
			},
			undefined,
			(error) => {
				console.error(error);
			}
		);

		camera.position.set(0, 0, 4);
		camera.lookAt(0, 0, 0);
		camera.rotateY(0.2);

		windowStore.subscribe((store) => {
			renderer.setSize(store.innerWidth, store.innerHeight);
			camera.aspect = store.innerWidth / store.innerHeight;
			camera.updateProjectionMatrix();
		});

		handleResize(window);
		node.appendChild(renderer.domElement);
	};
</script>

<div class="scene" use:appMount></div>
