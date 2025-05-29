@isTest
public class TST_TGR_Update_Survey_Event {
    
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
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        insert product;
        PricebookEntry priceBookEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert priceBookEntry;
        
        OpportunityLineItem opportunityProduct = UTL_TestData.createOpportunityLineItem(opportunityRecord.Id, priceBookEntry.Id);
        opportunityProduct.LI_OpportunityLineItem_Id__c = opportunityRecord.Id;
        insert opportunityProduct;  

        Proxy_Project__c project = new Proxy_Project__c(Is_Project_Billable__c = true, Opportunity__c = opportunityRecord.Id, Project_Start_Date__c = Date.today().addYears(-2), LI_Record_Id__c = '121',
                                                        Project_End_Date__c = Date.today().addDays(-3), Delivery_PIC_Name__c = testContact.Name, Record_Type_Name__c = CON_Qualtrics.RECORD_TYPE_ENGAGEMENT);
        Proxy_Project__c projectRecord = new Proxy_Project__c(Is_Project_Billable__c = false, Opportunity__c = opportunityRecord.Id, Project_End_Date__c = Date.today().addYears(-1), LI_Record_Id__c = '123',
                                                              Project_Start_Date__c = Date.today().addYears(-2), Delivery_PIC_Name__c = testContact.Name, Record_Type_Name__c = CON_Qualtrics.RECORD_TYPE_ENGAGEMENT);
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
    
    public static Client_Sat_Survey__c createClientSatSurveyRecord(String sendSurvey, String surveyRecipient1_Id, String opportunityId) {
        Client_Sat_Survey__c clientSatSurvey = new Client_Sat_Survey__c();
        clientSatSurvey.Send_Survey__c = sendSurvey;
        clientSatSurvey.Survey_Recipient_1__c = surveyRecipient1_Id;
        clientSatSurvey.Opportunity__c = opportunityId;
        return clientSatSurvey;
    }
    
    static DeclinedSurveyApproverGroup__c createDeclinedSurveyApproverGroup(String offeringSegment, String offeringType, String productCoe, String peoplesoftBusinessUnit, String mainDeliveryCountry, String userCountry, String businessUnit, String lineOfBusiness, String approver1Name, String approver2Name, Decimal priority){
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
    
    
    
    @isTest
    public static void testFromAgr(){
        List<Client_Sat_Survey__c> listOfSurveys = [SELECT Id, Send_Survey__c, Opportunity__c, Opportunity__r.Previous_survey_sent_date__c, CreatedDate, Opportunity_Product_Codes__c FROM Client_Sat_Survey__c];
        User testUser = [Select id from User limit 1];
        Contact projectManager = [Select id from Contact where RecordTypeId = :CON_CRM.CONTACT_RECORD_TYPE_IQVIA_USER_CONTACT];
        
        Trigger_Control_For_Migration__c migration = new Trigger_Control_For_Migration__c();
        migration.Disable_Agreement_Trigger__c = true;
        insert migration;
        
        Opportunity opp2 = [Select id,AccountId,CloseDate,Previous_survey_sent_date__c from Opportunity where Is_Survey_Exist__c != true][0];
        Test.startTest();
        List<Contract> contractList = new List<Contract>();
        Contract cntrt2 = UTL_TestData.createContract(opp2, 'Work_Order_Contract_Sales_Medical_Solutions');
        cntrt2.IQVIA_Project_Manager_Contact__c = projectManager.id;
        cntrt2.Opportunity__c = opp2.id;
        contractList.add(cntrt2);
        insert contractList;
        
        Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(null,false);
        testAgreement.Name = 'Test SOW';
        testAgreement.Apttus__Requestor__c = UserInfo.getUserId();
        testAgreement.Apttus__Subtype__c = 'Work Order';
        testAgreement.RecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Project Specific Agreement').getRecordTypeId();
        testAgreement.Apttus__Related_Opportunity__c = opp2.id;
        testAgreement.IQVIA_Project_Manager_Con__c = projectManager.id;
        insert testAgreement;  
        
        List<Client_Sat_Survey__c> surveyList = new List<Client_Sat_Survey__c>();
        Client_Sat_Survey__c csat2 = createClientSatSurveyRecord('No', projectManager.id, opp2.id);
        surveyList.add(csat2);
        insert surveyList;
        surveyList = [select id,Survey_PIC__c,Related_Contract_Id__c from Client_Sat_Survey__c where id=: csat2.id];
        system.assertEquals(surveyList[0].Related_Contract_Id__c, contractList[0].Id);
        Test.stopTest();
    }
    
    
    @isTest
    public static void testFromProxyProject() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Proxy_Project__c proxyProject = UTL_TestData.createProxyProject(opp.id);
        proxyProject.Record_Type_Name__c = 'Engagement';
        insert proxyProject;
        Client_Sat_Survey__c clientSatSurvey = new Client_Sat_Survey__c();
        clientSatSurvey.Opportunity__c = opp.Id;
        clientSatSurvey.Survey_Recipient_1__c = con.Id;
        insert clientSatSurvey;
        proxyProject.Delivery_PIC_Name__c = 'Test User';
        update proxyProject;
        Test.stopTest();
    }
    
}