@isTest
public class TST_CNT_CPQ_SendEmailProposal {

    @testSetup
    static void dataSetUp() {
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);									   
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.FirstName = UserInfo.getFirstName();
        cont.LastName = UserInfo.getLastName();
        cont.sub_group__c = 'TSL-Japan';
        cont.available_for_triage_flag__c = true;
        cont.pse__Salesforce_User__c = UserInfo.getUserId();
        insert cont;
        
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        opp.QI_Invited_to_Present__c = 'Yes';
        opp.Bid_Defense_Date__c = Date.newInstance(2020, 05, 08);
        opp.Presentation_Country__c = 'Armenia';
        opp.Presentation_Date_Status__c = 'Estimated';
        insert opp;
        
        Bid_History__c clinicalBid =  UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        clinicalBid.Bid_Number__c = 0;
        clinicalBid.Opportunity_Type__c = CON_CPQ.OPPORTUNITY_TYPE_BTS_BALLPARK;
										 
        clinicalBid.Budget_Deliverable__c= CON_CPQ.ROUNDED_BALLPARK;
        insert clinicalBid;
        
        Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);   
        budget.Total_IQVIA_Fees_BID__c = 1.0;
        budget.Approval_Status__c = CON_CPQ.APPROVAL_STATUS_FOR_FUNCTIONAL_REVIEW;
        update budget;
        
        List<Team_Member__c> proposalMemberList = UTL_TestData.createTeamMembers(budget.Id);
        insert proposalMemberList;
    }
    
    @isTest
    static void testSendMailToDSBReviewers() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        
        Test.startTest();
            CNT_CPQ_SendEmailProposal.EmailDetailsWrapper emailObj = CNT_CPQ_SendEmailProposal.getEmailTemplate(proposal.Id, '');
            emailObj.toEmailIds = CON_CPQ.TEST_EMAIL;
            CNT_CPQ_SendEmailProposal.sendMailMethod(JSON.serialize(emailObj));
        Test.stopTest();
        proposal = [SELECT Id, Apttus_Proposal__Approval_Stage__c FROM Apttus_Proposal__Proposal__c LIMIT 1];
        System.assertEquals(CON_CPQ.SUBMIT_FOR_REVIEW, proposal.Apttus_Proposal__Approval_Stage__c);
    }
    
    @isTest
    static void testSendMailToChallengeReviewers() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        
        Test.startTest();
            CNT_CPQ_SendEmailProposal.EmailDetailsWrapper emailObj = CNT_CPQ_SendEmailProposal.getEmailTemplate(proposal.Id, CON_CPQ.CHALLENGE_REVIEW);
            emailObj.toEmailIds = CON_CPQ.TEST_EMAIL;
            emailObj.bccEmailIds = CON_CPQ.TEST_EMAIL;
            CNT_CPQ_SendEmailProposal.sendMailMethod(JSON.serialize(emailObj));
            Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(1, invocations, 'Should Send Mail');
    }
    
    @isTest
    static void testSendMailForFinalSignOff() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        ContentVersion attach = new ContentVersion();       
        attach.Title = 'Unit Test Attachment'; 
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.VersionData = bodyBlob;
        attach.PathOnClient = 'abc';
        insert attach;
         
        //Get Content Documents
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(cdList.size(), 1);
        
        Test.startTest();
            CNT_CPQ_SendEmailProposal.EmailDetailsWrapper emailObj = CNT_CPQ_SendEmailProposal.getEmailTemplate(proposal.Id, CON_CPQ.SIGN_OFF);
            emailObj.toEmailIds = CON_CPQ.TEST_EMAIL;
            emailObj.ccEmailIds = CON_CPQ.TEST_EMAIL;
            emailObj.attachmentIds = new List<String> {cdList[0].Id};
            CNT_CPQ_SendEmailProposal.sendMailMethod(JSON.serialize(emailObj));
            Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        System.assertEquals(1, invocations, 'Should Send Mail');
    }
}
