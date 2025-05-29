public without sharing class CNT_CSM_ViewStat {
    @AuraEnabled
    public static void insertViewStat(String objectApiName, String recordId, String source){
        List<User> users = new List<User>();
        CSM_QI_View_Stat__c vs = null;
        String contactId = null;
        String accountId = null;
        users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'AccountId','ContactId'});
        if (users.size() > 0) {
            if(users[0].ContactId != null){
                contactId = users[0].ContactId;
            }
            if(users[0].AccountId != null){
                accountId = users[0].AccountId;
            }
            if(objectApiName == 'Knowledge__kav') {
                List<Knowledge__kav> kl =new SLT_Knowledge().getArticlesById(new Set<Id> {recordId}, new Set<String> {'ArticleNumber', 'KnowledgeArticleId', 'Title','PublishStatus','CreatedById', 'Test__c', 'ProductName__c', 'Pillar__c'});
                if(kl.size() > 0 ) {
                    if (kl[0].PublishStatus == 'Online') {
                        vs= new CSM_QI_View_Stat__c();
                        vs.ArticleNumber__c = kl[0].ArticleNumber;
                        vs.Title__c = kl[0].Title;
                        vs.Article_Creator__c = kl[0].CreatedById;
                        vs.Article_Reviewer__c = kl[0].Test__c;
                        vs.ProductName__c = kl[0].ProductName__c;
                        vs.Pillar__c = kl[0].Pillar__c;
                        vs.Contact__c = contactId;
                        vs.Account__c = accountId;
                        vs.ObjectApiName__c = objectApiName;
                        vs.Source__c = source;
                    }
                }
            }else if(objectApiName == 'Case'){
                List<Case> csList = [select id,CaseNumber,ProductId,Subject from case where id=:recordId];
                if(csList.size() > 0) {
                    vs= new CSM_QI_View_Stat__c();
                    vs.ProductName__c = csList.size()>0 ? csList[0].ProductId : null;
                    vs.Contact__c = contactId;
                    vs.Account__c = accountId;
                    vs.ObjectApiName__c = objectApiName;
                    vs.Source__c = source;
                    vs.Case_Number__c = csList[0].CaseNumber;
                    vs.Title__c = csList[0].Subject;
                }
            }
            if(vs != null) {
                try{
                    insert vs;
                } catch(Exception ex) {
                    throw new AuraHandledException(ex.getMessage());
                }
            }
        }
    }
    
}