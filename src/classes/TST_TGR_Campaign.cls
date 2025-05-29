/**
 * This test class is used to test all methods in Campaign trigger.
 * version : 1.0
 */
@isTest
public class TST_TGR_Campaign {
    static testMethod void testm1() {
        Campaign cmp = UTL_TestData.createCampaign();
        insert cmp;
        delete cmp;
    }
}