/**
 * This test class is used to test all methods in CON_CRM.
 * version : 1.0
 */
@isTest
private class TST_CON_CRM {

    /**
     * This method is testing all StageName constant in CON_CRM
     */
    static testMethod void testStageConstant() {
        Test.startTest();
            String stage1 = CON_CRM.IDENTIFYING_OPP_STAGE;
            String stage2 = CON_CRM.QUALIFYING_OPP_STAGE;
            String stage3 = CON_CRM.DEVELOPING_PROP_STAGE;
            String stage4 = CON_CRM.DELIVERING_PROP_STAGE;
            String stage5 = CON_CRM.FINALIZING_DEAL_STAGE;
            String stage6 = CON_CRM.RECEIVED_ATP_STAGE;
            String stage7 = CON_CRM.CLOSED_WON_STAGE;
            String stage8 = CON_CRM.CLOSED_LOST_STAGE;
            String stage9 = CON_CRM.IN_HAND_STAGE;
            String offeringGroupCodeGlobalRnd = CON_CRM.OFFERING_GROUP_CODE_GLOBAL_RND;
            String offeringGroupGlobalRnd = CON_CRM.OFFERING_GROUP_GLOBAL_RND; 
            String materialLevelProduct = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
            String oliApiName = CON_CRM.OPPORTUNITYLINEITEM_OBJECT_API;
            String olisApiName = CON_CRM.OPPORTUNITYLINEITEMSCHEDULE_OBJECT_API;
            String editlabel = CON_CRM.EDIT_LABEL;
            String createLabel = CON_CRM.CREATE_LABEL;
            String deleteLabel = CON_CRM.DELETE_LABEL;
            String opportunityObject = CON_CRM.OPPORTUNITY_OBJECT;
            String contactObject = CON_CRM.CONTACT_OBJECT;
            String accountObject = CON_CRM.ACCOUNT_OBJECT;
            String oppTerritoryField = CON_CRM.OPPORTUNITY_TERRITORY_FIELD_API;
            String actiontypeDelete =  CON_CRM.DELETE_LABEL;
            String actiontypeUpsert =  CON_CRM.UPSERT_LABEL;
            String groupNAME = CON_CRM.SUPER_CREDIT_CONTROL_ADMIN_GROUP;
        Test.stopTest();
        System.assertEquals('1. Identifying Opportunity', stage1);
        System.assertEquals('2. Qualifying Opportunity', stage2);
        System.assertEquals('3. Developing Proposal', stage3);
        System.assertEquals('4. Delivering Proposal', stage4);
        System.assertEquals('5. Finalizing Deal', stage5);
        System.assertEquals('6. Received ATP/LOI', stage6);
        System.assertEquals('7a. Closed Won', stage7);
        System.assertEquals('7b. Closed Lost', stage8);
        System.assertEquals('In-Hand', stage9);
        System.assertEquals('GPRDSX', offeringGroupCodeGlobalRnd);
        System.assertEquals('Research & Development Solutions', offeringGroupGlobalRnd);
        System.assertEquals('Material', materialLevelProduct);
        System.assertEquals('OpportunityLineItem', oliApiName);
        System.assertEquals('edit', editlabel);
        System.assertEquals('Delete', deleteLabel);
        System.assertEquals('create', createLabel);
        System.assertEquals('Opportunity', opportunityObject);
        System.assertEquals('Contact', contactObject);
        System.assertEquals('Account', accountObject);
        System.assertEquals('Territory__c', oppTerritoryField );
        System.assertEquals('Delete', actiontypeDelete);
        System.assertEquals('Upsert', actiontypeUpsert);
        System.assertEquals('Super Credit Control Admins', groupNAME);
    }
}