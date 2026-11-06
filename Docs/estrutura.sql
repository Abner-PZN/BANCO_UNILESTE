-- =====================================================================
-- Banco de dados do sistema de pedidos, fornecimento e estoque
-- Entrega 2 · Modelagem de Banco de Dados · SGBD: MySQL 8.0.16 ou superior
-- SCRIPT 1 de 2 (estrutura). Executa do zero, em banco vazio:
--   1. CREATE DATABASE        2. CREATE TABLE          3. Constraints (PK, FK, NOT NULL, UNIQUE, CHECK, DEFAULT)
--   3.1 Função e triggers
-- Execute DEPOIS o script 2 (02_massa_de_dados.sql): INSERTs, objetos pós-carga, SELECT, UPDATE, DELETE e consultas.
-- Observação: todos os dados abaixo são FICTÍCIOS (nomes, CNPJs, endereços e valores).
-- Referência de data da massa de dados: 03/11/2026 (último movimento: 02/11/2026).
-- =====================================================================

-- =====================================================================
-- 1. CREATE DATABASE
-- =====================================================================
DROP DATABASE IF EXISTS unileste;
CREATE DATABASE unileste
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

-- =====================================================================
-- 2 e 3. CREATE TABLE com constraints (PK, FK, NOT NULL, UNIQUE, CHECK, DEFAULT)
-- Prefixos: id_ identificador · nm_ nome · nr_ número · ds_ descrição · dt_ data
--           vl_ valor · tp_ tipo · qt_ quantidade · st_ situação
-- Ordem de criação: primeiro as tabelas referenciadas (sem FK), depois as que têm FK.
-- =====================================================================

CREATE TABLE distribuidor (
  id_distribuidor  INT           NOT NULL AUTO_INCREMENT,
  nm_distribuidor  VARCHAR(120)  NOT NULL,
  nr_cnpj          VARCHAR(18)   NOT NULL,
  ds_endereco      VARCHAR(200)  NOT NULL,
  nr_telefone      VARCHAR(20)   NULL,
  CONSTRAINT pk_distribuidor PRIMARY KEY (id_distribuidor),
  CONSTRAINT uk_distribuidor_cnpj UNIQUE (nr_cnpj),                                   -- RN02
  CONSTRAINT chk_distribuidor_cnpj_formato
    CHECK (nr_cnpj REGEXP '^[0-9]{2}[.][0-9]{3}[.][0-9]{3}/[0-9]{4}-[0-9]{2}$')       -- RN02 (formato)
) ENGINE=InnoDB;

CREATE TABLE fornecedor (
  id_fornecedor  INT           NOT NULL AUTO_INCREMENT,
  nm_fornecedor  VARCHAR(120)  NOT NULL,
  nr_cnpj        VARCHAR(18)   NOT NULL,
  ds_endereco    VARCHAR(200)  NOT NULL,
  nr_telefone    VARCHAR(20)   NOT NULL,
  CONSTRAINT pk_fornecedor PRIMARY KEY (id_fornecedor),
  CONSTRAINT uk_fornecedor_cnpj UNIQUE (nr_cnpj),                                     -- RN02
  CONSTRAINT chk_fornecedor_cnpj_formato
    CHECK (nr_cnpj REGEXP '^[0-9]{2}[.][0-9]{3}[.][0-9]{3}/[0-9]{4}-[0-9]{2}$')       -- RN02 (formato)
) ENGINE=InnoDB;

CREATE TABLE marca (
  id_marca  INT          NOT NULL AUTO_INCREMENT,
  nm_marca  VARCHAR(60)  NOT NULL,
  CONSTRAINT pk_marca PRIMARY KEY (id_marca),
  CONSTRAINT uk_marca_nome UNIQUE (nm_marca)
) ENGINE=InnoDB;

CREATE TABLE funcionario (
  id_funcionario  INT           NOT NULL AUTO_INCREMENT,
  nm_funcionario  VARCHAR(120)  NOT NULL,
  ds_cargo        VARCHAR(60)   NOT NULL,
  CONSTRAINT pk_funcionario PRIMARY KEY (id_funcionario)
) ENGINE=InnoDB;

