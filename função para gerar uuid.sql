CREATE OR REPLACE FUNCTION ADMIN.uuid
RETURN VARCHAR2
IS
  v_seq_value RAW(8);
  v_rand_value RAW(8);
  v_final_uuid RAW(16);
BEGIN
  -- Obter o próximo valor da sequência e formatá-lo como RAW
  SELECT HEXTORAW(LPAD(TO_CHAR(BBT_SEQ.NEXTVAL, 'FMXXXXXXXXXXXXXXX'), 8, '0')) INTO v_seq_value FROM DUAL;

  -- Gerar um valor aleatório usando SYS_GUID e pegar apenas uma parte dele
  v_rand_value := UTL_RAW.SUBSTR(SYS_GUID(), 1, 8);

  -- Concatenar a sequência formatada com o valor aleatório
  v_final_uuid := UTL_RAW.CONCAT(v_seq_value, v_rand_value);

  -- Formatar o resultado como UUID com 19 caracteres (16 + 3 hífens)
  RETURN REGEXP_REPLACE(
    RAWTOHEX(v_final_uuid),
    '([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})([A-F0-9]{4})',
    '\1-\2-\3-\4'
  );
END;
