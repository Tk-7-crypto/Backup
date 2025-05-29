@IsTest
private class TST_BCH_CSM_UserOutOfOfficeMessage {
    
    @IsTest
    private static void testBatch() {
        List<User> listOfUser = UTL_TestData.createUser(CON_CSM.S_PROFILENAME, 2);
        listOfUser[0].LastName = 'Test User 1';
        listOfUser[1].LastName = 'Test User 2';
        insert listOfUser;
        
        OutOfOffice outOfOfficeInstance = new OutOfOffice(UserId = listOfUser[0].Id, isEnabled = true, StartDate = Date.today(), EndDate = Date.today(), Message = 'Test1');
        OutOfOffice outOfOfficeRecord = new OutOfOffice(UserId = listOfUser[1].Id, isEnabled = true, StartDate = Date.today(), EndDate = Date.today().addDays(1), Message = 'Test2');        
        insert new List<OutOfOffice>{outOfOfficeRecord, outOfOfficeInstance};
        
            system.debug('jjj = '+[SELECT Id, User.Name, Message FROM OutOFOffice]);
        Test.startTest();
            BCH_CSM_UserOutOfOfficeMessage batch = new BCH_CSM_UserOutOfOfficeMessage();
            Id batchId = Database.executeBatch(batch, 2);
        Test.stopTest();
        
		String testUserName = [SELECT Id, LastName FROM User WHERE Id =: listOfUser[0].Id].LastName;    
		String userLastName = [SELECT Id, LastName FROM User WHERE Id =: listOfUser[1].Id].LastName;    
        
        System.assertEquals(false, testUserName.contains(' (Test1)'), 'Last Name should be updated');
        System.assertEquals(false, userLastName.contains(' (Test2)'), 'Last Name should be updated');
        System.abortJob(batchId);
    }
}