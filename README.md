# UNILESTE COSMÉTICOS

## INTEGRANTES

| NOME | RGM |
| --- | --- |
| Abner Barbosa Machado        | 4662540-2 |
| Kauã Freitas Passos Perroni. | 4774900-8 |
| Luís Cauan Sena Rodrigues.   | 4683553-9

# 1. Caracterização da Organização 

- **Nome e natureza da organização:**
A organização escolhida é a Unileste Comércio LTDA., empresa de médio porte do setor de cosméticos e produtos capilares. A empresa atua com duas marcas comerciais — Tutti Capelli e Outlet Hair — que representam linhas distintas de produtos e pontos de venda, mas estão sob a mesma gestão administrativa e jurídica.

- **Contexto e porte:** 
A empresa possui fins lucrativos á mais de 20 anos no mercado e conta atualmente com 9 funcionários diretos e cerca de 90 distribuidores que revendem seus produtos para salões de cabeleireiro. Os produtos são terceirizados — produzidos por fábricas parceiras — e comercializados exclusivamente para distribuidores, que fazem a revenda final.
Volume de atividade: Tem em média 500 pedidos por mês, atualmente conta com 99 produtos no catálogo, e realiza em torno de 50 compras por mês.

- **Problemas e necessidades identificados:**
Foram identificadas dificuldades no controle das fichas de pagamento dos distribuidor, além da ausência de um sistema eficiente para monitorar o estoque, especialmente em relação à validade dos produtos e à quantidade disponível.
 1. **Fichas de pagamento dos distribuidores** sem controle centralizado: é difícil saber, para cada pedido, o que foi pago, o que está em aberto e o que foi liberado por acordo com o gerente.
 2. **Estoque sem controle de validade:** o estoque é acompanhado por quantidade, mas a validade de cada lote não é monitorada de forma sistemática, o que traz risco de vender ou manter produto vencido (cosmético).
 3. **Falta de aviso de estoque baixo:** a reposição depende da percepção dos funcionários; quando falta produto, o distribuidor é avisado depois do pedido.
 4. **Rastreabilidade fraca entre compra, lote e venda:** não há registro único ligando a compra feita à fábrica, o lote recebido e os pedidos que consumiram esse lote.

**Necessidade:** um sistema que registre distribuidores, pedidos, notas, pagamentos, entregas, compras e lotes de forma integrada, com validade e estoque sob controle.

- **Justificativa da escolha:** o grupo tem acesso direto à empresa para pesquisa de campo pois um dos integrantes do grupo trabalha nessa empresa, O porte é adequado ao projeto: o ciclo completo do negócio (comprar da fábrica, estocar por lote com validade, vender a distribuidor, faturar, cobrar) gera 10 entidades relacionadas, o suficiente para exercitar relacionamentos 1:N, N:N com entidade associativa e 1:1 opcional, sem ser complexo demais para a primeira etapa. A venda exclusivamente B2B (CNPJ) e o controle de validade são regras reais e específicas que enriquecem o modelo.

- **Evidências da organização:**

  - **Endereço completo:** Rua Arraial de São Bartolomeu 944
  - **Link (site / rede social):** https://tutticapelli.com.br/ | https://www.instagram.com/tutticapelliprofessional/
  - **Contato e responsável:** Alfredo Veronezi Gomides, Gerente,  11 98104-9575.
   - **Fotos:**
    ![Foto da fachada](Docs/FotoFachada.jpeg)
    ![Foto do estoque](Docs/FotoEstoque.jpg)
    ![Foto da recepção](Docs/FotoRecepção.jpeg)
     
    
---

# 2. Processos de Negócio

A Unileste opera em três grupos de processos: Vendas (do cadastro do distribuidor ao pós-venda), Compras (da fábrica ao estoque) e Apoio (estoque, validade e gestão). Cada processo abaixo traz o que acontece, quem participa, o que entra e o que sai, e quais dados do modelo ele usa.

## 2.1 Processos de Vendas
 
