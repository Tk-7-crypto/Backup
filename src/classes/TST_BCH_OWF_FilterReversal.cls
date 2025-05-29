@isTest
public class TST_BCH_OWF_FilterReversal {
    
	@testSetup static void setupTestData()
	{
        List<User> userList = UTL_TestData.createUser('Sales User', 1);
        userList[0].IsActive = true;
        insert userList;
        Account a = UTL_TestData.createAccount();
        insert a;
        Contact c = UTL_TestData.createContact(a.Id);
        insert c;
        pse__Filter_Set__c userFilterSets = new pse__Filter_Set__c();
        userFilterSets.Name = UserInfo.getUserName() + ' Suggested Resource Filter';
        userFilterSets.pse__Feature__c = 'Resource Planner';
        userFilterSets.pse__SObject__c = 'Contact';
        insert userFilterSets;
        String value = JSON.serialize('Test User');
        pse__Filter__c newFilter = new pse__Filter__c();
        newFilter.pse__Filter_Set__c = userFilterSets.Id;
        newFilter.pse__Field__c = 'Name';
        newFilter.pse__Is_Active__c = true;
        newFilter.pse__Operator__c = 'equals';
        newFilter.pse__Value__c = '{"position":0,"containerId":"filterColumn1","includeSublevels":false,"value":['+value+']}';
        insert newFilter;          
    }
	
	
    @isTest static void testFilterReversal()
	{
        setupTestData();
        List<pse__Filter__c> filterList = [SELECT Id FROM pse__Filter__c Order by CreatedDate asc limit 10];
        Contact c = [SELECT Id, Name FROM Contact LIMIT 1];
        Set<String> cName = new Set<String>{c.Name};
        Test.startTest();
            BCH_OWF_FilterReversal filterReversal = new BCH_OWF_FilterReversal(filterList[0].id, cName);
            DataBase.executeBatch(filterReversal);
        Test.stopTest();
        
        filterList = [SELECT Id from pse__Filter__c WHERE Id =:filterList[0].id];
        System.assertEquals(0, filterList.size(),'Verifying BCH_OWF_FilterReversal Functionality');
    }    
}