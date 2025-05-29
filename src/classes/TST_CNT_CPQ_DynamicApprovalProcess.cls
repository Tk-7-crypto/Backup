@isTest
public class TST_CNT_CPQ_DynamicApprovalProcess {
    @TestSetup
    static void dataSetup() {
        Id userId = userInfo.getUserId();
        
        Criteria_Matrix__c apm = new Criteria_Matrix__c(
            Object_Name__c = 'Quote__c',
            Field_Name__c = 'Contracting_Country__c',
            Condition__c = 'In',
            Order__c = 1,
            Approval_Matrix_Field_Name__c = 'Country__c',
            Field_Type__c = 'country'
        );
        insert apm;
        
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Opportunity opp= UTL_TestData.createOpportunity(acc.id);
        opp.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        opp.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        opp.CurrencyIsoCode = CON_CPQ.USD;
        opp.Legacy_Quintiles_Opportunity_Number__c = 'MVP123';
        insert opp;
        
        Quote__c quote = new Quote__c(
            Approval_Stage__c = 'Finalized',
            Related_Opportunity__c = opp.Id,
            Pricing_Tools__c = CON_CPQ.Complete_Consent,
            GBU__c = CON_CPQ.GBU_DPS,
            Related_Account__c = acc.Id,
            Contracting_Country__c  = 'India'
        );
        insert quote;
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod = TST_TestGeneratorClass.buildTestProduct('COMPLETE CONSENT LICENSES', CON_CPQ.BUNDLE, 'US_DD_STUDLIC', '', '');       
        prod.CanUseRevenueSchedule = true;
        prod.Billing_System__c = CON_CPQ.SAP;
        prodList.add(prod);
        
        Product2 prod3 = TST_TestGeneratorClass.buildTestProduct('Method Development', CON_CPQ.OPTION, 'Q_111415', '', '');
        prod3.CanUseRevenueSchedule = true;
        prod3.Billing_System__c = CON_CPQ.SAP;
        prodList.add(prod3);
        insert prodList;
        
        List<Quote_Line_Item__c> quoteLineItemList = new List<Quote_Line_Item__c>();
        Quote_Line_Item__c testQLI = UTL_TestData.createIqviaQuoteLineItem(quote.Id, CON_CPQ.COMPLETE_CONSENT, false);
        testQLI.Bundle_Product__c = prod.Id;
        testQLI.BasePrice__c = 100;
        testQLI.Quantity__c = 1;
        testQLI.Country__c = CON_CPQ.USA;
        testQLI.Pathway__c = CON_CPQ.CONGA_PATHWAY;
        testQLI.Start_Date__c = Date.today();
        testQLI.End_Date__c = Date.Today().addMonths(3);
        quoteLineItemList.add(testQLI);
        Quote_Line_Item__c testQLI1 = UTL_TestData.createIqviaQuoteLineItem(quote.Id, CON_CPQ.COMPLETE_CONSENT, false);
        testQLI1.Option_Product__c = prod3.Id;
        testQLI1.BasePrice__c = 200;
        testQLI1.Include_In_Summary__c = true;
        testQLI1.Quantity__c = 1;
        testQLI1.Country__c = CON_CPQ.USA;
        testQLI1.Pathway__c = CON_CPQ.CONGA_PATHWAY;
        quoteLineItemList.add(testQLI1);
        insert quoteLineItemList;
        
        List<Approval_Matrix__c> approvalMatrixList = new List<Approval_Matrix__c>();
        Approval_Matrix__c approvalMatrix = new Approval_Matrix__c(
            Object_Name__c = 'Quote__c',
            levels__c = 'Level 1',
            priority__c = 1,
            Min_Amount__c = 200,
            Approver_1__c = userId,
            Approver_2__c = userId,
            Approver_3__c = userId,
            Approver_4__c = userId,
            Approver_5__c = userId,
            Notifier_1__c = 'test@gmail.com',
            Notifier_2__c = 'test@gmail.com',
            Notifier_3__c = 'test@gmail.com',
            Notifier_4__c = 'test@gmail.com',
            Notifier_5__c = 'test@gmail.com',
            Approve_On_First_Response__c = false,
            Auto_Approve__c = false,
            Track_Name__c = CON_CPQ.CPQ,
            Process_Type__c = CON_CPQ.APPROVAL_PROCESS,
            Country__c = 'India'
        );
        approvalMatrixList.add(approvalMatrix);
        
        Approval_Matrix__c approvalMatrix2 = new Approval_Matrix__c(
            Object_Name__c = 'Quote__c',
            levels__c = 'Level 1',
            priority__c = 2,
            Min_Amount__c = 200,
            Notifier_1__c = 'test@gmail.com',
            Notifier_2__c = 'test@gmail.com',
            Notifier_3__c = 'test@gmail.com',
            Notifier_4__c = 'test@gmail.com',
            Notifier_5__c = 'test@gmail.com',
            Approve_On_First_Response__c = false,
            Auto_Approve__c = true,
            Track_Name__c = CON_CPQ.CPQ,
            Process_Type__c = CON_CPQ.APPROVAL_PROCESS
        );
        approvalMatrixList.add(approvalMatrix2);
        
        Approval_Matrix__c approvalMatrix3 = new Approval_Matrix__c(
            Object_Name__c = 'Quote__c',
            levels__c = 'Level 2',
            priority__c = 3,
            Min_Amount__c = 200,
            Approver_1__c = userId,
            Approver_2__c = userId,
            Approver_3__c = userId,
            Approver_4__c = userId,
            Approver_5__c = userId,
            Notifier_1__c = 'test@gmail.com',
            Notifier_2__c = 'test@gmail.com',
            Notifier_3__c = 'test@gmail.com',
            Notifier_4__c = 'test@gmail.com',
            Notifier_5__c = 'test@gmail.com',
            Approve_On_First_Response__c = false,
            Auto_Approve__c = false,
            Track_Name__c = CON_CPQ.CPQ,
            Process_Type__c = CON_CPQ.APPROVAL_PROCESS
        );
        approvalMatrixList.add(approvalMatrix3);
        
        insert approvalMatrixList;
    }
    
