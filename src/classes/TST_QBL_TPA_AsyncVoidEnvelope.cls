@isTest(seeAllData = false)
public class TST_QBL_TPA_AsyncVoidEnvelope {
    private static TPA_Request__c tpaRequest1;
    private static Contact tpaContact;
    private static Address__c testClientAccount;
    private static Address__c testAccount;
    public static testMethod void testQBL_TPA_AsyncVoidEnvelope(){
        QBL_TPA_AsyncVoidEnvelope queuableObject = new QBL_TPA_AsyncVoidEnvelope();
        TPA_Request__c objTpaReq = UTL_TPA_SetupTestData.queryTPARequest();
        queuableObject.requestIds = new Set<Id>{objTpaReq.id} ;
        Test.startTest();
        System.enqueueJob(queuableObject);
        Test.stopTest();
    }
    
    @testSetup
    public static void setupTestData() {        
        Date todayDate = Date.today();        
        testAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test Account',1111);  
        testClientAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test Client Account',9999);
        tpaContact = UTL_TPA_SetupTestData.getTestContact(testAccount); 
        tpaRequest1 = UTL_TPA_SetupTestData.CreateTestRequest(testClientAccount.id, testAccount.Id );
    }
}