/********************************************************************************
** Copyright TOTVS S.A. (2015)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
********************************************************************************/

/********************************************************************************
** Programa.: JSONObject.cls
**
** Data.....: 08/04/2015
**
** Criaá∆o..: Jhosef Marks de Carvalho
**
** Objetivo.: A classe JSONObject foi desenvolvida para auxiliar no 
**            tratamento de objetos JSON.
** 
**		      Documentaá∆o completa: 
**            http://tdn.totvs.com/display/FRAMJOI/JSONObject
**
** Ultima Alt: 14/07/2015
********************************************************************************/

USING com.totvs.framework.abl.json.*.

&SCOPED-DEFINE MAX-LENGTH-CHAR 31900

CLASS com.totvs.framework.abl.json.JSONObject FINAL:

    DEFINE PUBLIC PROPERTY cDateFormat AS CHAR NO-UNDO
    GET.
    SET.

    /* N∆o exibe mensagens de erro */
    DEFINE PUBLIC PROPERTY lMute AS LOGICAL NO-UNDO
    GET.
    SET.

    DEFINE PRIVATE TEMP-TABLE ttJson
        FIELD cName     AS CHAR
        FIELD cValue    AS CHAR
        FIELD iIndex    AS INTEGER
        FIELD lQuoted   AS LOGICAL.

    CONSTRUCTOR JSONObject ():

        initialize().

    END CONSTRUCTOR.

    CONSTRUCTOR JSONObject (pJson AS LONGCHAR):

        initialize().

        fromJSONString(pJson).

    END CONSTRUCTOR.

    METHOD PRIVATE VOID initialize ():

        EMPTY TEMP-TABLE ttJson.

        ASSIGN  cDateFormat = "dmy".
                lMute       = TRUE.

    END METHOD.

    METHOD PUBLIC LOGICAL loadFromFile(INPUT pFile AS CHAR):

        DEFINE VARIABLE lContent AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE mContent AS MEMPTR NO-UNDO.
        
        COPY-LOB FROM FILE pFile TO mContent.
        COPY-LOB FROM mContent TO lContent.

        ASSIGN lContent = TRIM(lContent).

        IF SUBSTRING(lContent, 1, 1) = '~{' AND SUBSTRING(lContent, LENGTH(lContent)) = '~}' THEN DO:
            fromJSONString(lContent).
            RETURN TRUE.
        END.
        ELSE
            RETURN FALSE.

    END METHOD.

    METHOD PUBLIC LOGICAL saveToFile(INPUT pFile AS CHAR):

        DEFINE VARIABLE lContent AS LONGCHAR NO-UNDO.

        ASSIGN lContent = toJSONString().

        COPY-LOB FROM lContent TO FILE pFile NO-ERROR.

        IF ERROR-STATUS:ERROR THEN
            RETURN FALSE.
        ELSE
            RETURN TRUE.

    END METHOD.

    METHOD PRIVATE VOID addValue (INPUT pName AS CHAR, INPUT pValue AS LONGCHAR, INPUT pQuoted AS LOGICAL):
        
        DEFINE VARIABLE cValue  AS CHAR INITIAL '' NO-UNDO.
        DEFINE VARIABLE iStart  AS INTEGER NO-UNDO.
        DEFINE VARIABLE iIndex  AS INTEGER NO-UNDO.

        /* Verifica e limpa se existir mais de um registro para o elemento antes de incluir ou atualizar */
        FOR EACH ttJson WHERE ttJson.cName = pName AND ttJson.iIndex > 1 EXCLUSIVE-LOCK:
            DELETE ttJson.
        END.

        ASSIGN cValue = SUBSTRING(pValue, 1, {&MAX-LENGTH-CHAR}).

        /*  Atualiza ou inclui o primeiro registro do elemento */
        FIND FIRST ttJson WHERE ttJson.cName = pName AND ttJson.iIndex = 1 NO-LOCK NO-ERROR.
        IF AVAIL ttJson THEN DO:
            ASSIGN  ttJson.cValue   = cValue
                    ttJson.lQuoted  = pQuoted.
        END.
        ELSE DO:
            CREATE  ttJson.
            ASSIGN  ttJson.cName    = pName
                    ttJson.cValue   = cValue
                    ttJson.iIndex   = 1
                    ttJson.lQuoted  = pQuoted.
        END.

        /* Inclui demais registros para o elemento caso o mesmo tenha mais caracteres que um char possa suportar */
        IF LENGTH(pValue) > {&MAX-LENGTH-CHAR} THEN DO:
            ASSIGN  iStart  = {&MAX-LENGTH-CHAR} + 1
                    iIndex  = 2.

            REPEAT:
                CREATE  ttJson.
                ASSIGN  ttJson.cName    = pName
                        ttJson.cValue   = SUBSTRING(pValue, iStart, {&MAX-LENGTH-CHAR})
                        ttJson.iIndex   = iIndex
                        ttJson.lQuoted  = pQuoted.

                ASSIGN  iStart  = iStart + {&MAX-LENGTH-CHAR}
                        iIndex  = iIndex + 1.

                IF iStart > LENGTH(pValue) THEN
                    LEAVE.
            END.           
        END.

    END METHOD.

    METHOD PRIVATE VOID addValue (INPUT pName AS CHAR, INPUT pValue AS LONGCHAR):
        addValue(pName, pValue, FALSE).
    END METHOD.

    METHOD PUBLIC VOID putValue (INPUT pName AS CHAR, INPUT pValue AS CHAR):
        addValue(pName, pValue, TRUE).
    END METHOD.

    METHOD PUBLIC VOID putValue (INPUT pName AS CHAR, INPUT pValue AS LONGCHAR):
        addValue(pName, pValue, TRUE).
    END METHOD.

    METHOD PUBLIC VOID putValue (INPUT pName AS CHAR, INPUT pValue AS INTEGER):
        addValue(pName, STRING(pValue)).
    END METHOD.

    METHOD PUBLIC VOID putValue (INPUT pName AS CHAR, INPUT pValue AS INT64):
        addValue(pName, STRING(pValue)).
    END METHOD.

    METHOD PUBLIC VOID putValue (INPUT pName AS CHAR, INPUT pValue AS DECIMAL):
        addValue(pName, REPLACE(STRING(pValue), "," , ".")).
    END METHOD.

    METHOD PUBLIC VOID putValue (INPUT pName AS CHAR, INPUT pValue AS LOGICAL):
        addValue(pName, STRING(pValue,"true/false")).
    END METHOD.

    METHOD PUBLIC VOID putValue (INPUT pName AS CHAR, INPUT pValue AS DATE):

        DEFINE VARIABLE cOldFormat  AS CHAR NO-UNDO.

        ASSIGN cOldFormat = SESSION:DATE-FORMAT.

        SESSION:DATE-FORMAT = cDateFormat.

        addValue(pName, STRING(pValue), TRUE).

        SESSION:DATE-FORMAT = cOldFormat.

    END METHOD.

    METHOD PUBLIC VOID putValue (INPUT pName AS CHAR, INPUT pValue AS DATETIME):

        DEFINE VARIABLE cOldFormat  AS CHAR NO-UNDO.

        ASSIGN cOldFormat = SESSION:DATE-FORMAT.

        SESSION:DATE-FORMAT = cDateFormat.

        addValue(pName, STRING(pValue), TRUE).

        SESSION:DATE-FORMAT = cOldFormat.

    END METHOD.

    METHOD PUBLIC VOID putValue (INPUT pName AS CHAR, INPUT pValue AS CLASS JSONObject):
        addValue(pName, pValue:toJSONString()).

        DELETE OBJECT pValue.
    END METHOD.

    METHOD PUBLIC VOID putValue (INPUT pName AS CHAR, INPUT pValue AS CLASS JSONArray):
        addValue(pName, pValue:toJSONString()).

        DELETE OBJECT pValue.
    END METHOD.

    METHOD PUBLIC VOID setJSONString (INPUT pJson AS LONGCHAR):
        fromJSONString(pJson).
    END METHOD.

    METHOD PRIVATE VOID fromJSONString(INPUT pJson AS LONGCHAR):

        DEFINE VARIABLE cTmpJSON    AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE cName       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lQuoted     AS LOGICAL.

        DEFINE VARIABLE cValue      AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE iEndKey     AS INTEGER NO-UNDO.
        DEFINE VARIABLE iLevel      AS INTEGER INITIAL 0 NO-UNDO.

        ASSIGN cTmpJSON = TRIM(pJson).

        EMPTY TEMP-TABLE ttJson.

        /* Verifica se Ç um Objeto */
        IF (SUBSTRING(cTmpJSON, 1, 1) = '~{') AND (SUBSTRING(cTmpJSON, LENGTH(cTmpJSON), 1) = '~}') THEN
            cTmpJSON = SUBSTRING(cTmpJSON, 2, LENGTH(cTmpJSON) - 2).    
        ELSE
            RETURN.

        ASSIGN cTmpJSON = TRIM(cTmpJSON).
        ASSIGN cTmpJSON = REPLACE(cTmpJSON, CHR(13), '').
        ASSIGN cTmpJSON = REPLACE(cTmpJSON, CHR(10), '').

        /** Transforma objeto JSON em registros na ttJson **/
        DO WHILE INDEX(cTmpJSON, ':') > 0:

            ASSIGN  cName    = TRIM(REPLACE(ENTRY(1, cTmpJSON, ':'), '"', ''))
                    cValue   = ''
                    cTmpJSON = TRIM(SUBSTRING(cTmpJSON, INDEX(cTmpJSON, ':') + 1))
                    lQuoted  = FALSE.

            IF SUBSTRING(cTmpJSON, 1, 1) = "~{" OR SUBSTRING(cTmpJSON, 1, 1) = "["  THEN DO:
                DO iEndKey = 1 TO LENGTH(cTmpJSON):
                    IF SUBSTRING(cTmpJSON, iEndKey, 1) = "~{" OR SUBSTRING(cTmpJSON, iEndKey, 1) = "["  THEN DO:
                        ASSIGN iLevel = iLevel + 1.
                    END.

                    IF SUBSTRING(cTmpJSON, iEndKey, 1) = "~}" OR SUBSTRING(cTmpJSON, iEndKey, 1) = "]" THEN DO:
                        ASSIGN iLevel = iLevel - 1.

                        IF iLevel = 0 THEN LEAVE.
                    END.
                END.

                ASSIGN  cValue   = SUBSTRING(cTmpJSON, 1, iEndKey)
                        cTmpJSON = SUBSTRING(cTmpJSON, iEndKey + 1).
            END.
            ELSE IF SUBSTRING(cTmpJSON, 1, 1) = '"' THEN DO:

                DO iEndKey = 2 TO LENGTH(cTmpJSON):
                    IF SUBSTRING(cTmpJSON, iEndKey, 1) = '"' AND SUBSTRING(cTmpJSON, iEndKey - 1, 1) <> '~\'  THEN DO:
                        LEAVE.
                    END.
                END.
        
                ASSIGN  cValue   = SUBSTRING(cTmpJSON, 1, iEndKey)
                        cTmpJSON = SUBSTRING(cTmpJSON, iEndKey + 1).
        
                IF SUBSTRING(cValue, 1, 1) = '"' THEN DO:
                    ASSIGN  cValue  = SUBSTRING(cValue, 2, LENGTH(cValue) - 2)
                            lQuoted = TRUE.
                END.
            END.
            ELSE DO:
                ASSIGN  cValue   = ENTRY(1, cTmpJSON, ',')
                        cTmpJSON = TRIM(SUBSTRING(cTmpJSON, INDEX(cTmpJSON, ',') + 1)).
            END.

            IF SUBSTRING(cTmpJSON, 1, 1) = ',' THEN
                ASSIGN cTmpJSON = TRIM(SUBSTRING(cTmpJSON, 2)).

            addValue(cName, cValue, lQuoted).

        END.
        
    END METHOD.

    METHOD PUBLIC VOID remove (pName AS CHAR):

        FOR EACH ttJson WHERE ttJson.cName = pName EXCLUSIVE-LOCK:
            DELETE ttJson.
        END.

    END METHOD.

    METHOD PRIVATE LONGCHAR getValue (pName AS CHAR, lFirst AS LOGICAL):

        DEFINE VARIABLE cValue AS LONGCHAR INITIAL '' NO-UNDO.

        IF lFirst = TRUE THEN DO:
            FIND FIRST ttJson WHERE ttJson.cName = pName AND ttJson.iIndex = 1 NO-LOCK NO-ERROR.
            IF AVAIL ttJson THEN DO:
                ASSIGN cValue = ttJson.cValue.
            END.
        END.
        ELSE DO:
            FOR EACH ttJson WHERE ttJson.cName = pName EXCLUSIVE-LOCK BY iIndex:
                ASSIGN cValue = cValue + ttJson.cValue.
            END.
        END.

        IF cValue = '' THEN DO:
            IF NOT lMute THEN DO:
                MESSAGE pName " n∆o encontrado."
                    VIEW-AS ALERT-BOX INFO BUTTONS OK.
            END.

            RETURN ERROR.
        END.

        RETURN cValue.

    END METHOD.

    METHOD PRIVATE CHAR getValue (pName AS CHAR):

        RETURN STRING(SUBSTRING(getValue(pName, TRUE), 1, {&MAX-LENGTH-CHAR})).

    END METHOD.

    METHOD PUBLIC CHAR getString (pName AS CHAR):

        DEFINE VARIABLE cValue AS CHAR NO-UNDO.

        ASSIGN cValue = getValue(pName).

        IF TRIM(cValue) = "null" OR TRIM(cValue) = "ull" THEN
            RETURN ?.

        RETURN cValue.

    END METHOD.

    METHOD PUBLIC LONGCHAR getLongChar (pName AS CHAR):

        DEFINE VARIABLE cValue AS LONGCHAR NO-UNDO.

        ASSIGN cValue = getValue(pName, FALSE).

        IF TRIM(cValue) = "null" OR TRIM(cValue) = "ull" THEN
            RETURN ?.

        RETURN cValue.

    END METHOD.

    METHOD PUBLIC INTEGER getInteger (pName AS CHAR):

        DEFINE VARIABLE cValue AS CHAR NO-UNDO.
        DEFINE VARIABLE iValue AS INTEGER NO-UNDO.

        ASSIGN cValue = getValue(pName).
    
        IF cValue = "null" OR cValue = "ull" THEN
            RETURN ?.

        ASSIGN iValue = INT(cValue) NO-ERROR.
        
        IF ERROR-STATUS:ERROR THEN DO:
            IF NOT lMute THEN DO:
                MESSAGE pName " n∆o Ç um inteiro."
                    VIEW-AS ALERT-BOX INFO BUTTONS OK.
            END.

            RETURN ERROR.
        END.
        ELSE
            RETURN iValue.

    END METHOD.

    METHOD PUBLIC INT64 getInt64 (pName AS CHAR):

        DEFINE VARIABLE cValue AS CHAR NO-UNDO.
        DEFINE VARIABLE iValue AS INT64 NO-UNDO.
        
        ASSIGN cValue = getValue(pName).
        
        IF cValue = "null" OR cValue = "ull" THEN
            RETURN ?.
        
        ASSIGN iValue = INT64(cValue) NO-ERROR.
        
        IF ERROR-STATUS:ERROR THEN DO:
            IF NOT lMute THEN DO:
                MESSAGE pName " no Ç um inteiro."
                    VIEW-AS ALERT-BOX INFO BUTTONS OK.
            END.
            
            RETURN ERROR.
        END.
        ELSE
            RETURN iValue.
    
    END METHOD.

    METHOD PUBLIC DECIMAL getDecimal (pName AS CHAR):

        DEFINE VARIABLE cValue AS CHAR NO-UNDO.
        DEFINE VARIABLE dValue AS DECIMAL NO-UNDO.

        ASSIGN cValue = getValue(pName).
    
        IF cValue = "null" OR cValue = "ull" THEN
            RETURN ?.

        /* Substitui v°rgulas e pontos pelo SESSION:NUMERIC-DECIMAL-POINT */
        ASSIGN cValue = REPLACE(cValue, '.', SESSION:NUMERIC-DECIMAL-POINT).
        ASSIGN cValue = REPLACE(cValue, ',', SESSION:NUMERIC-DECIMAL-POINT).

        ASSIGN dValue = DECIMAL(cValue) NO-ERROR.
        
        IF ERROR-STATUS:ERROR THEN DO:
            IF NOT lMute THEN DO:
                MESSAGE pName " n∆o Ç um decimal."
                    VIEW-AS ALERT-BOX INFO BUTTONS OK.
            END.

            RETURN ERROR.
        END.
        ELSE
            RETURN dValue.

    END METHOD.

    METHOD PUBLIC LOGICAL getBoolean (pName AS CHAR):

        DEFINE VARIABLE cValue AS CHAR NO-UNDO.

        ASSIGN cValue = getValue(pName).

        IF cValue = "null" OR cValue = "ull" THEN
            RETURN ?.

        RETURN (cValue = "true" OR cValue = "yes").

    END METHOD .

    METHOD PUBLIC DATE getDate (pName AS CHAR):

        DEFINE VARIABLE cValue      AS CHAR NO-UNDO.
        DEFINE VARIABLE dValue      AS DATE NO-UNDO.
        DEFINE VARIABLE cOldFormat  AS CHAR NO-UNDO.

        ASSIGN cValue = getValue(pName).

        IF cValue = "null" OR cValue = "ull" THEN
            RETURN ?.

        ASSIGN cOldFormat = SESSION:DATE-FORMAT.
        SESSION:DATE-FORMAT = cDateFormat.

        ASSIGN dValue = DATE(cValue) NO-ERROR.

        SESSION:DATE-FORMAT = cOldFormat.

        IF ERROR-STATUS:ERROR THEN DO:
            IF NOT lMute THEN DO:
                MESSAGE pName " n∆o Ç uma data."
                    VIEW-AS ALERT-BOX INFO BUTTONS OK.
            END.

            RETURN ERROR.
        END.
        ELSE
            RETURN dValue.

    END METHOD.

    METHOD PUBLIC DATETIME getDateTime (pName AS CHAR):

        DEFINE VARIABLE cValue      AS CHAR NO-UNDO.
        DEFINE VARIABLE dValue      AS DATETIME NO-UNDO.
        DEFINE VARIABLE cOldFormat  AS CHAR NO-UNDO.

        ASSIGN cValue = getValue(pName).

        IF cValue = "null" OR cValue = "ull" THEN
            RETURN ?.

        ASSIGN cOldFormat = SESSION:DATE-FORMAT.
        SESSION:DATE-FORMAT = cDateFormat.

        ASSIGN dValue = DATETIME(cValue) NO-ERROR.

        SESSION:DATE-FORMAT = cOldFormat.

        IF ERROR-STATUS:ERROR THEN DO:
            IF NOT lMute THEN DO:
                MESSAGE pName " n∆o Ç uma data."
                    VIEW-AS ALERT-BOX INFO BUTTONS OK.
            END.

            RETURN ERROR.
        END.
        ELSE
            RETURN dValue.

    END METHOD.

    METHOD PUBLIC JSONObject getJSONObject (pName AS CHAR):

        DEFINE VARIABLE cValue      AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE oJSONObject AS CLASS JSONObject NO-UNDO.
        
        ASSIGN cValue = getValue(pName, FALSE) NO-ERROR.

        oJSONObject = NEW JSONObject(cValue).

        RETURN oJSONObject.

    END METHOD.

    METHOD PUBLIC JSONArray getJSONArray (pName AS CHAR):

        DEFINE VARIABLE cValue     AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE oJSONArray AS CLASS JSONArray NO-UNDO.

        ASSIGN cValue = getValue(pName, FALSE) NO-ERROR.

        oJSONArray = NEW JSONArray(cValue).

        RETURN oJSONArray.

    END METHOD.

    METHOD PUBLIC LONGCHAR toJSONString():

        DEFINE VARIABLE lcJson AS LONGCHAR INITIAL '' NO-UNDO.
        DEFINE BUFFER bbJson   FOR TEMP-TABLE ttJson.

        DEFINE VARIABLE cValue AS LONGCHAR NO-UNDO.

        FOR EACH ttJson WHERE ttJson.iIndex = 1 NO-LOCK:

            ASSIGN cValue = ''.

            FOR EACH bbJson WHERE bbJson.cName = ttJson.cName NO-LOCK:
                ASSIGN cValue = cValue + bbJson.cValue. 
            END.

            IF ttJson.lQuoted THEN
                ASSIGN cValue = '"' + TRIM(cValue) + '"'.
            ELSE
                ASSIGN cValue = TRIM(cValue).

            IF TRIM(lcJson) = '' THEN
                ASSIGN lcJson = '"' + ttJson.cName + '":' + cValue.
            ELSE 
                ASSIGN lcJson = lcJson + ',"' + ttJson.cName + '":' + cValue.
        END.

        RETURN '~{' + lcJson + '~}'.

    END METHOD.

END CLASS.
