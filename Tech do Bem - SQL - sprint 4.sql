-- Hugo Souza de Jesus    (RM568542)
-- Lucas Campanhã dos Santos (RM566815)
-- Lucas Marcelino Pompeu  (RM567010)


-- ============================================================
-- Apagando tabelas e sequences para evitar conflito
-- ============================================================

DROP TABLE Envia             CASCADE CONSTRAINTS;
DROP TABLE FK_ATEND_CAMP     CASCADE CONSTRAINTS;
DROP TABLE FK_EXAME_ATEND    CASCADE CONSTRAINTS;
DROP TABLE T_EXAME           CASCADE CONSTRAINTS;
DROP TABLE T_ATENDIMENTO     CASCADE CONSTRAINTS;
DROP TABLE T_NOTIFICACAO     CASCADE CONSTRAINTS;
DROP TABLE T_PACIENTE        CASCADE CONSTRAINTS;
DROP TABLE T_DENTISTA        CASCADE CONSTRAINTS;
DROP TABLE T_CAMPANHA        CASCADE CONSTRAINTS;
DROP TABLE T_COLABORADOR     CASCADE CONSTRAINTS;

DROP SEQUENCE SEQ_COLABORADOR;
DROP SEQUENCE SEQ_DENTISTA;
DROP SEQUENCE SEQ_PACIENTE;
DROP SEQUENCE SEQ_ATENDIMENTO;
DROP SEQUENCE SEQ_EXAME;
DROP SEQUENCE SEQ_NOTIFICACAO;
DROP SEQUENCE SEQ_CAMPANHA;

-- ============================================================
-- Criando sequences para geração de IDs
-- ============================================================

CREATE SEQUENCE SEQ_COLABORADOR  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_DENTISTA     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_PACIENTE     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_ATENDIMENTO  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_EXAME        START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_NOTIFICACAO  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_CAMPANHA     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- ============================================================
-- Criando tabelas
-- ============================================================

-- Entidade raiz: Colaborador
CREATE TABLE T_COLABORADOR (
    ID_COLABORADOR  NUMBER          NOT NULL,
    NOME            VARCHAR2(50)    NOT NULL,
    CPF             VARCHAR2(11)    NOT NULL, 
    EMAIL           VARCHAR2(50)    NOT NULL,
    SENHA           VARCHAR2(10)    NOT NULL,
    CARGO           VARCHAR2(15)    NOT NULL,
    DISPONIBILIDADE NUMBER(1)       NOT NULL,
    CONSTRAINT T_COLABORADOR_PK     PRIMARY KEY (ID_COLABORADOR),
    CONSTRAINT T_COLABORADOR_CPF_UN UNIQUE (CPF),
    CONSTRAINT T_COLABORADOR_EMAIL_UN UNIQUE (EMAIL),
    CONSTRAINT CK_COLAB_CPF         CHECK (REGEXP_LIKE(CPF, '^\d{11}$')), 
    CONSTRAINT CK_COLAB_CARGO       CHECK (CARGO IN ('Administrador', 'Coordenador', 'Auxiliar', 'Estagiário')),
    CONSTRAINT CK_COLAB_DISP        CHECK (DISPONIBILIDADE IN (0, 1))
);

-- Dentista vinculado a Colaborador
CREATE TABLE T_DENTISTA (
    ID_DENTISTA                  NUMBER          NOT NULL,
    NOME                         VARCHAR2(50)    NOT NULL,
    CPF                          VARCHAR2(11)    NOT NULL,
    EMAIL                        VARCHAR2(50)    NOT NULL,
    SENHA                        VARCHAR2(10)    NOT NULL,
    CRO                          VARCHAR2(9)     NOT NULL,
    ESPECIALIDADE                VARCHAR2(30),
    DISPONIBILIDADE              NUMBER(1)       NOT NULL,
    T_COLABORADOR_ID_COLABORADOR NUMBER,
    CONSTRAINT T_DENTISTA_PK     PRIMARY KEY (ID_DENTISTA),
    CONSTRAINT T_DENTISTA_CPF_UN  UNIQUE (CPF),
    CONSTRAINT T_DENTISTA_EMAIL_UN UNIQUE (EMAIL),
    CONSTRAINT T_DENTISTA_CRO_UN   UNIQUE (CRO),
    CONSTRAINT CK_DENT_CPF         CHECK (REGEXP_LIKE(CPF, '^\d{11}$')), 
    CONSTRAINT CK_DENT_CRO         CHECK (REGEXP_LIKE(CRO, '^\d{6}-[A-Z]{2}$')),
    CONSTRAINT CK_DENT_DISP        CHECK (DISPONIBILIDADE IN (0, 1)),
    CONSTRAINT T_DENTISTA_T_COLABORADOR_FK FOREIGN KEY (T_COLABORADOR_ID_COLABORADOR) REFERENCES T_COLABORADOR (ID_COLABORADOR)
);

