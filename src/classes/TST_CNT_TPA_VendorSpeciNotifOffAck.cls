@isTest(SeeAllData=False)
public class TST_CNT_TPA_VendorSpeciNotifOffAck {
    private static TPA_Request__c tpaRequest1;
    private static TPA_Agreement_Additional_Field__c AgrAdditionalObj;
    private static Contact tpaContact;
    private static Address__c testAccount;
    private static Address__c testClientAccount;
    public static testMethod void TTPA_AddendumNotificationControllerTest() {  
        TST_CNT_TPA_VendorSpeciNotifOffAck instance = new TST_CNT_TPA_VendorSpeciNotifOffAck();
        instance.setupTestData();
        
        TPA_Text_Editor__c textEditor = new TPA_Text_Editor__c(Content__c = 'test',  Page_Title__c = 'Shutdown Message', Is_Active__c = true, Page_Name__c = 'test');
        insert textEditor;
        
        Test.startTest();
        PageReference pageRef = Page.VFP_TPA_VendorSpeciNotifOffAck;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', tpaRequest1.Id);
        ApexPages.currentPage().getParameters().put('action', 'testaction');
        ApexPages.currentPage().getParameters().put('processExecutionMode', 'English_Translation__c');
        String message = CNT_TPA_VendorSpeciNotifOffAck.Message;
        CNT_TPA_VendorSpeciNotifOffAck ctrlInstance = new CNT_TPA_VendorSpeciNotifOffAck();
      
        CNT_TPA_VendorSpeciNotifOffAck.saveRequest(JSON.serialize(AgrAdditionalObj),JSON.serialize(tpaRequest1.Id),JSON.serialize('Modify'), JSON.serialize('DirectToClient'), 'testBody', 'testName');
        tpaRequest1.Request_Status__c = 'Awaiting Account Mgmt Communication';
        update tpaRequest1;
        Test.stopTest();
        CNT_TPA_VendorSpeciNotifOffAck.saveRequest(JSON.serialize(AgrAdditionalObj),JSON.serialize(tpaRequest1.Id),JSON.serialize('Confirm_Cancellation'), JSON.serialize('DirectToClient'), 'testBody', 'testName');
        tpaRequest1.Request_Status__c = UTL_TPA.AWAITING_CLIENT_CONFIRMATION;
        update tpaRequest1;
        final String IMS_logo = ctrlInstance.IMSLogo;
        AgrAdditionalObj.Client_Contact_First_Name__c = 'Test_Client';
        AgrAdditionalObj.QuintilesIMS_Account_Team_First_Name__c = 'Test_Title';
        AgrAdditionalObj.Offering_Notification_Ack_By_Email__c = 'test@test.com';
        
        CNT_TPA_VendorSpeciNotifOffAck.onClientSubmission(JSON.serialize(AgrAdditionalObj), JSON.serialize(tpaRequest1.id));

		ctrlInstance.getObjectTpaRequestToEdit();  
        ctrlInstance.getObjectTpaRequest();  
        ctrlInstance.gettpaAgreementAdditionalFieldData();
        
    }
    public static testMethod void TTPA_AddendumNotificationControllerTest1() {  
        TST_CNT_TPA_VendorSpeciNotifOffAck instance = new TST_CNT_TPA_VendorSpeciNotifOffAck();
        instance.setupTestData();
        Test.startTest();
        PageReference pageRef = Page.VFP_TPA_VendorSpeciNotifOffAck;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', tpaRequest1.Id);
        ApexPages.currentPage().getParameters().put('action', 'testaction');
        ApexPages.currentPage().getParameters().put('processExecutionMode', 'English_Translation__c');
        
        CNT_TPA_VendorSpeciNotifOffAck ctrlInstance = new CNT_TPA_VendorSpeciNotifOffAck();
        
        CNT_TPA_VendorSpeciNotifOffAck.saveRequest(JSON.serialize(AgrAdditionalObj),JSON.serialize(tpaRequest1.Id),JSON.serialize('Acknowledge'), JSON.serialize('DirectToClient'), 'testBody', 'testName');
        
        tpaRequest1.Request_Status__c = 'Awaiting Account Mgmt Communication';
        update tpaRequest1;
        CNT_TPA_VendorSpeciNotifOffAck.saveRequest(JSON.serialize(AgrAdditionalObj),JSON.serialize(tpaRequest1.Id),JSON.serialize('Cancel'), JSON.serialize('DirectToClient'), 'testBody', 'testName');
        tpaRequest1.Request_Status__c = 'Awaiting Account Mgmt Communication';
        update tpaRequest1;
        String ProfileName = CNT_TPA_VendorSpeciNotifOffAck.currentUserProfileName;
        String CommunityURL = CNT_TPA_VendorSpeciNotifOffAck.tpaCommunityUrl;

        
        Test.stopTest();
        
    }
    
    private void setupTestData() {        
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        
        Date todayDate = Date.today();
        testAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test vendor',1200);
        testClientAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('test client',1211);
        
        tpaRequest1 = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(testAccount.id);
        tpaRequest1.Request_Status__c = 'Awaiting Account Mgmt Communication';
        update tpaRequest1;
        AgrAdditionalObj = UTL_TPA_SetupTestData.getTPAAgreementAdditionalFieldObj(tpaRequest1);
    }

}