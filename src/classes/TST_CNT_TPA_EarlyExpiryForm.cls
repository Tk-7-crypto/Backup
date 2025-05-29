@isTest(seeAllData = false)
public class TST_CNT_TPA_EarlyExpiryForm {
    @TestSetup 
    static void setup() {
        TPA_Request__c testRequest = UTL_TPA_SetupTestData.getTestTPARequest();
        testRequest.Client_TPA_Representative_Email__c = 'test@test.com';
        testRequest.Vendor_Contact_e_mail__c = 'test@test.in';
        testRequest.TP_Processor_Email__c = 'test@test.in';
        testRequest.Expiration_Date__c = Date.today().addDays(5);
        insert testRequest;
        insert (new AMA_Agreement_Detail__c(TPA_Request__c  = testRequest.id, Agreement_End_Date__c = Date.today().addDays(5), Current_Year_Fees__c = 1.0));
        insert (new TPA_Contact__c(Email__c = 'test@test.in', TPA_Request__c = testRequest.id ));
        insert (new TPA_Agreement_Additional_Field__c(Related_TPA_Request__c = testRequest.id));
    }
    @isTest
    public static void testEarlyExpireFormSubmission(){
        Test.startTest();
        UTL_TPA_SetuptestData.createMultilingualTemplateSettingData();
        
        insert (new TPA_Text_Editor__c(Content__c = 'test', Page_Title__c = 'Shutdown Message', Page_Name__c = 'Shutdown Message', Is_Active__c = true));
        system.debug(CNT_TPA_EarlyExpiryForm.Message);
        system.debug(CNT_TPA_EarlyExpiryForm.currentLoggedInUser);
        system.debug(CNT_TPA_EarlyExpiryForm.currentUserProfileName);
        system.debug(CNT_TPA_EarlyExpiryForm.tpaCommunityUrl);
        TPA_Request__C tpaRequest = [SELECt id FROM TPA_Request__c  LIMIT 1];
        
        PageReference pageRef = Page.VFP_TPA_EarlyExpiryForm;
        pageRef.getParameters().put('id', tpaRequest.Id);
        Test.setCurrentPage(pageRef);

        CNT_TPA_EarlyExpiryForm testObj = new CNT_TPA_EarlyExpiryForm();
        system.debug(testobj.IMSLogo);
        System.debug(testObj.getObjectTpaRequest());
        CNT_TPA_EarlyExpiryForm.onClientSubmission(  DateTime.now().addDays(2).format('yyyy-MM-dd'),testObj.getObjectTpaRequest());
        
        Test.stopTest();
    }
    
    @isTest
    public static void testExceptionsAndTestingUsers(){
        Test.startTest();
        TPA_Settings__c tpaSetting = TPA_Settings__c.getOrgDefaults();
		tpaSetting.Is_TPA_Permanent_Down__c = true;
        tpaSetting.Base_Url__c = 'test';
        tpaSetting.TPA_RequestSubmitted_Email__c = 't@t.in';
        insert tpaSetting;
        CNT_TPA_EarlyExpiryForm testObj = new CNT_TPA_EarlyExpiryForm();
        
        TPA_Request__C tpaRequest = [SELECt id FROM TPA_Request__c  LIMIT 1];

        PageReference pageRef = Page.VFP_TPA_EarlyExpiryForm;
        pageRef.getParameters().put('isQaTesting', 'true');
        pageRef.getParameters().put('id', tpaRequest.Id);

        Test.setCurrentPage(pageRef);
        CNT_TPA_EarlyExpiryForm testObj2 = new CNT_TPA_EarlyExpiryForm();
        
        // limited Value Catch Statement Scenario
        CNT_TPA_EarlyExpiryForm.onClientSubmission(  DateTime.now().addDays(2).format('yyyy/MM/dd'),JSON.serialize(tpaRequest));

        // TemplateID Not Found Catch Statement Scenario
        CNT_TPA_EarlyExpiryForm.onClientSubmission(  DateTime.now().addDays(2).format('yyyy-MM-dd'),JSON.serialize(tpaRequest));
        
        // Email Template Not found Catch Statement Scenario
        insert (new TPA_Multilingual_Template_Setting__c(Name = 'Test150', label__c ='Early Expiry Confirmation Email', Language__c = 'English', Translated_Template_Id__c = 'TstUnknownID')); // Unknown Template ID
        CNT_TPA_EarlyExpiryForm.onClientSubmission( DateTime.now().addDays(2).format('yyyy-MM-dd'),JSON.serialize(tpaRequest));
        
        Test.stopTest();
    }
    
}