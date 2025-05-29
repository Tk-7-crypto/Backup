/**
 * This test class is used to test all methods in CON_PEP.
 * version : 1.0
 */
@isTest
private class TST_CON_PEP { 
    
    @isTest
    public static void testConstants(){
        Test.startTest(); 
            String prmProfileName = CON_PEP.S_P_PEP_COMMUNITY;
            String partnerPortal = CON_PEP.S_PARTNER_PORTAL;
            String portalMgr = CON_PEP.S_PEP_MANAGER;
            String portalConslt = CON_PEP.S_PEP_CONSULTANT;
            String pepQueue = CON_PEP.S_PEP_QUEUE;
            String pepRoleAllMgr = CON_PEP.ALLIANCE_MANAGER;
            String pepManualShare = CON_PEP.S_PEP_MANUAL_SHARE;
            String pepAccessEdit = CON_PEP.S_PEP_ACCESS_EDIT;
            String pepAccessRead = CON_PEP.S_PEP_ACCESS_READ;
            String pepOrgWideAdd = CON_PEP.S_PEP_ORG_WIDE_ADD_NO_REPLY;
            String pepLeadReg = CON_PEP.S_PEP_LD_STATUS_REGISTERED;
            String pepLeadConv = CON_PEP.S_PEP_LD_STATUS_CONVERTED;
            String pepLeadRej = CON_PEP.S_PEP_LD_STATUS_REJECTED;
            String pepLeadNewtemp = CON_PEP.S_PEP_LD_DEV_NAME_CREATION;
            String pepLeadConvTemp = CON_PEP.S_PEP_LD_DEV_NAME_CONVERTED;
            String pepLeadRejTemp = CON_PEP.S_PEP_LD_DEV_NAME_REJECTED ;
            String pepLeadRecType = CON_PEP.S_PEP_LED_RECORDTYPE;
            String pepContractRecType = CON_PEP.S_PEP_CTR_RECORDTYPE ;
            String pepCTREmailTemp = CON_PEP.S_PEP_CTR_DEV_NAME_RENEWALNOTIF;
            String pepContractActive = CON_PEP.S_PEP_ACTIVE_STATUS ;            
        Test.stopTest();
        System.assertEquals('Partner Portal', partnerPortal);
        System.assertEquals('PRM Community User', prmProfileName);
    }
}