@isTest
private class TST_DAOH_Contract {
    
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() { 
        

        Account acc = UTL_TestData.createAccount();
        insert acc;
        Stage_Gate_Status_Values__c statusvalue = new Stage_Gate_Status_Values__c();
        statusvalue.Name = 'AnalystPP';
        statusvalue.Status__c = 'Analyst Preparing Customer Budget Deliverable';
        upsert statusvalue;
        IQVIA_Legal_Entity__c iqviaLegalEntity = UTL_TestData.createIQVIALegalEntity();
        insert iqviaLegalEntity;
        Contract cntrt = new Contract();
        cntrt.AccountId = acc.Id;
        cntrt.Status = 'Draft';
        cntrt.CurrencyIsoCode = 'INR';
        cntrt.Status = 'Analyst Preparing Customer Budget Deliverable';
        cntrt.StartDate = System.today();
        cntrt.ContractTerm = 12;
        cntrt.Parent_Contract_Number__c = 1234;
        cntrt.Ultimate_Parent_Contract_Number__c = 5678;
        cntrt.Legal_Entity_IQVIA__c = iqviaLegalEntity.Id;
        cntrt.Legal_Entity_Customer__c = 'Test';
        insert cntrt;
        Opportunity testOpp = UTL_TestData.createOpportunity(acc.id);
        insert testOpp;
        Contract parentContract = UTL_TestData.createContract(testOpp, 'CNF_GBO');
        parentContract.Name = 'testParent';
        parentContract.Parent_Contract_Number__c = 1234;
        parentContract.Ultimate_Parent_Contract_Number__c = 5678;
        parentContract.Legal_Entity_IQVIA__c = iqviaLegalEntity.Id;
        parentContract.Legal_Entity_Customer__c = 'Test';
        insert parentContract;
    }
    
    /**
    * This method used to get User Metric By Id
    */    
    @IsTest
    static void testCreateContractLifeCycleRecord() {
        Test.startTest();
        Contract ctnrt = [Select Id from Contract LIMIT 1];
        update ctnrt;
        delete ctnrt;
        Test.stopTest();
    }
    
    /**
    * This method used to test COVID-19 Update Status
    */    
    @IsTest
    static void testUpdateStatusField() {
        Test.startTest();
        Contract ctnrt = [Select Id, RecordTypeId from Contract LIMIT 1];
        ctnrt.Update_Contract_Status__c = 'On Hold due to COVID-19';
        ctnrt.RecordTypeId = CON_CRM.CONTRACT_RECORD_TYPE_CNF_GBO;
        update ctnrt;
        ctnrt.Update_Contract_Status__c = 'Cancelled due to COVID-19';
        update ctnrt;
        Test.stopTest();
    }
    
    /**
    * This method used to set ContractFields   (there are 3 methods test SetContractFields)
    */ 
    @IsTest
    static void testSetContractFields1() {
        Test.startTest();
        List<Id> recordTypesIds = new List<Id>{CON_CRM.CONTRACT_RECORD_TYPE_CNF_GBO,CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER_GBO,CON_CRM.CONTRACT_RECORD_TYPE_GENERAL_CLIENT_AGREEMENT_GBO,CON_CRM.CONTRACT_RECORD_TYPE_PRELIMINARY_AGREEMENT_GBO};
        List<Contract> ctnrtList = [Select Id,Status,Update_Contract_Status__c,Unsigned_Status__c from Contract LIMIT 1];
        List<RecordType> recordTypList = [SELECT Id FROM RecordType where SobjectType = 'Contract' AND Id IN : recordTypesIds];
        if(recordTypList.size() > 0){
            ctnrtList[0].RecordTypeId = recordTypList[0].Id;
            ctnrtList[0].Unsigned_Status__c = CON_CRM.CONTRACT_STATUS_EXECUTED;
            update ctnrtList;
        }
        Test.stopTest();
        System.assertEquals(CON_CRM.CONTRACT_STATUS_EXECUTED,ctnrtList[0].Unsigned_Status__c);
    }
    
