<template>
  <div class="layout-container">
    <SidebarMenu />

    <!-- Main Content -->
    <div class="main-content">
      <div class="header-bar">
        <h2>Instâncias</h2>
      </div>
      <div class="card">
        <div class="add-instance-box" @click="openNewInstanceModal">
          <span class="plus-icon">+</span>
          <span class="add-text">Adicionar Nova Instância</span>
        </div>
        <div v-if="loadingInstances" class="loading-box">
          <div class="spinner"></div>
          <span>Carregando instâncias...</span>
        </div>
        <div v-else class="instances-grid">
          <InstanceCard
            v-for="instance in instances"
            :key="instance.id"
            :instance="instance"
            @delete="requestDeleteInstance"
            @connect="handleConnectRequest"
            @disconnect="handleDisconnectRequest"
          />
        </div>
      </div>
    </div>
  </div>
  <NewInstanceModal 
    v-if="showNewInstanceModal" 
    :user-id="userId"
    :initial-token="newInstanceToken" 
    @close="showNewInstanceModal = false" 
    @save="handleInstanceSaved" 
  />
  <QrCodeModal
    v-if="isQrModalOpen"
    :instance-name="selectedInstance?.name"
    :qr-code-image="qrCodeImage"
    :code="qrCodeCode"
    :pairing-code="qrCodePairingCode"
    @close="handleCloseQrModal"
  />
  <ConfirmDialog
    v-if="showConfirmDialog"
    title="Excluir Instância"
    message="Tem certeza de que deseja excluir esta instância?"
    @confirm="confirmDeleteInstance"
    @cancel="cancelDeleteInstance"
  />
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from '@/services/supabase'
import SidebarMenu from '@/components/layout/SidebarMenu.vue'
import NewInstanceModal from './NewInstanceModal.vue'
import InstanceCard from './InstanceCard.vue'
import QrCodeModal from './QrCodeModal.vue'
import ConfirmDialog from '@/components/ConfirmDialog.vue'

const route = useRoute()
const showNewInstanceModal = ref(false)
const isQrModalOpen = ref(false)
const newInstanceToken = ref('')
const instances = ref([])
const selectedInstance = ref(null)
const showConfirmDialog = ref(false)
const instanceToDelete = ref(null)
const loadingInstances = ref(false)
const qrCodeImage = ref(null)
const qrCodeCode = ref(null)
const qrCodePairingCode = ref(null)
const userId = ref(null)

async function fetchInstances() {
  loadingInstances.value = true;
  try {
    // Buscar instâncias via webhook (método antigo)
    const response = await fetch('https://webhook.devchat.com.br/webhook/1e1d3e68-f839-4518-bfb3-bd0437e6a9e6', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ user_id: userId.value, nome: '', numero: '' }),
    });
    if (!response.ok) throw new Error('Erro ao buscar instâncias');
    const result = await response.json();
    const dataArray = Array.isArray(result.data) ? result.data : [];
    instances.value = dataArray;
  } catch (err) {
    instances.value = [];
  } finally {
    loadingInstances.value = false;
  }
}

onMounted(async () => {
  // Obter o id do usuário logado
  const { data, error } = await supabase.auth.getUser();
  if (data && data.user) {
    userId.value = data.user.id;
  }
  fetchInstances();
  // Listener para fechar o modal de QR Code automaticamente
  window.addEventListener('close-qr-modal', handleCloseQrModal)
});

onUnmounted(() => {
  window.removeEventListener('close-qr-modal', handleCloseQrModal)
});

function openNewInstanceModal() {
  newInstanceToken.value = crypto.randomUUID().toUpperCase()
  showNewInstanceModal.value = true
}

async function handleInstanceSaved(instanceData) {
  showNewInstanceModal.value = false;
  setTimeout(() => {
    fetchInstances();
  }, 1500);
}

function requestDeleteInstance(instance) {
  instanceToDelete.value = instance
  showConfirmDialog.value = true
}

