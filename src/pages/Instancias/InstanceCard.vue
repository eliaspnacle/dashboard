<template>
  <div class="instance-card">
    <div class="card-header">
      <h3 class="instance-name">{{ instance.name }}</h3>
      <button class="delete-btn-top" @click="requestDelete" aria-label="Excluir">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      </button>
    </div>

    <div class="token-display">
      <span class="token-value">{{ displayedToken }}</span>
      <div class="token-actions">
        <button @click="copyToken" class="token-action-btn">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
        </button>
        <button @click="toggleTokenVisibility" class="token-action-btn">
          <svg v-if="!isTokenVisible" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
          <svg v-else xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
        </button>
      </div>
    </div>

    <p class="instance-number">{{ instance.number }}</p>

    <div class="card-footer-flex">
      <span :class="['status-badge', `status-${instance.connectionStatus}`]">{{ statusText }}</span>
      <div class="footer-actions">
        <button v-if="instance.connectionStatus === 'close' || instance.connectionStatus === 'disconnected' || instance.connectionStatus === 'connecting'" @click="requestConnect" class="connect-btn">Gerar QR Code</button>
        <button v-if="instance.connectionStatus === 'open' || instance.connectionStatus === 'connected'" @click="requestDisconnect" class="disconnect-btn">Desconectar</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';

const props = defineProps({
  instance: {
    type: Object,
    required: true,
  }
});

const emit = defineEmits(['delete', 'connect', 'disconnect']);

const isTokenVisible = ref(false);

console.log('InstanceCard props.instance:', props.instance);

const displayedToken = computed(() => {
  if (isTokenVisible.value || !props.instance.token) {
    return props.instance.token;
  }
  return '•'.repeat(props.instance.token.length);
});

const statusText = computed(() => {
  if (props.instance.connectionStatus === 'open' || props.instance.connectionStatus === 'connected') return 'Conectado';
  if (props.instance.connectionStatus === 'connecting') return 'Conectando...';
  if (props.instance.connectionStatus === 'close' || props.instance.connectionStatus === 'disconnected') return 'Desconectado';
  if (props.instance.connectionStatus === 'Desconhecido') return 'Desconhecido';
  return props.instance.connectionStatus || 'Desconhecido';
});

function toggleTokenVisibility() {
  isTokenVisible.value = !isTokenVisible.value;
}

function copyToken() {
  navigator.clipboard.writeText(props.instance.token);
}

function requestDelete() {
  emit('delete', props.instance);
}

function requestConnect() {
  emit('connect', props.instance);
}

function requestDisconnect() {
  emit('disconnect', props.instance);
}
</script>

<style scoped>
.instance-card {
  width: 320px;
  height: auto;
  min-height: 200px;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  background-color: #f9fafb;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  display: flex;
  flex-direction: column;
  padding: 16px;
  transition: box-shadow 0.2s;
  justify-content: space-between;
}
.instance-card:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.instance-name {
  font-size: 1.25rem;
  font-weight: 600;
  margin: 0;
  color: #1f2937;
}
.token-display {
  background-color: #fff;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  padding: 8px 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 12px;
  font-family: monospace;
}
.token-value {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: #374151;
}
.token-actions {
  display: flex;
  gap: 8px;
}
.token-action-btn {
  background: none;
  border: none;
  cursor: pointer;
  color: #6b7280;
}
.instance-number {
  font-size: 1rem;
  color: #374151;
  margin-top: 12px;
}
.card-footer-flex {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 16px;
  flex-wrap: wrap;
  gap: 12px;
}
.status-badge {
  font-weight: 500;
  font-size: 0.9rem;
  padding: 4px 16px;
  border-radius: 9999px;
  display: inline-block;
}
.status-connected,
.status-open {
  color: #166534;
  background-color: #dcfce7;
}
.status-disconnected,
.status-close {
  color: #991b1b;
  background-color: #fee2e2;
}
.status-connecting {
  color: #92400e;
  background-color: #fef9c3;
}
.footer-actions {
  display: flex;
  gap: 20px;
  margin-left: auto;
  flex-wrap: wrap;
  justify-content: flex-end;
  width: 100%;
}
.connect-btn,
.disconnect-btn {
  min-height: 40px;
  min-width: 130px;
  max-width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 8px 16px;
  font-size: 0.9rem;
  font-weight: 500;
  border-radius: 6px;
  border: none;
  cursor: pointer;
  transition: background-color 0.2s;
  box-sizing: border-box;
}
.connect-btn {
  background-color: #dc831c;
  color: white;
}
.connect-btn:hover {
  background-color: #b96a17;
}
.disconnect-btn {
  background-color: #ef4444;
  color: #fff;
}
.disconnect-btn:hover {
  background-color: #dc2626;
}
.delete-btn-top {
  background-color: #ef4444;
  color: #fff;
  border: none;
  border-radius: 8px;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.4rem;
  font-weight: bold;
  cursor: pointer;
  transition: background 0.2s;
  margin-left: 12px;
  box-sizing: border-box;
  padding: 0;
}
.delete-btn-top:hover {
  background-color: #dc2626;
}
.delete-btn-top svg {
  color: #fff;
  stroke: #fff;
}
</style> 