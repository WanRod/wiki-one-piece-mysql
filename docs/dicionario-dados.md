# Dicionário de dados: banco `onepiece_wiki`

Descrição de todas as tabelas, colunas, tipos e restrições do esquema físico definido em [`sql/01-banco-e-dados.sql`](../sql/01-banco-e-dados.sql). Os diagramas correspondentes estão em [`diagrama/der.png`](diagrama/der.png) (entidade-relacionamento) e [`diagrama/diagrama-classes.png`](diagrama/diagrama-classes.png) (classes).

## Convenções

| Item | Convenção |
|---|---|
| Nomes | português, `snake_case`, sem acento, tabelas no singular |
| Chave primária | coluna `id`, `INT AUTO_INCREMENT`, declarada como `PRIMARY KEY (id)` |
| Chave estrangeira | coluna `<tabela>_id`, constraint `fk_<tabela>_<referência>` |
| Índice único | `CREATE UNIQUE INDEX uq_<tabela>_<coluna>` logo após a tabela |
| CHECK | constraint `ck_<tabela>_<regra>` |
| Datas da obra | `VARCHAR(10)` no formato `AAAA-MM-DD`, no calendário Kaienreki da obra. Mês ou dia desconhecido é gravado como `01` (ex.: só o ano 1518 vira `1518-01-01`). O tipo `DATE` não foi usado porque o MySQL não garante anos anteriores a 1000. |
| Período | data final nula indica que o vínculo ainda vigora ou que o fim não é conhecido; data inicial nula indica início desconhecido. A data final nunca é anterior à inicial. |
| Formato de data | toda coluna de data tem um CHECK `REGEXP_LIKE(coluna, '^[0-9]{4}-(0[1-9]\|1[0-2])-(0[1-9]\|[12][0-9]\|3[01])$')` |

Abreviações usadas nas tabelas abaixo: **PK** chave primária, **FK** chave estrangeira, **UQ** índice único, **AI** auto incremento.

## Domínios fixos (ENUM)

| Coluna | Valores |
|---|---|
| `local.area` | `north_blue`, `south_blue`, `west_blue`, `east_blue`, `grand_line`, `red_line`, `calm_belt` (Calm Belt), `ceu` (ilhas do céu) e `fundo_do_mar` (Ilha dos Homens-Peixe e arredores, sob a Red Line) |
| `arco.saga` | `east_blue`, `alabasta`, `ilha_do_ceu`, `water_7`, `thriller_bark`, `guerra_de_marineford`, `ilha_dos_homens_peixe`, `dressrosa`, `yonkou`, `final` |
| `akuma_no_mi.tipo` | `paramecia`, `zoan`, `logia` |
| `navio.situacao` | `ativo`, `destruido`, `desaparecido` |
| `personagem_haki.haki` | `observacao`, `armamento`, `conquistador` |

Esses domínios ficaram como ENUM porque têm menos de 15 valores na obra, e o enunciado exige 15 registros em toda tabela.

---

## Cadastros base

### `raca`
Raças do universo de One Piece (Humano, Gigante, Homem-Peixe, Povo-Sereia, Mink...). Tribos, como as Kuja, não são raças.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador da raça |
| `nome` | VARCHAR(120) | NOT NULL, UQ `uq_raca_nome` | Nome da raça |

### `categoria_personagem`
Ocupação principal do personagem (Pirata, Marinheiro, Revolucionário, Civil...). Títulos como Yonkou e Shichibukai ficam em `titulo`.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador da categoria |
| `nome` | VARCHAR(120) | NOT NULL, UQ `uq_categoria_personagem_nome` | Nome da ocupação |

### `titulo`
Títulos e honrarias que um personagem pode receber e perder ao longo da história (Yonkou, Shichibukai, Pior Geração...).

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador do título |
| `nome` | VARCHAR(120) | NOT NULL, UQ `uq_titulo_nome` | Nome do título |

### `organizacao`
Organizações do mundo (Marinha, Governo Mundial, Exército Revolucionário, CP9...).

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador da organização |
| `nome` | VARCHAR(120) | NOT NULL, UQ `uq_organizacao_nome` | Nome da organização |

