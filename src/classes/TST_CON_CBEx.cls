/**
 * This test class is used to test all methods in CON_CBEx.
 * version : 1.0
 */
@isTest
private class TST_CON_CBEx {
    /**
     * This method is testing all StageName constant in CON_CBEx
     */
    static testMethod void testStageConstant() {
        
        Test.startTest();
            String rdsUser = CON_CBEx.RDS_User;
            String admin = CON_CBEx.administrator;
        	String tst = CON_CBEx.administratorSupport;
        	tst = CON_CBEx.Marketing_User_IQVIA;
        	tst = CON_CBEx.ACCOUNT_OBJECT;
        	tst = CON_CBEx.OPPORTUNITY_OBJECT;
        	tst = CON_CBEx.BIDHISTORY_OBJECT;
        	tst = CON_CBEx.RESOURCE_REQUEST_OBJECT;
        	tst = CON_CBEx.MULESOFT_SYNC_STATUS_PENDING;
        Test.stopTest();
        System.assertEquals('RDS User', rdsUser);
        System.assertEquals('Administrator', admin);
        
    }

}