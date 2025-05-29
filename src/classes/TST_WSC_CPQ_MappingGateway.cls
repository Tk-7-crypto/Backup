@isTest
public class TST_WSC_CPQ_MappingGateway {
	@isTest static void testGet() {
        Test.startTest();
            WSC_CPQ_MappingGateway.handleGetRequest();
        Test.stopTest();
    }
    @isTest static void testPut() {
        Test.startTest();
            WSC_CPQ_MappingGateway.handlePutRequest('test', 'test');
        Test.stopTest();
    }
    @isTest static void testPost() {
        Test.startTest();
            WSC_CPQ_MappingGateway.handlePostRequest('test', 'test');
        Test.stopTest();
    }
    @isTest static void testPatch() {
        Test.startTest();
            WSC_CPQ_MappingGateway.handlePatchRequest();
        Test.stopTest();
    }
    @isTest static void testDelete() {
        Test.startTest();
            WSC_CPQ_MappingGateway.handleDeleteRequest();
        Test.stopTest();
    }
}