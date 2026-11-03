# ⚙️ Oracle Database & PL/SQL Solutions

> Conjunto de rotinas corporativas desenvolvidas em Oracle PL/SQL (Triggers complexas, Stored Procedures e Functions) e scripts Python integrados para automação de regras de negócio, cálculo de prazos processuais e sustentação de banco de dados.

[![Database](https://img.shields.io/badge/Database-Oracle%2019c%20%7C%2021c-red.svg)](#)
[![Language](https://img.shields.io/badge/Language-PL%2FSQL-blue.svg)](#)
[![Python](https://img.shields.io/badge/Integration-Python%203-yellow.svg)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#)

---

## 🎯 Visão Geral

Este repositório reúne componentes de banco de dados desenvolvidos para sustentar e automatizar regras de negócio em sistemas jurídicos e operacionais corporativos de alta criticidade. As soluções resolvem desafios reais de integridade referencial, geração automática de agendas e desdobramento de processos entre instâncias judiciais.

---

## 📁 Estrutura do Repositório

```
MEUS_CODIGOS_BD_ORACLE/
├── triggers/                       # Gatilhos de automação de eventos e integridade
│   ├── tai_andamento_processual.sql  # Trigger mestre (+3.700 linhas) de automação de prazos e compromissos
│   ├── tai_desdobro_faturamento.sql  # Desdobramento automático de instâncias com replicação de pedidos
│   ├── taiu_situacao_compromisso.sql # Transação autônoma para sincronização de status de agendas
│   ├── tbiu_diautil_compromisso.sql  # Ajuste determinístico de datas para próximo dia útil antes do insert/update
│   ├── taiu_insert_bbt_categoria.sql # Classificação e vinculação de categorias
│   └── tbi_fmt_categorias_biblioteca.sql # Formatação e sanitização de campos textuais
├── functions/                      # Funções reutilizáveis de cálculo e regras
│   ├── fn_proxima_data_util.sql    # Cálculo de próximo dia útil considerando fins de semana e feriados
│   └── fn_gerar_uuid.sql           # Geração de identificadores únicos universais (UUID v4)
├── procedures/                     # Procedimentos armazenados de carga em lote
│   └── prc_gerar_feriados_anuais.sql # Carga de feriados fixos e algoritmo astronômico para feriados móveis
├── python/                         # Ferramentas complementares de suporte e análise
│   ├── RelatorioGerencial.py       # Interface Tkinter para consultas dinâmicas e exportação Excel
│   ├── requirements.txt           # Dependências Python (cx_Oracle, pandas, openpyxl, dotenv)
│   └── .env.example               # Template de variáveis de ambiente
├── docs/                           # Documentação técnica e arquitetura
│   └── DESCRICAO_APP_RELATORIO_GERENCIAL_.pdf # Especificação da ferramenta gerencial
├── .gitattributes                  # Mapeamento do Linguist para exibição de PL/SQL
├── .gitignore                      # Proteção de arquivos de ambiente e temporários
└── README.md                       # Documentação principal
```

---

## 🚀 Destaques Técnicos das Rotinas

### 1. `triggers/tai_andamento_processual.sql` (3.721 linhas)
* **Finalidade:** Disparada após inserção na tabela de andamentos (`JUR_ANDAMENTO`), avalia o tipo de ato processual (`ID_ATO`) e o cliente vinculado (`ID_CLIENTE`), orquestrando a inserção automática de compromissos judiciais, distribuição de tarefas para advogados e prazos processuais determinísticos.
* **Técnicas aplicadas:** Uso de cursores explícitos para joins complexos (`JUR_ASSUNTO`, `CAD_CASO`), controle de concorrência e geração de chaves primárias.

### 2. `triggers/taiu_situacao_compromisso.sql` & Transações Autônomas
* **Problema Resolvido:** Prevenção do erro clássico `ORA-04091: table is mutating, trigger/function may not see it`.
* **Solução:** Implementação de `PRAGMA AUTONOMOUS_TRANSACTION`, isolando o contexto de inserção na tabela de compromissos e executando o `COMMIT` atômico sem impactar a transação principal chamadora.

### 3. `procedures/prc_gerar_feriados_anuais.sql` & Feriados Móveis
* **Problema:** Cálculo de feriados bancários e judiciais com datas variáveis a cada ano (Carnaval, Sexta-Feira Santa, Páscoa e Corpus Christi).
* **Solução:** Algoritmo computacional para determinação do Domingo de Páscoa (`Meeus/Jones/Butcher`), derivando matematicamente o Carnaval ($D-47$), Sexta-feira Santa ($D-2$) e Corpus Christi ($D+60$), inserindo os registros na tabela `CALENDARIO`.

### 4. `functions/fn_proxima_data_util.sql`
* **Finalidade:** Recebe qualquer data de entrada e avança recursivamente até encontrar o próximo dia útil válido, consultando a tabela `CAD_FERIADO` e descartando sábados e domingos (`TO_CHAR(vDATA, 'DY')`).

---

## ⚙️ Pré-requisitos e Execução

* **Oracle Database:** Compatível com Oracle 11g, 12c, 19c e 21c (XE ou Enterprise).
* **Privilégios Recomendados:**
  ```sql
  GRANT CREATE TRIGGER, CREATE PROCEDURE, CREATE TABLE TO usuario;
  ```

---

## 🔐 Segurança e Sanitização de Dados

* Todos os identificadores de schemas corporativos proprietários (`CUSTOM`, `LDESK`) foram substituídos por schemas genéricos (`MYSCHEMA`, `APP`).
* UUIDs de instâncias reais foram anonimizados no padrão RFC 4122 fictício.
* As credenciais do script Python utilizam variáveis de ambiente (`.env`).

---

## 👨‍💻 Autor

Desenvolvido por **Marcos Sousa**  
* LinkedIn: [linkedin.com/in/](https://linkedin.com/in/)  
* GitHub: [@Marcos0020](https://github.com/Marcos0020)
