/*
 * Version       : 1.0
 * Description   : This test class is used to test all methods of SRV_CRM_Field_History.
 */ 
@isTest
private class TST_SRV_CRM_Field_History {
    /**
     * This method used to set up testdata
     */ 
    @testsetup
    static void setupData(){
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        CRM_Config__c CRMConfig = CRM_Config__c.getOrgDefaults();
        CRMConfig.Field_History_Exception_Email__c = 'abc@xyz.com:xyz@abc.com';
        upsert CRMConfig;
        abc__c abc = new abc__c();
        insert abc; 
    }
    /**
     * Public method to save field history records based on changes in records.
     */ 
     @isTest
    static void testSyncSaveFieldHistories(){
        String objectName = 'abc';
        Map<Id,abc__c> newRecords = new Map<Id,abc__c>([SELECT Id, name FROM abc__c LIMIT 1]);
        Test.StartTest();
        SRV_CRM_Field_History serviceInstance = SRV_CRM_Field_History.getInstance(objectName);
        serviceInstance.saveFieldHistories(newRecords.values(),null); 
        Test.StopTest();
    }
    /**
    * Public method to save field history records based on the provided request payload.
    */
    @isTest
    static void testAsyncSaveFieldHistories() {
        String objectName = 'abc';
        string payload = payloaddata();
        Test.startTest();
        SRV_CRM_Field_History serviceInstance = SRV_CRM_Field_History.getInstance(objectName);
        serviceInstance.saveFieldHistories((WSC_CRM_Field_History.RequestPayload)(JSON.Deserialize(payload,WSC_CRM_Field_History.RequestPayload.class)));
        Test.stopTest();
    }
     /**
    * This method is used for asynchronous saving of field histories.
    */
    @IsTest
    private static void testAsyncSaveFieldHistoriescallout() {
        string payload = payloaddata();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        System.enqueueJob(new QUE_CRM_AsyncFieldHistory(payload));
        Test.stopTest();
    }
    
    //Inner class to mock HTTP Response
    public class MockResponseGenerator implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            string payload = payloaddata();
            res.setHeader('Location','global');
            res.setBody(payload);
            res.setStatusCode(200);
            return res;
        }
    }
    
    /**
    * This method send mail when exception occurs.
    */
    
    @isTest
    static void testSendEmailOnException(){
        try {
            Integer i = 1 / 0; 
        } catch(Exception ex) {
            Test.startTest();
            SRV_CRM_Field_History.SendEmailOnException(ex);
            Test.stopTest();
        }
    }
    
    // Payload Record Creation
    private static string payloaddata(){
        String objectName = 'abc__c';
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
    static void testGetRecordName() {
        abc__c abc = [Select Id, Name From abc__c LIMIT 1];
        Test.startTest();
        String recordName = SRV_CRM_Field_History.getRecordIdName(abc.Id);
        Test.stopTest(); 
        System.assertEquals(abc.Name, recordName);
    }
}