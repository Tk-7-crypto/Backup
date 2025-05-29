@isTest 
public with sharing class TST_SLT_BoxParentFolder {
    @testSetup
    static void dataSetup() {

    }
    @IsTest
    static void testBoxParentFolder() {
        Test.startTest();
        Box_Parent_Folder__mdt rootFolder = new SLT_BoxParentFolder().getParentFolder('Bid History');
        Test.stopTest();
        System.assertEquals(rootFolder.Folder_Name__c, 'Biotech Proposal Folder');
    }
}