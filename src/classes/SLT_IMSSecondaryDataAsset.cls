/*
 * Version       : 1.0
 * Description   : Selector Class for IMS_Secondary_Data_Asset__c
 */
public class SLT_IMSSecondaryDataAsset extends fflib_SObjectSelector {    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            IMS_Secondary_Data_Asset__c.Id,
            IMS_Secondary_Data_Asset__c.Name,
            IMS_Secondary_Data_Asset__c.Secondary_Asset_Name__c
        };
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return IMS_Secondary_Data_Asset__c.sObjectType;
    }

    public static SLT_IMSSecondaryDataAsset instance {
        get {
            if(instance == null) {
                instance = new SLT_IMSSecondaryDataAsset();
            }
            return instance;
        }
        set;
    }
}