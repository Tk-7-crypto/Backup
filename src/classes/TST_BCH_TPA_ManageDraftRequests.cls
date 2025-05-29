/**
* This class contains unit tests for validating the behavior of Scheduler_ToUpdateProject class
**/
@isTest(seeAllData=false)
public class TST_BCH_TPA_ManageDraftRequests {
    @testSetup
    static void setup() {
        
        UTL_TPA_SetupTestData.createAMASetting();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        UTL_TPA_SetupTestData.createTPASettingsData();
        
        Address__c TestAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test_ Account',9999);
        Contact contact =  UTL_TPA_SetupTestData.getTestContact(TestAccount);
        
        TPA_Request__c tpaRequest = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(TestAccount.Id);
        TPA_Request__c TestAgreement;
        
        
        /*List<TPA_Request__c> ListAgg = [Select id,Name  From TPA_Request__c
                                                   where Name like 'TestAgreement'  LIMIT 1];
        
        if(ListAgg.size() == 0)
        {
            TestAgreement = UTL_TPA_SetupTestData.gettestAgreement(tpaRequest.id);
            insert TestAgreement;
        }
        else
        {
            TestAgreement = ListAgg[0];
        }*/
        
        tpaRequest = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(TestAccount.Id);
        tpaRequest.Request_Status__c = 'Client Draft';
        tpaRequest.Client_Address__c = TestAccount.Id;
        update tpaRequest;
    }
    
    /**
  * Test method to test Schedular
  **/
    
    private static testmethod void testExecute()
    {
        Test.startTest();
        BCH_TPA_ManageDraftRequests batchObj = new BCH_TPA_ManageDraftRequests();
        Database.executebatch(batchObj, 2);

        Test.stopTest();
    }
    
}