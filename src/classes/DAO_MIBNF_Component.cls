public class DAO_MIBNF_Component   extends fflib_SObjectDomain {
    
    public DAO_MIBNF_Component(List<MIBNF_Component__c> sObjectList) {
        super(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_MIBNF_Component(sObjectList);
        }
    }
    
    public override void onAfterInsert() {
        DAOH_MIBNF_Component.updateOpportunityFields((List<MIBNF_Component__c>)Records, null);
    }
    
    public override void onAfterDelete() {
        DAOH_MIBNF_Component.updateOpportunityFields((List<MIBNF_Component__c>)Records, null);
    }
}