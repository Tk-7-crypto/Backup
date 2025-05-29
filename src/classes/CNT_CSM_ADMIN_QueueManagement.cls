public class CNT_CSM_ADMIN_QueueManagement {
    @AuraEnabled
    public static List<sObject> fetchLookUpValues(String searchKeyWord) {
        String searchKey = searchKeyWord + '%';
        List <sObject> returnList = new List < sObject > ();
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 10
        if(searchKey != null){
            List <sObject> lstOfRecords = Database.query('select id, Name,Group_Id__c from Queue_User_Relationship__c where Name LIKE: searchKey and Type__c = \'Queue\' order by Name limit 10');
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
        }
        return returnList;
    }
    
    @AuraEnabled
    public static boolean getLocalAdmin(){
        String userId = UserInfo.getUserId();
        List<PermissionSetAssignment> sObj = Database.query('select Id, PermissionSetId, PermissionSet.Name, AssigneeId from PermissionSetAssignment where AssigneeId = \''+userId+'\' and  (PermissionSet.Profile.Name in (\'System Administrator\') or PermissionSet.Name in (\'Advanced_Administrator\',\'Local_Admin_Data\',\'Local_Admin\',\'UsersQueuesManager\'))');
        if(sObj != null && sObj.size() >0){
            return true;    
        }else{
            return false;
        }
        
    }
    
    @AuraEnabled
    public static List<EXT_CSM_CheckboxDetails> getSelectedQueueUsers(String queueId){
        EXT_CSM_CheckboxDetails user = null;
        List<EXT_CSM_CheckboxDetails>  userList = new List<EXT_CSM_CheckboxDetails>();
        Set<Id> notIn = new Set<Id>(); 
        List<CSM_Admin_Management__c> admin = Database.query('SELECT Id,User__c FROM CSM_Admin_Management__c where Status__c = \'New\' and Action__c = \'Delete\' and Queue_Id__c = :queueId');
        for(CSM_Admin_Management__c am : admin ){
            notIn.add(am.User__c);
        }
        List<User> uList = Database.query('select Id,Name From User where IsActive = true and ContactId = null and Id in (select UserOrGroupId From GroupMember where GroupId = :queueId) and Id NOT In : notIn');
        if(uList != null){
            for(User u : uList){
                user = new EXT_CSM_CheckboxDetails(u.Id,u.Name);
                userList.add(user);
            }    
        }
        
        return userList;
    }
    
    @AuraEnabled
    public static List<EXT_CSM_CheckboxDetails> getSearchUsers(String queueId, String searchKeyWord){
        String searchKey = searchKeyWord + '%';
        EXT_CSM_CheckboxDetails user = null;
        List<EXT_CSM_CheckboxDetails>  userList = new List<EXT_CSM_CheckboxDetails>();  
        List<EXT_CSM_CheckboxDetails> selectUser = getSelectedQueueUsers(queueId);
        if(selectUser!= null && selectUser.size() > 0){
            userList.addAll(selectUser);    
        }
        Set<Id> notIn = new Set<Id>(); 
        List<CSM_Admin_Management__c> admin = Database.query('SELECT Id,User__c FROM CSM_Admin_Management__c where Status__c = \'New\' and Queue_Id__c = :queueId');
        for(CSM_Admin_Management__c am : admin ){
            notIn.add(am.User__c);
        }
        if(searchKey != null){
            List<User> uList = Database.query('select Id,Name From User where IsActive = true and Name LIKE: searchKey and Id NOT in :notIn and ContactId = null order by Name limit 200');
            if(uList != null){
                for(User u : uList){
                    user = new EXT_CSM_CheckboxDetails(u.Id,u.Name);
                    userList.add(user);
                }
            }
        }
        return userList;
    }
    
    @AuraEnabled
    public static List<EXT_CSM_CheckboxDetails> saveSelectedUsersinGroupMember(String queueId, List<String> defaultList,List<String> selected){
        Set<Id> delSet = new Set<Id>();
        Set<Id> addSet = new Set<Id>();
        Map<String,String> delMap = new Map<String,String>();
        Map<String,String> addMap = new Map<String,String>();
        CSM_Admin_Management__c cam = null;
        List<CSM_Admin_Management__c> addMem = new List<CSM_Admin_Management__c>();
        if(selected != null && selected.size() > 0){
            if(selected != null && selected.size() > 0){
                for(String def : defaultList){
                    if(!selected.contains(def)){
                        delSet.add(def); 
                    }
                }    
            }
        }
        
        for(String add : selected){
            if(!defaultList.contains(add)){
                addSet.add(add);
            }
        }
        
        if(addSet != null && !addSet.isEmpty()){
            List<User> usList = Database.query('select Id,Name From User where IsActive = true and Id IN :addSet');
            for(User us : usList){
                cam = new CSM_Admin_Management__c();
                cam.Queue_Id__c = queueId;
                cam.Action__c = 'Add';
                cam.Status__c = 'New';
                cam.User__c = us.Id;
                cam.User_Name__c = us.Name;
                addMem.add(cam);     
            }
        }
        
        if(delSet != null && !delSet.isEmpty()){
            Map<Id, User> userMap = new Map<Id, User>((List<User>)Database.query('SELECT Id, Name FROM User WHERE IsActive = true AND Id IN :delSet'));
            if(userMap != null && !userMap.isEmpty()){
                Set<Id> userIds = userMap.keySet();
                List<Queue_User_Relationship__c> queueList = Database.query('SELECT User__c FROM Queue_User_Relationship__c WHERE Type__c = \'User\' AND User__c IN :userIds');
                if(queueList != null && !queueList.isEmpty()){
                    Map<Id, Integer> userCountMap = new Map<Id, Integer>();
                    for(Queue_User_Relationship__c queueRecord : queueList){
                        if(userCountMap.containsKey(queueRecord.User__c)){
                            Integer count = userCountMap.get(queueRecord.User__c) + 1;
                            userCountMap.remove(queueRecord.User__c);
                            userCountMap.put(queueRecord.User__c, count);
                        }
                        else{
                            userCountMap.put(queueRecord.User__c, 1);
                        }
                    }
                    if(userCountMap != null && !userCountMap.isEmpty()){
                        List<CSM_Admin_Management__c> adminList = Database.query('SELECT Id, Queue_Id__c, User__c FROM CSM_Admin_Management__c WHERE Action__c = \'Delete\' AND Status__c = \'New\' AND User__c IN :userIds');
                        if(adminList != null && !adminList.isEmpty()){
                            for(CSM_Admin_Management__c adminRecord : adminList){
                                if(userCountMap.get(adminRecord.User__c) != null){
                                    Integer count = userCountMap.get(adminRecord.User__c) - 1;
                                    userCountMap.remove(adminRecord.User__c);
                                    userCountMap.put(adminRecord.User__c, count);
                                }
                            }
                        }
                        List<EXT_CSM_CheckboxDetails> userNames = new List<EXT_CSM_CheckboxDetails>();
                        for(Id userId : userCountMap.keySet()){
                            if(userCountMap.get(userId) == 1){
                                EXT_CSM_CheckboxDetails user = new EXT_CSM_CheckboxDetails(userId, userMap.get(userId).Name+'--Restricted');
                                userNames.add(user);
                            }
                        }
                        if(userNames != null && !userNames.isEmpty()){
                            userNames.addAll(getSelectedQueueUsers(queueId));
                            return userNames;
                        }
                    }
                }
            }
            List<User> usList = Database.query('select Id,Name From User where IsActive = true and Id IN :delSet');
            for(User us : usList){
                delMap.put(us.Id,us.Name);
            }
            List<GroupMember> gList = Database.query('select Id,GroupId,UserOrGroupId From GroupMember where GroupId = :queueId and UserOrGroupId IN :delSet'); 
            for(GroupMember gm : gList){
                if(delMap.containsKey(gm.UserOrGroupId)){
                    cam = new CSM_Admin_Management__c();
                    cam.DeleteGroupMemberId__c = gm.Id;
                    cam.Queue_Id__c = gm.GroupId;
                    cam.Action__c = 'Delete';
                    cam.Status__c = 'New';
                    cam.User__c = gm.UserOrGroupId;
                    cam.User_Name__c = delMap.get(gm.UserOrGroupId);
                    addMem.add(cam);    
                }
                
            }
        }
        if(addMem != null && !addMem.isEmpty()){
            try{
                insert addMem;
            }catch(DmlException e){
                
            }
        }
        return getSelectedQueueUsers(queueId);
    }    
    
    @AuraEnabled
    public static EXT_CSM_DataTableResponse getAddedDeletedList(String queueId){
        Schema.SObjectType SObjectTypeObj = Schema.getGlobalDescribe().get('CSM_Admin_Management__c');
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();            
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get('QueueUserDetails');
        
        //To hold the table hearders 
        List<EXT_CSM_DataTableColumns> lstDataColumns = new List<EXT_CSM_DataTableColumns>();
        
        //Field to be queried - fetched from fieldset
        List<String> lstFieldsToQuery = new List<String>();
        
        //The final wrapper response to return to component
        EXT_CSM_DataTableResponse response = new EXT_CSM_DataTableResponse();
        
        for( Schema.FieldSetMember eachFieldSetMember : fieldSetObj.getFields() ){
            String dataType = String.valueOf(eachFieldSetMember.getType()).toLowerCase();
            //This way we can set the type of a column
            //We do not get the exact type from schema object which matches to lightning:datatable component structure
            if(dataType == 'datetime'){
                dataType = 'date';
            }
            //Create a wrapper instance and store label, fieldname and type.
            EXT_CSM_DataTableColumns datacolumns = new EXT_CSM_DataTableColumns( String.valueOf(eachFieldSetMember.getLabel()) , String.valueOf(eachFieldSetMember.getFieldPath()), String.valueOf(eachFieldSetMember.getType()).toLowerCase() );
            lstDataColumns.add(datacolumns);
            if('Status__c'.equals(String.valueOf(eachFieldSetMember.getFieldPath())) ){
                lstFieldsToQuery.add('toLabel(Status__c)');
            }else if('Action__c'.equals(String.valueOf(eachFieldSetMember.getFieldPath())) ){
                lstFieldsToQuery.add('toLabel(Action__c)');
            }else{
                lstFieldsToQuery.add(String.valueOf(eachFieldSetMember.getFieldPath()));  
            }
        } 
        EXT_CSM_DataTableColumns action = new EXT_CSM_DataTableColumns();
        EXT_CSM_DataTableColumns typeAttributes = new EXT_CSM_DataTableColumns();
        action.type = 'action';
        List<EXT_CSM_DataTableColumns> rowActions = new List<EXT_CSM_DataTableColumns>();
        EXT_CSM_DataTableColumns action1 = new EXT_CSM_DataTableColumns();
        action1.label = 'Show details';
        action1.name = 'show_details';
        rowActions.add(action1);
        EXT_CSM_DataTableColumns action2 = new EXT_CSM_DataTableColumns();
        action2.label = 'Delete';
        action2.name = 'delete';
        rowActions.add(action2);
        typeAttributes.rowActions = rowActions;
        action.typeAttributes = typeAttributes; 
        lstDataColumns.add(action);
        //Form an SOQL to fetch the data - Set the wrapper instance and return as response
        if(!lstDataColumns.isEmpty()){            
            response.lstDataTableColumns = lstDataColumns;
            String query = 'SELECT Id,' + String.join(lstFieldsToQuery, ',') + ' FROM CSM_Admin_Management__c where Status__c = \'New\' and Queue_Id__c = :queueId';
            response.lstDataTableData = Database.query(query);
        }
        
        return response;
    }
    
    @AuraEnabled
    public static void deleteRecord(String id){
        List<CSM_Admin_Management__c> dataList = Database.query('Select Id,Name From CSM_Admin_Management__c where id = :id');
        delete dataList;
    }
    
}
