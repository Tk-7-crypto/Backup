@isTest
private class TST_EXT_CSM_CalendarEvent {

    @isTest
    static void testExt_GenerateEvent(){
        Datetime startTime = Datetime.now();
        Datetime endTime = startTime;
        String recipient = 'dummyuser@mail.com';
        String summary = 'dummy data summary';
        String description = 'dummy data description';
        String uniqueId = 'uniq12345';
        Integer seqNr = 1;
        
        Test.startTest();
        Blob dataMemory = EXT_CSM_CalendarEvent.ext_GenerateEvent(recipient, summary, description, startTime, endTime, uniqueId, seqNr);
        Test.stopTest(); 
    }
}