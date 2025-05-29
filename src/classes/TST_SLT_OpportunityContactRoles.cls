/*
 * Version       : 1.0
 * Description   : This test class is used for Select OpportunityContactRoles
 */
@isTest
public class TST_SLT_OpportunityContactRoles {
    
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
        insert contactRole;
        
    }
	
    /**
     * This method used to Select OpportunityContactRoles by opportunity id
     */    
    @IsTest
    static void testSelectByOpportunityId() {
        Opportunity opp = [SELECT id FROM Opportunity WHERE name = 'TestOpportunity'];
        Test.startTest();
		Map<Id, OpportunityContactRole> contactRoleMap = new SLT_OpportunityContactRoles().selectByOpportunityId(new Set<Id> { opp.Id });
        List<OpportunityContactRole> contactRoleList = new SLT_OpportunityContactRoles().selectByOpportunityId(new Set<Id> { opp.Id },new Set<String>{'Id'});
        Test.stopTest();
        Integer expected = 1;
        Integer actual = contactRoleMap.size();
        System.assertEquals(expected, actual);
	}
}