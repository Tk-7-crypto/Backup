@isTest(SeeAllData=False)
public class TST_TPA_Dyn_Off_Not_GeneratorQueue { 
    private static TPA_Request__c tpaRequest;
   // private static TPA_Request__c cpcAgreement;
    private static Contact tpaContact;
    private static Address__c testAccount;
    private static Address__c testClientAccount;
    public static testMethod void TST_TPA_Dyn_Off_Not_GeneratorQueueTest() {  
        TST_TPA_Dyn_Off_Not_GeneratorQueue instance = new TST_TPA_Dyn_Off_Not_GeneratorQueue();
        instance.setupTestData();
        Test.startTest();
        TPA_Dyn_Off_Not_GeneratorQueue tpaDynOffNotGeneratorQueueObj =  new TPA_Dyn_Off_Not_GeneratorQueue();

        tpaDynOffNotGeneratorQueueObj.reqId = tpaRequest.Id;
        tpaDynOffNotGeneratorQueueObj.vendorAccountId = tpaRequest.Service_Provider_Address__c;
        tpaDynOffNotGeneratorQueueObj.clientLanguage = tpaRequest.Client_Language__c;
        tpaDynOffNotGeneratorQueueObj.vendorLanguage = tpaRequest.Vendor_Language__c;
        tpaDynOffNotGeneratorQueueObj.reqName = tpaRequest.Name;
        tpaDynOffNotGeneratorQueueObj.ClientContactEmail = tpaRequest.ClientContact__r.email;
        tpaDynOffNotGeneratorQueueObj.isdynamicOffNotificationReqForVendor = true;
        tpaDynOffNotGeneratorQueueObj.reqStatus = tpaRequest.Request_Status__c;
		tpaDynOffNotGeneratorQueueObj.isRunTPAButtonClicked = false;
        tpaDynOffNotGeneratorQueueObj.isAckByClient = false;
        
        System.enqueueJob(tpaDynOffNotGeneratorQueueObj);
        Test.stopTest();
    }
    private void setupTestData() {
        Date todayDate = Date.today();
        testAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test vendor',1200);
        testClientAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test client',1211);
        tpaContact = UTL_TPA_SetupTestData.getTestContact(testAccount);
        tpaRequest = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(testAccount.id);
       // date strtDate = date.newInstance(2014, 1, 1);
       // cpcAgreement = UTL_TPA_SetupTestData.getAgreement(tpaRequest);
    }
    
}