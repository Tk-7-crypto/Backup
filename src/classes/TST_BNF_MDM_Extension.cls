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
private class TST_BNF_MDM_Extension {
    
    private static BNF_MDM_Extension controller;
    
    
    @testSetup static void setupTestData(){
        Global_Variables.PCFlag = false;
        Global_Variables.RunQuickOppLimitTrigger = false;
        Global_Variables.RenewalCloneFlag = TRUE;
        Account TestAccount = BNF_Test_Data.createAccount();
        List<Address__c> TestAddress_Array = BNF_Test_Data.createAddress_Array();
        List<SAP_Contact__c> TestSapContact_Array = BNF_Test_Data.createSapContact_Array();
        Opportunity opp = BNF_Test_Data.createOpp();
        BNF_Settings__c bnfsetting = BNF_Test_Data.createBNFSetting();
        Current_Release_Version__c currentReleaseVersion = BNF_Test_Data.createCurrentReleaseVersionSetting();
        List<OpportunityLineItem> OLI_Array = BNF_Test_Data.createOppLineItem();
        BNF2__c TestBnf = BNF_Test_Data.createBNF();
    }
    
    static testMethod void t1()
    {   
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        BNF2__c TestBnf = bnfList[0];
        List<Account> accList = new List<Account>([Select id,name,Status__c from account]);
        //accList[0].Status__c = 'new';
        //upsert accList;
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        List<Address__c> TestAddress_Array = [Select id,Name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c];
        Test.starttest();
        pageReference AddressSelector = Page.BNF_Address_Selector;
        AddressSelector.getParameters().put('id',TestBnf.Id);
        AddressSelector.getParameters().put('AccountId',accList[0].id);
        System.debug('********* '+ApexPages.currentPage().getParameters().get('AccountId'));
        ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf);
        //  Create an instance of the controller extension       
        controller = new BNF_MDM_Extension(stc);
        controller.Initialise();
        
        controller.AddressSelectorRedirect();
        //controller.CreateNewBnf();
        controller.DoNothing();
        controller.fetchValidId(null);
        controller.getAccountAddresses();
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
        controller.ShowInfoMessages();
        controller.getBnfAccountId();
        
        
        controller.Save();
        controller.getAddressSelectorRendered();
        controller.getSalesOrgs();
        
        BNF2__c TestBnf2 = new BNF2__c(Opportunity__c=TestOpp.Id);
        TestBnf2.BNF_Status__c = 'New';
        TestBnf2.IMS_Sales_Org__c = 'IMS Spain';
        TestBnf2.Sales_Org_Code__c = 'CH04';
        // Added By : Himanshu Parashar
        // Date : 31-05-2012
        // only One BNF is allowed so creating as Revised BNF
        TestBNF2.Addendum__c=true;
        TestBNF2.Revised_BNF_Date__c=system.today();
        
        insert TestBnf2;
        Apexpages.currentPage().getParameters().put('newid',TestBnf2.Id);
        Apexpages.currentPage().getParameters().put('OriginalBnfId',TestBnf.Id);
        controller.UpdateCloneFromOriginal();
        controller.UpdateCloneWithAttachmentFromOriginal();
        controller.ShowSapCodeSelectionPanel();
        controller.HideSapCodeSelectionPanel();
        controller.SearchAddressByName();
        controller.NextAddressSearchPage();
        controller.PrevAddressSearchPage();
        controller.getMoreNextAddressSearchAvailable();
        controller.getMorePrevAddressSearchAvailable();
        controller.getSearchAddresses();
        controller.getFormTag();
        controller.getTextBox();
        controller.getAddressID();
        controller.getSAPContactName();
        controller.getAddressName();            
        
