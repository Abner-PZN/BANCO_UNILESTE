# Relacionamentos pertinentes
_____________________________________________________________________________________________________________
|              Relacionamento                 |                          Descrição                          |
| ------------------------------------------- | ----------------------------------------------------------- |
| Distribuidor -> Pedido                      | Um distribuidor pode realizar vários pedidos                |
| Pedido -> Nota Fiscal                       | Cada pedido gera uma nota fiscal correspondente             |
| Pedido -> Pagamento                         | Um pedido pode ter um ou mais pagamentos associados         |
| Produto -> Estoque                          | Cada produto é controlado em estoque (quantidade e validade)|
| Compra -> Produto                           | Cada compra abastece o estoque com produtos adquiridos      |
| Revenda -> Produto                          | Cada revenda retira produtos do estoque                     |
| Revenda -> Distribuidor                     | Cada revenda é vinculada a um distribuidor responsável      |
| Relatório -> (Pedidos, Estoque, Pagamentos) | Relatórios consolidados são gerados com essas entidades     |       
|_____________________________________________|_____________________________________________________________|


# Restrições e políticas organizacionais aplicadas ao modelo

Restrição/Política               | Impacto no modelo
---------------------------------|------------------------------------------------------------
Pedido só pode ser liberado após pagamento ou acordo | Relacionamento Pedido-Pagamento deve ser obrigatório
Nota Fiscal só pode ser emitida com produto em estoque | Relacionamento Pedido-Nota Fiscal depende do Estoque
Produtos não podem ser vendidos após a validade | Atributo Validade do Produto deve ser controlado
Estoque não pode ter quantidade negativa | Atributo Quantidade deve ter restrição >= 0
