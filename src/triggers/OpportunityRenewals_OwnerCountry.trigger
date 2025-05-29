trigger OpportunityRenewals_OwnerCountry on Renewal_Task__c (before insert, before update) {
    
    Set<Id> UserIdSet = new Set<Id> ();
    for(Renewal_Task__c newTask : Trigger.new){
        UserIdSet.add(newTask.ownerId);
    }
    
    Map<Id, User> UserMap = new Map<Id, User>([select id, User_Country__c from User where id in : UserIdSet]);
    
    for(Renewal_Task__c newTask : Trigger.new){
        User taskOwnerObj = UserMap.get(newTask.ownerId);
        if(taskOwnerObj != null )
            newTask.Owner_Country__c = taskOwnerObj.User_Country__c;        
    }
    
}