/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Project_Metric
 */
public class SLT_Project_Metric extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Project_Metric () {
        super(false, true, true);
    }
    
    /**
     * constructor to initialise CRUD and FLS with a parameter for FLS.
     */
    public SLT_Project_Metric (Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList () {
        Schema.DescribeSObjectResult describeResult = getSObjectType().getDescribe(); 
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();   
        return fieldsMap.values();
    }

    /**
     * This method used to get field set of field names for the sobject
     * @return  Set<String>
     */
    public Set<String> getSObjectFieldSet () {
        Set<String> fieldNames = new Set<String>();
        List<Schema.SObjectField> fields = getSObjectFieldList();
        if (fields != null && fields.size() > 0) {
            for (Schema.SObjectField sobjField : fields) {
                fieldNames.add(String.valueof(sobjField));
            }
        }        
        return fieldNames;
    }    
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType () {
        return Project_Metric__c.sObjectType;
    }

    /*
     * finds project metrics for specific fields and conditions
     * fieldSet - specific fields to query
     * conditions - specific condition to apply
     */
    public Project_Metric__c[] findBy (Set<String> fieldSet, String conditions) {
        return findByIds(fieldSet, conditions, null);
    }    

    /*
     * finds project metrics for specific fields and conditions
     * fieldSet - specific fields to query
     * conditions - specific condition to apply
     */
    public Project_Metric__c[] findByIds (Set<String> fieldSet, String conditions, Set<Id> idSet) {
        fflib_QueryFactory soqlBuilder = newQueryFactory(true);
        soqlBuilder.selectFields(fieldSet);
        soqlBuilder.setCondition(conditions);
        return ((Project_Metric__c[]) Database.query(soqlBuilder.toSOQL()));
    }    

    /*
     * finds project metrics by project id
     */
    public List<Project_Metric__c> selectByProject(Set<Id> projectIdSet, Set<String> fieldSet) {
        fflib_QueryFactory projectMetricQueryFactory = newQueryFactory(true);
        String queryString = projectMetricQueryFactory.selectFields(fieldSet).setCondition('Project__c IN :projectIdSet').toSOQL();
        return (List<Project_Metric__c>) Database.query(queryString);
    }
    
    /*
     * populate protocol picklist values
     * */
    public List<Project_Metric__c> findProtocolNamesForProject(String rdsProjectId) {
        List<Project_Metric__c> protocolList = [Select Id, Protocol_Name__c from Project_Metric__c  where Project__r.Id = :rdsProjectId ORDER BY Protocol_Name__c];
        return protocolList;
    }
    
    //check for RDS admin permission set
    public List<PermissionSetAssignment> hasRDSAdminPermmission() {
        List<PermissionSetAssignment> permissionSetList = [SELECT  PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
        return permissionSetList;
    }
}
