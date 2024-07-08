<script lang="ts">
	import './globals.css';
	import { handleResize } from '$lib/stores/windowStore';
</script>

<svelte:window on:resize={() => handleResize(window)} />

<div class="scenes">
	<slot />
</div>
