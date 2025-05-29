global class BCH_KAV_UpdateKnowledgeArticles implements Database.Batchable<sObject>,Database.Stateful {
    global List<KB_Mass_Draft_Articles__c> updatedCS;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<KB_Mass_Draft_Articles__c> kaDetails = [SELECT Name,To_Run__c FROM KB_Mass_Draft_Articles__c WHERE To_Run__c = true];
        Set<Id> articleId = new Set<Id>();
        for(KB_Mass_Draft_Articles__c kaId : kaDetails)
        {
            articleId.add(kaId.Name);
        }
        String query='SELECT KnowledgeArticleId FROM Knowledge__kav WHERE  PublishStatus = \'Online\' AND KnowledgeArticleId IN: articleId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Knowledge__kav> articleList){           
        Set<Id> updatedArticleId = new Set<Id>();
        Set<Id> failedArticleId = new Set<Id>();
        Map<Id,String> mapIdError = new Map<Id,String>();
        for(Knowledge__kav article : articleList)
        {
            try
            {                
                String draftArticleId = KBManagement.PublishingService.editOnLineArticle(article.KnowledgeArticleId,false);
                updatedArticleId.add(article.KnowledgeArticleId);
            }
            catch(Exception ex)
            {
                updatedArticleId.add(article.KnowledgeArticleId);
                if(ex.getMessage().Length() >= 254)
                {
                    mapIdError.put(article.KnowledgeArticleId, ex.getMessage().substring(0,254));  
                }
                else
                {
                    mapIdError.put(article.KnowledgeArticleId, ex.getMessage());
                }
            }
        }
        
        updatedCS = [SELECT Name,To_Run__c,Error_Message__c FROM KB_Mass_Draft_Articles__c WHERE Name IN : updatedArticleId];
        for(KB_Mass_Draft_Articles__c updateCS : updatedCS)
        {
            if(mapIdError != null)
            {
                if(mapIdError.containsKey(updateCS.Name) && mapIdError.get(updateCS.Name) != null)
                {
                    updateCS.Error_Message__c = mapIdError.get(updateCS.Name);
                }
                else
                {
                    updateCS.To_Run__c = false;
                }
            }
            else
            {
                updateCS.To_Run__c = false;
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        update updatedCS;
    }
}