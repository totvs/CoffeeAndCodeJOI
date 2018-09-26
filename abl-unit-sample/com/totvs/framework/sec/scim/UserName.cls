 
/*------------------------------------------------------------------------
   File        : UserName
   Purpose     : Classe de formatacao de nome de usuario no formato SCIM.
   Syntax      : 
   Description : Formatacao de nome de usuario
   Author(s)   : Rubens Dos Santos Filho
   Created     : Tue Jul 10 13:50:54 BRT 2018
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

CLASS com.totvs.framework.sec.scim.UserName SERIALIZABLE: 
    DEFINE SERIALIZABLE PRIVATE PROPERTY formatted AS CHARACTER  NO-UNDO INITIAL ?
        GET.
        SET.
    
    DEFINE SERIALIZABLE PRIVATE PROPERTY familyName AS CHARACTER NO-UNDO INITIAL ?
        GET.
        SET.
    
    DEFINE SERIALIZABLE PRIVATE PROPERTY givenName AS CHARACTER  NO-UNDO INITIAL ?
        GET.
        SET.

    DEFINE SERIALIZABLE PRIVATE PROPERTY middleName AS CHARACTER NO-UNDO INITIAL ?
        GET.
        SET.
    
    CONSTRUCTOR PUBLIC UserName():
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
     Purpose: Carrega os dados do objeto atual a partir de um objeto JSON
     Notes:
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC UserName(jsonUserName AS JsonObject):
        DEFINE VARIABLE cFormattedName AS CHARACTER NO-UNDO INITIAL "".

        IF  VALID-OBJECT(jsonUserName) THEN
        DO:
            ASSIGN 
                THIS-OBJECT:formatted  = IF jsonUserName:Has("formatted")  THEN jsonUserName:GetCharacter("formatted")  ELSE ""
                THIS-OBJECT:givenName  = IF jsonUserName:Has("givenName")  THEN jsonUserName:GetCharacter("givenName")  ELSE ""
                THIS-OBJECT:middleName = IF jsonUserName:Has("middleName") THEN jsonUserName:GetCharacter("middleName") ELSE ""
                THIS-OBJECT:familyName = IF jsonUserName:Has("familyName") THEN jsonUserName:GetCharacter("familyName") ELSE "".

            IF  THIS-OBJECT:formatted = ? OR THIS-OBJECT:formatted = "" THEN
            DO:
                IF  jsonUserName:Has("honorificPrefix") THEN
                    ASSIGN cFormattedName = jsonUserName:GetCharacter("honorificPrefix").
                
                ASSIGN 
                    cFormattedName = cFormattedName + " " + THIS-OBJECT:givenName
                    cFormattedName = cFormattedName + " " + THIS-OBJECT:middleName
                    cFormattedName = cFormattedName + " " + THIS-OBJECT:familyName.
                
                IF  jsonUserName:Has("honorificSuffix") THEN
                    ASSIGN 
                        cFormattedName = cFormattedName + ", " + jsonUserName:GetCharacter("honorificSuffix").
                
                ASSIGN
                    THIS-OBJECT:formatted = cFormattedName.
            END.                
        END.
    END.
        
    METHOD PUBLIC CHARACTER getFormatted():
        RETURN THIS-OBJECT:formatted.
    END METHOD.
    
    METHOD PUBLIC VOID setFormatted(cFormatted AS CHARACTER):
        THIS-OBJECT:formatted = cFormatted.
    END METHOD.
    
    METHOD PUBLIC CHARACTER getFamilyName():
        RETURN THIS-OBJECT:familyName.
    END METHOD.
    
    METHOD PUBLIC VOID setFamilyName(cFamilyName AS CHARACTER):
        THIS-OBJECT:familyName = cFamilyName.
    END METHOD.
    
    METHOD PUBLIC CHARACTER getGivenName():
        RETURN THIS-OBJECT:givenName.
    END METHOD.
    
    METHOD PUBLIC VOID setGivenName(cGivenName AS CHARACTER):
        THIS-OBJECT:givenName = cGivenName.
    END METHOD.
    
    METHOD PUBLIC CHARACTER getMiddleName():
        RETURN THIS-OBJECT:middleName.
    END METHOD.
    
    METHOD PUBLIC VOID setMiddleName(cMiddleName AS CHARACTER):
        THIS-OBJECT:middleName = cMiddleName.
    END METHOD.
    
    METHOD PUBLIC JsonObject serialize():
        DEFINE VARIABLE jsonSerialize AS JsonObject NO-UNDO.
        
        jsonSerialize = NEW JsonObject().
        jsonSerialize:Add("formatted", THIS-OBJECT:formatted).
        jsonSerialize:Add("familyName", THIS-OBJECT:familyName).
        jsonSerialize:Add("givenName", THIS-OBJECT:givenName).
        jsonSerialize:Add("middleName", THIS-OBJECT:middleName).
        
        RETURN jsonSerialize.
    END METHOD.
END CLASS.
