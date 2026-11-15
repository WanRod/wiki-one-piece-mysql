DROP DATABASE IF EXISTS onepiece_wiki;

CREATE DATABASE onepiece_wiki DEFAULT CHARACTER SET utf8mb4;

USE onepiece_wiki;

CREATE TABLE raca (
  id   INT AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  PRIMARY KEY (id)
);

CREATE UNIQUE INDEX uq_raca_nome ON raca (nome);

CREATE TABLE categoria_personagem (
  id   INT AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  PRIMARY KEY (id)
);

CREATE UNIQUE INDEX uq_categoria_personagem_nome ON categoria_personagem (nome);

CREATE TABLE titulo (
  id   INT AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  PRIMARY KEY (id)
);

CREATE UNIQUE INDEX uq_titulo_nome ON titulo (nome);

CREATE TABLE organizacao (
  id   INT AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  PRIMARY KEY (id)
);

CREATE UNIQUE INDEX uq_organizacao_nome ON organizacao (nome);

CREATE TABLE cargo (
  id   INT AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  PRIMARY KEY (id)
);

CREATE UNIQUE INDEX uq_cargo_nome ON cargo (nome);

CREATE TABLE akuma_no_mi (
  id    INT AUTO_INCREMENT,
  nome  VARCHAR(120) NOT NULL,
  tipo  ENUM('paramecia', 'zoan', 'logia') NOT NULL DEFAULT 'paramecia',
  poder VARCHAR(255) NULL,
  PRIMARY KEY (id)
);

CREATE UNIQUE INDEX uq_akuma_no_mi_nome ON akuma_no_mi (nome);

CREATE TABLE categoria_arma (
  id   INT AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  PRIMARY KEY (id)
);

CREATE UNIQUE INDEX uq_categoria_arma_nome ON categoria_arma (nome);

CREATE TABLE local (
  id   INT AUTO_INCREMENT,
  nome VARCHAR(120) NOT NULL,
  area ENUM('north_blue', 'south_blue', 'west_blue', 'east_blue', 'grand_line', 'red_line', 'calm_belt', 'ceu', 'fundo_do_mar') NOT NULL,
  PRIMARY KEY (id)
);

CREATE UNIQUE INDEX uq_local_nome ON local (nome);

-- Datas Kaienreki em texto 'AAAA-MM-DD' (DATE não garante ano < 1000); mês ou dia desconhecido vira 01 e data final nula indica que ainda vigora.
CREATE TABLE arco (
  id          INT AUTO_INCREMENT,
  nome        VARCHAR(120) NOT NULL,
  saga        ENUM('east_blue', 'alabasta', 'ilha_do_ceu', 'water_7', 'thriller_bark', 'guerra_de_marineford', 'ilha_dos_homens_peixe', 'dressrosa', 'yonkou', 'final') NOT NULL,
  data_inicio VARCHAR(10) NOT NULL,
  data_fim    VARCHAR(10) NULL,
  PRIMARY KEY (id),
  CONSTRAINT ck_arco_data_inicio CHECK (REGEXP_LIKE(data_inicio, '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$')),
  CONSTRAINT ck_arco_data_fim CHECK (REGEXP_LIKE(data_fim, '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$')),
  CONSTRAINT ck_arco_periodo CHECK ((data_fim IS NULL) OR (data_fim >= data_inicio))
);

CREATE UNIQUE INDEX uq_arco_nome ON arco (nome);

