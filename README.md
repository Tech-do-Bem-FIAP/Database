# Tech do Bem — Banco de Dados (Sprint 4)

Repositório com a estrutura e a massa de dados Oracle do projeto **Tech do Bem**, disciplina **Building Relational Database** — 1TDSPR / FIAP.

## Integrantes

| RM       | Nome                          |
|----------|-------------------------------|
| RM568542 | Hugo Souza de Jesus           |
| RM566815 | Lucas Campanhã dos Santos     |
| RM567010 | Lucas Marcelino Pompeu        |

## Conteúdo do repositório

| Arquivo                              | Descrição                                                                 |
|--------------------------------------|---------------------------------------------------------------------------|
| `Tech do Bem - SQL - sprint 4.sql`   | Script único e idempotente: DROP + CREATE + INSERT + UPDATE + DELETE + 5 relatórios |
| `DOCUMENTACAO.md`                    | Documentação atendendo à rubrica da Sprint 4 (modelagem, constraints, justificativa dos relatórios) |
| `README.md`                          | Este arquivo                                                              |

## Sobre o projeto

A **Tech do Bem** é uma ONG que oferece atendimento odontológico gratuito a populações vulneráveis. O banco modelado aqui sustenta a plataforma de gestão usada por administradores, coordenadores, auxiliares e dentistas — controlando colaboradores, dentistas, pacientes, campanhas, atendimentos, exames, anotações, notificações e solicitações de acesso.

O sistema completo é composto por três outros repositórios:

- [`Tech-do-Bem-FIAP/Backend_Java`](https://github.com/Tech-do-Bem-FIAP/Backend_Java) — API Java Quarkus que consome este banco
- [`Tech-do-Bem-FIAP/Frontend`](https://github.com/Tech-do-Bem-FIAP/Frontend) — SPA React + Vite + TypeScript
- [`Tech-do-Bem-FIAP/Backend_AI`](https://github.com/Tech-do-Bem-FIAP/Backend_AI) — API Flask com modelo preditivo de demanda

## Como executar

1. Conecte-se à instância Oracle da FIAP (ou qualquer Oracle 19c+) com SQL Developer, SQL*Plus, SQLcl ou similar usando seu RM como usuário.
2. Abra o arquivo `Tech do Bem - SQL - sprint 4.sql`.
3. Execute o script completo (F5 no SQL Developer ou `@"Tech do Bem - SQL - sprint 4.sql"` no SQL*Plus).
4. O script é **idempotente**: pode rodar quantas vezes for necessário; ele apaga e recria tudo a cada execução.
5. Após a execução, os 5 relatórios finais imprimem resultados — confira-os no painel de saída.

### Pré-requisitos

- Oracle Database 19c ou superior (testado no Oracle FIAP — `oracle.fiap.com.br:1521/orcl`).
- Cliente Oracle compatível (SQL Developer, SQL*Plus, SQLcl, DBeaver).
- Privilégios usuais de um usuário FIAP (CREATE TABLE, CREATE SEQUENCE, DROP, INSERT, UPDATE, DELETE, SELECT).

## Atendimento à rubrica Sprint 4

| Critério                                            | Pontuação | Localização no SQL          |
|-----------------------------------------------------|-----------|-----------------------------|
| Documentação Sprint 3                                | 10 pts    | `DOCUMENTACAO.md`           |
| Estrutura atualizada (DDL com PK/FK/NN/UK/CK)        | 10 pts    | Linhas 36 – 273             |
| INSERTs (mínimo 7 por tabela — entregamos muito mais)| 10 pts    | Linhas 275 – 820            |
| 3 UPDATEs + 3 DELETEs                                | 10 pts    | Linhas 822 – 857            |
| Relatório com classificação de dados (ORDER BY)      | 5 pts     | Linha 870                   |
| Relatório com função numérica simples                | 5 pts     | Linha 884                   |
| Relatório com função de grupo (HAVING)               | 15 pts    | Linha 895                   |
| Relatório com sub-consulta                           | 15 pts    | Linha 909                   |
| Relatório com junção de tabelas (INNER JOIN)         | 20 pts    | Linha 929                   |

Detalhes de cada item em [`DOCUMENTACAO.md`](DOCUMENTACAO.md).
