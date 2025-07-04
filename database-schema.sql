-- Schema do banco de dados para o sistema de mensagens
-- Execute este script no SQL Editor do Supabase

-- Habilitar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabela de usuários (se não existir)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de conversas
CREATE TABLE IF NOT EXISTS conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT, -- Para conversas em grupo
    created_by UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de participantes das conversas
CREATE TABLE IF NOT EXISTS conversation_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(conversation_id, user_id)
);

-- Tabela de mensagens
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    type TEXT DEFAULT 'text' CHECK (type IN ('text', 'image', 'file', 'audio')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de leitura de mensagens
CREATE TABLE IF NOT EXISTS message_reads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(conversation_id, user_id)
);

-- ============================================================================
-- NOVA TABELA SIMPLIFICADA PARA MENSAGENS COM NOME DO CONTATO COMO IDENTIFICADOR
-- ============================================================================

-- Tabela de mensagens simplificada usando nome do contato como identificador
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome TEXT NOT NULL, -- Nome de quem enviou a mensagem
    mensagem TEXT NOT NULL, -- Conteúdo da mensagem
    direcao TEXT NOT NULL CHECK (direcao IN ('entrada', 'saida')), -- Direção da mensagem (entrada/saída)
    data_hora TIMESTAMP WITH TIME ZONE DEFAULT NOW(), -- Data e hora da mensagem
    conversa_id TEXT NOT NULL, -- ID da conversa (pode ser o nome do contato ou um identificador único)
    nome_contato TEXT NOT NULL, -- Nome do contato que está enviando/recebendo mensagens
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_conversations_created_by ON conversations(created_by);
CREATE INDEX IF NOT EXISTS idx_conversations_updated_at ON conversations(updated_at);
CREATE INDEX IF NOT EXISTS idx_conversation_participants_conversation_id ON conversation_participants(conversation_id);
CREATE INDEX IF NOT EXISTS idx_conversation_participants_user_id ON conversation_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_message_reads_conversation_id ON message_reads(conversation_id);
CREATE INDEX IF NOT EXISTS idx_message_reads_user_id ON message_reads(user_id);

