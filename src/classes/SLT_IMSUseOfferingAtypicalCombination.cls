/*
 * Version       : 1.0
 * Description   : Selector Class for IMS_Use_Offering_Atypical_Combination__c
 */
public class SLT_IMSUseOfferingAtypicalCombination extends fflib_SObjectSelector {    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            IMS_Use_Offering_Atypical_Combination__c.Id,
            IMS_Use_Offering_Atypical_Combination__c.Use_Category__c,
            IMS_Use_Offering_Atypical_Combination__c.Use_Name__c,
            IMS_Use_Offering_Atypical_Combination__c.Offering_Country_del__c,
            IMS_Use_Offering_Atypical_Combination__c.Offering_Category__c, 
            IMS_Use_Offering_Atypical_Combination__c.Offering_Name__c,
            IMS_Use_Offering_Atypical_Combination__c.Secondary_Offering_Name__c, 
            IMS_Use_Offering_Atypical_Combination__c.isActive__c
        };
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return IMS_Use_Offering_Atypical_Combination__c.sObjectType;
    }

    /**
     * This method used to get all IMS_Use_Offering_Atypical_Combinations
     * @return  List<IMS_Use_Offering_Atypical_Combination__c>
     */
    public List<IMS_Use_Offering_Atypical_Combination__c> selectAllAtypicalUseOffComb(Set<String> fieldSet) {
        return (List<IMS_Use_Offering_Atypical_Combination__c>) Database.query(newQueryFactory(true).selectFields(fieldSet).toSOQL());
    }

    public static SLT_IMSUseOfferingAtypicalCombination instance {
        get {
            if(instance == null) {
                instance = new SLT_IMSUseOfferingAtypicalCombination();
            }
            return instance;
        }
        set;
    }
}