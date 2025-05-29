@IsTest
private class TST_TGR_OutOfOffice {
    @testSetup
    static void setup() {
        List<User> listOfUser = UTL_TestData.createUser(CON_CSM.S_PROFILENAME, 2);
        listOfUser[0].LastName = 'Test TGR_OutOfOffice User 1';
        listOfUser[1].LastName = 'Test TGR_OutOfOffice User 2';
        insert listOfUser;
    }
    
    @IsTest
    private static void testUpdateUserNameWithMessageOnInsert() {
        User userRecord = [SELECT Id, LastName FROM User WHERE LastName = 'Test TGR_OutOfOffice User 1'][0];
        OutOfOffice outOfOfficeInstance = new OutOfOffice(UserId = userRecord.Id, isEnabled = true, StartDate = Date.today(), EndDate = Date.today(), Message = 'Test');
        
        Test.startTest();
            insert new List<OutOfOffice>{outOfOfficeInstance};
        Test.stopTest();
        
		String userLastName = [SELECT Id, LastName FROM User WHERE Id =: userRecord.Id].LastName;    
        
        System.assertEquals('Test TGR_OutOfOffice User 1 (Test)', userLastName, 'Last Name should be updated');
    }
    
    @IsTest
    private static void testUpdateUserNameWithMessageOnUpdate() {
        User userRecord = [SELECT Id, LastName FROM User WHERE LastName = 'Test TGR_OutOfOffice User 1'][0];
        OutOfOffice outOfOfficeInstance = new OutOfOffice(UserId = userRecord.Id, isEnabled = true, StartDate = Date.today(), EndDate = Date.today(), Message = 'Test');
        insert new List<OutOfOffice>{outOfOfficeInstance};
        outOfOfficeInstance.Message = 'Test Update';
        
        Test.startTest();
            update new List<OutOfOffice>{outOfOfficeInstance};
        Test.stopTest();
        
		String userLastName = [SELECT Id, LastName FROM User WHERE Id =: userRecord.Id].LastName;    
        
        System.assertEquals('Test TGR_OutOfOffice User 1 (Test Update)', userLastName, 'Last Name should be updated');
    }
    
    @IsTest
    private static void testUpdateUserNameWithMessageOnDelete() {
        User userRecord = [SELECT Id, LastName FROM User WHERE LastName = 'Test TGR_OutOfOffice User 1'][0];
        OutOfOffice outOfOfficeInstance = new OutOfOffice(UserId = userRecord.Id, isEnabled = true, StartDate = Date.today(), EndDate = Date.today(), Message = 'Test');
        insert new List<OutOfOffice>{outOfOfficeInstance};
            
        Test.startTest();
            delete new List<OutOfOffice>{ outOfOfficeInstance};
        Test.stopTest();
        
		String userLastName = [SELECT Id, LastName FROM User WHERE Id =: userRecord.Id].LastName;    
        
        System.assertEquals('Test TGR_OutOfOffice User 1', userLastName, 'Last Name should be updated');
    }
}