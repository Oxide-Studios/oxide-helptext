import { createApp } from 'vue'
import App from './App.vue'
import '@fontsource-variable/inter'
// Bundled, not loaded from a CDN: a NUI page has no guaranteed internet access, and without
// the icon font every prompt icon renders as an empty box.
import '@fortawesome/fontawesome-free/css/all.min.css'
import './style.css'

createApp(App).mount('#app')
