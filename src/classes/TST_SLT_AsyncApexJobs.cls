/**
* Test Class for SLT_AsyncApexJobs.
* version : 1.0
*/
@isTest
private class TST_SLT_AsyncApexJobs {

    @isTest
    static void testAsyncApexData() {

        Set<Id> jobIds = new Map<Id,AsyncApexJob>([Select id from AsyncApexJob limit 1]).keyset();
        Set<String> fieldSet = new Set<String>{ 'Id', 'ApexClassId', 'ApexClass.Name' };

        // Call the selector method
        SLT_AsyncApexJobs selector = new SLT_AsyncApexJobs();
        Map<Id, AsyncApexJob> result = new Map<Id, AsyncApexJob>();
        Test.startTest();
        result = selector.Asyncdata(jobIds, fieldSet);
        Test.stopTest();
		
        System.assertEquals(0, result.size(), 'No Records Found');

    }

}