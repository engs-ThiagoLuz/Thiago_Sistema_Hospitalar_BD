set search_path to thiago_sistemahospitalar_bd;
-- ÍNDICES

CREATE INDEX idx_Thiago_prescricao_itens_medicamento
    ON prescricao_itens (medicamento_id);

CREATE INDEX idx_Thiago_internacoes_ativas
    ON internacoes (quarto_id)
    WHERE data_saida IS NULL;


-- Relatório 1: Desempenho de médicos

CREATE OR REPLACE VIEW vw_Thiago_Desempenho_Medicos AS
SELECT
    m.id AS medico_id,
    m.nome AS medico,
    m.crm,
    esp.nome AS especialidade,
    COUNT(c.id) AS total_consultas,
    COUNT(c.id) FILTER (WHERE c.status = 'Realizada') AS consultas_realizadas,
    COUNT(c.id) FILTER (WHERE c.status = 'Cancelada') AS consultas_canceladas,
    COUNT(c.id) FILTER (WHERE c.status = 'Agendada') AS consultas_agendadas,
    COALESCE(SUM(c.valor) FILTER (WHERE c.status = 'Realizada'), 0)   AS faturamento_total,
    ROUND(COALESCE(AVG(c.valor) FILTER (WHERE c.status = 'Realizada'), 0), 2) AS ticket_medio,
    (
        SELECT COUNT(*)
        FROM internacoes i
        WHERE i.medico_responsavel_id = m.id
    ) AS total_internacoes_responsavel
FROM medicos m
JOIN especialidades esp ON esp.id = m.especialidade_id
LEFT JOIN consultas c ON c.medico_id = m.id
GROUP BY m.id, m.nome, m.crm, esp.nome
ORDER BY faturamento_total DESC;

-- Relatório 2: Histórico de pacientes

CREATE MATERIALIZED VIEW mv_Thiago_Historico_Pacientes AS
SELECT
    p.id AS paciente_id,
    p.nome AS paciente,
    p.cpf,
    DATE_PART('year', AGE(CURRENT_DATE, p.data_nascimento))::INT AS idade,
    cv.nome  AS convenio,
    COUNT(DISTINCT c.id) AS total_consultas,
    COUNT(DISTINCT c.id) FILTER (WHERE c.status = 'Realizada')   AS consultas_realizadas,
    COUNT(DISTINCT i.id) AS total_internacoes,
    COUNT(DISTINCT pr.id) AS total_prescricoes,
    (
        SELECT MAX(c2.data_hora)
        FROM consultas c2
        WHERE c2.paciente_id = p.id
    ) AS ultima_consulta,
    (
        SELECT pt.diagnostico
        FROM prontuarios pt
        WHERE pt.paciente_id = p.id
        ORDER BY pt.data_registro DESC
        LIMIT 1
    ) AS diagnostico_mais_recente
FROM pacientes p
LEFT JOIN convenios cv ON cv.id = p.convenio_id
LEFT JOIN consultas c ON c.paciente_id = p.id
LEFT JOIN internacoes i ON i.paciente_id = p.id
LEFT JOIN prescricoes pr ON pr.paciente_id = p.id
GROUP BY p.id, p.nome, p.cpf, p.data_nascimento, cv.nome
WITH DATA;

-- Relatório 3: Internações ativas
CREATE OR REPLACE VIEW vw_Thiago_Internacoes_Ativas AS
SELECT
    i.id AS internacao_id,
    p.id AS paciente_id,
    p.nome AS paciente,
    q.numero AS quarto,
    q.tipo AS tipo_quarto,
    dep.nome AS departamento,
    m.nome AS medico_responsavel,
    i.data_entrada,
    (CURRENT_DATE - i.data_entrada::date)   AS dias_internado,
    i.diagnostico
FROM internacoes i
JOIN pacientes p ON p.id = i.paciente_id
JOIN quartos q ON q.id = i.quarto_id
JOIN departamentos dep ON dep.id = q.departamento_id
JOIN medicos m ON m.id = i.medico_responsavel_id
WHERE i.data_saida IS NULL
ORDER BY dias_internado DESC;

-- Relatório 4: Ranking de vendas de medicamentos por prescrições

CREATE MATERIALIZED VIEW mv_Thiago_Ranking_Medicamentos AS
SELECT
    med.id AS medicamento_id,
    med.nome AS medicamento,
    med.tipo,
    med.fabricante,
    COUNT(pi.id) AS total_prescricoes_item,
    COUNT(DISTINCT pr.paciente_id) AS pacientes_distintos,
    COUNT(DISTINCT pr.medico_id) AS medicos_que_prescreveram,
    (
        SELECT COUNT(*)
        FROM prescricao_itens pi2
        WHERE pi2.medicamento_id = med.id
          AND pi2.duracao_dias >= 14
    ) AS prescricoes_longa_duracao
FROM medicamentos med
JOIN prescricao_itens pi ON pi.medicamento_id = med.id
JOIN prescricoes pr ON pr.id = pi.prescricao_id
GROUP BY med.id, med.nome, med.tipo, med.fabricante
ORDER BY total_prescricoes_item DESC
WITH DATA;

-- Relatório 5: Faturamento por convênio e especialidade

CREATE OR REPLACE VIEW vw_Thiago_Faturamento_Convenio_Especialidade AS
SELECT
    cv.nome AS convenio,
    esp.nome AS especialidade,
    COUNT(c.id) AS qtd_consultas,
    SUM(c.valor) AS faturamento,
    ROUND(AVG(c.valor), 2) AS ticket_medio,
    ROUND(
        100.0 * SUM(c.valor) /
        NULLIF((SELECT SUM(valor) FROM consultas WHERE status = 'Realizada'), 0)
    , 2) AS pct_faturamento_total
FROM consultas c
JOIN pacientes p ON p.id = c.paciente_id
JOIN convenios cv ON cv.id = p.convenio_id
JOIN medicos m ON m.id = c.medico_id
JOIN especialidades esp ON esp.id = m.especialidade_id
WHERE c.status = 'Realizada'
GROUP BY cv.nome, esp.nome
ORDER BY faturamento DESC;

