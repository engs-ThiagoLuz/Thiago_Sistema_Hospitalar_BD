
set search_path to thiago_sistemahospitalar_bd;

CREATE ROLE readonly PASSWORD 'Senhaboa123!';

GRANT CONNECT ON DATABASE thiago_sistema_hospitalar_bd TO readonly;  

GRANT USAGE ON SCHEMA thiago_sitemahospitalar_bd TO readonly;       

GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;

CREATE ROLE professor WITH LOGIN PASSWORD 'Senhaboa456!';

GRANT readonly TO professor;
