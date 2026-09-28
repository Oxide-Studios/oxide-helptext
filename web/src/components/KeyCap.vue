<script setup>
defineProps({
  label: { type: String, required: true },
  pressed: { type: Boolean, default: false },
})
</script>

<template>
  <span class="keycap" :class="{ pressed }">{{ label }}</span>
</template>

<style scoped>
.keycap {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 24px;
  height: 24px;
  padding: 0 7px;
  box-sizing: border-box;
  font-size: 11.5px;
  font-weight: 700;
  letter-spacing: 0.02em;
  color: #F4F5F7;
  background: rgba(155, 44, 44, 0.22);
  border: 1px solid rgba(155, 44, 44, 0.75);
  border-radius: 5px;
  box-shadow: inset 0 -2px 0 rgba(0, 0, 0, 0.35);
  white-space: nowrap;
  transition: background 0.08s ease-out, transform 0.08s ease-out, box-shadow 0.08s ease-out;
}

.keycap.pressed {
  background: #9B2C2C;
  transform: translateY(1px);
  box-shadow: 0 0 12px rgba(155, 44, 44, 0.65);
}
</style>
