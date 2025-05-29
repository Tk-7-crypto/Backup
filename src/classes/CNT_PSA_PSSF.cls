public with sharing class CNT_PSA_PSSF {
    @AuraEnabled 
    public static boolean isSignalManagementProject(Id projectID) {
        List<pse__Proj__c> projRecList = new SLT_Project().selectSignalManagementProjectById(new Set<Id>{projectID}, new Set<String>{'Service_Line__c'});
        if( projRecList != null && projRecList.size() > 0){
            return true;  
        }else{
            return false;
        }
    }
    
    @AuraEnabled
    public static Map<String, String> autoPopulatedFieldData(String projectID){ 
        List<pse__Proj__c> projRecList  = new SLT_Project().selectSignalManagementProjectById(new Set<Id>{projectID}, new Set<String>{'pse__Account__c', 'pse__Parent_Project__r.Project_Code__c'});
        Map<String, String> projFieldLabelToValueMap = new Map<String, String>();
        if(projRecList != null && projRecList.size() > 0){
            projFieldLabelToValueMap.put('account',projRecList[0].pse__Account__c);
            projFieldLabelToValueMap.put('projectCode',projRecList[0].pse__Parent_Project__r.Project_Code__c);
        }
        return projFieldLabelToValueMap;
    }
    
    @AuraEnabled
    public static String pssfParentRecId(String projectId){
        String condition = 'Project_Name__c =: projectId AND PSSF_Parent__c = null AND PSSF_Status__c = ' +'\'' + CON_PSA.STATUS_DRAFT+'\'';
        List<PSSF__c> pssfDraftRecList = new SLT_PSSF().getPSSFDataForDraft(projectID, new Set<String>{'Id', 'Name'}, condition);
        if(pssfDraftRecList != null && pssfDraftRecList.size() > 0){
            return pssfDraftRecList[0].Id;
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static string getParentPssfIfChild(String pssfId){
        String condition = 'Id =: pssfId AND PSSF_Status__c =: status ';
        List<PSSF__c> pssfDraftRecList = new SLT_PSSF().getPSSFDataForStatus(pssfId, new Set<String>{'Id', 'Name','PSSF_Parent__c'}, condition, CON_PSA.STATUS_DRAFT_CHILD);
        if(pssfDraftRecList != null && pssfDraftRecList.size() > 0){
            return pssfDraftRecList[0].PSSF_Parent__c;
        }else{
            return pssfId;
        }
    }
    
    // true if has view rights and a record to view too
    @AuraEnabled
    public static boolean hasEditPermission(){
        boolean hasPermission = false;
        boolean hasSMEdit = false;
        boolean hasPMandFunctionalLead = false;
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        permissionSetList = new SLT_PermissionSetAssignment().selectByUserIds(new Set<String>{'PermissionSet.Name'}, new Set<Id>{UserInfo.getUserId()});
        for(PermissionSetAssignment perRec: permissionSetList){
            if(perRec.PermissionSet.Name == CON_PSA.RDS_ADMIN){
                hasPermission = true;
                break;
            }
            if(perRec.PermissionSet.Name == CON_PSA.RDS_SM_Edit) {
                hasSMEdit = true;
            }   
            if(perRec.PermissionSet.Name == CON_PSA.RDS_Project_Manager_and_Functional_Lead){
                hasPMandFunctionalLead = true;
            } 
        }
        if(hasSMEdit && hasPMandFunctionalLead){
            hasPermission = true;
        }
        return hasPermission;
    }
    
    @AuraEnabled
    public static Map<String, String> fetchRelatedRecords(String pssfParentRecId){
        Map<String, String> relatedChildRecNameToRecIdMap = new Map<String, String>();
        String condition = 'PSSF_Parent__c =: pssfParentRecId';
        List<PSSF__c> relatedRecordList = new SLT_PSSF().getPSSFDataForParentPSSF(pssfParentRecId, new Set<String>{'Id', 'Name'}, condition);
        if(relatedRecordList != null && relatedRecordList.size() > 0){
            for(PSSF__c rec : relatedRecordList){
                relatedChildRecNameToRecIdMap.put(rec.Name, rec.Id);
            }
        }
        return relatedChildRecNameToRecIdMap;
    }
    
    @AuraEnabled
    public static Map<String, String> getFocusFieldMap(){
        Map<String, String> focusFieldLabelToFocusValMap = new Map<String, String>();
        List<PSA_PSSF_Focus_Field_Value__mdt> focusFieldList = new SLT_PSSF().getPSSFFocusFieldValData();
        if(focusFieldList != null && focusFieldList.size()>0){
            for(PSA_PSSF_Focus_Field_Value__mdt focus : focusFieldList){
                focusFieldLabelToFocusValMap.put(focus.Label, focus.Focus__c);
            }
        }
        return focusFieldLabelToFocusValMap;
    }

    @AuraEnabled
    public static String fetchProjectId(String pssfParentRecId){
        List<PSSF__c> pssfList = new List<PSSF__c>();
        pssfList  = new SLT_PSSF().getPSSFById(new Set<Id>{pssfParentRecId}, new Set<String>{'Project_Name__c'});
        if(pssfList != null && pssfList.size()>0){
            return pssfList[0].Project_Name__c;
        }
        else{
            return CON_PSA.NO_PROJECT;
        }
    }
    
    @AuraEnabled
    public static List<PSSF__c> getAllPSSFParentRecord(string projectID){
        List<PSSF__c> pssfList  = new SLT_PSSF().getPSSFByProject(new Set<Id>{projectID}, new Set<String>{'Id','PSSF_Version__c','createdDate','CreatedById','CreatedBy.Name','PSSF_Status__c'});
        return pssfList;
    }
    
    @AuraEnabled
    public static List<PSSF__c> deleteHistoryRecord(List<ID> recordToDeleteIDList, String pssfParentId){
        List<PSSF__c> pssfList = new List<PSSF__c>();
        pssfList  = new SLT_PSSF().getPSSFById(new Set<ID>(recordToDeleteIDList), new Set<String>{'Id'});
        delete pssfList;
        List<PSSF__c> pssfHistoryList = new List<PSSF__c>();
        pssfHistoryList = new SLT_PSSF().getPSSFByPSSFParentHistoryChanges(new Set<Id>{pssfParentId}, new Set<String>{'Id','name'});
                    
        for(Integer i = 0 ; i < pssfHistoryList.size() ; i ++) {
            for(integer j = i+1 ; j <= pssfHistoryList.size() -1 ; j ++){
                pssf__c pssfTemp ;
                List<String> history1SplitList = pssfHistoryList[i].name.split(' ');
                List<String> history2SplitList = pssfHistoryList[j].name.split(' ');
                integer history1  = integer.valueOf(history1SplitList[2]);
                integer history2 = integer.valueOf(history2SplitList[2]);
                if(history1 > history2){
                    pssfTemp = pssfHistoryList[i]  ;
                    pssfHistoryList[i] = pssfHistoryList[j]  ;
                    pssfHistoryList[j]  = pssfTemp;
                }
            }
        }
                
        for(integer i=0; i < pssfHistoryList.size(); i++){
            pssfHistoryList[i].name = 'History Record ' + i;
        }
        update pssfHistoryList;
        return pssfHistoryList;
    } 
    
    @AuraEnabled
    public static boolean hasRDSAdminPermission(string pssfParentRecId){
        boolean hasPermission = false;
        List<PermissionSetAssignment> permissionSetList = new list<PermissionSetAssignment>();
        permissionSetList = new SLT_PermissionSetAssignment().selectByUserIds(new Set<String>{'PermissionSet.Name'}, new Set<Id>{UserInfo.getUserId()});
        for(PermissionSetAssignment perRec: permissionSetList){
            if(perRec.PermissionSet.Name == CON_PSA.RDS_ADMIN){
                hasPermission = true;
                break;
            }
        }
        if(hasPermission){
            return true;
        }else{
            return false;
        }       
    }
}