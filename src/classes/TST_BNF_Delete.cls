@isTest
private class TST_BNF_Delete {
    public static ApexPages.StandardController sc;
    public static MIBNF2__c MIBNF;
    public static MIBNF_Component__c MIBNF_Comp;
    public static MI_BNF_LineItem__c MIBNFLineItem;
    public static Opportunity opp;
    public static OpportunityLineItem OLI1;
    public static User TestUser1;
    public static Account TestAccount;
    public static List<Address__c> TestAddress_Array; 
    static BNF_Settings__c bnfsetting;
    
    @Testsetup
    static void testDataSetup() {
    	Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        
    	Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = true;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        //OpportunityTriggerUtil.RunBeforeTrigger = false;
        //OpportunityTriggerUtil.RunAfterTrigger = false;
        Global_Variables.isupdatableOppPlan = false;
        Global_Variables.isclonningOpportunity = true;
        
        bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=false,Enable_Customer_Validation__c=false,BNF_Opportunity_Threshold__c = 1000, Enable_BNF_Surcharge__c=false);
        upsert bnfsetting;
        Profile p = [select id from profile where (not Name like '%SYSTEM ADMINISTRATOR%') limit 1]; 
        TestUser1  = new User(alias = 'jpusr', email='japnalocal@metacube.com', 
                              emailencodingkey='UTF-8',firstname='User',lastname='Testing', languagelocalekey='en_US', 
                              localesidkey='en_US', profileid = p.Id, 
                              timezonesidkey='America/Los_Angeles', username='japnalocal@metacube.com');
        System.runAs(TestUser1) {     
            
        TestAccount = new Account();
        TestAccount.Name = 'Test Account';
        TestAccount.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        TestAccount.OwnerId = TestUser1.Id;
        insert TestAccount;
        
        insert new Profit_Centre__c(name='xz',ProfitCenterCode__c = 'USD');
        Contact MainDecisionMakerContact1 = new Contact(FirstName = 'MainDecisionMaker', LastName='Contact', AccountId = TestAccount.Id, Email = 'abc@xyz.com', CurrencyIsoCode = 'USD');
        MainDecisionMakerContact1.pse__Is_Resource__c=true;
        MainDecisionMakerContact1.pse__Is_Resource_Active__c=true;
        insert MainDecisionMakerContact1;
        
        //Principal_In_Charge__c PIC=new Principal_In_Charge__c(NAME=UserInfo.getLastName()+', '+UserInfo.getFirstName(), User__c=UserInfo.getUserId());
        //PIC.PseResource__c=MainDecisionMakerContact1.id;
         
        // insert PIC;
        
         // Create Opportunity
        Revenue_Analyst__c TestRA=new Revenue_Analyst__c(name='Test RA',User__c=TestUser1.Id);
        insert TestRA;
        
        opp = new Opportunity(Name='test',StageName='1. Identifying Opportunity',CloseDate=System.today());
        opp.LeadSource = 'Account Planning';
        opp.Budget_Available__c = 'Yes';
        //TestOpp.Unique_Business_Value__c = 'Unknown';
        //TestOpp.Compelling_Event__c = 'No';
        //TestOpp.StageName='5. Finalizing Deal';
        opp.AccountId = TestAccount.Id;
        //TestOpp.Contract_Term__c='Single-Period';
        opp.Contract_End_Date__c = system.today();
        opp.Contract_Start_Date__c = system.today();
        //TestOpp.Win_Loss_Reason__c='Win - Competitive Situation';
        //TestOpp.Contract_Type__c='Individual';
        opp.LeadSource = 'Account Planning';
        //TestOpp.Win_Additional_Details__c = 'Additional details';
        //TestOpp.Win_Loss_Reason_Details__c = 'Win Loss Reason Details'; 
        opp.CurrencyIsoCode = 'USD';
        insert opp;
        BNF_Settings__c bnfsetting= BNF_Settings__c.getInstance();
            if(bnfsetting== null)  {
                bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true,BNF_Release__c = '2019');
                //bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true);
                insert bnfsetting;
            }
        Contact con = new Contact();
        con.LastName = 'Ap';
        insert con;
 		OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(con.Id, opp.Id);
        insert contactRole;
        
        //  Add a line item to the opportunity
        List<OpportunityLineItem> OLI_Array = new List<OpportunityLineItem>();
        OpportunityLineItem OLI1 = new OpportunityLineItem();
        OLI1.OpportunityId = opp.Id;
        
        Product2 objProduct = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH08', Business_Type__c = 'I&A', Material_Type__c = 'ZPUB', isactive=true, CanUseRevenueSchedule = true, InterfacedWithMDM__c = true, Hierarchy_Level__c=CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI); 
        insert objProduct;
        
