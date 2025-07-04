<template>
  <div class="modal-overlay">
    <div class="modal-content">
      <div class="modal-header">
        <h2>Nova Instância</h2>
        <button class="close-btn-green" @click="closeModal">
          <span class="close-x">×</span>
        </button>
      </div>
      <div class="modal-body">
        <form v-if="!showToken" @submit.prevent="saveInstance">
          <div class="form-group">
            <label for="instance-name">Nome <span class="required">*</span></label>
            <input type="text" id="instance-name" v-model="instance.name" required @input="validateName" autocomplete="off">
            <div v-if="nameError" class="error-msg">{{ nameError }}</div>
          </div>
          <div class="form-group">
            <label for="instance-channel">Canal</label>
            <select id="instance-channel" v-model="instance.channel">
              <option value="baileys">Baileys</option>
              <option value="whatsapp_cloud_api">WhatsApp Cloud API</option>
            </select>
          </div>
          <div class="form-group">
            <label for="instance-number">Número</label>
            <input type="text" id="instance-number" v-model="instance.number" @input="onNumberInput">
          </div>
          <div class="form-group" v-if="instance.channel === 'whatsapp_cloud_api'">
            <label for="business-id">Business ID <span class="required">*</span></label>
            <input type="text" id="business-id" v-model="instance.businessId" :required="instance.channel === 'whatsapp_cloud_api'">
          </div>
          <div v-if="errorMsg" style="color: #ef4444; margin-bottom: 10px;">{{ errorMsg }}</div>
          <div v-if="successMsg" style="color: #22c55e; margin-bottom: 10px;">{{ successMsg }}</div>
          <div class="form-actions">
            <button type="submit" class="save-btn" :disabled="loading || !!nameError || checkingName">{{ loading ? 'Carregando...' : 'Criar Instância' }}</button>
          </div>
        </form>
        <div v-if="showToken" class="token-box">
          <label>Token gerado:</label>
          <input type="text" :value="instance.token" readonly>
          <button type="button" class="copy-btn" @click="copyToken">Copiar Token</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { supabase } from '@/services/supabase';

const props = defineProps({
  userId: String,
  initialToken: {
    type: String,
    required: true,
  }
})

const emit = defineEmits(['close', 'save']);

const instance = ref({
  name: '',
  channel: 'baileys',
  token: '',
  number: '',
  businessId: ''
});

const loading = ref(false);
const errorMsg = ref('');
const successMsg = ref('');
const showToken = ref(false);
const nameError = ref('');
const checkingName = ref(false);

async function checkUniqueName(name) {
  if (!name) return false;
  checkingName.value = true;
  try {
    // Normaliza o nome para minúsculo e sem espaços extras
    const nomeNormalizado = name.trim().toLowerCase().replace(/\s+/g, '');
    const { data, error } = await supabase
      .from('vue_instancias')
      .select('id')
      .eq('nome', nomeNormalizado)
      .limit(1);
    return data && data.length > 0;
  } catch (e) {
    return false;
  } finally {
    checkingName.value = false;
  }
}

async function validateName(e) {
  let value = e.target.value;
  // Normaliza para minúsculo e sem espaços extras
  value = value.trim().toLowerCase().replace(/\s+/g, '');
  instance.value.name = value; // Atualiza o campo já normalizado

  if (!value) {
    nameError.value = 'O nome da instância é obrigatório.';
  } else {
    nameError.value = '';
    // Verificação de unicidade
    if (value.length > 2) {
      if (await checkUniqueName(value)) {
        nameError.value = 'Já existe uma instância com esse nome. Escolha outro.';
      }
    }
  }
}

function formatPhoneNumber(value) {
  // Remove tudo que não for número
  value = value.replace(/\D/g, '');
  // Limita a 11 dígitos
  value = value.slice(0, 11);
  // Aplica a máscara xx xxxxx-xxxx
  if (value.length > 2) {
    value = value.replace(/(\d{2})(\d)/, '$1 $2');
  }
  if (value.length > 8) {
    value = value.replace(/(\d{2}) (\d{5})(\d)/, '$1 $2-$3');
  }
  return value;
}

