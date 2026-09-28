<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useNuiEvent } from './utils/useNuiEvent'
import { fetchNui } from './utils/nui'
import PromptCard from './components/PromptCard.vue'

const POSITIONS = [
  'top-left', 'top-center', 'top-right',
  'left-center', 'right-center',
  'bottom-left', 'bottom-center', 'bottom-right',
]

const prompts = ref([])
const pressed = reactive({})
const visible = ref(true)

const byPosition = computed(() =>
  Object.fromEntries(POSITIONS.map((position) => [
    position,
    prompts.value.filter((prompt) => prompt.position === position),
  ])),
)

useNuiEvent('setPrompts', (data) => {
  prompts.value = Array.isArray(data) ? data : []
})

useNuiEvent('keyState', ({ id, down }) => {
  if (down) pressed[id] = true
  else delete pressed[id]
})

useNuiEvent('setVisible', ({ visible: isVisible }) => {
  visible.value = isVisible !== false
})

onMounted(() => fetchNui('ready'))
</script>

<template>
  <div class="root" :class="{ 'is-hidden': !visible }">
    <TransitionGroup
      v-for="position in POSITIONS"
      :key="position"
      tag="div"
      name="prompt"
      class="stack"
      :class="position"
    >
      <PromptCard
        v-for="prompt in byPosition[position]"
        :key="prompt.uid"
        :prompt="prompt"
        :pressed="pressed"
      />
    </TransitionGroup>
  </div>
</template>

<style scoped>
.root {
  position: fixed;
  inset: 0;
  pointer-events: none;
  transition: opacity 0.15s ease-out;
}

.root.is-hidden {
  opacity: 0;
}

.stack {
  position: absolute;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.top-left     { top: 3vh;    left: 1.5vw;  align-items: flex-start; }
.top-center   { top: 3vh;    left: 50%;    align-items: center; transform: translateX(-50%); }
.top-right    { top: 3vh;    right: 1.5vw; align-items: flex-end; }
.left-center  { top: 50%;    left: 1.5vw;  align-items: flex-start; transform: translateY(-50%); }
.right-center { top: 50%;    right: 1.5vw; align-items: flex-end; transform: translateY(-50%); }
/* Clear of the default minimap */
.bottom-left  { bottom: 26vh; left: 1.5vw; align-items: flex-start; }
.bottom-center { bottom: 8vh; left: 50%;   align-items: center; transform: translateX(-50%); }
.bottom-right { bottom: 4vh;  right: 1.5vw; align-items: flex-end; }

.prompt-enter-active,
.prompt-leave-active {
  transition: opacity 0.14s ease-out, transform 0.14s ease-out;
}

.prompt-enter-from,
.prompt-leave-to {
  opacity: 0;
  transform: translateY(6px) scale(0.98);
}

.prompt-move {
  transition: transform 0.16s ease-out;
}
</style>
