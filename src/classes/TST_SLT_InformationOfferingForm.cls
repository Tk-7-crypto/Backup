@IsTest
private class TST_SLT_InformationOfferingForm {
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
    }
    
    @IsTest
    private static void testGetInformationOfferingByCondition() {
        String caseId = [SELECT Id FROM Case WHERE Subject = 'Data Test case' LIMIT 1].Id;
        String condition = 'Case__c = \'' +caseId + '\'';
        
        Test.startTest();
            List<Information_Offering_Forms__c> offerings = new SLT_InformationOfferingForm().getInformationOfferingByCondition(new Set<String>{'Id', 'Name', 'Form_Request_Type__c'}, condition);
        Test.stopTest();
        
        System.assertEquals(true, offerings != null, 'Should get Offerings related to Case');
    }
    
    @IsTest
    private static void testGetOfferingsById() {
        String offeringId = [SELECT Id FROM Information_Offering_Forms__c WHERE PRSNumber__c = '123' LIMIT 1].Id;
        
        Test.startTest();
            List<Information_Offering_Forms__c> offerings = new SLT_InformationOfferingForm().getOfferingsById(new Set<String>{'Id', 'Name'}, new Set<Id>{offeringId});
        Test.stopTest();
        
        System.assertEquals(true, offerings != null, 'Should get Offerings by Id');
    }
    
    @IsTest
    private static void testSelectById() {
        String offeringId = [SELECT Id FROM Information_Offering_Forms__c WHERE PRSNumber__c = '123' LIMIT 1].Id;
        
        Test.startTest();
            List<Information_Offering_Forms__c> offerings = new SLT_InformationOfferingForm().selectById(new Set<Id>{offeringId});
        Test.stopTest();
        
        System.assertEquals(true, offerings != null, 'Should get Offerings by Id');
    }
}