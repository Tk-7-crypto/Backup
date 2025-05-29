/*
 * Version       : 1.0
 * Description   : This test class is used for Select OpportunitySplitType
 */
@isTest
private class TST_SLT_OpportunitySplitType {

    /**
     * This method used to Select OpportunitySplitType by it's name
     */    
    @IsTest
    static void testSelectByOppSplitTypeName() {
        Test.startTest();
            List<OpportunitySplitType> opportunitySplitTypeList = new SLT_OpportunitySplitType().selectByOppSplitTypeName(CON_CRM.SPLIT_TYPE_NAME);
        Test.stopTest(); 
        Integer expected = 1;
        Integer actual = opportunitySplitTypeList.size();
        System.assertEquals(expected, actual);
    }
}