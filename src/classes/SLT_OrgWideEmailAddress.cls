public class SLT_OrgWideEmailAddress extends fflib_SObjectSelector{

    /**
    * constructor to initialise CRUD and FLS
    */
    public SLT_OrgWideEmailAddress() {
        super(false, false, false);
    }

    /**
    * This method used to get field list of sobject
    * @return  List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            OrgWideEmailAddress.Id
        };
    }

    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return OrgWideEmailAddress.sObjectType;
    }

    /**
    * This method used to get OrgWideEmailAddress by Id
    * @return  List<OrgWideEmailAddress >
    */
    public List<OrgWideEmailAddress> selectById(Set<ID> idSet) {
        return (List<OrgWideEmailAddress>) selectSObjectsById(idSet);
    }

    /**
    * This method used to get OrgWideEmailAddress by email address
    * @return  List<OrgWideEmailAddress>
    */
    public List<OrgWideEmailAddress> selectOrgWideEmailAddressByAdress(String emailAddress, Set<String> fieldSet) {
        return (List<OrgWideEmailAddress>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Address =: emailAddress').toSOQL());
    }

    /**
    * This method used to get OrgWideEmailAddress by Display Name
    * @return  List<OrgWideEmailAddress>
    */
    public List<OrgWideEmailAddress> selectOrgWideEmailAddressByName(String name, Set<String> fieldSet) {
        return (List<OrgWideEmailAddress>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('DisplayName =: name').toSOQL());
    }
}