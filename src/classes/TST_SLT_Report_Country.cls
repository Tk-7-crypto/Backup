/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Date_Offset
 */
@isTest
private class TST_SLT_Report_Country {

    @isTest
    static void testGetSObjectFieldList() {
        Test.startTest();
        List<Schema.SObjectFIeld> fields = new SLT_Report_Country().getSObjectFieldList();
        Test.stopTest();
        System.assertEquals(0,fields.size());
    }

    @isTest
    static void testgetReportCountriesByReport(){
        setupTestData();
        Test.startTest();
        Map<Id,List<Report_Country__c>> countryMap = new SLT_Report_Country().getReportCountriesByReport(new Set<Id>{ar.id});
        Test.stopTest();
        System.assertEquals(1,countryMap.keySet().size());
        System.assertEquals(1,countryMap.get(ar.Id).size());
    }

    private static Aggregate_Report__c ar;

    static void setupTestData(){
        RecordType recordId = [SELECT Id from RecordType where Name='General Report'];
        ar = new Aggregate_Report__c();
        ar.RecordTypeId = recordId.Id;
        insert ar;

        Report_Country__c rc = new Report_Country__c(
            Aggregate_Report__c=ar.Id,
            Country__c='AS'
        );
        insert rc;
    }
}