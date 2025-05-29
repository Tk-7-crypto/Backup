/**
* This test class is used to test all methods in opportunity trigger helper.
* version : 1.0
*/
@isTest
private class TST_SLT_APTS_Agreement {
    
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() 
	{
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Mulesoft_Integration_Control__c mulesoftIntegrationSettings = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getUserId());
        mulesoftIntegrationSettings.Ignore_Validation_Rules__c = true;
        upsert mulesoftIntegrationSettings;
        Apttus__APTS_Agreement__c agreement = UTL_OWF_TestData.createAgreement(acc.Id, opp.Id);
        agreement.RecordTypeId = CON_CLM.PSA_RECORDTYPEID;
        agreement.Apttus__Subtype__c = 'Work Order';
        insert agreement;
    }
    
    /**
    * This test method used for insert and update opportunity record
    */ 
    static testMethod void testAgreement() 
	{
        List<Schema.SObjectField> agreementList = new SLT_APTS_Agreement().getSObjectFieldList();
        Schema.SObjectType agreement = new SLT_APTS_Agreement().getSObjectType();
        
		Integer expected = 0;
        System.assertEquals(expected, agreementList.size());
    }    
    	
    static testMethod void testGetAgreementsById()
	{
        Apttus__APTS_Agreement__c agreement = [Select Id From Apttus__APTS_Agreement__c LIMIT 1][0];
        Set<Id> idSet = new Set<Id>{agreement.Id};
        Set<String> fieldSet = new Set<String>{'Id'};
        Map<Id, Apttus__APTS_Agreement__c> idToAgreementMap = new SLT_APTS_Agreement().getAgreementsById(idSet, fieldSet);
		
		Integer expected = 1;
        System.assertEquals(expected, idToAgreementMap.size());
    }
    /*
    static testMethod void testSelectByIdWithAgreementAndProjsResReqsAssignments(){
        Apttus__APTS_Agreement__c agreement = [Select Id From Apttus__APTS_Agreement__c LIMIT 1][0];
        Set<ID> agreementIdset = new Set<ID>{agreement.Id};
        Set<String> agreementFieldSet = new Set<String>{'Id'};
        Set<String> projectFieldSet = new Set<String>{'Id'};
        Set<String> resRequestFieldSet = new Set<String>{'Id'};
        Set<String> assignmentFieldSet = new Set<String>{'Id'};
        Map<Id, Apttus__APTS_Agreement__c> idToAgreementMap = new SLT_APTS_Agreement().selectByIdWithAgreementAndProjsResReqsAssignments(agreementIdset, agreementFieldSet, projectFieldSet, resRequestFieldSet, assignmentFieldSet);
		
		String expected = agreement.Id;
		String actual = String.valueof(idToAgreementMap.values()[0].get('Id'));
		System.assertEquals(expected, actual);
    } 

    static testMethod void testSelectByIdWithAgreementResourceRequests()
	{
        Apttus__APTS_Agreement__c agreement = [Select Id From Apttus__APTS_Agreement__c LIMIT 1][0];
        Set<ID> agreementIdset = new Set<ID>{agreement.Id}; 
        Set<String> agreementFieldSet = new Set<String>{'Id'};
        Set<String> resRequestFieldSet = new Set<String>{'Id'};
        Map<Id, Apttus__APTS_Agreement__c> idToAgreementMap = new SLT_APTS_Agreement().selectByIdWithAgreementResourceRequests(agreementIdset, agreementFieldSet, resRequestFieldSet);
		
		String expected = agreement.Id;
		String actual = String.valueof(idToAgreementMap.values()[0].get('Id'));
		System.assertEquals(expected, actual);
    } 
     */
    /*
    * This test method used to get agreement by Opportunity Id
    */
    static testMethod void testGetAgreementByOppId(){
        List<Opportunity> opportunityList  = [Select Id From Opportunity LIMIT 1];
        Set<ID> opportunityIDSet = new Set<ID>{opportunityList[0].Id}; 
        Set<String> agreementFieldSet = new Set<String>{'Id'};
        Test.startTest();
            Map<Id, Apttus__APTS_Agreement__c> idToAgreementMap = new SLT_APTS_Agreement().getAgreementByOppID(opportunityIDSet, agreementFieldSet);
        Test.stopTest();
        
        Integer expected = 1;
        System.assertEquals(expected, idToAgreementMap.size());
    }
	
    @isTest
    static void testGetBudgetsRelatedToOpportunity(){
        
        Set<String> agreementFieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.NAME};
        List<Opportunity> opportunityList  = [SELECT Id FROM Opportunity LIMIT 1];
        Set<Id> opportunityIDSet = new Set<Id>{opportunityList[0].Id};
        String condition = 'Name != null';
        
        Test.startTest();
            Map<Id, Apttus__APTS_Agreement__c> idToAgreementMap = new SLT_APTS_Agreement().getBudgetsRelatedToOpportunity(opportunityIDSet, agreementFieldSet, condition);
        Test.stopTest();
        
        Integer expected = 1;
        System.assertEquals(expected, idToAgreementMap.size());
    }
    
    static testMethod void testGetAgreementByOppIdOrderByCreatedDateDesc(){
        List<Opportunity> opportunityList  = [Select Id From Opportunity LIMIT 1];																								
        Set<ID> opportunityIDSet = new Set<ID>{opportunityList[0].Id}; 
        Set<String> agreementFieldSet = new Set<String>{'Id'};
		
        Test.startTest();
            Map<Id, Apttus__APTS_Agreement__c> idToAgreementMap = new SLT_APTS_Agreement().getAgreementByOppIDSortByCreatedDateDesc(opportunityIDSet, agreementFieldSet);
        Test.stopTest();
		
        Integer expected = 1;
        System.assertEquals(expected, idToAgreementMap.size());
    }
    /*
    static testMethod void testgetAgreementAndResReqsByOppId(){
        Apttus__APTS_Agreement__c agreement = [Select Id From Apttus__APTS_Agreement__c LIMIT 1][0];
        Opportunity opp = [SELECT Id FROM Opportunity Limit 1];
        Set<ID> sObjectIdSet = new Set<ID>{opp.Id}; 
        Set<String> agreementFieldSet = new Set<String>{'Id'};
        Set<String> resRequestFieldSet = new Set<String>{'Id'};
        String agrCondition = 'Apttus__Related_Opportunity__c in :sObjectIdSet';
        Map<Id, Apttus__APTS_Agreement__c> idToAgreementMap = new SLT_APTS_Agreement().getAgreementAndResReqsByOppId(sObjectIdSet, agreementFieldSet, resRequestFieldSet, agrCondition, null);		
		String expected = agreement.Id;
		String actual = String.valueof(idToAgreementMap.values()[0].get('Id'));
		System.assertEquals(expected, actual);
    }
     */
    static testMethod void testgetAgreementByOppIDSortByCreatedDateDesc(){
        Apttus__APTS_Agreement__c agreement = [Select Id From Apttus__APTS_Agreement__c LIMIT 1][0];
        Opportunity opp = [SELECT Id FROM Opportunity Limit 1];
        Set<ID> opportunityIdSet = new Set<ID>{opp.Id}; 
        Set<String> agreementFieldSet = new Set<String>{'Id'};
        Map<Id, Apttus__APTS_Agreement__c> idToAgreementMap = new SLT_APTS_Agreement().getAgreementByOppIDSortByCreatedDateDesc(opportunityIdSet, agreementFieldSet);
		
		String expected = agreement.Id;
		String actual = String.valueof(idToAgreementMap.values()[0].get('Id'));
		System.assertEquals(expected, actual);
    }
    
    static testMethod void testgetAgreementsByOppIds(){
        Apttus__APTS_Agreement__c agreement = [Select Id From Apttus__APTS_Agreement__c LIMIT 1][0];
        Opportunity opp = [SELECT Id FROM Opportunity Limit 1];
        Set<ID> opportunityIdSet = new Set<ID>{opp.Id}; 
        Set<String> agreementFieldSet = new Set<String>{'Id'};
        List<Apttus__APTS_Agreement__c> agreementList = new SLT_APTS_Agreement().getAgreementsByOppIds(opportunityIdSet, agreementFieldSet, new Set<String>{'Clinical'}, new Set<String>{'Clinical'});
		
		Integer expected = 1;
		Integer actual = agreementList.size();
		System.assertEquals(expected, actual);
    }
}
