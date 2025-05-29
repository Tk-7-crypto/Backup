@IsTest
public class TST_DAOH_ClientSatSurveyRecipient {
    
    @TestSetup static void setup() {
         User testUser1 = UTL_TestData.createUser('System Administrator', 1)[0];
        testUser1.EmployeeNumber = String.valueOf(System.currentTimeMillis());
        insert testUser1;
        
        Contact testContact = new Contact(FirstName = 'TestFirstName', LastName = 'Test', Email = 'test@test.com', RecordTypeId = CON_CRM.CONTACT_RECORD_TYPE_IQVIA_USER_CONTACT, pse__Salesforce_User__c = testUser1.Id, Salesforce_User__c = testUser1.id);
        insert testContact; 
        
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Opportunity opportunityRecord = new Opportunity(Name = 'Test Opportunity', Path_Probability__c = 'Verbal',  Line_of_Business__c = 'Clinical', Is_this_IQVIA_Biotech__c = 'No', StageName = 'In-Hand', CloseDate = Date.today(), AccountId = acc.id, Previous_survey_sent_date__c = Date.today().addMonths(-6), Research_Study_Classification__c = 'Not a research study',
            Survey_Recipient__c = testContact.Id, US_government_fully_or_partially_funded__c = 'No', Is_there_a_regulatory_purpose__c = 'No', Proposal_Due_Date__c = Date.today());
        insert opportunityRecord;
        
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
        
        Client_Sat_Survey__c clientSurvey = UTL_TestData.createClientSatSurveyRecord('testSurvey', 'Yes', String.valueOf(testContact.id), String.valueOf(opportunityRecord.id));
        clientSurvey.Survey_Send_Date__c = System.today();
        insert clientSurvey;

    }
    
    @istest
    public static void testSetOppDateFields(){
        Client_Sat_Survey__c clientSurvey = [Select id from Client_Sat_Survey__c limit 1][0];
        Client_Sat_Survey_Recipient__c csRec = new Client_Sat_Survey_Recipient__c();
        csRec.Client_Sat_Survey__c = clientSurvey.id;
        Test.startTest();
        insert csRec;
        Test.stopTest();
    }
    
    @istest
    public static void testSetOppDateFieldsZREP() {
        Test.startTest();
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            Product2 product = new Product2(Name = 'Test Product', Global_Product_Code__c = '123',Material_Type__c = 'ZREP');
            insert product;
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry priceBookEntry = new PricebookEntry(Product2Id = product.Id, UnitPrice = 54,
                IsActive = true, Pricebook2Id = pricebookId);
            insert priceBookEntry;
            OpportunityLineItem opportunityProduct = new OpportunityLineItem(OpportunityId = opp.Id, Sale_Type__c = 'New',Delivery_Country__c = 'USA',
                Revenue_Type__c = 'Subscription', UnitPrice = 40000, Quantity = 1, priceBookEntryId = priceBookEntry.Id, Therapy_area__c = 'Oncology');
            insert opportunityProduct;
            Proxy_Project__c proxyProject = UTL_TestData.createProxyProject(opp.id);
            proxyProject.Record_Type_Name__c = 'Engagement';
            proxyProject.Delivery_PIC_Name__c = 'Test Shikha';
            insert proxyProject;
            Contact testContact = [SELECT ID FROM CONTACT LIMIT 1];
            Client_Sat_Survey__c clientSurvey = UTL_TestData.createClientSatSurveyRecord('testSurvey', 'Yes', String.valueOf(testContact.id), String.valueOf(opp.id));
            clientSurvey.Survey_Send_Date__c = System.today();
            insert clientSurvey;
            Client_Sat_Survey_Recipient__c csRec = new Client_Sat_Survey_Recipient__c();
            csRec.Client_Sat_Survey__c = clientSurvey.id;
            insert csRec;
        Test.stopTest();
    }

}