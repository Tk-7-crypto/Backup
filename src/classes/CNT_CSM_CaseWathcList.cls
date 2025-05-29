public class CNT_CSM_CaseWathcList {
    public class UserQueueList {
        @AuraEnabled
        public String Id {get; set;}
        @AuraEnabled
        public String Name {get; set;}
        @AuraEnabled
        public String Email {get; set;}
        @AuraEnabled
        public String IconName {get; set;}

    }
    /*
    @AuraEnabled(cacheable=true)
    public static List<User> searchUser(String searchKey){
        String key=searchKey+'%';
        String licencekey='Salesforce%';
        String query='SELECT Id,Name, Email, User_License_Type__c from User where IsActive = true AND User_License_Type__c like :licencekey and Name like :key limit 10';
        //String query='SELECT Id,Name, Email, User_License_Type__c from User where User_License_Type__c like :licencekey and Name like :key limit 10';
        List<User> userlist = Database.query(query);
        return userlist;
    }
     */
    @AuraEnabled(cacheable=true)
    public static List<UserQueueList> searchUserGroup(String searchKey, String type ){
        List<UserQueueList> userQueueList = new List<UserQueueList>();
        String key=searchKey+'%';

        if(type == 'user' && key != null) {
            String licencekey='Salesforce%';
            if(licencekey != null){
                String query='SELECT Id,Name, Email, User_License_Type__c from User where IsActive = true AND User_License_Type__c like :licencekey and Name like :key limit 10';
                List<User> userlist = Database.query(query);
                for (User u : userlist) {
                    UserQueueList ul = new UserQueueList();
                    ul.Id = u.Id;
                    ul.Name = u.Name;
                    ul.Email = u.Email;
                    userQueueList.add(ul);
                }
            }
            
        }else{
            String query='select Id, Name from Group where Type=\'Queue\' and Name like :key limit 10';
            List<Group> grouplist = Database.query(query);
            for (Group queue : grouplist) {
                UserQueueList ql = new UserQueueList();
                ql.Id = queue.Id;
                ql.Name = queue.Name;
                userQueueList.add(ql);
            }
        }
        return userQueueList;
    }

    @AuraEnabled(cacheable=true)
    public static Case getCase(String caseId){
        Case c = new SLT_Case().getWatchUserDetails(caseId);
        return c;
    }

    /*
       @AuraEnabled(cacheable=true)
       public static List<User> watchUserList(String usersId){
        List<User> userList = null;
        if(usersId != null) {
            List<String> ids = usersId.split(',');
            userList = Database.query('SELECT Id,Name from User where Id IN :ids');
        }
        return userList;
       }
     */

    @AuraEnabled(cacheable=true)
    public static List<UserQueueList> watchUserList(String usersId){
        List<UserQueueList> userQueueList = new List<UserQueueList>();
        List<User> users = null;
        List<Group> groups = null;
        List<Id> uids = new List<Id>();
        List<Id> gids = new List<Id>();
        if(usersId != null) {
            List<String> ids = usersId.split(',');

            for (String id: ids) {
                if(id.startsWith('00G')){
                    gids.add(id);
                }else{
                    uids.add(id);
                }
            }

            if(uids.size()>0) {
                users = Database.query('SELECT Id,Name from User where Id IN :uids');
                for (User u : users) {
                    UserQueueList ul = new UserQueueList();
                    ul.Id = u.Id;
                    ul.Name = u.Name;
                    ul.IconName = 'standard:user';
                    userQueueList.add(ul);
                }
            }

            if(gids.size()>0) {
                groups = Database.query('SELECT Id,Name from Group where Id IN :gids');
                for (Group g : groups) {
                    UserQueueList ql = new UserQueueList();
                    ql.Id = g.Id;
                    ql.Name = g.Name;
                    ql.IconName = 'standard:queue';
                    userQueueList.add(ql);
                }
            }
        }
        return userQueueList;
    }

    @AuraEnabled
    public static Case updateWatchListUser(String caseId,String watchIds,String userId){
        String ids;
        Case caseRecord = new Case(Id=caseId);
        if(watchIds != null && watchIds != '' && userId !=null) {
            ids = watchIds +','+userId;
        }else if(watchIds != null && userId == null) {
            ids = watchIds;
        }
        else{
            ids = userId;
        }
        caseRecord.Watch_List_User__c = ids;
        DAOH_Case.isClosedCaseUpdatableTechno = true;
        DAOH_Case.isCaseUpdated = true;
        try{
            update caseRecord;
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return caseRecord;
    }
}
