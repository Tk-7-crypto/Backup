/*
 * Version       : 1.0
 * Description   : Test Class for SLT_ProcessInstance
 */
@isTest
private class TST_SLT_ProcessInstance {
    
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
        
        Bid_History__c clinicalBid = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        clinicalBid.Bid_Number__c = 0;
        insert clinicalBid;
        
        Apttus_Proposal__Proposal__c budgetRecord = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
    }
    
    @IsTest
    static void testGetProcessInstanceByTargetObjectIdAndStatus() {
        
        Apttus_Proposal__Proposal__c budgetRecord = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        /*Commented under LC-11457 to deactivate approval process
        Approval.ProcessSubmitRequest request= new Approval.ProcessSubmitRequest();
        request.setObjectId(budgetRecord.Id);
        request.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        Approval.ProcessResult result = Approval.process(request);*/
        
        Test.startTest();
            List<ProcessInstance> resultList = new SLT_ProcessInstance().getProcessInstanceByTargetObjectIdAndStatus(new Set<Id>{budgetRecord.Id}, CON_CPQ.PENDING,
            	new Set<String>{CON_CPQ.ID, CON_CPQ.TARGET_OBEJCT_ID});
        Test.stopTest();
        
        //System.assert(resultList.size() > 0, 'Result should not be empty');
    }

}