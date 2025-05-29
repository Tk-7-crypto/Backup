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
private class TST_MIBNF_ProductController {

    /**************************For Test Method****************/
    private static Opportunity opp;
    private static MIBNF2__c MIBNF;
    private static OpportunityLineItem OLI1;
    
    /*********************************************************/
   //Setup MIBNF for Test Methods
    static void SetupMIBNF() {
        upsert new  Mulesoft_Integration_Control__c(Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = true, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true);
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
         // Create Opportunity
        ID RevenueAnalystID;
        for(Revenue_Analyst__c RA: [select id from Revenue_Analyst__c])
        {
            if(RA == null) {
       			Revenue_Analyst__c ratest = new Revenue_Analyst__c(Name = 'Test', User__c = UserInfo.getUserId());
       			RevenueAnalystID = ratest.id;
            }
            else 
             RevenueAnalystID = RA.id; 
             break;
        }
        
        UTL_ExecutionControl.stopTriggerExecution = true;  
        List<User> userList = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE, 2);
        userList.addall(UTL_TestData.createUser('Sales User', 1));
        userList[0].PIC_Eligible__c = true;
        insert userList;
        Account TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        TestAccount.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        TestAccount.OwnerId = userList[0].Id;
        TestAccount.CustomerSegment__c = 'GOVERNMENT';
        TestAccount.Sub_Industry__c = 'STATE';
        insert TestAccount;
        Contact cnt = UTL_TestData.createContact(TestAccount.Id);
        cnt.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        cnt.Salesforce_User__c = userList[0].Id;
        insert cnt;
		
		
		
		Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        Opportunity opp1 =new Opportunity(Name='Quick opp',StageName='1. Identifying Opportunity',Amount=2000,CloseDate=System.today(),
        Contract_Term__c='Single-Period',Contract_Type__c='Individual');
        opp1.LeadSource = 'Account Planning';
        opp1.Budget_Available__c = 'Yes';
        opp1.Contract_Start_Date__c=system.today();
        opp1.Contract_End_Date__c=system.today();
		opp1.CurrencyIsoCode = 'USD';
        //opp1.Unique_Business_Value__c = 'Unknown';
        //opp1.Compelling_Event__c = 'No';
        opp1.Potential_Competitor_1__c = comp.Id;
        insert opp1;
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp1.Id);
            insert contactRole;
		
        AddLineItems(opp1);
        
        opp=new Opportunity(id=opp1.Id);
        opp.StageName='7a. Closed Won';
        opp.Primary_Win_Reason__c ='Project Performance';
        opp.Win_Type__c = 'Non-competitive bid';
        //opp.Win_Loss_Reason__c='Win - Competitive Situation';
        //opp.Win_Additional_Details__c = 'Additional details';
        //opp.Win_Loss_Reason_Details__c = 'Win Loss Reason Details'; 
        opp.Principle_inCharge__c = cnt.id;
        update opp;
        
        MIBNF=new MIBNF2__c();
        MIBNF.Client__c=opp.AccountId;
        MIBNF.Opportunity__c=opp.Id;
        MIBNF.Sales_Org_Code__c='CH08';
        MIBNF.Billing_Currency__c='USD';
        MIBNF.IMS_Sales_Org__c='Acceletra';
        MIBNF.Fair_Value_Type__c='Stand Alone';
        MIBNF.Invoice_Default_Day__c='15';
        MIBNF.Contract_Start_Date__c=system.today();
        MIBNF.Contract_End_Date__c=system.today();
        MIBNF.Contract_Type__c='Individual';
        MIBNF.Contract_Term__c='Single-Period';
        MIBNF.Payment_Terms__c='0000-Default Payment Terms of Customer Master Data';
        MIBNF.Revenue_Analyst__c=RevenueAnalystID;
        
        insert MIBNF;
        UTL_ExecutionControl.stopTriggerExecution = false;
    }   
   
  public static testMethod void testMyController() {
        
         SetupMIBNF();
         test.startTest();
         UTL_ExecutionControl.stopTriggerExecution = true;
         MIBNF_Component__c MIBNF_Comp=new MIBNF_Component__c();
                           MIBNF_Comp.MIBNF__c=MIBNF.Id;
                           MIBNF_Comp.BNF_Status__c='New';
                           MIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
                           MIBNF_Comp.Print_Shop__c='No';
                           insert MIBNF_Comp;
        MI_BNF_LineItem__c MI_BNFLineItem= new MI_BNF_LineItem__c();
        MI_BNFLineItem.MIBNF_Component__c=MIBNF_Comp.id;
        MI_BNFLineItem.Opportunity_Line_Itemid__c=OLI1.Id;
        MI_BNFLineItem.Total_Price__c=OLI1.TotalPrice;
        insert MI_BNFLineItem;
        UTL_ExecutionControl.stopTriggerExecution = false;
        
        
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', MIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductController extension = new MIBNF_ProductController(controller);
        
        extension.testCheck();
        
        
        
        ApexPages.currentPage().getParameters().put('compid',MIBNF_Comp.id);
        extension = new MIBNF_ProductController(controller);
     
        PageReference dummy = extension.save();
        
        
        //system.assertNotEquals(dummy,null);
        
        
        for(Integer i=0;i<extension.opptyLineItem2.size();i++)
        {
            extension.opptyLineItem2[i].Billing_Date__c=system.today();  
            extension.opptyLineItem2[i].Delivery_Date__c=system.today();    
                               
        }
        extension.ProductCheck();
        dummy = extension.save();
  
     
        //system.assertNotEquals(dummy,null);
        
        List<OpportunityLineItem> dummyList = extension.getOpportunityLineItem2();
     //   extension.setDeliveryMediaAll();
        dummy = extension.cancel();
        extension.setDeliveryMediaOpt(true);
        extension.getDeliveryMediaOpt();
        extension.getMIBNF_Comp();
        
        extension.setTemp('Temp');
        String temp = extension.getTemp();
        test.stopTest();
    }
    
    public static testMethod void test5() {
        
         SetupMIBNF();
         test.startTest();
         MIBNF_Component__c MIBNF_Comp=new MIBNF_Component__c();
                           MIBNF_Comp.MIBNF__c=MIBNF.Id;
                           MIBNF_Comp.BNF_Status__c='New';
                           MIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
                           MIBNF_Comp.Print_Shop__c='No';
                           insert MIBNF_Comp;
        MI_BNF_LineItem__c MI_BNFLineItem= new MI_BNF_LineItem__c();
        MI_BNFLineItem.MIBNF_Component__c=MIBNF_Comp.id;
        MI_BNFLineItem.Opportunity_Line_Itemid__c=OLI1.Id;
        MI_BNFLineItem.Total_Price__c=OLI1.TotalPrice;
        insert MI_BNFLineItem;
        
        
        PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
        pageRef.getParameters().put('compid', MIBNF_Comp.id);
        Test.setCurrentPage(pageRef);
        ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
        MIBNF_ProductController extension = new MIBNF_ProductController(controller);
        
        ApexPages.currentPage().getParameters().put('compid',MIBNF_Comp.id);
        extension = new MIBNF_ProductController(controller);
        
      
        for(Integer i=0;i<extension.opptyLineItem2.size();i++)
        {
            extension.opptyLineItem2[i].Billing_Frequency__c='Once';
            extension.opptyLineItem2[i].Proj_Rpt_Frequency__c='Once [O]';
            extension.opptyLineItem2[i].List_Price__c=2;
            extension.opptyLineItem2[i].Billing_Date__c=null;  
            extension.opptyLineItem2[i].Delivery_Date__c=null;
            extension.opptyLineItem2[i].Revenue_Type__c='Ad Hoc';
                               
        }
        extension.setOpportunityLineItem(extension.opptyLineItem2);
        pageRef = extension.save();
        ApexPages.Message msg1 = ApexPages.getMessages()[0];
        System.assertEquals('Billing date is mandatory when billing frequency "Once" is selected.', msg1.getDetail());
        msg1 = ApexPages.getMessages()[1];
        System.assertEquals('Delivery date is mandatory when delivery frequency "Once" is selected.', msg1.getDetail());
        msg1 = ApexPages.getMessages()[2];
        System.assertEquals('Please enter Billing Date for Ad Hoc Product', msg1.getDetail());
        msg1 = ApexPages.getMessages()[3];
        System.assertEquals('List price cannot be less than sales price.', msg1.getDetail());
        test.stopTest();
  

    }
  
  
  //This Method test for MIBNF LineItem and redirect user directly to MIBNF view page when user is following wizard steps  
  public static testmethod void LineItemTest()
  {
    SetupMIBNF();
    test.startTest();
    MIBNF_Component__c MIBNF_Comp=new MIBNF_Component__c();
    MIBNF_Comp.MIBNF__c=MIBNF.Id;
    MIBNF_Comp.BNF_Status__c='New';
    MIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
    MIBNF_Comp.Print_Shop__c='No';
    
    insert MIBNF_Comp;
    
    ApexPages.CurrentPage().getParameters().put('minfid' , MIBNF.id );
    ApexPages.CurrentPage().getParameters().put('prdids' , OLI1.Id);
    MI_BNF_ADD_Product prdcontroller = new MI_BNF_ADD_Product();
    prdcontroller.selectedInvoice=MIBNF_Comp.Id;
    PageReference prdpageRef=prdcontroller.Save();
    
    PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
    pageRef.getParameters().put('compid', MIBNF_Comp.id);
    Test.setCurrentPage(pageRef);
    ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
    MIBNF_ProductController extension = new MIBNF_ProductController(controller);
    
    PageReference pg=extension.ProductCheck();
    system.assertEquals(pg,null);
    test.stopTest();
  }
  
    public static testmethod void LineItemTestwithoutProductTest()
  {
    SetupMIBNF();
    test.startTest();
    MIBNF_Component__c MIBNF_Comp=new MIBNF_Component__c();
    MIBNF_Comp.MIBNF__c=MIBNF.Id;
    MIBNF_Comp.BNF_Status__c='New';
    MIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
    MIBNF_Comp.Print_Shop__c='No';
    insert MIBNF_Comp;
    
    PageReference pageRef = new PageReference('Page.MIBNF_ProductController');
    pageRef.getParameters().put('compid', MIBNF_Comp.id);
    Test.setCurrentPage(pageRef);
    ApexPages.standardController controller = new ApexPages.standardController(new MIBNF_Component__c());
    MIBNF_ProductController extension = new MIBNF_ProductController(controller);
    
    PageReference pg=extension.ProductCheck();
    ApexPages.Message msg1 = ApexPages.getMessages()[0];
    System.assertEquals('This BNF has no products. Please go back and add products before clicking on the "Edit Products" button.', msg1.getDetail());
    system.assertEquals(pg,null);
    test.stopTest();
  }
    
  public static testmethod void t1()
  {
    test.startTest();
    CLS_ProductionReference Convertor = new CLS_ProductionReference();
    Integer iTest = Convertor.CalculateElapsedMinsThisYear();
    system.debug('Mins this year: '+ iTest.format());
    String sOutput = Convertor.ConvertToRadix34(364883);
    system.debug('Output: '+ sOutput);
    system.assertEquals('AAMV',sOutput);
    test.stopTest();
  }

  public static testmethod void t2() 
    {
        upsert new  Mulesoft_Integration_Control__c(Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = true, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true);
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
      Datetime strDate = System.now();  
      //  Create a test account
    Account acct1 = new Account(Name='SPO BT Test Account',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
    insert acct1;
    List<Opportunity> InsertOppList = new List<Opportunity>();
    List<OpportunityLineItem> InsertOLIList = new List<OpportunityLineItem>();
    List<OpportunityLineItemSchedule> InsertOLISList = new List<OpportunityLineItemSchedule>();
    Map<String,Double> Revenue_Map = new Map<String,Double>();
    //  Setup test parameters
    Integer NumTestOpps = 1;
    Integer iNumSchedules = 18;
    for (Integer i=0;i<NumTestOpps;i++)
    {
      //  Create a test opportunity
      Opportunity oppty1 = new Opportunity(Name = 'SPO BT Test Oppty');
      oppty1.StageName = '1. Identifying Opportunity';
      oppty1.CloseDate = System.today();
      oppty1.AccountId = acct1.Id;
      oppty1.Budget_Available__c = 'Yes';
      oppty1.CurrencyIsoCode = 'USD';
        oppty1.Contract_Start_Date__c=system.today();
        oppty1.Contract_End_Date__c=system.today();
      InsertOppList.add(oppty1);
    }
    insert InsertOppList;
            PricebookEntry PE1;
        
        List<PricebookEntry> pblist = [Select Id from PricebookEntry];
        if(pblist.size() == 0) {
        	Product2 prod1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZREP',CanUseRevenueSchedule= true, Delivery_Media__c = 'DVD [DV]:CD [CD]',Delivery_Frequency__c = 'Monthly:Quaterly' ,isActive = true, Hierarchy_Level__c=CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI);
            prod1.Pillar__c = 'Technology Solutions; Information Offering';
            insert prod1;
        	PricebookEntry pbe = new PricebookEntry();
	        pbe.UseStandardPrice = false;
	        pbe.Pricebook2Id = Test.getStandardPricebookId();
	        pbe.Product2Id=prod1.id;
	        pbe.IsActive=true;
	        pbe.UnitPrice=100.0;
	        pbe.CurrencyIsoCode = 'USD';
	        insert pbe;
	        PE1 = pbe;
        }
        else {
        	PE1 = pblist[0];
        }
        
    for (Opportunity NewOpp:InsertOppList)
    {
      Id opptyId = NewOpp.Id;
      //  Add a line item to the opportunity
      OpportunityLineItem add1_oli = new OpportunityLineItem();
      add1_oli.OpportunityId = opptyId;    
      add1_oli.PricebookEntryId = PE1.Id;
      add1_oli.Quantity = 1.00;
        add1_oli.UnitPrice = 10000;
        add1_oli.Sale_Type__c = 'New';
        add1_oli.Delivery_Country__c = 'USA';
        add1_oli.Revenue_Type__c = 'Ad Hoc';
        add1_oli.Therapy_Area__c= 'Hepatitis C [21]';
        add1_oli.Wbsrelementcode__c = 'test';
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
    
    Test.Starttest();
    for (OpportunityLineItem NewOLI:InsertOLIList)
    {
      //  Retrieve the OpportunityLineItem which should now have been touched by the workflow
      OpportunityLineItem TestOli = [select Id,OpportunityId, Gross_Q1_Value__c,Gross_Q2_Value__c,Gross_Q3_Value__c,Gross_Q4_Value__c,Gross_Q1_NY_Value__c,Gross_Q2_NY_Value__c, Delivery_Date__c from OpportunityLineItem where Id = :NewOLI.Id][0];
      Opportunity TestOpp = [select Id, Amount from Opportunity where Id = :TestOli.OpportunityId][0];
   
      //  which modifies the OpportunityLineItem.Schedule_Update_Dummy__c field
      //  Check that the quarterly values have all been calculated after the workflow has touched the OpportunityLineItem
      Double Revenue = Revenue_Map.get(TestOli.Id);
      System.assertEquals(TestOpp.Amount,Revenue*iNumSchedules);
      System.assertEquals(Revenue*3,TestOli.Gross_Q1_Value__c);
      System.assertEquals(Revenue*3,TestOli.Gross_Q2_Value__c);
      System.assertEquals(Revenue*3,TestOli.Gross_Q3_Value__c);
      System.assertEquals(Revenue*3,TestOli.Gross_Q4_Value__c);
      System.assertEquals(Revenue*3,TestOli.Gross_Q1_NY_Value__c);
      System.assertEquals(Revenue*3,TestOli.Gross_Q2_NY_Value__c);
    }
    Test.stoptest();
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
    }    
     
     
      // AddLineItem to Opportunity
    static void AddLineItems(Opportunity O)
    {
        //  Add a line item to the opportunity
        //Test.startTest();
        PricebookEntry PE1;
        
        List<PricebookEntry> pblist = [Select Id from PricebookEntry];
        if(pblist.size() == 0) {
        	Product2 prod1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZREP',CanUseRevenueSchedule= true, Delivery_Media__c = 'DVD [DV]:CD [CD]',Delivery_Frequency__c = 'Monthly:Quaterly' ,isActive = true, Hierarchy_Level__c=CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI);
        	prod1.Pillar__c = 'Technology Solutions; Information Offering';
            insert prod1;
        	PricebookEntry pbe = new PricebookEntry();
	        pbe.UseStandardPrice = false;
	        pbe.Pricebook2Id = Test.getStandardPricebookId();
	        pbe.Product2Id=prod1.id;
	        pbe.IsActive=true;
	        pbe.UnitPrice=100.0;
	        pbe.CurrencyIsoCode = 'USD';
	        insert pbe;
	        PE1 = pbe;
        }
        else {
        	PE1 = pblist[0];
        }
        
        
        OLI1 = new OpportunityLineItem();
        OLI1.OpportunityId = O.Id;
        OLI1.PricebookEntryId = PE1.Id;
        OLI1.Quantity = 1.00;
        OLI1.TotalPrice=10000;
        OLI1.Sale_Type__c = 'New';
        OLI1.Delivery_Country__c = 'USA';
        OLI1.Revenue_Type__c = 'Ad Hoc';
        OLI1.Therapy_Area__c= 'Hepatitis C [21]';
        OLI1.Wbsrelementcode__c = 'Test';
        insert OLI1;
      
        //test.stopTest();
    }
}