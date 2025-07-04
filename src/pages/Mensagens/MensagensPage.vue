<template>
  <div class="layout-container">
    <SidebarMenu />

    <!-- Main Content -->
    <div class="main-content">
      <div class="header-bar">
        <h2 class="welcome-text">Mensagens</h2>
        <div class="header-actions">
          <button @click="refreshConversations" class="refresh-btn" title="Atualizar">
            <svg viewBox="0 0 24 24" width="20" height="20">
              <path fill="currentColor" d="M17.65,6.35C16.2,4.9 14.21,4 12,4A8,8 0 0,0 4,12A8,8 0 0,0 12,20C15.73,20 18.84,17.45 19.73,14H17.65C16.83,16.33 14.61,18 12,18A6,6 0 0,1 6,12A6,6 0 0,1 12,6C13.66,6 15.14,6.69 16.22,7.78L13,11H20V4L17.65,6.35Z"/>
            </svg>
          </button>
        </div>
      </div>
      <!-- Área de seleção de instâncias -->
      <div class="instances-bar-scroll">
        <div class="instances-bar" v-if="instances.length">
          <div v-for="instance in instances.filter(i => ['conectado', 'connected', 'open'].includes((i.connectionStatus || '').toLowerCase()))" :key="instance.id" :class="['instance-card', {selected: selectedInstance && selectedInstance.id === instance.id}]" @click="selectInstance(instance)">
            <div class="instance-avatar">
              <svg v-if="!instance.avatar" width="32" height="32" viewBox="0 0 24 24"><circle cx="12" cy="12" r="12" fill="#e5e7eb"/><text x="50%" y="55%" text-anchor="middle" fill="#22c55e" font-size="16" font-family="Arial" dy=".3em">{{ instance.name.charAt(0).toUpperCase() }}</text></svg>
              <img v-else :src="instance.avatar" alt="avatar" />
            </div>
            <div class="instance-info">
              <div class="instance-name">{{ instance.name }}</div>
              <div class="instance-status">
                <span :class="['status-dot', instance.connectionStatus]" />
                <span class="status-text">{{ statusLabel(instance.connectionStatus) }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="card messages-container">
        <div class="conversations-panel">
          <ConversationList 
            @conversation-selected="handleConversationSelected" 
            :selected-conversation-id="selectedConversation?.id"
            @refresh="refreshConversations"
            :instance-id="selectedInstance?.id"
            :numero-instancia="selectedInstance?.number"
          />
        </div>
        <div class="chat-view-panel">
          <ChatWindow 
            v-if="selectedConversation" 
            :key="selectedConversation.id" 
            :conversation="selectedConversation"
            :instance-id="selectedInstance?.id"
            :instance-name="selectedInstance?.name"
            :numero-instancia="selectedInstance?.number"
            @message-sent="handleMessageSent"
          />
          <ChatPlaceholder v-else />
        </div>
      </div>
    </div>

    <!-- Notificação de nova mensagem -->
    <div v-if="showNotification" class="notification" @click="handleNotificationClick">
      <div class="notification-content">
        <img :src="notificationData.avatar" alt="Avatar" class="notification-avatar">
        <div class="notification-text">
          <div class="notification-name">{{ notificationData.name }}</div>
          <div class="notification-message">{{ notificationData.message }}</div>
        </div>
      </div>
      <button @click.stop="dismissNotification" class="notification-close">×</button>
    </div>
  </div>
</template>

<script setup>
import { useRoute } from 'vue-router'
import SidebarMenu from '@/components/layout/SidebarMenu.vue'
import ChatPlaceholder from './ChatPlaceholder.vue'
import ConversationList from './ConversationList.vue'
import ChatWindow from './ChatWindow.vue'
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { supabase } from '@/services/supabase.js'

const route = useRoute()
const selectedConversation = ref(null)
const showNotification = ref(false)
const notificationData = ref({})

// Instâncias do usuário
const instances = ref([])
const selectedInstance = ref(null)

// Real-time subscription para novas mensagens
let messageSubscription = null

const handleConversationSelected = (conversation) => {
  selectedConversation.value = conversation
}

const handleMessageSent = () => {
  // Atualizar lista de conversas quando uma mensagem é enviada
  refreshConversations()
}

const refreshConversations = () => {
  // Emitir evento para atualizar a lista de conversas
  // O ConversationList irá escutar este evento
}

const setupRealtimeSubscription = () => {
  // Limpa subscription anterior, se houver
  if (messageSubscription) {
    supabase.removeChannel(messageSubscription)
    messageSubscription = null
  }
  messageSubscription = supabase
    .channel('messages')
    .on('postgres_changes', {
      event: 'INSERT',
      schema: 'public',
      table: 'messages'
    }, (payload) => {
      handleNewMessage(payload.new)
    })
    .subscribe()
}

const handleNewMessage = (message) => {
  // Verificar se a mensagem é para uma conversa que o usuário participa
  if (message.conversation_id === selectedConversation.value?.id) {
    // Atualizar mensagens na conversa atual
    return
  }

  // Mostrar notificação para nova mensagem
  showMessageNotification(message)
}

const showMessageNotification = (message) => {
  // Buscar informações do remetente
  getSenderInfo(message.sender_id).then(sender => {
    notificationData.value = {
      name: sender?.name || 'Usuário',
      message: message.content,
      avatar: sender?.avatar_url || 'https://i.pravatar.cc/150?img=1',
      conversationId: message.conversation_id
    }
    showNotification.value = true

    // Auto-dismiss após 5 segundos
    setTimeout(() => {
      dismissNotification()
    }, 5000)
  })
}

const getSenderInfo = async (senderId) => {
  try {
    // Buscar informações do remetente pelo auth
    const { data, error } = await supabase.auth.getUser(senderId);
    if (error) throw error;
    return data?.user || null;
  } catch (error) {
    console.error('Erro ao buscar informações do remetente:', error);
    return null;
  }
}

const handleNotificationClick = () => {
  // Navegar para a conversa da notificação
  if (notificationData.value.conversationId) {
    // Implementar navegação para a conversa
    console.log('Navegar para conversa:', notificationData.value.conversationId)
  }
  dismissNotification()
}

const dismissNotification = () => {
  showNotification.value = false
  notificationData.value = {}
}

const uuidMap = {
  "11976498623": "0a8fb570-ba28-4abd-85fc-698818105942",
  "11991928861": "b4b0b391-e227-4869-9478-1627728e07e1",
  "11111111111": "560ecb82-381d-48de-8ed7-f1cc43376d53"
};

const fetchInstances = async () => {
  // Obter o id do usuário logado
  const { data, error } = await supabase.auth.getUser();
  if (!data || !data.user) return;
  const userId = data.user.id;
  try {
    const response = await fetch('https://webhook.devchat.com.br/webhook/1e1d3e68-f839-4518-bfb3-bd0437e6a9e6', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ user_id: userId }),
    });
    if (!response.ok) throw new Error('Erro ao buscar instâncias');
    const result = await response.json();
    const dataArray = Array.isArray(result.data) ? result.data : [];
    instances.value = dataArray.map(item => ({
      id: uuidMap[item.numero || item.number] || item.id,
      name: item.nome || item.name,
      number: item.numero || item.number,
      connectionStatus: item.connectionStatus,
      token: item.token,
    }));
    // Seleciona a primeira instância por padrão
    if (!selectedInstance.value && instances.value.length) {
      selectedInstance.value = instances.value[0];
    }
  } catch (err) {
    instances.value = [];
  }
}

