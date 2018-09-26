
USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.
USING Progress.Json.ObjectModel.ObjectModelParser FROM PROPATH.
USING Progress.Lang.*.
USING OpenEdge.Core.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

/* ***************************  Definitions  ************************** */
DEFINE VARIABLE oParser     AS ObjectModelParser NO-UNDO.
DEFINE VARIABLE oJsonOrder  AS JsonObject        NO-UNDO.
DEFINE VARIABLE oJsonOrders AS JsonArray         NO-UNDO.
DEFINE VARIABLE fileExists  AS LOGICAL     NO-UNDO.
DEFINE VARIABLE jsonFilePath AS CHARACTER   NO-UNDO INITIAL "orders.json".

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
@SetUp.
PROCEDURE initializeVariables:
ASSIGN
    oParser     = NEW ObjectModelParser()
    oJsonOrder  = NEW JsonObject()
    oJsonOrders = NEW JsonArray().
END PROCEDURE.
@Test.
PROCEDURE fileExists:
    RUN searchForFile(INPUT jsonFilePath, OUTPUT fileExists).
    assert:isTrue(fileExists).
END PROCEDURE.
PROCEDURE searchForFile:
    DEF INPUT PARAM filePath AS CHAR.
    DEF OUTPUT PARAM fileExists AS LOGICAL.
    fileExists = (SEARCH(filePath) <> ?).
END PROCEDURE.
@Test.
PROCEDURE readJsonFile:
	/* Efetua a leitura do arquivo JSON */
	oJsonOrder = CAST(oParser:ParseFile(SEARCH(jsonFilePath)), JsonObject).

	/* Recupera a lista de "Orders" */
	oJsonOrders = oJsonOrder:GetJsonArray("Order").
	Assert:Equals(oJsonOrders:Length, 207).
END PROCEDURE.
@After.
PROCEDURE deleteObjects:

    DELETE OBJECT oParser     NO-ERROR.
    DELETE OBJECT oJsonOrders NO-ERROR.
    DELETE OBJECT oJsonOrder  NO-ERROR.
END PROCEDURE.
