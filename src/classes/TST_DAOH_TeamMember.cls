@isTest
public class TST_DAOH_TeamMember {
    private static String lastName = CON_CPQ.TEST_USER + '*' + CON_CPQ.SALES_USER;
    
    @testSetup
    static void dataSetUp() {
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        
        /*Commented under LC-11457 to deactivate approval proces
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;*/
        
        Opportunity testOpportunity = UTL_TestData.createOpportunity(testAccount.id);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        testOpportunity.CurrencyIsoCode = CON_CPQ.USD;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        insert testOpportunity;
        /*Commented under LC-11457 to deactivate approval proces
        Product2 testProduct = UTL_TestData.createProduct();
        insert testProduct;
        PricebookEntry testPricebookEntry = UTL_TestData.createPricebookEntry(testProduct.id);
        testPricebookEntry.CurrencyIsoCode = CON_CPQ.USD;
        testPricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert testPricebookEntry;*/
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        
        List<Team_Member__c> teamMemberList = UTL_TestData.createTeamMembers(budget.Id);
        insert teamMemberList;
        
        User salesUser1 = UTL_TestData.createUser(CON_CPQ.SALES_USER, 1).get(0);
        salesUser1.LastName = lastName;
        insert salesUser1;
    }
    
    @isTest
    static void testDummyMethodDaohTeamMember() {
        List<Team_Member__c> teamMember = [SELECT Id, User__c, Member_Role__c, Proposal__c FROM Team_Member__c];
        Map<Id, Team_Member__c> teamMemberMap = new Map<Id, Team_Member__c>();
        for(Team_Member__c team : teamMember) {
            teamMemberMap.put(team.Id, team);
        }
        Test.startTest();
            DAOH_TeamMember.recallOldAndSubmitProposalForNewApproval(teamMember, teamMemberMap);
            DAOH_TeamMember.recallApprovalProcessOnDeletion(teamMember);
        Test.stopTest();
    }
    
