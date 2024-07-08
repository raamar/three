<script lang="ts">
	import windowStore, { handleResize } from '$lib/stores/windowStore';
	import * as THREE from 'three';

	const appMount = (node: HTMLElement) => {
		const scene = new THREE.Scene();
		const camera = new THREE.PerspectiveCamera(
			45,
			$windowStore.innerWidth / $windowStore.innerHeight,
			1,
			500
		);

		const renderer = new THREE.WebGLRenderer();

		const material = new THREE.LineBasicMaterial({ color: 0xff8800 });
		const points = [];

		points.push(new THREE.Vector3(-7, 0, 0));
		points.push(new THREE.Vector3(0, 20, 0));
		points.push(new THREE.Vector3(7, 0, 0));
		points.push(new THREE.Vector3(-10, 13, 0));
		points.push(new THREE.Vector3(10, 13, 0));
		points.push(new THREE.Vector3(-7, 0, 0));

		const geomerty = new THREE.BufferGeometry().setFromPoints(points);
		const line = new THREE.Line(geomerty, material);

		const animate = () => {
			renderer.render(scene, camera);
		};

		camera.position.set(0, 0, 100);
		camera.lookAt(0, 0, 0);

		scene.add(line);

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
