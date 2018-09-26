USING Progress.Lang.*.
USING OpenEdge.Core.*.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.
USING Progress.Json.ObjectModel.ObjectModelParser FROM PROPATH.
USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE jsonFileName AS CHARACTER NO-UNDO INITIAL "orders.json".
DEF VAR jsonFilePath AS CHAR NO-UNDO.
/* ***************************  Definitions  ************************** */
DEFINE TEMP-TABLE Order NO-UNDO
    FIELD Order-num    AS INTEGER
    FIELD Cust-Num     AS INTEGER
    FIELD Order-Date   AS DATE
    FIELD Ship-Date    AS DATE
    FIELD Promise-Date AS DATE
    FIELD Carrier      AS CHARACTER
    FIELD Instructions AS CHARACTER
    FIELD PO           AS CHARACTER
    FIELD Terms        AS CHARACTER
    FIELD Sales-Rep    AS CHARACTER.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
@SetUp.
PROCEDURE prepare:
    EMPTY TEMP-TABLE Order.
    jsonFilePath = SEARCH(jsonFileName).
    DEF VAR lll AS LOGICAL.
    TEMP-TABLE Order:READ-JSON("FILE", SEARCH(jsonFilePath), "APPEND").
END PROCEDURE.
@Test.
PROCEDURE importJsonToTT:
    assert:isTrue(TEMP-TABLE Order:HAS-RECORDS).
END PROCEDURE.
@Test.
PROCEDURE verifyNumberOfRows:
    DEFINE VARIABLE contador AS INTEGER     NO-UNDO.
    FOR EACH Order :
        contador = contador + 1.
    END.
    Assert:Equals(contador, 207).
END PROCEDURE.
@Test.
PROCEDURE validateOutputFile:
    DEFINE VARIABLE lOutput     AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE oParser     AS ObjectModelParser NO-UNDO.
    DEFINE VARIABLE oJsonOrder  AS JsonObject        NO-UNDO.
    DEFINE VARIABLE oJsonOrders AS JsonArray         NO-UNDO.

    FIX-CODEPAGE(lOutput) = 'utf-8'.
    TEMP-TABLE Order:WRITE-JSON("longchar", lOutput).
    ASSIGN
        oParser     = NEW ObjectModelParser()
        oJsonOrder  = NEW JsonObject()
        oJsonOrders = NEW JsonArray().
    /* Efetua a leitura do arquivo JSON */
    oJsonOrder = CAST(oParser:Parse(lOutput), JsonObject).

    /* Recupera a lista de "Orders" */
    oJsonOrders = oJsonOrder:GetJsonArray("Order").

    assert:Equals(oJsonOrders:LENGTH, 207).
END PROCEDURE.