const selectInstance = (instance) => {
  selectedInstance.value = {
    ...instance,
    id: uuidMap[instance.number] || instance.id
  };
  selectedConversation.value = null; // Limpa a conversa ao trocar de instância
}

const statusLabel = (status) => {
  if (!status) return 'Sem status';
  if (status === 'open') return 'Conectado';
  if (status === 'close') return 'Desconectado';
  if (status === 'connecting') return 'Conectando';
  return status;
}

watch(selectedInstance, () => {
  selectedConversation.value = null;
});

onMounted(() => {
  setupRealtimeSubscription()
  fetchInstances()
})

onUnmounted(() => {
  if (messageSubscription) {
    supabase.removeChannel(messageSubscription)
    messageSubscription = null
  }
})
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
}

.header-actions {
  display: flex;
  gap: 12px;
}

.refresh-btn {
  background: #22c55e;
  color: #fff;
  border: none;
  border-radius: 8px;
  padding: 10px;
  font-size: 1rem;
  cursor: pointer;
  font-weight: 500;
  transition: background 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.refresh-btn:hover {
  background: #16a34a;
}

.card {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  padding: 0;
  flex: 1;
  display: flex;
  flex-direction: row;
  gap: 0;
  min-height: 0;
  width: 100%;
  margin: 0;
  max-width: none;
  overflow: hidden;
}

.welcome-text {
  font-size: 1.15rem;
  font-weight: 500;
  color: #222;
  margin-bottom: 18px;
  margin-top: -18px;
}

/* Estilos específicos para a página de mensagens */
.messages-container {
  flex-direction: row;
  padding: 0;
  gap: 0;
}

.conversations-panel {
  width: 350px;
  min-width: 300px;
  max-width: 400px;
  border-right: 1px solid #e5e7eb;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.chat-view-panel {
  flex: 1;
  height: 100%;
}

/* Notificação */
.notification {
  position: fixed;
  top: 20px;
  right: 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
  padding: 16px;
  display: flex;
  align-items: center;
  gap: 12px;
  max-width: 350px;
  z-index: 1000;
  cursor: pointer;
  transition: transform 0.2s;
  border-left: 4px solid #22c55e;
}

.notification:hover {
  transform: translateY(-2px);
}

.notification-content {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
}

.notification-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
}

