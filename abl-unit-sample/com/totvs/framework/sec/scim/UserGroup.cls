 
/*------------------------------------------------------------------------
   File        : UserGroup
   Purpose     : Classe com a estrutura de grupos do usuario no formato SCIM.
   Syntax      : 
   Description : Grupos do usuario
   Author(s)   : Rubens Dos Santos Filho
   Created     : Tue Jul 10 13:54:37 BRT 2018
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

CLASS com.totvs.framework.sec.scim.UserGroup SERIALIZABLE:
    DEFINE SERIALIZABLE PRIVATE PROPERTY value AS CHARACTER NO-UNDO
        GET.
        SET.
    
    DEFINE SERIALIZABLE PRIVATE PROPERTY ref AS CHARACTER NO-UNDO
        GET. 
        SET.
    
    DEFINE SERIALIZABLE PRIVATE PROPERTY display AS CHARACTER NO-UNDO
        GET.
        SET.
    
    DEFINE SERIALIZABLE PRIVATE PROPERTY type AS CHARACTER NO-UNDO
        GET.
        SET.
    
    METHOD PUBLIC CHARACTER getValue():
        RETURN THIS-OBJECT:value.
    END METHOD.
    
    METHOD PUBLIC VOID setValue(INPUT cValue AS CHARACTER):
        THIS-OBJECT:value = cValue.
    END METHOD.
    
    METHOD PUBLIC CHARACTER getRef():
        RETURN THIS-OBJECT:ref.
    END METHOD.
    
    METHOD PUBLIC VOID setRef(INPUT cRef AS CHARACTER):
        THIS-OBJECT:ref = cRef.
    END METHOD.
    
    METHOD PUBLIC CHARACTER getDisplay():
        RETURN THIS-OBJECT:display.
    END METHOD.
    
    METHOD PUBLIC VOID setDisplay(INPUT cDisplay AS CHARACTER):
        THIS-OBJECT:display = cDisplay.
    END METHOD.
    
    METHOD PUBLIC CHARACTER getType():
        RETURN THIS-OBJECT:type.
    END METHOD.
    
    METHOD PUBLIC VOID setType(INPUT cType AS CHARACTER):
        THIS-OBJECT:type = cType.
    END METHOD.
    
    METHOD PUBLIC JsonObject serialize():
        DEFINE VARIABLE jsonSerialize AS JsonObject NO-UNDO.
        
        jsonSerialize = NEW JsonObject().
        jsonSerialize:Add("value", THIS-OBJECT:value).
        jsonSerialize:Add("$ref", THIS-OBJECT:ref).
        jsonSerialize:Add("display", THIS-OBJECT:display).
        jsonSerialize:Add("type", THIS-OBJECT:type).
        
        RETURN jsonSerialize.
    END METHOD.
END CLASS.