-- Paciente vinculado a Dentista
CREATE TABLE T_PACIENTE (
    ID_PACIENTE   NUMBER          NOT NULL,
    NOME          VARCHAR2(50)    NOT NULL,
    CPF           VARCHAR2(11),             
    DATA_NASC     DATE            NOT NULL,
    TELEFONE      VARCHAR2(20)    NOT NULL,
    EMAIL         VARCHAR2(50)    NOT NULL,
    ID_DENTISTA   NUMBER          NOT NULL,
    CONSTRAINT T_PACIENTE_PK      PRIMARY KEY (ID_PACIENTE),
    CONSTRAINT T_PACIENTE_CPF_UN  UNIQUE (CPF),
    CONSTRAINT CK_PAC_CPF         CHECK (CPF IS NULL OR REGEXP_LIKE(CPF, '^\d{11}$')), 
    CONSTRAINT FK_PAC_DENT        FOREIGN KEY (ID_DENTISTA) REFERENCES T_DENTISTA (ID_DENTISTA)
);

-- Campanha vinculada a Colaborador
CREATE TABLE T_CAMPANHA (
    ID_CAMPANHA                  NUMBER          NOT NULL,
    NOME                         VARCHAR2(30)    NOT NULL,
    LOCAL                        VARCHAR2(50)    NOT NULL,
    DATA_INICIO                  DATE            NOT NULL,
    DATA_FIM                     DATE            NOT NULL,
    T_COLABORADOR_ID_COLABORADOR NUMBER          NOT NULL,
    CONSTRAINT T_CAMPANHA_PK     PRIMARY KEY (ID_CAMPANHA),
    CONSTRAINT CK_CAMP_DATAS     CHECK (DATA_FIM >= DATA_INICIO),
    CONSTRAINT T_CAMPANHA_T_COLABORADOR_FK FOREIGN KEY (T_COLABORADOR_ID_COLABORADOR) REFERENCES T_COLABORADOR (ID_COLABORADOR)
);

-- Atendimento vinculando Paciente, Dentista e Campanha
CREATE TABLE T_ATENDIMENTO (
    ID_ATENDIMENTO         NUMBER          NOT NULL,
    DATA                   DATE            NOT NULL,
    TIPO                   VARCHAR2(30)    NOT NULL,
    STATUS                 VARCHAR2(15)    NOT NULL,
    OBSERVACOES            VARCHAR2(200),
    T_PACIENTE_ID_PACIENTE NUMBER          NOT NULL,
    T_DENTISTA_ID_DENTISTA NUMBER          NOT NULL,
    ID_CAMPANHA            NUMBER          NOT NULL,
    CONSTRAINT T_ATENDIMENTO_PK    PRIMARY KEY (ID_ATENDIMENTO),
    CONSTRAINT CK_ATEND_STATUS     CHECK (STATUS IN ('agendado', 'realizado', 'cancelado')),
    CONSTRAINT T_ATENDIMENTO_T_PACIENTE_FK FOREIGN KEY (T_PACIENTE_ID_PACIENTE) REFERENCES T_PACIENTE (ID_PACIENTE),
    CONSTRAINT T_ATENDIMENTO_T_DENTISTA_FK FOREIGN KEY (T_DENTISTA_ID_DENTISTA) REFERENCES T_DENTISTA (ID_DENTISTA)
);

-- Notificacao vinculada a Dentista e Colaborador
CREATE TABLE T_NOTIFICACAO (
    ID_NOTIFICACAO               NUMBER(5)       NOT NULL,
    MENSAGEM                     VARCHAR2(200),
    DATA_ENVIO                   DATE            NOT NULL,
    STATUS_ENVIO                 VARCHAR2(10)    NOT NULL,
    CANAL                        VARCHAR2(10)    NOT NULL,
    T_DENTISTA_ID_DENTISTA       NUMBER,
    T_COLABORADOR_ID_COLABORADOR NUMBER,
    CONSTRAINT T_NOTIFICACAO_PK  PRIMARY KEY (ID_NOTIFICACAO),
    CONSTRAINT CK_NOTI_STATUS    CHECK (STATUS_ENVIO IN ('enviado', 'pendente', 'falhou')),
    CONSTRAINT T_NOTIFICACAO_T_DENTISTA_FK FOREIGN KEY (T_DENTISTA_ID_DENTISTA) REFERENCES T_DENTISTA (ID_DENTISTA),
    CONSTRAINT T_NOTIFICACAO_T_COLABORADOR_FK FOREIGN KEY (T_COLABORADOR_ID_COLABORADOR) REFERENCES T_COLABORADOR (ID_COLABORADOR)
);

-- Exame vinculado a Atendimento
CREATE TABLE T_EXAME (
    ID_EXAME       NUMBER          NOT NULL,
    TIPO           VARCHAR2(30)    NOT NULL,
    REQUISITOS     VARCHAR2(100),
    RESULTADO      VARCHAR2(200),
    ID_ATENDIMENTO NUMBER          NOT NULL,
    CONSTRAINT T_EXAME_PK          PRIMARY KEY (ID_EXAME)
);

-- ============================================================
-- Tabelas Associativas / Relacionais (Muitos-para-Muitos)
-- ============================================================

