/*
 * Version       : 1.0
 * Description   : Test Class for TST_SLT_PSA_ProjectCreationValidStage
 */

@isTest
private class TST_SLT_PSA_ProjectCreationValidStage {

    /**
     * This method used to test set up type of sobject
     * @return  Schema.SObjectType
     */

    @IsTest
    static void testGetSObjectType () {
        Test.startTest();
        SLT_PSA_ProjectCreationValidStage selector = new SLT_PSA_ProjectCreationValidStage();
        Schema.SObjectType ss= selector.getSObjectType();
        Test.stopTest();
        System.assertEquals('PSA_ProjectCreationValidStage__mdt', String.valueOf(ss));
    }

    /**
     * This method will get a list of all the Stages entered in the metadata table
     */
     @isTest
     static void testSelectValidStages(){
         Test.startTest();
         SLT_PSA_ProjectCreationValidStage selector = new SLT_PSA_ProjectCreationValidStage();
         List<String> stages = selector.selectValidStages();
         Test.stopTest();
         System.assertNotEquals(0, stages.size());
     }
}