async function confirmDeleteInstance() {
  if (!instanceToDelete.value) return
  try {
    const response = await fetch('https://webhook.devchat.com.br/webhook/cb48c15a-9f04-4bb0-bbf6-b1437857ab57', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ instanceName: instanceToDelete.value.name, user_id: userId.value })
    });
    if (!response.ok) throw new Error('Erro ao excluir instância');
    // Atualizar lista local (remover do array)
    const index = instances.value.findIndex(inst => inst.id === instanceToDelete.value.id);
    if (index !== -1) {
      instances.value.splice(index, 1);
    }
  } catch (err) {
    alert('Erro ao excluir instância!');
  } finally {
    showConfirmDialog.value = false;
    instanceToDelete.value = null;
  }
}

function cancelDeleteInstance() {
  showConfirmDialog.value = false;
  instanceToDelete.value = null;
}

function handleConnectRequest(instance) {
  selectedInstance.value = instance
  gerarQrCode(instance)
  const idx = instances.value.findIndex(inst => inst.id === instance.id)
  if (idx !== -1) {
    instances.value[idx].connectionStatus = 'connecting'
  }
}

async function handleDisconnectRequest(instance) {
  // Chama o webhook de desconexão
  try {
    await fetch('https://webhook.devchat.com.br/webhook/cb48c15a-9f24-4bb0-bbf6-b1437857ab57', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ instanceName: instance.name })
    });
  } catch (err) {
    alert('Erro ao desconectar instância!');
  }
  // Atualiza status local para 'disconnected'
  const idx = instances.value.findIndex(inst => inst.id === instance.id)
  if (idx !== -1) {
    instances.value[idx].connectionStatus = 'disconnected'
  }
}

function normalizarQrCodeResponse(response) {
  return {
    pairingCode: response.pairingCode ?? null,
    code: response.code ?? null,
    base64: response.base64 ?? null,
    count: response.count ?? null
  };
}

async function gerarQrCode(instance) {
  try {
    const response = await fetch('https://webhook.devchat.com.br/webhook/cb48c15a-9f04-4bb0-bbf4-b1437857ab57', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ instanceName: instance.name })
    })
    if (!response.ok) throw new Error('Erro ao gerar QR Code')
    const result = await response.json();
    let base64 = null;
    let code = null;
    let pairingCode = null;

    if (typeof result.message === 'string' && result.message.startsWith('data:image')) {
      // Caso 1: message já é a imagem base64
      base64 = result.message;
    } else {
      // Caso 2: message é um JSON string
      try {
        const qrData = JSON.parse(result.message);
        base64 = qrData.base64;
        code = qrData.code || null;
        pairingCode = qrData.pairingCode || null;
        if (base64 && !base64.startsWith('data:image')) {
          base64 = `data:image/png;base64,${base64}`;
        }
      } catch (e) {
        alert('Erro ao processar QR Code!');
        return;
      }
    }

    qrCodeImage.value = base64;
    qrCodeCode.value = code;
    qrCodePairingCode.value = pairingCode;
    isQrModalOpen.value = true;
  } catch (err) {
    alert('Erro ao gerar QR Code!')
  }
}

function handleCloseQrModal() {
  isQrModalOpen.value = false;
  fetchInstances();
}
</script>

