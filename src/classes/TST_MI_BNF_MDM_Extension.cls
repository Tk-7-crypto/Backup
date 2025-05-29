@isTest
private class TST_MI_BNF_MDM_Extension {
    
    private static MI_BNF_MDM_Extension controller;
    
    @testSetup static void setupTestData(){
        UTL_ExecutionControl.stopTriggerExecution = true;
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        
        Account TestAccount = BNF_Test_Data.createAccount();
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        List<SAP_Contact__c> TestSapContact_Array = BNF_Test_Data.createSapContact_Array();
        UTL_ExecutionControl.stopTriggerExecution = false;
        Opportunity opp = BNF_Test_Data.createOpp();
        UTL_ExecutionControl.stopTriggerExecution = true;
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
    }
    
    static TestMethod void MDMTest()
    {
        Account acc = [SELECT id,name,Status__c from account][0];  
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        
        Test.startTest();
        acc.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        upsert acc;
        ApexPages.CurrentPage().getParameters().put('id' , TestMIBNF_Comp.id );
        PageReference pageRef = ApexPages.currentPage();
        Test.setCurrentPageReference(pageRef);
        
        //  Create an instance of the standard controller
        ApexPages.StandardController stc = new ApexPages.StandardController(TestMIBNF_Comp);
        //  Create an instance of the controller extension       
        controller = new MI_BNF_MDM_Extension(stc);
        
        controller.Initialise();
        controller.DoNothing();
        controller.fetchValidId(null);
        controller.getAccountAddresses();
        controller.getAddressSelectorRendered();
        controller.Cancel();
        controller.getAddressContacts(TestAddress_Array[0].Id);
        controller.getAddressDetails(TestAddress_Array[0].Id);
        controller.getBillToContacts();
        controller.getShipToContacts();
        controller.getSecondCopyContacts();
        controller.getCarbonCopyContacts();
        controller.getCoverSheetContacts();
        controller.NextAddressPage();
        controller.PrevAddressPage();
        controller.getMoreNextAddressesAvailable();
        controller.getMorePrevAddressesAvailable();
        controller.getBillToAddressDetails();
        controller.getShipToAddressDetails();
        controller.getSecondCopyAddressDetails();
        controller.getCoverSheetAddressDetails();
        controller.getCarbonCopyAddressDetails();
        controller.getNumAddressRecordsPerPage();
        controller.getBnfId();
        controller.getBnfAccountId();
        controller.Save();
        controller.ShowInfoMessages();
        controller.getTextBox();
        controller.getAddressID();
        controller.getSAPContactName();
        controller.getAddressName();
        controller.getFormTag();
        
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Global_Variables.syncAgreementToOppty=false;
        Global_Variables.PCTrigger_Hault_Execution=false;
        
        MIBNF_Component__c TestMIBNF_Comp2=new MIBNF_Component__c();
        TestMIBNF_Comp2.MIBNF__c=TestMIBNF.Id;
        TestMIBNF_Comp2.BNF_Status__c='New';
        TestMIBNF_Comp2.Is_this_a_retainer_downpayment__c='No';
        TestMIBNF_Comp2.Print_Shop__c='No';
        insert TestMIBNF_Comp2;
        
        Apexpages.currentPage().getParameters().put('newid',TestMIBNF_Comp2.Id);
        Apexpages.currentPage().getParameters().put('OriginalBnfId',TestMIBNF_Comp.Id);
        controller.ShowSapCodeSelectionPanel();
        controller.HideSapCodeSelectionPanel();
        controller.SearchAddressByName();
        controller.NextAddressSearchPage();
        controller.PrevAddressSearchPage();
        controller.getMoreNextAddressSearchAvailable();
        controller.getMorePrevAddressSearchAvailable();
        controller.getSearchAddresses();
        test.stoptest();
    }
    
    static TestMethod void MIBNFAddressTest()
    {
        
        Account acc = [SELECT id,name,Status__c from account][0];  
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        
        ApexPages.CurrentPage().getParameters().put('id' , TestMIBNF_Comp.id );
        ApexPages.CurrentPage().getParameters().put('wz' , '1' );
        PageReference pageRef = ApexPages.currentPage();
        Test.setCurrentPageReference(pageRef);
        //  Create an instance of the standard controller
        ApexPages.StandardController stc = new ApexPages.StandardController(TestMIBNF_Comp);
        //  Create an instance of the controller extension       
        controller = new MI_BNF_MDM_Extension(stc);
        controller.Initialise();
        
        delete TestAddress_Array;
        controller.Initialise();
        test.stoptest();
    }
    
    
    static TestMethod void MDMBillToSave()
    {
        
        Account acc = [SELECT id,name,Status__c from account][0];  
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        
        acc.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        upsert acc;
        ApexPages.CurrentPage().getParameters().put('id' , TestMIBNF_Comp.id );
        PageReference pageRef = ApexPages.currentPage();
        Test.setCurrentPageReference(pageRef);
        
        //  Create an instance of the standard controller
        ApexPages.StandardController stc = new ApexPages.StandardController(TestMIBNF_Comp);
        //  Create an instance of the controller extension       
        controller = new MI_BNF_MDM_Extension(stc);
        
        controller.MIBNF_Comp.Bill_To__c=null;
        pageRef=controller.Save();
        ApexPages.Message msg1 = ApexPages.getMessages()[0];
        test.stoptest(); 
        
    }
    
