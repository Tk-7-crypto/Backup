public class SLT_Finance_IQVIA_Legal_Entity_Extension extends fflib_SObjectSelector {
    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_Finance_IQVIA_Legal_Entity_Extension() {
        super(false, true, true);
    }
    
    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_Finance_IQVIA_Legal_Entity_Extension(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS);
    }
    
    /**
    * This method used to set up type of sobject.
    */
    public Schema.SObjectType getSObjectType() {
        return Finance_IQVIA_Legal_Entity_Extension__c.sObjectType;
    }
    
    /**
    * overriding getOrderBy
    */    
    public override String getOrderBy() {
        return 'Name ASC';
    }
    
    /**
    * This method gives the list of SObjectField of Finance_IQVIA_Legal_Entity_Extension__c object.
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Finance_IQVIA_Legal_Entity_Extension__c.Id
        };
    }
}