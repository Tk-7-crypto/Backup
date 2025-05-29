/*
 * Version       : 1.0
 * Description   : Test Class for SLT_PSA_RS_Service_Lines
 */
@isTest
private class TST_SLT_PSA_RS_Service_Lines 
{
	@testSetup
    static void dataSetup() 
    {
        PSA_Related_System__c prs = new PSA_Related_System__c(Type__c='Test Type',System_Name__c='Test System',Hosted_By__c='IQVIA');
        insert prs;
        Service_Line__c serviceLine = new Service_Line__c(Name='TestLine', Service_Line_Code__c='TST');
        insert serviceLine;
        PSA_Related_Systems_Service_Lines__c prssl = new PSA_Related_Systems_Service_Lines__c(Service_Line__c=serviceLine.Id,PSA_Related_System__c=prs.Id);
        insert prssl;
    }
    
    @isTest
    static void testGetSObjectFieldList() {
        //setupTestData();

        Test.startTest();
        List<Schema.SObjectFIeld> fields = new SLT_PSA_RS_Service_Lines(true,true).getSObjectFieldList();
        Test.stopTest();

        System.assertNotEquals(0,fields.size());
    }

    @isTest 
    static void testGetAllPSARelatedSystems(){
        //setupTestData();

        Test.startTest();
        List<PSA_Related_Systems_Service_Lines__c> results = new SLT_PSA_RS_Service_Lines(false).getAll();
        Test.stopTest();

        System.assertEquals(1,results.size());
    }

    /*
    static PSA_Related_System__c prs;
    static PSA_Related_Systems_Service_Lines__c prssl;
    static Service_Line__c serviceLine;

    static void setupTestData(){
        prs = new PSA_Related_System__c(Type__c='Test Type',System_Name__c='Test System',Hosted_By__c='IQVIA');
        insert prs;
        serviceLine = new Service_Line__c(Name='TestLine', Service_Line_Code__c='TST');
        insert serviceLine;
        prssl = new PSA_Related_Systems_Service_Lines__c(Service_Line__c=serviceLine.Id,PSA_Related_System__c=prs.Id);
        insert prssl;
    }
	*/
}