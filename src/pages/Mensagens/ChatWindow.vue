<template>
  <div class="chat-window">
    <header class="chat-header">
      <div class="contact-info">
        <div class="avatar">
          <img v-if="props.conversation?.imagem_perfil" :src="props.conversation.imagem_perfil" alt="avatar" style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover;" />
          <svg v-else width="40" height="40" viewBox="0 0 40 40" fill="none">
            <circle cx="20" cy="20" r="20" fill="#bdbdbd"/>
            <circle cx="20" cy="15" r="8" fill="#ededed"/>
            <path d="M32 34c0-6.627-5.373-12-12-12s-12 5.373-12 12" fill="#ededed"/>
          </svg>
        </div>
        <div class="details">
          <div class="contact-name">{{ props.conversation?.nome_contato || 'Contato' }}</div>
          <div class="contact-status">
            <span class="status-dot"></span>
            online
          </div>
        </div>
      </div>
      <div class="header-icons">
        <button class="icon-btn" @click="toggleSearch" title="Buscar">
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
          </svg>
        </button>
        <button class="icon-btn" @click="showMenu = !showMenu" title="Mais opções">
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M12 8c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm0 2c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm0 6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z"/>
          </svg>
        </button>
      </div>
      
      <!-- Menu dropdown -->
      <div v-if="showMenu" class="menu-dropdown">
        <button @click="clearChat" class="menu-item">
          <svg viewBox="0 0 24 24" width="16" height="16">
            <path fill="currentColor" d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/>
          </svg>
          Limpar conversa
        </button>
        <button @click="blockContact" class="menu-item">
          <svg viewBox="0 0 24 24" width="16" height="16">
            <path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
          </svg>
          Bloquear contato
        </button>
      </div>
    </header>

    <!-- Barra de busca -->
    <div v-if="showSearch" class="search-bar">
      <svg class="search-icon" viewBox="0 0 24 24">
        <path fill="currentColor" d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
      </svg>
      <input 
        v-model="searchQuery" 
        @input="searchMessages"
        type="text" 
        placeholder="Buscar mensagens..."
        class="search-input"
      >
      <button @click="toggleSearch" class="close-search-btn">×</button>
    </div>

    <main class="chat-messages" ref="messagesContainer">
      <div v-if="loading" class="loading-messages">
        <div class="loading-spinner"></div>
        <p>Carregando mensagens...</p>
      </div>

      <div v-else-if="searchQuery && searchResults.length > 0" class="search-results">
        <div class="search-results-header">
          <h4>Resultados da busca</h4>
          <button @click="clearSearch" class="clear-search-btn">Limpar</button>
        </div>
        <div 
          v-for="message in searchResults" 
          :key="message.id" 
          class="search-result-item"
          @click="scrollToMessage(message.id)"
        >
          <div class="search-result-content">
            <span class="search-result-text">{{ message.content }}</span>
            <span class="search-result-time">{{ formatMessageTime(message.created_at) }}</span>
          </div>
        </div>
      </div>

      <div v-else class="messages-list">
        <div v-for="message in messages" :key="message.id" class="message-wrapper" :class="isOwnMessage(message) ? 'sent' : 'received'">
          <div class="message-bubble">
            <div v-if="!isOwnMessage(message)" class="message-sender">
              {{ message.nome }}
            </div>
            <div class="message-content">
              <template v-if="message.imagem_url">
                <img :src="message.imagem_url" alt="imagem" class="message-image" style="max-width: 220px; max-height: 220px; border-radius: 8px; margin-bottom: 4px; cursor: pointer;" @click="openImageModal(message.imagem_url)" />
              </template>
              <div v-if="!message.imagem_url" class="message-text">{{ message.mensagem }}</div>
            </div>
            <div class="message-timestamp">
              {{ formatMessageTime(message.created_at) }}
            </div>
          </div>
        </div>
      </div>
    </main>

    <footer class="chat-input-area">
      <div class="input-container">
        <button class="icon-btn emoji-btn" @click="toggleEmojiPicker" title="Emoji">
          <svg viewBox="0 0 24 24" width="20" height="20">
            <circle cx="12" cy="12" r="10" fill="#FFD93B"/>
            <circle cx="8.5" cy="10" r="1.5" fill="#3E4347"/>
            <circle cx="15.5" cy="10" r="1.5" fill="#3E4347"/>
            <path d="M8 15c1.333 1 2.667 1 4 0" stroke="#3E4347" stroke-width="1.5" stroke-linecap="round" fill="none"/>
          </svg>
        </button>
        
        <div class="input-wrapper">
          <textarea 
            v-model="newMessage" 
            @keydown.enter.prevent="handleEnterPress"
            @input="autoResize"
            placeholder="Digite uma mensagem..." 
            class="message-input"
            ref="messageInput"
            rows="1"
          ></textarea>
        </div>
        
        <button 
          @click="sendMessage"
          :disabled="!newMessage.trim()"
          class="send-btn"
          :class="{ 'active': newMessage.trim() }"
        >
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
          </svg>
        </button>
      </div>

      <!-- Seletor de emojis -->
      <EmojiPicker 
        :show="showEmojiPicker" 
        @emoji-selected="selectEmoji"
      />
    </footer>

    <!-- Inputs ocultos para upload -->
    <input 
      ref="imageInput" 
      type="file" 
      accept="image/*" 
      @change="handleImageUpload" 
      style="display: none"
    >
    <input 
      ref="fileInput" 
      type="file" 
      @change="handleFileUpload" 
      style="display: none"
    >

    <!-- Modal de imagem ampliada -->
    <div v-if="showImageModal" class="image-modal" @click.self="closeImageModal">
      <img :src="selectedImage" alt="Imagem ampliada" class="modal-image-large" />
      <button class="close-modal-btn" @click="closeImageModal">×</button>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, nextTick, onMounted, onUnmounted, defineEmits } from 'vue';
