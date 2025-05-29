public class DAOH_OWF_Contact {
    
    /*
*This method is used to Close all the related assignments
*if the isResource or isResourceActive is marked as false
*
*
*/
    public static void closeRelatedAssignmentsOnUpdate(List<Contact> nonResourceList,Map<Id,Contact> oldMap)
    {
        Set<Id> inactiveContactsSet = new Set<Id>();
        List<pse__Assignment__c> assignemntsToBeCloseList;
        List<pse__Schedule__c> scheduleToBeUpdatedList;
        List<pse__Resource_Request__c> rrToBeUpdatedList;
        pse__Schedule__c schdeuleInstance;
        pse__Resource_Request__c rrInstance;
        CON_OWF.BYPASS_VALIDATION_RULE_RR = true;
        List<pse__Assignment__c> assignemntsList = new List<pse__Assignment__c>();
        String assignmentCondition = ' pse__Resource__c IN :sObjectIdSet and pse__Status__c in (\'Pending\', \'Accepted\') and Assignment_Type__c in (\'Assignment\')';
        Set<String> assignmentFieldSet = new Set<String>{'Id', 'pse__Start_Date__c','pse__Schedule__c','pse__Resource_Request__c','pse__Resource_Request__r.pse__Status__c',
            'pse__Resource_Request__r.pse__End_Date__c','pse__Resource_Request__r.pse__Assignment__c',
            'pse__Resource_Request__r.Cancellation_Reason__c','pse__Resource_Request__r.Cancellation_Comments__c','pse__Schedule__r.pse__End_Date__c','Assignment_Type__c', 'pse__Status__c'};
        for(Contact con: nonResourceList)
        {
            if((oldMap.get(con.Id).pse__Is_Resource__c && !con.pse__Is_Resource__c) || (oldMap.get(con.Id).pse__Is_Resource_Active__c && !con.pse__Is_Resource_Active__c))
            {
                inactiveContactsSet.add(con.Id);
            }
        }
        if(!inactiveContactsSet.isEmpty()){
         	assignemntsList = new SLT_Assignment(false,false).getAssignmentByResource(inactiveContactsSet, assignmentCondition, assignmentFieldSet);
        }
        if(assignemntsList.size()>0)
        {
            assignemntsToBeCloseList = new List<pse__Assignment__c>();
            scheduleToBeUpdatedList = new List<pse__Schedule__c>();
            rrToBeUpdatedList = new List<pse__Resource_Request__c>();
            for(pse__Assignment__c assignment: assignemntsList)
            {
                rrInstance = new pse__Resource_Request__c();
                if(assignment.pse__Start_Date__c < = Date.today())
                {
                    assignment.pse__Status__c = 'Closed';
                    schdeuleInstance = new pse__Schedule__c();
                    schdeuleInstance.Id = assignment.pse__Schedule__c;
                    schdeuleInstance.pse__End_Date__c = Date.today();
                    
                    rrInstance.id = assignment.pse__Resource_Request__c;
                    rrInstance.pse__End_Date__c = Date.today();
                    rrInstance.pse__Status__c = 'Closed';

                    scheduleToBeUpdatedList.add(schdeuleInstance);
                    assignemntsToBeCloseList.add(assignment);
                    rrToBeUpdatedList.add(rrInstance);
                }
                else if(assignment.pse__Start_Date__c > Date.today())
                {
                    rrInstance.id = assignment.pse__Resource_Request__c;
                    rrInstance.pse__Status__c = 'Cancelled';
                    rrInstance.Cancellation_Reason__c = 'Other';
                    rrInstance.Cancellation_Comments__c = 'This resource has been Cancelled because the Original Assigned Resource has been Deactivated';
                    assignment.pse__Status__c = 'Cancelled';
                    UTL_OWF.isAssignmentStatusUpdateAsCancelledBySystem = true;
                    assignemntsToBeCloseList.add(assignment);
                    rrToBeUpdatedList.add(rrInstance);
                }
            } 
            
            CON_OWF.isUpdatedFromContact = true;
            if(assignemntsToBeCloseList.size()>0)
            {	
                update assignemntsToBeCloseList;
                update rrToBeUpdatedList;
            }
            if(scheduleToBeUpdatedList.size()>0)
            {
                update scheduleToBeUpdatedList;
            }
        }
    }
    // IQVIAPSA-7380 : Allow increase of Baseline FTE contacts having for GBO subgroups  
    public static void validateBaselineFTE(List<Contact> newList, Map<Id, Contact> oldMap){
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        if(!mulesoftSetting.Ignore_Validation_Rules__c){
            for(Contact newContact: newList){
            if((Trigger.isInsert || (Trigger.isUpdate && newContact.Baseline_FTE__c != oldMap.get(newContact.Id).Baseline_FTE__c))
               && (newContact.Baseline_FTE__c < 0.0 
                   || ((newContact.Baseline_FTE__c > 1.0) && (newContact.Sub_Group__c == null || !(newContact.Sub_Group__c.contains('GBO'))) && (newContact.Secondary_Sub_Group__c == null ||  !(newContact.Secondary_Sub_Group__c.contains('GBO')))))){
                   newContact.Baseline_FTE__c.addError('BaseLine FTE must be between 0.0 and 1.0');
               }
            }
        }   
    }    
}