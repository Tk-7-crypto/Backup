/*
* This class is used to test Approval Item
*/ 
@isTest
public class TST_ApprovalItems {
    
    @TestSetup
    static  void dataSetup() {
        BNFOpptyListLockedGrid.CheckValidation = false;
        User user = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];  
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.StageName = 'In-Hand';
        insert opp;
        Product2 product2 = UTL_TestData.createProduct();
        insert product2;
        PricebookEntry pbe = UTL_TestData.createPricebookEntry(product2.Id);
        insert pbe;
        OpportunityLineItem oli = UTL_TestData.createOpportunityLineItem(opp.Id, pbe.Id);
        insert oli;
        System.runAs(user){
            Group gp = UTL_TestData.createGroup('Test Group', 'Queue');
            insert gp;
            GroupMember gm = UTL_TestData.createGroupMember(gp.Id, UserInfo.getUserId());
            insert gm;
        }
    }
    
    static testMethod void testSetItemWrapperValuesWithSideBar() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        Test.startTest();
        MIBNF2__c mibnf2 = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert mibnf2;
        MIBNF_Component__c mibnfComp = UTL_TestData.createMIBNF_Comp(mibnf2, addressList);
        insert mibnfComp;
        MI_BNF_LineItem__c mIbnfLineItem = new MI_BNF_LineItem__c();
        mIbnfLineItem.MIBNF_Component__c = mibnfComp.id;
        mIbnfLineItem.Opportunity_Line_Itemid__c = oli.Id;
        insert mIbnfLineItem;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(mibnfComp.id);
        Approval.ProcessResult result = Approval.process(req1);
        System.assert(result.isSuccess());
        ProcessInstanceWorkItem piw = [SELECT id,ProcessInstance.TargetObject.Type FROM ProcessInstanceWorkItem
                                       WHERE processInstance.TargetObjectId =: mibnfComp.id LIMIT 1];
        Apexpages.currentPage().getParameters().put('isShowHeader','true');
        ApexPages.standardController controller = new ApexPages.StandardController(piw);
        ApprovalItems approvalItems = new ApprovalItems (controller);
        Test.stopTest();
    }
    
    static testMethod void testSetItemWrapperValuesWithoutSideBar() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        Test.startTest();
        MIBNF2__c mibnf2 = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert mibnf2;
        MIBNF_Component__c mibnfComp = UTL_TestData.createMIBNF_Comp(mibnf2, addressList);
        insert mibnfComp;
        MI_BNF_LineItem__c mIbnfLineItem = new MI_BNF_LineItem__c();
        mIbnfLineItem.MIBNF_Component__c = mibnfComp.id;
        mIbnfLineItem.Opportunity_Line_Itemid__c = oli.Id;
        insert mIbnfLineItem;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(mibnfComp.id);
        Approval.ProcessResult result = Approval.process(req1);
        System.assert(result.isSuccess());
        ProcessInstanceWorkItem piw = [SELECT id,ProcessInstance.TargetObject.Type FROM ProcessInstanceWorkItem
                                       WHERE processInstance.TargetObjectId =: mibnfComp.id LIMIT 1];
        Apexpages.currentPage().getParameters().put('isShowHeader','false'); 
        ApexPages.standardController controller = new ApexPages.StandardController(piw);
        ApprovalItems approvalItems = new ApprovalItems (controller);
        Test.stopTest();
    }
    
    static testMethod void testReassignPage() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        Test.startTest();
        MIBNF2__c mibnf2 = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert mibnf2;
        MIBNF_Component__c mibnfComp = UTL_TestData.createMIBNF_Comp(mibnf2, addressList);
        insert mibnfComp;
        MI_BNF_LineItem__c mIbnfLineItem = new MI_BNF_LineItem__c();
        mIbnfLineItem.MIBNF_Component__c = mibnfComp.id;
        mIbnfLineItem.Opportunity_Line_Itemid__c = oli.Id;
        insert mIbnfLineItem;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(mibnfComp.id);
        Approval.ProcessResult result = Approval.process(req1);
        ProcessInstanceWorkItem piw = [select id,ProcessInstance.TargetObject.Type, ProcessInstance.Status FROM ProcessInstanceWorkItem
                                       where processInstance.TargetObjectId =: mibnfComp.id limit 1];
        Apexpages.currentPage().getParameters().put('isShowHeader','false'); 
        ApexPages.standardController controller = new ApexPages.StandardController(piw);
        ApprovalItems ai = new ApprovalItems (controller);
        ApprovalItems.ItemWrapper itw = new ApprovalItems.ItemWrapper(piw);
        ai.checkboxAllValue = true;
        ai.getSelected();
        ai.ReassignPage();
        Test.stopTest();
    }
    
    static testMethod void testApproveRejectPage() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        Test.startTest();
        MIBNF2__c mibnf2 = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert mibnf2;
        MIBNF_Component__c mibnfComp = UTL_TestData.createMIBNF_Comp(mibnf2, addressList);
        insert mibnfComp;
        MI_BNF_LineItem__c mIbnfLineItem = new MI_BNF_LineItem__c();
        mIbnfLineItem.MIBNF_Component__c = mibnfComp.id;
        mIbnfLineItem.Opportunity_Line_Itemid__c = oli.Id;
        insert mIbnfLineItem;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(mibnfComp.id);
        Approval.ProcessResult result = Approval.process(req1);
        ProcessInstanceWorkItem piw = [select id,ProcessInstance.TargetObject.Type, ProcessInstance.Status FROM ProcessInstanceWorkItem
                                       where processInstance.TargetObjectId =: mibnfComp.id limit 1];
        Apexpages.currentPage().getParameters().put('isShowHeader','false'); 
        ApexPages.standardController controller = new ApexPages.StandardController(piw);
        ApprovalItems ai = new ApprovalItems (controller);
        ApprovalItems.ItemWrapper itw = new ApprovalItems.ItemWrapper(piw);
        ai.checkboxAllValue = true;
        ai.getSelected();
        ai.ApproveRejectPage();
        Test.stopTest();
    }
    
    static testMethod void testPagination() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        MIBNF2__c mibnf2 = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert mibnf2;
        Test.startTest();
        MIBNF_Component__c mibnfComp = UTL_TestData.createMIBNF_Comp(mibnf2, addressList);
        insert mibnfComp;
        MI_BNF_LineItem__c mIbnfLineItem = new MI_BNF_LineItem__c();
        mIbnfLineItem.MIBNF_Component__c = mibnfComp.id;
        mIbnfLineItem.Opportunity_Line_Itemid__c = oli.Id;
        insert mIbnfLineItem;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(mibnfComp.id);
        Approval.ProcessResult result = Approval.process(req1);
        ProcessInstanceWorkItem piw = [select id,ProcessInstance.TargetObject.Type, ProcessInstance.Status FROM ProcessInstanceWorkItem
                                       where processInstance.TargetObjectId =: mibnfComp.id limit 1];
        Apexpages.currentPage().getParameters().put('isShowHeader','false'); 
        ApexPages.standardController controller = new ApexPages.StandardController(piw);
        ApprovalItems ai = new ApprovalItems (controller);
        ApprovalItems.ItemWrapper itw = new ApprovalItems.ItemWrapper(piw);
        ai.itemfirstPage();
        Boolean hasNext = ai.ItemhasNext;
        Boolean hasPrevious = ai.ItemhasPrevious;
        Test.stopTest();
    }
    
    static testMethod void testNext() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        MIBNF2__c mibnf2 = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert mibnf2;
        Test.startTest();
        MIBNF_Component__c mibnfComp = UTL_TestData.createMIBNF_Comp(mibnf2, addressList);
        insert mibnfComp;
        MI_BNF_LineItem__c mIbnfLineItem = new MI_BNF_LineItem__c();
        mIbnfLineItem.MIBNF_Component__c = mibnfComp.id;
        mIbnfLineItem.Opportunity_Line_Itemid__c = oli.Id;
        insert mIbnfLineItem;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(mibnfComp.id);
        Approval.ProcessResult result = Approval.process(req1);
        ProcessInstanceWorkItem piw = [select id,ProcessInstance.TargetObject.Type, ProcessInstance.Status FROM ProcessInstanceWorkItem
                                       where processInstance.TargetObjectId =: mibnfComp.id limit 1];
        Apexpages.currentPage().getParameters().put('isShowHeader','false'); 
        ApexPages.standardController controller = new ApexPages.StandardController(piw);
        ApprovalItems ai = new ApprovalItems (controller);
        ApprovalItems.ItemWrapper itw = new ApprovalItems.ItemWrapper(piw);
        ai.itemNext();
        ai.Itemprevious();
        Test.stopTest();
    }
    
    static testMethod void testItemLastPage() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        insert addressList;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        MIBNF2__c mibnf2 = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert mibnf2;
        Test.startTest();
        MIBNF_Component__c mibnfComp = UTL_TestData.createMIBNF_Comp(mibnf2, addressList);
        insert mibnfComp;
        MI_BNF_LineItem__c mIbnfLineItem = new MI_BNF_LineItem__c();
        mIbnfLineItem.MIBNF_Component__c = mibnfComp.id;
        mIbnfLineItem.Opportunity_Line_Itemid__c = oli.Id;
        insert mIbnfLineItem;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(mibnfComp.id);
        Approval.ProcessResult result = Approval.process(req1);
        ProcessInstanceWorkItem piw = [select id,ProcessInstance.TargetObject.Type, ProcessInstance.Status FROM ProcessInstanceWorkItem
                                       where processInstance.TargetObjectId =: mibnfComp.id limit 1];
        Apexpages.currentPage().getParameters().put('isShowHeader','false'); 
        ApexPages.standardController controller = new ApexPages.StandardController(piw);
        ApprovalItems ai = new ApprovalItems (controller);
        ApprovalItems.ItemWrapper itw = new ApprovalItems.ItemWrapper(piw);
        ai.itemLastPage();
        Test.stopTest();
    } 
    
    static testMethod void testVerifyQuoteApproval() {
        Account account = [SELECT Id FROM Account Limit 1];
        
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        
        RecordType recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = :CON_CPQ.TECH_SOLUTION 
                                  AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];
        
        Test.startTest();
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
        request.setSubmitterId(UserInfo.getUserId()); // Logged in user is the submitter
        request.setNextApproverIds(new List<Id>{UserInfo.getUserId()});
        Approval.ProcessResult result = Approval.process(request);
        
        ProcessInstanceWorkItem piw = [SELECT id,ProcessInstance.TargetObject.Type FROM ProcessInstanceWorkItem
                                       WHERE processInstance.TargetObjectId =:proposal.Id LIMIT 1];
        System.assertNotEquals(null, piw.Id, 'Id should not be blank');                    
        Apexpages.currentPage().getParameters().put('isShowHeader','true');
        ApexPages.standardController controller = new ApexPages.StandardController(piw);
        ApprovalItems approvalItemsObj = new ApprovalItems (controller);
        System.assertEquals(true, approvalItemsObj.displayInfoRelatedToProposal, 'displayInfoRelatedToProposal flag should be true');
        Test.stopTest();
    }
}