        controller.BNF.Ship_To__c = null;
        controller.Save();
        test.stoptest();
    }
    
     //Quick Opp
    // Update by: Himanshu Parashar
    // Test method for quick opportunity
    static TestMethod void TestQuickOppAndBnfSAPValidated()
    {
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        BNF2__c TestBnf = bnfList[0];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        List<Account> accList = new List<Account>([Select id,name,Status__c from account]);
        List<Address__c> createAddress_Array = new List<Address__c>([Select id,name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c]);
        List<SAP_Contact__c> createSapContact_Array = new List<SAP_Contact__c>([Select id,name,Address__c,SAP_Contact_Number__c from SAP_Contact__c]);
        
        Profile p = [select id from profile where name like '%administrator%' limit 1]; 
        User u = new User(alias = 'jpusr', email='japnalocal@metacube.com',Sales_Org__c='[AR01] IMS Argentina',User_Country__c='Germany', 
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',Business_Unit__c='Asia Pacific',
                          localesidkey='en_US', profileid = p.Id, 
                          timezonesidkey='America/Los_Angeles', username='japnalocal@metacube.com', Change_Request_Description__c = 'test',
                          Change_Request_Ticket_Number__c ='test description', employeeNumber= '080808081');
        insert u;
        MDM_Defines.EnabledSalesOrgs.add('IHA, IMS Health Rotkreuz [CH03]');
        System.runAs(u) {                
            //setQuickOppAndBnf('SAP Validated');
            test.starttest();
            pageReference AddressSelector = Page.BNF_Address_Selector;
            AddressSelector.getParameters().put('id',TestBnf.Id);
            AddressSelector.getParameters().put('AccountId',accList[0].id);
            //Blob pageContent = AddressSelector.getContent();
            
            //  Create an instance of the standard controller
            ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf);
            //  Create an instance of the controller extension       
            controller = new BNF_MDM_Extension(stc);
            controller.Initialise();
            controller.AddressSelectorRedirect();
            controller.SalesOrg = 'IHA, IMS Health Rotkreuz [CH03]';
            PageReference pg = controller.CreateNewBnf();
            System.assertNotEquals(pg,null); 
            controller.BNF.Bill_To__c = null;
            controller.Save();
            test.stoptest();
        }
    
    }
    
    static TestMethod void TestQuickOppAndBnfNotSAPValidated()
    {
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        BNF2__c TestBnf = bnfList[0];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        List<Account> accList = new List<Account>([Select id,name,Status__c from account]);
        List<Address__c> createAddress_Array = new List<Address__c>([Select id,name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c]);
        List<SAP_Contact__c> createSapContact_Array = new List<SAP_Contact__c>([Select id,name,Address__c,SAP_Contact_Number__c from SAP_Contact__c]);
        Profile p = [select id from profile where name like '%administrator%' limit 1];
        User u = new User(alias = 'jpusr', email='japnalocal@metacube.com',Sales_Org__c='IMS Spain',User_Country__c='Germany', 
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',Business_Unit__c='East Europe',
                localesidkey='en_US', profileid = p.Id, 
                timezonesidkey='America/Los_Angeles', username='japnalocal@metacube.com', employeeNumber= '080808081');
       
        //System.runAs(u) {
                
            //setQuickOppAndBnf('Not Validated');
            test.starttest();
            pageReference AddressSelector = Page.BNF_Address_Selector;
            AddressSelector.getParameters().put('id',TestBnf.Id);
            AddressSelector.getParameters().put('newid',TestBnf.Id);
            AddressSelector.getParameters().put('addressid',createAddress_Array[0].Id);
            AddressSelector.getParameters().put('sapaddressid',createSapContact_Array[0].Id);
            AddressSelector.getParameters().put('OpportunityId',TestOpp.Id);        
            AddressSelector.getParameters().put('AccountId',accList[0].id);
            AddressSelector.getParameters().put('lookup','false');
            //Blob pageContent = AddressSelector.getContent();
            
            //  Create an instance of the standard controller
            ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf);
            //  Create an instance of the controller extension       
            controller = new BNF_MDM_Extension(stc);
            controller.Initialise();
            controller.AddressSelectorRedirect();
            controller.SalesOrg = 'IHA, IMS Health Rotkreuz [CH03]';
            PageReference pg=controller.CreateNewBnf();
            
            delete createAddress_Array;
            controller.Initialise();
        
            //BNF2__c tstBNF = new BNF2__c();
            //ApexPages.StandardController stc1 = new ApexPages.StandardController(tstBNF);
            //controller = new BNF_MDM_Extension(stc1);
            test.stoptest(); 
         //}
    
    }
    
    static TestMethod void TestOppAndBnfNotSAPValidated1()
    {
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        BNF2__c TestBnf = bnfList[0];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        
        List<Account> accList = new List<Account>([Select id,name,Status__c from account]);
        List<Address__c> createAddress_Array = new List<Address__c>([Select id,name,Enabled_Sales_Orgs__c,Account__c,Street__c,City__c,Country__c,SAP_Reference__c from Address__c]);
        List<SAP_Contact__c> createSapContact_Array = new List<SAP_Contact__c>([Select id,name,Address__c,SAP_Contact_Number__c from SAP_Contact__c]);
        Profile p = [select id from profile where name like '%administrator%' limit 1];
        User u = new User(alias = 'jpusr', email='japnalocal@metacube.com',Sales_Org__c='IMS Spain',User_Country__c='Germany', 
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',Business_Unit__c='East Europe',
                localesidkey='en_US', profileid = p.Id, 
                timezonesidkey='America/Los_Angeles', username='japnalocal@metacube.com', employeeNumber= '080808081');
       
        //System.runAs(u) {
                
            //setQuickOppAndBnf('Not Validated');
            test.starttest();
            pageReference AddressSelector = Page.BNF_Address_Selector;
            AddressSelector.getParameters().put('id',TestBnf.Id);
            AddressSelector.getParameters().put('newid',TestBnf.Id);
            AddressSelector.getParameters().put('addressid',createAddress_Array[0].Id);
            AddressSelector.getParameters().put('sapaddressid',createSapContact_Array[0].Id);
            AddressSelector.getParameters().put('OpportunityId',TestOpp.Id);        
            AddressSelector.getParameters().put('AccountId',accList[0].id);
            AddressSelector.getParameters().put('lookup','false');
            //Blob pageContent = AddressSelector.getContent();
            ApexPages.CurrentPage().getParameters().put('AccountId',accList[0].id);
            ApexPages.CurrentPage().getParameters().put('newid',TestBnf.Id);
            //  Create an instance of the standard controller
            ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf);
            //  Create an instance of the controller extension
            controller = new BNF_MDM_Extension(stc);
            controller.Initialise();
            controller.AddressSelectorRedirect();
            controller.SalesOrg = 'IHA, IMS Health Rotkreuz [CH03]';
            PageReference pg = controller.CreateNewBnf();
            System.assertEquals(pg, null);
            delete createAddress_Array;
            controller.Initialise();
        
            //BNF2__c tstBNF = new BNF2__c();
            //ApexPages.StandardController stc1 = new ApexPages.StandardController(tstBNF);
            //controller = new BNF_MDM_Extension(stc1);
            test.stoptest();
         //}
    
    }
    static TestMethod void testIBNF()
    {
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        BNF2__c TestBnf = bnfList[0];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        Account newAccount = UTL_TestData.createAccount();
		newAccount.MDM_Validation_Status__c = CON_CRM.MDM_VALIDATION_STATUS_VALIDATED;
		insert newAccount;
        TestOpp.AccountId = newAccount.id;
        update TestOpp;
        Profile p = [select id from profile where name like '%administrator%' limit 1]; 
        User u = new User(alias = 'jpusr', email='japnalocal@metacube.com',Sales_Org__c='[AR01] IMS Argentina',User_Country__c='Germany', 
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',Business_Unit__c='Asia Pacific',
                          localesidkey='en_US', profileid = p.Id, 
                          timezonesidkey='America/Los_Angeles', username='japnalocal@metacube.com', Change_Request_Description__c = 'test',
                          Change_Request_Ticket_Number__c ='test description', employeeNumber= '080808081');
        insert u;
        MDM_Defines.EnabledSalesOrgs.add('[DE82] Kairos GmbH');
        System.runAs(u) {                
            test.starttest();
            pageReference AddressSelector = Page.BNF_Address_Selector;
            AddressSelector.getParameters().put('id',TestBnf.Id);
            AddressSelector.getParameters().put('AccountId',newAccount.id);
           
            ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf);
            //  Create an instance of the controller extension       
            controller = new BNF_MDM_Extension(stc);
            controller.Initialise();
            controller.AddressSelectorRedirect();
            controller.SalesOrg = '[DE82] Kairos GmbH';
            PageReference pg = controller.CreateNewBnf();
            test.stoptest();
        }
    
    }
    
    // Method to setup quick opp
    /*static void setQuickOppAndBnf(String SAPType) 
    {
        RecordType recordtypeId = [SELECT Id FROM RecordType where Name Like 'Quick Opportunity'];
        List<Opportunity> opptyList = new List<Opportunity>([Select id,Name,StageName,CloseDate, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity]);
        
        if(opptyList.size()>0) {
            Opportunity TestOpp = opptyList[0];
            TestOpp.RecordTypeId=recordtypeId.Id;
            // Stop PA trigger
       		Global_Variables.PCFlag = false;
            upsert TestOpp;
        }
    }*/
    
    static TestMethod void testiqviaQuoteValidationCheck()
    {
        List<BNF2__c> bnfList = new List<BNF2__c>([Select id,name,Opportunity__c,BNF_Status__c,IMS_Sales_Org__c,Sales_Org_Code__c,Bill_To__c,X2nd_Copy__c,Carbon_Copy__c,Ship_To__c,Cover_Sheet__c from BNF2__c]);
        BNF2__c TestBnf = bnfList[0];
        Opportunity TestOpp = [Select id,Name,StageName,CloseDate, AccountId,Contract_Term__c,Contract_End_Date__c,Contract_Start_Date__c,Contract_Type__c,LeadSource,CurrencyIsoCode from Opportunity][0];
        Account newAccount = UTL_TestData.createAccount();
		newAccount.MDM_Validation_Status__c = CON_CRM.MDM_VALIDATION_STATUS_VALIDATED;
		insert newAccount;
        TestOpp.AccountId = newAccount.id;
        update TestOpp;
        Profile p = [select id from profile where name like '%administrator%' limit 1]; 
        User u = new User(alias = 'jpusr', email='japnalocal@metacube.com',Sales_Org__c='[AR01] IMS Argentina',User_Country__c='Germany', 
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',Business_Unit__c='Asia Pacific',
                          localesidkey='en_US', profileid = p.Id, 
                          timezonesidkey='America/Los_Angeles', username='japnalocal@metacube.com', Change_Request_Description__c = 'test',
                          Change_Request_Ticket_Number__c ='test description', employeeNumber= '080808081');
        insert u;
        MDM_Defines.EnabledSalesOrgs.add('[DE82] Kairos GmbH');
        System.runAs(u) {                
            test.starttest();
            pageReference AddressSelector = Page.BNF_Address_Selector;
            AddressSelector.getParameters().put('id',TestBnf.Id);
            AddressSelector.getParameters().put('AccountId',newAccount.id);
           
            ApexPages.StandardController stc = new ApexPages.StandardController(TestBnf);
            //  Create an instance of the controller extension       
            controller = new BNF_MDM_Extension(stc);
            controller.Initialise();
            controller.AddressSelectorRedirect();
            controller.SalesOrg = '[DE82] Kairos GmbH';
            PageReference pg = controller.CreateNewBnf();
            controller.iqviaQuoteValidationCheck(TestOpp.id);
            test.stoptest();
        }
    
    }
}