-- Índices para a nova tabela chat_messages
CREATE INDEX IF NOT EXISTS idx_chat_messages_conversa_id ON chat_messages(conversa_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_nome_contato ON chat_messages(nome_contato);
CREATE INDEX IF NOT EXISTS idx_chat_messages_data_hora ON chat_messages(data_hora);
CREATE INDEX IF NOT EXISTS idx_chat_messages_direcao ON chat_messages(direcao);

-- Função para atualizar o timestamp de updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para atualizar updated_at automaticamente
CREATE TRIGGER update_conversations_updated_at 
    BEFORE UPDATE ON conversations 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at 
    BEFORE UPDATE ON messages 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger para a nova tabela chat_messages
CREATE TRIGGER update_chat_messages_updated_at 
    BEFORE UPDATE ON chat_messages 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Função para buscar conversas de um usuário
CREATE OR REPLACE FUNCTION get_user_conversations(user_uuid UUID)
RETURNS TABLE (
    conversation_id UUID,
    conversation_name TEXT,
    last_message_content TEXT,
    last_message_created_at TIMESTAMP WITH TIME ZONE,
    unread_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id as conversation_id,
        c.name as conversation_name,
        m.content as last_message_content,
        m.created_at as last_message_created_at,
        COALESCE(unread.unread_count, 0) as unread_count
    FROM conversations c
    INNER JOIN conversation_participants cp ON c.id = cp.conversation_id
    LEFT JOIN LATERAL (
        SELECT content, created_at
        FROM messages 
        WHERE conversation_id = c.id 
        ORDER BY created_at DESC 
        LIMIT 1
    ) m ON true
    LEFT JOIN LATERAL (
        SELECT COUNT(*) as unread_count
        FROM messages msg
        WHERE msg.conversation_id = c.id 
        AND msg.created_at > COALESCE(mr.read_at, '1970-01-01'::timestamp)
        AND msg.sender_id != user_uuid
    ) unread ON true
    LEFT JOIN message_reads mr ON mr.conversation_id = c.id AND mr.user_id = user_uuid
    WHERE cp.user_id = user_uuid
    ORDER BY COALESCE(m.created_at, c.created_at) DESC;
END;
$$ LANGUAGE plpgsql;

-- Função para buscar conversas simplificadas por nome do contato
CREATE OR REPLACE FUNCTION get_chat_conversations()
RETURNS TABLE (
    nome_contato TEXT,
    ultima_mensagem TEXT,
    ultima_data_hora TIMESTAMP WITH TIME ZONE,
    total_mensagens BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cm.nome_contato,
        cm.mensagem as ultima_mensagem,
        cm.data_hora as ultima_data_hora,
        COUNT(*) OVER (PARTITION BY cm.nome_contato) as total_mensagens
    FROM chat_messages cm
    INNER JOIN (
        SELECT nome_contato, MAX(data_hora) as max_data_hora
        FROM chat_messages
        GROUP BY nome_contato
    ) latest ON cm.nome_contato = latest.nome_contato AND cm.data_hora = latest.max_data_hora
    ORDER BY cm.data_hora DESC;
END;
$$ LANGUAGE plpgsql;

-- Função para buscar mensagens de uma conversa específica
CREATE OR REPLACE FUNCTION get_chat_messages_by_contact(contact_name TEXT)
RETURNS TABLE (
    id UUID,
    nome TEXT,
    mensagem TEXT,
    direcao TEXT,
    data_hora TIMESTAMP WITH TIME ZONE,
    conversa_id TEXT,
    nome_contato TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cm.id,
        cm.nome,
        cm.mensagem,
        cm.direcao,
        cm.data_hora,
        cm.conversa_id,
        cm.nome_contato
    FROM chat_messages cm
    WHERE cm.nome_contato = contact_name
    ORDER BY cm.data_hora ASC;
END;
$$ LANGUAGE plpgsql;

-- Políticas de segurança RLS (Row Level Security)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_reads ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Políticas para usuários
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

-- Políticas para conversas
CREATE POLICY "Users can view conversations they participate in" ON conversations
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM conversation_participants 
            WHERE conversation_id = id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create conversations" ON conversations
    FOR INSERT WITH CHECK (auth.uid() = created_by);

-- Políticas para participantes
CREATE POLICY "Users can view conversation participants" ON conversation_participants
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM conversation_participants cp2
            WHERE cp2.conversation_id = conversation_id AND cp2.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can add themselves to conversations" ON conversation_participants
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Políticas para mensagens
CREATE POLICY "Users can view messages in their conversations" ON messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM conversation_participants 
            WHERE conversation_id = messages.conversation_id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can send messages to their conversations" ON messages
    FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- Políticas para leitura de mensagens
CREATE POLICY "Users can view message reads in their conversations" ON message_reads
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM conversation_participants 
            WHERE conversation_id = message_reads.conversation_id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can mark messages as read" ON message_reads
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own message reads" ON message_reads
    FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para chat_messages (permitir acesso total para usuários autenticados)
CREATE POLICY "Authenticated users can view all chat messages" ON chat_messages
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can insert chat messages" ON chat_messages
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update chat messages" ON chat_messages
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can delete chat messages" ON chat_messages
    FOR DELETE USING (auth.role() = 'authenticated');

-- Dados de exemplo (opcional)
-- INSERT INTO users (id, email, name, avatar_url) VALUES 
--     ('550e8400-e29b-41d4-a716-446655440000', 'usuario1@exemplo.com', 'João Silva', 'https://i.pravatar.cc/150?img=1'),
--     ('550e8400-e29b-41d4-a716-446655440001', 'usuario2@exemplo.com', 'Maria Santos', 'https://i.pravatar.cc/150?img=2'),
--     ('550e8400-e29b-41d4-a716-446655440002', 'usuario3@exemplo.com', 'Pedro Costa', 'https://i.pravatar.cc/150?img=3');

-- INSERT INTO conversations (id, name, created_by) VALUES 
--     ('660e8400-e29b-41d4-a716-446655440000', 'Conversa Geral', '550e8400-e29b-41d4-a716-446655440000');

-- INSERT INTO conversation_participants (conversation_id, user_id) VALUES 
--     ('660e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440000'),
--     ('660e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440001'),
--     ('660e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440002');

-- Dados de exemplo para a nova tabela chat_messages
-- INSERT INTO chat_messages (nome, mensagem, direcao, conversa_id, nome_contato) VALUES 
--     ('João Silva', 'Olá! Como você está?', 'entrada', 'joao_silva_001', 'João Silva'),
--     ('Você', 'Oi João! Tudo bem, e você?', 'saida', 'joao_silva_001', 'João Silva'),
--     ('João Silva', 'Tudo ótimo! Vamos conversar mais tarde?', 'entrada', 'joao_silva_001', 'João Silva'),
--     ('Maria Santos', 'Bom dia! Preciso de uma informação.', 'entrada', 'maria_santos_001', 'Maria Santos'),
--     ('Você', 'Bom dia Maria! Claro, como posso ajudar?', 'saida', 'maria_santos_001', 'Maria Santos'); 