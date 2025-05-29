public class DAOH_User {
    
	//under ESPSFDCQI-17201 used in user contact sync method
	public static List<Contact> contactListToUpdate = new List<Contact>();
    public static List<User> userListToUpdate = new List<User>();
	
    /**
     * This method is used for add KB Article Manager to the user when the Article Manager checkbox selected.
     * @params  newList List<Contact>,Map<Id,Contact> oldMap
     * @return  void
     */
    public static void addPermissionSetAfterInsertCSM(List<User> newList){
        String[] sUsers = new List<String>();
        PermissionSet ps = null;
        for (User c : newList) {
            if(c.Article_Manager__c == true) {
                sUsers.add(c.Id);
            }
        }
        
        if(sUsers.isEmpty() == false){
            ps = Database.query('SELECT Id, Name FROM PermissionSet WHERE IsOwnedByProfile = False and Name=\'KB_Article_Manager\' Limit 1');
            if(sUsers.isEmpty() == false && ps != null){
                SRV_CSM_AssignPermissionSet.AssignPermissionSetToUsers(sUsers, ps.Id);
            }
        }
        
    }
    /**
    * This method is used for add KB Article Manager to the user when the Article Manager checkbox selected.
    * @params  newList List<User>
    * @return  void
    */
    public static void PermissionSetAfterUpdateCSM(List<User> newList,Map<Id,User> oldMap){
        String[] sUsers = new List<String>();
        String[] sDeleteUsers = new List<String>();
        PermissionSetAssignment psa =null;
        List<PermissionSetAssignment> listPSAList = null;
        PermissionSet ps =null;
        for (User c : newList) {
            if(c.Article_Manager__c != null && c.Article_Manager__c != oldMap.get(c.Id).Article_Manager__c){
                if(c.Article_Manager__c == true) {
                    sUsers.add(c.Id);
                }else if(c.Article_Manager__c == false) {
                    sDeleteUsers.add(c.Id);
                }    
            }
        }
        if(sUsers.isEmpty() == false || sDeleteUsers.isEmpty() == false){
            ps = Database.query('SELECT Id, Name FROM PermissionSet WHERE IsOwnedByProfile = False and Name=\'KB_Article_Manager\' Limit 1');
        }
        
        if(sUsers.isEmpty() == false  && ps!=null){
            SRV_CSM_AssignPermissionSet.AssignPermissionSetToUsers(sUsers, ps.Id);
        }
        if(sDeleteUsers.isEmpty() == false && ps!=null){
            SRV_CSM_AssignPermissionSet.DeletePermissionSetToUsers(sDeleteUsers, ps.Id); 
        }
    }

    public static void updateContactOnPortalUser(List<User> userList){
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> prmUserIdSet = new Set<Id>();
        Set<Id> profileIdSet = new Set<Id>();
        for(User userRecord : userList) {
           if(userRecord.ContactId != null){
               userIdSet.add(userRecord.Id);
               profileIdSet.add(userRecord.profileId);
           }
        }
        
        Map<Id, Profile> profileMap = UTL_GLOBAL.getProfile(profileIdSet);
        
        for(User usrObj : userList)
        {
            if(profileMap != null && profileMap.size()>0){
                if(profileMap.containsKey(usrObj.ProfileId) && profileMap.get(usrObj.ProfileId).Name == CON_PEP.S_P_PEP_COMMUNITY)
                {
                    prmUserIdSet.add(usrObj.Id);
                }
            }
        }
        
        try{
            if(userIdSet.size()>0){
                updateContactOnUserId(userIdSet);
                updatePRMContactOnUserId(prmUserIdSet);
            }
        }
        catch(Exception e){
            e.getMessage();
        }
    }
    
    @Future
    private static void updateContactOnUserId(Set<Id> userIdSet){
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> profileIdSet = new Set<Id>();
        List<User> userList = [SELECT Id, ProfileId, isActive, ContactId, LastLoginDate, Email FROM User WHERE Id IN: userIdSet];
        DateTime lastLogin ;
        lastLogin = userList[0].LastLoginDate;
        for(User userRecord : userList) {
            profileIdSet.add(userRecord.profileId);
            contactIdSet.add(userRecord.contactId);
        }
        
        Id contactRecordId = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        Map<Id, Profile> profileMap = UTL_GLOBAL.getProfile(profileIdSet);
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, CSH_User__c, Email FROM Contact WHERE Id IN :contactIdSet AND RecordTypeId = :contactRecordId]);
        
        if(contactMap != null && contactMap.size()>0){
        for(User usrObj : userList){
        if(contactMap != null && profileMap != null && contactMap.containsKey(usrObj.ContactId)){
            if(profileMap.get(usrObj.ProfileId).Name == CON_CSM.S_P_CSM_COMMUNITY || profileMap.get(usrObj.ProfileId).Name == CON_CSM.S_P_CUSTOMER_COMMUNITY 
              || profileMap.get(usrObj.ProfileId).Name == CON_CSM.S_P_TPA_COMMUNITY ){
                contactMap.get(usrObj.ContactId).Salesforce_Customer_User__c = usrObj.Id;
                if(contactMap.get(usrObj.ContactId).Email != usrObj.Email){
                    contactMap.get(usrObj.ContactId).Email = usrObj.Email;
                }
                if(usrObj.IsActive){
                    contactMap.get(usrObj.ContactId).CSH_User__c = CON_CSM.S_YES;
                }
                else{
                    contactMap.get(usrObj.ContactId).CSH_User__c = CON_CSM.S_INACTIVE;
                }
            }
            else{
                contactMap.get(usrObj.ContactId).CSH_User__c = CON_CSM.S_NO;
            }
//            contactMap.get(usrObj.ContactId).CSH_User_Last_connection_date__c = lastlogin ;
        }
        }
        update contactMap.values();
        }
    }
  
    @Future
    private static void updatePRMContactOnUserId(Set<Id> userIdSet){
        Set<Id> contactIdSet = new Set<Id>();
        List<Id> listUserId = new List<Id>(userIdSet);
        List<User> userList = SLT_User.getUsersByUserIds(listUserId);
        for(User userRecord : userList) {
            contactIdSet.add(userRecord.contactId);
        }
        
        Set<String> fieldSetContact=new Set<String>{'Id','Name','PRM_User__c','Title','MobilePhone','Phone','Salesforce_Customer_User__c','Portal_Role__c'};
        Map<Id, Contact> contactMap = new Map<Id, Contact>(new SLT_Contact().selectContactByFieldSet(contactIdSet, fieldSetContact));
        
        if(contactMap != null  && contactMap.size()>0){
            for(User usrObj : userList){
                if(contactMap.containsKey(usrObj.ContactId)){
                    contactMap.get(usrObj.ContactId).Salesforce_Customer_User__c=usrObj.Id;
                    if(usrObj.IsActive){
                        contactMap.get(usrObj.ContactId).PRM_User__c = CON_PEP.S_ACTIVE;                            
                        }
                        else{
                            contactMap.get(usrObj.ContactId).PRM_User__c = CON_PEP.S_INACTIVE;                            
                        }
                    if(usrObj.UserRole.Name.contains('Partner User'))
                    {
                        contactMap.get(usrObj.ContactId).Portal_Role__c = 'Consultant';
                    }
                    else{
                        contactMap.get(usrObj.ContactId).Portal_Role__c = 'Partner Manager';
                    }
	                if(usrObj.Title != null){
                        contactMap.get(usrObj.ContactId).Title = usrObj.Title;
                    }
                    if(usrObj.MobilePhone != null){
                        contactMap.get(usrObj.ContactId).MobilePhone = usrObj.MobilePhone;
                    }
                    if(usrObj.Phone != null){
                        contactMap.get(usrObj.ContactId).Phone = usrObj.Phone;
                    }
                }
            }
            update contactMap.values();
        }
    }

    public static void setupFieldValues(List<User> newList, Map<Id, User> oldMap){
        for (User u : newList){
            //  If active user is inserted or existing inactive user is updated and active is changed from false to true
            if (u.IsActive == true && (oldMap == null || oldMap.get(u.id).IsActive != u.IsActive)){
                u.Activation_Date__c = system.now();
            }
        }
    }
    
    /**
    * @author dirish.bhaugeerutty
    * This method is used by the batch BCH_CSM_BatchQueueUser to create or del queue records
    * @return void
    */
    public static void manageQueuesRelations(){

        Map<Id, Group> groupsById = new Map<Id, Group>([SELECT Id, Name,Email FROM Group WHERE type ='Queue' LIMIT 50000]);
        Map<Id,Queue_User_Relationship__c> existingQRGrpIds = new Map<Id,Queue_User_Relationship__c>();
        List<Queue_User_Relationship__c> newQueueRelations = new List<Queue_User_Relationship__c>();
        List<Queue_User_Relationship__c> updateQueueRelations = new List<Queue_User_Relationship__c>();

        //Look for group Ids which have been deleted
        List<Queue_User_Relationship__c> queueUserRelationsToDel = [SELECT Id, Name, TECH_UserGroupIdCombination__c, 
        Type__c, User__c, Group_Id__c, Queue_Email__c
        FROM Queue_User_Relationship__c 
        WHERE Group_Id__c NOT IN: groupsById.keySet() LIMIT 50000];

        //delete any record where Group_Id__c = deleted group Id
        if(queueUserRelationsToDel.size() > 0){
            try{
                Database.delete(queueUserRelationsToDel);
            }catch(Exception e){
                System.debug('An error occured deleting redundant queue user relations');
            }
        }        

        //Look for all Queue_User_Relationship__c of type = 'Queue'
        List<Queue_User_Relationship__c> queueUserRelations = [SELECT Id, Name, TECH_UserGroupIdCombination__c, 
        Type__c, User__c, Group_Id__c, Queue_Email__c 
        FROM Queue_User_Relationship__c 
        WHERE Type__c ='Queue' AND Group_Id__c != NULL LIMIT 50000];        

        //store all existing relationships Ids
        for(Queue_User_Relationship__c curRel: queueUserRelations){
            existingQRGrpIds.put(curRel.Group_Id__c,curRel);
        }

        Queue_User_Relationship__c newQueueRel;
        Queue_User_Relationship__c updateQueueRel;
        for(Id currId : groupsById.keySet()){
            
            //check if relation absent for current Id
            if(!existingQRGrpIds.keySet().contains(currId)){
                
                //create relation
                newQueueRel = new Queue_User_Relationship__c();
                newQueueRel.Name = groupsById.get(currId).Name;
                newQueueRel.Type__c = 'Queue';
                newQueueRel.Group_Id__c = currId;

                newQueueRelations.add(newQueueRel);
            }else if(existingQRGrpIds.keySet().contains(currId) && (!(existingQRGrpIds.get(currId).Name.equalsIgnoreCase(groupsById.get(currId).Name)) || (groupsById.get(currId).Email != null && !groupsById.get(currId).Email.equalsIgnoreCase(existingQRGrpIds.get(currId).Queue_Email__c)) ) ){
                updateQueueRel = existingQRGrpIds.get(currId);
                updateQueueRel.Name = groupsById.get(currId).Name;
                if((groupsById.get(currId).Email != null && !groupsById.get(currId).Email.equalsIgnoreCase(existingQRGrpIds.get(currId).Queue_Email__c))){
                    updateQueueRel.Queue_Email__c = groupsById.get(currId).Email;
                }else{
                    updateQueueRel.Queue_Email__c = null;
                }
                updateQueueRelations.add(updateQueueRel);
            }
        }

        if(newQueueRelations.size() > 0){
            //insert new queues to DB
            try{
                Database.insert(newQueueRelations);
            }catch(Exception e){
                System.debug('An error occured during insertion of new queue: '+e);
            }
        }
        
        if(updateQueueRelations.size() > 0){
            //Update Queue Name Change
            try{
                Database.update(updateQueueRelations);
            }catch(Exception e){
                System.debug('An error occured during updating the queue: '+e);
            }
        }
    }


    /**
    * @author dirish.bhaugeerutty
    * This method is used by the batch BCH_CSM_BatchQueueUser to create or del queue records
    * @return void
    */
    public static void manageUserQueuesRelations(List<Group> aGroups){
        
        List<Queue_User_Relationship__c> newQueueUserRelations = new List<Queue_User_Relationship__c>();
        List<Queue_User_Relationship__c> queueUserRelationsToDel = new List<Queue_User_Relationship__c>();
        List<Queue_User_Relationship__c> updateQueueUserRelations = new List<Queue_User_Relationship__c>();
        Map<Id,OutOfOffice> oooMap = new Map<Id,OutOfOffice>();
        //customKey = userId + Group_Id__c
        Map<String, Queue_User_Relationship__c> queueUserRelationByCustomKey = new Map<String, Queue_User_Relationship__c>();
        Set<Id> existingUserIds = new Set<Id>();
        List<GroupMember> currentGroupMembers = null;
        Id gId = aGroups[0].Id;
        // Get the users.
        User[] users = Database.query('SELECT User.Id FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE group.Type =\'Queue\' AND group.Id =: gId) And ContactId = null LIMIT 50000');
        if(users != null && !users.isEmpty()){
            // Get the Ids.
            Id[] userIds = new List<Id>(new Map<Id, User>(users).keySet());
            
            //look for current group members
            currentGroupMembers = Database.query('SELECT group.Id, group.Name, UserOrGroupId FROM GroupMember WHERE group.Type =\'Queue\' AND group.Id =: gId AND UserOrGroupId IN: userIds LIMIT 50000');
            
            //Get OutofOffice Users
            List<OutOfOffice> oooUsers = Database.query('SELECT UserId,StartDate,EndDate FROM OutOfOffice WHERE UserId IN : userIds');
            for(OutOfOffice ooo : oooUsers){
                oooMap.put(ooo.UserId, ooo);
            }
        }
        //Get all queue user relationship for current group
        List<Queue_User_Relationship__c> queueUserRelations = Database.query('SELECT Id, Name, TECH_UserGroupIdCombination__c,Type__c, User__c, User__r.IsActive, Group_Id__c,OutOfOffice_StartDate__c,OutOfOffice_EndDate__c FROM Queue_User_Relationship__c WHERE Group_Id__c =: gId LIMIT 50000');
        
        Id currentGroupId;
        for(Queue_User_Relationship__c currQUserRel : queueUserRelations){
            
            if(currQUserRel.Type__c =='User'){
                queueUserRelationByCustomKey.put(currQUserRel.TECH_UserGroupIdCombination__c, currQUserRel);
            }else{
                currentGroupId = currQUserRel.Id;
            }
        }
        
        Queue_User_Relationship__c newUserRel;
        Queue_User_Relationship__c updateQueueRel;
        if(currentGroupMembers != null && !currentGroupMembers.isEmpty()){
        for(GroupMember currGrpMem : currentGroupMembers){
            
            String customKey =  String.valueOf(currGrpMem.UserOrGroupId) + String.valueOf(currGrpMem.group.Id);
            
            existingUserIds.add(currGrpMem.UserOrGroupId);
            
            //new members
            if(!queueUserRelationByCustomKey.containsKey(customKey)){
                
                newUserRel = new Queue_User_Relationship__c();
                
                newUserRel.Name = currGrpMem.group.Name;
                newUserRel.User__c = currGrpMem.UserOrGroupId;
                newUserRel.Type__c = 'User';
                newUserRel.Group_Id__c = currGrpMem.group.Id;
                newUserRel.TECH_QueueUser__c = currentGroupId;
                if(oooMap != null && oooMap.containsKey(currGrpMem.UserOrGroupId)){
                    newUserRel.OutOfOffice_StartDate__c = oooMap.get(currGrpMem.UserOrGroupId).StartDate;
                    newUserRel.OutOfOffice_EndDate__c = oooMap.get(currGrpMem.UserOrGroupId).EndDate;
                }
                newQueueUserRelations.add(newUserRel);
            }else if(queueUserRelationByCustomKey.containsKey(customKey) && queueUserRelationByCustomKey.get(customKey).Name != currGrpMem.group.Name){
                //Updating Queue Name in Queue User Relation
                updateQueueRel = queueUserRelationByCustomKey.get(customKey);
                updateQueueRel.Name = currGrpMem.group.Name;
                if(oooMap != null && oooMap.containsKey(updateQueueRel.User__c)){
                    updateQueueRel.OutOfOffice_StartDate__c = oooMap.get(updateQueueRel.User__c).StartDate;
                    updateQueueRel.OutOfOffice_EndDate__c = oooMap.get(updateQueueRel.User__c).EndDate;
                }
                updateQueueUserRelations.add(updateQueueRel);
            }else if(queueUserRelationByCustomKey.containsKey(customKey) && oooMap != null && oooMap.containsKey(queueUserRelationByCustomKey.get(customKey).User__c)){
                updateQueueRel = queueUserRelationByCustomKey.get(customKey);
                if(updateQueueRel.OutOfOffice_StartDate__c != oooMap.get(updateQueueRel.User__c).StartDate || updateQueueRel.OutOfOffice_EndDate__c != oooMap.get(updateQueueRel.User__c).EndDate){
                    updateQueueRel.OutOfOffice_StartDate__c = oooMap.get(updateQueueRel.User__c).StartDate;
                    updateQueueRel.OutOfOffice_EndDate__c = oooMap.get(updateQueueRel.User__c).EndDate;
                    updateQueueUserRelations.add(updateQueueRel);    
                }
                
            }
        }
    }
        /** used to not delete the user record from Queue_User_Relationship__c  object if user is assigned to only one queue **/
        List<String> usrIds = new List<String>();
        for(Queue_User_Relationship__c currRel : queueUserRelations){
            
            //departing members
            if(currRel.Type__c=='User' && !existingUserIds.contains(currRel.User__c)){
                queueUserRelationsToDel.add(currRel);
                usrIds.add(currRel.User__c);
            }
        }  
        if(usrIds!= null && !usrIds.isEmpty()){
            List<AggregateResult> results = Database.query('select User__c  userId, COUNT(Id) cnt from Queue_User_Relationship__c where Type__c =\'User\' and  User__c in :usrIds group by User__c having COUNT(Id) > 1 limit 1000');
            if(results != null){
                usrIds.clear();
                for(AggregateResult res : results){
                    if(Integer.valueOf(res.get('cnt')) > 1){
                        usrIds.add(String.valueOf(res.get('userId')));
                    }
                }
                for(integer i = 0; i< queueUserRelationsToDel.size() ; i++ ){
                    //departing members
                    if(queueUserRelationsToDel[i].Type__c == 'User' && queueUserRelationsToDel[i].User__r.IsActive && !usrIds.contains(queueUserRelationsToDel[i].User__c)){
                        queueUserRelationsToDel.remove(i);
                    }
                }    
            }    
        }
        
        
        if(newQueueUserRelations.size() > 0){
            
            try{
                Database.insert(newQueueUserRelations);
            }catch(Exception e){
                System.debug('An error occured creating queue user relations '+e);
            }
        }
        if(updateQueueUserRelations.size() > 0){
            
            try{
                Database.update(updateQueueUserRelations);
            }catch(Exception e){
                System.debug('An error occured updating queue name '+e);
            }
        }
        if(queueUserRelationsToDel.size() > 0){
            try{
                Database.delete(queueUserRelationsToDel);
            }catch(Exception e){
                System.debug('An error occured deleting queue user relations '+e);
            }
        }
    }
    
    /**
     * This method is used update the contact records related to the user by using User Contact Sync Custoom Setting.
     * @params jsonUserList String
     * @params jsonUserOldMap String
     * @return  void
     */  
    public static void createOrUpdateContactForUsers(String jsonUserList, String jsonUserOldMap) {
        List<User> newList = (List<User>)JSON.deserialize(jsonUserList, List<User>.Class);
        Map<Id, User> oldMap;
        if(jsonUserOldMap != null) {
            oldMap = (Map<Id, User>)JSON.deserialize(jsonUserOldMap, Map<Id, User>.Class);
        }
        List<String> employeeNumberList = new List<String>();
        Set<Id> salesforceUserIdSet = new set<Id>();
        /* Get EmployeeNumber List and Salesforce User Id Set*/
        for(User usr : newList) {
            if(!usr.IsPortalEnabled) {
                salesforceUserIdSet.add(usr.id);
            }
            if(usr.EmployeeNumber != null && usr.EmployeeNumber != CON_CRM.NA_SLASH_STRING && usr.EmployeeNumber != CON_CRM.NA_STRING){
                employeeNumberList.add(usr.EmployeeNumber);
            }
        }
        Set<String> fieldSet = new Set<String>();
        fieldSet.add(CON_CRM.SALESFORCE_USER);
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        /* Get all the Fields information from User Contact Sync Custom Setting*/
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(CON_CRM.USER_CONTACT_SYNC).getDescribe().fields.getMap();
        List<Schema.describefieldresult> listOfDescribeFields = new List<Schema.describefieldresult>();
        for(Schema.SObjectField sfield : fieldMap.Values()) {
            listOfDescribeFields.add(sfield.getDescribe());
        }
        SObject userContactSync = User_Contact_Sync__c.getInstance();
        /* Fetching Custom Setting fields into a Set*/
        for(Schema.describefieldresult dfield : listOfDescribeFields) {
            if(dfield.getName().contains(CON_CRM.UNDERSCORE_C)) {
                String synchField = String.valueOf(userContactSync.get(dfield.getName()));
                if(synchField != null) {
                    fieldSet.add(synchField.split(CON_CRM.COMMA)[1]);
                }
            }
        }
        
        /* User to Contact Sync works for Salesforce and Salesforce Platform user license.*/
        Set<String> setOfUserLicense = new Set<String>{CON_CRM.SALESFORCE_LICENSE, CON_CRM.SALESFORCE_PLATFORM_LICENSE};
        Set<String> userFieldSet = new Set<String>{'User_License_Type__c','EmployeeNumber'};
        Map<Id, User> userIdToUserMap = new Map<Id, User>();
        /*Creating a Map of User Id as key and User as value.*/
        if(salesforceUserIdSet.size() > 0) {
            userIdToUserMap = new SLT_User().selectByUserId(salesforceUserIdSet, userFieldSet);
        }
        
        List<Contact> existingContacts = new List<Contact>();
        fieldSet.add('EmployeeNumber__c');
        fieldSet.add('RecordTypeId');
        fieldSet.add('Workday_Field_Sync_Date__c');
        fieldSet.add('Salesforce_User__c');
        /* Creating a Map of Existing Contact with Contact EmployeeNUmber as key and contact as value.*/
        List<Contact> existingContactsBasedOnEmployeeNumberList = new List<Contact>();
        Map<String, Contact> existingContactsBasedOnEmployeeNumberMap = new Map<String, Contact>();
        if(employeeNumberList.size() > 0 && (jsonUserOldMap == null || userIdToUserMap != null)){
            existingContactsBasedOnEmployeeNumberList = new SLT_Contact().getContactByEmployeeNumbers(fieldSet,employeeNumberList);
            for(Contact con : existingContactsBasedOnEmployeeNumberList) {
                if(con.RecordTypeId == CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID){
                    existingContactsBasedOnEmployeeNumberMap.put(con.EmployeeNumber__c, con);    
                }
            }    
        }
        /* Creating a Map of User Id as Key and Contact associated to it as value.*/
        Map<Id, Contact> userIdToContactMap = new Map<Id, Contact>();
        if(jsonUserOldMap != null) {
            existingContacts = new SLT_Contact().selectBySalesforceUserIdList(salesforceUserIdSet, fieldSet);
            for(Contact con : existingContacts) {
                userIdToContactMap.put(con.Salesforce_User__c, con);
            }
        }
        Boolean isContactCreated = false;
        SObject newContact;
        SObject clonedNewUser;
        SObject clonedOldUser;
        SObject updateContact;
        Boolean isContactUpdated;
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Contact.SobjectType
            }
        );
        Boolean toCommit = false;
        List<User> userListToUpdateClone = new List<User>();
        
        /* Stating of the loop on User List*/
        for(User usr : newList) {
            try {
                /* userIdToUserMap should contains the user Id.*/
                if(userIdToUserMap.containsKey(usr.id)) {
                    String currUserLicense = userIdToUserMap.get(usr.id).User_License_Type__c;
                    /* Check for User license*/
                    if(!setOfUserLicense.contains(currUserLicense)){
                        break;
                    }
                    /* No Contact associated the user. New Contact is Created.*/
                    if(!userIdToContactMap.containsKey(usr.Id) && !existingContactsBasedOnEmployeeNumberMap.containsKey(usr.EmployeeNumber)) {
                        newContact = new Contact();
                        clonedNewUser = usr.clone(true, true, false, false);
                        /* Sync Contact Fields as per custom setting field values*/
                        for(Schema.describefieldresult dfield : listOfDescribeFields) {
                            if(dfield.getName().contains(CON_CRM.UNDERSCORE_C)) {
                                String synchField = String.valueOf(userContactSync.get(dfield.getName()));
                                if(synchField != null && (synchField.split(CON_CRM.COMMA)[2].equalsIgnoreCase(CON_CRM.BOTH) || synchField.split(CON_CRM.COMMA)[2].equalsIgnoreCase(CON_CRM.USER_TO_CONTACT))) {
                                    if(dfield.getName() == CON_CRM.RECORD_ACTIVE) {
                                        Boolean isActive = Boolean.valueOf(clonedNewUser.get(synchField.split(CON_CRM.COMMA)[0]));
                                        newContact.put(synchField.split(CON_CRM.COMMA)[1], !isActive);
                                    } else if(dfield.getName() == CON_CRM.RECORD_LICENSE_EXPIRY || dfield.getName() == CON_CRM.RECORD_HIRE_DATE) {
                                        Date dateField = Date.valueOf(clonedNewUser.get(synchField.split(CON_CRM.COMMA)[0]));
                                        newContact.put(synchField.split(CON_CRM.COMMA)[1], dateField);
                                    } else if(dfield.getName() == CON_CRM.RECORD_EMPLOYEE_NO) {
                                        String employeeNo = String.valueOf(clonedNewUser.get(synchField.split(CON_CRM.COMMA)[0]));
                                        if(employeeNo == null || employeeNo == '' || employeeNo.isNumeric()) {
                                            newContact.put(synchField.split(CON_CRM.COMMA)[1], employeeNo);
                                        }
                                    } else if(dfield.getName() == CON_CRM.RECORD_COUNTRY) {
                                        String country = String.valueOf(clonedNewUser.get(synchField.split(CON_CRM.COMMA)[0]));
                                        if(country != null && Delivery_Country_Mapping__c.getValues(country) != null) {
                                            newContact.put(synchField.split(CON_CRM.COMMA)[1], Delivery_Country_Mapping__c.getValues(country).ISOCODE__c);
                                        }
                                    } else {
                                        newContact.put(synchField.split(CON_CRM.COMMA)[1], usr.get(synchField.split(CON_CRM.COMMA)[0]));
                                    }
                                    isContactCreated = true;
                                }
                            }
                        }
                        if(isContactCreated) {
                            //newContact.put(CON_CRM.SALESFORCE_USER, usr.id);
                            /* Copy Workday_Field_Sync_Date__c from User to Contact*/
                            newContact.put('Workday_Field_Sync_Date__c', clonedNewUser.get('Workday_Field_Sync_Date__c'));
                            newContact.put(CON_CRM.RECORD_TYPE_ID, CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID);
                            newContact.put('AccountId', Org_Default_Setting__c.getInstance().Default_Account_Id__c);
                            //uow.registerNew((Contact)newContact);
                            clonedNewUser.put('User_To_Contact_Sync_Error__c', '');
                            userListToUpdate.add((User)clonedNewUser);
                            contactListToUpdate.add((Contact)newContact);
                            toCommit = true;
                        }
                        /* Contact associated to the User with Same Employee Number*/
                    }else if(existingContactsBasedOnEmployeeNumberMap.containsKey(usr.EmployeeNumber)){
                        isContactUpdated = false;
                        clonedNewUser = usr.clone(true, true, false, false);
                        updateContact = existingContactsBasedOnEmployeeNumberMap.get(usr.EmployeeNumber).clone(true, true, false, false);
                        /* Check for Workday_Field_Sync_Date__c on User and Contact*/
                        if(updateContact.get('Workday_Field_Sync_Date__c') != clonedNewUser.get('Workday_Field_Sync_Date__c')) {
                            /* Sync Contact Fields as per custom setting field values*/
                            for(Schema.SObjectField sfield : fieldMap.Values()) {
                                Schema.describefieldresult dfield = sfield.getDescribe();
                                if(dfield.getName().contains(CON_CRM.UNDERSCORE_C)) {
                                    String synchField = String.valueOf(userContactSync.get(dfield.getName()));
                                    if(synchField != null) {
                                        if(synchField != null && (synchField.split(CON_CRM.COMMA)[2].equalsIgnoreCase(CON_CRM.BOTH) || synchField.split(CON_CRM.COMMA)[2].equalsIgnoreCase(CON_CRM.USER_TO_CONTACT))) {
                                            if(dfield.getName() == CON_CRM.RECORD_ACTIVE) {
                                                Boolean isActive = Boolean.valueOf(clonedNewUser.get(synchField.split(CON_CRM.COMMA)[0]));
                                                updateContact.put(synchField.split(CON_CRM.COMMA)[1], !isActive );
                                            } else if(dfield.getName() == CON_CRM.RECORD_LICENSE_EXPIRY || dfield.getName() == CON_CRM.RECORD_HIRE_DATE) {
                                                Date dateField = Date.valueOf(clonedNewUser.get(synchField.split(CON_CRM.COMMA)[0]));
                                                updateContact.put(synchField.split(CON_CRM.COMMA)[1], dateField);
                                            } else if(dfield.getName() == CON_CRM.RECORD_EMPLOYEE_NO) {
                                                String employeeNo = String.valueOf(clonedNewUser.get(synchField.split(CON_CRM.COMMA)[0]));
                                                if(employeeNo == null || employeeNo == '' || employeeNo.isNumeric()) {
                                                    updateContact.put(synchField.split(CON_CRM.COMMA)[1], employeeNo);
                                                }
                                            } else if(dfield.getName() == CON_CRM.RECORD_COUNTRY) {
                                                String country = String.valueOf(clonedNewUser.get(synchField.split(CON_CRM.COMMA)[0]));
                                                if(country != null && Delivery_Country_Mapping__c.getValues(country) != null) {
                                                    updateContact.put(synchField.split(CON_CRM.COMMA)[1], Delivery_Country_Mapping__c.getValues(country).ISOCODE__c);
                                                }
                                            } else {
                                                updateContact.put(synchField.split(CON_CRM.COMMA)[1], usr.get(synchField.split(CON_CRM.COMMA)[0]));
                                            }
                                            //updateContact.put(CON_CRM.SALESFORCE_USER, usr.id);
                                            isContactUpdated = true;
                                        }
                                    }
                                }
                            }
                        }
                        if(isContactUpdated) {
                            /* Copy Workday_Field_Sync_Date__c from User to Contact*/
                            updateContact.put('Workday_Field_Sync_Date__c', clonedNewUser.get('Workday_Field_Sync_Date__c'));
                            clonedNewUser.put('User_To_Contact_Sync_Error__c', '');
                            //uow.registerDirty((Contact)updateContact);
                            userListToUpdate.add((User)clonedNewUser);
                            contactListToUpdate.add((Contact)updateContact);
                            toCommit = true;
                        }
                    }
                    else {
                        isContactUpdated = false;
                        clonedNewUser = usr.clone(true, true, false, false);
                        clonedOldUser = oldMap.get(usr.id).clone(false, true, false, false);
                        updateContact = userIdToContactMap.get(usr.Id).clone(true, true, false, false);
                        if( Boolean.valueOf(clonedOldUser.get('IsActive')) && !Boolean.valueOf(clonedNewUser.get('IsActive'))){
                            updateContact.put('pse__Is_Resource_Active__c',false);
                            isContactUpdated = true;
                        } 
                        /* Check for Workday_Field_Sync_Date__c on User and Contact*/
                        if(updateContact.get('Workday_Field_Sync_Date__c') != clonedNewUser.get('Workday_Field_Sync_Date__c')) {
                            /* Sync Contact Fields as per custom setting field values*/
                            for(Schema.SObjectField sfield : fieldMap.Values()) {
                                Schema.describefieldresult dfield = sfield.getDescribe();
                                if(dfield.getName().contains(CON_CRM.UNDERSCORE_C)) {
                                    String synchField = String.valueOf(userContactSync.get(dfield.getName()));
                                    if(synchField != null) {
                                        if((synchField.split(CON_CRM.COMMA)[2].equalsIgnoreCase(CON_CRM.BOTH) || synchField.split(CON_CRM.COMMA)[2].equalsIgnoreCase(CON_CRM.USER_TO_CONTACT)) ) {
                                            if(dfield.getName() == CON_CRM.RECORD_ACTIVE) {
                                                Boolean isActive = Boolean.valueOf(clonedNewUser.get(synchField.split(CON_CRM.COMMA)[0]));
                                                updateContact.put(synchField.split(CON_CRM.COMMA)[1], !isActive );
                                            } else if(dfield.getName() == CON_CRM.RECORD_LICENSE_EXPIRY || dfield.getName() == CON_CRM.RECORD_HIRE_DATE) {
                                                Date dateField = Date.valueOf(clonedNewUser.get(synchField.split(CON_CRM.COMMA)[0]));
                                                updateContact.put(synchField.split(CON_CRM.COMMA)[1], dateField);
                                            } else if(dfield.getName() == CON_CRM.RECORD_EMPLOYEE_NO) {
                                                String employeeNo = String.valueOf(clonedNewUser.get(synchField.split(CON_CRM.COMMA)[0]));
                                                if(employeeNo == null || employeeNo == '' || employeeNo.isNumeric()) {
                                                    updateContact.put(synchField.split(CON_CRM.COMMA)[1], employeeNo);
                                                }
                                            } else if(dfield.getName() == CON_CRM.RECORD_COUNTRY) {
                                                String country = String.valueOf(clonedNewUser.get(synchField.split(CON_CRM.COMMA)[0]));
                                                if(country != null && Delivery_Country_Mapping__c.getValues(country) != null) {
                                                    updateContact.put(synchField.split(CON_CRM.COMMA)[1], Delivery_Country_Mapping__c.getValues(country).ISOCODE__c);
                                                }
                                            } else {
                                                updateContact.put(synchField.split(CON_CRM.COMMA)[1], usr.get(synchField.split(CON_CRM.COMMA)[0]));
                                            }
                                            isContactUpdated = true;
                                        }
                                    }
                                }
                            }
                            //updateContact.put(CON_CRM.SALESFORCE_USER, usr.id);
                        }
                        if(isContactUpdated) {
                            /* Copy Workday_Field_Sync_Date__c from User to Contact*/
                            updateContact.put('Workday_Field_Sync_Date__c', clonedNewUser.get('Workday_Field_Sync_Date__c'));
                            clonedNewUser.put('User_To_Contact_Sync_Error__c', '');
                            //uow.registerDirty((Contact)updateContact);
                            userListToUpdate.add((User)clonedNewUser);
                            contactListToUpdate.add((Contact)updateContact);
                            toCommit = true;
                        }
                    }
                }
            }
            /* Copy Error in transaction on User at User_To_Contact_Sync_Error__c field*/
            Catch(Exception e) {
                clonedNewUser = usr.clone(true, true, false, false);
                clonedNewUser.put('User_To_Contact_Sync_Error__c', e + ' ' + e.getStackTraceString());
                userListToUpdate.add((User)clonedNewUser);
                toCommit = true;
                
            }
        }
    }
    
    public static void updateLastNametoUnavailable(List<User> newList,Map<Id, User> oldMap){
        for (User c : newList) {
            if(Trigger.isInsert || (Trigger.IsUpdate && oldMap != null && oldMap.get(c.Id) != null && c.Unavailable__c != oldMap.get(c.Id).Unavailable__c )){
                if(!c.Unavailable__c) {
                    c.LastName = c.LastName.remove(' (Unavailable)');
                }else if(c.Unavailable__c){
                    c.LastName += ' (Unavailable)';
                }    
            }
        }
    }
    
    /**
    * This method is used to create TPA records sharing as per the user profile/role
    * @param newList List<User>
    * @return void
    */
    public static void manageTpaRecordSharing(List<User> newRecords, Map<Id,User> existingRecords) {
        Map<id, profile> mapTPAProfiles = UTL_TPA.getTPAProfileMap();
        //list<id> portalUsers = new list<id>();
        list<Id> TPProcessorSuperUserIDs = new list<Id>();
        //Key : User's Contact id
        //Value : User
        for(User user : newRecords) {
            if(user.IsPortalEnabled && user.IsActive && mapTPAProfiles.containsKey(user.ProfileId)) {
                Profile userProfile = mapTPAProfiles.get(user.ProfileId);
                // if(userProfile.Name.contains('Customer Community Login User') 
                // || userProfile.Name.contains('TPA Customer Community Plus Login User')) {
                //     portalUsers.add(user.id);
                // } else 
                if(existingRecords == null 
                || (existingRecords != null && user.ProfileId != existingRecords.get(user.Id).ProfileId)){
                    TPProcessorSuperUserIDs.add(user.Id);                    
                }
            }
        }

        Map<id, User> contactIdUserMap = new Map<id, User>();
        if(TPProcessorSuperUserIDs.size() > 0) {
            for(User user : [select id, name, Profile.Name, ContactId from user where id IN :TPProcessorSuperUserIDs]) {
                contactIdUserMap.put(user.ContactId, user);
            }
        }

        // if(portalUsers.size() > 0) {
        //     TGRH_TPA_User.manageSharing(portalUsers);
        // }

        System.Debug('contactIdUserMap.size() = ' + contactIdUserMap.size());

        if(contactIdUserMap.size() > 0) {
            List<Contact_Address_Crosswalk__c> conAddCrosswalkObjList = [SELECT Address__c, Contact__c from Contact_Address_Crosswalk__c where Contact__c IN :contactIdUserMap.keySet()];
            System.Debug('conAddCrosswalkObjList.size() = ' + conAddCrosswalkObjList.size());
            
            //Key : Address__c Id
            //Value : List of Contact Ids associted with Addresses ids
            Map<Id, List<Id>> addressIdContactIdListMap = new Map<Id, List<Id>>();
            for(Contact_Address_Crosswalk__c conAddCrosswalkObj: conAddCrosswalkObjList) {
                List<Id> tempCrosswalkList = new List<Id>(); // Contact id List
                if(addressIdContactIdListMap.containsKey(conAddCrosswalkObj.Address__c)) {
                    tempCrosswalkList = addressIdContactIdListMap.get(conAddCrosswalkObj.Address__c);
                }
                tempCrosswalkList.add(conAddCrosswalkObj.Contact__c);
                addressIdContactIdListMap.put(conAddCrosswalkObj.Address__c, tempCrosswalkList);
            }
            System.Debug('addressIdContactIdListMap.size() = ' + addressIdContactIdListMap.size());
            System.Debug('addressIdContactIdListMap = ' + addressIdContactIdListMap);
            
            if(addressIdContactIdListMap.size() > 0) {
                BCH_TPA_ManageTPARequestSharing TPProcessorSuperUsersBatch = new BCH_TPA_ManageTPARequestSharing();
                TPProcessorSuperUsersBatch.addressIdContactIdListMap = addressIdContactIdListMap;
                TPProcessorSuperUsersBatch.TPProcessorSuperUserIDs = TPProcessorSuperUserIDs;
                TPProcessorSuperUsersBatch.contactIdUserMap = contactIdUserMap;
                Database.executebatch(TPProcessorSuperUsersBatch, 2000);
            }
        }
    }

    /**
    * This method is used for add KB Article Manager to the user when the Article Manager checkbox selected.
    * @params  newList List<User>
    * @return  void
    */
    public static void UserTerritory2AssociationAfterUpdateCSM(List<User> newList,Map<Id,User> oldMap){
        Set<Id> setFalUserId = new Set<Id>();
        Map<Id, List<String>> mapUser = new Map<Id, List<String>>();
        Map<Id, List<String>> mapUserGroup = new Map<Id, List<String>>();
        Set<Id> setUserId = new Set<Id>();
        Set<Id> setGroupUserId = new Set<Id>();
        Set<Id> setDupUserId = new Set<Id>();
        UserTerritory2Association[] ut2as = new List<UserTerritory2Association>();
        List<GroupMember> ugList = new List<GroupMember>();
        List<GroupMember> delList = new List<GroupMember>();
        List<String> groupIdList = new List<String>();
        List<Queue_User_Relationship__c> delQURList = new List<Queue_User_Relationship__c>();
        try{
            for (User u : newList) {
                User oldUser = oldMap.get(u.ID);
                if(u.IsActive == False && oldUser.IsActive == True) 
                    setFalUserId.add(u.id);
                if(u.IsActive == True && oldUser.IsActive == False) {
                    //u.User_Territory_Assigned__c = null;
                    //u.User_Group_Assigned__c = null;
                    //setting field value as null after importing the territories
                    setUserId.add(u.id);
                    setGroupUserId.add(u.id);
                }
            }
            // Executed during User Decativation
            if ( setFalUserId.size() > 0 ) {
                for( UserTerritory2Association u1 : [select UserId, Territory2Id from UserTerritory2Association where UserId =:setFalUserId] ) {
                    if (mapUser.get(u1.UserId) == null) {
                        mapUser.put(u1.UserId, new List<String>());
                        mapUser.get(u1.UserId).add(u1.Territory2Id);
                    }else
                        mapUser.get(u1.UserId).add(u1.Territory2Id);
                }
                for( GroupMember g : [select Id, GroupId,Group.Type, UserOrGroupId from GroupMember where UserOrGroupId in :setFalUserId and Group.Type='Queue'] ) {
                    if (mapUserGroup.get(g.UserOrGroupId) == null) {
                        mapUserGroup.put(g.UserOrGroupId, new List<String>());
                        mapUserGroup.get(g.UserOrGroupId).add(g.GroupId);
                        delList.add(g);
                    }else{
                        mapUserGroup.get(g.UserOrGroupId).add(g.GroupId);
                        delList.add(g);
                    }
                }
                for( Queue_User_Relationship__c q : [select id,QueueManager__c, name,QueueName__c,User__c, Type__c from Queue_User_Relationship__c where Type__c ='User' and User__c in :setFalUserId] ) {
                    delQURList.add(q);
                }
                if ( mapUser.size() > 0) {
                    for ( User u : newList) {
                        if (mapUser.get(u.Id) != null)
                            u.User_Territory_Assigned__c =  String.join(mapUser.get(u.Id),',');
                    }
                }
                
                if ( mapUserGroup.size() > 0) {
                    for ( User u : newList) {
                        if (mapUserGroup.get(u.Id) != null)
                            u.User_Group_Assigned__c =  String.join(mapUserGroup.get(u.Id),',');
                    }
                }
            }
            // Executed during User Activation
            if(setUserId != null && !setUserId.isEmpty()){
                for (UserTerritory2Association u : [select UserId from UserTerritory2Association where UserId =:setUserId] ) {
                    setDupUserId.add(u.UserId);
                }
                if ( setDupUserId.size() > 0)
                    setUserId.removeAll(setDupUserId);
                if ( setUserId.size() > 0 ) {
                    for(User u : [select User_Territory_Assigned__c from user where id =:setUserId]) {
                        if ( u.User_Territory_Assigned__c != null) {
                            String ter = u.User_Territory_Assigned__c.replaceAll('[^a-zA-Z0-9\\,]', ''); 
                            //(T1,T2) => T1,T2
                            List<String> lstTer = ter.split(',');
                            for (Integer i = 0; i < lstTer.size(); i++) {
                                UserTerritory2Association t = new UserTerritory2Association(UserId=u.Id, Territory2Id=lstTer[i]);
                                ut2as.add(t);
                            }
                        }
                    }
                    if ( ut2as.size() > 0 )
                        insert ut2as;
                }
            }
            if(delList != null && !delList.isEmpty()){
                try{
                    delete delList;
                }catch(DmlException e){
                    
                }
            }
            if(delQURList != null && !delQURList.isEmpty() && !System.isFuture() && !System.isBatch()){
                deleteQueueUserRelationshipforUser(JSON.serialize(delQURList));
            }
            if(setGroupUserId != null && !setGroupUserId.isEmpty()){
                if(!setDupUserId.isEmpty()) setDupUserId.clear();
                for (GroupMember u : [select Id, GroupId,Group.Type, UserOrGroupId from GroupMember where UserOrGroupId in :setGroupUserId and Group.Type='Queue'] ) {
                    setDupUserId.add(u.UserOrGroupId);
                }
                if ( setDupUserId.size() > 0)
                    setGroupUserId.removeAll(setDupUserId);
                if ( setGroupUserId.size() > 0 ) {
                    for(User u : [select User_Group_Assigned__c from user where id in :setGroupUserId]) {
                        if ( u.User_Group_Assigned__c != null) {
                            String gr = u.User_Group_Assigned__c.replaceAll('[^a-zA-Z0-9\\,]', ''); 
                            //(T1,T2) => T1,T2
                            for (String g : gr.split(',')) {
                                GroupMember gm = new GroupMember(UserOrGroupId=u.Id, GroupId=g);
                                ugList.add(gm);
                                groupIdList.add(g);
                            }
                        }
                    }
                    if (!ugList.isEmpty()){
                        try{
                            insert ugList;
                        }catch(DmlException e){
                            
                        }
                    }
                    if(!groupIdList.isEmpty() && !System.isBatch() && !System.isFuture()){
                      SRV_CSM_AssignPermissionSet.createQueueUserRelationshipToActiveUser(groupIdList);  
                    } 
                }
                
            }
        }catch(Exception ee){
            
        }
    }
    
    public static void checkduplicateEmployeeNumber(List<User> userList , Map<Id, User> oldMap) {
        Id profileId = UserInfo.getProfileId();
        Set<String> fieldSet = new Set<String>{'Id', 'EmployeeNumber'};
        Set<String> employeeNumberSet = new Set<String>();
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        Map<String, User> employeeNumberToIdMap = new Map<String, User>();
        if(!mulesoftSetting.Ignore_Validation_Rules__c) {
            List<PermissionSetAssignment> psaList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() 
                                                     AND PermissionSet.Name = 'Advanced_Administrator'];
            String profileName = [Select Id, Name from Profile where Id = :profileId].Name;
            if (profileName == CON_CRM.SYSTEM_ADMIN_PROFILE || psaList.size() > 0) {
                for (User user : userList) {
                    if (user.EmployeeNumber != null) {
                        if (user.EmployeeNumber.isNumeric()) {
                            if(Trigger.isInsert || oldMap.get(user.Id).EmployeeNumber != user.EmployeeNumber) {
                                employeeNumberToIdMap.put(user.EmployeeNumber, user);
                                employeeNumberSet.add(user.EmployeeNumber);    
                            }
                        } else if (user.EmployeeNumber.toUpperCase() != 'N/A') {
                            user.addError(System.Label.CRM_CL0031_RECORD_UPDATE_ERROR_1);
                        }    
                    } 
                }
                List<User> allUserList = new SLT_User().selectUserByEmployeeNumber(employeeNumberSet, fieldSet); 
                if (allUserList.size() > 0) {
                    for (User user : allUserList) {
                        employeeNumberToIdMap.get(user.EmployeeNumber).addError(System.Label.CRM_CL0031_RECORD_UPDATE_ERROR_2 + ' ' + String.valueOf(user.Id).substring(0, 15) + ' ' +  System.Label.CRM_CL0031_RECORD_UPDATE_ERROR_3);
                    }
                }    
            } else if (Trigger.isInsert) {
                for (User user : userList) {
                    if (user.ManagerId != null || user.EmployeeNumber != null) {
                        user.addError(System.Label.CRM_CL0031_RECORD_UPDATE_ERROR_4);
                    }
                }  
            } else {
                for (User user : userList) {
                    if(oldMap.get(user.Id).ManagerId != user.ManagerId || oldMap.get(user.Id).EmployeeNumber != user.EmployeeNumber) {
                        user.addError(System.Label.CRM_CL0031_RECORD_UPDATE_ERROR_5);
                    }
                }     
            }  
        }
    }
    
    /**
    * This method is used for insert User Audit Log.
    * @params  List<User> userList
    * @params  Map<Id,User> oldMap
    * @return  void
    */
    public static void insertAuditLog(List<User> userList, Map<Id,User> oldMap) {
        List<String> licenseTypeList = new List<String>();
        String fieldAPI = '';
        List<User_Audit_Log__c> userAuditLogList = new List<User_Audit_Log__c>();
        if(User_Audit_Log_Setting__c.getInstance() != null && User_Audit_Log_Setting__c.getInstance().Enable__c) {
            if(User_Audit_Log_Setting__c.getInstance().Licences_to_Audit__c != null) {
                licenseTypeList = ((User_Audit_Log_Setting__c.getInstance().Licences_to_Audit__c).toUppercase()).split(',');
            }
            for(User user : userList) {
                if(licenseTypeList.contains(user.User_License_Type__c.toUppercase())) {
                    for(Schema.FieldSetMember fieldSetMember : Schema.SObjectType.User.fieldSets.User_Audit_Field.getFields()) {
                        fieldAPI = fieldSetMember.getFieldPath();
                        User_Audit_Log__c userAuditLog = new User_Audit_Log__c();
                        if((Trigger.isInsert) || (Trigger.isUpdate && user.get(fieldAPI) != oldMap.get(user.id).get(fieldAPI))) {
                            userAuditLog.User__c = user.id;
                            userAuditLog.Field_Name__c = fieldAPI;
                            userAuditLog.Active_Inactive_Reason__c = user.Active_Inactive_Reason__c;
                            userAuditLog.Workday_Field_Sync_Date__c = user.Workday_Field_Sync_Date__c;
                            userAuditLog.User_Configuration_Json__c = user.User_Configuration_Json__c;
                            if(Trigger.isInsert) {
                                userAuditLog.Old_Value__c = null;
                            }else {
                                userAuditLog.Old_Value__c = String.valueOf(oldMap.get(user.id).get(fieldAPI));                  
                            }
                            userAuditLog.New_Value__c = String.valueOf(user.get(fieldAPI));          
                            userAuditLogList.add(userAuditLog);
                        }
                    }
                }
            }
            List<Contact> contactToUpdate  = updateContactPseResource(userList, oldMap);
            System.enqueueJob( new QUE_CRM_AsyncInsertUserAuditLog(userAuditLogList, contactToUpdate, contactListToUpdate, userListToUpdate));
                //System.enqueueJob( new QUE_CRM_AsyncInsertUserAuditLog(userAuditLogList));
        }
    }

    /**
    * This method is used to update generate new password checkbox if reset password scheduled date is updated
    * @params  newList List<User>
    * @return  void
    */
    public static void updateResetPassword(List<User> newList,Map<Id,User> oldMap){ 
        for(user newUser : newList) {
            if(newUser.Generate_New_Password__c == false && newUser.Reset_Password_Scheduled_Date__c != null) {
                newUser.Generate_New_Password__c = true;
            }
        }
    }

    public static void assignCallCenterManagePackage(List<User> userList){
        Set<Id> callCenterIdSet = new Set<Id>();
        List<User> selectedUserList = new List<User>();
        for(User userRecord : userList){
            if(userRecord.CallCenterId != null){
                callCenterIdSet.add(userRecord.CallCenterId);
                selectedUserList.add(userRecord);
            }
        }
        if(callCenterIdSet != null && callCenterIdSet.size() > 0){
            Map<Id, CallCenter> callCenterRecordMap = new SLT_CallCenter().selectCallCenterOnUser(callCenterIdSet);
            List<PackageLicense> packageRecordList = new SLT_PackageLicense().selectPackageLicensesOnOrg();
            if(packageRecordList != null && packageRecordList.size() > 0){
                Id packageId = packageRecordList[0].Id;
                Map<Id, UserPackageLicense> userLicensesMap = new SLT_PackageLicense().selectPackageMapOnId(packageId);
                Set<Id> licenseUserSet = new Set<Id>();
                List<UserPackageLicense> addPackageList = new List<UserPackageLicense>();
                List<UserPackageLicense> removePackageList = new List<UserPackageLicense>();
                Map<Id, UserPackageLicense> userIdPackageRecordMap = new Map<Id, UserPackageLicense>();
                if(userLicensesMap != null && !userLicensesMap.isEmpty()){
                    for(UserPackageLicense userPackageRecord : userLicensesMap.values()){
                        licenseUserSet.add(userPackageRecord.UserId);
                        userIdPackageRecordMap.put(userPackageRecord.UserId, userPackageRecord);
                    }
                }
                for(User userRecord : selectedUserList){
                    if(callCenterRecordMap.get(userRecord.CallCenterId).Name.contains(CON_CSM.S_CISCO)){
                        if(licenseUserSet.contains(userRecord.Id)){
                            if(!userRecord.IsActive){
                                removePackageList.add(userIdPackageRecordMap.get(userRecord.Id));
                            }
                        }
                        else{
                            if(userRecord.IsActive){
                                UserPackageLicense userPackageRecord = new UserPackageLicense();
                                userPackageRecord.PackageLicenseId = packageId;
                                userPackageRecord.UserId = userRecord.Id;
                                addPackageList.add(userPackageRecord);
                            }
                        }
                    }
                }
                try{
                    if(addPackageList != null && !addPackageList.isEmpty()){
                        insert addPackageList;
                    }
                    if(removePackageList != null && !removePackageList.isEmpty()){
                        delete removePackageList;
                    }
                }
                catch(Exception ex){
                    ex.getStackTraceString();
                }
            }
        }
    }
    /*
    * Feature- 6259
    * employee number validation
    */
    public static void usersEmployeeNumberValidation(List<User> newList, Map<Id, User> oldMap){
        List<String> employeeNumberList = new List<String>();
        List<User> filteredUserList = new List<User>();
        for (User currentUser: newList) {
            if(currentUser.ContactId == null){
                filteredUserList.add(currentUser);
            } 
        }
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        if(filteredUserList.size() > 0 && !mulesoftSetting.Ignore_Validation_Rules__c){
            Set<String> userLicenseNameSet = new Set<String>{CON_CRM.SALESFORCE_LICENSE,CON_CRM.SALESFORCE_PLATFORM_LICENSE,CON_CRM.CHATTER_FREE_LICENSE};
            Set<Id> profileIdSet = new Set<Id>();
            for (User currentUser: filteredUserList) {
                profileIdSet.add(currentUser.ProfileId);
            } 
            Map<Id, Profile> profileMap = new Map<Id, Profile>(new SLT_Profile().selectProfileById(profileIdSet,new Set<String>{'Id','Name','UserLicense.Name','UserLicenseId'}));
            for (User currentUser: filteredUserList) {
                if(userLicenseNameSet.contains(profileMap.get(currentUser.ProfileId).UserLicense.Name)){
                    if((currentUser.EmployeeNumber == null || currentUser.EmployeeNumber == CON_CRM.NA_SLASH_STRING || currentUser.EmployeeNumber == CON_CRM.NA_STRING) && currentUser.Audit_Employee_Number_Reason__c == null){
                        currentUser.addError(CON_CRM.AUDIT_EMPLOYEE_NUMBER_REQUIRED_MESSAGE);
                    }
                }
                if(currentUser.EmployeeNumber != CON_CRM.NA_STRING && currentUser.EmployeeNumber != CON_CRM.NA_SLASH_STRING && currentUser.EmployeeNumber != null && !(currentUser.EmployeeNumber).isNumeric()){
                    currentUser.addError(CON_CRM.EMPLOYEE_NUMBER_VALID_ERROR_MSG);
                }
            }
        }
    }
    
    public static void sendEmails(List<User> newList, Map<Id, User> oldMap){
        Map<Id, Profile> systemAdminProfileMap =  UTL_CRM.getSystemAdminstratorProfiles();
        Set<Id> sytemAdminProfileIdSet = systemAdminProfileMap.keySet();
        List<String> devOpsEmails = new List<String>();
        
        CRM_Config__c crmConfig = CRM_Config__c.getOrgDefaults(); 
        if(String.isNotBlank(crmConfig.User_Creation_Notification_Recipients__c)){
            for(String recipient : crmConfig.User_Creation_Notification_Recipients__c.split(',')){
                devOpsEmails.add(recipient);
            }
        }
        List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
        String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
        String sanboxName = getSandboxName();
        for(User user : newList){
            if(user.IsActive && sytemAdminProfileIdSet.contains(user.ProfileId) && (Trigger.IsInsert || user.ProfileId != oldMap.get(user.Id).ProfileId || user.IsActive != oldMap.get(user.Id).IsActive)){
                String subject = sanboxName +' ' + user.Full_User_Name__c + ' has been created or activated with a profile equivalent to System Administrator in IQVIA ES&P ';
                String link =  baseUrl + '/'+ user.Id;
                String body = '<html><body><ul>';
                body += '<li>Name of User : <a href="'+ link +'">' + user.Full_User_Name__c+'</a></li>';
                body += '<li>Email : ' + user.Email + '</li>';
                body += '<li>Sandbox Name : ' + sanboxName + '</li>';
                body += '<li>SN Ticket Number : ' + user.Change_Request_Ticket_Number__c + '</li>';
                body += '<li>SN Ticket Description : ' + user.Change_Request_Description__c + '</li>';
                body += '<li>Current user : ' + UserInfo.getName()+'</li>';
                body += '<li>Name : ' + user.Full_User_Name__c + '</li>';
                body += '<li>Profile Name : ' + systemAdminProfileMap.get(user.ProfileId).Name + '</li>';
                body += '<li>Employee Number : ' + user.EmployeeNumber + '</li>';
                body += '<li>Activation Date : ' + user.LastModifiedDate + '</li>';
                body += '</ul></body></html>';
                
                UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
                message.toEmails = devOpsEmails;
                message.whatId = user.Id;
                message.subject = subject;
                message.staticContent = body;
                messageList.add(message);
            }
        }
        if(messageList.size() > 0){
            String jsonMessage = JSON.serialize(messageList);
            sendEmailsFuture(jsonMessage);
        }   
    }
    
    @future
    public static void sendEmailsFuture(String jsonMessage){
        List<UTL_CRM_SendEmail.MessageWrapper> messageList = (List<UTL_CRM_SendEmail.MessageWrapper>) JSON.deserialize(jsonMessage, List<UTL_CRM_SendEmail.MessageWrapper>.class);
        UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);
    }
    
    public static String getSandboxName(){
        if(UTL_CRM.isSandboxOrg()){
            return URL.getOrgDomainUrl().getHost().substringBetween('--','.');
        }else{
            return 'IQVIA Production';
        }
    }
    
    public static void updateServiceCloudUserValue(List<User> newList, Map<Id, User> oldMap) {
        for(User userRecord: newList) {
            if(Trigger.isInsert || (Trigger.isUpdate && oldMap != null && oldMap.containsKey(userRecord.Id) && oldMap.get(userRecord.Id) != null 
                                    && userRecord.UserPermissionsSupportUser != oldMap.get(userRecord.Id).UserPermissionsSupportUser)) {
                userRecord.Service_Cloud_User__c = userRecord.UserPermissionsSupportUser;
            }
        }
    }

    public static void updatePRMSuperUser(List<User> userList, Map<Id, User> oldMap){
        Set<Id> mgrId = new Set<Id>();
        List<User> usersToUpdate = new List<User>();
        for(User us : userList)
        {
            mgrId.add(us.Id);
        }
        Map<Id,User> managerUser = new Map<Id,User>();
        managerUser = new SLT_User().getPRMUsers(mgrID);
        System.debug('Manager user list : ' + managerUser);
        
        for(User us : userList)
        {
            if (managerUser.containsKey(us.Id))
            {   
                System.debug('Inside map');
                if(Trigger.isUpdate && us.UserRoleId != oldMap.get(us.Id).UserRoleId)
                {             
                    if(managerUser.get(us.Id).UserRole.PortalRole == 'Manager')
                    {
                        System.debug('Potal Role inside manager : ' + managerUser.get(us.Id).UserRole.PortalRole);
                        us.IsPrmSuperUser = false;
                    }
                    else if(managerUser.get(us.Id).UserRole.PortalRole == 'Worker'){
                        System.debug('Portal Role in else : ' + managerUser.get(us.Id).UserRole.PortalRole);
                        us.IsPrmSuperUser = true;
                    }
                }
                if(Trigger.isInsert)
                {
                    List<User> mgrUser = new SLT_User().getPRMManagerUsers(mgrID);
                    if(mgrUser.size() > 0){
                        for(User usr : mgrUser)
                        {
                            usr.IsPrmSuperUser = true;    
                            System.debug('update to false');
                        }
                        if(!test.isRunningTest()) {
                            System.debug('inside update super user');
                            update mgrUser;
                        }
                    }
                }
            }
            
        }
    }

    public static void checkCSHDefaultQueueAssignment(List<User> newList) {
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> cshUserIdSet = new Set<Id>();
        Set<Id> profileIdSet = new Set<Id>();
        Map<Id,String> accPorMap = new Map<Id,String>();
        for(User u : newList) {
            if(u.ContactId != null) {
                userIdSet.add(u.Id);
                profileIdSet.add(u.profileId);
            }
        }
        if(profileIdSet != null && !profileIdSet.isEmpty()){
            Map<Id, Profile> profileMap = UTL_GLOBAL.getProfile(profileIdSet);
            if(profileMap != null && !profileMap.isEmpty()){
                for(User u : newList)
                {
                    if(profileMap.containsKey(u.ProfileId) && profileMap.get(u.ProfileId) != null && profileMap.get(u.ProfileId).Name == CON_CSM.S_P_CSM_COMMUNITY)
                    {
                        cshUserIdSet.add(u.Id);
                        accIdSet.add(u.ContactId);
                    }
                }
                if(accIdSet != null && !accIdSet.isEmpty()) {
                    List<Contact> conList = new SLT_Contact().selectByContactIdList(accIdSet,new Set<String> {'AccountId','Portal_Case_Type__c'});
                    if(conList != null && !conList.isEmpty()){
                        accIdSet.clear();
                        for(Contact c: conList){
                            accIdSet.add(c.AccountId);
                            accPorMap.put(c.Id,c.Portal_Case_Type__c);
                        }
                    }
                    
                    String str = '';
                    boolean isTech = false, isData = false;
                    List<CSM_QI_Data_Portal_Queue_User_details__c> datalist = Database.query('select Id, Account__c,AccountName__c, All_Current_Users__c, Order__c, Queue_User_Relationship__c, AccountCountry__c, CaseRecordType__c  from CSM_QI_Data_Portal_Queue_User_details__c where Account__c in :accIdSet and Order__c = 1 and Queue_User_Relationship__c != null and All_Current_Users__c = true');
                    if(datalist != null && !datalist.isEmpty()){
                        for(CSM_QI_Data_Portal_Queue_User_details__c c : datalist){
                            if(c.CaseRecordType__c == 'TechnologyCase' && c.Account__c != null){
                                isTech = true;
                            }else if(c.CaseRecordType__c == 'DATACase' && c.Account__c != null){
                                isData = true;
                            }
                        }
                    }
                    for(User u : newList){
                        if(!isTech && accPorMap.containsKey(u.ContactId) && accPorMap.get(u.ContactId) != null && accPorMap.get(u.ContactId).containsIgnoreCase('Technology Solutions')){
                            u.addError('Please create the default portal queue assignment for TechnologyCase');
                        }else if(!isData && accPorMap.containsKey(u.ContactId) && accPorMap.get(u.ContactId) != null && accPorMap.get(u.ContactId).containsIgnoreCase('Information Offering')){
                            u.addError('Please create the default portal queue assignment for DATACase');
                        }
                    }
                }
            }
        }
    }

    public static void setFieldValues(List<User> newList, Map<Id, User> oldMap){
        for (User u : newList){
            if (u.IsActive == true && u.First_Time_Activation__c == Null && (oldMap == null || oldMap.get(u.id).IsActive != u.IsActive)){
                u.First_Time_Activation__c = system.today();
                u.Active_Inactive_Reason__c = 'New User';
            } else if(u.IsActive == true && u.First_Time_Activation__c != Null && (oldMap == null || oldMap.get(u.id).IsActive != u.IsActive)) {
                u.Active_Inactive_Reason__c = 'Reactivation';
            } else if(u.IsActive == false && !System.isBatch() && (oldMap == null || oldMap.get(u.id).IsActive != u.IsActive)) {
                u.Active_Inactive_Reason__c = 'Other (Manual Deactivation)';
            }
            if(u.IsActive == false && (oldMap == null || oldMap.get(u.id).IsActive != u.IsActive)) {
                u.Last_Time_Deactivation__c = system.today();
            }
            if(u.User_License_Type__c == 'Salesforce'){
                if(u.UserRole_DeveloperName__c == 'Avacare'){
                    u.User_Type__c = 'Avacare';
                }else if(('EPG').equals(u.UserRole_DeveloperName__c)){
                    u.User_Type__c = 'EPG';
                }else if(('EPG_IME').equals(u.UserRole_DeveloperName__c)){
                    u.User_Type__c = 'EPG IME';
                }else if(('EPG_Collaborative').equals(u.UserRole_DeveloperName__c)){
                    u.User_Type__c = 'EPG Collaborative';
                }else{
                    u.User_Type__c = 'IQVIA';
                }
            }else{
                u.User_Type__c = '';
            }
        }
    }
    
    
    public static void setWDFieldSyncDate(List<User> newList, Map<Id, User> oldMap){
        Boolean wdFieldChange;
        String fieldAPI = '';
        for (User u : newList){
            wdFieldChange = false;
            if(oldMap != null) {
                for(Schema.FieldSetMember fieldSetMember : Schema.SObjectType.User.fieldSets.Workday_Field_Set.getFields()) {
                    fieldAPI = fieldSetMember.getFieldPath();
                    if((u.get(fieldAPI) != oldMap.get(u.id).get(fieldAPI))) {
                        wdFieldChange = true;
                    }
                }
            }
            if(u.Sync_Workday_Field_To_Contact__c == true) {
                wdFieldChange = true;
            }
            if(wdFieldChange) {
                u.Workday_Field_Sync_Date__c = System.now();
                u.Sync_Workday_Field_To_Contact__c = false;
            }
            if(Trigger.isInsert) {
                u.Workday_Field_Sync_Date__c = System.now();
                u.Sync_Workday_Field_To_Contact__c = false;
            }
        }
    }
    
    public static void deactivateCommunityUser(List<User> newList, Map<Id,User> existingRecords){
        Set<Id> userIdSet = new Set<Id>();
        system.debug('Inside Method' );
        for(User usr : newList){
            Date lstLoginDate = System.today().addMonths(-6);
            if(!System.isBatch() && existingRecords.get(usr.id).IsPortalEnabled && !usr.IsActive && (existingRecords.get(usr.id).lastlogindate > lstLoginDate)) {
                usr.IsActive=true;
                usr.IsPortalEnabled=true;
            }
        }
    }

    @future
    public static void deleteQueueUserRelationshipforUser(String jsonQueue){
        List<Queue_User_Relationship__c> qurList = (List<Queue_User_Relationship__c>) JSON.deserialize(jsonQueue, List<Queue_User_Relationship__c>.class);
        if(qurList != null && !qurList.isEmpty()){
            try{
                delete qurList;
            }catch(DmlException e){
                
            }
        }
    }

    public static List<Contact> updateContactPseResource(List<User> newList, Map<Id, User> oldMap) {
        Set<Id> userIdSet = new Set<Id>();
        List<Contact> contactList = new List<Contact>();
        List<Contact> contactListToUpdate = new List<Contact>();
        Set<String> contactFieldSet = new Set<String>{'Id', 'Name', 'pse__Is_Resource_Active__c'};
        for(User user : newList){
            if(!user.IsActive && (oldMap == NULL || oldMap.get(user.id).IsActive != user.IsActive) && user.Active_Inactive_Reason__c == 'Termination') {
                userIdSet.add(user.Id);
            }
        }
        if(userIdSet.size() > 0) {
            contactList = new SLT_Contact().selectBySalesforceUserIdsList(userIdSet, contactFieldSet);
        }
        if(contactList.size() > 0) {
            for(Contact con : contactList) {
                if(con.pse__Is_Resource_Active__c) {
                    con.pse__Is_Resource_Active__c = false;
                    contactListToUpdate.add(con);
                }
            }
        }
        return contactListToUpdate;
    }
    
    public static void setUserConfigJson(List<User> newList, Map<Id, User> oldMap){
        List<Id> userIdList  = new List<Id>();
        
        for(User u : newList) {
            if(u.IsActive == false && (oldMap == null || oldMap.get(u.id).IsActive != u.IsActive)) {
                userIdList.add(u.Id);
            }
        }
        Map<Id,List<UserPackageLicense>> userIdToUserLicenseMap;
        Map<Id,List<PermissionSetAssignment>> userIdToPermissionSetMap;
        Map<Id,List<GroupMember>> userIdToGroupMemberMap;
        Map<Id,List<UserTerritory2Association>> userIdToTerritoryMap;
        
        if(userIdList.size() > 0) {
            
            userIdToUserLicenseMap = new Map<Id,List<UserPackageLicense>>();
            userIdToPermissionSetMap = new Map<Id,List<PermissionSetAssignment>>();
            userIdToGroupMemberMap = new Map<Id,List<GroupMember>>();
            userIdToTerritoryMap = new Map<Id,List<UserTerritory2Association>>();
            
            for(UserPackageLicense upl : [select UserId,PackageLicenseId from UserPackageLicense where UserId in :userIdList]) {
                if(userIdToUserLicenseMap.containsKey(upl.UserId)) {
                    userIdToUserLicenseMap.get(upl.UserId).add(upl);
                } else {
                    userIdToUserLicenseMap.put(upl.UserId,new List<UserPackageLicense>{upl});
                }
            }
            for(PermissionSetAssignment psa : [select AssigneeId, PermissionSetId from PermissionSetAssignment where AssigneeId in :userIdList]) {
                if(userIdToPermissionSetMap.containsKey(psa.AssigneeId)) {
                    userIdToPermissionSetMap.get(psa.AssigneeId).add(psa);
                } else {
                    userIdToPermissionSetMap.put(psa.AssigneeId,new List<PermissionSetAssignment>{psa});
                }
            }
            for(GroupMember gm : [select UserOrGroupId, GroupId from GroupMember where UserOrGroupId in :userIdList]) {
                if(userIdToGroupMemberMap.containsKey(gm.UserOrGroupId)) {
                    userIdToGroupMemberMap.get(gm.UserOrGroupId).add(gm);
                } else {
                    userIdToGroupMemberMap.put(gm.UserOrGroupId,new List<GroupMember>{gm});
                }
            }
            for(UserTerritory2Association uta : [select id,Territory2Id, UserId from UserTerritory2Association where UserId in :userIdList]) {
                if(userIdToTerritoryMap.containsKey(uta.UserId)) {
                    userIdToTerritoryMap.get(uta.UserId).add(uta);
                } else {
                    userIdToTerritoryMap.put(uta.UserId,new List<UserTerritory2Association>{uta});
                }
            }
        }

        for (User u : newList){
            if(u.IsActive == false && (oldMap == null || oldMap.get(u.id).IsActive != u.IsActive)) {
				UserConfigWrapper configWrapper = new UserConfigWrapper();
                if(userIdToUserLicenseMap.containsKey(u.Id)) {
                    configWrapper.userlicenseList = userIdToUserLicenseMap.get(u.Id);
                }
                if(userIdToPermissionSetMap.containsKey(u.Id)) {
                    configWrapper.permissionSetList = userIdToPermissionSetMap.get(u.Id);
                }
                if(userIdToGroupMemberMap.containsKey(u.Id)) {
                    configWrapper.groupMemberList = userIdToGroupMemberMap.get(u.Id);
                }
                if(userIdToTerritoryMap.containsKey(u.Id)) {
                    configWrapper.territoryList = userIdToTerritoryMap.get(u.Id);
                }
                configWrapper.deactivationDate = Date.today();
                u.User_Configuration_Json__c = Json.serialize(configWrapper);
            }
            if(u.IsActive && (oldMap == null || oldMap.get(u.id).IsActive != u.IsActive)) {
                u.User_Configuration_Json__c = NULL;
            }
        }
    }

    public static void setAccessExpiryDate(List<User> newList, Map<Id, User> oldMap) {
        User_Activation_Input_Variables__c userConfig = User_Activation_Input_Variables__c.getValues('BusinessLogic');

        for(User u : newList) {
            if (u.Infrequent_User__c == false || u.isActive == false) {
                u.Access_Expiry_Date__c = null;
            } else if(u.Infrequent_User__c && u.isActive && ((oldMap == null || oldMap.get(u.id).Infrequent_User__c != u.Infrequent_User__c) || (oldMap == null || oldMap.get(u.id).isActive != u.isActive))) {
                u.Access_Expiry_Date__c = Date.today() + Integer.valueOf(userConfig.Infrequent_User_Active_Days__c);
            }
        }
    }
}