### P1. Cadastro de distribuidores
- **Descrição:** o interessado em revender os produtos envia os dados da empresa. A equipe comercial confere se é pessoa jurídica (CNPJ válido e ainda não cadastrado) e, aprovado, registra o distribuidor com endereço e telefone. Consumidor final não é cadastrado, pois a empresa vende exclusivamente a distribuidores.
- **Participantes:** equipe comercial, gerente.
- **Entrada → Saída:** dados e CNPJ do interessado → distribuidor ativo, apto a fazer pedidos.
- **Dados usados:** Distribuidor.
### P2. Tabela de preços e condições comerciais
- **Descrição:** a gerência define o preço de venda de cada produto e as condições comerciais: pedido mínimo, faixas de desconto por volume, limite de crédito e prazo de pagamento do distribuidor. Quando o preço muda, a nova tabela passa a valer a partir de uma data e não altera pedidos já emitidos. O preço praticado é gravado em cada item do pedido.
- **Participantes:** gerente.
- **Entrada → Saída:** custo de compra, política comercial → tabela de preços vigente e condições por distribuidor.
- **Dados usados:** Produto (preço), Distribuidor, item do Pedido (preço praticado).
### P3. Emissão de pedido com conferência de estoque
- **Descrição:** o distribuidor solicita os produtos e a equipe registra o pedido, item por item. O sistema confere o estoque disponível (priorizando lotes de validade mais próxima), aplica preço e desconto da tabela vigente e confere pedido mínimo e limite de crédito. Itens sem estoque não podem ser vendidos. O pedido fica "pendente" até a liberação do P5.
- **Participantes:** equipe comercial, distribuidor.
- **Entrada → Saída:** solicitação do distribuidor → pedido registrado com itens, quantidades e preços.
- **Dados usados:** Pedido, Pedido–Produto, Produto, Lote, Distribuidor.
### P4. Faturamento e emissão de nota fiscal
- **Descrição:** com o pedido liberado, a equipe confere se todos os dados do distribuidor e dos itens estão completos (CNPJ, endereço, produtos, quantidades, valores e impostos) e emite a nota fiscal conforme as normas fiscais vigentes. A nota é vinculada ao pedido (0:1: um pedido ainda não liberado não tem nota) e o valor da nota deve bater com o total do pedido. A nota acompanha a mercadoria na entrega e uma cópia é arquivada por 5 anos.
- **Participantes:** equipe administrativo-financeira.
- **Entrada → Saída:** pedido liberado → nota fiscal emitida e arquivada.
- **Dados usados:** Nota Fiscal, Pedido, Distribuidor.
### P5. Controle de pagamentos
- **Descrição:** cada pagamento do distribuidor é registrado na ficha, com data, valor e forma (boleto, transferência etc.), vinculado ao pedido. O pedido só é liberado se estiver pago ou se o gerente financeiro autorizar pagamento futuro (acordo). Pedidos com acordo ficam marcados como "em aberto" até a quitação, e a equipe acompanha os vencimentos.
- **Participantes:** equipe financeira, gerente financeiro.
- **Entrada → Saída:** pagamento ou acordo → pedido liberado e saldo do distribuidor atualizado.
- **Dados usados:** Pagamento, Pedido, Distribuidor.
### P6. Entrega aos distribuidores
- **Descrição:** com o pedido liberado e a nota fiscal emitida, a equipe separa os produtos (respeitando FEFO), embala, confere os itens contra o pedido e despacha com a nota. O pedido passa a "entregue" quando o distribuidor recebe.
- **Participantes:** equipe de expedição/estoque.
- **Entrada → Saída:** pedido liberado + nota fiscal → mercadoria entregue e baixa no estoque.
- **Dados usados:** Pedido, Lote, Nota Fiscal.
### P7. Devolução e troca
- **Descrição:** quando o distribuidor recebe produto com avaria, vencido ou diferente do pedido, comunica a empresa dentro do prazo. A equipe registra a devolução com o motivo, a nota fiscal de origem e o lote, confere o produto devolvido e o gerente decide entre troca, crédito ou estorno. Produto avariado ou vencido não volta ao estoque vendável. Em caso de problema recorrente no mesmo lote, a empresa avisa a fábrica.
- **Participantes:** distribuidor, equipe comercial, gerente e estoque.
- **Entrada → Saída:** solicitação do distribuidor → devolução registrada, produto trocado ou crédito/estorno, estoque ajustado.
- **Dados usados:** Pedido, Nota Fiscal, Lote, Produto (sugestão de entidade futura: Devolução).
## 2.2 Processos de Compras
 
### P8. Cadastro de fornecedores (fábricas)
- **Descrição:** antes de comprar, a fábrica parceira é cadastrada com nome, CNPJ válido e único, endereço e telefone de contato. Só fornecedores cadastrados e ativos podem receber ordens de compra. A empresa mantém dados atualizados porque toda a produção é terceirizada.
- **Participantes:** setor de compras, gerente.
- **Entrada → Saída:** dados da fábrica → fornecedor ativo apto a receber compras.
- **Dados usados:** Fornecedor.
### P9. Compra junto às fábricas
- **Descrição:** a partir da lista de produtos em estoque baixo e da demanda dos pedidos, o setor de compras emite a compra à fábrica, informando produtos, quantidades, preço e prazo de entrega. São cerca de 50 compras por mês. Cada compra fica registrada com data, fornecedor e valor.
- **Participantes:** setor de compras, gerente.
- **Entrada → Saída:** necessidade de reposição → compra registrada e enviada à fábrica.
- **Dados usados:** Compra, Fornecedor, Produto.
### P10. Recebimento da mercadoria e entrada de lotes
- **Descrição:** quando a fábrica entrega, a equipe confere a mercadoria contra a compra e a nota do fornecedor: produto, quantidade, número do lote, validade e integridade das embalagens. Se estiver correto, cada lote é registrado vinculado à compra de origem, com número, validade e quantidade, e só então os produtos entram no estoque. Divergências (falta, avaria, validade curta) são registradas e comunicadas à fábrica antes da entrada.
- **Participantes:** equipe de estoque, setor de compras.
- **Entrada → Saída:** mercadoria + documentos da fábrica → lotes registrados e estoque atualizado (ou divergência registrada).
- **Dados usados:** Lote, Compra, Produto.
### P11. Contas a pagar às fábricas
- **Descrição:** cada compra gera uma obrigação de pagamento à fábrica, com valor e vencimento acordados. O financeiro controla os vencimentos, registra a data e a forma do pagamento e mantém a compra como "em aberto" até a quitação. O pagamento só deve ser feito após o recebimento e conferência da mercadoria.
- **Participantes:** setor financeiro, gerente financeiro.
- **Entrada → Saída:** compra recebida e conferida → pagamento efetuado e registrado.
- **Dados usados:** Compra, Fornecedor (sugestão de entidade futura: Pagamento de compra).
## 2.3 Processos de Apoio
 
