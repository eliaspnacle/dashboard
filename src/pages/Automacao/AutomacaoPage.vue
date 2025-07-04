<template>
  <div class="layout-container">
    <SidebarMenu />
    <div class="main-content">
      <div class="header-bar">
        <h2 class="welcome-text">Automação</h2>
      </div>
      <div class="custom-desc">
        <strong>Mensagem Personalizada</strong><br>
        Crie abaixo mensagens personalizadas. O sistema enviará as mensagens em ordem de cadastro.
      </div>
      <div class="card">
        <div class="left-panel">
          <div class="message-block">
            <div class="message-block-header">
              <span class="message-title">Mensagem 01</span>
            </div>
            <div class="message-block-desc">
              Crie uma mensagem personalizada que será enviada automaticamente para o usuário via WhatsApp.
            </div>
            <label for="msg1" class="message-label">Texto da mensagem</label>
            <textarea id="msg1" v-model="msg1" class="message-textarea" :disabled="saved1" placeholder="Digite sua mensagem aqui..."></textarea>
            <div class="attachments-row">
              <label class="attach-btn">
                📷 Imagem
                <input type="file" accept="image/*" @change="onImageChange1" :disabled="saved1" style="display:none" />
              </label>
              <label class="attach-btn">
                📄 Documento
                <input type="file" accept=".pdf,.doc,.docx,.txt,.xls,.xlsx,.ppt,.pptx,.odt,.ods,.odp,.csv,.zip,.rar,.7z,.tar,.gz,.xml,.json,.rtf" @change="onDocChange1" :disabled="saved1" style="display:none" />
              </label>
            </div>
            <div v-if="img1Url" class="preview-img">
              <img :src="img1Url" alt="Preview" />
              <button class="remove-attach" @click="removeImg1" type="button">×</button>
            </div>
            <div v-if="doc1Name" class="preview-doc">
              📄 {{ doc1Name }}
              <button class="remove-attach" @click="removeDoc1" type="button">×</button>
            </div>
            <button class="save-btn" @click="toggleSave1" :class="{ edit: saved1 }">
              {{ saved1 ? 'Editar' : 'Salvar' }}
            </button>
          </div>
          <div class="message-block">
            <div class="message-block-header">
              <span class="message-title">Mensagem 02</span>
            </div>
            <div class="message-block-desc">
              Crie uma mensagem personalizada que será enviada automaticamente para o usuário via WhatsApp.
            </div>
            <label for="msg2" class="message-label">Texto da mensagem</label>
            <textarea id="msg2" v-model="msg2" class="message-textarea" :disabled="saved2" placeholder="Digite sua mensagem aqui..."></textarea>
            <div class="attachments-row">
              <label class="attach-btn">
                📷 Imagem
                <input type="file" accept="image/*" @change="onImageChange2" :disabled="saved2" style="display:none" />
              </label>
              <label class="attach-btn">
                📄 Documento
                <input type="file" accept=".pdf,.doc,.docx,.txt,.xls,.xlsx,.ppt,.pptx,.odt,.ods,.odp,.csv,.zip,.rar,.7z,.tar,.gz,.xml,.json,.rtf" @change="onDocChange2" :disabled="saved2" style="display:none" />
              </label>
            </div>
            <div v-if="img2Url" class="preview-img">
              <img :src="img2Url" alt="Preview" />
              <button class="remove-attach" @click="removeImg2" type="button">×</button>
            </div>
            <div v-if="doc2Name" class="preview-doc">
              📄 {{ doc2Name }}
              <button class="remove-attach" @click="removeDoc2" type="button">×</button>
            </div>
            <button class="save-btn" @click="toggleSave2" :class="{ edit: saved2 }">
              {{ saved2 ? 'Editar' : 'Salvar' }}
            </button>
          </div>
        </div>
        <div class="phone-mockup-side">
          <div class="phone-mockup-realista">
            <div class="wa-top-bar">
              <span class="wa-status-bar">
                <span class="wa-status-icons">
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="2" fill="#888"/></svg>
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><rect x="4" y="4" width="16" height="16" rx="8" fill="#888"/></svg>
                </span>
              </span>
              <span class="wa-header-bar">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none"><path d="M15 18l-6-6 6-6" stroke="#222" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                <img class="wa-avatar" src="https://cdn-icons-png.flaticon.com/512/149/149071.png" alt="Avatar" />
                <span class="wa-contact-info">
                  <span class="wa-contact-name">Contato</span>
                  <span class="wa-contact-status">online</span>
                </span>
                <span class="wa-header-icons">
                  <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="10" stroke="#222" stroke-width="2"/></svg>
                  <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><rect x="6" y="8" width="12" height="8" rx="2" stroke="#222" stroke-width="2"/></svg>
                  <svg width="22" height="22" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="1" fill="#222"/><circle cx="19" cy="12" r="1" fill="#222"/><circle cx="5" cy="12" r="1" fill="#222"/></svg>
                </span>
              </span>
            </div>
            <div class="wa-chat-bg">
              <div class="wa-messages-area">
                <div v-if="msg1 || img1Url || doc1Name" class="wa-bubble wa-bubble-received wa-bubble-user">
                  <div v-if="msg1">{{ msg1 }}</div>
                  <div v-if="img1Url"><img :src="img1Url" alt="Preview" class="wa-img-preview" /></div>
                  <div v-if="doc1Name" class="wa-doc-preview">📄 {{ doc1Name }}</div>
                  <span class="wa-time">14:02 <span class="wa-checks">✔✔</span></span>
                </div>
                <div v-if="msg2 || img2Url || doc2Name" class="wa-bubble wa-bubble-received wa-bubble-user">
                  <div v-if="msg2">{{ msg2 }}</div>
                  <div v-if="img2Url"><img :src="img2Url" alt="Preview" class="wa-img-preview" /></div>
                  <div v-if="doc2Name" class="wa-doc-preview">📄 {{ doc2Name }}</div>
                  <span class="wa-time">14:02 <span class="wa-checks">✔✔</span></span>
                </div>
              </div>
            </div>
            <div class="wa-footer-bar">
              <svg width="28" height="28" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="10" stroke="#888" stroke-width="2"/></svg>
              <input class="wa-input" type="text" placeholder="Mensagem" disabled />
              <svg width="28" height="28" viewBox="0 0 24 24" fill="none"><rect x="6" y="11" width="12" height="2" rx="1" fill="#888"/></svg>
              <svg width="28" height="28" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="10" stroke="#888" stroke-width="2"/></svg>
              <svg width="28" height="28" viewBox="0 0 24 24" fill="none"><path d="M4 20v-2a4 4 0 0 1 4-4h8a4 4 0 0 1 4 4v2" stroke="#25d366" stroke-width="2"/></svg>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import SidebarMenu from '@/components/layout/SidebarMenu.vue'
