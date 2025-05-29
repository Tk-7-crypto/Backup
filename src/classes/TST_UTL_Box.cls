@isTest
public class TST_UTL_Box {
    
     @testSetup
    static void dataSetup() {
        Box_End_Point__c boxEndPoint = new Box_End_Point__c();
        boxEndPoint.Name = 'Box End Point';
        boxEndPoint.End_Point__c = 'https://api.box.com';
        boxEndPoint.End_Point_for_Folders__c = 'https://api.box.com/2.0/';
        insert boxEndPoint;
    }

    @isTest
    static void testCopyAllFoldersAndFilesFromSourceToDestinationWhenSuccess() {
        String mockResponseBody = '{"type":"folder","id":"128836283233","sequence_id":"0","etag":"0","name":"Test Folder","created_at":"2020-12-29T21:17:56-08:00",'
            +'"modified_at":"2020-12-29T21:17:56-08:00","description":"","size":4263142,"path_collection":{"total_count":3,"entries":[{"type":"folder","id":"0","sequence_id":null,'
            +'"etag":null,"name":"All Files"},{"type":"folder","id":"103016339581","sequence_id":"1","etag":"1","name":"Salesforce Folder"},{"type":"folder","id":"104028912491","sequence_id":"1",'
            +'"etag":"1","name":"Agreements"}]},"created_by":{"type":"user","id":"14013138185","name":"ABC","login":"xyz@metacube.com"},"modified_by":{"type":"user","id":"14013138185","name":"ABC"}}';
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponseBody, 'OK', 201));
        
        Test.startTest();
            String result = UTL_Box.copyAllFoldersAndFilesFromSourceToDestination('103016339581', '213416339581', 'Test Folder');
        Test.stopTest();    
        
        System.assertNotEquals(null, result , 'The folder id of copied folder should not be null');
    } 
    
    @isTest
    static void testDeleteAllFilesAndFoldersWhenSuccess() {
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(null, 'OK', 204));
        
        Test.startTest();
            Boolean result = UTL_Box.deleteAllFilesAndFolders('103016339581');
        Test.stopTest();    
        
        System.assertEquals(true, result , 'True is expected for successful deletion');
    }
    
    @isTest
    static void testDeleteAllFilesAndFoldersWhenFailure() {
        String mockResponseBody = '{"type":"error","status":404,"code":"not_found","context_info":{"errors":[{"reason":"invalid_parameter","name":"item","message":'
            + 'Invalid value developers.box.comdocs #errors message":"Not Found","request_id":"b5ww51gpy7343xpw"}';
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponseBody, 'Not Found', 404));
        
        Test.startTest();
            Boolean result = UTL_Box.deleteAllFilesAndFolders('103016339581');
        Test.stopTest();    
        
        System.assertEquals(false, result , 'False is expected for failure in deletion');
    }
    
    @isTest
    static void testCopyAllFoldersAndFilesFromSourceToDestinationWhenFailure() {
        String mockResponseBody = '{"type":"error","status":409,"code":"item_name_in_use","context_info":{"conflicts":{"type":"folder","id":"136288576821","sequence_id":"0","etag":"0",'
            + '"name":"ZZA60166 - Bid 1"}},"help_url":"http:developers.box.com docs #errors","message":"Item with the same name already exists","request_id":"mq4mgvgpyh8fvlxt"}';     
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(mockResponseBody, 'item_name_in_use', 409));
        
        Test.startTest();
            String result = UTL_Box.copyAllFoldersAndFilesFromSourceToDestination('103016339581', '213416339581', 'Test Folder');
        Test.stopTest();    
        
        System.assertEquals(null, result , 'The folder id of copied folder should be null in case of api error');    
    }
}