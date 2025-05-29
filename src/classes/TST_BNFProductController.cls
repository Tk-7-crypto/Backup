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
private class TST_BNFProductController {
 
  public static testMethod void testMyController() {
        
        Account acct1 = new Account(Name='SPO BT Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acct1;
        Opportunity oppty1 = new Opportunity(Name = 'SPO BT Test Oppty');
        oppty1.StageName = '1 - Identify Opportunity';
        oppty1.CloseDate = System.today();
        oppty1.AccountId = acct1.Id;
        //oppty1.Budget_Available__c = 'Yes';
        oppty1.CurrencyIsoCode = 'USD';
        insert oppty1;
       
         BNF2__c TestBnf = new BNF2__c(Opportunity__c=oppty1.Id);
         TestBnf.BNF_Status__c = 'New';
         TestBnf.Contract_Start_Date__c = Date.today().addYears(1);
         TestBnf.Contract_End_Date__c = Date.today().addYears(2);
         TestBnf.IMS_Sales_Org__c = 'IHA, IMS Health Rotkreuz';
         TestBnf.Sales_Org_Code__c='CH03';
         //TestBnf.RecordTypeId = MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
         TestBnf.RecordTypeId  = Schema.SObjectType.BNF2__c.getRecordTypeInfosByName().get('SAP SD Integrated').getRecordTypeId();
         insert TestBnf;
        
         BNF_Settings__c bnfSetting = BNF_Settings__c.getOrgDefaults();
         bnfSetting.Excluded_Products__c = 'ZQUI';
         upsert bnfSetting;
        
        PageReference pageRef = new PageReference('Page.BNFProductController');
        pageRef.getParameters().put('bnfid', TestBnf.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new BNF2__c());
        BNFProductController extension = new BNFProductController(controller);
        BNFProductController extension1 = new BNFProductController();
        extension.testCheck();
        
        
        
        ApexPages.currentPage().getParameters().put('bnfid',TestBnf.Id);
        PageReference dummy = extension.save();
        dummy = extension.cancel();
        extension.setDeliveryMediaOpt(true);
        
        extension.getDeliveryMediaOpt();
        extension.getBNF();
        extension.savePartial();
        extension.setTemp('Temp');
        String temp = extension.getTemp();
       }
    
/*public static testmethod void t1()
{
  CLS_ProductionReference Convertor = new CLS_ProductionReference();
  Integer iTest = Convertor.CalculateElapsedMinsThisYear();
  system.debug('Mins this year: '+ iTest.format());
  String sOutput = Convertor.ConvertToRadix34(364883);
  system.debug('Output: '+ sOutput);
  system.assertEquals('AAMV',sOutput);
}*/

public static testmethod void t2() 
  {
    Current_Release_Version__c currReleaseVersion = new Current_Release_Version__c();
    currReleaseVersion.Current_Release__c = '2019.02';
    insert currReleaseVersion;
    Datetime strDate = System.now();  
    //  Create a test account
  Account acct1 = new Account(Name='SPO BT Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
  insert acct1;
  List<Opportunity> InsertOppList = new List<Opportunity>();
  List<OpportunityLineItem> InsertOLIList = new List<OpportunityLineItem>();
  List<OpportunityLineItemSchedule> InsertOLISList = new List<OpportunityLineItemSchedule>();
  Map<String,Double> Revenue_Map = new Map<String,Double>();
  //  Setup test parameters
  Integer NumTestOpps = 10;
  Integer iNumSchedules = 18;
  for (Integer i=0;i<NumTestOpps;i++)
  {
    //  Create a test opportunity
    Opportunity oppty1 = new Opportunity(Name = 'SPO BT Test Oppty');
    oppty1.StageName = '1 - Identify Opportunity';
    oppty1.CloseDate = System.today();
    oppty1.AccountId = acct1.Id;
    //oppty1.Budget_Available__c = 'Yes';
    oppty1.CurrencyIsoCode = 'USD';
    InsertOppList.add(oppty1);
  }
  insert InsertOppList;
  
  //****Jeganmohan N 09-25-11, to resolve 'Too many SOQL queries: 101' error while PROD migration
  Set<Id> Opp_Id_Set = new Set<Id>();
  Product2 objProduct = new Product2(Name='test5', ProductCode='5', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZSET',CanUseRevenueSchedule= true);
  insert objProduct;
    PricebookEntry PE = new PricebookEntry();
    PE.UseStandardPrice = false;
    PE.Pricebook2Id= Test.getStandardPricebookId();
    PE.IsActive=true;
    PE.Product2Id = objProduct.Id;
    PE.currencyisocode='USD';
    PE.UnitPrice=100.0;
    insert PE;
  PricebookEntry PE1 = [select Id, CurrencyIsoCode from PricebookEntry where CurrencyIsoCode = 'USD' and IsActive = true limit 1][0];
  for (Opportunity NewOpp:InsertOppList)
  {
    Id opptyId = NewOpp.Id;
    Opp_Id_Set.add(opptyId);
    //  Add a line item to the opportunity
    OpportunityLineItem add1_oli = new OpportunityLineItem();
    add1_oli.OpportunityId = opptyId;    
    add1_oli.PricebookEntryId = PE1.Id;
    add1_oli.Quantity = 1.00;
    add1_oli.UnitPrice = 10000;
    add1_oli.Sale_Type__c = 'New';
    add1_oli.Revenue_Type__c = 'Ad Hoc';
    add1_oli.Delivery_Country__c = 'USA';
    InsertOLIList.add(add1_oli);
  }
  insert InsertOLIList;
  for (OpportunityLineItem OLI:InsertOLIList)
  {
    //  Create 18 schedules to cover 18 months from the first month of the current year
    Integer RevFactor = 1;
    Double dRevenueAmount = RevFactor*1000.00;
    Revenue_Map.put(OLI.Id,dRevenueAmount);
    RevFactor = RevFactor + 2;
    Date strScheduleDate = Date.valueOf(String.valueOf(strDate.year())+'-01-15 00:00:00');    
    for (Integer i = 0; i < iNumSchedules; i++) 
    {
      OpportunityLineItemSchedule OliSched = new OpportunityLineItemSchedule();
      OliSched.OpportunityLineItemId = OLI.Id;
      OliSched.Type = 'Revenue';
      OliSched.Revenue = dRevenueAmount;
      OliSched.ScheduleDate = strScheduleDate;
      strScheduleDate = strScheduleDate.addMonths(1);
      InsertOLISList.add(OliSched); 
    }
  }
  insert InsertOLISList;
  Test.startTest();
  //****Jeganmohan N 09-25-11, to resolve 'Too many SOQL queries: 101' error while PROD migration
  List<Opportunity> Opp_Array_All = new List<Opportunity>([select Id, Amount from Opportunity where Id in : Opp_Id_Set]);
  

  Set<Id> OLI_Set = new Set<Id>();
  for (OpportunityLineItem NewOLI:InsertOLIList)
  {
      OLI_Set.add(NewOLI.Id);
  }
  Map<Id,OpportunityLineItem> OLI_Map = new Map<Id,OpportunityLineItem>([select Id,OpportunityId, Delivery_Date__c from OpportunityLineItem where Id in :OLI_Set]);
  for (OpportunityLineItem NewOLI:InsertOLIList)
  {
    //  Retrieve the OpportunityLineItem which should now have been touched by the workflow
    //  which modifies the OpportunityLineItem.Schedule_Update_Dummy__c field
    OpportunityLineItem TestOli = OLI_Map.get(NewOLI.Id);
    //Opportunity TestOpp = [select Id, Amount from Opportunity where Id = :TestOli.OpportunityId][0];
    //  Check that the quarterly values have all been calculated after the workflow has touched the OpportunityLineItem
    Double Revenue = Revenue_Map.get(TestOli.Id);
    for (Opportunity TestOppty:Opp_Array_All)
    {
        if(TestOli.OpportunityId == TestOppty.Id)
        {
            //System.assertEquals(TestOppty.Amount,Revenue*iNumSchedules);
        }
    }
    //System.assertEquals(Revenue*3,TestOli.Gross_Q1_Value__c);
    //System.assertEquals(Revenue*3,TestOli.Gross_Q2_Value__c);
    //System.assertEquals(Revenue*3,TestOli.Gross_Q3_Value__c);
    //System.assertEquals(Revenue*3,TestOli.Gross_Q4_Value__c);
    //System.assertEquals(Revenue*3,TestOli.Gross_Q1_NY_Value__c);
    //System.assertEquals(Revenue*3,TestOli.Gross_Q2_NY_Value__c);
  }
  //  Test that line items whose schedules have been deleted have the correct values in the summary fields
  /*delete InsertOLISList;
  for (OpportunityLineItem NewOLI:InsertOLIList)
  {
    OpportunityLineItem TestOli = [select Id,OpportunityId, Gross_Q1_Value__c,Gross_Q2_Value__c,Gross_Q3_Value__c,Gross_Q4_Value__c,Gross_Q1_NY_Value__c,Gross_Q2_NY_Value__c from OpportunityLineItem where Id = :NewOLI.Id][0];
    System.assertEquals(0,TestOli.Gross_Q1_Value__c);
    System.assertEquals(0,TestOli.Gross_Q2_Value__c);
    System.assertEquals(0,TestOli.Gross_Q3_Value__c);
    System.assertEquals(0,TestOli.Gross_Q4_Value__c);
    System.assertEquals(0,TestOli.Gross_Q1_NY_Value__c);
    System.assertEquals(0,TestOli.Gross_Q2_NY_Value__c);  
  }*/
    Address__c TestAddress = New Address__c (
            Name='Test Address',
            Account__c=acct1.Id,
            Street__c = 'Street',
            City__c = 'City',
            Country__c = 'Country',
            Marked_For_Deletion__c = false,
            SAP_Reference__c = '495001');
      TestAddress.MDM_Validation_Status__c = 'Validated';
      TestAddress.RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId();
      CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
     insert TestAddress;
     BNF2__c TestBnf = new BNF2__c(Opportunity__c=InsertOppList[0].Id);
     TestBnf.BNF_Status__c = 'New';
     TestBnf.Contract_Start_Date__c = Date.today().addYears(1);
     TestBnf.Contract_End_Date__c = Date.today().addYears(2);
     TestBnf.IMS_Sales_Org__c = 'IHA, IMS Health Rotkreuz';
     TestBnf.Sales_Org_Code__c='CH03';
     TestBnf.Bill_To__c=TestAddress.id;
     TestBnf.X2nd_Copy__c=TestAddress.id;
     TestBnf.Carbon_Copy__c=TestAddress.id;
     TestBnf.Ship_To__c=TestAddress.id;
     TestBnf.Cover_Sheet__c=TestAddress.id;
     //TestBnf.RecordTypeId = MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
     TestBnf.RecordTypeId  = Schema.SObjectType.BNF2__c.getRecordTypeInfosByName().get('SAP SD Integrated').getRecordTypeId();
     insert TestBnf;

    
    PageReference pageRef = new PageReference('Page.BNFProductController');
    pageRef.getParameters().put('newid', TestBnf.Id);
    pageRef.getParameters().put('id',InsertOppList[0].Id);
    Test.setCurrentPage(pageRef);
    ApexPages.standardController controller = new ApexPages.standardController(new BNF2__c());
    BNFProductController extension = new BNFProductController(controller);
    extension.testCheck();
    extension.save();
    extension.setOpportunityLineItem(extension.getOpportunityLineItem2());
    BNFProductController.getCartSessionXml(InsertOppList[0].Id , InsertOppList[0].Id, 'Test', 'Update','TEst','yes'); 
    Test.stopTest();
  }    
  
    /*private static testMethod void runPositiveTest()

    {

        // Prepare test data

        Account newAccount = new Account(AccountNumber ='TAC00001', Name='TESTING ACCOUNT', Type='Customer - Direct', Description='Account used for APEX code unitary tests', BillingStreet='1274 California St', BillingState='CA', BillingPostalCode='93415', BillingCountry='USA', BillingCity='San Francisco', ShippingStreet='1274 California St', ShippingState='CA', ShippingPostalCode='93415', ShippingCountry='USA', ShippingCity='San Francisco', AnnualRevenue=100000000);

        insert newAccount;

        // Prepare test data

         Opportunity  newOpportunity = new Opportunity(Type='Existing Customer - Upgrade', Name='TESTING OPPORTUNITY', Description='Opportunity used for APEX code unitary tests', AccountId= newAccount.id, Amount=50000.00, CloseDate=date.valueOf('2012-01-01 00:00:00'), Probability=10.00, StageName='Prospecting');

        insert newOpportunity;
        
        Set<Id> opps =new Set<Id> {newOpportunity.Id};
        // Commented by Sandeep Date 8 August for Task ( to delete Classes& triggers of CAM ) Assigned By Sam
        //BNFProductController.CAM_Callout(opps);

    }



    private static testMethod void runPositiveTest2() 

    {
    
        // Prepare test data 

        Account newAccount = new Account(AccountNumber ='TAC00001', Name='TESTING ACCOUNT', Type='Customer - Direct', Description='Account used for APEX code unitary tests', BillingStreet='1274 California St', BillingState='CA', BillingPostalCode='93415', BillingCountry='USA', BillingCity='San Francisco', ShippingStreet='1274 California St', ShippingState='CA', ShippingPostalCode='93415', ShippingCountry='USA', ShippingCity='San Francisco', AnnualRevenue=100000000);

        insert newAccount;

        // Prepare test data

         Opportunity  newOpportunity = new Opportunity(Type='Existing Customer - Upgrade', Name='TESTING OPPORTUNITY', Description='Opportunity used for APEX code unitary tests', AccountId= newAccount.id, Amount=50000.00, CloseDate=date.valueOf('2012-01-01 00:00:00'), Probability=10.00, StageName='Prospecting');

        insert newOpportunity;
        
        //String xml = BNFProductController.getCartSessionXml(newOpportunity.Id, '006Q0000002oGXyIAM', '1', '', '','no');
    }    */
    
}