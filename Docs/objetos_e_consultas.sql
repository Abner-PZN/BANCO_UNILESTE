-- UNILESTE — parte 3 de 3: objetos pós-carga, SELECT/UPDATE/DELETE e consultas. Execute DEPOIS de 02_dados.sql.
USE unileste;

-- =====================================================================
-- 4.13 Objetos que dependem do estoque já carregado (criados DEPOIS da carga)
-- O saldo de lote (qt_lote) já reflete as entregas dos pedidos históricos; por isso a
-- trigger de estoque (RN03/RN10) e a procedure de entrega (RN11 FEFO) só valem daqui em diante.
-- =====================================================================
DELIMITER $$

-- RN03 e RN10: não se vende acima do estoque disponível em lotes NÃO vencidos
CREATE TRIGGER trg_pedido_produto_bi BEFORE INSERT ON pedido_produto FOR EACH ROW
BEGIN
  DECLARE v_disponivel INT;
  SELECT COALESCE(SUM(qt_lote), 0) INTO v_disponivel
    FROM lote
   WHERE id_produto = NEW.id_produto
     AND dt_validade >= CURDATE();
  IF NEW.qt_solicitada > v_disponivel THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN03/RN10: estoque valido insuficiente para o item';
  END IF;
END$$

-- RN07, RN10, RN11: entrega de um pedido liberado, baixando os lotes pelo FEFO
CREATE PROCEDURE sp_entregar_pedido(IN p_id_pedido INT)
BEGIN
  DECLARE v_status  VARCHAR(20);
  DECLARE v_n       INT;
  DECLARE v_k       INT DEFAULT 0;
  DECLARE v_produto INT;
  DECLARE v_restante INT;
  DECLARE v_lote    INT;
  DECLARE v_saldo   INT;
  DECLARE v_retira  INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
  SELECT st_pedido INTO v_status FROM pedido WHERE id_pedido = p_id_pedido FOR UPDATE;
  IF v_status IS NULL OR v_status <> 'liberado' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN07: so pedido liberado pode ser entregue';
  END IF;

  SET v_n = (SELECT COUNT(*) FROM pedido_produto WHERE id_pedido = p_id_pedido);
  WHILE v_k < v_n DO
    SELECT id_produto, qt_solicitada INTO v_produto, v_restante
      FROM pedido_produto WHERE id_pedido = p_id_pedido ORDER BY id_produto LIMIT v_k, 1;
    WHILE v_restante > 0 DO
      -- RN11 (FEFO): lote não vencido com a validade mais próxima
      SET v_lote = (SELECT id_lote FROM lote
                     WHERE id_produto = v_produto AND qt_lote > 0 AND dt_validade >= CURDATE()
                     ORDER BY dt_validade, id_lote LIMIT 1);
      IF v_lote IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN03/RN10: estoque valido insuficiente para a entrega';
      END IF;
      SELECT qt_lote INTO v_saldo FROM lote WHERE id_lote = v_lote FOR UPDATE;
      SET v_retira = LEAST(v_saldo, v_restante);
      UPDATE lote SET qt_lote = qt_lote - v_retira WHERE id_lote = v_lote;
      SET v_restante = v_restante - v_retira;
    END WHILE;
    SET v_k = v_k + 1;
  END WHILE;

  UPDATE pedido SET st_pedido = 'entregue' WHERE id_pedido = p_id_pedido;
  COMMIT;
END$$

DELIMITER ;

-- Testes das regras (descomente UMA linha por vez; cada uma deve falhar com a mensagem indicada):
-- INSERT INTO distribuidor (nm_distribuidor, nr_cnpj, ds_endereco) VALUES ('Teste', '11.111.111/0001-11', 'Rua X, 1');   -- RN02
-- INSERT INTO pedido_produto (id_pedido, id_produto, qt_solicitada, vl_preco_praticado) VALUES (1, 99, 5, 10.00);       -- RN03 (produto 99 sem estoque)
-- INSERT INTO nota_fiscal (nr_nf, dt_emissao, vl_nf, id_pedido) VALUES ('999999', '2026-11-03', 10.00, 1);              -- RN09 (pedido 1 já tem nota)
-- DELETE FROM distribuidor WHERE id_distribuidor = 1;                                                                    -- FK RESTRICT
-- DELETE FROM pedido WHERE id_pedido = 1;                                                                                -- RN26 (não se apaga pedido)
-- UPDATE pedido SET st_pedido = 'cancelado' WHERE id_pedido = 1;                                                        -- RN26 (pedido entregue)

-- =====================================================================
-- 5. SELECT com JOIN (consultas que cruzam várias tabelas)
-- =====================================================================

-- J01 — Últimos pedidos com o distribuidor que os realizou
SELECT p.id_pedido, p.dt_pedido, p.st_pedido, d.nm_distribuidor, d.nr_cnpj
FROM pedido p
JOIN distribuidor d ON d.id_distribuidor = p.id_distribuidor
ORDER BY p.dt_pedido DESC, p.id_pedido DESC
LIMIT 15;

-- J02 — Itens do último pedido, com produto, quantidade, preço praticado e subtotal
SELECT p.id_pedido, pr.nm_produto, pr.tp_produto, pp.qt_solicitada, pp.vl_preco_praticado,
       pp.qt_solicitada * pp.vl_preco_praticado AS vl_item
FROM pedido p
JOIN pedido_produto pp ON pp.id_pedido = p.id_pedido
JOIN produto pr        ON pr.id_produto = pp.id_produto
WHERE p.id_pedido = (SELECT id_pedido FROM pedido WHERE st_pedido <> 'cancelado'
                     ORDER BY dt_pedido DESC, id_pedido DESC LIMIT 1)
ORDER BY pr.nm_produto;

-- J03 — Pedidos da última semana com nota fiscal e pagamentos (LEFT JOIN: pedido pode não ter nota nem pagamento)
SELECT p.id_pedido, d.nm_distribuidor, p.st_pedido, nf.nr_nf, nf.vl_nf,
       COUNT(pg.id_pagamento) AS qt_pagamentos, COALESCE(SUM(pg.vl_pagamento), 0) AS vl_pago
