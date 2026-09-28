import { onMounted, onUnmounted } from 'vue'

/**
 * Vue composable to listen for NUI messages from Lua
 * @param {string} action - The action to listen for
 * @param {function} handler - The handler function
 */
export function useNuiEvent(action, handler) {
  const eventListener = (event) => {
    const { action: eventAction, data } = event.data
    if (eventAction === action) {
      handler(data)
    }
  }

  onMounted(() => {
    window.addEventListener('message', eventListener)
  })

  onUnmounted(() => {
    window.removeEventListener('message', eventListener)
  })
}

/**
 * One-time listener setup (for use outside of component lifecycle)
 * @param {string} action - The action to listen for
 * @param {function} handler - The handler function
 * @returns {function} - Cleanup function
 */
export function addNuiListener(action, handler) {
  const eventListener = (event) => {
    const { action: eventAction, data } = event.data
    if (eventAction === action) {
      handler(data)
    }
  }

  window.addEventListener('message', eventListener)

  return () => {
    window.removeEventListener('message', eventListener)
  }
}
