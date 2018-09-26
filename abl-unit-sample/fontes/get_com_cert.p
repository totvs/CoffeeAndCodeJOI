USING Progress.Lang.*.
USING OpenEdge.Core.*.
USING OpenEdge.Net.HTTP.IHttpRequest.
USING OpenEdge.Net.HTTP.IHttpResponse.
USING OpenEdge.Net.HTTP.ClientBuilder.
USING OpenEdge.Net.HTTP.IHttpClientLibrary.
USING OpenEdge.Net.HTTP.lib.ClientLibraryBuilder.
USING OpenEdge.Net.HTTP.RequestBuilder.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE oLib           AS OpenEdge.Net.HTTP.IHttpClientLibrary NO-UNDO.
DEFINE VARIABLE oHttpClient    AS OpenEdge.Net.HTTP.IHttpClient        NO-UNDO.
DEFINE VARIABLE oRequest       AS IHttpRequest                         NO-UNDO.
DEFINE VARIABLE oResponse      AS IHttpResponse                        NO-UNDO.

DEFINE VARIABLE oObjParse      AS ObjectModelParser                    NO-UNDO.
DEFINE VARIABLE oJsonObject    AS JsonObject                           NO-UNDO.
DEFINE VARIABLE cURL 		   AS char                                 NO-UNDO.

assign cUrl = 'http://7a400afc-c204-48bf-943f-f27f71b6951a.mock.pstmn.io/orders/1'.

@SetUp.
PROCEDURE INITIALIZEVariables:
    ASSIGN oLib        = ClientLibraryBuilder:Build():sslVerifyHost(NO):library
           oHttpClient = ClientBuilder:Build():UsingLibrary(oLib):Client.
    RUN executeGet(OUTPUT oResponse).
END PROCEDURE.

@Test.
PROCEDURE testGetResponse:
    Assert:isTrue(VALID-OBJECT(oResponse) AND oResponse:StatusCode = 200).
END PROCEDURE.
@Test.
PROCEDURE parseResponse:
    ASSIGN oJsonObject = NEW JsonObject()
           oObjParse   = NEW ObjectModelParser().

    oJsonObject = CAST(oObjParse:Parse(oResponse:Entity:ToString()), JsonObject).
    Assert:isTrue(VALID-OBJECT(oJsonObject)).
END PROCEDURE.

PROCEDURE executeGet:
    DEF OUTPUT PARAM oResponse AS IHttpResponse NO-UNDO.
    ASSIGN oRequest = RequestBuilder:GET(cURL):Request.
    oResponse = oHttpClient:Execute(oRequest).
    Assert:isTrue(VALID-OBJECT(oResponse) AND oResponse:StatusCode = 200).
END PROCEDURE.



