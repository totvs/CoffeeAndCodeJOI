/********************************************************************************
** Copyright TOTVS S.A. (2015)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
********************************************************************************/

/********************************************************************************
** Programa.: JsonAPIUtils.cls
**
** Data.....: 12/06/2018
**
** Cria‡Æo..: Eduardo Filipe Gomes
**
** Objetivo.: A classe JsonAPIUtils ‚ um utilit rio para utiliza‡Æo
** pelas APIs Progress.
********************************************************************************/
USING com.totvs.framework.api.*.
USING Progress.Json.ObjectModel.*.

CLASS com.totvs.framework.api.JsonAPIUtils FINAL:

    /**
    * Verifica se o objeto possui a propriedade e, de acordo com o tipo do dado, faz o get correto.  
    * Caso a propriedade seja um array, todos os dados sÆo agrupados e transformados em uma string e os dados serÆo separados por ','
    **/
    METHOD PUBLIC STATIC CHARACTER getPropertyJsonObject(INPUT oJsonObject AS JsonObject, INPUT cProperty AS CHARACTER):

        DEFINE VARIABLE cReturn AS CHARACTER   NO-UNDO.
        DEFINE VARIABLE iType   AS INTEGER     NO-UNDO.
    
        IF oJsonObject:has(cProperty) THEN DO:

            ASSIGN iType = oJsonObject:getType(cProperty).

            CASE iType:
                WHEN JsonDataType:STRING THEN
                    ASSIGN cReturn = oJsonObject:getCharacter(cProperty).
                WHEN JsonDataType:NUMBER THEN
                    ASSIGN cReturn = STRING(oJsonObject:getInteger(cProperty)).
                WHEN JsonDataType:BOOLEAN THEN
                    ASSIGN cReturn = STRING(oJsonObject:getLogical(cProperty)).
                WHEN JsonDataType:OBJECT THEN
                    ASSIGN cReturn = STRING(oJsonObject:getJsonText(cProperty)).
                WHEN JsonDataType:ARRAY THEN
                    ASSIGN cReturn = getJsonArrayChar(oJsonObject:getJsonArray(cProperty)).
                WHEN JsonDataType:NULL THEN
                    ASSIGN cReturn = ''.
            END CASE.
        END.
    
        RETURN cReturn.
        
    END METHOD.

    /**
    * Retorna todos os dados agrupados e transformados em uma string separados por ','
    **/
    METHOD PUBLIC STATIC CHARACTER getJsonArrayChar(INPUT oJsonArray AS JsonArray):

        RETURN REPLACE(REPLACE(REPLACE(STRING(oJsonArray:getJsonText()),'"',''),'[',''),']','').

    END METHOD.

    /**
    * Verifica se o Json ‚ um array ou object
    **/
    METHOD PUBLIC STATIC LOGICAL checkJsonIsArray(INPUT pJsonConstruct AS JsonConstruct):

        DEFINE VARIABLE oJsonArray AS JsonArray.
    
        ASSIGN oJsonArray = CAST(pJsonConstruct, JsonArray).
    
        RETURN TRUE.
    
        CATCH eAnyError AS Progress.Lang.Error:
            RETURN FALSE.
        END CATCH.

    END METHOD.

    /**
    * Formata data para padrÆo utilizado em objetos JSON
    **/
    METHOD PUBLIC STATIC CHARACTER changeDateToISO (INPUT pDate AS DATE, INPUT pHour AS CHARACTER):

        DEFINE VARIABLE cDateISO AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cTimeZone AS CHARACTER NO-UNDO.
        
        // 2018-06-26T13:44:51-03:00

        ASSIGN cTimeZone = STRING(DATETIME-TZ(pDate, MTIME, TIMEZONE)).
            
        ASSIGN cDateISO = STRING(YEAR(pDate)) 
                     + '-' + STRING(MONTH(pDate),'99') 
                     + '-' + STRING(DAY(pDate),'99') 
                     + 'T' + SUBSTR(pHour,1,2) 
                     + ':' + SUBSTR(pHour,4,2) 
                     + ':' + SUBSTR(pHour,7,2)
                     + '-' + ENTRY(2,STRING(cTimeZone),"-").
        
        RETURN cDateISO.

    END METHOD.

    /**
    * Converte data ISO para Date
    **/
    METHOD PUBLIC STATIC DATE changeISOToDate (INPUT pDateISO AS CHARACTER):

        DEFINE VARIABLE cDateISO    AS CHARACTER NO-UNDO.
        DEFINE VARIABLE dDateReturn AS DATE NO-UNDO.
    
        ASSIGN cDateISO = ENTRY(1,pDateISO,'T')
               dDateReturn = DATE(INT(ENTRY(2,cDateISO,'-')), INT(ENTRY(3,cDateISO,'-')), INT(ENTRY(1,cDateISO,'-'))).

        RETURN dDateReturn.

    END METHOD.

    /**
    * Converte um LongChar para um JSONObject
    **/
    METHOD PUBLIC STATIC JsonObject convertLongcharToJsonObject (INPUT pJsonChar AS LONGCHAR):

        DEFINE VARIABLE oJsonObject AS JsonObject        NO-UNDO.
        DEFINE VARIABLE oObjParse   AS ObjectModelParser NO-UNDO.
    
        ASSIGN oJsonObject = NEW JsonObject()
               oObjParse   = NEW ObjectModelParser()
               oJsonObject = CAST(oObjParse:Parse(pJsonChar), JsonObject).
      
        DELETE OBJECT oObjParse   NO-ERROR.
      
        RETURN oJsonObject.

    END METHOD.

    /**
    * Converte uma TEMP-TABLE handle para um JSONObject
    **/
    METHOD PUBLIC STATIC JsonObject convertTempTableToJsonObject (INPUT pTempTable AS HANDLE):

        RETURN convertTempTableToJsonObject(pTempTable, FALSE).

    END METHOD.

    /**
    * Converte uma TEMP-TABLE handle para um JSONObject podendo optar pela omissÆo dos valores iniciais.
    **/
    METHOD PUBLIC STATIC JsonObject convertTempTableToJsonObject (INPUT pTempTable AS HANDLE, INPUT pOmitInitialValues AS LOGICAL):

        DEFINE VARIABLE lJsonChar AS LONGCHAR NO-UNDO.

        pTempTable:WRITE-JSON ('LONGCHAR':U, lJsonChar, FALSE, ?, pOmitInitialValues).

        RETURN convertLongcharToJsonObject(lJsonChar).

    END METHOD.

    /**
    * Converte uma TEMP-TABLE handle para um JSONArray
    **/
    METHOD PUBLIC STATIC JsonArray convertTempTableToJsonArray (INPUT pTempTable AS HANDLE):

        RETURN convertTempTableToJsonArray(pTempTable, FALSE).

    END METHOD.

    /**
    * Converte uma TEMP-TABLE handle para um JSONArray podendo optar pela omissÆo dos valores iniciais.
    **/
    METHOD PUBLIC STATIC JsonArray convertTempTableToJsonArray (INPUT pTempTable AS HANDLE, INPUT pOmitInitialValues AS LOGICAL):

        DEFINE VARIABLE oResult AS JsonObject NO-UNDO.

        ASSIGN oResult = convertTempTableToJsonObject(pTempTable, pOmitInitialValues).
        
        RETURN oResult:getJsonArray(pTempTable:SERIALIZE-NAME).

    END METHOD.

    /**
    * Converte uma TEMP-TABLE handle para um single JSONObject
    **/
    METHOD PUBLIC STATIC JsonObject convertTempTableFirstItemToJsonObject (INPUT pTempTable AS HANDLE):

        RETURN convertTempTableFirstItemToJsonObject(pTempTable, FALSE).

    END METHOD.

    /**
    * Converte o primeiro registro de uma TEMP-TABLE handle para um single 
    * JSONObject podendo optar pela omissÆo dos valores iniciais.
    **/
    METHOD PUBLIC STATIC JsonObject convertTempTableFirstItemToJsonObject (INPUT pTempTable AS HANDLE, INPUT pOmitInitialValues AS LOGICAL):

        DEFINE VARIABLE aResult AS JsonArray NO-UNDO.

        ASSIGN aResult = convertTempTableToJsonArray(pTempTable, pOmitInitialValues).

        IF aResult EQ ? OR aResult:LENGTH EQ 0 THEN DO:
            RETURN NEW JsonObject().
        END.
        
        RETURN aResult:getJsonObject(1).

    END METHOD.

    /**
    * Retorna a lista de campos da tabela para a lista de exce‡Æo 
    * com base no nome serializado do campo separados por ','.
    **/
    METHOD PUBLIC STATIC CHARACTER getTableExceptFieldsBySerializedFields (INPUT oHandle AS HANDLE, INPUT aFields AS JsonArray):

        DEFINE VARIABLE i         AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cFields   AS CHARACTER NO-UNDO INITIAL '':U.
        DEFINE VARIABLE cJsonText AS CHARACTER NO-UNDO.

        IF oHandle EQ ? OR aFields EQ ? OR aFields:LENGTH EQ 0 THEN RETURN cFields.

        ASSIGN cJsonText = aFields:getJsonText().

        DO i = 1 TO oHandle:DEFAULT-BUFFER-HANDLE:NUM-FIELDS:

            IF INDEX(cJsonText, QUOTER(
                oHandle:DEFAULT-BUFFER-HANDLE:BUFFER-FIELD(i):SERIALIZE-NAME)
            ) EQ 0 THEN DO:

                IF cFields NE ? AND LENGTH(TRIM(cFields)) > 0 THEN DO:
                    ASSIGN cFields = cFields + ',':U.
                END.

                ASSIGN cFields = cFields + oHandle:DEFAULT-BUFFER-HANDLE:BUFFER-FIELD(i):NAME.
            END.
        END.

        RETURN cFields.

    END METHOD.
    
END CLASS.
