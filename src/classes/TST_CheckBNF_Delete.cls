@isTest
public class TST_CheckBNF_Delete {
    
    @testSetup static void setupTestData(){
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        Revenue_Analyst__c TestLocalRA = new Revenue_Analyst__c(ownerId = UserInfo.getUserId() , name='TestRA',User__c = UserInfo.getUserId() ,Revenue_Analyst_Email__c='test123192@metacube.com');
        insert TestLocalRA;
        BNF_Settings__c bnfsetting=new BNF_Settings__c(Enable_Material_Validation__c=true,Enable_Customer_Validation__c=true,BNF_Opportunity_Threshold__c = 1000, Enable_BNF_Surcharge__c=true, Enable_Billing_Schedule_Validation__c = true,Revenue_Analyst_Exception_Email__c = 'dheeraj.kumar1@metacube.com');
        bnfsetting.Excluded_Products__c = 'ZQUI|test';
        insert bnfsetting;
        Automated_User_Downgrade_Settings__c downgradeSettings = new Automated_User_Downgrade_Settings__c(FailureEmail__c = 'dheeraj.kumar1@metacube.com');
        insert downgradeSettings;
        
        Account TestAccount = BNF_Test_Data.createAccount();
        Contact con = UTL_TestData.createContact(TestAccount.Id);
        con.RecordTypeId = CON_CRM.CONTACT_RECORD_TYPE_ID;
        con.Salesforce_User__c = UserInfo.getUserId();
        con.Survey_Opt_Out__c = false;
        insert con;
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        for(Integer index = 0; index < TestAddress_Array.size(); index++) {
            TestAddress_Array[index].MDM_Validation_Status__c = 'Validated';
            TestAddress_Array[index].RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId(); 
        }
        update TestAddress_Array;
        List<SAP_Contact__c> TestSapContact_Array = BNF_Test_Data.createSapContact_Array();
        
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        Opportunity TestOpp = new Opportunity(Name='test',CloseDate=System.today());
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.StageName='7a. Closed Won';
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
        TestOpp.Survey_Recipient__c = con.Id;
        //TestOpp.Unique_Business_Value__c = 'Unknown';
        //TestOpp.Therapy_Area__c= 'Hepatitis C [21]';
        TestOpp.Potential_Competitor_1__c = comp.Id;	
        insert TestOpp;
        
        Product2 prod1 = new Product2(Name='test1', ProductCode='1', Enabled_Sales_Orgs__c='CH03', Offering_Type__c = 'Commercial Tech', Material_Type__c = 'ZREP',CanUseRevenueSchedule= true, Delivery_Media__c = 'DVD [DV]:CD [CD]',Delivery_Frequency__c = 'Monthly:Quaterly');
        prod1.Pillar__c = 'Information Offering; Technology Solutions; R&D';
        insert prod1;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.UseStandardPrice = false;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id=prod1.id;
        pbe.IsActive=true;
        pbe.UnitPrice=100.0;
        pbe.CurrencyIsoCode = 'USD';
        insert pbe;
        
        
        Profit_Centre__c pseregion = CommanUtilityTestFunction.setUpRegion();
        insert pseregion; 
        SalesOrg__c salesorg = CommanUtilityTestFunction.setUpSalesOrg();
        insert salesorg;
        Account acc = CommanUtilityTestFunction.createAccount();
        acc.Website = 'https://www.test.com';
        insert acc;
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        for(integer i = 0; i < 2; i++){
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = TestOpp.Id;
            oli.Product_Start_Date__c = Date.today();
            oli.Product_End_Date__c = Date.today().addYears(1) ;
            oli.PricebookEntryId = pbe.Id;
            oli.Billing_Frequency__c = 'Once';
            oli.Proj_Rpt_Frequency__c='Once [O]';
            oli.Therapy_Area__c= 'Hepatitis C [21]';
            oli.Quantity = 1.00;
            oli.UnitPrice = 9000;  
            oli.List_Price__c = 9000;
            //oli.Budget__c = budg.id;
            oli.Delivery_Date__c = System.today().addYears(1);
            oli.Revenue_Type__c = 'Ad Hoc';
			oli.Delivery_Country__c = 'USA';
            oli.Sale_Type__c = 'New';
            oli.Wbsrelementcode__c = 'asd';
            oliList.add(oli);
        }
        insert oliList;
        
        List<OpportunityLineItemSchedule> InsertOLISList = new List<OpportunityLineItemSchedule>();
        Integer RevFactor = 1;
        
        Date strScheduleDate = Date.valueOf(String.valueOf(System.now().year())+'-01-15 00:00:00');    
        for(OpportunityLineItem oli : oliList){
            RevFactor = 1;
            for (Integer i = 0; i < 3; i++) 
            {
                Double dRevenueAmount = RevFactor*1000.00;
                RevFactor = RevFactor + 2;
                OpportunityLineItemSchedule OliSched = new OpportunityLineItemSchedule();
                OliSched.OpportunityLineItemId = oli.Id;
                OliSched.Type = 'Revenue';
                OliSched.Revenue = dRevenueAmount;
                OliSched.ScheduleDate = strScheduleDate;
                strScheduleDate = strScheduleDate.addMonths(1);
                InsertOLISList.add(OliSched); 
            }
        }
        insert InsertOLISList;
    }
    
    static testMethod void createBNFTestData() {
        upsert new Mulesoft_Integration_Control__c(Ignore_Validation_Rules__c = false); 
        Opportunity testOpp = [Select id from Opportunity limit 1];
        List<Address__c> TestAddress_Array = [Select id from Address__c limit 5];
        Test.startTest();
        BNF2__c TestBnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        TestBnf.BNF_Status__c = 'New';
        TestBnf.Contract_Start_Date__c = Date.today();
        TestBnf.Contract_End_Date__c = Date.today().addYears(1);
        TestBnf.IMS_Sales_Org__c = 'IHA, IMS Health Rotkreuz';
        TestBnf.Sales_Org_Code__c='CH03';
        TestBnf.Bill_To__c=TestAddress_Array[0].id;
        TestBnf.X2nd_Copy__c=TestAddress_Array[1].id;
        TestBnf.Carbon_Copy__c=TestAddress_Array[2].id;
        TestBnf.Ship_To__c=TestAddress_Array[3].id;
        TestBnf.Cover_Sheet__c=TestAddress_Array[4].id;
        TestBnf.RecordTypeId = MDM_Defines.SAP_SD_Integrated_Record_Type_Id;
        Revenue_Analyst__c TestLocalRA = [Select id from Revenue_Analyst__c limit 1];
        TestBnf.Revenue_Analyst__c = TestLocalRA.id;  
        insert TestBnf;
        delete TestBnf;
        Test.stopTest();
    }
}