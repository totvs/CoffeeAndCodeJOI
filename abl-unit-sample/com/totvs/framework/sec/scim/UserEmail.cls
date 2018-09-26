 
/*------------------------------------------------------------------------
   File        : UserEmail
   Purpose     : Classe de e-mails de usuarios no formato SCIM.
   Syntax      : 
   Description : E-mails de usuarios
   Author(s)   : Rubens Dos Santos Filho
   Created     : Tue Jul 10 13:53:37 BRT 2018
   Notes       : 
 ----------------------------------------------------------------------*/

USING com.totvs.framework.sec.scim.UserEmailTypeEnum FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

CLASS com.totvs.framework.sec.scim.UserEmail SERIALIZABLE:
    DEFINE SERIALIZABLE PRIVATE PROPERTY value   AS CHARACTER NO-UNDO INITIAL ?
        GET.
        SET.
    
    DEFINE SERIALIZABLE PRIVATE PROPERTY display AS CHARACTER NO-UNDO INITIAL ?
        GET.
        SET.
    
    DEFINE SERIALIZABLE PRIVATE PROPERTY type    AS CHARACTER NO-UNDO INITIAL "work"
        GET.
        SET.
    
    DEFINE SERIALIZABLE PRIVATE PROPERTY primary AS LOGICAL NO-UNDO INITIAL TRUE 
        GET.
        SET.
    
    METHOD PUBLIC CHARACTER getValue():
        RETURN THIS-OBJECT:value.
    END METHOD.
    
    METHOD PUBLIC VOID setValue(cValue AS CHARACTER):
        THIS-OBJECT:value = cValue.
    END METHOD.
    
    METHOD PUBLIC CHARACTER getDisplay():
        RETURN THIS-OBJECT:display.
    END METHOD.
    
    METHOD PUBLIC VOID setDisplay(cDisplay AS CHARACTER):
        THIS-OBJECT:display = cDisplay.
    END METHOD.
    
    METHOD PUBLIC CHARACTER getType():
        RETURN THIS-OBJECT:type.
    END METHOD.
    
    METHOD PUBLIC VOID setType(iType AS UserEmailTypeEnum):
        CASE iType:
            WHEN UserEmailTypeEnum:WORK THEN 
                THIS-OBJECT:type = "work".
            WHEN UserEmailTypeEnum:HOME THEN 
                THIS-OBJECT:type = "home".
            WHEN UserEmailTypeEnum:OTHER THEN 
                THIS-OBJECT:type = "other".
        END CASE.
    END METHOD.
    
    METHOD PUBLIC LOGICAL isPrimary():
        RETURN THIS-OBJECT:primary.
    END METHOD.
    
    METHOD PUBLIC VOID setIsPrimary(lPrimary AS LOGICAL):
        THIS-OBJECT:primary = lPrimary.
    END METHOD.
    
    METHOD PUBLIC JsonObject serialize():
        DEFINE VARIABLE jsonSerialize AS JsonObject NO-UNDO.
        
        jsonSerialize = NEW JsonObject().
        jsonSerialize:Add("value", THIS-OBJECT:value).
        jsonSerialize:Add("display", THIS-OBJECT:display).
        jsonSerialize:Add("type", THIS-OBJECT:type).
        jsonSerialize:Add("primary", THIS-OBJECT:primary).
        
        RETURN jsonSerialize.
    END METHOD.
END CLASS.
