@isTest
private class TST_DAOH_Topics_of_Interest {
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
    
    testmethod static void testautoPopulateTopicsOfInterestUniqueId(){
        Test.startTest();
        Topics_of_Interest__c toiRecord2 = UTL_PSA_TestData.createTopicOfInterest(1);
        toiRecord2.TOI_Unique_ID__c = 'TEST -TOPIC-00001';
        insert toiRecord2;
		Topics_of_Interest__c toiRecord = new Topics_of_Interest__c();
            toiRecord.Product__c = toiRecord2.Product__c;
            toiRecord.Account__c = toiRecord2.Account__c;
            toiRecord.project__c = toiRecord2.Project__c;
            toiRecord.Status__c = 'New';
            toiRecord.Topic_Term__c = 'Test';
            toiRecord.Topic_Category__c = 'Potential Risk (important)';
            toiRecord.Search_Variable_in_Data_Source__c = ' Adverse Events';
            toiRecord.Type_of_MedDRA_Query__c = 'HLGT' ;
            toiRecord.MedDRA_Search_Specifications__c = 'Test';
            toiRecord.Date_Started__c  =  Date.newInstance(2021, 1, 2);
            toiRecord.Date_Reminder_Calendar__c = Date.newInstance(2021, 4, 5);
            toiRecord.Part_of_Additional_RMM__c = 'No';
            toiRecord.In_RMP__c = 'No';
            toiRecord.Part_of_Commitment_to_HA__c = 'No';
            toiRecord.Rationale_Started__c = 'test';
            toiRecord.Document_Link_1__c = 'test';
            toiRecord.Document_Name_1__c = 'test';
        	
        insert toiRecord;
        Test.stopTest();
    }
}
