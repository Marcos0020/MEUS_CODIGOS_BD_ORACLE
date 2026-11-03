CREATE OR REPLACE TRIGGER APP.TBIU_DIAUTIL_COMPROMISSO_GOL
BEFORE INSERT OR UPDATE ON APP.JUR_COMPROMISSO
FOR EACH ROW
DECLARE
    vUsuario VARCHAR2(50); -- Variável para armazenar o usuário que fez a alteração
    vFeriado NUMBER; -- Flag para identificar se a data é feriado
    vTipoAssunto VARCHAR2(50); -- Variável para armazenar o tipo de assunto
BEGIN
    -- Obter o usuario que realizou a operação
    vUsuario := SYS_CONTEXT('USERENV', 'SESSION_USER');

    -- Verificar se o usuário é APP_USER ou APP_ADMIN
    IF vUsuario IN ('APP_USER', 'APP_USER') THEN
        -- Select para armazenar o valor do campo id_tipoassunto na variavel vTipoAssunto
        SELECT ID_TIPOASSUNTO 
        INTO  vTipoAssunto
        FROM APP.JUR_ASSUNTO
        WHERE ID_ASSUNTO = :NEW.ID_ASSUNTO; 

        -- Apenas realizar o ajuste se o ID_TIPOASSUNTO for Gol
        IF vTipoAssunto = 'B1B2C3D4-2222-BBBB-0002-000000000002' THEN
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
                    FROM APP.CAD_FERIADO
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

/* Trigger criada pelo desenvolvedor. Ajusta automaticamente a data de compromissos para o tipo de assunto "Gol" 
(inseridos ou alterados pelos usuários 'APP_USER' e 'APP_USER'), 
movendo o compromisso para o próximo dia útil caso a data original seja um sábado, domingo ou feriado. */