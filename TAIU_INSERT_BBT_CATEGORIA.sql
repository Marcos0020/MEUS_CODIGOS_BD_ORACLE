CREATE OR REPLACE TRIGGER ADMIN.TAIU_INSERT_BBT_CATEGORIA
AFTER INSERT OR UPDATE OF CATEGORIAS ON BIBLIOTECA
FOR EACH ROW
DECLARE
    v_id_biblioteca VARCHAR2(50);
    v_id_categoria VARCHAR2(50);
BEGIN
    -- Obtém o ID da biblioteca inserida ou atualizada
    v_id_biblioteca := :NEW.ID_BIBLIOTECA;

    -- Limpa os registros antigos da tabela BBT_CATEGORIA para esta biblioteca
    DELETE FROM BBT_CATEGORIA WHERE ID_BIBLIOTECA = v_id_biblioteca;

    -- Itera sobre as descrições de categorias da biblioteca e insere na tabela BBT_CATEGORIA
    FOR c IN (SELECT ID_CATEGORIA
              FROM CATEGORIA
              WHERE UPPER(DESCRICAO) IN (
                    SELECT TRIM(REGEXP_SUBSTR(:NEW.CATEGORIAS, '[^/]+', 1, LEVEL))
                    FROM DUAL
                    CONNECT BY LEVEL <= REGEXP_COUNT(:NEW.CATEGORIAS, '/') + 1 )) LOOP

        v_id_categoria := c.ID_CATEGORIA;

        -- Insere na tabela de junção BBT_CATEGORIA
        INSERT INTO BBT_CATEGORIA (ID_BIBLIOTECA, ID_CATEGORIA)
        VALUES (v_id_biblioteca, v_id_categoria);
    END LOOP;
END;
