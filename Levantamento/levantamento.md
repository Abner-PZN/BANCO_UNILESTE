# Levantamento — Unileste Comércio LTDA.

Texto organizado pelo grupo a partir da entrevista com o gerente, da observação da rotina na empresa e da pesquisa sobre distribuidoras de cosméticos. Voltar ao [README](../README.md).

---

## 1. Como o levantamento foi feito

| Fonte | Quando | Quem participou | O que rendeu |
| --- | --- | --- | --- |
| Entrevista com o gerente, na empresa | 14/09/2026 | Alfredo Veronezi Gomides (gerente) e Abner Barbosa Machado | Processos, regras, volumes e problemas |
| Observação da rotina (recepção, escritório e estoque) | 14/09/2026 | Abner Barbosa Machado | Como os dados circulam na prática (seção 4) |
| Pesquisa e IA sobre distribuidoras de cosméticos | Out./nov. 2026 | Grupo | Lista de processos, requisitos, regras e KPIs típicos, depois conferida com o gerente (README, seção 1.1 — itens típicos não incluídos — e seção 6) |

Um dos integrantes Abner Barbosa Machado trabalha na empresa, o que facilitou o acesso. Mesmo assim, a entrevista foi feita com o gerente, no ambiente da empresa.

---

## 2. A organização em números

| Item | Valor informado | Uso no projeto |
| --- | --- | --- |
| Tempo de mercado | Mais de 20 anos | Contexto |
| Funcionários diretos | 9 | Perfis de acesso (RNF01) |
| Distribuidores ativos | Cerca de 90 | 90 distribuidores na massa de dados |
| Produtos no catálogo | 99 | 99 produtos na massa de dados |
| Pedidos por mês | Cerca de 500 | ~1.000 pedidos para 2 meses de operação (set.–out./2026) |
| Compras às fábricas por mês | Cerca de 50 | ~134 compras na massa de dados (cerca de 2,7 meses, incluindo compras anteriores que formaram o estoque) |
| Marcas | 2 (Tutti Capelli e Outlet Hair) | Processo P13 |
| Tipos de produto | Shampoo, condicionador, máscara, óleo reparador, perfume capilar, ox, coloração e pó descolorante | Atributo tipo de Produto |

---

## 3. O que foi levantado na entrevista, por assunto

### 3.1 Clientes e vendas
- A empresa vende **somente a distribuidores com CNPJ**, que revendem aos salões. Não há venda ao consumidor final (RN01).
- O distribuidor é cadastrado com nome, CNPJ, endereço e telefone, no atendimento do primeiro pedido (P1).
- O pedido é registrado item por item: produto, quantidade e preço da tabela vigente. O preço praticado fica gravado no item (P3, RN05).
- Existe pedido mínimo de **R$ 50,00** (RN04).

### 3.2 Pagamento e liberação
- O pagamento é anotado na **ficha do distribuidor**: data, valor e forma (cartão, boleto, pix, cheque, transferência ou dinheiro) (P5).
- O pedido só é **liberado** se estiver pago ou se o gerente financeiro autorizar um acordo de pagamento futuro (RN07).
- Cada distribuidor tem limite de crédito de **R$ 1.000,00** e prazo até o fechamento do mês (RN06). 
- Problema relatado: é difícil saber o que cada distribuidor pagou, o que está em aberto e o que foi liberado por acordo (**PB1**).

### 3.3 Faturamento
- Com o pedido registrado e o estoque confirmado, é emitida **uma nota fiscal por pedido**, com valor igual ao total do pedido (P4, RN09).
- Os documentos fiscais são guardados por **5 anos** (RN23).

### 3.4 Estoque e validade
- O estoque é acompanhado por quantidade, **mas não por lote nem por validade** (**PB2**).
- A reposição depende de alguém perceber que o produto está acabando; às vezes o distribuidor só é avisado depois de fazer o pedido (**PB3**).
- Produto vencido não pode ser vendido (RN10, RN22). A saída deve priorizar o lote de validade mais próxima (FEFO, RN11).

