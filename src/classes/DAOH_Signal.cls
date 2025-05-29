/**
* This is Signal trigger handler class.
* version : 1.0
*/
public class DAOH_Signal {
    
    /**
    * This method is used to populate Signal_Unique_ID__c
    * @params List<Signal__c> newList
    * @return void
    */
    public static void populateSignalUniqueId(List<Signal__c> newList,Map<Id, Signal__c> oldMap){
        Set<String> accountIdSet = new Set<String>();
        Set<String> uniqueIdSet = new Set<String>();
        Map<String,String> accountIdToSignalUniqueNameMap = new Map<String,String>();
        for(Signal__c signal : newList) {
            if(signal.Account__c != null) {
                   accountIdSet.add(signal.Account__c);
            }            
        }
        if(accountIdSet.size() > 0){
            Map<Id,Account> accountMap = new Map<Id,Account>([Select Id,Name from Account where Id in: accountIdSet]);
            for(Id acc : accountMap.keySet()){
                String subName;
                if(accountMap.get(acc).Name.length() >= 5){
                    subName = accountMap.get(acc).Name.substring(0,5)+'%';  
                }else{
                    subName = accountMap.get(acc).Name+'%';
                }
                uniqueIdSet.add(subName);
            }
            for(Signal__c signal : [SELECT Id, Account__c,Account__r.Name,Signal_Unique_ID__c
                                   FROM Signal__c
                				   WHERE Signal_Unique_ID__c like: uniqueIdSet]){
                String initialFiveCharOfAccountName;
                if(signal.Account__r.Name.length() >= 5){
                  initialFiveCharOfAccountName = signal.Account__r.Name.substring(0,5);  
                }else{
                   initialFiveCharOfAccountName = signal.Account__r.Name;   
                }
                if(accountIdToSignalUniqueNameMap.containsKey(initialFiveCharOfAccountName) ) {
                    if(accountIdToSignalUniqueNameMap.get(initialFiveCharOfAccountName) < signal.Signal_Unique_ID__c ) {
                        accountIdToSignalUniqueNameMap.put(initialFiveCharOfAccountName,signal.Signal_Unique_ID__c);
                    }     
                }     
                else{
                     accountIdToSignalUniqueNameMap.put(initialFiveCharOfAccountName,signal.Signal_Unique_ID__c);                    
                }  
            }
            for(Signal__c signal : newList) {              
                String accountNameSubstring;
                if(accountMap.containsKey(signal.Account__c)){
                    accountNameSubstring = accountMap.get(signal.Account__c).Name.substring(0,5);
                }                
                if(accountIdToSignalUniqueNameMap.containsKey(accountNameSubstring) && accountIdToSignalUniqueNameMap.get(accountNameSubstring) != null){
                    Integer lastIndex = accountIdToSignalUniqueNameMap.get(accountNameSubstring).lastIndexOf('-') + 1;
                    Integer uniqueNumber = Integer.valueof(accountIdToSignalUniqueNameMap.get(accountNameSubstring).substring(lastIndex,18))+1;
                    String uniqueNumberString = String.valueOf(uniqueNumber).leftPad(5, '0');
                    signal.Signal_Unique_ID__c = accountNameSubstring+'-SIGNAL-'+uniqueNumberString;
                    accountIdToSignalUniqueNameMap.put(accountNameSubstring,signal.Signal_Unique_ID__c);
                }
                else{
                    signal.Signal_Unique_ID__c = accountNameSubstring+'-SIGNAL-'+String.valueOf(1).leftPad(5, '0');
                    accountIdToSignalUniqueNameMap.put(accountNameSubstring,signal.Signal_Unique_ID__c);
                }                
            }
        }
    }

