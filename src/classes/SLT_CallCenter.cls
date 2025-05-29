public class SLT_CallCenter extends fflib_SObjectSelector {

    public SLT_CallCenter() {
        super(false, false, false); 
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            CallCenter.Id,
            CallCenter.Name,
            CallCenter.InternalName,
            CallCenter.Version,
            CallCenter.AdapterUrl,
            CallCenter.CustomSettings,
            CallCenter.CreatedById,
            CallCenter.CreatedDate
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return CallCenter.sObjectType;
    }
    
    public List<CallCenter> selectById(Set<ID> idSet) {
        return (List<CallCenter>) selectSObjectsById(idSet);
    }
    
    public Map<Id, CallCenter> selectCallCenterOnUser(Set<Id> callCenterIdSet){
        return new Map<Id, CallCenter>((List<CallCenter>)Database.query('SELECT Id, Name, Version FROM CallCenter WHERE Id IN :callCenterIdSet'));
    }
}