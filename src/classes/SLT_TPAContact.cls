public class SLT_TPAContact extends fflib_SObjectSelector {

    public static SLT_TPAContact instance {
        get {
            if(instance == null) {
                instance = new SLT_TPAContact();
            }
            return instance;
        }
        set;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            TPA_Contact__c.Id};
    }

    public Schema.SObjectType getSObjectType() {
        return TPA_Contact__c.sObjectType;
    }

    public List<TPA_Contact__c> getTPAContactByCodition(String filterCondition){
  		return (List<TPA_Contact__c>)Database.query(newQueryFactory(true)
                                                    .setCondition(filterCondition)
                                                    .toSOQL());
  	}
}