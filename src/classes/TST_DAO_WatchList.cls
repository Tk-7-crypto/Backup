@isTest(seeAllData=false)
public class TST_DAO_WatchList { 
    @isTest
    static void testWatchListFunctionality() {
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test Account 1';
        insert testAccount1;
        
        Watch_List__c watchObj = UTL_TPA_SetupTestData.createWatchList(testAccount1.Id);
        watchObj.Offering__c = 'Asset 1';
        watchObj.Use__c = 'test purpose';
        insert watchObj;
        update watchObj;
    }
}