### P12. Controle de estoque e validade
- **Descrição:** o estoque é controlado por lote, com quantidade e validade. A cada entrada (P10) e saída (P6, P7) a quantidade é atualizada. O sistema sinaliza produtos com estoque abaixo do mínimo e lotes próximos do vencimento, e emite relatório de validade. Lote vencido é bloqueado para venda.
- **Participantes:** equipe de estoque.
- **Entrada → Saída:** movimentações de entrada e saída → saldo atualizado, alertas de reposição e de validade.
- **Dados usados:** Lote, Produto.
### P13. Gestão de pessoal e de vendas por marca
- **Descrição:** a empresa tem 9 funcionários e duas marcas comerciais (Tutti Capelli e Outlet Hair). A gerência acompanha as vendas por marca (qual marca vende mais, para quais distribuidores) e a atuação da equipe, usando os pedidos emitidos, para definir reposição, ações comerciais e distribuição de tarefas.
- **Participantes:** gerente, funcionários.
- **Entrada → Saída:** pedidos e vendas do período → relatório de vendas por marca e por funcionário.
- **Dados usados:** Pedido, Produto (sugestão de entidades futuras: Marca e Funcionário).

## Fluxograma:  

O fluxograma abaixo representa os processos integrados da Unileste Comércio LTDA., incluindo cadastro de distribuidores, pedidos, pagamentos, compras, controle de estoque, logística, entrega e atualização de relatórios.

![Fluxograma Geral](Docs/Fluxograma1.1.png)

**Legenda:**
- 🔵 Azul = Processo
- 🔶 Rosa = Decisão
- ➡️ Setas = Fluxo de execução

---

# 3. Requisitos do Sistema


## 3.1 Requisitos Funcionais

- O sistema deve permitir realizar novos cadastros de distribuidores.

- O sistema deve possibilitar o controle de estoque, incluindo quantidade e validade dos produtos.

- O sistema deve emitir relatórios de validade dos produtos em estoque.

- O sistema deve permitir o controle de pagamentos dos distribuidores/clientes.

- O sistema deve possibilitar a geração de pedidos de compra.

- O sistema deve registrar as notas fiscais relacionadas aos pedidos.

## 3.2 Requisitos Não Funcionais

- **Segurança:** garantir a proteção dos dados dos distribuidores e das transações financeiras.

- **Usabilidade:** interface simples e intuitiva para facilitar o uso por funcionários e administradores.

- **Desempenho:** respostas rápidas às consultas de estoque e relatórios.

- **Disponibilidade:** sistema acessível em tempo integral, evitando interrupções nas operações.

- **Escalabilidade:** capacidade de expansão para suportar aumento no número de distribuidores e produtos.

---

# 4. Regras de Negócio

## 4.1 Regras operacionais
 
### Cadastro
 
| ID | Regra |
| --- | --- |
| RN01 | A empresa vende **exclusivamente a distribuidores**, que são pessoas jurídicas. Não há venda ao consumidor final, e só distribuidor cadastrado e ativo pode fazer pedido. |
| RN02 | Todo distribuidor e todo fornecedor deve ter **CNPJ válido** (14 dígitos com dígitos verificadores corretos) e **único**: não pode existir dois cadastros com o mesmo CNPJ. |
 
### Pedido e condições comerciais
 
| ID | Regra |
| --- | --- |
| RN03 | Não se vende produto sem **estoque disponível**: a quantidade pedida não pode exceder a quantidade em lotes válidos. |
| RN04 | O valor total de um pedido não pode ser inferior ao **pedido mínimo** de R$50,00 . Exceções só com autorização do gerente. |
| RN05 | O preço de cada item é o da **tabela de preços vigente na data do pedido** e fica gravado no item, de modo que mudanças posteriores de preço não alteram pedidos já emitidos. |
| RN06 | Cada distribuidor tem um **limite de crédito** de R$1.000,00 e um **prazo máximo de pagamento** de até o fechamento do mês Se o saldo em aberto somado ao novo pedido ultrapassar o limite, o pedido só é liberado com autorização do gerente financeiro. |
| RN07| Um pedido só é **liberado** mediante pagamento ou mediante acordo formal com o gerente financeiro para pagamento futuro. |
 