CREATE TABLE produto (
  id_produto         INT            NOT NULL AUTO_INCREMENT,
  nm_produto         VARCHAR(120)   NOT NULL,
  tp_produto         VARCHAR(50)    NOT NULL,      -- sem CHECK de lista: novos tipos podem ser cadastrados (README)
  vl_preco           DECIMAL(10,2)  NOT NULL,
  qt_estoque_minimo  INT            NOT NULL DEFAULT 0,
  id_marca           INT            NOT NULL,
  CONSTRAINT pk_produto PRIMARY KEY (id_produto),
  CONSTRAINT fk_produto_marca FOREIGN KEY (id_marca)
    REFERENCES marca (id_marca) ON UPDATE CASCADE ON DELETE RESTRICT,                 -- P13
  INDEX idx_produto_marca (id_marca),
  CONSTRAINT chk_produto_preco   CHECK (vl_preco > 0),
  CONSTRAINT chk_produto_minimo  CHECK (qt_estoque_minimo >= 0)                       -- RN12
) ENGINE=InnoDB;

CREATE TABLE compra (
  id_compra      INT            NOT NULL AUTO_INCREMENT,
  dt_compra      DATE           NOT NULL,
  vl_compra      DECIMAL(10,2)  NOT NULL,
  id_fornecedor  INT            NOT NULL,
  CONSTRAINT pk_compra PRIMARY KEY (id_compra),
  CONSTRAINT fk_compra_fornecedor FOREIGN KEY (id_fornecedor)
    REFERENCES fornecedor (id_fornecedor) ON UPDATE CASCADE ON DELETE RESTRICT,       -- RN17
  CONSTRAINT chk_compra_valor CHECK (vl_compra > 0),
  INDEX idx_compra_fornecedor (id_fornecedor)
) ENGINE=InnoDB;

-- Contas a pagar às fábricas (P11): cada compra gera uma ou mais parcelas (RN20)
CREATE TABLE pagamento_compra (
  id_pagamento_compra  INT            NOT NULL AUTO_INCREMENT,
  dt_vencimento        DATE           NOT NULL,
  vl_parcela           DECIMAL(10,2)  NOT NULL,
  dt_pagamento         DATE           NULL,          -- NULL = parcela em aberto
  tp_forma_pagamento   VARCHAR(30)    NULL,
  id_compra            INT            NOT NULL,
  CONSTRAINT pk_pagamento_compra PRIMARY KEY (id_pagamento_compra),
  CONSTRAINT fk_pagcompra_compra FOREIGN KEY (id_compra) REFERENCES compra (id_compra)
    ON UPDATE CASCADE ON DELETE RESTRICT,                                             -- RN20
  CONSTRAINT chk_pagcompra_valor CHECK (vl_parcela > 0),
  CONSTRAINT chk_pagcompra_forma
    CHECK (tp_forma_pagamento IS NULL OR tp_forma_pagamento IN ('boleto','pix','transferencia')),
  CONSTRAINT chk_pagcompra_quitacao
    CHECK ((dt_pagamento IS NULL AND tp_forma_pagamento IS NULL)
        OR (dt_pagamento IS NOT NULL AND tp_forma_pagamento IS NOT NULL)),            -- paga = data + forma
  INDEX idx_pagcompra_compra (id_compra),
  INDEX idx_pagcompra_vencimento (dt_vencimento)
) ENGINE=InnoDB;

CREATE TABLE lote (
  id_lote      INT   NOT NULL AUTO_INCREMENT,
  id_compra    INT   NOT NULL,
  id_produto   INT   NOT NULL,
  qt_lote      INT   NOT NULL,                  -- saldo atual do lote (diminui na entrega, FEFO)
  dt_validade  DATE  NOT NULL,
  CONSTRAINT pk_lote PRIMARY KEY (id_lote),
  CONSTRAINT fk_lote_compra  FOREIGN KEY (id_compra)  REFERENCES compra (id_compra)
    ON UPDATE CASCADE ON DELETE RESTRICT,                                             -- RN19
  CONSTRAINT fk_lote_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
    ON UPDATE CASCADE ON DELETE RESTRICT,                                             -- RN19
  CONSTRAINT chk_lote_saldo CHECK (qt_lote >= 0),
  INDEX idx_lote_compra   (id_compra),
  INDEX idx_lote_produto  (id_produto),
  INDEX idx_lote_validade (dt_validade)                                               -- RN10, RN13
) ENGINE=InnoDB;

