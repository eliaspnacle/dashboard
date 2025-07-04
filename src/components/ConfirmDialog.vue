<template>
  <div class="confirm-overlay">
    <div class="confirm-modal">
      <h3 class="confirm-title">{{ title }}</h3>
      <p class="confirm-message">{{ message }}</p>
      <div class="confirm-actions">
        <button class="confirm-cancel" @click="$emit('cancel')">Cancelar</button>
        <button class="confirm-ok" @click="$emit('confirm')">Confirmar</button>
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  title: String,
  message: String
})
</script>

<style scoped>
.confirm-overlay {
  position: fixed;
  top: 0; left: 0; width: 100vw; height: 100vh;
  background: rgba(0,0,0,0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
}
.confirm-modal {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 4px 24px rgba(0,0,0,0.13);
  padding: 32px 28px 24px 28px;
  min-width: 320px;
  max-width: 90vw;
  text-align: center;
}
.confirm-title {
  font-size: 1.25rem;
  font-weight: 600;
  margin-bottom: 12px;
  color: #222;
}
.confirm-message {
  font-size: 1.05rem;
  color: #444;
  margin-bottom: 28px;
}
.confirm-actions {
  display: flex;
  justify-content: center;
  gap: 18px;
}
.confirm-cancel {
  background: #f3f4f6;
  color: #222;
  border: none;
  border-radius: 6px;
  padding: 10px 22px;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s;
}
.confirm-cancel:hover {
  background: #e5e7eb;
}
.confirm-ok {
  background: #ef4444;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 10px 22px;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s;
}
.confirm-ok:hover {
  background: #dc2626;
}
</style> 