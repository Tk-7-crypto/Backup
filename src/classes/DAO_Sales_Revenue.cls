public class DAO_Sales_Revenue extends fflib_SObjectDomain {
    
    public DAO_Sales_Revenue(List<Sales_Revenue__c> sObjectList) {
        super(sObjectList);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Sales_Revenue(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
        DAOH_Sales_Revenue.setSalesRevenueFields((List<Sales_Revenue__c>)Records);
    }
}