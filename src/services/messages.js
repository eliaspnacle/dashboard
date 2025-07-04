import { supabase } from './supabase.js'

// Tipos de mensagem
export const MESSAGE_TYPES = {
  TEXT: 'text',
  IMAGE: 'image',
  FILE: 'file',
  AUDIO: 'audio'
}

// Serviço para gerenciar conversas
export const conversationService = {
  // Buscar todas as conversas do usuário para uma instância
  async getConversations(numero_instancia = null) {
    try {
      let query = supabase
        .from('vue_mensagens')
        .select('*')
        .order('data_criacao', { ascending: false });
      if (numero_instancia) {
        query = query.eq('numero_instancia', numero_instancia);
      }
      const { data, error } = await query;
      if (error) throw error;
      // Agrupar por numero_contato e pegar a última mensagem de cada
      const conversasMap = {};
      data.forEach(msg => {
        const key = msg.numero_contato;
        if (!conversasMap[key] || new Date(msg.data_criacao) > new Date(conversasMap[key].data_criacao)) {
          conversasMap[key] = msg;
        }
      });
      const conversas = Object.values(conversasMap);
      return conversas;
    } catch (error) {
      console.error('Erro ao buscar conversas:', error);
      return [];
    }
  },

  // Criar nova conversa (agora apenas gera um novo id_conversa)
  async createConversation(participantIds) {
    // A criação de conversa agora é feita ao enviar a primeira mensagem com um novo id_conversa
    throw new Error('A criação de conversa é feita ao enviar a primeira mensagem.');
  }
}

// Serviço para gerenciar mensagens
export const messageService = {
  // Buscar mensagens de uma conversa
  async getMessages(id_conversa, instance_id = null, limit = 50, offset = 0) {
    try {
      let query = supabase
        .from('vue_mensagens')
        .select('*')
        .eq('id_conversa', id_conversa)
        .order('data_criacao', { ascending: true })
        .range(offset, offset + limit - 1);
      if (instance_id) {
        query = query.eq('id_instancia', instance_id);
      }
      const { data, error } = await query;
      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Erro ao buscar mensagens:', error);
      return [];
    }
  },

  // Enviar mensagem
  async sendMessage(id_conversa, mensagem, direcao = 'saida', nome = '', nome_contato = '', id_instancia = null, numero_instancia = null, numero_contato = null) {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Usuário não autenticado');
      const { data, error } = await supabase
        .from('vue_mensagens')
        .insert({
          id_conversa,
          mensagem,
          status: 'send',
          nome_contato: nome_contato || '',
          data_hora: new Date().toISOString(),
          data_criacao: new Date().toISOString(),
          data_atualizacao: new Date().toISOString(),
          id_instancia,
          numero_instancia,
          numero_contato,
          user_id: user.id
        })
        .select('*')
        .single();
      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Erro ao enviar mensagem:', error);
      throw error;
    }
  },

  // Marcar mensagens como lidas (opcional, pode ser implementado depois)
  async markAsRead(id_conversa) {
    // Não implementado para vue_mensagens
  }
}

// Serviço para busca
export const searchService = {
  // Buscar conversas por nome do contato
  async searchConversations(query) {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Usuário não autenticado');

      const { data, error } = await supabase
        .from('vue_mensagens')
        .select('*')
        .eq('user_id', user.id)
        .ilike('nome_contato', `%${query}%`)
        .order('data_criacao', { ascending: false });

      if (error) throw error;
      // Agrupar por id_conversa
      const conversasMap = {};
      data.forEach(msg => {
        const key = msg.id_conversa;
        if (!conversasMap[key] || new Date(msg.data_criacao) > new Date(conversasMap[key].data_criacao)) {
          conversasMap[key] = msg;
        }
      });
      return Object.values(conversasMap);
    } catch (error) {
      console.error('Erro na busca:', error);
      return [];
    }
  },

  // Buscar mensagens por conteúdo
  async searchMessages(id_conversa, query) {
    try {
      const { data, error } = await supabase
        .from('vue_mensagens')
        .select('*')
        .eq('id_conversa', id_conversa)
        .ilike('mensagem', `%${query}%`)
        .order('data_criacao', { ascending: false });

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Erro na busca de mensagens:', error);
      return [];
    }
  }
} 