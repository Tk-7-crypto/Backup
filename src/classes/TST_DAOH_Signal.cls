@isTest
public class TST_DAOH_Signal{
    @testSetup static void setup() {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        mulesoftSetting.Is_Mulesoft_User__c = true;
        mulesoftSetting.Ignore_Validation_Rules__c = false;
        upsert new  Mulesoft_Integration_Control__c(Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = true, Enable_OLI_Sync_Validation__c = true, Ignore_Validation_Rules__c = false,SetupOwnerId = UserInfo.getOrganizationId());
        UTL_PSA_TestData.createPermissionControls();
        
        Signal__c sigRec = UTL_PSA_TestData.createSignal();
        insert sigRec;
        
    }
    testmethod static void testValidateSignalFields(){
        Test.startTest(); 
        try{
            Signal__c signalRec = [SELECT id,Validation_Date__c from Signal__c limit 1];
            signalRec.Validation_Date__c = Date.newInstance(2030, 3, 4);
            update signalRec;
        }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    
    testmethod static void testValidateSignalFields2(){
        Test.startTest(); 
        try{
            Signal__c signalRec = [SELECT id,Validation_Date__c,Date_Detected__c from Signal__c limit 1];
            signalRec.Validation_Date__c = Date.newInstance(2021, 3, 4);
            signalRec.Date_Detected__c = Date.newInstance(2030, 3, 4);
            signalRec.Signal_Term__c = 'Test';
            update signalRec;
        }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    testmethod static void testClosedStatusSignalValidation1(){
        Test.startTest(); 
        try{
            Signal__c signalRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
            signalRec.Signal_Status__c = 'Closed';
            signalRec.Product__c = null;
            signalRec.Signal_Term__c = '';
            signalRec.SM_Service_Line_Lead_New__c = null;
            signalRec.Incl_Signal_Val_in_Metrics_Invoices__c = null;
            signalRec.Signal_Validation_Complexity__c = null;
            signalRec.Incl_Signal_Eval_in_Metrics_Invoices__c = null;
            signalRec.Further_Actions_to_be_Implemented__c = null;
            update signalRec;
        }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    testmethod static void testClosedStatusSignalValidation2(){
        Test.startTest(); 
        try{
            Target__c targetRec = [SELECT Id from Target__c];
            Contact contactRec = [SELECT Id from Contact];
            Signal__c signalRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
            signalRec.Signal_Status__c = 'Closed';
            signalRec.Product__c = targetRec.id;
            signalRec.Signal_Term__c = 'Test';
            signalRec.SM_Service_Line_Lead_New__c = contactRec.id;
            signalRec.Incl_Signal_Val_in_Metrics_Invoices__c = null;
            signalRec.Signal_Validation_Complexity__c = null;
            signalRec.Incl_Signal_Eval_in_Metrics_Invoices__c = null;
            signalRec.Further_Actions_to_be_Implemented__c = null;
            update signalRec;
        }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    
    testmethod static void testSignalStatusValidations1(){
        Test.startTest();
        try{
            Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
            sigRec.Signal_Status__c = 'Ongoing';
            sigRec.Source_or_Trigger_of_Signal__c = null;
            update sigRec;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    /*testmethod static void testSignalStatusValidations1(){
        Test.startTest();
        try{
            Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
            sigRec.Signal_Status__c = 'Ongoing';
            sigRec.Source_or_Trigger_of_Signal__c = null;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }*/
    testmethod static void testSignalStatusValidations2(){
        Test.startTest();
        try{
            Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
            sigRec.Signal_Status__c = 'Ongoing';
            sigRec.Reason_for_Evaluation__c = null;
            update sigRec;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    testmethod static void testSourceValidation(){
        Test.startTest();
        try{
            Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
            sigRec.Source_or_Trigger_of_Signal__c = 'Routine Signal Detection (specify)';
            sigRec.Routine_Signal_Detection_Specify__c = null;
            update sigRec;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    testmethod static void testSourceValidation2(){
        Test.startTest();
        try{
            Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
            sigRec.Source_or_Trigger_of_Signal__c = 'Other (specify)';
            sigRec.Other_Trigger_Specify__c = null;
            update sigRec;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    testmethod static void testSourceValidation3(){
        Test.startTest();
        try{
            Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
            sigRec.Source_or_Trigger_of_Signal__c = 'Partner (specify)';
            sigRec.Partner_Specify__c = null;
            update sigRec;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    testmethod static void testSigValValidation(){
        Test.startTest();
        try{
            Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
            sigRec.Incl_Signal_Val_in_Metrics_Invoices__c = 'No (Specify Reason)';
            sigRec.Reason_Signal_Val_not_in_Metric_Invoices__c = null;
            update sigRec;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    testmethod static void testSigValOutcomeValidation(){
        Test.startTest();
        try{
            Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
            sigRec.Validation_Outcome__c = 'Signal Not Validated(Specify Reason)';
            sigRec.Reason_Signal_Not_Validated__c = null;
            update sigRec;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    testmethod static void testSourceMultipleValidation(){
        Test.startTest();
        try{
            Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
            sigRec.Source_or_Trigger_of_Signal__c = 'Routine Signal Detection (Specify);Other (Specify);Partner (Specify)';
            sigRec.Routine_Signal_Detection_Specify__c = null;
            sigRec.Other_Trigger_Specify__c = null;
            sigRec.Partner_Specify__c = null;
            update sigRec;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    testmethod static void testValidationOutcome2(){
        Test.startTest();
        try{
            Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
            sigRec.Validation_Outcome__c = 'Signal Validated';
            sigRec.Source_or_Trigger_of_Signal__c = null;
            sigRec.Date_Detected__c = null;
            sigRec.Signal_Term__c = null;
            update sigRec;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    testmethod static void testInclSignalEvalField(){
        Test.startTest();
        try{
            Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
            sigRec.Incl_Signal_Eval_in_Metrics_Invoices__c = 'No (Specify Reason)';
            sigRec.Reason_Signal_Evl_not_in_Metric_Invoice__c = null;
            update sigRec;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    testmethod static void testSignalStatusField(){
        Test.startTest();
        try{
            Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
            sigRec.Signal_Status__c = 'Ongoing';
            sigRec.Methods_of_Signal_Evaluation__c = null;
            sigRec.Action_s_Taken_or_Planned__c = null;
            update sigRec;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    testmethod static void testDtClosedEvalField(){
        Test.startTest();
        try{
            Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
            sigRec.Date_Closed_Evaluation_Completed__c = Date.newInstance(2021, 3, 4);
            sigRec.Signal_Evaluation_Outcome__c = null;
            update sigRec;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    testmethod static void testActionPlannedField(){
        Test.startTest();
        try{
            Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
            sigRec.Action_s_Taken_or_Planned__c = 'Other (Specify);Additional Risk Minimization Measures (Specify)';
            sigRec.Other_Action_s_Taken_Planned_Specify__c = null;
            sigRec.Additional_RMM_Specify__c = null;
            update sigRec;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    testmethod static void testFurtherActionImplField(){
        Test.startTest();
        try{
            Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
            sigRec.Further_Actions_to_be_Implemented__c = 'Yes_specify_with_free_text';
            sigRec.Further_Actions_Implemented_Specify__c = null;
            update sigRec;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    testmethod static void testSignalPrioCatField(){
        Test.startTest();
        try{
            Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
            sigRec.Signal_Prioritization_Category__c = 'Custom';
            sigRec.Signal_Prioritization_Custom_Specify__c = null;
            update sigRec;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    testmethod static void testSignalDeletion(){
        Test.startTest();
            Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
        	delete sigRec;
        Test.stopTest();
    }
    testmethod static void testDeliverableCreation(){
        Test.startTest();
            Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
        	sigRec.Incl_Signal_Val_in_Metrics_Invoices__c = 'Yes';
        	sigRec.Validation_Date__c = Date.today();
            try{
                update sigRec;
            }catch(Exception ex){
				system.debug('');
        	}
        	
        Test.stopTest();
    }
    testmethod static void testEvalDeliverableCreation(){
        Test.startTest();
        Signal__c sigRec = [SELECT id,Signal_Status__c from Signal__c limit 1];
        sigRec.Incl_Signal_Eval_in_Metrics_Invoices__c = 'Yes';
        sigRec.Date_Closed_Evaluation_Completed__c = Date.today();
        sigRec.Signal_Evaluation_Outcome__c = 'Signal Refuted';
        sigRec.Date_SVF_Draft_Sent_for_QC__c = Date.newInstance(2020, 3, 4);
        sigRec.Date_QC_Completed_SVF__c = Date.newInstance(2020, 3, 4);
        sigRec.Date_SVF_Draft_sent_for_Medical_Review__c = Date.newInstance(2020, 3, 4);
        sigRec.Date_Medical_Review_Completed_SVF__c = Date.newInstance(2020, 3, 4);
        sigRec.Date_SVF_Final_DraftReady_for_SMT_Review__c = Date.newInstance(2020, 3, 4);
        sigRec.Date_SER_Draft_Sent_for_QC__c = Date.newInstance(2020, 3, 4);
        sigRec.Date_QC_Completed_SER__c = Date.newInstance(2020, 3, 4);
        sigRec.Date_SER_Draft_sent_for_Medical_Review__c = Date.newInstance(2020, 3, 4);
        sigRec.Date_Medical_Review_Completed_SER__c = Date.newInstance(2020, 3, 4);
        sigRec.Date_SER_Final_DraftReady_for_SMT_Review__c = Date.newInstance(2020, 3, 4);
        try{
                update sigRec;
            }catch(Exception ex){
               system.debug('');
            }
            
        Test.stopTest();
    }
    testmethod static void testValidations(){
        Test.startTest();
        	pse__Proj__c project = [select id from pse__Proj__c limit 1];
        	Target__c target = [select id from target__c limit 1];
            Signal__c sigRec = new Signal__c();
            sigRec.project__c = project.id;
            sigRec.Source_or_Trigger_of_Signal__c = 'FAERS';
            sigRec.Product__c = target.Id;
            sigRec.Date_Detected__c = Date.newInstance(2020, 3, 4);
            sigRec.Signal_Term__c = 'Test';
            sigRec.SM_Service_Line_Lead_New__c = null;
            sigRec.Incl_Signal_Val_in_Metrics_Invoices__c = 'Yes';
            sigRec.Signal_Validation_Complexity__c = 'Simple';
            sigRec.Incl_Signal_Eval_in_Metrics_Invoices__c = 'Yes';
            try{
            	insert sigRec;
            }catch(Exception ex){
                system.debug('');
            }
            
        Test.stopTest();
    }
    testmethod static void testValidations2(){
        Test.startTest();
            try{
                Signal__c sigRec = [select id from signal__c limit 1];
                sigRec.Date_Closed_Evaluation_Completed__c = Date.today();
                sigRec.Signal_Status__c = 'Ongoing';
                update sigRec;
                sigRec.Date_Closed_Evaluation_Completed__c = null;
                sigRec.Validation_Outcome__c = 'Signal Validated';
                sigRec.Signal_Status__c = 'Closed';
                update sigRec;
            }catch(Exception ex){
                system.debug('');
            }
            
        Test.stopTest();
    }
    testmethod static void testactiveAssgnmntValidations(){
        Test.startTest();
            try{
                Signal__c sigRec = [select id from signal__c limit 1];
                Contact contactRec = [SELECT Id from Contact];
                sigRec.SVF_SM_Specialist__c = contactRec.id;
                sigRec.SVF_SM_QC_Reviewer__c = contactRec.id;
                sigRec.SER_SM_Specialist__c = contactRec.id;
                sigRec.SER_SM_QC_Reviewer__c = contactRec.id;
                update sigRec;
            }catch(Exception ex){
                system.debug('');
            }
            
        Test.stopTest();
    }
    
    testmethod static void testsynchronizeProjectEvents(){
        Test.startTest();
        PSA_Event__c psaEvent = new PSA_Event__c();
        psaEvent.RecordTypes__c = 'NA';
        psaEvent.Object__c = 'Signal__c';
        psaEvent.Planned_Date_Field__c = 'Evaluation_Due_Date__c';
        psaEvent.Primary_Resource_Field__c = 'SM_Service_Line_Lead_New__c';
        psaEvent.Stakeholder_Fields__c = 'SM_Service_Line_Lead_New__c';
        psaEvent.Notification_Offset__c = -2;
        psaEvent.Event_Name__c = 'TEST';
        insert psaEvent;
        try{
        Signal__c sigRec = [SELECT id,Evaluation_Due_Date__c from Signal__c limit 1];
        sigRec.Evaluation_Due_Date__c = Date.newInstance(2021, 3, 4);
        update sigRec;
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
        psaEvent.Object__c = 'Signal__c';
        psaEvent.Planned_Date_Field__c = 'Evaluation_Due_Date__c';
        psaEvent.Primary_Resource_Field__c = 'SM_Service_Line_Lead_New__c';
        psaEvent.Stakeholder_Fields__c = 'SM_Service_Line_Lead_New__c';
        psaEvent.Notification_Offset__c = -2;
        psaEvent.Event_Name__c = 'TEST';
        insert psaEvent;
        
        
        try{
        Signal__c sigRec = [SELECT id,Evaluation_Due_Date__c from Signal__c limit 1];
        Project_Event__c pje = new Project_Event__c();
        pje.Signal__c = sigRec.id;
        pje.Event_Due_Date__c = sigRec.Evaluation_Due_Date__c;
        pje.Primary_Resource__c = sigRec.SM_Service_Line_Lead_New__c;
        pje.PSA_Event__c = psaEvent.id;
        insert pje;
            
        sigRec.Evaluation_Due_Date__c = Date.newInstance(2021, 8, 4);
        update sigRec;
        }
        catch(Exception ex){
            system.debug('error');
        }
        Test.stopTest();
    }
    
}