function onNumberInput(e) {
  instance.value.number = formatPhoneNumber(e.target.value);
}

async function sendToWebhook(payload) {
  try {
    loading.value = true;
    errorMsg.value = '';
    const response = await fetch('https://webhook.devchat.com.br/webhook/1e1d3e68-f839-4518-bfb3-bd0337e6a9e6', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });
    if (!response.ok) {
      throw new Error('Erro ao criar instância.');
    }
    const data = await response.json();
    return data;
  } catch (err) {
    errorMsg.value = err.message || 'Erro desconhecido.';
    return null;
  } finally {
    loading.value = false;
  }
}

function closeModal() {
  emit('close');
}

function copyToken() {
  if (instance.value.token) {
    navigator.clipboard.writeText(instance.value.token);
    successMsg.value = 'Token copiado!';
    setTimeout(() => { successMsg.value = ''; }, 1500);
  }
}

async function saveInstance() {
  if (!instance.value.name) {
    nameError.value = 'O nome da instância é obrigatório.';
    return;
  }
  loading.value = true;
  errorMsg.value = '';
  try {
    // Remover máscara antes de salvar
    const numeroLimpo = instance.value.number.replace(/\D/g, '');
    // Normalizar nome antes de salvar
    const nomeNormalizado = instance.value.name.trim().toLowerCase().replace(/\s+/g, '');
    const { data, error } = await supabase
      .from('vue_instancias')
      .insert({
        nome: nomeNormalizado,
        numero: numeroLimpo,
        user_id: props.userId,
        data_criacao: new Date().toISOString(),
        data_atualizacao: new Date().toISOString()
      })
      .select('*')
      .single();
    if (error) throw error;
    instance.value.token = data.id;
    showToken.value = true;
    successMsg.value = 'Instância criada com sucesso!';
    emit('save', data);

    // Enviar webhook após salvar no banco
    try {
      const webhookPayload = {
        user_id: props.userId,
        instanceName: nomeNormalizado,
        number: numeroLimpo
      };
      const response = await fetch('https://webhook.devchat.com.br/webhook/1e1d3e68-f839-4518-bfb3-bd0337e6a9e6', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(webhookPayload)
      });
      if (!response.ok) {
        throw new Error('Falha ao criar instância na API externa.');
      }
    } catch (webhookError) {
      errorMsg.value = 'Instância salva, mas não foi possível criar na API externa.';
    }
  } catch (err) {
    // Detecta erro de duplicidade
    if (err.message && err.message.includes('unique_nome_instancia')) {
      nameError.value = 'Já existe uma instância com esse nome. Escolha outro.';
    } else {
      errorMsg.value = err.message || 'Erro desconhecido.';
    }
  } finally {
    loading.value = false;
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: #fff;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  width: 100%;
  max-width: 500px;
  position: relative;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.modal-header h2 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 600;
  color: #0f172a;
}

.close-btn-green {
  background: #41b883;
  border: none;
  border-radius: 6px;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: background 0.2s;
  box-shadow: 0 2px 8px rgba(65,184,131,0.08);
  padding: 0;
}
.close-btn-green:hover {
  background: #369f6b;
}
.close-x {
  color: #fff;
  font-size: 1.7rem;
  font-weight: 700;
  line-height: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

.form-group {
  margin-bottom: 16px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #374151;
}

.required {
  color: #ef4444;
}

.form-group input,
.form-group select {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  box-sizing: border-box;
  font-size: 1rem;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 24px;
}

.save-btn {
  background-color: #41b883;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 10px 24px;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s;
}

.save-btn:hover {
  background-color: #369f6b;
}

.copy-btn {
  margin-top: 8px;
  background: #f3f4f6;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  padding: 6px 12px;
  font-size: 0.95rem;
  cursor: pointer;
  color: #0f172a;
  transition: background 0.2s;
}
.copy-btn:hover {
  background: #e5e7eb;
}

.token-box {
  margin-top: 24px;
  padding: 16px;
  background: #f9fafb;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.error-msg {
  color: #ef4444;
  font-size: 0.95rem;
  margin-top: 4px;
}
</style> 