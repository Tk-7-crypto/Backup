@istest
public class TST_SLT_Journals_Main_Catalogue {
    @testSetup
    static void dataSetup() {
        Journals_Main_Catalogue__c main_Journal_catalog=UTL_PSA_TestData.createJournalMainCatalogue();
       	insert main_Journal_catalog;
    }
	@isTest
    static void testGetSObjectFieldList() {
        Test.startTest();
        List<Schema.SObjectFIeld> fields = new SLT_Journals_Main_Catalogue(true,true).getSObjectFieldList();
        Test.stopTest();
        System.assertNotEquals(0,fields.size());
    }
    @isTest
    static void testgetMainJournalCatalog() {
        Set<String> fieldSet=new Set<String>{'Journal_Name__c','Name'};
        Test.startTest();
        List<Journals_Main_Catalogue__c> mainJournalCatalog = new SLT_Journals_Main_Catalogue().getMainJournalCatalog(fieldSet);
        Test.stopTest();

        System.assertNotEquals(0,mainJournalCatalog.size());
    }
    @isTest
    static void testgetJournalsMainCatalogueFromIds() {
        Journals_Main_Catalogue__c journalRecord = [Select id,Name from Journals_Main_Catalogue__c limit 1];
        set<String> setJournalRecordId = new set<String>();
        setJournalRecordId.add(journalRecord.Name);
        Test.startTest();
        List<Journals_Main_Catalogue__c> journalsMainCatalogueList = new SLT_Journals_Main_Catalogue().getJournalsMainCatalogueFromIds(setJournalRecordId, new Set<String>{'Id','Name','Country__c', 'Journal_Name__c','URL__c' ,'Periodicity__c','Regulatory_requirement__c',
            'Subscription__c','Paper_Journal__c','Therapeutic_Area__c'} );
        Test.stopTest();
        System.assertEquals(1,journalsMainCatalogueList.size());
    }
}
