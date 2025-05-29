public class SLT_Organization extends fflib_SObjectSelector {

    public SLT_Organization() {
        super(false, false, false);
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Organization.Id,
            Organization.Name,
            Organization.City,
            Organization.State,
            Organization.Country,
            Organization.IsSandbox,
            Organization.OrganizationType,
            Organization.PrimaryContact,
            Organization.Phone
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Organization.sObjectType;
    }
    
    public List<Organization> selectById(Set<ID> idSet) {
        return (List<Organization>) selectSObjectsById(idSet);
    }
    
    public List<Organization> selectOrganizationList(){
        return [SELECT Id, Name, OrganizationType, IsSandbox FROM Organization];
    }
}