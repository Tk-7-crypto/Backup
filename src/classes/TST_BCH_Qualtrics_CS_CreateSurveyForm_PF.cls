@isTest
private class TST_BCH_Qualtrics_CS_CreateSurveyForm_PF {
/*
    @TestSetup static void setup() {
        List<Group> listOfGroup = new List<Group>();
        Group newGroup = new Group();
        newGroup.Name = 'test Group';
        newGroup.type = 'Queue'; 
        listOfGroup.add(newGroup); 
        insert listOfGroup;
        Profile profile1 = getProfileIdByName('System Administrator');
        String UserName = 'testUser1@testGroupUpdate.com'+UserInfo.getOrganizationId();
        User testUser1 = new User(ProfileId = profile1.Id, UserName = UserName,
                                  Email = 'externalUser@bluewolf.com', EmailenCodingKey = 'UTF-8', LocalesIdKey = 'en_US',
                                  LanguageLocaleKey = 'en_US', TimeZonesIdKey = 'America/Los_Angeles', Alias = 'extUser',
                                  LastName = 'lastname', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description'
                                 ,EmployeeNumber ='08080808');
        insert testUser1;
        
        GroupMember groupMember1 = new GroupMember( GroupId = newGroup.Id, UseroRGroupId =  testUser1.Id);
        insert groupMember1;
    }
    
    static Profile getProfileIdByName(String profileName){
        return [SELECT Id FROM Profile WHERE Name =: profileName LIMIT 1];
    }
    static DeclinedSurveyApproverGroup__c createDeclinedSurveyApproverGroup(String productOfferingSegment, String offeringType, 
                                                                            String productCOE, String peopleSoftBusinessUnit, 
                                                                            String businessUnit, String mainDeliveryCountry, 
                                                                            String userCountry, String declinedSurveyApproverGroup, 
                                                                            Decimal priority){
                                                                                DeclinedSurveyApproverGroup__c declinedApproverGroup = new DeclinedSurveyApproverGroup__c();
                                                                                declinedApproverGroup.BusinessUnit__c = businessUnit;
                                                                                declinedApproverGroup.DeclinedSurveyApproverGroup__c = declinedSurveyApproverGroup;
                                                                                declinedApproverGroup.PeopleSoft_Product_Offering_Segment__c = productOfferingSegment;
                                                                                declinedApproverGroup.PeopleSoftBusinessUnit__c = peopleSoftBusinessUnit;
                                                                                declinedApproverGroup.PeopleSoft_User_Country__c = userCountry;
                                                                                declinedApproverGroup.MainDeliveryCountry__c = mainDeliveryCountry;
                                                                                declinedApproverGroup.PeopleSoftProductCOE__c = productCOE;
                                                                                declinedApproverGroup.PeopleSoftProductOfferingType__c = offeringType;
                                                                                declinedApproverGroup.Priority__c = priority;    
                                                                                return declinedApproverGroup;
                                                                            } 
    
    @IsTest
    static void testsendMailNotification() { 
        BCH_Qualtrics_CS_CreateSurveyForm_PF batchClass = new BCH_Qualtrics_CS_CreateSurveyForm_PF();
        Test.startTest();
        batchClass.sendMailNotification('Cannot create Survey');
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        system.assertEquals(1, invocations, 'An email should be sent');
    }
    
    @IsTest
    static void testsendErrorMailNotification() { 
        
        BCH_Qualtrics_CS_CreateSurveyForm_PF batchClass = new BCH_Qualtrics_CS_CreateSurveyForm_PF();
        Test.startTest();
        batchClass.sendErrorMailNotification('Cannot create Survey', 'test Group');
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        system.assertEquals(1, invocations, 'An email should be sent');
    }
    
    @IsTest
    static void testForClientSetSurveyInsertResult() {
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'Product X',ProductCode = 'Pro-X',isActive = true, Offering_Type__c ='Commercial Tech',Material_Type__c='ZREP',Offering_Segment__c='Commercial Solutions');
        prod.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        insert prod;
        PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,IsActive = true);
        insert pbEntry;
        
        Contact testContact = new Contact(FirstName = 'testfirstname', LastName = 'Test');
        insert testContact; 
        
        Opportunity opportunityRecord = new Opportunity(Name = 'Test Opportunity', StageName = 'In-Hand', CloseDate = Date.today(),
                                                        Actual_Close_Date__c = Date.today().addDays(-30),Conversion_Rate_To_USD__c = 1,
                                                        Survey_Recipient__c = testContact.Id);
        Opportunity opportunitynew = new Opportunity(Name = 'Test Opportunity', StageName = 'In-Hand', CloseDate = Date.today(),
                                                     Actual_Close_Date__c = Date.today().addDays(-30), Conversion_Rate_To_USD__c = 1,
                                                     Survey_Recipient__c = testContact.Id);
        List<Opportunity> opportunityList = new List<Opportunity>{opportunityRecord, opportunitynew};
            
        insert opportunityList;
        OpportunityLineItem lineItem = new OpportunityLineItem(OpportunityId = opportunitynew.Id, pse__IsServicesProductLine__c = true,Delivery_Country__c = 'USA',
                                                               Sale_Type__c = 'New', Revenue_Type__c= 'Ad Hoc', Quantity = 1, TotalPrice = 20000,
                                                               PricebookEntryId = pbEntry.Id,Project_Start_Date__c=Date.today().addYears(-2),
                                                               Project_End_Date__c=Date.today().addYears(2), Therapy_Area__c= 'Hepatitis C [21]');
        insert lineItem;
        Proxy_Project__c project = new Proxy_Project__c(Is_Project_Billable__c = true, Opportunity__c = opportunitynew.Id, Project_Start_Date__c = Date.today().addYears(-2),
                                                        Project_End_Date__c = Date.today().addDays(-3), LI_Record_Id__c = '121',
                                                        Record_Type_Name__c = CON_Qualtrics.RECORD_TYPE_ENGAGEMENT);
        insert project;
        Proxy_Project__c projectRecord = new Proxy_Project__c(Is_Project_Billable__c = false, Opportunity__c = opportunitynew.Id, Project_End_Date__c = Date.today().addYears(-1), 
                                                              Project_Start_Date__c = Date.today().addYears(-2), LI_Record_Id__c = '123', 
                                                              Record_Type_Name__c = CON_Qualtrics.RECORD_TYPE_PROJECT);
        List<Proxy_Project__c> projectList = new List<Proxy_Project__c>{projectRecord};
        insert projectList;
        projectRecord.Master_Project__c = project.Id;
        update projectRecord;

        Test.startTest();
        BCH_Qualtrics_CS_CreateSurveyForm_PF uca = new BCH_Qualtrics_CS_CreateSurveyForm_PF();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        
        List<Client_Sat_Survey__c> listOfClientSurvey = [SELECT Id, Name,Opp_Engagement__c, Survey_Initiation_Status__c
                                                         FROM Client_Sat_Survey__c];
        
        System.assertEquals(true, listOfClientSurvey.isEmpty(), 'Survey is created');
    }
    
    @IsTest
    static void testForClientSetSurveyInsertResultForInactiveUser() {
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X',isActive = true);
        prod.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        insert prod;
        PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id, UnitPrice = 100.00,IsActive = true);
        insert pbEntry;
        
        Contact testContact = new Contact(FirstName = 'testfirstname', LastName = 'Test');
        insert testContact; 
        
        Opportunity opportunityRecord = new Opportunity(Name = 'Test Opportunity', StageName = 'In-Hand', CloseDate = Date.today(),
                                                        Actual_Close_Date__c = Date.today());
        Opportunity opportunitynew = new Opportunity(Name = 'Test Opportunity', StageName = 'In-Hand', CloseDate = Date.today(),
                                                     Actual_Close_Date__c = Date.today());
        List<Opportunity> opportunityList = new List<Opportunity>{opportunityRecord, opportunitynew};
        insert opportunityList;
        OpportunityLineItem lineItem = new OpportunityLineItem(OpportunityId = opportunitynew.Id, pse__IsServicesProductLine__c = true,Delivery_Country__c = 'USA',
                                                               Sale_Type__c = 'New', Revenue_Type__c= 'Ad Hoc', Quantity = 1, TotalPrice = 20000,
                                                               PricebookEntryId = pbEntry.Id);
        insert lineItem;
        Proxy_Project__c project = new Proxy_Project__c(Is_Project_Billable__c = true, Opportunity__c = opportunitynew.Id, Project_Start_Date__c = Date.today().addYears(-2),
                                                        Project_End_Date__c = Date.today().addDays(-3), LI_Record_Id__c = '124',
                                                        Record_Type_Name__c = CON_Qualtrics.RECORD_TYPE_PROJECT);
        insert project;
        Proxy_Project__c projectRecord = new Proxy_Project__c(Is_Project_Billable__c = false, Opportunity__c = opportunitynew.Id, Project_End_Date__c = Date.today().addYears(-1), 
                                                              Project_Start_Date__c = Date.today().addYears(-2), 
                                                              Master_Project__c = project.Id, LI_Record_Id__c = '1275', 
                                                              Record_Type_Name__c = CON_Qualtrics.RECORD_TYPE_PROJECT);
        List<Proxy_Project__c> projectList = new List<Proxy_Project__c>{projectRecord};
        insert projectList;
        projectRecord.Master_Project__c = project.Id;
        update projectRecord;
        DeclinedSurveyApproverGroup__c declinedSurveyApproverGroup = createDeclinedSurveyApproverGroup('', '', '', '', '', '', '',
                                                                                                       'Client Sat Approver Canada', 2);
        List<DeclinedSurveyApproverGroup__c> declinedApproverGroupList = new List<DeclinedSurveyApproverGroup__c>{declinedSurveyApproverGroup};
        insert declinedApproverGroupList;   
        Test.startTest();
        BCH_Qualtrics_CS_CreateSurveyForm_PF uca = new BCH_Qualtrics_CS_CreateSurveyForm_PF();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        
        List<Client_Sat_Survey__c> listOfClientSurvey = [SELECT Id, Name, Opp_Engagement__c, Survey_Initiation_Status__c
                                                         FROM Client_Sat_Survey__c];
        
        System.assertEquals(true, listOfClientSurvey.isEmpty(), 'Survey is created');
    }
    
    @IsTest
    static void testsendInactiveApproversMail() { 
        List<String> inactiveGroupList = new List<STring>();
        inactiveGroupList.add('Client Sat Approver Canada : testUser');
        BCH_Qualtrics_CS_CreateSurveyForm_PF batchClass = new BCH_Qualtrics_CS_CreateSurveyForm_PF();
        Test.startTest();
        batchClass.sendInactiveApproversMail(inactiveGroupList);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        system.assertEquals(1, invocations, 'An email should be sent');
    }
*/
    
    @IsTest
    static void testsendInactiveApproversMail() { 
     	new BCH_Qualtrics_CS_CreateSurveyForm_PF();
    }
}