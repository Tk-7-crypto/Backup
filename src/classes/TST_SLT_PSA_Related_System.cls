/*
 * Version       : 1.0
 * Description   : Test Class for SLT_PSA_Related_System
 */
@isTest
private class TST_SLT_PSA_Related_System 
{
	@testSetup
    static void dataSetup() 
    {
        PSA_Related_System__c prs = new PSA_Related_System__c(Type__c='Test Type',System_Name__c='Test System',Hosted_By__c='IQVIA');
        insert prs;
    }
    
    @isTest
    static void testGetSObjectFieldList() {
        //setupTestData();
        PSA_Related_System__c prs = [Select Id,Name,Type__c,System_Name__c,Hosted_By__c from PSA_Related_System__c limit 1];
        Test.startTest();
        List<Schema.SObjectFIeld> fields = new SLT_PSA_Related_System(true,true).getSObjectFieldList();
        Test.stopTest();

        System.assertNotEquals(0,fields.size());
    }

    @isTest 
    static void testGetAllPSARelatedSystems(){
        //setupTestData();
		PSA_Related_System__c prs = [Select Id,Name,Type__c,System_Name__c,Hosted_By__c from PSA_Related_System__c limit 1];
        Test.startTest();
        List<PSA_Related_System__c> results = new SLT_PSA_Related_System(false).getAllPSARelatedSystems();
        Test.stopTest();

        System.assertEquals(1,results.size());
        System.assertEquals('Test Type',results[0].Type__c);
        System.assertEquals('Test System',results[0].System_Name__c);
        System.assertEquals('IQVIA',results[0].Hosted_By__c);
    }

    /*
    static PSA_Related_System__c prs;
    static void setupTestData(){
        prs = new PSA_Related_System__c(Type__c='Test Type',System_Name__c='Test System',Hosted_By__c='IQVIA');
        insert prs;
    }
	*/
}