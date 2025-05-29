@IsTest
private class TST_SLT_CreateForm {
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
        csData.Subject = 'CREATE Test case';
        csData.Description = 'No information available';
        csData.Status = 'In Progress';
        csData.CurrentQueue__c = queueUser.Id;
        csData.InitialQueueData__c = queueUser.Id;
        csData.First_response_email_time__c = null;
        csData.First_response_sent__c = FALSE;
        insert csData;   
       
        CSM_Create_Forms__c form = new CSM_Create_Forms__c();
        form.Form_Request_Type__c = 'Market Maintenance';
        form.Case__c = csData.Id;
        form.Action__c = 'New';
        form.Report_Number__c = 'IP001';
        insert form;
    }
    
    @IsTest
    private static void testSelectById() {
        String formId = [SELECT Id FROM CSM_Create_Forms__c WHERE Report_Number__c = 'IP001' LIMIT 1].Id;
        
        Test.startTest();
            List<CSM_Create_Forms__c> offerings = new SLT_CreateForm().selectById(new Set<Id>{formId});
        Test.stopTest();
        
    }
    
    @IsTest
    private static void testGetCreateFormByCondition() {
        String caseId = [SELECT Id FROM Case WHERE Subject = 'CREATE Test case' LIMIT 1].Id;
        String condition = 'Case__c = \'' +caseId + '\'';
        
        Test.startTest();
            List<CSM_Create_Forms__c> offerings = new SLT_CreateForm().getCreateFormByCondition(new Set<String>{'Id', 'Name', 'Form_Request_Type__c'}, condition);
        Test.stopTest();
        
    }
    
    @IsTest
    private static void testGetOfferingsById() {
        String offeringId = [SELECT Id FROM CSM_Create_Forms__c WHERE Report_Number__c = 'IP001' LIMIT 1].Id;
        
        Test.startTest();
            List<CSM_Create_Forms__c> offerings = new SLT_CreateForm().getOfferingsById(new Set<String>{'Id', 'Name'}, new Set<Id>{offeringId});
        Test.stopTest();
        
    }
    
    

}
