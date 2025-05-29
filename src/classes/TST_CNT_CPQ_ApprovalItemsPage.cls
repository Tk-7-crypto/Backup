@isTest
public class TST_CNT_CPQ_ApprovalItemsPage {
	@TestSetup
    static  void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.StageName = 'In-Hand';
        insert opp;
    }
    
    static testMethod void testVerifyQuoteApproval() {
        Test.startTest();	
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
        
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(proposal.Id);
        request.setSubmitterId(UserInfo.getUserId());
        request.setNextApproverIds(new List<Id>{UserInfo.getUserId()});
        Approval.ProcessResult result = Approval.process(request);
        
        ProcessInstanceWorkItem piw = [SELECT id,ProcessInstance.TargetObject.Type FROM ProcessInstanceWorkItem
                                       WHERE processInstance.TargetObjectId =:proposal.Id LIMIT 1];
        System.assertNotEquals(null, piw.Id, 'Id should not be blank');
        CNT_CPQ_ApprovalItemsPage.getApprovalData();
        Test.stopTest();
    }
    
    static testMethod void testCheckForBNF() {
        Boolean isOwnerQueue;
        Test.startTest();
        	Account account = [SELECT Id FROM Account Limit 1];
        	isOwnerQueue = CNT_CPQ_ApprovalItemsPage.checkForBNF(account.Id);
        Test.stopTest();
        System.assertNotEquals(null, isOwnerQueue, 'Id should not be null');
    }
}