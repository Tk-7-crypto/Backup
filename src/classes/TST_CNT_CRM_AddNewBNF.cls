/**
 * This test class is used to test all methods in controller CNT_CRM_AddNewBNF.
 * version : 1.0
 */
@isTest
private class TST_CNT_CRM_AddNewBNF {

    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
    	insert acc;
        List<Contact> contactList = UTL_TestData.createContacts(acc.Id, 6);
        insert contactList;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        List<String> roleList = new List<String>();
        roleList.add('Ship To & Bill To');
        roleList.add('Bill To Primary');
        roleList.add('Ship To Primary');
        roleList.add('Cover Sheet Primary');
        roleList.add('Carbon Copy Primary');
        roleList.add('Second Copy');
        List<OpportunityContactRole> contactRoleList = new List<OpportunityContactRole>();
        for(Integer i = 0; i < 6; i++) {
            OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(contactList[i].Id, opp.Id);
            contactRole.role = roleList[i];
            contactRoleList.add(contactRole);
        }
        insert contactRoleList;
    }
    
    /**
     * test method
     */
    @isTest
    static void test1() {
        PermissionSetAssignment pa = UTL_TestData.createPermissionSetAssignmentRecord('BNF_Non_MDM_User', UserInfo.getUserId());
        insert pa;
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
            PageReference pageRef = Page.VFP_CRM_AddNewBNF;
            Test.setCurrentPage(pageRef);
            System.currentPageReference().getParameters().put('id', opp.Id);
        	CNT_CRM_AddNewBNF newBNF = new CNT_CRM_AddNewBNF();
        Test.stopTest();
    }
}