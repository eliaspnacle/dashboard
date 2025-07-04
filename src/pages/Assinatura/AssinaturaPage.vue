<template>
  <div class="layout-container">
    <SidebarMenu />
    <div class="main-content">
      <div class="header-bar">
        <h2>Minha Assinatura</h2>
      </div>
      <div class="cards-row">
        <!-- STATUS -->
        <div class="info-card">
          <div class="card-title">STATUS</div>
          <div class="status-content">
            <span class="status-icon">⚠️</span>
            <span class="status-pendente">Pendente</span>
          </div>
          <div class="status-desc">O período de testes acabou</div>
          <button class="assinar-btn">
            <span class="btn-icon">🛒</span>
            Assinar
          </button>
        </div>
        <!-- VENCIMENTO -->
        <div class="info-card">
          <div class="card-title">VENCIMENTO</div>
          <div class="vencimento-content">
            <span class="vencimento-icon">📅</span>
            <span class="vencimento-data">22/01/2025</span>
          </div>
        </div>
        <!-- INSTÂNCIAS CRIADAS -->
        <div class="info-card">
          <div class="card-title">INSTÂNCIAS CRIADAS</div>
          <div class="instancias-content">
            <span class="instancia-icon" style="display: flex; align-items: center;">
              <svg xmlns="http://www.w3.org/2000/svg" x="0px" y="0px" width="32" height="32" viewBox="0 0 48 48">
                <path fill="#fff" d="M4.868,43.303l2.694-9.835C5.9,30.59,5.026,27.324,5.027,23.979C5.032,13.514,13.548,5,24.014,5c5.079,0.002,9.845,1.979,13.43,5.566c3.584,3.588,5.558,8.356,5.556,13.428c-0.004,10.465-8.522,18.98-18.986,18.98c-0.001,0,0,0,0,0h-0.008c-3.177-0.001-6.3-0.798-9.073-2.311L4.868,43.303z"></path>
                <path fill="#fff" d="M4.868,43.803c-0.132,0-0.26-0.052-0.355-0.148c-0.125-0.127-0.174-0.312-0.127-0.483l2.639-9.636c-1.636-2.906-2.499-6.206-2.497-9.556C4.532,13.238,13.273,4.5,24.014,4.5c5.21,0.002,10.105,2.031,13.784,5.713c3.679,3.683,5.704,8.577,5.702,13.781c-0.004,10.741-8.746,19.48-19.486,19.48c-3.189-0.001-6.344-0.788-9.144-2.277l-9.875,2.589C4.953,43.798,4.911,43.803,4.868,43.803z"></path>
                <path fill="#cfd8dc" d="M24.014,5c5.079,0.002,9.845,1.979,13.43,5.566c3.584,3.588,5.558,8.356,5.556,13.428c-0.004,10.465-8.522,18.98-18.986,18.98h-0.008c-3.177-0.001-6.3-0.798-9.073-2.311L4.868,43.303l2.694-9.835C5.9,30.59,5.026,27.324,5.027,23.979C5.032,13.514,13.548,5,24.014,5 M24.014,42.974C24.014,42.974,24.014,42.974,24.014,42.974C24.014,42.974,24.014,42.974,24.014,42.974 M24.014,42.974C24.014,42.974,24.014,42.974,24.014,42.974C24.014,42.974,24.014,42.974,24.014,42.974 M24.014,4C24.014,4,24.014,4,24.014,4C12.998,4,4.032,12.962,4.027,23.979c-0.001,3.367,0.849,6.685,2.461,9.622l-2.585,9.439c-0.094,0.345,0.002,0.713,0.254,0.967c0.19,0.192,0.447,0.297,0.711,0.297c0.085,0,0.17-0.011,0.254-0.033l9.687-2.54c2.828,1.468,5.998,2.243,9.197,2.244c11.024,0,19.99-8.963,19.995-19.98c0.002-5.339-2.075-10.359-5.848-14.135C34.378,6.083,29.357,4.002,24.014,4L24.014,4z"></path>
                <path fill="#40c351" d="M35.176,12.832c-2.98-2.982-6.941-4.625-11.157-4.626c-8.704,0-15.783,7.076-15.787,15.774c-0.001,2.981,0.833,5.883,2.413,8.396l0.376,0.597l-1.595,5.821l5.973-1.566l0.577,0.342c2.422,1.438,5.2,2.198,8.032,2.199h0.006c8.698,0,15.777-7.077,15.78-15.776C39.795,19.778,38.156,15.814,35.176,12.832z"></path>
                <path fill="#fff" fill-rule="evenodd" d="M19.268,16.045c-0.355-0.79-0.729-0.806-1.068-0.82c-0.277-0.012-0.593-0.011-0.909-0.011c-0.316,0-0.83,0.119-1.265,0.594c-0.435,0.475-1.661,1.622-1.661,3.956c0,2.334,1.7,4.59,1.937,4.906c0.237,0.316,3.282,5.259,8.104,7.161c4.007,1.58,4.823,1.266,5.693,1.187c0.87-0.079,2.807-1.147,3.202-2.255c0.395-1.108,0.395-2.057,0.277-2.255c-0.119-0.198-0.435-0.316-0.909-0.554s-2.807-1.385-3.242-1.543c-0.435-0.158-0.751-0.237-1.068,0.238c-0.316,0.474-1.225,1.543-1.502,1.859c-0.277,0.317-0.554,0.357-1.028,0.119c-0.474-0.238-2.002-0.738-3.815-2.354c-1.41-1.257-2.362-2.81-2.639-3.285c-0.277-0.474-0.03-0.731,0.208-0.968c0.213-0.213,0.474-0.554,0.712-0.831c0.237-0.277,0.316-0.475,0.474-0.791c0.158-0.317,0.079-0.594-0.04-0.831C20.612,19.329,19.69,16.983,19.268,16.045z" clip-rule="evenodd"></path>
              </svg>
            </span>
            <span class="instancia-num">{{ instances.length }}</span>
          </div>
          <div class="instancia-desc">De 5 contratadas</div>
        </div>
      </div>
      <!-- Suas Instâncias -->
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/services/supabase'
import SidebarMenu from '@/components/layout/SidebarMenu.vue'

