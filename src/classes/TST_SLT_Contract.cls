/*
* Version       : 1.0
* Description   : Test Class for SLT_Contract
*/
@isTest
private class TST_SLT_Contract {

    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount(); 
        insert acc; 
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        RecordType recordType = [SELECT Id, Name, DeveloperName From RecordType WHERE Id = :CON_CRM.CONTRACT_RECORD_TYPE_CNF_GBO LIMIT 1];
        IQVIA_Legal_Entity__c iqviaLegalEntity = new IQVIA_Legal_Entity__c(Name='Test');
        insert iqviaLegalEntity;
        Contract cntrt = UTL_TestData.createContract(opp, recordType.DeveloperName);
        cntrt.Name = 'Test Contract1';
        cntrt.Project_Number__c = '12';
        cntrt.Parent_Contract_Number__c = 1234;
        cntrt.Ultimate_Parent_Contract_Number__c = 5678;
        cntrt.Legal_Entity_IQVIA__c = iqviaLegalEntity.Id;
        cntrt.Legal_Entity_Customer__c = 'test';
        insert cntrt;
        recordType = [SELECT Id, Name, DeveloperName From RecordType WHERE Id = :CON_CRM.CONTRACT_RECORD_TYPE_CNF_GBO LIMIT 1];
        Contract cntrt2 = UTL_TestData.createContract(opp, recordType.DeveloperName);
        cntrt2.Parent_Contract__c = cntrt.Id;
        cntrt2.Name = 'Test Contract2';
        cntrt2.Project_Number__c = '1234';
        cntrt2.Change_Order_Number__c = '12';
        cntrt2.Legal_Entity_IQVIA__c = iqviaLegalEntity.Id;
        cntrt2.Legal_Entity_Customer__c = 'test';
        cntrt2.Parent_Contract_Number__c = 1234;
        cntrt2.Ultimate_Parent_Contract_Number__c = 5678;
        insert cntrt2;
		
        Account ac = new Account(name ='Acme',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE') ;
        ac.AccountCountry__c = 'BM' ;
        insert ac; 
        
        List<Product2> prodList = new List<Product2>();
        List<Agency_Program__c> agencyprogramList = new List<Agency_Program__c>();
        List<Contract> contractList = new List<Contract>();
        
        Product2 prod = TST_PEP_TestDataFactory.createProduct('Oce Sales');
        Product2 prodmarketing = TST_PEP_TestDataFactory.createProduct('Oce Marketing');
        prod.Pillar__c = CON_CPQ.R_AND_D;
        prodmarketing.Pillar__c = CON_CPQ.R_AND_D;
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
        ctr.PRM_Parent_Contract_Number__c='00001234';
        ctr.New_Contract_Number__c='00001235';
        ctrMark.Parent_Contract_Number__c = 123;
        ctrMark.Ultimate_Parent_Contract_Number__c = 345;
        contractList.add(ctr);
        contractList.add(ctrMark);
        insert contractList;
    }
    
    @isTest
    static void testSelectByContractId() {
        Set<Id> contractIdSet = new Set<Id>();
        Set<String> fieldSet = new Set<String>{'Name', 'Id'};
        Contract contract = [SELECT Id FROM Contract WHERE Name = 'Test Contract2' LIMIT 1];
        contractIdSet.add(contract.Id);
        Test.startTest();
        Map<Id, Contract> contractMap = new SLT_Contract().selectByContractId(contractIdSet, fieldSet);
        Test.stopTest();
        System.assertEquals('Test Contract2', contractMap.get(contract.Id).Name);
    }
    
    @isTest
    static void testSelectByContractIdList() {
        Set<Id> contractIdSet = new Set<Id>();
        Set<String> fieldSet = new Set<String>{'Name', 'Id'};
        List<Contract> contractList = [SELECT Id FROM Contract];
        contractIdSet.add(contractList[0].Id);
        contractIdSet.add(contractList[1].Id);
        Test.startTest();
        contractList = new SLT_Contract().selectByContractIdList(contractIdSet, fieldSet);
        Test.stopTest();
        System.assertEquals(2, contractList.size());
    }    
    
    @isTest
    static void testSelectCNFContractsByProjAndChangeOrderNumber() {
        Set<String> projNumSet = new Set<String>{'1234'};
        Set<String> chanOrdSet = new Set<String>{'12'};
        Set<String> fieldSet = new Set<String>{'Name', 'Id'};
        Contract cntrt = [SELECT Id, Project_Number__c FROM Contract WHERE Name = 'Test Contract2' LIMIT 1];
        Test.startTest();
        Map<Id, Contract> contractMap = new SLT_Contract().selectCNFContractsByProjAndChangeOrderNumber(projNumSet, chanOrdSet, fieldSet);
        Test.stopTest();
        //System.assertEquals(cntrt.Id, contractMap.get(cntrt.Id).Id);
    }
    
