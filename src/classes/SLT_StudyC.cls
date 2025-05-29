public class SLT_StudyC extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_StudyC() {
        super(false, true, true);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Study__c.sObjectType;
    }
    
    /**
     * This method used to get Study__c by Id
     * @return  Map<Id, Study__c>
     */
    public Map<Id, Study__c> selectByStudyId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Study__c>((List<Study__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet and Status__c = \'Active\'').toSOQL()));
    }
    
    /**
     * This method used to get Study__c by Id
     * @return  List<Study__c>
     */
    public List<Study__c> selectAccountByStudyId(Set<ID> idSet, Set<String> fieldSet) {
        return (List<Study__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet and Status__c = \'Active\'').toSOQL());
    }
    
    /**
     * This method used to get Study__c by Name
     * @return  List<Study__c>
     */
    public List<Study__c> selectAccountByStudyName(String name, Set<String> fieldSet) {
        return (List<Study__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Name =:name and Status__c = \'Active\'').toSOQL());
    }
    
    public List<Study__c> selectAllStudies(Set<String> fieldSet)
    {
        return (List<Study__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL()); 
    }
    
    public List<Study__c> selectStudyBasedOnProtocol(Set<String> protocolSet){
        return (List<Study__c>) Database.query('SELECT Id, Name, Sponsor__c,Sponsor__r.Name, Protocol__c,StudyID__c,ExtStudyId__c,ExtStudySystem__c FROM Study__c WHERE Name IN :protocolSet and Status__c = \'Active\'');
    }
	public List<Study__c> selectStudyBasedOnName(Set<String> protocolNameSet){
        return (List<Study__c>) Database.query('SELECT Id, Name, Sponsor__c, Protocol__c,StudyID__c,ExtStudyId__c,ExtStudySystem__c FROM Study__c WHERE Name IN :protocolNameSet and Status__c = \'Active\'');
    }
}