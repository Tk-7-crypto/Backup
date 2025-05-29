@isTest
public class TST_CNT_CRM_ExportBillingScheduleItems {
	
    static CNT_CRM_ExportBillingScheduleItems classObj;
    static BNF_BillingScheduleController classObjBNF;
    @testSetup
    static void setupTestData(){
        Account TestAccount = BNF_Test_Data.createAccount();
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        List<SAP_Contact__c> TestSapContact_Array = BNF_Test_Data.createSapContact_Array();
        Opportunity opp = BNF_Test_Data.createOpp();
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        Current_Release_Version__c currentReleaseVersionSetting = BNF_Test_Data.createCurrentReleaseVersionSetting();
        List<User_Locale__c> User_LocaleSetting = BNF_Test_Data.create_User_LocaleSetting();
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
        User u = BNF_Test_Data.createUser();
        Revenue_Analyst__c TestLocalRA = BNF_Test_Data.createRA();
        BNF2__c TestBnf = BNF_Test_Data.createBNF();
    }
    
    static testMethod void exportBillingItems(){
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity opp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        List<OpportunityLineitem> oliList1 = [Select Opportunity.CEQActiveRelease__c,Discount_Percentage_Formula__c, PricebookEntry.Name,
                                              PricebookEntry.Product2.Material_Type__c,PricebookEntry.Product2.Offering_Group__c ,Opportunity.Therapy_Area__c,
                                              PricebookEntry.Product2.Offering_Type__c , List_Price__c, Nbr_of_Users__c, Book_No__c,Other_Ship_To_SAP_Contact__c,
                                              CurrencyISOCode,TotalPrice,Delivery_Media__c, Product_Invoice_Text__c, PricebookEntry.ProductCode,PricebookEntry.Product2.Delivery_Media__c,
                                              PricebookEntry.Product2.Delivery_Frequency__c,Other_Ship_To_Address__c,Surcharge_Text__c,
                                              Billing_Frequency__c,Product_Start_Date__c,Product_End_Date__c, Proj_Rpt_Frequency__c,Discount_Reason__c, 
                                              Discount_Amount_Formula__c, Other_Ship_To__c, Billing_Date__c, Sale_Type__c, Revenue_Type__c,PricebookEntry.Product2.Item_Category_Group__c,
                                              Invoice_Lag_to_Data_Period__c, Revised_Price__c,Therapy_Area__c, Cancel__c,Business_Type__c, Delivery_Date__c,PO_Number__c,
                                              Sales_Text__c,Budget_Therapy_Area__c,Project_Start_Date__c,Project_End_Date__c, 
                                              OpportunityId,Billing_Schedule_Error_Msg__c,Revised_Revenue_Schedule__c,Revenue_Schedule_Error_Msg__c From OpportunityLineItem where OpportunityId = :opp.id ];
      
        Billing_Schedule__c sche = new Billing_Schedule__c(name = 'textSchedule', OLIId__c = oliList1[0].id);
        insert sche;        
        Billing_Schedule_Item__c schItem = new Billing_Schedule_Item__c(name = 'textScheduleItem', Billing_Amount__c = 2000,Billing_Date__c = system.today(),Billing_Schedule__c = sche.id);
        insert schItem;
        
        Billing_Schedule__c sche1 = new Billing_Schedule__c(name = 'textSchedule', OLIId__c = oliList1[1].id);
        insert sche1;        
        Billing_Schedule_Item__c schItem1 = new Billing_Schedule_Item__c(name = 'textScheduleItem', Billing_Amount__c = 2000,Billing_Date__c = system.today(),Billing_Schedule__c = sche1.id);
        insert schItem1;
        
        String oliIDSet = '';
        for(OpportunityLineitem oli : oliList1){
            if(oli.Id != null){
                oliIDSet += oli.Id + ',';
            }
        }
        oliIDSet.removeEnd(',');
        System.debug(oliIDSet);
         
        Test.startTest();
        PageReference pageRef = new PageReference('Page.VFP_CRM_ExportBillingScheduleItems');
        pageRef.getParameters().put('dataParam',oliIDSet);
        Test.setCurrentPage(pageRef);
        classObj = new CNT_CRM_ExportBillingScheduleItems();
        Test.stopTest();
    }
    
    static testMethod void exportBillingItemsWithoutSchedule(){
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        Opportunity opp = [Select id,Name,StageName,CloseDate,Budget_Available__c, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        List<OpportunityLineitem> oliList1 = [Select Opportunity.CEQActiveRelease__c,Discount_Percentage_Formula__c, PricebookEntry.Name,
                                              PricebookEntry.Product2.Material_Type__c,PricebookEntry.Product2.Offering_Group__c ,Opportunity.Therapy_Area__c,
                                              PricebookEntry.Product2.Offering_Type__c , List_Price__c, Nbr_of_Users__c, Book_No__c,Other_Ship_To_SAP_Contact__c,
                                              CurrencyISOCode,TotalPrice,Delivery_Media__c, Product_Invoice_Text__c, PricebookEntry.ProductCode,PricebookEntry.Product2.Delivery_Media__c,
                                              PricebookEntry.Product2.Delivery_Frequency__c,Other_Ship_To_Address__c,Surcharge_Text__c,
                                              Billing_Frequency__c,Product_Start_Date__c,Product_End_Date__c, Proj_Rpt_Frequency__c,Discount_Reason__c, 
                                              Discount_Amount_Formula__c, Other_Ship_To__c, Billing_Date__c, Sale_Type__c, Revenue_Type__c,PricebookEntry.Product2.Item_Category_Group__c,
                                              Invoice_Lag_to_Data_Period__c, Revised_Price__c,Therapy_Area__c, Cancel__c,Business_Type__c, Delivery_Date__c,PO_Number__c,
                                              Sales_Text__c,Budget_Therapy_Area__c,Project_Start_Date__c,Project_End_Date__c, 
                                              OpportunityId,Billing_Schedule_Error_Msg__c,Revised_Revenue_Schedule__c,Revenue_Schedule_Error_Msg__c From OpportunityLineItem where OpportunityId = :opp.id ];
        
        String oliIDSet = '';
        for(OpportunityLineitem oli : oliList1){
            if(oli.Id != null){
                oliIDSet += oli.Id + ',';
            }
        }
        oliIDSet.removeEnd(',');
        System.debug(oliIDSet);
         
        Test.startTest();
        PageReference pageRef = new PageReference('Page.VFP_CRM_ExportBillingScheduleItems');
        pageRef.getParameters().put('dataParam',oliIDSet);
        Test.setCurrentPage(pageRef);
        classObj = new CNT_CRM_ExportBillingScheduleItems();
        Test.stopTest();
    }
}