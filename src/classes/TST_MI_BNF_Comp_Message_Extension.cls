@isTest

private class TST_MI_BNF_Comp_Message_Extension 
{  
  public static ApexPages.StandardController sc;
    public static MIBNF2__c MIBNF;
    public static MIBNF_Component__c MIBNF_Comp;
    public static MI_BNF_LineItem__c MIBNFLineItem;
    public static Opportunity opp;
    public static OpportunityLineItem OLI1;
    public static User TestUser1;
    public static Account TestAccount;
    public static List<Address__c> TestAddress_Array; 
    public static List<OpportunityLineItem> olilist;
    public static List<MI_BNF_LineItem__c> MIBNFLineItemList;
  
  static void setupOppAndBnf() 
  {
        TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        TestAccount.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        TestAccount.OwnerId = TestUser1.Id;
        TestAccount.CustomerSegment__c = 'GOVERNMENT';
        TestAccount.Sub_Industry__c = 'STATE';
        insert TestAccount;
        
        // Create Opportunity
        Revenue_Analyst__c TestRA=new Revenue_Analyst__c(name='Test RA',User__c=TestUser1.Id);
        insert TestRA;
        
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        Opportunity TestOpp = new Opportunity(Name='test',CloseDate=System.today());
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.StageName='7a. Closed Won';
        TestOpp.FPI_Date__c=system.today();
        TestOpp.Population_Age_Group__c = 'Not Applicable';
        TestOpp.AccountId = TestAccount.Id;
        TestOpp.Contract_End_Date__c = system.today().addyears(12);
        TestOpp.Contract_Start_Date__c = system.today();
        //TestOpp.Win_Loss_Reason__c='Win - Competitive Situation';
        TestOpp.Contract_Type__c='Individual';
        TestOpp.LeadSource = 'Account Planning';
        //TestOpp.Win_Additional_Details__c = 'Additional details';
        //TestOpp.Win_Loss_Reason_Details__c = 'Win Loss Reason Details'; 
        TestOpp.CurrencyIsoCode = 'USD';
        //TestOpp.Exclude_From_Pricing_Calculator__c = true;
        //TestOpp.Compelling_Event__c = 'Unknown';
        TestOpp.Budget_Available__c = 'Unknown';
        //TestOpp.Unique_Business_Value__c = 'Unknown';
        //TestOpp.Therapy_Area__c= 'Hepatitis C [21]';
        TestOpp.Potential_Competitor_1__c = comp.Id;
        insert TestOpp;
        opp = TestOpp;
        Product2 prod1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZREP',CanUseRevenueSchedule= true, Delivery_Media__c = 'DVD [DV]:CD [CD]',Delivery_Frequency__c = 'Monthly:Quaterly');
        prod1.Business_Type__c = 'I&A' ;
        prod1.isactive = true;
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
        AddLineItems(opp);
        
        Opportunity opp1 =new Opportunity(id=opp.Id);
        opp1.StageName='7a. Closed Won';
        opp1.FPI_Date__c=system.today();
        opp1.Population_Age_Group__c = 'Not Applicable';
        //opp1.Win_Loss_Reason__c='Win - Competitive Situation';
        //opp1.Win_Additional_Details__c = 'Additional details';
        //opp1.Win_Loss_Reason_Details__c = 'Win Loss Reason Details'; 
        opp1.Primary_Win_Reason__c ='Project Performance';
        opp1.Win_Type__c = 'Non-competitive bid';
        update opp1;
        
        TestAddress_Array = new List<Address__c>();
        for (Integer i=0; i<10; i++)
        {
            Address__c TempAddress = New Address__c(Name=String.valueOf(i),
                                                    Account__c=TestAccount.Id,
                                                    Street__c = 'Street ' + i.format(),
                                                    City__c = 'City '+ i.format(),
                                                    Country__c = 'Country ' + i.format(),
                                                    SAP_Reference__c = String.valueOf(495000+i),
                                                    Enabled_Sales_Orgs__c='CH04',
                                                   	MDM_Validation_Status__c = 'Validated');
            TestAddress_Array.add(TempAddress);
        } 
        insert TestAddress_Array;
        
        
        MIBNF=new MIBNF2__c();
        MIBNF.Client__c=opp.AccountId;
        MIBNF.Opportunity__c=opp.Id;
        MIBNF.Sales_Org_Code__c='CH03';
        MIBNF.Billing_Currency__c='USD';
        MIBNF.IMS_Sales_Org__c='Acceletra';
        MIBNF.Fair_Value_Type__c='Stand Alone';
        MIBNF.Invoice_Default_Day__c='15';
        MIBNF.Contract_Start_Date__c=system.today();
        MIBNF.Contract_End_Date__c=system.today();
        MIBNF.Contract_Type__c='Individual';
        MIBNF.Contract_Term__c='Single-Period';
        MIBNF.Payment_Terms__c='0000-Default Payment Terms of Customer Master Data';
        MIBNF.Revenue_Analyst__c=TestRA.Id;
        
        insert MIBNF;
  }
    //setting up component for MIBNF
    static void SetupMIBNF_Comp(MIBNF2__c RefMIBNF)
    {
        MIBNF_Comp=new MIBNF_Component__c();
        MIBNF_Comp.MIBNF__c=RefMIBNF.Id;
        MIBNF_Comp.BNF_Status__c='New';
        MIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        MIBNF_Comp.Print_Shop__c='No';
        MIBNF_Comp.Bill_To__c=TestAddress_Array[0].Id;
        MIBNF_Comp.Ship_To__c=TestAddress_Array[0].id;
      
        insert MIBNF_Comp;
        MIBNFLineItemList=new List<MI_BNF_LineItem__c>();
       MI_BNF_LineItem__c MI_BNFLineItem= new MI_BNF_LineItem__c();
       MI_BNFLineItem.MIBNF_Component__c=MIBNF_Comp.id;
       MI_BNFLineItem.Opportunity_Line_Itemid__c=OLI1.Id;
       MI_BNFLineItem.Total_Price__c=OLI1.TotalPrice;
       MIBNFLineItemList.add(MI_BNFLineItem);
       insert MIBNFLineItemList;
       
    }
       // AddLineItem to Opportunity
    static void AddLineItems(Opportunity O)
    {
        //  Add a line item to the opportunity
        olilist=new List<OpportunityLineItem>();
        OLI1 = new OpportunityLineItem();
        OLI1.OpportunityId = O.Id;
        OLI1.Therapy_Area__c= 'Hepatitis C [21]';
        PricebookEntry PE1 = [select Id, CurrencyIsoCode,Product2Id from PricebookEntry where CurrencyIsoCode = 'USD' and IsActive = true and Product2.IsActive = true and Product2.Business_Type__c = 'I&A' limit 1][0];
        
        OLI1.PricebookEntryId = PE1.Id;
        OLI1.Quantity = 1.00;
        OLI1.TotalPrice=10000;
        OLI1.Sale_Type__c = 'New';
        OLI1.Delivery_Country__c = 'USA';
        OLI1.Revenue_Type__c = 'Ad Hoc';
        olilist.add(OLI1);
        insert olilist;
     
    }
    static testMethod void t1()
    {
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        
        TestUser1  = [select Id,Profile.Name from User where Profile.Name = 'system administrator' and IsActive = true and Id =:UserInfo.getUserid() limit 1];
        User TestUser2=[select id,Profile.name from user where isactive=true limit 1];
       System.runAs(TestUser1) 
       {     
           set<id> AddressId_Set = new set<id>();
           setupOppAndBnf();
           test.startTest();
           BNF_Settings__c bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true,BNF_Opportunity_Threshold__c = 1000, Enable_BNF_Surcharge__c=true, Enable_Billing_Schedule_Validation__c = true);
            insert bnfsetting;
           SetupMIBNF_Comp(MIBNF);
           AddressId_Set.add(MIBNF_Comp.Bill_To__c);
           AddressId_Set.add(MIBNF_Comp.Ship_To__c);
           Map<id,Address__c> AddressMap= new Map<id,Address__c>( [select Id,Name,SAP_Reference__c,Enabled_Sales_Orgs__c from Address__c where Id in :AddressId_Set]);
       
           Map<String,Address__c> map_Filled_Addresses = new Map<String,Address__c>();
           map_Filled_Addresses.put('Bill To',AddressMap.get(MIBNF_Comp.Bill_To__c));
           map_Filled_Addresses.put('Ship To',AddressMap.get(MIBNF_Comp.Ship_To__c));
       
           AddressWrapper addwrapper=New AddressWrapper(map_Filled_Addresses);

           //ApexPages.CurrentPage().getParameters().put('id' ,MIBNF_Comp.id);
           MI_BNF_Comp_Message_Extension controller=new MI_BNF_Comp_Message_Extension();
           controller.ProcessInstanceWorkitemMap=TestUser1.id + ':' + TestUser2.id;
           controller.objAddressWrapper=addwrapper;
           controller.MIBNFLineItemList=MIBNFLineItemList;
           controller.OLIItemList=olilist;
           controller.setMIBNF_Comp(MIBNF_Comp);
           controller.getMIBNF_Comp();
           controller.setCurrentUser(TestUser1);
           controller.getCurrentUser();
           controller.ProcessInstanceWorkitemMap = null;
           bnfsetting.Enable_Material_Validation__c = false;
           upsert bnfsetting;
           controller.ShowInfoMessages();
           //system.assertequals(3,controller.errorlst.size());
           
           test.StopTest();
       }
    }
    

}