CREATE TABLE Envia (
    T_NOTIFICACAO_ID_NOTIFICACAO NUMBER(5) NOT NULL,
    T_PACIENTE_ID_PACIENTE       NUMBER    NOT NULL,
    CONSTRAINT Envia_PK          PRIMARY KEY (T_NOTIFICACAO_ID_NOTIFICACAO, T_PACIENTE_ID_PACIENTE),
    CONSTRAINT Envia_T_NOTIF_FK  FOREIGN KEY (T_NOTIFICACAO_ID_NOTIFICACAO) REFERENCES T_NOTIFICACAO (ID_NOTIFICACAO),
    CONSTRAINT Envia_T_PAC_FK    FOREIGN KEY (T_PACIENTE_ID_PACIENTE) REFERENCES T_PACIENTE (ID_PACIENTE)
);

CREATE TABLE FK_ATEND_CAMP (
    T_CAMPANHA_ID_CAMPANHA       NUMBER    NOT NULL,
    T_ATENDIMENTO_ID_ATENDIMENTO NUMBER    NOT NULL,
    CONSTRAINT FK_ATEND_CAMP_PK  PRIMARY KEY (T_CAMPANHA_ID_CAMPANHA, T_ATENDIMENTO_ID_ATENDIMENTO),
    CONSTRAINT FK_ATC_ATEND_FK   FOREIGN KEY (T_ATENDIMENTO_ID_ATENDIMENTO) REFERENCES T_ATENDIMENTO (ID_ATENDIMENTO),
    CONSTRAINT FK_ATC_CAMP_FK    FOREIGN KEY (T_CAMPANHA_ID_CAMPANHA) REFERENCES T_CAMPANHA (ID_CAMPANHA)
);

CREATE TABLE FK_EXAME_ATEND (
    T_ATENDIMENTO_ID_ATENDIMENTO NUMBER    NOT NULL,
    T_EXAME_ID_EXAME             NUMBER    NOT NULL,
    CONSTRAINT FK_EXAME_ATEND_PK PRIMARY KEY (T_ATENDIMENTO_ID_ATENDIMENTO, T_EXAME_ID_EXAME),
    CONSTRAINT FK_EXA_ATEND_FK   FOREIGN KEY (T_ATENDIMENTO_ID_ATENDIMENTO) REFERENCES T_ATENDIMENTO (ID_ATENDIMENTO),
    CONSTRAINT FK_EXA_EXAME_FK   FOREIGN KEY (T_EXAME_ID_EXAME) REFERENCES T_EXAME (ID_EXAME)
);

-- ============================================================
-- INSERINDO DADOS NAS TABELAS
-- ============================================================
 
-- ------------------------------------------------------------
-- T_COLABORADOR (7 registros)
-- ------------------------------------------------------------
INSERT INTO T_COLABORADOR (ID_COLABORADOR, NOME, CPF, EMAIL, SENHA, CARGO, DISPONIBILIDADE)
VALUES (SEQ_COLABORADOR.NEXTVAL, 'Ana Lima',      '11111111101', 'ana.lima@techbem.com',      'ana123',  'Administrador', 1);
 
INSERT INTO T_COLABORADOR (ID_COLABORADOR, NOME, CPF, EMAIL, SENHA, CARGO, DISPONIBILIDADE)
VALUES (SEQ_COLABORADOR.NEXTVAL, 'Bruno Melo',    '11111111102', 'bruno.melo@techbem.com',    'bru456',  'Coordenador',   1);
 
INSERT INTO T_COLABORADOR (ID_COLABORADOR, NOME, CPF, EMAIL, SENHA, CARGO, DISPONIBILIDADE)
VALUES (SEQ_COLABORADOR.NEXTVAL, 'Carla Souza',   '11111111103', 'carla.souza@techbem.com',   'car789',  'Auxiliar',      1);
 
INSERT INTO T_COLABORADOR (ID_COLABORADOR, NOME, CPF, EMAIL, SENHA, CARGO, DISPONIBILIDADE)
VALUES (SEQ_COLABORADOR.NEXTVAL, 'Diego Rocha',   '11111111104', 'diego.rocha@techbem.com',   'die012',  'Estagiário',    0);
 
INSERT INTO T_COLABORADOR (ID_COLABORADOR, NOME, CPF, EMAIL, SENHA, CARGO, DISPONIBILIDADE)
VALUES (SEQ_COLABORADOR.NEXTVAL, 'Eva Torres',    '11111111105', 'eva.torres@techbem.com',    'eva345',  'Coordenador',   1);
 
INSERT INTO T_COLABORADOR (ID_COLABORADOR, NOME, CPF, EMAIL, SENHA, CARGO, DISPONIBILIDADE)
VALUES (SEQ_COLABORADOR.NEXTVAL, 'Fabio Nunes',   '11111111106', 'fabio.nunes@techbem.com',   'fab678',  'Auxiliar',      0);
 