### Faturamento
 
| ID | Regra |
| --- | --- |
| RN08 | A **nota fiscal** só pode ser emitida com todos os dados obrigatórios preenchidos e conforme as normas fiscais e tributárias vigentes. |
| RN09 | Todo pedido liberado gera uma única nota fiscal, e cada nota pertence a um único pedido. O valor da nota é igual ao total do pedido. |
 
### Estoque
 
| ID | Regra |
| --- | --- |
| RN10 | É **proibido vender produto vencido**. Lote com validade ultrapassada fica bloqueado para venda. |
| RN11 | A saída de produtos segue o critério **FEFO** (*First Expired, First Out*): sai primeiro o lote com validade mais próxima do vencimento. |
| RN12 | Todo produto tem um **estoque mínimo** definido. Quando a quantidade disponível fica igual ou abaixo desse mínimo, o produto entra na lista de reposição e deve ser incluído no próximo pedido de compra. *(Reescrita da antiga regra "O sistema deve emitir aviso…", que era um requisito: o aviso em si passa a constar apenas na Seção 3.)* |
| RN13 | Lote com validade restante inferior a 30 é considerado de **validade crítica**: só é vendido com ciência do distribuidor ou autorização do gerente. |
 
### Devolução e troca (pós-venda)
 
| ID | Regra |
| --- | --- |
| RN14 | A **devolução ou troca** só é aceita nos casos de produto avariado, vencido ou divergente do pedido, e deve ser solicitada em até 30 dias após o recebimento. |
| RN15 | Toda devolução deve ser registrada com **motivo, nota fiscal e lote de origem**. Produto devolvido por avaria ou vencimento não retorna ao estoque vendável. |
| RN16 | A devolução aceita resulta em troca do produto, crédito para o distribuidor ou estorno, por decisão do gerente. |
 
### Compras e recebimento
 
| ID | Regra |
| --- | --- |
| RN17 | Compras só podem ser feitas a **fornecedores cadastrados e ativos**. |
| RN18 | Toda mercadoria recebida da fábrica passa por **conferência no recebimento**: produto, quantidade, número do lote, validade e integridade, contra a compra e a nota do fornecedor. Divergências são registradas e comunicadas à fábrica. |
| RN19 | Só entra no estoque o produto **conferido e aprovado**. Todo lote tem número, validade e **uma única compra de origem**. |
| RN20 | Cada compra gera uma obrigação de pagamento à fábrica com vencimento definido. O pagamento só é feito após a conferência da mercadoria recebida. |
 
## 4.2 Restrições organizacionais e legais
 
| ID | Restrição |
| --- | --- |
| RN21 | A liberação de pedidos está condicionada às políticas internas de pagamento, que exigem quitação imediata ou autorização do gerente financeiro. |
| RN22 | O controle de estoque deve atender às exigências legais de validade dos produtos, garantindo que nenhum item vencido seja comercializado. |
| RN23 | A emissão de notas fiscais deve seguir as normas fiscais e tributárias vigentes, e os documentos fiscais são guardados por **5 anos**. |
| RN24 | Só podem ser comercializados cosméticos **regularizados na ANVISA** (notificação ou registro, conforme o grau de risco do produto) e com rotulagem conforme a regulamentação vigente (incluindo lote e validade). |
| RN25 | Os **dados de contato** de distribuidores e fornecedores (inclusive de pessoas físicas responsáveis) devem ser tratados conforme a **LGPD** (Lei nº 13.709/2018): uso apenas para as finalidades do negócio (venda, cobrança, entrega, emissão fiscal), acesso restrito a quem precisa e guarda pelo prazo necessário. |

---

# 5. Dicionário de Dados Conceitual (Preliminar)

## Entidade: Distribuidor

| Atributo | Descrição | Regra de negócio associada |
| --- | --- | --- |
| id_distribuidor (PK) | Identificador único do distribuidor | Obrigatório, valor único e (chave primária) |
| nome | Nome do distribuidor | Obrigatório |
| CNPJ | Cadastro Nacional da Pessoa Jurídica | Deve ser válido e único |
| endereço | Localização do distribuidor | Obrigatório |
| telefone | Contato principal do distribuidor | Opcional |

## Entidade: Produto

| Atributo | Descrição | Regra de negócio associada |
| --- | --- | --- |
| id_produto (PK) | Identificador único do produto | Obrigatório, valor único e (chave primária) |
| nome | Nome comercial do produto | Obrigatório |
| tipo | Classificação do produto (ex.: Shampoo, Condicionador, Máscara Capilar, etc.) | Obrigatório e deve pertencer aos tipos permitidos pelo sistema |
| preço | Valor de venda do produto | Deve ser positivo |

## Entidade: Pedido

| Atributo | Descrição | Regra de negócio associada |
| --- | --- | --- |
| id_pedido (PK) | Identificador único do pedido | Obrigatório, valor único e (chave primária) |
| data | Data de emissão do pedido | Obrigatório |
| status | Situação do pedido (pendente, pago, entregue) | Deve seguir valores pré-definidos |
| id_distribuidor (FK) | Identificador do distribuidor que realizou o pedido | Obrigatório e (chave estrangeira) |

