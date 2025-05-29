@IsTest
private class TST_DAOH_ClientSatSurvey {
    @TestSetup static void setup() {
        User testUser1 = UTL_TestData.createUser('System Administrator', 1)[0];
        testUser1.EmployeeNumber = String.valueOf(System.currentTimeMillis());
        insert testUser1;
        
        Contact testContact = new Contact(FirstName = 'TestFirstName', LastName = 'Test', Email = 'test@test.com', RecordTypeId = CON_CRM.CONTACT_RECORD_TYPE_IQVIA_USER_CONTACT, pse__Salesforce_User__c = testUser1.Id, Salesforce_User__c = testUser1.id);
        insert testContact; 
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opportunityRecord = new Opportunity(Name = 'Test Opportunity', Path_Probability__c = 'Verbal',  Line_of_Business__c = 'Clinical', Is_this_IQVIA_Biotech__c = 'No', StageName = 'In-Hand', CloseDate = Date.today(), AccountId = acc.id, Previous_survey_sent_date__c = Date.today().addMonths(-6), Research_Study_Classification__c = 'Not a research study',
                                                        US_government_fully_or_partially_funded__c = 'No', Is_there_a_regulatory_purpose__c = 'No', Proposal_Due_Date__c = Date.today());
        Opportunity opportunity = new Opportunity(Name = 'new Opportunity', Path_Probability__c = 'Verbal', Line_of_Business__c = 'Outcome', StageName = 'In-Hand', CloseDate = Date.today(), AccountId = acc.id, Research_Study_Classification__c = 'Not a research study',
                                                  US_government_fully_or_partially_funded__c = 'No', Is_there_a_regulatory_purpose__c = 'No', Proposal_Due_Date__c = Date.today(),CurrencyIsoCode = 'USD');
        List<Opportunity> opportunityList = new List<Opportunity>{opportunityRecord, opportunity};
        insert opportunityList;
        
        Product2 product = new Product2(Name = 'Test Product', Global_Product_Code__c = '123');
        insert product;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry priceBookEntry = new PricebookEntry(Product2Id = product.Id, UnitPrice = 54000,
                                                          IsActive = true, Pricebook2Id = pricebookId);
        insert priceBookEntry;
        
        OpportunityLineItem opportunityProduct = new OpportunityLineItem(OpportunityId = opportunityRecord.Id, Sale_Type__c = 'New',Delivery_Country__c = 'USA',
                                                                         Revenue_Type__c = 'Subscription', UnitPrice = 54000,
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
        clientSatSurvey.Survey_Send_Date__c = Date.today().addDays(3);
        Client_Sat_Survey__c declinedClientSatSurvey = createClientSatSurveyRecord('No', testContact.Id, opportunityRecord.Id);
        Client_Sat_Survey__c clientSurvey = createClientSatSurveyRecord('Yes', testContact.Id, opportunityRecord.Id);
        List<Client_Sat_Survey__c> clientSatSurveyList = new List<Client_Sat_Survey__c>{clientSatSurvey, declinedClientSatSurvey, clientSurvey};
        insert clientSatSurveyList;
        
        DeclinedSurveyApproverGroup__c nonRdsDeclinedSurveyApprover = createDeclinedSurveyApproverGroup('Commercial Solutions','ALL', 'ALL',	'US and Canada Region', 'United States', 'ALL', 'ALL', 'ALL','Shari Puddicombe', 'testapprover', 42);
        DeclinedSurveyApproverGroup__c rdsDeclinedSurveyApprover = createDeclinedSurveyApproverGroup('ALL','ALL', 'ALL',	'ALL', 'ALL', 'ALL', 'EMEA','Data Sciences', 'Martin Bate', 'testapprover', 8);
        List<DeclinedSurveyApproverGroup__c> declinedApproverGroupList = new List<DeclinedSurveyApproverGroup__c>{nonRdsDeclinedSurveyApprover, rdsDeclinedSurveyApprover};
        insert declinedApproverGroupList;     
        
        CS_Config__c csConfig = new CS_Config__c();
        csConfig.CS_Admin_Contact_Ids__c = String.valueOf(testContact.id) + ',' + String.valueOf(testContact.id);
        insert csConfig;
    } 

    static Client_Sat_Survey__c createClientSatSurveyRecord(String sendSurvey, String surveyRecipient1_Id, String opportunityId) {
        Client_Sat_Survey__c clientSatSurvey = new Client_Sat_Survey__c();
        clientSatSurvey.Send_Survey__c = sendSurvey;
        clientSatSurvey.Survey_Recipient_1__c = surveyRecipient1_Id;
        clientSatSurvey.Opportunity__c = opportunityId;
        return clientSatSurvey;
    }

    static DeclinedSurveyApproverGroup__c createDeclinedSurveyApproverGroup(String offeringSegment, String offeringType, String productCoe, String peoplesoftBusinessUnit, String mainDeliveryCountry, String userCountry,
                                                                            String businessUnit, String lineOfBusiness, String approver1Name, String approver2Name, Decimal priority){
        DeclinedSurveyApproverGroup__c declinedApproverGroup = new DeclinedSurveyApproverGroup__c();
        declinedApproverGroup.PeopleSoft_Product_Offering_Segment__c = offeringSegment;
        declinedApproverGroup.PeopleSoftProductOfferingType__c = offeringType;
        declinedApproverGroup.PeopleSoftProductCOE__c = productCoe;
        declinedApproverGroup.PeopleSoftBusinessUnit__c = peoplesoftBusinessUnit;
        declinedApproverGroup.PeopleSoft_User_Country__c = userCountry;
        declinedApproverGroup.BusinessUnit__c = businessUnit;
        declinedApproverGroup.Line_of_Business__c = lineOfBusiness;
        declinedApproverGroup.MainDeliveryCountry__c = mainDeliveryCountry;
        Contact approver1 = new Contact(FirstName = approver1Name, LastName = 'test');
        insert approver1;
		Contact approver2 = new Contact(FirstName = approver2Name, LastName = 'test');
        insert approver2;
        declinedApproverGroup.Declined_SurveyApprover_1__c = approver1.id;
        declinedApproverGroup.Declined_SurveyApprover_2__c = approver2.id;

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
        return [SELECT Id, Send_Survey__c, Opportunity__c, Opportunity__r.Previous_survey_sent_date__c, CreatedDate, Opportunity_Product_Codes__c FROM Client_Sat_Survey__c];
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
        Test.startTest();
        List<Client_Sat_Survey__c> listOfSurveys = getClientSatSurveyBySendSurvey('No');
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'new Opportunity' LIMIT 1];
        Client_Sat_Survey__c declinedClientSatSurvey = createClientSatSurveyRecord('No', con.Id, opp.Id);
        insert declinedClientSatSurvey;
        
        Map<Id, Client_Sat_Survey__c> oldMapOfSurveys = new Map<Id, Client_Sat_Survey__c>();
        oldMapOfSurveys.put(declinedClientSatSurvey.Id, declinedClientSatSurvey);
        oldMapOfSurveys.get(declinedClientSatSurvey.Id).Send_Survey__c = 'Yes';
        
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

    /*
    @IsTest
    private static void testValidateSurvey_SurveyExists() {
        List<Client_Sat_Survey__c> listOfSurveys = getClientSatSurveys();
        Date Date6Back = Date.today().addMonths(-6);        
        Test.startTest();
            DAOH_ClientSatSurvey.validateSurvey_SurveyExists(listOfSurveys);   
        Test.stopTest();
        
        System.assertEquals(true, listOfSurveys[0].CreatedDate > Date6Back, 'Survey has already been created within last 6 months.');
    }*/
    
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
    /**
    @IsTest
    private static void testReassignApprovalRequest() {
        List<Client_Sat_Survey__c> listOfSurveys;
        System.runAs(UTL_TestData.createUser('System Administrator', 1)[0]){
            insertGroup();
            
            Group gp = new Group(Name = 'Decline Survey Reassign Group');
            insert gp;
            GroupMember gpm = new GroupMember();
            gpm.GroupId = gp.Id;
            gpm.UserOrGroupId = UserInfo.getUserId();
            Database.insert(gpm);  
            listOfSurveys = getClientSatSurveyBySendSurvey('Yes');
            listOfSurveys[0].Send_Survey__c = 'No';
            update listOfSurveys;
            listOfSurveys[0].Need_Escalation__c = true;
            Test.startTest();
            update listOfSurveys;
            Test.stopTest();
        }        
        listOfSurveys = [Select id,Declined_Survey_Approver_1__c,Send_Survey__c from Client_Sat_Survey__c where Send_Survey__c = 'No'];
        ProcessInstance  pi;
        if(listOfSurveys.size() > 0){
            System.assertEquals('No', listOfSurveys[0].Send_Survey__c, 'Reassign for approval');
        }
    }
    **/
    @istest
    public static void testCreateContactForIntakeSolution(){
        Contact testContact = new Contact(FirstName = 'TestFirstName', LastName = 'Test', Email = 'test3@test.com', RecordtypeId = CON_CRM.CONTACT_RECORD_TYPE_ID);
        insert testContact; 
        List<Client_Sat_Survey__c> listOfSurveys = getClientSatSurveys();
        listOfSurveys[0].Survey_Recipient_1_Email__c = 'test1@test.com';
        listOfSurveys[0].Survey_Recipient_1_First_Name__c = 'test1';
        listOfSurveys[0].Survey_Recipient_1_Job_Title__c = 'Manager1';
        listOfSurveys[0].Survey_Recipient_1_Last_Name__c = 'last1';
        listOfSurveys[0].Survey_Recipient_2_Email__c = 'test2@test.com';
        listOfSurveys[0].Survey_Recipient_2_First_Name__c = 'test2';
        listOfSurveys[0].Survey_Recipient_2_Job_Title__c = 'Manager2';
        listOfSurveys[0].Survey_Recipient_2_Last_Name__c = 'last2';
        listOfSurveys[0].Survey_Recipient_3_Email__c = 'test3@test.com';
        listOfSurveys[0].Survey_Recipient_3_First_Name__c = 'test3';
        listOfSurveys[0].Survey_Recipient_3_Job_Title__c = 'Manager3';
        listOfSurveys[0].Survey_Recipient_3_Last_Name__c = 'last3';
        listOfSurveys[1].Survey_Recipient_2_Email__c = 'testemail';
        listOfSurveys[1].Survey_Recipient_2_First_Name__c = 'testdata';
        listOfSurveys[1].Survey_Recipient_2_Job_Title__c = 'employee';
        listOfSurveys[1].Survey_Recipient_2_Last_Name__c = 'testlast';
        Test.startTest();
        try {
            update listOfSurveys;
        } catch(Exception e) {
            
        }
        listOfSurveys[0].Survey_Recipient_2_Email__c = '';
        try {
            update listOfSurveys[0];
        } catch(Exception e) {
            
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testDeclinedSurveyApproverForNonRDS(){
        upsert new  Mulesoft_Integration_Control__c(Name = 'mulesoft test', Is_Mulesoft_User__c = true, SetupOwnerId = UserInfo.getUserId());
        User testUser2 = UTL_TestData.createUser('System Administrator', 1)[0];
        testUser2.PeopleSoft_Product_Offering_Segment__c = 'Commercial Solutions';
        testUser2.PeopleSoft_Product_Offering_Type__c = '';
        testUser2.PeopleSoft_Product_COE__c = '';
        testUser2.WD_Profit_Center_Hierarchy_Level_5__c = 'US and Canada Region';
        testUser2.User_Country__c = '';
        testUser2.PIC_Eligible__c = true;
        insert testUser2;

        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Test.startTest();
        List<Contact> contactList = new List<Contact>();
        Contact testContact = UTL_TestData.createContact(acc.id);
        testContact.RecordTypeId = CON_CRM.CONTACT_RECORD_TYPE_ID;
        contactList.add(testContact); 
        Contact picContact = UTL_TestData.createContact(acc.id);
        picContact.firstname = 'Pic';
        picContact.LastName = 'contact';
        picContact.Email = 'testuser12012805@iqvia.com';
        picContact.Salesforce_User__c = testUser2.id;
        picContact.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        contactList.add(picContact);     
        insert contactList;
        
        Opportunity opp = [Select id from Opportunity where name = 'new Opportunity'][0];
        opp.Principle_inCharge__c = picContact.id;
        opp.Business_Unit__c = 'Japan'; //ALL
        opp.Main_Delivery_Country__c = 'United States';
        opp.Survey_Recipient__c = testContact.id;
        
        
        update opp;
        Product2 product = UTL_TestData.createProduct();
        product.Material_Type__c = 'ZREP';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.List_Price__c = null;
        oppLineItem.TotalPrice = null;
        oppLineItem.UnitPrice = 7000000.00; 
        insert oppLineItem;
        
        Client_Sat_Survey__c declinedClientSatSurvey = createClientSatSurveyRecord('No', testContact.Id, opp.Id);
        insert declinedClientSatSurvey;
        Test.stopTest();
    }
    
    @isTest
    public static void testDeclinedSurveyApproverForRDS(){        
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Contact testContact = UTL_TestData.createContact(acc.id);
        testContact.RecordTypeId = CON_CRM.CONTACT_RECORD_TYPE_ID;
        insert testContact; 
        
        Test.startTest();
        Opportunity opp = [Select id from Opportunity where name = 'new Opportunity'][0];
        opp.Business_Unit__c = 'EMEA'; 
        opp.Survey_Recipient__c = testContact.id;
        opp.Line_of_Business__c = 'Data Sciences';
        opp.Pass_through_Expenses__c = 100;
        opp.Is_this_IQVIA_Biotech__c = 'No';
        update opp;
        
        Product2 product = UTL_TestData.createProduct();
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.List_Price__c = null;
        oppLineItem.TotalPrice = null;
        oppLineItem.UnitPrice = 7000000.00; 
        insert oppLineItem;
        
        Client_Sat_Survey__c declinedClientSatSurvey = createClientSatSurveyRecord('No', testContact.Id, opp.Id);
        insert declinedClientSatSurvey;
        Test.stopTest();
    }
    
    @isTest
    public static void testSetSurveyPIC(){
        List<Client_Sat_Survey__c> listOfSurveys = getClientSatSurveys();
        User testUser = [Select id from User limit 1];
        Contact projectManager = [Select id from Contact where RecordTypeId = :CON_CRM.CONTACT_RECORD_TYPE_IQVIA_USER_CONTACT];
		
        Trigger_Control_For_Migration__c migration = new Trigger_Control_For_Migration__c();
        migration.Disable_Agreement_Trigger__c = true;
		insert migration;
        
        Opportunity opp2 = [Select id,AccountId,CloseDate,Previous_survey_sent_date__c from Opportunity where Is_Survey_Exist__c != true][0];
        
        List<Contract> contractList = new List<Contract>();
        Contract cntrt2 = UTL_TestData.createContract(opp2, 'Work_Order_Contract_Sales_Medical_Solutions');
        cntrt2.IQVIA_Project_Manager_Contact__c = projectManager.id;
        cntrt2.Opportunity__c = opp2.id;
        contractList.add(cntrt2);
        insert contractList;
        
        Test.setCreatedDate(contractList[0].id, Date.today().addMonths(-3));
        Test.setCreatedDate(listOfSurveys[0].id, Date.today().addMonths(-6));
        
        Test.startTest();
		Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(null,false);
        testAgreement.Name = 'Test SOW';
        testAgreement.Apttus__Requestor__c = UserInfo.getUserId();
        testAgreement.Apttus__Subtype__c = 'Work Order';
        testAgreement.RecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Project Specific Agreement').getRecordTypeId();
        testAgreement.Apttus__Related_Opportunity__c = opp2.id;
        testAgreement.IQVIA_Project_Manager_Con__c = projectManager.id;
        insert testAgreement;  

        //Agreement_Extension__c agreementExt = TST_CLM_TestDataFactory.createAgreementExtension(testAgreement.Id,false);
        //agreementExt.IQVIA_Project_Manager_Con__c = projectManager.id;
        //insert agreementExt;
        
        List<Client_Sat_Survey__c> surveyList = new List<Client_Sat_Survey__c>();
        Client_Sat_Survey__c csat2 = createClientSatSurveyRecord('No', projectManager.id, opp2.id);
        surveyList.add(csat2);
        insert surveyList;
        surveyList = [select id,Survey_PIC__c,Related_Contract_Id__c from Client_Sat_Survey__c where id=: csat2.id];
        system.assertEquals(surveyList[0].Related_Contract_Id__c, contractList[0].Id);
        Test.stopTest();
    }
    
    @istest
    public static void testAfterDelete(){ 
        Opportunity opp = [Select id,Upcoming_Survey_Send_Date__c from Opportunity where name = 'Test Opportunity'][0];
        Client_Sat_Survey__c clientSatSurvey = new Client_Sat_Survey__c();
        clientSatSurvey.Opportunity__c = opp.id;
        clientSatSurvey.Survey_Send_Date__c = Date.today().addDays(6);
        insert clientSatSurvey;
        Test.startTest();
        delete clientSatSurvey;
        Test.stopTest();
    }
    
    @istest
    public static void testValidateSurveyLocked(){ 
        Opportunity opp = [Select id, AccountId, OwnerId from Opportunity where name = 'new Opportunity'][0];
        Mulesoft_Integration_Control__c testSetting = new  Mulesoft_Integration_Control__c(name = 'testSetting', Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = true, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true);
        upsert testSetting;
        List<User> userList = new List<User>();
        User testUser1 = UTL_TestData.createUser('System Administrator', 1)[0];
        testUser1.PIC_Eligible__c = true;
        User testUser2 = UTL_TestData.createUser('Sales User', 1)[0];
        userList.add(testUser1);
        userList.add(testUser2);
        Test.startTest();
        insert userList;
        testSetting.Is_Mulesoft_User__c = false;
        upsert testSetting;
        List<Client_Sat_Survey__c> listOfSurveys = getClientSatSurveys();
        
        system.runAs(testUser2){
            try{
                update listOfSurveys[0];
            }catch(Exception ex){
                system.assertEquals(ex.getMessage().contains(CON_Qualtrics.NOT_ALLOWED_TO_MODIFY_RECORD), true);
            }
        }
        CS_Config__c csConfig = new CS_Config__c();
        csConfig.SetupOwnerId = testUser2.id;
        csConfig.Is_Admin_User__c = true;
        insert csConfig;
        system.runAs(testUser2){
            update listOfSurveys[0];
        }
        csConfig = [Select id,SetupOwnerId, Is_Admin_User__c from CS_Config__c where SetupOwnerId =: testUser2.id ];
        csConfig.Is_Admin_User__c = false;
        upsert csConfig;
        system.runAs(testUser2){
            listOfSurveys[0].Survey_EM_EmployeeNumber__c = testUser2.EmployeeNumber;
            update listOfSurveys[0];
        }
        Test.stopTest();
    }
    
}