import { messageService, searchService, MESSAGE_TYPES } from '@/services/messages.js';
import EmojiPicker from '@/components/EmojiPicker.vue';
import { supabase } from '@/services/supabase.js';

const props = defineProps({
  conversation: {
    type: Object,
    required: true
  },
  instanceId: {
    type: [String, Number],
    default: null
  },
  instanceName: {
    type: String,
    default: null
  },
  numeroInstancia: {
    type: String,
    default: null
  }
});

const messagesContainer = ref(null);
const messageInput = ref(null);
const imageInput = ref(null);
const fileInput = ref(null);
const newMessage = ref('');
const messages = ref([]);
const loading = ref(false);
const showSearch = ref(false);
const searchQuery = ref('');
const searchResults = ref([]);
const showMenu = ref(false);
const showImageModal = ref(false);
const selectedImage = ref('');
const showEmojiPicker = ref(false);
let chatChannel = null;
let updateTimeout = null;

const emit = defineEmits(['message-sent', 'new-message-received']);

const scrollToBottom = () => {
  if (messagesContainer.value) {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight;
  }
};

const updateMessages = (newMessage) => {
  console.log('🔄 Tentando adicionar mensagem:', newMessage.id, newMessage.mensagem);
  
  // Verificar se a mensagem já existe
  const messageExists = messages.value.some(msg => msg.id === newMessage.id);
  if (!messageExists) {
    console.log('✅ Mensagem não existe, adicionando...');
    messages.value.push(newMessage);
    messages.value.sort((a, b) => new Date(a.created_at) - new Date(b.created_at));
    
    // Debounce para scroll
    if (updateTimeout) {
      clearTimeout(updateTimeout);
    }
    updateTimeout = setTimeout(() => {
      nextTick(() => {
        scrollToBottom();
      });
    }, 100);
    
    console.log('📊 Total de mensagens agora:', messages.value.length);
  } else {
    console.log('❌ Mensagem já existe, ignorando...');
  }
};