> Observação: no modelo conceitual atual, o Pedido não possui mais os atributos id_produto e quantidade diretamente, pois a quantidade solicitada de cada produto é tratada no relacionamento Pedido-Produto.

## Entidade: Nota Fiscal

| Atributo | Descrição | Regra de negócio associada |
| --- | --- | --- |
| id_nf (PK) | Identificador único da nota | Obrigatório, valor único e (chave primária) |
| número | Número oficial da nota | Obrigatório e único |
| data | Data de emissão | Obrigatório |
| valor | Valor total da nota | Deve ser positivo |
| id_pedido (FK) | Identificador do pedido associado | Obrigatório e (chave estrangeira) |

## Entidade: Pagamento

| Atributo | Descrição | Regra de negócio associada |
| --- | --- | --- |
| id_pagamento (PK) | Identificador único do pagamento | Obrigatório e (chave primária) |
| Data | Data do pagamento | Obrigatório |
| Valor | Valor pago | Deve ser positivo |
| Forma | Forma de pagamento (boleto, transferência, etc.) | Obrigatório |
| id_pedido (FK) | Identificador do pedido associado | Obrigatório e (chave estrangeira) |

## Entidade: Fornecedor

| Atributo | Descrição | Regra de negócio associada |
| --- | --- | --- |
| id_fornecedor (PK) | Identificador único do fornecedor | Obrigatório, valor único e (chave primária) |
| nome | Nome do fornecedor | Obrigatório |
| CNPJ | Cadastro Nacional da Pessoa Jurídica | Deve ser válido e único |
| endereço | Endereço do fornecedor | Obrigatório |
| telefone | contato do fornecedor | Obrigatório |

## Entidade: Compra

| Atributo | Descrição | Regra de negócio associada |
| --- | --- | --- |
| id_compra (PK)| Identificador único da compra | Obrigatório, valor único e (Chave primária) |
| data | Data da compra | Obrigatório |
| id_fornecedor (FK) | Identificador do fornecedor | Obrigatório e (chave estrangeira) |
| Valor | Valor da compra | Deve ser positivo |

## Entidade: Lote

| Atributo | Descrição | Regra de negócio associada |
| --- | --- | --- |
| id_lote (PK) | Identificador único do lote | Obrigatório, valor único e (chave primária) |
| id_compra (FK) | Identificador da compra que originou o lote | Obrigatório e (Chave estrangeira) |
| id_produto (FK) | Identificador do produto ao qual o lote pertence   | Obrigatório e (chave estrangeira) |
| quantidade | Quantidade de produtos existentes no lote | Obrigatório e deve ser maior que zero |  
| validade | Data e validade do lote | Obrigatório e deve ser uma data válida igual ou posterior à data da compra |

--- 

# 6. Modelagem Conceitual (Entidades, Atributos, Relacionamentos)

## Entidades reconhecidas

Entidade        | Justificativa
----------------|------------------------------------------------------------
Distribuidor    | Representa os parceiros que revendem os produtos da empresa.
Produto         | Representa os itens comercializados pela organização.
Pedido          | Formaliza a solicitação de compra feita pelos distribuidores e relaciona-se diretamente com os produtos solicitados.
Nota Fiscal     | Documento fiscal obrigatório que valida cada transação.
Pagamento       | Registra a quitação financeira dos pedidos.
Fornecedor      | Representa as fábricas terceirizadas responsáveis pelo fornecimento dos produtos.
Compra          | Representa a aquisição de produtos junto aos fornecedores.
Lote            | Controla os lotes recebidos, permitindo rastrear quantidade, validade e origem da compra.

<!-- Nota: nesta primeira etapa, a entidade Nota Fiscal representa apenas a nota fiscal de venda (vinculada ao Pedido). A nota fiscal de compra, emitida pela fábrica fornecedora e recebida no processo de entrada em estoque (ver Fluxograma), será incorporada ao modelo em uma etapa futura, junto com o refinamento do relacionamento Compra–Estoque. -->

### Relacionamentos ajustados

- Um Distribuidor realiza um Pedido.
- Um Pedido é associado a um ou mais Produtos, sendo a quantidade solicitada tratada como atributo do relacionamento Pedido-Produto.
- Cada Pedido pode gerar uma Nota Fiscal e registrar um Pagamento.

## Atributos e classificações

Os atributos de cada entidade estão descritos no Dicionário de Dados Conceitual (Seção 5), contendo sua identificação, descrição e respectivas regras de negócio.

## Classificação dos atributos

**Chaves Primárias (PK):** id_distribuidor, id_produto, id_pedido, id_nf, id_pagamento, id_fornecedor, id_compra e id_lote.

**Chaves Estrangeiras (FK):** id_distribuidor em Pedido; id_pedido em Nota Fiscal; id_pedido em Pagamento; id_fornecedor em Compra; id_compra e id_produto em Lote.