INSERT INTO T_COLABORADOR (ID_COLABORADOR, NOME, CPF, EMAIL, SENHA, CARGO, DISPONIBILIDADE)
VALUES (SEQ_COLABORADOR.NEXTVAL, 'Gabi Ferreira', '11111111107', 'gabi.ferreira@techbem.com', 'gab901',  'Administrador', 1);
 
 
-- ------------------------------------------------------------
-- T_DENTISTA (7 registros)
-- ------------------------------------------------------------
INSERT INTO T_DENTISTA (ID_DENTISTA, NOME, CPF, EMAIL, SENHA, CRO, ESPECIALIDADE, DISPONIBILIDADE, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_DENTISTA.NEXTVAL, 'Dr. Paulo Alves',  '22222222201', 'paulo.alves@techbem.com',  'pau111', '100001-SP', 'Ortodontia',     1, 1);
 
INSERT INTO T_DENTISTA (ID_DENTISTA, NOME, CPF, EMAIL, SENHA, CRO, ESPECIALIDADE, DISPONIBILIDADE, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_DENTISTA.NEXTVAL, 'Dra. Rita Costa',  '22222222202', 'rita.costa@techbem.com',   'rit222', '100002-SP', 'Periodontia',    1, 2);
 
INSERT INTO T_DENTISTA (ID_DENTISTA, NOME, CPF, EMAIL, SENHA, CRO, ESPECIALIDADE, DISPONIBILIDADE, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_DENTISTA.NEXTVAL, 'Dr. Saulo Dias',   '22222222203', 'saulo.dias@techbem.com',   'sau333', '100003-RJ', 'Endodontia',     1, 3);
 
INSERT INTO T_DENTISTA (ID_DENTISTA, NOME, CPF, EMAIL, SENHA, CRO, ESPECIALIDADE, DISPONIBILIDADE, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_DENTISTA.NEXTVAL, 'Dra. Tania Pinto', '22222222204', 'tania.pinto@techbem.com',  'tan444', '100004-MG', 'Clinico Geral',  0, 4);
 
INSERT INTO T_DENTISTA (ID_DENTISTA, NOME, CPF, EMAIL, SENHA, CRO, ESPECIALIDADE, DISPONIBILIDADE, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_DENTISTA.NEXTVAL, 'Dr. Ulisses Brum', '22222222205', 'ulisses.brum@techbem.com', 'uli555', '100005-PR', 'Implantodontia', 1, 5);
 
INSERT INTO T_DENTISTA (ID_DENTISTA, NOME, CPF, EMAIL, SENHA, CRO, ESPECIALIDADE, DISPONIBILIDADE, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_DENTISTA.NEXTVAL, 'Dra. Vera Lopes',  '22222222206', 'vera.lopes@techbem.com',   'ver666', '100006-BA', 'Ortodontia',     1, 6);
 
INSERT INTO T_DENTISTA (ID_DENTISTA, NOME, CPF, EMAIL, SENHA, CRO, ESPECIALIDADE, DISPONIBILIDADE, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_DENTISTA.NEXTVAL, 'Dr. Wagner Silva', '22222222207', 'wagner.silva@techbem.com', 'wag777', '100007-RS', 'Periodontia',    0, 7);
 
 
-- ------------------------------------------------------------
-- T_PACIENTE (7 registros)
-- ------------------------------------------------------------
INSERT INTO T_PACIENTE (ID_PACIENTE, NOME, CPF, DATA_NASC, TELEFONE, EMAIL, ID_DENTISTA)
VALUES (SEQ_PACIENTE.NEXTVAL, 'Sofia Alves',   '33333333300', DATE '2012-06-10', '11991110001', 'sofia.alves@email.com',    1);
 
INSERT INTO T_PACIENTE (ID_PACIENTE, NOME, CPF, DATA_NASC, TELEFONE, EMAIL, ID_DENTISTA)
VALUES (SEQ_PACIENTE.NEXTVAL, 'Pedro Rocha',   '33333333301', DATE '2013-09-20', '11991110003', 'pedro.rocha@email.com',    3);
 
INSERT INTO T_PACIENTE (ID_PACIENTE, NOME, CPF, DATA_NASC, TELEFONE, EMAIL, ID_DENTISTA)
VALUES (SEQ_PACIENTE.NEXTVAL, 'Lucas Mendes',  '33333333302', DATE '2011-04-05', '11991110005', 'lucas.mendes@email.com',   5);
 
INSERT INTO T_PACIENTE (ID_PACIENTE, NOME, CPF, DATA_NASC, TELEFONE, EMAIL, ID_DENTISTA)
VALUES (SEQ_PACIENTE.NEXTVAL, 'Gabriel Lima',  '33333333303', DATE '2014-02-28', '11991110007', 'gabriel.lima@email.com',   7);
 
INSERT INTO T_PACIENTE (ID_PACIENTE, NOME, CPF, DATA_NASC, TELEFONE, EMAIL, ID_DENTISTA)
VALUES (SEQ_PACIENTE.NEXTVAL, 'Maria Lima',    '33333333304', DATE '1990-03-15', '11991110002', 'maria.lima@email.com',     2);
 
