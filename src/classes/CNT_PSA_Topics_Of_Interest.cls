/**
** This is a controller class to Aura Component - LXC_PSA_Topics_Of_Interest
**/
public with sharing class CNT_PSA_Topics_Of_Interest {

    @AuraEnabled
    public static Map<string,string> autoPopulateFields(String projectId){
        
        list<pse__Proj__c> projRecord  = new SLT_Project().selectSignalManagementProjectById(new Set<Id>{projectID}, new Set<String>{'pse__Account__c', 'pse__Parent_Project__r.Project_Code__c' });
        Map<string,string> projDetail = new Map<string,string>();
        if(projRecord.size()>0){
            projDetail.put('account',projRecord[0].pse__Account__c);
            projDetail.put('projectCode',projRecord[0].pse__Parent_Project__r.Project_Code__c);
        }
        return projDetail;
    }
    @AuraEnabled
    public static boolean hasHAPermissionCreate(string projectID){
        boolean hasPermission = false;
        boolean hasSMEdit = false;
        boolean hasPMandFunctionalLead = false;
        List<PermissionSetAssignment> permissionSetList = new list<PermissionSetAssignment>();
        permissionSetList = [SELECT  PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
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
    public static boolean hasTOIPermissionEdit(string toiId){
        boolean hasPermission = false;
        boolean hasSMEdit = false;
        boolean hasPMandFunctionalLead = false;
        List<PermissionSetAssignment> permissionSetList = new list<PermissionSetAssignment>();
        permissionSetList = [SELECT  PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
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
        
        list<Topics_Of_Interest__c> toiList  = [SELECT Id, Project__r.Service_Line__r.name
                                                FROM Topics_Of_Interest__c
                                                WHERE Id =: toiId];
        if(hasPermission && toiList.size()>0 ){
            return true;  
        }
        else{
            return false;
        }
    }
    
    @AuraEnabled
        public static string haGetProjectId(string toiId){
        
        list<Topics_Of_Interest__c> toiList  = [SELECT Id, Project__c
                                                FROM Topics_Of_Interest__c
                                                WHERE Id =: toiId];
        if(toiList.size()>0 ){
            string recId =  toiList[0].Project__c;
            return recId;
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled
        public static string populateStatus(Date startedDate, Date stoppedDate){
        
        String statusValue;
        if(stoppedDate <> null) {
            statusValue = 'Completed';
        } 
        else if(startedDate <> null) {
            statusValue = 'Active';
        } 
        else{
            statusValue = 'New';
        }
        return statusValue;
    }
    
    @AuraEnabled
    public static List<Target__c> getTargetRecords(string projectID){
        List<Target__c> activeTargetsList = new List<Target__c>();
        activeTargetsList = UTL_PSA.getTargetRecords(projectID);
        return activeTargetsList;
    }
    
    @AuraEnabled
    public static boolean hasRDSAdminPermission(string toiId){
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
    
    // clone TOI record
    @AuraEnabled
    public static string cloneTOIRecord(id toiId, list<id> productId, Map<String, String> cloneValsMap){
        DescribeSObjectResult describeResult = toiId.getSObjectType().getDescribe();
        
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        Set<String> clonedDateFields = new Set<String>{'Date_Started__c','Date_Stopped__c','Date_Reminder_Calendar__c'};
        String query =
          ' SELECT ' +
              String.join( fieldNames, ',' ) +
          ' FROM ' +
              describeResult.getName() +
          ' WHERE ' +
              ' id = :toiId ' +
          ' LIMIT 1 '
        ;

        // return generic list of sobjects or typecast to expected type
        list<Topics_Of_Interest__c> toiList  = Database.query( query );
        list<Topics_Of_Interest__c> toiListtoInsert = new list<Topics_Of_Interest__c>();
        list<Topics_Of_Interest__c> sObjLst = new list<Topics_Of_Interest__c>();
        if(productId.size() == 0){
            Topics_Of_Interest__c toiCloneRec = toiList[0].clone(false, true, false, false);
            sObject clonedSobj = (Sobject) toiCloneRec;
            //clonedSobj.Product__c = null;
            // apply specified field values to cloned record
            if (cloneValsMap != null && cloneValsMap.size() > 0) {
                        for(String key : cloneValsMap.keyset()){
                            Object fieldVal = cloneValsMap.get(key);
                            // handle case when field is type date, need to grab the value of (YYYY-MM-DD)
                            if (clonedDateFields.contains(key)) {
                                fieldVal = (fieldVal == null ? null  : Date.valueOf(String.valueOf(fieldVal)));
                            }
                            if (key == 'Product__c') {
                                fieldVal = null;
                            }
                            if (key == 'Legacy_ID__c') {
                                fieldVal = null;
                            }
                            if (key == 'TOI_Unique_ID__c') {
                                fieldVal = null;
                            }
                            if (key == 'Topic_ID__c') {
                                fieldVal = null;
                            }
                                    clonedSobj.put(key, fieldVal);
                                }
            		}
            sObjLst.add((Topics_Of_Interest__c)clonedSobj);
            
        }
        else{
            for(id prdId: productId){
                Topics_Of_Interest__c toiCloneRec = toiList[0].clone(false, true, false, false);
                sObject clonedSobj = (Sobject) toiCloneRec;
                //clonedSobj.Product__c = prdId;
                // apply specified field values to cloned record
            if (cloneValsMap != null && cloneValsMap.size() > 0) {
                        for(String key : cloneValsMap.keyset()){
                            Object fieldVal = cloneValsMap.get(key);
                            // handle case when field is type date, need to grab the value of (YYYY-MM-DD)
                            if (clonedDateFields.contains(key)) {
                                fieldVal = (fieldVal == null ? null  : Date.valueOf(String.valueOf(fieldVal)));
                            }
                            if (key == 'Product__c') {
                                fieldVal = String.valueOf(prdId);
                            }
                            if (key == 'Legacy_ID__c') {
                                fieldVal = null;
                            }
                                    clonedSobj.put(key, fieldVal);
                                }
            		}
                
                //toiListtoInsert.add(clonedSobj);
                sObjLst.add((Topics_Of_Interest__c)clonedSobj);
            }
        }
            insert sObjLst;
            return string.valueof(toiListtoInsert.size());
        
    }
    
    // create TOI record
    @AuraEnabled
    public static string createTOIRecord(list<id> productId, Map<String, String> cloneValsMap){
        Set<String> clonedDateFields = new Set<String>{'Date_Started__c','Date_Stopped__c','Date_Reminder_Calendar__c'};
            if(cloneValsMap.containsKey('Topic_ID__c')){
                cloneValsMap.remove('Topic_ID__c');
            }
        
        list<Topics_Of_Interest__c> toiListtoInsert = new list<Topics_Of_Interest__c>();
        list<Topics_Of_Interest__c> sObjLst = new list<Topics_Of_Interest__c>();
        if(productId.size() == 0){
            Topics_Of_Interest__c newTOIRec = new Topics_Of_Interest__c();
            sObject clonedSobj = (Sobject) newTOIRec;
            // apply specified field values to cloned record
            if (cloneValsMap != null && cloneValsMap.size() > 0) {
                        for(String key : cloneValsMap.keyset()){
                            Object fieldVal = cloneValsMap.get(key);
                            // handle case when field is type date, need to grab the value of (YYYY-MM-DD)
                            if (clonedDateFields.contains(key)) {
                                fieldVal = (fieldVal == null ? null  : Date.valueOf(String.valueOf(fieldVal)));
                            }
                            
                                    clonedSobj.put(key, fieldVal);
                                }
            		}
            sObjLst.add((Topics_Of_Interest__c)clonedSobj);
            
        }
        else{
            for(id prdId: productId){
                Topics_Of_Interest__c newTOIrecord = new Topics_Of_Interest__c();
                sObject clonedSobj = (Sobject) newTOIrecord;
                
            if (cloneValsMap != null && cloneValsMap.size() > 0) {
                        for(String key : cloneValsMap.keyset()){
                            Object fieldVal = cloneValsMap.get(key);
                            
                            // handle case when field is type date, need to grab the value of (YYYY-MM-DD)
                            if (clonedDateFields.contains(key)) {
                                fieldVal = (fieldVal == null ? null  : Date.valueOf(String.valueOf(fieldVal)));
                            }
                            if (key == 'Product__c') {
                                fieldVal = String.valueOf(prdId);
                            }
                            if (key == 'Topic_ID__c') {
                                fieldVal = null;
                            }
                            clonedSobj.put(key, fieldVal);
                            clonedSobj.put('Product__c', String.valueOf(prdId));
                                }
            		}
                
                //toiListtoInsert.add(clonedSobj);
                sObjLst.add((Topics_Of_Interest__c)clonedSobj);
            }
        }
            insert sObjLst;
            return string.valueof(toiListtoInsert.size());        
    }
}