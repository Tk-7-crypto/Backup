/**
 * Test class to check SAP_Address_MDM_Extension class
 */ 
@isTest
private class TST_SAP_Address_MDM_Extension {
    
    /**
     * Method which creates data for test class
     */ 
    @testSetup
    static void dataSetup() { 
        Account account = new Account(Name='Test Account',Status__c=MDM_Defines.AddressStatus_Map.get('SAP_VALIDATED'),CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert account;
        
        List<User> userList = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE, 2);
        userList.addall(UTL_TestData.createUser('Sales User', 1));
        insert userList;
        
        Contact cnt = UTL_TestData.createContact(account.Id);
        cnt.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        cnt.Salesforce_User__c = userList[0].Id;
        insert cnt;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        Opportunity TestOpp = new Opportunity(Name='test',StageName='1. Identifying Opportunity',CloseDate=System.today());
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.Budget_Available__c = 'Yes';
        TestOpp.StageName='5. Finalizing Deal';
        TestOpp.AccountId = account.Id;
        TestOpp.Contract_Term__c='Single-Period';
        TestOpp.Contract_End_Date__c = system.today();
        TestOpp.Contract_Start_Date__c = system.today();
        TestOpp.Contract_Type__c='Individual';
        TestOpp.LeadSource = 'Account Planning';
        TestOpp.CurrencyIsoCode = 'USD';
        TestOpp.Potential_Competitor_1__c = comp.Id;			
        insert TestOpp;
        
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, TestOpp.Id);
        insert contactRole;
        
