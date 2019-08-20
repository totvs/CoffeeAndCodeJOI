
/*------------------------------------------------------------------------
    File        : idiomas.p
    Purpose     : API REST para manutená∆o de idiomas

    Syntax      :

    Description : Idiomas

    Author(s)   : Rubens Dos Santos Filho
    Created     : Wed Apr 25 16:49:20 BRT 2018
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
{utp/ut-api.i}
{utp/ut-api-utils.i}

{include/i-prgvrs.i idiomas 2.00.00.000} /*** 010000 ***/

{utp/ut-api-action.i pi-create POST /~*}
{utp/ut-api-action.i pi-update PUT /~*}
{utp/ut-api-action.i pi-delete DELETE /~*/~*}
{utp/ut-api-action.i pi-get GET /~*/~*}
{utp/ut-api-action.i pi-getAll GET /~*}
{utp/ut-api-notfound.i}

DEFINE TEMP-TABLE tt-idioma NO-UNDO
    FIELD cod_idioma            LIKE idioma.cod_idioma SERIALIZE-NAME "codIdioma"
    FIELD des_idioma            LIKE idioma.des_idioma SERIALIZE-NAME "desIdioma"
    FIELD cod_idiom_padr        LIKE idioma.cod_idiom_padr SERIALIZE-NAME "codIdiomPadr"
    FIELD cod_usuar_ult_atualiz LIKE idioma.cod_usuar_ult_atualiz SERIALIZE-NAME "codUsuarUltAtualiz"
    FIELD dat_ult_atualiz       LIKE idioma.dat_ult_atualiz SERIALIZE-NAME "datUltAtualiz"
    FIELD hra_ult_atualiz       LIKE idioma.hra_ult_atualiz SERIALIZE-NAME "hraUltAtualiz"
    INDEX idioma_id IS PRIMARY UNIQUE cod_idioma.
    
/* ********************  Preprocessor Definitions  ******************** */

/* ***************************  Main Block  *************************** */

