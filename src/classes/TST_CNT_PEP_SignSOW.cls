/*
* Version       : 1.0
* Description   : Test class for CNT_PEP_SignSOW
*/
@isTest
public class TST_CNT_PEP_SignSOW {
    
/**
* This method is used to setup data for all methods.
*/
    @testSetup
    static void dataSetup() {
        User partnerUser = TST_PEP_TestDataFactory.createPartnerUser('partneruser@iqvia.partner.com'); 
        User adminUser = TST_PEP_TestDataFactory.createAdminUser('admin','adminPartner@iqvia.com');

        List<User> lstUsers = new List<User>{partnerUser, adminUser}; 
        insert lstUsers;
        System.runAs(partnerUser){
        Account ac = new Account(name ='Acme1', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE') ;
        ac.AccountCountry__c = 'BM' ;
        insert ac; 
        
        List<Product2> prodList = new List<Product2>();
        List<Agency_Program__c> agencyprogramList = new List<Agency_Program__c>();
        List<Contract> contractList = new List<Contract>();
        
        Product2 prod = TST_PEP_TestDataFactory.createProduct('Oce Sales');
        Product2 prodmarketing = TST_PEP_TestDataFactory.createProduct('Oce Marketing');
        prodList.add(prod);
        prodList.add(prodmarketing);
        Insert prodList;
        
        Agency_Program__c agencyprog = TST_PEP_TestDataFactory.createAgencyProgram(prod);
        agencyprog.Duration_in_month__c=6;
        Agency_Program__c agencyprogMark = TST_PEP_TestDataFactory.createAgencyProgram(prodmarketing);
        agencyprogramList.add(agencyprog);
        agencyprogramList.add(agencyprogMark);
        insert agencyprogramList;

        Contract ctr = TST_PEP_TestDataFactory.createContract('Ctr000125', ac.Id, prod.Id);
        Contract ctrMark = TST_PEP_TestDataFactory.createContract('Ctr000126', ac.Id, prodmarketing.Id);
        ctr.Parent_Contract_Number__c = 123;
        ctr.Ultimate_Parent_Contract_Number__c = 345;
        ctr.Agency_Program__c=agencyprog.Id;
        ctr.EndDate=Date.today();
        ctr.Renewal_Status__c='Renewed';
        ctrMark.Parent_Contract_Number__c = 123;
        ctrMark.Ultimate_Parent_Contract_Number__c = 345;
        ctrMark.Renewal_Status__c='Renewed';
        contractList.add(ctr);
        contractList.add(ctrMark);
        insert contractList;
            
        PEP_DocuSign_credentials__c docuSignCredentials = new PEP_DocuSign_credentials__c();
        docuSignCredentials.PSO_Team_Mailbox__c = 'xyz@abcz.com';
        docuSignCredentials.PSO_TeamLead_Email__c = 'xyz@abcz.com';
        insert docuSignCredentials;
            
        Id agencyProgramFinancialsPrice = Schema.SObjectType.Agency_Program_Financials__c.getRecordTypeInfosByDeveloperName().get('Price').getRecordTypeId();
        Agency_Program_Financials__c apf=new Agency_Program_Financials__c();
        apf.RecordTypeId=agencyProgramFinancialsPrice;
        apf.Program_Name__c=agencyprog.Id;
        apf.Country__c='US';
        apf.CurrencyIsoCode='USD';
        apf.Default__c=true;
        apf.Product__c=prod.Id;
        apf.Price__c=100;
        insert apf;  
            
        Agency_Program_Financials__c apf2=new Agency_Program_Financials__c();
        apf2.RecordTypeId=agencyProgramFinancialsPrice;
        apf2.Program_Name__c=agencyprog.Id;
        apf2.Country__c='US';
        apf2.CurrencyIsoCode='USD';
        apf2.Default__c=false;
        apf2.Product__c=prod.Id;
        apf2.Price__c=100;
        insert apf2; 
            
        }
    }
    
    @isTest
    public static void testgetContractId(){
        Agency_Program__c agencyprog = [SELECT Id, Name, Product__c FROM Agency_Program__c WHERE Name = 'OCE Sales'];
        Agency_Program__c agencyprogMark = [SELECT Id, Name, Product__c FROM Agency_Program__c WHERE Name = 'OCE Marketing'];
		Contract ctr = [SELECT Id, Product__c, Name FROM Contract WHERE Name = 'Ctr000125'];
		Contract ctr2 = [SELECT Id, Product__c, Name FROM Contract WHERE Name = 'Ctr000126'];
        
        Contract_Template__c ct = TST_PEP_TestDataFactory.createContractTemplate(agencyprog);
        Contract_Template__c ct1 = TST_PEP_TestDataFactory.createContractTemplate(agencyprog);
        Contract_Template__c ct2 = TST_PEP_TestDataFactory.createContractTemplate(agencyprogMark);
        
        Test.startTest();
        	String returnURL1 = CNT_PEP_SignSOW.getContractId(ctr.Id,'True');
        	String returnURL2 = CNT_PEP_SignSOW.getContractId(ctr2.Id,'False');
        Test.stopTest();
        
        system.assertNotEquals(null, returnURL1);
        system.assertNotEquals(null, returnURL2);
    }
    @isTest
    public static void testGetRelatedContractId()
    { 
        Agency_Program__c agencyprog = [SELECT Id, Name, Product__c FROM Agency_Program__c WHERE Name = 'OCE Sales'];
        Agency_Program__c agencyprogMark = [SELECT Id, Name, Product__c FROM Agency_Program__c WHERE Name = 'OCE Marketing'];
        Contract ctr = [SELECT Id, Product__c, Name FROM Contract WHERE Name = 'Ctr000125'];
        Contract ctr2 = [SELECT Id, Product__c, Name FROM Contract WHERE Name = 'Ctr000126'];
        
        Test.startTest();
            String returnValue = CNT_PEP_SignSOW.getrelatedContractId(ctr.Id);
        Test.stopTest();
        System.assertNotEquals(null, returnValue);
        
        
    }
    
    @isTest
    public static void testRenewContractController()
    { 
        User partnerUser = [SELECT id FROM User WHERE email='partneruser@iqvia.partner.com'];
        Agency_Program__c agencyprog = [SELECT Id, Name, Product__c FROM Agency_Program__c WHERE Name = 'OCE Sales'];
        Contract ctr = [SELECT Id, Product__c, Name,Agency_Program__c FROM Contract WHERE Name = 'Ctr000125'];

        System.runAs(partnerUser){
            Test.startTest();
                String returnValue = CNT_PEP_SignSOW.renewContractController(ctr.Id);
            Test.stopTest();
            
        System.assertNotEquals(null, returnValue);
        }
    }
    
    @isTest
    public static void testRenewNonStandardContractController()
    { 
        User partnerUser = [SELECT id FROM User WHERE email='partneruser@iqvia.partner.com'];
        Agency_Program__c agencyprog = [SELECT Id, Name, Product__c FROM Agency_Program__c WHERE Name = 'OCE Sales'];
        Contract ctr = [SELECT Id, Product__c, Name,Agency_Program__c FROM Contract WHERE Name = 'Ctr000125'];
        System.runAs(partnerUser){
        Test.startTest();
        String returnValue=CNT_PEP_SignSOW.renewNonStandardContractController(ctr.Id);
        Test.stopTest();
        System.assertNotEquals(null, returnValue);
        }
        
    }
    @isTest
    public static void testGetChildContract()
    { 
        Agency_Program__c agencyprog = [SELECT Id, Name, Product__c FROM Agency_Program__c WHERE Name = 'OCE Sales'];
        Agency_Program__c agencyprogMark = [SELECT Id, Name, Product__c FROM Agency_Program__c WHERE Name = 'OCE Marketing'];
        Contract ctr = [SELECT Id, Product__c, Name FROM Contract WHERE Name = 'Ctr000125'];
        Contract ctr2 = [SELECT Id, Product__c, Name FROM Contract WHERE Name = 'Ctr000126'];
        
        Test.startTest();
        String returnValue = CNT_PEP_SignSOW.getChildContract(ctr.Id);
        Test.stopTest();
        system.assertNotEquals(null, returnValue);
        
        
    }
}