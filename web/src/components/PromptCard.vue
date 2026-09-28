<script setup>
import { computed } from 'vue'
import KeyCap from './KeyCap.vue'

const props = defineProps({
  prompt: { type: Object, required: true },
  pressed: { type: Object, required: true },
})

// Lua sends an empty table as {} rather than [], so guard every list.
const lines = computed(() => (Array.isArray(props.prompt.lines) ? props.prompt.lines : []))

const segmentsOf = (line) => (Array.isArray(line) ? line : [])
</script>

<template>
  <div class="card">
    <div v-if="prompt.title || prompt.icon" class="header">
      <i v-if="prompt.icon" :class="prompt.icon" class="icon"></i>
      <span v-if="prompt.title" class="title">{{ prompt.title }}</span>
    </div>

    <div v-for="(line, i) in lines" :key="i" class="line">
      <template v-for="(segment, j) in segmentsOf(line)" :key="j">
        <KeyCap
          v-if="segment.t === 'key'"
          :label="segment.v"
          :pressed="!!(segment.k && pressed[segment.k])"
        />
        <span v-else-if="segment.t === 'sep'" class="sep"></span>
        <span
          v-else
          class="text"
          :class="[segment.b && 'bold', segment.c && `color-${segment.c}`]"
        >{{ segment.v }}</span>
      </template>
    </div>
  </div>
</template>

<style scoped>
.card {
  position: relative;
  max-width: 360px;
  padding: 10px 14px;
  display: flex;
  flex-direction: column;
  gap: 7px;
  background: linear-gradient(135deg, rgba(15, 17, 19, 0.92) 0%, rgba(15, 17, 19, 0.84) 100%);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 8px;
  box-shadow: 0 6px 18px rgba(0, 0, 0, 0.35);
}

.card::before {
  content: '';
  position: absolute;
  inset: -1px;
  border-radius: 9px;
  background: linear-gradient(135deg, rgba(155, 44, 44, 0.35), transparent 55%);
  z-index: -1;
}

.header {
  display: flex;
  align-items: center;
  gap: 7px;
  padding-bottom: 6px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
}

.icon {
  font-size: 11px;
  color: #c24141;
}

.title {
  font-size: 10.5px;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: rgba(244, 245, 247, 0.55);
}

.line {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 6px 7px;
  min-height: 24px;
}

.text {
  font-size: 13px;
  font-weight: 500;
  line-height: 1.35;
  color: rgba(244, 245, 247, 0.92);
}

.text.bold {
  font-weight: 700;
  color: #ffffff;
}

.sep {
  width: 1px;
  height: 14px;
  margin: 0 3px;
  background: rgba(255, 255, 255, 0.16);
}

.color-red { color: #ef4444; }
.color-green { color: #22c55e; }
.color-blue { color: #60a5fa; }
.color-yellow { color: #facc15; }
.color-orange { color: #C47A2C; }
.color-purple { color: #a78bfa; }
.color-grey { color: #9ca3af; }
</style>
