
DROP SCHEMA IF EXISTS Thiago_SitemaHospitalar_BD CASCADE;

CREATE SCHEMA Thiago_SitemaHospitalar_BD;

SET SEARCH_PATH TO Thiago_SitemaHospitalar_BD;

DROP TABLE IF EXISTS prescricao_itens CASCADE;
DROP TABLE IF EXISTS prescricoes CASCADE;
DROP TABLE IF EXISTS prontuarios CASCADE;
DROP TABLE IF EXISTS internacoes CASCADE;
DROP TABLE IF EXISTS consultas CASCADE;
DROP TABLE IF EXISTS quartos CASCADE;
DROP TABLE IF EXISTS medicos CASCADE;
DROP TABLE IF EXISTS pacientes CASCADE;
DROP TABLE IF EXISTS medicamentos CASCADE;
DROP TABLE IF EXISTS departamentos CASCADE;
DROP TABLE IF EXISTS especialidades CASCADE;
DROP TABLE IF EXISTS convenios CASCADE;

-- TABELAS DE APOIO


CREATE TABLE especialidades (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE convenios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    telefone VARCHAR(20)
);

CREATE TABLE departamentos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    localizacao VARCHAR(100)
);

CREATE TABLE medicamentos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    fabricante VARCHAR(150),
    tipo VARCHAR(50)
);

-- PESSOAS

CREATE TABLE medicos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    crm VARCHAR(20) NOT NULL UNIQUE,
    especialidade_id INTEGER NOT NULL REFERENCES especialidades(id),
    telefone VARCHAR(20),
    email VARCHAR(150),
    data_contratacao DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE pacientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    sexo CHAR(1) CHECK (sexo IN ('M','F','O')),
    telefone VARCHAR(20),
    email VARCHAR(150),
    endereco VARCHAR(200),
    convenio_id INTEGER REFERENCES convenios(id)
);

-- ESTRUTURA FÍSICA

CREATE TABLE quartos (
    id SERIAL PRIMARY KEY,
    numero VARCHAR(10) NOT NULL,
    tipo VARCHAR(30) NOT NULL CHECK (tipo IN ('Enfermaria','Apartamento','UTI')),
    capacidade INTEGER NOT NULL DEFAULT 1,
    departamento_id INTEGER NOT NULL REFERENCES departamentos(id),
    UNIQUE (numero, departamento_id)
);

-- ATENDIMENTO

CREATE TABLE consultas (
    id SERIAL PRIMARY KEY,
    paciente_id INTEGER NOT NULL REFERENCES pacientes(id),
    medico_id INTEGER NOT NULL REFERENCES medicos(id),
    data_hora TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Agendada'
               CHECK (status IN ('Agendada','Realizada','Cancelada')),
    motivo VARCHAR(200),
    valor NUMERIC(10,2)
);

CREATE TABLE prontuarios (
    id SERIAL PRIMARY KEY,
    paciente_id INTEGER NOT NULL REFERENCES pacientes(id),
    consulta_id INTEGER REFERENCES consultas(id),
    data_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    descricao TEXT,
    diagnostico VARCHAR(200)
);

CREATE TABLE internacoes (
    id SERIAL PRIMARY KEY,
    paciente_id INTEGER NOT NULL REFERENCES pacientes(id),
    quarto_id INTEGER NOT NULL REFERENCES quartos(id),
    medico_responsavel_id INTEGER NOT NULL REFERENCES medicos(id),
    data_entrada TIMESTAMP NOT NULL,
    data_saida TIMESTAMP,
    diagnostico VARCHAR(200),
    CHECK (data_saida IS NULL OR data_saida >= data_entrada)
);

CREATE TABLE prescricoes (
    id SERIAL PRIMARY KEY,
    consulta_id INTEGER REFERENCES consultas(id),
    medico_id  INTEGER NOT NULL REFERENCES medicos(id),
    paciente_id INTEGER NOT NULL REFERENCES pacientes(id),
    data_emissao DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE prescricao_itens (
    id SERIAL PRIMARY KEY,
    prescricao_id INTEGER NOT NULL REFERENCES prescricoes(id) ON DELETE CASCADE,
    medicamento_id INTEGER NOT NULL REFERENCES medicamentos(id),
    dosagem VARCHAR(50) NOT NULL,
    frequencia VARCHAR(50) NOT NULL,
    duracao_dias INTEGER
);
