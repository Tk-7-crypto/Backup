@isTest 
public class TST_PSA_CreateSdRun {
    @testSetup static void setup() {
        UTL_PSA_TestData.createSdRun();
    }
    
    
    testmethod static void testAutoPopulatedFieldData() {
        Test.startTest();
        pse__Proj__c prjRec = [select id from pse__Proj__c where Service_Line__r.name =  'Signal Management' limit 1];
        Map<string,string> AutoPopulatedFieldDataMap = PSA_CreateSdRun.autoPopulatedFieldData(prjRec.id);
        Test.stopTest();
        
    }
    testmethod static void testHasSDRunPermissionCreate() {
        Test.startTest();
        pse__Proj__c prjRec = [select id from pse__Proj__c limit 1];
        boolean result = PSA_CreateSdRun.hasSDRunPermissionCreate(prjRec.id);
        Test.stopTest();
        
    }
    testmethod static void testHasSDRunPermissionView() {
        Test.startTest();
        SD_Runs__c sdRec = [select id from SD_Runs__c limit 1];
        boolean result = PSA_CreateSdRun.hasSDRunPermissionView(sdRec.id);
        Test.stopTest();
        
    }
    testmethod static void testSdRunProjectIDView() {
        Test.startTest();
        SD_Runs__c sdRec = [select id from SD_Runs__c limit 1];
        string projID = PSA_CreateSdRun.sDRunProjectIDView(sdRec.id);
        Test.stopTest();
        
    } 
    testmethod static void testGetTargetRecords() {
        Test.startTest();
        pse__Proj__c prjRec = [select id from pse__Proj__c limit 1];
        List<Target__c> targetList = PSA_CreateSdRun.getTargetRecords(prjRec.id);
        Test.stopTest();
        
    }  
    testmethod static void testHasRDSAdminPermission() {
        Test.startTest();
        SD_Runs__c sdRec = [select id from SD_Runs__c limit 1];
        Boolean hasPermission = PSA_CreateSdRun.hasRDSAdminPermission(sdRec.id);
        Test.stopTest();
        
    }
    
    testmethod static void testcloneSDRec(){
        Test.startTest();
        SD_Runs__c sdRec = [select id from SD_Runs__c limit 1];
        Map<String, String> cloneMap = new Map<String, String>();
        cloneMap.put('Last_SD_Run_for_Product__c','true');
        cloneMap.put('Data_Review_Period_End_Date__c',(Date.today().format()));
        String sdRecCloned = PSA_CreateSdRun.cloneSDRec(sdRec.Id,cloneMap);
        Test.stopTest();
    }
    testmethod static void testgetFreqDtForSDRunClone(){
        Test.startTest();
        SD_Runs__c sdRec = [select id from SD_Runs__c limit 1];
        Map<string,object> valsMap = new Map<string,object>();
        valsMap = PSA_CreateSdRun.getFreqDtForSDRunClone(sdRec.Id);
        Test.stopTest();
    }   
}