 
/*------------------------------------------------------------------------
   File        : UserName
   Purpose     : Formatacao do objeto Meta de retorno em caso de sucesso
   Syntax      : 
   Description : Formatacao do Meta de retorno em caso de sucesso
   Author(s)   : Jeferson Francisco
   Created     : Tue Jul 12 13:50:54 BRT 2018
   Notes       : 
 ----------------------------------------------------------------------*/
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

CLASS com.totvs.framework.sec.scim.Meta SERIALIZABLE: 
    DEFINE SERIALIZABLE PRIVATE PROPERTY created      AS CHARACTER NO-UNDO
        GET.
        SET.

    DEFINE SERIALIZABLE PRIVATE PROPERTY lastModified AS CHARACTER NO-UNDO
        GET.
        SET.

    DEFINE SERIALIZABLE PRIVATE PROPERTY resourceType AS CHARACTER NO-UNDO
        GET.
        SET.

    DEFINE SERIALIZABLE PRIVATE PROPERTY location     AS CHARACTER NO-UNDO
        GET.
        SET.

    CONSTRUCTOR PUBLIC Meta():
    END.

    CONSTRUCTOR PUBLIC Meta(cCreated AS CHARACTER, cLastModified AS CHARACTER, cResourceType AS CHARACTER):
        THIS-OBJECT:created = cCreated.
        THIS-OBJECT:lastModified = cLastModified.
        THIS-OBJECT:resourceType = cResourceType.
    END.

    METHOD PUBLIC CHARACTER getCreated():
        RETURN THIS-OBJECT:created.
    END METHOD.
      
    METHOD PUBLIC VOID setCreated(cCreated AS CHARACTER):
        THIS-OBJECT:created = cCreated.
    END METHOD.
    
    METHOD PUBLIC VOID setLastModified(cLastModified AS CHARACTER):
        THIS-OBJECT:lastModified = cLastModified.
    END METHOD.

    METHOD PUBLIC CHARACTER getLastModified():
        RETURN THIS-OBJECT:lastModified.
    END METHOD.

    METHOD PUBLIC VOID setResourceType(cResourceType AS CHARACTER):
        THIS-OBJECT:resourceType = cResourceType.
    END METHOD.

    METHOD PUBLIC CHARACTER getResourceType():
        RETURN THIS-OBJECT:resourceType.
    END METHOD.

    METHOD PUBLIC VOID setLocation(cLocation AS CHARACTER):
        THIS-OBJECT:location = cLocation.
    END METHOD.

    METHOD PUBLIC CHARACTER getLocation():
        RETURN THIS-OBJECT:location.
    END METHOD.
 
    /*------------------------------------------------------------------------------
     Purpose: Serializa os dados do objeto atual em um objeto JSON.
     Notes:
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC JsonObject serialize():
        DEFINE VARIABLE jsonSerialize AS JsonObject NO-UNDO.
        
        ASSIGN 
            jsonSerialize = NEW JsonObject().
        
        jsonSerialize:Add("created", created).
        jsonSerialize:Add("lastModified", lastModified).
        jsonSerialize:Add("resourceType", resourceType).
        jsonSerialize:Add("location", location).

        RETURN jsonSerialize.
    END METHOD.
END CLASS.