FROM pedido p
JOIN distribuidor d        ON d.id_distribuidor = p.id_distribuidor
LEFT JOIN nota_fiscal nf   ON nf.id_pedido = p.id_pedido
LEFT JOIN pagamento pg     ON pg.id_pedido = p.id_pedido
WHERE p.dt_pedido >= '2026-10-26'
GROUP BY p.id_pedido, d.nm_distribuidor, p.st_pedido, nf.nr_nf, nf.vl_nf
ORDER BY p.id_pedido
LIMIT 20;

-- J04 — Rastro compra → fornecedor → lote → produto (dos lotes com validade mais próxima)
SELECT l.id_lote, f.nm_fornecedor, c.id_compra, c.dt_compra, pr.nm_produto, l.qt_lote, l.dt_validade
FROM lote l
JOIN compra c       ON c.id_compra = l.id_compra
JOIN fornecedor f   ON f.id_fornecedor = c.id_fornecedor
JOIN produto pr     ON pr.id_produto = l.id_produto
WHERE l.qt_lote > 0
ORDER BY l.dt_validade
LIMIT 15;

-- J05 — Produtos que nunca foram pedidos (LEFT JOIN + IS NULL)
SELECT pr.id_produto, pr.nm_produto, pr.tp_produto
FROM produto pr
LEFT JOIN pedido_produto pp ON pp.id_produto = pr.id_produto
WHERE pp.id_produto IS NULL
ORDER BY pr.id_produto;

-- J07 — Pedidos com o funcionário que registrou e a marca de cada item (P13)
SELECT p.id_pedido, p.dt_pedido, f.nm_funcionario, m.nm_marca, pr.nm_produto, pp.qt_solicitada
FROM pedido p
JOIN funcionario f     ON f.id_funcionario = p.id_funcionario
JOIN pedido_produto pp ON pp.id_pedido = p.id_pedido
JOIN produto pr        ON pr.id_produto = pp.id_produto
JOIN marca m           ON m.id_marca = pr.id_marca
WHERE p.dt_pedido >= '2026-11-01'
ORDER BY p.id_pedido, m.nm_marca
LIMIT 20;

-- J08 — Devoluções com nota, pedido, distribuidor, lote e fábrica de origem (P7, RN15)
SELECT dv.id_devolucao, dv.dt_devolucao, dv.tp_motivo, dv.st_devolucao, nf.nr_nf, d.nm_distribuidor,
       pr.nm_produto, l.id_lote, l.dt_validade, fo.nm_fornecedor
FROM devolucao dv
JOIN nota_fiscal nf ON nf.id_nf = dv.id_nf
JOIN pedido p       ON p.id_pedido = nf.id_pedido
JOIN distribuidor d ON d.id_distribuidor = p.id_distribuidor
JOIN lote l         ON l.id_lote = dv.id_lote
JOIN produto pr     ON pr.id_produto = l.id_produto
JOIN compra c       ON c.id_compra = l.id_compra
JOIN fornecedor fo  ON fo.id_fornecedor = c.id_fornecedor
ORDER BY dv.dt_devolucao DESC;

-- J06 — Fornecedores cadastrados que ainda não receberam compra
SELECT f.id_fornecedor, f.nm_fornecedor
FROM fornecedor f
LEFT JOIN compra c ON c.id_fornecedor = f.id_fornecedor
WHERE c.id_compra IS NULL;

-- =====================================================================
-- 6. UPDATE
-- =====================================================================

-- U01 — Reajuste de 5% na tabela de preços das colorações (P2). Pedidos já emitidos não mudam:
--       o preço fica gravado em pedido_produto.vl_preco_praticado (RN05).
UPDATE produto
   SET vl_preco = ROUND(vl_preco * 1.05, 2)
 WHERE tp_produto = 'Coloração';

-- U02 — Gerente financeiro autoriza o pedido 931 por acordo de pagamento futuro (RN07):
--       pendente → liberado.
UPDATE pedido
   SET st_pedido = 'liberado'
 WHERE id_pedido = 931
   AND st_pedido = 'pendente';

-- U03 — Entrega do pedido liberado 885: a procedure baixa os lotes pelo FEFO (RN11) e muda o
--       status para 'entregue'.
CALL sp_entregar_pedido(885);

-- U04 — O distribuidor desistiu do pedido 1007, ainda pendente: ele é CANCELADO, não apagado (RN26).
--       A trigger trg_pedido_bu impede cancelar pedido liberado ou entregue.
UPDATE pedido
   SET st_pedido = 'cancelado'
 WHERE id_pedido = 1007
   AND st_pedido = 'pendente';

-- U05 — Financeiro quita uma parcela vencida de compra que estava em aberto (P11, RN20)
UPDATE pagamento_compra
   SET dt_pagamento = '2026-11-03', tp_forma_pagamento = 'boleto'
 WHERE id_pagamento_compra = (SELECT id FROM (SELECT MIN(id_pagamento_compra) AS id FROM pagamento_compra
                                               WHERE dt_pagamento IS NULL AND dt_vencimento < '2026-11-03') x);

-- =====================================================================
-- 7. DELETE
-- =====================================================================

-- D01 — Remove fornecedor cadastrado por engano e sem nenhuma compra (a FK RESTRICT impediria se houvesse).
DELETE FROM fornecedor
 WHERE id_fornecedor = 9
   AND NOT EXISTS (SELECT 1 FROM compra c WHERE c.id_fornecedor = fornecedor.id_fornecedor);

-- D02 — Pagamento lançado em duplicidade: insere e remove (a nota fiscal NÃO pode ser apagada, RN23).
INSERT INTO pagamento (dt_pagamento, vl_pagamento, tp_forma_pagamento, id_pedido)
VALUES ('2026-11-03', 10.00, 'pix', 1);
DELETE FROM pagamento
 WHERE id_pedido = 1 AND dt_pagamento = '2026-11-03' AND vl_pagamento = 10.00 AND tp_forma_pagamento = 'pix';

-- =====================================================================
-- 8. CONSULTAS GERENCIAIS (G01 a G21) — respondem aos problemas PB1 a PB4, aos processos P7/P11/P13 e aos KPIs do README (seção 1.6)
-- Data de referência: a consulta usa @dt_ref. Para reproduzir a demonstração com os dados gerados
-- em 03/11/2026, troque a linha abaixo por:  SET @dt_ref = '2026-11-03';
-- =====================================================================
SET @dt_ref = CURDATE();

-- ---------- PB1 — Fichas de pagamento sem controle centralizado ----------

