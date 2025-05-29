@isTest
private class TST_ContractMgmt_ComMethodClass {
	private static testMethod void testModifySearchStrShouldReturnModifiedStrWhenInputContainsStar(){
        String searchByString = 'Test\'s*';
        
        Test.startTest();
        	String modifiedSearchByString = ContractMgmt_ComMethodClass.modifySearchStr(searchByString);
        Test.stopTest();
        
        System.assertEquals(true,modifiedSearchByString.contains('%'),'The returned string does not contain % sign');
        System.assertNotEquals(null,modifiedSearchByString,'The returned string is null, when not expected');
    }
    
    private static testMethod void testModifySearchStrShouldReturnModifiedStrWhenInputDoesContainsStar(){
        String searchByString = 'Test';
        
        Test.startTest();
        	String modifiedSearchByString = ContractMgmt_ComMethodClass.modifySearchStr(searchByString);
        Test.stopTest();
        
        System.assertEquals('Test%',modifiedSearchByString,'The returned string does not match with the expected string');
    }
}