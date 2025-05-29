@isTest
private class TST_CPQ_ProductAttributeCallback {
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity testOpportunity= UTL_TestData.createOpportunity(acc.Id);
        insert testOpportunity;
        Apttus_Config2__PriceList__c pl = TST_TestGeneratorClass.buildTestPriceList('Q2 Solutions - USD');
        pl.CurrencyIsoCode = 'USD';
        insert pl;
        Quote__c quote = new Quote__c();
        quote.Pricing_Tools__c = CON_CPQ.Q2_Solutions;
        quote.Approval_Stage__c = 'Draft';
        quote.GBU__c = CON_CPQ.GBU_RDS;
        quote.Related_Opportunity__c = testOpportunity.Id;
        quote.Related_Account__c = acc.Id;
        insert quote;   
             
        RecordType recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = :CON_CPQ.TECH_SOLUTION 
                                  AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.createQuote();
        proposal.Apttus_Proposal__Account__c = acc.Id;
        proposal.RecordTypeId = recordType.Id;
        proposal.IQVIA_Quote__c = quote.Id;
        proposal.Apttus_Proposal__Opportunity__c = testOpportunity.Id;
        proposal.Select_Pricing_Tool__c = CON_CPQ.Q2_Solutions; 
        proposal.CountryCode__c = 'India';
        proposal.Apttus_Proposal__Approval_Stage__c = 'Draft';
        proposal.Apttus_QPConfig__PriceListId__c = pl.Id;
        insert proposal;
        
        Product2 prod = TST_TestGeneratorClass.buildTestProduct('SL-Development Metabolism', 'Bundle', 'Q_111813', 'US', 'Go Blue');
        prod.Apttus_Config2__HasOptions__c = true;
        prod.Apttus_Config2__HasAttributes__c = true;
        insert prod;
        
        Quote_Requisites__c quoteRequisite = new Quote_Requisites__c();
        quoteRequisite.Type__c = 'Quote Sections';
        quoteRequisite.Matrix__c = 'N/A';
        quoteRequisite.Study_Number__c = '1';
        quoteRequisite.Service_Line_Product__c = prod.Id;
        quoteRequisite.Site__c = 'Indianapolis - ADME';
        quoteRequisite.Species_Global__c = 'Baboon';
        quoteRequisite.Analyte_ID__c = 'dummy Molecule';
        quoteRequisite.Clinical_Type__c = 'Clinical';
        quoteRequisite.Specimen_Type__c = CON_CPQ.PLASMA;
        quoteRequisite.Number_of_Analyte_Global__c = '2';
        quoteRequisite.Quote__c = quote.Id;
        insert quoteRequisite;     
        
        Apttus_Config2__PriceListItem__c pli = TST_TestGeneratorClass.buildTestPriceListItem(pl.Id, prod.Id, 'PLI-011');  
        insert pli;											  						  
        Apttus_Config2__ProductConfiguration__c pc = new Apttus_Config2__ProductConfiguration__c();
        pc.Apttus_QPConfig__Proposald__c = proposal.Id;
        insert pc;

        Apttus_Config2__LineItem__c lineItem = TST_TestGeneratorClass.createOptionConfigLineItem(pc.Id, 1, 1, prod.Id, prod.Id, 1, 987);
        lineItem.Apttus_Config2__HasAttributes__c = true;
        insert lineItem;
        Apttus_Config2__ConfigCustomClasses__c apttusPricingCallbackClass = new Apttus_Config2__ConfigCustomClasses__c();
        apttusPricingCallbackClass.Apttus_Config2__PricingCallbackClass__c = 'CPQ_ProductAttributeCallback';
        apttusPricingCallbackClass.Name = 'System Properties'; 
        insert apttusPricingCallbackClass;
    }

    @isTest
    static void testSetDefaults() {
        Test.startTest();
        Apttus_Proposal__Proposal__c proposal = [SELECT ID, NAME, IQVIA_Quote__c FROM Apttus_Proposal__Proposal__c LIMIT 1]; 
        Product2 prod = [SELECT ID, Apttus_Config2__Uom__c, Name, Apttus_Config2__Customizable__c, Apttus_Config2__HasDefaults__c, Apttus_Config2__HasAttributes__c, Apttus_Config2__HasOptions__c  FROM Product2 LIMIT 1];
        
        Id q2PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name =: CON_CPQ.Q2_Permission_Set].Id;
        List<PermissionSetAssignment> psaList = [SELECT Id, PermissionSet.name, PermissionSetId  from PermissionSetAssignment where permissionSet.Name =: CON_CPQ.Q2_Permission_Set AND AssigneeId =: UserInfo.getUserId() LIMIT 1];
        if (psaList.size() == 0) {
            PermissionSetAssignment permissionAssignmentObj = new PermissionSetAssignment();
            permissionAssignmentObj.AssigneeId = UserInfo.getUserId();
            permissionAssignmentObj.PermissionSetId = q2PermissionSetId;
            insert permissionAssignmentObj;
        }
        Apttus_Config2__ProductConfiguration__c PC = [SELECT Id FROM Apttus_Config2__ProductConfiguration__c LIMIT 1];
        Apttus_Config2__LineItem__c lineItem = [SELECT Id, Apttus_Config2__LineNumber__c FROM Apttus_Config2__LineItem__c LIMIT 1];
        Apttus_Config2.CallbackTester.testProductAttributeCallback(pc.Id, lineItem, new CPQ_ProductAttributeCallback());
        Test.stopTest();
    }
}