const loadMessages = async () => {
  if (!props.conversation?.numero_contato || !props.numeroInstancia) return;
  loading.value = true;
  try {
    const { data, error } = await supabase
      .from('vue_mensagens')
      .select('*')
      .eq('numero_contato', props.conversation.numero_contato)
      .eq('numero_instancia', props.numeroInstancia)
      .order('data_criacao', { ascending: true });
    if (error) throw error;
    messages.value = data || [];
    nextTick(() => {
      scrollToBottom();
    });
  } catch (error) {
    console.error('Erro ao carregar mensagens:', error);
  } finally {
    loading.value = false;
  }
};

function gerarUUID() {
  // Gera um UUID v4 simples
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = Math.random() * 16 | 0, v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

async function getOrCreateConversaId(instanceId, numeroContato) {
  const { data, error } = await supabase
    .from('vue_mensagens')
    .select('id_conversa')
    .eq('id_instancia', instanceId)
    .eq('numero_contato', numeroContato)
    .limit(1);
  if (data && data.length > 0 && data[0].id_conversa) {
    return data[0].id_conversa;
  } else {
    return gerarUUID();
  }
}

const handleEnterPress = (event) => {
  if (event.shiftKey) {
    // Shift+Enter para nova linha
    return;
  }
  // sendMessage();
};

const autoResize = () => {
  if (messageInput.value) {
    messageInput.value.style.height = 'auto';
    messageInput.value.style.height = messageInput.value.scrollHeight + 'px';
  }
};

const toggleSearch = () => {
  showSearch.value = !showSearch.value;
  if (!showSearch.value) {
    searchQuery.value = '';
    searchResults.value = [];
  }
};

const searchMessages = async () => {
  if (!searchQuery.value.trim() || !props.conversation?.id) {
    searchResults.value = [];
    return;
  }

  try {
    const results = await searchService.searchMessages(props.conversation.id, searchQuery.value);
    searchResults.value = results;
  } catch (error) {
    console.error('Erro na busca:', error);
    searchResults.value = [];
  }
};

const clearSearch = () => {
  searchQuery.value = '';
  searchResults.value = [];
  showSearch.value = false;
};

const triggerFileUpload = (type) => {
  showAttachmentMenu.value = false;
  if (type === 'image') {
    imageInput.value.click();
  } else {
    fileInput.value.click();
  }
};

const handleImageUpload = async (event) => {
  const file = event.target.files[0];
  if (!file) return;

  try {
    // Aqui você implementaria o upload para o Supabase Storage
    const imageUrl = await uploadFile(file, 'images');
    await messageService.sendMessage(
      props.conversation.id, 
      imageUrl, 
      MESSAGE_TYPES.IMAGE
    );
    await loadMessages();
  } catch (error) {
    console.error('Erro ao enviar imagem:', error);
  }
};

const handleFileUpload = async (event) => {
  const file = event.target.files[0];
  if (!file) return;

  try {
    // Aqui você implementaria o upload para o Supabase Storage
    const fileUrl = await uploadFile(file, 'files');
    await messageService.sendMessage(
      props.conversation.id, 
      fileUrl, 
      MESSAGE_TYPES.FILE
    );
    await loadMessages();
  } catch (error) {
    console.error('Erro ao enviar arquivo:', error);
  }
};

const uploadFile = async (file, folder) => {
  // Implementar upload para Supabase Storage
  // Por enquanto, retorna uma URL mock
  return URL.createObjectURL(file);
};

const getContactName = () => {
  if (props.conversation?.participants) {
    const otherParticipants = props.conversation.participants.filter(p => p.user_id !== getCurrentUserId());
    if (otherParticipants.length > 0) {
      return otherParticipants[0].users?.name || 'Usuário';
    }
  }
  return 'Contato';
};

const getContactAvatar = () => {
  if (props.conversation?.participants) {
    const otherParticipants = props.conversation.participants.filter(p => p.user_id !== getCurrentUserId());
    if (otherParticipants.length > 0) {
      return otherParticipants[0].users?.avatar_url || 'https://i.pravatar.cc/150?img=1';
    }
  }
  return 'https://i.pravatar.cc/150?img=1';
};

const getContactStatus = () => {
  return 'online';
};

const isOwnMessage = (message) => {
  return message.status === 'send';
};

const getSenderName = (message) => {
  return message.sender?.name || 'Usuário';
};

const formatMessageTime = (timestamp) => {
  if (!timestamp) return '';
  const date = new Date(timestamp);
  const now = new Date();
  const diffInHours = (now - date) / (1000 * 60 * 60);
  if (diffInHours < 24) {
    return date.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
  } else {
    return date.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' });
  }
};

const getFileName = (url) => {
  return url.split('/').pop() || 'arquivo';
};

const openImageModal = (url) => {
  selectedImage.value = url;
  showImageModal.value = true;
};

const closeImageModal = () => {
  showImageModal.value = false;
  selectedImage.value = '';
};

const downloadFile = (fileUrl) => {
  const link = document.createElement('a');
  link.href = fileUrl;
  link.download = getFileName(fileUrl);
  link.click();
};

const clearChat = () => {
  if (confirm('Tem certeza que deseja limpar esta conversa?')) {
    messages.value = [];
  }
  showMenu.value = false;
};

const blockContact = () => {
  if (confirm('Tem certeza que deseja bloquear este contato?')) {
    // Implementar bloqueio
    console.log('Contato bloqueado');
  }
  showMenu.value = false;
};

const getCurrentUserId = () => {
  // Implementar lógica para obter ID do usuário atual
  return null;
};

const scrollToMessage = (messageId) => {
  // Implementar scroll para mensagem específica
  console.log('Scroll para mensagem:', messageId);
};

const toggleEmojiPicker = () => {
  showEmojiPicker.value = !showEmojiPicker.value;
  showAttachmentMenu.value = false;
};

const selectEmoji = (emoji) => {
  newMessage.value += emoji;
  showEmojiPicker.value = false;
  nextTick(() => {
    messageInput.value?.focus();
  });
};

const clearRealtimeAndPolling = () => {
  // Limpar timeout
  if (updateTimeout) {
    clearTimeout(updateTimeout);
    updateTimeout = null;
  }
  // Remover canal do chat
  if (chatChannel) {
    supabase.removeChannel(chatChannel);
    chatChannel = null;
  }
};

const sendMessage = async () => {
  if (!newMessage.value.trim() || !props.conversation?.numero_contato || !props.instanceId) return;

  const messageText = newMessage.value.trim();
  newMessage.value = '';
  autoResize();

  try {
    // Buscar ou criar conversa_id para o par
    const conversaId = await getOrCreateConversaId(props.instanceId, props.conversation.numero_contato || '');
    const message = await messageService.sendMessage(
      conversaId,
      messageText,
      'send',
      '',
      props.conversation.nome_contato,
      props.instanceId,
      props.numeroInstancia,
      props.conversation.numero_contato || ''
    );

    // Adicionar mensagem localmente imediatamente
    updateMessages(message);
    nextTick(() => {
      scrollToBottom();
    });

    // Chamada ao webhook
    try {
      await fetch('https://webhook.devchat.com.br/webhook/2efe7e16-78e9-4df2-9d28-cfc05a89f37c', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          nome_contato: props.conversation.nome_contato || '',
          mensagem: messageText,
          id: message.id,
          nome_instancia: props.instanceName || '',
          numero_contato: props.conversation.numero_contato || ''
        })
      });
    } catch (webhookError) {
      console.error('Erro ao enviar para o webhook:', webhookError);
    }
  } catch (error) {
    console.error('Erro ao enviar mensagem:', error);
    // Restaurar mensagem em caso de erro
    newMessage.value = messageText;
  }
};

