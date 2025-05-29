global class BCH_CSM_CSHUserUpdate implements Database.Batchable<sObject>, Database.Stateful{
    global final List<Id> lstInactiveUserId;
    global BCH_CSM_CSHUserUpdate(List<Id> lstInactiveUserId) {
        this.lstInactiveUserId = lstInactiveUserId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('lstInactiveUserId : '+lstInactiveUserId);
        String query = 'select Id, ContactId, Name, LastLoginDate, IsActive, IsPortalEnabled ,UserType from User where ContactId != null and isActive = true and IsPortalEnabled = true and UserType in (\'CustomerSuccess\',\'PowerCustomerSuccess\') and Id in :lstInactiveUserId LIMIT 500';
        return Database.getQueryLocator(query);
    }    
    global void execute(Database.BatchableContext BC, List<User> users){
        List<User> lstUser = new List<User>();
        System.debug('users : '+users);
        if(!users.isEmpty()){
            for(User u : users){
                u.IsActive = false;
                lstUser.add(u);
            }
            try{
                update lstUser;
            }catch(DmlException ex){System.debug('Exception occured at BCH_CSM_CSHUserUpdate : '+ex.getMessage());}
        }   
    }
    
    global void finish(Database.BatchableContext BC) {}

}