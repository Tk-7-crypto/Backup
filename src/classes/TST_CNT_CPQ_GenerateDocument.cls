@IsTest
private class TST_CNT_CPQ_GenerateDocument {

    @TestSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;

        Opportunity testOpportunity= UTL_TestData.createOpportunity(acc.Id);
        insert testOpportunity;

        Quote__c quote = UTL_TestData.createIqviaQuote(acc.Id, testOpportunity.Id, null, CON_CPQ.Q2_Solutions, CON_CPQ.GBU_RDS, false);
        quote.Approval_Stage__c = CON_CPQ.DRAFT;
        insert quote;

        Apttus__APTS_Template__c template = new Apttus__APTS_Template__c();
        template.Name = 'Test Template';
        template.Apttus__Guidance__c = 'Test Template Guidance';
        template.Apttus__Category__c = 'Test Template Category';
        template.Apttus__Subcategory__c = 'Test Template Subcategory';
        template.Apttus__Type__c = 'Test';
        template.Apttus__Keywords__c = 'TEST';
        insert template;

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test Content')
        );
        insert contentVersion;

        CPQ_Settings__c cpqSetting = new CPQ_Settings__c(Name = 'Test', Client_Id__c = 'Test Id', Client_Secret__c = 'Test Seceret Id');
        insert cpqSetting;
    }

    @isTest
    static void testGenerateDocument() {
        Quote__c quote = [SELECT Id, Name, Pricing_Tools__c FROM Quote__c LIMIT 1];
        CPQ_Settings__c cpqSetting = [SELECT Client_Id__c, Client_Secret__c FROM CPQ_Settings__c LIMIT 1];
        Apttus__APTS_Template__c template = [SELECT Id, Name FROM Apttus__APTS_Template__c LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();
            String getPricingTools = CNT_CPQ_GenerateDocument.getPricingTools(quote.Id).Pricing_Tools__c;
            System.assertNotEquals(getPricingTools, null, 'Pricing tool not found.');
            String availableTemplate = CNT_CPQ_GenerateDocument.getAvailableTemplate(quote.Id, 'Quote__c', quote.Pricing_Tools__c);
            System.assertNotEquals(availableTemplate, CON_CPQ.FAILED, 'Template not found.');
            String sessionId = CNT_CPQ_GenerateDocument.getAccessToken(cpqSetting.Client_Id__c, cpqSetting.Client_Secret__c);
            String generateRequest = CNT_CPQ_GenerateDocument.generateRequest(template.Id, sessionId, quote.Id, 'Quote__c', 'PDF');
            System.assertEquals(null, generateRequest, 'The desired result should be Success.');
            CNT_CPQ_GenerateDocument.generateDocument(template.Name, quote.Id, 'Quote__c', 'PDF');
        Test.stopTest();
    }
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader(CON_CPQ.CONTENT_TYPE, CON_CPQ.APPLICATION_JSON);
            res.setStatusCode(200);
            res.setBody('{"access_token" : "mock_access_token"}');
            return res;
        }
    }

    @isTest
    static void testUpdateContentDocuments() {
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        Test.startTest();
            Boolean result = CNT_CPQ_GenerateDocument.updateContentDocuments(new List<String>{contentVersion.ContentDocumentId});
        Test.stopTest();
        Assert.areEqual(true, result, 'The desired result should be true.');
    }
}