public class SLT_TPAAgreementAdditionalField extends fflib_SObjectSelector {

    public static SLT_TPAAgreementAdditionalField instance {
        get {
            if(instance == null) {
                instance = new SLT_TPAAgreementAdditionalField();
            }
            return instance;
        }
        set;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            TPA_Agreement_Additional_Field__c.Id
        };
    }

    public Schema.SObjectType getSObjectType() {
        return TPA_Agreement_Additional_Field__c.sObjectType;
    }

}