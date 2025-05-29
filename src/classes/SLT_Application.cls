public class SLT_Application extends fflib_SObjectSelector{

    public SLT_Application() {
        super(false, true, true);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Apttus_XApps__Application__c.Id,
            Apttus_XApps__Application__c.Name,
            Apttus_XApps__Application__c.Apttus_XApps__UniqueId__c
        };
    }

    public Schema.SObjectType getSObjectType() {

        return Apttus_XApps__Application__c.sObjectType;
    }

    public List<Apttus_XApps__Application__c> getApplicationByName(Set<String> names, Set<String> fieldSet){

        return new List<Apttus_XApps__Application__c>((List<Apttus_XApps__Application__c>) 
            Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Name in :names').toSOQL()));
    }
}