    /**
    * This method used to test set contract field method. 
    */ 
    @IsTest
    static void testSetContractFields2() {
        Test.startTest();
        List<Id> recordTypesIds = new List<Id>{CON_CRM.CONTRACT_RECORD_TYPE_CNF_GBO,CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER_GBO,CON_CRM.CONTRACT_RECORD_TYPE_GENERAL_CLIENT_AGREEMENT_GBO,CON_CRM.CONTRACT_RECORD_TYPE_PRELIMINARY_AGREEMENT_GBO};
        List<Contract> ctnrtList = [Select Id,Status,Update_Contract_Status__c,Unsigned_Status__c from Contract LIMIT 1];
        List<RecordType> recordTypList = [SELECT Id FROM RecordType where SobjectType = 'Contract' AND Id IN : recordTypesIds];
        if(recordTypList.size() > 0){
            ctnrtList[0].RecordTypeId = recordTypList[0].Id;
            ctnrtList[0].Update_Contract_Status__c = CON_CRM.CONTRACT_STATUS_NEGOTIATION_TERMINATED;
            update ctnrtList;
            Test.stopTest();
        }
        System.assertEquals(CON_CRM.CONTRACT_STATUS_NEGOTIATION_TERMINATED,ctnrtList[0].Update_Contract_Status__c);
    }
    
    /**
    * This method used to test set contract field method. 
    */ 
    @IsTest
    static void testSetContractFields3() {
        Test.startTest();
        List<Id> recordTypesIds = new List<Id>{CON_CRM.CONTRACT_RECORD_TYPE_CNF_GBO,CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER_GBO,CON_CRM.CONTRACT_RECORD_TYPE_GENERAL_CLIENT_AGREEMENT_GBO,CON_CRM.CONTRACT_RECORD_TYPE_PRELIMINARY_AGREEMENT_GBO};
        List<Contract> ctnrtList = [Select Id,Status,Update_Contract_Status__c,Unsigned_Status__c from Contract LIMIT 1];
        List<RecordType> recordTypList = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Contract' AND Id IN : recordTypesIds];
        if(recordTypList.size() > 0){
            ctnrtList[0].RecordTypeId = recordTypList[0].Id;
            ctnrtList[0].Update_Contract_Status__c = CON_CRM.CONTRACT_STATUS_NEGOTIATION_TERMINATED;
            update ctnrtList;
        } 
        Test.stopTest();
        System.assertEquals(CON_CRM.CONTRACT_STATUS_NEGOTIATION_TERMINATED,ctnrtList[0].Update_Contract_Status__c);
    }
    
    /**
    * This method used to test set contract field method. 
    */ 
    @IsTest
    static void testSetContractFields4() {
        Test.startTest();
        List<Id> recordTypesIds = new List<Id>{CON_CRM.CONTRACT_RECORD_TYPE_CNF_GBO,CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER_GBO,CON_CRM.CONTRACT_RECORD_TYPE_GENERAL_CLIENT_AGREEMENT_GBO,CON_CRM.CONTRACT_RECORD_TYPE_PRELIMINARY_AGREEMENT_GBO};
        List<Contract> ctnrtList = [Select Id,Status,Update_Contract_Status__c,Unsigned_Status__c from Contract LIMIT 1];
        List<RecordType> recordTypList = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Contract' AND Id IN : recordTypesIds];
        if(recordTypList.size() > 0){
            ctnrtList[0].RecordTypeId = recordTypList[0].Id; 
            ctnrtList[0].Is_this_Contract_a_Ballpark__c = CON_CRM.CONTRACT_IS_A_BALLPARK_NO;
            ctnrtList[0].Confidence_in_Approval_of_Budget_Draft__c = CON_CRM.CONTRACT_CONFIDENCE_IN_APPROVAL_OF_BUDGET_DRAFT;
            ctnrtList[0].Actual_Contract_Value__c = CON_CRM.CONTRACT_ACTUAL_CONTRACT_VALUE;
            ctnrtList[0].Status = CON_CRM.CONTRACT_STATUS_CONTRACT_AT_CUSTOMER_FOR_REVIEW;
            ctnrtList[0].Project_Expenses__c = CON_CRM.CONTRACT_ACTUAL_CONTRACT_VALUE;
            update ctnrtList;
        } 
        Test.stopTest();
        System.assertEquals(CON_CRM.CONTRACT_ACTUAL_CONTRACT_VALUE, [Select Id,Status,Update_Contract_Status__c,Unsigned_Status__c,Initial_Draft_at_High_Confidence_Value__c from Contract where id= : ctnrtList[0].id].get(0).Initial_Draft_at_High_Confidence_Value__c);
    }
    