    static TestMethod void MDMShipToSave()
    {
        Account acc = [SELECT id,name,Status__c from account][0];  
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        
        acc.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        upsert acc;
        ApexPages.CurrentPage().getParameters().put('id' , TestMIBNF_Comp.id );
        PageReference pageRef = ApexPages.currentPage();
        Test.setCurrentPageReference(pageRef);
        //  Create an instance of the standard controller
        ApexPages.StandardController stc = new ApexPages.StandardController(TestMIBNF_Comp);
        //  Create an instance of the controller extension       
        controller = new MI_BNF_MDM_Extension(stc);
        
        
        controller.getAddressContacts(TestAddress_Array[0].Id);
        controller.getAddressDetails(TestAddress_Array[0].Id);
        controller.getBillToContacts();
        controller.getBillToAddressDetails();
        controller.getBnfId();
        controller.getBnfAccountId();
        controller.MIBNF_Comp.Bill_To__c= TestAddress_Array[0].Id; 
        controller.MIBNF_Comp.Ship_To__c=null;
        pageRef=controller.Save();
        ApexPages.Message msg1 = ApexPages.getMessages()[0];
        test.stoptest();
    }
    
    static TestMethod void MDMShipToSave1()
    {
        
        Account acc = [SELECT id,name,Status__c from account][0];  
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        
        acc.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        upsert acc;
        ApexPages.CurrentPage().getParameters().put('id' , TestMIBNF_Comp.id );
        PageReference pageRef = ApexPages.currentPage();
        Test.setCurrentPageReference(pageRef);
        //  Create an instance of the standard controller
        ApexPages.StandardController stc = new ApexPages.StandardController(TestMIBNF_Comp);
        //  Create an instance of the controller extension       
        controller = new MI_BNF_MDM_Extension(stc);
        
        
        controller.getAddressContacts(TestAddress_Array[0].Id);
        controller.getAddressDetails(TestAddress_Array[0].Id);
        controller.getBillToContacts();
        controller.getBillToAddressDetails();
        controller.getBnfId();
        controller.getBnfAccountId();
        controller.MIBNF_Comp.Bill_To__c= TestAddress_Array[0].Id; 
        controller.MIBNF_Comp.Ship_To__c= TestAddress_Array[0].Id;
        pageRef=controller.Save();
        test.stoptest();
    }
    
    static TestMethod void MDMSaveSuccess()
    {
        Account acc = [SELECT id,name,Status__c from account][0];  
        Opportunity opp =[SELECT Id,AccountId, Opportunity_Number__c FROM Opportunity LIMIT 1];
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        List<SAP_Contact__c> TestSapContact_Array = new List<SAP_Contact__c>([Select id,name,Address__c,SAP_Contact_Number__c from SAP_Contact__c]);
        Revenue_Analyst__c TestLocalRA = UTL_TestData.createRevenueAnalyst();
        insert TestLocalRA;
        MIBNF2__c TestMIBNF = UTL_TestData.createMIBNF(opp, TestLocalRA);
        insert TestMIBNF;
        
        Test.startTest();
        MIBNF_Component__c TestMIBNF_Comp = UTL_TestData.createMIBNF_Comp(TestMIBNF, TestAddress_Array);
        insert TestMIBNF_Comp;
        
        acc.Status__c = MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED');
        upsert acc;
        ApexPages.CurrentPage().getParameters().put('id' , TestMIBNF_Comp.id );
        PageReference pageRef = ApexPages.currentPage();
        Test.setCurrentPageReference(pageRef);
        //  Create an instance of the standard controller
        ApexPages.StandardController stc = new ApexPages.StandardController(TestMIBNF_Comp);
        //  Create an instance of the controller extension       
        controller = new MI_BNF_MDM_Extension(stc);
        
        
        controller.getAddressContacts(TestAddress_Array[0].Id);
        controller.getAddressDetails(TestAddress_Array[0].Id);
        controller.getBillToContacts();
        controller.getBillToAddressDetails();
        controller.getBnfId();
        controller.getBnfAccountId();
        controller.MIBNF_Comp.Bill_To__c=TestAddress_Array[0].Id; 
        controller.MIBNF_Comp.Ship_To__c=TestAddress_Array[0].Id;
        controller.MIBNF_Comp.Carbon_Copy__c=TestAddress_Array[0].Id;
        controller.MIBNF_Comp.X2nd_Copy__c=TestAddress_Array[0].Id;
        controller.MIBNF_Comp.Bill_To_SAP_Contact__c=TestSapContact_Array[0].Id;
        controller.MIBNF_Comp.Ship_To_SAP_Contact__c=TestSapContact_Array[0].Id;
        controller.MIBNF_Comp.X2nd_Copy_SAP_Contact__c=TestSapContact_Array[0].Id;        
        pageRef=controller.Save();
        controller.MIBNF_Comp.Sold_To__c = controller.MIBNF_Comp.Bill_To__c;
        pageRef=controller.Save();
        System.assertNotEquals(ApexPages.getMessages(),null);
        test.stoptest();
    }
}