-- G01 — Quais pedidos liberados/entregues ainda têm saldo a receber, e de quanto?
-- Atende: PB1 (ficha de pagamento: o que foi pago, o que está em aberto e o que foi liberado por acordo)
WITH total_pedido AS (
  SELECT id_pedido, SUM(qt_solicitada * vl_preco_praticado) AS vl_total
  FROM pedido_produto GROUP BY id_pedido
),
pago_pedido AS (
  SELECT id_pedido, SUM(vl_pagamento) AS vl_pago
  FROM pagamento GROUP BY id_pedido
)
SELECT p.id_pedido, d.nm_distribuidor, p.dt_pedido, p.st_pedido,
       t.vl_total, COALESCE(g.vl_pago, 0) AS vl_pago,
       t.vl_total - COALESCE(g.vl_pago, 0) AS vl_em_aberto
FROM pedido p
JOIN distribuidor d     ON d.id_distribuidor = p.id_distribuidor
JOIN total_pedido t     ON t.id_pedido = p.id_pedido
LEFT JOIN pago_pedido g ON g.id_pedido = p.id_pedido
WHERE p.st_pedido IN ('liberado', 'entregue')
  AND ROUND(t.vl_total - COALESCE(g.vl_pago, 0), 2) > 0
ORDER BY vl_em_aberto DESC
LIMIT 20;

-- G02 — Qual o saldo em aberto de cada distribuidor e quanto ele representa do limite de crédito (R$ 1.000,00)?
-- Atende: PB1 · KPI: saldo em aberto por distribuidor (RN06)
WITH total_pedido AS (
  SELECT id_pedido, SUM(qt_solicitada * vl_preco_praticado) AS vl_total
  FROM pedido_produto GROUP BY id_pedido
),
pago_pedido AS (
  SELECT id_pedido, SUM(vl_pagamento) AS vl_pago
  FROM pagamento GROUP BY id_pedido
)
SELECT d.id_distribuidor, d.nm_distribuidor,
       COUNT(*) AS qt_pedidos_em_aberto,
       ROUND(SUM(t.vl_total - COALESCE(g.vl_pago, 0)), 2) AS vl_em_aberto,
       1000.00 AS vl_limite_credito,
       ROUND(SUM(t.vl_total - COALESCE(g.vl_pago, 0)) / 1000.00 * 100, 1) AS pct_do_limite
FROM pedido p
JOIN distribuidor d     ON d.id_distribuidor = p.id_distribuidor
JOIN total_pedido t     ON t.id_pedido = p.id_pedido
LEFT JOIN pago_pedido g ON g.id_pedido = p.id_pedido
WHERE p.st_pedido IN ('liberado', 'entregue')
  AND ROUND(t.vl_total - COALESCE(g.vl_pago, 0), 2) > 0
GROUP BY d.id_distribuidor, d.nm_distribuidor
ORDER BY vl_em_aberto DESC
LIMIT 15;

-- G03 — Quais distribuidores têm saldo vencido (pedidos de meses anteriores ao mês atual ainda em aberto)?
-- Atende: PB1 · KPI: valor em atraso por distribuidor (prazo de pagamento até o fechamento do mês, RN06)
WITH total_pedido AS (
  SELECT id_pedido, SUM(qt_solicitada * vl_preco_praticado) AS vl_total
  FROM pedido_produto GROUP BY id_pedido
),
pago_pedido AS (
  SELECT id_pedido, SUM(vl_pagamento) AS vl_pago
  FROM pagamento GROUP BY id_pedido
)
SELECT d.id_distribuidor, d.nm_distribuidor,
       COUNT(*) AS qt_pedidos_vencidos,
       ROUND(SUM(t.vl_total - COALESCE(g.vl_pago, 0)), 2) AS vl_vencido,
       MIN(p.dt_pedido) AS dt_pedido_mais_antigo
FROM pedido p
JOIN distribuidor d     ON d.id_distribuidor = p.id_distribuidor
JOIN total_pedido t     ON t.id_pedido = p.id_pedido
LEFT JOIN pago_pedido g ON g.id_pedido = p.id_pedido
WHERE p.st_pedido IN ('liberado', 'entregue')
  AND ROUND(t.vl_total - COALESCE(g.vl_pago, 0), 2) > 0
  AND DATE_FORMAT(p.dt_pedido, '%Y-%m') < DATE_FORMAT(@dt_ref, '%Y-%m')
GROUP BY d.id_distribuidor, d.nm_distribuidor
ORDER BY vl_vencido DESC
LIMIT 20;

-- ---------- PB2 — Estoque sem controle de validade ----------

-- G04 — Quais lotes estão vencidos e ainda têm saldo (devem ficar bloqueados para venda)?
-- Atende: PB2 (risco de manter produto vencido) · RN10
SELECT l.id_lote, pr.nm_produto, l.dt_validade, DATEDIFF(@dt_ref, l.dt_validade) AS dias_vencido,
       l.qt_lote, ROUND(l.qt_lote * pr.vl_preco, 2) AS vl_imobilizado_a_preco_de_venda
FROM lote l
JOIN produto pr ON pr.id_produto = l.id_produto
WHERE l.dt_validade < @dt_ref AND l.qt_lote > 0
ORDER BY l.dt_validade;

-- G05 — Relatório de validade: lotes com saldo que vencem nos próximos 90 dias (crítico = menos de 30 dias)
-- Atende: PB2 · RF de relatório de validade · RN13
SELECT l.id_lote, pr.nm_produto, l.dt_validade, DATEDIFF(l.dt_validade, @dt_ref) AS dias_para_vencer, l.qt_lote,
       CASE WHEN l.dt_validade < DATE_ADD(@dt_ref, INTERVAL 30 DAY)
            THEN 'CRITICA (menos de 30 dias)' ELSE 'ATENCAO (30 a 90 dias)' END AS faixa
FROM lote l
JOIN produto pr ON pr.id_produto = l.id_produto
WHERE l.qt_lote > 0
  AND l.dt_validade >= @dt_ref
  AND l.dt_validade <= DATE_ADD(@dt_ref, INTERVAL 90 DAY)
ORDER BY l.dt_validade;

-- ---------- PB3 — Falta de aviso de estoque baixo ----------

