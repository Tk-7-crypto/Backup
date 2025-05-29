/**
 * This test class is used to test all methods in CON_CRM_OpportunityRenewals.
 * version : 1.0
 */
@isTest
private class TST_CON_CRM_OpportunityRenewals {

    /**
     * This method is testing all StageName constant in CON_CRM_OpportunityRenewals
     */
    static testMethod void testConstants() {
      
        Test.startTest();
            String noChange = CON_CRM_OpportunityRenewals.NO_CHANGE_STR;
            String changeDetail = CON_CRM_OpportunityRenewals.CHANGE_DETAIL_STR;
            String noRenew = CON_CRM_OpportunityRenewals.NO_RENEW_STR;
            String needsNoRenewReason = CON_CRM_OpportunityRenewals.NEEDS_NO_RENEW_REASON_STR;
            String queued = CON_CRM_OpportunityRenewals.QUEUED_STATUS_STR;
            String cloned = CON_CRM_OpportunityRenewals.CLONED_STATUS_STR;
            String awaitingDetails = CON_CRM_OpportunityRenewals.AW_DETAILS_STATUS_STR;
            String noRenewStatus = CON_CRM_OpportunityRenewals.NO_RENEW_STATUS_STR;
            String errord = CON_CRM_OpportunityRenewals.ERROR_STATUS_STR;
            String stage1 = CON_CRM_OpportunityRenewals.OPP_STAGE_1;
            String stage2 = CON_CRM_OpportunityRenewals.OPP_STAGE_2;
            String stage3 = CON_CRM_OpportunityRenewals.OPP_STAGE_3;
            String stage4 = CON_CRM_OpportunityRenewals.OPP_STAGE_4;
            String stage5 = CON_CRM_OpportunityRenewals.OPP_STAGE_5;
            String stage6a = CON_CRM_OpportunityRenewals.OPP_STAGE_6A;
            String stage6b = CON_CRM_OpportunityRenewals.OPP_STAGE_6B;
            String stageInHand = CON_CRM_OpportunityRenewals.OPP_STAGE_IN_HAND ;
            Boolean isDebugEnabled = CON_CRM_OpportunityRenewals.IS_DEBUG_ENABLED ;
        Test.stopTest();
    }
}