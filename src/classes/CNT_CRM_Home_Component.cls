public class CNT_CRM_Home_Component {
    
    @AuraEnabled
    public static List<CSM_QI_News__c> getData(String profile,String field){
        string query = 'SELECT Id,Dashboard_Title__c,'+field+' FROM CSM_QI_News__c WHERE Profile__c =\''+ profile + '\' and Mode__c =\'Published\' and Module__c =\'CRM\' ORDER BY LastModifiedDate DESC';
        return Database.query(query);
    }
    
    @AuraEnabled
    public static Boolean hasEditPermission(String field){ 
        Map<String,Schema.SObjectField> m = Schema.SObjectType.CSM_QI_News__c.fields.getMap();
        if (m.containsKey(field) && m.get(field).getDescribe().isUpdateable()) {
            return true;
        }
        else{
            return false;           
        }
    }
}