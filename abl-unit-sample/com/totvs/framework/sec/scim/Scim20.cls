/********************************************************************************
** Copyright TOTVS S.A. (2015)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
********************************************************************************/

USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.
USING com.totvs.framework.api.JsonAPIResponse FROM PROPATH.
USING com.totvs.framework.sec.scim.Scim20 FROM PROPATH.
USING com.totvs.framework.sec.scim.Scim20Error FROM PROPATH.

CLASS com.totvs.framework.sec.scim.Scim20:
    /*********************************************   Scim User Schema **********************************************/
    DEFINE STATIC PUBLIC PROPERTY SCIM20USER_SCHEMA     AS CHARACTER    NO-UNDO INITIAL "urn:ietf:params:scim:schemas:core:2.0:User"            
        GET. 
        PRIVATE SET.

    DEFINE STATIC PUBLIC PROPERTY SCIM20USER_EXT_SCHEMA AS CHARACTER    NO-UNDO INITIAL "urn:ietf:params:scim:schemas:extension:external:2.0:User"   
        GET. 
        PRIVATE SET.

    DEFINE STATIC PUBLIC PROPERTY SCIM20LIST_SCHEMA     AS CHARACTER    NO-UNDO INITIAL "urn:ietf:params:scim:api:messages:2.0:ListResponse"
        GET. 
        PRIVATE SET.

    /********************************************  Scim Group Schema  *********************************************/
    DEFINE STATIC PUBLIC PROPERTY SCIM20GROUP_SCHEMA    AS CHARACTER    NO-UNDO INITIAL "urn:ietf:params:scim:schemas:core:2.0:Group"            
        GET. 
        PRIVATE SET.

    /***********************************************   Messages   ************************************************/
    DEFINE STATIC PUBLIC PROPERTY SCIM20ERROR_MESSAGE   AS CHARACTER    NO-UNDO INITIAL "urn:ietf:params:scim:api:messages:2.0:Error"  
        GET. 
        PRIVATE SET.
    
    /*********************************************   HTTP Status   ***********************************************/
    DEFINE STATIC PUBLIC PROPERTY HTTP_NO_CONTENT       AS INTEGER      NO-UNDO INITIAL 204         GET. 
        PRIVATE SET.
    DEFINE STATIC PUBLIC PROPERTY HTTP_NOT_FOUND        AS INTEGER      NO-UNDO INITIAL 404         GET. 
        PRIVATE SET.
   DEFINE STATIC PUBLIC PROPERTY HTTP_BAD_REQUEST       AS INTEGER      NO-UNDO INITIAL 400         GET. 
        PRIVATE SET.
    DEFINE STATIC PUBLIC PROPERTY HTTP_OK               AS INTEGER      NO-UNDO INITIAL 200         GET. 
        PRIVATE SET.
    DEFINE STATIC PUBLIC PROPERTY HTTP_CREATED          AS INTEGER      NO-UNDO INITIAL 201         GET. 
        PRIVATE SET.

    
    /*********************************************   HTTP Method   ***********************************************/
    DEFINE STATIC PUBLIC PROPERTY HTTP_POST             AS CHARACTER    NO-UNDO INITIAL "POST"      GET. 
        PRIVATE SET.
    DEFINE STATIC PUBLIC PROPERTY HTTP_PUT              AS CHARACTER    NO-UNDO INITIAL "PUT"       GET. 
        PRIVATE SET.
    DEFINE STATIC PUBLIC PROPERTY HTTP_GET              AS CHARACTER    NO-UNDO INITIAL "GET"       GET. 
        PRIVATE SET.
    DEFINE STATIC PUBLIC PROPERTY HTTP_DELETE           AS CHARACTER    NO-UNDO INITIAL "DELETE"    GET. 
        PRIVATE SET.

    /*********************************************   Constructors   *********************************************/
    CONSTRUCTOR Scim20 ():                
    END CONSTRUCTOR.

    /************************************************   Method   ************************************************/
    /*------------------------------------------------------------------------------
        Purpose: Converte o retorno para o padrao JSON com as regras do SCIM
        Notes: Metodo auxiliar responsavel por tratar o retorno somente quando ha erros
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC JsonAPIResponse parserResponse ( INPUT jsonOutput AS JsonObject, INPUT scError AS Scim20Error ):
        RETURN THIS-OBJECT:parserResponse(jsonOutput, scError:getHttpMethod(), scError).
    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Converte o retorno para o padrao JSON com as regras do SCIM
        Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC JsonAPIResponse parserResponse ( INPUT jsonOutput AS JsonObject, INPUT httpMethod AS CHARACTER, INPUT scError AS Scim20Error ):
        DEFINE VARIABLE oResponse AS JsonAPIResponse NO-UNDO.
        
        /* Tratamento de sucesso, caso nao exista o objeto de erro */
        IF ( scError = ? ) THEN 
        DO:
            IF ( httpMethod = Scim20:HTTP_DELETE ) THEN 
            DO:
                ASSIGN 
                    oResponse = THIS-OBJECT:successfulDelete(jsonOutput).
            END.
            ELSE IF ( httpMethod = Scim20:HTTP_PUT ) THEN
            DO:
                ASSIGN 
                    oResponse = THIS-OBJECT:successCreateAndUpdate(jsonOutput, scim20:HTTP_OK ).
            END.
            ELSE IF ( httpMethod = Scim20:HTTP_POST ) THEN
            DO:
                ASSIGN 
                    oResponse = THIS-OBJECT:successCreateAndUpdate(jsonOutput,scim20:HTTP_CREATED ).
            END.
        END.
        /* Tratamento de retorno dos erros */
        ELSE 
        DO:
            IF ( scError:getHttpStatus() = Scim20:HTTP_NOT_FOUND ) THEN
                ASSIGN oResponse = THIS-OBJECT:resourceNotFound(jsonOutput, scError).
            
            ELSE IF ( scError:getHttpStatus() = Scim20:HTTP_BAD_REQUEST ) THEN DO:
                ASSIGN oResponse = THIS-OBJECT:badRequest(jsonOutput, scError).
            END.
            ELSE
                ASSIGN oResponse = THIS-OBJECT:buildResponse(jsonOutput, scError). 
        END.

        RETURN oResponse.
    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Retorna o status '204 No Content' caso o recurso for corretamente eliminado
        Notes:
    ------------------------------------------------------------------------------*/                                             
    METHOD PRIVATE JsonAPIResponse successfulDelete ( INPUT jsonOutput AS JsonObject ):
        DEFINE VARIABLE oResponse AS JsonAPIResponse NO-UNDO.

        oResponse = NEW JsonAPIResponse(jsonOutput).
        oResponse:setStatus(Scim20:HTTP_NO_CONTENT).
    
        RETURN oResponse.
    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Retorna o status Json com status de sucesso (200 - Update, 201 - Created)
        Notes:
    ------------------------------------------------------------------------------*/  
    METHOD PRIVATE JsonAPIResponse successCreateAndUpdate( INPUT jsonOutput AS JsonObject, INPUT httpStatus AS INTEGER ):
        DEFINE VARIABLE oResponse   AS JsonAPIResponse  NO-UNDO.

        /*Remove a senha do json de retorno*/
        IF jsonOutput:has("password") THEN
            jsonOutput:remove("password").

        oResponse = NEW JsonAPIResponse(jsonOutput).
        oResponse:setStatus(httpStatus).
        RETURN oResponse.        
    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Retorna o objeto de resposta no padrao de recurso nao encontrado do SCIM
        Notes:
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE JsonAPIResponse resourceNotFound ( INPUT jsonOutput AS JsonObject, INPUT scError AS Scim20Error ):
        DEFINE VARIABLE oResponse  AS JsonAPIResponse NO-UNDO.
        DEFINE VARIABLE oJsonArray AS JsonArray       NO-UNDO.
    
        ASSIGN 
            oJsonArray = NEW JsonArray().
        oJsonArray:ADD(Scim20:SCIM20ERROR_MESSAGE).
    
        jsonOutput:ADD("schemas", oJsonArray).
        jsonOutput:ADD("detail", "Resource " + scError:getId() + " not found").
        jsonOutput:ADD("status", STRING(scError:getHttpStatus())).
    
        oResponse = NEW JsonAPIResponse(jsonOutput).
        oResponse:setStatus(scError:getHttpStatus()).
    
        RETURN oResponse.
    END METHOD.

    /*------------------------------------------------------------------------------
    Purpose: Retorna o objeto de resposta no padrao de erro 400 conforme rfc7644 secao 3.12
    Notes:
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE JsonAPIResponse badRequest ( INPUT jsonOutput AS JsonObject, INPUT scError AS Scim20Error ):
        DEFINE VARIABLE oResponse       AS JsonAPIResponse  NO-UNDO.
        DEFINE VARIABLE oJsonArray      AS JsonArray        NO-UNDO.
    
        ASSIGN oJsonArray = NEW JsonArray().
        oJsonArray:ADD(Scim20:SCIM20ERROR_MESSAGE).

        jsonOutput = NEW JsonObject().
        
        jsonOutput:ADD("schemas", oJsonArray).
        jsonOutput:ADD("scimType", scError:GetErrorType()).
        jsonOutput:ADD("detail", scError:GetDetail()).
        jsonOutput:ADD("status", STRING(scError:getHttpStatus())).
    
        oResponse = NEW JsonAPIResponse(jsonOutput).
        oResponse:setStatus(scError:getHttpStatus()).
    
        RETURN oResponse.
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Monta o objeto de resposta conforme o objeto de erro.
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE JsonAPIResponse buildResponse (INPUT oJsonOutput AS JsonObject, INPUT oScimError AS Scim20Error):
        DEFINE VARIABLE oResponse  AS JsonAPIResponse NO-UNDO.
        DEFINE VARIABLE oJsonArray AS JsonArray       NO-UNDO.
        DEFINE VARIABLE cDetail    AS CHARACTER       NO-UNDO.
    
        ASSIGN 
            oJsonArray = NEW JsonArray().
        oJsonArray:Add(Scim20:SCIM20ERROR_MESSAGE).
        
        ASSIGN
            cDetail = oScimError:getDetail().
    
        IF  oScimError:getHttpStatus() = 400 AND
            oScimError:getErrorType() <> ? AND TRIM(oScimError:getErrorType()) <> "" THEN
        DO:
            IF  cDetail = ? OR TRIM(cDetail) = "" THEN
            DO:
                CASE oScimError:getErrorType():
                    WHEN Scim20Error:TOO_MANY THEN 
                        cDetail = "There are too many results for this search.".
                END CASE.
            END.
            
            oJsonOutput:Add("scimType", oScimError:getErrorType()).
        END.
        
        IF  cDetail <> ? AND TRIM(cDetail) <> "" THEN
            oJsonOutput:Add("detail", cDetail).    
        
        oJsonOutput:Add("schemas", oJsonArray).
        oJsonOutput:Add("status", oScimError:getHttpStatus()).
        
        ASSIGN
            oResponse = NEW JsonAPIResponse(oJsonOutput).
        oResponse:setStatus(oScimError:getHttpStatus()).
        
        RETURN oResponse.
    END METHOD.

    METHOD STATIC LOGICAL isValidAttributeByClass(INPUT cAttribute AS CHARACTER, INPUT cls AS Progress.Lang.Class):                                            
        DEFINE VARIABLE oFlags      AS Progress.Reflect.Flags    NO-UNDO.
        DEFINE VARIABLE aProperties AS Progress.Reflect.Property NO-UNDO EXTENT.
        DEFINE VARIABLE cProperties AS CHARACTER                 NO-UNDO INITIAL ?.     
        DEFINE VARIABLE iTotal      AS INTEGER                   NO-UNDO.
        DEFINE VARIABLE iCount      AS INTEGER                   NO-UNDO.
        
        IF cls <> ? THEN
        DO:
            ASSIGN oFlags  = Progress.Reflect.Flags:Public OR Progress.Reflect.Flags:Protected OR Progress.Reflect.Flags:Private 
               oFlags      = oFlags:SetFlag(Progress.Reflect.Flags:Instance OR Progress.Reflect.Flags:Static) 
               oFlags      = oFlags:SetFlag(Progress.Reflect.Flags:DeclaredOnly)                                          
               aProperties = cls:GetProperties(oFlags)
               iTotal      = EXTENT(aProperties).    
        
            /* Transforma o EXTENT de propriedades em um CHARACTER delimitado */
            DO  iCount = 1 TO iTotal:
                IF aProperties[iCount]:NAME = cAttribute THEN
                    RETURN TRUE.
            END.     
        END.                                              
                                            
        RETURN FALSE.
    END.
END CLASS.
