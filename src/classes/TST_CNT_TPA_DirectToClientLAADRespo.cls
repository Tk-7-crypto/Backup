/**
 * Name: CNT_TPA_DirectToClientLAADRespo
 * Author Name: Rajendra Prakash Gupta
 * Date Created: 20 JUN 2016
 * Description: Test Class for CNT_TPA_DirectToClient_LAAD_ResponseTemp class
**/
@isTest
private class TST_CNT_TPA_DirectToClientLAADRespo {

    @TestSetup
    static void setupTestData() {
        UTL_TPA_SetupTestData.createTPASettingData();
        UTL_TPA_SetupTestData.createCrossWalkData();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        //Create Account
        Account acc = new Account(Name = 'Test acc', CurrencyIsoCode = 'USD', Region_Territory__c = 'China', BillingStreet = 'test1', BillingCity = 'test1', BillingCountry = 'test1', BillingPostalCode = 'test1', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acc;
        
        //Create Address
        Address__c testAddress = new Address__c(Name = 'Test Account', recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId, CurrencyIsoCode = 'USD', Account__c = acc.Id, Industry__c = 'Biotech', Vendor_Tier__c = 'Y', Is_Payment_Risk__c = true, Vendor_Registration_Number__c = 9999, is_TPA_Account__c=true, Street__c = 'test', City__c = 'test', Country__c = 'test', PostalCode__c = 'test');
        insert testAddress;

        //Creating Contact
        Contact  con = new Contact(FirstName = 'TestFirstName', LastName = 'Test Contact', Email = 'sunny.bansal@metacube.com', AccountId = acc.id);
        insert con;
        
        TPA_Request__c tpaRequest = UTL_TPA_SetupTestData.getTPARequest();
        TPA_Agreement_Additional_Field__c tpaAdditionalFieldObj = UTL_TPA_SetupTestData.getTPAAgreementAdditionalFieldObj(tpaRequest);
        
    }
    
    static testMethod void saveLAADResponseforClientTest() {
        
        TPA_Agreement_Additional_Field__c tpaAdditionalFieldObj = [Select Id, Related_TPA_Request__c,Related_TPA_Request__r.id,Related_TPA_Request__r.Agreement_Name__c from TPA_Agreement_Additional_Field__c];
        CNT_TPA_DirectToClientLAADRespo.requestID = tpaAdditionalFieldObj.Related_TPA_Request__c;
        
        TPA_Text_Editor__c textEditor = new TPA_Text_Editor__c(Content__c = 'test',  Page_Title__c = 'Shutdown Message', Is_Active__c = true, Page_Name__c = 'test');
        insert textEditor;
        
        String argParam = JSON.serialize(tpaAdditionalFieldObj);
        
        CNT_TPA_DirectToClientLAADRespo.saveLAADResponseforClient(argParam);
        
        CNT_TPA_DirectToClientLAADRespo controller = new CNT_TPA_DirectToClientLAADRespo();
        CNT_TPA_DirectToClientLAADRespo.generateDocument(''+ tpaAdditionalFieldObj.Related_TPA_Request__r.id, tpaAdditionalFieldObj.Related_TPA_Request__r.Agreement_Name__c);
        controller.getPrintView();
        controller.getWordStyle();
        String message = controller.Message;
        String agrFieldDetail = controller.agreementAdditionalFieldDetailAsString;
        String ProfileName = CNT_TPA_DirectToClientLAADRespo.currentUserProfileName;
        String CommunityURL = CNT_TPA_DirectToClientLAADRespo.tpaCommunityUrl;
    }
}