    /**
    * This method is used to validate Signal fields on insertion and updation.
    * @params List<Signal__c> newList
    * @return void
    */
    public static void validateSignalFields(List<Signal__c> newList,Map<Id, Signal__c> oldMap){
        String srcOfSignalValidn = '';
        String actionPlannedValidn = '';
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        Set<String> projIdSet = new Set<String>();
        Map<Id, List<pse__Assignment__c>> projAndRltdAssignmentMap = new Map<Id, List<pse__Assignment__c>>();
        String validationErrorMessage = '';
        If(!mulesoftSetting.Ignore_Validation_Rules__c){
            for(Signal__c signalRec : newList){
                if(signalRec.Project__c != null){
                    projIdSet.add(signalRec.Project__c);
                }
            }
            projAndRltdAssignmentMap = new SLT_Assignment().selectAssignmentsByProjId(projIdSet,
                                                                                                new Set<String>{'Id', 'Name', 'pse__Project__c', 'pse__Status__c', 'Active__c','Closed_for_Unit_Entry__c','pse__Closed_for_Time_Entry__c', 'pse__Resource__c'});
            
            for(Signal__c signalRec : newList){
                validationErrorMessage = '';
				//if(Trigger.isInsert){
                if(signalRec.SM_Service_Line_Lead_New__c == null){
                    signalRec.addError('The \'Service Line Lead\' is not present on the Signal Management project.');
                }
                if(signalRec.Date_Detected__c > signalRec.Validation_Date__c){
                    signalRec.addError('\'Date Detected\' cannot be after the \'Validation Date\'.');
                }
                if(signalRec.Date_Closed_Evaluation_Completed__c < signalRec.Validation_Date__c){
                    signalRec.addError('\'Date Closed (Evaluation Completed)\' cannot be before the \'Validation Date\', ');
                }
                if(signalRec.Date_Closed_Evaluation_Completed__c == null && signalRec.Validation_Outcome__c == 'Signal Validated' && (signalRec.Signal_Status__c == 'To Be Validated' || signalRec.Signal_Status__c == 'Not Validated') ){
                    signalRec.addError( '\'' + 'Signal Validated' +'\'' +' has been selected and the' +'\'' +'Signal Status'+'\''+' cannot be '+ '\'' + 'To be Validated' +  ' or ' + '\''+'Not Validated'+'\'' + '.');
                }
                if(signalRec.Date_Closed_Evaluation_Completed__c == null  && signalRec.Validation_Outcome__c == 'Signal Validated' && signalRec.Signal_Status__c == 'Closed'){
                    signalRec.addError( '\'' +'Date Closed (Evaluation Completed)' +'\''+ ' field cannot be empty as the '+'\''+'Signal Status'+'\''+' is '+'\''+ 'Closed' + '\'' + '.');
                }
                if(signalRec.Date_Closed_Evaluation_Completed__c == null && signalRec.Validation_Outcome__c == 'Signal Not Validated(Specify Reason)' && (signalRec.Signal_Status__c == 'To Be Validated' || signalRec.Signal_Status__c == 'Ongoing' || signalRec.Signal_Status__c == 'Closed')  ){
                    signalRec.addError(  ' \'Signal Not Validated\' has been selected and the \'Signal Status\' cannot be \'To be Validated\', \'Ongoing\' or \'Closed\' .');
                }
                if(signalRec.Date_Closed_Evaluation_Completed__c != null && signalRec.Validation_Outcome__c == 'Signal Validated' && (signalRec.Signal_Status__c == 'To Be Validated' || signalRec.Signal_Status__c == 'Ongoing' || signalRec.Signal_Status__c == 'Not Validated')  ){
                    signalRec.addError(   ' \'Date Closed (Evaluation Completed)\' has been entered and the \'Signal Status\' cannot be \'To be Validated\' , \'Not Validated\', or \'Ongoing\'.');
                }
                if(signalRec.Date_Detected__c > Date.today() 
                   || signalRec.Date_Medical_Review_Completed_SVF__c > Date.today() 
                   || signalRec.Validation_Date__c > Date.today() 
                   || signalRec.Date_BRM_Review_Completed_SVF__c > Date.today() 
                   || signalRec.Date_QC_Completed_SVF__c > Date.today() 
                   || signalRec.Date_Closed_Evaluation_Completed__c > Date.today() 
                   || signalRec.Date_BRM_Review_Completed_SER__c > Date.today() 
                   || signalRec.Date_QC_Completed_SER__c > Date.today() 
                   || signalRec.Dt_Transfer_of_Resp_for_Impl_of_Actions__c > Date.today() 
                   || signalRec.Date_Medical_Review_Completed_SER__c > Date.today()
                   || signalRec.Date_SVF_Draft_Sent_for_QC__c > Date.today()
                   || signalRec.Date_SVF_Draft_sent_for_Medical_Review__c > Date.today()
                   || signalRec.Date_SVF_Final_DraftReady_for_SMT_Review__c > Date.today()
                   || signalRec.Date_SER_Draft_Sent_for_QC__c > Date.today()
                   || signalRec.Date_SER_Draft_sent_for_Medical_Review__c > Date.today()
                   || signalRec.Date_Medical_Review_Completed_SER__c > Date.today()
                   || signalRec.Date_SER_Final_DraftReady_for_SMT_Review__c > Date.today()
                  ){
                   signalRec.addError('You cannot enter future dates in \'Date SER Draft sent for Medical Review\', \'Date Medical Review completed (SER)\', \'Date SER Final DraftReady for SMT Review\', \'Date SER Draft Sent for QC\', \'Date SVF Draft Sent for QC\', \'Date SVF Draft sent for Medical Review\', \'Date SVF Final DraftReady for SMT Review\', \'Date Detected\', \'Date Medical Review Completed (SVF)\', \'Validation Date\', \'Date BRM Review Completed (SVF)\', \'Date QC Completed (SVF)\', \'Date Closed (Evaluation Completed)\', \'Date BRM Review Completed (SER)\', \'Date QC Completed (SER)\', \'Dt Transfer of Resp for Impl. of Actions\', \'Date Medical Review Completed (SER)\' date fields.'); 
                }
                validationErrorMessage = '';
                if(signalRec.Signal_Status__c == 'Closed'){
                    if(signalRec.Product__c == null){
                        validationErrorMessage += '\'Product\', ';
                    }
                    if(signalRec.Signal_Term__c == '' || signalRec.Signal_Term__c == null){
                        validationErrorMessage += '\'Signal Term\', ';
                    }
                    if(signalRec.Incl_Signal_Val_in_Metrics_Invoices__c == null){
                        validationErrorMessage += '\'Incl. Signal Val in Metrics/Invoices?\', ';
                    }
                    if(signalRec.Signal_Validation_Complexity__c == null){
                        validationErrorMessage += '\'Signal Validation Complexity\', ';
                    }
                    if(signalRec.Validation_Outcome__c == CON_PSA.SIGNAL_PICKLIST_FIELD_VALUE_SIGNAL_VALIDATED 
                       && signalRec.Incl_Signal_Eval_in_Metrics_Invoices__c == null){
                        validationErrorMessage += '\'Incl. Signal Eval.in Metrics/Invoices?\', ';
                    }
                    if(signalRec.Further_Actions_to_be_Implemented__c == null){
                        validationErrorMessage += '\'Further Actions to be implemented\' ';
                    }
                    if(validationErrorMessage != ''){
                        signalRec.addError('The following fields cannot be empty '+validationErrorMessage+' if the \'Signal Status\' is \'Closed\'');
                    }                 
                }
                validationErrorMessage = '';
                    if(signalRec.Product__c == null){
                        validationErrorMessage += '\'Product\', ';
                    }
                    if(signalRec.Date_Detected__c == null){
                        validationErrorMessage += '\'Date Detected\', ';
                    }
                    if(signalRec.Signal_Term__c == '' || signalRec.Signal_Term__c == null){
                        validationErrorMessage += '\'Signal Term\', ';
                    }
                    if(signalRec.Incl_Signal_Val_in_Metrics_Invoices__c == null){
                        validationErrorMessage += '\'Incl. Signal Val in Metrics/Invoices?\', ';
                    }
                    if(signalRec.Signal_Validation_Complexity__c == null){
                        validationErrorMessage += '\'Signal Validation Complexity\', ';
                    }
                    
                    if(signalRec.Signal_Status__c == CON_PSA.SIGNAL_STATUS_CLOSED 
                       && signalRec.Incl_Signal_Eval_in_Metrics_Invoices__c == null
                       && signalRec.Validation_Outcome__c == CON_PSA.SIGNAL_PICKLIST_FIELD_VALUE_SIGNAL_VALIDATED ){
                           validationErrorMessage += ' \'Incl. Signal Eval in Metrics/Invoices?\' '; 
                       }
                    if(validationErrorMessage != ''){
                        signalRec.addError(validationErrorMessage+' cannot be empty.');
                    }
                if(signalRec.Signal_Status__c != null){
                    if((signalRec.Signal_Status__c.contains('Ongoing') 
                        || signalRec.Signal_Status__c.contains('Closed')) 
                       && signalRec.Reason_for_Evaluation__c == null
                       && signalRec.Validation_Outcome__c == CON_PSA.SIGNAL_PICKLIST_FIELD_VALUE_SIGNAL_VALIDATED){
                           signalRec.addError('\'Signal Status\' of the record equals \'Ongoing\' or \'Closed\' and the \'Reason for Evaluation\' field cannot be empty');
                       }
                }
                if(signalRec.Signal_Status__c != null){
                    if((signalRec.Signal_Status__c.contains('Ongoing') || signalRec.Signal_Status__c.contains('Closed')) && signalRec.Source_or_Trigger_of_Signal__c == null){
                        signalRec.addError('\'Signal Status\' of the record equals \'Ongoing\' or \'Closed\' and the \'Source or Trigger of Signal\' field cannot be empty');
                    }
                }
                if(signalRec.Incl_Signal_Val_in_Metrics_Invoices__c == 'No (Specify Reason)' && signalRec.Reason_Signal_Val_not_in_Metric_Invoices__c == null){
                    signalRec.addError('\'Reason Signal Val not in Metric/Invoices\' field cannot be empty if \'No (Specify reason)\' was selected in the \'Incl. Signal Val in Metrics/Invoices?\' field');
                }
                if(signalRec.Validation_Outcome__c == 'Signal Not Validated(Specify Reason)' && signalRec.Reason_Signal_Not_Validated__c == null){
                    signalRec.addError('\'Reason Signal Not Validated\' field cannot be empty if \'Signal Not Validated (Specify Reason)\' is selected as the \'Validation Outcome\'.');
                }
                if(signalRec.Validation_Outcome__c == 'Signal Validated' && (signalRec.Source_or_Trigger_of_Signal__c == null || signalRec.Date_Detected__c == null || signalRec.Signal_Term__c == null || signalRec.Reason_for_Evaluation__c == null || signalRec.Methods_of_Signal_Evaluation__c == null || signalRec.Action_s_Taken_or_Planned__c == null)){
                  signalRec.addError('\'Source or Trigger of Signal\', \'Date Detected\', \'Signal Term\', \'Reason for Evaluation\', and  \'Methods of Signal Evaluation\', \'Action(s) Taken or Planned\' fields cannot be empty if \'Signal Validated\' is selected as the \'Validation Outcome\'');  
                }
                if(signalRec.Source_or_Trigger_of_Signal__c != null && signalRec.Source_or_Trigger_of_Signal__c != ''){
                    if(signalRec.Source_or_Trigger_of_Signal__c.contains('Routine Signal Detection (Specify)') && signalRec.Routine_Signal_Detection_Specify__c == null){
                        srcOfSignalValidn = srcOfSignalValidn + '\'Routine Signal Detection (Specify)\' field cannot be empty as \'Routine Signal Detection (Specify)\' was selected ';
                    }
                    if(signalRec.Source_or_Trigger_of_Signal__c.contains('Other (Specify)') && signalRec.Other_Trigger_Specify__c == null){
                        srcOfSignalValidn = srcOfSignalValidn + '\'Other Trigger (Specify)\' field cannot be empty as \'Other (specify)\' was selected ';
                    }
                    if(signalRec.Source_or_Trigger_of_Signal__c.contains('Partner (Specify)') && signalRec.Partner_Specify__c == null){
                        srcOfSignalValidn = srcOfSignalValidn + '\'Partner (Specify)\' field cannot be empty as \'Partner (specify)\' was selected ';
                    }
                    if(srcOfSignalValidn != null && srcOfSignalValidn != ''){
                        srcOfSignalValidn = srcOfSignalValidn + 'from the Source or Trigger of Signal field.';
                        signalRec.addError(srcOfSignalValidn);
                        srcOfSignalValidn = '';
                    }
                }
                if(signalRec.Incl_Signal_Eval_in_Metrics_Invoices__c == 'No (Specify Reason)' && signalRec.Reason_Signal_Evl_not_in_Metric_Invoice__c == null){
                    signalRec.addError('\'Reason Signal Evl not in Metric/Invoice\' field cannot be empty if \'No (Specify reason)\' was selected from the \'Include Signal Evaluation in Metrics/Invoices?\' field.');
                }
                if(signalRec.Signal_Status__c != null){
                    if((signalRec.Signal_Status__c.contains('Ongoing') 
                        || signalRec.Signal_Status__c.contains('Closed')) 
                       && signalRec.Methods_of_Signal_Evaluation__c == null 
                       && signalRec.Validation_Outcome__c == CON_PSA.SIGNAL_PICKLIST_FIELD_VALUE_SIGNAL_VALIDATED){
                        signalRec.addError('\'Methods of Signal Evaluation\' field cannot be empty if the \'Signal Status\' equals \'Ongoing\' or \'Closed\'.');
                    }
                }
                if(signalRec.Date_Closed_Evaluation_Completed__c != null && signalRec.Signal_Evaluation_Outcome__c == null){
                    signalRec.addError('\'Signal Evaluation Outcome\' field cannot be empty if the \'Date Closed (Evaluation Completed)\' is present.');
                }
                if(signalRec.Signal_Status__c != null){
                    if((signalRec.Signal_Status__c.contains('Ongoing') || signalRec.Signal_Status__c.contains('Closed')) && signalRec.Action_s_Taken_or_Planned__c == null){
                        signalRec.addError('\'Action(s) Taken or Planned\' field cannot be empty if the \'Signal Status\' equals \'Ongoing\' or \'Closed\'.');
                    }
                }
                if(signalRec.Action_s_Taken_or_Planned__c != null && signalRec.Action_s_Taken_or_Planned__c != ''){
                    if(signalRec.Action_s_Taken_or_Planned__c.contains('Other (Specify)') && signalRec.Other_Action_s_Taken_Planned_Specify__c == null){
                        actionPlannedValidn = actionPlannedValidn + '\'Other Action(s) Taken/Planned\' field cannot be empty if \'Other (Specify)\' was selected ';
                    }
                    if(signalRec.Action_s_Taken_or_Planned__c.contains('Urgent Risk Minimization Measures (Specify)') && signalRec.Reason_for_urgent_RMM_Specify__c == null){
                        actionPlannedValidn = actionPlannedValidn + '\'Reason for urgent RMM (Specify)\' field cannot be empty if \'Urgent Risk Minimization Measures (Specify)\' was selected ';
                    }
                    if(signalRec.Action_s_Taken_or_Planned__c.contains('Additional Risk Minimization Measures (Specify)') && signalRec.Additional_RMM_Specify__c == null){
                        actionPlannedValidn = actionPlannedValidn + '\'Additional RMM (Specify)\' field cannot be empty if \'Additional Risk Minimization Measures (Specify)\' was selected ';
                    }
                    if(actionPlannedValidn != null && actionPlannedValidn != ''){
                        actionPlannedValidn = actionPlannedValidn + 'from \'Action(s) Taken or Planned\' field.';
                        signalRec.addError(actionPlannedValidn);
                    }
                }
                if(signalRec.Further_Actions_to_be_Implemented__c == 'Yes_specify_with_free_text' && signalRec.Further_Actions_Implemented_Specify__c == null){
                    signalRec.addError('\'Further Actions Implemented (Specify)\' field cannot be empty if \'Yes (specify with free text)\' was selected from \'Further Actions to be Implemented\' field.');
                }
                if(signalRec.Signal_Prioritization_Category__c == 'Custom' && signalRec.Signal_Prioritization_Custom_Specify__c == null){
                    signalRec.addError('\'Signal Prioritization Custom (Specify)\' field cannot be empty if \'Custom\' was selected from the \'Signal Prioritization Category\' field.');
                }
                if(signalRec.SVF_SM_Specialist__c != null){
                    List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
                    assignmentList = projAndRltdAssignmentMap.get(signalRec.Project__c);
                    boolean SMAssignmentActive = hasActiveAssignment(assignmentList, signalRec.SVF_SM_Specialist__c);
                    if(SMAssignmentActive == false){
                       signalRec.addError('There is no active Assignment on the project for the selected \'SVF SM Specialist\'.');
                    }
                }
                if(signalRec.SVF_SM_QC_Reviewer__c != null){
                    List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
                    assignmentList = projAndRltdAssignmentMap.get(signalRec.Project__c);
                    boolean SMAssignmentActive = hasActiveAssignment(assignmentList, signalRec.SVF_SM_QC_Reviewer__c);
                    if(SMAssignmentActive == false){
                       signalRec.addError('There is no active Assignment on the project for the selected \'SVF SM QC Reviewer\'.');
                    }
                }
                if(signalRec.SER_SM_Specialist__c != null){
                    List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
                    assignmentList = projAndRltdAssignmentMap.get(signalRec.Project__c);
                    boolean SMAssignmentActive = hasActiveAssignment(assignmentList, signalRec.SER_SM_Specialist__c);
                    if(SMAssignmentActive == false){
                       signalRec.addError('There is no active Assignment on the project for the selected \'SER SM Specialist\'.');
                    }
                }
                if(signalRec.SER_SM_QC_Reviewer__c != null){
                    List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
                    assignmentList = projAndRltdAssignmentMap.get(signalRec.Project__c);
                    boolean SMAssignmentActive = hasActiveAssignment(assignmentList, signalRec.SER_SM_QC_Reviewer__c);
                    if(SMAssignmentActive == false){
                       signalRec.addError('There is no active Assignment on the project for the selected \'SER SM QC Reviewer\'.');
                    }
                }
                if(signalRec.Signal_Status__c == CON_PSA.SIGNAL_STATUS_CLOSED &&
                   ( signalRec.Signal_Document_Name__c == null || signalRec.Signal_Document_Link__c == null )){                    
                     signalRec.addError('\'Signal Document Name\' and \'Signal Document Link\' cannot be empty as \'Status\' is \'Closed\'.');
                }
                if(signalRec.Signal_Status__c == CON_PSA.SIGNAL_STATUS_NOT_VALIDATED &&
                   ( signalRec.Signal_Document_Name__c == null || signalRec.Signal_Document_Link__c == null )){                    
                     signalRec.addError('\'Signal Document Name\' and \'Signal Document Link\' cannot be empty as \'Status\' is \'Not Validated\'.');
                }
                if(signalRec.Signal_Status__c == CON_PSA.SIGNAL_STATUS_NOT_VALIDATED){
                    if(signalRec.SVF_Medical_Safety_Advisor__c == null || signalRec.Date_Medical_Review_Completed_SVF__c == null || signalRec.SVF_SM_QC_Reviewer__c == null || signalRec.Date_QC_Completed_SVF__c == null){
                        if(signalRec.Does_this_SVF_require_Medical_Review__c == 'Yes' && signalRec.Does_this_SVF_require_QC__c == 'Yes'){
                            signalRec.addError('\'SVF Medical Safety Advisor\', \'Date Medical Review Completed (SVF)\', \'SVF SM QC Reviewer\', \'Date QC Completed (SVF)\' cannot be empty if \'Yes\' is selected from the \'Does this SVF require Medical Review?\' and \'Does this SVF require QC?\' fields');
                        }
                    }
                    if(signalRec.SER_Medical_Safety_Advisor__c == null || signalRec.Date_Medical_Review_Completed_SER__c == null || signalRec.SER_SM_QC_Reviewer__c == null || signalRec.Date_QC_Completed_SER__c == null){
                        if(signalRec.Does_this_SER_require_Medical_Review__c == 'Yes' && signalRec.Does_this_SER_require_QC__c == 'Yes'){
                            signalRec.addError('\'SER Medical Safety Advisor\', \'Date Medical Review Completed (SER)\', \'SER SM QC Reviewer\', \'Date QC Completed (SER)\' cannot be empty if \'Yes\' is selected from the \'Does this SER require Medical Review?\' and \'Does this SER require QC?\' fields');
                        }
                        if((signalRec.Does_this_SER_require_Medical_Review__c == 'No' && signalRec.Does_this_SER_require_QC__c == 'Yes') || (signalRec.Does_this_SER_require_Medical_Review__c == 'Yes' && signalRec.Does_this_SER_require_QC__c == 'No')){
                            signalRec.addError('\'SER Medical Safety Advisor\', \'Date Medical Review Completed (SER)\', \'SER SM QC Reviewer\', \'Date QC Completed (SER)\' cannot be empty if \'Yes\' is selected from the \'Does this SER require Medical Review?\' or \'Does this SER require QC?\' fields');
                        }
                    }
                }
                if(signalRec.Signal_Status__c == CON_PSA.SIGNAL_STATUS_ONGOING){
                    if(signalRec.SVF_Medical_Safety_Advisor__c == null || signalRec.Date_Medical_Review_Completed_SVF__c == null || signalRec.SVF_SM_QC_Reviewer__c == null || signalRec.Date_QC_Completed_SVF__c == null){
                        if(signalRec.Does_this_SVF_require_Medical_Review__c == 'Yes' && signalRec.Does_this_SVF_require_QC__c == 'Yes'){
                            signalRec.addError('\'SVF Medical Safety Advisor\', \'Date Medical Review Completed (SVF)\', \'SVF SM QC Reviewer\', \'Date QC Completed (SVF)\' cannot be empty if \'Yes\' is selected from the \'Does this SVF require Medical Review?\' and \'Does this SVF require QC?\' fields');
                        }
                    }
                }
                if(signalRec.Signal_Status__c == CON_PSA.SIGNAL_STATUS_CLOSED){
                    if(signalRec.SVF_Medical_Safety_Advisor__c == null || signalRec.Date_Medical_Review_Completed_SVF__c == null || signalRec.SVF_SM_QC_Reviewer__c == null || signalRec.Date_QC_Completed_SVF__c == null){
                        if(signalRec.Does_this_SVF_require_Medical_Review__c == 'Yes' && signalRec.Does_this_SVF_require_QC__c == 'Yes'){
                            signalRec.addError('\'SVF Medical Safety Advisor\', \'Date Medical Review Completed (SVF)\', \'SVF SM QC Reviewer\', \'Date QC Completed (SVF)\' cannot be empty if \'Yes\' is selected from the \'Does this SVF require Medical Review?\' and \'Does this SVF require QC?\' fields');
                        }
                    }
                    if(signalRec.SER_Medical_Safety_Advisor__c == null || signalRec.Date_Medical_Review_Completed_SER__c == null || signalRec.SER_SM_QC_Reviewer__c == null || signalRec.Date_QC_Completed_SER__c == null){
                        if(signalRec.Does_this_SER_require_Medical_Review__c == 'Yes' && signalRec.Does_this_SER_require_QC__c == 'Yes'){
                            signalRec.addError('\'SER Medical Safety Advisor\', \'Date Medical Review Completed (SER)\', \'SER SM QC Reviewer\', \'Date QC Completed (SER)\' cannot be empty if \'Yes\' is selected from the \'Does this SER require Medical Review?\' and \'Does this SER require QC?\' fields');
                        }
                        if(((signalRec.Does_this_SER_require_Medical_Review__c == 'No' || signalRec.Does_this_SER_require_Medical_Review__c == 'NA') && signalRec.Does_this_SER_require_QC__c == 'Yes') || (signalRec.Does_this_SER_require_Medical_Review__c == 'Yes' && (signalRec.Does_this_SER_require_QC__c == 'No' || signalRec.Does_this_SER_require_QC__c == 'NA'))){
                            signalRec.addError('\'SER Medical Safety Advisor\', \'Date Medical Review Completed (SER)\', \'SER SM QC Reviewer\', \'Date QC Completed (SER)\' cannot be empty if \'Yes\' is selected from the \'Does this SER require Medical Review?\' or \'Does this SER require QC?\' fields');
                        }
                    }
                }
                validationErrorMessage = '';
                if(signalRec.Signal_Status__c == CON_PSA.SIGNAL_STATUS_CLOSED 
                   || signalRec.Signal_Status__c == CON_PSA.SIGNAL_STATUS_NOT_VALIDATED){
                       if(signalRec.Does_this_SVF_require_Medical_Review__c == null ){
                           validationErrorMessage += '\'Does this SVF require Medical Review?\'';
                       }
                       if(signalRec.Does_this_SVF_require_QC__c == null ){
                           validationErrorMessage += '\'Does this SVF require QC?\'';
                       }
                       //IQVIAPSA-7141
                       if(signalRec.Validation_Outcome__c == CON_PSA.SIGNAL_PICKLIST_FIELD_VALUE_SIGNAL_VALIDATED){
                           if(signalRec.Does_this_SER_require_Medical_Review__c == null){
                               validationErrorMessage += '\'Does this SER require Medical Review?\''; 
                           }
                           if(signalRec.Does_this_SER_require_QC__c == null ){
                               validationErrorMessage += '\'Does this SER require QC?\'';
                           }
                       }
                       if(validationErrorMessage != ''){
                           signalRec.addError('When the \'Signal Status\' = \'Not Validated\' or \'Closed\' then the following fields '+validationErrorMessage+' cannot be empty');
                       }
                   }
                validationErrorMessage = '';
                // Validation of IQVIAPSA-6569, IQVIAPSA-6570, IQVIAPSA-6574, IQVIAPSA-6575
                If(signalRec.Validation_Outcome__c == CON_PSA.SIGNAL_PICKLIST_FIELD_VALUE_SIGNAL_VALIDATED 
                   && (signalRec.Signal_Status__c == CON_PSA.SIGNAL_STATUS_NOT_VALIDATED 
                       || signalRec.Signal_Status__c == CON_PSA.SIGNAL_STATUS_CLOSED))
                {
                    if(signalRec.Does_this_SER_require_QC__c != null 
                       && signalRec.Does_this_SER_require_QC__c != CON_PSA.SIGNAL_PICKLIST_FIELD_VALUE_EQUALS_NO 
                       && signalRec.Date_SER_Draft_Sent_for_QC__c == null){
                           validationErrorMessage +=  '\'Date SER Draft Sent for QC\', ';
                       }
                    if(signalRec.Does_this_SER_require_QC__c != null 
                       && signalRec.Does_this_SER_require_QC__c != CON_PSA.SIGNAL_PICKLIST_FIELD_VALUE_EQUALS_NO 
                       && signalRec.Date_QC_Completed_SER__c == null){
                           validationErrorMessage +=  '\'Date QC Completed (SER)\', ';
                       }
                    if(signalRec.Does_this_SER_require_Medical_Review__c != null 
                       && signalRec.Does_this_SER_require_Medical_Review__c != CON_PSA.SIGNAL_PICKLIST_FIELD_VALUE_EQUALS_NO 
                       && signalRec.Date_SER_Draft_sent_for_Medical_Review__c == null){
                           validationErrorMessage +=  '\'Date SER Draft sent for Medical Review\', ';
                       }
                    if(signalRec.Does_this_SER_require_Medical_Review__c != null 
                       && signalRec.Does_this_SER_require_Medical_Review__c != CON_PSA.SIGNAL_PICKLIST_FIELD_VALUE_EQUALS_NO 
                       && signalRec.Date_Medical_Review_Completed_SER__c == null){
                           validationErrorMessage +=  '\'Date Medical Review Completed (SER)\', ';
                       }
                    if(signalRec.Incl_Signal_Eval_in_Metrics_Invoices__c != null 
                       && signalRec.Incl_Signal_Eval_in_Metrics_Invoices__c != CON_PSA.SIGNAL_PICKLIST_FIELD_VALUE_EQUALS_NO_SPECIFY_REASON 
                       && signalRec.Date_SER_Final_DraftReady_for_SMT_Review__c == null){
                           validationErrorMessage +=  '\'Date SER Final DraftReady for SMT Review\', ';
                       }
                    if(signalRec.Does_this_SVF_require_QC__c != null 
                       && signalRec.Does_this_SVF_require_QC__c != CON_PSA.SIGNAL_PICKLIST_FIELD_VALUE_EQUALS_NO 
                       && signalRec.Date_SVF_Draft_Sent_for_QC__c == null){
                           validationErrorMessage +=  '\'Date SVF Draft Sent for QC\', ';
                       }
                    if(signalRec.Does_this_SVF_require_QC__c != null 
                       && signalRec.Does_this_SVF_require_QC__c != CON_PSA.SIGNAL_PICKLIST_FIELD_VALUE_EQUALS_NO 
                       && signalRec.Date_QC_Completed_SVF__c == null){
                           validationErrorMessage +=  '\'Date QC Completed (SVF)\', ';
                       }
                    if(signalRec.Does_this_SVF_require_Medical_Review__c != null 
                       && signalRec.Does_this_SVF_require_Medical_Review__c != CON_PSA.SIGNAL_PICKLIST_FIELD_VALUE_EQUALS_NO 
                       && signalRec.Date_SVF_Draft_sent_for_Medical_Review__c == null){
                           validationErrorMessage +=  '\'Date SVF Draft sent for Medical Review\', ';
                       }
                    if(signalRec.Does_this_SVF_require_Medical_Review__c != null 
                       && signalRec.Does_this_SVF_require_Medical_Review__c != CON_PSA.SIGNAL_PICKLIST_FIELD_VALUE_EQUALS_NO 
                       && signalRec.Date_Medical_Review_Completed_SVF__c == null){
                           validationErrorMessage +=  '\'Date Medical Review completed (SVF)\', ';
                       }
                    if((signalRec.Signal_Validation_Complexity__c != null 
                        && signalRec.Signal_Validation_Complexity__c != CON_PSA.SIGNAL_PICKLIST_FIELD_VALUE_EQUALS_ADMINISTRATIVE
                        && signalRec.Signal_Validation_Complexity__c != CON_PSA.SIGNAL_PICKLIST_FIELD_VALUE_EQUALS_NOT_APPLICABLE)
                       && signalRec.Date_SVF_Final_DraftReady_for_SMT_Review__c == null){
                           validationErrorMessage +=  '\'Date SVF Final Draft Ready for SMT Review\' ';
                       }
                    if(validationErrorMessage != ''){
                        signalRec.addError(validationErrorMessage+' field cannot be empty as the '+'\''+'Signal Status'+'\''+' is '+'\''+ 'Not Validated or Closed' + '\'' + '.');
                    }
                    
                }
            }
        }
    }
    
