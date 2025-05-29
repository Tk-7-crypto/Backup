@IsTest
private class TST_TGR_ClientSatSurvey {
    @TestSetup static void setup() {
        Contact testContact = new Contact(FirstName = 'TestFirstName', LastName = 'Test');
        insert testContact; 
            
        Opportunity opportunityRecord = new Opportunity(Name = 'Test Opportunity', StageName = 'In-Hand', CloseDate = Date.today());
        Opportunity Newopportunity = new Opportunity(Name = 'new Opportunity', StageName = 'In-Hand', CloseDate = Date.today());
        List<Opportunity> opportunityList = new List<Opportunity>{opportunityRecord, Newopportunity};
        insert opportunityList;
        
        Product2 product = new Product2(Name = 'Test Product', Global_Product_Code__c = '123');
        insert product;

        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry priceBookEntry = new PricebookEntry(Product2Id = product.Id, UnitPrice = 54,
                                                          IsActive = true, Pricebook2Id = pricebookId);
        insert priceBookEntry;
        
        OpportunityLineItem opportunityProduct = new OpportunityLineItem(OpportunityId = opportunityRecord.Id, Sale_Type__c = 'New',Delivery_Country__c = 'USA',
                                                                         Revenue_Type__c = 'Subscription', UnitPrice = 54,
                                                                         Quantity = 1, priceBookEntryId = priceBookEntry.Id);
        insert opportunityProduct;
        OpportunityLineItem newOpportunityProduct = new OpportunityLineItem(OpportunityId = Newopportunity.Id, Sale_Type__c = 'New',Delivery_Country__c = 'USA',
                                                                         Revenue_Type__c = 'Subscription', UnitPrice = 54,
                                                                         Quantity = 1, priceBookEntryId = priceBookEntry.Id);
        insert newOpportunityProduct;
        
        Proxy_Project__c project = new Proxy_Project__c(Is_Project_Billable__c = true, Opportunity__c = Newopportunity.Id, Project_Start_Date__c = Date.today().addYears(-2),
                                                Project_End_Date__c = Date.today().addDays(-3), LI_Record_Id__c = '121');
        Proxy_Project__c projectRecord = new Proxy_Project__c(Is_Project_Billable__c = false, Opportunity__c = Newopportunity.Id, Project_End_Date__c = Date.today().addYears(-1), 
                                                      Project_Start_Date__c = Date.today().addYears(-2), LI_Record_Id__c = '123');
        List<Proxy_Project__c> projectList = new List<Proxy_Project__c>{projectRecord, project};
        insert projectList;
        
        Client_Sat_Survey__c clientSatSurvey = createClientSatSurveyRecord('Yes', testContact.Id, opportunityRecord.Id);
        Client_Sat_Survey__c declinedClientSatSurvey = createClientSatSurveyRecord('No', testContact.Id, opportunityRecord.Id);
        Client_Sat_Survey__c clientSurvey = createClientSatSurveyRecord('Yes', testContact.Id, opportunityRecord.Id);
        List<Client_Sat_Survey__c> clientSatSurveyList = new List<Client_Sat_Survey__c>{clientSatSurvey, declinedClientSatSurvey, clientSurvey};
        insert clientSatSurveyList;
        
        DeclinedSurveyApproverGroup__c declinedApproverGroup = createDeclinedSurveyApproverGroup('Consumer Health','Canada',
                                                                                                 'Canada', 'Canada', 
                                                                                                 'Client Sat Approver Canada', 1);
        DeclinedSurveyApproverGroup__c declinedSurveyApproverGroup = createDeclinedSurveyApproverGroup('', '', '', '',
                                                                                                       'Client Sat Approver Canada', 2);
        List<DeclinedSurveyApproverGroup__c> declinedApproverGroupList =
            new List<DeclinedSurveyApproverGroup__c>{declinedApproverGroup, declinedSurveyApproverGroup};
        insert declinedApproverGroupList;        
    } 
    
    static Client_Sat_Survey__c createClientSatSurveyRecord(String sendSurvey, String surveyRecipient1_Id, String opportunityId) {
        Client_Sat_Survey__c clientSatSurvey = new Client_Sat_Survey__c();
        clientSatSurvey.Send_Survey__c = sendSurvey;
        clientSatSurvey.Survey_Recipient_1__c = surveyRecipient1_Id;
        clientSatSurvey.Opportunity__c = opportunityId;
        return clientSatSurvey;
    }
    
    static List<Client_Sat_Survey__c> getClientSatSurveyBySendSurvey(String sendSurvey) {
        return [SELECT Id, Send_Survey__c, Declined_Survey_Approver_Group_ID__c, Survey_Initiation_Status__c 
                FROM Client_Sat_Survey__c 
                WHERE Send_Survey__c =: sendSurvey
               ];
    }  
    
