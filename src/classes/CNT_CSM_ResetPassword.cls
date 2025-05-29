@RestResource(urlMapping='/ResetPassword/*')

global with sharing class CNT_CSM_ResetPassword {

    @HttpGet
    global static void resetPassword() {
        RestRequest req = RestContext.request;
        if(req != null) {
            String userId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            System.resetPassword(userId, true);
        }
    }
}
