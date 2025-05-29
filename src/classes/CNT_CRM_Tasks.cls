public with sharing class CNT_CRM_Tasks {
	@AuraEnabled(cacheable=true)
    public static List<Task> getTasks(String recordId){
        Set<String> recordTypes = new Set<String>();
        recordTypes.add('Standard_Task');
        recordTypes.add('Call_Plan_Task');
        recordTypes.add('MQL_Task');
        recordTypes.add('CSM_Task');
        if(recordId.startsWith('001'))
        	return [SELECT Id, Subject, Priority, ActivityDate, Status, What.Name, Who.Name, Owner.Name, RecordType.DeveloperName, Type, CreatedById from Task where AccountId = :recordId AND RecordType.DeveloperName IN :recordTypes];
        else
            return [SELECT Id, Subject, Priority, ActivityDate, Status, What.Name, Who.Name, Owner.Name, RecordType.DeveloperName, Type, CreatedById from Task where whoId = :recordId AND RecordType.DeveloperName IN :recordTypes];
    }
}