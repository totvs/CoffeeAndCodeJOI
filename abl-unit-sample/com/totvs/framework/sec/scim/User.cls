 
/*------------------------------------------------------------------------
   File        : User
   Purpose     : Classe de usuario no formato SCIM.
   Syntax      : 
   Description : Usuario
   Author(s)   : Rubens Dos Santos Filho
   Created     : Tue Jul 10 13:33:38 BRT 2018
   Notes       : 
 ----------------------------------------------------------------------*/
BLOCK-LEVEL ON ERROR UNDO, THROW.

USING Progress.Json.ObjectModel.JsonArray            FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject           FROM PROPATH.
USING com.totvs.framework.sec.scim.Scim20            FROM PROPATH.
USING com.totvs.framework.sec.scim.UserEmail         FROM PROPATH.
USING com.totvs.framework.sec.scim.UserEmailTypeEnum FROM PROPATH.
USING com.totvs.framework.sec.scim.UserExtension     FROM PROPATH.
USING com.totvs.framework.sec.scim.UserGroup         FROM PROPATH.
USING com.totvs.framework.sec.scim.Meta              FROM PROPATH.
USING com.totvs.framework.sec.scim.UserName          FROM PROPATH.

CLASS com.totvs.framework.sec.scim.User SERIALIZABLE:
    DEFINE SERIALIZABLE PRIVATE PROPERTY schemas           AS CHARACTER NO-UNDO INITIAL ?
        GET.
        SET.
    
    DEFINE SERIALIZABLE PRIVATE PROPERTY id                AS CHARACTER NO-UNDO INITIAL ?
        GET.
        SET.

    DEFINE SERIALIZABLE PRIVATE PROPERTY externalId        AS CHARACTER NO-UNDO INITIAL ?
        GET.
        SET.

    DEFINE SERIALIZABLE PRIVATE PROPERTY userName          AS CHARACTER NO-UNDO INITIAL ?
        GET.
        SET.
    
    DEFINE SERIALIZABLE PRIVATE PROPERTY name              AS UserName NO-UNDO
        GET.
        SET.

    DEFINE SERIALIZABLE PRIVATE PROPERTY displayName       AS CHARACTER NO-UNDO INITIAL ?
        GET.
        SET.
        
    DEFINE SERIALIZABLE PRIVATE PROPERTY userType          AS CHARACTER NO-UNDO INITIAL ?
        GET.
        SET.
    
    DEFINE SERIALIZABLE PRIVATE PROPERTY preferredLanguage AS CHARACTER NO-UNDO INITIAL ? 
        GET.
        SET.
    
    DEFINE SERIALIZABLE PRIVATE PROPERTY active            AS LOGICAL NO-UNDO INITIAL TRUE
        GET.
        SET.
    
    DEFINE SERIALIZABLE PRIVATE PROPERTY password          AS CHARACTER NO-UNDO INITIAL ?
        GET.
        SET.
    
    DEFINE SERIALIZABLE PRIVATE PROPERTY emails            AS UserEmail EXTENT NO-UNDO
        GET.
        SET.
    
    DEFINE SERIALIZABLE PRIVATE PROPERTY groups            AS UserGroup EXTENT NO-UNDO
        GET.
        SET.
    
    DEFINE SERIALIZABLE PRIVATE PROPERTY UserExtension     AS UserExtension NO-UNDO
        GET.
        SET.
        
    DEFINE SERIALIZABLE PRIVATE PROPERTY meta              AS Meta NO-UNDO
        GET.
        SET.
    
    DEFINE SERIALIZABLE PRIVATE PROPERTY hasEmails         AS LOGICAL NO-UNDO INITIAL NO
        GET.
        PRIVATE SET.
        
    CONSTRUCTOR PUBLIC User():
        THIS-OBJECT:AddSchema(Scim20:SCIM20USER_SCHEMA).
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
     Purpose: Carrega os dados do objeto atual a partir de um objeto JSON.
     Notes:
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC User(jsonUser AS JsonObject):
        DEFINE VARIABLE cSchemas       AS JsonArray NO-UNDO.
        DEFINE VARIABLE emails         AS JsonArray NO-UNDO.
        DEFINE VARIABLE iCount         AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cSchema        AS CHARACTER NO-UNDO.
        DEFINE VARIABLE objName        AS CLASS     JSONObject NO-UNDO.
        DEFINE VARIABLE objEmail       AS CLASS     JSONObject NO-UNDO.
        DEFINE VARIABLE primaryEmail   AS CHARACTER NO-UNDO.
        DEFINE VARIABLE secondaryEmail AS CHARACTER NO-UNDO.

        IF  VALID-OBJECT (jsonUser) THEN
        DO:
            ASSIGN 
                THIS-OBJECT:id                = IF jsonUser:Has("id")                  THEN jsonUser:GetCharacter("id")         ELSE ?
                THIS-OBJECT:externalId        = IF jsonUser:Has("externalId")          THEN jsonUser:GetCharacter("externalId") ELSE ?
                THIS-OBJECT:userName          = IF jsonUser:Has("userName")            THEN jsonUser:GetCharacter("userName")   ELSE ?
                THIS-OBJECT:userType          = IF jsonUser:Has("userType")            THEN jsonUser:GetCharacter("userType")   ELSE ?
                THIS-OBJECT:active            = IF jsonUser:Has("active")              THEN jsonUser:GetLogical("active")       ELSE ?
                THIS-OBJECT:password          = IF jsonUser:Has("password")            THEN jsonUser:GetCharacter("password")   ELSE ?
                THIS-OBJECT:preferredLanguage = IF jsonUser:Has("preferredLanguage")   THEN jsonUser:GetCharacter("preferredLanguage") ELSE ?.
                
            /* Realiza a atribuicao dos schemas */
            IF  jsonUser:Has("schemas") THEN
            DO:
                ASSIGN 
                    cSchemas = jsonUser:GetJsonArray("schemas").
                
                IF  VALID-OBJECT(cSchemas) THEN
                DO:
                    DO iCount = 1 TO cSchemas:Length:
                        ASSIGN 
                            cSchema = cSchemas:GetCharacter(iCount).  
                        THIS-OBJECT:AddSchema(cSchema).
                    END.
                END.
            END.

            /* Realiza a atribuicao do nome */
            IF  jsonUser:Has("name") THEN
            DO:
                ASSIGN 
                    THIS-OBJECT:NAME = NEW UserName(jsonUser:GetJsonObject("name")).
            END.

            /* Realiza a atribuicao do(s) email(s) */
            IF  jsonUser:Has("emails") THEN
            DO:
                ASSIGN 
                    emails = jsonUser:GetJsonArray("emails").
                
                THIS-OBJECT:setHasEmails(TRUE).

                IF  VALID-OBJECT (emails) THEN
                DO:
                    DO  iCount = 1 TO emails:Length:
                        ASSIGN 
                            objEmail = emails:GetJsonObject(iCount).
                
                        IF  objEmail:Has("value") AND objEmail:Has("primary") AND objEmail:GetLogical("primary") THEN
                            ASSIGN
                                primaryEmail = objEmail:GetCharacter("value").
                    
                        ELSE
                            ASSIGN
                                secondaryEmail = objEmail:GetCharacter("value").
                    END.
                END.

                IF  primaryEmail <> ? AND primaryEmail <> "" AND secondaryEmail <> ? AND secondaryEmail <> "" THEN 
                    THIS-OBJECT:SetEmails(primaryEmail, secondaryEmail).
                ELSE
                    IF  primaryEmail <> ? AND primaryEmail <> "" THEN 
                        THIS-OBJECT:SetEmails(primaryEmail).
            END.

            /* Realiza a atribuicao de usuario externo */      
            IF  jsonUser:Has("urn:ietf:params:scim:schemas:extension:external:2.0:User") THEN
                THIS-OBJECT:SetUserExtension(NEW UserExtension (jsonUser:GetJsonObject("urn:ietf:params:scim:schemas:extension:external:2.0:User"))).
        END.
    END CONSTRUCTOR.
    
    METHOD PUBLIC CHARACTER getSchemas():
        RETURN THIS-OBJECT:schemas.
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Adiciona um schema na lista separado por virgula.
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID addSchema(cSchema AS CHARACTER):
        IF  cSchema <> ? AND cSchema <> "" THEN
            IF  THIS-OBJECT:schemas <> ? AND THIS-OBJECT:schemas <> "" THEN
                ASSIGN
                    THIS-OBJECT:schemas = THIS-OBJECT:schemas + "," + cSchema.
            ELSE
                ASSIGN
                    THIS-OBJECT:schemas = cSchema. 
    END METHOD.
    
    METHOD PUBLIC CHARACTER getId():
        RETURN THIS-OBJECT:id.
    END METHOD.
    
    METHOD PUBLIC VOID setID(cId AS CHARACTER):
        THIS-OBJECT:id = cId.
    END METHOD.

    METHOD PUBLIC CHARACTER getExternalId():
        RETURN THIS-OBJECT:externalId.
    END METHOD.
    
    METHOD PUBLIC VOID setExternalId(cId AS CHARACTER):
        THIS-OBJECT:externalId = cId.
    END METHOD.

    METHOD PUBLIC UserExtension getUserExtension():
        RETURN THIS-OBJECT:userExtension.
    END METHOD.
    
    METHOD PUBLIC VOID setUserExtension(cUserExtension AS UserExtension):
        THIS-OBJECT:userExtension = cUserExtension.
    END METHOD.
    
    METHOD PUBLIC Meta getMeta():
        RETURN THIS-OBJECT:meta.
    END METHOD.
    
    METHOD PUBLIC VOID setMeta(oUserMeta AS Meta):
        THIS-OBJECT:meta = oUserMeta.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Retorna o email primario.
     Notes:
    -----------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER getPrimaryEmail():
        DEFINE VARIABLE iCount AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iTotal AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cEmail AS CHARACTER NO-UNDO INITIAL ?.
        
        ASSIGN
            iTotal = EXTENT(THIS-OBJECT:emails).

        IF  iTotal > 0 THEN
        DO:
            DO  iCount = 1 TO iTotal:
                IF  THIS-OBJECT:emails[iCount]:IsPrimary() THEN
                DO:
                    ASSIGN 
                        cEmail = THIS-OBJECT:emails[iCount]:getValue().
                    LEAVE.
                END.
            END.
        END.                
        
        RETURN cEmail.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Retorna o primeiro email nao primario.
     Notes:
    -----------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER getSecundaryEmail():
        DEFINE VARIABLE iCount AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iTotal AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cEmail AS CHARACTER NO-UNDO INITIAL ?.
        
        ASSIGN
            iTotal = EXTENT(THIS-OBJECT:emails).

        IF  iTotal > 0 THEN
        DO:
            DO  iCount = 1 TO iTotal:
                IF  NOT THIS-OBJECT:emails[iCount]:isPrimary() THEN
                DO:
                    ASSIGN 
                        cEmail = THIS-OBJECT:emails[iCount]:getValue().
                    LEAVE.
                END.
            END.
        END.
        
        RETURN cEmail.
    END METHOD.

    METHOD PUBLIC CHARACTER getUserName():
        RETURN THIS-OBJECT:userName.
    END METHOD.
    
    METHOD PUBLIC VOID setUserName(cUserName AS CHARACTER):
        THIS-OBJECT:userName = cUserName.
    END METHOD.
    
    METHOD PUBLIC UserName getName():
        RETURN THIS-OBJECT:name.
    END METHOD.
    
    METHOD PUBLIC VOID setName(cName AS CHARACTER):
        DEFINE VARIABLE cGivenName  AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFamilyName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iIndex      AS INTEGER   NO-UNDO.
        
        ASSIGN
            iIndex = INDEX(cName," ").
        
        IF  iIndex > 0 THEN
            ASSIGN
                cGivenName  = SUBSTRING(cName, 1, iIndex)
                cFamilyName = SUBSTRING(cName, iIndex).
        ELSE
            ASSIGN
                cGivenName  = cName
                cFamilyName = "".
        
        THIS-OBJECT:name = NEW UserName().
        THIS-OBJECT:name:setFormatted(cName).
        THIS-OBJECT:name:setGivenName(cGivenName).
        THIS-OBJECT:name:setFamilyName(cFamilyName).
    END METHOD.
    
    METHOD PUBLIC VOID setName(oName AS UserName):
        THIS-OBJECT:name = oName.
    END METHOD.
    
    METHOD PUBLIC CHARACTER getDisplayName():
        RETURN THIS-OBJECT:displayName.
    END METHOD.
    
    METHOD PUBLIC VOID setDisplayName(cDisplayName AS CHARACTER):
        THIS-OBJECT:displayName = cDisplayName.
    END METHOD.
    
    METHOD PUBLIC CHARACTER getUserType():
        RETURN THIS-OBJECT:userType.
    END METHOD.
    
    METHOD PUBLIC VOID setUserType(cUserType AS CHARACTER):
        THIS-OBJECT:userType = cUserType.
    END METHOD.
    
    METHOD PUBLIC CHARACTER getPreferredLanguage():
        RETURN THIS-OBJECT:preferredLanguage.
    END METHOD.
    
    METHOD PUBLIC VOID setPreferredLanguage(cPreferredLanguage AS CHARACTER):
        THIS-OBJECT:preferredLanguage = cPreferredLanguage.
    END METHOD.
    
    METHOD PUBLIC LOGICAL isActive():
        RETURN THIS-OBJECT:active.
    END METHOD.
    
    METHOD PUBLIC VOID setIsActive(lActive AS LOGICAL):
        THIS-OBJECT:active = lActive.
    END METHOD.
    
    METHOD PUBLIC CHARACTER getPassword():
        RETURN THIS-OBJECT:password.
    END METHOD.
    
    METHOD PUBLIC VOID setPassword(cPassword AS CHARACTER):
        THIS-OBJECT:password = cPassword.
    END METHOD.
    
    METHOD PUBLIC UserEmail EXTENT getEmails():
        RETURN THIS-OBJECT:emails.
    END METHOD.
    
    METHOD PUBLIC VOID setEmails(cPrimaryEmail AS CHARACTER):
        EXTENT(THIS-OBJECT:emails) = 1.
        
        THIS-OBJECT:emails[1] = NEW UserEmail().
        THIS-OBJECT:emails[1]:setValue(cPrimaryEmail).
        THIS-OBJECT:emails[1]:setDisplay(cPrimaryEmail).
        THIS-OBJECT:emails[1]:setType(UserEmailTypeEnum:WORK).
        THIS-OBJECT:emails[1]:setIsPrimary(TRUE).
    END METHOD.
    
    METHOD PUBLIC VOID setEmails(cPrimaryEmail AS CHARACTER, cSecondaryEmail AS CHARACTER):
        IF  cSecondaryEmail = ? OR TRIM(cSecondaryEmail) = "" THEN
            THIS-OBJECT:SetEmails(cPrimaryEmail).
        ELSE 
        DO:
            EXTENT(THIS-OBJECT:emails) = 2.
        
            THIS-OBJECT:emails[1] = NEW UserEmail().
            THIS-OBJECT:emails[1]:setValue(cPrimaryEmail).
            THIS-OBJECT:emails[1]:setDisplay(cPrimaryEmail).
            THIS-OBJECT:emails[1]:setType(UserEmailTypeEnum:WORK).
            THIS-OBJECT:emails[1]:setIsPrimary(TRUE).
            
            THIS-OBJECT:emails[2] = NEW UserEmail().
            THIS-OBJECT:emails[2]:setValue(cSecondaryEmail).
            THIS-OBJECT:emails[2]:setDisplay(cSecondaryEmail).
            THIS-OBJECT:emails[2]:setType(UserEmailTypeEnum:OTHER).
            THIS-OBJECT:emails[2]:setIsPrimary(FALSE).
        END.
    END METHOD.
    
    METHOD PUBLIC VOID setEmails(aEmails AS UserEmail EXTENT):
        THIS-OBJECT:emails = aEmails.
    END METHOD.
    
    METHOD PUBLIC UserGroup EXTENT getGroups():
        RETURN THIS-OBJECT:groups.
    END METHOD.
    
    METHOD PUBLIC VOID setGroups(aGroups AS UserGroup EXTENT):
        THIS-OBJECT:groups = aGroups.
    END METHOD.
    
    METHOD PUBLIC VOID addGroup(oGroup AS UserGroup):
        DEFINE VARIABLE aGroups AS UserGroup NO-UNDO EXTENT.
        DEFINE VARIABLE iExtent AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iCount  AS INTEGER   NO-UNDO.
        
        iExtent = EXTENT(THIS-OBJECT:groups).
        
        /* Efetua backup das informa‡äes antetiores */
        IF  iExtent = ? THEN
            iExtent = 0.
        ELSE
            aGroups = THIS-OBJECT:groups.
        
        /* Redimensiona o EXTENT */
        EXTENT(THIS-OBJECT:groups) = ?.
        EXTENT(THIS-OBJECT:groups) = iExtent + 1.
        
        /* Restaura as informa‡äes anteriores */
        DO iCount = 1 TO iExtent:
            THIS-OBJECT:groups[iCount] = aGroups[iCount].
        END.
        
        /* Adiciona o novo elemento no £ltimo ¡ndice */
        THIS-OBJECT:groups[iCount] = oGroup.
    END METHOD.
    
    METHOD PUBLIC JsonObject serialize():
        RETURN THIS-OBJECT:serialize(INPUT "").
    END METHOD.
    
    METHOD PUBLIC JsonObject serialize(INPUT cAttributes AS CHARACTER):
        DEFINE VARIABLE iCount        AS INTEGER    NO-UNDO.
        DEFINE VARIABLE iTotal        AS INTEGER    NO-UNDO.
        DEFINE VARIABLE cAttribute    AS CHARACTER  NO-UNDO.
        
        DEFINE VARIABLE jsonData      AS JsonObject NO-UNDO.
        DEFINE VARIABLE jsonList      AS JsonArray  NO-UNDO.
        
        DEFINE VARIABLE jsonSerialize AS JsonObject NO-UNDO.
        
        IF  NOT THIS-OBJECT:validAttributes(INPUT cAttributes, OUTPUT cAttribute) THEN
            UNDO, THROW NEW Progress.Lang.AppError("Attribute ~"" + cAttribute + "~" is invalid.", 400).

        jsonSerialize = NEW JsonObject().
        jsonSerialize:Add("id", THIS-OBJECT:id).
        
        IF  THIS-OBJECT:hasAttribute(cAttributes, "externalId") THEN
            jsonSerialize:Add("externalId", THIS-OBJECT:externalId).
        
        IF  THIS-OBJECT:hasAttribute(cAttributes, "schemas") THEN
        DO:
            jsonList = NEW JsonArray().
            jsonList:Add(THIS-OBJECT:schemas).
            jsonSerialize:Add("schemas", jsonList).
        END.
        
        IF  THIS-OBJECT:hasAttribute(cAttributes, "userName") THEN
            jsonSerialize:Add("userName", THIS-OBJECT:userName).
        
        IF  THIS-OBJECT:name <> ? AND THIS-OBJECT:hasAttribute(cAttributes, "name") THEN
            jsonSerialize:Add("name", THIS-OBJECT:name:Serialize()).
        
        IF  THIS-OBJECT:hasAttribute(cAttributes, "displayName") THEN
            jsonSerialize:Add("displayName", THIS-OBJECT:displayName).
        
        IF  THIS-OBJECT:hasAttribute(cAttributes, "userType") THEN
            jsonSerialize:Add("userType", THIS-OBJECT:userType).
        
        IF  THIS-OBJECT:hasAttribute(cAttributes, "preferredLanguage") THEN
            jsonSerialize:Add("preferredLanguage", THIS-OBJECT:preferredLanguage).
        
        IF  THIS-OBJECT:hasAttribute(cAttributes, "active") THEN
            jsonSerialize:Add("active", THIS-OBJECT:active).
        
        IF  THIS-OBJECT:hasAttribute(cAttributes, "emails") THEN
        DO:
            jsonList = NEW JsonArray().
            iTotal = EXTENT(THIS-OBJECT:emails).
            
            DO iCount = 1 TO iTotal:
                jsonList:Add(THIS-OBJECT:emails[iCount]:serialize()).
            END.
            
            jsonSerialize:Add("emails", jsonList).
        END.
        
        IF  THIS-OBJECT:hasAttribute(cAttributes, "groups") THEN
        DO:
            jsonList = NEW JsonArray().
            iTotal = EXTENT(THIS-OBJECT:groups).
            
            DO iCount = 1 TO iTotal:
                jsonList:Add(THIS-OBJECT:groups[iCount]:serialize()).
            END.
            
            jsonSerialize:Add("groups", jsonList).
        END.
        
        IF  THIS-OBJECT:meta <> ? AND THIS-OBJECT:hasAttribute(cAttributes, "meta") THEN
            jsonSerialize:Add("meta", THIS-OBJECT:meta:serialize()).
        
        RETURN jsonSerialize.
    END METHOD.
    
    METHOD PRIVATE LOGICAL validAttributes(INPUT cAttributes AS CHARACTER, OUTPUT cAttribute AS CHARACTER):
        DEFINE VARIABLE iCount      AS INTEGER                   NO-UNDO.
        DEFINE VARIABLE iTotal      AS INTEGER                   NO-UNDO.
        
        DEFINE VARIABLE lResult     AS LOGICAL                   NO-UNDO INITIAL TRUE.
        
        DEFINE VARIABLE oFlags      AS Progress.Reflect.Flags    NO-UNDO.
        DEFINE VARIABLE aProperties AS Progress.Reflect.Property NO-UNDO EXTENT.
        DEFINE VARIABLE cProperties AS CHARACTER                 NO-UNDO INITIAL ?.
        
        IF  cAttributes <> ? AND TRIM(cAttributes) <> "" THEN
        DO:
            ASSIGN 
                oFlags = Progress.Reflect.Flags:Public OR Progress.Reflect.Flags:Protected OR Progress.Reflect.Flags:Private 
                oFlags = oFlags:SetFlag(Progress.Reflect.Flags:Instance OR Progress.Reflect.Flags:Static) 
                oFlags = oFlags:SetFlag(Progress.Reflect.Flags:DeclaredOnly).

            aProperties = THIS-OBJECT:GetClass():GetProperties(oFlags).
            iTotal = EXTENT(aProperties).

            /* Transforma o EXTENT de propriedades em um CHARACTER delimitado */
            DO  iCount = 1 TO iTotal:
                IF  cProperties = ? THEN
                    cProperties = aProperties[iCount]:Name.
                ELSE
                    cProperties = cProperties + "," + aProperties[iCount]:Name.
            END.
            
            /* Efetua a validacao de cada atributo informado */
            iTotal = NUM-ENTRIES(cAttributes,",").
            
            DO  iCount = 1 TO iTotal:
                cAttribute = ENTRY(iCount,cAttributes,",").
                
                /* Se nÆo encontrou algum atributo emitir erro de aplicacao */
                IF  NOT LOOKUP(cAttribute,cProperties) > 0 THEN
                DO:
                    lResult = FALSE.
                    LEAVE.
                END.
            END.
        END.
        
        RETURN lResult.
    END METHOD.
   
    METHOD PRIVATE LOGICAL hasAttribute(INPUT cAttributes AS CHARACTER, INPUT cAttribute AS CHARACTER):
        RETURN cAttributes = ? OR TRIM(cAttributes) = "" OR LOOKUP(cAttribute,cAttributes) > 0.
    END METHOD.

    METHOD PRIVATE VOID setHasEmails(lHasEmails AS LOGICAL):
        THIS-OBJECT:hasEmails = lHasEmails.
    END METHOD.

    METHOD PUBLIC LOGICAL getHasEmails():
        RETURN THIS-OBJECT:hasEmails.
    END METHOD.

END CLASS.
