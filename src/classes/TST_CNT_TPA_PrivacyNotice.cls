@isTest
private class TST_CNT_TPA_PrivacyNotice {
    static testMethod void CNT_TPA_PrivacyNoticeTest() {
        TPA_Text_Editor__c tpaTxtEditor = new TPA_Text_Editor__c();
        tpaTxtEditor.Page_Name__c = 'Client Privacy Policy Message Board';
        tpaTxtEditor.Content__c = 'Test Contant';
        insert tpaTxtEditor;
        
        TPA_Settings__c setting = TPA_Settings__c.getOrgDefaults();
        setting.Base_Url__c = String.valueOf(URL.getOrgDomainUrl());
        setting.TPA_RequestSubmitted_Email__c = 'test@test.com';
        setting.Request_Submission_Form_URL__c = '/imshealthPortal/VFP_TPA_RequestSubmissionForm';
        setting.clientPrivacyMessageBoardId__c = tpaTxtEditor.Id;
        upsert setting;
        
        TPA_Multilingual_Global_Settings__c setting2 = TPA_Multilingual_Global_Settings__c.getOrgDefaults();
        setting2.Supported_Language_Code_with_Field_Map__c = 'ja=Japanese~Japanese_Translation__c~日本語;en_US=English~English_Translation__c~English';
        upsert setting2;
        
        update new User(Id = UserInfo.getUserId(), EmployeeNumber = String.valueOf(System.currentTimeMillis()));
        
        CNT_TPA_PrivacyNotice controller = new CNT_TPA_PrivacyNotice();
        controller.init();
        controller.getTitle();
        controller.getAcknowledgement();
        controller.showPopup();
        controller.accept();
    }
}