/**
 * This test class is used to test all methods in OpportunityRevenueSplitting Controller.
 * version : 1.0
 */
@isTest
private class TST_CNT_CRM_OpportunitySplit {
    
    /**
     * This method is used to setup data for all methods.
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
     * This test method used to fetch opportunity split records.
     */ 
    static testMethod void testGetOpportunitySplitRecords() {
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        System.runAs(userRecord) {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'TestOpportunity'];
            Test.startTest();
                List<OpportunitySplit> oppSplitList = new  List<OpportunitySplit>();
                oppSplitList = CNT_CRM_OpportunitySplit.getOpportunitySplitRecords(opp.id, CON_CRM.SPLIT_TYPE_NAME, new List<String>{'Id', 'OpportunityId'});
            Test.stopTest();
            System.assertEquals(true, oppSplitList.size() > 0);
        }
    }
    
    /**
     * This test method used to fetch opportunity split records.
     */ 
    static testMethod void testGetOpportunitySplitRecordsException() {
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
          System.runAs(userRecord) {
          Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'TestOpportunity'];
            List<OpportunitySplit> oppSplitList = new  List<OpportunitySplit>();
            Test.startTest();
            try {
                oppSplitList = CNT_CRM_OpportunitySplit.getOpportunitySplitRecords(opp.id, CON_CRM.SPLIT_TYPE_NAME, new List<String>{'Id', 'Name'});
                System.assert(false);
            } catch(Exception ex) {
                System.assertEquals(CON_CRM.AURA_EXCEPTION, ex.getTypeName());
            }
        }
        Test.stopTest();
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
            oppSplit.Id = null;
            oppSplitWrapperList.add(new OpportunityWrapper.OpportunitySplitWrapper(oppSplit, CON_CRM.DELETE_LABEL));
            String jsonString = Json.serialize(oppSplitWrapperList);
            Test.startTest();
                try {
                    CNT_CRM_OpportunitySplit.updateOpportunitySplitRecords(jsonString);
                    system.assert(false);
                } catch(Exception ex) {
                    System.assertEquals(CON_CRM.AURA_EXCEPTION, ex.getTypeName());
                }
            Test.stopTest();
        }
    }
    
    /**
    * test method to get Opp detail exception
    */  
    static testmethod void testGetOppDetailWithOppSplit() {
        OpportunityWrapper oppWrapper = null;
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<String> oppfieldSet = new List<String>{'Id'};
        List<String> oppSplitFieldSet = new List<String>{'Id', 'Name'};
        List<String> oppTeamFieldSet = new List<String>{'Id'};
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        System.runAs(userRecord) {
            Test.startTest();
                try {
                    oppWrapper = CNT_CRM_OpportunitySplit.getOppByIdWithOppTeamSplits(opp.Id, oppfieldSet, oppSplitFieldSet, oppTeamFieldSet, CON_CRM.SPLIT_TYPE_NAME);
                    system.assert(false);
                } catch(Exception ex) {
                    System.assertEquals(CON_CRM.AURA_EXCEPTION, ex.getTypeName());
                }
           Test.stopTest();
        }
    }
    
    /**
    * test method to get Opp detail no exception
    */  
    static testmethod void testGetOppDetailWithOppSplitNoException() {
        OpportunityWrapper oppWrapper = null;
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<String> oppfieldSet = new List<String>{'Id'};
        List<String> oppSplitFieldSet = new List<String>{'Id'};
        List<String> oppTeamFieldSet = new List<String>{'Id'};
        User userRecord = [SELECT Id FROM User WHERE LastName = 'lastName123' limit 1];
        String permissionApiName = 'Edit_Split';
        Boolean hasSpliPermission = false;
        System.runAs(userRecord) {
            Test.startTest();
                oppWrapper = CNT_CRM_OpportunitySplit.getOppByIdWithOppTeamSplits(opp.Id, oppfieldSet, oppSplitFieldSet, oppTeamFieldSet, CON_CRM.SPLIT_TYPE_NAME);
                hasSpliPermission = CNT_CRM_OpportunitySplit.hasEditSplitPermission(permissionApiName);
            Test.stopTest();
            System.assertNotEquals(null, oppWrapper);
            System.assertEquals(true, hasSpliPermission);
        }
    }
}