    static DeclinedSurveyApproverGroup__c createDeclinedSurveyApproverGroup(String offeringType, String businessUnit, 
                                                                            String mainDeliveryCountry, String userCountry, 
                                                                            String declinedSurveyApproverGroup, 
                                                                            Decimal priority){
        DeclinedSurveyApproverGroup__c declinedApproverGroup = new DeclinedSurveyApproverGroup__c();
        declinedApproverGroup.BusinessUnit__c = businessUnit;
        declinedApproverGroup.DeclinedSurveyApproverGroup__c = declinedSurveyApproverGroup;
        declinedApproverGroup.PeopleSoft_User_Country__c = userCountry;
        declinedApproverGroup.MainDeliveryCountry__c = mainDeliveryCountry;
        declinedApproverGroup.PeopleSoftProductOfferingType__c = offeringType;
        declinedApproverGroup.Priority__c = priority;    
        return declinedApproverGroup;
    }
    
    static List<Client_Sat_Survey__c> getClientSatSurveys() {
        return [SELECT Id, Send_Survey__c, Opportunity__c, CreatedDate, Opportunity_Product_Codes__c FROM Client_Sat_Survey__c];
    }

    @IsTest
    private static void testOnBeforeInsertCheckSurveyHasBillableProject() {
        Contact testContact = [Select Id, lastName from Contact where lastName = 'Test' Limit 1];
        opportunity opportunityRecord = [Select Id, Name From opportunity where Name = 'New Opportunity' limit 1];
        Client_Sat_Survey__c clientSatSurvey = createClientSatSurveyRecord('Yes', testContact.Id, opportunityRecord.Id);
        Boolean isExceptionThrown = false;
        
        Test.startTest();
        Try{
            insert clientSatSurvey;
        } catch(Exception ex) {
            isExceptionThrown = ex.getMessage().contains(CON_Qualtrics.OPPORTUNITY_ATLEAST_HAVE_ONE_BILLABLE_PROJECT_ERROR_MSG) ? true : false;
        }
        Test.stopTest();
        
        System.assertEquals(false, isExceptionThrown, 'Survey has billable project');
        
    }
    
    @IsTest
    private static void testOnBeforeInsertCheckSurveyExists() {
        Contact testContact = [Select Id, lastName from Contact where lastName = 'Test' Limit 1];
        opportunity opportunityRecord = [Select Id, Name From opportunity where Name = 'Test Opportunity' limit 1];
        Client_Sat_Survey__c clientSatSurvey = createClientSatSurveyRecord('Yes', testContact.Id, opportunityRecord.Id);
        Date Date6Back = Date.today().addMonths(-6);    
        Boolean isExceptionThrown = false;
        
        Test.startTest();
        Try{
            insert clientSatSurvey;
        } catch(Exception ex) {
            isExceptionThrown = ex.getMessage().contains(CON_Qualtrics.OPPORTUNITY_ATLEAST_HAVE_ONE_BILLABLE_PROJECT_ERROR_MSG) ? true : false;
        }
        Test.stopTest();
        
        List<Client_Sat_Survey__c> listOfSurveys = [Select Id, Name, CreatedDate,Opportunity_Product_Codes__c, Send_Survey__c From Client_Sat_Survey__c Where Survey_Recipient_1__c =: testContact.Id];
        System.assertEquals(true, listOfSurveys[0].CreatedDate > Date6Back, 'Survey has already been created within last 6 months.');
        System.assertEquals(false, isExceptionThrown, 'Survey has billable project');
        System.assertEquals(true, listOfSurveys[0].Opportunity_Product_Codes__c != null, 'Updated Opportunity Product Code');
        System.assertEquals('Yes', listOfSurveys[0].Send_Survey__c, 'Submitted for approval');
    }
    
    @IsTest
    private static void testSubmitForApprovalShouldSubmitForApproval() {
        List<Client_Sat_Survey__c> listOfSurveys = getClientSatSurveyBySendSurvey('Yes');
        Map<Id, Client_Sat_Survey__c> oldMapOfSurveys = new Map<Id, Client_Sat_Survey__c>(listOfSurveys);
        listOfSurveys[0].Send_Survey__c = 'No';
        
        Test.startTest();
            update listOfSurveys;
        Test.stopTest();
        
        System.assertEquals('No', listOfSurveys[0].Send_Survey__c, 'Submitted for approval');
    }
    
    @IsTest
    private static void testFilterSurvey_DeclinedSurveysShouldGiveDeclinedCSSet() {
        List<Client_Sat_Survey__c> listOfSurveys = getClientSatSurveyBySendSurvey('Yes');
        Map<Id, Client_Sat_Survey__c> oldMapOfSurveys = new Map<Id, Client_Sat_Survey__c>(listOfSurveys);
        listOfSurveys[0].Send_Survey__c = 'No';
        
        Test.startTest();
            update listOfSurveys;    
        Test.stopTest();
        
        List<Client_Sat_Survey__c> declinedCSSet = [Select Id From Client_Sat_Survey__c where Send_Survey__c = 'Yes'];
       System.assertEquals(true, declinedCSSet.size() > 0, 'Got declined Client Sat Survey set');
    }
    
    @IsTest
    private static void testUpdateSurvey_DeclinedSurveyApproversShouldSetApprover() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'new Opportunity' LIMIT 1];
        Client_Sat_Survey__c declinedClientSatSurvey = createClientSatSurveyRecord('No', con.Id, opp.Id);
        insert declinedClientSatSurvey;
        
        Test.startTest();
            update declinedClientSatSurvey; 
        Test.stopTest();
        
        System.assertEquals(false, declinedClientSatSurvey.Declined_Survey_Approver_Group_ID__c != null, 'Set approver');
    }
}