    @isTest
    static void testGetApprovers() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        
        Test.startTest();
            String result = CNT_CPQ_DynamicApprovalProcess.getApprovers(quote.Id, 'Quote__c', true);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Something went wrong');
    }
    
    @isTest
    static void testSubmitApprovalRequest() {
        Quote__c quote = [SELECT Id, TotalAmount__c FROM Quote__c LIMIT 1];
        String response = CNT_CPQ_DynamicApprovalProcess.getApprovers(quote.Id, 'Quote__c', true);
        
        Test.startTest();
            String result = CNT_CPQ_DynamicApprovalProcess.submitApprovalRequest(quote.Id, 'Quote__c', response, null);
        Test.stopTest();
        
        Assert.areEqual(result, 'Success', 'result should be Success');
    }
    
    @isTest
    static void testApproveProcessWorkItemRequest() {
        Quote__c quote = [SELECT Id, Approval_Stage__c, TotalAmount__c, Priority__c, Approver_Level__c, Related_Opportunity__r.name, Opportunity_Number__c FROM Quote__c LIMIT 1];
        String response = CNT_CPQ_DynamicApprovalProcess.getApprovers(quote.Id, 'Quote__c', true);
        CNT_CPQ_DynamicApprovalProcess.submitApprovalRequest(quote.Id, 'Quote__c', response, null);
        quote = [SELECT Id, Approval_Stage__c, TotalAmount__c, Priority__c, Approver_Level__c, Related_Opportunity__r.name, Opportunity_Number__c FROM Quote__c LIMIT 1];
        
        Test.startTest();
            String result = CNT_CPQ_DynamicApprovalProcess.approveProcessWorkItemRequest(quote.Id, 'Approve', 'Quote__c', response);
            CNT_CPQ_DynamicApprovalProcess.requestApprovedAndReject(quote.Id, 'Approved', 'Approve');
            CNT_CPQ_DynamicApprovalProcess.updateNextApprovalStep(new List<sobject>{quote}, 'Quote__c', new Map<Id, Quote__c>{quote.Id => quote});
            CNT_CPQ_DynamicApprovalProcess.checkForAutoApproval(new List<sobject>{quote}, 'Quote__c', new Map<Id, Quote__c>{quote.Id => quote});
        Test.stopTest();
        
        Assert.areEqual(result, 'Approved', 'result should be Approved');
    }
    
    @isTest
    static void testRejectProcessWorkItemRequest() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        String response = CNT_CPQ_DynamicApprovalProcess.getApprovers(quote.Id, 'Quote__c', true);
        CNT_CPQ_DynamicApprovalProcess.submitApprovalRequest(quote.Id, 'Quote__c', response, null);
        
        Test.startTest();
            String result = CNT_CPQ_DynamicApprovalProcess.rejectProcessWorkItemRequest(quote.Id, 'Reject');
        Test.stopTest();
        
        Assert.areEqual(result, 'Rejected', 'result should be Rejected');
    }

    @isTest
    static void testSendEmail() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        Test.startTest();
        	CNT_CPQ_DynamicApprovalProcess.sendEmail(new Set<Id>{userInfo.getUserId()}, quote, CON_CPQ.IQVIA_QUOTE_OBJECT_API_NAME, CON_CPQ.CPQ_05_SEND_EMAIL, 'Test', 'Test');
        Test.stopTest();
        List<Workflow_Email_Record__c> wer = [SELECT Id FROM Workflow_Email_Record__c];
        Assert.areEqual(wer.size() > 0, true, 'Workflow Email Record should have been created');
    }
    
    @isTest
    static void testSendEmailToOwner() {  
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id,Opportunity_Number__c,Name FROM Opportunity LIMIT 1];
        Quote__c quote = new Quote__c(
            Approval_Stage__c = 'Finalized',
            Related_Opportunity__c = opp.Id,
            Pricing_Tools__c = CON_CPQ.EMEA,
            GBU__c = CON_CPQ.RECORD_TYPE_TECH_SOLUTION,
            Related_Account__c = acc.Id,
            Contracting_Country__c  = 'India'
        );
            
        insert quote;
        
        Test.startTest();
        	CNT_CPQ_DynamicApprovalProcess.sendEmailToOwner(quote, 'Test Rejected');
        Test.stopTest();
        List<Workflow_Email_Record__c> wer = [SELECT Id FROM Workflow_Email_Record__c];
        Assert.areEqual(wer.size() > 0, true, 'Workflow Email Record should have been created');    
  }
  
    @isTest
    static void checkMsaFieldOnQuote(){
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        String url = 'https://test123.com';
        Id quoteId = quote.Id;
        Boolean isHistoricalOrMsaDiscountReason = true;
        Test.startTest();
        CNT_CPQ_DynamicApprovalProcess.updateMsaDiscountReasonOnQuote(quoteId,isHistoricalOrMsaDiscountReason,url);
        Test.stopTest();
        Quote__c quoteRecord = [SELECT Id, Is_Msa_Or_Historical_Discount_Reason__c FROM Quote__c WHERE Id = :quoteId ];
        System.assertEquals(true,quoteRecord.Is_Msa_Or_Historical_Discount_Reason__c, 'MSA Disount Reason Not Updated' );
    }
    @isTest
    public static void testDeleteUploadedFiles() {
        Test.startTest();
        ContentVersion file = new ContentVersion();
        file.Title = 'Test File';
        file.PathOnClient = 'TestFile.pdf';
        file.VersionData = Blob.valueOf('Sample data');
        file.IsMajorVersion = true;
        insert file;
        ContentVersion doc = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :file.Id LIMIT 1];
        List<String> fileIds = new List<String>{ doc.ContentDocumentId };
        CNT_CPQ_DynamicApprovalProcess.deleteUploadedFiles(fileIds);
        List<ContentDocument> remainingFiles = [SELECT Id FROM ContentDocument WHERE Id IN :fileIds];
        System.assertEquals(0, remainingFiles.size(), 'Files should be deleted successfully.');
        Test.stopTest();
    }
}
