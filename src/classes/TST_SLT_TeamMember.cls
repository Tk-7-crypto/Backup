/*
 * Version       : 1.0
 * Description   : This test class is used for SLT_TeamMember
 */
@isTest
private class TST_SLT_TeamMember {
    
    @testSetup
    static void dataSetup() 
    {
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        insert cont;
        
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        
        Bid_History__c clinicalBid = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        clinicalBid.Bid_Number__c = 0;
        insert clinicalBid;
        
        Apttus_Proposal__Proposal__c budgetRecord = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        
        Team_Member__c teamMember = UTL_TestData.createTeamMember(CON_CPQ.APPROVER, CON_CPQ.TSL, UserInfo.getUserId(), budgetRecord.Id);
        insert teamMember;
        
    }
    
    @IsTest
    static void testGetTeamMemberById() {
        
        Team_Member__c teamMember = [SELECT Id FROM Team_Member__c LIMIT 1];                    
        Test.startTest();
            List<Team_Member__c> teamMemberList = new SLT_TeamMember().getTeamMemberById(new Set<Id>{teamMember.Id},
                new Set<String>{CON_CPQ.ID, CON_CPQ.NAME, CON_CPQ.USER_FIELD});
        Test.stopTest();
        
        System.assert(teamMemberList.size() > 0 , 'teamMember List is not null');
    }
    
    @IsTest
    static void testGetTeamMemberByProposalIdANDMemberRole() {
        
        Team_Member__c teamMember = [SELECT Id, Member_Role__c, Proposal__c FROM Team_Member__c LIMIT 1]; 
        List<String> roleList = new List<String> {CON_CPQ.APPROVER};
            
        Test.startTest();
            List<Team_Member__c> teamMemberList = new SLT_TeamMember(false, false).getTeamMemberByProposalIdANDMemberRole(new Set<Id>{teamMember.Proposal__c},
                new Set<String>{CON_CPQ.ID, CON_CPQ.NAME, CON_CPQ.USER_FIELD}, roleList);
        Test.stopTest();
						
        System.assert(teamMemberList.size() > 0 , 'teamMember List is not null');
    }
	

    @isTest
    static void testGetTeamMemberByProposalIdANDRoleORMemberRole() {
        Team_Member__c teamMember = [SELECT Id,Proposal__c,Role_from_RR__c,Member_Role__c FROM Team_Member__c LIMIT 1];
        List<String> memberRoleList = new List<String> {CON_CPQ.FUNCTIONAL_REVIEWER};
        List<String> roleList = new List<String>{CON_CPQ.TSL, CON_CPQ.APPROVER_GROUP_PL};
        
        Test.startTest();
            List<Team_Member__c> teamMemberList = new SLT_TeamMember().getTeamMemberByProposalIdANDRoleORMemberRole(new Set<Id>{teamMember.Proposal__c},
                new Set<String>{CON_CPQ.ID, CON_CPQ.NAME, CON_CPQ.USER_FIELD}, memberRoleList, roleList );
        Test.stopTest();
        
        System.assert(teamMemberList.size() > 0 , 'teamMember List is not null');
        
    }

}