@isTest
public class TST_DAOH_CRM_Agreement_Extension {
    
    @TestSetup static void setup() {
        /*Mulesoft_Integration_Control__c mic = new Mulesoft_Integration_Control__c();
        mic.Is_Mulesoft_User__c = true;
        mic.Allow_Opportunity_Number_Override__c = true;
        insert mic;
        
        Account acc = UTL_TestData.createAccount();
        List<User> userList = new List<User>();
        User testUser1 = UTL_TestData.createUser('System Administrator', 1)[0];
        testUser1.PIC_Eligible__c = true;
        userList.add(testUser1);
        User testUser2 = UTL_TestData.createUser('System Administrator', 1)[0];
        testUser2.PIC_Eligible__c = true;
        userList.add(testUser2);
        insert userList;
        List<Contact> testContactList = new List<Contact>();
        Contact testContact = UTL_TestData.createContact(acc.id);
        testContact.Salesforce_User__c = testUser1.id;
        testContact.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        testContactList.add(testContact);
        Contact testContact1 = UTL_TestData.createContact(acc.id);
        testContact1.Salesforce_User__c = testUser1.id;
        testContact1.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        testContactList.add(testContact1);
        insert testContactList;
        Opportunity opp = UTL_TestData.createOpportunity(acc.id);
        opp.StageName = 'In-Hand';
        opp.Line_of_Business__c = 'Biostatistical/Medical Writing';
        opp.Opportunity_Number__c = '1234567';
        opp.Mulesoft_External_Id__c = '1298';
        //opp.Principle_inCharge__c = testContact.id;
        opp.Survey_Recipient__c = testContact.id; 
        opp.Research_Study_Classification__c = 'Not a research study';
        insert opp;
        Product2 product = new Product2(Name = 'Test Product', Global_Product_Code__c = '123');
        insert product;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry priceBookEntry = new PricebookEntry(Product2Id = product.Id, UnitPrice = 54,
                                                          IsActive = true, Pricebook2Id = pricebookId);
        insert priceBookEntry;
        
        OpportunityLineItem opportunityProduct = new OpportunityLineItem(OpportunityId = opp.Id, Sale_Type__c = 'New',Delivery_Country__c = 'USA',
                                                                         Revenue_Type__c = 'Subscription', UnitPrice = 150000,
                                                                         Quantity = 1, priceBookEntryId = priceBookEntry.Id);
        insert opportunityProduct;
        
        List<Client_Sat_Survey__c> surveyList = new List<Client_Sat_Survey__c>();
        
        
        Client_Sat_Survey__c cs = UTL_TestData.createClientSatSurveyRecord('test', 'Yes', testContact.id, opp.id);
        cs.Survey_Send_Date__c = System.today();
       	insert cs;
        Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Project Specific Agreement').getRecordTypeId(),false);
        testAgreement.Name = 'Test SOW';
        testAgreement.Apttus__Requestor__c = UserInfo.getUserId();
        testAgreement.Apttus__Subtype__c = 'Work Order';
        testAgreement.Apttus__Related_Opportunity__c = opp.id;
        insert testAgreement;*/
    }
    
    @istest
    public static void testUpdateSurveyPIC(){
                /*Client_Sat_Survey__c survey = [select id, Survey_PIC__c from Client_Sat_Survey__c limit 1][0];
        Test.startTest();

        List<Contact> testContactList = [Select id from Contact];
        Apttus__APTS_Agreement__c testAgreement = [Select id from Apttus__APTS_Agreement__c limit 1];
        Agreement_Extension__c agreementExt = TST_CLM_TestDataFactory.createAgreementExtension(testAgreement.Id,false);
        agreementExt.IQVIA_Project_Manager_Con__c = testContactList[1].id;
        insert agreementExt;

        Test.stopTest();
        survey = [select id, Survey_PIC__c,Related_Contract_Id__c from Client_Sat_Survey__c][0];
        System.assertEquals(agreementExt.IQVIA_Project_Manager_Con__c, survey.Survey_PIC__c);
        System.assertEquals(agreementExt.id, survey.Related_Contract_Id__c);*/
        DAOH_CRM_Agreement_Extension.updateSurveyPIC(null, null);
    }

}