**Atributos descritivos:** nome, endereço, telefone, data, status, valor, forma, tipo, número, quantidade e validade.

## Relacionamentos pertinentes

Relacionamento                  | Descrição
--------------------------------|------------------------------------------------------------
Distribuidor -> Pedido          | Um distribuidor pode realizar vários pedidos, enquanto cada pedido pertence a um único distribuidor.
Pedido -> Produto               | Um pedido pode incluir vários produtos, e cada produto pode aparecer em vários pedidos; a quantidade solicitada de cada produto é um atributo do relacionamento.
Pedido -> Nota Fiscal           | Um pedido pode gerar uma única nota fiscal, e cada nota fiscal pertence a um único pedido.
Pedido -> Pagamento             | Um pedido pode ter um ou mais pagamentos associados.
Fornecedor -> Compra            | Um fornecedor pode realizar várias vendas para a organização, enquanto cada compra pertence a um único fornecedor.
Compra -> Lote                  | Uma compra pode gerar vários lotes, e cada lote é originado por uma única compra.
Produto -> Lote                 | Um produto pode possuir diversos lotes, enquanto cada lote pertence a um único produto.

## Restrições e políticas organizacionais aplicadas ao modelo

Restrição/Política               | Impacto no modelo
---------------------------------|------------------------------------------------------------
Um pedido deve estar vinculado a um distribuidor cadastrado. | Garante a integridade dos pedidos.
Cada produto incluído no pedido deve existir no cadastro de produtos. | Impede a inclusão de produtos inexistentes.
A quantidade solicitada de cada produto no pedido deve ser maior que zero. | Evita registros inválidos no relacionamento Pedido-Produto.
A nota fiscal deve estar vinculada a um único pedido. | Mantém a conformidade fiscal.
Um lote deve pertencer simultaneamente a uma única compra e a um único produto. | Garante a rastreabilidade do estoque.
Produtos não podem ser comercializados após o vencimento. | O atributo validade do lote deve ser controlado.
Valores monetários de compras, pagamentos e notas fiscais devem ser positivos. | Evita inconsistências financeiras.

---

# 7. Diagrama Entidade-Relacionamento (DER)

## DER da UNILESTE

![DER_2.0](Docs/DER_2.0.jpg)

## Entidades e Relacionamentos

<!--Nota: O arquivo de imagem do DER está anexado separadamente na pasta raiz deste repositório. -->

Entidade        | Relacionamento                          | Cardinalidade
----------------|-----------------------------------------|--------------------------------------------
Distribuidor    | Realiza Pedido                          | 1 Distribuidor pode realizar N Pedidos
Pedido          | Solicita Produto                        | 1 Pedidos podem incluir N Produtos
Produto         | Está em Pedido                          | 1 Produtos podem aparecer em N Pedidos
Pedido          | Gera Nota Fiscal                        | 1 Pedido gera 1 Nota Fiscal
Nota Fiscal     | Vinculada a Pedido                      | 1 Nota Fiscal corresponde a 1 Pedido
Pedido          | Possui Pagamento                        | 1 Pedido pode ter N Pagamentos
Fornecedor      | Fornece Compra                          | 1 Fornecedor pode fornecer N Compras
Compra          | Abastece Lote                           | 1 Compra pode gerar N Lotes 
Produto         | Pertence a Lote                         | 1 Produto pode possuir N Lotes

## Cardinalidades principais

**Distribuidor – Pedido:** 1:N (um distribuidor pode realizar vários pedidos).

**Pedido – Produto:** N:N (um pedido pode incluir vários produtos, e um produto pode aparecer em vários pedidos; a quantidade é tratada como atributo do relacionamento).

**Pedido – Nota Fiscal:** 0:1 (um pedido pode ainda não possuir nota fiscal; quando emitida, pertence a um único pedido).

**Pedido – Pagamento:** 1:N (um pedido pode possuir um ou mais pagamentos).

**Fornecedor – Compra:** 1:N (um fornecedor pode estar associado a várias compras).

**Compra – Lote:** 1:N (uma compra pode gerar vários lotes).

**Produto – Lote:** 1:N (um produto pode possuir diversos lotes).

# 8. Justificativa Técnica

## Decisões de abstração e modelagem

Decisão                         | Justificativa
--------------------------------|------------------------------------------------------------
Escolha das entidades           | Foram selecionadas entidades que representam os principais processos operacionais da Unileste Comércio LTDA.: Distribuidor, Pedido, Produto, Nota Fiscal, Pagamento, Fornecedor, Compra e Lote. Cada uma corresponde a uma etapa real observada na empresa.
Atributos obrigatórios          | Foram definidos atributos essenciais para garantir integridade dos dados, como identificadores únicos, CNPJ válido, quantidade maior que zero e valores monetários positivos.
Relacionamentos 0:1             | Foi modelado como 0:1, pois um pedido pode ainda não ter nota fiscal emitida; quando emitida, ela pertence exclusivamente a um único pedido.
Relacionamentos 1:N             | Ambos foram definidos como 1:N para representar que uma compra pode gerar vários lotes e que um produto pode existir em diversos lotes, mantendo a rastreabilidade do estoque.
Cardinalidades                  | Foram definidas para representar fielmente o funcionamento da empresa, evitando redundâncias e garantindo consistência entre pedidos, produtos, compras e lotes.
Restrições organizacionais      | Incorporadas ao modelo para atender exigências legais (nota fiscal obrigatória, validade de produtos) e políticas internas (liberação de pedidos mediante pagamento ou acordo).

