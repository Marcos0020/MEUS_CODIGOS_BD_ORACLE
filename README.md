# MEUS_CODIGOS_BD_ORACLE

Repositório com triggers, procedures, funções e scripts Python que desenvolvi durante meu trabalho como analista de banco de dados Oracle.

## 📋 Conteúdo

| Arquivo | Descrição |
|---|---|
| `RelatorioGerencial.py` | Aplicação Python/Tkinter para relatórios gerenciais com exportação Excel |
| `MYSCHEMA.TAI_ANDAMENTO_TRAB.sql` | Trigger para automação de compromissos após andamentos processuais |
| `MYSCHEMA.TAI_DESDOBRO_ASSUNTO_FAT_EDP.sql` | Trigger para desdobramento de assuntos com faturamento EDP |
| `MYSCHEMA.SITUACAOCOMPROMISSO_GOL` | Trigger para situação de compromissos GOL |
| `FUNÇÃO PROXIMA_DATA_UTIL.sql` | Função para calcular próximo dia útil |
| `função para gerar uuid.sql` | Função para geração de UUID |
| `procedure para gerar feriados anuais.sql` | Procedure para inserção automática de feriados |
| `Regra Proximo dia util - GOl.sql` | Trigger para ajuste de datas em dias úteis |
| `TAIU_INSERT_BBT_CATEGORIA.sql` | Trigger para categorização de biblioteca |
| `TBI_FMT_CATEGORIAS_BIBLIOTECA` | Trigger para formatação de categorias |

## ⚙️ Configuração (RelatorioGerencial.py)

1. Instale as dependências:
```bash
pip install cx_Oracle pandas openpyxl python-dotenv
```

2. Copie o arquivo de exemplo e preencha com suas credenciais:
```bash
cp .env.example .env
```

3. Edite o `.env` com os dados do seu banco de dados Oracle.

> ⚠️ **Nunca commite o arquivo `.env` no repositório!**

## 🛠️ Tecnologias

- **Oracle Database** — PL/SQL (Triggers, Procedures, Functions)
- **Python** — cx_Oracle, Tkinter, Pandas, OpenPyXL
