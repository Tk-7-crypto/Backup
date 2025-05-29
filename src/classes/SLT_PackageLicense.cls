public class SLT_PackageLicense extends fflib_SObjectSelector {

    public SLT_PackageLicense() {
        super(false, false, false);
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            PackageLicense.Id,
            PackageLicense.NamespacePrefix,
            PackageLicense.Status,
            PackageLicense.IsProvisioned,
            PackageLicense.AllowedLicenses,
            PackageLicense.UsedLicenses,
            PackageLicense.ExpirationDate
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return PackageLicense.sObjectType;
    }
    
    public List<PackageLicense> selectById(Set<ID> idSet) {
        return (List<PackageLicense>) selectSObjectsById(idSet);
    }

    public List<PackageLicense> selectPackageLicensesOnOrg(){
        List<Organization> orgList = new SLT_Organization().selectOrganizationList();
        String packageQuery;
        if(orgList[0].isSandbox){
            packageQuery = 'SELECT Id, NamespacePrefix, AllowedLicenses, UsedLicenses, Status FROM PackageLicense WHERE NamespacePrefix = \'cnx\' LIMIT 1';
        }
        else{
            packageQuery = 'SELECT Id, NamespacePrefix, AllowedLicenses, UsedLicenses, Status FROM PackageLicense WHERE NamespacePrefix = \'cnx\' AND Status = \'Active\' AND AllowedLicenses > 0 LIMIT 1';
        }
        return (List<PackageLicense>)Database.query(packageQuery);
    }
    
    public Map<Id, UserPackageLicense> selectPackageMapOnId(Id packageId){
        return new Map<Id, UserPackageLicense>((List<UserPackageLicense>)Database.query('SELECT Id, PackageLicenseId, UserId FROM UserPackageLicense WHERE PackageLicenseId = :packageId'));
    }
}