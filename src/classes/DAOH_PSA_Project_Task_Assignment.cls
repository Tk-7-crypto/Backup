/**
* This is Project Task Assignment trigger handler class.
* version : 1.0
*/
public class DAOH_PSA_Project_Task_Assignment {

    /**
    * This method is used to update the project task with the primary resouorce
    */

    public static void setPrimaryResourceOnTask(List<pse__Project_Task_Assignment__c> newList, Map<Id, pse__Project_Task_Assignment__c> oldMap, Map<String, Set<String>> methodToRecordTypeMap) {
        Set<Id> projectTaskIdSet = new Set<Id>();
        List<pse__Project_Task_Assignment__c> inScopeTaskAssignmentList = new List<pse__Project_Task_Assignment__c>();
        List<pse__Project_Task__c> projectTaskUpdateList = new List<pse__Project_Task__c>();

        for(pse__Project_Task_Assignment__c pta : newList) {
            if ( methodToRecordTypeMap.get('setPrimaryResourceOnTask') == null || !methodToRecordTypeMap.get('setPrimaryResourceOnTask').contains(Schema.SObjectType.pse__Project_Task_Assignment__c.getRecordTypeInfosById().get(pta.RecordTypeId).getDeveloperName()) ) {
                continue;  //skip record if code not configured for recordtype
            }

            if (pta.pse__Project_Task__c != null) {
                // on insert
                if (oldMap == null && pta.Is_Primary__c && pta.pse__Resource__c != null) {
                    projectTaskIdSet.add(pta.pse__Project_Task__c);
                    inScopeTaskAssignmentList.add(pta);
                }

                //on update
                if (oldMap != null && pta.pse__Resource__c != null && pta.Is_Primary__c && !oldMap.get(pta.id).Is_Primary__c ) {
                    projectTaskIdSet.add(pta.pse__Project_Task__c);
                    inScopeTaskAssignmentList.add(pta);
                }
            }
        }

        if (inScopeTaskAssignmentList.size() > 0 ) {

            Map<Id, pse__Project_Task__c> projectTaskMap = new Map<Id, pse__Project_Task__c>([SELECT Id, Resource__c FROM pse__Project_Task__c WHERE Id in :projectTaskIdSet]);

            for (pse__Project_Task_Assignment__c pta : inScopeTaskAssignmentList) {
                pse__Project_Task__c tempTask = projectTaskMap.get(pta.pse__Project_Task__c);

                if (tempTask != null) {
                    tempTask.Resource__c = pta.pse__Resource__c;
                    projectTaskUpdateList.add(tempTask);
                }
            }

            if (projectTaskUpdateList.size() > 0) {
                update projectTaskUpdateList;
            }

        }
    }
}