@isTest
public class TST_AddProductBillingScheduleController {
    
    static date sDate = date.newInstance(2016, 1, 1);
    static date eDate = date.newInstance(2016,12,31);  
    
    static void setupTestData(){
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = true;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        //OpportunityTriggerUtil.RunBeforeTrigger = false;
        //OpportunityTriggerUtil.RunAfterTrigger = false;
        Global_Variables.isupdatableOppPlan = false;
        Global_Variables.isclonningOpportunity = true;
        Current_Release_Version__c currReleaseVersion = new Current_Release_Version__c();
        currReleaseVersion.Current_Release__c = '2019.02';
        insert currReleaseVersion;
        Account TestAccount = BNF_Test_Data.createAccount();
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        List<SAP_Contact__c> TestSapContact_Array = BNF_Test_Data.createSapContact_Array();
        Opportunity opp = BNF_Test_Data.createOpp();
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        List<User_Locale__c> User_LocaleSetting = BNF_Test_Data.create_User_LocaleSetting();
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
        User u = BNF_Test_Data.createUser();
        Revenue_Analyst__c TestLocalRA = BNF_Test_Data.createRA();
    }
    
    public static testMethod void testMyController() {
        setupTestData();
        BNF2__c TestBNF = BNF_Test_Data.createBNF();
        Test.startTest();
        MIBNF2__c TestMIBNF = BNF_Test_Data.createMIBNF();
        MIBNF_Component__c TestMIBNF_Comp = BNF_Test_Data.createMIBNF_Comp();
        MI_BNF_LineItem__c TestMI_BNFLineItem = BNF_Test_Data.createMI_BNF_LineItem();
        List<Billing_Schedule__c> billingSchedule = BNF_Test_Data.createBillingSchedule();
        List<Billing_Schedule_Item__c> billingScheduleItem = BNF_Test_Data.createBillingScheduleItem();
        OpportunityLineItem oli = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                   TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem][0];
        PageReference pageRef = new PageReference('Page.AddProductBillingSchedule');
        pageRef.getParameters().put('id',oli.id);
        pageRef.getParameters().put('bnfid', TestBNF.id);
        pageRef.getParameters().put('mibnf_comp_id', TestMIBNF_Comp.id);
        pageRef.getParameters().put('startdate', sDate.format());
        pageRef.getParameters().put('enddate', eDate.format());
        pageRef.getParameters().put('salesOrg', 'CH08');
        pageRef.getParameters().put('oppId', oli.OpportunityId);
        
        Test.setCurrentPage(pageRef);
        ApexPages.standardController std = new ApexPages.standardController(oli);
        AddProductBillingScheduleController extension = new AddProductBillingScheduleController(std);
        AddProductBillingScheduleController.getBillingPatterns();
        AddProductBillingScheduleController.getBillingLevels();
        
        extension.billingLevel = 'Component Level';
        extension.billingPattern= '60/40';
        extension.calculateSchedules();                        
        
        extension.billingLevel = 'Component Level';
        extension.billingPattern= '100% on signature';
        extension.calculateSchedules();           
        
        extension.billingLevel = 'Component Level';
        extension.billingPattern= '100% on delivery';
        extension.calculateSchedules();          
        
        extension.billingLevel = 'Component Level';
        extension.billingPattern= 'MONTHLY';
        extension.calculateSchedules();   
        
        extension.billingLevel = 'Component Level';
        extension.billingPattern= 'QUARTERLY';
        extension.calculateSchedules(); 
        