CREATE TABLE evento (
  id              INT AUTO_INCREMENT,
  nome            VARCHAR(120) NOT NULL,
  local_id        INT NOT NULL,
  arco_id         INT NULL,
  data_ocorrencia VARCHAR(10) NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_evento_local FOREIGN KEY (local_id) REFERENCES local(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_evento_arco FOREIGN KEY (arco_id) REFERENCES arco(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_evento_data_ocorrencia CHECK (REGEXP_LIKE(data_ocorrencia, '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$'))
);

CREATE UNIQUE INDEX uq_evento_nome ON evento (nome);

CREATE TABLE personagem (
  id                      INT AUTO_INCREMENT,
  nome                    VARCHAR(120) NOT NULL,
  epiteto                 VARCHAR(120) NULL,
  raca_id                 INT NULL,
  categoria_personagem_id INT NOT NULL,
  local_origem_id         INT NULL,
  arco_estreia_id         INT NULL,
  esta_vivo               BOOLEAN NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id),
  CONSTRAINT fk_personagem_raca FOREIGN KEY (raca_id) REFERENCES raca(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_personagem_categoria_personagem FOREIGN KEY (categoria_personagem_id) REFERENCES categoria_personagem(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_personagem_local_origem FOREIGN KEY (local_origem_id) REFERENCES local(id) ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_personagem_arco_estreia FOREIGN KEY (arco_estreia_id) REFERENCES arco(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE UNIQUE INDEX uq_personagem_nome ON personagem (nome);

CREATE TABLE tripulacao (
  id          INT AUTO_INCREMENT,
  nome        VARCHAR(120) NOT NULL,
  fundador_id INT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_tripulacao_fundador FOREIGN KEY (fundador_id) REFERENCES personagem(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE UNIQUE INDEX uq_tripulacao_nome ON tripulacao (nome);
CREATE UNIQUE INDEX uq_tripulacao_fundador_id ON tripulacao (fundador_id);

CREATE TABLE arma (
  id                INT AUTO_INCREMENT,
  nome              VARCHAR(120) NOT NULL,
  categoria_arma_id INT NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_arma_categoria_arma FOREIGN KEY (categoria_arma_id) REFERENCES categoria_arma(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE UNIQUE INDEX uq_arma_nome ON arma (nome);

CREATE TABLE navio (
  id            INT AUTO_INCREMENT,
  nome          VARCHAR(120) NOT NULL,
  construtor_id INT NULL,
  situacao      ENUM('ativo', 'destruido', 'desaparecido') NOT NULL DEFAULT 'ativo',
  PRIMARY KEY (id),
  CONSTRAINT fk_navio_construtor FOREIGN KEY (construtor_id) REFERENCES personagem(id) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE UNIQUE INDEX uq_navio_nome ON navio (nome);

CREATE TABLE personagem_haki (
  id            INT AUTO_INCREMENT,
  personagem_id INT NOT NULL,
  haki          ENUM('observacao', 'armamento', 'conquistador') NOT NULL,
  avancado      BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (id),
  CONSTRAINT fk_personagem_haki_personagem FOREIGN KEY (personagem_id) REFERENCES personagem(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE UNIQUE INDEX uq_personagem_haki ON personagem_haki (personagem_id, haki);

CREATE TABLE personagem_titulo (
  id            INT AUTO_INCREMENT,
  personagem_id INT NOT NULL,
  titulo_id     INT NOT NULL,
  data_obtencao VARCHAR(10) NULL,
  data_perda    VARCHAR(10) NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_personagem_titulo_personagem FOREIGN KEY (personagem_id) REFERENCES personagem(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_personagem_titulo_titulo FOREIGN KEY (titulo_id) REFERENCES titulo(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_personagem_titulo_data_obtencao CHECK (REGEXP_LIKE(data_obtencao, '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$')),
  CONSTRAINT ck_personagem_titulo_data_perda CHECK (REGEXP_LIKE(data_perda, '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$')),
  CONSTRAINT ck_personagem_titulo_periodo CHECK ((data_obtencao IS NULL) OR (data_perda IS NULL) OR (data_perda >= data_obtencao))
);

CREATE TABLE personagem_organizacao (
  id             INT AUTO_INCREMENT,
  personagem_id  INT NOT NULL,
  organizacao_id INT NOT NULL,
  cargo_id       INT NULL,
  data_entrada   VARCHAR(10) NULL,
  data_saida     VARCHAR(10) NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_personagem_organizacao_personagem FOREIGN KEY (personagem_id) REFERENCES personagem(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_personagem_organizacao_organizacao FOREIGN KEY (organizacao_id) REFERENCES organizacao(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_personagem_organizacao_cargo FOREIGN KEY (cargo_id) REFERENCES cargo(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_personagem_organizacao_data_entrada CHECK (REGEXP_LIKE(data_entrada, '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$')),
  CONSTRAINT ck_personagem_organizacao_data_saida CHECK (REGEXP_LIKE(data_saida, '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$')),
  CONSTRAINT ck_personagem_organizacao_periodo CHECK ((data_entrada IS NULL) OR (data_saida IS NULL) OR (data_saida >= data_entrada))
);

CREATE TABLE personagem_tripulacao (
  id            INT AUTO_INCREMENT,
  personagem_id INT NOT NULL,
  tripulacao_id INT NOT NULL,
  cargo_id      INT NULL,
  data_entrada  VARCHAR(10) NULL,
  data_saida    VARCHAR(10) NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_personagem_tripulacao_personagem FOREIGN KEY (personagem_id) REFERENCES personagem(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_personagem_tripulacao_tripulacao FOREIGN KEY (tripulacao_id) REFERENCES tripulacao(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_personagem_tripulacao_cargo FOREIGN KEY (cargo_id) REFERENCES cargo(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_personagem_tripulacao_data_entrada CHECK (REGEXP_LIKE(data_entrada, '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$')),
  CONSTRAINT ck_personagem_tripulacao_data_saida CHECK (REGEXP_LIKE(data_saida, '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$')),
  CONSTRAINT ck_personagem_tripulacao_periodo CHECK ((data_entrada IS NULL) OR (data_saida IS NULL) OR (data_saida >= data_entrada))
);

CREATE TABLE personagem_akuma_no_mi (
  id             INT AUTO_INCREMENT,
  personagem_id  INT NOT NULL,
  akuma_no_mi_id INT NOT NULL,
  despertada     BOOLEAN NOT NULL DEFAULT FALSE,
  data_obtencao  VARCHAR(10) NULL,
  data_perda     VARCHAR(10) NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_personagem_akuma_no_mi_personagem FOREIGN KEY (personagem_id) REFERENCES personagem(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_personagem_akuma_no_mi_akuma_no_mi FOREIGN KEY (akuma_no_mi_id) REFERENCES akuma_no_mi(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_personagem_akuma_no_mi_data_obtencao CHECK (REGEXP_LIKE(data_obtencao, '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$')),
  CONSTRAINT ck_personagem_akuma_no_mi_data_perda CHECK (REGEXP_LIKE(data_perda, '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$')),
  CONSTRAINT ck_personagem_akuma_no_mi_periodo CHECK ((data_obtencao IS NULL) OR (data_perda IS NULL) OR (data_perda >= data_obtencao))
);

CREATE TABLE personagem_arma (
  id            INT AUTO_INCREMENT,
  personagem_id INT NOT NULL,
  arma_id       INT NOT NULL,
  data_obtencao VARCHAR(10) NULL,
  data_perda    VARCHAR(10) NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_personagem_arma_personagem FOREIGN KEY (personagem_id) REFERENCES personagem(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_personagem_arma_arma FOREIGN KEY (arma_id) REFERENCES arma(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_personagem_arma_data_obtencao CHECK (REGEXP_LIKE(data_obtencao, '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$')),
  CONSTRAINT ck_personagem_arma_data_perda CHECK (REGEXP_LIKE(data_perda, '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$')),
  CONSTRAINT ck_personagem_arma_periodo CHECK ((data_obtencao IS NULL) OR (data_perda IS NULL) OR (data_perda >= data_obtencao))
);

-- O navio é usado por uma tripulação inteira ou por um personagem sozinho, nunca pelos dois.
CREATE TABLE tripulacao_navio (
  id              INT AUTO_INCREMENT,
  navio_id        INT NOT NULL,
  tripulacao_id   INT NULL,
  personagem_id   INT NULL,
  data_inicio_uso VARCHAR(10) NULL,
  data_fim_uso    VARCHAR(10) NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_tripulacao_navio_navio FOREIGN KEY (navio_id) REFERENCES navio(id) ON UPDATE CASCADE ON DELETE CASCADE,
  -- RESTRICT também no update: o MySQL proíbe CASCADE e SET NULL em coluna usada em CHECK.
  CONSTRAINT fk_tripulacao_navio_tripulacao FOREIGN KEY (tripulacao_id) REFERENCES tripulacao(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_tripulacao_navio_personagem FOREIGN KEY (personagem_id) REFERENCES personagem(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_tripulacao_navio_dono CHECK ((tripulacao_id IS NULL) <> (personagem_id IS NULL)),
  CONSTRAINT ck_tripulacao_navio_data_inicio_uso CHECK (REGEXP_LIKE(data_inicio_uso, '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$')),
  CONSTRAINT ck_tripulacao_navio_data_fim_uso CHECK (REGEXP_LIKE(data_fim_uso, '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$')),
  CONSTRAINT ck_tripulacao_navio_periodo CHECK ((data_inicio_uso IS NULL) OR (data_fim_uso IS NULL) OR (data_fim_uso >= data_inicio_uso))
);

-- O QG pertence a uma organização ou a uma tripulação, nunca às duas.
CREATE TABLE qg (
  id               INT AUTO_INCREMENT,
  local_id         INT NOT NULL,
  organizacao_id   INT NULL,
  tripulacao_id    INT NULL,
  data_instalacao  VARCHAR(10) NULL,
  data_desativacao VARCHAR(10) NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_qg_local FOREIGN KEY (local_id) REFERENCES local(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  -- RESTRICT também no update: o MySQL proíbe CASCADE e SET NULL em coluna usada em CHECK.
  CONSTRAINT fk_qg_organizacao FOREIGN KEY (organizacao_id) REFERENCES organizacao(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_qg_tripulacao FOREIGN KEY (tripulacao_id) REFERENCES tripulacao(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ck_qg_dono CHECK ((organizacao_id IS NULL) <> (tripulacao_id IS NULL)),
  CONSTRAINT ck_qg_data_instalacao CHECK (REGEXP_LIKE(data_instalacao, '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$')),
  CONSTRAINT ck_qg_data_desativacao CHECK (REGEXP_LIKE(data_desativacao, '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$')),
  CONSTRAINT ck_qg_periodo CHECK ((data_instalacao IS NULL) OR (data_desativacao IS NULL) OR (data_desativacao >= data_instalacao))
);

CREATE TABLE recompensa (
  id            INT AUTO_INCREMENT,
  personagem_id INT NOT NULL,
  valor         BIGINT NOT NULL,
  data_emissao  VARCHAR(10) NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_recompensa_personagem FOREIGN KEY (personagem_id) REFERENCES personagem(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT ck_recompensa_valor CHECK (valor > 0),
  CONSTRAINT ck_recompensa_data_emissao CHECK (REGEXP_LIKE(data_emissao, '^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$'))
);