### 3.5 Compras e recebimento
- Toda a produção é terceirizada a fábricas parceiras cadastradas (P8, RN17).
- A mercadoria recebida é conferida contra a compra e a nota do fornecedor: produto, quantidade, lote, validade e embalagem (P10, RN18).
- Não há um registro único que ligue a compra, o lote recebido e os pedidos atendidos com esse lote (**PB4**).

### 3.6 Pós-venda e gestão
- Devoluções e trocas são aceitas por avaria, vencimento ou divergência, em até 30 dias (P7, RN14 a RN16).
- A gerência acompanha as vendas por marca e por funcionário (P13).

---

## 4. O que foi observado no local (separado do que foi dito)

- **Ficha de pagamento:** a ficha de pagamento fica no armário na empresa, o funcionário que atende o distribuidor preenche com o valor do pedido e o valor do acerto.
- **Pedidos:** Os distribuidores realizam o pedido tanto por mensagem no Whatsapp, vindo presencialmente ou por ligação, hoje em dia eles lançam os pedidos em um sistema porem o sistema é somente para registrar os pedidos e gerar a nota.
- **Expedição:** o atendente gera o pedido e manda uma via para a Expedição realizar a separação e conferência do pedido.

---

## 5. Processos confirmados

| Código | Processo | Grupo |
| --- | --- | --- |
| P1 | Cadastro de distribuidores | Vendas |
| P2 | Tabela de preços e condições comerciais | Vendas |
| P3 | Emissão de pedido com conferência de estoque | Vendas |
| P4 | Faturamento e emissão de nota fiscal | Vendas |
| P5 | Controle de pagamentos | Vendas |
| P6 | Entrega aos distribuidores | Vendas |
| P7 | Devolução e troca | Vendas |
| P8 | Cadastro de fornecedores (fábricas) | Compras |
| P9 | Compra junto às fábricas | Compras |
| P10 | Recebimento da mercadoria e entrada de lotes | Compras |
| P11 | Contas a pagar às fábricas | Compras |
| P12 | Controle de estoque e validade | Apoio |
| P13 | Gestão de pessoal e de vendas por marca | Apoio |

A descrição completa de cada processo (participantes, entrada → saída e dados usados) está no README, seção 1.1 (Processos de negócio).

---

## 6. Problemas identificados

| Código | Problema | Origem |
| --- | --- | --- |
| PB1 | Fichas de pagamento sem controle centralizado | Entrevista |
| PB2 | Estoque sem controle de validade por lote | Entrevista |
| PB3 | Falta de aviso de estoque baixo | Entrevista |
| PB4 | Rastreabilidade fraca entre compra, lote e venda | Entrevista |

---

## 7. O que mudou em relação à Entrega 1

| Item | Entrega 1 | Entrega 2 | Motivo |
| --- | --- | --- | --- |
| Situação do pedido | pendente, pago, entregue | pendente, **liberado**, entregue | O pedido pode ser liberado por acordo, sem estar pago (RN07) |
| Estoque mínimo | Não existia | Atributo estoque_minimo em Produto | Necessário para a lista de reposição (RN12, PB3) |
| Saldo do estoque | Quantidade por produto | Saldo por lote, baixado na entrega pelo FEFO | Controle de validade (RN10, RN11, PB2) |
| Preço do item | Só o preço atual do produto | Preço praticado gravado no item do pedido | Mudança de preço não altera pedidos já emitidos (RN05) |
| Pedido mínimo, limite de crédito e prazos | Não detalhados | R$ 50,00, R$ 1.000,00 e fechamento do mês | Regras RN04 e RN06 |
| Cancelamento de pedido | Não previsto | Situação "cancelado"; pedido não é apagado (RN26) | Histórico e taxa de cancelamento |
| Escopo do modelo | Devolução, contas a pagar, marca e funcionário só descritos | Entidades Devolucao, Pagamento_Compra, Marca e Funcionario | O banco deve reunir todos os dados da empresa (P7, P11, P13) |

---