### `cargo`
Funções exercidas em tripulações (Capitão, Imediato, Médico, Navegador...) e patentes ou funções em organizações (Almirante, Vice-Almirante...). A mesma tabela atende os dois vínculos.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador do cargo |
| `nome` | VARCHAR(120) | NOT NULL, UQ `uq_cargo_nome` | Nome do cargo |

### `akuma_no_mi`
Frutas do Diabo. Na obra só existe uma fruta de cada no mundo, por isso o nome é único.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador da fruta |
| `nome` | VARCHAR(120) | NOT NULL, UQ `uq_akuma_no_mi_nome` | Nome original da fruta (ex.: Gomu Gomu no Mi) |
| `tipo` | ENUM | NOT NULL, DEFAULT `'paramecia'` | Classe da fruta: `paramecia`, `zoan` ou `logia` |
| `poder` | VARCHAR(255) | NULL | Descrição do poder; subtipos de Zoan (ancestral, mítica) são descritos aqui. Nulo quando o poder não foi revelado |

### `categoria_arma`
Categorias de armas (Katana, Sabre, Machado, Arma de Fogo, Bastão...).

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador da categoria |
| `nome` | VARCHAR(120) | NOT NULL, UQ `uq_categoria_arma_nome` | Nome da categoria |

### `local`
Ilhas, países e cidades do mundo, cada um em uma área.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador do local |
| `nome` | VARCHAR(120) | NOT NULL, UQ `uq_local_nome` | Nome do local (ex.: Alabasta, Wano, Marineford) |
| `area` | ENUM | NOT NULL | Área do mundo em que o local fica |

### `arco`
Arcos da história, agrupados em sagas e situados no tempo da obra.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador do arco |
| `nome` | VARCHAR(120) | NOT NULL, UQ `uq_arco_nome` | Nome do arco (ex.: Romance Dawn, Alabasta, Wano) |
| `saga` | ENUM | NOT NULL | Saga a que o arco pertence |
| `data_inicio` | VARCHAR(10) | NOT NULL, CHECK `ck_arco_data_inicio` | Data Kaienreki em que o arco começa |
| `data_fim` | VARCHAR(10) | NULL, CHECK `ck_arco_data_fim` | Data Kaienreki em que o arco termina; nula se o arco ainda está em andamento |

Restrição de tabela: `ck_arco_periodo` (data_fim >= data_inicio).

### `evento`
Batalhas e acontecimentos marcantes (Guerra de Marineford, Incidente de God Valley...).

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador do evento |
| `nome` | VARCHAR(120) | NOT NULL, UQ `uq_evento_nome` | Nome do evento |
| `local_id` | INT | NOT NULL, FK → `local` (ON UPDATE CASCADE, ON DELETE RESTRICT) | Onde o evento ocorreu |
| `arco_id` | INT | NULL, FK → `arco` (ON UPDATE CASCADE, ON DELETE RESTRICT) | Arco em que o evento acontece; nulo para fatos do passado que não pertencem a nenhum arco |
| `data_ocorrencia` | VARCHAR(10) | NULL, CHECK `ck_evento_data_ocorrencia` | Data Kaienreki do evento |

---

## Entidades principais

### `personagem`
Personagens da obra. É a tabela central do banco.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador do personagem |
| `nome` | VARCHAR(120) | NOT NULL, UQ `uq_personagem_nome` | Nome completo (ex.: Monkey D. Luffy); não admite homônimos |
| `epiteto` | VARCHAR(120) | NULL | Alcunha (ex.: Chapéu de Palha) |
| `raca_id` | INT | NULL, FK → `raca` (ON UPDATE CASCADE, ON DELETE RESTRICT) | Raça do personagem; nula quando a fonte não a informa |
| `categoria_personagem_id` | INT | NOT NULL, FK → `categoria_personagem` (ON UPDATE CASCADE, ON DELETE RESTRICT) | Ocupação principal |
| `local_origem_id` | INT | NULL, FK → `local` (ON UPDATE CASCADE, ON DELETE SET NULL) | Local de nascimento ou criação |
| `arco_estreia_id` | INT | NULL, FK → `arco` (ON UPDATE CASCADE, ON DELETE SET NULL) | Arco em que o personagem aparece pela primeira vez |
| `esta_vivo` | BOOLEAN | NOT NULL, DEFAULT TRUE | Indica se o personagem está vivo no ponto atual da história |

