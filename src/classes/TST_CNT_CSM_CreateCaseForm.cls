@IsTest
private class TST_CNT_CSM_CreateCaseForm {
    @IsTest
    private static void testGetRecordTypeValues() {
    
        Test.startTest();
            List<EXT_CSM_CheckboxDetails> recordTypes = CNT_CSM_CreateCaseForm.getRecordTypeValues();
        Test.stopTest();
        
        System.assertEquals(true, recordTypes.size() > 0, 'Should return case record types');
    }
    
    @IsTest
    private static void testGetAccountByContact() {
        Account acct = CSM_Util.createAccount();
        insert acct;
        Contact con = CSM_Util.createContact(acct.Id, 'TestContact');
        insert con;
        Test.startTest();
            String accountId = CNT_CSM_CreateCaseForm.getAccountByContact(con.Id);
        Test.stopTest();
        System.assertEquals(acct.Id, accountId, 'Should return account id');
    }
}
