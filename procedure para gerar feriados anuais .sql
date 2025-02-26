CREATE OR REPLACE PROCEDURE INSERIR_FERIADOS_ANUAIS(p_ano IN NUMBER) AS
    v_pascoa DATE := NULL;
    v_carnaval DATE := NULL;
    v_sexta_santa DATE := NULL;
    v_corpus_christi DATE := NULL;
BEGIN
    -- Cálculo da data da Páscoa (algoritmo de Gauss)
    DECLARE
        a NUMBER := MOD(p_ano, 19);
        b NUMBER := TRUNC(p_ano / 100);
        c NUMBER := MOD(p_ano, 100);
        d NUMBER := TRUNC(b / 4);
        e NUMBER := MOD(b, 4);
        f NUMBER := TRUNC((b + 8) / 25);
        g NUMBER := TRUNC((b - f + 1) / 3);
        h NUMBER := MOD((19 * a + b - d - g + 15), 30);
        i NUMBER := TRUNC(c / 4);
        k NUMBER := MOD(c, 4);
        l NUMBER := MOD((32 + 2 * e + 2 * i - h - k), 7);
        m NUMBER := TRUNC((a + 11 * h + 22 * l) / 451);
        mes NUMBER := TRUNC((h + l - 7 * m + 114) / 31);
        dia NUMBER := MOD((h + l - 7 * m + 114), 31) + 1;
    BEGIN
        v_pascoa := TO_DATE(dia || '/' || mes || '/' || p_ano, 'DD/MM/YYYY');
    END;

    -- Calcula os feriados móveis
    v_carnaval := v_pascoa - 47; -- Carnaval ocorre 47 dias antes da Páscoa
    v_sexta_santa := v_pascoa - 2; -- Sexta-feira Santa ocorre 2 dias antes da Páscoa
    v_corpus_christi := v_pascoa + 60; -- Corpus Christi ocorre 60 dias após a Páscoa

    -- Insere os feriados fixos
    INSERT INTO LDESK.CALENDARIO (DATA, ESCRITORIO, ORGNCODIG, DESCRICAO)
    SELECT TO_DATE('01/01/' || p_ano, 'DD/MM/YYYY'), 'SP', 1, 'Confraternizacao' FROM DUAL UNION ALL
    SELECT TO_DATE('01/01/' || p_ano, 'DD/MM/YYYY'), 'RJ', 2, 'Confraternizacao' FROM DUAL UNION ALL
    SELECT TO_DATE('21/04/' || p_ano, 'DD/MM/YYYY'), 'SP', 1, 'Tiradentes' FROM DUAL UNION ALL
    SELECT TO_DATE('21/04/' || p_ano, 'DD/MM/YYYY'), 'RJ', 2, 'Tiradentes' FROM DUAL UNION ALL
    SELECT TO_DATE('01/05/' || p_ano, 'DD/MM/YYYY'), 'SP', 1, 'Trabalho' FROM DUAL UNION ALL
    SELECT TO_DATE('01/05/' || p_ano, 'DD/MM/YYYY'), 'RJ', 2, 'Trabalho' FROM DUAL UNION ALL
    SELECT TO_DATE('07/09/' || p_ano, 'DD/MM/YYYY'), 'SP', 1, 'Independencia' FROM DUAL UNION ALL
    SELECT TO_DATE('07/09/' || p_ano, 'DD/MM/YYYY'), 'RJ', 2, 'Independencia' FROM DUAL UNION ALL
    SELECT TO_DATE('12/10/' || p_ano, 'DD/MM/YYYY'), 'SP', 1, 'Aparecida' FROM DUAL UNION ALL
    SELECT TO_DATE('12/10/' || p_ano, 'DD/MM/YYYY'), 'RJ', 2, 'Aparecida' FROM DUAL UNION ALL
    SELECT TO_DATE('02/11/' || p_ano, 'DD/MM/YYYY'), 'SP', 1, 'Finados' FROM DUAL UNION ALL
    SELECT TO_DATE('02/11/' || p_ano, 'DD/MM/YYYY'), 'RJ', 2, 'Finados' FROM DUAL UNION ALL
    SELECT TO_DATE('15/11/' || p_ano, 'DD/MM/YYYY'), 'SP', 1, 'Republica' FROM DUAL UNION ALL
    SELECT TO_DATE('15/11/' || p_ano, 'DD/MM/YYYY'), 'RJ', 2, 'Republica' FROM DUAL UNION ALL
  SELECT TO_DATE('20/11/' || p_ano, 'DD/MM/YYYY'), 'SP', 1, 'Consciencia Negra' FROM DUAL UNION ALL
    SELECT TO_DATE('20/11/' || p_ano, 'DD/MM/YYYY'), 'RJ', 2, 'Consciencia Negra' FROM DUAL UNION ALL
    SELECT TO_DATE('25/12/' || p_ano, 'DD/MM/YYYY'), 'SP', 1, 'Natal' FROM DUAL UNION ALL
    SELECT TO_DATE('25/12/' || p_ano, 'DD/MM/YYYY'), 'RJ', 2, 'Natal' FROM DUAL;

    -- Insere os feriados móveis
    INSERT INTO LDESK.CALENDARIO (DATA, ESCRITORIO, ORGNCODIG, DESCRICAO)
    SELECT v_carnaval, 'SP', 1, 'Carnaval' FROM DUAL UNION ALL
    SELECT v_carnaval, 'RJ', 2, 'Carnaval' FROM DUAL UNION ALL
    SELECT v_sexta_santa, 'SP', 1, 'Sexta Santa' FROM DUAL UNION ALL
    SELECT v_sexta_santa, 'RJ', 2, 'Sexta Santa' FROM DUAL UNION ALL
    SELECT v_corpus_christi, 'SP', 1, 'Corpus Christi' FROM DUAL UNION ALL
    SELECT v_corpus_christi, 'RJ', 2, 'Corpus Christi' FROM DUAL;

    -- Confirma a transação
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Erro ao inserir os feriados: ' || SQLERRM);
END;