        PricebookEntry PE1 = new PricebookEntry();
        PE1.UseStandardPrice = false;
        PE1.Pricebook2Id = Test.getStandardPricebookId();
        PE1.Product2Id=objProduct.id;
        PE1.IsActive=true;
        PE1.UnitPrice=100.0;
        PE1.CurrencyIsoCode = 'USD';
        insert PE1;
        //PricebookEntry PE1 = [select Id, CurrencyIsoCode,Product2Id from PricebookEntry where CurrencyIsoCode = 'USD' and IsActive = true and Product2.IsActive = true and Product2.Material_Type__c = 'ZPUB' limit 1][0];
        //Product2 p1=[Select Enabled_Sales_Orgs__c from Product2 where  Id =:PE1.Product2Id limit 1][0];
        //p1.Enabled_Sales_Orgs__c='CH03';
        //upsert p1;
        OLI1.Sale_Type__c = 'New';
        OLI1.Revenue_Type__c = 'Ad Hoc';
        OLI1.Product_Start_Date__c = Date.today();
        OLI1.Product_End_Date__c = Date.today().addYears(1) ;
        OLI1.PricebookEntryId = PE1.Id;
        OLI1.Billing_Frequency__c = 'Once';
        OLI1.Proj_Rpt_Frequency__c='Once [O]';
        OLI1.Therapy_Area__c= 'Hepatitis C [21]';
        OLI1.Quantity = 1.00;
        OLI1.UnitPrice = 10000;  
        OLI1.List_Price__c = 100;
        OLI1.Delivery_Country__c = 'USA';
        OLI1.Therapy_Area__c= 'Hepatitis C [21]';
        OLI_Array.add(OLI1);
        //insert OLI1;
        /*OpportunityLineItem OLI2 = new OpportunityLineItem();
        OLI2.OpportunityId = opp.Id;
        PricebookEntry PE2 = [select Id, CurrencyIsoCode,Product2Id from PricebookEntry where CurrencyIsoCode = 'USD' and IsActive = true and Product2.IsActive = true and Product2.Material_Type__c = 'ZPUB' limit 1][0];
        Product2 p2=[Select Enabled_Sales_Orgs__c from Product2 where Id=:PE2.Product2Id limit 1 ][0];
        p2.Enabled_Sales_Orgs__c='CH04';
        upsert p2;
        OLI2.OpportunityId = opp.Id;
        OLI2.Sale_Type__c = 'New';
        OLI2.Revenue_Type__c = 'Ad Hoc';
        OLI2.Product_Start_Date__c = Date.today();
        OLI2.Product_End_Date__c = Date.today().addYears(1) ;
        OLI2.PricebookEntryId = PE2.Id;
        OLI2.Billing_Frequency__c = 'Once';
        OLI2.Proj_Rpt_Frequency__c='Once [O]';
        OLI2.Therapy_Area__c= 'Hepatitis C [21]';
        OLI2.Quantity = 1.00;
        OLI2.UnitPrice = 10000;  
        OLI2.List_Price__c = 100;   
        OLI2.Delivery_Country__c = 'USA';
        OLI2.Therapy_Area__c= 'Hepatitis C [21]';
        OLI_Array.add(OLI2);*/
        insert OLI_Array;
        opp.StageName = '7a. Closed Won';
        opp.Primary_Win_Reason__c ='Project Performance';
        opp.Win_Type__c = 'Non-competitive bid';
        update opp;
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        TestAddress_Array = new List<Address__c>();
        for (Integer i=0; i<10; i++)
        {
            Address__c TempAddress = New Address__c(Name=String.valueOf(i),
                                                    Account__c=TestAccount.Id,
                                                    Street__c = 'Street ' + i.format(),
                                                    City__c = 'City '+ i.format(),
                                                    Country__c = 'Country ' + i.format(),
                                                    SAP_Reference__c = String.valueOf(495000+i),
                                                    MDM_Validation_Status__c = 'Validated',
                                                    RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId());
            TestAddress_Array.add(TempAddress);
        } 
        insert TestAddress_Array;
        
        
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
        MIBNF.Revenue_Analyst__c=TestRA.id;
        
        insert MIBNF;
            
        MIBNF_Comp=new MIBNF_Component__c();
        MIBNF_Comp.MIBNF__c=MIBNF.Id;
        MIBNF_Comp.BNF_Status__c='New';
        MIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        MIBNF_Comp.Print_Shop__c='No';
        MIBNF_Comp.Bill_To__c=TestAddress_Array[0].Id;
        MIBNF_Comp.Ship_To__c=TestAddress_Array[0].id;
        //MIBNF_Comp.Comp_Revenue_Analyst__c = TestRA.id; 
        insert MIBNF_Comp;
        MI_BNF_LineItem__c MI_BNFLineItem= new MI_BNF_LineItem__c();
        MI_BNFLineItem.MIBNF_Component__c=MIBNF_Comp.id;
        MI_BNFLineItem.Opportunity_Line_Itemid__c=OLI1.Id;
        MI_BNFLineItem.Total_Price__c=OLI1.TotalPrice;
        insert MI_BNFLineItem;
      }  
   }
    
   //@isTest 
    /*static void testdeleteMIBNFComp () {
      
        Test.startTest();
        MIBNF_Component__c TestMIBNF  = [Select id, Comp_Revenue_Analyst__c, Comments__c from MIBNF_Component__c Limit 1];
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(TestMIBNF.Id);
        Approval.ProcessResult result = Approval.process(req1);
        try {
            delete TestMIBNF;    
            System.assert(false,'code never reached here');
        }
        catch(DMlException e) {
            System.assert(true, 'custom validation error occured');
        }
        Test.stopTest();
    }*/
    
}