const instances = ref([])
const userId = ref(null)

async function fetchInstances() {
  try {
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
  }
}

onMounted(async () => {
  const { data } = await supabase.auth.getUser();
  if (data && data.user) {
    userId.value = data.user.id;
    fetchInstances();
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
  margin-bottom: 18px;
  margin-top: 0;
  width: 100%;
}
.header-bar h2 {
  font-size: 1.6rem;
  font-weight: 600;
  margin: 0;
  color: #222;
}
.cards-row {
  display: flex;
  gap: 18px;
  width: 100%;
  margin-bottom: 18px;
}
.info-card {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  padding: 20px 24px 18px 24px;
  min-width: 220px;
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  border: 1px solid #ececec;
}
.card-title {
  font-size: 0.95rem;
  color: #888;
  font-weight: 600;
  margin-bottom: 8px;
  letter-spacing: 0.5px;
}
.status-content {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 2px;
}
.status-icon {
  color: #f59e42;
  font-size: 1.3rem;
}
.status-pendente {
  color: #f59e42;
  font-size: 1.3rem;
  font-weight: 600;
}
.status-desc {
  color: #888;
  font-size: 0.98rem;
  margin-bottom: 12px;
}
.assinar-btn {
  background: #22c55e;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 8px 0;
  width: 100%;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-top: 8px;
  transition: background 0.2s;
}
.assinar-btn:hover {
  background: #16a34a;
}
.btn-icon {
  font-size: 1.1rem;
}
.vencimento-content {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 1.3rem;
  font-weight: 600;
  color: #222;
}
.vencimento-icon {
  font-size: 1.3rem;
}
.vencimento-data {
  font-size: 1.3rem;
}
.instancias-content {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 1.3rem;
  font-weight: 600;
  color: #2563eb;
}
.instancia-icon {
  font-size: 1.3rem;
}
.instancia-num {
  font-size: 1.3rem;
}
.instancia-desc {
  color: #888;
  font-size: 0.98rem;
}
.info-message {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  border: 1px solid #ececec;
  padding: 14px 18px;
  margin: 18px 0 0 0;
  width: 100%;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 1rem;
  color: #444;
}
.info-icon {
  color: #2563eb;
  font-size: 1.2rem;
}
.info-link {
  color: #2563eb;
  text-decoration: underline;
  cursor: pointer;
}
.instancias-section {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  border: 1px solid #ececec;
  margin-top: 18px;
  width: 100%;
  padding: 18px 18px 32px 18px;
}
.instancias-title {
  font-size: 1.1rem;
  font-weight: 600;
  margin-bottom: 18px;
  color: #222;
}
.instancias-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 32px 0;
  color: #888;
  gap: 12px;
}
.placeholder-icon {
  font-size: 2.5rem;
  color: #bdbdbd;
}
.placeholder-text {
  font-size: 1.1rem;
  color: #888;
}
</style> 