onMounted(async () => {
  console.log('🔄 ChatWindow montado para:', props.conversation?.nome_contato);
  await loadMessages();
  clearRealtimeAndPolling(); // Proteção extra
  // Criar canal único para real-time
  if (props.conversation?.nome_contato) {
    console.log('📡 Criando canal real-time para:', props.conversation.nome_contato);
    chatChannel = supabase.channel(`chat_${props.conversation.nome_contato}`)
      .on(
        'postgres_changes',
        { 
          event: 'INSERT', 
          schema: 'public', 
          table: 'vue_mensagens'
        },
        (payload) => {
          const msg = payload?.new;
          if (
            msg.numero_contato === props.conversation.numero_contato &&
            msg.numero_instancia === props.numeroInstancia &&
            msg.status === 'received'
          ) {
            updateMessages(msg);
          }
        }
      );
    await chatChannel.subscribe();
    console.log('✅ Canal real-time inscrito com sucesso');
  }
});

onUnmounted(() => {
  clearRealtimeAndPolling();
});

watch(
  () => props.conversation,
  async (newVal, oldVal) => {
    console.log('🔄 Conversa alterada:', oldVal?.numero_contato, '->', newVal?.numero_contato);
    clearRealtimeAndPolling();
    if (newVal?.numero_contato) {
      await loadMessages();
      // Criar novo canal para a nova conversa
      console.log('📡 Criando novo canal real-time para:', newVal.numero_contato);
      chatChannel = supabase.channel(`chat_${newVal.numero_contato}`)
        .on(
          'postgres_changes',
          { 
            event: 'INSERT', 
            schema: 'public', 
            table: 'vue_mensagens'
          },
          (payload) => {
            const msg = payload?.new;
            if (
              msg.numero_contato === newVal.numero_contato &&
              msg.numero_instancia === props.numeroInstancia &&
              msg.status === 'received'
            ) {
              updateMessages(msg);
            }
          }
        );
      await chatChannel.subscribe();
      console.log('✅ Novo canal real-time inscrito com sucesso');
    }
  },
  { immediate: true }
);

