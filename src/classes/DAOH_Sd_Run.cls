/**
* This is Sd Run trigger handler class.
* version : 1.0
*/
public class DAOH_Sd_Run {
    
/**
* This method is used to populate Sd Run Id on Sd Run when record is inserted.
* @params List<SD_Runs__c> newList
* @return void
*/
    /*public static void populateSdRunIdField(List<SD_Runs__c> newList,Map<Id, SD_Runs__c> oldMap){
        Map<id,pse__Proj__c> projectIdProjectMap= new Map<id,pse__Proj__c>();
        Set<Id> projectIdSet = new Set<Id>();
        for(SD_Runs__c sdRunRec : newList){
            if(sdRunRec.Project__c != null ){
                projectIdSet.add(sdRunRec.Project__c);
            }
        }
        
        list<pse__Proj__c> projRecList  = new SLT_Project().selectSignalManagementProjectById(projectIdSet, new Set<String>{'pse__Account__r.name','Service_Line__r.name','RecordTypeId'});
        String rdsServiceLineRecordTypeID = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('RDS Service Line').getRecordTypeId();
        
        for(pse__Proj__c projRec : projRecList){
            if(projRec.Service_Line__r.name == 'Signal Management' && projRec.RecordTypeId  == rdsServiceLineRecordTypeID ){
                projectIdProjectMap.put(projRec.id,projRec);
            }
        }
        
        list<SD_Runs__c> sdRec  = new SLT_SdRun().getLastCreatedSdRunRecord( new Set<String>{'Name'});
        if(sdRec.size()>0){
            if( sdRec[0].name != null){
                string name = sdRec[0].name;
                String delimiter = '-SD-';
                String splits = sdRec[0].name.substringAfter(delimiter);
                if(integer.valueof(splits) > DAO_Sd_Run.autoNumber || integer.valueof(splits) == 0){
                    DAO_Sd_Run.autoNumber = integer.valueof(splits) + 1;
                }
                else{
                    DAO_Sd_Run.autoNumber = DAO_Sd_Run.autoNumber ;
                }
            }
        }
        else{
            DAO_Sd_Run.autoNumber = 00000;
        }
        
        for(SD_Runs__c sdRunRec : newList) {
            if(sdRunRec.Project__c != null){
                string sdRunIdAuto = '';
                if(projectIdProjectMap.containsKey(sdRunRec.Project__c)){
                    string accountName= projectIdProjectMap.get(sdRunRec.Project__c).pse__Account__r.name.substring(0,3);
                    String incrementedNum = (('00000')+ DAO_Sd_Run.autoNumber).right(5);
                    sdRunIdAuto = accountName + '-SD-' + incrementedNum;
                    sdRunRec.Name = sdRunIdAuto;
                    DAO_Sd_Run.autoNumber++;
                }
            }
            else{
                sdRunRec.addError('Project field is null for service line project to which this sd run is related.');
            }
        }
    }*/
    
    public static void populateSdRunUniqueId(List<SD_Runs__c> newList,Map<Id, SD_Runs__c> oldMap){
        Set<String> uniqueIdSet = new Set<String>();
        Set<String> accountIdSet = new Set<String>();
        Map<String,String> accountIdToSdRunUniqueNameMap = new Map<String,String>();
        for(SD_Runs__c sdRun : newList) {
            if(sdRun.Account__c != null) {
                   accountIdSet.add(sdRun.Account__c);
            }            
        }
        if(accountIdSet.size() > 0){
            Map<Id,Account> accountMap = new Map<Id,Account>([Select Id,Name from Account where Id in: accountIdSet]);
            for(Id acc : accountMap.keySet()){
                String subName;
                if(accountMap.get(acc).Name.length() >= 5){
                	subName = accountMap.get(acc).Name.substring(0,5)+'%';
                }
                else{
                    subName = accountMap.get(acc).Name+'%';
                }
                uniqueIdSet.add(subName);
            }
            for(SD_Runs__c sdRun : [SELECT Id, Account__c,Account__r.Name,SD_Run_Unique_ID__c
                                   FROM SD_Runs__c
                				   WHERE SD_Run_Unique_ID__c like: uniqueIdSet]){  
                String initialFiveCharOfAccountName;
                if(sdRun.Account__r.Name.length() >= 5){
                	initialFiveCharOfAccountName = sdRun.Account__r.Name.substring(0,5);
                }
                else{
                    initialFiveCharOfAccountName = sdRun.Account__r.Name; 
                }                       
                if(accountIdToSdRunUniqueNameMap.containsKey(initialFiveCharOfAccountName)) {
                    if(accountIdToSdRunUniqueNameMap.get(initialFiveCharOfAccountName) < sdRun.SD_Run_Unique_ID__c ) {
                        accountIdToSdRunUniqueNameMap.put(initialFiveCharOfAccountName,sdRun.SD_Run_Unique_ID__c);
                    }     
                } 
                else{
                     accountIdToSdRunUniqueNameMap.put(initialFiveCharOfAccountName,sdRun.SD_Run_Unique_ID__c);           
                }                      
            }
            for(SD_Runs__c sdRun : newList) {                
                String accountNameSubstring;
                if(accountMap.containsKey(sdRun.Account__c)){
                    accountNameSubstring = accountMap.get(sdRun.Account__c).Name.substring(0,5);
                }                
                if(accountIdToSdRunUniqueNameMap.containsKey(accountNameSubstring)  && accountIdToSdRunUniqueNameMap.get(accountNameSubstring) != null){
                    Integer lastIndex = accountIdToSdRunUniqueNameMap.get(accountNameSubstring).lastIndexOf('-') + 1;
                    Integer uniqueNumber = Integer.valueof(accountIdToSdRunUniqueNameMap.get(accountNameSubstring).substring(lastIndex,14))+1;
                    String uniqueNumberString = String.valueOf(uniqueNumber).leftPad(5, '0');
                    sdRun.SD_Run_Unique_ID__c = accountNameSubstring+'-SD-'+uniqueNumberString;
                    accountIdToSdRunUniqueNameMap.put(accountNameSubstring,sdRun.SD_Run_Unique_ID__c);
                }
                else{
                    sdRun.SD_Run_Unique_ID__c = accountNameSubstring+'-SD-'+String.valueOf(1).leftPad(5, '0');
                    accountIdToSdRunUniqueNameMap.put(accountNameSubstring,sdRun.SD_Run_Unique_ID__c);
                }                
            }
        }
    }
    
