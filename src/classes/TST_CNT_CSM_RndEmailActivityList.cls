@isTest
private class TST_CNT_CSM_RndEmailActivityList {

    @testSetup
    static void dataSetup() {
        Account acc = CSM_Util.createAccount();
        insert acc;
        Account acc2 = CSM_Util.createRDAccount();
        insert acc2;
        Contact cnt = CSM_Util.createContact(acc.Id,'CaseTestContact');
        insert cnt;
        
        Contact cnt2 = CSM_Util.createContact(acc.Id,'CaseTestContact2');
        insert cnt2;
        Study__c study= CSM_Util.createStudy(acc2.Id);
        insert study;
        BusinessHours bHours = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acc.Id,Type = 'R_D',
                                          BusinessHoursId = bHours.Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        
        Queue_User_Relationship__c queues=new Queue_User_Relationship__c();
        queues.Name ='Q1';
        queues.QueueName__c ='Q1';
        queues.Type__c ='Queue';
        queues.User__c = UserInfo.getUserId(); 
        insert queues;
        Queue_User_Relationship__c queueUser=new Queue_User_Relationship__c();
        queueUser.Name ='Q1';
        queueUser.QueueName__c ='Q1';
        queueUser.Type__c ='User';
        queueUser.User__c = UserInfo.getUserId();
        insert queueUser;
        
        Id RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        Case cse = new Case(
            AccountId = acc.Id,
            ContactId = cnt.Id,
            Study__c = study.Id,
            Sponsor__c = acc2.Id,
            CurrentQueue__c=queues.Id,
            Origin = 'Chat',
            Status = 'In Progress',
            InitialQueue__c = 'Q1',
            Subject = 'Test Rnd Case Email Activity',
            OwnerId = UserInfo.getUserId(),
            EntitlementId = ent.Id,
            RecordTypeId = RecordTypeId
        );
        
        insert cse;
        EmailMessage message = new EmailMessage(FromAddress = 'dummyuser@mail.com', ToAddress = 'casecontact@mail.com',BccAddress  = 'casecontact@mail.com',CcAddress = 'casecontact@mail.com', Subject = 'Test subject',
                                                TextBody = 'Test dummy body', ParentId = cse.Id, Incoming=true);
        insert message;
        EmailMessage mOut = new EmailMessage(FromAddress = 'dummyuser@mail.com', ToAddress = 'casecontact@mail.com',BccAddress  = 'casecontact@mail.com',CcAddress = 'casecontact@mail.com', Subject = 'Test subject',TextBody = 'Test dummy body', ParentId = cse.Id, Incoming=false);
        insert mOut;
        List<Activity__c> actList = new List<Activity__c>();
        Activity__c act = new Activity__c(ActivityOwner__c=UserInfo.getUserId(),Site__c=acc.Id,Study__c=study.Id,Case__c=cse.Id,Status__c='Open',EmailMessageId__c = message.Id );
        actList.add(act);
        Activity__c act1 = new Activity__c(ActivityOwner__c=UserInfo.getUserId(),Site__c=acc.Id,Study__c=study.Id,Case__c=cse.Id,Status__c='Open',EmailMessageId__c = mOut.Id );
        actList.add(act1);
        insert actList;
    }
    @isTest
    private static void testRndEmailActivity(){
        Case c = [Select Id from Case where Subject = 'Test Rnd Case Email Activity' LIMIT 1];
        
        List<CNT_CSM_RndEmailActivityList.EmailActivityWrapper> eaList = CNT_CSM_RndEmailActivityList.getEmailActivityList(c.Id);
        CNT_CSM_RndEmailActivityList.getEmailCategorizationList('Email_Categorization__c');
        CNT_CSM_RndEmailActivityList.updateEmailActivityWrapperList(eaList);
        //CNT_CSM_RndEmailActivityList.updateEmailActivityWrapperList(emailActivityList);
    }
}