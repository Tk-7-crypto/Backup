/*
 * Version       : 1.0
 * Description   : Apex Controller for LXC_CSM_KnowledgeBrowser 
 */ 
public class CNT_CSM_KnowledgeBrowser {
    
    /*
    * Return a List of products Name with Community_Topic__c not null and and present in CaseCategorization Object 
    */
    @AuraEnabled
    public static List<AggregateResult> getProducts(){ 
        List<AggregateResult> products = new List<AggregateResult>();
        List<Product2> prds = new List<Product2>();
        prds = new SLT_Product2().getProductWithFilter(new Set<String>{'Name'},'Community_Topic__c != \'\' ');
        Set<String> prdNames = new Set<String>();
        for(Product2 prd: prds){
            prdNames.add(prd.Name);
        }
        products = new SLT_CaseCategorization().getProducts(prdNames);
        return products;
    }
    /*
    * Return List of Knowledge__kav by productName
    */
    @AuraEnabled
    public static List<Knowledge__kav> getArticlesByProductName(String productName){
        List<Knowledge__kav> articles =  new SLT_Knowledge().selectByProductName(productName);
        return articles;
    }

    @AuraEnabled
    public static List<Knowledge__kav> getArticlesByProductName2(String productName, String accountId){
        List<Knowledge__kav> articles = new List<Knowledge__kav>();
        Set<Id> knowledgeIds = new  Set<Id>(); 
        if (accountId!=''){
        for (Knowledge_Account_RelationShip__c ak:  Database.query('select Knowledge__c from Knowledge_Account_RelationShip__c where Knowledge__r.PublishStatus =\'Online\' and Knowledge__r.ProductName__c = \''+productName+'\' and Knowledge__r.IsMasterLanguage = true and Account__c=\''+ accountId + '\'')){
            knowledgeIds.add(ak.Knowledge__c);
        }
            articles =  new SLT_Knowledge().selectById(knowledgeIds);
        }else{
            articles =  new SLT_Knowledge().selectByProductName(productName);
        }
        return articles;
    }

    @AuraEnabled
    public static Map<Id, Account> getAccountsArticlesByProductName(String productName){
        Map<Id, Account> accounts = new Map<Id, Account>();
        Set<Id>  accountIds = new  Set<Id>(); 
        for (Knowledge_Account_RelationShip__c ak:  Database.query('select Account__c from Knowledge_Account_RelationShip__c where Knowledge__r.PublishStatus =\'Online\' and Knowledge__r.IsMasterLanguage = true and Knowledge__r.ProductName__c = \''+productName+'\'')){
            accountIds.add(ak.Account__c);
        }
        accounts = new SLT_Account().selectByAccountId(accountIds, new Set<String>{'id', 'Name'});
        return accounts;
    }
}