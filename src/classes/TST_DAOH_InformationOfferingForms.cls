@IsTest
private class TST_DAOH_InformationOfferingForms {
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
        Case cda = csData.clone();
        cda.Subject = 'Data case Subject';
        insert cda;
        Information_Offering_Forms__c offering = new Information_Offering_Forms__c();
        offering.Form_Request_Type__c = 'Patient Offering Additional Details';
        offering.Case__c = csData.Id;
        offering.PRSNumber__c = '123';
        insert offering;
        
        Information_Offering_Forms__c offering1 = new Information_Offering_Forms__c();
        offering1.Form_Request_Type__c = 'Data Integrity';
        offering1.Case__c = cda.Id;
        insert offering1;
    }
    
    @IsTest
    private static void testUpdateParentCaseFields() {
        Information_Offering_Forms__c offering = [SELECT Id, PRSNumber__c FROM Information_Offering_Forms__c WHERE PRSNumber__c = '123' LIMIT 1];
        offering.PRSNumber__c = '12345';
        
        Test.startTest();
            update offering; 
        Test.stopTest(); 
        
        Case caseRecord = [SELECT Id, InformationOfferingFormId__c FROM Case WHERE Subject = 'Data Test case' LIMIT 1];
        System.assertEquals(true, caseRecord.InformationOfferingFormId__c != null, 'Should update case');
    }
    
    @IsTest
    private static void testUpdateParentCaseFieldsOnDeletion() {
        Information_Offering_Forms__c offering = [SELECT Id, PRSNumber__c FROM Information_Offering_Forms__c WHERE PRSNumber__c = '123' LIMIT 1];
        
        Test.startTest();
            delete offering; 
        Test.stopTest(); 
        
        Case caseRecord = [SELECT Id, InformationOfferingFormId__c FROM Case WHERE Subject = 'Data Test case' LIMIT 1];
        System.assertEquals(true, caseRecord.InformationOfferingFormId__c == null, 'Should update case');
    }
}