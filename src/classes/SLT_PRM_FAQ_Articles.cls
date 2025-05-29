public class SLT_PRM_FAQ_Articles {
    
    public List<PRM_FAQ_Articles__c> getFAQArticles(){
        return  Database.query('SELECT Name, Article_Link__c FROM PRM_FAQ_Articles__c WHERE IsActive__c = true ORDER BY Order__c');
    }
}