/*
 * Version       : 1.0
 * Description   : Test Class for SLT_ProcessInstanceWorkitem
 */
@isTest
private class TST_SLT_ProcessInstanceWorkitem {
    
    /**
     * This method used to test sobject field list
     */    
    @IsTest
    static void testGetSObjectFieldList() {
        Test.startTest();
            SLT_ProcessInstanceWorkitem sltProcessInstanceWorkitem = new SLT_ProcessInstanceWorkitem();
            sltProcessInstanceWorkitem.getSObjectFieldList();
        Test.stopTest();
    }
    
    /**
     * This method used to test SObjectType
     */    
    @IsTest
    static void testGetSObjectType() {
        Test.startTest();
            SLT_ProcessInstanceWorkitem sltProcessInstanceWorkitem = new SLT_ProcessInstanceWorkitem();
            sltProcessInstanceWorkitem.getSObjectType();
        Test.stopTest();
    }
    
    /**
     * This method used to get ProcessInstanceWorkitem by id
     */    
    @IsTest
    static void testSelectById() {
        List<ProcessInstanceWorkitem> processInstanceWorkitems = new  List<ProcessInstanceWorkitem>();  
        Test.startTest();
            processInstanceWorkitems = new SLT_ProcessInstanceWorkitem().selectById(new Set<Id> {});
        Test.stopTest();
        Integer expected = 0;
        Integer actual = processInstanceWorkitems.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * This method used to get all Pending ProcessInstanceWorkitem by id
     */    
    @IsTest
    static void testGetAllPendingWorkItems() {
        List<ProcessInstanceWorkitem> processInstanceWorkitems = new  List<ProcessInstanceWorkitem>();  
        Test.startTest();
            processInstanceWorkitems = new SLT_ProcessInstanceWorkitem().getAllPendingWorkItems(new Set<Id> {});
        Test.stopTest();
        Integer expected = 0;
        Integer actual = processInstanceWorkitems.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * This method used to get RecordType by Name
     */    
    @IsTest
    static void testGetRecordTypeIdByName() {
        RecordType recordType = [select id, name, developername from recordType LIMIT 1];
        Test.startTest();
            recordType = new SLT_ProcessInstanceWorkitem().getRecordTypeIdByName(recordType.developername);
        Test.stopTest();
    }
	
    /**
     * This method used to get RecordType by sObjectType
     */    
    @IsTest
    static void testGetRecordTypesBySObjectType() {
        RecordType recordType = [select Id, Name from recordType LIMIT 1];
        Test.startTest();
            List<recordType> recordTypeList = new SLT_ProcessInstanceWorkitem().getRecordTypesBySObjectType(recordType.Name);
        Test.stopTest();
        Integer expected = 0;
        Integer actual = recordTypeList.size();
        System.assertEquals(expected, actual);
    }
	
    @IsTest
    static void testGetProcessInstanceWorkItem() {
        UTL_TestData.createOneKeyConfig();
        Test.setMock(HttpCalloutMock.class, new TST_Mock_WSC_CSM_OneKeyCaseVerification());
        case newCase1 = UTL_TestData.createCase();
        insert newCase1;
        SLT_ProcessInstanceWorkitem processIntance = new SLT_ProcessInstanceWorkitem();
        
        Test.startTest();
            List<ProcessInstanceWorkitem> result = processIntance.getProcessInstanceWorkitemByTargetId(new Set<Id>{newCase1.Id});
        Test.stopTest();
        
        System.assertEquals(true, result.isEmpty(), 'Case is in approval process');
    }
    static void dataSetup() {
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
    static void testGetProcessInstanceWorkitemByTargetIdAndStatus() {
        dataSetup();
        Apttus_Proposal__Proposal__c budgetRecord = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        /*Commented under LC-11457 to deactivate approval process
        Approval.ProcessSubmitRequest request= new Approval.ProcessSubmitRequest();
        request.setObjectId(budgetRecord.Id);
        request.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        Approval.ProcessResult result = Approval.process(request);*/
        
        Test.startTest();
            List<ProcessInstanceWorkitem> resultList = new SLT_ProcessInstanceWorkitem().getProcessInstanceWorkitemByTargetIdAndStatus(new Set<Id>{budgetRecord.Id}, CON_CPQ.PENDING,
            	new Set<String>{CON_CPQ.ID, CON_CPQ.PROCESS_INSTANCE_TARGET_OBEJCT_ID});
        Test.stopTest();
        
        //System.assert(resultList.size() > 0, 'Result should not be empty');
    }
    
    @IsTest
    static void testGetProcessInstanceWorkitemsByTargetIdAndStatus() {
        dataSetup();
        Apttus_Proposal__Proposal__c budgetRecord = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        /*Commented under LC-11457 to deactivate approval process
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(budgetRecord.Id);
        request.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        Approval.ProcessResult result = Approval.process(request);*/
        
        Test.startTest();
            List<ProcessInstanceWorkitem> resultList = new SLT_ProcessInstanceWorkitem().getProcessInstanceWorkitemsByTargetIdAndStatus(new Set<Id>{budgetRecord.Id}, CON_CPQ.PENDING);
        Test.stopTest();
        
        //System.assert(resultList.size() > 0, 'Result should not be empty');
    }
}