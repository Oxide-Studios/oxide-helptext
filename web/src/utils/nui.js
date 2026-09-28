/**
 * Get the parent resource name for NUI callbacks
 */
export function getResourceName() {
  return window.GetParentResourceName ? window.GetParentResourceName() : 'oxide-helptext'
}

/**
 * Send a callback to Lua
 * @param {string} event - The event name
 * @param {object} data - The data to send
 * @returns {Promise<any>}
 */
export async function fetchNui(event, data = {}) {
  try {
    const res = await fetch(`https://${getResourceName()}/${event}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    })
    return await res.json()
  } catch (error) {
    console.error(`NUI Callback Error [${event}]:`, error)
    return null
  }
}

/**
 * Check if running in FiveM NUI environment
 */
export function isNuiEnvironment() {
  return typeof window.GetParentResourceName === 'function'
}
