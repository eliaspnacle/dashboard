<template>
  <div class="layout-container">
    <SidebarMenu />

    <!-- Main Content -->
    <div class="main-content">
      <div class="header-bar">
        <h2 class="welcome-text">Bem Vindo! {{ userName }}</h2>
      </div>
      
      <!-- Stats Cards -->
      <div class="stats-container">
        <div class="stat-card">
          <div class="stat-icon">📱</div>
          <div class="stat-content">
            <div class="stat-number">{{ instancesCount }}</div>
            <div class="stat-label">Instâncias</div>
          </div>
        </div>
        
        <div class="stat-card">
          <div class="stat-icon">💬</div>
          <div class="stat-content">
            <div class="stat-number">{{ messagesCount }}</div>
            <div class="stat-label">Mensagens</div>
          </div>
        </div>
        
        <div class="stat-card">
          <div class="stat-icon">🔑</div>
          <div class="stat-content">
            <div class="stat-number">{{ apiKeysCount }}</div>
            <div class="stat-label">Chaves de API</div>
          </div>
        </div>
      </div>

      <div class="card">
        <h3>Chaves de API para Transcrição</h3>
        <p class="subtitle">Estas chaves de API são utilizadas para realizar a transcrição de áudio em texto. No momento, o sistema aceita apenas chaves da OpenAI para este serviço.</p>
        <table class="api-table">
          <thead>
            <tr>
              <th>Descrição</th>
              <th>Chave</th>
              <th>Ações</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>chave que nao funciona</td>
              <td>243************4y3</td>
              <td><span class="delete-icon">🗑️</span></td>
            </tr>
            <tr>
              <td>Minha Chave</td>
              <td>sk-************WU</td>
              <td><span class="delete-icon">🗑️</span></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useRoute } from 'vue-router'
import SidebarMenu from '@/components/layout/SidebarMenu.vue'
import { ref, onMounted } from 'vue'
import { supabase } from '@/services/supabase'

const route = useRoute()
const userName = ref('')

// Dados simulados para os blocos informativos
const instancesCount = ref(5)
const messagesCount = ref(1247)
const apiKeysCount = ref(2)

onMounted(async () => {
  // Buscar usuário autenticado
  const { data: authData } = await supabase.auth.getUser()
  if (authData && authData.user) {
    const userId = authData.user.id
    // Buscar dados do cadastro
    const { data, error } = await supabase
      .from('vue_cadastro')
      .select('nome, sobrenome, email')
      .eq('id', userId)
      .single()
    if (!error && data) {
      userName.value = `${data.nome} ${data.sobrenome} (${data.email})`
    }
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

/* Stats Cards Styles */
.stats-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 24px;
  width: 100%;
  margin-bottom: 32px;
}

.stat-card {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 16px;
  transition: transform 0.2s, box-shadow 0.2s;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0,0,0,0.08);
}

.stat-icon {
  font-size: 2rem;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f0f9ff;
  border-radius: 12px;
}

.stat-content {
  flex: 1;
}

.stat-number {
  font-size: 2rem;
  font-weight: 700;
  color: #1e293b;
  line-height: 1;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 0.9rem;
  color: #64748b;
  font-weight: 500;
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
  min-height: 0;
  width: 100%;
  margin: 0;
  max-width: none;
  align-items: flex-start;
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
.welcome-text {
  font-size: 1.15rem;
  font-weight: 500;
  color: #222;
  margin-bottom: 18px;
  margin-top: -18px;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .stats-container {
    grid-template-columns: 1fr;
    gap: 16px;
  }
  
  .stat-card {
    padding: 20px;
  }
  
  .stat-number {
    font-size: 1.5rem;
  }
}
</style> 