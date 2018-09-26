/********************************************************************************
** Copyright TOTVS S.A. (2015)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
********************************************************************************/
USING com.totvs.framework.sec.scim.ErrorTypeEnum.

CLASS com.totvs.framework.sec.scim.Scim20Error:

    /*********************************************   Constants   ***********************************************/
    DEFINE STATIC PUBLIC PROPERTY INVALID_FILTER        AS CHARACTER    NO-UNDO INITIAL "invalidFilter"  GET. PRIVATE SET.
    DEFINE STATIC PUBLIC PROPERTY TOO_MANY              AS CHARACTER    NO-UNDO INITIAL "tooMany"        GET. PRIVATE SET.
    DEFINE STATIC PUBLIC PROPERTY UNIQUENESS            AS CHARACTER    NO-UNDO INITIAL "uniqueness"     GET. PRIVATE SET.
    DEFINE STATIC PUBLIC PROPERTY MUTABILITY            AS CHARACTER    NO-UNDO INITIAL "mutability"     GET. PRIVATE SET.
    DEFINE STATIC PUBLIC PROPERTY INVALID_SINTAX        AS CHARACTER    NO-UNDO INITIAL "invalidSyntax"  GET. PRIVATE SET.
    DEFINE STATIC PUBLIC PROPERTY INVALID_PATH          AS CHARACTER    NO-UNDO INITIAL "invalidPath"    GET. PRIVATE SET.
    DEFINE STATIC PUBLIC PROPERTY NO_TARGET             AS CHARACTER    NO-UNDO INITIAL "noTarget"       GET. PRIVATE SET.
    DEFINE STATIC PUBLIC PROPERTY INVALID_VALUE         AS CHARACTER    NO-UNDO INITIAL "invalidValue"   GET. PRIVATE SET.
    DEFINE STATIC PUBLIC PROPERTY INVALID_VERS          AS CHARACTER    NO-UNDO INITIAL "invalidVers"    GET. PRIVATE SET.
    DEFINE STATIC PUBLIC PROPERTY SENSITIVE             AS CHARACTER    NO-UNDO INITIAL "sensitive"      GET. PRIVATE SET.
    
    /*********************************************   Properties   ***********************************************/
    /*Guid*/
    DEFINE PRIVATE PROPERTY cId             AS CHARACTER NO-UNDO
    GET.
    SET.       

    /*POST, PUT, GET, DELETE*/
    DEFINE PRIVATE PROPERTY cHttpMethod     AS CHARACTER NO-UNDO
    GET.
    SET.
    
    /*ScimType: INVALID_VALUE*/
    DEFINE PRIVATE PROPERTY cErrorType      AS CHARACTER NO-UNDO
    GET.
    SET.

    /*Message error: The atribute 'ID' is required */
    DEFINE PRIVATE PROPERTY cDetail         AS  CHARACTER NO-UNDO
    GET.
    SET.

    /*400 - BAD_REQUEST*/
    DEFINE PRIVATE PROPERTY iHttpStatus     AS INTEGER NO-UNDO
    GET.
    SET.

    /*********************************************   Constructors   *********************************************/
    CONSTRUCTOR Scim20Error ():                
    END CONSTRUCTOR.

    CONSTRUCTOR Scim20Error (pId           AS CHARACTER, 
                             pHttpMethod   AS CHARACTER, 
                             pErrorType    AS CLASS ErrorTypeEnum, 
                             pDetail       AS CHARACTER, 
                             pHttpStatus   AS INTEGER): 

    ASSIGN THIS-OBJECT:cId          = pId
           THIS-OBJECT:cHttpMethod  = pHttpMethod
           THIS-OBJECT:cDetail      = pDetail
           THIS-OBJECT:iHttpStatus  = pHttpStatus.
           setErrorType(INPUT pErrorType).
    END CONSTRUCTOR.

    /*****************************************   Getters and Setters   *****************************************/
    METHOD PUBLIC CHARACTER getId():
        RETURN THIS-OBJECT:cId.
    END METHOD.
    
    METHOD PUBLIC VOID setId(INPUT cGuid AS CHARACTER):
        ASSIGN
            THIS-OBJECT:cId = cGuid.
    END METHOD.
    
    METHOD PUBLIC CHARACTER getHttpMethod():
        RETURN THIS-OBJECT:cHttpMethod.
    END METHOD.
    
    METHOD PUBLIC VOID setHttpMethod(INPUT httpMet AS CHARACTER):
        ASSIGN
            THIS-OBJECT:cHttpMethod = httpMet.
    END METHOD.

    METHOD PUBLIC CHARACTER getErrorType():
        RETURN THIS-OBJECT:cErrorType.
    END METHOD.
    
    METHOD PUBLIC VOID setErrorType(INPUT errorT AS CLASS ErrorTypeEnum):
      
       CASE errorT:
           WHEN ErrorTypeEnum:INVALID_FILTER THEN
               ASSIGN 
                   THIS-OBJECT:cErrorType = INVALID_FILTER.   
    
           WHEN ErrorTypeEnum:TOO_MANY THEN
               ASSIGN 
                   THIS-OBJECT:cErrorType = TOO_MANY.
           
           WHEN ErrorTypeEnum:UNIQUENESS THEN 
               ASSIGN 
                   THIS-OBJECT:cErrorType = UNIQUENESS.
           
           WHEN ErrorTypeEnum:MUTABILITY THEN 
               ASSIGN 
                   THIS-OBJECT:cErrorType = MUTABILITY.
           
           WHEN ErrorTypeEnum:INVALID_SINTAX THEN
               ASSIGN 
                   THIS-OBJECT:cErrorType = INVALID_SINTAX.
           
           WHEN ErrorTypeEnum:INVALID_PATH THEN
               ASSIGN 
                   THIS-OBJECT:cErrorType = INVALID_PATH.
           
           WHEN ErrorTypeEnum:NO_TARGET THEN
               ASSIGN 
                   THIS-OBJECT:cErrorType = NO_TARGET.
           
           WHEN ErrorTypeEnum:INVALID_VALUE THEN
               ASSIGN 
                   THIS-OBJECT:cErrorType = INVALID_VALUE.
           
           WHEN ErrorTypeEnum:INVALID_VERS THEN
               ASSIGN 
                   THIS-OBJECT:cErrorType = INVALID_VERS.
           
           WHEN ErrorTypeEnum:SENSITIVE THEN
               ASSIGN 
                   THIS-OBJECT:cErrorType = SENSITIVE.       
       END CASE.
    END METHOD.

    METHOD PUBLIC CHARACTER getDetail():
        RETURN THIS-OBJECT:cDetail.
    END METHOD.
    
    METHOD PUBLIC VOID setDetail(INPUT detail AS CHARACTER):
        ASSIGN
            THIS-OBJECT:cDetail = detail.
    END METHOD.
        
    METHOD PUBLIC INTEGER getHttpStatus():
        RETURN THIS-OBJECT:iHttpStatus.
    END METHOD.
    
    METHOD PUBLIC VOID setHttpStatus(INPUT httpStat AS INTEGER):
        ASSIGN
            THIS-OBJECT:iHttpStatus = httpStat.
    END METHOD.

END CLASS.