/* **********************  Internal Procedures  *********************** */
/*------------------------------------------------------------------------------
 Purpose: Retorna a lista de idiomas.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE pi-getAll:
    DEFINE INPUT  PARAMETER jsonInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAMETER jsonOutput AS JsonObject NO-UNDO.
    
    DEFINE VARIABLE jsonIdiomas AS JsonArray NO-UNDO.
    
    EMPTY TEMP-TABLE tt-idioma.
    EMPTY TEMP-TABLE RowErrors.
    
    FOR EACH idioma NO-LOCK BY cod_idioma:
        CREATE tt-idioma.
        BUFFER-COPY idioma TO tt-idioma.
    END.
    
    ASSIGN 
        jsonIdiomas = NEW JsonArray().
    jsonIdiomas:Read(TEMP-TABLE tt-idioma:HANDLE).
    
    RUN createJsonResponse(INPUT jsonIdiomas, INPUT TABLE RowErrors, INPUT FALSE, OUTPUT jsonOutput).
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Retorna as informaá‰es do idioma informado na requisiá∆o.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE pi-get:
    DEFINE INPUT  PARAMETER jsonInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAMETER jsonOutput AS JsonObject NO-UNDO.
    
    DEFINE VARIABLE codIdioma AS CHARACTER NO-UNDO.
    
    EMPTY TEMP-TABLE tt-idioma.
    EMPTY TEMP-TABLE RowErrors.
    
    ASSIGN 
        codIdioma = jsonInput:GetJsonArray("pathParams"):GetCharacter(1).
    
    FIND FIRST idioma NO-LOCK WHERE idioma.cod_idioma = codIdioma NO-ERROR.
    
    IF  AVAILABLE idioma THEN
        RUN pi-load-idioma-json IN THIS-PROCEDURE(OUTPUT jsonOutput).        
    ELSE
        ASSIGN jsonOutput = NEW JsonObject().
    
    RUN createJsonResponse(INPUT jsonOutput, INPUT TABLE RowErrors, INPUT FALSE, OUTPUT jsonOutput).
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Efetua a criaá∆o de um novo idioma.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE pi-create:
    DEFINE INPUT  PARAMETER jsonInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAMETER jsonOutput AS JsonObject NO-UNDO.

    RUN pi-upsert IN THIS-PROCEDURE(INPUT jsonInput:GetJsonObject("payload"), INPUT FALSE, OUTPUT jsonOutput).
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Efetua a modificaá∆o de um determinado idioma.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE pi-update:
    DEFINE INPUT  PARAMETER jsonInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAMETER jsonOutput AS JsonObject NO-UNDO.

    RUN pi-upsert IN THIS-PROCEDURE(INPUT jsonInput:GetJsonObject("payload"), INPUT TRUE, OUTPUT jsonOutput).
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Efetiva a manutená∆o (criaá∆o/modificaá∆o) de um idioma.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE pi-upsert PRIVATE:
    DEFINE INPUT  PARAMETER jsonIdioma AS JsonObject NO-UNDO.
    DEFINE INPUT  PARAMETER isUpdate   AS LOGICAL    NO-UNDO.
    DEFINE OUTPUT PARAMETER jsonOutput AS JsonObject NO-UNDO.
    
    EMPTY TEMP-TABLE RowErrors.
    
    /* Valida as informaá‰es do idioma */
    RUN pi-validate-fields IN THIS-PROCEDURE(INPUT jsonIdioma).

    IF  RETURN-VALUE = 'NOK' THEN 
    DO:
        RUN utp/ut-msgs.p (INPUT "msg", INPUT 42571, INPUT "").
            
        CREATE RowErrors.
        ASSIGN 
            RowErrors.ErrorNumber      = 42571
            RowErrors.ErrorType        = "error"
            RowErrors.ErrorDescription = RETURN-VALUE.
    END.
    ELSE 
    DO:
        /* Valida a tentativa de criaá∆o de um idioma duplicado */
        IF  CAN-FIND(FIRST idioma WHERE idioma.cod_idioma = jsonIdioma:GetCharacter("codIdioma")) THEN 
        DO:
            IF  NOT isUpdate THEN 
            DO:
                RUN utp/ut-msgs.p (INPUT "msg", INPUT 4242, INPUT "Idioma").
    
                CREATE RowErrors.
                ASSIGN 
                    RowErrors.ErrorNumber      = 4242
                    RowErrors.ErrorType        = "error"
                    RowErrors.ErrorDescription = RETURN-VALUE.
            END.
        END.
        ELSE 
        /* Valida a tentativa de modificaá∆o de um idioma inv†lido */
        DO:
            IF  isUpdate THEN 
            DO:
                RUN utp/ut-msgs.p (INPUT "msg", INPUT 43163, INPUT "Idioma").
    
                CREATE RowErrors.
                ASSIGN 
                    RowErrors.ErrorNumber      = 43163
                    RowErrors.ErrorType        = "error"
                    RowErrors.ErrorDescription = RETURN-VALUE.
            END.
        END.
    END. 

    IF  NOT CAN-FIND(FIRST RowErrors) THEN
    DO: 
        FIND FIRST idioma EXCLUSIVE-LOCK
            WHERE idioma.cod_idioma = jsonIdioma:GetCharacter("codIdioma") NO-ERROR.
        
        IF  NOT AVAILABLE idioma THEN 
        DO:
            CREATE idioma.
            ASSIGN 
                idioma.cod_idioma = jsonIdioma:GetCharacter("codIdioma").
        END.

        ASSIGN 
            idioma.des_idioma     = jsonIdioma:GetCharacter("desIdioma")
            idioma.cod_idiom_padr = jsonIdioma:GetCharacter("codIdiomPadr").

        IF  jsonIdioma:Has("datUltAtualiz") THEN
            ASSIGN idioma.dat_ult_atualiz = jsonIdioma:GetDate("datUltAtualiz").

        IF  jsonIdioma:Has("hraUltAtualiz") THEN
            ASSIGN idioma.hra_ult_atualiz = jsonIdioma:GetCharacter("hraUltAtualiz").
        
        FIND FIRST idioma NO-LOCK WHERE idioma.cod_idioma = jsonIdioma:GetCharacter("codIdioma") NO-ERROR.
        RUN pi-load-idioma-json IN THIS-PROCEDURE(OUTPUT jsonOutput).
    END.
    ELSE
        RUN createJsonResponse(NEW JsonObject(), INPUT TABLE RowErrors, INPUT FALSE, OUTPUT jsonOutput).
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Efetua a exclus∆o de um determinado idioma.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE pi-delete:
    DEFINE INPUT  PARAMETER jsonInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAMETER jsonOutput AS JsonObject NO-UNDO.
    
    DEFINE VARIABLE codIdioma AS CHARACTER NO-UNDO.
    
    ASSIGN 
        codIdioma = jsonInput:GetJsonArray("pathParams"):GetCharacter(1).
    
    FIND FIRST idioma EXCLUSIVE-LOCK WHERE idioma.cod_idioma = codIdioma NO-ERROR.
    
    IF  AVAILABLE idioma THEN
    DO:
        DELETE idioma.
        ASSIGN 
            jsonOutput = NEW JsonObject().
    END.
    ELSE 
    DO:
        RUN utp/ut-msgs.p (INPUT "msg", INPUT 8263, INPUT "Idioma " + codIdioma).
        
        CREATE RowErrors.
        ASSIGN 
            RowErrors.ErrorNumber      = 8263
            RowErrors.ErrorType        = "error"
            RowErrors.ErrorDescription = RETURN-VALUE.
        
        RUN createJsonResponse(NEW JsonObject(), INPUT TABLE RowErrors, INPUT FALSE, OUTPUT jsonOutput).
    END.
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Cria um JSON a partir do idioma posicionado.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE pi-load-idioma-json PRIVATE:
    DEFINE OUTPUT PARAMETER jsonIdioma AS JsonObject NO-UNDO.
    
    ASSIGN 
        jsonIdioma = NEW JsonObject().
    
    jsonIdioma:Add("codIdioma", idioma.cod_idioma).
    jsonIdioma:Add("desIdioma", idioma.des_idioma).
    jsonIdioma:Add("codIdiomPadr", idioma.cod_idiom_padr).
    jsonIdioma:Add("codUsuarUltAtualiz", idioma.cod_usuar_ult_atualiz).
    jsonIdioma:Add("datUltAtualiz", idioma.dat_ult_atualiz).
    jsonIdioma:Add("hraUltAtualiz", idioma.hra_ult_atualiz).
END PROCEDURE.

/*------------------------------------------------------------------------------
 Purpose: Valida as informaá‰es de idioma.
 Notes:
------------------------------------------------------------------------------*/
PROCEDURE pi-validate-fields PRIVATE:
    DEFINE INPUT PARAMETER jsonInput AS JsonObject NO-UNDO.
    
    IF  NOT jsonInput:Has("codIdioma") THEN
        RETURN "NOK".
    
    IF  NOT jsonInput:Has("desIdioma") THEN
        RETURN "NOK".
    
    IF  NOT jsonInput:Has("codIdiomPadr") THEN
        RETURN "NOK".
    
    IF  NOT jsonInput:Has("codUsuarUltAtualiz") THEN
        RETURN "NOK".
    
    RETURN "OK".
END PROCEDURE.
