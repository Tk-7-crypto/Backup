public class DAOH_Knowledge {
    
    public static void addAccountKnowledgeRecord(List<Knowledge__kav> newKnowledgeList){
        set<string> articleNumberSet = new set<string>();
        List<Knowledge_Account_RelationShip__c> newKAccountList =new List<Knowledge_Account_RelationShip__c>();
        Knowledge_Account_RelationShip__c newKAccount;
        for(Knowledge__kav knowId : newKnowledgeList)  {
            articleNumberSet.add(knowId.ArticleNumber);
        }
        List<Knowledge_Account_RelationShip__c> knowledgeAccount = [SELECT id,Account__c, Location__c, Knowledge__r.PublishStatus,Knowledge__r.ArticleNumber FROM Knowledge_Account_RelationShip__c WHERE Knowledge__r.ArticleNumber in: articleNumberSet and Knowledge__r.PublishStatus ='Online'];
        if(knowledgeAccount.size()>0)  {
            for(Knowledge_Account_RelationShip__c knowRelation : knowledgeAccount ){
                for (Knowledge__kav knowledgeRecord : newKnowledgeList){
                    if(knowledgeRecord.PublishStatus == 'Draft')  {
                        newKAccount = new Knowledge_Account_RelationShip__c();
                        newKAccount.Knowledge__c = knowledgeRecord.id;
                        if(knowRelation.Account__c != null)
                            newKAccount.Account__c = knowRelation.Account__c;
                        if(knowRelation.Location__c != null)
                            newKAccount.Location__c = knowRelation.Location__c;
                        newKAccountList.add(newKAccount);
                    }
                }
            }
            if(newKAccountList.size()>0)
                insert newKAccountList;
        } 
    }

    public static void updateVisibleToPartner(List<Knowledge__kav> newKnowledgeList){
        List<Knowledge__kav> knowArticles = new List<Knowledge__kav>();
        Set<String> knowId = new Set<String>();
        String partnerType = 'Integrator Partner;Data Partner;Tech Partner;One Home for Sites;AMESA - Integrator Partner';
        for(Knowledge__kav ka : newKnowledgeList)
        {
            if(ka.IsVisibleInCsp == true && ka.IsVisibleInPrm == false && ka.PublishStatus == 'Draft')
            {
                ka.IsVisibleInPrm = true;
                if(ka.Partner_Type__c == null || ka.Partner_Type__c == '')
                {
                    ka.Partner_Type__c = partnerType;
                }
            }
        
        }
    }
    
    public static void setDefaultValuesinDraftStatus(List<Knowledge__kav> newList){
        for(Knowledge__kav k : newList)  {
            if(k.Pillar__c != null && k.Pillar__c == 'R&D' && k.PublishStatus == 'Draft')  {
                k.ValidationStatus = 'Not Validated';
            }
            k.ReviewDate__c = System.today().addYears(1);
        }
    }

    public static void deleteArticleOrder(List<Knowledge__kav> newList, Map<Id, Knowledge__kav> oldMap) {
        List<String> ArticleNumbers = new List<String>();
        for (Knowledge__kav newRecord : newList) {
            Knowledge__kav oldRecord = oldMap.get(newRecord.Id);
            if (oldRecord != null && oldRecord.Article_Chapter__c != null && oldRecord.Article_Chapter__c != '' && oldRecord.Article_Chapter__c != newRecord.Article_Chapter__c) {
                ArticleNumbers.add(newRecord.ArticleNumber);
            }
        }
        if (!ArticleNumbers.isEmpty()) {
            List<CSM_QI_Knowledge_Article_Order__c> articleOrdersToDelete = [
                SELECT Id
                FROM CSM_QI_Knowledge_Article_Order__c
                WHERE ArticleNumber__c IN :ArticleNumbers
            ];
            
            if (!articleOrdersToDelete.isEmpty()) { 
                delete articleOrdersToDelete;
            }
        }
    }
}