INSERT INTO T_PACIENTE (ID_PACIENTE, NOME, CPF, DATA_NASC, TELEFONE, EMAIL, ID_DENTISTA)
VALUES (SEQ_PACIENTE.NEXTVAL, 'Fernanda Costa','33333333305', DATE '1985-07-22', '11991110004', 'fernanda.costa@email.com', 4);
 
INSERT INTO T_PACIENTE (ID_PACIENTE, NOME, CPF, DATA_NASC, TELEFONE, EMAIL, ID_DENTISTA)
VALUES (SEQ_PACIENTE.NEXTVAL, 'Ana Beatriz',   '33333333306', DATE '1995-11-18', '11991110006', 'ana.beatriz@email.com',    6);
 
 
-- ------------------------------------------------------------
-- T_CAMPANHA (7 registros)
-- ------------------------------------------------------------
INSERT INTO T_CAMPANHA (ID_CAMPANHA, NOME, LOCAL, DATA_INICIO, DATA_FIM, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_CAMPANHA.NEXTVAL, 'Saude Bucal 2025',  'UBS Centro',        DATE '2025-02-01', DATE '2025-02-28', 1);
 
INSERT INTO T_CAMPANHA (ID_CAMPANHA, NOME, LOCAL, DATA_INICIO, DATA_FIM, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_CAMPANHA.NEXTVAL, 'Sorria Mais',        'Escola Municipal',  DATE '2025-03-10', DATE '2025-03-20', 2);
 
INSERT INTO T_CAMPANHA (ID_CAMPANHA, NOME, LOCAL, DATA_INICIO, DATA_FIM, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_CAMPANHA.NEXTVAL, 'Dentes Saudaveis',   'CRAS Leste',        DATE '2025-04-01', DATE '2025-04-30', 3);
 
INSERT INTO T_CAMPANHA (ID_CAMPANHA, NOME, LOCAL, DATA_INICIO, DATA_FIM, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_CAMPANHA.NEXTVAL, 'Prevencao Total',     'Hospital Geral',    DATE '2025-05-05', DATE '2025-05-25', 4);
 
INSERT INTO T_CAMPANHA (ID_CAMPANHA, NOME, LOCAL, DATA_INICIO, DATA_FIM, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_CAMPANHA.NEXTVAL, 'Bem Estar Oral',      'Praca da Saude',    DATE '2025-06-01', DATE '2025-06-15', 5);
 
INSERT INTO T_CAMPANHA (ID_CAMPANHA, NOME, LOCAL, DATA_INICIO, DATA_FIM, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_CAMPANHA.NEXTVAL, 'Sorrir e Viver',      'UBS Sul',           DATE '2025-07-10', DATE '2025-07-31', 6);
 
INSERT INTO T_CAMPANHA (ID_CAMPANHA, NOME, LOCAL, DATA_INICIO, DATA_FIM, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_CAMPANHA.NEXTVAL, 'Agosto da Saude',     'Ginasio Municipal', DATE '2025-08-01', DATE '2025-08-31', 7);
 
 
-- ------------------------------------------------------------
-- T_ATENDIMENTO (7 registros)
-- ------------------------------------------------------------
INSERT INTO T_ATENDIMENTO (ID_ATENDIMENTO, DATA, TIPO, STATUS, OBSERVACOES, T_PACIENTE_ID_PACIENTE, T_DENTISTA_ID_DENTISTA, ID_CAMPANHA)
VALUES (SEQ_ATENDIMENTO.NEXTVAL, DATE '2025-02-05', 'Consulta Inicial',    'realizado', 'Paciente com gengivite leve',       1, 1, 1);
 
INSERT INTO T_ATENDIMENTO (ID_ATENDIMENTO, DATA, TIPO, STATUS, OBSERVACOES, T_PACIENTE_ID_PACIENTE, T_DENTISTA_ID_DENTISTA, ID_CAMPANHA)
VALUES (SEQ_ATENDIMENTO.NEXTVAL, DATE '2025-03-12', 'Limpeza',             'realizado', 'Limpeza realizada com sucesso',     2, 2, 2);
 
INSERT INTO T_ATENDIMENTO (ID_ATENDIMENTO, DATA, TIPO, STATUS, OBSERVACOES, T_PACIENTE_ID_PACIENTE, T_DENTISTA_ID_DENTISTA, ID_CAMPANHA)
VALUES (SEQ_ATENDIMENTO.NEXTVAL, DATE '2025-04-10', 'Extracao',            'realizado', 'Extracao do dente 38',              3, 3, 3);
 
INSERT INTO T_ATENDIMENTO (ID_ATENDIMENTO, DATA, TIPO, STATUS, OBSERVACOES, T_PACIENTE_ID_PACIENTE, T_DENTISTA_ID_DENTISTA, ID_CAMPANHA)
VALUES (SEQ_ATENDIMENTO.NEXTVAL, DATE '2025-05-08', 'Restauracao',         'agendado',  NULL,                               4, 4, 4);
 
INSERT INTO T_ATENDIMENTO (ID_ATENDIMENTO, DATA, TIPO, STATUS, OBSERVACOES, T_PACIENTE_ID_PACIENTE, T_DENTISTA_ID_DENTISTA, ID_CAMPANHA)
VALUES (SEQ_ATENDIMENTO.NEXTVAL, DATE '2025-06-03', 'Consulta de Retorno', 'cancelado', 'Paciente nao compareceu',           5, 5, 5);
 
