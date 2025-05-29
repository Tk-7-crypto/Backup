/*
* Version       : 0.0.1
* Description   : This Apex Class is Webservice Class for RestAPI
* Created By    : Danish Khan
* Created For   : Webservice Class for Internal or External API Request Mapping.
*/

@RestResource(urlmapping = '/GenericMappingServices/*')
global class WSC_CPQ_MappingGateway {

    @HttpGet
    global static String handleGetRequest() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            List<String> columns = UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, 'fields') == null  ? new List<String>() : 
                                    UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, 'fields').contains(', ') ? UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, 'fields').split(', ') :
                                    UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, 'fields').contains(',') ? UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, 'fields').split(',') : new List<String>{UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, 'fields')};

            UTL_CPQ_MappingGateway.WPR_CPQ_SOQLConstructor Tokens = new UTL_CPQ_MappingGateway.WPR_CPQ_SOQLConstructor(
                                                                        UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, 'entity'),
                                                                        UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, 'condition'),
                                                                        columns,
                                                                        UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, 'orderBy'),
                                                                        UTL_CPQ_MappingGateway.getFieldValueFromRequestBody(req, 'limit'),
                                                                        UTL_CPQ_MappingGateway.getSubRequest(req)
                                                                    );
            return JSON.Serialize(UTL_CPQ_MappingGateway.handleGetRequest(Tokens));
        } catch (Exception e) { 
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Error: ' + e.getMessage() + '\nStack Trace: ' + e.getStackTraceString() +
                    '\nline number: ' + e.getLineNumber() + '\nline number: ' + e.getCause());
            System.debug('Error:    : ' + e.getMessage() + '\nStack Trace: ' + e.getStackTraceString());
            return null;
        }
    }

    @HttpPost
    global static String handlePostRequest(String jsonBody, String featureSettings) {
        return JSON.Serialize(UTL_CPQ_MappingGateway.handlePostRequest(jsonBody));
    }

    @HttpPut
    global static String handlePutRequest(String jsonBody, String featureSettings) {
        return JSON.Serialize(UTL_CPQ_MappingGateway.handlePutRequest(jsonBody));
    }

    @HttpPatch
    global static String handlePatchRequest() {
        return JSON.Serialize(UTL_CPQ_MappingGateway.handlePatchRequest());
    }

    @HttpDelete
    global static String handleDeleteRequest() {
        return JSON.Serialize(UTL_CPQ_MappingGateway.handleDeleteRequest());
    }
}
