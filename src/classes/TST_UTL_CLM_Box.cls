@isTest
public class TST_UTL_CLM_Box {
    
    @testSetup
    static void dataSetup() {
        CLM_Configuration__c clmConfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmConfiguration.Box_End_Point__c = 'https://api.box.com/2.0/';
        insert clmConfiguration;
    }

    @isTest
    private static void testGetTotalFolderCountWhenSuccess() {
        String mockResponseBody = '{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files","created_at":null,'
            +'"modified_at":null,"description":"","size":0,"path_collection":{"total_count":0,"entries":[]},"created_by":{"type":"user","id":"","name":"","login":""},'
            +'"modified_by":{"type":"user","id":"14013138185","name":"ABC","login":"xyz@metacube.com"},"trashed_at":null,"purged_at":null,"content_created_at":null,'
            +'"content_modified_at":null,"owned_by":{"type":"user","id":"14013138185","name":"ABC","login":"xyz@metacube.com"},"shared_link":null,"folder_upload_email":null,'
            +'"parent":null,"item_status":"active","item_collection":{"total_count":1,"entries":[{"type":"folder","id":"103016339581","sequence_id":"1","etag":"1","name":"Salesforce Folder"}],'
            +'"offset":0,"limit":100,"order":[{"by":"type","direction":"ASC"},{"by":"name","direction":"ASC"}]}}';
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponseBody, 'OK', 200));
        
        Test.startTest();
            Integer totalCount =  UTL_CLM_Box.getTotalFolderCount('103016339581');
        Test.stopTest();    
        
        System.assertEquals(1, totalCount , 'The count of folder obtained should be 1');
    }
    
    @isTest
    private static void testCopyAllFoldersAndFilesFromContractToAgreementWhenSuccess() {
        String mockResponseBody = '{"type":"folder","id":"128836283233","sequence_id":"0","etag":"0","name":"Test Folder","created_at":"2020-12-29T21:17:56-08:00",'
            +'"modified_at":"2020-12-29T21:17:56-08:00","description":"","size":4263142,"path_collection":{"total_count":3,"entries":[{"type":"folder","id":"0","sequence_id":null,'
            +'"etag":null,"name":"All Files"},{"type":"folder","id":"103016339581","sequence_id":"1","etag":"1","name":"Salesforce Folder"},{"type":"folder","id":"104028912491","sequence_id":"1",'
            +'"etag":"1","name":"Agreements"}]},"created_by":{"type":"user","id":"14013138185","name":"ABC","login":"xyz@metacube.com"},"modified_by":{"type":"user","id":"14013138185","name":"ABC"}}';
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponseBody, 'OK', 201));
        
        Test.startTest();
            String result = UTL_CLM_Box.copyAllFoldersAndFilesFromContractToAgreement('103016339581', '213416339581', 'Test Folder');
        Test.stopTest();    
        
        System.assertNotEquals(null, result , 'The folder id of copied folder should not be null');
    } 
    
    @isTest
    private static void testDeleteAllFilesAndFoldersWhenSuccess() {
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(null, 'OK', 204));
        
        Test.startTest();
            Boolean result = UTL_CLM_Box.deleteAllFilesAndFolders('103016339581');
        Test.stopTest();    
        
        System.assertEquals(true, result , 'True is expected for successful deletion');
    }
    
    @isTest
    private static void testDeleteAllFilesAndFoldersWhenFailure() {
        String mockResponseBody = '{"type":"error","status":404,"code":"not_found","context_info":{"errors":[{"reason":"invalid_parameter","name":"item","message":'
            + 'Invalid value developers.box.comdocs #errors message":"Not Found","request_id":"b5ww51gpy7343xpw"}';
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponseBody, 'Not Found', 404));
        
        Test.startTest();
            Boolean result = UTL_CLM_Box.deleteAllFilesAndFolders('103016339581');
        Test.stopTest();    
        
        System.assertEquals(false, result , 'False is expected for failure in deletion');
    }
    
    @isTest
    private static void testCopyAllFoldersAndFilesFromContractToAgreementWhenFailure() {
        String mockResponseBody = '{"type":"error","status":409,"code":"item_name_in_use","context_info":{"conflicts":{"type":"folder","id":"136288576821","sequence_id":"0","etag":"0",'
            + '"name":"ZZA60166 - Bid 1"}},"help_url":"http:developers.box.com docs #errors","message":"Item with the same name already exists","request_id":"mq4mgvgpyh8fvlxt"}';     
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponseBody, 'item_name_in_use', 409));
        
        Test.startTest();
            String result = UTL_CLM_Box.copyAllFoldersAndFilesFromContractToAgreement('103016339581', '213416339581', 'Test Folder');
        Test.stopTest();    
        
        System.assertEquals(null, result , 'The folder id of copied folder should be null in case of api error');    
    }
    
    @isTest
    private static void testGetTotalFolderCountWhenFailure() {
        String mockResponseBody = '{"type":"error","status":404,"code":"trashed","help_url":"http:developers.box.comdocs#errors","message":"Item is trashed",'
            + '"request_id":"gebsrcgpyhmdbiga"}';
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponseBody, 'Item Not Found', 404));
        
        Test.startTest();
            Integer totalCount = UTL_CLM_Box.getTotalFolderCount('103016339581');
        Test.stopTest();    
        
        System.assertEquals(0, totalCount , 'The count of folder obtained should be 0 in case of failure');
    }
}