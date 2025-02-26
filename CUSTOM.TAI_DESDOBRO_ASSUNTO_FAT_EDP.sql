CREATE OR REPLACE TRIGGER CUSTOM.TAI_DESDOBRO_ASSUNTO_FAT_EDP
AFTER INSERT ON LDESK.JUR_ASSUNTO_VINCULO
FOR EACH ROW
DECLARE
    -- Variáveis para armazenar os valores do registro principal de LDESK.JUR_ASSUNTO
    vPasta              LDESK.JUR_ASSUNTO.PASTA%TYPE;
    vIdPrognostico      LDESK.JUR_ASSUNTO.ID_PROGNOSTICO%TYPE;
    vDataVcausa         LDESK.JUR_ASSUNTO.DATA_VCAUSA%TYPE;
    vIdMoedaVcausa     	LDESK.JUR_ASSUNTO.ID_MOEDA_VCAUSA%TYPE;
    vValorCausa         LDESK.JUR_ASSUNTO.VALOR_CAUSA%TYPE;
    vDataVenvolvido     LDESK.JUR_ASSUNTO.DATA_VENVOLVIDO%TYPE;
    vIdMoedaVenvolvido 	LDESK.JUR_ASSUNTO.ID_MOEDA_VENVOLVIDO%TYPE;
    vValorEnvolvido     LDESK.JUR_ASSUNTO.VALOR_ENVOLVIDO%TYPE;
	vIdEscritorio		LDESK.JUR_ASSUNTO.ID_ESCRITORIO%TYPE;
	vDataEntrada		LDESK.JUR_ASSUNTO.DATA_ENTRADA%TYPE;
	vIdAreaJuridica		LDESK.JUR_ASSUNTO.ID_AREAJURIDICA%TYPE;
	vIdSubAreajuridica	LDESK.JUR_ASSUNTO.ID_SUBAREAJURIDICA%TYPE;
	vDataFato			LDESK.JUR_ASSUNTO.C_DATAFATO%TYPE;
	vIdProcessoFisico	LDESK.JUR_ASSUNTO.ID_PROCESSO_FISICO%TYPE;
	vLiminar			LDESK.JUR_ASSUNTO.C_LIMINAR%TYPE;
	
	
    -- Cursor para buscar os registros na tabela CUSTOM_JUR_ASSUNTO_FATURAMENTO vinculados ao ID_ASSUNTO_PRINC
    CURSOR cFaturamento IS
        SELECT *
        FROM LDESK.CUSTOM_JUR_ASSUNTO_FATURAMENTO
        WHERE id_assunto = :NEW.id_assunto_princ;

    -- Variável para armazenar cada registro do cursor cFaturamento
    faturamentoRec cFaturamento%ROWTYPE;
	
	-- Cursor para buscar os registros na tabela LDESK.JUR_PEDIDO vinculados ao ID_ASSUNTO_PRINC
	CURSOR cPedido IS
        SELECT *
        FROM LDESK.JUR_PEDIDO
        WHERE id_assunto = :NEW.id_assunto_princ;

    -- Variável para armazenar cada registro do cursor cPedido
    PedidoRec cPedido%ROWTYPE;
	
	-- Cursor para buscar os registros na tabela LDESK.JUR_PEDIDO_VALOR vinculados ao ID_ASSUNTO_PRINC
	CURSOR cPedidoValor IS
        SELECT *
        FROM LDESK.JUR_PEDIDO_VALOR
        WHERE id_pedido IN (SELECT id_pedido FROM ldesk.jur_pedido WHERE id_assunto = :NEW.id_assunto_princ);

    -- Variável para armazenar cada registro do cursor cPedidoValor
    PedidoValorRec cPedidoValor%ROWTYPE;

    -- Variável para armazenar o id_tipoassunto e a instancia da tabela JUR_ASSUNTO
    vIdTipoAssunto LDESK.JUR_ASSUNTO.ID_TIPOASSUNTO%TYPE;
	vInstancia     LDESK.JUR_ASSUNTO.INSTANCIA%TYPE;

