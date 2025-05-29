public class QUE_CRM_Contact_Resource_Active_Updated implements Queueable{
    
    List<Contact> contactList = new List<Contact>();
    public List<Contact> contactListUserContactSync = new List<Contact>();
    public List<User> userListUserContactSync = new List<User>();
    public Map<Id,Contact> userIdToContactMap = new Map<Id, Contact>();
    public Map<String, ID> userEmployeeNumToUserIdMap = new Map<String, ID>();
    
    public QUE_CRM_Contact_Resource_Active_Updated(List<Contact> conList, Map<Id,Contact> userIdToContactMap, List<User> userList){
        this.contactListUserContactSync = conList;
        this.userIdToContactMap = userIdToContactMap;
        this.userListUserContactSync = userList;
    }
    
    public QUE_CRM_Contact_Resource_Active_Updated(List<Contact> contactListToUpdate, List<Contact> contactToUpdateList, List<User> userListToUpdate) {
        this.contactList = contactListToUpdate;
        this.contactListUserContactSync = contactToUpdateList;
        this.userListUserContactSync = userListToUpdate;
        
        if(contactListUserContactSync.size() > 0){
            Set<String> employeeNumberSet = new Set<String>();
            Set<Id> userIDs = new Set<Id>();
            for(Contact con : contactListUserContactSync){
                userIDs.add(con.Salesforce_User__c);
                employeeNumberSet.add(con.EmployeeNumber__c);
            }
            //adding Id of all users to be updated from userListUserContactSync
            for(User u : userListUserContactSync){
                userIDs.add(u.ID);
            }
            
            //get user by emloyee number
            List<User> userListWithEmpNum = new List<User>();
            userListWithEmpNum = new SLT_User().selectUserByEmployeeNumber(employeeNumberSet, new Set<String>{'Id','User_License_Type__c','EmployeeNumber'});
            
            //preparing map of employee number to user ID
            for(Integer i=0; i<userIDs.size(); i++){
                for(User u : userListWithEmpNum){
                    if(userIDs.contains(u.Id)){
                        userEmployeeNumToUserIdMap.put(u.EmployeeNumber, u.Id);
                    }
                }
            }
            
            //preparing map of user Id to associated contact
            List<Contact> existingContacts = new List<Contact>();
            if(!userIDs.isEmpty()) {
                existingContacts = new SLT_Contact().selectBySalesforceUserIdList(userIDs, new Set<String>{'Id','Salesforce_User__c','EmployeeNumber__c'});
                for(Contact con : existingContacts) {
                    userIdToContactMap.put(con.Salesforce_User__c, con);
                }      
            }
            
            if(contactListUserContactSync.size() > 0){
                List<Database.UpsertResult> updateResultsList = Database.upsert(contactListUserContactSync, false);
                upsertContactExceptionHandling(updateResultsList);
            } 
        }
    }
    
    public void execute(QueueableContext qc){
        if(contactList.size() > 0) {
            update contactList;
        }
        
        if(userListUserContactSync.size() > 0 && !Test.isRunningTest()){
            System.enqueueJob(new QUE_CRM_User_Contact_Sync_UpdateUser(userListUserContactSync));
        }
    }
    
    @testVisible
    private void upsertContactExceptionHandling(List<Database.UpsertResult> updateResultsList){
        for(Integer i=0; i<updateResultsList.size(); i++) {
            if (!updateResultsList.get(i).isSuccess()){
                Database.Error error = updateResultsList.get(i).getErrors().get(0);
                String failedDML = error.getStatusCode()+' '+error.getMessage();
                if(contactListUserContactSync.get(i).Id != NULL) {
                    List<Contact> conList = userIdToContactMap.values();
                    for(Contact con : conList) {
                        if(con.Id == contactListUserContactSync.get(i).Id) {
                            User uRec = new User();
                            if(con.Salesforce_User__c != null){
                                uRec.Id = con.Salesforce_User__c;
                            }
                            else if(userEmployeeNumToUserIdMap.containsKey(con.EmployeeNumber__c)){
                                uRec.Id = userEmployeeNumToUserIdMap.get(con.EmployeeNumber__c);                                   
                            }
                            uRec.User_To_Contact_Sync_Error__c = failedDML;
                            Integer index;
                            for(User u : userListUserContactSync) {
                                if(u.id == uRec.Id) {
                                    index = userListUserContactSync.indexOf(u);
                                }
                            }
                            userListUserContactSync.remove(index);
                            userListUserContactSync.add(uRec);
                        } 
                    } 
                }            
            }
        }
    }
}