    /**
    * This method used to test set contract field method. 
    */ 
   @IsTest
    static void testSetParentContractFieldsOnCNF() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        IQVIA_Legal_Entity__c iqviaLegalEntity = [SELECT Id FROM IQVIA_Legal_Entity__c LIMIT 1];
        Contract ctnrt = [Select Id, RecordTypeId from Contract LIMIT 1];
        Contract testCNFGBOContract = new Contract();
        testCNFGBOContract.RecordTypeId = CON_CRM.CONTRACT_RECORD_TYPE_CNF_GBO;
        testCNFGBOContract.Project_Number__c = 'Test Project Number';
        testCNFGBOContract.Change_Order_Number__c = '12';
        testCNFGBOContract.Status = 'Analyst Preparing Customer Budget Deliverable';
        testCNFGBOContract.AccountId = acc.Id;
        testCNFGBOContract.Parent_Contract_Number__c = 1234;
        testCNFGBOContract.Parent_Contract__c = ctnrt.Id;
        testCNFGBOContract.Ultimate_Parent_Contract_Number__c = 5678;
        testCNFGBOContract.Legal_Entity_IQVIA__c = iqviaLegalEntity.Id;
        testCNFGBOContract.Legal_Entity_Customer__c = 'Test';
        insert testCNFGBOContract;
        
