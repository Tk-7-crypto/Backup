/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for ProcessInstance
 */
public class SLT_ProcessInstance extends fflib_SObjectSelector {
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ProcessInstance.Id,
            ProcessInstance.TargetObjectId,
            ProcessInstance.SubmittedById,
            ProcessInstance.Status
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */    
    public Schema.SObjectType getSObjectType() {
        return ProcessInstance.sObjectType;
    }    
    
    /**
     * Return List<ProcessInstanceWorkitem>
     * @Param set Of object Id for which approval process is working
     */
    public List<ProcessInstance> getProcessInstanceByTargetObjectIdAndStatus(Set<Id> setOfTargetId, String status, Set<String> fieldSet){

        return (List<ProcessInstance>) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('TargetObjectId IN: setOfTargetId AND processInstance.Status =:' + ' status').toSOQL());
    }
}