CREATE TABLE pedido (
  id_pedido        INT          NOT NULL AUTO_INCREMENT,
  dt_pedido        DATE         NOT NULL,
  st_pedido        VARCHAR(20)  NOT NULL DEFAULT 'pendente',
  id_distribuidor  INT          NOT NULL,
  id_funcionario   INT          NOT NULL,      -- funcionário que registrou o pedido (P13)
  CONSTRAINT pk_pedido PRIMARY KEY (id_pedido),
  CONSTRAINT fk_pedido_distribuidor FOREIGN KEY (id_distribuidor)
    REFERENCES distribuidor (id_distribuidor) ON UPDATE CASCADE ON DELETE RESTRICT,   -- RN01
  CONSTRAINT fk_pedido_funcionario FOREIGN KEY (id_funcionario)
    REFERENCES funcionario (id_funcionario) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_pedido_status
    CHECK (st_pedido IN ('pendente','liberado','entregue','cancelado')),              -- RN07, RN26
  INDEX idx_pedido_funcionario (id_funcionario),
  INDEX idx_pedido_distribuidor (id_distribuidor),
  INDEX idx_pedido_status (st_pedido),
  INDEX idx_pedido_data (dt_pedido)
) ENGINE=InnoDB;

CREATE TABLE pedido_produto (
  id_pedido           INT            NOT NULL,
  id_produto          INT            NOT NULL,
  qt_solicitada       INT            NOT NULL,
  vl_preco_praticado  DECIMAL(10,2)  NOT NULL,
  CONSTRAINT pk_pedido_produto PRIMARY KEY (id_pedido, id_produto),
  CONSTRAINT fk_pedprod_pedido  FOREIGN KEY (id_pedido)  REFERENCES pedido (id_pedido)
    ON UPDATE CASCADE ON DELETE CASCADE,                                              -- item faz parte do pedido
  CONSTRAINT fk_pedprod_produto FOREIGN KEY (id_produto) REFERENCES produto (id_produto)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_pedprod_qtd   CHECK (qt_solicitada > 0),
  CONSTRAINT chk_pedprod_preco CHECK (vl_preco_praticado > 0),                        -- RN05
  INDEX idx_pedprod_produto (id_produto)
) ENGINE=InnoDB;

CREATE TABLE nota_fiscal (
  id_nf       INT            NOT NULL AUTO_INCREMENT,
  nr_nf       VARCHAR(20)    NOT NULL,
  dt_emissao  DATE           NOT NULL,
  vl_nf       DECIMAL(10,2)  NOT NULL,
  id_pedido   INT            NOT NULL,
  CONSTRAINT pk_nota_fiscal PRIMARY KEY (id_nf),
  CONSTRAINT uk_nf_numero UNIQUE (nr_nf),
  CONSTRAINT uk_nf_pedido UNIQUE (id_pedido),                                         -- RN09 (0,1)-(1,1)
  CONSTRAINT fk_nf_pedido FOREIGN KEY (id_pedido) REFERENCES pedido (id_pedido)
    ON UPDATE CASCADE ON DELETE RESTRICT,                                             -- RN23 (guarda 5 anos)
  CONSTRAINT chk_nf_valor CHECK (vl_nf > 0)
) ENGINE=InnoDB;

CREATE TABLE pagamento (
  id_pagamento        INT            NOT NULL AUTO_INCREMENT,
  dt_pagamento        DATE           NOT NULL,
  vl_pagamento        DECIMAL(10,2)  NOT NULL,
  tp_forma_pagamento  VARCHAR(30)    NOT NULL,
  id_pedido           INT            NOT NULL,
  CONSTRAINT pk_pagamento PRIMARY KEY (id_pagamento),
  CONSTRAINT fk_pagamento_pedido FOREIGN KEY (id_pedido) REFERENCES pedido (id_pedido)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_pagamento_valor CHECK (vl_pagamento > 0),
  CONSTRAINT chk_pagamento_forma
    CHECK (tp_forma_pagamento IN ('cartao','boleto','pix','cheque','transferencia','dinheiro')),
  INDEX idx_pagamento_pedido (id_pedido),
  INDEX idx_pagamento_data (dt_pagamento)
) ENGINE=InnoDB;

