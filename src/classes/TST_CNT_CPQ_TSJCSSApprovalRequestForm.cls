@IsTest
private class TST_CNT_CPQ_TSJCSSApprovalRequestForm {

    /**
    * This method used to set up testdata
    */
    @TestSetup
    static void dataSetup() {
        Account account = UTL_OCE_TestData.createaccount();
        insert account;
        Opportunity opportunity = UTL_OCE_TestData.createOpportunity(account.Id);
        insert opportunity;
    }

    @IsTest
    static void testSubmitForCSSApproval() {
        Account account = [SELECT Id FROM Account Limit 1];
        
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        
        RecordType recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = :CON_CPQ.TECH_SOLUTION 
                                  AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];
        
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.createQuote();
        proposal.Apttus_Proposal__Account__c = account.Id;
        proposal.RecordTypeId = recordType.Id;
        proposal.Apttus_Proposal__Opportunity__c = opportunity.Id;
        proposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.FINALIZED;
        proposal.Select_Pricing_Tool__c = CON_CPQ.TS_JAPAN;
        insert proposal;
        
        // Create Proposal Line Items
        Product2 product = UTL_TestData.createProduct();
        Apttus_Proposal__Proposal_Line_Item__c lineItem = UTL_TestData.createProposalLineItem(proposal.Id, product.Id);
        insert lineItem;
        
        Profile p = [select id from profile where name='System administrator'];
        User u = new User (
            alias               = 'testUser',
            email               = 'testjapanuser@metacube.com',
            emailencodingkey    = 'UTF-8', 
            lastname            = 'Testing',
            languagelocalekey   = 'en_US',
            localesidkey        = 'en_US',
            profileid           = p.Id,
            timezonesidkey      = 'America/Los_Angeles', 
            username            = 'testjapanuser@testorg.com',
            IsActive            = true,
            Change_Request_Description__c = 'test',
            Change_Request_Ticket_Number__c ='test description',
            EmployeeNumber = '090909091'
        );
        insert u ;
        
        CNT_CPQ_TSJapanCSSApprovalRequestForm.getCSSApprovers();
        CNT_CPQ_TSJapanCSSApprovalRequestForm.ProposalDetails proposalObj = CNT_CPQ_TSJapanCSSApprovalRequestForm.getProposalWithLineItems(proposal.Id);
        
        System.assertEquals(proposal.Id, proposalObj.proposalSObject.Id);
        
        CNT_CPQ_TSJapanCSSApprovalRequestForm.ApprovalDetailsWrapper approvalDetails = new CNT_CPQ_TSJapanCSSApprovalRequestForm.ApprovalDetailsWrapper();
        
        system.runAs(u){
            approvalDetails.proposalId = proposal.Id;
            approvalDetails.approvalUserEmail = u.Email;
            approvalDetails.subject = 'CSS Approval Request';
            approvalDetails.templateBody = 'Test Email Body';
            
            Test.startTest();
            CNT_CPQ_TSJapanCSSApprovalRequestForm.submitForCSSApproval(JSON.serialize(approvalDetails));
            Test.stopTest();
        }
        
        // Verify Final_Review_Call_Notes__c of Proposal is updated with templateBody
        proposal = [Select Final_Review_Call_Notes__c, Is_Strategy_Call_Required__c, MedDRA_Classification__c From Apttus_Proposal__Proposal__c Where Id =: proposal.Id];
        System.assertEquals(approvalDetails.templateBody, proposal.Final_Review_Call_Notes__c);
        
        // Verify Is_Strategy_Call_Required__c is set to true as Approver user and submitter user are same
        System.assertEquals(true, proposal.Is_Strategy_Call_Required__c);
        
        // Verify Approver name
        System.assertEquals(u.lastname, proposal.MedDRA_Classification__c);
    }
}