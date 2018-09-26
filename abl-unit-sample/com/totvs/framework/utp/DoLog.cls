/********************************************************************************
** Copyright TOTVS S.A. (2015)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da TOTVS, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
********************************************************************************/

/********************************************************************************
** Programa.: Log.cls
**
** Data.....: 02/05/2016
**
** Cria‡Æo..: Menna
**
** Objetivo.: Gera log do produto
********************************************************************************/

USING com.totvs.framework.utp.*.

CLASS com.totvs.framework.utp.DoLog INHERITS com.totvs.framework.Framework:
    DEFINE PRIVATE STATIC VARIABLE cArquivo     AS CHARACTER NO-UNDO.
    DEFINE PRIVATE STATIC VARIABLE cCategList   AS CHARACTER NO-UNDO.
    DEFINE PRIVATE STATIC VARIABLE iNivel       AS INTEGER   NO-UNDO.

    CONSTRUCTOR DoLog ():
        ASSIGN cArquivo   = LOG-MANAGER:LOGFILE-NAME
               iNivel     = LOG-MANAGER:LOGGING-LEVEL        
               cCategList = LOG-MANAGER:LOG-ENTRY-TYPES no-error. 
    END CONSTRUCTOR.

    DEFINE PUBLIC STATIC PROPERTY fileName AS CHARACTER NO-UNDO
        GET ():
            RETURN LOG-MANAGER:LOGFILE-NAME.
        END GET.
        SET (INPUT pArq AS CHARACTER):
            LOG-MANAGER:LOGFILE-NAME = pArq.
            ASSIGN cArquivo = pArq.
        END SET.
        
    DEFINE PUBLIC STATIC PROPERTY level AS INTEGER NO-UNDO
        GET ():
            RETURN LOG-MANAGER:LOGGING-LEVEL.
        END GET.
        SET (INPUT pNivel AS INTEGER):
            LOG-MANAGER:LOGGING-LEVEL = pNivel.
            ASSIGN iNivel = pNivel.
        END SET.

    DEFINE PUBLIC STATIC PROPERTY categories AS CHARACTER NO-UNDO
        GET ():
            RETURN LOG-MANAGER:LOG-ENTRY-TYPES.
        END GET.
        SET (INPUT pCategs AS CHARACTER):
            LOG-MANAGER:LOG-ENTRY-TYPES = pCategs.
            ASSIGN cCategList = pCategs.
        END SET.

    METHOD PUBLIC STATIC VOID start (INPUT pArq AS CHARACTER, INPUT pNivel AS INTEGER, INPUT pCategs AS CHARACTER):
        ASSIGN fileName   = pArq
               categories = pCategs
               level      = pNivel.
    END METHOD.

    METHOD PUBLIC STATIC VOID stop ():
        ASSIGN categories = ""
               level      = 0
               fileName   = ?.
    END METHOD.

    METHOD PUBLIC STATIC VOID block (INPUT pBloqueia AS LOGICAL):
        IF pBloqueia = TRUE THEN DO:
            IF  iNivel <> LOG-MANAGER:LOGGING-LEVEL THEN
                ASSIGN iNivel     = LOG-MANAGER:LOGGING-LEVEL
                       cCategList = LOG-MANAGER:LOG-ENTRY-TYPES.
            LOG-MANAGER:LOGGING-LEVEL = 0.
            LOG-MANAGER:LOG-ENTRY-TYPES = "".
        END.
        ELSE DO:
            /* se nao tem um nivel definido, assume o nivel 4 */
            IF  iNivel = 0 THEN
                ASSIGN iNivel = 4.
            LOG-MANAGER:LOG-ENTRY-TYPES = cCategList NO-ERROR.
            LOG-MANAGER:LOGGING-LEVEL    = iNivel.
        END.
    END METHOD.

    METHOD PUBLIC STATIC VOID addCateg (INPUT pCateg AS CHARACTER):
        IF NOT CAN-DO(cCategList, pCateg) THEN
            ASSIGN cCategList = cCategList + "," + pCateg.
        ASSIGN categories = cCategList.
    END METHOD.

    METHOD PUBLIC STATIC VOID removeCateg (INPUT pCateg AS CHARACTER):
        IF  CAN-DO(cCategList, pCateg) THEN DO:
            /* remove a categoria da lista */
            /* colocado 2 formas de remocao para caso a categoria esteja antes ou depois de uma virgula */
            ASSIGN cCategList = REPLACE(cCategList, "," + pCateg, "")
                   cCategList = REPLACE(cCategList, pCateg + ",", "").
            ASSIGN categories = cCategList.
        END.
    END METHOD.

    METHOD PUBLIC STATIC VOID message (INPUT pArea AS CHARACTER, INPUT pCateg AS CHARACTER, INPUT pMsg AS CHARACTER):
        IF  LOG-MANAGER:LOGFILE-NAME <> ? 
       /* AND (pCateg = "" 
        OR  pCateg = ?
        OR CAN-DO(cCategList, pCateg)) */ THEN DO:
            IF  pArea <> ""
            AND pArea <> ? THEN
                pCateg = pArea + "_" + pCateg.
            LOG-MANAGER:WRITE-MESSAGE (pMsg, pCateg).
        END.
    END METHOD.
END CLASS.
