@isTest
public class TST_DAOH_ClientSatSurveyOld {
    static testmethod void testM1(){
        DAOH_ClientSatSurveyOld ad = new DAOH_ClientSatSurveyOld();
    }
    /*
	@TestSetup static void setup() {
        User testUser1 = UTL_TestData.createUser('System Administrator', 1)[0];
        insert testUser1;
        
        Contact testContact = new Contact(FirstName = 'TestFirstName', LastName = 'Test', pse__Salesforce_User__c = testUser1.Id);
        insert testContact; 
             
        Opportunity opportunityRecord = new Opportunity(Name = 'Test Opportunity', StageName = 'In-Hand', CloseDate = Date.today());
        Opportunity opportunity = new Opportunity(Name = 'new Opportunity', StageName = 'In-Hand', CloseDate = Date.today());
        List<Opportunity> opportunityList = new List<Opportunity>{opportunityRecord, opportunity};
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
        Proxy_Project__c project = new Proxy_Project__c(Is_Project_Billable__c = true, Opportunity__c = opportunityRecord.Id, Project_Start_Date__c = Date.today().addYears(-2),
                                                        Project_End_Date__c = Date.today().addDays(-3), LI_Record_Id__c = '121',
                                                        Delivery_PIC_Name__c = testContact.Name, Record_Type_Name__c = CON_Qualtrics.RECORD_TYPE_ENGAGEMENT);
        Proxy_Project__c projectRecord = new Proxy_Project__c(Is_Project_Billable__c = false, Opportunity__c = opportunityRecord.Id, Project_End_Date__c = Date.today().addYears(-1), 
                                                              Project_Start_Date__c = Date.today().addYears(-2), LI_Record_Id__c = '123',
                                                              Delivery_PIC_Name__c = testContact.Name,
                                                              Record_Type_Name__c = CON_Qualtrics.RECORD_TYPE_ENGAGEMENT);
        List<Proxy_Project__c> projectList = new List<Proxy_Project__c>{projectRecord, project};
        insert projectList;
        
        Client_Sat_Survey__c clientSatSurvey = createClientSatSurveyRecord('Yes', testContact.Id, opportunityRecord.Id);
        Client_Sat_Survey__c declinedClientSatSurvey = createClientSatSurveyRecord('No', testContact.Id, opportunityRecord.Id);
        Client_Sat_Survey__c clientSurvey = createClientSatSurveyRecord('Yes', testContact.Id, opportunityRecord.Id);
        List<Client_Sat_Survey__c> clientSatSurveyList = new List<Client_Sat_Survey__c>{clientSatSurvey, declinedClientSatSurvey, clientSurvey};
        insert clientSatSurveyList;
        
        DeclinedSurveyApproverGroup__c declinedApproverGroup = createDeclinedSurveyApproverGroup('Consumer Health','Canada',
                                                                                                 'Canada', 'Canada', 
                                                                                                 'Test Group', 1);
        DeclinedSurveyApproverGroup__c declinedSurveyApproverGroup = createDeclinedSurveyApproverGroup('', '', '', '',
                                                                                                       'Test Group', 2);
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

    static List<DeclinedSurveyApproverGroup__c> getDeclinedApproverGroupByOfferingType(String offeringType) {
        return [SELECT Id, DeclinedSurveyApproverGroup__c 
                FROM DeclinedSurveyApproverGroup__c 
                WHERE PeopleSoftProductOfferingType__c =: offeringType];
    }
    
    static List<Client_Sat_Survey__c> getClientSatSurveyBySendSurvey(String sendSurvey) {
        return [SELECT Id, Send_Survey__c, Declined_Survey_Approver_Group_ID__c, Survey_Initiation_Status__c 
                FROM Client_Sat_Survey__c 
                WHERE Send_Survey__c =: sendSurvey
               ];
    }    
    
    static List<Client_Sat_Survey__c> getClientSatSurveys() {
        return [SELECT Id, Send_Survey__c, Opportunity__c, CreatedDate, Opportunity_Product_Codes__c FROM Client_Sat_Survey__c];
    }
    
    static void insertGroup() {
        List<Group> listOfGroup = new List<Group>();
        Group newGroup = new Group();
        newGroup.Name = 'Test Group';
        newGroup.type = 'Queue'; 
        listOfGroup.add(newGroup); 
        insert listOfGroup;
        User testUser1 = UTL_TestData.createUser('System Administrator', 1)[0];
        insert testUser1;
        GroupMember groupMember1 = new GroupMember( GroupId = newGroup.Id, UseroRGroupId =  testUser1.Id);
        insert groupMember1;
    }
  
    @IsTest
    private static void testUpdateSurvey_InitiationStatusShouldUpdate() {
        List<Client_Sat_Survey__c> listOfSurveys = getClientSatSurveyBySendSurvey('Yes');
        Map<Id, Client_Sat_Survey__c> oldMapOfSurveys = new Map<Id, Client_Sat_Survey__c>(listOfSurveys);
        listOfSurveys[0].Send_Survey__c = 'No';
        
        Test.startTest();
            update listOfSurveys;
        Test.stopTest();
        
        System.assertEquals('No', listOfSurveys[0].Send_Survey__c, 'Updated');
    }
    
    @IsTest
    private static void testFilterSurvey_DeclinedSurveysShouldGiveDeclinedCSSet() {
        List<Client_Sat_Survey__c> listOfSurveys = getClientSatSurveyBySendSurvey('No');
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'new Opportunity' LIMIT 1];
        Client_Sat_Survey__c declinedClientSatSurvey = createClientSatSurveyRecord('No', con.Id, opp.Id);
        insert declinedClientSatSurvey;
        
        Map<Id, Client_Sat_Survey__c> oldMapOfSurveys = new Map<Id, Client_Sat_Survey__c>();
        oldMapOfSurveys.put(declinedClientSatSurvey.Id, declinedClientSatSurvey);
        oldMapOfSurveys.get(declinedClientSatSurvey.Id).Send_Survey__c = 'Yes';
        
        Test.startTest();
        Set<Client_Sat_Survey__c> declinedCSSet = DAOH_ClientSatSurvey.filterSurvey_DeclinedSurveys(new List<Client_Sat_Survey__c>{declinedClientSatSurvey}, oldMapOfSurveys);
        Test.stopTest();
        
        System.assertEquals(false, declinedCSSet.size() > 0, 'Got declined Client Sat Survey set');
    }
    
    @IsTest
    private static void testFilterSurvey_DeclinedSurveysShouldNotGiveDeclinedCSSet() {
        List<Client_Sat_Survey__c> listOfSurveys = getClientSatSurveyBySendSurvey('Yes');
        Map<Id, Client_Sat_Survey__c> oldMapOfSurveys = new Map<Id, Client_Sat_Survey__c>(getClientSatSurveyBySendSurvey('Yes'));
        
        Test.startTest();
            Set<Client_Sat_Survey__c> declinedCSSet = DAOH_ClientSatSurvey.filterSurvey_DeclinedSurveys(listOfSurveys, oldMapOfSurveys);
        Test.stopTest();
        
        System.assertEquals(false, declinedCSSet.size() > 0, 'Did not get declined Client Sat Survey set');
    }
    
    @IsTest
    private static void testUpdateSurvey_DeclinedSurveyApproversShouldSetApprover() {
        insertGroup();
        Set<Client_Sat_Survey__c> csSet = new Set<Client_Sat_Survey__c>();
        csSet.addAll(getClientSatSurveys());
        Test.startTest();
            DAOH_ClientSatSurvey.updateSurvey_DeclinedSurveyApprovers(csSet);
        Test.stopTest();
        
        Client_Sat_Survey__c clientSatSurvey = new List<Client_Sat_Survey__c> ( csSet )[0];
        
        System.assertEquals(true, clientSatSurvey.Declined_Survey_Approver_Group_ID__c != null, 'Set approver');
    }
  
    @IsTest
    private static void testUpdateSurvey_DeclinedSurveyApproversShouldNotSetApprover() {
        Set<Client_Sat_Survey__c> csSet = new Set<Client_Sat_Survey__c>();
        csSet.addAll(getClientSatSurveys());
        
        DeclinedSurveyApproverGroup__c declinedApproverGroup = getDeclinedApproverGroupByOfferingType('')[0];
        declinedApproverGroup.DeclinedSurveyApproverGroup__c = 'Test';
        update declinedApproverGroup;
        
        Test.startTest();
            DAOH_ClientSatSurvey.updateSurvey_DeclinedSurveyApprovers(csSet);
        Test.stopTest();
        
        Client_Sat_Survey__c clientSatSurvey = new List<Client_Sat_Survey__c> ( csSet )[0];
        
        System.assertEquals(true, clientSatSurvey.Declined_Survey_Approver_Group_ID__c == null, 'Did not set approver');
    }
    
    @IsTest
    private static void testGetApproverGroupNameShouldGiveApprover() {
        Test.startTest();
            String approverName = DAOH_ClientSatSurvey.getApproverGroupName('Consumer Health', 'Canada', 'Canada', 'Canada',
                                                                           '', '','');
        Test.stopTest();
        
        System.assertEquals('Test Group', approverName, 'Got approver Name');
    }
    
    @IsTest
    private static void testGetApproverGroupNameShouldGiveSurveyApprover() {
        Test.startTest();
            String approverName = DAOH_ClientSatSurvey.getApproverGroupName('Test Offering', 'Test User Country',
                                                                            'Test Business Unit', 'Test Main Delivery Country',
                                                                            '','','');
        Test.stopTest();
        
        System.assertEquals('Test Group', approverName, 'Got approver Name');
    }

    @IsTest
    private static void testGetApproverGroupNameShouldGiveDefaultApprover() {
        DeclinedSurveyApproverGroup__c declinedApproverGroup = getDeclinedApproverGroupByOfferingType('')[0];
        delete declinedApproverGroup;
        
        Test.startTest();
            String approverName = DAOH_ClientSatSurvey.getApproverGroupName('Test Offering', 'Test User Country',
                                                                            'Test Business Unit', 'Test Main Delivery Country',
                                                                            '','','');
        Test.stopTest();
        
        System.assertEquals('Client Sat Admins', approverName, 'Got approver Name');
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
    private static void testValidateSurvey_SurveyExists() {
        List<Client_Sat_Survey__c> listOfSurveys = getClientSatSurveys();
        Date Date6Back = Date.today().addMonths(-6);        
        Test.startTest();
            DAOH_ClientSatSurvey.validateSurvey_SurveyExists(listOfSurveys);   
        Test.stopTest();
        
        System.assertEquals(true, listOfSurveys[0].CreatedDate > Date6Back, 'Survey has already been created within last 6 months.');
    }
    
    @IsTest
    private static void testUpdateSurvey_OpportunityProductCodesShouldUpdate() {
        List<Client_Sat_Survey__c> listOfSurveys = getClientSatSurveys();
            
        Test.startTest();
            DAOH_ClientSatSurvey.updateSurvey_OpportunityProductCodes(listOfSurveys);   
        Test.stopTest(); 
        
        System.assertEquals(true, listOfSurveys[0].Opportunity_Product_Codes__c != null, 'Updated Opportunity Product Code');
    }
    
    @IsTest
    private static void testValidateSurvey_HasBillableProject() {
        List<Client_Sat_Survey__c> listOfSurveys = getClientSatSurveys();
        Boolean isExceptionThrown = false;
        Test.startTest();
        try{
            DAOH_ClientSatSurvey.validateSurvey_HasBillableProject(listOfSurveys);            
        } catch(Exception ex) {
            isExceptionThrown = ex.getMessage().contains(CON_Qualtrics.OPPORTUNITY_ATLEAST_HAVE_ONE_BILLABLE_PROJECT_ERROR_MSG) ? true : false;
        }
        Test.stopTest();
        
        System.assertEquals(false, isExceptionThrown, 'Survey has billable project');
    }
	*/
}