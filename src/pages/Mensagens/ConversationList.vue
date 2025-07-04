<template>
  <div class="list-container">
    <div class="conversations-header">
      <h3>Conversas</h3>
      <button @click="showNewConversationModal = true" class="new-conversation-btn">
        <svg viewBox="0 0 24 24" width="20" height="20">
          <path fill="currentColor" d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
        </svg>
      </button>
    </div>

    <div v-if="loading" class="loading-container">
      <div class="loading-spinner"></div>
      <p>Carregando conversas...</p>
    </div>

    <ul v-else class="conversations-list">
      <li 
        v-for="convo in filteredConversations" 
        :key="convo.id" 
        @click="selectConversation(convo)" 
        class="conversation-item"
        :class="{ 'selected': convo.id === selectedConversationId }"
      >
        <div class="avatar-container">
          <div class="avatar">
            <img v-if="convo.imagem_perfil" :src="convo.imagem_perfil" alt="avatar" style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover;" />
            <svg v-else width="40" height="40" viewBox="0 0 40 40" fill="none">
              <circle cx="20" cy="20" r="20" fill="#bdbdbd"/>
              <circle cx="20" cy="15" r="8" fill="#ededed"/>
              <path d="M32 34c0-6.627-5.373-12-12-12s-12 5.373-12 12" fill="#ededed"/>
            </svg>
          </div>
        </div>
        <div class="conversation-details">
          <div class="details-top">
            <span class="name">{{ convo.nome_contato }}</span>
            <span class="timestamp">{{ formatTimestamp(convo.data_hora) }}</span>
          </div>
          <div class="details-bottom">
            <p class="last-message">{{ convo.numero_contato }}</p>
          </div>
        </div>
      </li>
    </ul>

    <div v-if="!loading && filteredConversations.length === 0" class="empty-state">
      <svg class="empty-icon" viewBox="0 0 24 24">
        <path fill="currentColor" d="M20 2H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h4l4 4 4-4h4c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-2 12H6v-2h12v2zm0-3H6V9h12v2zm0-3H6V6h12v2z"/>
      </svg>
      <p>{{ searchQuery ? 'Nenhuma conversa encontrada' : 'Nenhuma conversa ainda' }}</p>
      <button v-if="!searchQuery" @click="showNewConversationModal = true" class="start-conversation-btn">
        Iniciar conversa
      </button>
    </div>

    <!-- Modal para nova conversa -->
    <div v-if="showNewConversationModal" class="modal-overlay" @click="showNewConversationModal = false">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>Nova Conversa</h3>
          <button @click="showNewConversationModal = false" class="close-btn">×</button>
        </div>
        <div class="modal-body">
          <input 
            v-model="newConversationQuery" 
            type="text" 
            placeholder="Buscar usuários..."
            class="user-search-input"
          >
          <div class="user-list">
            <div 
              v-for="user in filteredUsers" 
              :key="user.id"
              @click="createConversation(user.id)"
              class="user-item"
            >
              <img :src="user.avatar_url || 'https://i.pravatar.cc/150?img=1'" alt="avatar" class="user-avatar">
              <span class="user-name">{{ user.name }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import { conversationService, searchService } from '@/services/messages.js';

const props = defineProps({
  selectedConversationId: {
    type: Number,
    default: null
  },
  instanceId: {
    type: [String, Number],
    default: null
  },
  numeroInstancia: {
    type: String,
    default: null
  }
});

const emit = defineEmits(['conversation-selected']);

const conversations = ref([]);
const filteredConversations = ref([]);
const loading = ref(false);
const showNewConversationModal = ref(false);
const newConversationQuery = ref('');
const users = ref([]);

const selectConversation = (conversation) => {
  emit('conversation-selected', conversation);
};

const loadConversations = async () => {
  loading.value = true;
  try {
    let data = await conversationService.getConversations(props.numeroInstancia);
    conversations.value = data;
    filteredConversations.value = data;
  } catch (error) {
    console.error('Erro ao carregar conversas:', error);
  } finally {
    loading.value = false;
  }
};

const getConversationName = (conversation) => conversation.nome_contato || 'Conversa';
const getConversationAvatar = (conversation) => 'https://i.pravatar.cc/150?u=' + (conversation.nome_contato || 'default');
const getLastMessage = (conversation) => conversation.mensagem || 'Nenhuma mensagem';
const formatTimestamp = (timestamp) => {
  if (!timestamp) return '';
  const date = new Date(timestamp);
  const now = new Date();
  const diffInHours = (now - date) / (1000 * 60 * 60);
  if (diffInHours < 24) {
    return date.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
  } else if (diffInHours < 48) {
    return 'ontem';
  } else {
    return date.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' });
  }
};

const getCurrentUserId = () => {
  // Implementar lógica para obter ID do usuário atual
  return null;
};

const createConversation = async (userId) => {
  try {
    const conversation = await conversationService.createConversation([userId]);
    showNewConversationModal.value = false;
    await loadConversations();
    emit('conversation-selected', conversation);
  } catch (error) {
    console.error('Erro ao criar conversa:', error);
  }
};

const filteredUsers = computed(() => {
  if (!newConversationQuery.value) return users.value;
  return users.value.filter(user => 
    user.name.toLowerCase().includes(newConversationQuery.value.toLowerCase())
  );
});

onMounted(() => {
  loadConversations();
});

watch(() => props.instanceId, loadConversations);
</script>

<style scoped>
.list-container { 
  width: 100%; 
  height: 100%; 
  display: flex; 
  flex-direction: column; 
  background-color: #fff; 
}

.conversations-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-bottom: 1px solid #e9edef;
}