-- Devolução e troca (P7): registrada com motivo, nota fiscal e lote de origem (RN14, RN15, RN16)
CREATE TABLE devolucao (
  id_devolucao   INT          NOT NULL AUTO_INCREMENT,
  dt_devolucao   DATE         NOT NULL,          -- data da solicitação pelo distribuidor
  qt_devolvida   INT          NOT NULL,
  tp_motivo      VARCHAR(20)  NOT NULL,
  st_devolucao   VARCHAR(20)  NOT NULL DEFAULT 'em_analise',
  tp_resolucao   VARCHAR(20)  NULL,              -- só preenchida quando a devolução é aceita
  id_nf          INT          NOT NULL,
  id_lote        INT          NOT NULL,
  CONSTRAINT pk_devolucao PRIMARY KEY (id_devolucao),
  CONSTRAINT fk_devolucao_nf FOREIGN KEY (id_nf) REFERENCES nota_fiscal (id_nf)
    ON UPDATE CASCADE ON DELETE RESTRICT,                                             -- RN15
  CONSTRAINT fk_devolucao_lote FOREIGN KEY (id_lote) REFERENCES lote (id_lote)
    ON UPDATE CASCADE ON DELETE RESTRICT,                                             -- RN15
  CONSTRAINT chk_devolucao_qtd CHECK (qt_devolvida > 0),
  CONSTRAINT chk_devolucao_motivo CHECK (tp_motivo IN ('avaria','vencido','divergente')),          -- RN14
  CONSTRAINT chk_devolucao_status CHECK (st_devolucao IN ('em_analise','aceita','recusada')),
  CONSTRAINT chk_devolucao_resolucao
    CHECK ((st_devolucao = 'aceita' AND tp_resolucao IN ('troca','credito','estorno'))
        OR (st_devolucao <> 'aceita' AND tp_resolucao IS NULL)),                      -- RN16
  INDEX idx_devolucao_nf (id_nf),
  INDEX idx_devolucao_lote (id_lote)
) ENGINE=InnoDB;

-- =====================================================================
-- 3.1 Função e triggers de regras que o CHECK não consegue expressar
-- (CHECK do MySQL não aceita função própria nem consulta a outra tabela)
-- Estes objetos são criados ANTES da carga: validam CNPJ (RN02), a validade do lote (RN19) e o
-- histórico de pedidos cancelados (RN26).
-- =====================================================================
DELIMITER $$

-- RN02: CNPJ válido (14 dígitos e dígitos verificadores corretos)
CREATE FUNCTION fn_cnpj_valido(p_cnpj VARCHAR(18))
RETURNS TINYINT(1)
DETERMINISTIC NO SQL
BEGIN
  DECLARE v_num   VARCHAR(40);
  DECLARE v_i     INT;
  DECLARE v_soma  INT;
  DECLARE v_peso  INT;
  DECLARE v_dv1   INT;
  DECLARE v_dv2   INT;

  SET v_num = REPLACE(REPLACE(REPLACE(p_cnpj, '.', ''), '/', ''), '-', '');
  IF CHAR_LENGTH(v_num) <> 14 OR v_num NOT REGEXP '^[0-9]{14}$' THEN
    RETURN 0;
  END IF;
  IF REPLACE(v_num, SUBSTRING(v_num, 1, 1), '') = '' THEN   -- todos os dígitos iguais
    RETURN 0;
  END IF;

  SET v_soma = 0; SET v_i = 1; SET v_peso = 5;
  WHILE v_i <= 12 DO
    SET v_soma = v_soma + CAST(SUBSTRING(v_num, v_i, 1) AS UNSIGNED) * v_peso;
    SET v_peso = v_peso - 1;
    IF v_peso < 2 THEN SET v_peso = 9; END IF;
    SET v_i = v_i + 1;
  END WHILE;
  SET v_dv1 = IF(MOD(v_soma, 11) < 2, 0, 11 - MOD(v_soma, 11));

  SET v_soma = 0; SET v_i = 1; SET v_peso = 6;
  WHILE v_i <= 13 DO
    SET v_soma = v_soma + CAST(SUBSTRING(v_num, v_i, 1) AS UNSIGNED) * v_peso;
    SET v_peso = v_peso - 1;
    IF v_peso < 2 THEN SET v_peso = 9; END IF;
    SET v_i = v_i + 1;
  END WHILE;
  SET v_dv2 = IF(MOD(v_soma, 11) < 2, 0, 11 - MOD(v_soma, 11));

  RETURN (v_dv1 = CAST(SUBSTRING(v_num, 13, 1) AS UNSIGNED)
      AND v_dv2 = CAST(SUBSTRING(v_num, 14, 1) AS UNSIGNED));
