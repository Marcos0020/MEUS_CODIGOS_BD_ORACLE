CREATE OR REPLACE FUNCTION CUSTOM.PROXIMA_DATA_UTIL(pDATA DATE) RETURN DATE IS
    vDATA DATE := pDATA;
    vFERIADO DATE;
BEGIN
    LOOP
        -- Verifica se a data cai no fim de semana (6 = Sábado, 7 = Domingo)
        IF TO_CHAR(vDATA, 'D') IN ('7', '1') THEN
            vDATA := vDATA + 1;
            CONTINUE;
        END IF;

        -- Verifica se a data é um feriado
        SELECT MAX(DATA) 
		INTO vFERIADO
        FROM ldesk.cad_feriado
        WHERE TRUNC(DATA) = TRUNC(vDATA);

        IF vFERIADO IS NOT NULL THEN
            vDATA := vDATA + 1;
            CONTINUE;
        END IF;

        -- Se não for fim de semana nem feriado, sai do loop
        EXIT;
    END LOOP;

    RETURN vDATA;
END;


/* Função criada por MVS para calcular feriados e fins de semana */
--CUSTOM.PROXIMA_DATA_UTIL(:NEW.DATA + 10)
--CUSTOM.PROXIMA_DATA_UTIL(SYSDATE + 10)