    /**
    * This method will insert record in Audit Log on Inserting/Updating Signal__c record
    **/
    public static void insertAuditLogOnUpdate(List<Signal__c> updatedList,Map<Id,Signal__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Signal__c
    **/
    public static void insertAuditLog(List<Signal__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    }
    
    /**
    * This method will insert Project Task record based on certain condition on Signal record.
    **/
    public static void createDeliverable(List<Signal__c> updatedList,Map<Id,Signal__c> existingRecords){
        List<Signal__c> signalValidationListForDeliverables = new List<Signal__c>();
        List<Signal__c> signalEvaluationListForDeliverables = new List<Signal__c>();
        Set<Id> svProjectIdSet = new Set<Id>();
        Set<Id> seProjectIdSet = new Set<Id>();
        String serviceCode = '';
        List<pse__Project_Task__c> projectTaskSignalValidationList = new List<pse__Project_Task__c>();
        List<pse__Project_Task__c> projectTaskSignalEvaluationList = new List<pse__Project_Task__c>();
        List<pse__Project_Task__c> projectTaskToBeInsertedList = new List<pse__Project_Task__c>();
        for(Signal__c signalRecord : updatedList) {
            if(signalRecord.Incl_Signal_Val_in_Metrics_Invoices__c == 'Yes' 
               && (signalRecord.Validation_Date__c != null) 
               && (existingRecords == null 
                   || (existingRecords.containsKey(signalRecord.id) 
                       && (existingRecords.get(signalRecord.id).Incl_Signal_Val_in_Metrics_Invoices__c != signalRecord.Incl_Signal_Val_in_Metrics_Invoices__c 
                           || existingRecords.get(signalRecord.id).Validation_Date__c != signalRecord.Validation_Date__c)
                      )
                  )
              ){
                  if(signalRecord.SVF_SM_Specialist__c == null){
                      signalRecord.addError('Please Enter the resource in SVF SM Specialist');
                  }else{
                      signalValidationListForDeliverables.add(signalRecord);
                      svProjectIdSet.add(signalRecord.Project__c);
                      serviceCode = CON_PSA.PROJ_ServiceCode_SM3;
                  }   
              }
            if(signalRecord.Incl_Signal_Eval_in_Metrics_Invoices__c == 'Yes' 
               && signalRecord.Date_Closed_Evaluation_Completed__c != null 
               && (existingRecords == null 
                   || (existingRecords.containsKey(signalRecord.id) 
                       && (existingRecords.get(signalRecord.id).Incl_Signal_Eval_in_Metrics_Invoices__c != signalRecord.Incl_Signal_Eval_in_Metrics_Invoices__c 
                           || existingRecords.get(signalRecord.id).Date_Closed_Evaluation_Completed__c != signalRecord.Date_Closed_Evaluation_Completed__c)
                      )
                  )
              ){
                  if(signalRecord.SER_SM_Specialist__c == null){
                      signalRecord.addError('Please Enter the resource in SER SM Specialist');
                  }else{
                      signalEvaluationListForDeliverables.add(signalRecord);
                      seProjectIdSet.add(signalRecord.Project__c);
                      serviceCode = CON_PSA.PROJ_ServiceCode_SM4;
                  }
              }
        }
        if(signalValidationListForDeliverables.size() > 0) {
            projectTaskSignalValidationList = getDeliverablesList(signalValidationListForDeliverables,svProjectIdSet, CON_PSA.MILESTONE_Name_Signal_Validation , CON_PSA.PROJ_Resource_SVF_Specialist);
        	projectTaskToBeInsertedList.addAll(projectTaskSignalValidationList);
        }
        if(signalEvaluationListForDeliverables.size() > 0) {
            projectTaskSignalEvaluationList = getDeliverablesList(signalEvaluationListForDeliverables,seProjectIdSet, CON_PSA.MILESTONE_Name_Signal_Evaluation ,CON_PSA.PROJ_Resource_SER_Specialist);
        	projectTaskToBeInsertedList.addAll(projectTaskSignalEvaluationList);
        }
        if(projectTaskToBeInsertedList != null && projectTaskToBeInsertedList.size() > 0){
            insert projectTaskToBeInsertedList;
        }
    }
    
    private static List<pse__Project_Task__c> getDeliverablesList(List<Signal__c> signalList,Set<Id> projectIdSet, String milestoneName, String resource) {
        List<pse__Project_Task__c> returndeliverablesList = new List<pse__Project_Task__c>();
        Map<Id,List<pse__Project_Task__c>> signalIdToExistingDeliverablesMap = new Map<Id,List<pse__Project_Task__c>>();
        Set<String> deliverableFields = new Set<String>{'Id','pse__Milestone__r.Name','Service__r.Name','Project_Code__c','Signal__c','Product_Name__c','Identifier__c', 'pse__Status__c', 'Resource__c', 'Service_Code__c'};
        Id deliverableRecordTypeId = Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByDeveloperName().get('RDS_Deliverable').getRecordTypeId();    
        Set<Id> signalIdSet = new Set<Id>();
        //Get map of Signal records to access Parent record's fields.
        for(Signal__c signal : signalList) {
            signalIdSet.add(signal.id);
        }
        Map<Id,Signal__c> signalMap = new Map<Id,Signal__c>([SELECT Id, Account__r.Name, Product__r.Name
                                                         FROM Signal__c 
                                                         WHERE Id in: signalIdSet]);
        //Get milestones of the related Project of Signal.
        Map<Id, List<pse__Milestone__c>> projectMilestoneListMap = new SLT_Milestone().selectMilestoneListByProjectId(projectIdSet,new Set<String> {'Id','Name','pse__Project__c','Service__r.Name'});
        //Service milestone and service name map
        Map<String, Id> serviceNameMilestoneMap = new Map<String,Id>();
        
        //Get existing deliverables to update
        Set<Id> signalIdToLookUpDeliverables = new Map<Id,Signal__c>(signalList).keySet(); 
        List<pse__Project_Task__c> existingDeliverables = new SLT_Project_Task().getProjectTasksBySignal(signalIdToLookUpDeliverables, deliverableFields);
        
        //Create map of Signal Id to existing Deliverable List.
        if(existingDeliverables.size() > 0){
            for(pse__Project_Task__c deliverable : existingDeliverables){
                if(!signalIdToExistingDeliverablesMap.containsKey(deliverable.Signal__c)){
                    signalIdToExistingDeliverablesMap.put(deliverable.Signal__c, new List<pse__Project_task__c>());
                    signalIdToExistingDeliverablesMap.get(deliverable.Signal__c).add(deliverable);
                }
                else{
                    signalIdToExistingDeliverablesMap.get(deliverable.Signal__c).add(deliverable);
                }
            }
        }
        
        //Check if existing deliverables exist or are system generated, if not then we need to create one.
        pse__Project_Task__c deliverable = new pse__Project_Task__c();
        Boolean deliverableExists = false;
        for(Signal__c signal : signalList) {
            
            //Get milestones list of the related project of Signal.
            if(projectMilestoneListMap.containsKey(signal.Project__c)) {
                for(pse__Milestone__c milestone : projectMilestoneListMap.get(signal.Project__c)){
                    serviceNameMilestoneMap.put( milestone.Service__r.Name, milestone.Id);
                }
             }
            //Check if existing deliverable is present on the milestone for which we want to create deliverable.
            //If not , then check if the desired milestones exist on the project.
            if(signalIdToExistingDeliverablesMap.containsKey(signal.id)) {
                for(pse__Project_Task__c pt : signalIdToExistingDeliverablesMap.get(signal.id)) {
                    if(pt.Service__r.Name == milestoneName){
                        deliverableExists = true;
                        break;
                    }
                }
            }
               
            //Check if required milestone is present on the project.
            if(!deliverableExists) { 
                Boolean milestoneExists = true;
                String uniqueString =signal.Signal_Unique_ID__c;
                String secondString = uniqueString.remove(uniqueString.substringBefore('-'));
                String firstString = uniqueString.substringBefore('-').left(3);
                String signalName = firstString+secondString;
                if(serviceNameMilestoneMap.containsKey(milestoneName)){
                    deliverable.pse__Milestone__c = serviceNameMilestoneMap.get(milestoneName);
                       
                    deliverable.Name = milestoneName + '-' +signalName ;
                }else if(serviceNameMilestoneMap.containsKey('SM Miscellaneous')){
                    deliverable.pse__Milestone__c = serviceNameMilestoneMap.get('SM Miscellaneous');
                    //deliverable.Name = 'SM Miscellaneous' + '-' + signal.Name + '-'+milestoneName;
                    deliverable.Name = 'SM Miscellaneous' + '-' + signalName + '-'+milestoneName;
                }
                else {
                    milestoneExists = false;
                }
                 
                if(milestoneExists) {
                    deliverable.RecordTypeId = deliverableRecordTypeId;	
                    deliverable.Signal__c = signal.Id;
                    deliverable.Account_Name__c = signalMap.get(signal.Id).Account__r.Name;
                    deliverable.Product_Name__c = signalMap.get(signal.Id).Product__r.Name;
                    deliverable.Signal_Term__c = signal.Signal_Term__c;
                    deliverable.Evaluation_Due_Date__c = signal.Evaluation_Due_Date__c;
                    deliverable.Signal_Status__c = signal.Signal_Status__c;
                    deliverable.Signal_Id__c = '<a href=/lightning/r/Signal__c/'+ signal.Id +'/view>'+ signalName+ '</a>';
                    //deliverable.Date_Completed__c = signal.;
                    //deliverable.Identifier__c =  milestoneName+'-'+signal.name;
                    deliverable.Identifier__c = deliverable.Name;
                    deliverable.pse__Project__c = signal.Project__c;
                    deliverable.pse__Status__c = 'Complete';
                    deliverable.System_Generated_Deliverable__c = true;
                    deliverable.Validation_Due_Date__c = signal.Validation_Due_Date__c;
                    deliverable.Validation_Date__c = signal.Validation_Date__c;
                    deliverable.Date_Closed_Evaluation_Completed__c = signal.Date_Closed_Evaluation_Completed__c;
                    if(resource == CON_PSA.PROJ_Resource_SVF_Specialist){
                        deliverable.Resource__c = signal.SVF_SM_Specialist__c;                        
                    }else if(resource == CON_PSA.PROJ_Resource_SER_Specialist){
                        deliverable.Resource__c = signal.SER_SM_Specialist__c;
                    }
                    returndeliverablesList.add(deliverable);
                }             
                else{
                    signal.addError('SM MISX or '+milestoneName+' service milestone does not exist on this project, deliverables cannot be created, please make sure either of these two service milestones exist on the project');
                }                
            }
        } 
        return returndeliverablesList;
    }
    
    /**
    * This method will check whether the given user has an active assignment on the given project.
    **/
    public static boolean hasActiveAssignment(List<pse__Assignment__c> rltdAssgnmntList, Id resourceId){
        boolean hasActiveAssignment = false;
        if(rltdAssgnmntList.size() > 0){
            for(pse__Assignment__c assignment : rltdAssgnmntList){
            if(resourceId == assignment.pse__Resource__c && assignment.Active__c == true){
                hasActiveAssignment = true;
            }
        }
        }
        
        return hasActiveAssignment;
    }
    
    private static Map<String,Map<String,PSA_Event__c>> dateFieldToPSAEventMap;
    private static List<PSA_Event__c> psaEvents;
    private static Set<String> eventDateFields;
    
    public static void synchronizeProjectEvents(List<Signal__c> updatedList, Map<Id,Signal__c> existingRecords){
        
        List<Signal__c> signalsToSync = new List<Signal__c>();
        for(Signal__c sigRec : updatedList){
            if(sigRec.Evaluation_Due_Date__c != null || sigRec.Validation_Due_Date__c != null){
                signalsToSync.add(sigRec);
            }
        }
        fetchPSAEvents();
        buildDateFieldMap();
        Id userId = UserInfo.getUserId();

        try {
            setEventDateFields();
        } catch (Exception e) {
            Signal__c sigRec = signalsToSync.get(0);
            sigRec.addError( e.getMessage());
            return;
        }

        Set<String> signalFields = Schema.SObjectType.Signal__c.fields.getMap().keySet();
        Map<Id,Map<Id,Project_Event__c>> reportToProjectEventMap = getProjectEventsBySignals(signalsToSync);
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Project_Event__c.SObjectType }
        );

