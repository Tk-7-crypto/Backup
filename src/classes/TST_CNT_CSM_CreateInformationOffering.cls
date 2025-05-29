@IsTest
private class TST_CNT_CSM_CreateInformationOffering {
    @testSetup
    static void setup() {
        Id mdmValidAccount = Schema.SObjectType.account.getRecordTypeInfosByName().get('MDM Validated Account').getRecordTypeId();
        Account accCase = new Account();
        accCase.RecordTypeId = mdmValidAccount;
        accCase.Name = 'Techno Portal';
        accCase.RDCategorization__c = 'Site';
        accCase.CustomerSegment__c = 'GOVERNMENT';
        accCase.Sub_Industry__c = 'STATE';
        insert accCase;
        
        Contact conCase = new Contact();
        conCase.AccountId = accCase.Id;
        conCase.FirstName = 'test';
        conCase.LastName = 'con';
        conCase.Salutation = 'Eng';
        conCase.Email = 'noreply@dummy.com';
        insert conCase;
        
        Queue_User_Relationship__c queues = new Queue_User_Relationship__c();
        queues.Name = 'Q1';
        queues.QueueName__c = 'Q1';
        queues.Type__c = 'Queue';
        queues.User__c = UserInfo.getUserId(); 
        insert queues;
        Queue_User_Relationship__c queueUser = new Queue_User_Relationship__c();
        queueUser.Name = 'Q1';
        queueUser.QueueName__c = 'Q1';
        queueUser.Type__c = 'User';
        queueUser.User__c = UserInfo.getUserId();
        insert queueUser;
        
        Id recordTypeIdData = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        
        Case csData = new Case();
        csData.AccountId = accCase.Id;
        csData.AssignCaseToCurrentUser__c = false;
        csData.RecordTypeId = RecordTypeIdData;
        csData.OwnerId = UserInfo.getUserId();
        csData.LOS__c = 'DATA';
        csData.SubType1__c = 'DATA MGT/PRODUCTION';
        csData.SubType2__c = 'DATA ISSUES';
        csData.SubType3__c = 'Account';
        csData.Priority = 'High';
        csData.Origin = 'Agent Initiated';
        csData.Subject = 'Data Test case';
        csData.Description = 'No information available';
        csData.Status = 'In Progress';
        csData.CurrentQueue__c = queueUser.Id;
        csData.InitialQueueData__c = queueUser.Id;
        csData.First_response_email_time__c = null;
        csData.First_response_sent__c = FALSE;
        insert csData;   
       
        Information_Offering_Forms__c offering = new Information_Offering_Forms__c();
        offering.Form_Request_Type__c = 'Patient Offering Additional Details';
        offering.Case__c = csData.Id;
        offering.PRSNumber__c = '123';
        insert offering;
        
        
        Case csData1 = new Case();
        csData1.AccountId = accCase.Id;
        csData1.AssignCaseToCurrentUser__c = false;
        csData1.RecordTypeId = RecordTypeIdData;
        csData1.OwnerId = UserInfo.getUserId();
        csData1.LOS__c = 'DATA';
        csData1.SubType1__c = 'DATA MGT/PRODUCTION';
        csData1.SubType2__c = 'DATA ISSUES';
        csData1.SubType3__c = 'Account';
        csData1.Priority = 'High';
        csData1.Origin = 'Agent Initiated';
        csData1.Subject = 'CREATE Test case';
        csData1.Description = 'No information available';
        csData1.Status = 'In Progress';
        csData1.CurrentQueue__c = queueUser.Id;
        csData1.InitialQueueData__c = queueUser.Id;
        csData1.First_response_email_time__c = null;
        csData1.First_response_sent__c = FALSE;
        insert csData1;

        EmailMessage message = new EmailMessage(FromAddress = 'dummyuser@mail.com', ToAddress = 'casecontact@mail.com',BccAddress  = 'casecontact@mail.com',CcAddress = 'casecontact@mail.com', Subject = 'Test subject',
                                                TextBody = 'Test dummy body', ParentId = csData1.Id, Incoming=true);
        insert message;
        TimeSheet__c s = new TimeSheet__c(Type__c = 'System',StartTime__c = System.now(), Case__c = csData1.Id, Status__c = 'stop',Time_Type__c = 'Estimated effort');
        insert s;
        FeedItem fi = new FeedItem(ParentId = csData1.Id, Body ='Test Contat',Type = 'TextPost' , Visibility ='AllUsers');
        insert fi;
        CaseComment caseCom = new CaseComment(CommentBody ='Body1',ParentId =csData1.id);
        insert caseCom;
        CSM_Create_Forms__c form = new CSM_Create_Forms__c();
        form.Form_Request_Type__c = 'Market Maintenance';
        form.Case__c = csData1.Id;
        form.Action__c = 'New';
        form.PRS_LSOM_Number__c = 'IP001';
        insert form;
        
    }
    
    @IsTest
    private static void testGetInformationOffering() {
        String caseId = [SELECT Id FROM Case WHERE Subject = 'Data Test case' LIMIT 1].Id;
        
        Test.startTest();
            CNT_CSM_CreateInformationOffering.InformationOfferingWrapper offeringWrapper = 
            CNT_CSM_CreateInformationOffering.getInformationOffering(caseId);
        Test.stopTest();
        
        System.assertEquals(true, offeringWrapper != null, 'Should get offering related to Case');
    }
    
    @IsTest
    private static void testGetCreate() {
        String caseId = [SELECT Id FROM Case WHERE Subject = 'CREATE Test case' LIMIT 1].Id;
        
        Test.startTest();
            CNT_CSM_CreateInformationOffering.CreateWrapper createWrapper = 
                CNT_CSM_CreateInformationOffering.getCreate(caseId);
        CNT_CSM_CreateInformationOffering.CreatePreviewWrapper createPreviewWrapper = 
                CNT_CSM_CreateInformationOffering.getCreatHistoryPreview(caseId);
        Test.stopTest();
        
    }
}