-- G06 — Quais produtos estão com estoque válido igual ou abaixo do mínimo (lista de reposição)?
-- Atende: PB3 · KPI: produtos abaixo do estoque mínimo (RN12)
SELECT p.id_produto, p.nm_produto, p.tp_produto, p.qt_estoque_minimo,
       COALESCE(SUM(CASE WHEN l.dt_validade >= @dt_ref THEN l.qt_lote END), 0) AS qt_disponivel,
       p.qt_estoque_minimo - COALESCE(SUM(CASE WHEN l.dt_validade >= @dt_ref THEN l.qt_lote END), 0) AS qt_faltante
FROM produto p
LEFT JOIN lote l ON l.id_produto = p.id_produto
GROUP BY p.id_produto, p.nm_produto, p.tp_produto, p.qt_estoque_minimo
HAVING COALESCE(SUM(CASE WHEN l.dt_validade >= @dt_ref THEN l.qt_lote END), 0) <= p.qt_estoque_minimo
ORDER BY qt_faltante DESC;

-- ---------- PB4 — Rastreabilidade fraca entre compra, lote e venda ----------

-- G07 — Para um produto, qual o caminho fornecedor → compra → lote e quanto dele já foi entregue desde cada compra?
-- Atende: PB4 (troque o id_produto = 1 para rastrear outro produto)
-- Limite assumido do modelo: a venda é ligada ao PRODUTO, não ao lote (ver README, seção 1.5).
SELECT f.nm_fornecedor, c.id_compra, c.dt_compra, l.id_lote, pr.nm_produto, l.dt_validade,
       l.qt_lote AS qt_saldo_do_lote,
       (SELECT COALESCE(SUM(pp.qt_solicitada), 0)
          FROM pedido_produto pp
          JOIN pedido pd ON pd.id_pedido = pp.id_pedido
         WHERE pp.id_produto = l.id_produto
           AND pd.st_pedido = 'entregue'
           AND pd.dt_pedido >= c.dt_compra) AS qt_entregue_do_produto_desde_a_compra
FROM lote l
JOIN compra c     ON c.id_compra = l.id_compra
JOIN fornecedor f ON f.id_fornecedor = c.id_fornecedor
JOIN produto pr   ON pr.id_produto = l.id_produto
WHERE l.id_produto = 1
ORDER BY c.dt_compra, l.id_lote;

-- ---------- KPIs de gestão ----------

-- G08 — Qual o faturamento (soma das notas fiscais) por mês?
-- Atende: KPI faturamento mensal (RN09)
SELECT DATE_FORMAT(dt_emissao, '%Y-%m') AS mes, COUNT(*) AS qt_notas, ROUND(SUM(vl_nf), 2) AS vl_faturado
FROM nota_fiscal
GROUP BY mes
ORDER BY mes;

-- G09 — Qual o ticket médio (valor médio por pedido) e o número de pedidos por mês?
-- Atende: KPI ticket médio por mês
WITH total_pedido AS (
  SELECT id_pedido, SUM(qt_solicitada * vl_preco_praticado) AS vl_total
  FROM pedido_produto GROUP BY id_pedido
)
SELECT DATE_FORMAT(p.dt_pedido, '%Y-%m') AS mes, COUNT(*) AS qt_pedidos,
       ROUND(SUM(t.vl_total), 2) AS vl_total_pedidos, ROUND(AVG(t.vl_total), 2) AS ticket_medio
FROM pedido p
JOIN total_pedido t ON t.id_pedido = p.id_pedido
WHERE p.st_pedido <> 'cancelado'
GROUP BY mes
ORDER BY mes;

-- G10 — Quais os 10 produtos mais vendidos em quantidade e quanto renderam?
-- Atende: KPI ranking de produtos (apoia reposição de PB3)
SELECT pr.id_produto, pr.nm_produto, pr.tp_produto,
       SUM(pp.qt_solicitada) AS qt_vendida,
       ROUND(SUM(pp.qt_solicitada * pp.vl_preco_praticado), 2) AS receita
FROM pedido_produto pp
JOIN pedido p   ON p.id_pedido = pp.id_pedido
JOIN produto pr ON pr.id_produto = pp.id_produto
WHERE p.st_pedido IN ('liberado', 'entregue')
GROUP BY pr.id_produto, pr.nm_produto, pr.tp_produto
ORDER BY qt_vendida DESC
LIMIT 10;

-- G11 — Quanto cada tipo de produto representa da receita?
-- Atende: KPI participação por tipo de produto
SELECT pr.tp_produto,
       SUM(pp.qt_solicitada) AS qt_vendida,
       ROUND(SUM(pp.qt_solicitada * pp.vl_preco_praticado), 2) AS receita,
       ROUND(100 * SUM(pp.qt_solicitada * pp.vl_preco_praticado)
                 / SUM(SUM(pp.qt_solicitada * pp.vl_preco_praticado)) OVER (), 1) AS pct_da_receita
FROM pedido_produto pp
JOIN pedido p   ON p.id_pedido = pp.id_pedido
JOIN produto pr ON pr.id_produto = pp.id_produto
WHERE p.st_pedido IN ('liberado', 'entregue')
GROUP BY pr.tp_produto
ORDER BY receita DESC;

-- G12 — Quais distribuidores concentram a receita (curva ABC dos 15 maiores)?
-- Atende: KPI concentração de receita por distribuidor
WITH total_pedido AS (
  SELECT id_pedido, SUM(qt_solicitada * vl_preco_praticado) AS vl_total
  FROM pedido_produto GROUP BY id_pedido
),
rec AS (
  SELECT d.id_distribuidor, d.nm_distribuidor, SUM(t.vl_total) AS receita
  FROM pedido p
  JOIN distribuidor d ON d.id_distribuidor = p.id_distribuidor
  JOIN total_pedido t ON t.id_pedido = p.id_pedido
  WHERE p.st_pedido IN ('liberado', 'entregue')
  GROUP BY d.id_distribuidor, d.nm_distribuidor
)
SELECT id_distribuidor, nm_distribuidor, ROUND(receita, 2) AS receita,
       ROUND(100 * receita / SUM(receita) OVER (), 1) AS pct_da_receita,
       ROUND(100 * SUM(receita) OVER (ORDER BY receita DESC) / SUM(receita) OVER (), 1) AS pct_acumulado
FROM rec
ORDER BY receita DESC
LIMIT 15;

