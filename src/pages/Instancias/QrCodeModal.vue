<template>
  <div class="modal-overlay">
    <div class="modal-content">
      <div class="modal-header" style="justify-content: flex-end;">
        <button class="close-btn" @click="$emit('close')" aria-label="Fechar">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
        </button>
      </div>
      <div class="modal-body">
        <div class="qr-instruction">
          Por favor, escaneie o QR Code abaixo com o WhatsApp<br />para conectar sua instância.
        </div>
        <div v-if="qrCodeImage">
          <img :src="qrCodeImage" alt="QR Code" class="qrcode-img" />
          <div v-if="code || pairingCode" style="margin-top: 16px; word-break: break-all;">
            <div v-if="code"><b>Code:</b> {{ code }}</div>
            <div v-if="pairingCode"><b>Pairing Code:</b> {{ pairingCode }}</div>
          </div>
        </div>
        <div v-else>
          <span>Carregando QR Code...</span>
        </div>
      </div>
      <div style="text-align:center; margin-top: 18px; color: #ef4444; font-weight: 500;">
        Esta janela será fechada automaticamente em {{ secondsLeft }} segundos.
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
const props = defineProps({
  instanceName: String,
  qrCodeImage: String,
  code: String,
  pairingCode: String
})

const secondsLeft = ref(30)
let timer = null
let interval = null

onMounted(() => {
  timer = setTimeout(() => {
    window.dispatchEvent(new CustomEvent('close-qr-modal'))
  }, 30000)
  interval = setInterval(() => {
    if (secondsLeft.value > 0) secondsLeft.value--
  }, 1000)
})

onUnmounted(() => {
  if (timer) clearTimeout(timer)
  if (interval) clearInterval(interval)
})
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.modal-content {
  background: #fff;
  border-radius: 12px;
  padding: 32px 24px;
  min-width: 320px;
  max-width: 90vw;
  box-shadow: 0 4px 24px rgba(0,0,0,0.18);
  position: relative;
}
.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 18px;
}
.close-btn {
  background: #ef4444;
  border: none;
  color: #fff;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  width: 36px;
  height: 36px;
  border-radius: 8px;
  transition: background 0.2s;
}
.close-btn:hover {
  background: #dc2626;
}
.close-btn svg {
  color: #fff;
  stroke: #fff;
}
.qrcode-img {
  display: block;
  margin: 0 auto;
  max-width: 260px;
  max-height: 260px;
  border: 2px solid #dc831c;
  border-radius: 12px;
  background: #fff;
}
.qr-instruction {
  font-size: 1.08rem;
  color: #222;
  margin-bottom: 18px;
  text-align: center;
  font-weight: 500;
}
</style> 