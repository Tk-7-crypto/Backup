/*
 * Version       : 1.0
 * Description   : Test Class for SRV_CRM_OpportunityTeamMember
 */
@isTest
private class TST_SRV_CRM_OpportunityTeamMember {
    
    /**
     * This method is used to setup data for all methods.
     */
    @testSetup
    static void dataSetup() {
        List<User> user = UTL_TestData.createUser('System Administrator', 1);
        insert user;
        
        Account account = UTL_TestData.createAccount();
        insert account;
        
        Opportunity opp = UTL_TestData.createOpportunity(account.id);
        insert opp;
        
        OpportunityTeamMember oppTeamMember = UTL_TestData.createOpportunityTeamMember(opp.id, user[0].id);
        insert oppTeamMember;
        
        user = UTL_TestData.createUser('Sales User', 1);
        insert user;
        
    }
    
    /**
    * test method to update Opportunity Team Member
    */  
    static testmethod void testUpdateOpportunityTeamMember() {
        List<OpportunityTeamMember> oppTeamMemberList = [SELECT Id, TeamMemberRole FROM OpportunityTeamMember WHERE TeamMemberRole ='Account Director'];
        System.assertEquals(1, oppTeamMemberList.size());
        oppTeamMemberList[0].TeamMemberRole = 'Alliance Manager';
        Test.startTest();
        try{
            SRV_CRM_OpportunityTeamMember.addOpportunityTeamMember(oppTeamMemberList);
        } catch(Exception ex) {
            System.assertEquals('SRV_CRM_OpportunityTeamMember.OpportunityTeamMemberServiceException', ex.getTypeName());  
        }
        oppTeamMemberList = [SELECT Id, TeamMemberRole FROM OpportunityTeamMember WHERE TeamMemberRole ='Account Director'];
        System.assertEquals(0, oppTeamMemberList.size());
        Test.stopTest();
    }
    
    /**
    * test method to add Opportunity Team Member
    */  
    static testmethod void testAddOpportunityTeamMember() {
        List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
        List<User> userList = [SELECT Id FROM User WHERE LastName = 'lastName123' AND Profile.Name = 'Sales User'];
        List<OpportunityTeamMember> oppTeamMemberList = new List<OpportunityTeamMember>();
        OpportunityTeamMember oppTeamMember = UTL_TestData.createOpportunityTeamMember(opportunityList[0].id, userList[0].id);
        oppTeamMemberList.add(oppTeamMember);
        try{
            SRV_CRM_OpportunityTeamMember.addOpportunityTeamMember(oppTeamMemberList);
        } catch(Exception ex) {
            System.assertEquals('SRV_CRM_OpportunityTeamMember.OpportunityTeamMemberServiceException', ex.getTypeName());  
        }
        oppTeamMemberList = [SELECT Id, TeamMemberRole FROM OpportunityTeamMember];
        System.assertEquals(3, oppTeamMemberList.size());
        oppTeamMemberList = [SELECT Id FROM OpportunityTeamMember];
    }
    
    /**
    * test method to add Opportunity Team Member With Exception
    */  
    static testmethod void testAddOpportunityTeamMemberException() {
        List<OpportunityTeamMember> oppTeamMemberList = new List<OpportunityTeamMember>();
        Test.startTest();
        try {
            oppTeamMemberList.add(new OpportunityTeamMember(TeamMemberRole ='Account Director'));
            SRV_CRM_OpportunityTeamMember.addOpportunityTeamMember(oppTeamMemberList);
        } catch(Exception ex) {
            System.assertEquals('SRV_CRM_OpportunityTeamMember.OpportunityTeamMemberServiceException', ex.getTypeName());
        }
        Test.stopTest();
    }
    
    /**
     * test method to delete Opportunity Team Member
     */
    static testmethod void testDeleteOpportunityTeamMember() {
        List<OpportunityTeamMember> oppTeamMemberList = [SELECT Id FROM OpportunityTeamMember WHERE TeamMemberRole = 'Account Director'];  
        Test.startTest();
        try{
            SRV_CRM_OpportunityTeamMember.deleteOpportunityTeamMember(oppTeamMemberList);
        } catch(Exception ex){  
            System.assertEquals('SRV_CRM_OpportunityTeamMember.OpportunityTeamMemberServiceException', ex.getTypeName());
        }
        oppTeamMemberList = [SELECT Id FROM OpportunityTeamMember];
        System.assertEquals(1,oppTeamMemberList.size());
        Test.stopTest();
    }
    
    /**
     * test method to delete Opportunity Team Member with Exception
     */
    static testmethod void testDeleteOpportunityTeamMemberException() {
        List<OpportunityTeamMember> oppTeamMemberList = [SELECT Id FROM OpportunityTeamMember];  
        Test.startTest(); 
        try {
            SRV_CRM_OpportunityTeamMember.deleteOpportunityTeamMember(oppTeamMemberList);
        } catch(Exception ex) {
            System.assertEquals('SRV_CRM_OpportunityTeamMember.OpportunityTeamMemberServiceException', ex.getTypeName());
        }
        Test.stopTest(); 
    }
}