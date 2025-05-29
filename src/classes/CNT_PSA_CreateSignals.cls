public class CNT_PSA_CreateSignals {
    
    @AuraEnabled
    public static Map<string,string> autoPopulatedFieldData(string projectID){
        
        list<pse__Proj__c> projRec  = new SLT_Project().selectSignalManagementProjectById(new Set<Id>{projectID}, new Set<String>{'pse__Account__c', 'pse__Parent_Project__r.Project_Code__c','Service_Line_Lead__c' });
        Map<string,string> projDetail = new Map<string,string>();
        if(projRec.size()>0){
            projDetail.put('account',projRec[0].pse__Account__c);
            projDetail.put('projectCode',projRec[0].pse__Parent_Project__r.Project_Code__c);
            projDetail.put('serviceLineLead',projRec[0].Service_Line_Lead__c);
        }
        return projDetail;
    }
    
    @AuraEnabled
    public static boolean hasSignalPermissionView(){
        boolean hasPermission = false;
        boolean hasSMEdit = false;
        boolean hasPMandFunctionalLead = false;
        SLT_PSA_Signal signalService = new SLT_PSA_Signal();
        List<PermissionSetAssignment> permissionSetList = new list<PermissionSetAssignment>();
        permissionSetList = signalService.checkPermmission();
        for(PermissionSetAssignment perRec: permissionSetList){
            if(perRec.PermissionSet.Name == 'RDS_ADMIN'){
                hasPermission = true;
                break;
            }
            if(perRec.PermissionSet.Name == 'RDS_SM_Edit') {
                hasSMEdit = true;
            }   
            if(perRec.PermissionSet.Name == 'RDS_Project_Manager_and_Functional_Lead'){
                hasPMandFunctionalLead = true;
            }  
        }
        
        if(hasSMEdit && hasPMandFunctionalLead){
            hasPermission = true;
        }
        
        if(hasPermission){
            return true;  
        }
        else{
            return false;
        }
    }
    
    @AuraEnabled
    public static boolean hasSignalPermissionCreate(string projectID){
        boolean hasPermission = false;
        boolean hasSMEdit = false;
        boolean hasPMandFunctionalLead = false;
        SLT_PSA_Signal signalService = new SLT_PSA_Signal();
        List<PermissionSetAssignment> permissionSetList = new list<PermissionSetAssignment>();
        permissionSetList = signalService.checkPermmission();
        for(PermissionSetAssignment perRec: permissionSetList){
            if(perRec.PermissionSet.Name == 'RDS_ADMIN'){
                hasPermission = true;
                break;
            }
            if(perRec.PermissionSet.Name == 'RDS_SM_Edit') {
                hasSMEdit = true;
            }   
            if(perRec.PermissionSet.Name == 'RDS_Project_Manager_and_Functional_Lead'){
                hasPMandFunctionalLead = true;
            } 
        }
        if(hasSMEdit && hasPMandFunctionalLead){
            hasPermission = true;
        }
        
        list<pse__Proj__c> projRec  = new SLT_Project().selectSignalManagementProjectById(new Set<Id>{projectID}, new Set<String>{'Service_Line__c'});
        if(hasPermission && projRec.size()>0){
            return true;  
        }
        else{
            return false;
        }
    }
    
    @AuraEnabled
        public static string signalGetProjectId(string signalId){
        SLT_PSA_Signal signalService = new SLT_PSA_Signal();
        list<Signal__c> signalList  = signalService.getSignalListById(signalId);
        if(signalList.size()>0 ){
            string recId =  signalList[0].Project__c;
            return recId;
        }
        else{
            return null;
        }
    }
    @AuraEnabled
    public static List<Target__c> getTargetRecords(string projectID){
        List<Target__c> activeTargetsList = new List<Target__c>();
        activeTargetsList = UTL_PSA.getTargetRecords(projectID);
        
        return activeTargetsList;
    }
    
    @AuraEnabled
    public static EvalResponse populateEvalDueDate(String signalPriorCategory, Date signalValidationDate) {
        EvalResponse response = new EvalResponse();
        Date evaluationDueDate= null;
        if(signalPriorCategory == 'Low'){
            evaluationDueDate = signalValidationDate.addDays(90);
        }
        else if(signalPriorCategory == 'Medium'){
            evaluationDueDate = signalValidationDate.addDays(50);
        }
        else if(signalPriorCategory == 'High'){
            evaluationDueDate = signalValidationDate.addDays(30);
        }
        else if(signalPriorCategory == null || signalPriorCategory==''){
            evaluationDueDate = signalValidationDate;
        }
        if( evaluationDueDate != null && ( signalPriorCategory == 'Low' || signalPriorCategory == 'Medium' || signalPriorCategory == 'High') ){
            response.isReadable = TRUE;
            response.evalDate = evaluationDueDate;
        }else if( signalPriorCategory =='Custom' ){
            response.isReadable = FALSE;
            response.evalDate = evaluationDueDate;
        }else if(signalPriorCategory ==null || signalPriorCategory==''|| signalPriorCategory.equalsIgnoreCase('None')){
            response.isReadable = FALSE;
            response.evalDate =null;
        }
        
        return response;
    }  
    @AuraEnabled
    public static boolean hasRDSAdminPermission(string signalId){
        boolean hasPermission = false;
        List<PermissionSetAssignment> permissionSetList = new list<PermissionSetAssignment>();
        permissionSetList = [SELECT  PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
        for(PermissionSetAssignment perRec: permissionSetList){
            if(perRec.PermissionSet.Name == 'RDS_ADMIN'){
                hasPermission = true;
                break;
            }
        }
        if(hasPermission){
            return true;
        }
        else{
            return false;
        }       
    }
	@AuraEnabled
    public static String populateSignalStatusValue(Date dateClosedEvaluationValue, String validationOutcomeValue) {
        String signalStatus = '';
        if(dateClosedEvaluationValue == null){
            if(validationOutcomeValue == 'Signal Validated') {
                signalStatus = 'Ongoing';
            } 
            if(validationOutcomeValue == 'Signal Not Validated(Specify Reason)'){
                signalStatus = 'Not Validated';
            }
        }
        else {
            signalStatus = 'Closed';
        }
        return signalStatus;
    }
    
    @AuraEnabled
    public static Signal__c getSignalRecord(string signalID){
        
        Signal__c signalList = [SELECT Id, Validation_Date__c,Evaluation_Due_Date__c, Date_Closed_Evaluation_Completed__c,Signal_Prioritization_Category__c FROM Signal__c WHERE Id =: signalID];
        return signalList;
    }
    public Class EvalResponse{
        @AuraEnabled
        public Boolean isReadable{get;set;} 
        @AuraEnabled
        public Date evalDate{get;set;} 
    }
}