<style scoped>
.layout-container {
  display: flex;
  height: 100vh;
  width: 100vw;
  min-height: 100vh;
  min-width: 100vw;
  background: #f6f8fa;
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  justify-content: flex-start;
  align-items: stretch;
}
.sidebar {
  width: 220px;
  min-width: 220px;
  background: #fff;
  border-right: 1px solid #e5e7eb;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  padding: 24px 0 12px 0;
  height: 100vh;
  box-sizing: border-box;
  border-radius: 0 18px 18px 0;
  box-shadow: 2px 0 16px 0 rgba(0,0,0,0.08), 0 0 0 0 rgba(0,0,0,0);
  margin: 0;
  position: relative;
}
.sidebar-logo {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-bottom: 32px;
}
.devchat-logo {
  width: 48px;
  height: 48px;
  display: block;
}
.sidebar-menu {
  flex: 0 0 auto;
}
.sidebar-menu ul {
  list-style: none;
  padding: 0;
  margin: 0;
}
.sidebar-menu li {
  padding: 12px 24px;
  cursor: pointer;
  color: #222;
  border-left: 4px solid transparent;
  transition: background 0.2s, border 0.2s;
}
.sidebar-menu li.active, .sidebar-menu li:hover {
  background: #f0f4f8;
  font-weight: 500;
}
.sidebar-menu li.active {
  border-left: 4px solid #22c55e;
}
.sidebar-user {
  padding: 12px 24px;
  font-size: 0.95rem;
  color: #888;
  border-top: 1px solid #e5e7eb;
  margin-top: auto;
}
.logout-btn {
  width: 100%;
  background: #f3f4f6;
  color: #e11d48;
  border: none;
  border-radius: 6px;
  padding: 10px 0;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}
.logout-btn:hover {
  background: #fee2e2;
}
.logout-icon {
  display: flex;
  align-items: center;
}
.main-content {
  flex: 1;
  min-width: 0;
  min-height: 100vh;
  padding: 32px 24px 0 24px;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}
.header-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
  margin-top: 0;
  width: 100%;
}
.header-bar h2 {
  font-size: 1.6rem;
  font-weight: 600;
  margin: 0;
  color: #222;
}
.new-key-btn {
  background: #22c55e;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 10px 20px;
  font-size: 1rem;
  cursor: pointer;
  font-weight: 500;
  transition: background 0.2s;
}
.new-key-btn:hover {
  background: #16a34a;
}
.card {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  padding: 32px 28px;
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 24px;
  min-height: 0;
  width: 100%;
  margin: 0;
  max-width: none;
}
.card h3 {
  margin-top: 0;
  font-size: 1.2rem;
  font-weight: 600;
}
.subtitle {
  color: #666;
  font-size: 0.98rem;
  margin-bottom: 18px;
}
.api-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 18px;
}
.api-table th, .api-table td {
  padding: 12px 10px;
  text-align: left;
}
.api-table th {
  color: #888;
  font-weight: 500;
  border-bottom: 1px solid #e5e7eb;
}
.api-table td {
  color: #222;
  border-bottom: 1px solid #f0f0f0;
}
.delete-icon {
  cursor: pointer;
  color: #e11d48;
  font-size: 1.2rem;
}
body, html, #app {
  height: 100%;
  width: 100%;
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}
.menu-icon {
  display: inline-flex;
  align-items: center;
  margin-right: 10px;
  color: inherit;
}
.welcome-text {
  font-size: 1.15rem;
  font-weight: 500;
  color: #222;
  margin-bottom: 18px;
  margin-top: -18px;
}
.menu-link {
  display: flex;
  align-items: center;
  color: inherit;
  text-decoration: none;
  width: 100%;
  height: 100%;
}
.menu-link:visited {
  color: inherit;
}

.add-instance-box {
  display: flex;
  flex-direction: row;
  justify-content: center;
  align-items: center;
  width: 250px;
  height: 50px;
  border: 2px dashed #d1d5db;
  border-radius: 12px;
  cursor: pointer;
  color: #6b7280;
  transition: all 0.2s ease-in-out;
  gap: 12px;
}

.add-instance-box:hover {
  background-color: #f9fafb;
  border-color: #9ca3af;
  color: #1f2937;
}

.plus-icon {
  font-size: 1.8rem;
  font-weight: 300;
  line-height: 1;
  margin-bottom: 0;
}

.add-text {
  font-size: 1rem;
  font-weight: 500;
}

.instances-grid {
  display: grid;
  grid-template-columns: repeat(2, 320px);
  gap: 24px;
  justify-content: start;
}

.loading-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 32px 0;
  gap: 12px;
}
.spinner {
  width: 32px;
  height: 32px;
  border: 4px solid #e5e7eb;
  border-top: 4px solid #41b883;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}
@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style> 