/**
 * Version       : 1.0
 * Description   : This test class is used for Select Admin_Time_Entry_Data__c
 */
@isTest
private class TST_SLT_Admin_Time_Entry_Data 
{
     
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() 
    {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);        
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        List<Admin_Time_Entry_Data__c> adminTimeEntryDataList = UTL_TestData.createAdminTimeEntryData(proposal.Id); 
        insert adminTimeEntryDataList;
    }
     
    @isTest
    static void testSelectByCondition() {
        
        Apttus_Proposal__Proposal__c testProposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> fieldSet = new Set<String> {CON_CPQ.ID};
        String condition = ' Proposal__c IN :parentIdsSet ';
        
        Test.startTest();
            List<Admin_Time_Entry_Data__c> adminTimeEntryDataList = new SLT_Admin_Time_Entry_Data().selectByCondition(new Set<Id> {testProposal.Id}, fieldSet, condition);
        Test.stopTest();
        
        System.assertEquals(adminTimeEntryDataList.size() > 0, true, 'Admin Time Entry Data exists');
    }
}