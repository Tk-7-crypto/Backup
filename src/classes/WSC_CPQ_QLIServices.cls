/*
* Version       : 0.0.1
* Description   : This Apex Class is Webservice Class for RestAPI
* Created By    : Danish Khan
* Created For   : Webservice Class for Internal or External API Request.
*/
@RestResource(urlmapping = '/CPQ/QLIServices/*')
global class WSC_CPQ_QLIServices {
    
    @HttpPost
    global static String insertQLIs(String jsonBody, String featureSettings) {
        return String.valueOf(UTL_CPQ_Services.insertQLIs(jsonBody, featureSettings));
    }
}
