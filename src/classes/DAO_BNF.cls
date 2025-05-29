/*
* Name              : DAO_BNF
* Created By        : Dheeraj Kumar
* Created Date      : 15th May 2017
* Revision          : Pramod Kumar
* Description       : Domain Class for BNF
*/
public class DAO_BNF {
	
	private static string PENDING_STATUS = 'Pending';  
	private static string ERROR_MESSAGE = 'BNF\'s cannot be deleted as related BNF is in submitted state'; 
	private static String SUBJECT_TEXT = 'Exceptions when deleting Process Instance work item of Inactive Users';
	private static Automated_User_Downgrade_Settings__c downgradeSettings = Automated_User_Downgrade_Settings__c.getOrgDefaults();
	private static String EXCEPTION_MESSAGE = '==============Exception :========\n';
	private static String INACTIVE_MESSAGE = '==============On Inactive Users ID:========\n';
	 
    /**
    * method used to delete Process Instance WorkItem of Inactive Users
    * @param : inactiveUserSet : Set of Ids
    * @return : void
    * @Modified By : Dheeraj -- Issue-10862 -- Issue-11136 -- 2 August 2017
    */    
    public static void deleteInactiveUsersWorkItem(Set<Id> inactiveUserSet) {
        List<String> BNF_OBJECT_NAME_LIST = new List<String>{'BNF2__c', 'MIBNF_Component__c'};
        try {
            if(inactiveUserSet != null && inactiveUserSet.size() > 0) {
				Map<Id, User> inactiveUserMap = new Map<Id, User>([Select id from User where Id IN :inactiveUserSet and isActive = false]);
				List<ProcessInstanceWorkItem> workItemToDeleteList = new List<ProcessInstanceWorkItem>();
				if(inactiveUserMap.size() > 0) {
					Integer inActiveUserCount;
					List<ProcessInstance> processInstanceList = [Select id, (Select id, actorId, Actor.isActive from WorkItems) from ProcessInstance where status = :PENDING_STATUS and TargetObject.type IN :BNF_OBJECT_NAME_LIST];
					for(ProcessInstance pInstance : processInstanceList){	
						if(pInstance.WorkItems.size() > 1){
							inActiveUserCount = 0;
							for(ProcessInstanceWorkItem workItem : pInstance.WorkItems){
								if(inactiveUserMap.keySet().contains(workItem.actorId)){
									workItemToDeleteList.add(workItem);
									inActiveUserCount++;
								}
							}
							if(inActiveUserCount == pInstance.WorkItems.size()){
								workItemToDeleteList.remove(workItemToDeleteList.size() - 1);
							}
								
						}
					}
					if(workItemToDeleteList.size() > 0){
						delete workItemToDeleteList;
					}					
				}
            }
        } catch(Exception ex) {
            sendMailOnException(inactiveUserSet, ex.getMessage());
        }
    }
    
    /**
    * method used to delete Process Instance WorkItem of Inactive Users with future call 
    * @param : inactiveUserSet : Set of Ids
    * @return : void
    * @Modified By : Dheeraj -- Issue-10862 -- 15 May 2017
    */
    @future
    public static void deleteInactiveUsersWorkItemFuture(Set<Id> inactiveUserSet) {
        deleteInactiveUsersWorkItem(inactiveUserSet);
    }
    
    /**
    * method send mail when exception occurs
    * @param1 : inactiveUserSet : Set of Ids
    * @param2 : exception_List : List of Exceptions
    * @return : void
    * @Modified By : Dheeraj -- Issue-10862 -- 15 May 2017
    */    
    @TestVisible
    private static void sendMailOnException(Set<Id> inactiveUserSet, String exceptionMessage) {
    	String BodyText = ''; 
        String emailId = downgradeSettings.FailureEmail__c;                      
        BodyText += EXCEPTION_MESSAGE;
       	BodyText += exceptionMessage;      
        BodyText  += INACTIVE_MESSAGE; 
        for(String userId : inactiveUserSet){              
        	BodyText += userId;      
        }               
        UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
        message.toEmails = new List<String>{emailId};
        message.whatId = UserInfo.getUserId();
        message.subject = SUBJECT_TEXT;
        message.staticContent = BodyText;
        
        
        if(!(!Mulesoft_Integration_Control__c.getInstance().Is_Mulesoft_User__c && Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c)){
            UTL_CRM_SendEmail.sendEmailThroughWorkflow(new List<UTL_CRM_SendEmail.MessageWrapper>{message});
        }	
    }
    
    /**
    * method used to prevent deletion of BNF if other realted BNF is in submitted state
    * @param : triggerOldMap : Map of <Id, MIBNF_Component__c> deletable BNF
    * @return : void
    * @Modified By : Anshita Issue-10862
    */ 
    public static void stopDeletionOfBNF(Map<Id, MIBNF_Component__c> triggerOldMap){
    	Set<Id> mibnfDeleteSet = new Set<Id>();
    	Id mibnfId;
    	Map<Id,Id> mibnfCompIdToMIBNFIdMap = new Map<Id,Id>();
    	Map<Id,Set<Id>> mibnfToSetOfMIBNFCompIdMap = new Map<Id,Set<Id>>();
        for (MIBNF_Component__c mibnfComp: triggerOldMap.values()){
            mibnfDeleteSet.add(mibnfComp.MIBNF__c);
        }
        List<MIBNF_Component__c> mibnfComponentList = [select id, MIBNF__c from MIBNF_Component__c where MIBNF__c in : mibnfDeleteSet];
        mibnfDeleteSet.clear();
        for (MIBNF_Component__c mibnfComp: mibnfComponentList){
        	mibnfDeleteSet = new Set<Id>();
            mibnfCompIdToMIBNFIdMap.put(mibnfComp.Id, mibnfComp.MIBNF__c);
            if(!mibnfToSetOfMIBNFCompIdMap.containskey(mibnfComp.MIBNF__c)){
            	mibnfToSetOfMIBNFCompIdMap.put(mibnfComp.MIBNF__c, new Set<Id>{mibnfComp.id});
            } else {
            	mibnfDeleteSet = mibnfToSetOfMIBNFCompIdMap.get(mibnfComp.MIBNF__c);
            	mibnfDeleteSet.add(mibnfComp.id);
            	mibnfToSetOfMIBNFCompIdMap.put(mibnfComp.MIBNF__c, mibnfDeleteSet);
            }
        }
        List<ProcessInstanceWorkItem> workItemList = [Select id, ProcessInstance.TargetObjectId from ProcessInstanceWorkItem where ProcessInstance.status = :PENDING_STATUS and ProcessInstance.TargetObjectId in : mibnfComponentList];
        for(ProcessInstanceWorkItem piTemp : workItemList){
        	mibnfId = mibnfCompIdToMIBNFIdMap.get(piTemp.ProcessInstance.TargetObjectId);
        	mibnfDeleteSet = mibnfToSetOfMIBNFCompIdMap.get(mibnfId);
        	for(Id mibnfComp : mibnfDeleteSet){
        		if(triggerOldMap.get(mibnfComp) != null){
        			triggerOldMap.get(mibnfComp).addError(ERROR_MESSAGE);
        		}
        	}
        }
    }
}