### `tripulacao`
Tripulações piratas (Piratas do Chapéu de Palha, Piratas do Barba Branca...).

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador da tripulação |
| `nome` | VARCHAR(120) | NOT NULL, UQ `uq_tripulacao_nome` | Nome da tripulação |
| `fundador_id` | INT | NULL, UQ `uq_tripulacao_fundador_id`, FK → `personagem` (ON UPDATE CASCADE, ON DELETE RESTRICT) | Personagem que fundou a tripulação; nulo quando a fonte não o informa. O índice único torna a relação 1:1: cada personagem funda no máximo uma tripulação |

### `arma`
Armas com nome próprio (Yoru, Wado Ichimonji...).

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador da arma |
| `nome` | VARCHAR(120) | NOT NULL, UQ `uq_arma_nome` | Nome da arma |
| `categoria_arma_id` | INT | NOT NULL, FK → `categoria_arma` (ON UPDATE CASCADE, ON DELETE RESTRICT) | Categoria da arma |

### `navio`
Navios da obra (Going Merry, Thousand Sunny, Moby Dick...).

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador do navio |
| `nome` | VARCHAR(120) | NOT NULL, UQ `uq_navio_nome` | Nome do navio |
| `construtor_id` | INT | NULL, FK → `personagem` (ON UPDATE CASCADE, ON DELETE SET NULL) | Carpinteiro responsável pela construção; nulo se desconhecido |
| `situacao` | ENUM | NOT NULL, DEFAULT `'ativo'` | Situação atual: `ativo`, `destruido` ou `desaparecido` |

---

## Ligações e histórico

Nas tabelas abaixo, excluir um personagem exclui junto o histórico dele (CASCADE). Já as entidades referenciadas no histórico de vários personagens (título, organização, tripulação, fruta, arma) não podem ser excluídas enquanto houver registro que as use (RESTRICT).

### `personagem_haki`
Tipos de Haki que cada personagem domina. Há um registro por tipo; o nível avançado é marcado no próprio registro, de modo que o avançado substitui o básico.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador do registro |
| `personagem_id` | INT | NOT NULL, FK → `personagem` (ON UPDATE CASCADE, ON DELETE CASCADE) | Personagem |
| `haki` | ENUM | NOT NULL | Tipo de Haki: `observacao`, `armamento` ou `conquistador` |
| `avancado` | BOOLEAN | NOT NULL, DEFAULT FALSE | Indica se o personagem domina a forma avançada: Visão do Futuro (observação), Emissão ou Destruição Interna (armamento) e Infusão (conquistador) |

Restrição de tabela: UQ `uq_personagem_haki` (personagem_id, haki).

### `personagem_titulo`
Títulos recebidos por cada personagem e o período em que os teve (N:N entre personagem e título).

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador do registro |
| `personagem_id` | INT | NOT NULL, FK → `personagem` (ON UPDATE CASCADE, ON DELETE CASCADE) | Personagem |
| `titulo_id` | INT | NOT NULL, FK → `titulo` (ON UPDATE CASCADE, ON DELETE RESTRICT) | Título |
| `data_obtencao` | VARCHAR(10) | NULL, CHECK `ck_personagem_titulo_data_obtencao` | Data Kaienreki em que o título foi obtido |
| `data_perda` | VARCHAR(10) | NULL, CHECK `ck_personagem_titulo_data_perda` | Data Kaienreki em que o título foi perdido; nula se ainda o tem ou se a perda não tem data conhecida |

Restrição de tabela: `ck_personagem_titulo_periodo` (data_perda >= data_obtencao).

