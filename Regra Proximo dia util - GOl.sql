CREATE OR REPLACE TRIGGER LDESK.TBIU_DIAUTIL_COMPROMISSO_GOL
BEFORE INSERT OR UPDATE ON LDESK.JUR_COMPROMISSO
FOR EACH ROW
DECLARE
    vUsuario VARCHAR2(50); -- Variável para armazenar o usuário que fez a alteração
    vFeriado NUMBER; -- Flag para identificar se a data é feriado
    vTipoAssunto VARCHAR2(50); -- Variável para armazenar o tipo de assunto
BEGIN
    -- Obter o usuario que realizou a operação
    vUsuario := SYS_CONTEXT('USERENV', 'SESSION_USER');

    -- Verificar se o usuário é LDESK ou INSIDE02
    IF vUsuario IN ('LDESK', 'INSIDE02') THEN
        -- Select para armazenar o valor do campo id_tipoassunto na variavel vTipoAssunto
        SELECT ID_TIPOASSUNTO 
        INTO  vTipoAssunto
        FROM LDESK.JUR_ASSUNTO
        WHERE ID_ASSUNTO = :NEW.ID_ASSUNTO; 

        -- Apenas realizar o ajuste se o ID_TIPOASSUNTO for Gol
        IF vTipoAssunto = '5FDA21D3-B241-9F3E-7CB2-17F1DA0AB41D' THEN
            -- LOOP para garantir que a data seja um dia útil
            LOOP
                -- Verificar se a data é um sábado ou domingo
                IF TO_CHAR(:NEW.DATA, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') IN ('SAT', 'SUN') THEN
                    -- Mover a data para o próximo dia se cair no sabado ou domingo 
                    :NEW.DATA := :NEW.DATA + INTERVAL '1' DAY;
                ELSE
                    -- Verificar se a nova data cai em um feriado (usando a tabela de feriados)
                    SELECT COUNT(1)
                    INTO vFeriado
                    FROM LDESK.CAD_FERIADO
                    WHERE TRUNC(DATA) = :NEW.DATA;

                    -- Se for feriado (valor maior que 0), mover para o próximo dia
                    IF vFeriado > 0 THEN
                        :NEW.DATA := :NEW.DATA + INTERVAL '1' DAY;
                    ELSE
                        EXIT; -- Se não for feriado, sair do loop
                    END IF;
                END IF;
            END LOOP;
        END IF;
    END IF;
END;

/* Trigger criada por MVS. Ajusta automaticamente a data de compromissos para o tipo de assunto "Gol" 
(inseridos ou alterados pelos usuários 'LDESK' e 'INSIDE02'), 
movendo o compromisso para o próximo dia útil caso a data original seja um sábado, domingo ou feriado. */