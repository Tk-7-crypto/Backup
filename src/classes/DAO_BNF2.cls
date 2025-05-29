public class DAO_BNF2  extends fflib_SObjectDomain {
    
    public DAO_BNF2(List<BNF2__c> sObjectList) {
        super(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_BNF2(sObjectList);
        }
    }
    
    public override void onAfterInsert() {
        DAOH_BNF2.updateOpportunityFields((List<BNF2__c>)Records, null);
    }
    
    public override void onAfterDelete() {
        DAOH_BNF2.updateOpportunityFields((List<BNF2__c>)Records, null);
    }
}