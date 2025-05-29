@isTest
public class TST_SLT_PSA_Signal {
@testSetup static void setup() {    
    Signal__c sigRec = UTL_PSA_TestData.createSignal();
    insert sigRec;
    }
    
    testmethod static void testCheckPermmission() {
        Test.startTest();
        SLT_PSA_Signal svc = new SLT_PSA_Signal();
        svc.checkPermmission();
        Test.stopTest();
        
    }
    testmethod static void testGetSignalListById() {
        Test.startTest();
        SLT_PSA_Signal svc = new SLT_PSA_Signal();
        Signal__c sig = [select id from Signal__c limit 1];
        svc.getSignalListById(sig.id);
        List<Schema.SObjectField> schema = new SLT_PSA_Signal().getSObjectFieldList();
        Set<String> fieldSet =  new SLT_PSA_Signal().getSObjectFieldSet();
        Map<Id, Signal__c> signalMap = new SLT_PSA_Signal(false,false).getSignalMapBySignalIds(new Set<Id>{sig.id},new Set<String>{'Name'});
        Test.stopTest();
           
    }
}
