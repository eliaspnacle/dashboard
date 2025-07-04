<template>
  <aside class="sidebar">
    <div class="sidebar-logo">
      <img src="@/assets/logo.svg" alt="Logo Devchat" class="devchat-logo" />
    </div>
    <nav class="sidebar-menu">
      <ul>
        <li :class="{ active: route.path === '/inicio' }">
          <router-link to="/inicio" class="menu-link">
            <span class="menu-icon">
              <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M3 12L12 5l9 7"/><path d="M5 12v7a2 2 0 0 0 2 2h2a2 2 0 0 0 2-2v-3h2v3a2 2 0 0 0 2 2h2a2 2 0 0 0 2-2v-7"/></svg>
            </span>
            <span>Inicio</span>
          </router-link>
        </li>
        <li :class="{ active: route.path === '/instancias' }">
          <router-link to="/instancias" class="menu-link">
            <span class="menu-icon">
              <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="3" y="7" width="18" height="13" rx="2"/><path d="M8 7V5a4 4 0 0 1 8 0v2"/></svg>
            </span>
            <span>Instâncias</span>
          </router-link>
        </li>
        <li :class="{ active: route.path === '/mensagens' }">
          <router-link to="/mensagens" class="menu-link">
            <span class="menu-icon">
              <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
            </span>
            <span>Mensagens</span>
          </router-link>
        </li>
        <li :class="{ active: route.path === '/automacao' }">
          <router-link to="/automacao" class="menu-link">
            <span class="menu-icon">
              <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M12 8v4l3 3"/></svg>
            </span>
            <span>Automação</span>
          </router-link>
        </li>
        <li :class="{ active: route.path === '/assinatura' }">
          <router-link to="/assinatura" class="menu-link">
            <span class="menu-icon">
              <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="2" y="7" width="20" height="10" rx="2"/><circle cx="12" cy="12" r="3"/><path d="M2 9a2 2 0 0 0 2-2m16 0a2 2 0 0 0 2 2m-18 6a2 2 0 0 0 2 2m16 0a2 2 0 0 0 2-2"/></svg>
            </span>
            <span>Assinatura</span>
          </router-link>
        </li>
      </ul>
    </nav>
    <div class="sidebar-user">
      <button class="logout-btn" @click="logout">
        <span class="logout-icon">
          <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M17 16l4-4m0 0l-4-4m4 4H7"/><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/></svg>
        </span>
        Sair
      </button>
    </div>
  </aside>
</template>

<script setup>
import { useRoute, useRouter } from 'vue-router';
import { supabase } from '@/services/supabase';

const route = useRoute();
const router = useRouter();

const logout = async () => {
  try {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
    
    // Após o logout bem-sucedido, o guarda de rotas irá redirecionar
    // para /login se o usuário tentar acessar uma rota protegida.
    // Mas podemos forçar o redirecionamento imediato aqui.
    router.push('/login');
  } catch (error) {
    console.error('Erro ao fazer logout:', error.message);
  }
};
</script>

<style scoped>
.sidebar {
  width: 220px;
  min-width: 220px;
  background: #fff;
  border-right: 1px solid #e5e7eb;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  padding: 24px 0 12px 0;
  min-height: 100vh;
  height: 100%;
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
  color: #4A5568;
  border-left: 4px solid transparent;
  transition: background 0.2s, border 0.2s;
}
.sidebar-menu li:hover {
  background: #f0f4f8;
  font-weight: 500;
}
.sidebar-menu li.active {
  border-left-color: #22c55e;
  color: #222;
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
.menu-link {
  display: flex;
  align-items: center;
  gap: 12px;
  text-decoration: none;
  color: inherit;
}
.menu-icon {
  display: flex;
  align-items: center;
}
</style> 