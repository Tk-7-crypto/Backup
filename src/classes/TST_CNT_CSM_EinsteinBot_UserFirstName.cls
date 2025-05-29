@isTest
private class TST_CNT_CSM_EinsteinBot_UserFirstName {

    @isTest
    static void testGetFirstName(){
        LiveChatVisitor chatVisitor = new LiveChatVisitor();
        insert chatVisitor;
        
        LiveChatTranscript transChatRecord = new LiveChatTranscript(LiveChatVisitorId = chatVisitor.Id, Email__c = 'testuser@dummytest.com', 
                                                          FirstName__c = 'Saurabh', LastName__c = 'Sharma', Body = 'Test chat content');
        insert transChatRecord;
        Test.startTest();
        CNT_CSM_EinsteinBot_UserFirstName.TranscriptInput chatIdRecord = new CNT_CSM_EinsteinBot_UserFirstName.TranscriptInput();
        chatIdRecord.routableId = transChatRecord.Id;
        List<CNT_CSM_EinsteinBot_UserFirstName.TranscriptInput> chatIdList = new List<CNT_CSM_EinsteinBot_UserFirstName.TranscriptInput>();
        chatIdList.add(chatIdRecord);
        CNT_CSM_EinsteinBot_UserFirstName.getFirstName(chatIdList);
        Test.stopTest();
    }
}