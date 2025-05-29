/**
* This is Aggregate Report trigger handler class.
* version : 1.0
*/
public class DAOH_Aggregate_Report {
   
    private static List<PSA_Event__c> psaEvents;
    private static Set<String> eventDateFields;
    private static Map<String,Map<String,PSA_Event__c>> dateFieldToPSAEventMap;
    private static Set<String> sanofiRecordTypeNames = new Set<String>{CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_GSO, CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_PVS};
    private static Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Aggregate_Report__c').getDescribe().fields.getMap();
    private static Set<Id> skipDrugCheckIdSet = new Set<Id>();
    private static Set<Id> childUpdatedAggRecordSet = new Set<Id>();
    /**
     * This method ensures a report has at least one drug on it
     */
    public static void validateReportDrugs(List<Aggregate_Report__c> updatedList, Map<Id,Aggregate_Report__c> existingRecords, Map<String, Set<String>> methodToRecordTypeMap){
        List<Id> reportIds = new List<Id>();
        List<Aggregate_Report__c> reportsToCheck = new List<Aggregate_Report__c>();
        for(Aggregate_Report__c agReport : updatedList){
            String recordTypeName = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId).getDeveloperName();

            if( Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId) == null ||
                !methodToRecordTypeMap.get('validateReportDrugs').contains(recordTypeName) ) {
                continue;
            }

