USING Progress.Lang.*.
USING OpenEdge.Core.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

/* --- DEFINICOES --- */

DEFINE VARIABLE iCount          AS INTEGER     NO-UNDO.
DEFINE VARIABLE cCmd            AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cReturn         AS CHARACTER   NO-UNDO.
DEFINE VARIABLE batFile         AS CHARACTER   NO-UNDO.
DEFINE VARIABLE batReturnFile   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE certDirectory   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE cExpectedReturn AS CHARACTER   NO-UNDO INITIAL 'Importing trusted certificate to alias name:'.
DEFINE VARIABLE isImported      AS LOGICAL     NO-UNDO INITIAL NO.

/* --- MAIN BLOCK --- */

ASSIGN batFile       = session:temp-directory + 'cert#NUMBER.bat'
       batReturnFile = session:temp-directory + 'retorno#NUMBER.txt'.


/* --- PROCEDURES --- */

@SetUp.
PROCEDURE setVariables:
    ASSIGN cCmd          = '@echo off' + CHR(10)
                         + 'set OPENSSL_CONF=%DLC%\keys\policy\pscpki.cnf' + chr(10)
                         + 'set BPSERVER_BIN=%DLC%\oebpm\server\bin' + chr(10)
                         + 'set PATH=%DLC%\BIN;%BPSERVER_BIN%;%DLC%\PERL\BIN;%PATH%' + chr(10)
                         + 'set LIB=%DLC%\LIB;%LIB%' + CHR(10)
           certDirectory = '\\jvd003095\ablunit\quente\postman#NUMBER.cer'.
END PROCEDURE.

@Test.
PROCEDURE importCertificate:
    DO iCount = 1 TO 5 ON ERROR UNDO, RETURN:
        RUN importCertFiles(INPUT  REPLACE(certDirectory, '#NUMBER' , STRING(iCount)),
                            INPUT  REPLACE(batFile, '#NUMBER' , STRING(iCount)),
                            INPUT  REPLACE(batReturnFile, '#NUMBER' , STRING(iCount)),
                            OUTPUT isImported).
        IF NOT isImported THEN LEAVE.
    END.
    Assert:isTrue(isImported).
END PROCEDURE.

@After.
PROCEDURE deleteFiles:
    DO iCount = 1 TO 5.
        OS-DELETE VALUE(REPLACE(batFile, '#NUMBER' , STRING(iCount))).
        OS-DELETE value(REPLACE(batReturnFile, '#NUMBER' , STRING(iCount))).
    END.
END PROCEDURE.

PROCEDURE importCertFiles:
    DEFINE INPUT PARAMETER  ipCertDir        AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER  ipBatFile        AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER  ipBatRetFile     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER opImportComplete AS LOGICAL   NO-UNDO INITIAL NO.

    OUTPUT TO VALUE(ipBatFile).
        PUT UNFORMATTED cCmd + 'certutil -format DER -import ' + ipCertDir + ' >> ' + ipBatRetFile.
    OUTPUT CLOSE.

    OS-COMMAND SILENT VALUE(ipBatFile) NO-WAIT. 

    INPUT FROM VALUE(ipBatRetFile).
    REPEAT:
        IMPORT UNFORMATTED cReturn.
        IF LENGTH(cReturn) > 0 THEN DO:
            IF NOT cReturn BEGINS cExpectedReturn THEN
                RETURN.
        END.
    END.
    INPUT CLOSE.
    
    ASSIGN opImportComplete = TRUE.

END PROCEDURE.