    /**
    * This method is used to validate Sd Run fields on insertion and updation.
    * @params List<SD_Runs__c> newList
    * @params Map<Id, PSSF__c> oldMap
    * @return void
    */
    public static void validateSDRunFields(List<SD_Runs__c> newList,Map<Id, SD_Runs__c> oldMap){
        String sdRunOutcomeValidn = '';
        String futureDateErrorMsg ='';
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        Set<String> projIdSet = new Set<String>();
        Map<Id, List<pse__Assignment__c>> projAndRltdAssignmentMap = new Map<Id, List<pse__Assignment__c>>();
        If(!mulesoftSetting.Ignore_Validation_Rules__c){
            for(SD_Runs__c sdRunRec : newList){
                if(sdRunRec.Project__c != null){
                    projIdSet.add(sdRunRec.Project__c);
                }
            }
            
            projAndRltdAssignmentMap = new SLT_Assignment().selectAssignmentsByProjId(projIdSet,
                                                                                                new Set<String>{'Id', 'Name', 'pse__Project__c', 'pse__Status__c', 'Active__c','Closed_for_Unit_Entry__c','pse__Closed_for_Time_Entry__c', 'pse__Resource__c'});
            
            for(SD_Runs__c sdRunRec : newList){
                if(sdRunRec.Service_Line_Lead__c == null){
                    sdRunRec.addError('The \'Service Line Lead\' is not present on the Signal Management project.');
                }                
                
                if(sdRunRec.SD_Run_Date_Completed__c != null ){
                    
                    sdRunRec.Status__c = 'Completed';
                }
                if(sdRunRec.Status__c == 'Completed' && (sdRunRec.Does_this_SD_Run_require_Medical_Review__c =='Yes' && sdRunRec.Does_this_SD_Run_require_QC__c == 'Yes') &&  (sdRunRec.SD_Run_Date_Completed__c == null || sdRunRec.SD_Run_Complexity__c == null ||
                                                        sdRunRec.SM_Specialist__c == null || sdRunRec.Medical_Safety_Advisor__c == null ||sdRunRec.Date_Medical_Review_Completed__c == null || sdRunRec.SM_QC_Reviewer__c == null ||
                                                        sdRunRec.Date_QC_Completed__c == null || sdRunRec.Date_Draft_Sent_for_QC__c == null ||
                                                        sdRunRec.Date_Draft_sent_for_Medical_Review__c == null || sdRunRec.Date_final_Draft_Ready_for_SMT_Review__c == null)){
                       sdRunRec.addError(' \'Date Draft sent for Medical Review\', \'Date final Draft Ready for SMT Review\', \'Date Draft Sent for QC\', \'SD run date completed\', \'SD Run Complexity\', \'SM Specialist\', \'Medical Safety Advisor\', \'Date Medical Review Completed\', \'SM QC Reviewer\', \'Date QC Completed\' cannot be empty to mark the status as Complete or Create deliverables.');
                    
                }
                else if(sdRunRec.Status__c == 'Completed' && sdRunRec.Does_this_SD_Run_require_Medical_Review__c =='Yes' && sdRunRec.Does_this_SD_Run_require_QC__c == 'No' &&  (sdRunRec.SD_Run_Date_Completed__c == null || sdRunRec.SD_Run_Complexity__c == null ||
                                                        sdRunRec.SM_Specialist__c == null || sdRunRec.Medical_Safety_Advisor__c == null ||sdRunRec.Date_Medical_Review_Completed__c == null))    {
                       sdRunRec.addError('\'SD run date completed\', \'SD Run Complexity\', \'SM Specialist\', \'Medical Safety Advisor\', \'Date Medical Review Completed\' cannot be empty to mark the status as Complete or Create deliverables.');    
                }
                
                else if(sdRunRec.Status__c == 'Completed' && sdRunRec.Does_this_SD_Run_require_Medical_Review__c =='No' && sdRunRec.Does_this_SD_Run_require_QC__c == 'Yes' &&  (sdRunRec.SD_Run_Date_Completed__c == null || sdRunRec.SD_Run_Complexity__c == null ||
                                                        sdRunRec.SM_Specialist__c == null || sdRunRec.SM_QC_Reviewer__c == null ||
                                                        sdRunRec.Date_QC_Completed__c == null))    {
                       sdRunRec.addError('\'SD run date completed\', \'SD Run Complexity\', \'SM Specialist\', \'SM QC Reviewer\', \'Date QC Completed\' cannot be empty to mark the status as Complete or Create deliverables.');
                }
                
                else if(sdRunRec.Status__c == CON_PSA.SD_RUNS_STATUS_COMPLETED && ( sdRunRec.Name_Reviewed_Source__c == null || sdRunRec.Link_to_Reviewed_Source__c == null )){
                       sdRunRec.addError('\'Name Reviewed Source\', \'Link to Reviewed Source\' cannot be empty to mark the status as Complete or Create deliverables.');
                }
                
            /*    if(sdRunRec.Status__c == 'Completed' && sdRunRec.Does_this_SD_Run_require_Medical_Review__c =='No' && sdRunRec.Does_this_SD_Run_require_QC__c == 'No' &&  ( sdRunRec.Medical_Safety_Advisor__c == null ||sdRunRec.Date_Medical_Review_Completed__c == null || sdRunRec.SM_QC_Reviewer__c == null ||
                                                        sdRunRec.Date_QC_Completed__c == null))    {
                       handleOnSuccess;
                }  */
                //////////////////////////////////////////////////////////////////////////////
                
                
                else if(sdRunRec.Status__c == 'Completed' && sdRunRec.Does_this_SD_Run_require_Medical_Review__c =='No' && sdRunRec.Does_this_SD_Run_require_QC__c == 'No' &&  (sdRunRec.SD_Run_Date_Completed__c == null || sdRunRec.SD_Run_Complexity__c == null ||
                                                        sdRunRec.SM_Specialist__c == null))    {
                       sdRunRec.addError('\'SD run date completed\', \'SD Run Complexity\', \'SM Specialist\' cannot be empty to mark the status as Complete or Create deliverables.');  
                }
                
                if(sdRunRec.SD_Run_Complexity__c == null){
                    sdRunRec.addError('The \'SD Run Complexity\' field cannot be empty.');
                }
                if(sdRunRec.Discussed_in_SMT_Meeting__c == 'Yes (enter date)' && sdRunRec.Date_SMT_Meeting__c == null){
                    sdRunRec.addError('\'Date SMT Meeting\' cannot be blank as \'Discussed in the SMT Meeting\' is set to \'Yes (enter date)\'.');
                }
                if(sdRunRec.Discussed_in_SMT_Meeting__c == 'No (specify reason)' && sdRunRec.Not_Discussed_in_SMT_Meeting_Reason__c == null){
                    sdRunRec.addError('\'Not Discussed in SMT Meeting Reason\' field cannot be blank as \'Discussed in the SMT Meeting\' is set to \'No (specify reason)\'.');
                }
                if(sdRunRec.SD_Run_Outcome__c == 'Potential Signal' && sdRunRec.Potential_Signal_Description1__c == null){
                    sdRunRec.addError('\'Potential Signal\' has been selected therefore the \'Potential Signal Description\' field cannot be empty.');
                }
                if(sdRunRec.SD_Run_Outcome__c == 'Potential Emerging Safety Issue' && sdRunRec.Potential_Emerging_Safety_Issue_Detail__c == null){
                    sdRunRec.addError('\'Potential Emerging Safety Issue\' has been selected therefore the \'Potential Emerging Safety Issue Detail\' field cannot be empty.');
                }
                if(sdRunRec.SD_Run_Outcome__c == 'Other (specify)' && sdRunRec.Other_SD_Run_Action_Items__c == null){
                    sdRunRec.addError('\'Other (specify)\' has been selected therefore the \'Other SD Run Action Items\' field cannot be empty.');
                }
                if(sdRunRec.SD_Run_Date_Completed__c != null && sdRunRec.SD_Run_Outcome__c == null){
                    sdRunRec.addError('As there is value in the \'SD Run Date Completed\' field, \'SD Run Outcome\' cannot be empty.');
                }
                if(sdRunRec.Last_SD_Run_for_Product__c == true && sdRunRec.Last_SD_Run_for_Product_Reason__c == null){
                    sdRunRec.addError('\'Last SD Run for Product Reason\' cannot be blank as the \'Last SD Run for Product\' field is checked');
                }
                if(sdRunRec.SD_Run_Start_Date__c != null && (sdRunRec.Status__c == 'Not Yet Started' ||sdRunRec.Status__c == 'Assigned')){
                    sdRunRec.addError('\'SD Run Start Date\' is populated and the \'Status\' cannot be \'Not Yet Started\' or \'Assigned\'.');
                }
                if(sdRunRec.Data_Review_Period_Start_Date__c > sdRunRec.Data_Review_Period_End_Date__c){
                    sdRunRec.addError('\'Data Review Period End Date\' is before the \'Data Review Period Start Date\'.');
                }
                if(sdRunRec.SD_Run_Date_Completed__c != null && sdRunRec.SD_Run_Start_Date__c == null){
                    sdRunRec.addError('\'SD Run Date Completed\' cannot be populated if  \'SD Run Start Date\' is empty.');
                }
                if(sdRunRec.SD_Run_Start_Date__c > sdRunRec.SD_Run_Date_Completed__c){
                    sdRunRec.addError('The record cannot be saved as the \'SD Run Date Completed\' date is before the \'SD Run Start Date\'.');
                }
                if(sdRunRec.SD_Run_Date_Completed__c > Date.today() 
                   || sdRunRec.Date_Medical_Review_Completed__c > Date.today() || sdRunRec.Date_QC_Completed__c > Date.today() 
                   || sdRunRec.Date_BRM_Review_Completed__c > Date.today() || sdRunRec.SD_Run_Start_Date__c > Date.today() 
                   || sdRunRec.Date_Draft_Sent_for_QC__c > Date.today() || sdRunRec.Date_Draft_sent_for_Medical_Review__c > Date.today()
                   || sdRunRec.Date_final_Draft_Ready_for_SMT_Review__c > Date.today()){
                       futureDateErrorMsg = 'You cannot enter future date in';
                       if(sdRunRec.Date_final_Draft_Ready_for_SMT_Review__c > Date.today()){
                          futureDateErrorMsg += ' \'Date final Draft Ready for SMT Review \', ';
                       }
                       if(sdRunRec.SD_Run_Date_Completed__c > Date.today()){
                          futureDateErrorMsg += ' \'SD Run Date Completed\', ';
                       }
                       if(sdRunRec.Date_Medical_Review_Completed__c > Date.today()){
                           futureDateErrorMsg += ' \'Date Medical Review Completed\', ';
                       }
                       if(sdRunRec.Date_QC_Completed__c > Date.today()){
                           futureDateErrorMsg += ' \'Date QC Completed\', ';
                       }
                       if(sdRunRec.Date_BRM_Review_Completed__c > Date.today()){
                           futureDateErrorMsg += ' \'Date BRM Review Completed\', ';
                       }
                       if(sdRunRec.SD_Run_Start_Date__c > Date.today()){
                           futureDateErrorMsg += ' \'SD Run Start Date\', ';
                       }
                       if(sdRunRec.Date_Draft_Sent_for_QC__c > Date.today()){
                           futureDateErrorMsg += ' \'Date Draft Sent for QC\', ';
                       }
                       if(sdRunRec.Date_Draft_sent_for_Medical_Review__c > Date.today()){
                           futureDateErrorMsg += ' \'Date Draft sent for Medical Review\' ';
                       }
                       futureDateErrorMsg += ' fields.';
                       sdRunRec.addError(futureDateErrorMsg);
                }
                if(sdRunRec.SD_Run_Outcome__c != null && sdRunRec.SD_Run_Outcome__c != ''){
                    if(sdRunRec.SD_Run_Outcome__c.contains('Potential Signal') && sdRunRec.Potential_Signal_Description1__c == null){
                        sdRunOutcomeValidn = sdRunOutcomeValidn + '\'Potential Signal Description\' field cannot be empty if \'Potential Signal\' is selected ';
                    }
                    if(sdRunRec.SD_Run_Outcome__c.contains('Potential Emerging Safety Issue') && sdRunRec.Potential_Emerging_Safety_Issue_Detail__c == null){
                        sdRunOutcomeValidn = sdRunOutcomeValidn + '\'Potential Emerging Safety Issue Detail\' field cannot be empty if \'Potential Emerging Safety Issue\' is selected ';
                    }
                    if(sdRunRec.SD_Run_Outcome__c.contains('Other (specify)') && sdRunRec.Other_SD_Run_Action_Items__c == null){
                        sdRunOutcomeValidn = sdRunOutcomeValidn + '\'Other SD Run Action Items\' field cannot be empty if \'Other (Specify)\' is selected ';
                    }
                    if(sdRunOutcomeValidn != null && sdRunOutcomeValidn != ''){
                        sdRunRec.addError(sdRunOutcomeValidn + 'from the \'SD Run Outcome\' field.');
                        sdRunOutcomeValidn = '';
                    }
                }
                                                        
                if(sdRunRec.SM_Specialist__c != null){
                    List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
                    //Set<Id> rltdProjId = new Set<Id>();
                    //rltdProjId.add(sdRunRec.Project__c);
                    assignmentList = projAndRltdAssignmentMap.get(sdRunRec.Project__c);
                    boolean SMAssignmentActive = false;
                    if(assignmentList != null && assignmentList.size() > 0) {
                        SMAssignmentActive = hasActiveAssignment(assignmentList, sdRunRec.SM_Specialist__c);
                    }                    
                    if(SMAssignmentActive == false){
                       sdRunRec.addError('There is no active Assignment on the project for the selected SM Specialist.');
                    }
                }
                if(sdRunRec.SM_QC_Reviewer__c != null){
                    List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
                    //Set<Id> rltdProjId = new Set<Id>();
                    //rltdProjId.add(sdRunRec.Project__c);
                    assignmentList = projAndRltdAssignmentMap.get(sdRunRec.Project__c);
                    boolean SMAssignmentActive = false;
                    if(assignmentList != null && assignmentList.size() > 0) {
                        SMAssignmentActive = hasActiveAssignment(assignmentList, sdRunRec.SM_QC_Reviewer__c);
                    }
                    if(SMAssignmentActive == false){
                       sdRunRec.addError('There is no active Assignment on the project for the selected SM QC Reviewer.');
                    }
                }
            }
        }
    }
    
