/*
 * Version       : 1.0
 * Description   : Selector Class for TPA_Request__c
 */
public class SLT_TPARequest extends fflib_SObjectSelector {
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            TPA_Request__c.Id,
            TPA_Request__c.Name,
            TPA_Request__c.OwnerId,
            TPA_Request__c.Client_Address__c,
            TPA_Request__c.Client_Company_Name_Address__c,
            TPA_Request__c.ClientContact__c,
            TPA_Request__c.Request_Status__c,
            TPA_Request__c.Data_Access_End_Date__c,
            TPA_Request__c.Vendor_Language__c,
            TPA_Request__c.Vendor_e_mail__c,
            TPA_Request__c.Data_Access_End_Date__c,
            TPA_Request__c.tp_processor_email__c,
            TPA_Request__c.AMA_USPrescriberData__c,
            TPA_Request__c.Request_Type__c,
            TPA_Request__c.Vendor_First_Name__c,
            TPA_Request__c.Vendor_Contact_Last_Name__c,
            TPA_Request__c.Vendor_Contact_Title__c,
            TPA_Request__c.Vendor_e_mail__c,
            TPA_Request__c.Client_Address__c,
            TPA_Request__c.Client_Company_Name_Address__c
        };
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return TPA_Request__c.sObjectType;
    }

    /**
     * This method is used to get all TPA requests By Client Contact Id
     * @return List<TPA_Request__c>
     */
    public List<TPA_Request__c> selectByContactId(Set<Id> contactIdsSet, Set<String> fieldSet) {
        return (List<TPA_Request__c>)Database.query(newQueryFactory(true)
                                                    .setCondition('ClientContact__c IN :contactIdsSet')
                                                    .addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING)
                                                    .toSOQL());
    }

    /**
     * This method is used to get all TPA Requests by IDs
     * @return A QueryLocator
     */
    public Database.QueryLocator queryLocatorTPARequestById(Set<Id> idSet, Set<String> fieldSet) {
        return Database.getQueryLocator(newQueryFactory(true)
                                        .selectFields(fieldSet)
                                        .setCondition('Id IN :idSet')
                                        .toSOQL());
    }

    public List<TPA_Request__c> getTPARequestById(Set<Id> idSet, Set<String> fieldSet){
  		return (List<TPA_Request__c>)Database.query(newQueryFactory(true)
                                                    .selectFields(fieldSet)
                                                    .setCondition('Id IN :idSet')
                                                    .toSOQL());
  	}

    public List<TPA_Request__c> selectTPARequestWithAMAAndAgrAdditionalFieldData(Set<String> reqFieldSet, Set<String> amaAgrFieldSet,  String orderBy, String sortOrder) {
        fflib_QueryFactory tpaRequestFactory = newQueryFactory(true).selectFields(reqFieldSet);
        fflib_QueryFactory amaAgreementFactory = SLT_AMAAgreementDetail.instance.addQueryFactorySubselect(tpaRequestFactory, 'AMA_Agreement_Details__r')
                                                                                .selectFields(amaAgrFieldSet);
        fflib_QueryFactory agrAdditionalFieldFactory = SLT_TPAAgreementAdditionalField.instance
                                                                                      .addQueryFactorySubselect(tpaRequestFactory, 'TPA_Agreement_Additional_Fields__r')
                                                                                      ;
        return (List<TPA_Request__c>) Database.query(tpaRequestFactory.toSOQL());
    }

  	public Database.QueryLocator queryLocatorTPARequest(Integer recLimit) {
        return Database.getQueryLocator(newQueryFactory(true)
                                        .setLimit(recLimit)
                                        .toSOQL());
    }

    public Database.QueryLocator queryLocatorTPARequest(String query) {
        return Database.getQueryLocator(query);
    }

    public List<TPA_Request__c> getTPARequests(String query){
    	return (List<TPA_Request__c>)Database.query(query);
    }

    public static SLT_TPARequest instance {
        get {
            if(instance == null) {
                instance = new SLT_TPARequest();
            }
            return instance;
        }
        set;
    }
}