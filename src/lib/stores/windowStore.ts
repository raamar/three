import { writable } from 'svelte/store';

const windowStore = writable<{ innerWidth: number; innerHeight: number }>({
	innerHeight: 0,
	innerWidth: 0
});

const handleResize = (window: Window) => {
	windowStore.update((store) => ({
		innerHeight: window.innerHeight,
		innerWidth: window.innerWidth
	}));
};

export default windowStore;
export { handleResize };
