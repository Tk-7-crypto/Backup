public class SLT_TPARegionCountry extends fflib_SObjectSelector {
    public static SLT_TPARegionCountry instance {
        get {
            if(instance == null) {
                instance = new SLT_TPARegionCountry();
            }
            return instance;
        }
        set;
    }

      public List<Schema.SObjectField> getSObjectFieldList() {
          return new List<Schema.SObjectField>{
              TPA_Region_Country__c.TP_Processor__c };
      }

      public Schema.SObjectType getSObjectType() {
          return TPA_Region_Country__c.sObjectType;
      }

      public List<TPA_Region_Country__c> getTPARegionCountryDataByConditionAndLimit(Set<String> fieldSet, String filterCondition, Integer recordLimit) {
          return (List<TPA_Region_Country__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(filterCondition).setLimit(recordLimit).toSOQL());
      }


}