END$$

CREATE TRIGGER trg_distribuidor_bi BEFORE INSERT ON distribuidor FOR EACH ROW
BEGIN
  IF fn_cnpj_valido(NEW.nr_cnpj) = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN02: CNPJ do distribuidor invalido';
  END IF;
END$$
CREATE TRIGGER trg_distribuidor_bu BEFORE UPDATE ON distribuidor FOR EACH ROW
BEGIN
  IF fn_cnpj_valido(NEW.nr_cnpj) = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN02: CNPJ do distribuidor invalido';
  END IF;
END$$
CREATE TRIGGER trg_fornecedor_bi BEFORE INSERT ON fornecedor FOR EACH ROW
BEGIN
  IF fn_cnpj_valido(NEW.nr_cnpj) = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN02: CNPJ do fornecedor invalido';
  END IF;
END$$
CREATE TRIGGER trg_fornecedor_bu BEFORE UPDATE ON fornecedor FOR EACH ROW
BEGIN
  IF fn_cnpj_valido(NEW.nr_cnpj) = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN02: CNPJ do fornecedor invalido';
  END IF;
END$$

-- RN19: a validade do lote não pode ser anterior à data da compra de origem
CREATE TRIGGER trg_lote_bi BEFORE INSERT ON lote FOR EACH ROW
BEGIN
  DECLARE v_dt_compra DATE;
  SELECT dt_compra INTO v_dt_compra FROM compra WHERE id_compra = NEW.id_compra;
  IF NEW.dt_validade < v_dt_compra THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN19: validade do lote anterior a data da compra';
  END IF;
END$$

-- RN26: pedido não é apagado; o cancelamento fica no histórico (situação 'cancelado')
CREATE TRIGGER trg_pedido_bd BEFORE DELETE ON pedido FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN26: pedido nao pode ser apagado; use a situacao cancelado';
END$$

-- RN26: só pedido pendente pode ser cancelado, e pedido cancelado não volta a ser movimentado
CREATE TRIGGER trg_pedido_bu BEFORE UPDATE ON pedido FOR EACH ROW
BEGIN
  IF NEW.st_pedido = 'cancelado' AND OLD.st_pedido NOT IN ('pendente', 'cancelado') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN26: so pedido pendente pode ser cancelado';
  END IF;
  IF OLD.st_pedido = 'cancelado' AND NEW.st_pedido <> 'cancelado' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN26: pedido cancelado nao pode mudar de situacao';
  END IF;
END$$

-- RN26: pedido cancelado não recebe nota fiscal nem pagamento
CREATE TRIGGER trg_nota_fiscal_bi BEFORE INSERT ON nota_fiscal FOR EACH ROW
BEGIN
  IF (SELECT st_pedido FROM pedido WHERE id_pedido = NEW.id_pedido) = 'cancelado' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN26: pedido cancelado nao recebe nota fiscal';
  END IF;
END$$
CREATE TRIGGER trg_pagamento_bi BEFORE INSERT ON pagamento FOR EACH ROW
BEGIN
  IF (SELECT st_pedido FROM pedido WHERE id_pedido = NEW.id_pedido) = 'cancelado' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RN26: pedido cancelado nao recebe pagamento';
  END IF;
END$$

DELIMITER ;
