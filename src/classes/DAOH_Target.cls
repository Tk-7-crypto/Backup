/**
* This is Target trigger handler class.
* version : 1.0
*/
public class DAOH_Target {
   
    /**
    * This method will insert record in Audit Log on Inserting/Updating Target
    **/ 
    public static void insertAuditLogOnUpdate(List<Target__c> updatedList,Map<Id,Target__c> existingRecords){

        List<Target__c> inScopeTaskList = new List<Target__c>();
        Map<Id, Target__c> inScopeExistingTaskMap;
        
        
        if (trigger.isUpdate) inScopeExistingTaskMap = new Map<Id,Target__c>();
        
        for(Target__c tar : updatedList) {
            if (tar.RecordTypeId != Schema.SObjectType.Target__c.getRecordTypeInfosByName().get('PV Agreement').getRecordTypeId()) {
                continue;  //skip record if not type PV Agreement
            }

            inScopeTaskList.add(tar);
            if (trigger.isUpdate) inScopeExistingTaskMap.put(tar.id, existingRecords.get(tar.id));
        }

        if (inScopeTaskList.size() > 0) {
            SRV_PSA_AuditLog.setAuditOnInsertUpdate(inScopeTaskList, inScopeExistingTaskMap);
        }
    }

    /**
    * This method will insert record in Audit Log on Deleting/UnDeleting Target
    **/
    public static void insertAuditLog(List<Target__c> insertList,String operation){

        List<Target__c> inScopeTaskList = new List<Target__c>();
        
        for(Target__c tar : insertList) {
            if (tar.RecordTypeId != Schema.SObjectType.Target__c.getRecordTypeInfosByName().get('PV Agreement').getRecordTypeId()) {
                continue;  //skip record if not type PV Agreement
            }

            inScopeTaskList.add(tar);
        }

        if (inScopeTaskList.size() > 0) {
            SRV_PSA_AuditLog.setAuditLogOnDeleteUnDelete(inScopeTaskList,operation);
        }
    }

