@isTest
public class TST_CNT_PSA_PSSF {
    
    @testSetup static void setup() {
        UTL_PSA_TestData.createPSSF();
    }
    
    testmethod static void testAutoPopulatedFieldData() {
        Test.startTest();
        pse__Proj__c prjRec = [select id from pse__Proj__c limit 1];
        Map<string,string> AutoPopulatedFieldDataMap = CNT_PSA_PSSF.autoPopulatedFieldData(prjRec.id);
        Test.stopTest();
        
    }
    testmethod static void testIsSignalManagementProject() {
        Test.startTest();
        pse__Proj__c prjRec = [select id from pse__Proj__c limit 1];
        boolean result = CNT_PSA_PSSF.isSignalManagementProject(prjRec.id);
        Test.stopTest();
    }
    testmethod static void testPssfParentRecId() {
        Test.startTest();
        pse__Proj__c prjRec = [select id from pse__Proj__c limit 1];
        String result = CNT_PSA_PSSF.pssfParentRecId(prjRec.id);
        Test.stopTest();
    }
    testmethod static void testHasEditPermission() {
        Test.startTest();
        pse__Proj__c prjRec = [select id from pse__Proj__c limit 1];
        Boolean result = CNT_PSA_PSSF.hasEditPermission();
        Test.stopTest();
    }
    testmethod static void testFetchRelatedRecords() {
        Test.startTest();
        PSSF__c pssfRec = [select id from PSSF__c where PSSF_Version__c = 'Draft' limit 1];
        Map<string,string> result = CNT_PSA_PSSF.fetchRelatedRecords(pssfRec.id);
        Test.stopTest();
    }
    testmethod static void testGetFocusFieldMap() {
        Test.startTest();
        //PSSF__c pssfRec = [select id from PSSF__c where PSSF_Version__c = 'Draft' limit 1];
        Map<string,string> result = CNT_PSA_PSSF.getFocusFieldMap();
        Test.stopTest();
    }
    /*testmethod static void testfetchVersionOfPSSF() {
        Test.startTest();
        pse__Proj__c prjRec = [select id from pse__Proj__c limit 1];
        String result = CNT_PSA_PSSF.fetchVersionOfPSSF(prjRec.id);
        Test.stopTest();
    }*/
    testmethod static void testfetchProjectId() {
        Test.startTest();
        PSSF__c pssfRec = [select id,Project_Name__c from PSSF__c where PSSF_Version__c = 'Draft' limit 1];
        String result = CNT_PSA_PSSF.fetchProjectId(pssfRec.id);
        Test.stopTest();
    }
    testmethod static void getAllPSSFParentRecord() {
        Test.startTest();
        pse__Proj__c prjRec = [select id from pse__Proj__c limit 1];
        list<PSSF__c> pssfList = CNT_PSA_PSSF.getAllPSSFParentRecord(prjRec.id);
        Test.stopTest();
    }
    testmethod static void testdeleteHistoryRecord() {
        Test.startTest();
        PSSF__c pssfRec = [select id from PSSF__c where Is_History_of_Changes_Record__c = true limit 1];
        PSSF__c pssfParRec = [select id from PSSF__c where PSSF_Parent__c = null limit 1];
        list<Id> ppsfIdList =  new List<Id>();
        ppsfIdList.add(pssfRec.Id);
        list<PSSF__c> ppsfRecList =  CNT_PSA_PSSF.deleteHistoryRecord(ppsfIdList,pssfParRec.Id);
        
        Test.stopTest();
    }
    testmethod static void testHasRDSAdminPermission() {
        Test.startTest();
        PSSF__c pssfRec = [select id,Project_Name__c from PSSF__c where PSSF_Version__c = 'Draft' limit 1];
        Boolean hasPermission = CNT_PSA_PSSF.hasRDSAdminPermission(pssfRec.id);
        Test.stopTest();
        
    }
} 
