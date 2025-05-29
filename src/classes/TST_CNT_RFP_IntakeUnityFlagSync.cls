/**
* This test class is used to test all methods in CNT_RFP_IntakeUnityFlagSync class.
* version : 1.0
*/
@isTest
private class TST_CNT_RFP_IntakeUnityFlagSync {
    
    @testSetup
    static void dataSetup() {
        Box_End_Point__c boxEndpoint = new Box_End_Point__c();
        boxEndPoint.End_point__c = 'https://app.box.com/';
        boxEndpoint.End_Point_for_Folders__c = 'https://api.box.com/2.0/';
        insert boxEndpoint;
        
        box__Folder_Details__c boxFolderDetails = new box__Folder_Details__c();
        boxFolderDetails.box__Folder_Name__c = 'BID_History';
        boxFolderDetails.box__FolderId__c = '104028912491';
        boxFolderDetails.Name = 'BID_History';
        insert boxFolderDetails; 
        
        Account acc = UTL_TestData.createAccount(); 
        insert acc; 
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        
        pse__Grp__c grp = new pse__Grp__c( Name = 'TestGroup', CurrencyIsoCode = 'USD' );
        insert grp;
        Contact cont = UTL_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.FirstName = 'Test';
        cont.LastName = 'Contact';
        cont.sub_group__c = 'TSL-Japan';
        cont.available_for_triage_flag__c = true;   
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        
        Mulesoft_Integration_Control__c mulesoftIntegrationSettings = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getUserId());
        mulesoftIntegrationSettings.Ignore_Validation_Rules__c = true;
        upsert mulesoftIntegrationSettings;
        Apttus__APTS_Agreement__c agreement = UTL_TestData.createAgreement();
        agreement.Apttus__Account__c = acc.Id;
        agreement.Apttus__Related_Opportunity__c = opp.Id;
        agreement.LQ_Bid_Histroy_Id__c = 'Test Id';
        
        agreement.RecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('PSA').getRecordTypeId();
        insert agreement;
        
        Bid_History__c bidHistory = new Bid_History__c();
        bidHistory.Bid_History_Account__c = acc.Id;
        bidHistory.Bid_History_Related_Opportunity__c = opp.Id;
        bidHistory.LQ_Bid_Histroy_Id__c = 'Test Id';
        bidHistory.Requested_Services__c='Auditing and Compliance (Clinical)';
        bidHistory.RecordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Clinical_Bid').getRecordTypeId();
        bidHistory.Migrated_Agreement_Id__c = agreement.Id;
        insert bidHistory;
        
    }
   
    /**
    * This test method used for insert Account record
    */ 
    static testMethod void testInsertAndUpdateAccount() {
        Test.startTest();
            Account newAccount = UTL_TestData.createAccount();
            insert newAccount;
        Test.stopTest();
        Account existingAccount = [SELECT Id, Name FROM Account LIMIT 1];
        System.assertEquals('TestAccount', existingAccount.Name);
        existingAccount.Name = 'TestAccountUpdate';
        update existingAccount;
    }
    
}