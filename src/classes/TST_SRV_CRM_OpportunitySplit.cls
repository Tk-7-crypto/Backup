/*
 * Version       : 1.0
 * Description   : This test class is used for Select OpportunitySplit
 */
@isTest
private class TST_SRV_CRM_OpportunitySplit {

    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
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
        System.runAs(userList[0]) {
            OpportunitySplit oppSplit = UTL_TestData.createOpportunitySplit(opp.Id, userList[0].Id, splitTypeId);
            insert oppSplit;
        }
    }
    
    /**
     * This method used to get OpportunitySplit By Opportunity Id With Exception
     */    
    @IsTest
    static void testGetOpportunitySplitRecordsWithException() {
        Opportunity opp = [SELECT id FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<String> fieldSet = new Set<String> {'Id', 'Name'};
        Set<Id> oppIdSet = new Set<Id>{opp.Id};
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        System.runAs(userRecord) {
            Test.startTest();
                try {
                    List<OpportunitySplit> opportunitySplitList = SRV_CRM_OpportunitySplit.getOpportunitySplitRecords(oppIdSet, CON_CRM.SPLIT_TYPE_NAME, fieldSet);
                    System.assert(false);
                } catch(Exception ex) {
                    System.assertEquals('SRV_CRM_OpportunitySplit.OpportunitySplitServiceException', ex.getTypeName());
                }
            Test.stopTest();
        }
    }
    
    /**
     * This method used to get OpportunitySplit By Opportunity Id
     */    
    @IsTest
    static void testGetOpportunitySplitRecords() {
        Opportunity opp = [SELECT id FROM Opportunity WHERE name = 'TestOpportunity'];
        List<OpportunitySplit> opportunitySplitList = null;
        Set<String> fieldSet = new Set<String> {'Id'};
        Set<Id> oppIdSet = new Set<Id>{opp.Id};
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        System.runAs(userRecord) {
            Test.startTest();
                opportunitySplitList = SRV_CRM_OpportunitySplit.getOpportunitySplitRecords(oppIdSet, CON_CRM.SPLIT_TYPE_NAME, fieldSet);
            Test.stopTest();
            Integer expected = 1;
            system.debug(opportunitySplitList);
            Integer actual = opportunitySplitList.size();
            System.assertEquals(expected, actual);
        }
    }
    
    /**
     * This method used to delete OpportunitySplit By Opportunity Id
     */    
    @IsTest
    static void testDeleteOpportunitySplits() {
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        System.runAs(userRecord) {
            OpportunitySplit oppSplit = [SELECT id FROM OpportunitySplit WHERE SplitType.DeveloperName = :CON_CRM.SPLIT_TYPE_NAME];
            List<OpportunityWrapper.OpportunitySplitWrapper> oppSplitWrapperList = new List<OpportunityWrapper.OpportunitySplitWrapper>();
            oppSplitWrapperList.add(new OpportunityWrapper.OpportunitySplitWrapper(oppSplit, CON_CRM.DELETE_LABEL));
            Test.startTest();
                SRV_CRM_OpportunitySplit.updateOpportunitySplits(oppSplitWrapperList);
            Test.stopTest();
            List<OpportunitySplit> oppSplitList = [SELECT id FROM OpportunitySplit WHERE SplitType.DeveloperName = :CON_CRM.SPLIT_TYPE_NAME];
            Integer expected = 0;
            Integer actual = oppSplitList.size();
            System.assertEquals(expected, actual);
        }
    }
    
    /**
     * This method used to delete OpportunitySplit By Opportunity Id
     */    
    @IsTest
    static void testDeleteOpportunitySplitsException() {
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        System.runAs(userRecord) {
            OpportunitySplit oppSplit = [SELECT id FROM OpportunitySplit WHERE SplitType.DeveloperName = :CON_CRM.SPLIT_TYPE_NAME];
            oppSplit.Id = null;
            List<OpportunityWrapper.OpportunitySplitWrapper> oppSplitWrapperList = new List<OpportunityWrapper.OpportunitySplitWrapper>();
            oppSplitWrapperList.add(new OpportunityWrapper.OpportunitySplitWrapper(oppSplit, CON_CRM.DELETE_LABEL));
            Test.startTest();
                try {
                    SRV_CRM_OpportunitySplit.updateOpportunitySplits(oppSplitWrapperList);
                    System.assert(false);
                } catch(Exception ex) {
                    System.assertEquals('SRV_CRM_OpportunitySplit.OpportunitySplitServiceException', ex.getTypeName());
                } 
            Test.stopTest();
        }
    }
    
    
    /**
     * This method used to udpate OpportunitySplit By Opportunity Id
     */    
    @IsTest
    static void testUpdateOpportunitySplits() {
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        System.runAs(userRecord) {
            OpportunitySplit oppSplit = [SELECT id FROM OpportunitySplit WHERE SplitType.DeveloperName = :CON_CRM.SPLIT_TYPE_NAME];
            oppSplit.SplitNote = 'Test Split V2';
            List<OpportunityWrapper.OpportunitySplitWrapper> oppSplitWrapperList = new List<OpportunityWrapper.OpportunitySplitWrapper>();
            oppSplitWrapperList.add(new OpportunityWrapper.OpportunitySplitWrapper(oppSplit, CON_CRM.EDIT_LABEL));
            Test.startTest();
                SRV_CRM_OpportunitySplit.updateOpportunitySplits(oppSplitWrapperList);
            Test.stopTest();
            List<OpportunitySplit> oppSplitList = [SELECT id, SplitNote FROM OpportunitySplit WHERE SplitType.DeveloperName = :CON_CRM.SPLIT_TYPE_NAME];
            String expected = 'Test Split V2';
            String actual = oppSplitList[0].SplitNote;
            System.assertEquals(expected, actual);
        }
    }
    
    /**
     * This method used to get OpportunitySplitType Id By OpportunitySplitType Name
     */
    @IsTest
    static void testGetOpportunitySplitTypeIdByName() {
        Test.startTest();
            Id oppSplitTypeId = SRV_CRM_OpportunitySplit.getOpportunitySplitTypeIdByName(CON_CRM.SPLIT_TYPE_NAME);
        Test.stopTest(); 
        System.assertNotEquals(null, oppSplitTypeId);
    }
}