### `personagem_organizacao`
Participação de personagens em organizações, com cargo e período (N:N entre personagem e organização).

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador do registro |
| `personagem_id` | INT | NOT NULL, FK → `personagem` (ON UPDATE CASCADE, ON DELETE CASCADE) | Personagem |
| `organizacao_id` | INT | NOT NULL, FK → `organizacao` (ON UPDATE CASCADE, ON DELETE RESTRICT) | Organização |
| `cargo_id` | INT | NULL, FK → `cargo` (ON UPDATE CASCADE, ON DELETE RESTRICT) | Cargo ou patente; nulo se desconhecido |
| `data_entrada` | VARCHAR(10) | NULL, CHECK `ck_personagem_organizacao_data_entrada` | Data Kaienreki de entrada |
| `data_saida` | VARCHAR(10) | NULL, CHECK `ck_personagem_organizacao_data_saida` | Data Kaienreki de saída; nula se ainda é membro ou se a saída não tem data conhecida |

Restrição de tabela: `ck_personagem_organizacao_periodo` (data_saida >= data_entrada).

### `personagem_tripulacao`
Participação de personagens em tripulações, com cargo e período (N:N entre personagem e tripulação). Quem sai e volta ganha um novo registro.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador do registro |
| `personagem_id` | INT | NOT NULL, FK → `personagem` (ON UPDATE CASCADE, ON DELETE CASCADE) | Personagem |
| `tripulacao_id` | INT | NOT NULL, FK → `tripulacao` (ON UPDATE CASCADE, ON DELETE RESTRICT) | Tripulação |
| `cargo_id` | INT | NULL, FK → `cargo` (ON UPDATE CASCADE, ON DELETE RESTRICT) | Função na tripulação; nula se desconhecida |
| `data_entrada` | VARCHAR(10) | NULL, CHECK `ck_personagem_tripulacao_data_entrada` | Data Kaienreki de entrada |
| `data_saida` | VARCHAR(10) | NULL, CHECK `ck_personagem_tripulacao_data_saida` | Data Kaienreki de saída; nula se ainda é membro ou se a saída não tem data conhecida |

Restrição de tabela: `ck_personagem_tripulacao_periodo` (data_saida >= data_entrada).

### `personagem_akuma_no_mi`
Usuários de cada Akuma no Mi ao longo do tempo (N:N). Uma fruta pode ter vários usuários em sequência (Mera Mera no Mi: Ace e depois Sabo), e um personagem pode ter mais de uma fruta (Barba Negra).

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador do registro |
| `personagem_id` | INT | NOT NULL, FK → `personagem` (ON UPDATE CASCADE, ON DELETE CASCADE) | Usuário |
| `akuma_no_mi_id` | INT | NOT NULL, FK → `akuma_no_mi` (ON UPDATE CASCADE, ON DELETE RESTRICT) | Fruta |
| `despertada` | BOOLEAN | NOT NULL, DEFAULT FALSE | Indica se o usuário despertou a fruta |
| `data_obtencao` | VARCHAR(10) | NULL, CHECK `ck_personagem_akuma_no_mi_data_obtencao` | Data Kaienreki em que a fruta foi comida |
| `data_perda` | VARCHAR(10) | NULL, CHECK `ck_personagem_akuma_no_mi_data_perda` | Data Kaienreki em que o poder foi perdido (ex.: morte do usuário) |

Restrição de tabela: `ck_personagem_akuma_no_mi_periodo` (data_perda >= data_obtencao).

### `personagem_arma`
Posse de armas ao longo do tempo (N:N). A mesma arma pode passar de um dono a outro (Wado Ichimonji: Kuina e depois Zoro).

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador do registro |
| `personagem_id` | INT | NOT NULL, FK → `personagem` (ON UPDATE CASCADE, ON DELETE CASCADE) | Dono |
| `arma_id` | INT | NOT NULL, FK → `arma` (ON UPDATE CASCADE, ON DELETE RESTRICT) | Arma |
| `data_obtencao` | VARCHAR(10) | NULL, CHECK `ck_personagem_arma_data_obtencao` | Data Kaienreki em que a arma foi obtida |
| `data_perda` | VARCHAR(10) | NULL, CHECK `ck_personagem_arma_data_perda` | Data Kaienreki em que a arma deixou de ser do personagem |

