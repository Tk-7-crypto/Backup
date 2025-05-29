@isTest
private class TST_DAO_ActivityC {

    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() {
        Account acc = CSM_Util.createAccount();
        insert acc;
        Account acc2 = CSM_Util.createRDAccount();
        insert acc2;
        Contact cnt = CSM_Util.createContact(acc.Id,'CaseTestContact');
        insert cnt;
        
    }
    
    /**
    * This test method used for insert and update Case record
    */ 
    static testMethod void testAuditforActivity() {
        CNT_CSM_FieldHistoryTracking.saveFields('Activity__c','ActivityOrigin__c,ActivityOwner__c,AppointmentType__c,Case__c,CloseDate__c,Comments__c,Contact__c,CreatedById,CurrencyIsoCode,Description__c,Duration__c,EndDate__c,EscalationType__c,FirstName__c,Language__c,LastModifiedById,LastName__c,LOS__c,PassFail__c,RecordTypeId,ResponseSyntellectId__c,Site__c,StartDate__c,Status__c,Study__c,SystemModstamp,Team__c,TeamLocation__c,Type__c');
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'CaseTestAccount' LIMIT 1];
        Account acct2= [SELECT Id, Name FROM Account WHERE Name = 'CaseRDTestAccount' LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Name = 'CaseTestContact CaseTestContact' LIMIT 1];
        Contact cnt2 = CSM_Util.createContact(acc.Id,'CaseTestContact2');
        insert cnt2;
        Study__c study = CSM_Util.createStudy(acct2.Id);
        insert study;
        Study__c study2 = CSM_Util.createStudy(acct2.Id);
        insert study2;
        Product2 product = CSM_Util.createProduct2();
        insert product;
        Asset aset = CSM_Util.createAsset('CaseTestProduct',product.Id,acc.Id,cnt.Id,study.Id);
        insert aset;
        ServiceNow_Group__c service=new ServiceNow_Group__c();
        service.Group_ID__c='GRP123';
        service.Name = 'Service GRP123';
        insert service;
        
        ServiceNow_Group__c service2=new ServiceNow_Group__c();
        service2.Group_ID__c='GRP123';
        service2.Name = 'Service GRP123';
        insert service2;
        
        BusinessHours bHours = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        BusinessHours bHours2 = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='EU Business Hours' LIMIT 1];
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acc.Id,Type = 'R_D',
                                          BusinessHoursId = bHours.Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        
        Entitlement ent2 = new Entitlement(Name='Testing2', AccountId=acc.Id,Type = 'R_D',
                                           BusinessHoursId = bHours2.Id,
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
        Queue_User_Relationship__c queues2=new Queue_User_Relationship__c();
        queues2.Name ='Q2';
        queues2.QueueName__c ='Q2';
        queues2.Type__c ='Queue';
        queues2.User__c = UserInfo.getUserId();
        insert queues2; 
        Queue_User_Relationship__c queueUser2=new Queue_User_Relationship__c();
        queueUser2.Name ='Q2';
        queueUser2.QueueName__c ='Q2';
        queueUser2.Type__c ='User';
        queueUser2.User__c = UserInfo.getUserId();
        insert queueUser2;
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        Id RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        List<Case> csList=new List<Case>();
        Case cse = null,cseParent = null;
        cse = new Case(
            AccountId = acc.Id,
            ContactId = cnt.Id,
            Study__c = study.Id,
            Sponsor__c = acct2.Id,
            ServiceNow_Group__c=service.Id,
            CurrentQueue__c=queues.Id,
            Origin = 'Chat',
            Status = 'In Progress',
            InitialQueue__c = 'Q1',
            OwnerId = UserInfo.getUserId(),
            EntitlementId = ent.Id,
            RecordTypeId = RecordTypeId
        );
        csList.add(cse);
        cseParent = new Case(
            AccountId = acc.Id,
            ContactId = cnt.Id,
            Study__c = study.Id,
            Sponsor__c = acct2.Id,
            ServiceNow_Group__c=service.Id,
            CurrentQueue__c=queues.Id,
            Origin = 'Chat',
            Status = 'In Progress',
            InitialQueue__c = 'Q1',
            OwnerId = UserInfo.getUserId(),
            EntitlementId = ent.Id,
            RecordTypeId = RecordTypeIdCase
        );
        csList.add(cseParent);
        insert csList;
        Activity__c act = new Activity__c(ActivityOwner__c=UserInfo.getUserId(),Site__c=acc.Id,Study__c=study.Id,Case__c=cseParent.Id,Status__c='Open' );
        Test.startTest();
        insert act;
        act.Status__c = 'Done';
        act.Contact__c = cnt.Id;
        act.FirstName__c = 'Act First';
        update act;
        act.Site__c = null;
        act.Status__c = 'Done';
        act.FirstName__c = 'Act First One';
        act.Contact__c = cnt.Id;
        update act;
        act.Site__c = acc.Id;
        act.Status__c = 'Done';
        act.FirstName__c = '';
        act.Contact__c = cnt2.Id;
        update act;
        act.Contact__c = null;
        act.ActivityOwner__c = null;
        act.Description__c = 'Test Activity Description';
        act.Study__c = study2.Id;
        update act;
        Test.stopTest();
    }
}