-- G13 — Quanto foi comprado de cada fábrica por mês?
-- Atende: KPI volume de compras por fornecedor (cerca de 50 compras por mês)
SELECT DATE_FORMAT(c.dt_compra, '%Y-%m') AS mes, f.nm_fornecedor,
       COUNT(*) AS qt_compras, ROUND(SUM(c.vl_compra), 2) AS vl_comprado
FROM compra c
JOIN fornecedor f ON f.id_fornecedor = c.id_fornecedor
GROUP BY mes, f.id_fornecedor, f.nm_fornecedor
ORDER BY mes, vl_comprado DESC;

-- G14 — Que percentual do vendido em cada mês ainda está em aberto (inadimplência)?
-- Atende: PB1 · KPI % do vendido em aberto, por mês do pedido
WITH total_pedido AS (
  SELECT id_pedido, SUM(qt_solicitada * vl_preco_praticado) AS vl_total
  FROM pedido_produto GROUP BY id_pedido
),
pago_pedido AS (
  SELECT id_pedido, SUM(vl_pagamento) AS vl_pago
  FROM pagamento GROUP BY id_pedido
)
SELECT DATE_FORMAT(p.dt_pedido, '%Y-%m') AS mes,
       ROUND(SUM(t.vl_total), 2) AS vl_vendido,
       ROUND(SUM(COALESCE(g.vl_pago, 0)), 2) AS vl_recebido,
       ROUND(SUM(t.vl_total) - SUM(COALESCE(g.vl_pago, 0)), 2) AS vl_em_aberto,
       ROUND(100 * (SUM(t.vl_total) - SUM(COALESCE(g.vl_pago, 0))) / SUM(t.vl_total), 1) AS pct_em_aberto
FROM pedido p
JOIN total_pedido t     ON t.id_pedido = p.id_pedido
LEFT JOIN pago_pedido g ON g.id_pedido = p.id_pedido
WHERE p.st_pedido IN ('liberado', 'entregue')
GROUP BY mes
ORDER BY mes;

-- G15 — Quantos dias, em média, o distribuidor leva para quitar o pedido (prazo médio de recebimento)?
-- Atende: PB1 · KPI prazo médio de recebimento (pedidos totalmente quitados), por mês
WITH total_pedido AS (
  SELECT id_pedido, SUM(qt_solicitada * vl_preco_praticado) AS vl_total
  FROM pedido_produto GROUP BY id_pedido
),
pago_pedido AS (
  SELECT id_pedido, SUM(vl_pagamento) AS vl_pago
  FROM pagamento GROUP BY id_pedido
)
SELECT DATE_FORMAT(p.dt_pedido, '%Y-%m') AS mes, COUNT(*) AS qt_pedidos_quitados,
       ROUND(AVG(DATEDIFF(q.dt_ultimo_pgto, p.dt_pedido)), 1) AS prazo_medio_dias
FROM pedido p
JOIN total_pedido t ON t.id_pedido = p.id_pedido
JOIN (SELECT id_pedido, MAX(dt_pagamento) AS dt_ultimo_pgto, SUM(vl_pagamento) AS vl_pago
        FROM pagamento GROUP BY id_pedido) q ON q.id_pedido = p.id_pedido
WHERE ROUND(q.vl_pago - t.vl_total, 2) >= 0
GROUP BY mes
ORDER BY mes;

-- G16 — Quantos pedidos e quanto em valor há em cada situação (funil: pendente → liberado → entregue, e cancelados)?
-- Atende: PB1 · acompanhamento do status do pedido
WITH total_pedido AS (
  SELECT id_pedido, SUM(qt_solicitada * vl_preco_praticado) AS vl_total
  FROM pedido_produto GROUP BY id_pedido
)
SELECT p.st_pedido, COUNT(*) AS qt_pedidos, ROUND(SUM(t.vl_total), 2) AS vl_total
FROM pedido p
JOIN total_pedido t ON t.id_pedido = p.id_pedido
GROUP BY p.st_pedido
ORDER BY qt_pedidos DESC;


-- ---------- Processos P7, P11 e P13 e KPIs complementares ----------

-- G17 — Quanto cada marca vendeu por mês (quantidade e receita)?
-- Atende: P13 · KPI receita por marca por mês
SELECT DATE_FORMAT(p.dt_pedido, '%Y-%m') AS mes, m.nm_marca,
       SUM(pp.qt_solicitada) AS qt_vendida,
       ROUND(SUM(pp.qt_solicitada * pp.vl_preco_praticado), 2) AS receita
FROM pedido p
JOIN pedido_produto pp ON pp.id_pedido = p.id_pedido
JOIN produto pr        ON pr.id_produto = pp.id_produto
JOIN marca m           ON m.id_marca = pr.id_marca
WHERE p.st_pedido IN ('liberado', 'entregue')
GROUP BY mes, m.id_marca, m.nm_marca
ORDER BY mes, receita DESC;

-- G18 — Quantos pedidos e quanto em vendas cada funcionário registrou por mês?
-- Atende: P13 · KPI vendas e ticket médio por funcionário
WITH total_pedido AS (
  SELECT id_pedido, SUM(qt_solicitada * vl_preco_praticado) AS vl_total
  FROM pedido_produto GROUP BY id_pedido
)
SELECT DATE_FORMAT(p.dt_pedido, '%Y-%m') AS mes, f.nm_funcionario, f.ds_cargo,
       COUNT(*) AS qt_pedidos, ROUND(SUM(t.vl_total), 2) AS vl_vendido, ROUND(AVG(t.vl_total), 2) AS ticket_medio
FROM pedido p
JOIN funcionario f  ON f.id_funcionario = p.id_funcionario
JOIN total_pedido t ON t.id_pedido = p.id_pedido
WHERE p.st_pedido IN ('liberado', 'entregue')
GROUP BY mes, f.id_funcionario, f.nm_funcionario, f.ds_cargo
ORDER BY mes, vl_vendido DESC;

-- G19 — Quais parcelas das compras estão vencidas em aberto ou vencem nos próximos 30 dias?
-- Atende: P11 (contas a pagar às fábricas) · RN20 · KPI valor a pagar por fornecedor
SELECT CASE WHEN pc.dt_vencimento < @dt_ref THEN 'VENCIDA' ELSE 'A VENCER (30 dias)' END AS situacao,
       fo.nm_fornecedor, c.id_compra, c.dt_compra, pc.dt_vencimento, pc.vl_parcela,
       DATEDIFF(pc.dt_vencimento, @dt_ref) AS dias_para_vencer
