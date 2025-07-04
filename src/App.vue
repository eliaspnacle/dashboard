<script setup>
import { onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from './services/supabase'

const route = useRoute()

onMounted(async () => {
  // Debug temporário para verificar a sessão
  const { data: { session } } = await supabase.auth.getSession()
  console.log('Sessão atual:', session ? 'Logado' : 'Não logado')
  console.log('Rota atual:', route.path)
})
</script>

<template>
  <router-view />
</template>

<style scoped>
header {
  line-height: 1.5;
}

.logo {
  display: block;
  margin: 0 auto 2rem;
}

@media (min-width: 1024px) {
  header {
    display: flex;
    place-items: center;
    padding-right: calc(var(--section-gap) / 2);
  }

  .logo {
    margin: 0 2rem 0 0;
  }

  header .wrapper {
    display: flex;
    place-items: flex-start;
    flex-wrap: wrap;
  }
}
</style>

<style>
body, html, #app {
  background: #F6F8FA !important;
}
</style>
