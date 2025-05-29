/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TST_BNF_Limit {

    private static Opportunity TestOpp;
    private static List<Opportunity> Opportunity_Array;
    private static BNF2__c TestBnf;
    private static Account NewAccount;
    private static User TestUser; 
    private static Revenue_Analyst__c TestRA;
    
    static void SetupExistingOpps()
    {
        TestUser = [select Id from User where Profile.Name like '%sales%' and IsActive = true limit 1];
        NewAccount = new Account();
        NewAccount.Name = 'Test Account';
        NewAccount.OwnerId = TestUser.Id;
        NewAccount.CustomerSegment__c = 'GOVERNMENT';
        NewAccount.Sub_Industry__c = 'STATE';
        insert NewAccount;

        TestRa = new Revenue_Analyst__c(name='TestRA',User__c = TestUser.Id);
        insert TestRa;
        
        AccountTeamMember ATM = new AccountTeamMember(AccountId=NewAccount.Id,UserId=TestRa.User__c);
        insert ATM;
        
        AccountShare AccShare = [Select Id, AccountId, UserOrGroupId, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, RowCause, LastModifiedDate, LastModifiedById FROM AccountShare WHERE RowCause = 'Team' AND AccountId = :NewAccount.Id and UserOrGroupId=:TestRa.User__c limit 1];
        AccShare.AccountAccessLevel = 'Edit';
        AccShare.OpportunityAccessLevel = 'Edit';
        update AccShare;
        
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        Opportunity_Array = new List<Opportunity>();
        TestOpp = new Opportunity(Name='test',StageName='1. Identifying Opportunity',CloseDate=System.today());
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.Budget_Available__c = 'Yes';
        //TestOpp.Unique_Business_Value__c = 'Unknown';
        //TestOpp.Compelling_Event__c = 'No';
        TestOpp.StageName='5. Finalizing Deal';
        TestOpp.AccountId = NewAccount.Id;
        TestOpp.Contract_Term__c='Single-Period';
        TestOpp.Contract_End_Date__c = system.today();
        TestOpp.Contract_Start_Date__c = system.today();
        //TestOpp.Win_Loss_Reason__c='Win - Competitive Situation';
        TestOpp.Contract_Type__c='Individual';
        TestOpp.LeadSource = 'Account Planning';
        //TestOpp.Win_Additional_Details__c = 'Additional details';
        //TestOpp.Win_Loss_Reason_Details__c = 'Win Loss Reason Details'; 
        TestOpp.CurrencyIsoCode = 'USD';
        TestOpp.OwnerId = TestUser.Id;
        TestOpp.Potential_Competitor_1__c = comp.Id;
        Opportunity_Array.add(TestOpp);
        insert TestOpp;        
    }
    
	static void AddLineItems()
	{
    	OpportunityLineItem OLI1 = new OpportunityLineItem();
        OLI1.OpportunityId = TestOpp.Id;
		OLI1.Delivery_Country__c = 'USA';
        Product2 Product1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZPUP');
        insert product1;
        PricebookEntry pbe = new PricebookEntry();
        pbe.UseStandardPrice = false;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id=Product1.id;
        pbe.IsActive=true;
        pbe.UnitPrice=100.0;
        pbe.CurrencyIsoCode = 'USD';
        insert pbe;
        //PricebookEntry PE1 = [select Id, CurrencyIsoCode from PricebookEntry where CurrencyIsoCode = 'USD' and IsActive = true and Product2.IsActive = true and Product2.Material_Type__c = 'ZPUB' limit 1][0];
        OLI1.PricebookEntryId = pbe.Id;
        OLI1.Quantity = 1.00;
        OLI1.UnitPrice = 10000;
        OLI1.Sale_Type__c = 'New';
        OLI1.Revenue_Type__c = 'Ad Hoc';
  		insert OLI1;
        //insert OLI1;
     	TestBnf = new BNF2__c(Opportunity__c=TestOpp.Id);
		TestBnf.BNF_Status__c = MDM_Defines.BnfStatus_Map.get('NEW');
		TestBnf.Sales_Org_Code__c = 'ES51';
		TestBnf.IMS_Sales_Org__c = 'IMS Spain';
		TestBnf.RecordTypeId = MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
		TestBnf.Revenue_Analyst__c = TestRa.Id;
		insert TestBnf;
	}
    
    static testMethod void BnfLimitTest() {
        SetupExistingOpps();
        AddLineItems();
         // Submit the approval request for the BNF
        try
        {
            BNF2__c TestBnf1 = new BNF2__c(Opportunity__c=TestOpp.Id);
            TestBnf1.BNF_Status__c = MDM_Defines.BnfStatus_Map.get('NEW');
            TestBnf1.Sales_Org_Code__c = 'ES51';
            TestBnf1.IMS_Sales_Org__c = 'IMS Spain';
            TestBnf1.RecordTypeId = MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
            TestBnf1.Revenue_Analyst__c = TestRa.Id;
            insert TestBnf1;
        }
        catch (Exception E)
        {
            system.debug('E.getMessage(): '+ E.getMessage());
            system.assert(E.getMessage().contains('Only one BNF can be created per opportunity.  To create a revised BNF ensure that the "Revised BNF" is selected.'));
        }
    }
}