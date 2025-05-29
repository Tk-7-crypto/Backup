@isTest 
public with sharing class TST_SLT_BoxChildFolder {
    @testSetup
    static void dataSetup() {

    }
    @IsTest
    static void testBoxChildFolder() {
        Test.startTest();
        List<Box_Folder__mdt> childFolders = new SLT_BoxChildFolder().getChildFolders('Final_Agreement');
        Test.stopTest();
        Boolean expected = true;
        Boolean actual = childFolders.size() > 0 ;
        System.assertEquals(expected, actual);
    }
}