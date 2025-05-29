/**
* This test class is used to test all methods in SLT_Bid_History class.
* version : 1.0
*/
@isTest
public class TST_SLT_Bid_History {
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
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Bid_Number__c = 0;
        insert agreement;
    }
    
	
    /**
    * This test method used for insert and update opportunity record
    */ 
    static testMethod void testAgreement() 
	{
        List<Schema.SObjectField> agreementList = new SLT_Bid_History().getSObjectFieldList();
        Schema.SObjectType agreement = new SLT_Bid_History().getSObjectType();
        
		Integer expected = 0;
        System.assertEquals(expected, agreementList.size());
    }    
    
	
    static testMethod void testGetAgreementsById()
	{
        Bid_History__c agreement = [Select Id From Bid_History__c][0];
        Set<Id> idSet = new Set<Id>{agreement.Id};
        Set<String> fieldSet = new Set<String>{'Id'};
        Map<Id, Bid_History__c> idToAgreementMap = new SLT_Bid_History().getBidHistoriesById(idSet, fieldSet);
		
        new SLT_Bid_History().getBidHistoryFieldsById(idSet, fieldSet);
		Integer expected = 1;
        System.assertEquals(expected, idToAgreementMap.size());
    }
    
	
    static testMethod void testSelectByIdWithAgreementAndProjsResReqsAssignments(){
        Bid_History__c agreement = [Select Id From Bid_History__c][0];
        Set<ID> agreementIdset = new Set<ID>{agreement.Id};
        Set<String> agreementFieldSet = new Set<String>{'Id'};
        Set<String> projectFieldSet = new Set<String>{'Id'};
        Set<String> resRequestFieldSet = new Set<String>{'Id'};
        Set<String> assignmentFieldSet = new Set<String>{'Id'};
        Map<Id, Bid_History__c> idToAgreementMap = new SLT_Bid_History().selectByIdWithAgreementAndProjsResReqsAssignments(agreementIdset, agreementFieldSet, projectFieldSet, resRequestFieldSet, assignmentFieldSet);
		
		String expected = agreement.Id;
		String actual = String.valueof(idToAgreementMap.values()[0].get('Id'));
		System.assertEquals(expected, actual);
    } 
    
	
    /*static testMethod void testSelectByIdWithAgreementResourceRequests()
	{
        Bid_History__c agreement = [Select Id From Bid_History__c][0];
        Set<ID> agreementIdset = new Set<ID>{agreement.Id}; 
        Set<String> agreementFieldSet = new Set<String>{'Id'};
        Set<String> resRequestFieldSet = new Set<String>{'Id'};
        Map<Id, Bid_History__c> idToAgreementMap = new SLT_Bid_History().selectByIdWithAgreementResourceRequests(agreementIdset, agreementFieldSet, resRequestFieldSet);
		
		String expected = agreement.Id;
		String actual = String.valueof(idToAgreementMap.values()[0].get('Id'));
		System.assertEquals(expected, actual);
    } */
    
    /**
    * This test method used to get agreement by Opportunity Id
    */
    static testMethod void testGetAgreementByOppId(){
        List<Opportunity> opportunityList  = [Select Id From Opportunity];
        Set<ID> opportunityIDSet = new Set<ID>{opportunityList[0].Id}; 
        Set<String> agreementFieldSet = new Set<String>{'Id'};
        Test.startTest();
            Map<Id, Bid_History__c> idToAgreementMap = new SLT_Bid_History().getBidHistoriesByOppID(opportunityIDSet, agreementFieldSet);
        Test.stopTest();
        
        
        new SLT_Bid_History().getBidHistoryByOpportunitesAll(opportunityIDSet, agreementFieldSet);
        Integer expected = 1;
        System.assertEquals(expected, idToAgreementMap.size());
    }
    
    static testMethod void testGetAgreementByOppIdOrderByCreatedDateDesc(){
        List<Opportunity> opportunityList  = [Select Id From Opportunity];
        Set<ID> opportunityIDSet = new Set<ID>{opportunityList[0].Id}; 
        Set<String> agreementFieldSet = new Set<String>{'Id'};
        Test.startTest();
            Map<Id, Bid_History__c> idToAgreementMap = new SLT_Bid_History().getAgreementByOppIDSortByCreatedDateDesc(opportunityIDSet, agreementFieldSet);
        Test.stopTest();
        
        
        
        
        Integer expected = 1;
        System.assertEquals(expected, idToAgreementMap.size());
    }
    
    /*@isTest
    static void testGetBudgetRelatedToOpportunity(){
        
        Set<String> agreementFieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.NAME};
        List<Opportunity> opportunityList  = [SELECT Id FROM Opportunity];
        Set<ID> opportunityIDSet = new Set<ID>{opportunityList[0].Id};
        String condition = 'Name != null';
        
        Test.startTest();
            Map<Id, Bid_History__c> idToAgreementMap = new SLT_Bid_History().getBudgetRelatedToOpportunity(opportunityIDSet, agreementFieldSet, condition);
        Test.stopTest();
        
        Integer expected = 1;
        System.assertEquals(expected, idToAgreementMap.size());
    }*/
    
    /*@isTest
    static void testGetBudget(){
        
        Set<String> agreementFieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.NAME};
        List<Bid_History__c> agreementList  = [SELECT Id FROM Bid_History__c];
        Set<ID> agreementIDSet = new Set<ID>{agreementList[0].Id};
        String condition = 'Name != null';
        
        Test.startTest();
            Map<Id, Bid_History__c> idToAgreementMap = new SLT_Bid_History().getBudget(agreementIDSet, agreementFieldSet, condition);
        Test.stopTest();
        
        Integer expected = 1;
        System.assertEquals(expected, idToAgreementMap.size());
    }*/

    /*static testMethod void testGetAgreementsByIdWithoutCRUDAndFLS(){
        Bid_History__c agreement = [SELECT Id FROM Bid_History__c][0];
        Set<Id> idSet = new Set<Id>{agreement.Id};
        Set<String> fieldSet = new Set<String>{CON_CPQ.ID};
        Test.startTest();
            Map<Id, Bid_History__c> idToAgreementMap = new SLT_Bid_History().getAgreementsByIdWithoutCRUDAndFLS(idSet, fieldSet);
        Test.stopTest();
    }*/
    
    @isTest
    static void testGetLatestClinicalBid(){
        List<Opportunity> opportunityList  = [Select Id From Opportunity];
        Set<ID> opportunityIDSet = new Set<ID>{opportunityList[0].Id};
        Bid_History__c clinicalBid = [Select Id From Bid_History__c][0];
        Test.startTest();
            Map<Id, Bid_History__c> clinicalBidMap = new SLT_Bid_History().getLatestClinicalBidOnOpportunity(opportunityIDSet, new Set<String>{CON_CPQ.BID_HISTORY_OPPORTUNITY}, 'Bid_History_Related_Opportunity__c in :opportunityIdSet');
        Test.stopTest();
        List<Bid_History__c> clinicalBidList = clinicalBidMap.values();
        System.assertEquals(clinicalBidList.size(), 1, 'Clinical Bid present');
    }
    
    @isTest
    static void testGetClinicalBidDetails(){
        Bid_History__c testClinicalBid = [Select Id From Bid_History__c][0];
        Test.startTest();
            Bid_History__c clinicalBid = new SLT_Bid_History().getClinicalBidDetails(testClinicalBid.Id, new Set<String>{CON_CPQ.BID_HISTORY_OPPORTUNITY});
        Test.stopTest();
        
        System.assertnotEquals(clinicalBid, null, 'Clinical Bid present');
    }
    
    @isTest
    static void testGetBidHistoryByOppOrderByField(){
        List<Opportunity> opportunityList  = [Select Id From Opportunity];
        Set<ID> opportunityIDSet = new Set<ID>{opportunityList[0].Id}; 
        Set<String> bidHistoryFieldSet = new Set<String>{'Id', 'Budget_Tools__c', 'Bid_History_Related_Opportunity__c', 'Bid_Number__c'};
        String whereclause = 'Bid_History_Related_Opportunity__c IN : sObjectIdSet AND RecordTypeId = \'' +CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID+ '\'';
        Test.startTest();
            List<Bid_History__c> bidHistoryRecordsList = new SLT_Bid_History().getBidHistoryByOppOrderByField(opportunityIDSet, bidHistoryFieldSet, whereClause, 'CreatedDate');
        Test.stopTest();
        System.assertEquals(0, bidHistoryRecordsList.size());
    }

    @isTest
    static void testGetLatestBidHistory(){
        Bid_History__c exitingBid = [Select Id, Bid_History_Related_Opportunity__c From Bid_History__c][0];
        Test.startTest();
            List<Bid_History__c> bids = new SLT_Bid_History().getLatestBidHistory(new Set<String>{CON_CPQ.BID_HISTORY_OPPORTUNITY}, ' Bid_History_Related_Opportunity__c =\'' + exitingBid.Bid_History_Related_Opportunity__c + '\'');
        Test.stopTest();
        
        System.assertEquals(bids.size() > 0, true, 'Bid present');
    }
    @isTest
    static void testgetBidHistoryWithCollectionTools(){
        Set<ID> exitingBidSet= New Set<ID>();
        Bid_History__c exitingBid = [Select Id From Bid_History__c][0];
        exitingBidSet.add(exitingBid.id);
        SLT_Bid_History sltbidHistory = new SLT_Bid_History();
        Test.startTest();
        sltbidHistory.getBidHistoryWithCollectionTools(exitingBidSet);
        Test.stopTest();
        List<Bid_History__c> bidHistoryList = [Select id from Bid_History__c];
        System.assertEquals(bidHistoryList.size()>0, true);
    }
}