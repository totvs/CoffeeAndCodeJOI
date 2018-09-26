/********************************************************************************
** Copyright TOTVS S.A. (2015)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
********************************************************************************/

/********************************************************************************
** Programa.: JSONArray.cls
**
** Data.....: 08/04/2015
**
** Criaá∆o..: Jhosef Marks de Carvalho
**
** Objetivo.: A classe JSONArray È um complemento para a classe JSONObject pois 
**			  ela auxilia no tratamento de arrays dentro de objetos JSON.
** 
**		      Documentaá∆o completa: 
**		      http://tdn.totvs.com/display/FRAMJOI/JSONArray
**
** Ultima Alt: 14/07/2015
********************************************************************************/
USING com.totvs.framework.abl.json.*.

&SCOPED-DEFINE MAX-LENGTH-CHAR 31900

CLASS com.totvs.framework.abl.json.JSONArray FINAL:

    /* N∆o exibe mensagens de erro */
    DEFINE PUBLIC PROPERTY lMute AS LOGICAL NO-UNDO
    GET.
    SET.

    DEFINE PRIVATE TEMP-TABLE ttJsonArray
        FIELD iPosition AS INTEGER
        FIELD cValue    AS CHAR
        FIELD iIndex    AS INTEGER.

    CONSTRUCTOR JSONArray ():

        initialize().

    END CONSTRUCTOR.

    CONSTRUCTOR JSONArray (pJsonArray AS LONGCHAR):

        initialize().

        fromJSONArrayString(pJsonArray).

    END CONSTRUCTOR.

    METHOD PRIVATE VOID initialize ():

        EMPTY TEMP-TABLE ttJsonArray.

        ASSIGN lMute = TRUE.

    END METHOD.

    METHOD PUBLIC LOGICAL loadFromFile(INPUT pFile AS CHAR):

        DEFINE VARIABLE lContent AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE mContent AS MEMPTR NO-UNDO.
        
        COPY-LOB FROM FILE pFile TO mContent.
        COPY-LOB FROM mContent TO lContent.

        ASSIGN lContent = TRIM(lContent).

        IF SUBSTRING(lContent, 1, 1) = '[' AND SUBSTRING(lContent, LENGTH(lContent)) = ']' THEN DO:
            fromJSONArrayString(lContent).
            RETURN TRUE.
        END.
        ELSE
            RETURN FALSE.

    END METHOD.

    METHOD PUBLIC LOGICAL saveToFile(INPUT pFile AS CHAR):

        DEFINE VARIABLE lContent AS LONGCHAR NO-UNDO.

        ASSIGN lContent = toJSONString().

        COPY-LOB FROM lContent TO FILE pFile NO-ERROR.

        IF ERROR-STATUS:ERROR THEN DO:
            RETURN FALSE.
        END.
        ELSE
            RETURN TRUE.

    END METHOD.

    METHOD PRIVATE VOID addValue (INPUT pValue AS LONGCHAR, INPUT pPosition AS INTEGER):

        DEFINE VARIABLE iPosition   AS INTEGER NO-UNDO.
        DEFINE VARIABLE iStart      AS INTEGER NO-UNDO.
        DEFINE VARIABLE iIndex      AS INTEGER NO-UNDO.

        IF (pPosition = 0) OR (pPosition > COUNT()) THEN DO:
            ASSIGN iPosition = 1.

            FOR EACH ttJsonArray WHERE ttJsonArray.iIndex = 1 BY ttJsonArray.iPosition:
                ASSIGN iPosition = iPosition + 1.
            END.
        END.
        ELSE DO:
            FOR EACH ttJsonArray WHERE ttJsonArray.iPosition >= pPosition EXCLUSIVE-LOCK BY ttJsonArray.iPosition DESC:
                ASSIGN ttJsonArray.iPosition = ttJsonArray.iPosition + 1.
            END.

            ASSIGN iPosition = pPosition.
        END.

        ASSIGN  iStart  = 1
                iIndex  = 1.

        REPEAT:
            CREATE  ttJsonArray.
            ASSIGN  ttJsonArray.iPosition   = iPosition
                    ttJsonArray.cValue      = STRING(SUBSTRING(pValue, iStart, {&MAX-LENGTH-CHAR}))
                    ttJsonArray.iIndex      = iIndex.

            ASSIGN  iStart  = iStart + {&MAX-LENGTH-CHAR}
                    iIndex  = iIndex + 1.

            IF iStart > LENGTH(pValue) THEN
                LEAVE.
        END.

    END METHOD.

    METHOD PRIVATE VOID addValue (INPUT pValue AS LONGCHAR):
        addValue (pValue, 0).
    END METHOD.

    METHOD PUBLIC VOID putValue (INPUT pPosition AS INTEGER, INPUT pValue AS CLASS JSONObject):
        addValue(pValue:toJSONString(), pPosition).
    END METHOD.

    METHOD PUBLIC VOID putValue (INPUT pValue AS CLASS JSONObject):
        addValue(pValue:toJSONString()).
    END METHOD.

    METHOD PUBLIC VOID setJSONArray (INPUT pJson AS LONGCHAR):
        fromJSONArrayString(pJson).
    END METHOD.

    METHOD PRIVATE VOID fromJSONArrayString(INPUT pJson AS LONGCHAR):

        DEFINE VARIABLE cTmpJSON    AS LONGCHAR NO-UNDO.

        DEFINE VARIABLE cValue      AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE iEndKey     AS INTEGER NO-UNDO.
        DEFINE VARIABLE iLevel      AS INTEGER INITIAL 0 NO-UNDO.
        
        ASSIGN cTmpJSON = TRIM(pJson).
        
        EMPTY TEMP-TABLE ttJsonArray.

        /* Verifica se Ç um Array */
        IF (SUBSTRING(cTmpJSON, 1, 1) = '[') AND (SUBSTRING(cTmpJSON, LENGTH(cTmpJSON), 1) = ']') THEN
            cTmpJSON = SUBSTRING(cTmpJSON, 2, LENGTH(cTmpJSON) - 2).    
        ELSE
            RETURN.

        ASSIGN cTmpJSON = REPLACE(cTmpJSON, CHR(13), '').
        ASSIGN cTmpJSON = REPLACE(cTmpJSON, CHR(10), '').
        ASSIGN cTmpJSON = TRIM(cTmpJSON).

        /** Transforma o json array em registros na ttJson **/
        DO WHILE LENGTH(cTmpJSON) > 0:
        
            DO iEndKey = 1 TO LENGTH(cTmpJSON):
                IF SUBSTRING(cTmpJSON, iEndKey, 1) = "~{" OR SUBSTRING(cTmpJSON, iEndKey, 1) = "["  THEN DO:
                    ASSIGN iLevel = iLevel + 1.
                END.
            
                IF SUBSTRING(cTmpJSON, iEndKey, 1) = "~}" OR SUBSTRING(cTmpJSON, iEndKey, 1) = "]" THEN DO:
                    ASSIGN iLevel = iLevel - 1.
            
                    IF iLevel = 0 THEN LEAVE.
                END.
            END.

            ASSIGN cValue   = TRIM(SUBSTRING(cTmpJSON, INDEX(cTmpJSON, '~{'), iEndKey)).
            ASSIGN cTmpJSON = TRIM(SUBSTRING(cTmpJSON, iEndKey + 1)).

            IF SUBSTRING(cTmpJSON, 1, 1) = ',' THEN
                ASSIGN cTmpJSON = TRIM(SUBSTRING(cTmpJSON, 2)).
        
            addValue(cValue).
        END.
    END METHOD.

    METHOD PUBLIC INTEGER COUNT ():

        DEFINE VARIABLE iCount AS INTEGER INITIAL 0 NO-UNDO.

        FOR EACH ttJsonArray WHERE ttJsonArray.iIndex = 1 BY ttJsonArray.iPosition:
            ASSIGN iCount = iCount + 1.
        END.

        RETURN iCount.

    END METHOD.

    METHOD PUBLIC VOID remove (pPosition AS INTEGER):

        IF pPosition <= COUNT() THEN DO:
            FOR EACH ttJsonArray WHERE ttJsonArray.iPosition = pPosition:
                DELETE ttJsonArray.
            END.

            FOR EACH ttJsonArray WHERE iPosition >= pPosition BY iPosition:
                ASSIGN ttJsonArray.iPosition = iPosition - 1.
            END.
        END.

    END METHOD.

    METHOD PUBLIC LONGCHAR getJSONString (pPosition AS INTEGER):

        DEFINE VARIABLE cValue AS LONGCHAR INITIAL '' NO-UNDO.

        FOR EACH ttJsonArray WHERE ttJsonArray.iPosition = pPosition BY ttJsonArray.iIndex:
            ASSIGN cValue = cValue + ttJsonArray.cValue.
        END.

        IF cValue = '' THEN DO:
            IF NOT lMute THEN DO:
                MESSAGE "Item na posiá∆o " pPosition " n∆o encontrado."
                    VIEW-AS ALERT-BOX INFO BUTTONS OK.
            END.
        END.

        RETURN cValue.

    END METHOD.

    METHOD PUBLIC JSONObject getJSONObject (pPosition AS INTEGER):

        DEFINE VARIABLE oJSONObject AS CLASS JSONObject NO-UNDO.

        oJSONObject = NEW JSONObject(getJSONString(pPosition)).

        RETURN oJSONObject.

    END METHOD.

    METHOD PUBLIC LONGCHAR toJSONString():

        DEFINE VARIABLE lcJsonArray AS LONGCHAR INITIAL '' NO-UNDO.
        DEFINE BUFFER bbJsonArray FOR TEMP-TABLE ttJsonArray.

        DEFINE VARIABLE lcValue AS LONGCHAR NO-UNDO.

        FOR EACH ttJsonArray WHERE ttJsonArray.iIndex = 1 NO-LOCK BY ttJsonArray.iPosition:

            ASSIGN lcValue = ''.

            FOR EACH bbJsonArray WHERE bbJsonArray.iPosition = ttJsonArray.iPosition NO-LOCK BY bbJsonArray.iIndex:
                ASSIGN lcValue = lcValue + bbJsonArray.cValue. 
            END.

            IF TRIM(lcJsonArray) = '' THEN
                ASSIGN lcJsonArray = TRIM(lcValue).
            ELSE 
                ASSIGN lcJsonArray = lcJsonArray + ',' + TRIM(lcValue).

        END.

        RETURN '[' + lcJsonArray + ']'.

    END METHOD.

END CLASS.