        //  Add a line item to the opportunity
        List<OpportunityLineItem> OLI_Array = new List<OpportunityLineItem>();
        Product2 product2 = UTL_TestData.createProduct();
        product2.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product2.IsActive = true;
        product2.Material_Type__c = 'ZPUB';
        insert product2;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product2.Id);
        pbEntry.CurrencyIsoCode = 'USD';
        pbEntry.IsActive = true;
        insert pbEntry;
        PricebookEntry PE1 = [SELECT Id, CurrencyIsoCode FROM PricebookEntry WHERE CurrencyIsoCode = 'USD' and IsActive = true AND Product2.IsActive = true AND Product2.Material_Type__c = 'ZPUB' limit 1][0];
        OpportunityLineItem OLI1 = UTL_TestData.createOpportunityLineItem(TestOpp.Id, PE1.Id);
        OLI1.Quantity = 1.00;
        OLI_Array.add(OLI1);
        PricebookEntry PE2 = [SELECT Id, CurrencyIsoCode FROM PricebookEntry WHERE CurrencyIsoCode = 'USD' and IsActive = true AND Product2.IsActive = true AND Product2.Material_Type__c = 'ZPUB' LIMIT 1][0];
        OpportunityLineItem OLI2 = UTL_TestData.createOpportunityLineItem(TestOpp.Id, PE2.Id);
        OLI2.Quantity = 1.00;
        OLI_Array.add(OLI2);
        insert OLI_Array;
    }
    
    /**
     * test method to check constructor conditions
     */ 
    static testMethod void testSAPAddressMDMExtensionsConstructor() {
        Test.startTest();
        Opportunity TestOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        BNF2__c bnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        bnf.BNF_Status__c = 'New';
        bnf.IMS_Sales_Org__c = 'IMS Spain';
        bnf.Client__c = TestOpp.AccountId;
        insert bnf;
        List<Account> accountList = [SELECT Id FROM Account];
        Apexpages.currentPage().getParameters().put('AccountId',accountList[0].Id);        
        Apexpages.currentPage().getParameters().put('BnfId',bnf.Id);
        Apexpages.currentPage().getParameters().put('popup','0');
        Apexpages.currentPage().getParameters().put('ApprovalRequest','true');
        Apexpages.currentPage().getParameters().put('retURL','/' + bnf.Id);  
        SAP_Address_MDM_Extension controller = new SAP_Address_MDM_Extension();
        ApexPages.Message msg1 = ApexPages.getMessages()[0];
        System.assertEquals('There are currently no addresses available for this account.  Please use the form below to submit a request for the creation of a new address in SAP.', msg1.getDetail()); 
        Test.stopTest();
    }
    
    /**
     * test method to check constructor conditions
     */ 
    static testMethod void testSAPAddressMDMExtensionsConstructor2() {
        Test.startTest();
        Opportunity TestOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        BNF2__c bnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        bnf.BNF_Status__c = 'New';
        bnf.IMS_Sales_Org__c = 'IMS Spain';
        bnf.Client__c = TestOpp.AccountId;
        insert bnf;
        
        MIBNF2__c MIBNF=new MIBNF2__c();
        MIBNF.Client__c=TestOpp.AccountId;
        MIBNF.Opportunity__c=TestOpp.Id;
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
        insert MIBNF;
        
        MIBNF_Component__c MIBNF_Comp=new MIBNF_Component__c();
        MIBNF_Comp.MIBNF__c=MIBNF.Id;
        MIBNF_Comp.BNF_Status__c='New';
        MIBNF_Comp.Is_this_a_retainer_downpayment__c='No';
        MIBNF_Comp.Print_Shop__c='No'; 
        insert MIBNF_Comp;
        Apexpages.currentPage().getParameters().put('AccountId',TestOpp.AccountId);        
        Apexpages.currentPage().getParameters().put('BnfId',bnf.Id);
        Apexpages.currentPage().getParameters().put('compId',MIBNF_Comp.Id);
        Apexpages.currentPage().getParameters().put('BnfAccountId',TestOpp.AccountId);
        SAP_Address_MDM_Extension controller = new SAP_Address_MDM_Extension();
        Test.stopTest();
    }
    
    /**
     * test method to check GetTitles method
     */ 
    static testMethod void testGetTitles() {
        Test.startTest();
        Opportunity TestOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        BNF2__c bnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        bnf.BNF_Status__c = 'New';
        bnf.IMS_Sales_Org__c = 'IMS Spain';
        bnf.Client__c = TestOpp.AccountId;
        insert bnf;
        Apexpages.currentPage().getParameters().put('AccountId',TestOpp.AccountId);        
        Apexpages.currentPage().getParameters().put('BnfId',bnf.Id);
        SAP_Address_MDM_Extension controller = new SAP_Address_MDM_Extension(); 
        controller.getTitles();
        Test.stopTest();
    }
    
    /**
     * test method to check ReturnToBnf method
     */ 
    static testMethod void testReturnToBnf() {
        Test.startTest();
        Opportunity TestOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        BNF2__c bnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        bnf.BNF_Status__c = 'New';
        bnf.IMS_Sales_Org__c = 'IMS Spain';
        bnf.Client__c = TestOpp.AccountId;
        insert bnf;
        Apexpages.currentPage().getParameters().put('AccountId',TestOpp.AccountId);        
        Apexpages.currentPage().getParameters().put('BnfId',bnf.Id);
        SAP_Address_MDM_Extension controller = new SAP_Address_MDM_Extension();
        controller.ReturnToBnf();
        Apexpages.currentPage().getParameters().put('retURL','/' + bnf.Id);
        controller.ReturnToBnf();
        Apexpages.currentPage().getParameters().put('BnfAccountId',TestOpp.AccountId);
        SAP_Address_MDM_Extension controller1 = new SAP_Address_MDM_Extension();
        controller1.ReturnToBnf();
        Test.stopTest();
    }
    
    /**
     * test method to check SendNewRequestNotificationEmail method Validation
     */ 
    static testMethod void testSendNewRequestNotificationEmailValidation() {
        Test.startTest();
        Opportunity TestOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        BNF2__c bnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        bnf.BNF_Status__c = 'New';
        bnf.IMS_Sales_Org__c = 'IMS Spain';
        bnf.Client__c = TestOpp.AccountId;
        insert bnf;
        Apexpages.currentPage().getParameters().put('AccountId',TestOpp.AccountId);        
        Apexpages.currentPage().getParameters().put('BnfId',bnf.Id);
        SAP_Address_MDM_Extension controller = new SAP_Address_MDM_Extension();
        controller.SAP_Contact = controller.getSAP_Contact();
        PageReference pg = controller.SendNewRequestNotificationEmail();
        ApexPages.Message msg = ApexPages.getMessages()[0];
        System.assertEquals('Last Name Required.', msg.getDetail());
        Test.stopTest();
    }
    
    /**
     * test method to check SendNewRequestNotificationEmail method
     */ 
    static testMethod void testSendNewRequestNotificationEmail() {
        Test.startTest();
        Opportunity TestOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        BNF2__c bnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        bnf.BNF_Status__c = 'New';
        bnf.IMS_Sales_Org__c = 'IMS Spain';
        bnf.Client__c = TestOpp.AccountId;
        insert bnf;
        Apexpages.currentPage().getParameters().put('AccountId',TestOpp.AccountId);        
        Apexpages.currentPage().getParameters().put('BnfId',bnf.Id);
        SAP_Address_MDM_Extension controller = new SAP_Address_MDM_Extension();
        controller.SAP_Contact = controller.getSAP_Contact();
        controller.SAP_Contact.Last_Name__c = 'Test Sap';
        controller.Address.Name='Test User';
        controller.Address.City__c='Temp';
        controller.Address.Country__c='Turkey';
        controller.Address.PostalCode__c='123456';
        controller.Address.Payment_Terms__c='15 days';
        controller.Address.Taxation_Status__c='Fully taxable';
        controller.Address.VAT_Registration_Number__c = '123';
        controller.Address.Address_Line_1__c = 'Abc';
        controller.Address.Tax_Number_1__c = '123456';
        PageReference pg = controller.SaveAddress();
        controller.Address.PO_Box__c = '123';
        pg = controller.SendNewRequestNotificationEmail();
        Test.stopTest();
    }
    
    /**
     * test method to check SendNewRequestNotificationEmail method
     */ 
    static testMethod void testSendNewRequestNotificationEmail1() {
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        Test.startTest();
        Opportunity TestOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        BNF2__c bnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        bnf.BNF_Status__c = 'New';
        bnf.IMS_Sales_Org__c = 'IMS Spain';
        bnf.Client__c = TestOpp.AccountId;
        insert bnf;
        Apexpages.currentPage().getParameters().put('AccountId',TestOpp.AccountId);        
        Apexpages.currentPage().getParameters().put('BnfId',bnf.Id);
        SAP_Address_MDM_Extension controller = new SAP_Address_MDM_Extension();
        controller.SAP_Contact = controller.getSAP_Contact();
        controller.SAP_Contact.Last_Name__c = 'Test Sap';
        controller.Address.Name='Test User';
        controller.Address.City__c='Temp';
        controller.Address.Country__c='Turkey';
        controller.Address.PostalCode__c='123456';
        controller.Address.Payment_Terms__c='15 days';
        controller.Address.Taxation_Status__c='Fully taxable';
        controller.Address.VAT_Registration_Number__c = '123';
        controller.Address.Address_Line_1__c = 'Abc';
        controller.Address.Tax_Number_1__c = '123456';
        controller.Address.PO_Box__c = '123';
        PageReference pg = controller.SaveAddress();
        pg = controller.SendNewRequestNotificationEmail();
        Test.stopTest();
    }
    
    /**
     * test method to check AddSAPContact method Validation
     */ 
    static testMethod void testAddSAPContactValidation() {
        Test.startTest();
        Opportunity TestOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        BNF2__c bnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        bnf.BNF_Status__c = 'New';
        bnf.IMS_Sales_Org__c = 'IMS Spain';
        bnf.Client__c = TestOpp.AccountId;
        insert bnf;
        Apexpages.currentPage().getParameters().put('AccountId',TestOpp.AccountId);        
        Apexpages.currentPage().getParameters().put('BnfId',bnf.Id);
        SAP_Address_MDM_Extension controller = new SAP_Address_MDM_Extension();
        controller.SAP_Contact = controller.getSAP_Contact();
        controller.SAP_Contact.Last_Name__c=null;
        PageReference pg = controller.AddSAPContact();
        ApexPages.Message msg = ApexPages.getMessages()[0];
        System.assertEquals('Last Name Required.', msg.getDetail());
        Test.stopTest();
    }
    
    /**
     * test method to check AddSAPContact method
     */ 
    static testMethod void testAddSAPContact() {
        Test.startTest();
        Opportunity TestOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        BNF2__c bnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        bnf.BNF_Status__c = 'New';
        bnf.IMS_Sales_Org__c = 'IMS Spain';
        bnf.Client__c = TestOpp.AccountId;
        insert bnf;
        Apexpages.currentPage().getParameters().put('AccountId',TestOpp.AccountId);        
        Apexpages.currentPage().getParameters().put('BnfId',bnf.Id);
        SAP_Address_MDM_Extension controller = new SAP_Address_MDM_Extension();
        controller.SAP_Contact = controller.getSAP_Contact();
        controller.SAP_Contact.Last_Name__c = 'Test Sap';
        PageReference pg = controller.AddSAPContact();
        Test.stopTest();
    }
    
    /**
     * test method to add SaveAddress method Validation
     */ 
    static testMethod void testSaveAddressValidation() {
        Test.startTest();
        Opportunity TestOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        BNF2__c bnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        bnf.BNF_Status__c = 'New';
        bnf.IMS_Sales_Org__c = 'IMS Spain';
        bnf.Client__c = TestOpp.AccountId;
        insert bnf;
        Apexpages.currentPage().getParameters().put('AccountId',TestOpp.AccountId);        
        SAP_Address_MDM_Extension controller = new SAP_Address_MDM_Extension();
        controller.Address.City__c='Temp';
        controller.Address.Country__c='Turkey';
        controller.Address.Payment_Terms__c='15 days';
        controller.Address.Taxation_Status__c='Fully taxable';
        controller.Address.Language__c='C';
        controller.Address.PostalCode__c = '123';
        controller.Address.International_Name__c ='Test User Test User Test User Test User Test User Test User Test User Test User Test User';
        controller.Address.Name='Test User Test User Test User Test User Test User Test User Test User Test User Test User';
        controller.Address.International_City__c = 'abc';
        PageReference pg = controller.SaveAddress();

        System.assertEquals('Address Line 1 is Mandatory when the PO Box is blank.', ApexPages.getMessages()[0].getDetail());
        System.assertEquals('Address Line 1 (Local) is Mandatory when the PO Box is blank and Language is selected.', ApexPages.getMessages()[1].getDetail());
        System.assertEquals('Customer Name must be less than 70 characters', ApexPages.getMessages()[2].getDetail());
        System.assertEquals('VAT Registration Number is mandatory for addresses in ' + controller.address.Country__c, ApexPages.getMessages()[3].getDetail());
        System.assertEquals('Address Line 1 is mandatory for addresses in ' + controller.address.Country__c, ApexPages.getMessages()[4].getDetail());
        System.assertEquals('Tax Number 1 is required when Country is Argentina, Bolivia, Brazil, Chile, Colombia, Ecuador, Guatemala, Mexico, Peru, Paraguay, Turkey, Uruguay, or Venezuela.', ApexPages.getMessages()[5].getDetail());
        System.assertEquals('Customer Name (Local) must be less than 70 characters', ApexPages.getMessages()[6].getDetail());
        
        Test.clearApexPageMessages();
        controller.Address.Country__c='Argentina';
        controller.Address.International_Name__c ='Test User Local';
        controller.Address.Name = 'Test Name';
        controller.Address.VAT_Registration_Number__c = '123';
        controller.Address.Address_Line_1__c = 'Abc';
        controller.Address.Tax_Number_1__c = '123';
        controller.Address.Address_Line_1_Local__c = '123';
        controller.SaveAddress();
        System.assertEquals('Tax Type is required when Country is Argentina.', ApexPages.getMessages()[0].getDetail());
        
         
        Test.stopTest();
    }
    
    /**
     * test method to check SaveAddress method
     */ 
    static testMethod void testSaveAddress() {
        Test.startTest();
        Opportunity TestOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        BNF2__c bnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        bnf.BNF_Status__c = 'New';
        bnf.IMS_Sales_Org__c = 'IMS Spain';
        bnf.Client__c = TestOpp.AccountId;
        insert bnf;
        Apexpages.currentPage().getParameters().put('AccountId',TestOpp.AccountId);        
        Apexpages.currentPage().getParameters().put('BnfId',bnf.Id);
        SAP_Address_MDM_Extension controller = new SAP_Address_MDM_Extension();
        controller.Address.Name='Test User';
        controller.address.City__c='Temp';
        controller.address.Country__c='Turkey';
        controller.address.PostalCode__c='123456';
        controller.Address.Payment_Terms__c='15 days';
        controller.Address.Taxation_Status__c='Fully taxable';
        controller.Address.VAT_Registration_Number__c = '123';
        controller.Address.Address_Line_1__c = 'Abc';
        controller.Address.Tax_Number_1__c = '123456';
        controller.Address.PO_Box__c = '123';
        PageReference pg = controller.SaveAddress();
        System.assertEquals(controller.RequestSubmitted,true);
        Test.stopTest();
    }
    
    /**
     * test method to check SendNewAddressRequestNotificationEmail method
     */ 
    static testMethod void testSendNewAddressRequestNotificationEmail() {
        Test.startTest();
        Opportunity TestOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        BNF2__c bnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        bnf.BNF_Status__c = 'New';
        bnf.IMS_Sales_Org__c = 'IMS Spain';
        bnf.Client__c = TestOpp.AccountId;
        insert bnf;
        Apexpages.currentPage().getParameters().put('AccountId',TestOpp.AccountId);        
        Apexpages.currentPage().getParameters().put('BnfId',bnf.Id);
        SAP_Address_MDM_Extension controller = new SAP_Address_MDM_Extension();
        controller.Address.Name='Test User';
        controller.address.City__c='Temp';
        controller.address.Country__c='Turkey';
        controller.address.PostalCode__c='123456';
        controller.Address.Payment_Terms__c='15 days';
        controller.Address.Taxation_Status__c='Fully taxable';
        controller.Address.VAT_Registration_Number__c = '123';
        controller.Address.Address_Line_1__c = 'Abc';
        controller.Address.Tax_Number_1__c = '123456';
        controller.Address.PO_Box__c = '123';
        PageReference pg = controller.SendNewAddressRequestNotificationEmail();
        Test.stopTest();
    }
    
    /**
     * test method to check SendNewAddressRequestNotificationEmail method
     */ 
    static testMethod void testSendNewAddressRequestNotificationEmail1() {
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        Test.startTest();
        Opportunity TestOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        BNF2__c bnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        bnf.BNF_Status__c = 'New';
        bnf.IMS_Sales_Org__c = 'IMS Spain';
        bnf.Client__c = TestOpp.AccountId;
        insert bnf;
        Apexpages.currentPage().getParameters().put('AccountId',TestOpp.AccountId);        
        Apexpages.currentPage().getParameters().put('BnfId',bnf.Id);
        SAP_Address_MDM_Extension controller = new SAP_Address_MDM_Extension();
        controller.Address.Name='Test User';
        controller.address.City__c='Temp';
        controller.address.Country__c='Turkey';
        controller.address.PostalCode__c='123456';
        controller.Address.Payment_Terms__c='15 days';
        controller.Address.Taxation_Status__c='Fully taxable';
        controller.Address.VAT_Registration_Number__c = '123';
        controller.Address.Address_Line_1__c = 'Abc';
        controller.Address.Tax_Number_1__c = '123456';
        controller.Address.PO_Box__c = '123';
        PageReference pg = controller.SendNewAddressRequestNotificationEmail();
        Test.stopTest();
    }
    
    /**
     * test method to check DoNothing method
     */ 
    static testMethod void testDoNothing() {
        Test.startTest();
        Opportunity TestOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        BNF2__c bnf = new BNF2__c(Opportunity__c=TestOpp.Id);
        bnf.BNF_Status__c = 'New';
        bnf.IMS_Sales_Org__c = 'IMS Spain';
        bnf.Client__c = TestOpp.AccountId;
        insert bnf;
        Apexpages.currentPage().getParameters().put('AccountId',TestOpp.AccountId);        
        Apexpages.currentPage().getParameters().put('BnfId',bnf.Id);
        SAP_Address_MDM_Extension controller = new SAP_Address_MDM_Extension();
        controller.DoNothing();
        System.assertEquals('YYYXXXXX',controller.Debug);
        Test.stopTest();
    }
}