import { createRouter, createWebHistory } from 'vue-router'
import HomePage from '../pages/Inicio/HomePage.vue'
import InstanciasPage from '../pages/Instancias/InstanciasPage.vue'
import MensagensPage from '../pages/Mensagens/MensagensPage.vue'
import LoginPage from '../pages/Auth/LoginPage.vue'
import SignupPage from '../pages/Auth/SignupPage.vue'
import AutomacaoPage from '../pages/Automacao/AutomacaoPage.vue'
import { AssinaturaPage } from '../pages/Assinatura'
import { supabase } from '../services/supabase'

const routes = [
  { path: '/', redirect: '/login' },
  { path: '/inicio', component: HomePage, meta: { requiresAuth: true } },
  { path: '/instancias', component: InstanciasPage, meta: { requiresAuth: true } },
  { path: '/mensagens', component: MensagensPage, meta: { requiresAuth: true } },
  { path: '/login', component: LoginPage },
  { path: '/signup', component: SignupPage },
  { path: '/automacao', component: AutomacaoPage, meta: { requiresAuth: true } },
  { path: '/assinatura', component: AssinaturaPage, meta: { requiresAuth: true } },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// Função para verificar se há uma sessão válida
async function checkAuthStatus() {
  try {
    // Primeiro, verificar se há dados de sessão no localStorage
    const storedSession = localStorage.getItem('dashboard-auth')
    if (storedSession) {
      const sessionData = JSON.parse(storedSession)
      if (sessionData && sessionData.access_token) {
        // Se há dados no localStorage, verificar com o Supabase
        const { data: { session }, error } = await supabase.auth.getSession()
        if (session && !error) {
          return { hasSession: true, session }
        }
      }
    }
    
    // Se não há dados no localStorage ou a sessão é inválida, verificar diretamente
    const { data: { session }, error } = await supabase.auth.getSession()
    return { hasSession: !!session, session, error }
  } catch (error) {
    console.error('Erro ao verificar status de autenticação:', error)
    return { hasSession: false, error }
  }
}

router.beforeEach(async (to, from, next) => {
  try {
    // Verificar se a rota requer autenticação
    const requiresAuth = to.matched.some(record => record.meta.requiresAuth);
    
    // Se não requer autenticação, permitir acesso
    if (!requiresAuth) {
      next();
      return;
    }
    
    // Verificar status de autenticação
    const { hasSession, session, error } = await checkAuthStatus();
    
    if (error) {
      console.error('Erro ao verificar sessão:', error);
      next('/login');
      return;
    }
    
    // Se requer autenticação mas não há sessão, redirecionar para login
    if (!hasSession) {
      console.log('Sem sessão, redirecionando para login');
      next('/login');
      return;
    }
    
    // Se há sessão e está tentando acessar login/signup manualmente, redirecionar para início
    if ((to.path === '/login' || to.path === '/signup') && hasSession && from.path !== '/') {
      next('/inicio');
      return;
    }
    
    // Permitir acesso
    console.log('Sessão válida, permitindo acesso para:', to.path);
    next();
    
  } catch (error) {
    console.error('Erro no guarda de rotas:', error);
    next('/login');
  }
});

supabase.auth.onAuthStateChange((event, session) => {
  console.log('Mudança de estado de autenticação:', event, session ? 'com sessão' : 'sem sessão');
  
  if (event === 'SIGNED_IN') {
    const currentPath = router.currentRoute.value.path;
    if (currentPath === '/login' || currentPath === '/signup' || currentPath === '/') {
      router.push('/inicio');
    }
    // Se estiver em qualquer outra rota, não faz nada
  }
});

export default router; 