    @isTest
    static void testFetchParentContract() {
        Set<Id> contractIdSet = new Set<Id>();
        Set<String> fieldSet = new Set<String>{'Name', 'Id'};
        Contract contract = [SELECT Id, Parent_Contract__c FROM Contract WHERE Name = 'Test Contract2' LIMIT 1];        
        contractIdSet.add(contract.Parent_Contract__c);
        contract = [SELECT Id FROM Contract WHERE Name = 'Test Contract1' LIMIT 1];
        Test.startTest();
        Map<Id, Contract> contractMap = new SLT_Contract().fetchParentContract(contractIdSet, fieldSet);
        Test.stopTest();
        System.assertEquals(contract.Id, contractMap.get(contract.Id).Id);
    }
    
    @isTest
    static void testFetchContract() {
        Set<Id> contractIdSet = new Set<Id>();
        Set<String> fieldSet = new Set<String>{'Name', 'Id'};
        List<Contract> contractList = [SELECT Id FROM Contract];
        contractIdSet.add(contractList[0].Id);
        contractIdSet.add(contractList[1].Id);
        Test.startTest();
        contractList = new SLT_Contract().fetchContract(contractIdSet, fieldSet);
        Test.stopTest();
        System.assertEquals(2, contractList.size());
    }
    
    @isTest
    static void testGetContractUsingContractNumber() {
        Set<String> fieldSet = new Set<String>{'Name', 'Id'};
        Contract contract = [SELECT Id, ContractNumber FROM Contract WHERE Name = 'Test Contract2' LIMIT 1];
        Test.startTest();
        List<Contract> contractList = new SLT_Contract().getContractUsingContractNumber(contract.ContractNumber, fieldSet);
        Test.stopTest(); 
        System.assertEquals(contract.Id, contractList[0].Id);
    }

    @isTest
    static void testSelectExistingContract() {
        Agency_Program__c agencyprog = [SELECT Id, Name, Product__c FROM Agency_Program__c WHERE Name = 'OCE Sales'];
        Agency_Program__c agencyprogMark = [SELECT Id, Name, Product__c FROM Agency_Program__c WHERE Name = 'OCE Marketing'];
        Contract ctr = [SELECT Id, Product__c, Name FROM Contract WHERE Name = 'Ctr000125'];
        Contract ctr2 = [SELECT Id, Product__c, Name FROM Contract WHERE Name = 'Ctr000126'];
        Test.startTest();
        	List<Contract> contractList = new SLT_Contract().selectExistingContract(agencyprog.Id);
        Test.stopTest(); 
        System.assertNotEquals(null, contractList);
    }
    
    @isTest
    static void testSelectContractToRenew() {
        Contract ctr = [SELECT Id, Product__c, Name FROM Contract WHERE Name = 'Ctr000125'];
        Test.startTest();
            Contract renewContract = new SLT_Contract().selectContractToRenew(ctr.Id);
        Test.stopTest(); 
        System.assertEquals(ctr.Id, renewContract.Id);
    }
    
    @isTest
    static void testSelectNewContractById() {
        Contract ctr = [SELECT Id, Product__c, Name FROM Contract WHERE Name = 'Ctr000125'];
        Test.startTest();
            Contract newContract = new SLT_Contract().selectNewContractById(ctr.Id);
        Test.stopTest(); 
        System.assertEquals(ctr.Id, newContract.Id);
    }
    
    @isTest
    static void testSelectChildContract() {
        Contract ctr = [SELECT Id, Product__c, Name,PRM_Parent_Contract_Number__c FROM Contract WHERE Name = 'Ctr000125'];
        Test.startTest();
        List<Contract> newContract = new SLT_Contract().selectChildContract(ctr.PRM_Parent_Contract_Number__c);
        Test.stopTest(); 
        System.assertEquals(ctr.Id, newContract[0].Id);
    }
    
    @isTest
    static void testSelectParentContract() {
        Contract ctr = [SELECT Id, Product__c, Name,New_Contract_Number__c FROM Contract WHERE Name = 'Ctr000125'];
        Test.startTest();
        List<Contract> newContract = new SLT_Contract().selectParentContract(ctr.New_Contract_Number__c);
        Test.stopTest(); 
        System.assertEquals(ctr.Id, newContract[0].Id);
    }
    
    @isTest
    static void testGetContractByContractNumberCondition() {
        Contract ctr = [SELECT Id, ContractNumber, Name FROM Contract WHERE Name = 'Ctr000125'];
        String condition = 'SELECT ID FROM Contract WHERE ContractNumber = \''+ctr.ContractNumber+'\'';

        Test.startTest();
            List<Contract> contracts = new SLT_Contract().getContractByContractNumberCondition(condition);
        Test.stopTest(); 
        System.assertEquals(ctr.Id, contracts.get(0).Id);
    }

    @isTest
    Static void testGetContractListByCondition() {
        Set<Id> contractIds = new Set<Id>();
        Set<String> fields = new Set<String>{'Name', 'Id'};
        String condition = 'Id IN : contractIds';
        Contract contract = [Select Id From Contract Where Name = 'Ctr000125'];
        contractIds.add(contract.Id);
        Test.startTest();
            List<Contract> contractList = new SLT_Contract().getContractListByCondition(fields, condition, contractIds);
        Test.stopTest();
        System.assertEquals(1, contractList.size(), 'Contract not fetched');
    }
    
}