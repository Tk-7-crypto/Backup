@isTest
private class TST_RefreshPageController {
    private static date strtDate = date.newInstance(2019, 1, 1);
    public static void setUp(){
        Account testacc = new Account(Name = 'TestAccountNameForSCM1',CurrencyIsoCode = 'USD',Region_Territory__c = 'India',Industry_IMS__c = 'Biotech',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert testacc;
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        
        Opportunity testOpportunity= UTL_TestData.createOpportunity(testacc.id);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        testOpportunity.CurrencyIsoCode = CON_CPQ.USD;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c='MVP123';
        insert testOpportunity;
        
        //Id clinicalBidRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Clinical Bid').getRecordTypeId();
        
        Mulesoft_Integration_Control__c mulesoftIntegrationSettings = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getUserId());
        mulesoftIntegrationSettings.Ignore_Validation_Rules__c = true;
        upsert mulesoftIntegrationSettings;
        
        Apttus__APTS_Agreement__c clinicalBidAgreement = UTL_TestData.createAgreement();
        clinicalBidAgreement.Apttus__Related_Opportunity__c = testOpportunity.Id;
        //clinicalBidAgreement.RecordTypeId = clinicalBidRecordTypeId;
        clinicalBidAgreement.Apttus__Contract_Start_Date__c = Date.today();
        //clinicalBidAgreement.O_Term_Years__c = '3';
        insert clinicalBidAgreement;
        
        mulesoftIntegrationSettings.Ignore_Validation_Rules__c = false;
        upsert mulesoftIntegrationSettings;
    }
    @isTest
    public static void testRefresh(){
        setUp();
        Apttus__APTS_Agreement__c agree = [Select Id from Apttus__APTS_Agreement__c Limit 1];
        box__FRUP__c  box = new box__FRUP__c (box__Record_ID__c = agree.Id);
        insert box;
        ApexPages.StandardController sc = new Apexpages.Standardcontroller(agree);
        Test.startTest();
        RefreshPageController ref = new RefreshPageController(sc);
        ref.refresh();
        Test.stopTest();
    }
}