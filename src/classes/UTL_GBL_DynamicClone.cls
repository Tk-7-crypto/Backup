public Without Sharing class UTL_GBL_DynamicClone {
   public static List<sObject> cloneObjects(List<sObject> sObjects, Schema.SObjectType objectType){    
    List<Id> sObjectIds = new List<Id>{};
    List<String> sObjectFields = new List<String>{};
    List<sObject> clonedSObjects = new List<sObject>{};    
    if(objectType != null) {
        sObjectFields.addAll(objectType.getDescribe().fields.getMap().keySet());
    }    

    if (sObjects != null && !sObjects.isEmpty() && !sObjectFields.isEmpty()) {    
        for (sObject objectInstance: sObjects){
            sObjectIds.add(objectInstance.Id);
        }
  
      	String allSObjectFieldsQuery = 'SELECT ' + sObjectFields.get(0);     
        for (Integer i = 1 ; i < sObjectFields.size() ; i++){
            allSObjectFieldsQuery += ', ' + sObjectFields.get(i);
        }    
        allSObjectFieldsQuery += ' FROM '+objectType.getDescribe().getName()+ ' WHERE ID IN (\''+sObjectIds.get(0)+ '\'';
        for (Integer i = 1 ; i < sObjectIds.size() ; i++){
            allSObjectFieldsQuery += ', \'' + sObjectIds.get(i) + '\'';
        }    
        allSObjectFieldsQuery += ')'; 
        
        try{      
            List<SObject> sObjectListFromDatabase = Database.query(allSObjectFieldsQuery);
            for (SObject sObjectFromDatabase : sObjectListFromDatabase) {
                clonedSObjects.add(sObjectFromDatabase.clone(false, true, false, false));  
            }    
        } catch (exception e){
            system.debug('ERROR in Dynamic Clone = '+e.getMessage());
        }
    }      
       return clonedSObjects;
   }
}