
set search_path to thiago_sistemahospitalar_bd;
-- 1) Criar o ROLE de leitura (um "perfil" de permissões, sem login)
CREATE ROLE readonly PASSWORD 'Senhaboa123!';

-- 2) Conceder permissão de conectar ao banco específico
GRANT CONNECT ON DATABASE thiago_sistema_hospitalar_bd TO readonly;   -- troque "hospital" pelo nome do seu banco

-- 3) Conceder USAGE no schema (necessário para "enxergar" os objetos)
GRANT USAGE ON SCHEMA thiago_sitemahospitalar_bd TO readonly;         -- troque "public" se usar outro schema

-- 4) Conceder SELECT nas tabelas/views JÁ EXISTENTES no schema
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;

-- 7) Criar o usuário que efetivamente vai se conectar
CREATE ROLE professor WITH LOGIN PASSWORD 'Senhaboa456!';

-- 8) Atribuir o papel "readonly" ao usuário
GRANT readonly TO professor;

-- =====================================================================
-- TESTE DE CONEXÃO (via psql, trocando host/db pelos dados do seu projeto Neon)
-- =====================================================================
-- psql "postgresql://analista_relatorios:OutraSenhaForte456!@<endpoint>.neon.tech/hospital?sslmode=require&channel_binding=require"
--
-- SELECT * FROM vw_desempenho_medicos;   -- funciona
-- INSERT INTO pacientes (...) VALUES (...);   -- erro: permission denied

-- =====================================================================
-- REVOGAR ACESSO NO FUTURO, SE NECESSÁRIO
-- =====================================================================
-- REVOKE readonly FROM analista_relatorios;