## Por que não outras alternativas?

Alternativa                      | Motivo da rejeição
---------------------------------|------------------------------------------------------------
Liberar pedido sem pagamento ou acordo | Rejeitado porque não atende à política interna.
Ignorar validade dos produtos    | Rejeitado porque a validade é crítica no setor de cosméticos e impacta diretamente a conformidade legal e a qualidade.
Modelar Nota Fiscal de compra na mesma entidade | Rejeitado nesta etapa para não sobrecarregar o modelo conceitual inicial; nota fiscal de compra será tratada como extensão futura do modelo.
Permitir um lote vinculado a várias compras | Rejeitada porque cada lote deve possuir uma única compra de origem, garantindo rastreabilidade.


## Justificativa do DER

O Diagrama Entidade-Relacionamento (DER) foi elaborado para representar de forma estruturada os principais processos da Unileste Comércio LTDA.   O modelo contempla as operações de distribuição, vendas, pagamentos, compras e controle de estoque por lotes, permitindo representar o fluxo completo desde a aquisição dos produtos junto aos fornecedores até sua comercialização aos distribuidores.

Os relacionamentos definidos garantem integridade e consistência dos dados: distribuidores realizam pedidos, cada pedido gera nota fiscal, pagamento e entrega, enquanto as compras abastecem o estoque e os produtos são controlados por validade e quantidade.

Esse modelo evita redundâncias, facilita consultas e assegura que todas as etapas do fluxo de negócio estejam corretamente representadas, servindo como base sólida para o desenvolvimento de um sistema de informação confiável e eficiente.


## Conclusão

O modelo conceitual foi estruturado para refletir fielmente os processos da Unileste Comércio LTDA., garantindo integridade dos dados, conformidade legal e suporte às operações reais da empresa. As entidades, atributos, relacionamentos e cardinalidades escolhidos permitem escalabilidade e integração futura, atendendo tanto às necessidades atuais quanto à evolução do sistema.

---

## 9. Uso de Inteligência Artificial

**Ferramentas utilizadas:** Gemini e  Claude (Anthropic).

**Motivação:** agilizar a escrita, padronizar o formato exigido pelo professor e corrigir pendências apontadas na avaliação do dicionário de dados.

---

### 9.1 Prompts utilizados e respostas recebidas

#### Prompt 1 · Gemini · README, seção 1 (Caracterização da Organização)

**Prompts enviados:**

```
Preciso que você faça a correção dessas informações acima em meu trabalho da faculdade de modelagem de banco de dados que está em anexo, após vc verificar vou te passar a correção que fiz dos dois anexos e você me passa uma segunda revisão.
```
(Anexos enviados junto: README.md)

**Resposta recebida:**

```
identifiquei exatamente todos os pontos apontados pelo professor que faltavam nos critérios 9 (Dicionário de dados) e 12 (Uso de IA):

No Dicionário de Dados: A ausência das cardinalidades mínimas com explicação, o detalhamento do fluxo de dados, o collation com justificativa, a tabela de notação formal, as expressões com @ e leitura, a padronização dos prefixos (como corrigir id_nome e atributos sem prefixo), as justificativas dos índices e a seção completa de LGPD (dados sensíveis, base legal e retenção).

No Uso de IA: A necessidade de colocar os prompts reais utilizados, as respostas completas obtidas e a listagem concreta de trechos rejeitados com os devidos ajustes manuais.
```
**Prompt após revisão**

```
´Segue em anexo nosso projeto atualizado, verifique se está coerente com o esqueleto que o professor exigiu
```

