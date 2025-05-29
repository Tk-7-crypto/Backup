/**
* This test class is used to test DAOH_PSA_PSSF.cls.
*
*/
@isTest
private class TST_DAOH_PSA_PSSF {
    @testSetup static void setup() {
        UTL_PSA_TestData.createPSSF(); 
    }
    
    testmethod static void testvalidateFieldsPSSF(){
        Test.startTest(); 
        try{
            PSSF__c pssfRec = [SELECT id from PSSF__c limit 1];
            //pssfRec.Project_Name__c = null;
            //pssfRec.Account__c = null;
            pssfRec.PSSF_Status__c = 'Published';
            update pssfRec;
        }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        //System.assertEquals(1, pssfRec.size());
        Test.stopTest();
    }
    testmethod static void testUpdateAuditLogCreation(){
        Test.startTest(); 
        try{
            PSSF__c pssfRec = [SELECT id from PSSF__c limit 1];
            update pssfRec;
        }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
        }
        Test.stopTest();
    }    
    testmethod static void testDeleteAuditLogCreation(){
        Test.startTest(); 
        try{
            PSSF__c pssfRec = [SELECT id from PSSF__c limit 1];
            delete pssfRec;
        }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
        }
        Test.stopTest();
    }
    
    testmethod static void testsynchronizeProjectEvents(){
        Test.startTest();
        PSA_Event__c psaEvent = new PSA_Event__c();
        psaEvent.RecordTypes__c = 'NA';
        psaEvent.Object__c = 'PSSF__c';
        psaEvent.Planned_Date_Field__c = 'PSSF_Effective_Date__c';
        psaEvent.Primary_Resource_Field__c = 'Service_Line_Lead__c';
        psaEvent.Stakeholder_Fields__c = 'Service_Line_Lead__c';
        psaEvent.Notification_Offset__c = -2;
        psaEvent.Event_Name__c = 'TEST pssf';
        insert psaEvent;
        Test.stopTest();
    }

    testmethod static void testupdtRltdPJEToUpdtReciepients(){
        Test.startTest();
        PSA_Event__c psaEvent = new PSA_Event__c();
        psaEvent.RecordTypes__c = 'NA';
        psaEvent.Object__c = 'PSSF__c';
        psaEvent.Planned_Date_Field__c = 'PSSF_Effective_Date__c';
        psaEvent.Primary_Resource_Field__c = 'Service_Line_Lead__c';
        psaEvent.Stakeholder_Fields__c = 'Service_Line_Lead__c';
        psaEvent.Notification_Offset__c = -2;
        psaEvent.Event_Name__c = 'TEST pssf';
        insert psaEvent;
        
        
        try{
		PSSF__c pssfRec = [SELECT id,PSSF_Effective_Date__c from PSSF__c limit 1];
        Project_Event__c pje = new Project_Event__c();
        pje.PSSF__c = pssfRec.id;
        pje.Event_Due_Date__c = pssfRec.PSSF_Effective_Date__c;
        pje.Primary_Resource__c = pssfRec.Service_Line_Lead__c;
        pje.PSA_Event__c = psaEvent.id;
        insert pje;
            
        pssfRec.PSSF_Effective_Date__c = Date.newInstance(2021, 8, 4);
        update pssfRec;
        }
        catch(Exception ex){
            system.debug('error');
        }
        Test.stopTest();
    }
    
    
}
