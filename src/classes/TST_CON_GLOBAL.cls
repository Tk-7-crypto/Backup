/**
 * This test class is used to test all methods in CON_GLOBAL.
 * version : 1.0
 */
@isTest
private class TST_CON_GLOBAL {
    /**
     * This method is testing all StageName constant in CON_CRM
     */
    static testMethod void testStageConstant() {
        Test.startTest();
            Double nov2018Release = CON_GLOBAL.RELEASE_NOV_2018;
            Double dec2018Release = CON_GLOBAL.RELEASE_Dec_2018;
            Double jan2019Release = CON_GLOBAL.RELEASE_JAN_2019;
            Double feb2019Release = CON_GLOBAL.RELEASE_FEB_2019;
            Double mar2019Release = CON_GLOBAL.RELEASE_MAR_2019;
            Double apr2019Release = CON_GLOBAL.RELEASE_APR_2019;
            Double may2019Release = CON_GLOBAL.RELEASE_MAY_2019;
            Double jun2019Release = CON_GLOBAL.RELEASE_JUN_2019;
            Double jul2019Release = CON_GLOBAL.RELEASE_JUL_2019;
            Double aug2019Release = CON_GLOBAL.RELEASE_AUG_2019;
            Double sep2019Release = CON_GLOBAL.RELEASE_SEP_2019;
            Double oct2019Release = CON_GLOBAL.RELEASE_OCT_2019;
            Double nov2019Release = CON_GLOBAL.RELEASE_NOV_2019;
            Double dec2019Release = CON_GLOBAL.RELEASE_DEC_2019;
            Double sep2020Release = CON_GLOBAL.RELEASE_SEP_2020;
        Test.stopTest();
        System.assertEquals(2018.11, nov2018Release);
        System.assertEquals(2018.12, dec2018Release);
        System.assertEquals(2019.01, jan2019Release);
        System.assertEquals(2019.02, feb2019Release);
        System.assertEquals(2019.03, mar2019Release);
        System.assertEquals(2019.04, apr2019Release);
        System.assertEquals(2019.05, may2019Release);
        System.assertEquals(2019.06, jun2019Release);
        System.assertEquals(2019.07, jul2019Release);
        System.assertEquals(2019.08, aug2019Release);
        System.assertEquals(2019.09, sep2019Release);
        System.assertEquals(2019.10, oct2019Release);
        System.assertEquals(2019.11, nov2019Release);
        System.assertEquals(2019.12, dec2019Release);
        System.assertEquals(2020.09, sep2020Release);
    }
}