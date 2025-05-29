@isTest
public class TST_SLT_Agency_Program_Financials {
    @testSetup
    static void dataSetup()
    {
        Account ac = new Account(name ='Acme',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE') ;
        ac.AccountCountry__c = 'US' ;
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
        Agency_Program__c agencyprogMark = TST_PEP_TestDataFactory.createAgencyProgram(prodmarketing);
        agencyprogramList.add(agencyprog);
        agencyprogramList.add(agencyprogMark);
        insert agencyprogramList;
        
        Contract ctr = TST_PEP_TestDataFactory.createContract('Ctr000125', ac.Id, prod.Id);
        Contract ctrMark = TST_PEP_TestDataFactory.createContract('Ctr000126', ac.Id, prodmarketing.Id);
        ctr.Parent_Contract_Number__c = 123;
        ctr.Ultimate_Parent_Contract_Number__c = 345;
        ctr.Notification_Counter__c=2;
        ctr.Agency_Program__c=agencyprog.Id;
        ctrMark.Parent_Contract_Number__c = 123;
        ctrMark.Ultimate_Parent_Contract_Number__c = 345;
        contractList.add(ctr);
        contractList.add(ctrMark);
        insert contractList;
        
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
    
    @isTest
    static void testGetAgencyProgramFinancialsDetails()
    {
        List<Account> acc=[SELECT AccountCountry__c FROM Account LIMIT 1];
        Agency_Program__c agencyprog = [SELECT Id, Name, Product__c FROM Agency_Program__c WHERE Name = 'OCE Sales'];
        Set<Id> apId=new Set<Id>{agencyprog.Id};
        Id recordId = Schema.SObjectType.Agency_Program_Financials__c.getRecordTypeInfosByDeveloperName().get('Price').getRecordTypeId();
        Test.startTest();
        List<Agency_Program_Financials__c> agencyProgramFinancials=new SLT_Agency_Program_Financials().getAgencyProgramFinancialsDetails(recordId,agencyprog.Id,acc[0].AccountCountry__c);
        Test.stopTest();
        System.assertNotEquals(null, agencyProgramFinancials.size());
    }
    
    @isTest
    static void testGetAgencyProgramFinancialsDetailsDefault()
    {
        List<Account> acc=[SELECT AccountCountry__c FROM Account LIMIT 1];
        Agency_Program__c agencyprog = [SELECT Id, Name, Product__c FROM Agency_Program__c WHERE Name = 'OCE Sales'];
        Set<Id> apId=new Set<Id>{agencyprog.Id};
        Id recordId = Schema.SObjectType.Agency_Program_Financials__c.getRecordTypeInfosByDeveloperName().get('Price').getRecordTypeId();
        Test.startTest();
        List<Agency_Program_Financials__c> agencyProgramFinancials=new SLT_Agency_Program_Financials().getAgencyProgramFinancialsDetailsDefault(recordId,agencyprog.Id);
        Test.stopTest();
        System.assertNotEquals(null, agencyProgramFinancials.size());
    }
    
    @isTest
    static void testGetAgencyProgramFinancialsAddress()
    {
        List<Account> acc=[SELECT AccountCountry__c FROM Account LIMIT 1];
        Agency_Program__c agencyprog = [SELECT Id, Name, Product__c FROM Agency_Program__c WHERE Name = 'OCE Sales'];
        Set<Id> apId=new Set<Id>{agencyprog.Id};
        Id recordId = Schema.SObjectType.Agency_Program_Financials__c.getRecordTypeInfosByDeveloperName().get('Address').getRecordTypeId();
        Test.startTest();
        List<Agency_Program_Financials__c> agencyProgramFinancials=new SLT_Agency_Program_Financials().getAgencyProgramFinancialsAddress(recordId,acc[0].AccountCountry__c);
        Test.stopTest();
        System.assertNotEquals(null, agencyProgramFinancials.size());
    }
    
    @isTest
    static void testGetAgencyProgramFinancialsAddressDefault()
    {
        List<Account> acc=[SELECT AccountCountry__c FROM Account LIMIT 1];
        Agency_Program__c agencyprog = [SELECT Id, Name, Product__c FROM Agency_Program__c WHERE Name = 'OCE Sales'];
        Set<Id> apId=new Set<Id>{agencyprog.Id};
        Id recordId = Schema.SObjectType.Agency_Program_Financials__c.getRecordTypeInfosByDeveloperName().get('Address').getRecordTypeId();
        Test.startTest();
        List<Agency_Program_Financials__c> agencyProgramFinancials=new SLT_Agency_Program_Financials().getAgencyProgramFinancialsAddressDefault(recordId);
        Test.stopTest();
        System.assertNotEquals(null, agencyProgramFinancials.size());
    }
    
}