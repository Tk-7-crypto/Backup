/**
 * This test class is used to test DAOH_Sd_Run.cls.
 *
 */
@isTest
private class TST_DAOH_Sd_Run {
    @testSetup static void setup() {
        UTL_PSA_TestData.createSdRun();
        upsert new  Mulesoft_Integration_Control__c(Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = true, Enable_OLI_Sync_Validation__c = true, Ignore_Validation_Rules__c = false,SetupOwnerId = UserInfo.getOrganizationId());
    }
    
    testmethod static void testPopulateSdRunIdField(){
        Test.startTest();
        // Validate if a record was inserted in QC Tracker Result 
        //list<SD_Runs__c> sdRunRec = [SELECT id from SD_Runs__c];
        //System.assertEquals(2, sdRunRec.size());
        Test.stopTest();
    }
    
    testmethod static void testValidateSDRunFields(){
        Test.startTest(); 
        try{
            SD_Runs__c sdRec = [SELECT id from SD_Runs__c limit 1];
            UTL_PSA_TestData.createResources(1,false);
        	Contact con = [Select id,FirstName,LastName,Email from Contact limit 1];
            //insert con;
            sdRec.Status__c = 'Completed';
            sdRec.Last_SD_Run_for_Product__c = true;
            sdRec.Discussed_in_SMT_Meeting__c = 'Yes (enter date)';
            sdRec.SD_Run_Outcome__c = 'No Action;Potential Signal;Potential Emerging Safety Issue;Other (specify)';
            sdRec.SD_Run_Date_Completed__c = System.today();
            sdRec.SD_Run_Complexity__c = null;
            sdRec.SD_Run_Start_Date__c = Date.newInstance(2030, 3, 4);
            sdRec.SD_Run_Date_Completed__c  = Date.newInstance(2021, 3, 4);
            sdRec.Status__c = 'Not Yet Started';
            sdRec.Data_Review_Period_Start_Date__c = Date.newInstance(2030, 3, 4);
            sdRec.Data_Review_Period_End_Date__c =Date.newInstance(2021, 3, 4);
            sdRec.Discussed_in_SMT_Meeting__c = 'No (specify reason)';
            sdRec.Not_Discussed_in_SMT_Meeting_Reason__c = null;
            sdRec.Date_SMT_Meeting__c = null;
            sdRec.Date_Draft_Sent_for_QC__c = Date.today();
            sdRec.Date_QC_Completed__c = Date.today();
            sdRec.Date_Draft_sent_for_Medical_Review__c = Date.today();
            sdRec.Date_Medical_Review_Completed__c = Date.today();
            sdRec.Date_final_Draft_Ready_for_SMT_Review__c = Date.today();
            update sdRec;
        }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        //System.assertEquals(1, pssfRec.size());
        Test.stopTest();
    }
    testmethod static void testUpdateAuditLog(){
        Test.startTest();
        list<SD_Runs__c> sdRunRec = [SELECT id, Frequency__c from SD_Runs__c limit 1];
        sdRunRec[0].Frequency__c = 'Monthly';
        update sdRunRec;
        Test.stopTest();
    }
    
    testmethod static void testDeleteAuditLog(){
        Test.startTest();
        list<SD_Runs__c> sdRunRec = [SELECT id, Frequency__c from SD_Runs__c limit 1];
        delete sdRunRec;
        Test.stopTest();
    }
    testmethod static void testCreateDeliverables(){
        Test.startTest();
        Mulesoft_Integration_Control__c settings = Mulesoft_Integration_Control__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings Mulesoft_Integration_Control__c.Id;

        try {
            list<SD_Runs__c> sdRunRec = [SELECT id, Frequency__c,Status__c from SD_Runs__c limit 1];
            sdRunRec[0].Status__c = 'Completed';
            update sdRunRec;
        }
        catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        Test.stopTest();
    }
    
    testmethod static void testActiveAssignments(){
        Test.startTest();
        try {
            list<SD_Runs__c> sdRunRec = [SELECT id, Frequency__c,Status__c from SD_Runs__c limit 1];
            Contact con = [Select id, Name from Contact limit 1];
            sdRunRec[0].SM_Specialist__c = con.id;
            update sdRunRec;
        }
        catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        Test.stopTest();
    }
    
    testmethod static void testsynchronizeProjectEvents(){
        Test.startTest();
        PSA_Event__c psaEvent = new PSA_Event__c();
        psaEvent.RecordTypes__c = 'NA';
        psaEvent.Object__c = 'SD_Runs__c';
        psaEvent.Planned_Date_Field__c = 'SD_Run_Due_Date__c';
        psaEvent.Primary_Resource_Field__c = 'Service_Line_Lead__c';
        psaEvent.Stakeholder_Fields__c = 'Service_Line_Lead__c';
        psaEvent.Notification_Offset__c = -2;
        psaEvent.Event_Name__c = 'TEST SD';
        insert psaEvent;
        try{
        SD_Runs__c sdRec = [SELECT id,SD_Run_Due_Date__c from SD_Runs__c limit 1];
        sdRec.SD_Run_Due_Date__c = Date.newInstance(2021, 3, 4);
        update sdRec;
        }
        catch(Exception ex){
            system.debug('error');
        }
        Test.stopTest();
    }
    
    testmethod static void testupdtRltdPJEToUpdtReciepients(){
        Test.startTest();
        PSA_Event__c psaEvent = new PSA_Event__c();
        psaEvent.RecordTypes__c = 'NA';
        psaEvent.Object__c = 'SD_Runs__c';
        psaEvent.Planned_Date_Field__c = 'SD_Run_Due_Date__c';
        psaEvent.Primary_Resource_Field__c = 'Service_Line_Lead__c';
        psaEvent.Stakeholder_Fields__c = 'Service_Line_Lead__c';
        psaEvent.Notification_Offset__c = -2;
        psaEvent.Event_Name__c = 'TEST SD';
        insert psaEvent;
        
        
        try{
        SD_Runs__c sdRec = [SELECT id,SD_Run_Due_Date__c from SD_Runs__c limit 1];
        Project_Event__c pje = new Project_Event__c();
        pje.SD_Runs__c = sdRec.id;
        pje.Event_Due_Date__c = sdRec.SD_Run_Due_Date__c;
        pje.Primary_Resource__c = sdRec.Service_Line_Lead__c;
        pje.Secondary_Resource__c = sdRec.Service_Line_Lead__c;
        pje.PSA_Event__c = psaEvent.id;
        insert pje;
            
        sdRec.SD_Run_Due_Date__c = Date.newInstance(2021, 7, 4);
        update sdRec;
        }
        catch(Exception ex){
            system.debug('error');
        }
        Test.stopTest();
    }  
}