.notification-text {
  flex: 1;
  min-width: 0;
}

.notification-name {
  font-weight: 600;
  font-size: 14px;
  color: #333;
  margin-bottom: 2px;
}

.notification-message {
  font-size: 13px;
  color: #666;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.notification-close {
  background: none;
  border: none;
  font-size: 18px;
  color: #666;
  cursor: pointer;
  padding: 4px;
  border-radius: 50%;
  transition: background-color 0.2s;
}

.notification-close:hover {
  background-color: #f0f0f0;
}

/* Responsividade */
@media (max-width: 768px) {
  .main-content {
    padding: 16px 12px 0 12px;
  }

  .header-bar {
    margin-bottom: 16px;
  }

  .header-bar h2 {
    font-size: 1.3rem;
  }

  .messages-container {
    flex-direction: column;
  }

  .conversations-panel {
    width: 100%;
    max-width: none;
    border-right: none;
    border-bottom: 1px solid #e5e7eb;
    height: 40vh;
  }

  .chat-view-panel {
    height: 60vh;
  }

  .notification {
    left: 20px;
    right: 20px;
    max-width: none;
  }
}

@media (max-width: 480px) {
  .main-content {
    padding: 12px 8px 0 8px;
  }

  .card {
    border-radius: 8px;
  }

  .conversations-panel {
    height: 35vh;
  }

  .chat-view-panel {
    height: 65vh;
  }
}

.instances-bar-scroll {
  overflow-x: auto;
  padding-bottom: 8px;
  margin-bottom: 16px;
}
.instances-bar {
  display: flex;
  gap: 16px;
  min-width: 100%;
}
.instance-card {
  display: flex;
  align-items: center;
  background: #fff;
  border: 2px solid #e5e7eb;
  border-radius: 16px;
  padding: 8px 18px 8px 10px;
  cursor: pointer;
  min-width: 180px;
  box-shadow: 0 2px 8px rgba(34,197,94,0.04);
  transition: border 0.2s, box-shadow 0.2s, background 0.2s;
  position: relative;
}
.instance-card.selected {
  border: 2px solid #22c55e;
  background: #e8fbe9;
  box-shadow: 0 4px 16px rgba(34,197,94,0.10);
}
.instance-card:hover {
  border: 2px solid #16a34a;
  background: #f0fdf4;
}
.instance-avatar {
  width: 38px;
  height: 38px;
  border-radius: 50%;
  background: #e5e7eb;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  overflow: hidden;
}
.instance-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 50%;
}
.instance-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.instance-name {
  font-weight: 600;
  font-size: 15px;
  color: #222;
}
.instance-status {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: #666;
}
.status-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  display: inline-block;
}
.status-dot.connected {
  background: #22c55e;
}
.status-dot.connecting {
  background: #facc15;
}
.status-dot.disconnected {
  background: #d1d5db;
}
.status-text {
  font-size: 12px;
  color: #666;
}
</style> 