        for(Signal__c sigRec : signalsToSync){
            //String recordTypeName = Schema.SObjectType.Signal__c.getRecordTypeInfosById().get(sigRec.RecordTypeId).getDeveloperName();
            for(String dateField : eventDateFields){
                Date dateFieldContents = (Date) sigRec.get(dateField);
                PSA_Event__c psaEvent = ( dateFieldToPSAEventMap.get(dateField) != null) ? dateFieldToPSAEventMap.get(dateField).get('NA') : null;
                
                Project_Event__c projectEvent= ( reportToProjectEventMap.get(sigRec.Id) != null && psaEvent != null) ? reportToProjectEventMap.get(sigRec.Id).get(psaEvent.Id) : null;

                if( dateFieldContents != null && psaEvent != null ) {

                    try {
                        validatePSAEvent(psaEvent, signalFields);
                    } catch (signalFieldException e){
                        sigRec.addError(e.getMessage());
                        continue;
                    }

                    if(projectEvent == null){
                        projectEvent = populateProjectEvent(sigRec, psaEvent);
                        uow.registerNew(projectEvent);
                    } else {
                        //Note, this will register all existing Project Events as dirty vs checking every field-- a SOQL vs CPU tradeoff?
                        //TODO - Remove the SOQL query from populate project event and check events for needing update before updating
                        populateProjectEvent(sigRec, psaEvent, projectEvent);
                        uow.registerDirty(projectEvent);
                    }
                }

                else if ( projectEvent != null ){
                    //Note, this will catch any Project Events whose PSA Event now indicate a blank date field. 
                    projectEvent.ownerId = userId;
                    uow.registerDirty(projectEvent);
                    uow.registerDeleted(projectEvent);
                }
            }
        }
        uow.commitWork();

    }

    /**
     * This method retrieves all Project_Event__c objects for the Signals, and maps them by signal Id followed by PSA Event Id
     * This allows us to validate them against both the Signals and the PSA Event, in case either has changed
     * @params List<Signal__c> reports
     * @return Map<Id,Map<Id,Project_Event__c>>
     */ 
    private static Map<Id,Map<Id,Project_Event__c>> getProjectEventsBySignals(List<Signal__c> signal ){
        Set<Id> reportIds = new Set<Id>(new Map<Id,Signal__c>(signal).keySet());
        Set<String> eventFields = new SLT_Project_Event().getDefaultFields();
        Map<Id,Map<Id,Project_Event__c>> projectEventsMap = new Map<Id,Map<Id,Project_Event__c>>();
        List<Project_Event__c> events = new SLT_Project_Event().getProjectEventsBySignal(reportIds, eventFields);
        for(Project_Event__c event : events){
            if(projectEventsMap.get(event.Signal__c) == null){
                projectEventsMap.put(event.Signal__c, new Map<Id,Project_Event__c>());
            }
            projectEventsMap.get(event.Signal__c).put(event.PSA_Event__c, event);
        }
        return projectEventsMap;
    }
    
    /**
     * This method builds a map of Planned_Date_Field__c to RecordTypeName to PSA_Event__c
     * It allows you to filter PSA Events by both field and recordtype when trying to match up with signal
     */
    private static void buildDateFieldMap(){
        fetchPSAEvents();
        if(dateFieldToPSAEventMap == null){
            dateFieldToPSAEventMap = new Map<String,Map<String,PSA_Event__c>>(); 
        }
        for(PSA_Event__c event : psaEvents){
            if(dateFieldToPSAEventMap.get(event.Planned_Date_Field__c) == null){
                dateFieldToPSAEventMap.put(event.Planned_Date_Field__c, new Map<String, PSA_Event__c>());
            }
            Map<String, PSA_Event__c> recordTypeMap = dateFieldToPSAEventMap.get(event.Planned_Date_Field__c);
            recordTypeMap.put('NA', event);
            /*List<String> recordTypes = event.RecordTypes__c.split(',');
            for(String recordType : recordTypes){
                recordTypeMap.put(recordType, event);
            }*/
        }
    }
    
    /**
     * Retrieves all the PSA Events that could be applied to an signal
     */
    private static void fetchPSAEvents(){
        if(psaEvents == null){
            psaEvents =  new SLT_PSA_Event().getAllPSAEvents('Signal__c');
        }
    }
    
    /**
     * Compiles a list of the Due Date fields from a list of PSA events
     * These are the fields that we will be examining on signal for changes
     */
    private static void setEventDateFields(){
        Set<String> signalFields = Schema.SObjectType.Signal__c.fields.getMap().keySet();
        Set<String> invalidFields = new Set<String>();
        fetchPSAEvents();

        if(eventDateFields == null){
            eventDateFields = new Set<String>();
        }
        for(PSA_Event__c event : psaEvents){
            if(event.Planned_Date_Field__c != null) {
                if ( !signalFields.contains( event.Planned_Date_Field__c.toLowerCase() ) ) {
                    invalidFields.add(event.Name+':'+event.Planned_Date_Field__c);
                } else {
                    eventDateFields.add(event.Planned_Date_Field__c);
                }
            }
        }
    
        if(invalidFields.size() > 0){
            throw new signalFieldException('Contact your PSA Admin. Found bad PSA Event Planned Date fields: '+String.join( new List<String>(invalidFields), ',' ) );
        }
    }
    
    /**
     * Validates that the target fields in a PSA Event are valid field names
     * @params PSA_Event__c psaEvent
     */
    static void validatePSAEvent( PSA_Event__c psaEvent, Set<String> validFields ){
        Set<String> invalidFields = new Set<String>();
        Set<String> psaEventFieldValues = new Set<String>();
        Set<String> psaEventFieldNames = new Set<String>{
            'Actual_Date_Field__c',
            'Planned_Date_Field__c',
            'Primary_Resource_Field__c',
            'Secondary_Resource_Field__c',
            'Other_Resource_Field__c'
        };

        for ( String fieldName : psaEventFieldNames ){
            if ( psaEvent.get(fieldName) != null ){
                psaEventFieldValues.add( String.valueOf( psaEvent.get(fieldName) ) );
            }
        }
        if(psaEvent.Stakeholder_Fields__c != null && psaEvent.Stakeholder_Fields__c != ''){
            for ( String stakeholder : psaEvent.Stakeholder_Fields__c.split(',')) {
            psaEventFieldValues.add( stakeholder.trim() );
        }
        }
        
        for ( String fieldValue : psaEventFieldValues ) {
            if ( !validFields.contains( fieldValue.toLowerCase() ) ) {
                invalidFields.add( fieldValue );
            }
        }

        if(invalidFields.size() > 0){
            throw new signalFieldException('Contact your PSA Admin. Found invalid field data for PSA Event '+psaEvent.Name+': '+String.join( new List<String>(invalidFields), ',' ) );
        }
    }
    
    /**
     * Populate fields on a project event given an aggregate report and a psa event
     * @params Signal__c signal
     * @params PSA_Event__c psaEvent
     * @params Project_Event__c projectEvent
     * 
     * @return Project_Event__c
     */
    private static Project_Event__c populateProjectEvent( Signal__c signal, PSA_Event__c psaEvent){
        return populateProjectEvent( signal, psaEvent, new Project_Event__c());
    }

    private static Project_Event__c populateProjectEvent( Signal__c signal, PSA_Event__c psaEvent, Project_Event__c projectEvent) {

        if ( psaEvent.Actual_Date_Field__c != null && signal.get(psaEvent.Actual_Date_Field__c) != null) {
            projectEvent.Event_Actual_Date__c = (Date)signal.get(psaEvent.Actual_Date_Field__c);
        } else {
            projectEvent.Event_Actual_Date__c = null;
        }

        if ( psaEvent.Planned_Date_Field__c != null && signal.get(psaEvent.Planned_Date_Field__c) != null) { 
                projectEvent.Event_Due_Date__c = (Date)signal.get(psaEvent.Planned_Date_Field__c);
        } else {
            projectEvent.Event_Due_Date__c = null;
        }

        if ( psaEvent.Planned_Date_Field__c != null && signal.get(psaEvent.Planned_Date_Field__c) != null && psaEvent.Notification_Offset__c != null) {
            projectEvent.Notification_Date__c = ((Date)signal.get(psaEvent.Planned_Date_Field__c)).addDays(Integer.valueOf(psaEvent.Notification_Offset__c));
        } else {
            projectEvent.Notification_Date__c = null;
        }

        projectEvent.Primary_Resource__c = (psaEvent.Primary_Resource_Field__c != null) ? String.valueOf(signal.get(psaEvent.Primary_Resource_Field__c)) : null;
        projectEvent.Secondary_Resource__c = (psaEvent.Secondary_Resource_Field__c != null) ? String.valueOf(signal.get(psaEvent.Secondary_Resource_Field__c)) : null;
        projectEvent.Other_Resource__c = (psaEvent.Other_Resource_Field__c != null) ? String.valueOf(signal.get(psaEvent.Other_Resource_Field__c)) : null;
        projectEvent.Stakeholder_ID__c = getStakeholderIds(signal, psaEvent.Stakeholder_Fields__c);

        projectEvent.PSA_Event__c = psaEvent.Id;
        projectEvent.Signal__c = signal.Id;
        projectEvent.Project__c = (signal.Project__c != null) ? String.valueOf(signal.Project__c) : null;
        return projectEvent;
    }
    
    /**
     * update PJE on change of recipients so the updated recipient receives the notification
     * 
     */
    public static void updtRltdPJEToUpdtReciepients(List<Signal__c> updatedList, Map<Id,Signal__c> existingRecords){
        List<Signal__c> sigToUpdtLst = new List<Signal__c>();
        fetchPSAEvents();
        
        for(PSA_Event__c event : psaEvents){
            for(Signal__c sig : updatedList){
                Boolean plannedDtChanged = false, primaryResChanged = false, secResChanged = false, otherResChanged = false;
                if(event.Planned_Date_Field__c != null){
                    plannedDtChanged = sig.get(event.Planned_Date_Field__c) != (existingRecords.get(sig.Id)).get(event.Planned_Date_Field__c);
                }
                if(event.Primary_Resource_Field__c != null){
                    primaryResChanged = sig.get(event.Primary_Resource_Field__c) != (existingRecords.get(sig.Id)).get(event.Primary_Resource_Field__c);
                }
                if(event.Secondary_Resource_Field__c != null){
                    secResChanged = sig.get(event.Secondary_Resource_Field__c) != (existingRecords.get(sig.Id)).get(event.Secondary_Resource_Field__c);
                }           
                if(event.Other_Resource_Field__c != null){
                    otherResChanged = sig.get(event.Other_Resource_Field__c) != (existingRecords.get(sig.Id)).get(event.Other_Resource_Field__c);
                }
                if(plannedDtChanged || primaryResChanged || secResChanged || otherResChanged){
                    if(!sigToUpdtLst.contains(sig)){
                       sigToUpdtLst.add(sig);
                    }
                }
            }
        }
        
        Set<Id> reportIds = new Set<Id>(new Map<Id,Signal__c>(sigToUpdtLst).keySet());
        Set<String> eventFields = new SLT_Project_Event().getDefaultFields();
        Map<Id,Date> projectEventsToActualDateMap = new Map<Id,Date>();
        List<Project_Event__c> events = new SLT_Project_Event().getProjectEventsBySignal(reportIds, eventFields);
        
        Map<Id, List<Project_Event__c>> sigToPJEMap = new Map<Id, List<Project_Event__c>>();
        for (Project_Event__c pje : events) {
            List<Project_Event__c> tempMSList = sigToPJEMap.get(pje.Signal__c);

            if (tempMSList != null) {
                tempMSList.add(pje);
                sigToPJEMap.put(pje.Signal__c,tempMSList);
            } else {
                sigToPJEMap.put(pje.Signal__c, new List<Project_Event__c>{pje});
            }
        }
        
        List<Project_Event__c> allPjeEvents = new List<Project_Event__c>();
        for(Signal__c sig : sigToUpdtLst){
            if( sigToPJEMap.containsKey( sig.Id ) && sigToPJEMap.get(sig.Id) != null ){
                List<Project_Event__c> pjeEvents = sigToPJEMap.get(sig.Id);
                for(Project_Event__c pje : pjeEvents){
                    projectEventsToActualDateMap.put(pje.Id, pje.Event_Actual_Date__c);
                    allPjeEvents.add(pje);
                }
            }
        }
        
        for(Project_Event__c pJeAll : allPjeEvents){
            pJeAll.Event_Actual_Date__c = System.Today();
        }
        update allPjeEvents;
                
        for(Project_Event__c pJeAll : allPjeEvents){
            pJeAll.Event_Actual_Date__c = (projectEventsToActualDateMap.get(pJeAll.Id) != null) ? ((Date) projectEventsToActualDateMap.get(pJeAll.Id)) : null;
        }
        update allPjeEvents;

    }  
    
    /**
     * Retrieve user Ids for stakeholders based on a list of fields to check
     * @return String
     */
    private static String getStakeholderIds(Signal__c signal, String fields){
        Set<Id> contactIds = new Set<Id>();
        String ids = '';
        if(fields != null && fields !=''){
           for(String field : fields.split(',')){
            String fieldName = field.trim();
            if(signal.get(fieldName) != null && signal.get(fieldName) InstanceOf Id){
                contactIds.add((Id)signal.get(fieldName));
            }
        }
        
        for( Contact stakeholder : new SLT_Contact().selectByContactIdList(contactIds, new Set<String>{'pse__Salesforce_User__c'}) ){
            if(ids != ''){
                ids += ',';
            }
            ids += String.valueOf(stakeholder.pse__Salesforce_User__c);
        } 
        }
        return ids;
    }
    
    /*
     * IQVIAPSA-6569, IQVIAPSA-6570, IQVIAPSA-6574, IQVIAPSA-6575
     */
    public static void sendEmailNotification(List<Signal__c> newList, Map<Id,Signal__c> oldMap){
        List<Workflow_Email_Record__c> workflowEmailRecList = new List<Workflow_Email_Record__c>();
        String emailSubject ='';
        String validationErrorMessage = '';
        String futureDateValidationMsg = '';
        String emailOverallBodyContent = '';
        Set<Id> signalIdSet = new Set<Id>();
        Workflow_Email_Record__c objWorkFlowEmail;
        String uniqueKey = '';
        Date workingDate;
        Signal__c signalRecord;
        Set<String> holidayList = new Set<String>();
        Set<Id> smSpecialistIdSet = new Set<Id>();
        List<Contact> resourceList = new List<Contact>();
        Map<Id, pse__HolidayObj__c> holidayIdToHolidayRecordMap = new Map<Id, pse__HolidayObj__c>();
        Map<Id, Set<String>> workCalendarIdToHolidayDateSetMap = new Map<Id, Set<String>>();
        Set<Id> workCalendarIdSet = new Set<Id>();
        Map<String, String> resourceIdToWorkCalendarIdMap = new Map<String, String>();
        Map<String, Set<Id>> uniqueKeyToSignalIdSetMap = new Map<String, Set<Id>>();
        Map<Id, Signal__c> signalIdToSendToEmailSignalMap = new Map<Id, Signal__c>();
        Integer content1FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.content_1__c.getLength();
        Integer content2FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.content_2__c.getLength();
        Set<String> signalFieldSet = new Set<String>{'Id', 'Name', 'SVF_Medical_Safety_Advisor__r.Email', 
            'SM_Service_Line_Lead_New__r.Email', 'Project_Code__c', 'Date_QC_Completed_SER__c', 'Date_SVF_Draft_Sent_for_QC__c',
            'SVF_SM_Specialist__r.Email', 'Account__r.Name', 'Date_QC_Completed_SVF__c', 'Date_Medical_Review_Completed_SVF__c',
            'Product__r.Name', 'SVF_SM_Specialist__r.Name', 'Date_SVF_Draft_sent_for_Medical_Review__c', 'Signal_Term__c',
            'SVF_SM_QC_Reviewer__r.Email', 'SVF_SM_QC_Reviewer__r.Email', 'Date_SVF_Final_DraftReady_for_SMT_Review__c',
            'SVF_SM_QC_Reviewer__r.Name', 'SVF_Medical_Safety_Advisor__r.Email', 'Date_SER_Draft_Sent_for_QC__c',
            'SER_SM_QC_Reviewer__r.Email', 'SER_SM_Specialist__r.Email', 'SER_SM_Specialist__r.Name', 'SER_SM_QC_Reviewer__r.Name',
            'Signal_Document_Link__c', 'Signal_Document_Name__c', 'Signal_Unique_ID__c','Date_SER_Draft_sent_for_Medical_Review__c',
            'SER_Medical_Safety_Advisor__r.Email','Date_SER_Final_DraftReady_for_SMT_Review__c','Date_Medical_Review_Completed_SER__c'
            };
            Set<String> contactFieldSet = new Set<String>{'Id', 'pse__Work_Calendar__c'};
            Set<String> holidayFieldSet = new Set<String>{'Id', 'Name', 'pse__Date__c', 'pse__Work_Calendar__c'};
            for(Signal__c signal : newList)
            {
                validationErrorMessage = '';
                futureDateValidationMsg = '';
                if( (trigger.isInsert || (trigger.isUpdate && signal.Date_SVF_Draft_Sent_for_QC__c != oldMap.get(signal.Id).Date_SVF_Draft_Sent_for_QC__c))
                   && signal.Date_SVF_Draft_Sent_for_QC__c != null 
                   && signal.SM_Service_Line_Lead_New__c != null )
                {
                    signalIdSet.add(signal.Id);
                    smSpecialistIdSet.add(signal.SM_Service_Line_Lead_New__c);
                    if(uniqueKeyToSignalIdSetMap.containsKey(CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_QC)){
                        uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_QC).add(signal.Id);
                    }else{
                        uniqueKeyToSignalIdSetMap.put(CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_QC, new Set<Id>{signal.Id});
                    }
                }
                if((trigger.isInsert || (trigger.isUpdate && signal.Date_QC_Completed_SVF__c != oldMap.get(signal.Id).Date_QC_Completed_SVF__c)) 
                   && signal.Date_QC_Completed_SVF__c != null){
                       signalIdSet.add(signal.Id);
                       if(uniqueKeyToSignalIdSetMap.containsKey(CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SVF)){
                           uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SVF).add(signal.Id);
                       }else{
                           uniqueKeyToSignalIdSetMap.put(CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SVF, new Set<Id>{signal.Id});
                       }
                   }
                if((trigger.isInsert || (trigger.isUpdate && signal.Date_SVF_Draft_sent_for_Medical_Review__c != oldMap.get(signal.Id).Date_SVF_Draft_sent_for_Medical_Review__c))
                   && signal.Date_SVF_Draft_sent_for_Medical_Review__c != null
                   && signal.SM_Service_Line_Lead_New__c != null
                  ){
                      signalIdSet.add(signal.Id);
                      smSpecialistIdSet.add(signal.SM_Service_Line_Lead_New__c);
                      if(uniqueKeyToSignalIdSetMap.containsKey(CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_MEDICAL_REVIEW)){
                          uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_MEDICAL_REVIEW).add(signal.Id);
                      }else{
                          uniqueKeyToSignalIdSetMap.put(CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_MEDICAL_REVIEW, new Set<Id>{signal.Id});
                      }
                  }
                if((trigger.isInsert || (trigger.isUpdate && signal.Date_Medical_Review_Completed_SVF__c != oldMap.get(signal.Id).Date_Medical_Review_Completed_SVF__c))
                   && signal.Date_Medical_Review_Completed_SVF__c != null){
                       signalIdSet.add(signal.Id);
                       if(uniqueKeyToSignalIdSetMap.containsKey(CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SVF)){
                           uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SVF).add(signal.Id);
                       }else{
                           uniqueKeyToSignalIdSetMap.put(CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SVF, new Set<Id>{signal.Id});
                       }
                   }
                if((trigger.isInsert || (trigger.isUpdate && signal.Date_SVF_Final_DraftReady_for_SMT_Review__c != oldMap.get(signal.Id).Date_SVF_Final_DraftReady_for_SMT_Review__c))
                   && signal.Date_SVF_Final_DraftReady_for_SMT_Review__c != null){
                       signalIdSet.add(signal.Id);
                       if(uniqueKeyToSignalIdSetMap.containsKey(CON_PSA.CONSTANT_SIGNAL_DATE_SVF_FINAL_DARFT_READY_FOR_SMT_REVIEW)){
                           uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_SVF_FINAL_DARFT_READY_FOR_SMT_REVIEW).add(signal.Id);
                       }else{
                           uniqueKeyToSignalIdSetMap.put(CON_PSA.CONSTANT_SIGNAL_DATE_SVF_FINAL_DARFT_READY_FOR_SMT_REVIEW, new Set<Id>{signal.Id});
                       }
                   }
                if((trigger.isInsert || (trigger.isUpdate && signal.Date_SER_Draft_Sent_for_QC__c != oldMap.get(signal.Id).Date_SER_Draft_Sent_for_QC__c))
                   && signal.Date_SER_Draft_Sent_for_QC__c != null
                   && signal.SM_Service_Line_Lead_New__c != null){
                       signalIdSet.add(signal.Id);
                       smSpecialistIdSet.add(signal.SM_Service_Line_Lead_New__c);
                       if(uniqueKeyToSignalIdSetMap.containsKey(CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_FOR_QC)){
                           uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_FOR_QC).add(signal.Id);
                       }else{
                           uniqueKeyToSignalIdSetMap.put(CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_FOR_QC, new Set<Id>{signal.Id});
                       }
                   }
                if((trigger.isInsert || (trigger.isUpdate && signal.Date_QC_Completed_SER__c != oldMap.get(signal.Id).Date_QC_Completed_SER__c))
                   && signal.Date_QC_Completed_SER__c != null){
                       signalIdSet.add(signal.Id);
                       if(uniqueKeyToSignalIdSetMap.containsKey(CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SER)){
                           uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SER).add(signal.Id);
                       }else{
                           uniqueKeyToSignalIdSetMap.put(CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SER, new Set<Id>{signal.Id});
                       }
                   }
                // IQVIA 6575
                if((trigger.isInsert || (trigger.isUpdate && signal.Date_SER_Draft_sent_for_Medical_Review__c != oldMap.get(signal.Id).Date_SER_Draft_sent_for_Medical_Review__c))
                   && signal.Date_SER_Draft_sent_for_Medical_Review__c != null
                   && signal.SM_Service_Line_Lead_New__c != null){
                       signalIdSet.add(signal.Id);
                       smSpecialistIdSet.add(signal.SM_Service_Line_Lead_New__c);
                       if(uniqueKeyToSignalIdSetMap.containsKey(CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_SENT_FOR_MEDICAL_REVIEW)){
                           uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_SENT_FOR_MEDICAL_REVIEW).add(signal.Id);
                       }else{
                           uniqueKeyToSignalIdSetMap.put(CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_SENT_FOR_MEDICAL_REVIEW, new Set<Id>{signal.Id});
                       }
                   }
                if((trigger.isInsert || (trigger.isUpdate && signal.Date_Medical_Review_Completed_SER__c != oldMap.get(signal.Id).Date_Medical_Review_Completed_SER__c))
                   && signal.Date_Medical_Review_Completed_SER__c != null){
                       signalIdSet.add(signal.Id);
                       if(uniqueKeyToSignalIdSetMap.containsKey(CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SER)){
                           uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SER).add(signal.Id);
                       }else{
                           uniqueKeyToSignalIdSetMap.put(CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SER, new Set<Id>{signal.Id});
                       }
                   }
                if((trigger.isInsert || (trigger.isUpdate && signal.Date_SER_Final_DraftReady_for_SMT_Review__c != oldMap.get(signal.Id).Date_SER_Final_DraftReady_for_SMT_Review__c))
                   && signal.Date_SER_Final_DraftReady_for_SMT_Review__c != null){
                       signalIdSet.add(signal.Id);
                       if(uniqueKeyToSignalIdSetMap.containsKey(CON_PSA.CONSTANT_SIGNAL_DATE_SER_FINAL_DARFT_READY_FOR_SMT_REVIEW)){
                           uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_SER_FINAL_DARFT_READY_FOR_SMT_REVIEW).add(signal.Id);
                       }else{
                           uniqueKeyToSignalIdSetMap.put(CON_PSA.CONSTANT_SIGNAL_DATE_SER_FINAL_DARFT_READY_FOR_SMT_REVIEW, new Set<Id>{signal.Id});
                       }
                   }
            }
        if(signalIdSet.size() > 0){
            signalIdToSendToEmailSignalMap =  new SLT_PSA_Signal().getSignalMapBySignalIds(signalIdSet, signalFieldSet);
            
            if(smSpecialistIdSet.size() > 0){
                resourceList =  new SLT_Contact().selectByContactIdList(smSpecialistIdSet, contactFieldSet);
                for(Contact resource : resourceList){
                    if(resource.pse__Work_Calendar__c != null){
                        workCalendarIdSet.add(resource.pse__Work_Calendar__c);
                        resourceIdToWorkCalendarIdMap.put(resource.Id, resource.pse__Work_Calendar__c);
                    }
                }
                if(workCalendarIdSet.size() > 0){
                    holidayIdToHolidayRecordMap = new SLT_Holiday().getHolidayMapByWorkCalendarId(workCalendarIdSet, holidayFieldSet);
                    for(pse__HolidayObj__c holiday : holidayIdToHolidayRecordMap.values()){
                        if(holiday.pse__Date__c != null && holiday.pse__Work_Calendar__c != null){
                            if(workCalendarIdToHolidayDateSetMap.containsKey(holiday.pse__Work_Calendar__c)){
                                workCalendarIdToHolidayDateSetMap.get(holiday.pse__Work_Calendar__c).add(String.valueOf(holiday.pse__Date__c)); 
                            }else{
                                workCalendarIdToHolidayDateSetMap.put(holiday.pse__Work_Calendar__c, new Set<String> {String.valueOf(holiday.pse__Date__c)});
                            }
                        }
                    }
                }
            }
            if(signalIdToSendToEmailSignalMap.size() > 0){
                uniqueKey = '';
                emailSubject = '';
                emailOverallBodyContent = '';
                if(uniqueKeyToSignalIdSetMap.containskey(CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_QC)){
                    for(Id signalId : uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_QC)){
                        if(signalIdToSendToEmailSignalMap.containsKey(signalId)){
                            signalRecord = signalIdToSendToEmailSignalMap.get(signalId);
                            holidayList = null;
                            if(signalRecord.SM_Service_Line_Lead_New__c != null
                               && resourceIdToWorkCalendarIdMap.containsKey(signalRecord.SM_Service_Line_Lead_New__c)
                               && resourceIdToWorkCalendarIdMap.get(signalRecord.SM_Service_Line_Lead_New__c) != null
                               && workCalendarIdToHolidayDateSetMap.containsKey(resourceIdToWorkCalendarIdMap.get(signalRecord.SM_Service_Line_Lead_New__c))
                               && workCalendarIdToHolidayDateSetMap.get(resourceIdToWorkCalendarIdMap.get(signalRecord.SM_Service_Line_Lead_New__c)).size() > 0
                              ){
                                  holidayList = workCalendarIdToHolidayDateSetMap.get(resourceIdToWorkCalendarIdMap.get(signalRecord.SM_Service_Line_Lead_New__c));
                              }
                            workingDate = UTL_PSA.calculateWorkingDate(signalRecord.Date_SVF_Draft_Sent_for_QC__c, 1, holidayList);
                            if(signalRecord.Signal_Unique_ID__c != null){
                                uniqueKey = signalRecord.Signal_Unique_ID__c.left(3)+signalRecord.Signal_Unique_ID__c.right(13);
                            }
                            objWorkFlowEmail = new Workflow_Email_Record__c();
                            if(signalRecord.SVF_SM_QC_Reviewer__r.Email != null){
                                objWorkFlowEmail.To_Email_1__c = signalRecord.SVF_SM_QC_Reviewer__r.Email;
                            }
                            if(signalRecord.SM_Service_Line_Lead_New__r.Email != null){
                                objWorkFlowEmail.To_Email_2__c = signalRecord.SM_Service_Line_Lead_New__r.Email;
                            }
                            if(signalRecord.SVF_SM_Specialist__r.Email != null){
                                objWorkFlowEmail.To_Email_3__c = signalRecord.SVF_SM_Specialist__r.Email;
                            }
                            if(objWorkFlowEmail.To_Email_1__c != null || objWorkFlowEmail.To_Email_2__c != null || objWorkFlowEmail.To_Email_3__c != null  || Test.isRunningTest()){
                                emailSubject = signalRecord.Account__r.Name != null ? '[' + signalRecord.Account__r.Name.substring(0,3) + ']' : '';
                                emailSubject += ' ';
                                emailSubject += signalRecord.Product__r.Name != null ? '[' + signalRecord.Product__r.Name + ']' : '';
                                emailSubject += ' ';
                                emailSubject += uniqueKey != null ? '[' + uniqueKey + ']' : ''; 
                                emailSubject += ' SVF Draft Ready for QC ALERT.';     
                                emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Hi,<br><br>';
                                emailOverallBodyContent += 'The SVF Draft is ready for QC. Please act accordingly.'+'<br><br>'; 
                                emailOverallBodyContent+= createEmailBody(signalRecord, CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_QC, uniqueKey, workingDate);
                                objWorkFlowEmail.Email_Action__c = CON_PSA.SIGNAL_SEND_EMAIL_NOTIFICATION;
                                objWorkFlowEmail.Module_Name__c = CON_PSA.PSA_MODULE_NAME;
                                objWorkFlowEmail.Email_Subject__c = emailSubject;
                                if(emailOverallBodyContent.length() < content1FieldLength){
                                    objWorkFlowEmail.content_1__c = emailOverallBodyContent;
                                }else{
                                    objWorkFlowEmail.content_1__c = emailOverallBodyContent.substring(0, content1FieldLength - 1);
                                    if(emailOverallBodyContent.length() < content1FieldLength+content2FieldLength - 2 ) {
                                        objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, emailOverallBodyContent.length());
                                    } else {
                                        objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, content1FieldLength+content2FieldLength-2);
                                    }
                                }
                                workflowEmailRecList.add(objWorkFlowEmail);
                                emailOverallBodyContent = '';
                                emailSubject = '';
                            }
                        }
                        
                    }
                }
                if(uniqueKeyToSignalIdSetMap.containskey(CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SVF)){   
                    for(Id signalId : uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SVF)){
                        if(signalIdToSendToEmailSignalMap.containsKey(signalId)){
                            signalRecord = signalIdToSendToEmailSignalMap.get(signalId);
                            if(signalRecord.Signal_Unique_ID__c != null){
                                uniqueKey = signalRecord.Signal_Unique_ID__c.left(3)+signalRecord.Signal_Unique_ID__c.right(13);
                            }
                            objWorkFlowEmail = new Workflow_Email_Record__c();
                            if(signalRecord.SVF_SM_QC_Reviewer__r.Email != null){
                                objWorkFlowEmail.To_Email_1__c = signalRecord.SVF_SM_QC_Reviewer__r.Email;
                            }
                            if(signalRecord.SM_Service_Line_Lead_New__r.Email != null){
                                objWorkFlowEmail.To_Email_2__c = signalRecord.SM_Service_Line_Lead_New__r.Email;
                            }
                            if(signalRecord.SVF_SM_Specialist__r.Email != null){
                                objWorkFlowEmail.To_Email_3__c = signalRecord.SVF_SM_Specialist__r.Email;
                            }
                            if(objWorkFlowEmail.To_Email_1__c != null || objWorkFlowEmail.To_Email_2__c != null || objWorkFlowEmail.To_Email_3__c != null  || Test.isRunningTest()){
                                emailSubject = signalRecord.Account__r.Name != null ? '[' + signalRecord.Account__r.Name.substring(0,3) + ']' : '';
                                emailSubject += ' ';
                                emailSubject += signalRecord.Product__r.Name != null ? '[' + signalRecord.Product__r.Name + ']' : '';
                                emailSubject += ' ';
                                emailSubject += uniqueKey != null ? '[' + uniqueKey + ']' : ''; 
                                emailSubject += ' QC Review Completed ALERT';     
                                emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Hi,<br><br>';
                                emailOverallBodyContent += 'The quality review of the SVF draft is completed. Please act accordingly.'+'<br><br>'; 
                                emailOverallBodyContent+= createEmailBody(signalRecord, CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SVF, uniqueKey, null);
                                objWorkFlowEmail.Email_Action__c = CON_PSA.SIGNAL_SEND_EMAIL_NOTIFICATION;
                                objWorkFlowEmail.Module_Name__c = CON_PSA.PSA_MODULE_NAME;
                                objWorkFlowEmail.Email_Subject__c = emailSubject;
                                if(emailOverallBodyContent.length() < content1FieldLength){
                                    objWorkFlowEmail.content_1__c = emailOverallBodyContent;
                                }else{
                                    objWorkFlowEmail.content_1__c = emailOverallBodyContent.substring(0, content1FieldLength - 1);
                                    if(emailOverallBodyContent.length() < content1FieldLength+content2FieldLength - 2 ) {
                                        objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, emailOverallBodyContent.length());
                                    } else {
                                        objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, content1FieldLength+content2FieldLength-2);
                                    }
                                }
                                workflowEmailRecList.add(objWorkFlowEmail);
                                emailOverallBodyContent = '';
                                emailSubject = '';
                            }
                        }
                    }
                }
                if(uniqueKeyToSignalIdSetMap.containskey(CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_MEDICAL_REVIEW)){
                    for(Id signalId : uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_MEDICAL_REVIEW)){
                        if(signalIdToSendToEmailSignalMap.containsKey(signalId)){
                            signalRecord = signalIdToSendToEmailSignalMap.get(signalId);
                            holidayList = null;
                            if(signalRecord.SVF_SM_Specialist__c != null
                               && resourceIdToWorkCalendarIdMap.containsKey(signalRecord.SM_Service_Line_Lead_New__c)
                               && resourceIdToWorkCalendarIdMap.get(signalRecord.SM_Service_Line_Lead_New__c) != null
                               && workCalendarIdToHolidayDateSetMap.containsKey(resourceIdToWorkCalendarIdMap.get(signalRecord.SM_Service_Line_Lead_New__c))
                               && workCalendarIdToHolidayDateSetMap.get(resourceIdToWorkCalendarIdMap.get(signalRecord.SM_Service_Line_Lead_New__c)).size() > 0
                              ){
                                  holidayList = workCalendarIdToHolidayDateSetMap.get(resourceIdToWorkCalendarIdMap.get(signalRecord.SM_Service_Line_Lead_New__c));
                              }
                            workingDate = UTL_PSA.calculateWorkingDate(signalRecord.Date_SVF_Draft_sent_for_Medical_Review__c, 3, holidayList);
                            if(signalRecord.Signal_Unique_ID__c != null){
                                uniqueKey = signalRecord.Signal_Unique_ID__c.left(3)+signalRecord.Signal_Unique_ID__c.right(13);
                            }
                            objWorkFlowEmail = new Workflow_Email_Record__c();
                            if(signalRecord.SVF_SM_QC_Reviewer__r.Email != null){
                                objWorkFlowEmail.To_Email_1__c = signalRecord.SVF_SM_QC_Reviewer__r.Email;
                            }
                            if(signalRecord.SM_Service_Line_Lead_New__r.Email != null){
                                objWorkFlowEmail.To_Email_2__c = signalRecord.SM_Service_Line_Lead_New__r.Email;
                            }
                            if(signalRecord.SVF_SM_Specialist__r.Email != null){
                                objWorkFlowEmail.To_Email_3__c = signalRecord.SVF_SM_Specialist__r.Email;
                            }
                            if(signalRecord.SVF_Medical_Safety_Advisor__r.Email != null){
                                objWorkFlowEmail.To_Email_4__c = signalRecord.SVF_Medical_Safety_Advisor__r.Email;
                            }
                            if(objWorkFlowEmail.To_Email_1__c != null || objWorkFlowEmail.To_Email_2__c != null 
                               || objWorkFlowEmail.To_Email_3__c != null || objWorkFlowEmail.To_Email_4__c != null 
                               || Test.isRunningTest()){
                                   emailSubject = signalRecord.Account__r.Name != null ? '[' + signalRecord.Account__r.Name.substring(0,3) + ']' : '';
                                   emailSubject += ' ';
                                   emailSubject += signalRecord.Product__r.Name != null ? '[' + signalRecord.Product__r.Name + ']' : '';
                                   emailSubject += ' ';
                                   emailSubject += uniqueKey != null ? '[' + uniqueKey + ']' : ''; 
                                   emailSubject += ' Draft SVF Ready for Medical Review ALERT.';     
                                   emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Hi,<br><br>';
                                   emailOverallBodyContent += 'The SVF Draft is ready for Medical Review. Please act accordingly.'+'<br><br>'; 
                                   emailOverallBodyContent+= createEmailBody(signalRecord, CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_MEDICAL_REVIEW, uniqueKey, workingDate);
                                   objWorkFlowEmail.Email_Action__c = CON_PSA.SIGNAL_SEND_EMAIL_NOTIFICATION;
                                   objWorkFlowEmail.Module_Name__c = CON_PSA.PSA_MODULE_NAME;
                                   objWorkFlowEmail.Email_Subject__c = emailSubject;
                                   if(emailOverallBodyContent.length() < content1FieldLength){
                                       objWorkFlowEmail.content_1__c = emailOverallBodyContent;
                                   }else{
                                       objWorkFlowEmail.content_1__c = emailOverallBodyContent.substring(0, content1FieldLength - 1);
                                       if(emailOverallBodyContent.length() < content1FieldLength+content2FieldLength - 2 ) {
                                           objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, emailOverallBodyContent.length());
                                       } else {
                                           objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, content1FieldLength+content2FieldLength-2);
                                       }
                                   }
                                   workflowEmailRecList.add(objWorkFlowEmail);
                                   emailOverallBodyContent = '';
                                   emailSubject = '';
                               }
                        }
                    }
                }
                if(uniqueKeyToSignalIdSetMap.containskey(CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SVF)){
                    for(Id signalId : uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SVF)){
                        if(signalIdToSendToEmailSignalMap.containsKey(signalId)){
                            signalRecord = signalIdToSendToEmailSignalMap.get(signalId);
                            if(signalRecord.Signal_Unique_ID__c != null){
                                uniqueKey = signalRecord.Signal_Unique_ID__c.left(3)+signalRecord.Signal_Unique_ID__c.right(13);
                            }
                            objWorkFlowEmail = new Workflow_Email_Record__c();
                            if(signalRecord.SVF_SM_QC_Reviewer__r.Email != null){
                                objWorkFlowEmail.To_Email_1__c = signalRecord.SVF_SM_QC_Reviewer__r.Email;
                            }
                            if(signalRecord.SM_Service_Line_Lead_New__r.Email != null){
                                objWorkFlowEmail.To_Email_2__c = signalRecord.SM_Service_Line_Lead_New__r.Email;
                            }
                            if(signalRecord.SVF_SM_Specialist__r.Email != null){
                                objWorkFlowEmail.To_Email_3__c = signalRecord.SVF_SM_Specialist__r.Email;
                            }
                            if(signalRecord.SVF_Medical_Safety_Advisor__r.Email != null){
                                objWorkFlowEmail.To_Email_4__c = signalRecord.SVF_Medical_Safety_Advisor__r.Email;
                            }
                            if(objWorkFlowEmail.To_Email_1__c != null || objWorkFlowEmail.To_Email_2__c != null 
                               || objWorkFlowEmail.To_Email_3__c != null || objWorkFlowEmail.To_Email_4__c != null 
                               || Test.isRunningTest())
                            {
                                emailSubject = signalRecord.Account__r.Name != null ? '[' + signalRecord.Account__r.Name.substring(0,3) + ']' : '';
                                emailSubject += ' ';
                                emailSubject += signalRecord.Product__r.Name != null ? '[' + signalRecord.Product__r.Name + ']' : '';
                                emailSubject += ' ';
                                emailSubject += uniqueKey != null ? '[' + uniqueKey + ']' : ''; 
                                emailSubject += ' SVF Medical Review Completed ALERT.';     
                                emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Hi,<br><br>';
                                emailOverallBodyContent += 'The medical review of the draft is completed. Please act accordingly.'+'<br><br>'; 
                                emailOverallBodyContent+= createEmailBody(signalRecord, CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SVF, uniqueKey, null);
                                objWorkFlowEmail.Email_Action__c = CON_PSA.SIGNAL_SEND_EMAIL_NOTIFICATION;
                                objWorkFlowEmail.Module_Name__c = CON_PSA.PSA_MODULE_NAME;
                                objWorkFlowEmail.Email_Subject__c = emailSubject;
                                if(emailOverallBodyContent.length() < content1FieldLength){
                                    objWorkFlowEmail.content_1__c = emailOverallBodyContent;
                                }else{
                                    objWorkFlowEmail.content_1__c = emailOverallBodyContent.substring(0, content1FieldLength - 1);
                                    if(emailOverallBodyContent.length() < content1FieldLength+content2FieldLength - 2 ) {
                                        objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, emailOverallBodyContent.length());
                                    } else {
                                        objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, content1FieldLength+content2FieldLength-2);
                                    }
                                }
                                workflowEmailRecList.add(objWorkFlowEmail);
                                emailOverallBodyContent = '';
                                emailSubject = '';
                            }
                        }
                    }
                }
                if(uniqueKeyToSignalIdSetMap.containskey(CON_PSA.CONSTANT_SIGNAL_DATE_SVF_FINAL_DARFT_READY_FOR_SMT_REVIEW)){
                    for(Id signalId : uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_SVF_FINAL_DARFT_READY_FOR_SMT_REVIEW)){
                        if(signalIdToSendToEmailSignalMap.containsKey(signalId)){
                            signalRecord = signalIdToSendToEmailSignalMap.get(signalId);
                            if(signalRecord.Signal_Unique_ID__c != null){
                                uniqueKey = signalRecord.Signal_Unique_ID__c.left(3)+signalRecord.Signal_Unique_ID__c.right(13);
                            }
                            objWorkFlowEmail = new Workflow_Email_Record__c();
                            if(signalRecord.SVF_SM_QC_Reviewer__r.Email != null){
                                objWorkFlowEmail.To_Email_1__c = signalRecord.SVF_SM_QC_Reviewer__r.Email;
                            }
                            if(signalRecord.SM_Service_Line_Lead_New__r.Email != null){
                                objWorkFlowEmail.To_Email_2__c = signalRecord.SM_Service_Line_Lead_New__r.Email;
                            }
                            if(signalRecord.SVF_SM_Specialist__r.Email != null){
                                objWorkFlowEmail.To_Email_3__c = signalRecord.SVF_SM_Specialist__r.Email;
                            }
                            if(objWorkFlowEmail.To_Email_1__c != null || objWorkFlowEmail.To_Email_2__c != null 
                               || objWorkFlowEmail.To_Email_3__c != null || objWorkFlowEmail.To_Email_4__c != null 
                               || Test.isRunningTest())
                            {
                                emailSubject = signalRecord.Account__r.Name != null ? '[' + signalRecord.Account__r.Name.substring(0,3) + ']' : '';
                                emailSubject += ' ';
                                emailSubject += signalRecord.Product__r.Name != null ? '[' + signalRecord.Product__r.Name + ']' : '';
                                emailSubject += ' ';
                                emailSubject += uniqueKey != null ? '[' + uniqueKey + ']' : ''; 
                                emailSubject += ' Final Draft Ready for SMT Review ALERT.';     
                                emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Hi,<br><br>';
                                emailOverallBodyContent += 'The final draft is ready for SMT review. Please act accordingly.'+'<br><br>'; 
                                emailOverallBodyContent+= createEmailBody(signalRecord, CON_PSA.CONSTANT_SIGNAL_DATE_SVF_FINAL_DARFT_READY_FOR_SMT_REVIEW, uniqueKey, null);
                                objWorkFlowEmail.Email_Action__c = CON_PSA.SIGNAL_SEND_EMAIL_NOTIFICATION;
                                objWorkFlowEmail.Module_Name__c = CON_PSA.PSA_MODULE_NAME;
                                objWorkFlowEmail.Email_Subject__c = emailSubject;
                                if(emailOverallBodyContent.length() < content1FieldLength){
                                    objWorkFlowEmail.content_1__c = emailOverallBodyContent;
                                }else{
                                    objWorkFlowEmail.content_1__c = emailOverallBodyContent.substring(0, content1FieldLength - 1);
                                    if(emailOverallBodyContent.length() < content1FieldLength+content2FieldLength - 2 ) {
                                        objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, emailOverallBodyContent.length());
                                    } else {
                                        objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, content1FieldLength+content2FieldLength-2);
                                    }
                                }
                                workflowEmailRecList.add(objWorkFlowEmail);
                                emailOverallBodyContent = '';
                                emailSubject = '';
                            }
                        }
                    }
                }
                if(uniqueKeyToSignalIdSetMap.containskey(CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_FOR_QC)){
                    for(Id signalId : uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_FOR_QC)){
                        if(signalIdToSendToEmailSignalMap.containsKey(signalId)){
                            signalRecord = signalIdToSendToEmailSignalMap.get(signalId);
                            holidayList = null;
                            if(signalRecord.SM_Service_Line_Lead_New__c != null
                               && resourceIdToWorkCalendarIdMap.containsKey(signalRecord.SM_Service_Line_Lead_New__c)
                               && resourceIdToWorkCalendarIdMap.get(signalRecord.SM_Service_Line_Lead_New__c) != null
                               && workCalendarIdToHolidayDateSetMap.containsKey(resourceIdToWorkCalendarIdMap.get(signalRecord.SM_Service_Line_Lead_New__c))
                               && workCalendarIdToHolidayDateSetMap.get(resourceIdToWorkCalendarIdMap.get(signalRecord.SM_Service_Line_Lead_New__c)).size() > 0
                              ){
                                  holidayList = workCalendarIdToHolidayDateSetMap.get(resourceIdToWorkCalendarIdMap.get(signalRecord.SM_Service_Line_Lead_New__c));
                              }
                            workingDate = UTL_PSA.calculateWorkingDate(signalRecord.Date_SER_Draft_Sent_for_QC__c, 1, holidayList);
                            if(signalRecord.Signal_Unique_ID__c != null){
                                uniqueKey = signalRecord.Signal_Unique_ID__c.left(3)+signalRecord.Signal_Unique_ID__c.right(13);
                            }
                            objWorkFlowEmail = new Workflow_Email_Record__c();
                            if(signalRecord.SER_SM_QC_Reviewer__r.Email != null){
                                objWorkFlowEmail.To_Email_1__c = signalRecord.SER_SM_QC_Reviewer__r.Email;
                            }
                            if(signalRecord.SM_Service_Line_Lead_New__r.Email != null){
                                objWorkFlowEmail.To_Email_2__c = signalRecord.SM_Service_Line_Lead_New__r.Email;
                            }
                            if(signalRecord.SER_SM_Specialist__r.Email != null){
                                objWorkFlowEmail.To_Email_3__c = signalRecord.SER_SM_Specialist__r.Email;
                            }
                            if(objWorkFlowEmail.To_Email_1__c != null || objWorkFlowEmail.To_Email_2__c != null || objWorkFlowEmail.To_Email_3__c != null  || Test.isRunningTest()){
                                emailSubject = signalRecord.Account__r.Name != null ? '[' + signalRecord.Account__r.Name.substring(0,3) + ']' : '';
                                emailSubject += ' ';
                                emailSubject += signalRecord.Product__r.Name != null ? '[' + signalRecord.Product__r.Name + ']' : '';
                                emailSubject += ' ';
                                emailSubject += uniqueKey != null ? '[' + uniqueKey + ']' : ''; 
                                emailSubject += ' SER Draft Ready for QC ALERT.';     
                                emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Hi,<br><br>';
                                emailOverallBodyContent += 'The SER Draft is ready for QC. Please act accordingly..'+'<br><br>'; 
                                emailOverallBodyContent+= createEmailBody(signalRecord, CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_FOR_QC, uniqueKey, workingDate);
                                objWorkFlowEmail.Email_Action__c = CON_PSA.SIGNAL_SEND_EMAIL_NOTIFICATION;
                                objWorkFlowEmail.Module_Name__c = CON_PSA.PSA_MODULE_NAME;
                                objWorkFlowEmail.Email_Subject__c = emailSubject;
                                if(emailOverallBodyContent.length() < content1FieldLength){
                                    objWorkFlowEmail.content_1__c = emailOverallBodyContent;
                                }else{
                                    objWorkFlowEmail.content_1__c = emailOverallBodyContent.substring(0, content1FieldLength - 1);
                                    if(emailOverallBodyContent.length() < content1FieldLength+content2FieldLength - 2 ) {
                                        objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, emailOverallBodyContent.length());
                                    } else {
                                        objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, content1FieldLength+content2FieldLength-2);
                                    }
                                }
                                workflowEmailRecList.add(objWorkFlowEmail);
                                emailOverallBodyContent = '';
                                emailSubject = '';
                            }
                        }
                        
                    }
                }
                if(uniqueKeyToSignalIdSetMap.containskey(CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SER)){
                    for(Id signalId : uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SER)){
                        if(signalIdToSendToEmailSignalMap.containsKey(signalId)){
                            signalRecord = signalIdToSendToEmailSignalMap.get(signalId);
                            if(signalRecord.Signal_Unique_ID__c != null){
                                uniqueKey = signalRecord.Signal_Unique_ID__c.left(3)+signalRecord.Signal_Unique_ID__c.right(13);
                            }
                            objWorkFlowEmail = new Workflow_Email_Record__c();
                            if(signalRecord.SER_SM_QC_Reviewer__r.Email != null){
                                objWorkFlowEmail.To_Email_1__c = signalRecord.SER_SM_QC_Reviewer__r.Email;
                            }
                            if(signalRecord.SM_Service_Line_Lead_New__r.Email != null){
                                objWorkFlowEmail.To_Email_2__c = signalRecord.SM_Service_Line_Lead_New__r.Email;
                            }
                            if(signalRecord.SER_SM_Specialist__r.Email != null){
                                objWorkFlowEmail.To_Email_3__c = signalRecord.SER_SM_Specialist__r.Email;
                            }
                            if(objWorkFlowEmail.To_Email_1__c != null || objWorkFlowEmail.To_Email_2__c != null || objWorkFlowEmail.To_Email_3__c != null  || Test.isRunningTest()){
                                emailSubject = signalRecord.Account__r.Name != null ? '[' + signalRecord.Account__r.Name.substring(0,3) + ']' : '';
                                emailSubject += ' ';
                                emailSubject += signalRecord.Product__r.Name != null ? '[' + signalRecord.Product__r.Name + ']' : '';
                                emailSubject += ' ';
                                emailSubject += uniqueKey != null ? '[' + uniqueKey + ']' : ''; 
                                emailSubject += ' QC Review Completed ALERT';     
                                emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Hi,<br><br>';
                                emailOverallBodyContent += 'The quality review of the SER is completed. Please act accordingly.'+'<br><br>'; 
                                emailOverallBodyContent+= createEmailBody(signalRecord, CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SER, uniqueKey, null);
                                
                                objWorkFlowEmail.Email_Action__c = CON_PSA.SIGNAL_SEND_EMAIL_NOTIFICATION;
                                objWorkFlowEmail.Module_Name__c = CON_PSA.PSA_MODULE_NAME;
                                objWorkFlowEmail.Email_Subject__c = emailSubject;
                                if(emailOverallBodyContent.length() < content1FieldLength){
                                    objWorkFlowEmail.content_1__c = emailOverallBodyContent;
                                }else{
                                    objWorkFlowEmail.content_1__c = emailOverallBodyContent.substring(0, content1FieldLength - 1);
                                    if(emailOverallBodyContent.length() < content1FieldLength+content2FieldLength - 2 ) {
                                        objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, emailOverallBodyContent.length());
                                    } else {
                                        objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, content1FieldLength+content2FieldLength-2);
                                    }
                                }
                                workflowEmailRecList.add(objWorkFlowEmail);
                                emailOverallBodyContent = '';
                                emailSubject = '';
                            }
                        }
                    }
                }
                if(uniqueKeyToSignalIdSetMap.containskey(CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_SENT_FOR_MEDICAL_REVIEW)){
                    for(Id signalId : uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_SENT_FOR_MEDICAL_REVIEW)){
                        if(signalIdToSendToEmailSignalMap.containsKey(signalId)){
                            signalRecord = signalIdToSendToEmailSignalMap.get(signalId);
                            holidayList = null;
                            if(signalRecord.SM_Service_Line_Lead_New__c != null
                               && resourceIdToWorkCalendarIdMap.containsKey(signalRecord.SM_Service_Line_Lead_New__c)
                               && resourceIdToWorkCalendarIdMap.get(signalRecord.SM_Service_Line_Lead_New__c) != null
                               && workCalendarIdToHolidayDateSetMap.containsKey(resourceIdToWorkCalendarIdMap.get(signalRecord.SM_Service_Line_Lead_New__c))
                               && workCalendarIdToHolidayDateSetMap.get(resourceIdToWorkCalendarIdMap.get(signalRecord.SM_Service_Line_Lead_New__c)).size() > 0
                              ){
                                  holidayList = workCalendarIdToHolidayDateSetMap.get(resourceIdToWorkCalendarIdMap.get(signalRecord.SM_Service_Line_Lead_New__c));
                              }
                            workingDate = UTL_PSA.calculateWorkingDate(signalRecord.Date_SER_Draft_sent_for_Medical_Review__c, 3, holidayList);
                            if(signalRecord.Signal_Unique_ID__c != null){
                                uniqueKey = signalRecord.Signal_Unique_ID__c.left(3)+signalRecord.Signal_Unique_ID__c.right(13);
                            }
                            objWorkFlowEmail = new Workflow_Email_Record__c();
                            if(signalRecord.SER_SM_QC_Reviewer__r.Email != null){
                                objWorkFlowEmail.To_Email_1__c = signalRecord.SER_SM_QC_Reviewer__r.Email;
                            }
                            if(signalRecord.SM_Service_Line_Lead_New__r.Email != null){
                                objWorkFlowEmail.To_Email_2__c = signalRecord.SM_Service_Line_Lead_New__r.Email;
                            }
                            if(signalRecord.SER_SM_Specialist__r.Email != null){
                                objWorkFlowEmail.To_Email_3__c = signalRecord.SER_SM_Specialist__r.Email;
                            }
                            if(signalRecord.SER_Medical_Safety_Advisor__r.Email != null){
                                objWorkFlowEmail.To_Email_4__c = signalRecord.SER_Medical_Safety_Advisor__r.Email;
                            }
                            if(objWorkFlowEmail.To_Email_1__c != null || objWorkFlowEmail.To_Email_2__c != null || objWorkFlowEmail.To_Email_3__c != null  || objWorkFlowEmail.To_Email_4__c != null || Test.isRunningTest()){
                                emailSubject = signalRecord.Account__r.Name != null ? '[' + signalRecord.Account__r.Name.substring(0,3) + ']' : '';
                                emailSubject += ' ';
                                emailSubject += signalRecord.Product__r.Name != null ? '[' + signalRecord.Product__r.Name + ']' : '';
                                emailSubject += ' ';
                                emailSubject += uniqueKey != null ? '[' + uniqueKey + ']' : ''; 
                                emailSubject += ' Draft SER Ready for Medical Review ALERT';     
                                emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Hi,<br><br>';
                                emailOverallBodyContent += 'The SER Draft is ready for Medical Review. Please act accordingly.'+'<br><br>'; 
                                emailOverallBodyContent+= createEmailBody(signalRecord, CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_SENT_FOR_MEDICAL_REVIEW, uniqueKey, workingDate);
                                
                                objWorkFlowEmail.Email_Action__c = CON_PSA.SIGNAL_SEND_EMAIL_NOTIFICATION;
                                objWorkFlowEmail.Module_Name__c = CON_PSA.PSA_MODULE_NAME;
                                objWorkFlowEmail.Email_Subject__c = emailSubject;
                                if(emailOverallBodyContent.length() < content1FieldLength){
                                    objWorkFlowEmail.content_1__c = emailOverallBodyContent;
                                }else{
                                    objWorkFlowEmail.content_1__c = emailOverallBodyContent.substring(0, content1FieldLength - 1);
                                    if(emailOverallBodyContent.length() < content1FieldLength+content2FieldLength - 2 ) {
                                        objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, emailOverallBodyContent.length());
                                    } else {
                                        objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, content1FieldLength+content2FieldLength-2);
                                    }
                                }
                                workflowEmailRecList.add(objWorkFlowEmail);
                                emailOverallBodyContent = '';
                                emailSubject = '';
                            }
                        }
                    }
                }
                if(uniqueKeyToSignalIdSetMap.containskey(CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SER)){
                    for(Id signalId : uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SER)){
                        if(signalIdToSendToEmailSignalMap.containsKey(signalId)){
                            signalRecord = signalIdToSendToEmailSignalMap.get(signalId);
                            if(signalRecord.Signal_Unique_ID__c != null){
                                uniqueKey = signalRecord.Signal_Unique_ID__c.left(3)+signalRecord.Signal_Unique_ID__c.right(13);
                            }
                            objWorkFlowEmail = new Workflow_Email_Record__c();
                            if(signalRecord.SER_Medical_Safety_Advisor__r.Email != null){
                                objWorkFlowEmail.To_Email_1__c = signalRecord.SER_Medical_Safety_Advisor__r.Email;
                            }
                            if(signalRecord.SM_Service_Line_Lead_New__r.Email != null){
                                objWorkFlowEmail.To_Email_2__c = signalRecord.SM_Service_Line_Lead_New__r.Email;
                            }
                            if(signalRecord.SER_SM_Specialist__r.Email != null){
                                objWorkFlowEmail.To_Email_3__c = signalRecord.SER_SM_Specialist__r.Email;
                            }
                            if(objWorkFlowEmail.To_Email_1__c != null || objWorkFlowEmail.To_Email_2__c != null || objWorkFlowEmail.To_Email_3__c != null  || Test.isRunningTest()){
                                emailSubject = signalRecord.Account__r.Name != null ? '[' + signalRecord.Account__r.Name.substring(0,3) + ']' : '';
                                emailSubject += ' ';
                                emailSubject += signalRecord.Product__r.Name != null ? '[' + signalRecord.Product__r.Name + ']' : '';
                                emailSubject += ' ';
                                emailSubject += uniqueKey != null ? '[' + uniqueKey + ']' : ''; 
                                emailSubject += ' SER Medical Review Completed ALERT';     
                                emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Hi,<br><br>';
                                emailOverallBodyContent += 'The medical review of the draft is completed. Please act accordingly.'+'<br><br>'; 
                                emailOverallBodyContent += createEmailBody(signalRecord, CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SER, uniqueKey, null);
                                
                                objWorkFlowEmail.Email_Action__c = CON_PSA.SIGNAL_SEND_EMAIL_NOTIFICATION;
                                objWorkFlowEmail.Module_Name__c = CON_PSA.PSA_MODULE_NAME;
                                objWorkFlowEmail.Email_Subject__c = emailSubject;
                                if(emailOverallBodyContent.length() < content1FieldLength){
                                    objWorkFlowEmail.content_1__c = emailOverallBodyContent;
                                }else{
                                    objWorkFlowEmail.content_1__c = emailOverallBodyContent.substring(0, content1FieldLength - 1);
                                    if(emailOverallBodyContent.length() < content1FieldLength+content2FieldLength - 2 ) {
                                        objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, emailOverallBodyContent.length());
                                    } else {
                                        objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, content1FieldLength+content2FieldLength-2);
                                    }
                                }
                                workflowEmailRecList.add(objWorkFlowEmail);
                                emailOverallBodyContent = '';
                                emailSubject = '';
                            }
                        }
                    }
                }
                if(uniqueKeyToSignalIdSetMap.containskey(CON_PSA.CONSTANT_SIGNAL_DATE_SER_FINAL_DARFT_READY_FOR_SMT_REVIEW)){
                    for(Id signalId : uniqueKeyToSignalIdSetMap.get(CON_PSA.CONSTANT_SIGNAL_DATE_SER_FINAL_DARFT_READY_FOR_SMT_REVIEW)){
                        if(signalIdToSendToEmailSignalMap.containsKey(signalId)){
                            signalRecord = signalIdToSendToEmailSignalMap.get(signalId);
                            if(signalRecord.Signal_Unique_ID__c != null){
                                uniqueKey = signalRecord.Signal_Unique_ID__c.left(3)+signalRecord.Signal_Unique_ID__c.right(13);
                            }
                            objWorkFlowEmail = new Workflow_Email_Record__c();
                            if(signalRecord.SER_SM_QC_Reviewer__r.Email != null){
                                objWorkFlowEmail.To_Email_1__c = signalRecord.SER_SM_QC_Reviewer__r.Email;
                            }
                            if(signalRecord.SM_Service_Line_Lead_New__r.Email != null){
                                objWorkFlowEmail.To_Email_2__c = signalRecord.SM_Service_Line_Lead_New__r.Email;
                            }
                            if(signalRecord.SER_SM_Specialist__r.Email != null){
                                objWorkFlowEmail.To_Email_3__c = signalRecord.SER_SM_Specialist__r.Email;
                            }
                            if(objWorkFlowEmail.To_Email_1__c != null || objWorkFlowEmail.To_Email_2__c != null || objWorkFlowEmail.To_Email_3__c != null || objWorkFlowEmail.To_Email_4__c != null ||Test.isRunningTest()){
                                emailSubject = signalRecord.Account__r.Name != null ? '[' + signalRecord.Account__r.Name.substring(0,3) + ']' : '';
                                emailSubject += ' ';
                                emailSubject += signalRecord.Product__r.Name != null ? '[' + signalRecord.Product__r.Name + ']' : '';
                                emailSubject += ' ';
                                emailSubject += uniqueKey != null ? '[' + uniqueKey + ']' : ''; 
                                emailSubject += ' Final Draft Ready for SMT / Client Review ALERT';     
                                emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Hi,<br><br>';
                                emailOverallBodyContent += 'The final draft is ready for SMT / Client review. Please act accordingly.'+'<br><br>'; 
                                emailOverallBodyContent += createEmailBody(signalRecord, CON_PSA.CONSTANT_SIGNAL_DATE_SER_FINAL_DARFT_READY_FOR_SMT_REVIEW, uniqueKey, null);
                                
                                objWorkFlowEmail.Email_Action__c = CON_PSA.SIGNAL_SEND_EMAIL_NOTIFICATION;
                                objWorkFlowEmail.Module_Name__c = CON_PSA.PSA_MODULE_NAME;
                                objWorkFlowEmail.Email_Subject__c = emailSubject;
                                if(emailOverallBodyContent.length() < content1FieldLength){
                                    objWorkFlowEmail.content_1__c = emailOverallBodyContent;
                                }else{
                                    objWorkFlowEmail.content_1__c = emailOverallBodyContent.substring(0, content1FieldLength - 1);
                                    if(emailOverallBodyContent.length() < content1FieldLength+content2FieldLength - 2 ) {
                                        objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, emailOverallBodyContent.length());
                                    } else {
                                        objWorkFlowEmail.content_2__c = emailOverallBodyContent.substring(content1FieldLength - 1, content1FieldLength+content2FieldLength-2);
                                    }
                                }
                                workflowEmailRecList.add(objWorkFlowEmail);
                                emailOverallBodyContent = '';
                                emailSubject = '';
                            }
                        }
                    }
                }
            }
        }
        if(workflowEmailRecList.size() > 0){
            Database.insert(workflowEmailRecList, false);
        }
    }    
    public static String createEmailBody(Signal__c signalRecord, String contentType, String uniqueKey, Date workingDate){
        String signalDocumentName  = signalRecord.Signal_Document_Name__c != null ? signalRecord.Signal_Document_Name__c : 'SD Document Link';
        String tableStyle ='<table style="border-style:groove;">';
        String thStyle = '<th style="border-right:groove;">';
        String tdStyle = '<td style="border-top:groove;border-right:groove;">';
        List<String> emailOverallBodyContentList = new List<String>();
        emailOverallBodyContentList.add(tableStyle);
        emailOverallBodyContentList.add('<tr style="border-top:groove;">');
        emailOverallBodyContentList.add(thStyle);
        emailOverallBodyContentList.add(' Account ');
        emailOverallBodyContentList.add('</th>');
        emailOverallBodyContentList.add(thStyle);
        emailOverallBodyContentList.add(' Project Code ');
        emailOverallBodyContentList.add('</th>');
        emailOverallBodyContentList.add(thStyle);
        if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_QC){
            emailOverallBodyContentList.add(' Date SVF Draft Sent for QC ');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SVF){
            emailOverallBodyContentList.add(' Date QC Completed (SVF) '); 
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_MEDICAL_REVIEW){
            emailOverallBodyContentList.add(' Date SVF Draft sent for Medical Review ');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SVF){
            emailOverallBodyContentList.add(' Date Medical Review completed (SVF) ');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SVF_FINAL_DARFT_READY_FOR_SMT_REVIEW){
            emailOverallBodyContentList.add('Date SVF Final Draft Ready for SMT / Client Review '); 
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_FOR_QC){
            emailOverallBodyContentList.add('Date SER Draft Sent for QC '); 
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SER){
            emailOverallBodyContentList.add('Date QC Completed (SER)'); 
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_SENT_FOR_MEDICAL_REVIEW){
            emailOverallBodyContentList.add('Date SER Draft sent for Medical Review'); 
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SER){
            emailOverallBodyContentList.add('Date Medical Review completed (SER)'); 
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SER_FINAL_DARFT_READY_FOR_SMT_REVIEW){
            emailOverallBodyContentList.add('Date SER Final Draft Ready for SMT Review'); 
        }
        emailOverallBodyContentList.add('</th>');
        emailOverallBodyContentList.add(thStyle);
        emailOverallBodyContentList.add(' Signal Term ');
        emailOverallBodyContentList.add('</th>');
        
        if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_QC){
            emailOverallBodyContentList.add(thStyle + ' Due Date for Review </th>'); 
            emailOverallBodyContentList.add(thStyle + ' SVF SM Specialist Name </th>'); 
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SVF){
            emailOverallBodyContentList.add(thStyle + ' SVF SM QC Reviewer </th>'); 
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_MEDICAL_REVIEW){
            emailOverallBodyContentList.add(thStyle + ' Due Date for Review </th>');
            emailOverallBodyContentList.add(thStyle + ' SVF SM Specialist Name </th>'); 
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SVF){
            emailOverallBodyContentList.add(thStyle + ' SVF SM Specialist Name </th>'); 
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SVF_FINAL_DARFT_READY_FOR_SMT_REVIEW){
            emailOverallBodyContentList.add(thStyle + ' SVF SM Specialist Name </th>'); 
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_FOR_QC){
            emailOverallBodyContentList.add(thStyle + ' Due Date for Review </th>'); 
            emailOverallBodyContentList.add(thStyle + ' SER SM Specialist Name </th>'); 
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SER){
            emailOverallBodyContentList.add(thStyle + ' SER SM QC Reviewer </th>'); 
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_SENT_FOR_MEDICAL_REVIEW){
            emailOverallBodyContentList.add(thStyle + ' Due Date for Review </th>'); 
            emailOverallBodyContentList.add(thStyle + ' SER SM Specialist Name </th>'); 
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SER){
            emailOverallBodyContentList.add(thStyle + ' SER SM Specialist Name </th>'); 
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SER_FINAL_DARFT_READY_FOR_SMT_REVIEW){
            emailOverallBodyContentList.add(thStyle + ' SER SM Specialist Name </th>'); 
        }
        emailOverallBodyContentList.add(thStyle + ' Signal Document Link </th>');
        emailOverallBodyContentList.add('<th> PSA Link </th>'); 
        emailOverallBodyContentList.add('</tr>');
        
        // Add the data rows
        emailOverallBodyContentList.add('<tr>');
        emailOverallBodyContentList.add(tdStyle); 
        emailOverallBodyContentList.add(signalRecord.Account__r.Name != null ? signalRecord.Account__r.Name : '');
        emailOverallBodyContentList.add('</td>');
        emailOverallBodyContentList.add(tdStyle);
        emailOverallBodyContentList.add(signalRecord.Project_Code__c != null ? signalRecord.Project_Code__c : '');
        emailOverallBodyContentList.add('</td>');
        emailOverallBodyContentList.add(tdStyle);
        if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_QC){
            emailOverallBodyContentList.add(signalRecord.Date_SVF_Draft_Sent_for_QC__c != null ? String.valueOf(signalRecord.Date_SVF_Draft_Sent_for_QC__c) : '');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SVF){
            emailOverallBodyContentList.add(signalRecord.Date_QC_Completed_SVF__c != null ? String.valueOf(signalRecord.Date_QC_Completed_SVF__c) : '');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_MEDICAL_REVIEW){
            emailOverallBodyContentList.add( signalRecord.Date_SVF_Draft_sent_for_Medical_Review__c != null ? String.valueOf(signalRecord.Date_SVF_Draft_sent_for_Medical_Review__c) : '');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SVF){
            emailOverallBodyContentList.add(signalRecord.Date_Medical_Review_Completed_SVF__c != null ? String.valueOf(signalRecord.Date_Medical_Review_Completed_SVF__c) : '');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SVF_FINAL_DARFT_READY_FOR_SMT_REVIEW){
            emailOverallBodyContentList.add(signalRecord.Date_SVF_Final_DraftReady_for_SMT_Review__c != null ? String.valueOf(signalRecord.Date_SVF_Final_DraftReady_for_SMT_Review__c) : '');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_FOR_QC){
            emailOverallBodyContentList.add(signalRecord.Date_SER_Draft_Sent_for_QC__c != null ? String.valueOf(signalRecord.Date_SER_Draft_Sent_for_QC__c) : '');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SER){
            emailOverallBodyContentList.add(signalRecord.Date_QC_Completed_SER__c != null ? String.valueOf(signalRecord.Date_QC_Completed_SER__c) : '');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_SENT_FOR_MEDICAL_REVIEW){
            emailOverallBodyContentList.add(signalRecord.Date_SER_Draft_sent_for_Medical_Review__c != null ? String.valueOf(signalRecord.Date_SER_Draft_sent_for_Medical_Review__c) : '');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SER){
            emailOverallBodyContentList.add(signalRecord.Date_Medical_Review_Completed_SER__c != null ? String.valueOf(signalRecord.Date_Medical_Review_Completed_SER__c) : '');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SER_FINAL_DARFT_READY_FOR_SMT_REVIEW){
            emailOverallBodyContentList.add(signalRecord.Date_SER_Final_DraftReady_for_SMT_Review__c != null ? String.valueOf(signalRecord.Date_SER_Final_DraftReady_for_SMT_Review__c) : '');
        }
        emailOverallBodyContentList.add('</td>');
        emailOverallBodyContentList.add(tdStyle);
        emailOverallBodyContentList.add(signalRecord.Signal_Term__c != null ? signalRecord.Signal_Term__c : '');
        emailOverallBodyContentList.add('</td>');
        emailOverallBodyContentList.add(tdStyle);
        if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_QC){
            emailOverallBodyContentList.add(workingDate != null ? String.valueOf(workingDate) : '');
            emailOverallBodyContentList.add('</td>');
            emailOverallBodyContentList.add(tdStyle);
            emailOverallBodyContentList.add(signalRecord.SVF_SM_Specialist__r.Name != null ? signalRecord.SVF_SM_Specialist__r.Name : ''); 
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SVF){
            emailOverallBodyContentList.add(signalRecord.SVF_SM_QC_Reviewer__r.Name != null ? signalRecord.SVF_SM_QC_Reviewer__r.Name : '');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SVF_DRAFT_SENT_FOR_MEDICAL_REVIEW){
            emailOverallBodyContentList.add(workingDate != null ? String.valueOf(workingDate) : '');
            emailOverallBodyContentList.add('</td>');
            emailOverallBodyContentList.add(tdStyle);
            emailOverallBodyContentList.add(signalRecord.SVF_SM_Specialist__r.Name != null ? signalRecord.SVF_SM_Specialist__r.Name : '');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SVF){
            emailOverallBodyContentList.add(signalRecord.SVF_SM_Specialist__r.Name != null ? signalRecord.SVF_SM_Specialist__r.Name : '');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SVF_FINAL_DARFT_READY_FOR_SMT_REVIEW){
            emailOverallBodyContentList.add(signalRecord.SVF_SM_Specialist__r.Name != null ? signalRecord.SVF_SM_Specialist__r.Name : '');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_FOR_QC){
            emailOverallBodyContentList.add(workingDate != null ? String.valueOf(workingDate) : '');
            emailOverallBodyContentList.add('</td>');
            emailOverallBodyContentList.add(tdStyle);
            emailOverallBodyContentList.add(signalRecord.SER_SM_Specialist__r.Name != null ? signalRecord.SER_SM_Specialist__r.Name : '');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_QC_COMPLETED_SER){
            emailOverallBodyContentList.add(signalRecord.SER_SM_QC_Reviewer__r.Name != null ? signalRecord.SER_SM_QC_Reviewer__r.Name : '');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SER_DRAFT_SENT_FOR_MEDICAL_REVIEW){
            emailOverallBodyContentList.add(workingDate != null ? String.valueOf(workingDate) : '');
            emailOverallBodyContentList.add('</td>');
            emailOverallBodyContentList.add(tdStyle);
            emailOverallBodyContentList.add(signalRecord.SER_SM_Specialist__r.Name != null ? signalRecord.SER_SM_Specialist__r.Name : '');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_MEDICAL_REVIEW_COMPLETED_SER){
            emailOverallBodyContentList.add(signalRecord.SER_SM_Specialist__r.Name != null ? signalRecord.SER_SM_Specialist__r.Name : '');
        }else if(contentType == CON_PSA.CONSTANT_SIGNAL_DATE_SER_FINAL_DARFT_READY_FOR_SMT_REVIEW){
            emailOverallBodyContentList.add(signalRecord.SER_SM_Specialist__r.Name != null ? signalRecord.SER_SM_Specialist__r.Name : '');
        }
        emailOverallBodyContentList.add('</td>');
        emailOverallBodyContentList.add(tdStyle);
        if(signalRecord.Signal_Document_Link__c != null){
           emailOverallBodyContentList.add('<a href="' + signalRecord.Signal_Document_Link__c + '">' + signalDocumentName + '</a>');
          
        }else{
            emailOverallBodyContentList.add(''); 
        }
       emailOverallBodyContentList.add('</td>');
        emailOverallBodyContentList.add('<td style="border-top:groove;">');
        emailOverallBodyContentList.add('<a href="' + URL.getOrgDomainUrl().toExternalForm() + '/' + signalRecord.Id + '">' + uniqueKey + '</a>');
        emailOverallBodyContentList.add('</td> </tr> </table> <br> Thank You<br><br> </div>');
        return String.join(emailOverallBodyContentList, '');
    }
    public class signalFieldException extends Exception {}
}
