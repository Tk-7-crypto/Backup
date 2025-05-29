/*
 * Version       : 1.0
 * Description   : Test Class for SLT_SdRun
 */
@isTest
private class TST_SLT_SdRun {
    @testSetup static void setup() {
        UTL_PSA_TestData.createSdRun();
    }
    
    /**
     * This method used to get a Report Drug.
     */    
    @IsTest
    static void testgetReportDrugList() {
        Test.startTest();
        SD_Runs__c sdRec = [select id from SD_Runs__c limit 1];
        List<Schema.SObjectField> schema = new SLT_SdRun().getSObjectFieldList();
        Set<String> fieldSet =  new SLT_SdRun().getSObjectFieldSet();
        List<SD_Runs__c> sdRunList1 = new SLT_SdRun().getSdRunById(new Set<Id>{sdRec.id}, new Set<String>{'Project__c'} );
        List<SD_Runs__c> sdRunList2 = new SLT_SdRun(false).getSdRunById(new Set<Id>{sdRec.id}, new Set<String>{'Project__c'} );
        List<SD_Runs__c> sdRunList3 = new SLT_SdRun(false,false).getSdRunById(new Set<Id>{sdRec.id}, new Set<String>{'Project__c'} );
        List<SD_Runs__c> sdRunList5  = new SLT_SdRun(false,false).getLastCreatedSdRunRecord(new Set<String>{'Project__c'} );
        Map<Id, SD_Runs__c> sdRunMap = new SLT_SdRun(false,false).getSdRunMapBySdRunIds(new Set<Id>{sdRec.id}, new Set<String>{'Project__c'});
        pse__Proj__c projRec = [select id from pse__Proj__c where pse__Parent_Project__c != null];
        Test.stopTest();
        System.assertEquals(sdRunList1.size(), 1);
    }

}