INSERT INTO T_ATENDIMENTO (ID_ATENDIMENTO, DATA, TIPO, STATUS, OBSERVACOES, T_PACIENTE_ID_PACIENTE, T_DENTISTA_ID_DENTISTA, ID_CAMPANHA)
VALUES (SEQ_ATENDIMENTO.NEXTVAL, DATE '2025-07-15', 'Avaliacao Ortodontica','agendado', NULL,                               6, 6, 6);
 
INSERT INTO T_ATENDIMENTO (ID_ATENDIMENTO, DATA, TIPO, STATUS, OBSERVACOES, T_PACIENTE_ID_PACIENTE, T_DENTISTA_ID_DENTISTA, ID_CAMPANHA)
VALUES (SEQ_ATENDIMENTO.NEXTVAL, DATE '2025-08-20', 'Implante',            'realizado', 'Implante inferior esquerdo',        7, 7, 7);
 
 
-- ------------------------------------------------------------
-- T_NOTIFICACAO (7 registros)
-- ------------------------------------------------------------
INSERT INTO T_NOTIFICACAO (ID_NOTIFICACAO, MENSAGEM, DATA_ENVIO, STATUS_ENVIO, CANAL, T_DENTISTA_ID_DENTISTA, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_NOTIFICACAO.NEXTVAL, 'Lembrete de consulta amanha',      DATE '2025-02-04', 'enviado',  'email',   1, 1);
 
INSERT INTO T_NOTIFICACAO (ID_NOTIFICACAO, MENSAGEM, DATA_ENVIO, STATUS_ENVIO, CANAL, T_DENTISTA_ID_DENTISTA, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_NOTIFICACAO.NEXTVAL, 'Confirmacao de agendamento',       DATE '2025-03-11', 'enviado',  'SMS',     2, 2);
 
INSERT INTO T_NOTIFICACAO (ID_NOTIFICACAO, MENSAGEM, DATA_ENVIO, STATUS_ENVIO, CANAL, T_DENTISTA_ID_DENTISTA, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_NOTIFICACAO.NEXTVAL, 'Campanha de prevencao bucal',      DATE '2025-04-01', 'pendente', 'email',   3, 3);
 
INSERT INTO T_NOTIFICACAO (ID_NOTIFICACAO, MENSAGEM, DATA_ENVIO, STATUS_ENVIO, CANAL, T_DENTISTA_ID_DENTISTA, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_NOTIFICACAO.NEXTVAL, 'Resultado de exame disponivel',    DATE '2025-05-06', 'enviado',  'app',     4, 4);
 
INSERT INTO T_NOTIFICACAO (ID_NOTIFICACAO, MENSAGEM, DATA_ENVIO, STATUS_ENVIO, CANAL, T_DENTISTA_ID_DENTISTA, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_NOTIFICACAO.NEXTVAL, 'Consulta cancelada pelo dentista', DATE '2025-06-02', 'falhou',   'SMS',     5, 5);
 
INSERT INTO T_NOTIFICACAO (ID_NOTIFICACAO, MENSAGEM, DATA_ENVIO, STATUS_ENVIO, CANAL, T_DENTISTA_ID_DENTISTA, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_NOTIFICACAO.NEXTVAL, 'Nova campanha disponivel',         DATE '2025-07-09', 'enviado',  'email',   6, 6);
 
INSERT INTO T_NOTIFICACAO (ID_NOTIFICACAO, MENSAGEM, DATA_ENVIO, STATUS_ENVIO, CANAL, T_DENTISTA_ID_DENTISTA, T_COLABORADOR_ID_COLABORADOR)
VALUES (SEQ_NOTIFICACAO.NEXTVAL, 'Retorno agendado com sucesso',     DATE '2025-08-18', 'pendente', 'app',     7, 7);
 
 
-- ------------------------------------------------------------
-- T_EXAME (7 registros)
-- ------------------------------------------------------------
INSERT INTO T_EXAME (ID_EXAME, TIPO, REQUISITOS, RESULTADO, ID_ATENDIMENTO)
VALUES (SEQ_EXAME.NEXTVAL, 'Radiografia Panoramica',  'Jejum nao necessario',  'Sem alteracoes osseas',         1);
 
INSERT INTO T_EXAME (ID_EXAME, TIPO, REQUISITOS, RESULTADO, ID_ATENDIMENTO)
VALUES (SEQ_EXAME.NEXTVAL, 'Periapical',               'Higiene previa',        'Carie em dente 36',             2);
 
INSERT INTO T_EXAME (ID_EXAME, TIPO, REQUISITOS, RESULTADO, ID_ATENDIMENTO)
VALUES (SEQ_EXAME.NEXTVAL, 'Interproximal',            NULL,                    'Carie interproximal leve',      3);
 
