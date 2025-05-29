@IsTest
private class TST_SCH_CSM_UserOutOfOfficeMessage {
    @IsTest
    private static void testBatch() {
        List<User> listOfUser = UTL_TestData.createUser(CON_CSM.S_PROFILENAME, 2);
        listOfUser[0].LastName = 'Test User 1';
        listOfUser[1].LastName = 'Test User 2';
        insert listOfUser;
        
        OutOfOffice outOfOfficeInstance = new OutOfOffice(UserId = listOfUser[0].Id, isEnabled = true, StartDate = Date.today(), EndDate = Date.today(), Message = 'Test1');
        insert new List<OutOfOffice>{outOfOfficeInstance};
        
        Test.startTest();
            SCH_CSM_UserOutOfOfficeMessage btchQueue = new SCH_CSM_UserOutOfOfficeMessage();
            String sch = '0 0 * * * ?';
            String jobID = System.schedule('SCH_CSM_UserOutOfOfficeMessage_Batch_Test', sch, btchQueue);
        Test.stopTest();
    }
}