            if(!skipDrugCheckIdSet.contains(agReport.Id)){
                reportIds.add(agReport.Id);
                reportsToCheck.add(agReport);
                
                //Add parent report ids too
                if(agReport.Primary_Report__c != null){
                    reportIds.add(agReport.Primary_Report__c);
                }
            }
        }

        if(reportIds.size() > 0){
            Set<Id> reportsWithDrugs = new Set<Id>();
            List<Report_Drug__c> reportDrugs = [SELECT Id, Name, Aggregate_Report__c FROM Report_Drug__c WHERE Aggregate_Report__c IN :reportIds];
            for(Report_Drug__c drug : reportDrugs){
                reportsWithDrugs.add(drug.Aggregate_Report__c);
            }
            for(Aggregate_Report__c report : reportsToCheck){
                if(skipDrugCheckIdSet.contains(report.Id)){
                    continue;
                }
                if( reportsWithDrugs.contains(report.Id)){
                    skipDrugCheckIdSet.add(report.Id);
                    continue;
                }

                //For inserts, if it's a standalone report, we have to live with it
                if(Trigger.isInsert){
                    skipDrugCheckIdSet.add(report.Id);
                    if (report.Status__c == 'Completed') {
                        report.addError('Status__c','You cannot mark your new report complete until at least one Report Drug has been added. Choose a different status, create your report, add a Report Drug, and then set status to complete.');
                    }
                    if(report.Primary_Report__c != null && !reportsWithDrugs.contains(report.Primary_Report__c)){
                        report.addError('Primary_Report__c','This report will inherit report drugs from the Primary Report. Add at least one Report Drug to the parent before creating this child report.');
                    }
                }

            //   For updates, there should always be drugs
                 if(Trigger.isUpdate){
                     if (report.Status__c != 'Cancelled' ) {
                          report.addError('Status__c','This report must have at least one report drug associated with it to be saved.');
                        
                    }
                }
            }
        }
    }

    /**
     * This method performs field validations
     */
    public static void validateFields(List<Aggregate_Report__c> updatedList, Map<Id,Aggregate_Report__c> existingRecords, Map<String, Set<String>> methodToRecordTypeMap){
        Boolean errorFound = false;
        Set<Id> reportContactIdSet = new Set<Id>();
        Set<Id> reportProjectIdSet = new Set<Id>();
        Set<Id> countryReportIds = new Set<Id>();
        Map<Id,pse__Proj__c> projectsMap;
        Map<Id,List<Report_Country__c>> reportCountriesMap;
        Map<Id,Contact> resourceMap;
        Map<Id,Map<Id,List<pse__Assignment__c>>> assignmentMap; //Map is: Project Id => {Resource Id => Assignment}
        List<Aggregate_Report__c> filteredReportList = new List<Aggregate_Report__c>();
        List<Messaging.SingleEmailMessage> validationEmails = new List<Messaging.SingleEmailMessage>();
        PSA_RDS_Settings__c rdsSettings= PSA_RDS_Settings__c.getInstance();
        Map<Id,Drug__c> drugMap = new Map<Id,Drug__c>();
        Set<Id> drugIdSet = new Set<Id>();

        //First loop filters reports to those needing validation and collects Ids so related validation data can be queried efficiently
        for(Aggregate_Report__c agReport : updatedList){
            String recordTypeName = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId).getDeveloperName();

            if( Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId) == null ||
                !methodToRecordTypeMap.get('validateFields').contains(recordTypeName) ) {
                continue;
            }
            if (agReport.Status__c == 'Cancelled' && (recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_GSO || recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_PVS)) {
                continue;
            }
            filteredReportList.add(agReport);
            reportProjectIdSet.add(agReport.Project__c);
            if(agReport.Product_Name_Active_Ingredient__c != null ) {
                drugIdSet.add(agReport.Product_Name_Active_Ingredient__c);
            }
            
            if(agReport.Id != null && agReport.Report_Countries_Required__c == 'Yes'){
                countryReportIds.add(agReport.Id);
            }

            Set<String> contactFieldSet = buildContactFieldSet(recordTypeName);
            for(String contactField : contactFieldSet){
                if(agReport.get( contactField ) != null ){
                    reportContactIdSet.add( (Id)agReport.get( contactField ) );
                }
            }
        }

        if(filteredReportList.size() == 0){
            return;
        }

        //Data needed to perform validations is now collected
        projectsMap = new SLT_Project(false, false).getProjectById(reportProjectIdSet, new Set<String>{'Id', 'pse__Start_Date__c', 'pse__End_Date__c','Service_Line__r.Name'});
        resourceMap = new SLT_Contact(false, false).selectByContactId(reportContactIdSet, new Set<String>{'Id', 'Location_Code_text__c','pse__Salesforce_User__r.isActive'});
        assignmentMap = buildAssignmentMap(reportContactIdSet, reportProjectIdSet);
        reportCountriesMap = buildCountriesMap(countryReportIds);
        drugMap = new SLT_Drug(false,false).getDrugById(drugIdSet,new Set<String>{'Id','Service_Lines__c'});
            
        //Main Validation loop
       for(Aggregate_Report__c agReport : filteredReportList){
            String recordTypeName = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId).getDeveloperName();

            //Validations for ALL reports
            validateActualDates(agReport, recordTypeName);
            validateGenericDependencies(agReport, recordTypeName);
            validateContactSubRoles(agReport, recordTypeName, assignmentMap.get(agReport.Project__c));
            if(agReport != null && projectsMap != null && projectsMap.size() > 0 && drugMap != null && drugMap.size() > 0 && recordTypeName != null){
                if(methodToRecordTypeMap.get('validateProductDrug').contains(recordTypeName))  {
                    validateProductDrug(agReport,projectsMap,drugMap);    
                }
            }
            
            if(rdsSettings.Send_aggregate_report_validation_emails__c == true){
                validateStartAndEndDates(agReport, recordTypeName, projectsMap.get(agReport.Project__c), validationEmails);
                validateContactAssignments(agReport, recordTypeName, assignmentMap.get(agReport.Project__c), validationEmails);
            }

            if(sanofiRecordTypeNames.contains(recordTypeName)){
                if( agReport.Task_Type__c == 'Other Activities' && String.isBlank(agReport.Activity_DetailsEvent_Name__c) ) {
                    agReport.addError('Please enter the other activity details as ‘Deliverable’ selected is ‘Other Activities’');
                    errorFound = true;
                }
            }

            if( agReport.Status__c == 'Completed' ){

                validateContactsOnCompletion(agReport, recordTypeName, resourceMap);
                validateGeneric(agReport, recordTypeName, true);
                validateDates(agReport, recordTypeName, true);

                if(sanofiRecordTypeNames.contains(recordTypeName)){
                    validateSanofiOnCompletion(agReport,recordTypeName);
                } else {
                    validateNonSanofiOnCompletion(agReport,recordTypeName);

                    if( agReport.Service_Milestone__c == null){
                        agReport.addError('You must specify a service milestone before completing a report.');
                        errorFound = true;
                    }
                    
                    if(agReport.Date_Submitted_to_IQVIA_or_Client_Reg__c == null && recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA) {
                        agReport.addError('Please fill in the \'Date Submitted to IQVIA or Client Reg\' before marking the report complete.');
                        errorFound = true;
                    }

                    if( agReport.Report_Countries_Required__c == 'Yes' && 
                        (reportCountriesMap.get(agReport.Id) == null || reportCountriesMap.get(agReport.Id).size() == 0 )){ 
                            agReport.addError('This report requires you to add at least one Report Country before marking it Completed.');
                            errorFound = true;
                    }
                    if( agReport.Customer_Requested_Resource_Location__c == null ) {
                        agReport.addError('You must set the Customer Requested Resource Location before completing this report.');
                        errorFound = true;
                    }
                }
            } else {
                validateGeneric(agReport, recordTypeName, false);
                validateDates(agReport, recordTypeName, false);
            }
            if(trigger.isInsert && trigger.isBefore && agReport.Primary_Report__c != null &&
               Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId).getDeveloperName() == CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE &&
               agReport.Product_Name_Active_Ingredient__c != null){
                   agReport.addError('Product Name (Active Ingredient) inherits from the parent report, you cannot edit Product Name (Active Ingredient) field on the child report.');
                   errorFound = true;
               } 
            if(trigger.isUpdate && agReport.Primary_Report__c != null && agReport.Status__c != 'Cancelled' 
               && Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId).getDeveloperName() == CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE &&
               agReport.Product_Name_Active_Ingredient__c != existingRecords.get(agReport.Id).Product_Name_Active_Ingredient__c &&
               agReport.Primary_Report__c == existingRecords.get(agReport.Id).Primary_Report__c && !childUpdatedAggRecordSet.contains(agReport.id)){
                       agReport.addError('Product Name (Active Ingredient) inherits from the parent report, you cannot edit Product Name (Active Ingredient) field on the child report.');
                       errorFound = true;
            }
            if(agReport.Primary_Report__c == null && agReport.Is_Child_RA_Response__c == true && Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE){
               agReport.addError('You cannot remove the primary report.');
                   errorFound = true;
            }
                } 

        if(!errorFound && validationEmails.size() > 0){
            Messaging.sendEmail(validationEmails);
        }
    }
    
    /**
     * This method is validates that dates designated 'Actual' on a report are not set to a future date, and are excused if they occur after the planned date
     */
    private static void validateActualDates(Aggregate_Report__c agReport, String recordTypeName){
        Date today = Date.today();
        Map<String,String> actualToPlannedMap = (actualDatesMaps.get(recordTypeName) != null) ? actualDatesMaps.get(recordTypeName) : actualDatesMaps.get('Default');
        Map<String,String> actualToLateReasonMap = (actualToLateReasonMaps.get(recordTypeName) != null) ? actualToLateReasonMaps.get(recordTypeName) : actualToLateReasonMaps.get('Default');

        Set<String> actualDates = actualToPlannedMap.keySet();
        Set<String>  fieldsToEliminateFutureValidation = recordtypeToFieldsToEliminateMap.get(recordTypeName); 
        for(String actual : actualDates){
            String planned = actualToPlannedMap.get( actual );
            Date actualDate = Date.valueOf(agReport.get( actual ));
            Date plannedDate = Date.valueOf(agReport.get( planned ));
            //Check actuals dates are not in the future, unless user has permission to do that
            if( actualDate != null && actualDate > today && !FeatureManagement.checkPermission('SARA_Override') && !fieldsToEliminateFutureValidation.contains(actual) ){
                agReport.addError(actual,'You may not set actual date "'+getLabel(actual)+'" in the future.');
                break;
            }

            //Check actual dates are after planned dates, unless a reason is given
            if( actualDate != null && plannedDate != null && actualDate > plannedDate ) {
                List<String> reasonFields = (actualToLateReasonMap.get( actual ) != null) ? actualToLateReasonMap.get( actual ).split(',') : new List<String>();
                for(String reasonField : reasonFields){
                    if( agReport.get( reasonField ) == null ){
                        agReport.addError(actual,'When "'+getLabel(actual)+'" date is after "'+getLabel(planned)+'" you must fill out '+getLabel(reasonField)+'.');
                        break;
                    }
                }
            }
        }
    }

    //*
    private static void validateStartAndEndDates(Aggregate_Report__c agReport, String recordTypeName, pse__Proj__c project, List<Messaging.SingleEmailMessage> validationEmails) {
        if( project == null || project.pse__Start_Date__c == null ){
            return;
        }

        //Collect all the various dates on the report
        Set<String> dateFields = new Set<String>();
        Map<String,String> actualDates = actualDatesMaps.get(recordTypeName);
        Map<String,String> dateFieldtoNAField = dateFieldtoNAFieldMaps.get(recordTypeName);
        Map<String,String> actualToLateReason = actualToLateReasonMaps.get(recordTypeName);

        dateFields.addAll(actualDates.keySet());
        dateFields.addAll(actualDates.values());
        dateFields.addAll(dateFieldtoNAField.keySet());
        dateFields.addAll(actualToLateReason.keySet());

        List<String> errors = new List<String>();
        for(String dateField : dateFields){
            Date thisDate = Date.valueOf(agReport.get(dateField));
            if( thisDate != null && (thisDate < project.pse__Start_Date__c || (project.pse__End_Date__c != null && thisDate > project.pse__End_Date__c)) ) {
                errors.add(getLabel(dateField));
            }
        }

        if(errors.size() > 0){
            Set<Id> recipientIds = new Set<Id>();
            if(agReport.PV_Solutions_Lead__c != null){
                recipientIds.add(agReport.PV_Solutions_Lead__c);
            }
            if(agReport.Service_Line_Lead__c != null) {
                recipientIds.add(agReport.Service_Line_Lead__c);
            }

            if(recipientIds.size() > 0) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<Id>(recipientIds));
                mail.setSubject('Warning - Aggregate report contains invalid dates'); 
                String bodyText = 'The aggregate report '+agReport.Name+' has '+errors.size()+' dates that fall outside the project start/end dates: \n';
                bodyText += String.join(errors,'\n');
                bodyText += '\n\nPlease visit the Service Line Project detail page and update it.';
                mail.setPlainTextBody(bodyText);  
                mail.setSaveAsActivity(false);
                validationEmails.add(mail);
            }
        }
    }
    //*/

    /**
     * This method makes sure all the contacts on this report type have an assignment on the associated project
     */
    //*
    private static void validateContactAssignments(Aggregate_Report__c agReport, String recordTypeName, Map<Id,List<pse__Assignment__c>> projectAssignments, List<Messaging.SingleEmailMessage> validationEmails){

        Map<String,String> contactMap = buildContactMap(recordTypeName);
        List<String> errors = new List<String>();

        for(String contactField : contactMap.keySet()){
            if(contactField == 'PV_Solutions_Lead__c'){
                continue;
            }
            Id contactId = (Id)agReport.get( contactField );
            if( contactId != null ){
                if( projectAssignments == null || projectAssignments.get( contactId ) == null || projectAssignments.get( contactId ).size() > 1 ){
                    errors.add(getLabel(contactField));
                }
            }
        }

        if(errors.size() > 0){
            Set<Id> recipientIds = new Set<Id>();
            if(agReport.Primary_Author__c != null){
                recipientIds.add(agReport.Primary_Author__c);
            }
            if(agReport.Service_Line_Lead__c != null) {
                recipientIds.add(agReport.Service_Line_Lead__c);
            }

            if(recipientIds.size() > 0) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<Id>(recipientIds));
                mail.setSubject('Warning - Aggregate report contains contacts with no assignment'); 
                String bodyText = 'The aggregate report '+agReport.Name+' has '+errors.size()+' contacts that do not have assignments on the project: \n';
                bodyText += String.join(errors,'\n');
                mail.setPlainTextBody(bodyText);  
                mail.setSaveAsActivity(false);
                validationEmails.add(mail);
            }
        }
    }
    //*/

    /**
     * This method checks that a contact has an active assignment with a specifically mapped subrole, and prevents saving if not
     */
    private static void validateContactSubRoles(Aggregate_Report__c agReport, String recordTypeName, Map<Id, List<pse__Assignment__c>> projectAssignments){
        Map<String,String> contactRoleMap = buildContactRoleMap(recordTypeName);

        for(String contactField : contactRoleMap.keySet()){

            String fieldRole = contactRoleMap.get(contactField);
            Id contactId = (Id)agReport.get( contactField );
            List<pse__Assignment__c> assignments; 
            Boolean foundMatch = false;

            if( contactId == null ){
                continue;
            }

            if( projectAssignments != null ){
                assignments = projectAssignments.get(contactId);
            }
            if(assignments != null){

                for(pse__Assignment__c assignment : assignments){
                    if(assignment.Sub_role__c == fieldRole){
                        foundMatch = true;
                        break;
                    }
                }
            }

            if(!foundMatch){
               agReport.addError(contactField,'Resources assigned as '+fieldRole+' must have a valid assignment on the project with a sub-role of '+fieldRole);               
        }
        }
    }

    /**
     * This method validates report contacts when report is completed
     */
    private static void validateContactsOnCompletion(Aggregate_Report__c agReport, String recordTypeName, Map<Id,Contact> resourceMap) {
        Map<String,String> contactFieldMap = buildContactMap(recordTypeName);
        Boolean isSanofi = sanofiRecordTypeNames.contains(recordTypeName);

        //Check that all contacts on completed report have location set
        for(String contactField : contactFieldMap.keySet()){
            Boolean hasContact = agReport.get(contactField) != null;
            Boolean isSecondary = contactField.contains('Secondary');
            String validatingField = contactFieldMap.get(contactField);
			
         
            if( isSanofi == false && 
                agReport.get(contactField) != null && 
                resourceMap.get((Id)agReport.get(contactField)).pse__Salesforce_User__r.isActive &&
                resourceMap.get((Id)agReport.get(contactField)).Location_Code_text__c == null){

                agReport.addError('The resource for "'+getLabel(contactField)+'" must have a Location set on the Contact record.');
            }

            if( !String.isBlank(validatingField) && agReport.get(validatingField) != null ) {
                //NA or Client must be blank, IQVIA must be filled
                String validation = String.valueOf(agReport.get(validatingField));
                if(!hasContact && !isSecondary && validation == 'IQVIA'){
                    agReport.addError('Resource must be assigned to "'+getLabel(contactField)+'" when "'+getLabel(validatingField)+'" is set to "IQVIA".');
                }
                if(hasContact && (validation == 'NA' || validation == 'Client')) {
                    agReport.addError('Resource must not be assigned "'+getLabel(contactField)+'" when "'+getLabel(validatingField)+'" is set to "NA" or "Client".');
                }
            }
        }

    }

    /** 
     * This method allows us to validate that one field is not blank if another field is filled out
     **/
    private static void validateGenericDependencies(Aggregate_Report__c agReport, String recordTypeName){
        Map<String,String> dependencyMap = (dependencyMaps.get(recordTypeName) != null) ? dependencyMaps.get(recordTypeName) : dependencyMaps.get('Default');
        for(String dependentField : dependencyMap.keySet()){
            String dependency = dependencyMap.get(dependentField);
            if( agReport.get(dependentField) != null && !String.isBlank(dependency) && agReport.get(dependency) == null){
                agReport.addError(dependentField,'The field "'+getLabel(dependency)+'" must be set before you can save the field "'+getLabel(dependentField)+'".');
            }
        }
    }

    /**
     * This method validates any other fields with NA pairings when report is completed
     */
    private static void validateGeneric(Aggregate_Report__c agReport, String recordTypeName, Boolean isComplete) {

        Map<String,String> genericFieldtoNAField = genericFieldtoNAFieldMaps.get(recordTypeName);
        for(String genericField : genericFieldtoNAField.keySet()){

            String naField = genericFieldtoNAField.get(genericField);
            String naValue = (String) agReport.get( naField );  

            if (agReport.get(genericField) == null && 
                (naValue == null || naValue == 'No' || naValue == 'IQVIA')) {
                agReport.addError(genericField,'Please fill in "'+getLabel(genericField)+'" or set "'+getLabel(naField)+'" to a different value.');

            } else if (agReport.get(genericField) != null &&
                (naValue == 'Yes' || naValue == 'NA' || naValue == 'Client')) {
                agReport.addError(genericField,'You may not enter a value for "'+getLabel(genericField)+'" when "'+getLabel(naField)+'" is set to "'+naValue+'".');
            }
        }
    }
    
	/**
     * This method validates report dates and NA validations when report is completed
     */
    private static void validateDates(Aggregate_Report__c agReport, String recordTypeName, Boolean isComplete) {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
    	List<String> sectionList = new List<String> ();
    	for (String sectionRec: newFieldValidationMaps.keySet()) {
    		if (sectionRec.contains(recordTypeName)) {
    			sectionList.add(sectionRec);
    		}
    	}
        if(!mulesoftSetting.Ignore_Validation_Rules__c) {
            for (String str: sectionList) {
                Map<String, String> dateFieldtoNAField = newFieldValidationMaps.get(str);
                for (String dateField: dateFieldtoNAField.keySet()) {
                    String naField = dateFieldtoNAField.get(dateField);
                    if(agReport != null){
                        if (str.contains(CON_PSA.AGG_REPORT_SECTION_REPORT_WRITING)) {
                            if(isComplete && (agReport.get(dateField) == null &&
                                agReport.get(naField) == null )){
                                agReport.addError('Please fill in "' + getLabel(dateField) + '" or "' + getLabel(naField) + '".');
                            } else if (agReport.Report_Writing__c == 'NA' && (agReport.Primary_Author__c != null || agReport.Secondary_Author__c != null)) {
                                agReport.addError('Report_Writing__c','You have chosen NA in Report Writing, you cannot enter values in other fields in this section.');
                            }
                        } else if (str.contains(CON_PSA.AGG_REPORT_SECTION_LITR_REVIEW)) {
                            if(isComplete && (agReport.get(dateField) == null &&
                                agReport.get(naField) == null)){
                                agReport.addError('Please fill in "' + getLabel(dateField) + '" or "' + getLabel(naField) + '".');
                            } else if (agReport.Literature_Review_Requirement__c == 'NA' && (agReport.Primary_Reviewer__c != null || agReport.Secondary_Reviewer__c != null)) {
                                agReport.addError('You have chosen NA in Literaure Review Requirement, you cannot enter values in other fields in this section.');
                            } else if (agReport.Literature_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_Client && (agReport.Primary_Reviewer__c != null || agReport.Secondary_Reviewer__c != null)) {
                                agReport.addError('You have chosen Client in Literaure Review Requirement, you cannot enter values in other fields in this section.');
                            }
                        } else if (str.contains(CON_PSA.AGG_REPORT_SECTION_BRM)) {
                            if (isComplete && (agReport.BRM_Review_Requirement__c != 'NA' && agReport.BRM_Review_Requirement__c != CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_Client && agReport.get(dateField) == null &&
                                    (agReport.get(naField) == null || agReport.get(naField) == 'No'))) {
                                agReport.addError('Please fill in "' + getLabel(dateField) + '" or set "' + getLabel(naField) + '" to "Yes".');
                            } else if (agReport.BRM_Review_Requirement__c == 'NA' && (agReport.get(dateField) != null ||
                                    agReport.get(naField) == 'Yes' || agReport.Primary_BRM_Analyst__c != null || agReport.Secondary_BRM_Analyst__c != null ||
                                    agReport.BRM_Late_Responsibility__c != null || agReport.BRM_Late_Reason_Text__c != null || agReport.BRM_Late_Reason__c != null)) {
                                agReport.addError('You have chosen NA in BRM Review Requirement, you cannot enter values in other fields in this section.');
                            } else if (agReport.BRM_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_Client && (agReport.get(dateField) != null ||
                                    agReport.get(naField) == 'Yes' || agReport.get(naField) == 'No' || agReport.Primary_BRM_Analyst__c != null || agReport.Secondary_BRM_Analyst__c != null ||
                                    agReport.BRM_Late_Responsibility__c != null || agReport.BRM_Late_Reason_Text__c != null || agReport.BRM_Late_Reason__c != null)) {
                                agReport.addError('You have chosen Client in BRM Review Requirement, you cannot enter values in other fields in this section.');
                            }
                        } else if (str.contains(CON_PSA.AGG_REPORT_SECTION_MED_REVIEW)) {
                            if (isComplete && (agReport.Medical_Reviewer_Review_Requirement__c != 'NA' && agReport.Medical_Reviewer_Review_Requirement__c != CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_Client && agReport.get(dateField) == null &&
                                    (agReport.get(naField) == null || agReport.get(naField) == 'No'))) {
                                agReport.addError('Please fill in "' + getLabel(dateField) + '" or set "' + getLabel(naField) + '" to "Yes".');
                            } else if (agReport.Medical_Reviewer_Review_Requirement__c == 'NA' && (agReport.get(dateField) != null ||
                                    agReport.get(naField) == 'Yes' || agReport.Primary_Medical_Reviewer__c != null || agReport.Secondary_Medical_Reviewer__c != null ||
                                agReport.Medical_Review_Late_Responsibility__c != null || agReport.Medical_Review_Late_Reason_Text__c != null || agReport.Medical_Review_Late_Reason__c != null)) {
                                agReport.addError('You have chosen NA in Medical Review Requirement, you cannot enter values in other fields in this section.');
                            } else if (agReport.Medical_Reviewer_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_Client && (agReport.get(dateField) != null ||
                                    agReport.get(naField) == 'Yes' || agReport.get(naField) == 'No' || agReport.Primary_Medical_Reviewer__c != null || agReport.Secondary_Medical_Reviewer__c != null ||
                                agReport.Medical_Review_Late_Responsibility__c != null || agReport.Medical_Review_Late_Reason_Text__c != null || agReport.Medical_Review_Late_Reason__c != null)) {
                                agReport.addError('You have chosen Client in Medical Review Requirement, you cannot enter values in other fields in this section.');
                            }
                            
                        } else if (str.contains(CON_PSA.AGG_REPORT_SECTION_LL)) {
                            if((recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_GENERAL || recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA) && (agReport.Planned_Date_to_Request_Final_LL__c != null && agReport.Planned_Date_to_Request_Final_LL_NA__c == 'Yes') ||
                              (agReport.Actual_Date_Final_LL_Requested__c != null && agReport.Actual_Date_Final_LL_Requested_NA__c == 'Yes') ||
                              (agReport.Actual_Date_Final_LL_to_Author_Client__c != null && agReport.Actual_Date_Final_LL_to_Author_Client_N__c == 'Yes')){ 
                                  agReport.addError('You may not enter a date for Planned Date to Request Final LL, Actual Date Final LL Requested and Actual Date: Final LL to Author/Client when Planned Date to Request Final LL NA, Actual Date Final LL Requested NA, Actual Date: Final LL to Author/Client NA is set to "Yes".');
                            }
                            else if (isComplete && (agReport.Line_Listing_Review_Requirement__c != 'NA' && agReport.Line_Listing_Review_Requirement__c != CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_Client && agReport.get(dateField) == null &&
                                    (agReport.get(naField) == null || agReport.get(naField) == 'No'))) {
                                agReport.addError('Please fill in "' + getLabel(dateField) + '" or set "' + getLabel(naField) + '" to "Yes".');
                            } else if (agReport.Line_Listing_Review_Requirement__c == 'NA' && (agReport.get(dateField) != null || agReport.get(naField) == 'No' ||
                                    agReport.get(naField) == 'Yes' || agReport.Line_Listing_Reviewer__c != null || agReport.Line_Listing_QCer__c != null)) {
                                agReport.addError('You have chosen NA in Line Listing Requirement, you cannot enter values in other fields in this section.');
                            } else if (agReport.Line_Listing_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_Client && (agReport.get(dateField) != null || agReport.get(naField) == 'No' ||
                                    agReport.get(naField) == 'Yes' || agReport.Line_Listing_Reviewer__c != null || agReport.Line_Listing_QCer__c != null)) {
                                agReport.addError('You have chosen Client in Line Listing Requirement, you cannot enter values in other fields in this section.');
                            }
                        } else if (isComplete && (!(str.contains(CON_PSA.AGG_REPORT_SECTION_LL) || str.contains(CON_PSA.AGG_REPORT_SECTION_MED_REVIEW) || str.contains(CON_PSA.AGG_REPORT_SECTION_BRM) ||
                                str.contains(CON_PSA.AGG_REPORT_SECTION_LITR_REVIEW) || str.contains(CON_PSA.AGG_REPORT_SECTION_REPORT_WRITING)) && (agReport.get(dateField) == null &&
                                (agReport.get(naField) == null || agReport.get(naField) == 'No')))) {
                            agReport.addError(dateField,'Please fill in "' + getLabel(dateField) + '" or set "' + getLabel(naField) + '" to "Yes".');
                        } else if (recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE && (agReport.Line_Listing_Review_Requirement__c == 'NA' && (
                                agReport.Line_Listing_Reviewer__c != null || agReport.Line_Listing_QCer__c != null || agReport.LL_Review_Due__c != null ||
                                agReport.LL_Review_Completion_Date__c != null || agReport.LL_Review_Due_Date_NA__c != null || agReport.LL_Review_Completion_Date_NA__c != null ||
                                agReport.LL_QC_Completion_Date__c != null || agReport.LL_QC_Completion_Date_NA__c != null || agReport.LL_QC_Due_Date__c != null ||
                                agReport.LL_QC_Due_Date_NA__c != null))) {
                            agReport.addError('You have chosen NA in Line Listing Requirement, you cannot enter values in other fields in this section.');
                        } else if (recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE && (agReport.Line_Listing_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_Client && (
                                agReport.Line_Listing_Reviewer__c != null || agReport.Line_Listing_QCer__c != null || agReport.LL_Review_Due__c != null ||
                                agReport.LL_Review_Completion_Date__c != null || agReport.LL_Review_Due_Date_NA__c != null || agReport.LL_Review_Completion_Date_NA__c != null ||
                                agReport.LL_QC_Completion_Date__c != null || agReport.LL_QC_Completion_Date_NA__c != null || agReport.LL_QC_Due_Date__c != null ||
                                agReport.LL_QC_Due_Date_NA__c != null))) {
                            agReport.addError('You have chosen Client in Line Listing Requirement, you cannot enter values in other fields in this section.');
                        } else if (agReport.get(dateField) != null &&
                        	agReport.get(naFIeld) == 'Yes') {
                            agReport.addError(dateField,'You may not enter a date for "' + getLabel(dateField) + '" when "' + getLabel(naField) + '" is set to "Yes".');
                        }   
                    } 
                }
            }
        }
    }

    /**
     * This method validates Sanofi reports when a report is completed
     */
    private static void validateSanofiOnCompletion(Aggregate_Report__c agReport, String recordTypeName) {
        if(recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_GSO){
            if( String.isBlank(agReport.IQVIA_GSO_LM__c)){
                agReport.addError('IQVIA_GSO_LM__c','IQVIA GSO LM must be filled in for completed reports.');
            }
            /*if( String.isBlank(agReport.IQVIA_Secondary_GSO__c)){
                agReport.addError('IQVIA Secondary GSO must be filled in for completed reports.');
            }*/
        }

        if(recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_PVS){
            if(String.isBlank(agReport.IQVIA_GSO_LM__c) && !String.isBlank(agReport.IQVIA_Primary_GSO__c)) {
               // agReport.addError('IQVIA_GSO_LM__c','IQVIA GSO LM must be filled out when there is also an IQVIA Primary GSO.');
            }
            if( agReport.PVS_Activity_Start_Date__c == null) {
                agReport.addError('PVS_Activity_Start_Date__c','PVS Activity Start Date must be filled in for completed reports.');
            }
            if( agReport.PVS_Completion_Date__c == null) {
                agReport.addError('PVS_Completion_Date__c','PVS Completion Date must be filled in for completed reports.');
            }
        }

        //For all Sanofi record types
        if( agReport.Assigned_Date__c == null) {
            agReport.addError('Assigned_Date__c','Assigned Date must be filled in for completed reports.');
        }
        if( agReport.Client_Final_Due__c == null) {
            agReport.addError('Client_Final_Due__c','Client Final Due must be filled in for completed reports.');
        }
        if( agReport.Client_Final_Sent__c == null) {
            agReport.addError('Client_Final_Sent__c','Client Final Sent must be filled in for completed reports.');
        }
    }

    /**
     * This method validates non-Sanofi reports when a report is finished
     */
    private static void validateNonSanofiOnCompletion(Aggregate_Report__c agReport, String recordTypeName) {
       // Check non-Sanofi for some fields
      /*  if(recordTypeName != CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA && String.isBlank(agReport.Project_Files_SMP__c)){
            agReport.addError('Project Files SMP must be filled in for completed reports.');
     }
        if(recordTypeName != CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA && String.isBlank(agReport.Client_Final_Report__c)){
            agReport.addError('Client Final Report must be filled in for completed reports.');
      } */
        
        
       if((recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA || recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_GENERAL) && (agReport.Status__c == 'Completed'))
       											{
           										 if ((String.isBlank(agReport.Client_Final_Report__c) ||
                                                   String.isBlank(agReport.Report_Therapeutic_Area__c) ||
                                                   String.isBlank(agReport.Report_Countries_Required__c) ||
                                                   String.isBlank(agReport.Product_Name_Active_Ingredient__c) ||
                                                   String.isBlank(agReport.Customer_Requested_Resource_Location__c) ||
                                                   String.isBlank(agReport.Safety_Database_Location__c) ||
                                                   String.isBlank(agReport.Report_Size__c) ||
                                                   (agReport.No_of_riskssignalsindication__c == null) ||
                                                   (agReport.Report_Due_to_IQVIA_or_Client_Reg__c==null) ||
                                                   (agReport.Date_Submitted_to_IQVIA_or_Client_Reg__c == null) ||
                                                   (agReport.Report_Due_to_Reg_Agency__c==null) ||
                                                   String.isBlank(agReport.Formatting_Request__c) ||
                                                   String.isBlank(agReport.Upload_to_eTMF_Wingspan_Client_Spec_Repo__c) ||
                                                   String.isBlank(agReport.Project_Files_SMP__c) ||
                                                   String.isBlank(agReport.Client_Final_Report__c) ||
                                                   String.isBlank(agReport.eTMF_Wingspan_Client_Spec_Repo_File_Stat__c))) {
            agReport.addError('The report status is set to Completed therefore the following fields cannot be empty: Report Therapeutic Area, Report Countries Required, Product Name (Active Ingredient),  Customer Requested Resource Location, Safety Database Location, Report Size, No. of risks/signals/indication, Report Due to IQVIA or Client Reg, Date Submitted to IQVIA or Client Reg, Report Due to Reg Agency, Formatting Request, Upload to eTMF/Wingspan/Client Spec Repo, Project Files SM, Client Final Report, eTMF/Wingspan/Client Spec Repo File Stat.');
        }
  }

         if((recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA || recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_GENERAL) && (agReport.Status__c == CON_PSA.AGG_REPORT_Status_Completed) && (agReport.Line_Listing_Review_Requirement__c != CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_NA ) && (agReport.Line_Listing_Review_Requirement__c != CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_Client ))
        {
 		     if(((agReport.Planned_Date_to_Request_Draft_LL_NA__c == 'No' ) && (agReport.Planned_Date_to_Request_Draft_LL__c == null)) || 
             (  (agReport.Actual_Date_to_Request_Draft_LL_NA__c == 'No' ) && (agReport.Actual_Date_to_Request_Draft_LL__c == null)) ||
             	((agReport.Draft_LL_Request_Ticket_Number_NA__c == 'No' ) && (String.isBlank(agReport.Draft_LL_Request_Ticket_Number__c))) ||
             	 ((agReport.Plnnd_Dt_Draft_LL_to_Author_Client_NA__c == 'No' ) && (agReport.Plnnd_Date_Draft_LL_to_Author_Client__c == null)) ||
             	((agReport.Actual_Dt_Draft_LL_to_Author_ClientNA__c == 'No' ) && (agReport.Actual_Date_Draft_LL_to_Author_Client__c == null)) ||
             	((agReport.Final_Listings_Ticket_Number_NA__c == 'No' ) && (String.isBlank(agReport.Final_Listings_Ticket_Number__c))) ||
             	((agReport.Planned_Date_to_Request_Final_LL_NA__c == 'No' ) && (agReport.Planned_Date_to_Request_Final_LL__c == null))||
             	((agReport.Actual_Date_Final_LL_Requested_NA__c == 'No' ) && (agReport.Actual_Date_Final_LL_Requested__c == null)) ||
             	((agReport.Actual_Date_Final_LL_to_Author_Client_N__c == 'No' ) && (agReport.Actual_Date_Final_LL_to_Author_Client__c == null)) ||
             	((agReport.Plnnd_Date_Final_LL_to_Author_ClientNA__c == 'No' ) && (agReport.Plnnd_Date_Final_LL_to_Author_Client__c == null)))
             	 {
                 agReport.addError('The report status is set to Completed therefore the following fields cannot be empty Planned Date to Request Draft LL, Actual Date to Request Draft LL, Draft LL Request Ticket Number,Plnnd Date Draft LL to Author/Client, Actual Date Draft LL to Author/Client, Final Listings Ticket Number,  Plnnd Date: Final LL to Author/Client, Planned Date to Request Final LL, Actual Date Final LL Requested, Actual Date: Final LL to Author/Client. If listed NA fields are not marked yes the associated field must have a value');
             	}
        }
        
        
        
    }

    /**
     * Retrieves a map of contacts for the current recordtype
     */
    private static Map<String,String> buildContactMap(String recordTypeName) {
        return (contactDependencyMaps.get(recordTypeName) != null) ? contactDependencyMaps.get(recordTypeName) : contactDependencyMaps.get('Default');
    }

    /**
     * Retrieves a set of field names for contact lookups on the report
     */
    private static Set<String> buildContactFieldSet(String recordTypeName) {
        Set<String> contactFieldSet = buildContactMap(recordTypeName).keySet().clone();
        Set<String> contactRoleFieldsSet = buildContactRoleMap(recordTypeName).keySet().clone();
        Set<String> fields = new Set<String>(contactFieldSet);
        fields.addAll(contactRoleFieldsSet);
        return fields;
    }

    /**
     * Retrieves a map of contact roles for the current recordtype
     */
    private static Map<String,String> buildContactRoleMap(String recordTypeName) {
        return (contactSubRoleMaps.get(recordTypeName) != null) ? contactSubRoleMaps.get(recordTypeName) : contactSubRoleMaps.get('Default');
    }

    /**
     * Builds a map of resource Id to map of Project and Assignments
     */
    private static Map<Id,Map<Id,List<pse__Assignment__c>>> buildAssignmentMap(Set<Id> reportContactIdSet, Set<Id> reportProjectIdSet) {
        Map<Id,Map<Id,List<pse__Assignment__c>>> assignmentMap = new Map<Id,Map<Id,List<pse__Assignment__c>>>();

        List<pse__Assignment__c> contactAssignments = new SLT_Assignment(false, false).getAssignmentByResourceAndProject(reportContactIdSet, reportProjectIdSet, new Set<String>{'Id', 'pse__Resource__c', 'pse__Project__c','Sub_role__c'});
        for(pse__Assignment__c assignment : contactAssignments){
            if( assignmentMap.get( assignment.pse__Project__c ) == null ){
                assignmentMap.put( assignment.pse__Project__c, new Map<Id,List<pse__Assignment__c>>() );
            }
            List<pse__Assignment__c> assignmentList = assignmentMap.get( assignment.pse__Project__c ).get( assignment.pse__Resource__c );
            if( assignmentList == null){
                assignmentList = new List<pse__Assignment__c>();
                assignmentMap.get( assignment.pse__Project__c ).put( assignment.pse__Resource__c, assignmentList );
            }
            assignmentList.add(assignment);

        }
        return assignmentMap;
    }

    /**
     * Retrieves a map of countries for the specified reports
     */
    private static Map<Id,List<Report_Country__c>> buildCountriesMap(Set<Id> countryReportIds) {
        if(countryReportIds == null || countryReportIds.size() == 0){
            return new Map<Id,List<Report_Country__c>>();
        }
        return new SLT_Report_Country(false, false).getReportCountriesByReport(countryReportIds);
    }

    public static void validateDeletion(List<Aggregate_Report__c> deletedList){
        for(Aggregate_Report__c agReport : deletedList){
            if( String.isBlank( agReport.Delete_Reason__c ) ){
                agReport.addError('A delete reason must be entered before deleting an aggregate report.');
            }
        }
    }

    /**
     * Method to get label for an API field
     */
    private static String getLabel(String apiName){
        return fieldMap.get(apiName).getDescribe().getLabel();
    }

    /**
     * Method to validate the Drug associated with the Aggregate Report.
     */
     private static void validateProductDrug(Aggregate_Report__c aggReport,Map<Id,pse__Proj__c> projectsMap,Map<Id,Drug__c> drugMap) {
         if(aggReport != null && projectsMap != null && projectsMap.size() > 0 && drugMap != null && drugMap.size() > 0 
            && aggReport.Product_Name_Active_Ingredient__c != null && aggReport.Project__c != null
           	&& projectsMap.get(aggReport.Project__c).Service_Line__r.Name != null){
             if(projectsMap.containsKey(aggReport.Project__c) && drugMap.containsKey(aggReport.Product_Name_Active_Ingredient__c)
                && drugMap.get(aggReport.Product_Name_Active_Ingredient__c).Service_Lines__c != null && aggReport.Status__c != 'Cancelled' 
                
                && !drugMap.get(aggReport.Product_Name_Active_Ingredient__c).Service_Lines__c.contains(projectsMap.get(aggReport.Project__c).Service_Line__r.Name)) {
                    
                    aggReport.addError('The selected Drug is not associated with the related Project\'s Service Line. Please select another Drug.');
                }
         }   
     }

    /**
     * This method synchronizes fields on the project with the aggregate report
     */
    public static void synchronizeFields(List<Aggregate_Report__c> updatedList, Map<Id,Aggregate_Report__c> existingRecords){
        Set<String> projectFields = new Set<String>{'Service_Line_Lead__c'};
        Set<Id> projectIds = new Set<Id>();
        PSA_RDS_Settings__c rdsSettings= PSA_RDS_Settings__c.getInstance();

        //Gather report project Ids, and set the Sanofi project Ids if not set
        for ( Aggregate_Report__c agReport : updatedList ){
            String recordTypeName = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId).getDeveloperName();
            if(agReport.Project__c != null){
                projectIds.add( agReport.Project__c );
            }
            else if(recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_GSO ){
                projectIds.add( rdsSettings.Sanofi_GSO_Project__c );
                agReport.Project__c = rdsSettings.Sanofi_GSO_Project__c; 
            }
            else if(recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_PVS ){
                projectIds.add( rdsSettings.Sanofi_PVS_Project__c );
                agReport.Project__c = rdsSettings.Sanofi_PVS_Project__c;
            }

            if( Trigger.isInsert && (recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_GSO || recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_PVS )) {
                agReport.Prior_PV_Scientist__c = agReport.IQVIA_Primary_PV_Scientist__c;
            }
        }

        //Synchronize the PV Solutions Lead
        Map<Id,pse__Proj__c> PVAtoPVSMap = new SLT_Project(false, false).lookupPVSolutionsProjects(projectIds, projectFields);
        for ( Aggregate_Report__c agReport : updatedList ){
            if (agReport.Status__c != 'Completed' && PVAtoPVSMap.get(agReport.Project__c) != null && PVAtoPVSMap.get(agReport.Project__c).Service_Line_Lead__c != null) {
                agReport.PV_Solutions_Lead__c = PVAtoPVSMap.get(agReport.Project__c).Service_Line_Lead__c;
            }
        }
    }

    /**
     * This method creates or synchronizes a deliverable to a completed aggregate report
     */
    public static void synchronizeDeliverables(List<Aggregate_Report__c> updatedList, Map<Id,Aggregate_Report__c> existingRecords, Map<String, Set<String>> methodToRecordTypeMap){
        List<Aggregate_Report__c> reportsToSync = new List<Aggregate_Report__c>();

        //Filter ag reports to determine if we need to sync them
        for(Aggregate_Report__c agReport : updatedList){
            if( Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId) == null ||
            !methodToRecordTypeMap.get('synchronizeDeliverables').contains(Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId).getDeveloperName()) ) {
                continue;
            }

            //To sync when:
            //Completed and deliverable field not already set - we need to create one
            //Completed and deliverable already set when the existing record was also set - we are updating existing deliverable
            //To not sync when: 
            //X Not Copmleted
            //Completed and deliverable already set, but wasn't set on existing record - we must have just added it, so no need to sync

            if( agReport.Status__c != CON_PSA.AGG_REPORT_Status_Completed || agReport.Service_Milestone__c == null) { 
                continue;
            }

            if( agReport.Deliverable__c == null || 
                (existingRecords != null && existingRecords.get(agReport.Id).Deliverable__c == agReport.Deliverable__c) ){
                reportsToSync.add(agReport);
            }
            if(reportsToSync.size() > 0){
            System.enqueueJob(new QUE_PSA_SyncARDeliverables(reportsToSync));
        }
        }
    }

    /**
     * This method updates date offsets for dates the user may have set
     */
    public static void applyDateOffsets(List<SObject> records){
        SRV_PSA_Date_Offset.applyDateOffsets(records);
    }

    /**
     * This method synchronizes the Project Events for an Aggregate Report if a date on the report changes, provided it has a corresponding entry in the PSA Events table
     */
    public static void synchronizeProjectEvents(List<Aggregate_Report__c> updatedList, Map<Id,Aggregate_Report__c> existingRecords){

        List<Aggregate_Report__c> reportsToSync = new List<Aggregate_Report__c>();
        for(Aggregate_Report__c agReport : updatedList){
            if(agReport.Status__c != 'Completed'){
                reportsToSync.add(agReport);
            }
        }

        fetchPSAEvents();
        buildDateFieldMap();
        Id userId = UserInfo.getUserId();

        try {
            setEventDateFields();
        } catch (Exception e) {
            Aggregate_Report__c agReport = reportsToSync.get(0);
            agReport.addError( e.getMessage());
            return;
        }

        Set<String> aggregateReportFields = Schema.SObjectType.Aggregate_Report__c.fields.getMap().keySet();
        Map<Id,Map<Id,Project_Event__c>> reportToProjectEventMap = getProjectEventsByReport(reportsToSync);

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Project_Event__c.SObjectType }
        );


        for(Aggregate_Report__c agReport : reportsToSync){
            String recordTypeName = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId).getDeveloperName();
            for(String dateField : eventDateFields){
                Date dateFieldContents = (Date) agReport.get(dateField);
                PSA_Event__c psaEvent = ( dateFieldToPSAEventMap.get(dateField) != null) ? dateFieldToPSAEventMap.get(dateField).get(recordTypeName) : null;
                Project_Event__c projectEvent= ( reportToProjectEventMap.get(agReport.Id) != null && psaEvent != null) ? reportToProjectEventMap.get(agReport.Id).get(psaEvent.Id) : null;

                if( dateFieldContents != null && psaEvent != null ) {

                    try {
                        validatePSAEvent(psaEvent, aggregateReportFields);
                    } catch (AggregateReportFieldException e){
                        agReport.addError(e.getMessage());
                        continue;
                    }

                    if(projectEvent == null){
                        projectEvent = populateProjectEvent(agReport, psaEvent);
                        uow.registerNew(projectEvent);
                    } else {
                        //Note, this will register all existing Project Events as dirty vs checking every field-- a SOQL vs CPU tradeoff?
                        //TODO - Remove the SOQL query from populate project event and check events for needing update before updating
                        populateProjectEvent(agReport, psaEvent, projectEvent);
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
     * This methods is intended to be used to clear project events when an aggregate report is deleted
     */
    public static void deleteProjectEvents(List<Aggregate_Report__c> aggregateReportList){
        Set<Id> aggregateReportIds = new Set<Id>();
        for(Aggregate_Report__c agReport : aggregateReportList){
            aggregateReportIds.add(agReport.Id);
        }
        List<Project_Event__c> eventsToDelete = new SLT_Project_Event().getProjectEventsByReport(aggregateReportIds, new Set<String>{'Id'});
        delete eventsToDelete;
    }
   
    /**
    * This method will insert record in Audit Log on Inserting/Updating Aggregate Report
    **/
    public static void insertAuditLogOnUpdate(List<Aggregate_Report__c> updatedList,Map<Id,Aggregate_Report__c> existingRecords){
        SRV_PSA_AuditLog.setAuditOnInsertUpdate(updatedList,existingRecords);
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Aggregate Report
    **/
    public static void insertAuditLog(List<Aggregate_Report__c> insertList,String operation){
        SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(insertList,operation);
    } 


    /**
     * Retrieves all the PSA Events that could be applied to an Aggregate Report
     */
    private static void fetchPSAEvents(){
        if(psaEvents == null){
            psaEvents =  new SLT_PSA_Event().getAllPSAEvents('Aggregate_Report__c');
        }
    }

    /**
     * Compiles a list of the Due Date fields from a list of PSA events
     * These are the fields that we will be examining on Aggregate Reports for changes
     */
    private static void setEventDateFields(){
        Set<String> aggregateReportFields = Schema.SObjectType.Aggregate_Report__c.fields.getMap().keySet();
        Set<String> invalidFields = new Set<String>();
        fetchPSAEvents();

        if(eventDateFields == null){
            eventDateFields = new Set<String>();
        }
        for(PSA_Event__c event : psaEvents){
            if ( !aggregateReportFields.contains( event.Planned_Date_Field__c.toLowerCase() ) ) {
                invalidFields.add(event.Name+':'+event.Planned_Date_Field__c);
            } else {
                eventDateFields.add(event.Planned_Date_Field__c);
            }
        }

        if(invalidFields.size() > 0){
            throw new AggregateReportFieldException('Contact your PSA Admin. Found bad PSA Event Planned Date fields: '+String.join( new List<String>(invalidFields), ',' ) );
        }
    }

    /**
     * This method builds a map of Planned_Date_Field__c to RecordTypeName to PSA_Event__c
     * It allows you to filter PSA Events by both field and recordtype when trying to match up with Aggregate Reports
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
            List<String> recordTypes = event.RecordTypes__c.split(',');
            for(String recordType : recordTypes){
                recordTypeMap.put(recordType, event);
            }
        }
    }

    /**
     * This method retrieves all Project_Event__c objects for the Aggregate Reports, and maps them by Report Id followed by PSA Event Id
     * This allows us to validate them against both the Aggregate Report and the PSA Event, in case either has changed
     * @params List<Aggregate_Report__c> reports
     * @return Map<Id,Map<Id,Project_Event__c>>
     */
    private static Map<Id,Map<Id,Project_Event__c>> getProjectEventsByReport(List<Aggregate_Report__c> reports ){
        Set<Id> reportIds = new Set<Id>(new Map<Id,Aggregate_Report__c>(reports).keySet());
        Set<String> eventFields = new SLT_Project_Event().getDefaultFields();
        Map<Id,Map<Id,Project_Event__c>> projectEventsMap = new Map<Id,Map<Id,Project_Event__c>>();
        List<Project_Event__c> events = new SLT_Project_Event().getProjectEventsByReport(reportIds, eventFields);
        for(Project_Event__c event : events){
            if(projectEventsMap.get(event.Report__c) == null){
                projectEventsMap.put(event.Report__c, new Map<Id,Project_Event__c>());
            }
            projectEventsMap.get(event.Report__c).put(event.PSA_Event__c, event);
        }
        return projectEventsMap;
    }

    /**
     * Retrieve user Ids for stakeholders based on a list of fields to check
     * @return String
     */
    private static String getStakeholderIds(Aggregate_Report__c agReport, String fields){
        Set<Id> contactIds = new Set<Id>();
        for(String field : fields.split(',')){
            String fieldName = field.trim();
            if(agReport.get(fieldName) != null && agReport.get(fieldName) InstanceOf Id){
                contactIds.add((Id)agReport.get(fieldName));
            }
        }

        String ids = '';
        for( Contact stakeholder : new SLT_Contact().selectByContactIdList(contactIds, new Set<String>{'pse__Salesforce_User__c'}) ){
            if(ids != ''){
                ids += ',';
            }
            ids += String.valueOf(stakeholder.pse__Salesforce_User__c);
        }
        return ids;
    }

    /**
     * Populate fields on a project event given an aggregate report and a psa event
     * @params Aggregate_Report__c agReport
     * @params PSA_Event__c psaEvent
     * @params Project_Event__c projectEvent
     * 
     * @return Project_Event__c
     */
    private static Project_Event__c populateProjectEvent( Aggregate_Report__c agReport, PSA_Event__c psaEvent){
        return populateProjectEvent( agReport, psaEvent, new Project_Event__c());
    }

    private static Project_Event__c populateProjectEvent( Aggregate_Report__c agReport, PSA_Event__c psaEvent, Project_Event__c projectEvent) {

        if ( psaEvent.Actual_Date_Field__c != null && agReport.get(psaEvent.Actual_Date_Field__c) != null) {
            projectEvent.Event_Actual_Date__c = (Date)agReport.get(psaEvent.Actual_Date_Field__c);
        } else {
            projectEvent.Event_Actual_Date__c = null;
        }

        if ( psaEvent.Planned_Date_Field__c != null && agReport.get(psaEvent.Planned_Date_Field__c) != null) { 
                projectEvent.Event_Due_Date__c = (Date)agReport.get(psaEvent.Planned_Date_Field__c);
        } else {
            projectEvent.Event_Due_Date__c = null;
        }

        if ( psaEvent.Planned_Date_Field__c != null && agReport.get(psaEvent.Planned_Date_Field__c) != null && psaEvent.Notification_Offset__c != null) {
            projectEvent.Notification_Date__c = ((Date)agReport.get(psaEvent.Planned_Date_Field__c)).addDays(Integer.valueOf(psaEvent.Notification_Offset__c));
        } else {
            projectEvent.Notification_Date__c = null;
        }

        projectEvent.Primary_Resource__c = (psaEvent.Primary_Resource_Field__c != null) ? String.valueOf(agReport.get(psaEvent.Primary_Resource_Field__c)) : null;
        projectEvent.Secondary_Resource__c = (psaEvent.Secondary_Resource_Field__c != null) ? String.valueOf(agReport.get(psaEvent.Secondary_Resource_Field__c)) : null;
        projectEvent.Other_Resource__c = (psaEvent.Other_Resource_Field__c != null) ? String.valueOf(agReport.get(psaEvent.Other_Resource_Field__c)) : null;
        projectEvent.Stakeholder_ID__c = getStakeholderIds(agReport, psaEvent.Stakeholder_Fields__c);

        projectEvent.PSA_Event__c = psaEvent.Id;
        projectEvent.Report__c = agReport.Id;
        projectEvent.Project__c = (agReport.Project__c != null) ? String.valueOf(agReport.Project__c) : null;
        return projectEvent;
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

        for ( String stakeholder : psaEvent.Stakeholder_Fields__c.split(',')) {
            psaEventFieldValues.add( stakeholder.trim() );
        }

        for ( String fieldValue : psaEventFieldValues ) {
            if ( !validFields.contains( fieldValue.toLowerCase() ) ) {
                invalidFields.add( fieldValue );
            }
        }

        if(invalidFields.size() > 0){
            throw new AggregateReportFieldException('Contact your PSA Admin. Found invalid field data for PSA Event '+psaEvent.Name+': '+String.join( new List<String>(invalidFields), ',' ) );
        }
    }
    
    
    /**
     * This method is used to set MuleSoft Sync Process.
     * Set value of Mulesoft Sync Status field to Pending if update in field set (Mulesoft_Synced_Fields) fields.
     */
    public static void setMuleSoftSyncMechanism(List<Aggregate_Report__c> newList, Map<Id,Aggregate_Report__c> oldMap){
        List<Schema.FieldSetMember> aggFieldMemberList = Schema.SObjectType.Aggregate_Report__c.fieldSets.Mulesoft_Synced_Fields.getFields();
        for(Aggregate_Report__c newAgg : newList) {
            String fieldAPI = '';
            for(Schema.FieldSetMember sf : aggFieldMemberList) {
                fieldAPI = sf.getFieldPath();
                if(trigger.isInsert || (trigger.isUpdate && newAgg.get(fieldAPI) != oldMap.get(newAgg.Id).get(fieldAPI))) {
                    newAgg.Mulesoft_Sync_Status__c = 'Pending';
                    break;
                }
            }
        }
    } 
    
    /**
    * This method is used to set Product Name (Active Ingredient) on RA Response Report.
    * Set value of Product Name (Active Ingredient) field of RA Response Report from Product Name (Active Ingredient) field of Parent Takeda or General Report.
    */
    public static void setProductNameOnRAResponseReport(List<Aggregate_Report__c> newList,Map<Id,Aggregate_Report__c> oldMap){
        if(trigger.isInsert){
            set<id> parentAggReportIDSet = new set<id>();
            Map<id,Aggregate_Report__c> idFieldToAggReportMap= new Map<id,Aggregate_Report__c>();
            for(Aggregate_Report__c newAgg : newList){
                if(Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(newAgg.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE && newAgg.Primary_Report__c != null){
                    parentAggReportIDSet.add(newAgg.Primary_Report__c);
                }
            }
            if(parentAggReportIDSet.size()>0){
                for( Aggregate_Report__c aggRec : new SLT_Aggregate_Report(false,false).selectAggregateReportsById(parentAggReportIDSet, new Set<String>{'RecordTypeId','id','Product_Name_Active_Ingredient__c'}) ){
                    if(Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(aggRec.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA || 
                       Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(aggRec.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_GENERAL||
                      Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(aggRec.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE){
                           idFieldToAggReportMap.put(aggRec.id,aggRec);
                       }
                }
            }
            for(Aggregate_Report__c newAgg : newList){
                if(idFieldToAggReportMap.containsKey(newAgg.Primary_Report__c) && idFieldToAggReportMap.get(newAgg.Primary_Report__c) != null){
                    newAgg.Product_Name_Active_Ingredient__c =  idFieldToAggReportMap.get(newAgg.Primary_Report__c).Product_Name_Active_Ingredient__c;
                }
            }
        }
        if(trigger.isUpdate){
            if(trigger.isAfter){
                // to handle update on primary report's(parent report) product name
                set<id> AggReportIDSet = new set<id>();
                Map<id,List<Aggregate_Report__c>> idFieldToAggReportListMap= new Map<id,List<Aggregate_Report__c>>();
                List<Aggregate_Report__c> childAggReportList;
                List<Aggregate_Report__c> aggRecordList = new List<Aggregate_Report__c>();
                for(Aggregate_Report__c newAgg : newList) {
                    if(Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(newAgg.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA ||
                       Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(newAgg.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_GENERAL ||
                       Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(newAgg.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE &&
                       newAgg.Product_Name_Active_Ingredient__c != oldMap.get(newAgg.Id).Product_Name_Active_Ingredient__c){
                           AggReportIDSet.add(newAgg.id);
                       }
                }
                if(AggReportIDSet.size()>0){
                    for( Aggregate_Report__c aggRec : new SLT_Aggregate_Report(false,false).selectAggregateReportsById(AggReportIDSet, new Set<String>{'RecordTypeId','Primary_Report__c','Product_Name_Active_Ingredient__c'},'Primary_Report__c') ){
                        if(Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(aggRec.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE ){
                            if(idFieldToAggReportListMap.get(aggRec.Primary_Report__c) == null){
                                childAggReportList = new List<Aggregate_Report__c>();
                                childAggReportList.add(aggRec);
                                idFieldToAggReportListMap.put(aggRec.Primary_Report__c,childAggReportList);
                            }
                            else
                            {
                                List<Aggregate_Report__c> tempList = idFieldToAggReportListMap.get(aggRec.Primary_Report__c);
                                tempList.add(aggRec);
                                idFieldToAggReportListMap.put(aggRec.Primary_Report__c,tempList);
                            }
                        }
                    }
                }
                for(Aggregate_Report__c newAgg : newList){
                    if(Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(newAgg.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA ||
                       Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(newAgg.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_GENERAL ||
                       Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(newAgg.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE &&
                       newAgg.Product_Name_Active_Ingredient__c != oldMap.get(newAgg.Id).Product_Name_Active_Ingredient__c){
                           if(idFieldToAggReportListMap.containsKey(newAgg.id) &&  idFieldToAggReportListMap.get(newAgg.id) != null){
                               List<Aggregate_Report__c> aggReportList= idFieldToAggReportListMap.get(newAgg.id);
                               for(Aggregate_Report__c aggRec : aggReportList) {
                                   aggRec.Product_Name_Active_Ingredient__c =  newAgg.Product_Name_Active_Ingredient__c;
                               }
                               aggRecordList.addAll(aggReportList);
                           }
                       }
                }
                if(aggRecordList.size()>0){
                    for(Aggregate_Report__c agrec : aggRecordList){
                        childUpdatedAggRecordSet.add(agrec.id);    
                    }
                    update aggRecordList;
                }
            }
            if(trigger.isBefore){
                // to handle update of primary  report field in child record.
                set<id> parentAggReportIDSet = new set<id>();
                Map<id,Aggregate_Report__c> idFieldToAggReportMap= new Map<id,Aggregate_Report__c>();
                for(Aggregate_Report__c newAgg : newList){
                    if(Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(newAgg.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE && newAgg.Primary_Report__c != null && newAgg.Primary_Report__c != oldMap.get(newAgg.Id).Primary_Report__c){
                        parentAggReportIDSet.add(newAgg.Primary_Report__c);
                    }
                }
                if(parentAggReportIDSet.size()>0){
                    for( Aggregate_Report__c aggRec : new SLT_Aggregate_Report(false,false).selectAggregateReportsById(parentAggReportIDSet, new Set<String>{'RecordTypeId','id','Product_Name_Active_Ingredient__c'}) ){
                        if(Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(aggRec.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA || 
                           Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(aggRec.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_GENERAL ||
                          Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(aggRec.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE){
                               idFieldToAggReportMap.put(aggRec.id,aggRec);
                           }
                    }
                }
                for(Aggregate_Report__c newAgg : newList){ 
                    if(newAgg.Primary_Report__c != null && idFieldToAggReportMap.containsKey(newAgg.Primary_Report__c)){ //&& idFieldToAggReportMap.get(newAgg.Primary_Report__c) != null
                        newAgg.Product_Name_Active_Ingredient__c =  idFieldToAggReportMap.get(newAgg.Primary_Report__c).Product_Name_Active_Ingredient__c;
                    }
                }
            }
        }
    }
    
    
    /**
     * Exception class for DAOH_Aggregate_Report field validation
     */
    public class AggregateReportFieldException extends Exception {}

        private static Map<String, Map<String,String>> newFieldValidationMaps = new Map<String, Map<String,String>>{
        'Default' => new Map<String,String>(),
        //Sanofi GSO
        (CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_GSO + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_SANOFI_GSO) => new Map<String,String>{
            'Reporting_Period_Start__c' => 'Reporting_Period_Start_NA__c',
            'DLP_Reporting_Period_End__c' => 'DLP_Reporting_Period_End_NA__c',
            'Planned_date_for_First_GSO_Review__c' => 'Planned_date_for_First_GSO_Review_NA__c',
            'Actual_Date_Sent_to_GSO__c' => 'Actual_Date_Sent_to_GSO_NA__c',
            'Actual_Date_for_Final_GSO_Review__c' => 'Actual_Date_for_Final_GSO_Review_NA__c',
            'Planned_Date_for_Final_GSO_Review__c' => 'Planned_date_for_Final_GSO_Review_NA__c',
            'Planned_date_for_First_GSO_Review__c' => 'Planned_date_for_First_GSO_Review_NA__c',
            'Planned_Date_of_IQVIA_TAH_Support__c' => 'Planned_Date_of_IQVIA_TAH_Support_NA__c',
            'Actual_Date_Sent_to_IQVIA_TAH__c' => 'Actual_Date_Sent_to_IQVIA_TAH_NA__c',
            'Planned_IQVIA_TAH_Support_End_Date__c' => 'Planned_IQVIA_TAH_Support_End_Date_NA__c',
            'Final_IQVIA_TAH_Review_Date__c' => 'Final_IQVIA_TAH_Review_Date_NA__c',
            'Client_First_Draft_Due__c' => 'Client_First_Draft_Due_NA__c',
            'Client_First_Draft_Sent__c' => 'Client_First_Draft_Sent_NA__c',
            'GSO_Completion_Date__c' => 'GSO_Completion_Date_NA__c',
            'Report_Due_to_Reg_Agency__c' => 'Report_Due_to_Reg_Agency_NA__c'
        },
        //Sanofi PVS
        (CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_PVS + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_SANOFI_PVS) => new Map<String,String>{
            'Reporting_Period_Start__c' => 'Reporting_Period_Start_NA__c',
            'DLP_Reporting_Period_End__c' => 'DLP_Reporting_Period_End_NA__c',
            'Planned_date_for_First_GSO_Review__c' => 'Planned_date_for_First_GSO_Review_NA__c',
            'Actual_Date_Sent_to_GSO__c' => 'Actual_Date_Sent_to_GSO_NA__c',
            'Planned_Date_for_Final_GSO_Review__c' => 'Planned_date_for_Final_GSO_Review_NA__c',
            'Actual_Date_for_Final_GSO_Review__c' => 'Actual_Date_for_Final_GSO_Review_NA__c',
            'Planned_Date_of_IQVIA_TAH_Support__c' => 'Planned_Date_of_IQVIA_TAH_Support_NA__c',
            'Actual_Date_Sent_to_IQVIA_TAH__c' => 'Actual_Date_Sent_to_IQVIA_TAH_NA__c',
            'Planned_IQVIA_TAH_Support_End_Date__c' => 'Planned_IQVIA_TAH_Support_End_Date_NA__c',
            'Final_IQVIA_TAH_Review_Date__c' => 'Final_IQVIA_TAH_Review_Date_NA__c',
            'Client_First_Draft_Due__c' => 'Client_First_Draft_Due_NA__c',
            'Client_First_Draft_Sent__c' => 'Client_First_Draft_Sent_NA__c',
            'GSO_Completion_Date__c' => 'GSO_Completion_Date_NA__c',
            'Report_Due_to_Reg_Agency__c' => 'Report_Due_to_Reg_Agency_NA__c'
        },
        //Report writing section
        (CON_PSA.AGG_REPORT_REC_TYPE_GENERAL + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_REPORT_WRITING) => new Map<String,String>{
                'Primary_Author__c' => 'Report_Writing__c'
        },
        (CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_REPORT_WRITING) => new Map<String,String>{
                'Primary_Author__c' => 'Report_Writing__c'
        },
        (CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_REPORT_WRITING) => new Map<String,String>{
                'Primary_Author__c' => 'Report_Writing__c'
        },
        //Litr. POC section
        (CON_PSA.AGG_REPORT_REC_TYPE_GENERAL + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_LITR_REVIEW) => new Map<String,String>{
                'Primary_Reviewer__c' => 'Literature_Review_Requirement__c'
        },
        (CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_LITR_REVIEW) => new Map<String,String>{
                'Primary_Reviewer__c' => 'Literature_Review_Requirement__c'
        },
        (CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_LITR_REVIEW) => new Map<String,String>{
                'Primary_Reviewer__c' => 'Literature_Review_Requirement__c'
        },
        //Meeting section
        (CON_PSA.AGG_REPORT_REC_TYPE_GENERAL + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_MEETINGS) => new Map<String,String>{
            'PreStrategy_Actual_Date__c' => 'PreStrategy_Actual_Date_NA__c',
            'PreStrategy_Planned_Date__c' => 'PreStrategy_Planned_Date_NA__c',
			'Strategy_Planning_Mtg_Actual_Date__c' => 'Strategy_Planning_Mtg_Actual_Date_NA__c',
            'Strategy_Planning_Mtg_Planned_Date__c' => 'Strategy_Planning_Mtg_Planned_Date_NA__c',
			'First_RTR_Actual_Date__c' => 'First_RTR_Actual_Date_NA__c',
            'First_RTR_Planned_Date__c' => 'First_RTR_Planned_Date_NA__c',
			'Second_RTR_Actual_Date__c' => 'Second_RTR_Actual_Date_NA__c',
            'Second_RTR_Planned_Date__c' => 'Second_RTR_Planned_Date_NA__c',
            'Planned_date_Strategy_meeting_agenda__c'=>'Planned_date_Strategy_meeting_agenda_NA__c',
            'Strategy_meeting_agenda_sent__c'=>'Strategy_meeting_agenda_sent_NA__c'
        },
        (CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_MEETINGS) => new Map<String,String>{
            'PreStrategy_Actual_Date__c' => 'PreStrategy_Actual_Date_NA__c',
            'PreStrategy_Planned_Date__c' => 'PreStrategy_Planned_Date_NA__c',
			'Strategy_Planning_Mtg_Actual_Date__c' => 'Strategy_Planning_Mtg_Actual_Date_NA__c',
            'Strategy_Planning_Mtg_Planned_Date__c' => 'Strategy_Planning_Mtg_Planned_Date_NA__c',
			'First_RTR_Actual_Date__c' => 'First_RTR_Actual_Date_NA__c',
            'First_RTR_Planned_Date__c' => 'First_RTR_Planned_Date_NA__c',
			'Second_RTR_Actual_Date__c' => 'Second_RTR_Actual_Date_NA__c',
            'Second_RTR_Planned_Date__c' => 'Second_RTR_Planned_Date_NA__c'
        },
        (CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_MEETINGS) => new Map<String,String>{
            'PreStrategy_Actual_Date__c' => 'PreStrategy_Actual_Date_NA__c',
            'PreStrategy_Planned_Date__c' => 'PreStrategy_Planned_Date_NA__c',
			'Strategy_Planning_Mtg_Actual_Date__c' => 'Strategy_Planning_Mtg_Actual_Date_NA__c',
            'Strategy_Planning_Mtg_Planned_Date__c' => 'Strategy_Planning_Mtg_Planned_Date_NA__c',
			'First_RTR_Actual_Date__c' => 'First_RTR_Actual_Date_NA__c',
            'First_RTR_Planned_Date__c' => 'First_RTR_Planned_Date_NA__c',
	        'Second_RTR_Actual_Date__c' => 'Second_RTR_Actual_Date_NA__c',
            'Second_RTR_Planned_Date__c' => 'Second_RTR_Planned_Date_NA__c',
            'Planned_date_Strategy_meeting_agenda__c'=>'Planned_date_Strategy_meeting_agenda_NA__c',
            'Strategy_meeting_agenda_sent__c'=>'Strategy_meeting_agenda_sent_NA__c',
            'RFI_mails_Planned_date__c'=>'RFI_mails_Planned_date_NA__c',
            'RFI_mails_Sent__c'=>'RFI_mails_Sent_NA__c',
            'RFI_response_Pre_KOM_Planned_date__c'=>'RFI_response_Pre_KOM_Planned_date_NA__c',
            'RFI_response_Pre_KOM_Received_date__c'=>'RFI_response_Pre_KOM_Received_date_NA__c',
            'RFI_response_KOM_Planned_date__c'=>'RFI_response_KOM_Planned_date_NA__c',
            'RFI_response_KOM_Received_date__c'=>'RFI_response_KOM_Received_date_NA__c',
            'RFI_response_Post_DLP_Planned_date__c'=>'RFI_response_Post_DLP_Planned_date_NA__c',
            'RFI_response_Post_DLP_Received_date__c'=>'RFI_response_Post_DLP_Received_date_NA__c'
        },   
         
        //QC
        (CON_PSA.AGG_REPORT_REC_TYPE_GENERAL + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_QC) => new Map<String,String>{
            'Planned_Date_for_QC_Completion__c' => 'Planned_Date_for_QC_Completion_NA__c',
            'Planned_Date_for_QC_Sent__c' => 'Planned_Date_for_QC_Sent_NA__c',
			'Actual_Date_for_QC_Completion__c' => 'Actual_Date_for_QC_Completion_NA__c',
            'Actual_Date_for_QC_Sent__c' => 'Actual_Date_for_QC_Sent_NA__c'
        },
        (CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_QC) => new Map<String,String>{
            'Planned_Date_for_QC_Completion__c' => 'Planned_Date_for_QC_Completion_NA__c',
            'Planned_Date_for_QC_Sent__c' => 'Planned_Date_for_QC_Sent_NA__c',
			'Actual_Date_for_QC_Completion__c' => 'Actual_Date_for_QC_Completion_NA__c',
            'Actual_Date_for_QC_Sent__c' => 'Actual_Date_for_QC_Sent_NA__c'
        },
        (CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_QC) => new Map<String,String>{
            'Planned_Date_for_QC_Completion__c' => 'Planned_Date_for_QC_Completion_NA__c',
            'Planned_Date_for_QC_Sent__c' => 'Planned_Date_for_QC_Sent_NA__c',
			'Actual_Date_for_QC_Completion__c' => 'Actual_Date_for_QC_Completion_NA__c',
            'Actual_Date_for_QC_Sent__c' => 'Actual_Date_for_QC_Sent_NA__c'
        },
            
        //BRM
        (CON_PSA.AGG_REPORT_REC_TYPE_GENERAL + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_BRM) => new Map<String,String>{
            'Planned_Date_for_BRM_Completion__c' => 'Planned_Date_for_BRM_Completion_NA__c',
            'Planned_Date_for_BRM_Sent__c' => 'Planned_Date_for_BRM_Sent_NA__c',
			'Actual_Date_for_BRM_Completion__c' => 'Actual_Date_for_BRM_Completion_NA__c',
            'Actual_Date_for_BRM_Sent__c' => 'Actual_Date_for_BRM_Sent_NA__c'
        },
        (CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_BRM) => new Map<String,String>{
            'Planned_Date_for_BRM_Completion__c' => 'Planned_Date_for_BRM_Completion_NA__c',
            'Planned_Date_for_BRM_Sent__c' => 'Planned_Date_for_BRM_Sent_NA__c',
			'Actual_Date_for_BRM_Completion__c' => 'Actual_Date_for_BRM_Completion_NA__c',
            'Actual_Date_for_BRM_Sent__c' => 'Actual_Date_for_BRM_Sent_NA__c'
        },
        (CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_BRM) => new Map<String,String>{
            'Planned_Date_for_BRM_Completion__c' => 'Planned_Date_for_BRM_Completion_NA__c',
            'Planned_Date_for_BRM_Sent__c' => 'Planned_Date_for_BRM_Sent_NA__c',
			'Actual_Date_for_BRM_Completion__c' => 'Actual_Date_for_BRM_Completion_NA__c',
            'Actual_Date_for_BRM_Sent__c' => 'Actual_Date_for_BRM_Sent_NA__c'
        },
            
        //Medical Review
        (CON_PSA.AGG_REPORT_REC_TYPE_GENERAL + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_MED_REVIEW) => new Map<String,String>{
            'Actual_Date_for_Medical_Review_Cmpltn__c' => 'Actual_Date_for_Medical_Review_Cmpltn_NA__c',
            'Actual_Date_for_Medical_Review_Sent__c' => 'Actual_Date_for_Medical_Review_Sent_NA__c',
			'Planned_Date_for_Medical_Review_Sent__c' => 'Planned_Date_for_Medical_Review_Sent_NA__c',
			'Plnnd_Date_for_Medical_Review_Cmpltn__c' => 'Plnnd_Date_for_Medical_Review_Cmpltn_NA__c'
        },
        (CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_MED_REVIEW) => new Map<String,String>{
            'Actual_Date_for_Medical_Review_Cmpltn__c' => 'Actual_Date_for_Medical_Review_Cmpltn_NA__c',
            'Actual_Date_for_Medical_Review_Sent__c' => 'Actual_Date_for_Medical_Review_Sent_NA__c',
			'Planned_Date_for_Medical_Review_Sent__c' => 'Planned_Date_for_Medical_Review_Sent_NA__c',
			'Plnnd_Date_for_Medical_Review_Cmpltn__c' => 'Plnnd_Date_for_Medical_Review_Cmpltn_NA__c'
        },
        (CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_MED_REVIEW) => new Map<String,String>{
            'Actual_Date_for_Medical_Review_Cmpltn__c' => 'Actual_Date_for_Medical_Review_Cmpltn_NA__c',
            'Actual_Date_for_Medical_Review_Sent__c' => 'Actual_Date_for_Medical_Review_Sent_NA__c',
	    	'Planned_Date_for_Medical_Review_Sent__c' => 'Planned_Date_for_Medical_Review_Sent_NA__c',
	    	'Plnnd_Date_for_Medical_Review_Cmpltn__c' => 'Plnnd_Date_for_Medical_Review_Cmpltn_NA__c'
        },
         
        //Client and regulatory timelines
        (CON_PSA.AGG_REPORT_REC_TYPE_GENERAL + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_CLIENT_REG) => new Map<String,String>{
            'Client_First_Draft_Due__c' => 'Client_First_Draft_Due_NA__c',
            'Client_First_Draft_Sent__c' => 'Client_First_Draft_Sent_NA__c',
	    'Planned_Final_Draft_Comments_Due__c' => 'Planned_Final_Draft_Comments_Due_NA__c',
            'Planned_First_Draft_Comments_Due__c' => 'Planned_First_Draft_Comments_Due_NA__c',
	    'Actual_Final_Draft_Comments_Due__c' => 'Actual_Final_Draft_Comments_Due_NA__c',
            'Actual_First_Draft_Comments_Due__c' => 'Actual_First_Draft_Comments_Due_NA__c',
			'Client_Final_Draft_Due__c' => 'Client_Final_Draft_Due_NA__c',
            'Client_Final_Draft_Sent__c' => 'Client_Final_Draft_Sent_NA__c',
            'Planned_Date_to_obtain_sign_Approval__c'=>'Planned_Date_to_obtain_sign_Approval_NA__c',
            'Date_signatures_obtained__c'=>'Date_signatures_obtained_NA__c'    
        },
        (CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_CLIENT_REG) => new Map<String,String>{
            'Client_First_Draft_Due__c' => 'Client_First_Draft_Due_NA__c',
            'Client_First_Draft_Sent__c' => 'Client_First_Draft_Sent_NA__c',
			'Planned_Final_Draft_Comments_Due__c' => 'Planned_Final_Draft_Comments_Due_NA__c',
            'Planned_First_Draft_Comments_Due__c' => 'Planned_First_Draft_Comments_Due_NA__c',
			'Actual_Final_Draft_Comments_Due__c' => 'Actual_Final_Draft_Comments_Due_NA__c',
            'Actual_First_Draft_Comments_Due__c' => 'Actual_First_Draft_Comments_Due_NA__c',
			'Client_Final_Draft_Due__c' => 'Client_Final_Draft_Due_NA__c',
            'Client_Final_Draft_Sent__c' => 'Client_Final_Draft_Sent_NA__c'
        },
        (CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_CLIENT_REG) => new Map<String,String>{
            'Client_First_Draft_Due__c' => 'Client_First_Draft_Due_NA__c',
            'Client_First_Draft_Sent__c' => 'Client_First_Draft_Sent_NA__c',
			'Planned_Final_Draft_Comments_Due__c' => 'Planned_Final_Draft_Comments_Due_NA__c',
            'Planned_First_Draft_Comments_Due__c' => 'Planned_First_Draft_Comments_Due_NA__c',
			'Actual_Final_Draft_Comments_Due__c' => 'Actual_Final_Draft_Comments_Due_NA__c',
            'Actual_First_Draft_Comments_Due__c' => 'Actual_First_Draft_Comments_Due_NA__c',
			'Client_Final_Draft_Due__c' => 'Client_Final_Draft_Due_NA__c',
            'Client_Final_Draft_Sent__c' => 'Client_Final_Draft_Sent_NA__c',
            'Planned_Date_to_obtain_sign_Approval__c'=>'Planned_Date_to_obtain_sign_Approval_NA__c',
            'Date_signatures_obtained__c'=>'Date_signatures_obtained_NA__c' 
        },
            
        //Line Listing (For general and takeda)
        (CON_PSA.AGG_REPORT_REC_TYPE_GENERAL + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_LL) => new Map<String,String>{
            'LL_QC_Completion_Date__c' => 'LL_QC_Completion_Date_NA__c',
            'LL_QC_Due_Date__c' => 'LL_QC_Due_Date_NA__c',
            'LL_Review_Completion_Date__c' => 'LL_Review_Completion_Date_NA__c',
            'LL_Review_Due__c' => 'LL_Review_Due_Date_NA__c',
            'Planned_Date_to_Request_Final_LL__c' => 'Planned_Date_to_Request_Final_LL_NA__c',
            'Planned_Date_to_Request_Draft_LL__c' => 'Planned_Date_to_Request_Draft_LL_NA__c',
            'Plnnd_Date_Final_LL_to_Author_Client__c' => 'Plnnd_Date_Final_LL_to_Author_ClientNA__c',
            'Plnnd_Date_Draft_LL_to_Author_Client__c' => 'Plnnd_Dt_Draft_LL_to_Author_Client_NA__c',
            'Actual_Date_Final_LL_Requested__c' => 'Actual_Date_Final_LL_Requested_NA__c',
            'Actual_Date_Final_LL_to_Author_Client__c' => 'Actual_Date_Final_LL_to_Author_Client_N__c',
            'Actual_Date_Draft_LL_to_Author_Client__c' => 'Actual_Dt_Draft_LL_to_Author_ClientNA__c',
            'Actual_Date_to_Request_Draft_LL__c' => 'Actual_Date_to_Request_Draft_LL_NA__c',
            'Draft_LL_Request_Ticket_Number__c' => 'Draft_LL_Request_Ticket_Number_NA__c',
            'Final_Listings_Ticket_Number__c' => 'Final_Listings_Ticket_Number_NA__c'
        },
        (CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_LL) => new Map<String,String>{
            'LL_QC_Completion_Date__c' => 'LL_QC_Completion_Date_NA__c',
            'LL_QC_Due_Date__c' => 'LL_QC_Due_Date_NA__c',
            'LL_Review_Completion_Date__c' => 'LL_Review_Completion_Date_NA__c',
            'LL_Review_Due__c' => 'LL_Review_Due_Date_NA__c',
            'Planned_Date_to_Request_Final_LL__c' => 'Planned_Date_to_Request_Final_LL_NA__c',
            'Planned_Date_to_Request_Draft_LL__c' => 'Planned_Date_to_Request_Draft_LL_NA__c',
            'Plnnd_Date_Final_LL_to_Author_Client__c' => 'Plnnd_Date_Final_LL_to_Author_ClientNA__c',
            'Plnnd_Date_Draft_LL_to_Author_Client__c' => 'Plnnd_Dt_Draft_LL_to_Author_Client_NA__c',
            'Actual_Date_Final_LL_Requested__c' => 'Actual_Date_Final_LL_Requested_NA__c',
            'Actual_Date_Final_LL_to_Author_Client__c' => 'Actual_Date_Final_LL_to_Author_Client_N__c',
            'Actual_Date_Draft_LL_to_Author_Client__c' => 'Actual_Dt_Draft_LL_to_Author_ClientNA__c',
            'Actual_Date_to_Request_Draft_LL__c' => 'Actual_Date_to_Request_Draft_LL_NA__c',
            'Draft_LL_Request_Ticket_Number__c' => 'Draft_LL_Request_Ticket_Number_NA__c', 
            'Final_Listings_Ticket_Number__c' => 'Final_Listings_Ticket_Number_NA__c'
        },
            
        //General
        (CON_PSA.AGG_REPORT_REC_TYPE_GENERAL + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_GENERAL) => new Map<String,String>{
            'Starting_Date__c' => 'Starting_Date_NA__c',
			'Data_Lock_Point__c' => 'Data_Lock_Point_NA__c',
            'Date_Locked__c' => 'Date_Locked_NA__c',
			'Reporting_Period_End__c' => 'Reporting_Period_End_NA__c',
            'Reporting_Period_Start__c' => 'Reporting_Period_Start_NA__c',
            'Planned_starting_date__c' => 'Planned_starting_date_NA__c'
        },
        (CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_GENERAL) => new Map<String,String>{
            'Starting_Date__c' => 'Starting_Date_NA__c',
			'Data_Lock_Point__c' => 'Data_Lock_Point_NA__c',
            'Date_Locked__c' => 'Date_Locked_NA__c',
			'Reporting_Period_End__c' => 'Reporting_Period_End_NA__c',
            'Reporting_Period_Start__c' => 'Reporting_Period_Start_NA__c'
        },
        (CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_GENERAL) => new Map<String,String>{
            'Starting_Date__c' => 'Starting_Date_NA__c',
			'Data_Lock_Point__c' => 'Data_Lock_Point_NA__c',
            'Date_Locked__c' => 'Date_Locked_NA__c',
			'Reporting_Period_End__c' => 'Reporting_Period_End_NA__c',
            'Reporting_Period_Start__c' => 'Reporting_Period_Start_NA__c',
            'Planned_starting_date__c' => 'Planned_starting_date_NA__c'
        },
            
        //Takeda section in Takeda report
        (CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_REPORT_TAKEDA) => new Map<String,String>{
            //'Final_Report_delivery_to_Takeda_PSS_sent__c' => 'Fnl_Rprt_delivery_to_Takeda_PSS_sent_NA__c',
            'Final_verification_copy_to_Takeda_due__c' => 'Final_verification_copy_to_Takeda_due_NA__c',
            'Final_verified_copy_received_by_IQVIA__c' => 'Final_verified_copy_received_by_IQVIA_NA__c',
            //'Date_esignatures_obtained__c' => 'Date_esignatures_obtained_NA__c',
            'Date_final_report_published__c' => 'Date_final_report_published_NA__c',
            'Date_for_fnl_rprt_pblshng_in_EDMS_due__c' => 'Date_for_fnl_rprt_pblshng_in_EDMS_due_NA__c',
            //'Date_for_IQVIA_to_obtain_esignatures__c' => 'Date_for_IQVIA_to_obtain_esignatures_NA__c',
            //'Fnl_Rprt_delivery_to_Takeda_PSS_due__c' => 'Fnl_Rprt_delivery_to_Takeda_PSS_due_NA__c',
			'Read_receipt_filed_on_ECM__c' => 'Read_receipt_filed_on_ECM_NA__c',
            'Read_receipt_received_from_PSS__c' => 'Read_receipt_received_from_PSS_NA__c'
        }
    };
        
    private static Map<String, Map<String,String>> actualDatesMaps = new Map<String, Map<String,String>>{
        'Default' => new Map<String,String>(),
        CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_GSO => new Map<String,String>{
            'Client_Final_Sent__c' => 'Client_Final_Due__c'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_PVS => new Map<String,String>{
            'Client_Final_Sent__c' => 'Client_Final_Due__c'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_GENERAL => new Map<String,String>{
            'Actual_Date_for_BRM_Completion__c' => 'Planned_Date_for_BRM_Completion__c',
            'Actual_Date_for_BRM_Sent__c' => 'Planned_Date_for_BRM_Sent__c',
            'Actual_Date_for_Medical_Review_Sent__c' => 'Planned_Date_for_Medical_Review_Sent__c',
            'Actual_Date_for_Medical_Review_Cmpltn__c' => 'Plnnd_Date_for_Medical_Review_Cmpltn__c',
            'Actual_Date_for_QC_Completion__c' => 'Planned_Date_for_QC_Completion__c',
            'Actual_Date_for_QC_Sent__c' => 'Planned_Date_for_QC_Sent__c',
            'Actual_Final_Draft_Comments_Due__c' => 'Planned_Final_Draft_Comments_Due__c',
            'Actual_First_Draft_Comments_Due__c' => 'Planned_First_Draft_Comments_Due__c',
            'Date_Submitted_to_IQVIA_or_Client_Reg__c' => 'Report_Due_to_IQVIA_or_Client_Reg__c',
            'PreStrategy_Actual_Date__c' => 'PreStrategy_Planned_Date__c',
            'Client_Final_Draft_Sent__c' => 'Client_Final_Draft_Due__c',
            'Client_First_Draft_Sent__c' => 'Client_First_Draft_Due__c',
            'First_RTR_Actual_Date__c' => 'First_RTR_Planned_Date__c',
            'LL_QC_Due_Date__c' => 'LL_QC_Completion_Date__c',
            'LL_Review_Due__c' => 'LL_Review_Completion_Date__c',
            'Second_RTR_Actual_Date__c' => 'Second_RTR_Planned_Date__c',
            'Strategy_Planning_Mtg_Actual_Date__c' => 'Strategy_Planning_Mtg_Planned_Date__c'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_SANDOZ => new Map<String,String>{
            'Actual_Date_for_BRM_Completion__c' => 'Planned_Date_for_BRM_Completion__c',
            'Actual_Date_for_BRM_Sent__c' => 'Planned_Date_for_BRM_Sent__c',
            'Actual_Date_for_Medical_Review_Sent__c' => 'Planned_Date_for_Medical_Review_Sent__c',
            'Actual_Date_for_Medical_Review_Cmpltn__c' => 'Plnnd_Date_for_Medical_Review_Cmpltn__c',
            'Actual_Date_for_QC_Completion__c' => 'Planned_Date_for_QC_Completion__c',
            'Actual_Date_for_QC_Sent__c' => 'Planned_Date_for_QC_Sent__c',
            'Actual_Final_Draft_Comments_Due__c' => 'Planned_Final_Draft_Comments_Due__c',
            'Actual_First_Draft_Comments_Due__c' => 'Planned_First_Draft_Comments_Due__c',
            'Date_Submitted_to_IQVIA_or_Client_Reg__c' => 'Report_Due_to_IQVIA_or_Client_Reg__c',
            'PreStrategy_Actual_Date__c' => 'PreStrategy_Planned_Date__c',
            'Client_Final_Draft_Sent__c' => 'Client_Final_Draft_Due__c',
            'Client_First_Draft_Sent__c' => 'Client_First_Draft_Due__c',
            'First_RTR_Actual_Date__c' => 'First_RTR_Planned_Date__c',
            'LL_QC_Due_Date__c' => 'LL_QC_Completion_Date__c',
            'LL_Review_Due__c' => 'LL_Review_Completion_Date__c',
            'Second_RTR_Actual_Date__c' => 'Second_RTR_Planned_Date__c',
            'Strategy_Planning_Mtg_Actual_Date__c' => 'Strategy_Planning_Mtg_Planned_Date__c'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA => new Map<String,String>{
            'Actual_Date_for_BRM_Completion__c' => 'Planned_Date_for_BRM_Completion__c',
            'Actual_Date_for_BRM_Sent__c' => 'Planned_Date_for_BRM_Sent__c',
            'Actual_Date_for_Medical_Review_Cmpltn__c' => 'Plnnd_Date_for_Medical_Review_Cmpltn__c',
            'Actual_Date_for_Medical_Review_Sent__c' => 'Planned_Date_for_Medical_Review_Sent__c',
            'Actual_Date_for_QC_Completion__c' => 'Planned_Date_for_QC_Completion__c',
            'Actual_Date_for_QC_Sent__c' => 'Planned_Date_for_QC_Sent__c',
            'Actual_Final_Draft_Comments_Due__c' => 'Planned_Final_Draft_Comments_Due__c',
            'Actual_First_Draft_Comments_Due__c' => 'Planned_First_Draft_Comments_Due__c',
            'Client_Final_Draft_Sent__c' => 'Client_Final_Draft_Due__c',
            'Client_First_Draft_Sent__c' => 'Client_First_Draft_Due__c',
            'Date_final_report_published__c' => 'Date_for_fnl_rprt_pblshng_in_EDMS_due__c',
            'Date_Submitted_to_IQVIA_or_Client_Reg__c' => 'Report_Due_to_IQVIA_or_Client_Reg__c',
            //'Fnl_Rprt_delivery_to_Takeda_PSS_due__c' => 'Final_Report_delivery_to_Takeda_PSS_sent__c',
            'First_RTR_Actual_Date__c' => 'First_RTR_Planned_Date__c',
            'LL_QC_Completion_Date__c' => 'LL_QC_Due_Date__c',
            'LL_Review_Completion_Date__c' => 'LL_Review_Due__c',
            'PreStrategy_Actual_Date__c' => 'PreStrategy_Planned_Date__c',
            'Second_RTR_Actual_Date__c' => 'Second_RTR_Planned_Date__c',
            'Strategy_Planning_Mtg_Actual_Date__c' => 'Strategy_Planning_Mtg_Planned_Date__c'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE => new Map<String,String>{
            'Actual_Date_for_BRM_Completion__c' => 'Planned_Date_for_BRM_Completion__c',
            'Actual_Date_for_BRM_Sent__c' => 'Planned_Date_for_BRM_Sent__c',
            'Actual_Date_for_Medical_Review_Sent__c' => 'Planned_Date_for_Medical_Review_Sent__c',
            'Actual_Date_for_Medical_Review_Cmpltn__c' => 'Plnnd_Date_for_Medical_Review_Cmpltn__c',
            'Actual_Date_for_QC_Completion__c' => 'Planned_Date_for_QC_Completion__c',
            'Actual_Date_for_QC_Sent__c' => 'Planned_Date_for_QC_Sent__c',
            'Actual_Final_Draft_Comments_Due__c' => 'Planned_Final_Draft_Comments_Due__c',
            'Actual_First_Draft_Comments_Due__c' => 'Planned_First_Draft_Comments_Due__c',
            'Date_Submitted_to_IQVIA_or_Client_Reg__c' => 'Report_Due_to_IQVIA_or_Client_Reg__c',
            'PreStrategy_Actual_Date__c' => 'PreStrategy_Planned_Date__c',
            'Client_Final_Draft_Sent__c' => 'Client_Final_Draft_Due__c',
            'Client_First_Draft_Sent__c' => 'Client_First_Draft_Due__c',
            'First_RTR_Actual_Date__c' => 'First_RTR_Planned_Date__c',
            'LL_QC_Due_Date__c' => 'LL_QC_Completion_Date__c',
            'LL_Review_Due__c' => 'LL_Review_Completion_Date__c',
            'Second_RTR_Actual_Date__c' => 'Second_RTR_Planned_Date__c',
            'Strategy_Planning_Mtg_Actual_Date__c' => 'Strategy_Planning_Mtg_Planned_Date__c'
        }
    };

    private static Map<String, Map<String,String>> dateFieldtoNAFieldMaps = new Map<String, Map<String,String>>{
        'Default' => new Map<String,String>(),
        //Sandoz record type (QC Section)
        (CON_PSA.AGG_REPORT_REC_TYPE_SANDOZ + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_QC) => new Map<String,String>{
            'Actual_Date_for_QC_Completion__c' => 'Actual_Date_for_QC_Completion_NA__c',
            'Planned_Date_for_QC_Completion__c' => 'Planned_Date_for_QC_Completion_NA__c',
            'Actual_Date_for_QC_Sent__c' => 'Actual_Date_for_QC_Sent_NA__c',
            'Planned_Date_for_QC_Sent__c' => 'Planned_Date_for_QC_Sent_NA__c'
        }, 
        //Sandoz record type (Meetings Section)
        (CON_PSA.AGG_REPORT_REC_TYPE_SANDOZ + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_MEETINGS) => new Map<String,String>{
            'Second_RTR_Planned_Date__c' => 'Second_RTR_Planned_Date_NA__c',
            'Second_RTR_Actual_Date__c' => 'Second_RTR_Actual_Date_NA__c',
            'First_RTR_Planned_Date__c' => 'First_RTR_Planned_Date_NA__c',
            'First_RTR_Actual_Date__c' => 'First_RTR_Actual_Date_NA__c',
            'Strategy_Planning_Mtg_Actual_Date__c' => 'Strategy_Planning_Mtg_Actual_Date_NA__c',
            'Strat_Planning_Mtg_minute_sent_date__c' => 'Strat_Planning_Mtg_minute_sent_date_NA__c',
            'Planned_date_Strat_Planning_Mtg_minute__c' => 'Planned_date_Strat_Planning_Mtg_minuteNA__c',
            'Strategy_Planning_Mtg_Planned_Date__c' => 'Strategy_Planning_Mtg_Planned_Date_NA__c',
            'Pre_strat_minutes_sent_actual_date__c' => 'Pre_strat_minutes_sent_actual_date_NA__c',
            'Planned_date_to_send_Prestrat_minutes__c' => 'Planned_date_to_send_Prestrat_minutesNA__c',
            'PreStrategy_Actual_Date__c' => 'PreStrategy_Actual_Date_NA__c',
            'PreStrategy_Planned_Date__c' => 'PreStrategy_Planned_Date_NA__c',
            'CFI_prestrat_Mtg_agenda_date_sent__c' => 'CFI_prestrat_Mtg_agenda_date_sentNA__c',
            'Planned_date_CFI_prestrat_Mtg_agenda__c' => 'Planned_date_CFI_prestrat_Mtg_agendaNA__c'
        }, 
        //Sandoz record type (BRM Section)
        (CON_PSA.AGG_REPORT_REC_TYPE_SANDOZ + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_BRM) => new Map<String,String>{
            'Actual_Date_for_BRM_Completion__c' => 'Actual_Date_for_BRM_Completion_NA__c',
            'Planned_Date_for_BRM_Completion__c' => 'Planned_Date_for_BRM_Completion_NA__c',
            'Actual_Date_for_BRM_Sent__c' => 'Actual_Date_for_BRM_Sent_NA__c',
            'Planned_Date_for_BRM_Sent__c' => 'Planned_Date_for_BRM_Sent_NA__c'
        },
        //Sandoz record type (Medical Review Section)
        (CON_PSA.AGG_REPORT_REC_TYPE_SANDOZ + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_MED_REVIEW) => new Map<String,String>{
            'Actual_Date_for_Medical_Review_Cmpltn__c' => 'Actual_Date_for_Medical_Review_Cmpltn_NA__c',
            'Plnnd_Date_for_Medical_Review_Cmpltn__c' => 'Plnnd_Date_for_Medical_Review_Cmpltn_NA__c',
            'Actual_Date_for_Medical_Review_Sent__c' => 'Actual_Date_for_Medical_Review_Sent_NA__c',
            'Planned_Date_for_Medical_Review_Sent__c' => 'Planned_Date_for_Medical_Review_Sent_NA__c'
        },
        //Sandoz record type (Line Listings Section)
        (CON_PSA.AGG_REPORT_REC_TYPE_SANDOZ + CON_PSA.AGG_REPORT_SECTION_COMMA_SEPARATOR + CON_PSA.AGG_REPORT_SECTION_LL) => new Map<String,String>{
            'Actual_Date_Final_LL_Requested__c' => 'Actual_Date_Final_LL_Requested_NA__c',
            'Planned_Date_to_Request_Final_LL__c' => 'Planned_Date_to_Request_Final_LL_NA__c',
            'Actual_Date_Final_LL_to_Author_Client__c' => 'Actual_Date_Final_LL_to_Author_Client_N__c',
            'Plnnd_Date_Final_LL_to_Author_Client__c' => 'Plnnd_Date_Final_LL_to_Author_ClientNA__c',
            'Final_Listings_Ticket_Number__c' => 'Final_Listings_Ticket_Number_NA__c',
            'Actual_Date_Draft_LL_to_Author_Client__c' => 'Actual_Dt_Draft_LL_to_Author_ClientNA__c',
            'Plnnd_Date_Draft_LL_to_Author_Client__c' => 'Plnnd_Dt_Draft_LL_to_Author_Client_NA__c',
	        'Draft_LL_Request_Ticket_Number__c' => 'Draft_LL_Request_Ticket_Number_NA__c',
            'Actual_Date_to_Request_Draft_LL__c' => 'Actual_Date_to_Request_Draft_LL_NA__c',
	        'Planned_Date_to_Request_Draft_LL__c' => 'Planned_Date_to_Request_Draft_LL_NA__c',
            'LL_QC_Completion_Date__c' => 'LL_QC_Completion_Date_NA__c',
            'LL_QC_Due_Date__c' => 'LL_QC_Due_Date_NA__c',
	        'LL_Review_Completion_Date__c' => 'LL_Review_Completion_Date_NA__c',
            'LL_Review_Due__c' => 'LL_Review_Due_Date_NA__c'
        }, 
        CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_GSO => new Map<String,String>{
            'Reporting_Period_Start__c' => 'Reporting_Period_Start_NA__c',
            'DLP_Reporting_Period_End__c' => 'DLP_Reporting_Period_End_NA__c',
            'Planned_date_for_First_GSO_Review__c' => 'Planned_date_for_First_GSO_Review_NA__c',
            'Actual_Date_Sent_to_GSO__c' => 'Actual_Date_Sent_to_GSO_NA__c',
            'Actual_Date_for_Final_GSO_Review__c' => 'Actual_Date_for_Final_GSO_Review_NA__c',
            'Planned_Date_for_Final_GSO_Review__c' => 'Planned_date_for_Final_GSO_Review_NA__c',
            'Planned_date_for_First_GSO_Review__c' => 'Planned_date_for_First_GSO_Review_NA__c',
            'Planned_Date_of_IQVIA_TAH_Support__c' => 'Planned_Date_of_IQVIA_TAH_Support_NA__c',
            'Actual_Date_Sent_to_IQVIA_TAH__c' => 'Actual_Date_Sent_to_IQVIA_TAH_NA__c',
            'Planned_IQVIA_TAH_Support_End_Date__c' => 'Planned_IQVIA_TAH_Support_End_Date_NA__c',
            'Final_IQVIA_TAH_Review_Date__c' => 'Final_IQVIA_TAH_Review_Date_NA__c',
            'Client_First_Draft_Due__c' => 'Client_First_Draft_Due_NA__c',
            'Client_First_Draft_Sent__c' => 'Client_First_Draft_Sent_NA__c',
            'GSO_Completion_Date__c' => 'GSO_Completion_Date_NA__c',
            'Report_Due_to_Reg_Agency__c' => 'Report_Due_to_Reg_Agency_NA__c'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_PVS => new Map<String,String>{
            'Reporting_Period_Start__c' => 'Reporting_Period_Start_NA__c',
            'DLP_Reporting_Period_End__c' => 'DLP_Reporting_Period_End_NA__c',
            'Planned_date_for_First_GSO_Review__c' => 'Planned_date_for_First_GSO_Review_NA__c',
            'Actual_Date_Sent_to_GSO__c' => 'Actual_Date_Sent_to_GSO_NA__c',
            'Planned_Date_for_Final_GSO_Review__c' => 'Planned_date_for_Final_GSO_Review_NA__c',
            'Actual_Date_for_Final_GSO_Review__c' => 'Actual_Date_for_Final_GSO_Review_NA__c',
            'Planned_Date_of_IQVIA_TAH_Support__c' => 'Planned_Date_of_IQVIA_TAH_Support_NA__c',
            'Actual_Date_Sent_to_IQVIA_TAH__c' => 'Actual_Date_Sent_to_IQVIA_TAH_NA__c',
            'Planned_IQVIA_TAH_Support_End_Date__c' => 'Planned_IQVIA_TAH_Support_End_Date_NA__c',
            'Final_IQVIA_TAH_Review_Date__c' => 'Final_IQVIA_TAH_Review_Date_NA__c',
            'Client_First_Draft_Due__c' => 'Client_First_Draft_Due_NA__c',
            'Client_First_Draft_Sent__c' => 'Client_First_Draft_Sent_NA__c',
            'GSO_Completion_Date__c' => 'GSO_Completion_Date_NA__c',
            'Report_Due_to_Reg_Agency__c' => 'Report_Due_to_Reg_Agency_NA__c'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_GENERAL => new Map<String,String>{
            'Actual_Date_for_BRM_Completion__c' => 'Actual_Date_for_BRM_Completion_NA__c',
            'Actual_Date_for_BRM_Sent__c' => 'Actual_Date_for_BRM_Sent_NA__c',
            'Actual_Date_for_Medical_Review_Cmpltn__c' => 'Actual_Date_for_Medical_Review_Cmpltn_NA__c',
            'Actual_Date_for_Medical_Review_Sent__c' => 'Actual_Date_for_Medical_Review_Sent_NA__c',
            'Actual_Date_for_QC_Completion__c' => 'Actual_Date_for_QC_Completion_NA__c',
            'Actual_Date_for_QC_Sent__c' => 'Actual_Date_for_QC_Sent_NA__c',
            'Actual_Final_Draft_Comments_Due__c' => 'Actual_Final_Draft_Comments_Due_NA__c',
            'Actual_First_Draft_Comments_Due__c' => 'Actual_First_Draft_Comments_Due_NA__c',
            'Client_Final_Draft_Due__c' => 'Client_Final_Draft_Due_NA__c',
            'Client_Final_Draft_Sent__c' => 'Client_Final_Draft_Sent_NA__c',
            'Client_First_Draft_Due__c' => 'Client_First_Draft_Due_NA__c',
            'Client_First_Draft_Sent__c' => 'Client_First_Draft_Sent_NA__c',
            'Data_Lock_Point__c' => 'Data_Lock_Point_NA__c',
            'Date_Locked__c' => 'Date_Locked_NA__c',
            'First_RTR_Actual_Date__c' => 'First_RTR_Actual_Date_NA__c',
            'First_RTR_Planned_Date__c' => 'First_RTR_Planned_Date_NA__c',
            'Final_Listings_Ticket_Number__c' => 'Final_Listings_Ticket_Number_NA__c',
            'LL_QC_Completion_Date__c' => 'LL_QC_Completion_Date_NA__c',
            'LL_QC_Due_Date__c' => 'LL_QC_Due_Date_NA__c',
            'LL_Review_Completion_Date__c' => 'LL_Review_Completion_Date_NA__c',
            'LL_Review_Due__c' => 'LL_Review_Due_Date_NA__c',
            'Planned_Date_for_BRM_Completion__c' => 'Planned_Date_for_BRM_Completion_NA__c',
            'Planned_Date_for_BRM_Sent__c' => 'Planned_Date_for_BRM_Sent_NA__c',
            'Planned_Date_for_Medical_Review_Sent__c' => 'Planned_Date_for_Medical_Review_Sent_NA__c',
            'Planned_Date_for_QC_Completion__c' => 'Planned_Date_for_QC_Completion_NA__c',
            'Planned_Date_for_QC_Sent__c' => 'Planned_Date_for_QC_Sent_NA__c',
            'Planned_Final_Draft_Comments_Due__c' => 'Planned_Final_Draft_Comments_Due_NA__c',
            'Planned_First_Draft_Comments_Due__c' => 'Planned_First_Draft_Comments_Due_NA__c',
            'Plnnd_Date_for_Medical_Review_Cmpltn__c' => 'Plnnd_Date_for_Medical_Review_Cmpltn_NA__c',
            'Plnnd_Date_Final_LL_to_Author_Client__c' => 'Plnnd_Date_Final_LL_to_Author_ClientNA__c',
            'Plnnd_Date_Draft_LL_to_Author_Client__c' => 'Plnnd_Dt_Draft_LL_to_Author_Client_NA__c',
            'PreStrategy_Actual_Date__c' => 'PreStrategy_Actual_Date_NA__c',
            'PreStrategy_Planned_Date__c' => 'PreStrategy_Planned_Date_NA__c',
            'Reporting_Period_End__c' => 'Reporting_Period_End_NA__c',
            'Reporting_Period_Start__c' => 'Reporting_Period_Start_NA__c',
            'Second_RTR_Actual_Date__c' => 'Second_RTR_Actual_Date_NA__c',
            'Second_RTR_Planned_Date__c' => 'Second_RTR_Planned_Date_NA__c',
            'Starting_Date__c' => 'Starting_Date_NA__c',
            'Strategy_Planning_Mtg_Actual_Date__c' => 'Strategy_Planning_Mtg_Actual_Date_NA__c',
            'Strategy_Planning_Mtg_Planned_Date__c' => 'Strategy_Planning_Mtg_Planned_Date_NA__c',
            'Planned_Date_to_Request_Draft_LL__c' => 'Planned_Date_to_Request_Draft_LL_NA__c',
            'Planned_Date_to_Request_Final_LL__c' => 'Planned_Date_to_Request_Final_LL_NA__c',
            'Actual_Date_Final_LL_Requested__c' => 'Actual_Date_Final_LL_Requested_NA__c',
            'Actual_Date_Final_LL_to_Author_Client__c' => 'Actual_Date_Final_LL_to_Author_Client_N__c',
            'Actual_Date_Draft_LL_to_Author_Client__c' => 'Actual_Dt_Draft_LL_to_Author_ClientNA__c',
            'Actual_Date_to_Request_Draft_LL__c' => 'Actual_Date_to_Request_Draft_LL_NA__c',
            'Draft_LL_Request_Ticket_Number__c' => 'Draft_LL_Request_Ticket_Number_NA__c'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE => new Map<String,String>{
            'Actual_Date_for_BRM_Completion__c' => 'Actual_Date_for_BRM_Completion_NA__c',
            'Actual_Date_for_BRM_Sent__c' => 'Actual_Date_for_BRM_Sent_NA__c',
            'Actual_Date_for_Medical_Review_Cmpltn__c' => 'Actual_Date_for_Medical_Review_Cmpltn_NA__c',
            'Actual_Date_for_Medical_Review_Sent__c' => 'Actual_Date_for_Medical_Review_Sent_NA__c',
            'Actual_Date_for_QC_Completion__c' => 'Actual_Date_for_QC_Completion_NA__c',
            'Actual_Date_for_QC_Sent__c' => 'Actual_Date_for_QC_Sent_NA__c',
            'Actual_Final_Draft_Comments_Due__c' => 'Actual_Final_Draft_Comments_Due_NA__c',
            'Actual_First_Draft_Comments_Due__c' => 'Actual_First_Draft_Comments_Due_NA__c',
            'Client_Final_Draft_Due__c' => 'Client_Final_Draft_Due_NA__c',
            'Client_Final_Draft_Sent__c' => 'Client_Final_Draft_Sent_NA__c',
            'Client_First_Draft_Due__c' => 'Client_First_Draft_Due_NA__c',
            'Client_First_Draft_Sent__c' => 'Client_First_Draft_Sent_NA__c',
            'Data_Lock_Point__c' => 'Data_Lock_Point_NA__c',
            //'Date_esignatures_obtained__c' => 'Date_esignatures_obtained_NA__c',
            'Date_final_report_published__c' => 'Date_final_report_published_NA__c',
            'Date_for_fnl_rprt_pblshng_in_EDMS_due__c' => 'Date_for_fnl_rprt_pblshng_in_EDMS_due_NA__c',
            //'Date_for_IQVIA_to_obtain_esignatures__c' => 'Date_for_IQVIA_to_obtain_esignatures_NA__c',
            'Date_Locked__c' => 'Date_Locked_NA__c',
            //'Final_Report_delivery_to_Takeda_PSS_sent__c' => 'Fnl_Rprt_delivery_to_Takeda_PSS_sent_NA__c',
            'Final_verification_copy_to_Takeda_due__c' => 'Final_verification_copy_to_Takeda_due_NA__c',
            'Final_verified_copy_received_by_IQVIA__c' => 'Final_verified_copy_received_by_IQVIA_NA__c',
            'First_RTR_Actual_Date__c' => 'First_RTR_Actual_Date_NA__c',
            'First_RTR_Planned_Date__c' => 'First_RTR_Planned_Date_NA__c',
            //'Fnl_Rprt_delivery_to_Takeda_PSS_due__c' => 'Fnl_Rprt_delivery_to_Takeda_PSS_due_NA__c',
            'Planned_Date_for_BRM_Completion__c' => 'Planned_Date_for_BRM_Completion_NA__c',
            'Planned_Date_for_BRM_Sent__c' => 'Planned_Date_for_BRM_Sent_NA__c',
            'Planned_Date_for_Medical_Review_Sent__c' => 'Planned_Date_for_Medical_Review_Sent_NA__c',
            'Planned_Date_for_QC_Completion__c' => 'Planned_Date_for_QC_Completion_NA__c',
            'Planned_Date_for_QC_Sent__c' => 'Planned_Date_for_QC_Sent_NA__c',
            'Planned_Final_Draft_Comments_Due__c' => 'Planned_Final_Draft_Comments_Due_NA__c',
            'Planned_First_Draft_Comments_Due__c' => 'Planned_First_Draft_Comments_Due_NA__c',
            'Plnnd_Date_for_Medical_Review_Cmpltn__c' => 'Plnnd_Date_for_Medical_Review_Cmpltn_NA__c',
            'PreStrategy_Actual_Date__c' => 'PreStrategy_Actual_Date_NA__c',
            'PreStrategy_Planned_Date__c' => 'PreStrategy_Planned_Date_NA__c',
            'Read_receipt_filed_on_ECM__c' => 'Read_receipt_filed_on_ECM_NA__c',
            'Read_receipt_received_from_PSS__c' => 'Read_receipt_received_from_PSS_NA__c',
            'Reporting_Period_End__c' => 'Reporting_Period_End_NA__c',
            'Reporting_Period_Start__c' => 'Reporting_Period_Start_NA__c',
            'Second_RTR_Actual_Date__c' => 'Second_RTR_Actual_Date_NA__c',
            'Second_RTR_Planned_Date__c' => 'Second_RTR_Planned_Date_NA__c',
            'Starting_Date__c' => 'Starting_Date_NA__c',
            'Strategy_Planning_Mtg_Actual_Date__c' => 'Strategy_Planning_Mtg_Actual_Date_NA__c',
            'Strategy_Planning_Mtg_Planned_Date__c' => 'Strategy_Planning_Mtg_Planned_Date_NA__c'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA => new Map<String,String>{
            'Actual_Date_for_BRM_Completion__c' => 'Actual_Date_for_BRM_Completion_NA__c',
            'Actual_Date_for_BRM_Sent__c' => 'Actual_Date_for_BRM_Sent_NA__c',
            'Actual_Date_for_Medical_Review_Cmpltn__c' => 'Actual_Date_for_Medical_Review_Cmpltn_NA__c',
            'Actual_Date_for_Medical_Review_Sent__c' => 'Actual_Date_for_Medical_Review_Sent_NA__c',
            'Actual_Date_for_QC_Completion__c' => 'Actual_Date_for_QC_Completion_NA__c',
            'Actual_Date_for_QC_Sent__c' => 'Actual_Date_for_QC_Sent_NA__c',
            'Actual_Final_Draft_Comments_Due__c' => 'Actual_Final_Draft_Comments_Due_NA__c',
            'Actual_First_Draft_Comments_Due__c' => 'Actual_First_Draft_Comments_Due_NA__c',
            'Client_Final_Draft_Due__c' => 'Client_Final_Draft_Due_NA__c',
            'Client_Final_Draft_Sent__c' => 'Client_Final_Draft_Sent_NA__c',
            'Client_First_Draft_Due__c' => 'Client_First_Draft_Due_NA__c',
            'Client_First_Draft_Sent__c' => 'Client_First_Draft_Sent_NA__c',
            'Data_Lock_Point__c' => 'Data_Lock_Point_NA__c',
            //'Date_esignatures_obtained__c' => 'Date_esignatures_obtained_NA__c',
            'Date_final_report_published__c' => 'Date_final_report_published_NA__c',
            'Date_for_fnl_rprt_pblshng_in_EDMS_due__c' => 'Date_for_fnl_rprt_pblshng_in_EDMS_due_NA__c',
            //'Date_for_IQVIA_to_obtain_esignatures__c' => 'Date_for_IQVIA_to_obtain_esignatures_NA__c',
            'Date_Locked__c' => 'Date_Locked_NA__c',
            'Final_Listings_Ticket_Number__c' => 'Final_Listings_Ticket_Number_NA__c',
            //'Final_Report_delivery_to_Takeda_PSS_sent__c' => 'Fnl_Rprt_delivery_to_Takeda_PSS_sent_NA__c',
            'Final_verification_copy_to_Takeda_due__c' => 'Final_verification_copy_to_Takeda_due_NA__c',
            'Final_verified_copy_received_by_IQVIA__c' => 'Final_verified_copy_received_by_IQVIA_NA__c',
            'First_RTR_Actual_Date__c' => 'First_RTR_Actual_Date_NA__c',
            'First_RTR_Planned_Date__c' => 'First_RTR_Planned_Date_NA__c',
            //'Fnl_Rprt_delivery_to_Takeda_PSS_due__c' => 'Fnl_Rprt_delivery_to_Takeda_PSS_due_NA__c',
            'LL_QC_Completion_Date__c' => 'LL_QC_Completion_Date_NA__c',
            'LL_QC_Due_Date__c' => 'LL_QC_Due_Date_NA__c',
            'LL_Review_Completion_Date__c' => 'LL_Review_Completion_Date_NA__c',
            'LL_Review_Due__c' => 'LL_Review_Due_Date_NA__c',
            'Planned_Date_for_BRM_Completion__c' => 'Planned_Date_for_BRM_Completion_NA__c',
            'Planned_Date_for_BRM_Sent__c' => 'Planned_Date_for_BRM_Sent_NA__c',
            'Planned_Date_for_Medical_Review_Sent__c' => 'Planned_Date_for_Medical_Review_Sent_NA__c',
            'Planned_Date_for_QC_Completion__c' => 'Planned_Date_for_QC_Completion_NA__c',
            'Planned_Date_for_QC_Sent__c' => 'Planned_Date_for_QC_Sent_NA__c',
            'Planned_Final_Draft_Comments_Due__c' => 'Planned_Final_Draft_Comments_Due_NA__c',
            'Planned_First_Draft_Comments_Due__c' => 'Planned_First_Draft_Comments_Due_NA__c',
            'Plnnd_Date_for_Medical_Review_Cmpltn__c' => 'Plnnd_Date_for_Medical_Review_Cmpltn_NA__c',
            'Plnnd_Date_Final_LL_to_Author_Client__c' => 'Plnnd_Date_Final_LL_to_Author_ClientNA__c',
            'Plnnd_Date_Draft_LL_to_Author_Client__c' => 'Plnnd_Dt_Draft_LL_to_Author_Client_NA__c',
            'PreStrategy_Actual_Date__c' => 'PreStrategy_Actual_Date_NA__c',
            'PreStrategy_Planned_Date__c' => 'PreStrategy_Planned_Date_NA__c',
            'Read_receipt_filed_on_ECM__c' => 'Read_receipt_filed_on_ECM_NA__c',
            'Read_receipt_received_from_PSS__c' => 'Read_receipt_received_from_PSS_NA__c',
            'Reporting_Period_End__c' => 'Reporting_Period_End_NA__c',
            'Reporting_Period_Start__c' => 'Reporting_Period_Start_NA__c',
            'Second_RTR_Actual_Date__c' => 'Second_RTR_Actual_Date_NA__c',
            'Second_RTR_Planned_Date__c' => 'Second_RTR_Planned_Date_NA__c',
            'Starting_Date__c' => 'Starting_Date_NA__c',
            'Strategy_Planning_Mtg_Actual_Date__c' => 'Strategy_Planning_Mtg_Actual_Date_NA__c',
            'Strategy_Planning_Mtg_Planned_Date__c' => 'Strategy_Planning_Mtg_Planned_Date_NA__c',
            'Planned_Date_to_Request_Draft_LL__c' => 'Planned_Date_to_Request_Draft_LL_NA__c',
            'Planned_Date_to_Request_Final_LL__c' => 'Planned_Date_to_Request_Final_LL_NA__c',
            'Actual_Date_Final_LL_Requested__c' => 'Actual_Date_Final_LL_Requested_NA__c',
            'Actual_Date_Final_LL_to_Author_Client__c' => 'Actual_Date_Final_LL_to_Author_Client_N__c',
            'Actual_Date_Draft_LL_to_Author_Client__c' => 'Actual_Dt_Draft_LL_to_Author_ClientNA__c',
            'Actual_Date_to_Request_Draft_LL__c' => 'Actual_Date_to_Request_Draft_LL_NA__c',
            'Draft_LL_Request_Ticket_Number__c' => 'Draft_LL_Request_Ticket_Number_NA__c'
        }
    };

    private static Map<String, Map<String,String>> genericFieldtoNAFieldMaps = new Map<String, Map<String,String>>{
        'Default' => new Map<String,String>(),
        CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_GSO => new Map<String,String>{
            'IQVIA_TAH__c' => 'IQVIA_TAH_NA__c'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_PVS => new Map<String,String>{
            'IQVIA_Primary_GSO__c' => 'IQVIA_Primary_GSO_NA__c',
            'IQVIA_Secondary_GSO__c' => 'IQVIA_Secondary_GSO_NA__c',
            'IQVIA_TAH__c' => 'IQVIA_TAH_NA__c'
           // 'PVS_GBU_Lead__c' => 'PVS_GBU_Lead_NA__c',
          //   'IQVIA_GSO_LM__c' => 'IQVIA_GSO_LM_NA__c'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_GENERAL => new Map<String,String>(),
        CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE => new Map<String,String>(),
        CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA => new Map<String,String>()
    };

    private static Map<String, Map<String,String>> actualToLateReasonMaps = new Map<String, Map<String,String>>{
        'Default' => new Map<String,String>(),
        CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_GSO => new Map<String,String>{
            'Client_Final_Sent__c' => 'Final_Sent_Late_Reason_Text__c'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_PVS => new Map<String,String>{
            'Client_Final_Sent__c' => 'Final_Sent_Late_Reason_Text__c'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_GENERAL => new Map<String,String>{
            'Actual_Date_for_BRM_Completion__c' => 'BRM_Late_Responsibility__c,BRM_Late_Reason__c',
            'Client_Final_Draft_Sent__c' => 'Final_Draft_Sent_Late_Reason__c,Final_Draft_Sent_Late_Responsibility__c',
            'Client_First_Draft_Sent__c' => 'First_Draft_Sent_Late_Reason__c,First_Draft_Sent_Late_Responsibility__c',
            'Actual_Date_for_Medical_Review_Cmpltn__c' => 'Medical_Review_Late_Reason__c,Medical_Review_Late_Responsibility__c',
            'Actual_Date_for_QC_Completion__c' => 'QC_Late_Responsibility__c,QC_Late_Reason__c',
            'Actual_Date_for_QC_Sent__c' => 'QC_Sent_Late_Reason__c',
            'Date_Submitted_to_IQVIA_or_Client_Reg__c' => 'Submitted_to_IQVIA_Late_Reason__c,Submitted_to_IQVIA_Late_Responsibility__c'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE => new Map<String,String>{
            'Actual_Date_for_BRM_Completion__c' => 'BRM_Late_Responsibility__c,BRM_Late_Reason__c',
            'Client_Final_Draft_Sent__c' => 'Final_Draft_Sent_Late_Reason__c,Final_Draft_Sent_Late_Responsibility__c',
            'Client_First_Draft_Sent__c' => 'First_Draft_Sent_Late_Reason__c,First_Draft_Sent_Late_Responsibility__c',
            'Actual_Date_for_Medical_Review_Cmpltn__c' => 'Medical_Review_Late_Reason__c,Medical_Review_Late_Responsibility__c',
            'Actual_Date_for_QC_Completion__c' => 'QC_Late_Responsibility__c,QC_Late_Reason__c',
            'Actual_Date_for_QC_Sent__c' => 'QC_Sent_Late_Reason__c',
            'Date_Submitted_to_IQVIA_or_Client_Reg__c' => 'Submitted_to_IQVIA_Late_Reason__c,Submitted_to_IQVIA_Late_Responsibility__c'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA => new Map<String,String>{
            'Actual_Date_for_BRM_Completion__c' => 'BRM_Late_Responsibility__c,BRM_Late_Reason__c',
            'Client_Final_Draft_Sent__c' => 'Final_Draft_Sent_Late_Reason__c,Final_Draft_Sent_Late_Responsibility__c',
            'Client_First_Draft_Sent__c' => 'First_Draft_Sent_Late_Reason__c,First_Draft_Sent_Late_Responsibility__c',
            'Actual_Date_for_Medical_Review_Cmpltn__c' => 'Medical_Review_Late_Reason__c,Medical_Review_Late_Responsibility__c',
            'Actual_Date_for_QC_Completion__c' => 'QC_Late_Responsibility__c,QC_Late_Reason__c',
            'Actual_Date_for_QC_Sent__c' => 'QC_Sent_Late_Reason__c',
            'Date_Submitted_to_IQVIA_or_Client_Reg__c' => 'Submitted_to_IQVIA_Late_Reason__c,Submitted_to_IQVIA_Late_Responsibility__c'
        }
    };

    private static Map<String, Map<String,String>> contactDependencyMaps = new Map<String, Map<String,String>>{
        'Default' => new Map<String,String>(),
        CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_GSO => new Map<String,String>(),
        CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_PVS => new Map<String,String>(),
        CON_PSA.AGG_REPORT_REC_TYPE_GENERAL => new Map<String,String>{
            'Coordinator__c' => 'Coordinator_NA__c',
            'Line_Listing_QCer__c' => '',
            'Line_Listing_Reviewer__c' => '',
            'Primary_Author__c' => 'Report_Writing__c',
            'Primary_BRM_Analyst__c' => 'BRM_Review_Requirement__c',
            'Primary_Medical_Reviewer__c' => 'Medical_Reviewer_Review_Requirement__c',
            'Primary_QC_Reviewer__c' => '',
            'Primary_Reviewer__c' => 'Literature_Review_Requirement__c',
            'PV_Solutions_Lead__c' => '',
            'Secondary_Author__c' => 'Report_Writing__c',
            'Secondary_BRM_Analyst__c' => 'BRM_Review_Requirement__c',
            'Secondary_Medical_Reviewer__c' => 'Medical_Reviewer_Review_Requirement__c',
            'Secondary_QC_Reviewer__c' => '',
            'Secondary_Reviewer__c' => 'Literature_Review_Requirement__c'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE => new Map<String,String>{
            'Coordinator__c' => 'Coordinator_NA__c',
            'Primary_Author__c' => 'Report_Writing__c',
            'Primary_BRM_Analyst__c' => 'BRM_Review_Requirement__c',
            'Primary_Medical_Reviewer__c' => 'Medical_Reviewer_Review_Requirement__c',
            'Primary_QC_Reviewer__c' => '',
            'Primary_Reviewer__c' => 'Literature_Review_Requirement__c',
            'PV_Solutions_Lead__c' => '',
            'Secondary_Author__c' => 'Report_Writing__c',
            'Secondary_BRM_Analyst__c' => 'BRM_Review_Requirement__c',
            'Secondary_Medical_Reviewer__c' => 'Medical_Reviewer_Review_Requirement__c',
            'Secondary_QC_Reviewer__c' => '',
            'Secondary_Reviewer__c' => 'Literature_Review_Requirement__c'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA => new Map<String,String>{
            'Coordinator__c' => 'Coordinator_NA__c',
            'Line_Listing_QCer__c' => '',
            'Line_Listing_Reviewer__c' => '',
            'Primary_Author__c' => 'Report_Writing__c',
            'Primary_BRM_Analyst__c' => 'BRM_Review_Requirement__c',
            'Primary_Medical_Reviewer__c' => 'Medical_Reviewer_Review_Requirement__c',
            'Primary_QC_Reviewer__c' => '',
            'Primary_Reviewer__c' => 'Literature_Review_Requirement__c',
            'PV_Solutions_Lead__c' => '',
            'Secondary_Author__c' => 'Report_Writing__c',
            'Secondary_BRM_Analyst__c' => 'BRM_Review_Requirement__c',
            'Secondary_Medical_Reviewer__c' => 'Medical_Reviewer_Review_Requirement__c',
            'Secondary_QC_Reviewer__c' => '',
            'Secondary_Reviewer__c' => 'Literature_Review_Requirement__c'
        }
    };

    private static Map<String, Map<String,String>> contactSubRoleMaps = new Map<String, Map<String,String>>{
        'Default' => new Map<String,String>(),
        CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_GSO => new Map<String,String>{
            'IQVIA_Primary_PV_Scientist__c' => 'IQVIA Primary PV Scientist',
            'IQVIA_Primary_GSO__c' => 'IQVIA Primary GSO',
            'IQVIA_Secondary_GSO__c' => 'IQVIA Secondary GSO',
            'IQVIA_GSO_LM__c' => 'IQVIA GSO LM',
            'IQVIA_TAH__c' => 'IQVIA TAH',
            'PVS_GBU_Lead__c' => 'PVS GBU lead',
            'IQVIA_PVS_Manager__c' => 'PVS Manager'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_PVS => new Map<String,String>{
            'IQVIA_Primary_PV_Scientist__c' => 'IQVIA Primary PV Scientist',
            'IQVIA_Primary_GSO__c' => 'IQVIA Primary GSO',
            'IQVIA_Secondary_GSO__c' => 'IQVIA Secondary GSO',
            // 'IQVIA_GSO_LM__c' => 'IQVIA GSO LM',
            'IQVIA_TAH__c' => 'IQVIA TAH'
           // 'PVS_GBU_Lead__c' => 'PVS GBU lead',
          // 'IQVIA_PVS_Manager__c' => 'PVS Manager'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_GENERAL => new Map<String,String>(),
        CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE => new Map<String,String>(),
        CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA => new Map<String,String>()
    };
    private static Map<String, Map<String,String>> dependencyMaps = new Map<String, Map<String,String>>{
        'Default' => new Map<String,String>(),
        CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_GSO => new Map<String,String>{
            'Planned_date_for_First_GSO_Review__c' => 'IQVIA_Primary_GSO__c',
            'Actual_Date_Sent_to_IQVIA_TAH__c' => 'IQVIA_TAH__c',
            'Final_IQVIA_TAH_Review_Date__c' => 'IQVIA_TAH__c',
            'Planned_Date_of_IQVIA_TAH_Support__c' => 'IQVIA_TAH__c',
            'Planned_IQVIA_TAH_Support_End_Date__c' => 'IQVIA_TAH__c'
        },
        CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_PVS => new Map<String,String>{
            //IQVIAPSA-9368
            /*'Planned_date_for_First_GSO_Review__c' => 'IQVIA_Primary_GSO__c',
            'Actual_Date_Sent_to_IQVIA_TAH__c' => 'IQVIA_TAH__c',
            'Final_IQVIA_TAH_Review_Date__c' => 'IQVIA_TAH__c',
            'Planned_Date_of_IQVIA_TAH_Support__c' => 'IQVIA_TAH__c',
            'Planned_IQVIA_TAH_Support_End_Date__c' => 'IQVIA_TAH__c'*/
        },
        CON_PSA.AGG_REPORT_REC_TYPE_GENERAL => new Map<String,String>(),
        CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE => new Map<String,String>(),
        CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA => new Map<String,String>()
    };
        
        private static Map<string,set<string>> recordtypeToFieldsToEliminateMap = new Map<string,set<string>>{
            CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE => new Set<String>{'LL_Review_Due__c','LL_QC_Due_Date__c','Client_First_Draft_Due__c','Client_Final_Draft_Due__c','Report_Due_to_IQVIA_or_Client_Reg__c','Planned_First_Draft_Comments_Due__c','Actual_First_Draft_Comments_Due__c','Planned_Final_Draft_Comments_Due__c','Actual_Final_Draft_Comments_Due__c','Report_Due_to_Reg_Agency__c'},
            CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA => new Set<String>{'LL_Review_Due__c','LL_QC_Due_Date__c','Fnl_Rprt_delivery_to_Takeda_PSS_due__c','Report_Due_to_IQVIA_or_Client_Reg__c','Date_for_fnl_rprt_pblshng_in_EDMS_due__c','Client_First_Draft_Due__c','Client_Final_Draft_Due__c','Planned_First_Draft_Comments_Due__c','Actual_First_Draft_Comments_Due__c','Planned_Final_Draft_Comments_Due__c','Actual_Final_Draft_Comments_Due__c','Report_Due_to_Reg_Agency__c','Final_verification_copy_to_Takeda_due__c'},
            CON_PSA.AGG_REPORT_REC_TYPE_GENERAL =>  new Set<String>{'LL_Review_Due__c','LL_QC_Due_Date__c','Client_First_Draft_Due__c','Client_Final_Draft_Due__c','Report_Due_to_IQVIA_or_Client_Reg__c','Planned_First_Draft_Comments_Due__c','Actual_First_Draft_Comments_Due__c','Planned_Final_Draft_Comments_Due__c','Actual_Final_Draft_Comments_Due__c','Report_Due_to_Reg_Agency__c'},
            CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_PVS => new Set<String>{'Client_Final_Due__c','Report_Due_to_Reg_Agency__c'},
            CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_GSO => new Set<String>{'Client_Final_Due__c','Report_Due_to_Reg_Agency__c'}    
        };
   
    public static void makeReportValid(Aggregate_Report__c agReport){
        String recordTypeName = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId).getDeveloperName();
        Map<String,String> dateFieldtoNAField = dateFieldtoNAFieldMaps.get(recordTypeName);
        for(String dateField : dateFieldtoNAField.keySet()){
            if(agReport.get(dateField) == null) {
                agReport.put(dateFieldtoNAField.get(dateField), 'Yes');
            }
        }

        Map<String,String> contactFieldMap = buildContactMap(recordTypeName);

        //Check that all contacts on completed report have location set
        for(String contactField : contactFieldMap.keySet()){
            Boolean hasContact = agReport.get(contactField) != null;
            String validatingField = contactFieldMap.get(contactField);

            if( hasContact && !String.isBlank(validatingField) ){
                agReport.put(validatingField, 'IQVIA');
            }
            if( !hasContact && !String.isBlank(validatingField) &&(validatingField != 'BRM_Review_Requirement__c' &&
                   validatingField != 'Medical_Reviewer_Review_Requirement__c' )){
                agReport.put(validatingField, 'NA');
            }
        }

        if(!sanofiRecordTypeNames.contains(recordTypeName)){
            agReport.Customer_Requested_Resource_Location__c = 'USDUR1';
        }
    }
    
    public static void populateSanofiProducts(List<Aggregate_Report__c> updatedList, Map<Id,Aggregate_Report__c> existingRecords){
        List<Aggregate_Report__c> sanofiReports = new List<Aggregate_Report__c>();
        for(Aggregate_Report__c ar : updatedList){
           	String recordTypeName = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(ar.RecordTypeId).getDeveloperName();
        	Boolean isSanofi = sanofiRecordTypeNames.contains(recordTypeName);
            
            if(isSanofi){
                sanofiReports.add(ar);
            }
        }
        
        List<Report_Drug__c> relatedReportDrugs = [SELECT Id, Name, Aggregate_Report__c FROM Report_Drug__c WHERE Aggregate_Report__c IN :sanofiReports];
        for(Aggregate_Report__c ar : sanofiReports){
            List<String> relatedProds = new List<String>();
            for(Report_Drug__c rd : relatedReportDrugs){
                if(rd.Aggregate_Report__c == ar.Id){
                    relatedProds.add(rd.Name);
                }
            }
            if(!relatedProds.isEmpty()){
                ar.Sanofi_Products__c = string.join(relatedProds,' ');
            }
        }
        
    }

    /*
     * A method for after insert or update that copies drugs from a primary report to its cloned child
     */
    public static void populateSanofiDrugs(List<Aggregate_Report__c> updatedList, Map<Id,Aggregate_Report__c> existingRecords, Map<String, Set<String>> methodToRecordTypeMap){

        List<Aggregate_Report__C> reportsNeedingDrugsList = new List<Aggregate_Report__c>();
        Set<Id> primaryReportIdSet = new Set<Id>();
        Set<Id> aggReportIdSet = new Set<Id>();

        for(Aggregate_Report__c agReport : updatedList){
            String recordTypeName = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId).getDeveloperName();

            if( Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId) == null ||
                !methodToRecordTypeMap.get('populateSanofiDrugs').contains(recordTypeName) ) {
                continue;
            }

            //Find Sanofi reports that are new and have a parent, or exist and have a new parent
            //Note: if for some reason you were changing the primary report and had existing drugs on the child, these are currently not being deleted
            if( agReport.Id != null && agReport.Primary_Report__c != null &&
                (existingRecords == null || existingRecords.get(agReport.Id) == null || existingRecords.get(agReport.Id).Primary_Report__c != agReport.Primary_Report__c))
            {
                reportsNeedingDrugsList.add(agReport);
                primaryReportIdSet.add(agReport.Primary_Report__c);
                aggReportIdSet.add(agReport.id);
            }
        }

        if(reportsNeedingDrugsList.size() > 0){
            Map<Id,List<Report_Drug__c>> agReportIDToExistingReportDrugMap = new Map<Id,List<Report_Drug__c>>();
            List<Report_Drug__c> relatedReportDrugsExist = new SLT_Report_Drug(false).getReportDrugList(aggReportIdSet, new Set<String>{'Id', 'Name', 'Aggregate_Report__c', 'Drug__c','Drug__r.name', 'Indication__c', 'Therapeutic_Area__c', 'Program__c'}, 'Aggregate_Report__c' );
            for(Report_Drug__c drug : relatedReportDrugsExist){
                List<Report_Drug__c> drugList = agReportIDToExistingReportDrugMap.get(drug.Aggregate_Report__c);
                if(drugList == null){
                    drugList = new List<Report_Drug__c>();
                    agReportIDToExistingReportDrugMap.put(drug.Aggregate_Report__c,drugList);
                }
                drugList.add(drug);
            }
            
            //Find the parents' drugs to copy, and index them by report
            List<Report_Drug__c> relatedReportDrugs = new SLT_Report_Drug(false).getReportDrugList(primaryReportIdSet, new Set<String>{'Id', 'Name', 'Aggregate_Report__c', 'Drug__c','Drug__r.name', 'Indication__c', 'Therapeutic_Area__c', 'Program__c'}, 'Aggregate_Report__c' );
            Map<Id,List<Report_Drug__c>> reportToDrugMap = new Map<Id,List<Report_Drug__c>>();
            for(Report_Drug__c drug : relatedReportDrugs){
                List<Report_Drug__c> drugList = reportToDrugMap.get(drug.Aggregate_Report__c);
                if(drugList == null){
                    drugList = new List<Report_Drug__c>();
                    reportToDrugMap.put(drug.Aggregate_Report__c,drugList);
                }
                drugList.add(drug);
            }

            //Make copies of the drugs for each child report
            List<Report_Drug__c> drugsToInsertList = new List<Report_Drug__c>();
            List<Report_Drug__c> drugsToDeleteList = new List<Report_Drug__c>();
            
            for(Aggregate_Report__c report : reportsNeedingDrugsList){
                List<Report_Drug__c> drugsToCopyList = reportToDrugMap.get(report.Primary_Report__c);
                List<Report_Drug__c> existingReportDrugList = agReportIDToExistingReportDrugMap.get(report.id);
                if(drugsToCopyList != null){
                    for(Report_Drug__c drugToCopy : drugsToCopyList){
                        if(existingReportDrugList != null && existingReportDrugList.size()>0){
                            boolean recordAlreadyExist= false;
                            integer index=0;
                            for(Report_Drug__c existRptDrug : existingReportDrugList ){
                                if(drugToCopy.Drug__r.name == existRptDrug.Drug__r.name){
                                    recordAlreadyExist = true;
                                    break;
                                }
                                index = index + 1;
                            }
                            if(recordAlreadyExist)
                            {
                                existingReportDrugList.remove(index);
                                continue;
                            }
                        }
                        Report_Drug__c copiedDrug = drugToCopy.clone(false,true,false,false);
                        copiedDrug.Aggregate_Report__c = report.Id;
                        drugsToInsertList.add(copiedDrug);
                    }
                    if(existingReportDrugList != null && existingReportDrugList.size()>0){
                        drugsToDeleteList.addAll(existingReportDrugList);
                    }
                }
            }

            if(drugsToInsertList.size() > 0){
                insert drugsToInsertList;
            }
            // Delete report drug on aggregate report that does not exist on primary report.
            if(drugsToDeleteList.size() > 0){
                delete drugsToDeleteList;
            }
            
        }
    }
    
    public static void fieldValidations(List<Aggregate_Report__c> newList,Map<Id, Aggregate_Report__c> oldMap){
        
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        If(!mulesoftSetting.Ignore_Validation_Rules__c){
            for(Aggregate_Report__c aggRepRec : newList){
                String recordTypeName = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(aggRepRec.RecordTypeId).getDeveloperName();
                if(recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA || recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_GENERAL){
                    if(aggRepRec.Date_Submitted_to_IQVIA_or_Client_Reg__c > aggRepRec.Report_Due_to_IQVIA_or_Client_Reg__c && (
                    aggRepRec.Submitted_to_IQVIA_Late_Responsibility__c == null || aggRepRec.Submitted_to_IQVIA_Late_Reason_Text__c == null ||
                    aggRepRec.Submitted_to_IQVIA_Late_Reason__c == null)){
                        aggRepRec.addError('The \'Submitted to Reg Late Responsibility\', \'Submitted to Reg Late Reason\' and \'Submitted to Reg Late Reason Text\' fields cannot be empty as the \'Date Submitted to IQVIA or Client Reg\' is after the \'Report Due to IQVIA or Client Reg\'.');
                    }
                }
            }
        }
    }
    
    /**
     * update PJE on change of recipients so the updated recipient receives the notification
     * 
     */
    public static void updtRltdPJEToUpdtReciepients(List<Aggregate_Report__c> updatedList, Map<Id,Aggregate_Report__c> existingRecords){
        List<Aggregate_Report__c> aggRepToUpdtLst = new List<Aggregate_Report__c>();
        fetchPSAEvents();
        
        for(PSA_Event__c event : psaEvents){
            for(Aggregate_Report__c aggRep : updatedList){
                Boolean plannedDtChanged = false, primaryResChanged = false, secResChanged = false, otherResChanged = false;
                if(event.Planned_Date_Field__c != null){
                    plannedDtChanged = aggRep.get(event.Planned_Date_Field__c) != (existingRecords.get(aggRep.Id)).get(event.Planned_Date_Field__c);
                }
                if(event.Primary_Resource_Field__c != null){
                    primaryResChanged = aggRep.get(event.Primary_Resource_Field__c) != (existingRecords.get(aggRep.Id)).get(event.Primary_Resource_Field__c);
                }
                if(event.Secondary_Resource_Field__c != null){
                    secResChanged = aggRep.get(event.Secondary_Resource_Field__c) != (existingRecords.get(aggRep.Id)).get(event.Secondary_Resource_Field__c);
                }           
                if(event.Other_Resource_Field__c != null){
                    otherResChanged = aggRep.get(event.Other_Resource_Field__c) != (existingRecords.get(aggRep.Id)).get(event.Other_Resource_Field__c);
                }
                if(plannedDtChanged || primaryResChanged || secResChanged || otherResChanged){
                    if(!aggRepToUpdtLst.contains(aggRep) && aggRep.Status__c != CON_PSA.AGG_REPORT_Status_Completed){
                       aggRepToUpdtLst.add(aggRep);
                    }
                }
                
            }
        }
        
        Set<Id> reportIds = new Set<Id>(new Map<Id,Aggregate_Report__c>(aggRepToUpdtLst).keySet());
        Set<String> eventFields = new SLT_Project_Event().getDefaultFields();
        Map<Id,Date> projectEventsToActualDateMap = new Map<Id,Date>();
        List<Project_Event__c> events = new SLT_Project_Event().getProjectEventsByReport(reportIds, eventFields);
        
        Map<Id, List<Project_Event__c>> aggRepToPJEMap = new Map<Id, List<Project_Event__c>>();
        for (Project_Event__c pje : events) {
            List<Project_Event__c> tempMSList = aggRepToPJEMap.get(pje.Report__c);

            if (tempMSList != null) {
                tempMSList.add(pje);
                aggRepToPJEMap.put(pje.Report__c,tempMSList);
            } else {
                aggRepToPJEMap.put(pje.Report__c, new List<Project_Event__c>{pje});
            }
        }
        
        List<Project_Event__c> allPjeEvents = new List<Project_Event__c>();
        for(Aggregate_Report__c aggRep : aggRepToUpdtLst){
            if( aggRepToPJEMap.containsKey( aggRep.Id )  && aggRepToPJEMap.get(aggRep.Id) != null ){
                List<Project_Event__c> pjeEvents = aggRepToPJEMap.get(aggRep.Id);
                if( pjeEvents.size() > 0  ){
                    for(Project_Event__c pje : pjeEvents){
                        projectEventsToActualDateMap.put(pje.Id, pje.Event_Actual_Date__c);
                        allPjeEvents.add(pje);                
                    	}  
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
    
    
    public static void checkQCTOnReportCompletion(List<Aggregate_Report__c> updatedList, Map<Id,Aggregate_Report__c> oldMap){
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        Set<Id> toCompleteAggRepSet = new Set<Id>();
        Boolean qctInvalidChkBox = false;
        Map<Id, List<QC_Tracker_Result__c>> aggRepIdToQCTListMap = new Map<Id, List<QC_Tracker_Result__c>>();
        List<String> qcFormTypeList = new List<String>();
        List<String> qcRecToChkFormTypeList = new List<String>();
        Set<QC_Tracker_Result__c> chkDuplValSet = new Set<QC_Tracker_Result__c>();
        String aggRepType = '';
        List<QC_Tracker_Result__c> qctList = new List<QC_Tracker_Result__c>();
        Map<Id, Aggregate_Report__c> aggRepToCheckMap = new Map<Id, Aggregate_Report__c>();
        If(!mulesoftSetting.Ignore_Validation_Rules__c){
            for(Aggregate_Report__c aggRep : updatedList){
                String recordTypeName = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(aggRep.RecordTypeId).getDeveloperName();
                if(recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_GENERAL || recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA){
                    if((trigger.isInsert && aggRep.Status__c == 'Completed') || (trigger.isUpdate && aggRep.Status__c == 'Completed' && oldMap.get(aggRep.Id).Status__c != 'Completed')){
                        toCompleteAggRepSet.add(aggRep.Id);
                        aggRepToCheckMap.put(aggRep.Id,aggRep);
                    }
                }
            }
            if(toCompleteAggRepSet.size() > 0){
                String whereClause = 'Aggregate_Report__c IN :rltdAggRepId AND Date_Deleted__c = null';
                aggRepIdToQCTListMap = new SLT_QC_Tracker(false,false).getActiveQCTrackerRecordsforAggReps(toCompleteAggRepSet, new Set<String>{'Id','Name','REP_QC_Form_Type__c','Aggregate_Report__r.Report_Type__c'}, whereClause);
            }
            if(aggRepIdToQCTListMap != null && aggRepIdToQCTListMap.size() > 0){
                for(Id aggRepId : aggRepIdToQCTListMap.keyset()){
                    qctList = aggRepIdToQCTListMap.get(aggRepId);
                    if(qctList != null && qctList.size() > 0){
                        aggRepType = qctList.get(0).Aggregate_Report__r.Report_Type__c;
                        if(aggRepType != null || aggRepType != ''){
                            qcFormTypeList = CON_PSA.aggRepValToQCFormTypeMap.get(aggRepType);
                            chkDuplValSet.addAll(qctList);
                            if(qcFormTypeList != null && qcFormTypeList.size() > 0){
                                if((qctList.size() != qcFormTypeList.size()) || (chkDuplValSet.size() < qcFormTypeList.size())){
                                    qctInvalidChkBox = true;
                                }else{
                                    for(QC_Tracker_Result__c qc : qctList){
                                        qcRecToChkFormTypeList.add(qc.REP_QC_Form_Type__c);
                                    }
                                    for(String formType : qcFormTypeList){
                                        if(qcRecToChkFormTypeList.size() > 0 && !qcRecToChkFormTypeList.contains(formType)){
                                            qctInvalidChkBox = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if(qctInvalidChkBox == true){
                        Aggregate_Report__c aggRepToUpdt = aggRepToCheckMap.get(aggRepId);
                        aggRepToUpdt.Override_done_by_system__c = false;
                    }else{
                        Aggregate_Report__c aggRepToUpdt = aggRepToCheckMap.get(aggRepId);
                        aggRepToUpdt.Override__c = true;
                        aggRepToUpdt.Override_done_by_system__c = true;
                    }
                }
            }
        }
    }
    public static void checkQCTOnReportCompletionForSandoz(List<Aggregate_Report__c> updatedList, Map<Id,Aggregate_Report__c> oldMap){
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        Set<Id> toCompleteAggRepSet = new Set<Id>();
        Boolean qctInvalidChkBox = false;
        Map<Id, List<QC_Tracker_Result__c>> aggRepIdToQCTListMap = new Map<Id, List<QC_Tracker_Result__c>>();
        List<String> qcFormTypeList = new List<String>();
        List<String> qcRecToChkFormTypeList = new List<String>();
        Set<QC_Tracker_Result__c> chkDuplValSet = new Set<QC_Tracker_Result__c>();
        String aggRepType = '';
        List<QC_Tracker_Result__c> qctList = new List<QC_Tracker_Result__c>();
        Map<Id, Aggregate_Report__c> aggRepToCheckMap = new Map<Id, Aggregate_Report__c>();
        If(!mulesoftSetting.Ignore_Validation_Rules__c){
            for(Aggregate_Report__c aggRep : updatedList){
                String recordTypeName = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(aggRep.RecordTypeId).getDeveloperName();
                if(recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_SANDOZ){
                    if((trigger.isInsert && aggRep.Status__c == 'Completed') || (trigger.isUpdate && aggRep.Status__c == 'Completed' && oldMap.get(aggRep.Id).Status__c != 'Completed')){
                        toCompleteAggRepSet.add(aggRep.Id);
                        aggRepToCheckMap.put(aggRep.Id,aggRep);
                    }
                }
            }
            if(toCompleteAggRepSet.size() > 0){
                String whereClause = 'Aggregate_Report__c IN :rltdAggRepId AND Date_Deleted__c = null';
                aggRepIdToQCTListMap = new SLT_QC_Tracker(false,false).getActiveQCTrackerRecordsforAggReps(toCompleteAggRepSet, new Set<String>{'Id','Name','REP_QC_Form_Type__c','Aggregate_Report__r.Report_Type__c'}, whereClause);
            }
            if(aggRepIdToQCTListMap != null && aggRepIdToQCTListMap.size() > 0){
                for(Id aggRepId : aggRepIdToQCTListMap.keyset()){
                    qctList = aggRepIdToQCTListMap.get(aggRepId);
                    if(qctList != null && qctList.size() > 0){
                        aggRepType = qctList.get(0).Aggregate_Report__r.Report_Type__c;
                        if(aggRepType != null || aggRepType != ''){
                            qcFormTypeList = CON_PSA.aggRepValToQCFormTypeMapForSandoz.get(aggRepType);
                            chkDuplValSet.addAll(qctList);
                            if(qcFormTypeList != null && qcFormTypeList.size() > 0){
                                if((qctList.size() != qcFormTypeList.size()) || (chkDuplValSet.size() < qcFormTypeList.size())){
                                    qctInvalidChkBox = true;
                                }else{
                                    for(QC_Tracker_Result__c qc : qctList){
                                        qcRecToChkFormTypeList.add(qc.REP_QC_Form_Type__c);
                                    }
                                    for(String formType : qcFormTypeList){
                                        if(qcRecToChkFormTypeList.size() > 0 && !qcRecToChkFormTypeList.contains(formType)){
                                            qctInvalidChkBox = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if(qctInvalidChkBox == true){
                        Aggregate_Report__c aggRepToUpdt = aggRepToCheckMap.get(aggRepId);
                        aggRepToUpdt.Override_done_by_system__c = false;
                    }else{
                        Aggregate_Report__c aggRepToUpdt = aggRepToCheckMap.get(aggRepId);
                        aggRepToUpdt.Override__c = true;
                        aggRepToUpdt.Override_done_by_system__c = true;
                    }
                }
            }
        }
    }
    
    /**
     * update prior email fields to store previously asssigned resources email for sending email alerts.(IQVIAPSA-5353)
     * 
     */
    public static void updateFieldsforEmailAlerts(List<Aggregate_Report__c> newList, Map<Id, Aggregate_Report__c> oldMap){ 
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id,Contact> contactIdToRecordMap;
        for(Aggregate_Report__c agReport : newList){
            if(Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA || 
               Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_GENERAL ||
               Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE ||
               Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_SANDOZ){
                   if(oldMap.get(agReport.id).Primary_QC_Reviewer__c != null){
                       contactIdSet.add(oldMap.get(agReport.id).Primary_QC_Reviewer__c); 
                   }
                   if(oldMap.get(agReport.id).Secondary_QC_Reviewer__c != null){
                       contactIdSet.add(oldMap.get(agReport.id).Secondary_QC_Reviewer__c);
                   }
                   if(oldMap.get(agReport.id).Primary_BRM_Analyst__c != null){
                       contactIdSet.add(oldMap.get(agReport.id).Primary_BRM_Analyst__c);
                   }
                   if(oldMap.get(agReport.id).Secondary_BRM_Analyst__c != null){
                       contactIdSet.add(oldMap.get(agReport.id).Secondary_BRM_Analyst__c);
                   }
                   if(oldMap.get(agReport.id).Primary_Medical_Reviewer__c != null){
                       contactIdSet.add(oldMap.get(agReport.id).Primary_Medical_Reviewer__c);
                   }
                   if(oldMap.get(agReport.id).Secondary_Medical_Reviewer__c != null){
                       contactIdSet.add(oldMap.get(agReport.id).Secondary_Medical_Reviewer__c);
                   }
                   if(oldMap.get(agReport.id).Coordinator__c != null){
                       contactIdSet.add(oldMap.get(agReport.id).Coordinator__c);
                   } 
                   if(oldMap.get(agReport.id).Line_Listing_Reviewer__c != null){
                       contactIdSet.add(oldMap.get(agReport.id).Line_Listing_Reviewer__c);
                   } 
                   if(oldMap.get(agReport.id).Line_Listing_QCer__c != null){
                       contactIdSet.add(oldMap.get(agReport.id).Line_Listing_QCer__c);
                   } 
                   if(oldMap.get(agReport.id).Secondary_Author__c != null){
                       contactIdSet.add(oldMap.get(agReport.id).Secondary_Author__c);
                   } 
                   if(oldMap.get(agReport.id).Primary_Author__c != null){
                       contactIdSet.add(oldMap.get(agReport.id).Primary_Author__c);
                   } 
                   if((Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_GSO
               		|| Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(agReport.RecordTypeId).getDeveloperName()  == CON_PSA.AGG_REPORT_REC_TYPE_SANOFI_PVS)
              		 && oldMap.get(agReport.id).IQVIA_Primary_PV_Scientist__c != null){
                   		contactIdSet.add(oldMap.get(agReport.id).IQVIA_Primary_PV_Scientist__c);
                     }
               }  
        }
        contactIdToRecordMap = new Map<Id, Contact>(new SLT_Contact().selectContactBasedOnId(contactIdSet));
        for(Aggregate_Report__c agReport : newList){
            if(agReport.Primary_QC_Reviewer__c != null 
               && oldMap.get(agReport.id).Primary_QC_Reviewer__c != null
               && agReport.Primary_QC_Reviewer__c != oldMap.get(agReport.id).Primary_QC_Reviewer__c 
               && contactIdToRecordMap.containsKey(oldMap.get(agReport.id).Primary_QC_Reviewer__c) 
               && contactIdToRecordMap.get(oldMap.get(agReport.id).Primary_QC_Reviewer__c).Email != null){
                   agReport.Prior_Primary_QC_Reviewer_Email__c = contactIdToRecordMap.get(oldMap.get(agReport.id).Primary_QC_Reviewer__c).Email;
               }
            if(agReport.Secondary_QC_Reviewer__c != null 
               && oldMap.get(agReport.id).Secondary_QC_Reviewer__c != null
               && agReport.Secondary_QC_Reviewer__c != oldMap.get(agReport.id).Secondary_QC_Reviewer__c 
               && contactIdToRecordMap.containsKey(oldMap.get(agReport.id).Secondary_QC_Reviewer__c) 
               && contactIdToRecordMap.get(oldMap.get(agReport.id).Secondary_QC_Reviewer__c).Email != null){
                agReport.Prior_Secondary_QC_Reviewer_Email__c = contactIdToRecordMap.get(oldMap.get(agReport.id).Secondary_QC_Reviewer__c).Email;
            }
            if(agReport.Primary_BRM_Analyst__c != null 
               && oldMap.get(agReport.id).Primary_BRM_Analyst__c != null
               && agReport.Primary_BRM_Analyst__c != oldMap.get(agReport.id).Primary_BRM_Analyst__c 
               && contactIdToRecordMap.containsKey(oldMap.get(agReport.id).Primary_BRM_Analyst__c) 
               && contactIdToRecordMap.get(oldMap.get(agReport.id).Primary_BRM_Analyst__c).Email != null){
                agReport.Prior_Primary_BRM_Analyst_Email__c = contactIdToRecordMap.get(oldMap.get(agReport.id).Primary_BRM_Analyst__c).Email;
            }
            if(agReport.Secondary_BRM_Analyst__c != null 
               && oldMap.get(agReport.id).Secondary_BRM_Analyst__c != null
               && agReport.Secondary_BRM_Analyst__c != oldMap.get(agReport.id).Secondary_BRM_Analyst__c 
               && contactIdToRecordMap.containsKey(oldMap.get(agReport.id).Secondary_BRM_Analyst__c) 
               && contactIdToRecordMap.get(oldMap.get(agReport.id).Secondary_BRM_Analyst__c).Email != null){
                agReport.Prior_Secondary_BRM_Analyst_Email__c = contactIdToRecordMap.get(oldMap.get(agReport.id).Secondary_BRM_Analyst__c).Email;
            }
            if(agReport.Primary_Medical_Reviewer__c != null 
               && oldMap.get(agReport.id).Primary_Medical_Reviewer__c != null
               && agReport.Primary_Medical_Reviewer__c != oldMap.get(agReport.id).Primary_Medical_Reviewer__c 
               && contactIdToRecordMap.containsKey(oldMap.get(agReport.id).Primary_Medical_Reviewer__c) 
               && contactIdToRecordMap.get(oldMap.get(agReport.id).Primary_Medical_Reviewer__c).Email != null){
                agReport.Prior_Primary_Medical_Reviewer_Email__c = contactIdToRecordMap.get(oldMap.get(agReport.id).Primary_Medical_Reviewer__c).Email;
            }
            if(agReport.Secondary_Medical_Reviewer__c != null 
               && oldMap.get(agReport.id).Secondary_Medical_Reviewer__c != null
               && agReport.Secondary_Medical_Reviewer__c != oldMap.get(agReport.id).Secondary_Medical_Reviewer__c 
               && contactIdToRecordMap.containsKey(oldMap.get(agReport.id).Secondary_Medical_Reviewer__c) 
               && contactIdToRecordMap.get(oldMap.get(agReport.id).Secondary_Medical_Reviewer__c).Email != null){
                agReport.Prior_Secondary_Medical_Reviewer_Email__c = contactIdToRecordMap.get(oldMap.get(agReport.id).Secondary_Medical_Reviewer__c).Email;
            }
            if(agReport.Coordinator__c != null 
               && oldMap.get(agReport.id).Coordinator__c != null
               && agReport.Coordinator__c != oldMap.get(agReport.id).Coordinator__c 
               && contactIdToRecordMap.containsKey(oldMap.get(agReport.id).Coordinator__c) 
               && contactIdToRecordMap.get(oldMap.get(agReport.id).Coordinator__c).Email != null){
                agReport.Prior_Coordinator_Email__c = contactIdToRecordMap.get(oldMap.get(agReport.id).Coordinator__c).Email;
            }
            if(agReport.Line_Listing_Reviewer__c != null 
               && oldMap.get(agReport.id).Line_Listing_Reviewer__c != null
               && agReport.Line_Listing_Reviewer__c != oldMap.get(agReport.id).Line_Listing_Reviewer__c 
               && contactIdToRecordMap.containsKey(oldMap.get(agReport.id).Line_Listing_Reviewer__c) 
               && contactIdToRecordMap.get(oldMap.get(agReport.id).Line_Listing_Reviewer__c).Email != null){
                agReport.Prior_Line_Listing_Reviewer_Email__c = contactIdToRecordMap.get(oldMap.get(agReport.id).Line_Listing_Reviewer__c).Email;
            }
            if(agReport.Line_Listing_QCer__c != null 
               && oldMap.get(agReport.id).Line_Listing_QCer__c != null
               && agReport.Line_Listing_QCer__c != oldMap.get(agReport.id).Line_Listing_QCer__c 
               && contactIdToRecordMap.containsKey(oldMap.get(agReport.id).Line_Listing_QCer__c) 
               && contactIdToRecordMap.get(oldMap.get(agReport.id).Line_Listing_QCer__c).Email != null){
                agReport.Prior_Line_Listing_Qcer_Email__c = contactIdToRecordMap.get(oldMap.get(agReport.id).Line_Listing_QCer__c).Email;
            }
            if(agReport.Secondary_Author__c != null 
               && oldMap.get(agReport.id).Secondary_Author__c != null
               && agReport.Secondary_Author__c != oldMap.get(agReport.id).Secondary_Author__c 
               && contactIdToRecordMap.containsKey(oldMap.get(agReport.id).Secondary_Author__c) 
               && contactIdToRecordMap.get(oldMap.get(agReport.id).Secondary_Author__c).Email != null){
                agReport.Prior_Secondary_Author_Email__c = contactIdToRecordMap.get(oldMap.get(agReport.id).Secondary_Author__c).Email;
            }
            if(agReport.Primary_Author__c != null 
               && oldMap.get(agReport.id).Primary_Author__c != null
               && agReport.Primary_Author__c != oldMap.get(agReport.id).Primary_Author__c 
               && contactIdToRecordMap.containsKey(oldMap.get(agReport.id).Primary_Author__c) 
               && contactIdToRecordMap.get(oldMap.get(agReport.id).Primary_Author__c).Email != null){
                agReport.Prior_Author_Email__c = contactIdToRecordMap.get(oldMap.get(agReport.id).Primary_Author__c).Email;
            }
        }
        for(Aggregate_Report__c agReport : newList){
            if(agReport.IQVIA_Primary_PV_Scientist__c != null 
               && oldMap.get(agReport.id).IQVIA_Primary_PV_Scientist__c != null 
               && contactIdToRecordMap.containsKey(oldMap.get(agReport.id).IQVIA_Primary_PV_Scientist__c) ){
                   agReport.Prior_PV_Scientist__c = contactIdToRecordMap.get(oldMap.get(agReport.id).IQVIA_Primary_PV_Scientist__c).psa_report__Resource_Name__c;
               }
        }
    }
    public static void sendMailToPrimaryResource(List<Aggregate_Report__c> newList, Map<Id, Aggregate_Report__c> oldMap){
        String recordTypeName = '';
        String projectCode = '';
        String emailSubject = '';
        String emailBody = '';
        String primaryEmailBody = '';
        String secondaryEmailBody = '';
        Set<Id> reportIdSet = new Set<Id>();
        String eventName ='';
        String moduleName = CON_PSA.PSA_MODULE_NAME;
        String emailAction = CON_PSA.AGG_REPORT_SEND_PRIMARY_RESOURCE;
        String primaryResourceName = '';
        String secondaryResourceName = '';
        String primaryResourceEmail = '';
        String secondaryResourceEmail = '';
        Set<String> resourceEmailSet = new Set<String>();
        Map<String,Project_Event__c> aggregateReportIdToProjectEventMap = new Map<String,Project_Event__c>();
        String whereClause = 'Report__c IN : reportIdSet';
        Set<String> projectEventFieldsSet = new Set<String>{'Id','Report__c','Primary_Resource__r.Name','Primary_Resource__r.Email','Secondary_Resource__r.Email','Secondary_Resource__r.Name'};
        List<Workflow_Email_Record__c> workflowEmailRecList = new List<Workflow_Email_Record__c>();
        for(Aggregate_Report__c ag : newList){
            recordTypeName = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(ag.RecordTypeId).getDeveloperName();
            if(ag.Record_Type__c != null  
               && (ag.Plnnd_Date_for_Medical_Review_Cmpltn__c != null || ag.Planned_Date_for_Medical_Review_Sent__c != null)
               && (recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_GENERAL || recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_TAKEDA || recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE)
               && (ag.Report_Type__c != oldMap.get(ag.Id).Report_Type__c 
                   || ag.Product_Name_Active_Ingredient__c != oldMap.get(ag.Id).Product_Name_Active_Ingredient__c
                   || (ag.Plnnd_Date_for_Medical_Review_Cmpltn__c != oldMap.get(ag.Id).Plnnd_Date_for_Medical_Review_Cmpltn__c && ag.Actual_Date_for_Medical_Review_Cmpltn__c == null)
                   || (ag.Planned_Date_for_Medical_Review_Sent__c != oldMap.get(ag.Id).Planned_Date_for_Medical_Review_Sent__c && ag.Actual_Date_for_Medical_Review_Sent__c == null)))
            {
                reportIdSet.add(ag.Id);
            }
        }
        List<Project_Event__c> projectEventList = new SLT_Project_Event(false, false).getProjectEventsByAggregateReport(reportIdSet, whereClause, projectEventFieldsSet);
        for(Project_Event__c projectEvent : projectEventList){
            aggregateReportIdToProjectEventMap.put(projectEvent.Report__c,projectEvent);
        }
        List<Aggregate_Report__c> aggregateReportList = new SLT_Aggregate_Report(false, false).selectAggregateReportsById(reportIdSet,new Set<String>{'Actual_Date_for_Medical_Review_Sent__c','Actual_Date_for_Medical_Review_Cmpltn__c',
            'Primary_Author__r.Name','Primary_Author__r.Email','Plnnd_Date_for_Medical_Review_Cmpltn__c',
            'Planned_Date_for_Medical_Review_Sent__c','Account_Name__c','Project_Code__c','Name',
            'Product_Name_Active_Ingredient_Name__c','Report_Type__c','Planned_Date_for_Medical_Review_Sent__c',
            'Actual_Date_for_Medical_Review_Cmpltn__c','Service_Milestone__r.Name'});
        for(Aggregate_Report__c agReport : aggregateReportList){
            if((agReport.Plnnd_Date_for_Medical_Review_Cmpltn__c != oldMap.get(agReport.Id).Plnnd_Date_for_Medical_Review_Cmpltn__c 
                && agReport.Planned_Date_for_Medical_Review_Sent__c == oldMap.get(agReport.Id).Planned_Date_for_Medical_Review_Sent__c && agReport.Actual_Date_for_Medical_Review_Cmpltn__c == null)
               || (agReport.Plnnd_Date_for_Medical_Review_Cmpltn__c != null && agReport.Planned_Date_for_Medical_Review_Sent__c == null)){
                   eventName = CON_PSA.AGG_REPORT_PLANNED_DATE_FOR_MEDICAL_REVIEW_COMPLETION;
               }else if((agReport.Planned_Date_for_Medical_Review_Sent__c != oldMap.get(agReport.Id).Planned_Date_for_Medical_Review_Sent__c
                         && agReport.Plnnd_Date_for_Medical_Review_Cmpltn__c == oldMap.get(agReport.Id).Plnnd_Date_for_Medical_Review_Cmpltn__c && agReport.Actual_Date_for_Medical_Review_Sent__c == null)
                        || (agReport.Planned_Date_for_Medical_Review_Sent__c != null && agReport.Plnnd_Date_for_Medical_Review_Cmpltn__c == null))
               {
                   eventName = CON_PSA.AGG_REPORT_PLANNED_DATE_FOR_MEDICAL_REVIEW_SENT;
               }else{
                   eventName = CON_PSA.AGG_REPORT_PLANNED_DATE_FOR_MEDICAL_REVIEW_COMPLETION_AND_PLANNED_DATE_FOR_MEDICAL_REVIEW_SENT;
               } 
            if(agReport.Project_Code__c != null){
                projectCode =  agReport.Project_Code__c;
            }
            if(aggregateReportIdToProjectEventMap.containsKey(agReport.Id) && aggregateReportIdToProjectEventMap.get(agReport.Id) != null){
                if(aggregateReportIdToProjectEventMap.get(agReport.Id).Primary_Resource__r.Name != null){
                    primaryResourceName = aggregateReportIdToProjectEventMap.get(agReport.Id).Primary_Resource__r.Name;
                }
                if(aggregateReportIdToProjectEventMap.get(agReport.Id).Primary_Resource__r.Email != null)
                {
                    primaryResourceEmail = aggregateReportIdToProjectEventMap.get(agReport.Id).Primary_Resource__r.Email;
                }
                if(aggregateReportIdToProjectEventMap.get(agReport.Id).Secondary_Resource__r.Name != null){
                    secondaryResourceName = aggregateReportIdToProjectEventMap.get(agReport.Id).Secondary_Resource__r.Name;
                }
                if(aggregateReportIdToProjectEventMap.get(agReport.Id).Secondary_Resource__r.Email != null){
                    secondaryResourceEmail = aggregateReportIdToProjectEventMap.get(agReport.Id).Secondary_Resource__r.Email;
                }
            }
            
            emailSubject= 'EVENT CHANGE ALERT:'+agReport.Account_Name__c+'-'+projectCode+'-'+agReport.Name+'-'+eventName;
            primaryEmailBody = 'Dear '+primaryResourceName+', <br><br>';
            secondaryEmailBody = 'Dear '+secondaryResourceName+', <br><br>';
            emailBody += '<b>Client: </b>'+agReport.Account_Name__c+'<br>';
            emailBody += '<b>Project Code:</b> '+projectCode+'<br>';
            emailBody += '<b>Report:</b> '+agReport.Name+'<br>';
            emailBody += '<b>Service MileStone:</b> '+agReport.Service_Milestone__r.Name+'<br>';
            emailBody += '<b>Event Name:</b> '+eventName+'<br>';
            if(agReport.Plnnd_Date_for_Medical_Review_Cmpltn__c != oldMap.get(agReport.Id).Plnnd_Date_for_Medical_Review_Cmpltn__c && agReport.Actual_Date_for_Medical_Review_Cmpltn__c == null){
                emailBody += '<b>Old Due Date of Planned Date for Medical Review Completion: </b> '+oldMap.get(agReport.Id).Plnnd_Date_for_Medical_Review_Cmpltn__c+'<br>'; 
                emailBody += '<b>New Due Date of Planned Date for Medical Review Completion: </b> '+agReport.Plnnd_Date_for_Medical_Review_Cmpltn__c+'<br>'; 
            }
            if(agReport.Planned_Date_for_Medical_Review_Sent__c != oldMap.get(agReport.Id).Planned_Date_for_Medical_Review_Sent__c && agReport.Actual_Date_for_Medical_Review_Sent__c == null){
                emailBody += '<b>Old Due Date of Planned Date for Medical Review Sent: </b> '+oldMap.get(agReport.Id).Planned_Date_for_Medical_Review_Sent__c+'<br>'; 
                emailBody += '<b>New Due Date of Planned Date for Medical Review Sent: </b> '+agReport.Planned_Date_for_Medical_Review_Sent__c+'<br>'; 
            }
            if(agReport.Product_Name_Active_Ingredient_Name__c != oldMap.get(agReport.Id).Product_Name_Active_Ingredient_Name__c){
                emailBody += '<b>Product :Old</b> : '+oldMap.get(agReport.Id).Product_Name_Active_Ingredient_Name__c+'  <b>New: </b>'+agReport.Product_Name_Active_Ingredient_Name__c +'<br>';
            }
            if(agReport.Report_Type__c != oldMap.get(agReport.Id).Report_Type__c){
                emailBody += '<b>Report Type: Old</b> : '+oldMap.get(agReport.Id).Report_Type__c +' <b>New: </b>'+agReport.Report_Type__c+'<br><br>';
            }
            emailBody += 'Thank you.';
            if(primaryResourceEmail != '' && !resourceEmailSet.contains(primaryResourceEmail)){
                resourceEmailSet.add(primaryResourceEmail);
                workflowEmailRecList.add(new Workflow_Email_Record__c(Email_Action__c = emailAction, Module_Name__c = moduleName, To_Email_1__c = primaryResourceEmail, Email_Subject__c = emailSubject, content_1__c = primaryEmailBody+emailBody));  
            }
            if(secondaryResourceEmail != '' && !resourceEmailSet.contains(secondaryResourceEmail)){
                resourceEmailSet.add(secondaryResourceEmail);
                workflowEmailRecList.add(new Workflow_Email_Record__c(Email_Action__c = emailAction, Module_Name__c = moduleName, To_Email_1__c = secondaryResourceEmail, Email_Subject__c = emailSubject, content_1__c = secondaryEmailBody+emailBody)); 
            }
        }
        if(workflowEmailRecList.size() > 0){
            insert workflowEmailRecList;
        }
    } 

    public static void sandozRecordTypeFieldValidations(List<Aggregate_Report__c> newList,Map<Id, Aggregate_Report__c> oldMap){    
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        String recordTypeName;
        String naField;
        List<String> sectionList = new List<String> ();
        Map<String, String> dateFieldtoNAField;
        for(Aggregate_Report__c aggRepRec : newList){
            recordTypeName = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(aggRepRec.RecordTypeId).getDeveloperName();
            for (String sectionRec: dateFieldtoNAFieldMaps.keySet()) {
                if(!mulesoftSetting.Ignore_Validation_Rules__c && sectionRec.contains(recordTypeName)){
                    sectionList.add(sectionRec); //for section-wise validations.
                    if(aggRepRec.Status__c == CON_PSA.AGG_REPORT_Status_Completed && recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_SANDOZ
                    	&& (aggRepRec.Report_Due_to_IQVIA_or_Client_Reg__c == null || aggRepRec.Date_Submitted_to_IQVIA_or_Client_Reg__c == null
                        || aggRepRec.Report_Due_to_Reg_Agency__c == null)){
                        	aggRepRec.addError('The report status is set to Completed therefore the following fields cannot be empty: Report Due to IQVIA or Client Reg, Date Submitted to IQVIA or Client Reg, Report Due to Reg Agency');
                    }
                }
            }
        }
        for(Aggregate_Report__c aggRepRec : newList){
            for(String str: sectionList){
                dateFieldtoNAField = dateFieldtoNAFieldMaps.get(str);
                for (String dateField: dateFieldtoNAField.keySet()){
                    naField = dateFieldtoNAField.get(dateField);
                    // sandoz report meeting section validations.
                    if(aggRepRec != null && aggRepRec.Status__c != null && aggRepRec.Status__c == CON_PSA.AGG_REPORT_Status_Completed){
                        if(str.contains(CON_PSA.AGG_REPORT_SECTION_MEETINGS) && (aggRepRec.get(dateField) == null && (aggRepRec.get(naField) == null || aggRepRec.get(naField) == CON_PSA.AGG_REPORT_NA_FIELD_VALUE_EQUALS_NO))){
                            aggRepRec.addError('Please fill in "' + getLabel(dateField) + '" or set "' + getLabel(naField) + '" to "Yes".');
                        }else if(str.contains(CON_PSA.AGG_REPORT_SECTION_MEETINGS) && aggRepRec.get(dateField) != null && aggRepRec.get(naField) == CON_PSA.AGG_REPORT_NA_FIELD_VALUE_EQUALS_YES){
                            aggRepRec.addError('Please fill in "' + getLabel(dateField) + '" or set "' + getLabel(naField) + '" to "Yes".');
                        }
                    }
                    // sandoz report QC section validations.
                    if(aggRepRec != null && aggRepRec.Status__c != null && aggRepRec.Status__c == CON_PSA.AGG_REPORT_Status_Completed){
                        if(str.contains(CON_PSA.AGG_REPORT_SECTION_QC) && (aggRepRec.get(dateField) == null && (aggRepRec.get(naField) == null || aggRepRec.get(naField) == CON_PSA.AGG_REPORT_NA_FIELD_VALUE_EQUALS_NO))){
                            aggRepRec.addError('Please fill in "' + getLabel(dateField) + '" or set "' + getLabel(naField) + '" to "Yes".');
                        }else if(str.contains(CON_PSA.AGG_REPORT_SECTION_QC) && aggRepRec.get(dateField) != null && aggRepRec.get(naField) == CON_PSA.AGG_REPORT_NA_FIELD_VALUE_EQUALS_YES){
                            aggRepRec.addError('Please fill in "' + getLabel(dateField) + '" or set "' + getLabel(naField) + '" to "Yes".');
                        }
                    }
                    // sandoz report BRM section validations.
                    if(aggRepRec != null && aggRepRec.Status__c != null && aggRepRec.Status__c == CON_PSA.AGG_REPORT_Status_Completed){
                        if(aggRepRec.BRM_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_IQVIA 
                           && aggRepRec.Primary_BRM_Analyst__c == null){
                               aggRepRec.addError('Resource must be assigned to "Primary BRM Analyst" when "BRM Review Requirement" is set to "IQVIA".');
                           }else if(str.contains(CON_PSA.AGG_REPORT_SECTION_BRM)  
                           			&& (aggRepRec.BRM_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_IQVIA
                           				|| aggRepRec.BRM_Review_Requirement__c == null) && (aggRepRec.get(dateField) == null 
                               		&& (aggRepRec.get(naField) == null || aggRepRec.get(naField) == CON_PSA.AGG_REPORT_NA_FIELD_VALUE_EQUALS_NO))){
                                   		 aggRepRec.addError('Please fill in "' + getLabel(dateField) + '" or set "' + getLabel(naField) + '" to "Yes".');
                           }else if(str.contains(CON_PSA.AGG_REPORT_SECTION_BRM) 
                                    && (aggRepRec.BRM_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_IQVIA 
                           				|| aggRepRec.BRM_Review_Requirement__c == null)
                                    && aggRepRec.get(dateField) != null && aggRepRec.get(naField) == CON_PSA.AGG_REPORT_NA_FIELD_VALUE_EQUALS_YES){
                                        aggRepRec.addError('Please fill in "' + getLabel(dateField) + '" or set "' + getLabel(naField) + '" to "Yes".');
                          }
                    }     
                    if(aggRepRec != null && str.contains(CON_PSA.AGG_REPORT_SECTION_BRM) 
                       && aggRepRec.BRM_Review_Requirement__c == 'NA' 
                       && (aggRepRec.get(dateField) != null || aggRepRec.get(naField) != null 
                           || aggRepRec.Primary_BRM_Analyst__c != null || aggRepRec.Secondary_BRM_Analyst__c != null 
                           || aggRepRec.BRM_Late_Responsibility__c != null || aggRepRec.BRM_Late_Reason_Text__c != null 
                           || aggRepRec.BRM_Late_Reason__c != null)){
                               aggRepRec.addError('You have chosen NA in BRM Review Requirement, you cannot enter values in other fields in this section.');
                     }else if(aggRepRec != null && str.contains(CON_PSA.AGG_REPORT_SECTION_BRM) 
                              && aggRepRec.BRM_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_Client 
                              && (aggRepRec.get(dateField) != null || aggRepRec.get(naField) != null 
                                  || aggRepRec.Primary_BRM_Analyst__c != null || aggRepRec.Secondary_BRM_Analyst__c != null 
                                  || aggRepRec.BRM_Late_Responsibility__c != null || aggRepRec.BRM_Late_Reason_Text__c != null 
                                  || aggRepRec.BRM_Late_Reason__c != null)){
                                      aggRepRec.addError('You have chosen Client in BRM Review Requirement, you cannot enter values in other fields in this section.');
                     }
                    // sandoz report Medical Review section validations.
                    if(aggRepRec != null && aggRepRec.Status__c != null && aggRepRec.Status__c == CON_PSA.AGG_REPORT_Status_Completed){
                        if(aggRepRec.Medical_Reviewer_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_IQVIA 
                           && aggRepRec.Primary_Medical_Reviewer__c == null){
                               aggRepRec.addError('Resource must be assigned to "Primary Medical Reviewer" when "Medical Reviewer Review Requirement" is set to "IQVIA".');
                           }else if(str.contains(CON_PSA.AGG_REPORT_SECTION_MED_REVIEW) 
                                     && (aggRepRec.Medical_Reviewer_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_IQVIA
                                     	|| aggRepRec.Medical_Reviewer_Review_Requirement__c == null)
                                     && (aggRepRec.get(dateField) == null 
                                         && (aggRepRec.get(naField) == null || aggRepRec.get(naField) == CON_PSA.AGG_REPORT_NA_FIELD_VALUE_EQUALS_NO))){
                                            aggRepRec.addError('Please fill in "' + getLabel(dateField) + '" or set "' + getLabel(naField) + '" to "Yes".');
                            }else if(str.contains(CON_PSA.AGG_REPORT_SECTION_MED_REVIEW) 
                                      && (aggRepRec.Medical_Reviewer_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_IQVIA 
                                      	 || aggRepRec.Medical_Reviewer_Review_Requirement__c == null)
                                      && aggRepRec.get(dateField) != null && aggRepRec.get(naField) == CON_PSA.AGG_REPORT_NA_FIELD_VALUE_EQUALS_YES){
                                          aggRepRec.addError('Please fill in "' + getLabel(dateField) + '" or set "' + getLabel(naField) + '" to "Yes".');
                            }
                    }
                    if(aggRepRec != null && str.contains(CON_PSA.AGG_REPORT_SECTION_MED_REVIEW) 
                       && aggRepRec.Medical_Reviewer_Review_Requirement__c == 'NA' 
                       && (aggRepRec.get(dateField) != null || aggRepRec.get(naField) != null 
                           || aggRepRec.Primary_Medical_Reviewer__c != null || aggRepRec.Secondary_Medical_Reviewer__c != null 
                           || aggRepRec.Medical_Review_Late_Responsibility__c != null || aggRepRec.Medical_Review_Late_Reason_Text__c != null 
                           || aggRepRec.Medical_Review_Late_Reason__c != null)){
                               aggRepRec.addError('You have chosen NA in Medical Review Requirement, you cannot enter values in other fields in this section.');
                     }else if(aggRepRec != null && str.contains(CON_PSA.AGG_REPORT_SECTION_MED_REVIEW) 
                              && aggRepRec.Medical_Reviewer_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_Client 
                              && (aggRepRec.get(dateField) != null || aggRepRec.get(naField) != null 
                                  || aggRepRec.Primary_Medical_Reviewer__c != null || aggRepRec.Secondary_Medical_Reviewer__c != null 
                                  || aggRepRec.Medical_Review_Late_Responsibility__c != null || aggRepRec.Medical_Review_Late_Reason_Text__c != null 
                                  || aggRepRec.Medical_Review_Late_Reason__c != null)){
                                       aggRepRec.addError('You have chosen Client in Medical Review Requirement, you cannot enter values in other fields in this section.');
                    }
                    // sandoz report Line Listing section validations.
                    if(aggRepRec != null && aggRepRec.Status__c != null && aggRepRec.Status__c == CON_PSA.AGG_REPORT_Status_Completed){
                        if(str.contains(CON_PSA.AGG_REPORT_SECTION_LL) 
                        	&& (aggRepRec.Line_Listing_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_IQVIA 
                           		|| aggRepRec.Line_Listing_Review_Requirement__c == null)
                            && (aggRepRec.get(dateField) == null 
                            && (aggRepRec.get(naField) == null || aggRepRec.get(naField) == CON_PSA.AGG_REPORT_NA_FIELD_VALUE_EQUALS_NO))){
                                aggRepRec.addError('Please fill in "' + getLabel(dateField) + '" or set "' + getLabel(naField) + '" to "Yes".');
                         }else if(str.contains(CON_PSA.AGG_REPORT_SECTION_LL) && aggRepRec.Status__c == CON_PSA.AGG_REPORT_Status_Completed
                               		&& (aggRepRec.Line_Listing_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_IQVIA 
                           				|| aggRepRec.Line_Listing_Review_Requirement__c == null)
                                    && aggRepRec.get(dateField) != null && aggRepRec.get(naField) == CON_PSA.AGG_REPORT_NA_FIELD_VALUE_EQUALS_YES){
                                    	aggRepRec.addError('Please fill in "' + getLabel(dateField) + '" or set "' + getLabel(naField) + '" to "Yes".');
                        }
                    }
                    if(aggRepRec != null && str.contains(CON_PSA.AGG_REPORT_SECTION_LL) 
                    	&& aggRepRec.Line_Listing_Review_Requirement__c == 'NA' 
                        && (aggRepRec.get(dateField) != null || aggRepRec.get(naField) != null 
                        	|| aggRepRec.Line_Listing_Reviewer__c != null || aggRepRec.Line_Listing_QCer__c != null)){
                            	aggRepRec.addError('You have chosen NA in Line Listing Review Requirement, you cannot enter values in other fields in this section.');
                     }else if(aggRepRec != null && str.contains(CON_PSA.AGG_REPORT_SECTION_LL) 
                           		&& aggRepRec.Line_Listing_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_Client 
                                && (aggRepRec.get(dateField) != null || aggRepRec.get(naField) != null 
                                    || aggRepRec.Line_Listing_Reviewer__c != null || aggRepRec.Line_Listing_QCer__c != null)){
                                        aggRepRec.addError('You have chosen Client in Line Listing Review Requirement, you cannot enter values in other fields in this section.');
                    }
                    // sandoz report Coordinator section validations.
                    if(aggRepRec != null && aggRepRec.Status__c == CON_PSA.AGG_REPORT_Status_Completed
                        && aggRepRec.Coordinator_NA__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_IQVIA 
                        && aggRepRec.Coordinator__c == null){
                            aggRepRec.addError('Resource must be assigned to "Coordinator" when "Coordinator NA" is set to "IQVIA".');
                    }else if(aggRepRec != null && aggRepRec.Status__c == CON_PSA.AGG_REPORT_Status_Completed
                        && (aggRepRec.Coordinator_NA__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_Client
                            || aggRepRec.Coordinator_NA__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_NA)&& aggRepRec.Coordinator__c != null){
                            	aggRepRec.addError('Resource must not be assigned to "Coordinator" when "Coordinator NA" is set to "NA" or "Client".');
                    }
                }
            }
        }
    }
    
    public static void sendMailForMedicalReviewDateChange(List<Aggregate_Report__c> newList, Map<Id, Aggregate_Report__c> oldMap){
        String recordTypeName = '';
        String emailSubject = '';
        String emailBody = '';
        Set<Id> reportIdSet = new Set<Id>();
        String moduleName = CON_PSA.PSA_MODULE_NAME;
        String emailAction = CON_PSA.AGG_REPORT_SEND_PRIMARY_RESOURCE;
        String primaryResourceEmail = '';
        String secondaryResourceEmail = '';
        Set<String> mRSentResourceEmailSet = new Set<String>();
        Set<String> mRCompletionResourceEmailSet = new Set<String>();
        List<Workflow_Email_Record__c> workflowEmailRecList = new List<Workflow_Email_Record__c>();
        
        for(Aggregate_Report__c ag : newList){
            recordTypeName = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(ag.RecordTypeId).getDeveloperName();
            if(ag.Record_Type__c != null
               && recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_SANDOZ
               && (ag.Planned_Date_for_Medical_Review_Sent__c != oldMap.get(ag.Id).Planned_Date_for_Medical_Review_Sent__c || ag.Plnnd_Date_for_Medical_Review_Cmpltn__c != oldMap.get(ag.Id).Plnnd_Date_for_Medical_Review_Cmpltn__c))
            {
                reportIdSet.add(ag.Id);
            }
        }        
        List<Aggregate_Report__c> aggregateReportList = new SLT_Aggregate_Report(true, true).selectAggregateReportsById(reportIdSet,new Set<String>{'Primary_Medical_Reviewer__c','Record_Type__c',
            'Secondary_Medical_Reviewer__c','Primary_Medical_Reviewer__r.Email','Secondary_Medical_Reviewer__r.Email',
            'Plnnd_Date_for_Medical_Review_Cmpltn__c','Planned_Date_for_Medical_Review_Sent__c','Project_Code__c','Name',
            'Report_Type__c','Account__c','Account__r.Name','Product_Name_Active_Ingredient_Name__c','Service_Milestone__r.Name'});
        for(Aggregate_Report__c agReport : aggregateReportList){
            primaryResourceEmail = '';
            secondaryResourceEmail = '';
            mRSentResourceEmailSet.clear();
            mRCompletionResourceEmailSet.clear();
            emailSubject = '';
            emailBody = '';
            if(agReport.Planned_Date_for_Medical_Review_Sent__c != oldMap.get(agReport.Id).Planned_Date_for_Medical_Review_Sent__c){   
                if(agReport.Primary_Medical_Reviewer__c != null && agReport.Primary_Medical_Reviewer__r.Email != null){
                    primaryResourceEmail = agReport.Primary_Medical_Reviewer__r.Email;
                }
                if(agReport.Secondary_Medical_Reviewer__c != null && agReport.Secondary_Medical_Reviewer__r.Email != null){
                    secondaryResourceEmail = agReport.Secondary_Medical_Reviewer__r.Email;
                }
                emailSubject= 'Change in Planned Date for Medical Review Sent';
                emailBody += '<div style="font-size:12pt;font-family:arial">';
                emailBody += 'Planned Date for Medical Review Sent is updated on the following Aggregate Report:'+'<br><br>';
                emailBody += '<b>Aggregate Report Number: </b>';
                emailBody += '<a href = ' + URL.getOrgDomainUrl().toExternalForm()+'/'+agReport.Id+ '><B>'+ agReport.Name +'</B></a><br>';
                emailBody += '<b>Product Name(Active Ingredient) :</b> '+(agReport.Product_Name_Active_Ingredient_Name__c != null ? (agReport.Product_Name_Active_Ingredient_Name__c):(''))+'<br>';
                emailBody += '<b>Report Type :</b> '+(agReport.Record_Type__c != null ? (agReport.Record_Type__c):(''))+'<br>';
                emailBody += '<b>Service milestone :</b> '+(agReport.Service_Milestone__r.Name != null ? (agReport.Service_Milestone__r.Name):(''))+'<br>';
                emailBody += '<b>Account :</b> '+(agReport.Account__r.Name != null ? (agReport.Account__r.Name):(''))+'<br>';
                emailBody += '<b>Planned Date for Medical Review Sent :</b> '+(agReport.Planned_Date_for_Medical_Review_Sent__c != null ? (agReport.Planned_Date_for_Medical_Review_Sent__c.format()): (''))+'<br><br>';
                emailBody += 'Please contact your line manager if you have any questions.'+'<br>';
                emailBody += 'Thank you';
                emailBody += '</div>';
                
                if(primaryResourceEmail != '' && !mRSentResourceEmailSet.contains(primaryResourceEmail)){
                    mRSentResourceEmailSet.add(primaryResourceEmail);
                    workflowEmailRecList.add(new Workflow_Email_Record__c(Email_Action__c = emailAction, Module_Name__c = moduleName, To_Email_1__c = primaryResourceEmail, Email_Subject__c = emailSubject, content_1__c = emailBody));  
                }
                if(secondaryResourceEmail != '' && !mRSentResourceEmailSet.contains(secondaryResourceEmail)){
                    mRSentResourceEmailSet.add(secondaryResourceEmail);
                    workflowEmailRecList.add(new Workflow_Email_Record__c(Email_Action__c = emailAction, Module_Name__c = moduleName, To_Email_1__c = secondaryResourceEmail, Email_Subject__c = emailSubject, content_1__c = emailBody)); 
                }
            }
            emailBody = '';
            if(agReport.Plnnd_Date_for_Medical_Review_Cmpltn__c != oldMap.get(agReport.Id).Plnnd_Date_for_Medical_Review_Cmpltn__c){   
                if(agReport.Primary_Medical_Reviewer__c != null && agReport.Primary_Medical_Reviewer__r.Email != null){
                    primaryResourceEmail = agReport.Primary_Medical_Reviewer__r.Email;
                }
                if(agReport.Secondary_Medical_Reviewer__c != null && agReport.Secondary_Medical_Reviewer__r.Email != null){
                    secondaryResourceEmail = agReport.Secondary_Medical_Reviewer__r.Email;
                }
                emailSubject= 'Change in Planned Date for Medical Review Completion';
                emailBody += '<div style="font-size:12pt;font-family:arial">';
                emailBody += 'Planned Date for Medical Review Completion is updated on the following Aggregate Report:'+'<br><br>';
                emailBody += '<b>Aggregate Report Number: </b>';
                emailBody += '<a href = ' + URL.getOrgDomainUrl().toExternalForm()+'/'+agReport.Id+ '><B>'+ agReport.Name +'</B></a><br>';
                emailBody += '<b>Product Name(Active Ingredient) :</b> '+(agReport.Product_Name_Active_Ingredient_Name__c != null ? (agReport.Product_Name_Active_Ingredient_Name__c):(''))+'<br>';
                emailBody += '<b>Report Type :</b> '+(agReport.Record_Type__c != null ? (agReport.Record_Type__c):(''))+'<br>';
                emailBody += '<b>Service milestone :</b> '+(agReport.Service_Milestone__r.Name != null ? (agReport.Service_Milestone__r.Name):(''))+'<br>';
                emailBody += '<b>Account:</b> '+(agReport.Account__r.Name != null ? (agReport.Account__r.Name):(''))+'<br>';
                emailBody += '<b>Planned Date for Medical Review Completion:</b> '+(agReport.Plnnd_Date_for_Medical_Review_Cmpltn__c != null ? (agReport.Plnnd_Date_for_Medical_Review_Cmpltn__c.format()): (''))+'<br><br>';
                emailBody += 'Please contact your line manager if you have any questions.'+'<br>';
                emailBody += 'Thank you';
                emailBody += '</div>';
                
                if(primaryResourceEmail != '' && !mRCompletionResourceEmailSet.contains(primaryResourceEmail)){
                    mRCompletionResourceEmailSet.add(primaryResourceEmail);
                    workflowEmailRecList.add(new Workflow_Email_Record__c(Email_Action__c = emailAction, Module_Name__c = moduleName, To_Email_1__c = primaryResourceEmail, Email_Subject__c = emailSubject, content_1__c = emailBody));  
                }
                if(secondaryResourceEmail != '' && !mRCompletionResourceEmailSet.contains(secondaryResourceEmail)){
                    mRCompletionResourceEmailSet.add(secondaryResourceEmail);
                    workflowEmailRecList.add(new Workflow_Email_Record__c(Email_Action__c = emailAction, Module_Name__c = moduleName, To_Email_1__c = secondaryResourceEmail, Email_Subject__c = emailSubject, content_1__c = emailBody)); 
                }
            }
        }
        if(workflowEmailRecList.size() > 0){
            insert workflowEmailRecList;
        }
    }
    public static void setDefaultValueFromReportType(List<Aggregate_Report__c> newList, Map<Id, Aggregate_Report__c> oldMap){
       	Set<String> lineListingFieldsSet = new Set<String>{
            'Actual_Date_Final_LL_Requested_NA__c',
            'Planned_Date_to_Request_Final_LL_NA__c',
            'Actual_Date_Final_LL_to_Author_Client_N__c',
            'Plnnd_Date_Final_LL_to_Author_ClientNA__c',
            'Final_Listings_Ticket_Number_NA__c',
            'Actual_Dt_Draft_LL_to_Author_ClientNA__c',
            'Plnnd_Dt_Draft_LL_to_Author_Client_NA__c',
            'Draft_LL_Request_Ticket_Number_NA__c',
            'Actual_Date_to_Request_Draft_LL_NA__c',
            'Planned_Date_to_Request_Draft_LL_NA__c',
            'LL_QC_Completion_Date_NA__c',
            'LL_QC_Due_Date_NA__c',
            'LL_Review_Completion_Date_NA__c',
            'LL_Review_Due_Date_NA__c'
        };
        Set<String> medicalReviewerFieldsSet = new Set<String>{
            'Planned_Date_for_Medical_Review_Sent_NA__c',
			'Actual_Date_for_Medical_Review_Sent_NA__c',
			'Plnnd_Date_for_Medical_Review_Cmpltn_NA__c',   
            'Actual_Date_for_Medical_Review_Cmpltn_NA__c'
        };
        Set<String> brmFieldsSet = new Set<String>{
            'Planned_Date_for_BRM_Sent_NA__c',
            'Actual_Date_for_BRM_Sent_NA__c',
            'Planned_Date_for_BRM_Completion_NA__c',
            'Actual_Date_for_BRM_Completion_NA__c'
        };
        Set<String> coordinatorFieldsSet = new Set<String>{
            'Upload_to_eTMF_Wingspan_Client_Spec_Repo__c',
            'Formatting_Request__c',
            'eTMF_Wingspan_Client_Spec_Repo_File_Stat__c'
        };
        Set<String> othersFieldsSet = new Set<String>{
            'PreStrategy_Planned_Date_NA__c','Strategy_Planning_Mtg_Planned_Date_NA__c','Pre_draft_QC_Review_Planned_date_NA__c',
            'Pre_draft_QC_due_date_NA__c','Pre_draft_Client_Review_Planned_date_NA__c','Pre_draft_Client_Review_due_date_NA__c',
            'Planned_Date_for_QC_Sent_NA__c',
            'Planned_Date_for_QC_Completion_NA__c','Client_First_Draft_Due_NA__c',
            'Planned_First_Draft_Comments_Due_NA__c','First_RTR_Planned_Date_NA__c','Client_Final_Draft_Due_NA__c',
            'Planned_Final_Draft_Comments_Due_NA__c','Second_RTR_Planned_Date_NA__c','Independent_QC_Planned_date_NA__c',
            'Independent_QC_due_date_NA__c','EU_QPPV_designee_review_Planned_date_NA__c','EU_QPPV_designee_review_due_date_NA__c',
            'IQVIA_Planned_Date_for_Sign_Approval_NA__c','Report_Due_to_Reg_Agency_NA__c',
            'PreStrategy_Actual_Date_NA__c','Strategy_Planning_Mtg_Actual_Date_NA__c',
            'Pre_draft_for_QC_sent_NA__c','Pre_draft_QC_Completion_Date_NA__c','Pre_draft_Client_Review_Actual_date_NA__c',
            'Pre_draft_Client_Review_sent_date_NA__c',
            'Actual_Date_for_QC_Sent_NA__c','Actual_Date_for_QC_Completion_NA__c',
            'Client_First_Draft_Sent_NA__c','Actual_First_Draft_Comments_Due_NA__c',
            'First_RTR_Actual_Date_NA__c','Client_Final_Draft_Sent_NA__c','Actual_Final_Draft_Comments_Due_NA__c',
            'Second_RTR_Actual_Date_NA__c','Independent_QC_sent_NA__c','Independent_QC_completion_date_NA__c',
            'EU_QPPV_designee_review_sent_NA__c','EU_QPPV_designee_review_completion_NA__c','Date_signatures_Approval_obtained_NA__c',
            'Report_Submitted_to_Reg_Agency_NA__c'};
        Set<String> defaultValueSetReportTypeSet = new Set<String>{
            'PAER', 'Medical safety evaluation of Annual product quality reports', 'Argus listings / tabulations',
            'PSUR Addendum', 'PADER Annual','PADER Quarterly', 'ACO', 'PBRER', 'simplified PADER',
            'Vet PDER', '6 mo LL', 'Ad-hoc','Partner Questionnaire/Report','RA Response','DSUR','PADER',
            'LOC Query Response','Declaration no RMP','License partner RMP Review','Local RMP Update',
            'New Local RMP','RMM Line-listing','RMP Update','RMP',
            'Targeted follow up questionnaire', 'Expert statement', 'Annual Simplified PADERs', 'IND', 'PSUR', 'BR Assessment', 'RA Response'};        
        List<String> reportTypeSet = new List<String>();
        List<String> recordTypeSet = new List<String>();
        List<Aggregate_Report__c> aggregateReportList = new List<Aggregate_Report__c>();
        List<PSA_Default_Value_Set_Setting__c> defaultValueSetList = new List<PSA_Default_Value_Set_Setting__c>();
        for(Aggregate_Report__c ar :newList){
            if(ar.Report_Type__c != null
               && defaultValueSetReportTypeSet.contains(ar.Report_Type__c)
               && ((Trigger.isInsert && ar.Status__c !=  CON_PSA.AGG_REPORT_Status_Completed)
                   || (Trigger.isUpdate && ar.Report_Type__c != oldMap.get(ar.Id).Report_Type__c))
              ){
                  reportTypeSet.add(ar.Report_Type__c);
                  aggregateReportList.add(ar);
                  recordTypeSet.add(ar.Record_Type__c);
              }
        }
        if(!reportTypeSet.isEmpty()){
            for(PSA_Default_Value_Set_Setting__c customSetting : [SELECT Id, Actual_Date_Field__c, Actual_Date_Field_Value__c, Planned_Date_Field__c,
                                                                  Planned_Date_Field_Value__c, Record_Type__c, Report_Type__c
                                                                  FROM PSA_Default_Value_Set_Setting__c
                                                                  WHERE Report_Type__c IN :reportTypeSet
                                                                  AND Record_Type__c IN :recordTypeSet
                                                                  AND Actual_Date_Field__c != null 
                                                                  AND Planned_Date_Field__c != null
                                                                 ])
            {
                defaultValueSetList.add(customSetting);
            }
            if(!defaultValueSetList.isEmpty()){
                for(Aggregate_Report__c ar :aggregateReportList){
                    if(reportTypeSet.contains(ar.Report_Type__c) && recordTypeSet.contains(ar.Record_Type__c)){
                        for(PSA_Default_Value_Set_Setting__c customSetting : defaultValueSetList){
                            
                            if(customSetting.Actual_Date_Field__c != null 
                               && ((lineListingFieldsSet.contains(customSetting.Actual_Date_Field__c) && ar.Line_Listing_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_IQVIA)
                                   || (medicalReviewerFieldsSet.contains(customSetting.Actual_Date_Field__c) && ar.Medical_Reviewer_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_IQVIA)
                                   || (brmFieldsSet.contains(customSetting.Actual_Date_Field__c) && ar.BRM_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_IQVIA)
                                   || (coordinatorFieldsSet.contains(customSetting.Actual_Date_Field__c) && ar.Coordinator_NA__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_IQVIA)
                                   || (othersFieldsSet.contains(customSetting.Actual_Date_Field__c))
                                  )){
                                ar.put(customSetting.Actual_Date_Field__c, customSetting.Actual_Date_Field_Value__c); 
                            }
                            if(customSetting.Planned_Date_Field__c != null
                               && ((lineListingFieldsSet.contains(customSetting.Planned_Date_Field__c) && ar.Line_Listing_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_IQVIA)
                                   || (medicalReviewerFieldsSet.contains(customSetting.Planned_Date_Field__c) && ar.Medical_Reviewer_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_IQVIA)
                                   || (brmFieldsSet.contains(customSetting.Planned_Date_Field__c) && ar.BRM_Review_Requirement__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_IQVIA)
                                   || (coordinatorFieldsSet.contains(customSetting.Planned_Date_Field__c) && ar.Coordinator_NA__c == CON_PSA.AGG_REPORT_SECTION_REQUIRED_EQUALS_IQVIA)
                                   || (othersFieldsSet.contains(customSetting.Actual_Date_Field__c))
                                  )){
                                ar.put(customSetting.Planned_Date_Field__c, customSetting.Planned_Date_Field_Value__c);
                            }
                        }
                    } 
                }
            }
        }
    }
    public static void completeStatusValidationForSandoz(List<Aggregate_Report__c> newList, Map<Id, Aggregate_Report__c> oldMap){
        String recordTypeName = '';
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        Set<String> defaultValueSetReportTypeSetForSandoz = new Set<String>{
            'PAER', 'Medical safety evaluation of Annual product quality reports', 'Argus listings / tabulations',
            'PSUR Addendum', 'PADER Annual','PADER Quarterly', 'ACO', 'PBRER', 'simplified PADER',
            'Vet PDER', '6 mo LL', 'Ad-hoc','Partner Questionnaire/Report','RA Response','DSUR','PADER',
            'LOC Query Response','Declaration no RMP','License partner RMP Review','Local RMP Update',
            'New Local RMP','RMM Line-listing','RMP Update','RMP',
            'Targeted follow up questionnaire', 'Expert statement', 'Annual Simplified PADERs', 'IND', 'PSUR', 'BR Assessment'};  
        for(Aggregate_Report__c ar : newList){
            recordTypeName = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(ar.RecordTypeId).getDeveloperName();
            if(!mulesoftSetting.Ignore_Validation_Rules__c 
               && recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_SANDOZ
               && ar.Status__c ==  CON_PSA.AGG_REPORT_Status_Completed
               && defaultValueSetReportTypeSetForSandoz.contains(ar.Report_Type__c))
            {
                if(Trigger.isUpdate 
                   && ar.Report_Type__c != oldMap.get(ar.Id).Report_Type__c){
                       ar.addError('Report type can not be changed in case of completed status for Sandoz Report.'); 
                   }
                if(Trigger.isInsert){
                    ar.addError('Save the record other than completed status for Sandoz Report.');
                }
            }
        }
        Set<String> defaultValueSetReportTypeSetForRaResponse = new Set<String>{'RA Response'};  
        for(Aggregate_Report__c ar : newList){
            recordTypeName = Schema.SObjectType.Aggregate_Report__c.getRecordTypeInfosById().get(ar.RecordTypeId).getDeveloperName();
            if(!mulesoftSetting.Ignore_Validation_Rules__c 
               && recordTypeName == CON_PSA.AGG_REPORT_REC_TYPE_RA_RESPONSE
               && ar.Status__c ==  CON_PSA.AGG_REPORT_Status_Completed
               && defaultValueSetReportTypeSetForRaResponse.contains(ar.Report_Type__c))
            {
                if(Trigger.isUpdate 
                   && ar.Report_Type__c != oldMap.get(ar.Id).Report_Type__c){
                       ar.addError('Report type can not be changed in case of completed status for Sandoz Report.'); 
                   }
                if(Trigger.isInsert){
                    ar.addError('Save the record other than completed status for Sandoz Report.');
                }
            }
        }
    }    
}
