

GRANT CONNECT ON DATABASE thiago_sistema_hospitalar_bd TO readonly;

GRANT USAGE ON SCHEMA thiago_sistemahospitalar_bd TO readonly;

GRANT SELECT ON ALL TABLES IN SCHEMA thiago_sistemahospitalar_bd TO readonly;

ALTER DEFAULT PRIVILEGES IN SCHEMA thiago_sistemahospitalar_bd
    GRANT SELECT ON TABLES TO readonly;

GRANT SELECT ON ALL SEQUENCES IN SCHEMA thiago_sistemahospitalar_bd TO readonly;

ALTER DEFAULT PRIVILEGES IN SCHEMA thiago_sistemahospitalar_bd
    GRANT SELECT ON SEQUENCES TO readonly;

ALTER ROLE professor SET search_path TO thiago_sistemahospitalar_bd;

-- Connection string: postgresql://professor:Senhaboa456%21@ep-spring-waterfall-ac0qs29b-pooler.sa-east-1.aws.neon.tech/thiago_sistema_hospitalar_bd?sslmode=require&channel_binding=require