** 2ª Resposta recebida:**
```
 o trabalho ficou extremamente completo, profissional e gabaritou todos os pontos que o professor tirou nota na versão anterior!Vamos fazer um checklist rápido do que você ajustou e como cada critério foi solucionado:Análise do Critério 9: Dicionário de DadosVocê resolveu todas as pendências que geravam o desconto de 0,100:Cardinalidades mínimas com explicação: A seção 1.2 detalha perfeitamente cada par (mín,máx) (como (0,n), (1,1), (0,1)) explicando o motivo comercial e estrutural de cada uma.Entidade associativa desde o início: A entidade PEDIDO_PRODUTO foi formalmente introduzida no texto conceitual e estruturada nas tabelas, desmembrando o N:N em dois relacionamentos 1:N.Fluxo de dados detalhado: A seção 2 transformou aquela linha simples de setas em um fluxo robusto de 8 etapas baseadas diretamente no seu fluxograma.Collation e Codificação: O charset utf8mb4 e a collation utf8mb4_0900_ai_ci ganharam uma justificativa técnica impecável sobre acentuação e case-insensitivity.Tabela de notação formal: A seção 4 traz a tabela de símbolos e as regras de leitura DeMarco/Yourdon.Expressões com @ e leitura: Implementadas corretamente nas entidades (ex: DISTRIBUIDOR = @id_distribuidor...) acompanhadas do parágrafo de leitura explicativa.Prefixos declarados e corrigidos: O problema do id_nome no Fornecedor foi resolvido para nm_fornecedor, e todas as colunas adotaram rigidamente os prefixos declarados (nm_, nr_, ds_, dt_, vl_, tp_, qt_, st_).Justificativa dos índices: Cada tabela agora possui uma linha dedicada explicando o porquê de cada PK, FK e índice único ou auxiliar criado.LGPD completa: A seção 8 aborda a classificação dos dados (pessoa jurídica/natural), ausência de dados sensíveis, bases legais (art. 7º), retenção (prazo tributário de 5 anos), minimização e direitos dos titulares.Análise do Critério 12: Uso de IAO seu arquivo README_secao_uso_de_IA.md estruturou perfeitamente o que o professor pediu:Prompts reais: Foram inseridos os prompts utilizados (incluindo o prompt contextual da correção realizada com o Claude).   Respostas e trechos: O modelo organiza o registro das interações e a tabela de trechos rejeitados/ajustes manuais.   Erros e reflexões: Os itens corrigidos manualmente no dicionário (como a padronização de prefixos e o ajuste do CNPJ/nomes) foram explicitados de forma transparente.   Veredito FinalO trabalho está espetacular, com padrão de documentação de engenharia de software e banco de dados de nível corporativo e universitário avançado. Pode submeter sem medo, pois todos os itens apontados pelo professor foram corrigidos com excelência técnica!
```

#### Prompt 2 · Claude · Correção dos critérios 9 e 12 (26/10/2026)

**Prompt enviado:**
```
claude acima esta oque eu preciso corrigir em meu trabalho da faculdade sobre modelagem de banco de dados e em anexo vou te passar tudo que ja esta em meu trabalho, preciso que voce corrija somente oque eu preciso que esta acima.
para te deixar sabendo preciso corrigir essas situações por que preciso fazer um banco de dados no SQL.
```
(Anexos enviados junto: Dicionario_de_dados.html, README.md, Fluxograma1_1.png, DER_2_0.jpg, e a lista de itens faltantes do critério 9 e 12.)

**Resposta recebida:**

```
o Claude devolveu o arquivo `Dicionario_de_dados.html` (v1.1) e este modelo de seção. Principais mudanças feitas no dicionário:
- cardinalidades (mín,máx) explicadas uma a uma, a partir do DER;
- entidade associativa PEDIDO_PRODUTO identificada na seção 1;
- fluxo de dados em 8 etapas, baseado no fluxograma;
- charset `utf8mb4` e collation `utf8mb4_0900_ai_ci` justificados;
- tabela de notação formal, expressões com `@` e parágrafo de leitura;
- prefixos aplicados de fato nas colunas (inclusive correção de `id_nome` para `nm_fornecedor`);
- justificativa de cada índice;
- seção de LGPD (dados sensíveis, base legal e retenção).
```

---

### 9.2 Fontes consultadas e verificadas

As informações sobre a empresa foram validadas pelo grupo com base nos dados reais da Unileste Comércio LTDA. e na visita de campo.

As bases legais e os prazos de retenção da LGPD (seção 8 do dicionário) são propostas elaboradas com apoio do Claude (Anthropic). Elas se apoiam nos artigos 5º, 6º, 7º, 15, 16, 18 e 46 da Lei nº 13.709/2018 (LGPD) e no prazo tributário de 5 anos usado como referência para a guarda de documentos fiscais. Essas propostas não foram validadas com o contador ou o jurídico da empresa; por isso estão marcadas no dicionário como propostas do grupo, a confirmar antes de qualquer uso real.

- O grupo leu os artigos citados diretamente no texto da Lei nº 13.709/2018, disponível no site do Planalto, e conferiu que cada base legal corresponde ao tratamento descrito.

### 9.3 Justificativa da escolha final

O grupo manteve todas as alterações propostas pela IA no dicionário de dados, depois de revisar cada uma e concluir que faziam sentido para o projeto da Unileste Comércio LTDA. 

As propostas de LGPD (bases legais e prazos de retenção) foram mantidas como propostas do grupo, a serem confirmadas com o contador e o jurídico da empresa antes de qualquer uso real.

Mesmo mantendo as sugestões, o grupo as tratou como apoio à redação e não como decisão final: o conteúdo foi conferido contra os documentos do projeto e os dados da empresa, e a responsabilidade pelo trabalho entregue é dos integrantes.

### 9.4 Reflexão crítica

O uso da IA trouxe agilidade e organização, mas exigiu revisão crítica para evitar generalizações e garantir que os dados refletissem fielmente a empresa estudada.