        Contract changeOrderContract = new Contract();
        changeOrderContract.RecordTypeId = CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER_GBO;
        changeOrderContract.Project_Number__c = 'Test Project Number';
        changeOrderContract.Change_Order_Number__c = '12';
        changeOrderContract.Status = 'Analyst Preparing Customer Budget Deliverable';
        changeOrderContract.AccountId = acc.Id;
        changeOrderContract.Parent_Contract_Number__c = 1234;
        changeOrderContract.Ultimate_Parent_Contract_Number__c = 5678;
        changeOrderContract.Legal_Entity_IQVIA__c = iqviaLegalEntity.Id;
        changeOrderContract.Legal_Entity_Customer__c = 'Test';
        Test.startTest();
            insert changeOrderContract;
        Test.stopTest();
    }
    
    /**
    * This method used to test parent contract.
    */ 
   /*
   @IsTest
    static void testParentContract() {
        Account acc = [select id from Account where Name = 'TestAccount'];
        Opportunity testOpp = [select id from Opportunity where accountId = :acc.id];
        Id devRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('CNF - GBO').getRecordTypeId();
        Contract parentContract = [select id from Contract where recordTypeId =: devRecordTypeId ][0];
        Contract cntrt = [select id from Contract where AccountId = :acc.Id and Parent_Contract__c = null][0];
        cntrt.Parent_Contract__c = parentContract.id;
        Test.startTest();
        update cntrt;
        Test.stopTest();     
    }
	*/
    
    /*
     * This test method set the contract values when we update it.
     */ 
    @isTest
    static void testUpdateContractValues1(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        IQVIA_Legal_Entity__c iqviaLegalEntity = [SELECT Id FROM IQVIA_Legal_Entity__c LIMIT 1];
        
        Contract changeOrderContract = new Contract();
        changeOrderContract.RecordTypeId = CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER;
        changeOrderContract.Project_Number__c = 'Test Project Number';
        changeOrderContract.Change_Order_Number__c = '12';
        changeOrderContract.Status = 'Analyst Preparing Customer Budget Deliverable';
        changeOrderContract.AccountId = acc.Id;
        changeOrderContract.Parent_Contract_Number__c = 1234;
        changeOrderContract.Ultimate_Parent_Contract_Number__c = 5678;
        changeOrderContract.Legal_Entity_IQVIA__c = iqviaLegalEntity.Id;
        changeOrderContract.Legal_Entity_Customer__c = 'Test';
        changeOrderContract.Confidence_in_Approval_of_Budget_Draft__c = 'High';
        insert changeOrderContract;
         List<Contract> contractInsert = [Select Id, Initial_Draft_at_High_Confidence_Expense__c from Contract Where Project_Number__c = 'Test Project Number' LIMIT 1 ];
        
        Test.startTest();
            contractInsert[0].Confidence_in_Approval_of_Budget_Draft__c = 'Low';
            contractInsert[0].Initial_Draft_at_High_Confidence_Date__c = System.today();
            contractInsert[0].Initial_Draft_at_High_Confidence_Expense__c = 322;
            contractInsert[0].Initial_Draft_at_High_Confidence_Value__c = 434;
            Update contractInsert;
        Test.stopTest();
        
        List<Contract> contract = [Select Id, Initial_Draft_at_High_Confidence_Expense__c from Contract Where Project_Number__c = 'Test Project Number' LIMIT 1 ];
        System.assertEquals(NULL, contract[0].Initial_Draft_at_High_Confidence_Expense__c);
    }
    
    /**
    * This method used to test parent contract.
    */ 
   
   @IsTest
    static void testSetContractFieldsFromParentContractFields() {
        Account acc = [select id from Account where Name = 'TestAccount'];
        Opportunity testOpp = [select id, accountId, CloseDate from Opportunity where accountId = :acc.id];
        Contract parentContract = [select id, Parent_Contract_Number__c, Ultimate_Parent_Contract_Number__c, Legal_Entity_IQVIA__r.id, Legal_Entity_Customer__c from Contract where Name = 'testParent'][0];
        Contract cntrt = UTL_TestData.createContract(testOpp, 'Change_Order'); 
        cntrt.Parent_Contract__c = parentContract.id;
        Test.startTest();
        insert cntrt;
        cntrt = [select id, Parent_Contract_Number__c, Ultimate_Parent_Contract_Number__c, Legal_Entity_IQVIA__r.id, Legal_Entity_Customer__c from Contract where Parent_contract__c != null and recordTypeId =: CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER][0];
        system.assertequals(parentContract.Ultimate_Parent_Contract_Number__c,cntrt.Ultimate_Parent_Contract_Number__c);
        system.assertequals(parentContract.Legal_Entity_IQVIA__r.id,cntrt.Legal_Entity_IQVIA__r.id);
        system.assertequals(parentContract.Legal_Entity_Customer__c,cntrt.Legal_Entity_Customer__c);
        Test.stopTest();     
    }
    
    @IsTest
    static void testSetSurveyPIC() {
        Mulesoft_Integration_Control__c mic = new Mulesoft_Integration_Control__c();
        mic.Is_Mulesoft_User__c = true;
        mic.Allow_Opportunity_Number_Override__c = true;
        insert mic;
        CS_Config__c config = new CS_Config__c();
        config.Is_Admin_User__c = true;
        insert config;
        Account acc = [Select id from Account limit 1][0];
        List<User> userList = new List<User>();
        User testUser1 = UTL_TestData.createUser('System Administrator', 1)[0];
        testUser1.PIC_Eligible__c = true;
        userList.add(testUser1);
        User testUser2 = UTL_TestData.createUser('System Administrator', 1)[0];
        testUser2.PIC_Eligible__c = true;
        userList.add(testUser2);
        insert userList;
        List<Contact> testContactList = new List<Contact>();
        Contact testContact = UTL_TestData.createContact(acc.id);
        testContact.Salesforce_User__c = testUser1.id;
        testContact.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        testContactList.add(testContact);
        Contact testContact1 = UTL_TestData.createContact(acc.id);
        testContact1.Salesforce_User__c = testUser1.id;
        testContact1.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        testContactList.add(testContact1);
        insert testContactList;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = UTL_TestData.createOpportunity(acc.id);
        opp.StageName = 'In-Hand';
        opp.Line_of_Business__c = 'Data Sciences';
        opp.Opportunity_Number__c = '1234567';
        opp.Mulesoft_External_Id__c = '1298';        
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.Principle_inCharge__c = testContact.id;
        opp.Survey_Recipient__c = testContact.id; 
        opp.Research_Study_Classification__c = 'Not a research study';
        oppList.add(opp);
        
        Opportunity opp2 = UTL_TestData.createOpportunity(acc.id);
        opp2.StageName = 'In-Hand';
        opp2.Line_of_Business__c = 'Outcome';
        opp2.Opportunity_Number__c = '3293907';
        opp2.Mulesoft_External_Id__c = '7487';
        opp2.Potential_Regions__c = 'Asia Pacific';
        opp2.Principle_inCharge__c = testContact.id;
        opp2.Survey_Recipient__c = testContact.id; 
        opp2.Research_Study_Classification__c = 'Not a research study';
        oppList.add(opp2);
        
        insert oppList;
        List<Client_Sat_Survey__c> surveyList = new List<Client_Sat_Survey__c>();
        
        Client_Sat_Survey__c cs = UTL_TestData.createClientSatSurveyRecord('test', 'Yes', testContact.id, oppList[0].id);
        Client_Sat_Survey__c cs2 = UTL_TestData.createClientSatSurveyRecord('test2', 'Yes', testContact.id, oppList[1].id);
        surveyList.add(cs);
        surveyList.add(cs2);
        insert surveyList;
        
        Test.startTest();
        testContactList = [Select id from Contact];
        List<Contract> contractList = new List<Contract>();
        Contract cntrt = UTL_TestData.createContract(oppList[0], 'Work_Order_Contract_Sales_Medical_Solutions');
        cntrt.IQVIA_Project_Manager_Contact__c = testContactList[1].id;
        cntrt.Opportunity__c = oppList[0].id;
        contractList.add(cntrt);
        Contract cntrt2 = UTL_TestData.createContract(oppList[0], 'Work_Order_Contract_Sales_Medical_Solutions');
        cntrt2.IQVIA_Project_Manager_Contact__c = testContactList[0].id;
        cntrt2.Opportunity__c = oppList[0].id;
        //contractList.add(cntrt2);
        
        Contract cntrt3 = UTL_TestData.createContract(oppList[1], 'Work_Order_Contract_Sales_Medical_Solutions');
        cntrt3.IQVIA_Project_Manager_Contact__c = testContactList[0].id;
        cntrt3.Opportunity__c = oppList[1].id;
        contractList.add(cntrt3);
        insert contractList;

        Test.stopTest();
        contractList = [Select id,IQVIA_Project_Manager_Contact__c,Opportunity__c from Contract where IQVIA_Project_Manager_Contact__c != null];
        surveyList = [select id, Survey_PIC__c,Related_Contract_Id__c,Opportunity__c from Client_Sat_Survey__c];
    }

    /**
    * This method used to test updateContractFieldValues() method.
    */ 
    @isTest
    static void testUpdateContractFieldValues() {
        Contract ctnrt = [Select Id, RecordTypeId from Contract LIMIT 1];
        ctnrt.Name = 'Test Contract 1';
        ctnrt.Update_Contract_Status__c = CON_CRM.CONTRACT_STATUS_NEGOTIATION_TERMINATED;
        ctnrt.RecordTypeId = CON_CRM.CONTRACT_RECORD_TYPE_CNF_GBO;
        ctnrt.Is_the_CNF_Accepted__c = 'Accepted';
        Test.startTest();
        update ctnrt;
        Test.stopTest();
        Contract contract1 = [Select Id, Is_the_CNF_Accepted__c from Contract where Name = 'Test Contract 1'];
        System.assertEquals(contract1.Is_the_CNF_Accepted__c, 'Rejected');
    }
    
}