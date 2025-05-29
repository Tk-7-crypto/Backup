@IsTest
private class TST_CNT_CSM_CaseCSATDetails {
    @testSetup
    static void setup() {
        Account acct = new Account(Name = 'testSetupTestSiteAccount1', RDSponsor__c = true, RDClinicalSite__c = true, RDCategorization__c = 'Site', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acct;
        
        Contact con = new Contact(FirstName = 'TestFirstName', Lastname = 'testSetupContact', Phone = '(619)852-4569', Department = 'Mission Control', 
            Title = 'Mission Specialist - Neptune', Email = 'testSetupcon@iqvia.com', AccountId = acct.Id, PreferredLanguage__c = 'en_US');
        insert con;
        
        Queue_User_Relationship__c queues1 = new Queue_User_Relationship__c();
        queues1.Name = 'Q1';
        queues1.QueueName__c = 'Q1';
        queues1.Type__c = 'Queue';
        queues1.User__c = UserInfo.getUserId(); 
        insert queues1;
        
        Queue_User_Relationship__c queueUser1 = new Queue_User_Relationship__c();
        queueUser1.Name = 'Q1';
        queueUser1.QueueName__c = 'Q1';
        queueUser1.Type__c = 'User';
        queueUser1.User__c = UserInfo.getUserId();
        insert queueUser1;
        Product2 p2 = new Product2(Name = 'Nexxus MI',Pillar__c = 'Technology Solutions',SpecificToCSM__c = True);
        insert p2;
        Asset a2 = new Asset(Name = 'Nexxus MI', AccountId = acct.Id, Product2Id = p2.id, Status ='Installed');
        insert a2;
        CSM_QI_Case_Categorization__c cc = new CSM_QI_Case_Categorization__c(
            Product__c= p2.Id,SubType1__c = 'Incident-Module', SubType2__c = 'Formularies',
            SubType3__c = '--none--', Active__c = true, Type__c = 'Categorization', Pillar__c = 'Technology Solutions');
            insert cc;
        
        Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Case cs = new Case();
        cs.ContactId = con.Id;
        cs.AccountId = acct.Id;
        cs.AssignCaseToCurrentUser__c = false;
        cs.OwnerId = UserInfo.getUserId();
        cs.RecordTypeId = recordTypeIdTechno;
        cs.Priority = 'Priority 4';
        cs.Origin = 'Customer Portal';
        cs.Mail_CC_List__c = 'nodata@info.com';
        cs.Subject = 'Techno Test case';
        cs.Description = 'Test class to check case creation ';
        cs.Status = 'New';
        cs.CurrentQueue__c = queueUser1.Id;
        cs.ProductName__c= 'Nexxus MI';
        cs.SubType1__c = 'Incident-Module';
        cs.SubType2__c = 'Formularies';  
        cs.SubType3__c = '--none--';
        insert cs;    
    }
    
    @IsTest
    private static void testGetCustomerRatings() {
        Case cs = [SELECT Id FROM Case WHERE Subject = 'Techno Test case' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'testSetupContact' LIMIT 1];
        List<CSAT_Responses__c> listOfCSATResponse = new List<CSAT_Responses__c>();
        CSAT_Responses__c csat1 = new CSAT_Responses__c(Question__c = CON_CSM.S_CSAT_QUESTION_1, Answer__c = '5', Answer_Numeric__c = 5,
                                                       Case__c = cs.Id, Contact__c = con.Id);   
        listOfCSATResponse.add(csat1);
        CSAT_Responses__c csat2 = new CSAT_Responses__c(Question__c = 'Test', Answer__c = '4', Answer_Numeric__c = 4,
                                                       Case__c = cs.Id, Contact__c = con.Id); 
        listOfCSATResponse.add(csat2);
        CSAT_Responses__c csat3 = new CSAT_Responses__c(Question__c = 'TestCon', Answer__c = '5', Answer_Numeric__c = 5,
                                                       Case__c = cs.Id, Contact__c = con.Id);
        listOfCSATResponse.add(csat3);
        insert listOfCSATResponse;
        
        Test.startTest();
            CNT_CSM_CaseCSATDetails.CSATSurveyWrapper customerRatings = CNT_CSM_CaseCSATDetails.getCustomerRatings(cs.Id);
        Test.stopTest();
        
        system.assertEquals(5, customerRatings.overallSatisfactionForContact, 'Should give overall Contact rating');
        system.assertEquals(4, customerRatings.lowestResponseScore, 'Should give Lowest response for case');
    }
    
    @IsTest
    private static void testSaveCase() {
        Case cs = [SELECT Id, CSAT_Reviewed_by__c FROM Case WHERE Subject = 'Techno Test case' LIMIT 1];
        cs.CSAT_Reviewed_by__c = 'Test Reviewer';
        
        Test.startTest();
            CNT_CSM_CaseCSATDetails.saveCase(cs);
        Test.stopTest();
        
        Case updateCase = [SELECT Id, CSAT_Reviewed_by__c FROM Case WHERE Id =:cs.Id];        
        System.assertEquals(true, updateCase.CSAT_Reviewed_by__c.contains('Test Reviewer'), 'Should update Reviewer');
    }
    
    @IsTest
    private static void testSaveSLAReviewer() {
        Case cs = [SELECT Id, SLA_FCR_Reviewed__c, SLA_IRT_Reviewed__c, SLA_FCR_Reviewed_By__c, SLA_IRT_Reviewed_By__c FROM Case WHERE Subject = 'Techno Test case' LIMIT 1];
        cs.SLA_IRT_Reviewed__c = true;
        cs.SLA_FCR_Reviewed__c = true;
        cs.FCR_Review_Escalation__c = 'Essential Escalation';
        
        Test.startTest();
            CNT_CSM_CaseCSATDetails.saveSLAReviewer(cs);
        Test.stopTest();
        
        Case updateCase = [SELECT Id, SLA_FCR_Reviewed_By__c, SLA_IRT_Reviewed_By__c FROM Case WHERE Id =:cs.Id];        
        System.assertEquals(true, updateCase.SLA_FCR_Reviewed_By__c != null, 'Should update Reviewer');
    }
    
    @IsTest
    private static void testSaveSLAReviewerShouldUpdate() {
        Case cs = [SELECT Id, SLA_FCR_Reviewed__c, SLA_IRT_Reviewed__c, SLA_FCR_Reviewed_By__c, SLA_IRT_Reviewed_By__c, FCR_Review_Escalation__c FROM Case WHERE Subject = 'Techno Test case' LIMIT 1];
        cs.SLA_IRT_Reviewed__c = false;
        cs.SLA_FCR_Reviewed__c = false;
        
        Test.startTest();
            CNT_CSM_CaseCSATDetails.saveSLAReviewer(cs);
        Test.stopTest();
        
        Case updateCase = [SELECT Id, SLA_FCR_Reviewed_By__c, SLA_IRT_Reviewed_By__c FROM Case WHERE Id =:cs.Id];        
        System.assertEquals(true, updateCase.SLA_FCR_Reviewed_By__c == null, 'Should update Reviewer');
    }
}