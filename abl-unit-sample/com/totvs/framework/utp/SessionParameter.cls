/********************************************************************************
** Copyright TOTVS S.A. (2015)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
********************************************************************************/

/********************************************************************************
** Programa.: SessionParameter.cls
**
** Data.....: 28/10/2015
**
** Cria‡Æo..: Menna
**
** Objetivo.: Retorna os parametros lidos do session:parameter.
********************************************************************************/

USING com.totvs.framework.utp.*.

{include/i_prdvers.i}

CLASS com.totvs.framework.utp.SessionParameter INHERITS com.totvs.framework.Framework FINAL:
    CONSTRUCTOR SessionParameter ():
    END CONSTRUCTOR.

    DEFINE PUBLIC STATIC PROPERTY param01 AS CHARACTER NO-UNDO
        GET ():
            RETURN getValue(01).
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY param02 AS CHARACTER NO-UNDO
        GET ():
            RETURN getValue(02).
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY remoteServerPort AS CHARACTER NO-UNDO
        GET ():
            RETURN getValue(03).
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY loginName AS CHARACTER NO-UNDO
        GET ():
            RETURN getValue(04).
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY password AS CHARACTER NO-UNDO
        GET ():
            RETURN getValue(05).
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY parentThreadId AS CHARACTER NO-UNDO
        GET ():
            RETURN getValue(06).
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY param07 AS CHARACTER NO-UNDO
        GET ():
            RETURN getValue(07).
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY param08 AS CHARACTER NO-UNDO
        GET ():
            RETURN getValue(08).
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY serverPort AS CHARACTER NO-UNDO
        GET ():
            RETURN getValue(09).
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY sessionId AS CHARACTER NO-UNDO
        GET ():
            RETURN getValue(10).
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY remoteServer AS CHARACTER NO-UNDO
        GET ():
            RETURN getValue(11).
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY serviceContext AS CHARACTER NO-UNDO
        GET ():
            RETURN getValue(12).
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY userExternal AS CHARACTER NO-UNDO
        GET ():
            RETURN getValue(13).
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY accessRemote AS CHARACTER NO-UNDO
        GET ():
            RETURN getValue(14).
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY domain AS CHARACTER NO-UNDO
        GET ():
            RETURN getValue(15).
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY ipAddress AS CHARACTER NO-UNDO
        GET ():
            RETURN getValue(16).
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY serverName AS CHARACTER NO-UNDO
        GET ():
            RETURN getValue(17).
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY hostName AS CHARACTER NO-UNDO
        GET ():
            RETURN getValue(18).
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY execHTML AS LOGICAL NO-UNDO
        GET ():
            DEFINE VARIABLE cret AS CHARACTER NO-UNDO.
            ASSIGN cret = getValue(24).
            IF  cret = "" 
            AND serviceContext = "menu-html" THEN DO:
                ASSIGN cret = "true".
            END.
            RETURN (cret = "true").
        END GET.
        PRIVATE SET.

    DEFINE PUBLIC STATIC PROPERTY totalParameters AS INTEGER NO-UNDO
        GET ():
            RETURN NUM-ENTRIES(SESSION:PARAMETER).
        END GET.
        PRIVATE SET.

    METHOD PUBLIC STATIC CHARACTER getValue(INPUT pPos AS INTEGER):
        DEFINE VARIABLE cret AS CHARACTER NO-UNDO INITIAL "".
        IF  NUM-ENTRIES(SESSION:PARAMETER) >= pPos THEN DO:
            ASSIGN cret = TRIM(ENTRY(pPos, SESSION:PARAMETER)).
        END.
        RETURN cret.
    END METHOD.
END CLASS.
