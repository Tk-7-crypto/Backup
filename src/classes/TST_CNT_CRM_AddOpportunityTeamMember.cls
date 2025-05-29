/*
 * Version       : 1.0
 * Description   : Test Class for CNT_CRM_AddOpportunityTeamMember
 */
@isTest
public class TST_CNT_CRM_AddOpportunityTeamMember {
    /**
     * This method is used to setup data for all methods.
     */
    @testSetup
    static void dataSetup() {
        String profileName = CON_CRM.SYSTEM_ADMIN_PROFILE;
        List<User> userList = UTL_TestData.createUser(profileName, 1);
        insert userList;
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
    }
    
    /**
     * test method to get field Details and add Opportunity Team Members.
     */  
    static testmethod void testGetOpportuityTeamMemberDetails() {
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        User userRecord = [SELECT id FROM user WHERE lastName = 'lastName123' limit 1];
        String recordJson = '[{"opportunityId":"'+opp.id+'","teammemberrole":"Associate Global BD - NovaQuest","opportunityaccesslevel":"Read","userid":"'+userRecord.id+'"}]';
        String fieldData = 'teammemberRole,opportunityAccessLevel,userId';
        Test.startTest();
            CNT_CRM_AddOpportunityTeamMember.getOppTeamMemberList(opp.Id);
            CNT_CRM_AddOpportunityTeamMember.getCommercialUserDetail();
            CNT_CRM_AddOpportunityTeamMember.getOppTeamMemberFieldDetail(fieldData);
            CNT_CRM_AddOpportunityTeamMember.saveOpportunityTeamMembers(recordJson, opp, true);
            List<OpportunityTeamMember> teamMemberList = [SELECT Id FROM OpportunityTeamMember where OpportunityId = : opp.id];
            String teamMemberJSONString = JSON.serialize(teamMemberList);
            try {
                CNT_CRM_AddOpportunityTeamMember.deleteOpportunityTeamMembers(teamMemberJSONString);
            } catch(System.AuraHandledException ex) {
                
            }
        Test.stopTest();
        Integer expected = 2;
        Integer actual = [SELECT Id FROM OpportunityTeamMember where OpportunityId = : opp.id].size();
        //System.assertEquals(expected, actual);
    }
    
    /**
     * test method for Exception in field details.
     */  
    static testmethod void testExceptionOnOpportunityTeamMember() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        User userRecord = [SELECT id FROM user WHERE lastName = 'lastName123' limit 1];
        String recordJson = '';
        String fieldData = '';
        Test.startTest();
        try{
        	CNT_CRM_AddOpportunityTeamMember.getOppTeamMemberFieldDetail(fieldData);
            CNT_CRM_AddOpportunityTeamMember.saveOpportunityTeamMembers(recordJson, opp, true);
        }
        catch(Exception e){
        }
        Test.stopTest();
        Integer expected = 1   ;
        Integer actual = [SELECT Id FROM OpportunityTeamMember where OpportunityId = : opp.id].size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * test method for Exception in insert of Opportunity Team Member.
     */  
    static testmethod void testExceptionOnOpportunityTeamMemberForService() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        User userRecord = [SELECT id FROM user WHERE lastName = 'lastName123' limit 1];
        String recordJson = '[{"opportunityId":"'+opp.id+'","teammemberrole":"Associate Global BD - NovaQuest","opportunityaccesslevel":"Read"}]';
        String fieldData = '';
        Test.startTest();
        try{
        	CNT_CRM_AddOpportunityTeamMember.saveOpportunityTeamMembers(recordJson, opp, true);
        }
        catch(Exception e){
        }
        Test.stopTest();
        Integer expected = 1   ;
        Integer actual = [SELECT Id FROM OpportunityTeamMember where OpportunityId = : opp.id].size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * test method for Exception in insert of Opportunity Team Member With Exception.
     */  
    static testmethod void testExceptionOnOpportunityTeamMember1() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        User userRecord = [SELECT id FROM user WHERE lastName = 'lastName123' limit 1];
        String recordJson = '[{,"teammemberrole":"Associate Global BD - NovaQuest","opportunityaccesslevel":"Read"}]';
        String fieldData = '';
        Test.startTest();
        try{
        	CNT_CRM_AddOpportunityTeamMember.saveOpportunityTeamMembers(recordJson, opp, true);
            System.assert(false);
        }
        catch(Exception e){
        }
        Test.stopTest();
    }
    
}