     /**
    * This method is used set and perform field updates
    */
    public static void setFieldUpdates(List<Target__c> newList, Map<Id, Target__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {

        List<Target__c> inScopeTaskList = new List<Target__c>();

        for(Target__c tar : newList) {
       
            if ( tar.RecordTypeId == null || methodToRecordTypeMap == null || methodToRecordTypeMap.get('setFieldUpdates') == null || !methodToRecordTypeMap.get('setFieldUpdates').contains(Schema.SObjectType.Target__c.getRecordTypeInfosById().get(tar.RecordTypeId).getDeveloperName()) ) {
                continue;  //skip record if code not configured for recordtype
            }
            
            inScopeTaskList.add(tar);
        }

        if (inScopeTaskList.size() > 0) {
            for(Target__c tar : inScopeTaskList) {

                if (tar.Drug__c != null) {
                    string drugName = UTL_PSA.getString(tar.Drug_Name__c);
                    string drugStrength = UTL_PSA.getString(tar.Drug_Strength__c);
                    string drugCountry = UTL_PSA.getString(tar.Single_Country__c);
                    
                    integer countryLength = drugCountry.length() > 0 ? 2 : 0;
                    integer strengthLength = drugStrength.length() > 20 ? 20 : drugStrength.length();
                    
                    tar.Name = drugName.left(80 - strengthLength - countryLength) + ' ' + drugStrength + ' ' + drugCountry;
                }

                if (tar.api__c != null) {
                    string drugName = UTL_PSA.getString(tar.api__c);
                    string drugStrength = UTL_PSA.getString(tar.Strength__c);
                    string drugDosage = UTL_PSA.getString(tar.Dosage_Form__c);
                    string drugCountry = UTL_PSA.getString(tar.Single_Country__c);
                    
                    integer countryLength = drugCountry.length() > 0 ? 2 : 0;
                    integer strengthLength = drugStrength.length() > 20 ? 20 : drugStrength.length();
                    
                    string nameString = tar.Multiple_Countries__c == null ? drugName + ' ' + drugStrength + ' ' + drugDosage + ' ' + drugCountry : drugName + ' Multiple Countries ' + drugStrength + ' ' + drugDosage;
                    tar.Name = nameString.left(80);
                }
            }
        }
    }
    
    /**
    * This method is used to manage active and inactive date fields on toggling the active checkbox
    */
    public static void manageDatesOnActiveToggle(List<Target__c> newList, Map<Id, Target__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {
        for(Target__c tar : newList) {
            if ( tar.RecordTypeId == null || methodToRecordTypeMap == null || methodToRecordTypeMap.get('manageDatesOnActiveToggle') == null || !methodToRecordTypeMap.get('manageDatesOnActiveToggle').contains(Schema.SObjectType.Target__c.getRecordTypeInfosById().get(tar.RecordTypeId).getDeveloperName()) ) {
                continue;  //skip record if code not configured for recordtype
            }
            if (tar.Active__c &&  tar.Inactivated_Date__c != null ) {
                tar.Inactivated_Date__c = null;
            }else if(!tar.Active__c &&  tar.Date_Activated__c != null) {
                tar.Date_Activated__c = null;
            }
        }
    }
    
    /**
    * This method is used to update Countries_product_is_marketed_by_Client__c field on related HA Websites Review records.
    */
    public static void updateHAWebsitesReviewRecords(List<Target__c> newList, Map<Id, Target__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {
        Map<Id, Target__c> targetIdToTargetMap = new Map<Id,Target__c>();
        for(Target__c tar : newList) {
            if ( tar.RecordTypeId == null || methodToRecordTypeMap == null || methodToRecordTypeMap.get('updateHAWebsitesReviewRecords') == null || !methodToRecordTypeMap.get('manageDatesOnActiveToggle').contains(Schema.SObjectType.Target__c.getRecordTypeInfosById().get(tar.RecordTypeId).getDeveloperName()) ) {
                continue;  //skip record if code not configured for recordtype
            }
            if (oldMap == null || 
                (tar.Countries__c != oldMap.get(tar.id).Countries__c || tar.Single_Country__c != oldMap.get(tar.id).Single_Country__c)) {
                targetIdToTargetMap.put(tar.id,tar);
            }
        }
        if(targetIdToTargetMap.size() > 0) {
            List<HA_Websites_Review__c> HAWRList = new List<HA_Websites_Review__c>();
            HAWRList = [SELECT Id,Countries_product_is_marketed_by_Client__c, Product__c 
                        FROM HA_Websites_Review__c 
                        WHERE Product__c in: targetIdToTargetMap.keySet()];
           for(HA_Websites_Review__c hwr : HAWRList) {
               if(targetIdToTargetMap.get(hwr.Product__c).Countries__c != '' && targetIdToTargetMap.get(hwr.Product__c).Countries__c != null) {
                   hwr.Countries_product_is_marketed_by_Client__c = targetIdToTargetMap.get(hwr.Product__c).Countries__c;
               }
               else if(targetIdToTargetMap.get(hwr.Product__c).Single_Country__c != '' && targetIdToTargetMap.get(hwr.Product__c).Single_Country__c != null){
                   hwr.Countries_product_is_marketed_by_Client__c = targetIdToTargetMap.get(hwr.Product__c).Single_Country__c;
               }
               else	
                   hwr.Countries_product_is_marketed_by_Client__c = '';               
           }
           if(HAWRList.size() > 0) {
               update HAWRList;
           }
        }
    } 
    public static void preventDeactiveTarget( List<Target__c> newList , Map<Id, Target__c> existingRecords ){
        List< Project_Target__c> lstToUpdate = new List< Project_Target__c>();
        Map<String,Target__c>  mapOfTarget = new Map<String,Target__c>();
        Boolean hasAccess = false;
        Set<String> fieldSet=new Set<String>{'PermissionSet.Id','PermissionSet.Name'};
        Set<Id> userIDs=new Set<Id>{userInfo.getUserId()};
        List<PermissionSetAssignment> permissionsets=new SLT_PermissionSetAssignment().selectByUserIds(fieldSet,userIDs);
        for(PermissionSetAssignment pSet:permissionsets){
            if( pSet.permissionSet.Name=='RDS_Admin' ){
                hasAccess=true;
                break;
            }
        }
        for( Target__c target : newList ){
            if( ( Trigger.isUpdate 
                 &&  target.Active__c != existingRecords.get( target.Id ).Active__c ) 
                 && hasAccess == FALSE 
                 && target.RecordTypeId == CON_PSA.TARGET_REC_TYPE_ID_RDS_PRODUCT_LINE
              ){
                   target.addError('You are not authorize to set active/inactive this Target.');
               }
            if( ( Trigger.isUpdate 
                 && target.Active__c != existingRecords.get( target.Id ).Active__c ) 
                 && hasAccess == TRUE 
                 && target.RecordTypeId == CON_PSA.TARGET_REC_TYPE_ID_RDS_PRODUCT_LINE
              ){
                   mapOfTarget.put( target.Id, target );
               }
        }
        for( Project_Target__c pt : [ SELECT Id,Active__c,Target__c  FROM Project_Target__c WHERE Target__c IN :mapOfTarget.keySet() ] ){
            pt.Active__c = mapOfTarget.get( pt.Target__c ).Active__c;
            lstToUpdate.add( pt );
        }
        if( lstToUpdate.size() > 0 ){
            Update lstToUpdate;
        }
    }
    public static void targetNamingConvention(List<Target__c> newList , Map<Id, Target__c> existingRecords){
        String targetName = '';
        
        for(Target__c target : newList){
            targetName = '';
            if(target.RecordTypeId == CON_PSA.TARGET_RECORD_TYPE_ID_RDS_PROTOCAL){
                targetName = (target.Protocol_Number__c != null ? target.Protocol_Number__c : '') +' '+(target.Single_Country__c != null ?  target.Single_Country__c : '' )+' '+(target.Therapeutic_Area__c != null ? target.Therapeutic_Area__c : '');
            }
            else if(target.RecordTypeId == CON_PSA.TARGET_RECORD_TYPE_ID_RDS_COUNTRY){
                targetName = (target.Single_Country__c != null ? target.Single_Country__c : '' )+' '+ (target.Location__c != null ? target.Location__c : '');
            }
            if(String.isNotBlank(targetName)){
                target.Name = targetName.length() > 80 ?  targetName.substring(0,80) : targetName;
            }
        }
    }
    public static void pvAgreeMentTargetNamingConvention(List<Target__c> newList , Map<Id, Target__c> existingRecords){
        String targetName = '';
        List<Target__c> updateToTargetList = new List<Target__c>();
        
        Set<Id> targetIdSet = new Set<Id>();
        for(Target__c target : newList){
            if(target.RecordTypeId == CON_PSA.TARGET_RECORD_TYPE_ID_PV_AGREEMENT && target.Program__c != null){
                targetIdSet.add(target.Id);    
            }
        }
        
        if(!targetIdSet.isEmpty()){
            for(Target__c target : [SELECT Id, Program__r.Name, PVA_ID__c FROM Target__c WHERE Id IN : targetIdSet ]){
                targetName = (target.Program__r.Name != null ? target.Program__r.Name : '' )+' '+ (target.PVA_ID__c != null ? target.PVA_ID__c : '');
                target.Name = targetName.length() > 80 ?  targetName.substring(0,80) : targetName;
                updateToTargetList.add(target);
            }
            if(!updateToTargetList.isEmpty()){
                update updateToTargetList;
            }
        }
    }
}
