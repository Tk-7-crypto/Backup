@istest
public class TST_BCH_CRMINT_PopulateSurveyDates {

    @TestSetup static void setup() {
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(Name = 'Product X',ProductCode = 'Pro-X',isActive = true, Offering_Type__c ='Commercial Tech',Material_Type__c='ZREP',Offering_Segment__c='Commercial Solutions', Billing_System__c = 'PeopleSoft');
        prod.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        insert prod;
        PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId,Product2Id = prod.Id,UnitPrice = 100.00,IsActive = true);
        insert pbEntry;
        List<User> users = UTL_TestData.createUser('System Administrator', 1);
        insert users;
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact con = UTL_TestData.createContact(acc.Id);
        con.RecordTypeId = CON_CRM.CONTACT_RECORD_TYPE_ID;
        con.Salesforce_User__c = users[0].Id;
        con.Survey_Opt_Out__c = false;
        insert con;
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Test Indication', 'Acute Care');
        insert indication;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        Opportunity nonrds = new Opportunity(Name = 'Test Opportunity', StageName = 'In-Hand', CloseDate = Date.today(),
                                                     Actual_Close_Date__c = Date.today().addDays(-30), Conversion_Rate_To_USD__c = 1,   accountId = acc.Id,
                                                     Survey_Recipient__c = con.Id ,Contract_Start_Date__c = Date.today().addYears(-1), Contract_End_Date__c = Date.today(), Potential_Competitor_1__c = comp.Id, 
                                                     Previous_survey_sent_date__c = Date.today().addMonths(-12), Early_Engagement_COE__c = 'Not Applicable', Proposal_Sent_Date__c =Date.today(),
                                                     Path_Probability__c = 'Verbal', Research_Study_Classification__c = 'Not a research study',Indication_List__c = indication.Id,Phase_P__c =  'Phase 1',
                                                     US_government_fully_or_partially_funded__c = 'No', Is_there_a_regulatory_purpose__c = 'No', Proposal_Due_Date__c = Date.today());
        Opportunity rdsWithLOB = new Opportunity(Name = 'Test Opportunity', StageName = '7a. Closed Won',Is_this_IQVIA_Biotech__c = 'No' ,CloseDate = Date.today(),
                                                        Actual_Close_Date__c = Date.today().addDays(-30),Conversion_Rate_To_USD__c = 1,  accountId = acc.Id,
                                                        Survey_Recipient__c = con.Id, Awarded_Date__c = Date.today().addYears(-1).addDays(-2),Signed_Contract_Date__c = Date.today(),
                                                        Line_of_Business__c = 'Clinical', Contract_Start_Date__c = Date.today().addYears(-1), Contract_End_Date__c = Date.today(),
                                                        Previous_survey_sent_date__c = Date.today().addMonths(-6), Expected_Project_Start_Date__c = Date.today().addYears(-1), Potential_Competitor_1__c = comp.Id, 
                                                        Expected_Project_End_Date__c = Date.today(), Proposal_Sent_Date__c = system.today(), Early_Engagement_COE__c = 'Not Applicable',
                                                        Path_Probability__c = 'Verbal', Research_Study_Classification__c = 'Not a research study',Indication_List__c = indication.Id,Phase_P__c =  'Phase 1',
                                                        US_government_fully_or_partially_funded__c = 'No', Is_there_a_regulatory_purpose__c = 'No', Proposal_Due_Date__c = Date.today());
         Opportunity rdswithoutLOB = new Opportunity(Name = 'Test Opportunity', StageName = '7a. Closed Won' ,CloseDate = Date.today(),
                                                        Actual_Close_Date__c = Date.today().addDays(-30),Conversion_Rate_To_USD__c = 1,  accountId = acc.Id,
                                                        Survey_Recipient__c = con.Id, Awarded_Date__c = Date.today().addYears(-1).addDays(-2),Signed_Contract_Date__c = Date.today(), Potential_Competitor_1__c = comp.Id, 
                                                        Line_of_Business__c = 'Outcome', Is_this_IQVIA_Biotech__c = 'No', Contract_Start_Date__c = Date.today().addYears(-1), Contract_End_Date__c = Date.today(),
                                                        Previous_survey_sent_date__c = Date.today().addMonths(-6), Early_Engagement_COE__c = 'Not Applicable', Proposal_Sent_Date__c =Date.today(),
                                                        Path_Probability__c = 'Verbal', Research_Study_Classification__c = 'Not a research study',Indication_List__c = indication.Id,Phase_P__c =  'Phase 1',
                                                        US_government_fully_or_partially_funded__c = 'No', Is_there_a_regulatory_purpose__c = 'No', Proposal_Due_Date__c = Date.today());
        List<Opportunity> opportunityList = new List<Opportunity>{rdsWithLOB, nonrds, rdswithoutLOB};
            insert opportunityList;