watch(messages, () => {
  nextTick(() => {
    scrollToBottom();
  });
}, { deep: true });

watch(searchQuery, searchMessages);
</script>

<style scoped>
.chat-window {
  display: flex;
  flex-direction: column;
  height: 100%;
  background-color: #fff;
}

.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 20px;
  border-bottom: 1px solid #e0e0e0;
  background-color: #f8f9fa;
  position: relative;
}

.contact-info {
  display: flex;
  align-items: center;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  margin-right: 12px;
  object-fit: cover;
}

.details {
  display: flex;
  flex-direction: column;
}

.contact-name {
  font-weight: 600;
  font-size: 16px;
  color: #333;
}

.contact-status {
  display: flex;
  align-items: center;
  font-size: 13px;
  color: #666;
  margin-top: 2px;
}

.status-dot {
  width: 8px;
  height: 8px;
  background: #22c55e;
  border-radius: 50%;
  margin-right: 6px;
}

.header-icons {
  display: flex;
  gap: 12px;
}

.icon-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 8px;
  border-radius: 50%;
  color: #666;
  transition: background-color 0.2s;
}

.icon-btn:hover {
  background-color: #e9ecef;
}

.menu-dropdown {
  position: absolute;
  top: 100%;
  right: 20px;
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  z-index: 1000;
  min-width: 150px;
}

.menu-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  background: none;
  border: none;
  width: 100%;
  text-align: left;
  cursor: pointer;
  color: #333;
  transition: background-color 0.2s;
}

.menu-item:hover {
  background-color: #f8f9fa;
}

.search-bar {
  display: flex;
  align-items: center;
  padding: 12px 20px;
  background-color: #f8f9fa;
  border-bottom: 1px solid #e0e0e0;
  gap: 12px;
}

.search-icon {
  width: 20px;
  height: 20px;
  color: #666;
}

.search-input {
  flex: 1;
  border: none;
  background: white;
  padding: 8px 12px;
  border-radius: 20px;
  font-size: 14px;
}

