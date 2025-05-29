public class CNT_CSM_AddOrRemoveFavoriteRecord {
    @AuraEnabled(cacheable=true)
    public static Boolean isFavorite(SObject genericRecord)
    {   
        Boolean isFav= false;
        List<CSM_QI_Favorite_Record__c> favRecordList = new List<CSM_QI_Favorite_Record__c>();
        Id recordId = genericRecord.Id;
        String entityName = string.valueOf(recordId.getSObjectType());
        String condition = '';
        if(entityName == 'Knowledge__kav') {
            knowledge__kav record = new knowledge__kav();
            record = (knowledge__kav)genericRecord;
            condition = ' AND EntityId__c = \'' + record.KnowledgeArticleId + '\'';   
        }
        if(entityName == 'Case') {
            Case record = new Case();
            record = (Case)genericRecord;
            condition = ' AND EntityId__c = \'' + record.Id + '\'';   
        }
        favRecordList = Database.query('SELECT Id FROM CSM_QI_Favorite_Record__c WHERE EntityName__c = \'' + entityName + '\' AND User__c = \'' + UserInfo.getUserId() + '\'' + condition);
        if (favRecordList.size() > 0) {
            isFav = true;
        }
        return isFav;
    }

    @AuraEnabled
    public static Boolean addOrRemoveFavorite(SObject genericRecord, Boolean isFavorite)
    {
        List<CSM_QI_Favorite_Record__c> favRecordList = new List<CSM_QI_Favorite_Record__c>();
        CSM_QI_Favorite_Record__c favRecord;
        String entityName = string.valueOf(genericRecord.Id.getSObjectType());
        if (isFavorite){
            if(entityName == 'Knowledge__kav') {
                knowledge__kav record = (knowledge__kav)genericRecord;
                favRecord = New CSM_QI_Favorite_Record__c (EntityName__c= 'Knowledge__kav' , EntityId__c = record.KnowledgeArticleId,  User__c = UserInfo.getUserId()); 
            }
            if(entityName == 'Case') {
                Case record = (Case)genericRecord;
                favRecord = New CSM_QI_Favorite_Record__c (EntityName__c= 'Case' ,EntityId__c = record.Id,  User__c = UserInfo.getUserId()); 
            }
            insert favRecord;
        }else{
            if(entityName == 'Knowledge__kav') {
                knowledge__kav record = (knowledge__kav)genericRecord;
                favRecordList = [SELECT Id FROM CSM_QI_Favorite_Record__c WHERE EntityName__c= 'Knowledge__kav' AND EntityId__c =: record.KnowledgeArticleId AND User__c =: UserInfo.getUserId()];
            }
            if(entityName == 'Case') {
                Case record = (Case)genericRecord;
                favRecordList = [SELECT Id FROM CSM_QI_Favorite_Record__c WHERE EntityName__c= 'Case' AND EntityId__c =: record.Id AND User__c =: UserInfo.getUserId()];
            }
            if (favRecordList.size() > 0) {
                delete favRecordList;
            }
        }
        return true;
    }
}