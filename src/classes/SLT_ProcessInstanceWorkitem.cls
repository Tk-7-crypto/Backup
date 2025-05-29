/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for ProcessInstanceWorkitem
 */
public class SLT_ProcessInstanceWorkitem extends fflib_SObjectSelector {
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ProcessInstanceWorkitem.Id,
            ProcessInstanceWorkitem.ProcessInstanceId            
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */    
    public Schema.SObjectType getSObjectType() {
        return ProcessInstanceWorkitem.sObjectType;
    }
    
    /**
     * This method used to get ProcessInstanceWorkitem by Id
     * @return  List<ProcessInstanceWorkitem>
     */
    public List<ProcessInstanceWorkitem> selectById(Set<ID> idSet) {
        return (List<ProcessInstanceWorkitem>) selectSObjectsById(idSet);
    }        
    
    /**
     * This method used to get pending work items list
     * @Param    idSet    Set<ID>
     * @Retuen    List<ProcessInstanceWorkitem>
     * @return  List<ProcessInstanceWorkitem>
     */    
    public List<ProcessInstanceWorkitem> getAllPendingWorkItems(Set<ID> idSet) {
        Set<String> fieldSet = new Set<String>{CON_CRM.WORKITEM_PROCESSINSTANCE_TARGETOBJECTID_FIELD_API};        
        return (List<ProcessInstanceWorkitem>) Database.query(newQueryFactory().selectFields(fieldSet).setCondition('ProcessInstance.Status = \'Pending\' and ProcessInstance.TargetObjectId IN :idSet').toSOQL());
    }    
    
    /**
     * Return RecordType Id
     * @Param    recordTypeName    
     */    
    public RecordType getRecordTypeIdByName(String recordTypeName) {   
        List<RecordType> recordType = [select id, name, developername from recordType where developername =: recordTypeName];
        return recordType[0];
    }

    /**
     * Return List<RecordType>
     * @Param    sObjectType
     */    
    public List<RecordType> getRecordTypesBySObjectType(String sObjectTypeName) {   
        List<RecordType> listRecordTypes = [select id, name, developername from recordType where SobjectType =: sObjectTypeName ];
        return listRecordTypes;
    }
	
    /**
     * Return List<ProcessInstanceWorkitem>
     * @Param set Of object Id for which approval process is working
     */    
    public List<ProcessInstanceWorkitem> getProcessInstanceWorkitemByTargetId(Set<Id> setOfTargetId) {   
        List<ProcessInstanceWorkitem> listOfworkItemLst = [SELECT Id , processInstance.TargetObjectId
                                                           FROM ProcessInstanceWorkitem  
                                                           WHERE processInstance.TargetObjectId=:setOfTargetId]; 
        return listOfworkItemLst;
    }
    
    /**
     * Return List<ProcessInstanceWorkitem>
     * @Param set Of object Id for which approval process is working
     */
    public List<ProcessInstanceWorkitem> getProcessInstanceWorkitemByTargetIdAndStatus(Set<Id> setOfTargetId, String status, Set<String> fieldSet) {
     	
        return (List<ProcessInstanceWorkitem>) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('processInstance.TargetObjectId IN: setOfTargetId AND processInstance.Status =:' + ' status').toSOQL());
    }
    
    /**
     * Return List<ProcessInstanceWorkitem>
     * @Param set Of object Id for which approval process is working
     */
    public List<ProcessInstanceWorkitem> getProcessInstanceWorkitemsByTargetIdAndStatus(Set<Id> targetIdSet, String status){     	
        return [SELECT Id , OriginalActor.Name, Actor.Name, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem  
            WHERE ProcessInstance.TargetObjectId IN :targetIdSet 
            AND ProcessInstance.Status = :status order by ProcessInstance.CompletedDate desc];
    }
    
    /**
     * This method used to get ProcessInstanceWorkitem by set or target object Id
     * @param Set<String> fieldSet
     * @param Set<Id> idSet
     * @return  List<ProcessInstanceWorkitem>
     */
    public List<ProcessInstanceWorkitem> getAllPendingWorkItems(Set<String> fieldSet, Set<Id> idSet) {
        return (List<ProcessInstanceWorkitem>) Database.query(newQueryFactory().selectFields(fieldSet).setCondition('ProcessInstance.Status = \'Pending\' and ProcessInstance.TargetObjectId IN :idSet').toSOQL());
    }
}