FROM pagamento_compra pc
JOIN compra c      ON c.id_compra = pc.id_compra
JOIN fornecedor fo ON fo.id_fornecedor = c.id_fornecedor
WHERE pc.dt_pagamento IS NULL
  AND pc.dt_vencimento <= DATE_ADD(@dt_ref, INTERVAL 30 DAY)
ORDER BY pc.dt_vencimento;

-- G20 — Quantas devoluções houve por motivo e por fábrica de origem do lote, e qual a taxa sobre o vendido?
-- Atende: P7 · RN14, RN15 · KPI taxa de devolução (itens devolvidos / itens entregues)
SELECT fo.nm_fornecedor, dv.tp_motivo,
       COUNT(*) AS qt_devolucoes, SUM(dv.qt_devolvida) AS qt_itens_devolvidos,
       SUM(CASE WHEN dv.st_devolucao = 'aceita' THEN 1 ELSE 0 END) AS qt_aceitas,
       ROUND(100 * SUM(dv.qt_devolvida) /
             (SELECT SUM(pp.qt_solicitada) FROM pedido_produto pp
                JOIN pedido p ON p.id_pedido = pp.id_pedido WHERE p.st_pedido = 'entregue'), 3) AS pct_dos_itens_entregues
FROM devolucao dv
JOIN lote l        ON l.id_lote = dv.id_lote
JOIN compra c      ON c.id_compra = l.id_compra
JOIN fornecedor fo ON fo.id_fornecedor = c.id_fornecedor
GROUP BY fo.nm_fornecedor, dv.tp_motivo
ORDER BY qt_devolucoes DESC;

