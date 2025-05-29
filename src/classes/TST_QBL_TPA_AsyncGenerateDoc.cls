@isTest(seeAllData = false)
public class TST_QBL_TPA_AsyncGenerateDoc { 
    private static TPA_Request__c tpaRequest1;
    private static Contact tpaContact;
    private static Address__c testClientAccount;
    private static Address__c testAccount;
    public static testMethod void testQBL_TPA_AsyncGenerateDoc()
    {
        UTL_TPA_SetupTestData.createTPASettingData();
        UTL_TPA_SetupTestData.createAMASetting();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        QBL_TPA_AsyncGenerateDoc queuableObject = new QBL_TPA_AsyncGenerateDoc();
        TPA_Request__c objTpaReq = UTL_TPA_SetupTestData.queryTPARequest();
        queuableObject.requestId = objTpaReq.id ;
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
        tpaRequest1.Data_Access_Start_Date__c = todayDate.addDays(-5);
        tpaRequest1.Data_Access_End_Date__c = todayDate.addDays(-3);
        update tpaRequest1;
        
    }
    
}