Restrição de tabela: `ck_personagem_arma_periodo` (data_perda >= data_obtencao).

### `tripulacao_navio`
Uso de navios ao longo do tempo. O navio é usado por uma tripulação inteira ou por um personagem sozinho (casos de uso curto), nunca pelos dois no mesmo registro.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador do registro |
| `navio_id` | INT | NOT NULL, FK → `navio` (ON UPDATE CASCADE, ON DELETE CASCADE) | Navio |
| `tripulacao_id` | INT | NULL, FK → `tripulacao` (ON UPDATE RESTRICT, ON DELETE RESTRICT) | Tripulação que usou o navio |
| `personagem_id` | INT | NULL, FK → `personagem` (ON UPDATE RESTRICT, ON DELETE RESTRICT) | Personagem que usou o navio sozinho |
| `data_inicio_uso` | VARCHAR(10) | NULL, CHECK `ck_tripulacao_navio_data_inicio_uso` | Data Kaienreki de início do uso |
| `data_fim_uso` | VARCHAR(10) | NULL, CHECK `ck_tripulacao_navio_data_fim_uso` | Data Kaienreki de fim do uso; nula se ainda em uso ou se o fim não tem data conhecida |

Restrições de tabela: `ck_tripulacao_navio_dono` (exatamente uma entre `tripulacao_id` e `personagem_id` preenchida) e `ck_tripulacao_navio_periodo` (data_fim_uso >= data_inicio_uso). As FKs de `tripulacao_id` e `personagem_id` são RESTRICT também no update porque o MySQL não aceita CASCADE nem SET NULL em coluna usada em CHECK.

### `qg`
Quartéis-generais de organizações e tripulações. Cada QG pertence a uma organização ou a uma tripulação, nunca às duas.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador do QG |
| `local_id` | INT | NOT NULL, FK → `local` (ON UPDATE CASCADE, ON DELETE RESTRICT) | Local do QG |
| `organizacao_id` | INT | NULL, FK → `organizacao` (ON UPDATE RESTRICT, ON DELETE RESTRICT) | Organização dona do QG |
| `tripulacao_id` | INT | NULL, FK → `tripulacao` (ON UPDATE RESTRICT, ON DELETE RESTRICT) | Tripulação dona do QG |
| `data_instalacao` | VARCHAR(10) | NULL, CHECK `ck_qg_data_instalacao` | Data Kaienreki em que o QG passou a funcionar |
| `data_desativacao` | VARCHAR(10) | NULL, CHECK `ck_qg_data_desativacao` | Data Kaienreki em que deixou de ser QG; nula se ainda funciona ou se a desativação não tem data conhecida |

Restrições de tabela: `ck_qg_dono` (exatamente uma entre `organizacao_id` e `tripulacao_id` preenchida) e `ck_qg_periodo` (data_desativacao >= data_instalacao). As FKs de `organizacao_id` e `tripulacao_id` são RESTRICT também no update, pelo mesmo motivo de `tripulacao_navio`.

### `recompensa`
Histórico de recompensas (bounties) de cada personagem.

| Coluna | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INT | PK, AI | Identificador da recompensa |
| `personagem_id` | INT | NOT NULL, FK → `personagem` (ON UPDATE CASCADE, ON DELETE CASCADE) | Personagem procurado |
| `valor` | BIGINT | NOT NULL, CHECK `ck_recompensa_valor` (valor > 0) | Valor em berries. BIGINT porque há recompensas acima de 3 bilhões |
| `data_emissao` | VARCHAR(10) | NULL, CHECK `ck_recompensa_data_emissao` | Data Kaienreki em que a recompensa foi emitida |

---

## Resumo das restrições

| Restrição | Quantidade |
|---|---|
| Tabelas | 23 |
| PRIMARY KEY | 23 |
| FOREIGN KEY | 29 |
| Índices únicos | 16 |
| CHECK | 29 (18 de formato de data, 8 de período, 2 de dono exclusivo, 1 de valor) |
| DEFAULT | 5 (`esta_vivo`, `tipo`, `situacao`, `despertada`, `avancado`) |
