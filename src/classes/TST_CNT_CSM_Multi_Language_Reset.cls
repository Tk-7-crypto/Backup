@IsTest
private class TST_CNT_CSM_Multi_Language_Reset {
    @testSetup
    static void setup() {
        Account acct = new Account(Name = 'testSetupTestSiteAccount1', RDSponsor__c = true, RDClinicalSite__c = true,
                                   RDCategorization__c = 'Site', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acct;
        Contact con = new Contact(Firstname = 'testFirstName', Lastname = 'testSetupContact', Phone = '(619)852-4569', Department = 'Mission Control', 
                                  Title = 'Mission Specialist - Neptune', Email='testSetupcon@iqvia.com', AccountId = acct.Id,
                                  Portal_Case_Type__c = 'Information Offering', Contact_User_Type__c = 'HO User');
        insert con;
        Queue_User_Relationship__c qurPortal = new Queue_User_Relationship__c(Name = 'Q1',User__c = UserInfo.getUserId(),Type__c = 'Queue');
        insert qurPortal;
        CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
        dT.Queue_User_Relationship__c = qurPortal.Id;
        dT.Account__c = acct.Id;
        dT.All_Current_Users__c = true;
        dT.CaseRecordType__c = 'TechnologyCase';
        dT.Type__c ='Queue Assignment';
        dT.Order__c = 1;
        insert dT;
        CSM_QI_Data_Portal_Queue_User_details__c dd = new CSM_QI_Data_Portal_Queue_User_details__c();
        dd.Queue_User_Relationship__c = qurPortal.Id;
        dd.Account__c = acct.Id;
        dd.All_Current_Users__c = true;
        dd.CaseRecordType__c = 'DATACase';
        dd.Type__c ='Queue Assignment';
        dd.Order__c = 1;
        insert dd;
        List<User> listOfUser = UTL_TestData.createUser(CON_CSM.S_P_CSM_COMMUNITY, 1);
        listOfUser[0].ContactId = con.Id;
        insert listOfUser[0];
    }
    
    @IsTest
    private static void testEmailTemplateMergeFieldsForResetPassword() {
        CNT_CSM_Multi_Language_Reset_Password ctrlInstance = new CNT_CSM_Multi_Language_Reset_Password();
        Id contactId = [SELECT Id FROM Contact WHERE LastName = 'testSetupContact'][0].Id;
        
        Test.startTest();
            ctrlInstance.setRecipientId(contactId);
        Test.stopTest();
        
        System.assertEquals(true, ctrlInstance.recipientUser != null, 'Got User Info');
        System.assertEquals(contactId, ctrlInstance.getRecipientId(), 'Got Recepient Id');
    }
    
    @IsTest
    private static void testEmailTemplateMergeFieldsForWelcomeEmail() {
        CNT_CSM_Multi_Language_Reset_Password ctrlInstance = new CNT_CSM_Multi_Language_Reset_Password();
        Id userId = [SELECT Id FROM User WHERE LastName = 'lastName123'][0].Id;
        
        Test.startTest();
            ctrlInstance.setRecipientId(userId);
        Test.stopTest();
        
        System.assertEquals(true, ctrlInstance.recipientUser != null, 'Got User Info');
        System.assertEquals(userId, ctrlInstance.getRecipientId(), 'Got Recepient Id');
    }
}
