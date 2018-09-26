/********************************************************************************
** Copyright TOTVS S.A. (2015)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
********************************************************************************/

/********************************************************************************
** Programa.: JsonAPIRequestParser.cls
**
** Data.....: 12/06/2018
**
** Cria‡Æo..: Eduardo Filipe Gomes
**
** Objetivo.: A classe JsonAPIRequest ‚ um facilitador na manipula‡Æo da request 
** em formato JSON recebida pelas APIs Progress.
********************************************************************************/
USING com.totvs.framework.api.*.
USING Progress.Json.ObjectModel.*.

CLASS com.totvs.framework.api.JsonAPIRequestParser FINAL:

    DEFINE VARIABLE oJsonInput AS JsonObject NO-UNDO.

    CONSTRUCTOR PUBLIC JsonAPIRequestParser (INPUT pJsonInput AS JsonObject):

        oJsonInput = pJsonInput.

        parserRequest().
    END.

    DEFINE PRIVATE PROPERTY cURI AS CHARACTER NO-UNDO
    GET.
    SET.

    DEFINE PRIVATE PROPERTY cMethod AS CHARACTER NO-UNDO
    GET.
    SET.

    DEFINE PRIVATE PROPERTY oHeaders AS JsonObject NO-UNDO
    GET.
    SET.

    DEFINE PRIVATE PROPERTY aPathParams AS JsonArray NO-UNDO
    GET.
    SET.

    DEFINE PRIVATE PROPERTY oQueryParams AS JsonObject NO-UNDO
    GET.
    SET.

    DEFINE PRIVATE PROPERTY oPayload AS JsonObject NO-UNDO
    GET.
    SET.

    DEFINE PRIVATE PROPERTY aMultyPartFile AS JsonArray NO-UNDO
    GET.
    SET.

    DEFINE PRIVATE PROPERTY iPageSize AS INTEGER INITIAL 20 NO-UNDO
    GET.
    SET.

    DEFINE PRIVATE PROPERTY iPage AS INTEGER INITIAL 1 NO-UNDO
    GET.
    SET.

    DEFINE PRIVATE PROPERTY aFields AS JsonArray NO-UNDO
    GET.
    SET.

    DEFINE PRIVATE PROPERTY aOrder AS JsonArray NO-UNDO
    GET.
    SET.

    DEFINE PRIVATE PROPERTY aExpand AS JsonArray NO-UNDO
    GET.
    SET.

    /**
    * URL enviada na requisi‡Æo
    **/
    METHOD PUBLIC CHARACTER getURI():
        RETURN cURI.
    END METHOD.

    /**
    * Method utilizado na requisi‡Æo
    **/
    METHOD PUBLIC CHARACTER getMethod():
        RETURN cMethod.
    END METHOD.

    /**
    * Headers da requisi‡Æo
    **/
    METHOD PUBLIC JsonObject getHeaders():
        RETURN oHeaders.
    END METHOD.

    /**
    * Parƒmetros Paths da requisi‡Æo
    **/
    METHOD PUBLIC JsonArray getPathParams():
        RETURN aPathParams.
    END METHOD.

    /**
    * Parƒmetros Querys da requisi‡Æo
    **/
    METHOD PUBLIC JsonObject getQueryParams():
        RETURN oQueryParams.
    END METHOD.

    /**
    * Body da requisi‡Æo
    **/
    METHOD PUBLIC JsonObject getPayload():
        RETURN oPayload.
    END METHOD.

    /**
    * Body da requisi‡Æo (LONGCHAR)
    **/
    METHOD PUBLIC LONGCHAR getPayloadLongChar():
        RETURN oPayload:getJsonText().
    END METHOD.

    /**
    * Parƒmetro pageSize (quando enviado via QueryParam)
    **/
    METHOD PUBLIC INTEGER getPageSize():
        RETURN iPageSize.
    END METHOD.

    /**
    * Parƒmetro page (quando enviado via QueryParam)
    **/
    METHOD PUBLIC INTEGER getPage():
        RETURN iPage.
    END METHOD.

    /**
    * N£mero da linha de ¡nicio da pesquisa dos registros em banco (calculado)
    **/
    METHOD PUBLIC INTEGER getStartRow():
        RETURN (iPage - 1) * iPageSize + 1.
    END METHOD.

    /**
    * Parƒmetro fields (quando enviado via QueryParam) (JSONArray)
    **/
    METHOD PUBLIC JsonArray getFields():
        RETURN aFields.
    END METHOD.

    /**
    * Parƒmetro fields (quando enviado via QueryParam) (String separado por ,)
    **/
    METHOD PUBLIC CHARACTER getFieldsChar():
        RETURN JsonAPIUtils:getJsonArrayChar(aFields).
    END METHOD.

    /**
    * Parƒmetro order (quando enviado via QueryParam) (JSONArray)
    **/
    METHOD PUBLIC JsonArray getOrder():
        RETURN aOrder.
    END METHOD.

    /**
    * Parƒmetro order (quando enviado via QueryParam) (String separado por ,)
    **/
    METHOD PUBLIC CHARACTER getOrderChar():
        RETURN JsonAPIUtils:getJsonArrayChar(aOrder).
    END METHOD.

    /**
    * Parƒmetro expand (quando enviado via QueryParam) (JSONArray)
    **/
    METHOD PUBLIC JsonArray getExpand():
        RETURN aExpand.
    END METHOD.

    /**
    * Parƒmetro expand (quando enviado via QueryParam) (String separado por ,)
    **/
    METHOD PUBLIC CHARACTER getExpandChar():
        RETURN JsonAPIUtils:getJsonArrayChar(aExpand).
    END METHOD.

    METHOD PRIVATE VOID parserRequest():

        DEFINE VARIABLE iPageSizeRet AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iPageRet     AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iLoop        AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cValue       AS CHARACTER NO-UNDO.

        ASSIGN cURI           = JsonAPIUtils:getPropertyJsonObject(oJsonInput, "uri")
               cMethod        = JsonAPIUtils:getPropertyJsonObject(oJsonInput, "method")
               oHeaders       = oJsonInput:getJsonObject("headers")
               aPathParams    = oJsonInput:getJsonArray("pathParams")
               oQueryParams   = oJsonInput:getJsonObject("queryParams")
               oPayload       = oJsonInput:getJsonObject("payload")
               aMultyPartFile = oJsonInput:getJsonArray("multiPartFile")
               iPageSizeRet   = INT(JsonAPIUtils:getPropertyJsonObject(oQueryParams, "pageSize"))
               iPageRet       = INT(JsonAPIUtils:getPropertyJsonObject(oQueryParams, "page"))
               aExpand        = NEW JsonArray()
               aFields        = NEW JsonArray()
               aOrder         = NEW JsonArray().

        IF iPageSizeRet > 0 THEN
            ASSIGN iPageSize = iPageSizeRet.

        IF iPageRet > 0 THEN
            ASSIGN iPage = iPageRet.

        IF oQueryParams:has("pageSize") THEN
            oQueryParams:remove("pageSize").

        IF oQueryParams:has("page") THEN
            oQueryParams:remove("page").

        IF (oQueryParams:has("fields") AND oQueryParams:getJsonArray("fields") NE ?) THEN DO:

            ASSIGN cValue = oQueryParams:getJsonArray("fields"):getCharacter(1).

            IF (cValue NE ?) THEN DO:

                DO iLoop = 1 TO NUM-ENTRIES(cValue, ',':U):
                    aFields:ADD(ENTRY(iLoop, cValue, ',':U)).
                END.
            
                oQueryParams:remove("fields").
            END.
        END.
            
        IF (oQueryParams:has("order") AND oQueryParams:getJsonArray("order") NE ?) THEN DO:

            ASSIGN cValue = oQueryParams:getJsonArray("order"):getCharacter(1).

            IF (cValue NE ?) THEN DO:

                DO iLoop = 1 TO NUM-ENTRIES(cValue, ',':U):
                    aOrder:ADD(ENTRY(iLoop, cValue, ',':U)).
                END.
            
                oQueryParams:remove("order").
            END.
        END.

        IF (oQueryParams:has("expand") AND oQueryParams:getJsonArray("expand") NE ?) THEN DO:

            ASSIGN cValue = oQueryParams:getJsonArray("expand"):getCharacter(1).

            IF (cValue NE ?) THEN DO:

                DO iLoop = 1 TO NUM-ENTRIES(cValue, ',':U):
                    aExpand:ADD(ENTRY(iLoop, cValue, ',':U)).
                END.
            
                oQueryParams:remove("expand").
            END.
        END.
        
    END METHOD.

END CLASS.