        extension.addOppLevelSchedule();
        extension.selectedOpLevel = 0;
        extension.deleteSchedule();
        extension.saveOppLevelSchedules();
        extension.crudeReset();
        Test.stopTest();
    }
    
    public static testMethod void testWithoutBNF() {
        setupTestData();
        Test.startTest();
        MIBNF2__c TestMIBNF = BNF_Test_Data.createMIBNF();
        MIBNF_Component__c TestMIBNF_Comp = BNF_Test_Data.createMIBNF_Comp();
        MI_BNF_LineItem__c TestMI_BNFLineItem = BNF_Test_Data.createMI_BNF_LineItem();
        List<Billing_Schedule__c> billingSchedule = BNF_Test_Data.createBillingSchedule();
        List<Billing_Schedule_Item__c> billingScheduleItem = BNF_Test_Data.createBillingScheduleItem();
        OpportunityLineItem oli = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                   TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem][0];
        
        PageReference pageRef = new PageReference('Page.AddProductBillingSchedule');
        pageRef.getParameters().put('id',oli.id);
        pageRef.getParameters().put('mibnf_comp_id', TestMIBNF_Comp.id);
        pageRef.getParameters().put('startdate',sDate.format());
        pageRef.getParameters().put('salesOrg', 'CH08');
        pageRef.getParameters().put('oppId', oli.OpportunityId);
        Test.setCurrentPage(pageRef);
        ApexPages.standardController std = new ApexPages.standardController(oli);
        AddProductBillingScheduleController extension = new AddProductBillingScheduleController(std);
        AddProductBillingScheduleController.getBillingPatterns();
        AddProductBillingScheduleController.getBillingLevels();
        
        extension.billingLevel = 'Component Level';
        extension.billingPattern= '60/40';
        extension.calculateSchedules(); 
        extension.addOppLevelSchedule();
        
        extension.SaveScheduleListNClose();
        Test.stopTest();
    }
    
    public static testMethod void testWithZLIC() {
        setupTestData();
        BNF2__c TestBNF = BNF_Test_Data.createBNF();
        Test.startTest();
        MIBNF2__c TestMIBNF = BNF_Test_Data.createMIBNF();
        MIBNF_Component__c TestMIBNF_Comp = BNF_Test_Data.createMIBNF_Comp();
        MI_BNF_LineItem__c TestMI_BNFLineItem = BNF_Test_Data.createMI_BNF_LineItem();
        List<Billing_Schedule__c> billingSchedule = BNF_Test_Data.createBillingSchedule();
        List<Billing_Schedule_Item__c> billingScheduleItem = BNF_Test_Data.createBillingScheduleItem();
        List<Product2> products = [SELECT id, Material_Type__c, Item_Category_Group__c from Product2];
        for(product2 pro : products){
            pro.Item_Category_Group__c = 'ZLIC';
            pro.Material_Type__c = 'ZPUB';
        }
        upsert products;
        OpportunityLineItem oli = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                   TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem][0];
        
        
        PageReference pageRef = new PageReference('Page.AddProductBillingSchedule');
        pageRef.getParameters().put('id',oli.id);
        pageRef.getParameters().put('salesOrg', 'CH08');
        pageRef.getParameters().put('oppId', oli.OpportunityId);
        
        Test.setCurrentPage(pageRef);
        ApexPages.standardController std = new ApexPages.standardController(oli);
        AddProductBillingScheduleController extension = new AddProductBillingScheduleController(std);
        AddProductBillingScheduleController.getBillingPatterns();
        AddProductBillingScheduleController.getBillingLevels();
        extension.billingLevel = 'Component Level';
        extension.billingPattern= '50/50';
        extension.calculateSchedules(); 
        extension.addOppLevelSchedule();
        extension.selectedOpLevel = 0;
        extension.deleteScheduleOppLevel();
        extension.SaveOppLvlScheduleListNClose();
        Test.stopTest();
    }
    
    public static testMethod void testNegativePart() {
        setupTestData();
        MIBNF2__c TestMIBNF = BNF_Test_Data.createMIBNF();
        Test.startTest();
        MIBNF_Component__c TestMIBNF_Comp = BNF_Test_Data.createMIBNF_Comp();
        MI_BNF_LineItem__c TestMI_BNFLineItem = BNF_Test_Data.createMI_BNF_LineItem();
        List<Billing_Schedule__c> billingSchedule = BNF_Test_Data.createBillingSchedule();
        List<Billing_Schedule_Item__c> billingScheduleItem = BNF_Test_Data.createBillingScheduleItem();
        OpportunityLineItem oli = [select id, OpportunityId, Opportunity.StageName, Opportunity.currencyIsoCode, Opportunity.Contract_Start_Date__c, Opportunity.Contract_End_Date__c, Project_Start_Date__c,Project_End_Date__c,
                                   TotalPrice,PricebookEntry.Product2.Name, PricebookEntry.Product2.material_type__c,PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Item_Category_Group__c, Product_Start_Date__c, Product_End_Date__c,Revised_Price__c,Revised_Revenue_Schedule__c from OpportunityLineItem][0];
        
        PageReference pageRef = new PageReference('Page.AddProductBillingSchedule');
        pageRef.getParameters().put('id',oli.id);
        pageRef.getParameters().put('mibnf_comp_id', TestMIBNF_Comp.id);
        pageRef.getParameters().put('startdate', sDate.format());
        pageRef.getParameters().put('enddate', eDate.format());
        pageRef.getParameters().put('salesOrg', 'CH08');
        pageRef.getParameters().put('oppId', oli.OpportunityId);
        
        Test.setCurrentPage(pageRef);
        ApexPages.standardController std = new ApexPages.standardController(oli);
        AddProductBillingScheduleController extension = new AddProductBillingScheduleController(std);
        AddProductBillingScheduleController.getBillingPatterns();
        AddProductBillingScheduleController.getBillingLevels();
        
        extension.billingLevel = 'Component Level';
        extension.billingPattern= '60/40';
        extension.calculateSchedules();                        
        
        extension.billingLevel = 'Component Level';
        extension.billingPattern= '100% on signature';
        extension.calculateSchedules();           
        
        extension.billingLevel = 'Component Level';
        extension.billingPattern= '100% on delivery';
        extension.calculateSchedules();          
        
        extension.billingLevel = 'Component Level';
        extension.billingPattern= 'MONTHLY';
        extension.calculateSchedules();   
        
        extension.billingLevel = 'Component Level';
        extension.billingPattern= 'QUARTERLY';
        extension.calculateSchedules(); 
        
        extension.addOppLevelSchedule();       
        
        extension.selectedOLIId = oli.id;
        extension.selectedIdx = 0;
        extension.selectedOpLevel = 0;
        extension.deleteSchedule();
        extension.saveOppLevelSchedules();
        
        extension.billingLevel = 'Opportunity Level';
        extension.saveSchedules();
        
        extension.billingLevel = 'Component Level';
        delete extension.insertBSiList;
        extension.saveSchedules();
        
        delete extension.bsList;
        extension.saveSchedules();
        
        // Stop PA trigger
        Global_Variables.PCFlag = false;
        delete extension.oliList;
        extension.saveSchedules();
        
        extension.crudeReset();
        Test.stopTest();
    }
}