-- G21 — Qual a taxa de cancelamento de pedidos por mês?
-- Atende: KPI taxa de cancelamento (pedidos cancelados / pedidos registrados) · RN26
SELECT DATE_FORMAT(dt_pedido, '%Y-%m') AS mes,
       COUNT(*) AS qt_pedidos,
       SUM(CASE WHEN st_pedido = 'cancelado' THEN 1 ELSE 0 END) AS qt_cancelados,
       ROUND(100 * SUM(CASE WHEN st_pedido = 'cancelado' THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_cancelamento
FROM pedido
GROUP BY mes
ORDER BY mes;

-- =====================================================================
-- 9. CONSULTAS DE AUDITORIA (A01 a A21) — conferem regras de negócio e a integridade dos dados
-- Resultado vazio = nenhuma violação (esperado), exceto onde o comentário indicar o contrário.
-- =====================================================================

-- A01 — Existe pedido registrado sem nenhum item?
-- Verifica: cardinalidade (1,n) Pedido–Produto (processo P3: pedido sem item não existe)
SELECT p.id_pedido, p.dt_pedido
FROM pedido p
LEFT JOIN pedido_produto pp ON pp.id_pedido = p.id_pedido
WHERE pp.id_pedido IS NULL;

-- A02 — Existe compra sem nenhum lote recebido?
-- Verifica: RN19 e cardinalidade (1,n) Compra–Lote (a compra só se conclui com lote conferido)
SELECT c.id_compra, c.dt_compra, c.id_fornecedor
FROM compra c
LEFT JOIN lote l ON l.id_compra = c.id_compra
WHERE l.id_lote IS NULL;

-- A03 — Existe nota fiscal com valor diferente do total do pedido?
-- Verifica: RN09 (o valor da nota é igual ao total do pedido)
WITH total_pedido AS (
  SELECT id_pedido, SUM(qt_solicitada * vl_preco_praticado) AS vl_total
  FROM pedido_produto GROUP BY id_pedido
)
SELECT nf.id_nf, nf.nr_nf, nf.vl_nf, t.vl_total
FROM nota_fiscal nf
JOIN total_pedido t ON t.id_pedido = nf.id_pedido
WHERE ROUND(nf.vl_nf - t.vl_total, 2) <> 0;

-- A04 — Existe pedido liberado ou entregue sem nota fiscal?
-- Verifica: RN09 e processo P4 (a nota é emitida antes da liberação e acompanha a entrega)
SELECT p.id_pedido, p.dt_pedido, p.st_pedido
FROM pedido p
LEFT JOIN nota_fiscal nf ON nf.id_pedido = p.id_pedido
WHERE p.st_pedido IN ('liberado', 'entregue') AND nf.id_nf IS NULL;

-- A05 — Quais pedidos liberados/entregues não têm nenhum pagamento (liberados só por acordo)?
-- Verifica: RN07 (liberação mediante pagamento OU acordo formal). Aqui são esperadas linhas: cada uma exige acordo do gerente financeiro.
SELECT p.id_pedido, p.dt_pedido, p.st_pedido, d.nm_distribuidor
FROM pedido p
JOIN distribuidor d ON d.id_distribuidor = p.id_distribuidor
LEFT JOIN pagamento pg ON pg.id_pedido = p.id_pedido
WHERE p.st_pedido IN ('liberado', 'entregue') AND pg.id_pagamento IS NULL
ORDER BY p.dt_pedido
LIMIT 25;

-- A06 — Existe pedido com pagamentos somando mais que o total?
-- Verifica: RN07 / consistência da ficha de pagamento (pagamento a maior)
WITH total_pedido AS (
  SELECT id_pedido, SUM(qt_solicitada * vl_preco_praticado) AS vl_total
  FROM pedido_produto GROUP BY id_pedido
),
pago_pedido AS (
  SELECT id_pedido, SUM(vl_pagamento) AS vl_pago
  FROM pagamento GROUP BY id_pedido
)
SELECT t.id_pedido, t.vl_total, g.vl_pago
FROM total_pedido t
JOIN pago_pedido g ON g.id_pedido = t.id_pedido
WHERE ROUND(g.vl_pago - t.vl_total, 2) > 0;

-- A07 — Existe lote com validade anterior à data da compra que o originou?
-- Verifica: RN19 (rastreabilidade e validade coerente) — regra do dicionário de dados
SELECT l.id_lote, l.id_compra, c.dt_compra, l.dt_validade
FROM lote l
JOIN compra c ON c.id_compra = l.id_compra
WHERE l.dt_validade < c.dt_compra;

-- A08 — Existe pedido pendente ou liberado com item acima do estoque válido atual?
-- Verifica: RN03 e RN10 (não se vende acima do estoque válido nem de lote vencido)
SELECT p.id_pedido, p.st_pedido, pp.id_produto, pp.qt_solicitada, COALESCE(e.qt_valida, 0) AS qt_valida
FROM pedido p
JOIN pedido_produto pp ON pp.id_pedido = p.id_pedido
LEFT JOIN (SELECT id_produto, SUM(qt_lote) AS qt_valida
             FROM lote WHERE dt_validade >= @dt_ref GROUP BY id_produto) e ON e.id_produto = pp.id_produto
WHERE p.st_pedido IN ('pendente', 'liberado')
  AND pp.qt_solicitada > COALESCE(e.qt_valida, 0)
ORDER BY p.id_pedido;

-- A09 — Existe distribuidor ou fornecedor com CNPJ inválido (dígitos verificadores)?
-- Verifica: RN02
SELECT 'distribuidor' AS origem, id_distribuidor AS id, nr_cnpj FROM distribuidor WHERE fn_cnpj_valido(nr_cnpj) = 0
UNION ALL
SELECT 'fornecedor', id_fornecedor, nr_cnpj FROM fornecedor WHERE fn_cnpj_valido(nr_cnpj) = 0;

-- A10 — Existe CNPJ repetido entre os distribuidores ou entre os fornecedores?
-- Verifica: RN02 (CNPJ único)
SELECT 'distribuidor' AS origem, nr_cnpj, COUNT(*) AS qt FROM distribuidor GROUP BY nr_cnpj HAVING COUNT(*) > 1
UNION ALL
SELECT 'fornecedor', nr_cnpj, COUNT(*) FROM fornecedor GROUP BY nr_cnpj HAVING COUNT(*) > 1;

-- A11 — Existe distribuidor cadastrado que nunca fez pedido?
-- Verifica: RN01 e cardinalidade (1,n) Distribuidor–Pedido (o distribuidor é registrado no atendimento do primeiro pedido)
SELECT d.id_distribuidor, d.nm_distribuidor
FROM distribuidor d
LEFT JOIN pedido p ON p.id_distribuidor = d.id_distribuidor
WHERE p.id_pedido IS NULL;

-- A12 — Existe pedido com total abaixo do pedido mínimo de R$ 50,00?
-- Verifica: RN04 (exceções só com autorização do gerente — se aparecer linha, conferir a autorização)
WITH total_pedido AS (
  SELECT id_pedido, SUM(qt_solicitada * vl_preco_praticado) AS vl_total
  FROM pedido_produto GROUP BY id_pedido
)
SELECT p.id_pedido, p.dt_pedido, t.vl_total
FROM pedido p
JOIN total_pedido t ON t.id_pedido = p.id_pedido
WHERE t.vl_total < 50.00;

-- A13 — Quais distribuidores estão com saldo em aberto acima do limite de crédito de R$ 1.000,00?
-- Verifica: RN06 (acima do limite, só com autorização do gerente financeiro). Linhas esperadas: conferir a autorização.
WITH total_pedido AS (
  SELECT id_pedido, SUM(qt_solicitada * vl_preco_praticado) AS vl_total
  FROM pedido_produto GROUP BY id_pedido
),
pago_pedido AS (
  SELECT id_pedido, SUM(vl_pagamento) AS vl_pago
  FROM pagamento GROUP BY id_pedido
)
SELECT d.id_distribuidor, d.nm_distribuidor,
       ROUND(SUM(t.vl_total - COALESCE(g.vl_pago, 0)), 2) AS vl_em_aberto
FROM pedido p
JOIN distribuidor d     ON d.id_distribuidor = p.id_distribuidor
JOIN total_pedido t     ON t.id_pedido = p.id_pedido
LEFT JOIN pago_pedido g ON g.id_pedido = p.id_pedido
WHERE p.st_pedido IN ('liberado', 'entregue')
GROUP BY d.id_distribuidor, d.nm_distribuidor
HAVING SUM(t.vl_total - COALESCE(g.vl_pago, 0)) > 1000.00
ORDER BY vl_em_aberto DESC;

-- A14 — Existe nota fiscal emitida antes da data do pedido?
-- Verifica: RN08 e processo P4 (a nota só é emitida depois do registro do pedido)
SELECT nf.id_nf, nf.nr_nf, nf.dt_emissao, p.id_pedido, p.dt_pedido
FROM nota_fiscal nf
JOIN pedido p ON p.id_pedido = nf.id_pedido
WHERE nf.dt_emissao < p.dt_pedido;

-- A15 — Existe pagamento com data anterior à do pedido?
-- Verifica: consistência da ficha de pagamento (processo P5)
SELECT pg.id_pagamento, pg.dt_pagamento, p.id_pedido, p.dt_pedido
FROM pagamento pg
JOIN pedido p ON p.id_pedido = pg.id_pedido
WHERE pg.dt_pagamento < p.dt_pedido;

-- A17 — Existe devolução aceita que foi solicitada mais de 30 dias depois da nota fiscal?
-- Verifica: RN14 (devolução só em até 30 dias após o recebimento; a mercadoria segue com a nota)
SELECT dv.id_devolucao, dv.dt_devolucao, nf.nr_nf, nf.dt_emissao, DATEDIFF(dv.dt_devolucao, nf.dt_emissao) AS dias
FROM devolucao dv
JOIN nota_fiscal nf ON nf.id_nf = dv.id_nf
WHERE dv.st_devolucao = 'aceita'
  AND DATEDIFF(dv.dt_devolucao, nf.dt_emissao) > 30;

-- A18 — Existe devolução de produto que não está no pedido da nota, ou em quantidade maior que a vendida?
-- Verifica: RN15 (devolução ligada à nota e ao lote de origem do produto vendido)
SELECT dv.id_devolucao, nf.nr_nf, l.id_produto, dv.qt_devolvida, pp.qt_solicitada
FROM devolucao dv
JOIN nota_fiscal nf          ON nf.id_nf = dv.id_nf
JOIN lote l                  ON l.id_lote = dv.id_lote
LEFT JOIN pedido_produto pp  ON pp.id_pedido = nf.id_pedido AND pp.id_produto = l.id_produto
WHERE pp.id_produto IS NULL OR dv.qt_devolvida > pp.qt_solicitada;

-- A19 — Existe pedido cancelado com nota fiscal ou pagamento?
-- Verifica: RN26 (pedido cancelado não é faturado nem recebe pagamento)
SELECT p.id_pedido, p.dt_pedido,
       (SELECT COUNT(*) FROM nota_fiscal nf WHERE nf.id_pedido = p.id_pedido) AS qt_notas,
       (SELECT COUNT(*) FROM pagamento pg WHERE pg.id_pedido = p.id_pedido) AS qt_pagamentos
FROM pedido p
WHERE p.st_pedido = 'cancelado'
  AND (EXISTS (SELECT 1 FROM nota_fiscal nf WHERE nf.id_pedido = p.id_pedido)
    OR EXISTS (SELECT 1 FROM pagamento pg WHERE pg.id_pedido = p.id_pedido));

-- A20 — Existe compra cujas parcelas não somam o valor da compra?
-- Verifica: RN20 (cada compra gera a obrigação de pagamento do seu valor total)
SELECT c.id_compra, c.vl_compra, COALESCE(SUM(pc.vl_parcela), 0) AS vl_parcelas
FROM compra c
LEFT JOIN pagamento_compra pc ON pc.id_compra = c.id_compra
GROUP BY c.id_compra, c.vl_compra
HAVING ROUND(COALESCE(SUM(pc.vl_parcela), 0) - c.vl_compra, 2) <> 0;

-- A21 — Existe parcela de compra com vencimento ou pagamento anterior à data da compra?
-- Verifica: RN20 (o pagamento à fábrica só é feito depois da compra e da conferência)
SELECT pc.id_pagamento_compra, c.id_compra, c.dt_compra, pc.dt_vencimento, pc.dt_pagamento
FROM pagamento_compra pc
JOIN compra c ON c.id_compra = pc.id_compra
WHERE pc.dt_vencimento < c.dt_compra OR pc.dt_pagamento < c.dt_compra;

-- A16 — Resumo: quantas ocorrências cada verificação encontrou?
-- Verifica: panorama geral das regras RN01, RN02, RN04, RN07, RN09, RN14, RN15, RN19, RN20, RN26 (0 = sem violação)
WITH total_pedido AS (
  SELECT id_pedido, SUM(qt_solicitada * vl_preco_praticado) AS vl_total
  FROM pedido_produto GROUP BY id_pedido
),
pago_pedido AS (
  SELECT id_pedido, SUM(vl_pagamento) AS vl_pago
  FROM pagamento GROUP BY id_pedido
)
SELECT 'A01 pedido sem item' AS verificacao, COUNT(*) AS qt_ocorrencias
  FROM pedido p LEFT JOIN pedido_produto pp ON pp.id_pedido = p.id_pedido WHERE pp.id_pedido IS NULL
UNION ALL
SELECT 'A02 compra sem lote', COUNT(*)
  FROM compra c LEFT JOIN lote l ON l.id_compra = c.id_compra WHERE l.id_lote IS NULL
UNION ALL
SELECT 'A03 NF diferente do total do pedido', COUNT(*)
  FROM nota_fiscal nf JOIN total_pedido t ON t.id_pedido = nf.id_pedido WHERE ROUND(nf.vl_nf - t.vl_total, 2) <> 0
UNION ALL
SELECT 'A04 liberado/entregue sem NF', COUNT(*)
  FROM pedido p LEFT JOIN nota_fiscal nf ON nf.id_pedido = p.id_pedido
  WHERE p.st_pedido IN ('liberado', 'entregue') AND nf.id_nf IS NULL
UNION ALL
SELECT 'A06 pagamento acima do total', COUNT(*)
  FROM total_pedido t JOIN pago_pedido g ON g.id_pedido = t.id_pedido WHERE ROUND(g.vl_pago - t.vl_total, 2) > 0
UNION ALL
SELECT 'A07 validade antes da compra', COUNT(*)
  FROM lote l JOIN compra c ON c.id_compra = l.id_compra WHERE l.dt_validade < c.dt_compra
UNION ALL
SELECT 'A09 CNPJ invalido', (SELECT COUNT(*) FROM distribuidor WHERE fn_cnpj_valido(nr_cnpj) = 0)
                          + (SELECT COUNT(*) FROM fornecedor WHERE fn_cnpj_valido(nr_cnpj) = 0)
UNION ALL
SELECT 'A11 distribuidor sem pedido', COUNT(*)
  FROM distribuidor d LEFT JOIN pedido p ON p.id_distribuidor = d.id_distribuidor WHERE p.id_pedido IS NULL
UNION ALL
SELECT 'A12 pedido abaixo de R$ 50', COUNT(*) FROM total_pedido WHERE vl_total < 50.00
UNION ALL
SELECT 'A14 NF antes do pedido', COUNT(*)
  FROM nota_fiscal nf JOIN pedido p ON p.id_pedido = nf.id_pedido WHERE nf.dt_emissao < p.dt_pedido
UNION ALL
SELECT 'A15 pagamento antes do pedido', COUNT(*)
  FROM pagamento pg JOIN pedido p ON p.id_pedido = pg.id_pedido WHERE pg.dt_pagamento < p.dt_pedido
UNION ALL
SELECT 'A17 devolucao aceita fora do prazo', COUNT(*)
  FROM devolucao dv JOIN nota_fiscal nf ON nf.id_nf = dv.id_nf
  WHERE dv.st_devolucao = 'aceita' AND DATEDIFF(dv.dt_devolucao, nf.dt_emissao) > 30
UNION ALL
SELECT 'A19 cancelado com NF ou pagamento', COUNT(*)
  FROM pedido p WHERE p.st_pedido = 'cancelado'
  AND (EXISTS (SELECT 1 FROM nota_fiscal nf WHERE nf.id_pedido = p.id_pedido)
    OR EXISTS (SELECT 1 FROM pagamento pg WHERE pg.id_pedido = p.id_pedido))
UNION ALL
SELECT 'A21 parcela antes da compra', COUNT(*)
  FROM pagamento_compra pc JOIN compra c ON c.id_compra = pc.id_compra
  WHERE pc.dt_vencimento < c.dt_compra OR pc.dt_pagamento < c.dt_compra;

-- Fim do script.
