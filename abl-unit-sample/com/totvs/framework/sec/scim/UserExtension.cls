 
/*------------------------------------------------------------------------
   File        : UserExtension
   Purpose     : Classe de extensao do usuario no formato SCIM.
   Syntax      : 
   Description : Extensao do usuario
   Author(s)   : Rubens Dos Santos Filho
   Created     : Tue Jul 10 14:15:40 BRT 2018
   Notes       : 
 ----------------------------------------------------------------------*/
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

CLASS com.totvs.framework.sec.scim.UserExtension SERIALIZABLE: 

    DEFINE SERIALIZABLE PRIVATE PROPERTY domain       AS CHARACTER NO-UNDO INITIAL ?
        GET.
        SET.

    DEFINE SERIALIZABLE PRIVATE PROPERTY externalUser AS CHARACTER NO-UNDO INITIAL ?
        GET.
        SET. 

    CONSTRUCTOR PUBLIC UserExtension():
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose: Carrega os dados do objeto atual a partir de um objeto JSON
     Notes:
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC UserExtension(jsonExtension AS JsonObject):
        IF  jsonExtension:Has("domain") THEN
            ASSIGN 
                THIS-OBJECT:domain = jsonExtension:GetCharacter("domain").
        
        IF  jsonExtension:Has("externalUser") THEN
            ASSIGN
                THIS-OBJECT:externalUser = jsonExtension:GetCharacter("externalUser").
    END CONSTRUCTOR.    

    METHOD PUBLIC CHARACTER getDomain():
        RETURN THIS-OBJECT:domain.
    END METHOD.
    
    METHOD PUBLIC VOID setDomain(cDomain AS CHARACTER):
        THIS-OBJECT:domain = cDomain.
    END METHOD.

    METHOD PUBLIC CHARACTER getExternalUser():
        RETURN THIS-OBJECT:externalUser.
    END METHOD.
    
    METHOD PUBLIC VOID setExternalUser(cExternalUser AS CHARACTER):
        THIS-OBJECT:externalUser = externalUser.
    END METHOD.
END CLASS.
