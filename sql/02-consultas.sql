USE onepiece_wiki;

-- Q1. Listar os personagens do Clã D., em ordem alfabética
SELECT
  personagem.nome    AS nome,
  personagem.epiteto AS epiteto
FROM personagem
WHERE
  (personagem.nome LIKE '%D.%')
ORDER BY
  personagem.nome;

-- Q2. Listar os eventos da Era de Roger, entre 1480 e 1500, em ordem cronológica
SELECT
  evento.nome            AS nome,
  evento.data_ocorrencia AS data_ocorrencia
FROM evento
WHERE
  (evento.data_ocorrencia BETWEEN '1480-01-01' AND '1500-12-31')
ORDER BY
  evento.data_ocorrencia;

-- Q3. Listar os navios destruídos ou desaparecidos
SELECT
  navio.nome     AS nome,
  navio.situacao AS situacao
FROM navio
WHERE
  (navio.situacao IN ('destruido', 'desaparecido'))
ORDER BY
  navio.situacao,
  navio.nome;

-- Q4. Listar as sagas que têm arcos iniciados em 1524, depois do salto temporal
SELECT DISTINCT
  arco.saga AS saga
FROM arco
WHERE
  (arco.data_inicio LIKE '1524-%')
ORDER BY
  arco.saga;

-- Q5. Listar os 5 primeiros arcos da jornada
SELECT
  arco.nome        AS nome,
  arco.saga        AS saga,
  arco.data_inicio AS data_inicio
FROM arco
ORDER BY
  arco.data_inicio,
  arco.data_fim
LIMIT 5;

-- Q6. Contar quantos personagens existem de cada raça
SELECT
  raca.nome AS raca,
  COUNT(*)  AS quantidade_personagens
FROM personagem INNER JOIN raca ON (raca.id = personagem.raca_id)
GROUP BY
  raca.nome
ORDER BY
  quantidade_personagens DESC;

-- Q7. Mostrar a evolução da recompensa dos personagens com 3 ou mais recompensas emitidas
SELECT
  personagem.nome                 AS personagem,
  COUNT(*)                        AS quantidade_recompensas,
  MIN(recompensa.valor)           AS menor_recompensa,
  MAX(recompensa.valor)           AS maior_recompensa,
  ROUND(AVG(recompensa.valor), 2) AS media_recompensa
FROM recompensa INNER JOIN personagem ON (personagem.id = recompensa.personagem_id)
GROUP BY
  personagem.nome
HAVING
  (COUNT(*) >= 3)
ORDER BY
  maior_recompensa DESC;

-- Q8. Contar, por tipo de Haki, quantos personagens vivos o dominam e quantos chegaram ao nível avançado
SELECT
  personagem_haki.haki          AS haki,
  COUNT(*)                      AS quantidade_usuarios,
  SUM(personagem_haki.avancado) AS quantidade_avancados
FROM personagem_haki INNER JOIN personagem ON (personagem.id = personagem_haki.personagem_id)
WHERE
  (personagem.esta_vivo)
GROUP BY
  personagem_haki.haki
ORDER BY
  personagem_haki.haki;

-- Q9. Listar os membros dos Piratas do Chapéu de Palha com cargo e data de entrada, em ordem cronológica
SELECT
  personagem.nome                    AS personagem,
  cargo.nome                         AS cargo,
  personagem_tripulacao.data_entrada AS data_entrada
FROM personagem INNER JOIN personagem_tripulacao ON (personagem_tripulacao.personagem_id = personagem.id)
                INNER JOIN tripulacao ON (tripulacao.id = personagem_tripulacao.tripulacao_id)
                LEFT JOIN cargo ON (cargo.id = personagem_tripulacao.cargo_id)
WHERE
  (tripulacao.nome = 'Piratas do Chapéu de Palha')
ORDER BY
  personagem_tripulacao.data_entrada IS NULL,
  personagem_tripulacao.data_entrada,
  personagem.nome;

-- Q10. Contar quantos personagens a Marinha tem em cada patente
SELECT
  cargo.nome AS patente,
  COUNT(*)   AS quantidade_personagens
FROM personagem_organizacao INNER JOIN organizacao ON (organizacao.id = personagem_organizacao.organizacao_id)
                            INNER JOIN cargo ON (cargo.id = personagem_organizacao.cargo_id)
WHERE
  (organizacao.nome = 'Marinha')
GROUP BY
  cargo.nome
ORDER BY
  quantidade_personagens DESC;
