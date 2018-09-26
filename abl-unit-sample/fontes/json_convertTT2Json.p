USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.
USING com.totvs.framework.api.JsonAPIUtils FROM PROPATH.
USING Progress.Lang.*.
USING OpenEdge.Core.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

/* ***************************  Definitions  ************************** */
DEFINE TEMP-TABLE ttOrder NO-UNDO
    FIELD Order-num    AS INTEGER   SERIALIZE-NAME "orderNum"
    FIELD Cust-Num     AS INTEGER   SERIALIZE-NAME "custNum"
    FIELD Order-Date   AS DATE      SERIALIZE-NAME "orderDate"
    FIELD Ship-Date    AS DATE      SERIALIZE-NAME "shipDate"
    FIELD Promise-Date AS DATE      SERIALIZE-NAME "promiseDate"
    FIELD Carrier      AS CHARACTER SERIALIZE-NAME "carrier"
    FIELD Instructions AS CHARACTER SERIALIZE-NAME "instructions"
    FIELD PO           AS CHARACTER SERIALIZE-NAME "po"
    FIELD Terms        AS CHARACTER SERIALIZE-NAME "terms"
    FIELD Sales-Rep    AS CHARACTER SERIALIZE-NAME "salesRep".


DEFINE VARIABLE oUtils      AS JsonAPIUtils NO-UNDO.
DEFINE VARIABLE cOrders     AS LONGCHAR     NO-UNDO.
DEFINE VARIABLE oJsonOrder  AS JsonObject   NO-UNDO.
DEFINE VARIABLE oOrder      AS JsonObject   NO-UNDO.
DEFINE VARIABLE oJsonOrders AS JsonArray    NO-UNDO.
DEFINE VARIABLE iCount      AS INTEGER      NO-UNDO.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


@SetUp.
PROCEDURE fillTT:
    FOR EACH Order NO-LOCK:
        CREATE ttOrder.
        BUFFER-COPY Order TO ttOrder.
    END.
    oJsonOrder = JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE ttOrder:HANDLE).	
END PROCEDURE.
@Test.
PROCEDURE convertTTToJson:
    Assert:isTrue(VALID-OBJECT(oJsonOrder)).
END PROCEDURE.
@Test.
PROCEDURE verifyJsonLength:
    /* Recupera a lista de "Orders" */
    oJsonOrders = oJsonOrder:GetJsonArray("ttOrder").
    
    Assert:Equals(oJsonOrders:Length, 207).
END PROCEDURE.
@After.
PROCEDURE RELEASEObjects:
    DELETE OBJECT oJsonOrders NO-ERROR.
    DELETE OBJECT oJsonOrder  NO-ERROR.
END PROCEDURE.
