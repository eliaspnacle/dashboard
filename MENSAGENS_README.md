# Sistema de Mensagens - Configuração

Este documento explica como configurar e usar o sistema de mensagens implementado no projeto.

## 🚀 Funcionalidades Implementadas

### ✅ Funcionalidades Principais
- **Lista de Conversas**: Visualização de todas as conversas do usuário
- **Chat em Tempo Real**: Interface de chat com mensagens em tempo real
- **Busca de Conversas**: Pesquisa por nome de contato
- **Busca de Mensagens**: Pesquisa dentro de uma conversa específica
- **Envio de Mensagens**: Texto, imagens e arquivos
- **Notificações**: Alertas para novas mensagens
- **Status de Leitura**: Indicação de mensagens lidas/não lidas
- **Interface Responsiva**: Funciona em desktop e mobile

### ✅ Funcionalidades Avançadas
- **Criação de Conversas**: Modal para iniciar novas conversas
- **Upload de Arquivos**: Suporte para imagens e documentos
- **Menu de Opções**: Limpar conversa, bloquear contato
- **Auto-resize**: Campo de texto que se adapta ao conteúdo
- **Scroll Automático**: Para a última mensagem
- **Real-time Updates**: Atualizações em tempo real via Supabase

## 🗄️ Configuração do Banco de Dados

### 1. Execute o Schema SQL
1. Acesse o **SQL Editor** no seu projeto Supabase
2. Copie e cole o conteúdo do arquivo `database-schema.sql`
3. Execute o script completo

### 2. Verifique as Tabelas Criadas
- `users` - Perfis dos usuários
- `conversations` - Conversas/chat rooms
- `conversation_participants` - Participantes das conversas
- `messages` - Mensagens enviadas
- `message_reads` - Controle de leitura de mensagens

### 3. Políticas de Segurança (RLS)
O schema inclui políticas de segurança que garantem que:
- Usuários só veem conversas que participam
- Usuários só enviam mensagens em conversas que participam
- Dados são protegidos por autenticação

## 🔧 Configuração do Frontend

### 1. Variáveis de Ambiente
Certifique-se de que seu arquivo `.env` contém:
```env
VITE_SUPABASE_URL=sua_url_do_supabase
VITE_SUPABASE_ANON_KEY=sua_chave_anonima_do_supabase
```

### 2. Dependências
O projeto já inclui as dependências necessárias:
- `@supabase/supabase-js` - Cliente do Supabase
- `vue` - Framework principal
- `vue-router` - Roteamento

### 3. Estrutura de Arquivos
```
src/
├── pages/Mensagens/
│   ├── MensagensPage.vue      # Página principal
│   ├── ConversationList.vue   # Lista de conversas
│   ├── ChatWindow.vue         # Interface do chat
│   └── ChatPlaceholder.vue    # Placeholder quando nenhuma conversa selecionada
├── services/
│   ├── supabase.js           # Configuração do Supabase
│   └── messages.js           # Serviços de mensagens
└── database-schema.sql       # Schema do banco de dados
```

## 📱 Como Usar

### 1. Acessar a Página
Navegue para `/mensagens` no seu aplicativo

### 2. Lista de Conversas
- **Buscar**: Use a barra de pesquisa para encontrar conversas
- **Nova Conversa**: Clique no botão "+" para criar uma nova conversa
- **Selecionar**: Clique em uma conversa para abrir o chat

### 3. Chat
- **Enviar Mensagem**: Digite no campo de texto e pressione Enter
- **Anexar Arquivo**: Clique no ícone de clipe para enviar imagens ou documentos
- **Buscar Mensagens**: Use o ícone de lupa no cabeçalho do chat
- **Opções**: Clique nos três pontos para acessar menu de opções

### 4. Funcionalidades do Chat
- **Shift + Enter**: Nova linha
- **Enter**: Enviar mensagem
- **Clique na imagem**: Abrir em modal
- **Download**: Clique em "Baixar" para arquivos

## 🔄 Real-time Features

### 1. Atualizações em Tempo Real
O sistema usa Supabase Realtime para:
- Novas mensagens aparecem instantaneamente
- Status de leitura atualiza automaticamente
- Notificações para mensagens de outras conversas

### 2. Notificações
- Aparecem no canto superior direito
- Mostram avatar, nome e preview da mensagem
- Auto-dismiss após 5 segundos
- Clique para ir para a conversa

## 🎨 Personalização

### 1. Cores
As cores principais podem ser alteradas no CSS:
```css
--primary-color: #22c55e;  /* Verde principal */
--secondary-color: #16a34a; /* Verde escuro */
--background-color: #f0f2f5; /* Fundo do chat */
```

### 2. Layout
- **Desktop**: Layout horizontal (lista + chat lado a lado)
- **Mobile**: Layout vertical (lista em cima, chat embaixo)

### 3. Componentes
Cada componente pode ser personalizado independentemente:
- `ConversationList.vue` - Lista de conversas
- `ChatWindow.vue` - Interface do chat
- `ChatPlaceholder.vue` - Estado vazio

## 🐛 Troubleshooting

### 1. Mensagens não aparecem
- Verifique se o usuário está autenticado
- Confirme se as políticas RLS estão ativas
- Verifique os logs do console

### 2. Real-time não funciona
- Confirme se o Realtime está habilitado no Supabase
- Verifique se as variáveis de ambiente estão corretas
- Teste a conexão com o Supabase

### 3. Upload de arquivos não funciona
- Implemente o upload para Supabase Storage
- Configure as políticas de storage
- Verifique os limites de tamanho de arquivo

## 🔮 Próximas Melhorias

### Funcionalidades Planejadas
- [ ] Emojis e reações
- [ ] Mensagens de voz
- [ ] Conversas em grupo
- [ ] Status online/offline
- [ ] Mensagens editadas/deletadas
- [ ] Backup de conversas
- [ ] Temas escuro/claro
- [ ] Notificações push

### Otimizações
- [ ] Paginação de mensagens
- [ ] Cache local
- [ ] Compressão de imagens
- [ ] Lazy loading
- [ ] Service Worker para offline

## 📞 Suporte

Para dúvidas ou problemas:
1. Verifique os logs do console
2. Teste a conexão com o Supabase
3. Confirme se todas as tabelas foram criadas
4. Verifique as políticas de segurança

---

**Nota**: Este sistema está configurado para funcionar com Supabase. Certifique-se de que seu projeto Supabase está configurado corretamente antes de usar as funcionalidades. 