import { supabase } from '@/services/supabase'

const route = useRoute()
const msg1 = ref('')
const saved1 = ref(false)
const img1Url = ref('')
const doc1Name = ref('')
const msg2 = ref('')
const saved2 = ref(false)
const img2Url = ref('')
const doc2Name = ref('')
const userId = ref(null)
const automacoes = ref([])

function toggleSave1() { saved1.value = !saved1.value }
function onImageChange1(e) {
  const file = e.target.files[0]
  if (file) img1Url.value = URL.createObjectURL(file)
}
function onDocChange1(e) {
  const file = e.target.files[0]
  if (file) doc1Name.value = file.name
}
function removeImg1() { img1Url.value = '' }
function removeDoc1() { doc1Name.value = '' }
function toggleSave2() { saved2.value = !saved2.value }
function onImageChange2(e) {
  const file = e.target.files[0]
  if (file) img2Url.value = URL.createObjectURL(file)
}
function onDocChange2(e) {
  const file = e.target.files[0]
  if (file) doc2Name.value = file.name
}
function removeImg2() { img2Url.value = '' }
function removeDoc2() { doc2Name.value = '' }

async function fetchAutomacoes() {
  const { data, error } = await supabase
    .from('vue_automacoes')
    .select('*')
    .eq('user_id', userId.value)
    .order('data_criacao', { ascending: false })
  if (!error) automacoes.value = data
}

