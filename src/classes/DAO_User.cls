public class DAO_User extends fflib_SObjectDomain {
    
    /**
    * Constructor of this class
    * @params sObjectList List<SObject>
    */
    public DAO_User(List<SObject> sObjectList) {
        super(sObjectList);
    }
    
    /**
    * Constructor Class for construct new Instance of This Class
    */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_User(sObjectList);
        }
    }
    
    /**
    * This method is used for before insert of the User trigger.
    * @return void
    */
    public override void onBeforeInsert() {
        //if(!isUserSystemAdmin()){
            // Comment out below line as a hotfix, need to refactor again
            // blockRecordtoSave((List<User>)Records);
        //}
        DAOH_User.setupFieldValues((List<User>)records, null);
        DAOH_User.checkduplicateEmployeeNumber((List<User>)records, null);
        DAOH_User.updateResetPassword((List<User>)records, null);
        DAOH_User.assignCallCenterManagePackage((List<User>)records);
        DAOH_User.usersEmployeeNumberValidation((List<User>)records, null);
        DAOH_User.updateServiceCloudUserValue((List<User>)records, null);
        DAOH_User.checkCSHDefaultQueueAssignment((List<User>)records);
        DAOH_User.setFieldValues((List<User>)records, null);
        DAOH_User.setWDFieldSyncDate((List<User>)records, null);
        DAOH_User.setUserConfigJson((List<User>) Records, null);
        DAOH_User.setAccessExpiryDate((List<User>) Records, null);
    }
    
    /**
    * This method is used for after insert of the User trigger.
    * @return void
    */
    public override void onAfterInsert() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_User.manageTpaRecordSharing((List<User>)records, null);
        }
        DAOH_User.addPermissionSetAfterInsertCSM((List<User>)records);
        String jsonUserList = JSON.serialize((List<User>)records);
		if(Schema.sObjectType.Contact.isAccessible()){
            DAOH_User.createOrUpdateContactForUsers(jsonUserList, null);    
        }            
        DAOH_User.updateContactOnPortalUser((List<User>)Records);
        DAOH_User.insertAuditLog((List<User>)Records,null);
        DAOH_User.sendEmails((List<User>)Records, null);
        DAOH_User.updatePRMSuperUser((List<User>)Records,null);
        //DAOH_User.updateContactPseResource((List<User>)Records, null);
    }
    
    /**
    * This method is used for before update of the User trigger.
    * @params  Map<Id, SObject> existingRecords
    * @return void
    */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        //if(!isUserSystemAdmin()){
            // DAOH_User.deactivateCommunityUser((List<User>)records, (Map<Id, User>)existingRecords);
            // Comment out below line as a hotfix, need to refactor again
            // blockRecordtoSave((List<User>)Records);
        //}
        DAOH_User.setUserConfigJson((List<User>) Records, (Map<Id, User>)existingRecords); 
        DAOH_User.setupFieldValues((List<User>)records, (Map<Id, User>)existingRecords);
        DAOH_User.UserTerritory2AssociationAfterUpdateCSM((List<User>)records, (Map<Id, User>)existingRecords);
        DAOH_User.checkduplicateEmployeeNumber((List<User>)records, (Map<Id, User>)existingRecords);
        DAOH_User.updateResetPassword((List<User>)records, (Map<Id, User>)existingRecords);
        DAOH_User.assignCallCenterManagePackage((List<User>)records);
        //DAOH_User.usersEmployeeNumberValidation((List<User>)records,  (Map<Id, User>)existingRecords);
        DAOH_User.updateServiceCloudUserValue((List<User>)records,  (Map<Id, User>)existingRecords);
        DAOH_User.setFieldValues((List<User>)records, (Map<Id, User>)existingRecords);
        DAOH_User.setWDFieldSyncDate((List<User>)records, (Map<Id, User>)existingRecords);
        DAOH_User.updatePRMSuperUser((List<User>)records,(Map<Id, User>)existingRecords);
        DAOH_User.setAccessExpiryDate((List<User>) Records, (Map<Id, User>)existingRecords);
    }
    
    /**
    * This method is used for after update of the User trigger.
    * @params  Map<Id, SObject> existingRecords
    * @return void
    */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_User.manageTpaRecordSharing((List<User>)records, (Map<Id,User>)existingRecords);
        }
        DAOH_User.PermissionSetAfterUpdateCSM((List<User>)records, (Map<Id,User>)existingRecords);
        if(!CON_CRM.preventContactUpdate && CON_OWF.runFutureJob && CON_PEP.runFutureMethod) {
            String jsonUserList = JSON.serialize((List<User>)records);
            String jsonUserOldMap = JSON.serialize((Map<Id, User>)existingRecords);
			if(Schema.sObjectType.Contact.isAccessible()){
                DAOH_User.createOrUpdateContactForUsers(jsonUserList, jsonUserOldMap);
			}	
        }
        DAOH_User.updateContactOnPortalUser((List<User>)Records);
        DAOH_User.insertAuditLog((List<User>)Records,(Map<Id,User>)existingRecords);
        DAOH_User.sendEmails((List<User>)Records, (Map<Id,User>)existingRecords);
        //DAOH_User.updateContactPseResource((List<User>)Records, (Map<Id,User>)existingRecords);
    }
    
    private boolean isUserSystemAdmin(){
        string adminProfile='System Administrator';
        string serviceProfile='Service User';
        string salesProfile='Sales User';
        String pName = [Select Name from Profile where Id = :UserInfo.getProfileId()].Name;
        List<PermissionSetAssignment> pSAssignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Label = 'Advanced Administrator' AND AssigneeId = :UserInfo.getUserId()];
        if(pName == adminProfile || (pName == serviceProfile && (pSAssignments != null && pSAssignments.size()>0)) || pName == salesProfile){
            return true;
        }else{
            return false;
        }    
    }
    
    //use to add custom Error on the Record
    
    private void blockRecordtoSave(List<User> records){
        for(User usr: records){
            usr.addError('You cannot Create/Update user record.');
        }
    }
}