<script lang="ts">
	import windowStore, { handleResize } from '$lib/stores/windowStore';
	import * as THREE from 'three';
	import earthTexture from '$lib/assets/textures/earth.png?url';
	import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

	const appMount = (node: HTMLElement) => {
		const scene = new THREE.Scene();
		const camera = new THREE.PerspectiveCamera(
			45,
			$windowStore.innerWidth / $windowStore.innerHeight,
			1,
			500
		);

		const renderer = new THREE.WebGLRenderer({ antialias: true });
		const controls = new OrbitControls(camera, renderer.domElement);

		const geomerty = new THREE.SphereGeometry(0.5, 32, 32);
		const texture = new THREE.TextureLoader().load(earthTexture);
		const material = new THREE.MeshBasicMaterial({ map: texture });
		const earthMesh = new THREE.Mesh(geomerty, material);

		scene.add(earthMesh);

		const animate = () => {
			controls.update();
			renderer.render(scene, camera);
		};

		camera.position.z = 3;

		windowStore.subscribe((store) => {
			renderer.setSize(store.innerWidth, store.innerHeight);
			camera.aspect = store.innerWidth / store.innerHeight;
			camera.updateProjectionMatrix();
		});

		handleResize(window);
		renderer.setAnimationLoop(animate);
		node.appendChild(renderer.domElement);
	};
</script>

<div class="scene" use:appMount></div>