async function salvarAutomacao(texto, imagem_url = '', documento_url = '') {
  const { error } = await supabase
    .from('vue_automacoes')
    .insert({
      texto,
      imagem_url,
      documento_url,
      user_id: userId.value,
      data_criacao: new Date().toISOString(),
      data_atualizacao: new Date().toISOString()
    })
  if (!error) fetchAutomacoes()
}

onMounted(async () => {
  const { data } = await supabase.auth.getUser()
  if (data && data.user) userId.value = data.user.id
  fetchAutomacoes()
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
  height: 100vh;
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
.card {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  padding: 32px 28px;
  width: 100%;
  margin: 0;
  max-width: none;
  display: flex;
  flex-direction: row;
  align-items: flex-start;
  justify-content: flex-start;
  height: calc(100vh - 32px);
  min-height: 0;
  flex: unset;
}
.card-horizontal {
  flex-direction: row;
  align-items: flex-start;
  justify-content: flex-start;
  gap: 40px;
  width: 100%;
}
.left-panel {
  flex: 1 1 0;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  max-width: 440px;
  width: 100%;
  height: 100%;
  max-height: 100%;
  overflow-y: auto;
}
.message-block {
  background: #f9fafb;
  border-radius: 10px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.04);
  padding: 24px 20px 20px 20px;
  margin-bottom: 24px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.message-block-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 2px;
}
.message-title {
  color: #22c55e;
  font-weight: 600;
  font-size: 1.08rem;
}
.message-block-desc {
  color: #666;
  font-size: 0.98rem;
  margin-bottom: 6px;
}
.message-label {
  font-size: 1rem;
  font-weight: 500;
  color: #222;
  margin-bottom: 4px;
}
.message-textarea {
  width: 100%;
  min-height: 90px;
  padding: 12px 14px;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  font-size: 1rem;
  background: #fff;
  resize: vertical;
  margin-bottom: 8px;
  transition: border 0.2s;
}
.message-textarea:focus {
  border-color: #22c55e;
}
.message-textarea:disabled {
  background: #f3f3f3;
  opacity: 0.6;
  color: #888;
  cursor: not-allowed;
}
.phone-mockup-side {
  display: flex;
  align-items: flex-start;
  justify-content: flex-start;
  min-width: 340px;
  margin-left: 40px;
  height: 100%;
}
.phone-mockup-realista {
  width: 340px;
  height: 650px;
  background-image: url('https://i.ibb.co/KchQz2NW/348fc9806e32bba0fb4c42e799ddf880.jpg');
  background-size: cover;
  background-position: center;
  border-radius: 32px;
  box-shadow: 0 4px 24px rgba(0,0,0,0.12);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  border: 6px solid #111;
  position: relative;
}
.wa-top-bar {
  background: #fff;
  padding: 0 0 2px 0;
  border-bottom: 1px solid #e5e7eb;
  display: flex;
  flex-direction: column;
  z-index: 2;
}
.wa-status-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 0.95rem;
  color: #888;
  padding: 2px 16px 0 16px;
  height: 22px;
}
.wa-status-icons svg {
  margin: 0 2px;
}
.wa-header-bar {
  display: flex;
  align-items: center;
  padding: 6px 10px 6px 6px;
  gap: 8px;
}
.wa-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #e5e7eb;
}
.wa-contact-info {
  display: flex;
  flex-direction: column;
  margin-left: 6px;
  margin-right: 12px;
}
.wa-contact-name {
  font-weight: 600;
  color: #222;
  font-size: 1.08rem;
}
.wa-contact-status {
  font-size: 0.92rem;
  color: #22c55e;
}
.wa-header-icons {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-left: auto;
}
.wa-chat-bg {
  flex: 1;
  background: #ece5dd;
  padding: 0;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
}
.wa-messages-area {
  padding: 18px 10px 12px 10px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  height: 100%;
  overflow-y: auto;
}
.wa-bubble {
  display: inline-block;
  padding: 10px 16px;
  border-radius: 12px;
  font-size: 1rem;
  max-width: 85%;
  box-shadow: 0 1px 4px rgba(0,0,0,0.06);
  word-break: break-word;
  position: relative;
  margin-bottom: 2px;
}
.wa-bubble-sent {
  align-self: flex-start;
  background: #fff;
  color: #222;
  border-bottom-left-radius: 4px;
}
.wa-bubble-received {
  align-self: flex-end;
  background: #dcf8c6;
  color: #222;
  border-bottom-right-radius: 4px;
}
.wa-bubble-success {
  background: #e7fbe7;
  border: 1px solid #b6eab6;
}
.wa-bubble-user {
  font-weight: 500;
}
.wa-time {
  font-size: 0.85rem;
  color: #888;
  margin-left: 8px;
  vertical-align: bottom;
}
.wa-checks {
  color: #22c55e;
  font-size: 0.9em;
  margin-left: 2px;
}
.wa-footer-bar {
  background: #fff;
  padding: 8px 10px;
  display: flex;
  align-items: center;
  gap: 8px;
  border-top: 1px solid #e5e7eb;
}
.wa-input {
  flex: 1;
  border: none;
  background: #f0f0f0;
  border-radius: 18px;
  padding: 8px 16px;
  font-size: 1rem;
  outline: none;
  margin: 0 4px;
}
.welcome-text {
  font-size: 1.15rem;
  font-weight: 500;
  color: #222;
  margin-bottom: 18px;
  margin-top: -18px;
}
.save-btn {
  margin-top: 8px;
  padding: 10px 24px;
  background: #22c55e;
  color: #fff;
  border: none;
  border-radius: 6px;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s;
}
.save-btn:hover {
  background: #16a34a;
}
.save-btn.edit {
  background: #f59e42;
  color: #fff;
}
.attachments-row {
  display: flex;
  gap: 12px;
  margin-bottom: 8px;
}
.attach-btn {
  background: #f3f3f3;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  padding: 7px 16px;
  font-size: 1rem;
  color: #222;
  cursor: pointer;
  font-weight: 500;
  transition: background 0.2s, border 0.2s;
  display: flex;
  align-items: center;
}
.attach-btn:hover {
  background: #e5e7eb;
}
.preview-img {
  margin-bottom: 8px;
  position: relative;
  display: inline-block;
}
.preview-img img {
  max-width: 120px;
  max-height: 80px;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
}
.preview-doc {
  margin-bottom: 8px;
  color: #222;
  font-size: 0.98rem;
  background: #f3f3f3;
  border-radius: 6px;
  padding: 4px 32px 4px 10px;
  display: inline-block;
  position: relative;
}
.wa-img-preview {
  max-width: 120px;
  max-height: 80px;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  margin-top: 6px;
}
.wa-doc-preview {
  color: #222;
  font-size: 0.98rem;
  background: #f3f3f3;
  border-radius: 6px;
  padding: 4px 10px;
  display: inline-block;
  margin-top: 6px;
}
.remove-attach {
  background: #e11d48;
  color: #fff;
  border: none;
  border-radius: 50%;
  width: 22px;
  height: 22px;
  font-size: 1.1rem;
  font-weight: bold;
  position: absolute;
  top: 4px;
  right: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2;
  transition: background 0.2s;
}
.remove-attach:hover {
  background: #be123c;
}
.custom-desc {
  margin-bottom: 18px;
  font-size: 1.08rem;
  color: #222;
  background: #f9fafb;
  border-radius: 8px;
  padding: 16px 22px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.04);
  max-width: 900px;
}
</style> 