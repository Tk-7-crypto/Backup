@isTest(seeAllData = false)
public class TST_SLT_TPARequest {
    @isTest
    static void testSLT_TPARequest() {
        String testId = 'asedhnwaedqw345';
        String query = 'select id from TPA_Request__c';
        SLT_TPARequest.instance.selectByContactId(new Set<Id>(), new Set<String>());
        SLT_TPARequest.instance.queryLocatorTPARequestById(new Set<Id>(), new Set<String>());
        SLT_TPARequest.instance.getTPARequestById(new Set<Id>(), new Set<String>());
        SLT_TPARequest.instance.selectTPARequestWithAMAAndAgrAdditionalFieldData(new Set<String>(), new Set<String>(), 'name', 'asc');
        SLT_TPARequest.instance.queryLocatorTPARequest( 1);
        SLT_TPARequest.instance.queryLocatorTPARequest(query);
        SLT_TPARequest.instance.getTPARequests(query);
        SLT_TPARequest.instance.getTPARequests(query);
    }
}