    public static void createDeliverables(List<SD_Runs__c> updatedList,Map<Id, SD_Runs__c> oldMap){
        List<SD_Runs__c> reportsToSync = new List<SD_Runs__c>();
        List<SD_Runs__c> reportsToSyncPriorMilestoneCheck = new List<SD_Runs__c>();

        
        for(SD_Runs__c sdRunRec : updatedList){
            if(sdRunRec.Status__c != 'Completed'){
                continue;
            }
            if(sdRunRec.Status__c == 'Completed' && sdRunRec.Deliverable__c != null){
                continue;
            }
            if(sdRunRec.Status__c == 'Completed' && sdRunRec.Deliverable__c == null){
                reportsToSyncPriorMilestoneCheck.add(sdRunRec);
            }
        }
        
        Set<Id> projectIdSet = new Set<Id>();
        for(SD_Runs__c sdRunRec : reportsToSyncPriorMilestoneCheck){
            projectIdSet.add(sdRunRec.Project__c);
        }
        Map<Id, List<pse__Milestone__c>> projectMilestoneListMap = new SLT_Milestone().selectMilestoneListByProjectId(projectIdSet,new Set<String> {'Id','Name','pse__Project__c','Service__r.Name'});
        Map<String, Id> serviceNameMilestoneMap = new Map<String,Id>();
        for(SD_Runs__c sdRunRec : reportsToSyncPriorMilestoneCheck){
            if(projectMilestoneListMap.containsKey(sdRunRec.Project__c)) {
                for(pse__Milestone__c milestone : projectMilestoneListMap.get(sdRunRec.Project__c)){
                    serviceNameMilestoneMap.put( milestone.Service__r.Name, milestone.Id);
                }
            }
            if(serviceNameMilestoneMap.containsKey('Signal Detection Run') || serviceNameMilestoneMap.containsKey('SM Miscellaneous')){
               reportsToSync.add(sdRunRec); 
            }
            else{
                sdRunRec.addError('SM MISX or Signal Detection Run'+' service milestone does not exist on this project, deliverables cannot be created, please make sure either of these two service milestones exist on the project');
			}
        }
        
        if(reportsToSync.size() > 0){
            System.enqueueJob(new QUE_PSA_SyncSDRunsDeliverables(reportsToSync));
        }
    }
    /**
    * This method will insert record in Audit Log on Inserting/Updating SD_Runs__c record
    **/
    public static void insertAuditLogOnUpdate(List<SD_Runs__c> updatedList,Map<Id,SD_Runs__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting HA_Websites_Review__c
    **/
    public static void insertAuditLog(List<SD_Runs__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
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
    
    public static void synchronizeProjectEvents(List<SD_Runs__c> updatedList, Map<Id,SD_Runs__c> existingRecords){
        
        List<SD_Runs__c> sdRunToSync = new List<SD_Runs__c>();
        for(SD_Runs__c sdRunRec : updatedList){
            if(sdRunRec.SD_Run_Due_Date__c != null){
                sdRunToSync.add(sdRunRec);
            }
        }

        fetchPSAEvents();
        buildDateFieldMap();
        Id userId = UserInfo.getUserId();

        try {
            setEventDateFields();
            
        } catch (Exception e) {
            
            SD_Runs__c sigRec = sdRunToSync.get(0);
            sigRec.addError( e.getMessage());
            return;
        }

        Set<String> sdRunFields = Schema.SObjectType.SD_Runs__c.fields.getMap().keySet();
        Map<Id,Map<Id,Project_Event__c>> reportToProjectEventMap = getProjectEventsBysdRun(sdRunToSync);

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Project_Event__c.SObjectType }
        );

        for(SD_Runs__c sdRunRec : sdRunToSync){
            
            //String recordTypeName = Schema.SObjectType.SD_Runs__c.getRecordTypeInfosById().get(sigRec.RecordTypeId).getDeveloperName();
            for(String dateField : eventDateFields){
                Date dateFieldContents = (Date) sdRunRec.get(dateField);
                //PSA_Event__c psaEvent = ( dateFieldToPSAEventMap.get(dateField) != null) ? dateFieldToPSAEventMap.get(dateField).get(recordTypeName) : null;
                PSA_Event__c psaEvent = ( dateFieldToPSAEventMap.get(dateField) != null) ? dateFieldToPSAEventMap.get(dateField).get('NA') : null;
                
                Project_Event__c projectEvent= ( reportToProjectEventMap.get(sdRunRec.Id) != null && psaEvent != null) ? reportToProjectEventMap.get(sdRunRec.Id).get(psaEvent.Id) : null;

                if( dateFieldContents != null && psaEvent != null ) {

                    try {
                        validatePSAEvent(psaEvent, sdRunFields);
                    } catch (sdRunFieldException e){
                        
                        sdRunRec.addError(e.getMessage());
                        continue;
                    }
                    if(projectEvent == null){
                        projectEvent = populateProjectEvent(sdRunRec, psaEvent);
                        uow.registerNew(projectEvent);
                    } else {
                        //Note, this will register all existing Project Events as dirty vs checking every field-- a SOQL vs CPU tradeoff?
                        //TODO - Remove the SOQL query from populate project event and check events for needing update before updating
                        populateProjectEvent(sdRunRec, psaEvent, projectEvent);
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
     * This method retrieves all Project_Event__c objects for the sdRun, and maps them by sd run id followed by PSA Event Id
     * This allows us to validate them against both the sdRun and the PSA Event, in case either has changed
     * @params List<SD_Runs__c> reports
     * @return Map<Id,Map<Id,Project_Event__c>>
     */ 
    private static Map<Id,Map<Id,Project_Event__c>> getProjectEventsBysdRun(List<SD_Runs__c> sdRun ){
        Set<Id> reportIds = new Set<Id>(new Map<Id,SD_Runs__c>(sdRun).keySet());
        Set<String> eventFields = new SLT_Project_Event().getDefaultFields();
        Map<Id,Map<Id,Project_Event__c>> projectEventsMap = new Map<Id,Map<Id,Project_Event__c>>();
        List<Project_Event__c> events = new SLT_Project_Event().getProjectEventsBysdRun(reportIds, eventFields);
        for(Project_Event__c event : events){
            if(projectEventsMap.get(event.SD_Runs__c) == null){
                projectEventsMap.put(event.SD_Runs__c, new Map<Id,Project_Event__c>());
            }
            projectEventsMap.get(event.SD_Runs__c).put(event.PSA_Event__c, event);
        }
        return projectEventsMap;
    }
    
    /**
     * This method builds a map of Planned_Date_Field__c to RecordTypeName to PSA_Event__c
     * It allows you to filter PSA Events by both field and recordtype when trying to match up with sd run
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
     * Retrieves all the PSA Events that could be applied to an sd run
     */
    private static void fetchPSAEvents(){
        if(psaEvents == null){
            psaEvents =  new SLT_PSA_Event().getAllPSAEvents('SD_Runs__c');
        }
    }
    
    /**
     * Compiles a list of the Due Date fields from a list of PSA events
     * These are the fields that we will be examining on sd run for changes
     */
    private static void setEventDateFields(){
        Set<String> sdRunFields = Schema.SObjectType.SD_Runs__c.fields.getMap().keySet();
        Set<String> invalidFields = new Set<String>();
        fetchPSAEvents();

        if(eventDateFields == null){
            eventDateFields = new Set<String>();
        }
        for(PSA_Event__c event : psaEvents){
            if ( !sdRunFields.contains( event.Planned_Date_Field__c.toLowerCase() ) ) {
                invalidFields.add(event.Name+':'+event.Planned_Date_Field__c);
            } else {
                eventDateFields.add(event.Planned_Date_Field__c);
            }
        }

        if(invalidFields.size() > 0){
            throw new sdRunFieldException('Contact your PSA Admin. Found bad PSA Event Planned Date fields: '+String.join( new List<String>(invalidFields), ',' ) );
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
            throw new sdRunFieldException('Contact your PSA Admin. Found invalid field data for PSA Event '+psaEvent.Name+': '+String.join( new List<String>(invalidFields), ',' ) );
        }
    }
    
    /**
     * Populate fields on a project event given an aggregate report and a psa event
     * @params SD_Runs__c sdRun
     * @params PSA_Event__c psaEvent
     * @params Project_Event__c projectEvent
     * 
     * @return Project_Event__c
     */
    private static Project_Event__c populateProjectEvent( SD_Runs__c sdRun, PSA_Event__c psaEvent){
        return populateProjectEvent( sdRun, psaEvent, new Project_Event__c());
    }

    private static Project_Event__c populateProjectEvent( SD_Runs__c sdRun, PSA_Event__c psaEvent, Project_Event__c projectEvent) {

        if ( psaEvent.Actual_Date_Field__c != null && sdRun.get(psaEvent.Actual_Date_Field__c) != null) {
            projectEvent.Event_Actual_Date__c = (Date)sdRun.get(psaEvent.Actual_Date_Field__c);
        } else {
            projectEvent.Event_Actual_Date__c = null;
        }

        if ( psaEvent.Planned_Date_Field__c != null && sdRun.get(psaEvent.Planned_Date_Field__c) != null) { 
                projectEvent.Event_Due_Date__c = (Date)sdRun.get(psaEvent.Planned_Date_Field__c);
        } else {
            projectEvent.Event_Due_Date__c = null;
        }

        if ( psaEvent.Planned_Date_Field__c != null && sdRun.get(psaEvent.Planned_Date_Field__c) != null && psaEvent.Notification_Offset__c != null) {
            projectEvent.Notification_Date__c = ((Date)sdRun.get(psaEvent.Planned_Date_Field__c)).addDays(Integer.valueOf(psaEvent.Notification_Offset__c));
        } else {
            projectEvent.Notification_Date__c = null;
        }

        projectEvent.Primary_Resource__c = (psaEvent.Primary_Resource_Field__c != null) ? String.valueOf(sdRun.get(psaEvent.Primary_Resource_Field__c)) : null;
        projectEvent.Secondary_Resource__c = (psaEvent.Secondary_Resource_Field__c != null) ? String.valueOf(sdRun.get(psaEvent.Secondary_Resource_Field__c)) : null;
        projectEvent.Other_Resource__c = (psaEvent.Other_Resource_Field__c != null) ? String.valueOf(sdRun.get(psaEvent.Other_Resource_Field__c)) : null;
        projectEvent.Stakeholder_ID__c = getStakeholderIds(sdRun, psaEvent.Stakeholder_Fields__c);

        projectEvent.PSA_Event__c = psaEvent.Id;
        projectEvent.SD_Runs__c = sdRun.Id;
        projectEvent.Project__c = (sdRun.Project__c != null) ? String.valueOf(sdRun.Project__c) : null;
        return projectEvent;
    }
    
    /**
     * Retrieve user Ids for stakeholders based on a list of fields to check
     * @return String
     */
    private static String getStakeholderIds(SD_Runs__c sdRun, String fields){
        Set<Id> contactIds = new Set<Id>();
        String ids = '';
        if(fields != null) {
            for(String field : fields.split(',')){
                String fieldName = field.trim();
                if(sdRun.get(fieldName) != null && sdRun.get(fieldName) InstanceOf Id){
                    contactIds.add((Id)sdRun.get(fieldName));
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

    /**
     * update PJE on change of recipients so the updated recipient receives the notification
     * 
     */
    public static void updtRltdPJEToUpdtReciepients(List<SD_Runs__c> updatedList, Map<Id,SD_Runs__c> existingRecords){
        List<SD_Runs__c> sdRunsToUpdtLst = new List<SD_Runs__c>();
        fetchPSAEvents();
        
        for(PSA_Event__c event : psaEvents){
            for(SD_Runs__c sdRun : updatedList){
                Boolean plannedDtChanged = false, primaryResChanged = false, secResChanged = false, otherResChanged = false;
                if(event.Planned_Date_Field__c != null){
                    plannedDtChanged = sdRun.get(event.Planned_Date_Field__c) != (existingRecords.get(sdRun.Id)).get(event.Planned_Date_Field__c);
                }
                if(event.Primary_Resource_Field__c != null){
                    primaryResChanged = sdRun.get(event.Primary_Resource_Field__c) != (existingRecords.get(sdRun.Id)).get(event.Primary_Resource_Field__c);
                }
                if(event.Secondary_Resource_Field__c != null){
                    secResChanged = sdRun.get(event.Secondary_Resource_Field__c) != (existingRecords.get(sdRun.Id)).get(event.Secondary_Resource_Field__c);
                }           
                if(event.Other_Resource_Field__c != null){
                    otherResChanged = sdRun.get(event.Other_Resource_Field__c) != (existingRecords.get(sdRun.Id)).get(event.Other_Resource_Field__c);
                }
                if(plannedDtChanged || primaryResChanged || secResChanged || otherResChanged){
                    if(!sdRunsToUpdtLst.contains(sdRun)){
                       sdRunsToUpdtLst.add(sdRun);
                    }
                }
                
            }
        }
        
        Set<Id> reportIds = new Set<Id>(new Map<Id,SD_Runs__c>(sdRunsToUpdtLst).keySet());
        Set<String> eventFields = new SLT_Project_Event().getDefaultFields();
        Map<Id,Date> projectEventsToActualDateMap = new Map<Id,Date>();
        List<Project_Event__c> events = new SLT_Project_Event().getProjectEventsBysdRun(reportIds, eventFields);
        
        Map<Id, List<Project_Event__c>> sdRunToPJEMap = new Map<Id, List<Project_Event__c>>();
        for (Project_Event__c pje : events) {
            List<Project_Event__c> tempMSList = sdRunToPJEMap.get(pje.SD_Runs__c);

            if (tempMSList != null) {
                tempMSList.add(pje);
                sdRunToPJEMap.put(pje.SD_Runs__c,tempMSList);
            } else {
                sdRunToPJEMap.put(pje.SD_Runs__c, new List<Project_Event__c>{pje});
            }
        }
        
        List<Project_Event__c> allPjeEvents = new List<Project_Event__c>();
        for(SD_Runs__c sdRun : sdRunsToUpdtLst){
            if( sdRunToPJEMap.containsKey( sdRun.Id ) && sdRunToPJEMap.get(sdRun.Id) != null ){
                List<Project_Event__c> pjeEvents = sdRunToPJEMap.get(sdRun.Id);
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
    public static void sendEmailNotification(List<SD_Runs__c> newList, Map<Id,SD_Runs__c> oldMap){
        List<Workflow_Email_Record__c> workflowEmailRecList = new List<Workflow_Email_Record__c>();
        List<Contact> resourceList = new List<Contact>();
        Map<Id, pse__HolidayObj__c> holidayIdToHolidayRecordMap = new Map<Id, pse__HolidayObj__c>();
        Map<Id, Set<String>> workCalendarIdToHolidayDateSetMap = new Map<Id, Set<String>>();
        String emailSubject ='';
        String emailOverallBodyContent = '';
        Set<Id> sdRunIdSet = new Set<Id>();
        String uniqueKey = '';
        SD_Runs__c sdRecord;
        Set<Id> smSpecialistIdSet = new Set<Id>();
        Map<String, Set<Id>> uniqueKeyToSdRunIdSetMap = new Map<String, Set<Id>>();
        Workflow_Email_Record__c objWorkFlowEmail;
        Map<Id, SD_Runs__c> sdRunIdToSendToEmailSdRunMap = new Map<Id, SD_Runs__c>();
        Integer content1FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.content_1__c.getLength();
        Integer content2FieldLength = Schema.SObjectType.Workflow_Email_Record__c.fields.content_2__c.getLength();
        Set<String> sdRunFieldSet = new Set<String>{'Id', 'Name', 'Date_Draft_Sent_for_QC__c', 'SM_Specialist__c', 
            'Account__r.Name', 'Product__r.Name', 'SD_Run_Unique_ID__c', 'SM_Specialist__r.Name', 'SD_Document_Name__c',
            'Project_Code__c', 'SM_Specialist__r.Email','SM_QC_Reviewer__r.Email', 'Service_Line_Lead__r.Email',
            'Date_QC_Completed__c', 'SM_QC_Reviewer__r.Name','Medical_Safety_Advisor__r.Email','SD_Document_Link__c',
            'Date_Draft_sent_for_Medical_Review__c','Date_Medical_Review_Completed__c','Date_final_Draft_Ready_for_SMT_Review__c',
            'Link_to_Reviewed_Source__c','Name_Reviewed_Source__c'
            };
        Set<String> contactFieldSet = new Set<String>{'Id', 'pse__Work_Calendar__c'};
        Set<String> holidayFieldSet = new Set<String>{'Id', 'Name', 'pse__Date__c', 'pse__Work_Calendar__c'};
        Set<Id> workCalendarIdSet = new Set<Id>();
        Map<String, String> resourceIdToWorkCalendarIdMap = new Map<String, String>();
        Date workingDate;
        Set<String> holidayList = new Set<String>();
        for(SD_Runs__c sdRun : newList){
            if(sdRun.Date_Draft_Sent_for_QC__c != null 
               && sdRun.SM_Specialist__c != null
               && (trigger.isInsert || (trigger.isUpdate && sdRun.Date_Draft_Sent_for_QC__c != oldMap.get(sdRun.Id).Date_Draft_Sent_for_QC__c)))
            {
                sdRunIdSet.add(sdRun.Id);
                smSpecialistIdSet.add(sdRun.SM_Specialist__c);
                if(uniqueKeyToSdRunIdSetMap.containsKey(CON_PSA.CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_QC)){
                    uniqueKeyToSdRunIdSetMap.get(CON_PSA.CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_QC).add(sdRun.Id);
                }else{
                    uniqueKeyToSdRunIdSetMap.put(CON_PSA.CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_QC, new Set<Id>{sdRun.Id});
                }
            }
            if(sdRun.Date_QC_Completed__c != null 
               && (trigger.isInsert || (trigger.isUpdate && sdRun.Date_QC_Completed__c != oldMap.get(sdRun.Id).Date_QC_Completed__c))){
                   sdRunIdSet.add(sdRun.Id);
                   if(uniqueKeyToSdRunIdSetMap.containsKey(CON_PSA.CONSTANT_SD_RUN_DATE_QC_COMPLETED)){
                       uniqueKeyToSdRunIdSetMap.get(CON_PSA.CONSTANT_SD_RUN_DATE_QC_COMPLETED).add(sdRun.Id);
                   }else{
                       uniqueKeyToSdRunIdSetMap.put(CON_PSA.CONSTANT_SD_RUN_DATE_QC_COMPLETED, new Set<Id>{sdRun.Id});
                   }
               }
            if(sdRun.Date_Draft_sent_for_Medical_Review__c != null
               && (trigger.isInsert || (trigger.isUpdate && sdRun.Date_Draft_sent_for_Medical_Review__c != oldMap.get(sdRun.Id).Date_Draft_sent_for_Medical_Review__c)))
            {
                sdRunIdSet.add(sdRun.Id);
                if(uniqueKeyToSdRunIdSetMap.containsKey(CON_PSA.CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_MEDICAL_REVIEW)){
                    uniqueKeyToSdRunIdSetMap.get(CON_PSA.CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_MEDICAL_REVIEW).add(sdRun.Id);
                }else{
                    uniqueKeyToSdRunIdSetMap.put(CON_PSA.CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_MEDICAL_REVIEW, new Set<Id>{sdRun.Id});
                }
            }
            if(sdRun.Date_Medical_Review_Completed__c != null 
               && (trigger.isInsert || (trigger.isUpdate && sdRun.Date_Medical_Review_Completed__c != oldMap.get(sdRun.Id).Date_Medical_Review_Completed__c)))
            {
                sdRunIdSet.add(sdRun.Id);
                if(uniqueKeyToSdRunIdSetMap.containsKey(CON_PSA.CONSTANT_SD_RUN_DATE_MEDICAL_REVIEW_COMPLETED)){
                    uniqueKeyToSdRunIdSetMap.get(CON_PSA.CONSTANT_SD_RUN_DATE_MEDICAL_REVIEW_COMPLETED).add(sdRun.Id);
                }else{
                    uniqueKeyToSdRunIdSetMap.put(CON_PSA.CONSTANT_SD_RUN_DATE_MEDICAL_REVIEW_COMPLETED, new Set<Id>{sdRun.Id});
                }
            }
            if(sdRun.Date_final_Draft_Ready_for_SMT_Review__c != null
               && (trigger.isInsert || (trigger.isUpdate && sdRun.Date_final_Draft_Ready_for_SMT_Review__c != oldMap.get(sdRun.Id).Date_final_Draft_Ready_for_SMT_Review__c)))
            {
                sdRunIdSet.add(sdRun.Id);
                if(uniqueKeyToSdRunIdSetMap.containsKey(CON_PSA.CONSTANT_SD_RUN_DATE_FINAL_DARFT_READY_FOR_SMT_REVIEW)){
                    uniqueKeyToSdRunIdSetMap.get(CON_PSA.CONSTANT_SD_RUN_DATE_FINAL_DARFT_READY_FOR_SMT_REVIEW).add(sdRun.Id);
                }else{
                    uniqueKeyToSdRunIdSetMap.put(CON_PSA.CONSTANT_SD_RUN_DATE_FINAL_DARFT_READY_FOR_SMT_REVIEW, new Set<Id>{sdRun.Id});
                }
            }
        }
        if(sdRunIdSet.size() > 0){
            sdRunIdToSendToEmailSdRunMap =  new SLT_SdRun().getSdRunMapBySdRunIds(sdRunIdSet, sdRunFieldSet);
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
            if(sdRunIdToSendToEmailSdRunMap.size() > 0){
                if(uniqueKeyToSdRunIdSetMap.containskey(CON_PSA.CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_QC)){   
                    for(Id sdId : uniqueKeyToSdRunIdSetMap.get(CON_PSA.CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_QC)){
                        if(sdRunIdToSendToEmailSdRunMap.containsKey(sdId)){
                            sdRecord = sdRunIdToSendToEmailSdRunMap.get(sdId);
                            if(sdRecord.SD_Run_Unique_ID__c != null){
                                uniqueKey = sdRecord.SD_Run_Unique_ID__c.left(3)+sdRecord.SD_Run_Unique_ID__c.right(9);
                            }
                            objWorkFlowEmail = new Workflow_Email_Record__c();
                            if(sdRecord.SM_Specialist__r.Email != null){
                                objWorkFlowEmail.To_Email_1__c = sdRecord.SM_Specialist__r.Email;
                            }
                            if(sdRecord.SM_QC_Reviewer__r.Email != null){
                                objWorkFlowEmail.To_Email_2__c = sdRecord.SM_QC_Reviewer__r.Email;
                            }
                            if(sdRecord.Service_Line_Lead__r.Email != null){
                                objWorkFlowEmail.To_Email_3__c = sdRecord.Service_Line_Lead__r.Email;
                            }
                            holidayList = null;
                            if(sdRecord.SM_Specialist__c != null
                               && resourceIdToWorkCalendarIdMap.containsKey(sdRecord.Service_Line_Lead__c)
                               && resourceIdToWorkCalendarIdMap.get(sdRecord.Service_Line_Lead__c) != null
                               && workCalendarIdToHolidayDateSetMap.containsKey(resourceIdToWorkCalendarIdMap.get(sdRecord.Service_Line_Lead__c))
                               && workCalendarIdToHolidayDateSetMap.get(resourceIdToWorkCalendarIdMap.get(sdRecord.Service_Line_Lead__c)).size() > 0
                              ){
                                  holidayList = workCalendarIdToHolidayDateSetMap.get(resourceIdToWorkCalendarIdMap.get(sdRecord.Service_Line_Lead__c));
                              }
                            workingDate = UTL_PSA.calculateWorkingDate(sdRecord.Date_Draft_Sent_for_QC__c, 1, holidayList);
                            if(objWorkFlowEmail.To_Email_1__c != null || objWorkFlowEmail.To_Email_2__c != null || objWorkFlowEmail.To_Email_3__c != null  || Test.isRunningTest()){
                                emailSubject = sdRecord.Account__r.Name != null ? '[' + sdRecord.Account__r.Name.substring(0,3) + ']' : '';
                                emailSubject += ' ';
                                emailSubject += sdRecord.Product__r.Name != null ? '[' + sdRecord.Product__r.Name + ']' : '';
                                emailSubject += ' ';
                                emailSubject += uniqueKey != null ? '[' + uniqueKey + ']' : ''; 
                                emailSubject += ' Draft Ready for QC Review ALERT';     
                                emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Hi,<br><br>';
                                emailOverallBodyContent += 'The Draft is ready for QC. Please act accordingly.'+'<br><br>'; 
                                emailOverallBodyContent+= createEmailBody(sdRecord, CON_PSA.CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_QC, uniqueKey, workingDate);
                                objWorkFlowEmail.Email_Action__c = CON_PSA.SD_RUN_SEND_EMAIL_NOTIFICATION;
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
                if(uniqueKeyToSdRunIdSetMap.containskey(CON_PSA.CONSTANT_SD_RUN_DATE_QC_COMPLETED)){   
                    for(Id sdId : uniqueKeyToSdRunIdSetMap.get(CON_PSA.CONSTANT_SD_RUN_DATE_QC_COMPLETED)){
                        if(sdRunIdToSendToEmailSdRunMap.containsKey(sdId)){
                            sdRecord = sdRunIdToSendToEmailSdRunMap.get(sdId);
                            if(sdRecord.SD_Run_Unique_ID__c != null){
                                uniqueKey = sdRecord.SD_Run_Unique_ID__c.left(3)+sdRecord.SD_Run_Unique_ID__c.right(9);
                            }
                            objWorkFlowEmail = new Workflow_Email_Record__c();
                            if(sdRecord.SM_Specialist__r.Email != null ){
                                objWorkFlowEmail.To_Email_1__c = sdRecord.SM_Specialist__r.Email;
                            }
                            if(sdRecord.SM_QC_Reviewer__r.Email != null){
                                objWorkFlowEmail.To_Email_2__c = sdRecord.SM_QC_Reviewer__r.Email;
                            }
                            if(sdRecord.Service_Line_Lead__r.Email != null){
                                objWorkFlowEmail.To_Email_3__c = sdRecord.Service_Line_Lead__r.Email;
                            }
                            if(objWorkFlowEmail.To_Email_1__c != null || objWorkFlowEmail.To_Email_2__c != null || objWorkFlowEmail.To_Email_3__c != null || Test.isRunningTest()){
                                emailSubject = sdRecord.Account__r.Name != null ? '[' + sdRecord.Account__r.Name.substring(0,3) + ']' : '';
                                emailSubject += ' ';
                                emailSubject += sdRecord.Product__r.Name != null ? '[' + sdRecord.Product__r.Name + ']' : '';
                                emailSubject += ' ';
                                emailSubject += uniqueKey != null ? '[' + uniqueKey + ']' : ''; 
                                emailSubject += ' QC Review Completed ALERT';     
                                emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Hi,<br><br>';
                                emailOverallBodyContent += 'The quality review of the draft is completed. Please act accordingly.'+'<br><br>'; 
                                emailOverallBodyContent+= createEmailBody(sdRecord, CON_PSA.CONSTANT_SD_RUN_DATE_QC_COMPLETED, uniqueKey, null);
                                objWorkFlowEmail.Email_Action__c = CON_PSA.SD_RUN_SEND_EMAIL_NOTIFICATION;
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
                if(uniqueKeyToSdRunIdSetMap.containskey(CON_PSA.CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_MEDICAL_REVIEW)){   
                    for(Id sdId : uniqueKeyToSdRunIdSetMap.get(CON_PSA.CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_MEDICAL_REVIEW)){
                        if(sdRunIdToSendToEmailSdRunMap.containsKey(sdId)){
                            sdRecord = sdRunIdToSendToEmailSdRunMap.get(sdId);
                            if(sdRecord.SD_Run_Unique_ID__c != null){
                                uniqueKey = sdRecord.SD_Run_Unique_ID__c.left(3)+sdRecord.SD_Run_Unique_ID__c.right(9);
                            }
                            objWorkFlowEmail = new Workflow_Email_Record__c();
                            if(sdRecord.SM_Specialist__r.Email != null ){
                                objWorkFlowEmail.To_Email_1__c = sdRecord.SM_Specialist__r.Email;
                            }
                            if(sdRecord.SM_QC_Reviewer__r.Email != null){
                                objWorkFlowEmail.To_Email_2__c = sdRecord.SM_QC_Reviewer__r.Email;
                            }
                            if(sdRecord.Service_Line_Lead__r.Email != null){
                                objWorkFlowEmail.To_Email_3__c = sdRecord.Service_Line_Lead__r.Email;
                            }
                            if(sdRecord.Medical_Safety_Advisor__r.Email != null){
                                objWorkFlowEmail.To_Email_4__c = sdRecord.Medical_Safety_Advisor__r.Email;
                            }
                            holidayList = null;
                            if(sdRecord.SM_Specialist__c != null
                               && resourceIdToWorkCalendarIdMap.containsKey(sdRecord.Service_Line_Lead__c)
                               && resourceIdToWorkCalendarIdMap.get(sdRecord.Service_Line_Lead__c) != null
                               && workCalendarIdToHolidayDateSetMap.containsKey(resourceIdToWorkCalendarIdMap.get(sdRecord.Service_Line_Lead__c))
                               && workCalendarIdToHolidayDateSetMap.get(resourceIdToWorkCalendarIdMap.get(sdRecord.Service_Line_Lead__c)).size() > 0
                              ){
                                  holidayList = workCalendarIdToHolidayDateSetMap.get(resourceIdToWorkCalendarIdMap.get(sdRecord.Service_Line_Lead__c));
                              }
                            workingDate = UTL_PSA.calculateWorkingDate(sdRecord.Date_Draft_sent_for_Medical_Review__c, 3, holidayList);
                            if(objWorkFlowEmail.To_Email_1__c != null || objWorkFlowEmail.To_Email_2__c != null || objWorkFlowEmail.To_Email_3__c != null || Test.isRunningTest()){
                                emailSubject = sdRecord.Account__r.Name != null ? '[' + sdRecord.Account__r.Name.substring(0,3) + ']' : '';
                                emailSubject += ' ';
                                emailSubject += sdRecord.Product__r.Name != null ? '[' + sdRecord.Product__r.Name + ']' : '';
                                emailSubject += ' ';
                                emailSubject += uniqueKey != null ? '[' + uniqueKey + ']' : ''; 
                                emailSubject += ' Draft Ready for Medical Review ALERT';     
                                emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Hi,<br><br>';
                                emailOverallBodyContent += 'The Draft is ready for Medical Review. Please act accordingly.'+'<br><br>'; 
                                emailOverallBodyContent+= createEmailBody(sdRecord, CON_PSA.CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_MEDICAL_REVIEW, uniqueKey, workingDate);
                                objWorkFlowEmail.Email_Action__c = CON_PSA.SD_RUN_SEND_EMAIL_NOTIFICATION;
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
                if(uniqueKeyToSdRunIdSetMap.containskey(CON_PSA.CONSTANT_SD_RUN_DATE_MEDICAL_REVIEW_COMPLETED)){   
                    for(Id sdId : uniqueKeyToSdRunIdSetMap.get(CON_PSA.CONSTANT_SD_RUN_DATE_MEDICAL_REVIEW_COMPLETED)){
                        if(sdRunIdToSendToEmailSdRunMap.containsKey(sdId)){
                            sdRecord = sdRunIdToSendToEmailSdRunMap.get(sdId);
                            if(sdRecord.SD_Run_Unique_ID__c != null){
                                uniqueKey = sdRecord.SD_Run_Unique_ID__c.left(3)+sdRecord.SD_Run_Unique_ID__c.right(9);
                            }
                            objWorkFlowEmail = new Workflow_Email_Record__c();
                            if(sdRecord.SM_Specialist__r.Email != null ){
                                objWorkFlowEmail.To_Email_1__c = sdRecord.SM_Specialist__r.Email;
                            }
                            if(sdRecord.SM_Specialist__r.Email != null){
                                objWorkFlowEmail.To_Email_2__c = sdRecord.SM_QC_Reviewer__r.Email;
                            }
                            if(sdRecord.SM_Specialist__r.Email != null){
                                objWorkFlowEmail.To_Email_3__c = sdRecord.Service_Line_Lead__r.Email;
                            }
                            if(sdRecord.Medical_Safety_Advisor__r.Email != null){
                                objWorkFlowEmail.To_Email_4__c = sdRecord.Medical_Safety_Advisor__r.Email;
                            }
                            if(objWorkFlowEmail.To_Email_1__c != null || objWorkFlowEmail.To_Email_2__c != null || objWorkFlowEmail.To_Email_3__c != null || objWorkFlowEmail.To_Email_4__c != null || Test.isRunningTest()){
                                emailSubject = sdRecord.Account__r.Name != null ? '[' + sdRecord.Account__r.Name.substring(0,3) + ']' : '';
                                emailSubject += ' ';
                                emailSubject += sdRecord.Product__r.Name != null ? '[' + sdRecord.Product__r.Name + ']' : '';
                                emailSubject += ' ';
                                emailSubject += uniqueKey != null ? '[' + uniqueKey + ']' : ''; 
                                emailSubject += ' Medical Review Completed ALERT';     
                                emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Hi,<br><br>';
                                emailOverallBodyContent += 'The medical review of the draft is completed. Please act accordingly.'+'<br><br>';  
                                emailOverallBodyContent+= createEmailBody(sdRecord, CON_PSA.CONSTANT_SD_RUN_DATE_MEDICAL_REVIEW_COMPLETED, uniqueKey, null);
                                objWorkFlowEmail.Email_Action__c = CON_PSA.SD_RUN_SEND_EMAIL_NOTIFICATION;
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
                if(uniqueKeyToSdRunIdSetMap.containskey(CON_PSA.CONSTANT_SD_RUN_DATE_FINAL_DARFT_READY_FOR_SMT_REVIEW)){   
                    for(Id sdId : uniqueKeyToSdRunIdSetMap.get(CON_PSA.CONSTANT_SD_RUN_DATE_FINAL_DARFT_READY_FOR_SMT_REVIEW)){
                        if(sdRunIdToSendToEmailSdRunMap.containsKey(sdId)){
                            sdRecord = sdRunIdToSendToEmailSdRunMap.get(sdId);
                            if(sdRecord.SD_Run_Unique_ID__c != null){
                                uniqueKey = sdRecord.SD_Run_Unique_ID__c.left(3)+sdRecord.SD_Run_Unique_ID__c.right(9);
                            }
                            objWorkFlowEmail = new Workflow_Email_Record__c();
                            if(sdRecord.SM_Specialist__r.Email != null ){
                                objWorkFlowEmail.To_Email_1__c = sdRecord.SM_Specialist__r.Email;
                            }
                            if(sdRecord.SM_Specialist__r.Email != null){
                                objWorkFlowEmail.To_Email_2__c = sdRecord.SM_QC_Reviewer__r.Email;
                            }
                            if(sdRecord.SM_Specialist__r.Email != null){
                                objWorkFlowEmail.To_Email_3__c = sdRecord.Service_Line_Lead__r.Email;
                            }
                            if(objWorkFlowEmail.To_Email_1__c != null || objWorkFlowEmail.To_Email_2__c != null || objWorkFlowEmail.To_Email_3__c != null || Test.isRunningTest()){
                                emailSubject = sdRecord.Account__r.Name != null ? '[' + sdRecord.Account__r.Name.substring(0,3) + ']' : '';
                                emailSubject += ' ';
                                emailSubject += sdRecord.Product__r.Name != null ? '[' + sdRecord.Product__r.Name + ']' : '';
                                emailSubject += ' ';
                                emailSubject += uniqueKey != null ? '[' + uniqueKey + ']' : ''; 
                                emailSubject += ' Final Draft Ready for SMT Review ALERT';     
                                emailOverallBodyContent = '<div style="background-color=white;text-align=left;"><br><p style="font-size:13px;font-family:arial;">Hi,<br><br>';
                                emailOverallBodyContent += 'The final draft is ready for SMT review. Please act accordingly.'+'<br><br>';  
                                emailOverallBodyContent+= createEmailBody(sdRecord, CON_PSA.CONSTANT_SD_RUN_DATE_FINAL_DARFT_READY_FOR_SMT_REVIEW, uniqueKey, null);
                                objWorkFlowEmail.Email_Action__c = CON_PSA.SD_RUN_SEND_EMAIL_NOTIFICATION;
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
    
    public static String createEmailBody(SD_Runs__c sdRecord, String contentType, String uniqueKey, Date workingDate){
        String sdDocumentName  = sdRecord.SD_Document_Name__c != null ? sdRecord.SD_Document_Name__c : 'SD Document Link';
        String nameReviewedSource  = sdRecord.Name_Reviewed_Source__c != null ? sdRecord.Name_Reviewed_Source__c : 'Link to Reviewed Source';
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
        emailOverallBodyContentList.add(contentType);
        emailOverallBodyContentList.add('</th>');
        emailOverallBodyContentList.add(thStyle);
        if(contentType == CON_PSA.CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_QC){
            emailOverallBodyContentList.add(' Due Date for Review </th>');
            emailOverallBodyContentList.add(thStyle);
            emailOverallBodyContentList.add(' SM Specialist Name ');
        }else if(contentType == CON_PSA.CONSTANT_SD_RUN_DATE_QC_COMPLETED){
            emailOverallBodyContentList.add(' SM QC Reviewer '); 
        }else if(contentType == CON_PSA.CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_MEDICAL_REVIEW){
            emailOverallBodyContentList.add(' Due Date for Review </th>');
            emailOverallBodyContentList.add(thStyle);
            emailOverallBodyContentList.add(' SM Specialist Name ');
        }else if(contentType == CON_PSA.CONSTANT_SD_RUN_DATE_MEDICAL_REVIEW_COMPLETED){
            emailOverallBodyContentList.add(' SM Specialist Name ');
        }else if(contentType == CON_PSA.CONSTANT_SD_RUN_DATE_FINAL_DARFT_READY_FOR_SMT_REVIEW){
            emailOverallBodyContentList.add(' SM Specialist Name '); 
        }
        emailOverallBodyContentList.add(thStyle + ' Link to Reviewed Source </th>');
        emailOverallBodyContentList.add(thStyle + ' SD  Document Link </th>');
        emailOverallBodyContentList.add('<th> PSA Link </th>'); 
        emailOverallBodyContentList.add('</tr>');
        
        // Add the data rows
        emailOverallBodyContentList.add('<tr>');
        emailOverallBodyContentList.add(tdStyle); 
        emailOverallBodyContentList.add(sdRecord.Account__r.Name != null ? sdRecord.Account__r.Name : '');
        emailOverallBodyContentList.add('</td>');
        emailOverallBodyContentList.add(tdStyle);
        emailOverallBodyContentList.add(sdRecord.Project_Code__c != null ? sdRecord.Project_Code__c : '');
        emailOverallBodyContentList.add('</td>');
        emailOverallBodyContentList.add(tdStyle);
        if(contentType == CON_PSA.CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_QC){
            emailOverallBodyContentList.add(sdRecord.Date_Draft_Sent_for_QC__c != null ? String.valueOf(sdRecord.Date_Draft_Sent_for_QC__c) : '');
        }else if(contentType == CON_PSA.CONSTANT_SD_RUN_DATE_QC_COMPLETED){
            emailOverallBodyContentList.add(sdRecord.Date_QC_Completed__c != null ? String.valueOf(sdRecord.Date_QC_Completed__c) : '');
        }else if(contentType == CON_PSA.CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_MEDICAL_REVIEW){
            emailOverallBodyContentList.add( sdRecord.Date_Draft_sent_for_Medical_Review__c != null ? String.valueOf(sdRecord.Date_Draft_sent_for_Medical_Review__c) : '');
        }else if(contentType == CON_PSA.CONSTANT_SD_RUN_DATE_MEDICAL_REVIEW_COMPLETED){
            emailOverallBodyContentList.add(sdRecord.Date_Medical_Review_Completed__c != null ? String.valueOf(sdRecord.Date_Medical_Review_Completed__c) : '');
        }else if(contentType == CON_PSA.CONSTANT_SD_RUN_DATE_FINAL_DARFT_READY_FOR_SMT_REVIEW){
            emailOverallBodyContentList.add(sdRecord.Date_final_Draft_Ready_for_SMT_Review__c != null ? String.valueOf(sdRecord.Date_final_Draft_Ready_for_SMT_Review__c) : '');
        }
        emailOverallBodyContentList.add('</td>');
        emailOverallBodyContentList.add(tdStyle);
        if(contentType == CON_PSA.CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_QC){
            emailOverallBodyContentList.add(workingDate != null ? String.valueOf(workingDate) : '');
            emailOverallBodyContentList.add('</td>');
            emailOverallBodyContentList.add(tdStyle);
            emailOverallBodyContentList.add(sdRecord.SM_Specialist__r.Name != null ? sdRecord.SM_Specialist__r.Name : ''); 
        }else if(contentType == CON_PSA.CONSTANT_SD_RUN_DATE_QC_COMPLETED){
            emailOverallBodyContentList.add(sdRecord.SM_QC_Reviewer__r.Name != null ? sdRecord.SM_QC_Reviewer__r.Name : '');
        }else if(contentType == CON_PSA.CONSTANT_SD_RUN_DATE_DRAFT_SENT_FOR_MEDICAL_REVIEW){
            emailOverallBodyContentList.add(workingDate != null ? String.valueOf(workingDate) : '');
            emailOverallBodyContentList.add('</td>');
            emailOverallBodyContentList.add(tdStyle);
            emailOverallBodyContentList.add(sdRecord.SM_Specialist__r.Name != null ? sdRecord.SM_Specialist__r.Name : '');
        }else if(contentType == CON_PSA.CONSTANT_SD_RUN_DATE_MEDICAL_REVIEW_COMPLETED){
            emailOverallBodyContentList.add(sdRecord.SM_Specialist__r.Name != null ? sdRecord.SM_Specialist__r.Name : '');
        }else if(contentType == CON_PSA.CONSTANT_SD_RUN_DATE_FINAL_DARFT_READY_FOR_SMT_REVIEW){
            emailOverallBodyContentList.add(sdRecord.SM_Specialist__r.Name != null ? sdRecord.SM_Specialist__r.Name : '');
        }
        emailOverallBodyContentList.add('</td>');
        emailOverallBodyContentList.add(tdStyle);
        if(sdRecord.Link_to_Reviewed_Source__c != null){
            emailOverallBodyContentList.add('<a href="' + sdRecord.Link_to_Reviewed_Source__c + '">' + nameReviewedSource + '</a>'); 
        }else{
            emailOverallBodyContentList.add('');            
        }
        
        emailOverallBodyContentList.add('</td>');
        emailOverallBodyContentList.add(tdStyle);
        if(sdRecord.SD_Document_Link__c != null){
            emailOverallBodyContentList.add('<a href="' + sdRecord.SD_Document_Link__c + '">' + sdDocumentName+ '</a>');
        }else{
            emailOverallBodyContentList.add('');
        }
        emailOverallBodyContentList.add('</td>');
        emailOverallBodyContentList.add('<td style="border-top:groove;">');
        emailOverallBodyContentList.add('<a href="' + URL.getOrgDomainUrl().toExternalForm() + '/' + sdRecord.Id + '">' + uniqueKey + '</a>');
        emailOverallBodyContentList.add('</td> </tr> </table> <br> Thank You<br><br> </div>');
        return String.join(emailOverallBodyContentList, '');
    }
    
    public class sdRunFieldException extends Exception {}
} 
