@isTest
private class TST_SLT_SharepointFile {
    @isTest
    private static void testSLTSharepointFileWithoutParameter(){
        Test.startTest();
            SLT_SharepointFile sltSharepoint = new SLT_SharepointFile();
        Test.stopTest();
        
        System.assertNotEquals(null,sltSharepoint, 'No SLT_Sharepoint Object Found');
    }
    
    @isTest
    private static void testSLTSharepointFileWithParameter(){
        Test.startTest();
            SLT_SharepointFile sltSharepoint = new SLT_SharepointFile(true, true);
        Test.stopTest();

        System.assertNotEquals(null, sltSharepoint, 'No SLT_Sharepoint Object Found');
    }

    @isTest
    private static void testSetSObjectFieldListShouldReturnFieldList(){
        Test.startTest();
            SLT_SharepointFile sltSharepoint = new SLT_SharepointFile();
            List<Schema.SObjectField> lstFields = sltSharepoint.getSObjectFieldList();
        Test.stopTest();

        System.assertNotEquals(null, lstFields, 'No List of Field Found');
    }

    @isTest
    private static void testGetSObjectTypeShouldReturnType(){
        Test.startTest();
            SLT_SharepointFile sltSharepoint = new SLT_SharepointFile();
            Schema.SObjectType sObjectType = sltSharepoint.getSObjectType();
        Test.stopTest();

        System.assertEquals('Sharepoint File', sObjectType.getDescribe().getLabel(), 'No Object Found Named: Sharepoint File');
    }

    @isTest
    private static void testSelectByIdShouldReturnValidObj(){
        Sharepoint_File__c objSharepointFile = TST_UTL_SharepointFactory.createSharepointFile(true);

        Test.startTest();
            SLT_SharepointFile sltSharepoint = new SLT_SharepointFile();
            List<Sharepoint_File__c> lstSharepointFile = sltSharepoint.selectById(new Set<Id>{objSharepointFile.Id});
        Test.stopTest();

        System.assertNotEquals(0, lstSharepointFile.size(), 'No Object Found Named: Sharepoint File');
    }

    @isTest
    private static void testGetSharepointFileByAgreementShouldReturnObject(){
        Sharepoint_File__c objSharepointFile = TST_UTL_SharepointFactory.createSharepointFile(true);
        
        Test.startTest();
            SLT_SharepointFile sltSharepoint = new SLT_SharepointFile();
            List<Sharepoint_File__c> lstSharepointFile = sltSharepoint.getSharepointFileByParentId(new Set<Id>{objSharepointFile.Parent_Id__c},1);
        Test.stopTest();

        System.assertNotEquals(0, lstSharepointFile.size(), 'No Object Found Named: Sharepoint File');
    }

    @isTest
    private static void testGetSharepointFileByAgreementShouldReturnObjectWithFolder() {
        Sharepoint_File__c objSharepointFile = TST_UTL_SharepointFactory.createSharepointFile(true);
        
        Test.startTest();
            SLT_SharepointFile sltSharepoint = new SLT_SharepointFile();
            List<Sharepoint_File__c> lstSharepointFile = sltSharepoint.getSharepointFileByParentIdAndFolder(
                new Set<Id>{objSharepointFile.Parent_Id__c}, 1, 'File_Url__c LIKE \'%test%\'');
        Test.stopTest();

        System.assertNotEquals(0, lstSharepointFile.size(), 'No Object Found Named: Sharepoint File');
    }
}