@isTest(seeAllData = false)
public class TST_CNT_TPA_CODescisionTable {
    @isTest
    public static void testGetRelatedComList(){
        Test.startTest();
        TPA_Request__c testRequest = UTL_TPA_SetupTestData.getTestTPARequest();
        insert testRequest;
        system.debug(CNT_TPA_CODescisionTable.tpaCommunityUrl);
        system.debug(CNT_TPA_CODescisionTable.currentLoggedInUser);
        system.debug(CNT_TPA_CODescisionTable.currentUserProfileName);
        List<TPA_Commercial_Review__c> test1 = CNT_TPA_CODescisionTable.getRelatedComList(null,testRequest.id, 'CSubmit', 'rr');
        CNT_TPA_CODescisionTable testObj = new CNT_TPA_CODescisionTable();
        PageReference testPage = testobj.requestValidateOnLoad(); 
        Test.stopTest();
    } 
}