/**
 * Test class of CNT_CPQ_QuoteLanding
 */
@IsTest
private class TST_CNT_CPQ_QuoteLanding {

    /**
    * This method used to set up testdata
    */
    @TestSetup
    static void dataSetup() {
        // Create custom setting record to get Permission set and allowed record types
        CPQ_Proposal_Create_Settings__c customSettingsObj = new CPQ_Proposal_Create_Settings__c();
        customSettingsObj.Name = 'CPQ TS Quote/Proposal';
        customSettingsObj.Permission_Set_Name__c = CON_CPQ.CPQ_TS_READ_WRITE_PERMISSION_SET;
        customSettingsObj.Proposal_Record_Type_Name__c = CON_CPQ.TECH_SOLUTION;
        insert customSettingsObj;
        
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'AL';
        acc.AccountStatus__c = 'active';
        insert acc;
        
        Opportunity testOpportunity= UTL_TestData.createOpportunity(acc.id);
        testOpportunity.Line_of_Business__c = 'Clinical';
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        testOpportunity.CurrencyIsoCode = CON_CPQ.USD;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = 'MVP123';
        testOpportunity.Potential_Regions__c = CON_CPQ.REGION_ASIA_PASIFIC;
        testOpportunity.Number_of_Potential_Regions__c = 0;
        insert testOpportunity;
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
     
    }
    
    @IsTest
    static void testGetRecordTypes_NoCustomSettingsRecordDefined() {
        // Delete the custom settings record
        delete [Select Id From CPQ_Proposal_Create_Settings__c];
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Test.startTest();
        List<CNT_CPQ_QuoteLanding.RecordTypeDetail> recordTypes = CNT_CPQ_QuoteLanding.getAvaiableRecordTypes(oppId);
        System.assertEquals(0, recordTypes.size(), 'Record Types size mis-match');
        Test.stopTest();
    }
    
    @IsTest
    static void testGetRecordTypes_NoPermissionSetAssignedToUser() {
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Test.startTest();
        List<PermissionSetAssignment> permissionList = [SELECT Id from PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.name =: CON_CPQ.CPQ_TS_READ_WRITE_PERMISSION_SET];
        if (permissionList.size() != 0) {
            delete permissionList;
        }
        List<CNT_CPQ_QuoteLanding.RecordTypeDetail> recordTypes = CNT_CPQ_QuoteLanding.getAvaiableRecordTypes(oppId);
        System.assertEquals(0, recordTypes.size(), 'Record Types size mis-match');
        Test.stopTest();
    }
    
    @IsTest
    static void testGetRecordTypes_PermissionSetAssignedToUser() {
        // Retrieve CPQ TS Read Write Permission Set
        PermissionSet permissionSetObj = [SELECT Id FROM PermissionSet WHERE Name =: CON_CPQ.CPQ_TS_READ_WRITE_PERMISSION_SET];
        
        // Assign the CPQ TS Read Write Permission set to current user
        List<PermissionSetAssignment> permissionList = [SELECT Id from PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.name =: CON_CPQ.CPQ_TS_READ_WRITE_PERMISSION_SET];
        if (permissionList.size() == 0) {
            PermissionSetAssignment permissionAssignmentObj = new PermissionSetAssignment();
            permissionAssignmentObj.AssigneeId = UserInfo.getUserId();
            permissionAssignmentObj.PermissionSetId = permissionSetObj.Id;
            insert permissionAssignmentObj;
        }
        
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Test.startTest();
        List<CNT_CPQ_QuoteLanding.RecordTypeDetail> recordTypes = CNT_CPQ_QuoteLanding.getAvaiableRecordTypes(oppId);
        System.assertEquals(1, recordTypes.size(), 'Record Types size mis-match');
        Test.stopTest();
    } 
    
    @IsTest
    static void testValidClinicalBid() {
      	Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
			Boolean validBid = CNT_CPQ_QuoteLanding.validClinicalBid(opp.id);	
        Test.stopTest();
       System.assertEquals(false, validBid);
        
    }

    @isTest
    static void testCreateQuote() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        String tsRecordTypeID = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Tech Solution').getRecordTypeId();
        
        Apttus_Config2__PriceList__c priceList = UTL_TestData.createPriceList('AMESA Price List');
        
        CPQ_Proposal_Create_Settings__c customSettingsObj = new CPQ_Proposal_Create_Settings__c();
        customSettingsObj.Name = 'CPQ TS AMESA Quote/Proposal';
        customSettingsObj.Permission_Set_Name__c = 'AMESA Permission Set';
        customSettingsObj.Proposal_Record_Type_Name__c = CON_CPQ.TECH_SOLUTION;
        customSettingsObj.Price_List__c = 'AMESA Price List';
        customSettingsObj.Available_Pricing_Tools__c = 'AMESA';
        insert customSettingsObj;
        
        Test.startTest();
            String firstBudgetId = CNT_CPQ_QuoteLanding.createQuote(CON_CPQ.AMESA, tsRecordTypeID, opp.Id);
        Test.stopTest();
        
        System.assert( firstBudgetId != null, 'Quote is created successfully');
    }
}
