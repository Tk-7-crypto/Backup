/*
* Version       : 0.0.1
* Description   : This Apex Class is Webservice Class for RestAPI
* Created By    : Danish Khan
* Created For   : Webservice Class for Internal or External API Request.
*/

public class UTL_CPQ_FileServices {

    public static Id createContentVersion (Blob fileBody, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = fileBody;
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv.Id;
        } catch (DMLException e) {
            return e.getMessage();
        }
    }
    public static Id createContentLink (String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { 
            return null; 
        }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl.ContentDocumentId;
        } catch (DMLException e) {
            return e.getMessage();
        }
    }
}