BEGIN

	IF :NEW.TIPO_VINCULO <> 'D' THEN
        RETURN;
    END IF;
    -- Verifica se o id_tipoassunto e a instancia da tabela JUR_ASSUNTO é o esperado
	
	SELECT instancia,id_tipoassunto
    INTO vInstancia,vIdTipoAssunto
    FROM LDESK.JUR_ASSUNTO a
    WHERE a.ID_ASSUNTO = :NEW.id_assunto;
	
	-- Só executa a trigger se o id_tipoassunto for EDP e a instancia 2 ou T
    IF (vIdTipoAssunto = '61080D7B-0906-1621-BE67-DB05FA687023') 
					   	AND (vInstancia='2' OR vInstancia='T')	THEN
    
        -- Recupera os valores do registro principal para realizar o update na tabela ldesk.jur_assunto nos desdobramentos
        SELECT 
            PASTA, ID_PROGNOSTICO, DATA_VCAUSA, ID_MOEDA_VCAUSA, 
            VALOR_CAUSA, DATA_VENVOLVIDO, ID_MOEDA_VENVOLVIDO, VALOR_ENVOLVIDO,
			ID_ESCRITORIO,DATA_ENTRADA,ID_AREAJURIDICA,ID_SUBAREAJURIDICA,
			C_DATAFATO,ID_PROCESSO_FISICO,C_LIMINAR
        INTO 
            vPasta, vIdPrognostico, vDataVcausa, vIdMoedaVcausa, 
            vValorCausa, vDataVenvolvido, vIdMoedaVenvolvido, vValorEnvolvido,
			vIdEscritorio,vDataEntrada,vIdAreaJuridica,vIdSubAreajuridica,
			vDataFato,vIdProcessoFisico,vLiminar
        FROM LDESK.JUR_ASSUNTO
        WHERE ID_ASSUNTO = :NEW.ID_ASSUNTO_PRINC;

        -- Atualiza os dados na tabela LDESK.JUR_ASSUNTO
        UPDATE LDESK.JUR_ASSUNTO
        SET
            PASTA = vPasta,
            ID_PROGNOSTICO = vIdPrognostico,
            DATA_VCAUSA = vDataVcausa,
            ID_MOEDA_VCAUSA = vIdMoedaVcausa,
            VALOR_CAUSA = vValorCausa,
            DATA_VENVOLVIDO = vDataVenvolvido,
            ID_MOEDA_VENVOLVIDO = vIdMoedaVenvolvido,
            VALOR_ENVOLVIDO = vValorEnvolvido,
			ID_ESCRITORIO = vIdEscritorio,
			DATA_ENTRADA = vDataEntrada,
			ID_AREAJURIDICA = vIdAreaJuridica,
			ID_SUBAREAJURIDICA = vIdSubAreajuridica,
			C_DATAFATO = vDataFato,
			ID_PROCESSO_FISICO = vIdProcessoFisico,
			C_LIMINAR = vLiminar
        WHERE ID_ASSUNTO = :NEW.ID_ASSUNTO;

        -- Loop pelos registros de faturamento vinculados ao processo principal
        FOR faturamentoRec IN cFaturamento LOOP
            -- Inserir uma cópia desses registros para os desdobramentos cujo ID_TIPOASSUNTO seja EDP
            INSERT INTO LDESK.CUSTOM_JUR_ASSUNTO_FATURAMENTO (
                id_assunto,
                id_faturamento,
                id_licenca,
                observacoes,
                data_entrada,
                data_encerramento,
                data_reativacao,
                processo_migrado,
                pro_labore,
                faturar,
                exito_faturado,
                arquivado,
                data_inclusao,
                usuario_inclusao,
                codigo,
                faturado,
                data_vpartidofixo,
                id_moeda_vpartidofixo,
                valor_partidofixo,
                id_areajuridica,
                id_subareajuridica,
                observacoes_honorarios,
                id_nomevalor,
                c_primeira_instancia,
                c_segunda_instancia,
                c_terceira_instancia,
                c_finais
            )
            SELECT
                a.id_assunto,
                LDESK.UUID,
                1,
                faturamentoRec.observacoes,
                faturamentoRec.data_entrada,
                faturamentoRec.data_encerramento,
                faturamentoRec.data_reativacao,
                faturamentoRec.processo_migrado,
                faturamentoRec.pro_labore,
                faturamentoRec.faturar,
                faturamentoRec.exito_faturado,
                faturamentoRec.arquivado,
                SYSDATE,
                'CUSTOM',
                abs(dbms_random.random)*(-1),
                faturamentoRec.faturado,
                faturamentoRec.data_vpartidofixo,
                faturamentoRec.id_moeda_vpartidofixo,
                faturamentoRec.valor_partidofixo,
                faturamentoRec.id_areajuridica,
                faturamentoRec.id_subareajuridica,
                faturamentoRec.observacoes_honorarios,
                faturamentoRec.id_nomevalor,
                faturamentoRec.c_primeira_instancia,
                faturamentoRec.c_segunda_instancia,
                faturamentoRec.c_terceira_instancia,
                faturamentoRec.c_finais
            FROM LDESK.JUR_ASSUNTO a
            WHERE a.id_assunto = :NEW.id_assunto;
        END LOOP;
		
		-- Loop pelos registros de jur_Pedido vinculados ao processo principal		        
		FOR PedidoRec IN cPedido LOOP
		-- Inserir uma cópia desses registros para os desdobramentos cujo ID_TIPOASSUNTO seja EDP
		    INSERT INTO LDESK.JUR_PEDIDO (
				ID_PEDIDO,
				ID_LICENCA,
				ID_ASSUNTO,
				ID_TIPOPEDIDO,
				SITUACAO,
				ID_PROGNOSTICO,
				ID_PRELIMINAR,
				MOTIVO_PRELIMINAR,
				DESCRICAO,
				CDA,
				CNPJ,
				DATA_INCLUSAO,
				USUARIO_INCLUSAO,
				CODIGO,
				ORIGEM_ALTERACAO,
				DATA,
				ID_MOEDA,
				VALOR,
				ID_PROGNOSTICO_PRELIMINAR,
				ID_CONDENACAO,
				ID_RESULTADO_PEDIDO,
				ID_EVENTO,
				C_DATACITACAO,
				C_DATAFATO,
				C_REDE_AUTORA
			)
            SELECT
                LDESK.UUID,
                1,
				a.id_assunto,
				PedidoRec.id_tipopedido,
				PedidoRec.situacao,
				PedidoRec.id_prognostico,
				PedidoRec.id_preliminar,
				PedidoRec.motivo_preliminar,
				PedidoRec.descricao,
				PedidoRec.cda,
				PedidoRec.cnpj,
				SYSDATE,
				'CUSTOM',
                abs(dbms_random.random)*(-1),
				PedidoRec.origem_alteracao,
				PedidoRec.data,
				PedidoRec.id_moeda,
				PedidoRec.valor,
				PedidoRec.id_prognostico_preliminar,
				PedidoRec.id_condenacao,
				PedidoRec.id_resultado_pedido,
				PedidoRec.id_evento,
				PedidoRec.c_datacitacao,
				PedidoRec.c_datafato,
				PedidoRec.c_rede_autora
            FROM LDESK.JUR_ASSUNTO a
            WHERE a.id_assunto = :NEW.id_assunto;
		END LOOP;
		
		-- Loop pelos registros de jur_Pedido_valor vinculados ao processo principal		        
		FOR PedidoValorRec IN cPedidoValor LOOP
		-- Inserir uma cópia desses registros para os desdobramentos cujo ID_TIPOASSUNTO seja EDP
		    INSERT INTO LDESK.JUR_PEDIDO_VALOR (
				ID_PEDIDO_VALOR,
				ID_LICENCA,
				ID_PEDIDO,
				ID_TIPOPEDIDOVALOR,
				ATUALIZAR,
				DATA,
				ID_MOEDA,
				VALOR,
				ID_FORMA_CORRECAO,
				ID_PROGNOSTICO,
				VALOR_ATUALIZADO,
				VALOR_JUROS,
				DATA_INCLUSAO,
				USUARIO_INCLUSAO,
				CODIGO,
				DATA_JUROS,
				ORIGEM_ALTERACAO,
				PARCELA,
				ID_PRELIMINAR,
				VALOR_CALCULADO1,
				OBSERVACOES,
				PERCENTUAL,
				ID_PROGNOSTICO_PRELIMINAR,
				DATA_PRELIMINAR,
				ID_MOEDA_PRELIMINAR,
				VALOR_PRELIMINAR,
				MOTIVO_PRELIMINAR,
				VALOR_CALCULADO2,
				C_PORTCENTAGEM,
				C_VALOR_CALCULADO	
			)
            SELECT
                LDESK.UUID,
                1,
				p.id_pedido,
				PedidoValorRec.id_tipopedidovalor,
				PedidoValorRec.atualizar,
				PedidoValorRec.data,
				PedidoValorRec.id_moeda,
				PedidoValorRec.valor,
				PedidoValorRec.id_forma_correcao,
				PedidoValorRec.id_prognostico,
				PedidoValorRec.valor_atualizado,
				PedidoValorRec.valor_juros,
				SYSDATE,
				'CUSTOM',
				abs(dbms_random.random)*(-1),
				PedidoValorRec.data_juros,
				PedidoValorRec.origem_alteracao,
				PedidoValorRec.parcela,
				PedidoValorRec.id_preliminar,
				PedidoValorRec.valor_calculado1,
				PedidoValorRec.observacoes,
				PedidoValorRec.percentual,
				PedidoValorRec.id_prognostico_preliminar,
				PedidoValorRec.data_preliminar,
				PedidoValorRec.id_moeda_preliminar,
				PedidoValorRec.valor_preliminar,
				PedidoValorRec.motivo_preliminar,
				PedidoValorRec.valor_calculado2,
				PedidoValorRec.c_portcentagem,
				PedidoValorRec.c_valor_calculado
            FROM LDESK.JUR_PEDIDO p
            WHERE p.id_assunto = :NEW.id_assunto;
		END LOOP;
    END IF;
END;

/* 
  Gatilho feito por MVS para realizar alterações e inserções 
  em desdobramento de 2ª e 3ª instância do perfil EDP 
*/