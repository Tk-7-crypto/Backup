/*
 * Version       : 1.0
 * Description   : This test class is used to test all methods of WSC_CRM_Field_History.
 */ 
@isTest
public class TST_WSC_CRM_Field_History {
    
     /**
     * This method used to set up testdata
     */ 
    @testsetup
    static void setupData(){
        CRM_Config__c CRMConfig = CRM_Config__c.getOrgDefaults();
        CRMConfig.Field_History_Exception_Email__c = 'abc@xyz.com:xyz@abc.com';
        upsert CRMConfig;
        abc__c abc = new abc__c();
        insert abc; 
    }
    
    // Payload Record Creation
    private static String payloaddata(){
        String objectName = 'abc';
        Map<Id,abc__c> newRecords = new Map<Id,abc__c>([SELECT Id, Name FROM abc__c LIMIT 1]);
        WSC_CRM_Field_History.RequestPayload payloaddata = new WSC_CRM_Field_History.RequestPayload();
        payloaddata.setObjectName(objectName) ;
        payloaddata.setNewRecords(newRecords.values());
        payloaddata.setOldMap(null) ;
        payloaddata.setActionUserId(userinfo.getuserid());
        payloaddata.setActionTime(System.now());  
        string payloadresult= JSON.serialize(payloaddata); 
        return payloadresult;
    }
    
    @isTest
    public static void testCreateHistoryTrackingRecords(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createHistoryTrackingRecords';
        req.httpMethod = 'POST';
       	req.requestBody = Blob.valueof(payloaddata());
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        	WSC_CRM_Field_History.createHistoryTrackingRecords();
        Test.stopTest();
    }
    
}