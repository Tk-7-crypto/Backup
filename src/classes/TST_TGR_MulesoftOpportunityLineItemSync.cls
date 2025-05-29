@isTest
private class TST_TGR_MulesoftOpportunityLineItemSync {
    
    static testmethod void insertMulesoftOpportunityLineItemSyc () {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        Mulesoft_OpportunityLineItem_Sync__c mls = new Mulesoft_OpportunityLineItem_Sync__c ();
        mls.Mulesoft_Update_GUID__c = UTL_Guid.newGuid();
        mls.Mulesoft_Sync_Status__c = CON_CRM.MULESOFT_SYNC_STATUS_PENDING;
        mls.Mulesoft_Sync_Timestamp__c = null;
        mls.Mulesoft_Error_Message__c = null;
        mls.OpportunityLineItemId__c = oppLineItem.id; 
        Test.startTest();
        try{
		insert mls;
		}
		catch(exception e){}
        Test.stopTest();
    }

}