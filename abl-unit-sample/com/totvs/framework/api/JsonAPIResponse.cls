/********************************************************************************
** Copyright TOTVS S.A. (2015)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
********************************************************************************/

/********************************************************************************
** Programa.: JsonAPIResponse.cls
**
** Data.....: 12/06/2018
**
** Cria‡Æo..: Eduardo Filipe Gomes
**
** Objetivo.: A classe JsonAPIResponse ‚ um facilitador na cria‡Æo da response 
** em formato JSON enviado pelas APIs Progress.
********************************************************************************/
USING com.totvs.framework.api.*.
USING Progress.Json.ObjectModel.*.

CLASS com.totvs.framework.api.JsonAPIResponse FINAL:

    DEFINE VARIABLE oJsonInput AS JsonConstruct NO-UNDO.

    CONSTRUCTOR PUBLIC JsonAPIResponse (INPUT pJsonInput AS JsonConstruct):

        oJsonInput = pJsonInput.
    END.

    DEFINE PRIVATE PROPERTY iStatus AS INTEGER INITIAL 200 NO-UNDO
    GET.
    SET.

    DEFINE PRIVATE PROPERTY lHasNext AS LOGICAL INITIAL FALSE NO-UNDO
    GET.
    SET.

    DEFINE PRIVATE PROPERTY oRowErrors AS JsonArray NO-UNDO
    GET.
    SET.

    DEFINE PRIVATE PROPERTY oAppError AS Progress.Lang.AppError NO-UNDO
    GET.
    SET.

    DEFINE PRIVATE PROPERTY oError AS Progress.Lang.Error NO-UNDO
    GET.
    SET.

    /**
    * Seta um status code customizado na response
    **/
    METHOD PUBLIC VOID setStatus (pStatus AS INTEGER):
        ASSIGN iStatus = pStatus.
    END METHOD.

    /**
    * Seta um indicadodor se h  mais registros a serem listados 
    **/
    METHOD PUBLIC VOID setHasNext (pHasNext AS LOGICAL):
        ASSIGN lHasNext = pHasNext.
    END METHOD.

    /**
    * Seta a tabela tempor ria de erros a serem retornados na response
    **/
    METHOD PUBLIC VOID setRowErrors (pRowErrors AS JsonArray):
         ASSIGN oRowErrors = pRowErrors.
    END METHOD.

    /**
    * Seta o Progress.Lang.AppError de erros a serem retornados na response
    **/
    METHOD PUBLIC VOID setAppError (pAppError AS Progress.Lang.AppError):
        ASSIGN oAppError = pAppError.
    END METHOD.

    /**
    * Seta o Progress.Lang.Error de erros a serem retornados na response
    **/
    METHOD PUBLIC VOID setError (pError AS Progress.Lang.Error):
        ASSIGN oError = pError.
    END METHOD.

    /**
    * Cria e retorna o json que dever  ser retornado na response
    **/
    METHOD PUBLIC JsonObject createJsonResponse():

        DEFINE VARIABLE oResponse  AS JsonObject NO-UNDO.
        DEFINE VARIABLE oPayload   AS JsonObject NO-UNDO.

        DEFINE VARIABLE oJsonArray    AS JsonArray  NO-UNDO.
        DEFINE VARIABLE oDetails      AS JsonArray  NO-UNDO.
        DEFINE VARIABLE oRowError     AS JsonObject NO-UNDO.
        DEFINE VARIABLE oDetailError  AS JsonObject NO-UNDO.

        DEFINE VARIABLE iCount        AS INTEGER NO-UNDO.
        DEFINE VARIABLE lInitialError AS LOGICAL NO-UNDO.
        DEFINE VARIABLE lSubTypeError AS LOGICAL NO-UNDO INITIAL FALSE.

        ASSIGN oResponse = NEW JsonObject().
        ASSIGN oPayload  = NEW JsonObject().

        /** Verifica se existem erros na RowErrors **/
        IF (oRowErrors <> ?) THEN DO:
            checkError:
            DO iCount = 1 TO oRowErrors:LENGTH:
    
                oRowError = oRowErrors:GetJsonObject(iCount).
    
                IF LC(JsonAPIUtils:getPropertyJsonObject(oRowError, "ErrorSubType")) EQ "error" THEN DO:
                    ASSIGN lSubTypeError = TRUE.
                    LEAVE checkError.
                END. 
            END.
        END.

        IF ((oRowErrors <> ? AND oRowErrors:LENGTH > 0 AND lSubTypeError) OR (oError <> ? AND oError:NumMessages > 0) OR (oAppError <> ? AND oAppError:NumMessages > 0)) THEN DO:
        
            ASSIGN oDetails = NEW JsonArray().

            IF oRowErrors <> ? AND oRowErrors:LENGTH > 0 THEN DO:
                
                ASSIGN lInitialError = TRUE.

                DO iCount = 1 TO oRowErrors:LENGTH:

                    oRowError = oRowErrors:GetJsonObject(iCount).

                    IF LC(JsonAPIUtils:getPropertyJsonObject(oRowError, "ErrorSubType")) NE "error" THEN 
                        NEXT.

                    IF lInitialError = TRUE THEN DO:
                        oPayload:ADD("code", JsonAPIUtils:getPropertyJsonObject(oRowError, "ErrorNumber")).
                        oPayload:ADD("message", JsonAPIUtils:getPropertyJsonObject(oRowError, "ErrorDescription")).
                        oPayload:ADD("detailMessage", JsonAPIUtils:getPropertyJsonObject(oRowError, "ErrorHelp")).
                        ASSIGN lInitialError = FALSE.
                    END.
                    ELSE DO:
                        ASSIGN oDetailError = NEW JsonObject().
                        oDetailError:ADD("code", JsonAPIUtils:getPropertyJsonObject(oRowError, "ErrorNumber")).
                        oDetailError:ADD("message", JsonAPIUtils:getPropertyJsonObject(oRowError, "ErrorDescription")).
                        oDetailError:ADD("detailMessage", JsonAPIUtils:getPropertyJsonObject(oRowError, "ErrorHelp")).
                        oDetails:ADD(oDetailError).
                    END.
                END.
            END.
            ELSE DO:
                IF oError <> ? AND oError:NumMessages > 0 THEN DO:
                    ASSIGN lSubTypeError = TRUE.
                    DO iCount = 1 to oError:NumMessages:

                        IF lInitialError = TRUE THEN DO:
                            oPayload:ADD("code", oError:getMessageNum(iCount)).
                            oPayload:ADD("message", oError:getMessage(iCount)).
                            oPayload:ADD("detailMessage", oError:GetClass():TypeName).
                            ASSIGN lInitialError = FALSE.
                        END.
                        ELSE DO:
                            ASSIGN oDetailError = NEW JsonObject().
                            oDetailError:ADD("code", oError:getMessageNum(iCount)).
                            oDetailError:ADD("message", oError:getMessage(iCount)).
                            oDetailError:ADD("detailMessage", "").
                            oDetails:ADD(oDetailError).
                        END.
                    END.
                END.
                ELSE DO:
                    IF oAppError <> ? AND oAppError:NumMessages > 0 THEN DO:
                        ASSIGN lSubTypeError = TRUE.
                        DO iCount = 1 to oAppError:NumMessages:
    
                            IF lInitialError = TRUE THEN DO:
                                oPayload:ADD("code", oAppError:getMessageNum(iCount)).
                                oPayload:ADD("message", oAppError:getMessage(iCount)).
                                oPayload:ADD("detailMessage", oAppError:GetClass():TypeName).
                                ASSIGN lInitialError = FALSE.
                            END.
                            ELSE DO:
                                ASSIGN oDetailError = NEW JsonObject().
                                oDetailError:ADD("code", oAppError:getMessageNum(iCount)).
                                oDetailError:ADD("message", oAppError:getMessage(iCount)).
                                oDetailError:ADD("detailMessage", "").
                                oDetails:ADD(oDetailError).
                            END.
                        END.
                    END.
                END.
            END.

            IF oDetails:LENGTH > 0 THEN
               oPayload:Add("details", oDetails).
        
            IF iStatus = 200 THEN
                oResponse:ADD("status", 500).
            ELSE
                oResponse:ADD("status", iStatus).
        END.
        ELSE DO:
            IF JsonAPIUtils:checkJsonIsArray(oJsonInput) THEN DO:

    		    ASSIGN oJsonArray = CAST(oJsonInput, JsonArray).

    		    oPayload:ADD("total", oJsonArray:LENGTH).
    		    oPayload:ADD("hasNext", lHasNext).
    		    oPayload:ADD("items", oJsonArray).
    	    END.
    	    ELSE DO:
        		oPayload = CAST(oJsonInput, JsonObject).
    	    END.
            oResponse:ADD("status", iStatus).
        END.

        oResponse:ADD("payload", oPayload).

        RETURN oResponse.

    END METHOD.

END CLASS.
