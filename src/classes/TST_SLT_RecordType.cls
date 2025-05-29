/*
* Version       : 1.0
* Description   : This test class is used for Select RecordType
*/
@isTest
private class TST_SLT_RecordType {
    @IsTest
    private static void testGettRecordType() {
        SLT_RecordType sltRecordType = new SLT_RecordType();
        
        Test.startTest();
            List<RecordType> result = sltRecordType.getRecordType(CON_CSM_OneKey.S_HCP_ONE_KEY_REQUEST);
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'record type is not fetched');
        System.assertEquals(1, result.size(), 'record type is not fetched');
    }
    
    @IsTest
    private static void testGettRecordTypeBySObjectType() {
        SLT_RecordType sltRecordType = new SLT_RecordType();
        Test.startTest();
            List<RecordType> result = sltRecordType.getRecordTypesBySObjectType('Apttus_Proposal__Proposal__c', new List<String>{CON_CPQ.TECH_SOLUTION});
        Test.stopTest();
        System.assertEquals(1, result.size(), 'record type is not fetched');
    }
}