.close-search-btn {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  color: #666;
  padding: 4px;
}

.chat-messages {
  flex-grow: 1;
  padding: 20px;
  background-color: #f0f2f5;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.loading-messages {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px;
  color: #666;
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

.search-results {
  background: white;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 16px;
}

.search-results-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.search-results-header h4 {
  margin: 0;
  font-size: 14px;
  color: #333;
}

.clear-search-btn {
  background: none;
  border: none;
  color: #22c55e;
  cursor: pointer;
  font-size: 12px;
}

.search-result-item {
  padding: 8px 12px;
  border-radius: 6px;
  cursor: pointer;
  transition: background-color 0.2s;
  margin-bottom: 4px;
}

.search-result-item:hover {
  background-color: #f8f9fa;
}

.search-result-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-result-text {
  font-size: 13px;
  color: #333;
  flex: 1;
}

.search-result-time {
  font-size: 11px;
  color: #666;
  margin-left: 12px;
}

.messages-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.message-wrapper {
  display: flex;
  max-width: 70%;
}

.message-wrapper.sent {
  align-self: flex-end;
}

.message-wrapper.received {
  align-self: flex-start;
}

.message-bubble {
  padding: 8px 12px;
  border-radius: 12px;
  position: relative;
  box-shadow: 0 1px 2px rgba(0,0,0,0.1);
}

.message-wrapper.sent .message-bubble {
  background-color: #22c55e;
  color: white;
}

.message-wrapper.received .message-bubble {
  background-color: #ffffff;
  color: #333;
}

.message-sender {
  font-size: 12px;
  font-weight: 600;
  color: #22c55e;
  margin-bottom: 4px;
}

.message-content {
  margin-bottom: 4px;
}

.message-text {
  font-size: 14px;
  line-height: 1.4;
  white-space: pre-wrap;
}

.message-image {
  display: block;
  margin: 0 auto 4px auto;
  border-radius: 8px;
  max-width: 220px;
  max-height: 220px;
}

.message-file {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px;
  background: rgba(0,0,0,0.05);
  border-radius: 6px;
}

.file-info {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
}

.file-name {
  font-size: 13px;
  font-weight: 500;
}

.download-btn {
  background: #22c55e;
  color: white;
  border: none;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 11px;
  cursor: pointer;
}

.message-timestamp {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 4px;
  font-size: 11px;
  color: rgba(255,255,255,0.8);
}

.message-wrapper.received .message-timestamp {
  color: #666;
}

.message-status {
  display: flex;
  align-items: center;
}

.chat-input-area {
  padding: 12px 20px;
  background-color: #f8f9fa;
  border-top: 1px solid #e0e0e0;
  position: relative;
}

.input-container {
  display: flex;
  align-items: flex-end;
  gap: 12px;
}

.emoji-btn {
  padding: 8px;
  color: #666;
}

.input-wrapper {
  flex: 1;
  background-color: white;
  border-radius: 20px;
  padding: 8px 12px;
  border: 1px solid #e0e0e0;
  min-height: 40px;
  max-height: 120px;
  overflow-y: auto;
}

.message-input {
  width: 100%;
  border: none;
  outline: none;
  font-size: 14px;
  background: transparent;
  resize: none;
  font-family: inherit;
  line-height: 1.4;
}

.send-btn {
  background: #e0e0e0;
  border: none;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
  color: #666;
}

.send-btn.active {
  background: #22c55e;
  color: white;
}

.send-btn:disabled {
  cursor: not-allowed;
  opacity: 0.5;
}

.image-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0,0,0,0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.modal-image-large {
  max-width: 90vw;
  max-height: 90vh;
  border-radius: 12px;
  box-shadow: 0 4px 24px rgba(0,0,0,0.3);
}

.close-modal-btn {
  position: absolute;
  top: 32px;
  right: 48px;
  background: transparent;
  border: none;
  color: #fff;
  font-size: 2.5rem;
  cursor: pointer;
  z-index: 10000;
}
</style> 