.conversations-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #111827;
}

.new-conversation-btn {
  background: #22c55e;
  color: white;
  border: none;
  border-radius: 50%;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: background-color 0.2s;
}

.new-conversation-btn:hover {
  background: #16a34a;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
  color: #667781;
}

.loading-spinner {
  width: 24px;
  height: 24px;
  border: 2px solid #e5e7eb;
  border-top: 2px solid #22c55e;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 12px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.conversations-list { 
  list-style: none; 
  padding: 0; 
  margin: 0; 
  overflow-y: auto; 
  flex: 1; 
}

.conversation-item {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  cursor: pointer;
  border-bottom: 1px solid #f0f2f5;
  transition: background-color 0.2s;
  gap: 12px;
}

.conversation-item:hover {
  background-color: #f5f5f5;
}

.conversation-item.selected {
  background-color: #e8e8e8;
}

.avatar-container {
  position: relative;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
}

.conversation-details { 
  flex: 1; 
  overflow: hidden; 
}

.details-top { 
  display: flex; 
  justify-content: space-between; 
  align-items: center;
  margin-bottom: 4px;
}

.name {
  font-weight: 600;
  color: #111827;
  font-size: 14px;
}

.timestamp { 
  font-size: 12px; 
  color: #667781; 
}

.details-bottom { 
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.last-message { 
  font-size: 13px; 
  color: #667781; 
  white-space: nowrap; 
  overflow: hidden; 
  text-overflow: ellipsis; 
  margin: 0;
  flex: 1;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
  color: #667781;
  text-align: center;
}

.empty-icon {
  width: 48px;
  height: 48px;
  margin-bottom: 16px;
  color: #cbd5e1;
}

.start-conversation-btn {
  background: #22c55e;
  color: white;
  border: none;
  border-radius: 8px;
  padding: 8px 16px;
  font-size: 14px;
  cursor: pointer;
  margin-top: 12px;
  transition: background-color 0.2s;
}

.start-conversation-btn:hover {
  background: #16a34a;
}

/* Modal styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 12px;
  width: 90%;
  max-width: 400px;
  max-height: 80vh;
  overflow: hidden;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #e5e7eb;
}

.modal-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #667781;
}

.modal-body {
  padding: 20px;
}

.user-search-input {
  width: 100%;
  padding: 12px;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  font-size: 14px;
  margin-bottom: 16px;
}

.user-list {
  max-height: 300px;
  overflow-y: auto;
}

.user-item {
  display: flex;
  align-items: center;
  padding: 12px;
  cursor: pointer;
  border-radius: 8px;
  transition: background-color 0.2s;
  gap: 12px;
}

.user-item:hover {
  background-color: #f5f5f5;
}

.user-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
}

.user-name {
  font-size: 14px;
  color: #111827;
  font-weight: 500;
}
</style> 