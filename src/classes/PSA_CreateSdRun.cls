public with sharing class PSA_CreateSdRun {
    @AuraEnabled
    public static Map<string,string> autoPopulatedFieldData(string projectID){
        
        list<pse__Proj__c> projRec  = new SLT_Project().selectSignalManagementProjectById(new Set<Id>{projectID}, new Set<String>{'pse__Account__c', 'pse__Parent_Project__r.Project_Code__c','Service_Line_Lead__c'});
        Map<string,string> projDetail = new Map<string,string>();
        if(projRec.size()>0){
            projDetail.put('account',projRec[0].pse__Account__c);
            projDetail.put('projectCode',projRec[0].pse__Parent_Project__r.Project_Code__c);
            projDetail.put('serviceLineLead',projRec[0].Service_Line_Lead__c);
        }
        return projDetail;
    }
    
    // This method is used to just populate field on UI but actual insertion in field is done from trigger(DAOH_Sd_Run -class, populateSdRunIdField -method).
    /*@AuraEnabled
    public static string sdRunFieldData(string projectID){
        list<pse__Proj__c> projRec  = new SLT_Project().selectSignalManagementProjectById(new Set<Id>{projectID}, new Set<String>{'pse__Account__r.name'});
        string sdRunIdAuto = '';
        system.debug(projRec.size());
        if(projRec.size()>0){
            system.debug(projRec[0].pse__Account__c);
            //list<SD_Runs__c> sdRec = [select name from SD_Runs__c order by createdDate desc limit 1];
            list<SD_Runs__c> sdRec  = new SLT_SdRun().getLastCreatedSdRunRecord( new Set<String>{'Name'});
            
            if(sdRec.size()>0){
                if( sdRec[0].name != null){
                    string name = sdRec[0].name;
                    String delimiter = '-SD-';
                    String splits = sdRec[0].name.substringAfter(delimiter);
                    Decimal num = integer.valueof(splits) + 1;
                    String incrementedNum = (('00000')+num).right(5);
                    string accountName= projRec[0].pse__Account__r.name.substring(0,3);
                    sdRunIdAuto = accountName + '-SD-' + incrementedNum;
                }
                else{
                    system.debug('error: there is a latest sd run record having name as null');
                }
            }
            else{
                string accountName= projRec[0].pse__Account__r.name.substring(0,3);
                sdRunIdAuto = accountName + '-SD-' + '00000';
            }
        }
        return sdRunIdAuto;
    }*/
   /* 
    @AuraEnabled
    public static boolean hasEditPermission(){
        boolean hasPermission = false;
        List<PermissionSetAssignment> permissionSetList = new list<PermissionSetAssignment>();
        permissionSetList = [SELECT  PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
        for(PermissionSetAssignment perRec: permissionSetList){
            if(perRec.PermissionSet.Name == 'RDS_ADMIN' || perRec.PermissionSet.Name == 'RDS_SM_Edit'){
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
    */
    
    @AuraEnabled
    public static boolean hasSDRunPermissionCreate(string projectID){
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
        
        system.debug('projectID' + projectID);
        list<pse__Proj__c> projRec  = new SLT_Project().selectSignalManagementProjectById(new Set<Id>{projectID}, new Set<String>{'Service_Line__c'});
        if(hasPermission && projRec.size()>0){
            return true;  
        }
        else{
            return false;
        }
    }
    
    @AuraEnabled
    public static boolean hasSDRunPermissionView(string sdRunID){
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
        
        if(hasPermission){
            return true;  
        }
        else{
            return false;
        }
        
        /*
        boolean hasPermission = false;
        List<PermissionSetAssignment> permissionSetList = new list<PermissionSetAssignment>();
        permissionSetList = [SELECT  PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
        for(PermissionSetAssignment perRec: permissionSetList){
            if(perRec.PermissionSet.Name == 'RDS_ADMIN' || perRec.PermissionSet.Name == 'RDS_SM_Edit'){
                hasPermission = true;
                break;
            }   
        }
        
        system.debug('sdRunID' + sdRunID);
        list<SD_Runs__c> sdRec  = new SLT_SdRun().getSdRunById(new Set<Id>{sdRunID}, new Set<String>{'Project__r.Service_Line__r.name'});
        if(hasPermission && sdRec.size()>0 ){
            return true;  
        }
        else{
            return false;
        }*/
    }
    
    @AuraEnabled
    public static string sDRunProjectIDView(string sdRunID){
        list<SD_Runs__c> sdRec  = new SLT_SdRun().getSdRunById(new Set<Id>{sdRunID}, new Set<String>{'Project__c'});
        if(sdRec.size()>0 ){
            string recId =  sdRec[0].Project__c;
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
    public static boolean hasRDSAdminPermission(string sdRunID){
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
    
    @AuraEnabled(cacheable=false)
    public static String cloneSDRec(string sdRunID, Map<String, String> cloneValsMap){
        String recId = '';
        String msg = '';
        System.debug('Sd Run Id and mp'+cloneValsMap+ ' '+sdRunID);
        try {
            // load the project metric record to clone!
            SLT_SdRun sdRunService = new SLT_SdRun(false);
            Set<String> fields = sdRunService.getSObjectFieldSet();
            String conditions = 'Id = \'' + sdRunID + '\'';
            SD_Runs__c[] sdRuns = sdRunService.findBy(fields, conditions);

            if (sdRuns == null || sdRuns.size() <= 0) {
                throw new AuraHandledException('Undefined sd run record to clone.');
            }
            if(fields.contains('SD_Run_ID__c')){
                fields.remove('SD_Run_ID__c');
            }
            if(fields.contains('Name')){
                fields.remove('Name');
            }

            // clone the record
            SD_Runs__c clonedSdRun = sdRuns[0].clone();
			System.debug('Last sd run val'+cloneValsMap.get('Last_SD_Run_for_Product__c'));
            sObject clonedSobj = (Sobject) clonedSdRun;
            // apply specified field values to cloned record
            if (cloneValsMap != null && cloneValsMap.size() > 0) {
                Set<String> clonedDateFields = new Set<String>{'Data_Review_Period_End_Date__c', 'Data_Review_Period_Start_Date__c', 'Date_BRM_Review_Completed__c', 'Date_Client_Meeting__c'
                    , 'Date_Data_Transfer_to_BIOS__c', 'Date_Draft_Report_Sent_to_Client_Opt__c', 'Date_Internal_Review_Meeting_Opt__c', 'Date_Medical_Review_Completed__c', 'Date_QC_Completed__c',
                    'Date_SMT_Meeting__c', 'Discussed_in_SMT_Meeting__c', 'Due_Date_BIOS_to_DM_Optional__c', 'Due_Date_MSA_to_TMA__c', 'Due_Date_data_to_PSA__c', 'SD_Run_Date_Completed__c',
                    'SD_Run_Due_Date__c', 'SD_Run_Start_Date__c'};
                        for(String key : cloneValsMap.keyset()){
                            Object fieldVal = cloneValsMap.get(key);
                            // handle case when field is type date, need to grab the value of (YYYY-MM-DD)
                            if (clonedDateFields.contains(key)) {
                                fieldVal = (fieldVal == null ? null  : Date.valueOf(String.valueOf(fieldVal)));
                            }
                                    if(key == 'Last_SD_Run_for_Product__c'){
                                      fieldVal = fieldVal != null ? Boolean.valueOf(String.valueOf(fieldVal)) : null;  
                                    }
                            if(key != 'SD_Run_ID__c'){
                                clonedSobj.put(key, fieldVal);
                            }
                                    
                                }
                          
            		}
            if(clonedSobj.get('Legacy_ID__c') != null){
                clonedSobj.put('Legacy_ID__c', null);
            }
            // save the cloned record
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { SD_Runs__c.SObjectType });
            uow.registerNew(clonedSobj);
            uow.commitWork();

            // return new id
            System.debug('new id'+clonedSdRun.id);
            recId = clonedSdRun.id;
        }catch(DmlException e){
            //Any type of Validation Rule error message, Required field missing error message, Trigger error message etc..
            //we can get from DmlException
             
            //Get All DML Messages
            for (Integer i = 0; i < e.getNumDml(); i++) {
                //Get Validation Rule & Trigger Error Messages
                msg =+ e.getDmlMessage(i) +  '\n' ;
            }
            //throw DML exception message
            throw new AuraHandledException(msg);
        }catch (Exception e) {
            System.debug('Exception'+e);
        }
        return recId;
    }
    
    @AuraEnabled
    public static Map<string,object> getFreqDtForSDRunClone(string recId){
        
        list<SD_Runs__c> sdRec  = new SLT_SdRun().getSdRunById(new Set<Id>{recId}, new Set<String>{'Frequency__c','Data_Review_Period_End_Date__c','Account__c','Project__c','Product__c','Project_Code__c'});
        Map<string,object> sdRunDetail = new Map<string,object>();
        if(sdRec.size()>0){
            sdRunDetail.put('Frequency',sdRec[0].Frequency__c);
            sdRunDetail.put('ReviewEndDate',sdRec[0].Data_Review_Period_End_Date__c);
            sdRunDetail.put('Account',sdRec[0].Account__c);
            sdRunDetail.put('ProjectCd',sdRec[0].Project_Code__c);
            sdRunDetail.put('Product',sdRec[0].Product__c);
            sdRunDetail.put('Project',sdRec[0].Project__c);
        }
        return sdRunDetail;
    }
}