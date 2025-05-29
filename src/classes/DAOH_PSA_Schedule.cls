public class DAOH_PSA_Schedule {
     /**
     * Method to check if the running user is allowed to delete the given Schedule record.
     */
    public static void validateDeletion(List<pse__Schedule__c> deletedList){
        Set<Id> scheduleIdSet = new Set<Id>();
        Map<Id,Boolean> scheduleIdToVerifyDeletionMap = new Map<Id,Boolean>();
        Boolean validateScheduleDeletion = false;
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        List<PermissionSetAssignment> permissionSetList = new list<PermissionSetAssignment>();
        permissionSetList = [SELECT  PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
        
        Set<String> profileNameSet = new Set<String>{'System Administrator', 'System Administrator Integration', 'System Administrator Module','System Administrator Package Support','IQVIA Salesforce Platform Support'};
         
        if(!profileNameSet.contains(profileName)) {
            for(PermissionSetAssignment perRec: permissionSetList){
                if(perRec.PermissionSet.Name == 'RDS_ADMIN' || perRec.PermissionSet.Name == 'RDS_Project_Manager_and_Functional_Lead'
                    || perRec.PermissionSet.Name == 'RDS_Project_Manager_and_Functional_Lead'){
                    validateScheduleDeletion = true;
                }
            }
        }
        if(validateScheduleDeletion) {
            for(pse__Schedule__c schedule : deletedList){
                scheduleIdSet.add(schedule.id);
            }
        
        
            for(pse__Resource_Request__c rr : [SELECT Id, pse__Project__r.recordType.Name,pse__Preferred_Schedule__r.id from pse__Resource_Request__c
                                               WHERE pse__Preferred_Schedule__c in: scheduleIdSet ]) {
                if(rr.pse__Project__r.recordType.Name.startsWith('RDS')) {
                    if(!scheduleIdToVerifyDeletionMap.containsKey(rr.pse__Preferred_Schedule__r.id)) {
                        scheduleIdToVerifyDeletionMap.put(rr.pse__Preferred_Schedule__r.id,true);   
                    }  
                }                                    
                else{
                    scheduleIdToVerifyDeletionMap.put(rr.pse__Preferred_Schedule__r.id,false);  
                    break;
                }                                  
            }
            for(pse__Assignment__c assignment : [SELECT Id, pse__Project__r.recordType.Name, pse__Schedule__r.Id
                                                 FROM pse__Assignment__c
                                                 WHERE pse__Schedule__c in: scheduleIdSet]) {
                                                 
                if(assignment.pse__Project__r.recordType.Name.startsWith('RDS')) {
                    if(!scheduleIdToVerifyDeletionMap.containsKey(assignment.pse__Schedule__r.id)) {
                        scheduleIdToVerifyDeletionMap.put(assignment.pse__Schedule__r.id,true);   
                    }  
                }                                    
                else{
                    scheduleIdToVerifyDeletionMap.put(assignment.pse__Schedule__r.id,false);  
                    break;
                } 
            }
            for(pse__Schedule__c schedule : deletedList){
                if((scheduleIdToVerifyDeletionMap.containsKey(schedule.id) && !scheduleIdToVerifyDeletionMap.get(schedule.id))
                   || !scheduleIdToVerifyDeletionMap.containsKey(schedule.id) ) {
                    schedule.addError('You are not authorised to delete this Schedule record');
                }
            }
        }         
    }    
}