@isTest
private class TST_SLT_Frequency {

    @isTest
    static void testSelectById(){
        CSM_QI_Frequency__c freqRecord = new CSM_QI_Frequency__c();
        freqRecord.Frequency__c = 'Weekly';
        freqRecord.Weekday__c = 'Saturday';
        insert freqRecord;
        
        Test.startTest();
        new SLT_Frequency().selectById(new Set<Id>{freqRecord.Id});
        Test.stopTest();
    }
}