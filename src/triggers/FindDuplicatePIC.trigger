//This trigger was created by Hari on Old UAT org for defect #10314
//Refactored by Abhishek Bansal : 31-Dec-2015 : Issue-08184 : Remove SOQL queries from trigger 
trigger FindDuplicatePIC on Principal_In_Charge__c(before insert,before update){
    Set<Id> setOfUserIds = new Set<Id>();
    for(Principal_In_Charge__c newPIC : trigger.new){
        if(newPIC.User__c != null){
            setOfUserIds.add(newPIC.User__c);
        }
        if(trigger.isInsert || (trigger.isUpdate && trigger.oldMap.get(newPIC.id).User__c != newPIC.User__c)) {
            newPIC.External_Id__c = newPIC.User__c;
        }
    }
    
    Map<Id,Id> mapOfPICWithUser = new Map<Id,Id>();
    Map<Id,User> mapOfUsers = new Map<Id,User>();
    
    if(setOfUserIds.size() > 0){
        for(Principal_In_Charge__c pic : [Select Id, Name, User__c from Principal_In_Charge__c where User__c in :setOfUserIds ]){
            mapOfPICWithUser.put(pic.User__c, pic.id);
        }
        
        for(User u : [select Name,FirstName,LastName from User where Id in :setOfUserIds]) {
            mapOfUsers.put(u.id, u);
        }
    }
    
    for(Principal_In_Charge__c newPIC : trigger.new){
        if((trigger.isInsert || (trigger.isUpdate && trigger.oldMap.get(newPIC.id).User__c != newPIC.User__c)) && mapOfPICWithUser.containsKey(newPIC.User__c)){
            newPIC.addError('PIC Already exist for this User'); 
        }
        else{
            System.debug('New PIC ____ '+ newPIC);
            System.debug('mapOfUsers___' + mapOfUsers);
            if(!newPIC.Name.contains('Cegedim') && mapOfUsers.containsKey(newPIC.User__c) && newPIC.Name != mapOfUsers.get(newPIC.User__c).LastName + ', ' + mapOfUsers.get(newPIC.User__c).FirstName){
                newPIC.Name.addError('Incorrect format for PIC please enter as [LastName],{space}[FirstName]');
            }
        }
    }
}