INSERT INTO T_EXAME (ID_EXAME, TIPO, REQUISITOS, RESULTADO, ID_ATENDIMENTO)
VALUES (SEQ_EXAME.NEXTVAL, 'Tomografia',               'Sem metal na boca',     'Sem comprometimento osseo',     4);
 
INSERT INTO T_EXAME (ID_EXAME, TIPO, REQUISITOS, RESULTADO, ID_ATENDIMENTO)
VALUES (SEQ_EXAME.NEXTVAL, 'Radiografia Periapical',   NULL,                    NULL,                            5);
 
INSERT INTO T_EXAME (ID_EXAME, TIPO, REQUISITOS, RESULTADO, ID_ATENDIMENTO)
VALUES (SEQ_EXAME.NEXTVAL, 'Modelos de Gesso',         'Impressao dental',      'Arcada superior e inferior OK', 6);
 
INSERT INTO T_EXAME (ID_EXAME, TIPO, REQUISITOS, RESULTADO, ID_ATENDIMENTO)
VALUES (SEQ_EXAME.NEXTVAL, 'Tomografia Cone Beam',     'Sem metal na boca',     'Posicao ideal para implante',   7);
 
 
-- ------------------------------------------------------------
-- Envia — Notificacao x Paciente (7 registros)
-- ------------------------------------------------------------
INSERT INTO Envia (T_NOTIFICACAO_ID_NOTIFICACAO, T_PACIENTE_ID_PACIENTE) VALUES (1, 1);
INSERT INTO Envia (T_NOTIFICACAO_ID_NOTIFICACAO, T_PACIENTE_ID_PACIENTE) VALUES (2, 2);
INSERT INTO Envia (T_NOTIFICACAO_ID_NOTIFICACAO, T_PACIENTE_ID_PACIENTE) VALUES (3, 3);
INSERT INTO Envia (T_NOTIFICACAO_ID_NOTIFICACAO, T_PACIENTE_ID_PACIENTE) VALUES (4, 4);
INSERT INTO Envia (T_NOTIFICACAO_ID_NOTIFICACAO, T_PACIENTE_ID_PACIENTE) VALUES (5, 5);
INSERT INTO Envia (T_NOTIFICACAO_ID_NOTIFICACAO, T_PACIENTE_ID_PACIENTE) VALUES (6, 6);
INSERT INTO Envia (T_NOTIFICACAO_ID_NOTIFICACAO, T_PACIENTE_ID_PACIENTE) VALUES (7, 7);
 
 
-- ------------------------------------------------------------
-- FK_ATEND_CAMP — Atendimento x Campanha (7 registros)
-- ------------------------------------------------------------
INSERT INTO FK_ATEND_CAMP (T_CAMPANHA_ID_CAMPANHA, T_ATENDIMENTO_ID_ATENDIMENTO) VALUES (1, 1);
INSERT INTO FK_ATEND_CAMP (T_CAMPANHA_ID_CAMPANHA, T_ATENDIMENTO_ID_ATENDIMENTO) VALUES (2, 2);
INSERT INTO FK_ATEND_CAMP (T_CAMPANHA_ID_CAMPANHA, T_ATENDIMENTO_ID_ATENDIMENTO) VALUES (3, 3);
INSERT INTO FK_ATEND_CAMP (T_CAMPANHA_ID_CAMPANHA, T_ATENDIMENTO_ID_ATENDIMENTO) VALUES (4, 4);
INSERT INTO FK_ATEND_CAMP (T_CAMPANHA_ID_CAMPANHA, T_ATENDIMENTO_ID_ATENDIMENTO) VALUES (5, 5);
INSERT INTO FK_ATEND_CAMP (T_CAMPANHA_ID_CAMPANHA, T_ATENDIMENTO_ID_ATENDIMENTO) VALUES (6, 6);
INSERT INTO FK_ATEND_CAMP (T_CAMPANHA_ID_CAMPANHA, T_ATENDIMENTO_ID_ATENDIMENTO) VALUES (7, 7);
 
 
-- ------------------------------------------------------------
-- FK_EXAME_ATEND — Exame x Atendimento (7 registros)
-- ------------------------------------------------------------
INSERT INTO FK_EXAME_ATEND (T_ATENDIMENTO_ID_ATENDIMENTO, T_EXAME_ID_EXAME) VALUES (1, 1);
INSERT INTO FK_EXAME_ATEND (T_ATENDIMENTO_ID_ATENDIMENTO, T_EXAME_ID_EXAME) VALUES (2, 2);
INSERT INTO FK_EXAME_ATEND (T_ATENDIMENTO_ID_ATENDIMENTO, T_EXAME_ID_EXAME) VALUES (3, 3);
INSERT INTO FK_EXAME_ATEND (T_ATENDIMENTO_ID_ATENDIMENTO, T_EXAME_ID_EXAME) VALUES (4, 4);
INSERT INTO FK_EXAME_ATEND (T_ATENDIMENTO_ID_ATENDIMENTO, T_EXAME_ID_EXAME) VALUES (5, 5);
INSERT INTO FK_EXAME_ATEND (T_ATENDIMENTO_ID_ATENDIMENTO, T_EXAME_ID_EXAME) VALUES (6, 6);
INSERT INTO FK_EXAME_ATEND (T_ATENDIMENTO_ID_ATENDIMENTO, T_EXAME_ID_EXAME) VALUES (7, 7);
 
