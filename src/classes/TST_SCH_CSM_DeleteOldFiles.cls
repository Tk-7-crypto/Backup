@IsTest
private class TST_SCH_CSM_DeleteOldFiles {
    @IsTest
    private static void testBatch() {
        Test.startTest();
        SCH_CSM_DeleteOldFiles btchQueue = new SCH_CSM_DeleteOldFiles();
        String sch = '0 00 10 * * ?';
        String jobID = System.schedule('SCH_CSM_DeleteOldFiles_Batch_Test', sch, btchQueue);
        Test.stopTest();
    }
    
}