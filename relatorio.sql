 SELECT    p.id                AS "codigo",
           p.descricaocompleta AS "descrição produto",
           ne.numeronota       AS "numero nota",
           ne.dataentrada      AS "data entrada",
           (
                  SELECT te.descricao
                  FROM   tipoembalagem te
                  WHERE  te.id = p.id_tipoembalagem limit 1) AS "embalagem",
           nei.qtdembalagem                                  AS "quantidade embalagem",
           nei.quantidade,
           nei.qtdembalagem * nei.quantidade           AS "total_quantidade",
           cast (nei.custocomimpostoanterior AS money) AS "custo anterior",
           cast (nei.valor AS                   money) AS "valor",
           cast (nei.valortotal AS              money) AS "valor total",
           cast (nei.valortotalfinal AS         money) AS "total final",
           cast (nei.custocomimposto AS         money) AS "custo c/ imposto",
           cast (pc.precovenda AS               money) AS "preço_venda",
           (
                  SELECT a.descricao
                  FROM   aliquota a
                  WHERE  a.id = nei.id_aliquota) AS "icms_nfe",
           (
                  SELECT a.descricao
                  FROM   aliquota a
                  WHERE  a.id = pa.id_aliquotaconsumidor) AS "icms_sistema",
           nei.valoripi,
           (
                  SELECT tent.descricao
                  FROM   tipoentrada tent
                  WHERE  tent.id = nei.id_tipoentrada) AS "tipo_entrada",
           to_char(
                     (
                     SELECT
                            CASE
                                   WHEN pc.precovenda = 0 THEN 0
                                   WHEN pc.custocomimposto = 0 THEN 0
                                   ELSE (pc.precovenda - pc.custocomimposto) / pc.custocomimposto * 100
                            END
                     FROM   produtocomplemento pc
                     WHERE  pc.id_produto = p.id
                     AND    pc.id_loja =#LOJA:3:loja:::0:true:# ), '9990D99%') AS "margem_sob_custo"
FROM       produto p
INNER JOIN notaentradaitem nei
ON         p.id = nei.id_produto
INNER JOIN notaentrada ne
ON         nei.id_notaentrada = ne.id
AND        ne.id_loja =#LOJA:3:loja:::0:true:#
INNER JOIN tipoembalagem te
ON         te.id = p.id_tipoembalagem
INNER JOIN produtocomplemento pc
ON         p.id = pc.id_produto
AND        pc.id_loja =#LOJA:3:loja:::0:true:#
INNER JOIN produtoaliquota pa
ON         p.id = pa.id_produto
WHERE      ne.dataentrada BETWEEN '#PERIODO INICIO:7::::0:false:#' AND        '#PERIODO FIM:7::::0:false:#'
AND        ne.numeronota = #numeroNOTA:2::::0:false:#
GROUP BY   p.id,
           p.descricaocompleta,
           ne.numeronota,
           ne.dataentrada,
           embalagem,
           nei.qtdembalagem,
           nei.quantidade,
           total_quantidade,
           nei.custocomimpostoanterior,
           nei.valor,
           nei.valortotal,
           nei.valortotalfinal,
           nei.custocomimposto,
           pc.precovenda,
           icms_nfe,
           icms_sistema,
           nei.valoripi,
           tipo_entrada,
           margem_sob_custo
ORDER BY   p.descricaocompleta 