COMMIT;
 
 
-- ============================================================
-- ATUALIZANDO DADOS DAS TABELAS (3 UPDATEs)
-- ============================================================
 
-- UPDATE 1: Dentista 4 (Tania Pinto) volta a estar disponível
UPDATE T_DENTISTA
SET    DISPONIBILIDADE = 1
WHERE  ID_DENTISTA = 4;
 
-- UPDATE 2: Atendimento 5 é remarcado — status muda de 'cancelado' para 'realizado'
UPDATE T_ATENDIMENTO
SET    STATUS      = 'realizado',
       OBSERVACOES = 'Paciente remarcou e compareceu na data seguinte'
WHERE  ID_ATENDIMENTO = 5;
 
-- UPDATE 3: Colaborador 4 (Diego Rocha) é promovido e seu e-mail é atualizado
UPDATE T_COLABORADOR
SET    CARGO  = 'Auxiliar',
       EMAIL  = 'diego.rocha.atualizado@techbem.com'
WHERE  ID_COLABORADOR = 4;
 
COMMIT;
 
 
-- ============================================================
-- DELETANDO DADOS DAS TABELAS (3 DELETEs)
-- ============================================================
 
-- DELETE 1: Remove a notificação com falha de envio (ID 5)
--           Primeiro remove o registro filho em Envia para não violar FK
DELETE FROM Envia
WHERE  T_NOTIFICACAO_ID_NOTIFICACAO = 5;
 
DELETE FROM T_NOTIFICACAO
WHERE  ID_NOTIFICACAO = 5;
 
-- DELETE 2: Remove o exame sem resultado (ID 5 — Radiografia Periapical sem resultado)
--           Primeiro remove o vínculo na tabela associativa FK_EXAME_ATEND
DELETE FROM FK_EXAME_ATEND
WHERE  T_EXAME_ID_EXAME = 5;
 
DELETE FROM T_EXAME
WHERE  ID_EXAME = 5;
 
-- DELETE 3: Remove a campanha encerrada (ID 7 — Agosto da Saude)
--           Primeiro remove o vínculo na tabela associativa FK_ATEND_CAMP
DELETE FROM FK_ATEND_CAMP
WHERE  T_CAMPANHA_ID_CAMPANHA = 7;
 
DELETE FROM T_CAMPANHA
WHERE  ID_CAMPANHA = 7;
 
COMMIT;
 
 
-- ============================================================
-- CRIANDO RELATÓRIOS
-- ============================================================
 
 
-- ------------------------------------------------------------
-- RELATÓRIO 1 — Classificação de Dados
-- Lista todos os pacientes ordenados por data de nascimento, 
-- do mais novo ao mais velho
-- ------------------------------------------------------------
select nome, to_char(data_nasc, 'DD/MM/YY') "Dt. Nasc.",
       trunc(months_between(sysdate, data_nasc) / 12) "Idade"
from t_paciente
order by data_nasc desc;
 
 
-- ------------------------------------------------------------
-- RELATÓRIO 2 — Função Numérica Simples
-- Calcula a duração de cada campanha em dias e semanas
-- ------------------------------------------------------------
select nome, local,
       (data_fim - data_inicio)             "Duracao (dias)",
       round((data_fim - data_inicio) / 7)  "Duracao (semanas)"
from t_campanha
order by 3 desc;
 
 
-- ------------------------------------------------------------
-- RELATÓRIO 3 — Função de Grupo
-- Quantos atendimentos cada dentista possui?
-- ------------------------------------------------------------
select t_dentista_id_dentista "ID Dentista",
       count(id_atendimento)  "Total Atendimentos",
       max(data)              "Ultimo Atendimento",
       min(data)              "Primeiro Atendimento"
from t_atendimento
group by t_dentista_id_dentista
having count(id_atendimento) >= 1
order by 1;
 
 
-- ------------------------------------------------------------
-- RELATÓRIO 4 — Sub-consulta
-- Mostra os pacientes que possuem atendimento com
-- status 'realizado'
-- ------------------------------------------------------------
select id_paciente, nome, email, telefone
from t_paciente
where id_paciente in (select t_paciente_id_paciente
                      from t_atendimento
                      where status = 'realizado')
order by nome;
 
 
-- ------------------------------------------------------------
-- RELATÓRIO 5 — Junção de Tabelas
-- Detalhamento completo: paciente + dentista + campanha
-- ------------------------------------------------------------
select p.nome "Paciente", d.nome "Dentista",
       d.especialidade, a.tipo "Tipo Atend.",
       to_char(a.data, 'DD/MM/YY') "Data",
       a.status, c.nome "Campanha", c.local
from t_atendimento a
inner join t_paciente p on a.t_paciente_id_paciente = p.id_paciente
inner join t_dentista d on a.t_dentista_id_dentista = d.id_dentista
inner join t_campanha c on a.id_campanha            = c.id_campanha
order by a.data;















