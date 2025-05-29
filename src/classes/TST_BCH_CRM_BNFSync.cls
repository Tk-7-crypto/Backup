@isTest
private class TST_BCH_CRM_BNFSync {
    
    /**
* This method used to set up testdata
*/ 
    @testSetup
    static void dataSetup() {
        Current_Release_Version__c crv = new Current_Release_Version__c();
        crv.Current_Release__c = '3000.01';
        upsert crv;
        BNF_Settings__c bs = new BNF_Settings__c();
        bs.BNF_Release__c = '2019.01';
        upsert bs;
        Mulesoft_Integration_Control__c mulesoft = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getOrganizationId());
        mulesoft.Is_Mulesoft_User__c = true;
        upsert mulesoft;
        List<User> userList = UTL_TestData.createUser(CON_CRM.SYSTEM_ADMIN_PROFILE, 1);
        userList[0].PIC_Eligible__c = true;
        userList[0].IsActive = true;
        insert userList;
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = New Contact(LastName='TestAp');
        cnt.Salesforce_User__c = userList[0].Id;
        cnt.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        insert cnt;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Principle_inCharge__c = cnt.Id;
        opp.StageName = '7a. Closed Won';
        opp.Primary_Win_Reason__c ='Project Performance';
        opp.Win_Type__c = 'Non-competitive bid';
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE;
        oppLineItem.LI_OpportunityLineItem_Id__c = opp.id;
        insert oppLineItem;
        Test.startTest();
        OpportunityLineItemSchedule olis = UTL_TestData.createOpportunityLineItemSchedule(oppLineItem.Id);
        insert olis;
        Billing_Schedule__c sch = new Billing_Schedule__c(name = 'textSchedule1', OLIId__c = oppLineItem.id);
        insert sch;
        Billing_Schedule_Item__c scheItem = new Billing_Schedule_Item__c(name = 'textScheduleItem1', Billing_Amount__c = 100, Billing_Date__c = system.today(), Billing_Schedule__c = sch.id);
        insert scheItem;
        oppLineItem.Billing_Schedule__c = sch.Id;
        update oppLineItem;
        List<Address__c> addressList = UTL_TestData.createAddresses(acc);
        for(Integer index = 0; index < addressList.size(); index++) {
            addressList[index].MDM_Validation_Status__c = 'Validated';
            addressList[index].RecordTypeId = Schema.SObjectType.Address__c.getRecordTypeInfosByDeveloperName().get('MDM_Validated').getRecordTypeId(); 
        }
        CON_GLOBAL.RELEASE_MAY_2021 = 9999.99;
        insert addressList;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        BNF2__c bnfRecord = UTL_TestData.createBNFRecord(opp, oppLineItem, addressList, revenueAnalyst.Id);
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>{oppLineItem};
        String oliJson = Json.serialize(oliList);
        bnfRecord.OLI_Json_Data_1__c = oliJson;
        bnfRecord.OLI_Json_Data_2__c = oliJson;
        bnfRecord.OLI_Json_Data_3__c = oliJson;
        insert bnfRecord; 
        Test.stopTest();
    }
    
    @isTest
    static void test1() {
        Test.startTest();
        BCH_CRM_BNFSync bchCrmBnfSync = new BCH_CRM_BNFSync();
        Id batchId = Database.executeBatch(bchCrmBnfSync);
        Test.stopTest();
        //System.assertEquals(10, [select count() from BNF2__c where MailingCity = 'New York']);
    }
}