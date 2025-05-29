@isTest
private class TST_CNT_CSM_SendMultiLanguageEmail {
    @testSetup static void setupData(){
        Account newAccount = UTL_TestData.createAccount();
        INSERT newAccount;
        
        Contact newContact = UTL_TestData.createContact(newAccount.Id);
        INSERT newContact;
        newContact.PreferredLanguage__c = 'en_US';
        UPDATE newContact;
        
        newContact.Email = 'test@iqvia.com';
        UPDATE newContact;
        
        Multi_Language_Email_Templates__c cs = new Multi_Language_Email_Templates__c();
        cs.Name = 'en_US';
        //cs.Template_Name__c = 'English Template';
        cs.Template_Id__c = '00X8A000000IwcaUAC';
        INSERT cs;
        
        Queue_User_Relationship__c queue = new Queue_User_Relationship__c(Name ='Que', QueueName__c ='Que', Type__c ='Queue', 
                                                                           User__c = UserInfo.getUserId()); 
        INSERT queue;
        
        Queue_User_Relationship__c queueUser = new Queue_User_Relationship__c(Name ='QUser', QueueName__c ='QUser', 
                                                                              Type__c ='User', User__c = UserInfo.getUserId());
        INSERT queueUser;
        
        Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Case newCase = new Case(
            Origin = 'Web',
            Urgency__c = 'Low',
            Techno_Impact__c = 'Low',
            Status = 'New',
            Subject = 'Test subject',
            Description = 'Test description',
            ContactId = newContact.Id,
            AccountId = newAccount.Id,
            RecordTypeId = recordTypeIdTechno,
            CurrentQueue__c = queueUser.Id
        );
        
        INSERT newCase;
    }
    
    @isTest 
    static void testSendMultiLanguageEmailNotification(){
        Contact con = [SELECT Id, AccountId FROM Contact WHERE Email = 'test@iqvia.com' LIMIT 1];
        Case newCase = [SELECT Id, Status FROM Case WHERE ContactId = :con.Id LIMIT 1];
        Test.startTest();
            newCase.Status = 'Resolved with Customer';
            UPDATE newCase;
            CNT_CSM_SendMultiLanguageEmail.sendMultiLanguageEmailNotification(new List<Id>{newCase.Id});
        Test.stopTest();
        Case updatedCase = [SELECT Id, Status FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assertEquals('Resolved with Customer', updatedCase.Status);
    }
}