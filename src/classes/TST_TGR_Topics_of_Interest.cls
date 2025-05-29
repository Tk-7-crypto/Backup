@isTest
private class TST_TGR_Topics_of_Interest {
    @testSetup static void setup() {
        
    }
    testmethod static void testvalidateTopicsOfInterestFields(){
        Test.startTest(); 
        try{
            Topics_of_Interest__c toiRecord = UTL_PSA_TestData.createTopicOfInterest(0);
            toiRecord.Product__c = null;
            toiRecord.Date_Started__c  =  Date.newInstance(2030, 3, 4);
            toiRecord.Date_Stopped__c  =  Date.newInstance(2029, 3, 4);
            toiRecord.Date_Reminder_Calendar__c = Date.newInstance(2029, 4, 5);
            insert toiRecord;
        }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    
    
    testmethod static void testautoPopulateTopicsOfInterestFields(){
        Test.startTest();
        Topics_of_Interest__c toiRecord = UTL_PSA_TestData.createTopicOfInterest(1);
        system.debug('shyam '+toiRecord);
        insert toiRecord;
        Topics_of_Interest__c toiRecordUpdate = [select id from Topics_of_Interest__c where In_RMP__c =: 'No'];
        update toiRecordUpdate;
        Test.stopTest();
    }
}