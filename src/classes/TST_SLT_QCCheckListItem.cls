@isTest
private class TST_SLT_QCCheckListItem {

    static QC_Check_List_Item__c setQCCheckListItemData(String typeOfProcessStep, String migrationId){
    
        QC_Check_List_Item__c qcCheckListItem = UTL_TestData.createQCCheckListItem();
        qcCheckListItem.Type_Of_Process_Step__c = typeOfProcessStep;
        qcCheckListItem.Record_Type__c = CON_CPQ.INITIAL_BID_REBID;
        qcCheckListItem.Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT;
        qcCheckListItem.Migration_Id__c = migrationId;
        insert qcCheckListItem;
        return qcCheckListItem;
    }

    @isTest
    static void testSelectQCCheckListItemById() {

        QC_Check_List_Item__c qcCheckListItem = setQCCheckListItemData('Draft', 'QCLI-001');
            Set<Id> idSet = new Set<Id>{qcCheckListItem.Id};

        Test.startTest();
            List<QC_Check_List_Item__c> qcSelfCheckDraftList = new SLT_QCCheckListItem().selectById(idSet);
        Test.stopTest();

        system.assertEquals(1, qcSelfCheckDraftList.size(), 'Should return one Qc Check List Item');
    }

    @isTest
    static void testGetQCCheckListItemByProcessStepBidTypeRecordType() {

        QC_Check_List_Item__c qcCheckListItem = setQCCheckListItemData('Draft', 'QCLI-002');
        Set<Id> idSet = new Set<Id>{qcCheckListItem.Id};
        Set<String> qcFieldSet = new Set<String>{CON_CPQ.Id, CON_CPQ.RECORDTYPE, CON_CPQ.TYPE, CON_CPQ.QUESTION, CON_CPQ.GUIDELINES, 
            CON_CPQ.TYPE_OF_PROPOSAL};

        Test.startTest();
            List<QC_Check_List_Item__c> qcSelfCheckDraftList = new SLT_QCCheckListItem().getQCCheckListItemByProcessStepBidTypeRecordType(CON_CPQ.INITIAL_BID_REBID, 
                qcFieldSet, CON_CPQ.DRAFT, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT);
        Test.stopTest();

        system.assertEquals(1, qcSelfCheckDraftList.size(), 'Should return one Qc Check List Item');
    }

    @isTest
    static void testGetQCCheckListItemByRecordType() {

        QC_Check_List_Item__c qcCheckListItem = setQCCheckListItemData('Draft', 'QCLI-003');
        Set<Id> idSet = new Set<Id>{qcCheckListItem.Id};
        Set<String> qcFieldSet = new Set<String>{CON_CPQ.Id, CON_CPQ.RECORDTYPE, CON_CPQ.TYPE, CON_CPQ.QUESTION, CON_CPQ.GUIDELINES, 
            CON_CPQ.TYPE_OF_PROPOSAL};

        Test.startTest();
            List<QC_Check_List_Item__c> qcSelfCheckDraftList = new SLT_QCCheckListItem().getQCCheckListItemByRecordType(CON_CPQ.INITIAL_BID_REBID, qcFieldSet);
        Test.stopTest();

        system.assertEquals(1, qcSelfCheckDraftList.size(), 'Should return one Qc Check List Item');
    }
    
    @isTest
    static void testGetQCCheckListItemForBudget() 
    {		
        QC_Check_List_Item__c qcCheckListItem = UTL_TestData.createQCCheckListItem();
        qcCheckListItem.Opportunity_Type__c = CON_CPQ.OPPORTUNITY_TYPE_FSP;
        qcCheckListItem.Budget_Type__c = CON_CPQ.INITIAL;
        qcCheckListItem.Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT;
        qcCheckListItem.Stage__c = CON_CPQ.DRAFT;
        qcCheckListItem.Migration_Id__c = 'QCLI-011';
        insert qcCheckListItem;

        Set<String> qcFieldSet = new Set<String>{CON_CPQ.Id, CON_CPQ.RECORDTYPE, CON_CPQ.TYPE, CON_CPQ.QUESTION, CON_CPQ.GUIDELINES, 
            CON_CPQ.TYPE_OF_PROPOSAL};

        Test.startTest();
            List<QC_Check_List_Item__c> qcSelfCheckList = new SLT_QCCheckListItem().getQCCheckListItemForBudget(qcFieldSet,CON_CPQ.OPPORTUNITY_TYPE_FSP,
            	CON_CPQ.INITIAL,CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT,CON_CPQ.DRAFT);
        Test.stopTest();

        system.assertEquals(1, qcSelfCheckList.size(), 'Should return one Qc Check List Item');
    }
    
    @isTest
    static void testGetQCCheckListItemForBudgetFiltered() 
    {		
        QC_Check_List_Item__c qcCheckListItem = UTL_TestData.createQCCheckListItem();
        qcCheckListItem.Opportunity_Type__c = CON_CPQ.OPPORTUNITY_TYPE_FSP;
        qcCheckListItem.Budget_Type__c = CON_CPQ.INITIAL;
        qcCheckListItem.Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT;
        qcCheckListItem.Stage__c = CON_CPQ.DRAFT;
        qcCheckListItem.Filter__c = CON_CPQ.PS;
        qcCheckListItem.Migration_Id__c = 'QCLI-010';
        insert qcCheckListItem;

        Set<String> qcFieldSet = new Set<String>{CON_CPQ.Id, CON_CPQ.RECORDTYPE, CON_CPQ.TYPE, CON_CPQ.QUESTION, CON_CPQ.GUIDELINES, 
            CON_CPQ.TYPE_OF_PROPOSAL};

        Test.startTest();
            List<QC_Check_List_Item__c> qcSelfCheckList = new SLT_QCCheckListItem().getQCCheckListItemForBudgetFiltered(qcFieldSet,CON_CPQ.OPPORTUNITY_TYPE_FSP,
            	CON_CPQ.INITIAL,CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT,CON_CPQ.DRAFT,CON_CPQ.PS);
        Test.stopTest();

        system.assertEquals(1, qcSelfCheckList.size(), 'Should return one Qc Check List Item');
    }
}