    /*Commented under LC-11457 to deactivate approval proces
    @isTest
    static void testRecallOldAndSubmitProposalForNewApproval() {
        Team_Member__c teamMember = [SELECT Id, User__c, Member_Role__c, Proposal__c FROM Team_Member__c WHERE Member_Role__c =: CON_CPQ.APPROVER LIMIT 1];
        Apttus_Proposal__Proposal__c budget = [SELECT Id, Name, Apttus_Proposal__Approval_Stage__c, Approval_Status__c FROM Apttus_Proposal__Proposal__c LIMIT 1 ];
        budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.SUBMIT_FOR_REVIEW;
        budget.Approval_Status__c = CON_CPQ.SUBMITTED_FOR_FUNCTIONAL_REVIEW;
        CNT_CPQ_BudgetWorkflowController.fireAprrovalRequest(budget.Id, UserInfo.getUserId());
        User salesUser1 = [SELECT ID, NAME, CONTACTID FROM USER WHERE LastName = :lastName LIMIT 1];
        Test.startTest();
            teamMember.User__c = salesUser1.Id;
            update teamMember;
        Test.stopTest();
        Team_Member__c updatedteamMember = [SELECT Id, User__c, Member_Role__c, Proposal__c FROM Team_Member__c WHERE Member_Role__c =: CON_CPQ.APPROVER LIMIT 1];
        System.assertEquals(updatedteamMember.User__c, salesUser1.Id, 'User updated successfully.');
    }
    
    @isTest
    static void testRecallOldAndSubmitProposalForNewApprovalWhenNoUser() {
        Account testAccount = [SELECT Id, Name FROM Account LIMIT 1];
        pse__Grp__c testGroup = [SELECT Id, Name FROM pse__Grp__c LIMIT 1];
        Team_Member__c teamMember = [SELECT Id, User__c, Member_Role__c, Proposal__c FROM Team_Member__c WHERE Member_Role__c =: CON_CPQ.APPROVER LIMIT 1];
        Apttus_Proposal__Proposal__c budget = [SELECT Id, Name, Apttus_Proposal__Approval_Stage__c, Approval_Status__c FROM Apttus_Proposal__Proposal__c LIMIT 1 ];
        budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.SUBMIT_FOR_REVIEW;
        budget.Approval_Status__c = CON_CPQ.SUBMITTED_FOR_FUNCTIONAL_REVIEW;
        Contact cont = UTL_OWF_TestData.createContact(testAccount.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = testGroup.Id;
        cont.Sub_Group__c = CON_CPQ.DSB_MW;
        cont.available_for_triage_flag__c = true;
        cont.pse__Salesforce_User__c = UserInfo.getUserId();
        insert cont;
        CNT_CPQ_BudgetWorkflowController.fireAprrovalRequest(budget.Id, UserInfo.getUserId());
        Test.startTest();
            teamMember.User__c = null;
        	teamMember.Contact__c = cont.Id;
            update teamMember;
        Test.stopTest();
        Team_Member__c updatedteamMember = [SELECT Id, User__c, Member_Role__c, Proposal__c FROM Team_Member__c WHERE Member_Role__c =: CON_CPQ.APPROVER LIMIT 1];
        System.assertEquals(updatedteamMember.User__c, null, 'User updated successfully.');
    }
    
    @isTest
    static void testRecallApprovalProcessOnDeletion() {
        Team_Member__c teamMember = [SELECT Id, User__c, Member_Role__c, Proposal__c FROM Team_Member__c WHERE Member_Role__c =: CON_CPQ.APPROVER LIMIT 1];
        Apttus_Proposal__Proposal__c budget = [SELECT Id, Name, Apttus_Proposal__Approval_Stage__c, Approval_Status__c FROM Apttus_Proposal__Proposal__c LIMIT 1 ];
        budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.SUBMIT_FOR_REVIEW;
        budget.Approval_Status__c = CON_CPQ.SUBMITTED_FOR_FUNCTIONAL_REVIEW;
        CNT_CPQ_BudgetWorkflowController.fireAprrovalRequest(budget.Id, UserInfo.getUserId());
        User salesUser1 = [SELECT ID, NAME FROM USER LIMIT 1];
        
        Test.startTest();
            teamMember.User__c = salesUser1.Id;
            delete teamMember;
        Test.stopTest();
        
        List<Team_Member__c> teamMemberList = [SELECT Id, User__c, Member_Role__c, Proposal__c FROM Team_Member__c WHERE Member_Role__c =: CON_CPQ.APPROVER Limit 1];
        System.assertEquals(teamMemberList.size() , 0, 'Team Member deleted successfully');
    }*/
    
    /*Commented under LC-10187 to remove ref of Reviewer/Final Reviewer picklist value from Team Member object
    @isTest
    static void testSendQCNotificationForDraft() {
        Team_Member__c teamMember = [SELECT Id, User__c, Member_Role__c, Proposal__c FROM Team_Member__c WHERE Member_Role__c =: CON_CPQ.QC_REVIEWER LIMIT 1];
        User salesUser1 = [SELECT ID, NAME, CONTACTID FROM USER WHERE LastName = :lastName LIMIT 1];
        Test.startTest();
            teamMember.User__c = salesUser1.Id;
            update teamMember;
        Test.stopTest();
    }
	
    @isTest
    static void testSendQCNotificationForFinal() {
        Team_Member__c teamMember = [SELECT Id, User__c, Member_Role__c, Proposal__c FROM Team_Member__c WHERE Member_Role__c =: CON_CPQ.FINAL_QC_REVIEWER LIMIT 1];
        User salesUser1 = [SELECT ID, NAME, CONTACTID FROM USER WHERE LastName = :lastName LIMIT 1];
        Test.startTest();
            teamMember.User__c = salesUser1.Id;
            update teamMember;
        Test.stopTest();
    }*/


}