/********************************************************************************
** Copyright TOTVS S.A. (2015)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
********************************************************************************/

/********************************************************************************
** Programa.: JsonAPIResponseBuilder.cls
**
** Data.....: 31/07/2018
**
** Cria‡Æo..: Thiago Almeida de Souza Weber
**
** Objetivo.: A classe JsonAPIResponseBuilder ‚ um builder para a cria‡Æo da  
** response em formato JSON enviado pelas APIs Progress.
********************************************************************************/
USING com.totvs.framework.api.*.
USING Progress.Json.ObjectModel.*.

USING Progress.Lang.Error.

CLASS com.totvs.framework.api.JsonAPIResponseBuilder FINAL:

    CONSTRUCTOR PRIVATE JsonAPIResponseBuilder(): 
    END.

    /**
    * Cria um retorno positivo com o payload e com o c¢digo do status HTTP 200.
    **/
    METHOD PUBLIC STATIC JsonObject ok(INPUT pPayload AS JsonObject):

        RETURN JsonAPIResponseBuilder:ok(pPayload, 200).

    END METHOD.

    /**
    * Cria um retorno positivo com o payload e com o c¢digo do status HTTP informado.
    **/
    METHOD PUBLIC STATIC JsonObject ok(INPUT pPayload AS JsonObject, INPUT pStatus AS INTEGER):
        
        DEFINE VARIABLE oResponse AS JsonAPIResponse NO-UNDO.
        
        oResponse = new JsonAPIResponse(pPayload).
        oResponse:setStatus(pStatus).
        
        RETURN oResponse:createJsonResponse().

    END METHOD.

    /**
    * Cria um retorno positivo com a lista de resultados, com o c¢digo do status
    * HTTP 200 e se existem mais resultados a serem buscados.
    **/
    METHOD PUBLIC STATIC JsonObject ok(INPUT pPayload AS JsonArray, INPUT pHasNext AS LOGICAL):
        
        DEFINE VARIABLE oResponse AS JsonAPIResponse NO-UNDO.
        
        oResponse = new JsonAPIResponse(pPayload).
        oResponse:setHasNext(pHasNext).
        oResponse:setStatus(200).
        
        RETURN oResponse:createJsonResponse().

    END METHOD.

    /**
    * Cria um retorno de erro com base na exce‡Æo Progress.Lang.Error e 
    * com o c¢digo do status HTTP 500.
    **/
    METHOD PUBLIC STATIC JsonObject ROW(INPUT pError AS ERROR):

        RETURN JsonAPIResponseBuilder:asError(pError, 500).

    END METHOD.

    /**
    * Cria um retorno de erro com base na exce‡Æo Progress.Lang.Error e 
    * com o c¢digo do status HTTP informado.
    **/
    METHOD PUBLIC STATIC JsonObject asError(INPUT pError AS Error, INPUT pStatus AS INTEGER):
        
        DEFINE VARIABLE oResponse AS JsonAPIResponse NO-UNDO.
        DEFINE VARIABLE oPayload  AS JsonObject      NO-UNDO.
        
        ASSIGN oPayload  = NEW JsonObject().
        
        oResponse = new JsonAPIResponse(oPayload).
        oResponse:setStatus(pStatus).
        oResponse:setError(pError).
        
        RETURN oResponse:createJsonResponse().

    END METHOD.

    /**
    * Cria um retorno de erro com base na RowErrors e com o c¢digo do status
    * HTTP 500.
    **/
    METHOD PUBLIC STATIC JsonObject asError(INPUT pRowErrors AS HANDLE):

        RETURN JsonAPIResponseBuilder:asError(JsonAPIUtils:convertTempTableToJsonArray(pRowErrors), 500).

    END METHOD.

    /**
    * Cria um retorno de erro com uma lista erros da RowErrors e com o c¢digo 
    * do status HTTP informado.
    **/
    METHOD PUBLIC STATIC JsonObject asError(INPUT pRowErrors AS JsonArray, INPUT pStatus AS INTEGER):
        
        DEFINE VARIABLE oResponse AS JsonAPIResponse NO-UNDO.
        DEFINE VARIABLE oPayload  AS JsonObject      NO-UNDO.
        
        ASSIGN oPayload  = NEW JsonObject().
        
        oResponse = new JsonAPIResponse(oPayload).
        oResponse:setStatus(pStatus).
        oResponse:setRowErrors(pRowErrors).
        
        RETURN oResponse:createJsonResponse().

    END METHOD.

    /**
    * Cria um retorno vazio e com o c¢digo do status HTTP 200.
    **/
    METHOD PUBLIC STATIC JsonObject empty():

        RETURN JsonAPIResponseBuilder:empty(200).

    END METHOD.

    /**
    * Cria um retorno vazio e com o c¢digo do status HTTP informado.
    **/
    METHOD PUBLIC STATIC JsonObject empty(INPUT pStatus AS INTEGER):
        
        DEFINE VARIABLE oResponse AS JsonAPIResponse NO-UNDO.
        DEFINE VARIABLE oPayload  AS JsonObject      NO-UNDO.
        
        ASSIGN oPayload  = NEW JsonObject().
        
        oResponse = new JsonAPIResponse(oPayload).
        oResponse:setStatus(pStatus).
        
        RETURN oResponse:createJsonResponse().

    END METHOD.

END CLASS.
