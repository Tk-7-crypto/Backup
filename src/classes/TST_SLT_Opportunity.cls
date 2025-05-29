/*
* Version       : 1.0
* Description   : This test class is used for Select Opportunity
*/
@isTest
private class TST_SLT_Opportunity { 
    
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Opportunity_Number__c = '124';
        opp.Legacy_Quintiles_Opportunity_Number__c = '12';
        opp.Line_of_Business__c = 'Data Sciences';
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.LI_Opportunity_Id__c = 'scrapId';

        insert opp;
        Product2 product = UTL_TestData.createProduct();
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        List<User> userList = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE, 1);
        insert userList;
        OpportunityTeamMember teamMember = UTL_TestData.createOpportunityTeamMember(opp.Id, userList[0].Id);
        insert teamMember;
        Id splitTypeId = SRV_CRM_OpportunitySplit.getOpportunitySplitTypeIdByName(CON_CRM.SPLIT_TYPE_NAME);
        pse__Proj__c project = new pse__Proj__c(pse__Is_Billable__c = false, pse__Opportunity__c = opp.Id);
        project.Name = 'Annual Leave/Vacation';
        project.Go_Live_Date__c = Date.today().addDays(30);
        project.pse__Account__c = acc.id;
        insert project;
        System.runAs(userList[0]) {
            OpportunitySplit oppSplit = UTL_TestData.createOpportunitySplit(opp.Id, userList[0].Id, splitTypeId);
            insert oppSplit;
        }
        Test.startTest();
        Product2 product2 = UTL_TestData.createProduct();
        insert product2;
        PricebookEntry pbe = UTL_TestData.createPricebookEntry(product2.Id);
        insert pbe;
        OpportunityLineItem oli = UTL_TestData.createOpportunityLineItem(opp.Id, pbe.Id);
        insert oli;
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        for(Integer index = 0; index < addressList.size(); index++) {
            addressList[index].MDM_Validation_Status__c = 'Validated';
            addressList[index].RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId(); 
        }
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        insert addressList;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        BNF2__c bnf2 = UTL_TestData.createBNFRecord(opp, oli, addressList, revenueAnalyst.Id);
        insert bnf2;
        MIBNF2__c mibnf2 = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert mibnf2;
        Test.stopTest();
    }
    
    static Apttus__APTS_Agreement__c getAgreementData(Id opportuntiyId, String recordTypeAPIName){

        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;

        Id recordTypeId =
            SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get(recordTypeAPIName).getRecordTypeId();
        Apttus__APTS_Agreement__c testAgreement = UTL_TestData.createAgreement();
        testAgreement.RecordTypeId = recordTypeId;
        testAgreement.Apttus__Related_Opportunity__c = opportuntiyId;
        insert testAgreement;
        return testAgreement;
    }
    
    @isTest
    static void testGetOpportunityDetails() {
        Opportunity opp = [SELECT id FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<String> oppFieldSet = new Set<String> {'Id', 'Name'};
        Test.startTest();
        Opportunity opportunityRecord = new SLT_Opportunity().getOpportunityDetails(opp.Id , oppFieldSet);
        Test.stopTest();
        System.assertEquals(opp.Id, opportunityRecord.Id); 
    }
    
    @isTest
    static void testGetOpportunityById() {
        Opportunity opp = [SELECT id FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<String> oppFieldSet = new Set<String> {'Id'};
        Test.startTest();
        Map<Id, Opportunity> idToOpportunityMap = new SLT_Opportunity().getOpportunityById(new Set<Id> { opp.Id }, oppFieldSet);
        Test.stopTest();
        System.assertEquals(opp.Id, idToOpportunityMap.get(opp.Id).Id); 
    }
    
    @isTest
    static void testSelectByIdWithOpportunitySplit() {
        Opportunity opp = [SELECT id FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<String> oppfieldSet = new Set<String>{'Id'};
        Set<String> oppSplitFieldSet = new Set<String>{'Id'};
        Set<String> oppTeamFieldSet = new Set<String>{'Id'};    
        Test.startTest();
        Map<Id, Opportunity> idToOpportunityMap = new SLT_Opportunity().selectByIdWithOpportuntiyTeamSplits(new Set<Id>{opp.Id}, oppFieldSet, oppSplitFieldSet, oppTeamFieldSet, CON_CRM.SPLIT_TYPE_NAME);
        List<Opportunity> oppList = idToOpportunityMap.values();
        Test.stopTest();
        Integer expected = 1;
        Integer actual = oppList.size();
        System.assertEquals(expected, actual);
    }
    
    static testMethod void testSelectByIdWithOpportuntiyLineItem() {
        Set<Id> oppIdSet = new Set<Id>();
        Set<String> oppfieldSet = new Set<String>{'Id'};
        Set<String> oliFieldSet = new Set<String>{'Id'};
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
     	oppIdSet.add(opp.Id);
        Test.startTest();
        Map<Id, Opportunity> idToOpportunityMap = new SLT_Opportunity().SelectByIdWithOpportuntiyLineItem(oppIdSet, oppfieldSet, oliFieldSet);
        List<Opportunity> oppList = idToOpportunityMap.values();
        Test.stopTest();
        Integer expected = 1;
        Integer actual = oppList.size();
        System.assertEquals(expected, actual);
    }
    
    static testMethod void testSelectAgreementByOpportunity() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(opp.Id);
        Set<String> oppfieldSet = new Set<String>{'Id'};
        Set<Id> agreementRecordTypesSet = new Set<Id>();
        Set<String> agreementFieldsSet = new Set<String>{'Id'}; 
        Test.startTest();
        Map<Id, Opportunity> idToOpportunityMap = new SLT_Opportunity().selectAgreementByOpportunity(oppIdSet, oppfieldSet, agreementRecordTypesSet, agreementFieldsSet);
        Test.stopTest();
        System.assertEquals(1, idToOpportunityMap.size());  
    }
    
    static testMethod void testSelectByIdWithOpportuntiyAgreementWithCondition(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(opp.Id);
        Set<String> oppfieldSet = new Set<String>{'Id'};
        Set<String> agreementFieldSet = new Set<String>{'Id'};
        Integer recordLimit = 1;
        String agrCondition = 'name = \'Test Agr\'';
        Test.startTest();
        Map<Id, Opportunity> idToOpportunityMap = new SLT_Opportunity().selectByIdWithBidHistoryCondtion(oppIdSet, oppfieldSet, agreementFieldSet,agrCondition );
        List<Opportunity> oppList = idToOpportunityMap.values();
        Test.stopTest();
        Integer expected = 1;
        Integer actual = oppList.size();
        System.assertEquals(expected, actual);
    }
    
    @isTest
    static void testSelectAgreementByOpportunities() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(opp.Id);
        Set<String> oppfieldSet = new Set<String>{'Id'};
        Set<String> agreementFieldSet = new Set<String>{'Id'};
        Test.startTest();
        Map<Id, Opportunity> idToOpportunityMap = new SLT_Opportunity().selectAgreementByOpportunities(oppIdSet, oppfieldSet, agreementFieldSet);
        List<Opportunity> oppList = idToOpportunityMap.values();
        Test.stopTest();
        Integer expected = 1;
        Integer actual = oppList.size();
        System.assertEquals(expected, actual);
    }
    
    @isTest
    static void testGetOpportunityByFieldCondition(){
        Set<String> fieldSet = new Set<String>{'Id', 'Name'};
        List<String> fieldValueList = new List<String>{'124'};
        Set<String> oppIds = new Set<String>();
        Test.startTest();
        List<Opportunity> oppList = new SLT_Opportunity().getOpportunityByFieldCondition(fieldSet, fieldValueList, oppIds);
        Test.stopTest();
        Integer expected = 0;
        Integer actual = oppList.size();
        System.assertEquals(expected, actual);
    }
    
    @isTest
    static void testSelectByIdWithBNF() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(opp.Id);
        Set<String> oppfieldSet = new Set<String>{'Id'};
        Set<String> bnfFieldSet = new Set<String>{'Id'};
        Test.startTest();
        Map<Id, Opportunity> idToOpportunityMap = new SLT_Opportunity().selectByIdWithBNF(oppIdSet, oppfieldSet, bnfFieldSet);
        Test.stopTest();
        System.assertEquals(opp.Id, idToOpportunityMap.get(opp.Id).Id);      
    }
    
    @isTest
    static void testSelectByIdWithMIBNF() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(opp.Id);
        Set<String> oppfieldSet = new Set<String>{'Id'};
        Set<String> mibnfFieldSet = new Set<String>{'Id'};
        Test.startTest();
        Map<Id, Opportunity> idToOpportunityMap = new SLT_Opportunity().selectByIdWithMIBNF(oppIdSet, oppfieldSet, mibnfFieldSet);
        Test.stopTest();
        System.assertEquals(opp.Id, idToOpportunityMap.get(opp.Id).Id); 
    }
    
    @isTest
    static void testSelectByOpportunityId() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(opp.Id);
        Set<String> oppfieldSet = new Set<String>{'Id'};
        Test.startTest();
        Map<Id, Opportunity> idToOpportunityMap = new SLT_Opportunity().selectByOpportunityId(oppIdSet, oppfieldSet);
        Test.stopTest();
        System.assertEquals(opp.Id, idToOpportunityMap.get(opp.Id).Id); 
    }
    
   /* @isTest
    static void testSelectByIdWithLineItemGroups() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<String> oppfieldSet = new Set<String>{'Id'};
        List<String> oppFieldsGroupSet = new List<String>{'12'};
        Set<String> lineItemFieldsSet = new Set<String>{'Id'};
        Test.startTest();
        Map<Id, Opportunity> idToOpportunityMap = new SLT_Opportunity().selectByIdWithLineItemGroups(oppfieldSet, oppFieldsGroupSet, lineItemFieldsSet);
        Test.stopTest();
        System.assertEquals(opp.Id, idToOpportunityMap.get(opp.Id).Id); 
    } */
    
    @isTest
    static void testGetMapOfOpportunitiesWithProjectsById(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Test.startTest();
        Map<Id, Opportunity> idToOpportunityMap = new SLT_Opportunity().getMapOfOpportunitiesWithProjectsById(new Set<Id>{opp.id});
        Test.stopTest();
        System.assertEquals(false, idToOpportunityMap.isEmpty(),'Map is not fetched');
        System.assertEquals(1, idToOpportunityMap.size(),'Map is not fetched');
    }
    
    @isTest
    static void testgetOpportunityWithOpportunityHistory(){ 
        DateTime today = System.today();
        Set<String> oppfieldSet = new Set<String> {'Id','StageName','Primary_Win_Reason__c','Win_Type__c','Contract_Start_Date__c','Contract_End_Date__c','Account.Date_Risk_Assessed__c'};
        Set<String> oppHistoryFieldSet = new Set<String> {'id','StageName','createdDate'};
        String oppCondition =  'Account.Global_Risk_Rating__c =\'' + CON_CRM.ACCOUNT_RISK_RATING_6_DO_NOT_SELL + '\'';
        Test.startTest();
        new SLT_Opportunity().getOpportunityWithOpportunityHistories(oppfieldSet, oppCondition, oppHistoryFieldSet);
        Test.stopTest();
    }
    
    @isTest
    static void testGetOpportunityWithOpportunityTeamMember(){
        Set<String> oppfieldSet = new Set<String>{'id','name'};
        Opportunity opp = [Select id from Opportunity where name = 'TestOpportunity'];
        Set<Id> oppidSet = new Set<Id>{opp.id};
        Set<String> oppTeamMemberFieldSet = new Set<String>{'id','name'};
        Test.startTest();
            new SLT_Opportunity().getOpportunityWithOpportunityTeamMember(oppfieldSet,oppidSet,oppTeamMemberFieldSet);
        Test.stopTest();
    }
    
    @isTest
    static void testGetOpportunityByParentNumber() {
        Set<String> fieldSet = new Set<String>{'Id', 'Name', 'Parent_Number__c', 'Legacy_Quintiles_Opportunity_Number__c'};
        Opportunity opp = [Select id, Opportunity_Number__c from Opportunity where name = 'TestOpportunity'];
        Set<String> parentIdSet = new Set<String>{opp.Id};
        Test.startTest();
            new SLT_Opportunity().getOpportunityByParentId(fieldSet, parentIdSet);
        Test.stopTest();
    }
    

    static testMethod void getSelectBySearchStringTest(){
        SLT_Opportunity sltObjectClass = new SLT_Opportunity();
        // Id oppId = [SELECT Id FROM Opportunity WHERE name = 'testOpp'].Id;
        Opportunity oppRec = [SELECT Id, Name, StageName FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<String> fieldsToQuery = new Set<String>{'Id', 'StageName'};
        String searchString = 'test';
        String searchStr = '\'%' + searchString + '%\'';
        List<Opportunity> oppRecLst = sltObjectClass.selectBySearchString(searchStr, fieldsToQuery);
        System.assertEquals(oppRecLst[0].StageName , oppRec.StageName);
        System.assertEquals(oppRecLst[0].Id , oppRec.Id);
    }
    
    @IsTest
    private static void testGetOpportunityWithClientSatByoppId() {
        Opportunity opp = [SELECT id FROM Opportunity WHERE name = 'TestOpportunity'];
        Date Date6Back = Date.today().addMonths(-6); 
        Test.startTest();
        List<opportunity> opplist = new SLT_Opportunity().getOpportunityWithClientSatByoppId(new Set<Id>{opp.Id}, Date6Back);
        Test.stopTest();
        
        System.assertEquals(1, opplist.size(), 'Got Opportunity Record');
    }     
    
    
    @IsTest
    private static void getLatestSurveyOfOpportunity() {
        Opportunity opp = [SELECT id FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<String> oppFieldSet = new Set<String>{'Is_Survey_Exist__c'};
        String Condition = 'Is_Survey_Exist__c = false';   
        Test.startTest();
        List<opportunity> opplist = new SLT_Opportunity().getLatestSurveyOfOpportunity(new Set<Id>{opp.Id});
        List<opportunity> oppSurveyList = new SLT_Opportunity().getOpportunityWithNonExistingsurvey(new Set<Id>{opp.Id}, oppFieldSet, Condition);
        opplist = new SLT_Opportunity().getLatestSurveyOfOpportunitybyLOB(new Set<Id>{opp.Id}, new Set<String> {'Outcome'});
        opplist = new SLT_Opportunity().getLastSurveyOfOpportunity(new Set<Id>{opp.Id});
        Test.stopTest();
    } 
    
    @isTest
    private static void testGetOpportunityByAccountIdANDStage() {
        Account acc = [Select Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT id, StageName FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<Id> accIdSet = new Set<Id>{acc.Id};
        Set<String> stageNameSet = new Set<String>{opp.StageName};
        Set<String> oppFieldSet = new Set<String> {'Id','AccountId','Name','StageName','Line_of_Business__c','Amount_In_USD__c', 'Owner_Email__c','Amount','CSMS_Product__c','CSMS_Product_Amount__c',
            'GMI_Product_Count__c','GMI_Product_Amount__c','Q2_Product_Count__c','Q2_Product_Amount__c','RD_Product_Count__c',
            'RD_Product_Amount__c','RWAS_Product_Count__c','RWAS_Product_Amount__c','Commercial_Tech_Product_Count__c',
            'Tech_Analytic_Product_Amount__c'};
        Test.startTest();
        Map<Id, Opportunity> oppMap = new SLT_Opportunity().getOpportunityByAccountIdANDStage(accIdSet, oppFieldSet, stageNameSet);
        Test.stopTest();
    }
    
    @isTest
    private static void testGetOpportunityWithInsideSalesUser() {
        Account acc = [Select Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT id, StageName FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<String> oppFieldSet = new Set<String> {'Id','AccountId','Name','StageName','Line_of_Business__c'};
        Test.startTest();
        List<Opportunity> oppList = new SLT_Opportunity().getOpportunityWithInsideSalesUser(oppFieldSet, UserInfo.getUserId());
        Test.stopTest();
    }
    
    @isTest
    private static void testGetOppWithFilterCondition() {
        Opportunity opp = [Select id from Opportunity where name = 'TestOpportunity'];
        Set<Id> oppidSet = new Set<Id>{opp.id};
        Set<String> oppFieldSet = new Set<String>{'Id','Name','Is_Survey_Exist__c'};
        String Condition = 'Discount_Approval_Requested__c = false';   
        Test.startTest();
        Map<Id, Opportunity> OppMap = new SLT_Opportunity().getOppWithFilterCondition(oppidSet,oppFieldSet,Condition);
        Test.stopTest();
        
    }
    
    @isTest
    private static void testGetRecordByIdForCallOut() {
        Opportunity opp = [Select id from Opportunity where name = 'TestOpportunity'];  
        Test.startTest();
        Opportunity oppRecord = new SLT_Opportunity().getRecordByIdForCallOut(opp.Id);
        Test.stopTest();
        
    }
    
    @isTest
    private static void testSelectById() {
        Opportunity opp = [Select id from Opportunity where name = 'TestOpportunity']; 
        Set<Id> oppidSet = new Set<Id>{opp.id};
        Set<String> oppFieldSet = new Set<String>{'Id','Name','Is_Survey_Exist__c'};
        Test.startTest();
        List<Opportunity> oppList = new SLT_Opportunity().selectById(oppidSet,oppFieldSet);
        Test.stopTest();
        
    }
    
    @isTest
    private static void testselectByIdWithPricingAssistant() {
        Opportunity opp = [Select id from Opportunity where name = 'TestOpportunity'];
        Set<Id> oppidSet = new Set<Id>{opp.id};
        Test.startTest();
        List<Opportunity> oppList = new SLT_Opportunity().selectByIdWithPricingAssistant(oppidSet);
        Test.stopTest();
    }
}