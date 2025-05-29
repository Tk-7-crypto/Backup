@isTest(SeeAllData=false)
public with sharing class TST_CNT_TPA_Additional_Terms {
	
    @TestSetup
    static void setupTestData()
    {
        Account acc =  new Account(Name = 'Test acc', CurrencyIsoCode = 'USD', Region_Territory__c = 'China', BillingStreet = 'test1', BillingCity = 'test1', BillingCountry = 'test1', BillingPostalCode = 'test1', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');//Modified by C.P.Pandey under Issue-7181
        insert acc;
        Address__c testAddrs = new Address__c(Name = 'TPA Test Acc', CurrencyIsoCode = 'USD', Account__c = acc.Id, Industry__c = 'Biotech', Vendor_Tier__c = 'Y', Is_Payment_Risk__c = true, Vendor_Registration_Number__c = 9999, is_TPA_Account__c=true, Street__c = 'test', City__c = 'test', Country__c = 'test', PostalCode__c = 'test');
        insert testAddrs;
        Contact  con = new Contact(FirstName = 'TestFirstName', LastName = 'Test Contact', Email = 'sunny.bansal@metacube.com', AccountId = acc.id);
        insert con;
        TPA_Request__c tpaRequest = new TPA_Request__c(
            OwnerId = UserInfo.getUserId(), 
            ClientContact__c = con.id, 
            Client_Language__c = 'English', 
            Data_Asset_List__c = 'AAN',
            Purpose_List__c = 'Test Purpose List', 
            IMS_Legal_Entity_List__c = 'test',
            Agreement_Number__c = '123', 
            Secondary_Data_Asset_List__c = 'Test');

        insert tpaRequest;
        
        TPA_Additional_Term__c newAdditionalTerm = new TPA_Additional_Term__c(
        	Addtional_Term__c = 'abc',
            Category__c = 'General Ad-Hoc Term',
            TPA_Request__c = tpaRequest.Id
        );
        
        insert newAdditionalTerm;
    }
    
    @isTest
    public static void saveTPAAdditionalTermsTest() {

        TPA_Request__c tpaRequest = [select id from TPA_Request__c limit 1];
        TPA_Additional_Term__c newAdditionalTermToAdd = new TPA_Additional_Term__c(
        	Addtional_Term__c = 'def',
            Category__c = 'General Ad-Hoc Term',
            TPA_Request__c = tpaRequest.Id,
            Term_Name__c = 'new test term'
        );
        Map<Id,TPA_Additional_Term__c> allAdditionalTerms ;
        
        Boolean showExhibitPage = CNT_TPA_Additional_Terms.showExhibitPage;
        CNT_TPA_Additional_Terms cnt_tpa_add = new CNT_TPA_Additional_Terms();
        String JSONAdditionalTermsAttachId = cnt_tpa_add.JSONAdditionalTermsAttachId;
        Test.StartTest();
        PageReference pageRef = Page.VFP_TPA_Additional_Terms;
        pageRef.getParameters().put('tpaRequestId', tpaRequest.Id);
        Test.setCurrentPage(pageRef);
        
        String retVal = CNT_TPA_Additional_Terms.saveRequest(JSON.Serialize(newAdditionalTermToAdd),'{"Name":"ExhibitDemoPage.pdf","mimeType":"application/pdf","body":"JVBERi0x"}',tpaRequest.Id,'New',false);
        Test.stopTest();
        
       	//System.assertEquals(2, allAdditionalTerms.size());
    } 
    
    @isTest
    public static void deleteAdditionalTermTest(){
       	TPA_Request__c tpaRequest = [select id,(select Id from TPA_Additional_Terms__r) from TPA_Request__c limit 1];
        TPA_Additional_Term__c additionalTermToDelete;
        for(TPA_Additional_Term__c additionalterm : tpaRequest.TPA_Additional_Terms__r) {
                additionalTermToDelete = additionalterm;
        }
		String termName = 'test term name';
        Map<Id,TPA_Additional_Term__c> allAdditionalTerms ;
        Test.StartTest();
        PageReference pageRef = Page.VFP_TPA_Additional_Terms;
        pageRef.getParameters().put('tpaRequestId', tpaRequest.Id);
        Test.setCurrentPage(pageRef);
        String strAllAdditionalTerms = CNT_TPA_Additional_Terms.deleteAdditionalTerm(additionalTermToDelete.Id,null,termName,tpaRequest.Id);
        Test.stopTest();
        allAdditionalTerms = (Map<Id,TPA_Additional_Term__c>)JSON.deserialize(strAllAdditionalTerms, Map<Id,TPA_Additional_Term__c>.class);
        System.assertEquals(0, allAdditionalTerms.size());
    }
    
    @isTest
    public static void getCategoryTest(){
        List<string> allCategories = new List<string>();
        allCategories.add('--None--');
        Schema.DescribeFieldResult fieldResult = TPA_Additional_Term__c.Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            allCategories.add(f.getLabel());
        }
        String primaryOfferingJson = CNT_TPA_Additional_Terms.jsonPriOfferingList;
        String jsonSecOfferingList = CNT_TPA_Additional_Terms.jsonSecOfferingList;
        allCategories.sort();
        String resultFromClass;
        Test.startTest();
        CNT_TPA_Additional_Terms a = new CNT_TPA_Additional_Terms();
        String tpaRequestJson = a.getTPARequest();
        String additionalTermsMapJson = a.getJSONAdditionalTermsMap();
        String legalEntities = CNT_TPA_Additional_Terms.jsonLegalEntityList;
        Boolean isGlobalUser = CNT_TPA_Additional_Terms.isGlobalUser;
        resultFromClass = a.getCategory();
        Test.stopTest();
        
        System.assertEquals(JSON.serialize(allCategories), resultFromClass);
    }
}