        OpportunityLineItem lineItem = new OpportunityLineItem(OpportunityId = nonrds.Id, pse__IsServicesProductLine__c = true,
                                                               Sale_Type__c = 'New', Revenue_Type__c= 'Ad Hoc', Quantity = 1, TotalPrice = 20000,Delivery_Country__c = 'USA',
                                                               PricebookEntryId = pbEntry.Id,Project_Start_Date__c=Date.today().addYears(-2),
                                                               Project_End_Date__c=Date.today().addYears(2), Therapy_Area__c= 'Hepatitis C [21]', Product_Material_Type_Text__c = 'ZREP');
        OpportunityLineItem lineItem2 = new OpportunityLineItem(OpportunityId = rdsWithLOB.Id, pse__IsServicesProductLine__c = true,Delivery_Country__c = 'USA',
                                                               Sale_Type__c = 'New', Revenue_Type__c= 'Ad Hoc', Quantity = 1, TotalPrice = 200000,
                                                               PricebookEntryId = pbEntry.Id,Project_Start_Date__c=Date.today().addYears(-2),
                                                               Project_End_Date__c=Date.today().addYears(2), Therapy_Area__c= 'Hepatitis C [21]', Product_Material_Type_Text__c = 'ZREP');
        OpportunityLineItem lineItem3 = new OpportunityLineItem(OpportunityId = rdswithoutLOB.Id, pse__IsServicesProductLine__c = true, Delivery_Country__c = 'USA',
                                                               Sale_Type__c = 'New', Revenue_Type__c= 'Ad Hoc', Quantity = 1, TotalPrice = 200000,
                                                               PricebookEntryId = pbEntry.Id,Project_Start_Date__c=Date.today().addYears(-2),
                                                               Project_End_Date__c=Date.today().addYears(2), Therapy_Area__c= 'Hepatitis C [21]', Product_Material_Type_Text__c = 'ZREP');
        List<OpportunityLineItem> lineItemList = new List<OpportunityLineItem>{lineItem, lineItem2, lineItem3};
        insert lineItemList;        
        Survey_Setting__c testsetting = new Survey_Setting__c();
        testsetting.Intake_Survey_Delay_Duration__c = 30;
        insert testsetting;
    }
    
    
     @IsTest
    static void testsendMailNotification() { 
        BCH_CRMINT_PopulateSurveyDates batchClass = new BCH_CRMINT_PopulateSurveyDates(Date.today(), Date.today().addDays(31));
        Test.startTest();
        BCH_CRMINT_PopulateSurveyDates.sendErrorMailNotification('','');
        List<Workflow_Email_Record__c> workflow = [select id from Workflow_Email_Record__c LIMIT 1];
        Test.stopTest();
    }
    
    @IsTest
    static void testForClientSetSurveyInsertResult() {
        
        Test.startTest();
        BCH_CRMINT_PopulateSurveyDates uca = new BCH_CRMINT_PopulateSurveyDates(Date.today(), Date.today().addDays(31));
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
    }   
}