/**
* This is FRUP trigger handler class.
* version : 1.0
*/
public class DAOH_box_FRUP {
    
 
   
    
    /**
	* This method is used to generate box folder URL on Opportunity whenever a FRUP record is inserted and Object is Opportunity
	* @params newList List<box__FRUP__c>
	* @return void
	*/
    public static void generateBoxFolderURLonOpp(List<box__FRUP__c> newList){
        Set<Id> oppIDs = new Set<Id>();
        for(box__FRUP__c frup : newList){  
            if(frup.box__Object_Name__c == 'Opportunity' && string.isNotBlank(frup.box__Record_ID__c) && string.isNotBlank(frup.box__Folder_ID__c)){
                oppIDs.add(frup.box__Record_ID__c);
            }
        }
        
        Map<Id, Opportunity> oppByIDs = new SLT_Opportunity().getOppWithFilterCondition(oppIDs, new Set<String>{'Id', 'Box_Folder_Url__c', 'Line_of_Business__c'}, 'Line_of_Business__c = \'Q2 Solutions\'');
        List<box__FRUP__c> oppFrupList = new List<box__FRUP__c>();
        for(box__FRUP__c frup : newList){
            if(frup.box__CollaborationID__c == null && frup.box__Object_Name__c == 'Opportunity' && string.isNotBlank(frup.box__Record_ID__c) && string.isNotBlank(frup.box__Folder_ID__c) && oppByIDs.containsKey(frup.box__Record_ID__c)){
                oppFrupList.add(frup);
            } 
        }
        //calling future method to update opportunities
        if(oppFrupList.size() > 0){
            if(system.isBatch() || system.isFuture()){
                updateboxFolderURLonOpp(JSON.serialize(oppFrupList));
            }else{
                updateboxFolderURLonOppFuture(JSON.serialize(oppFrupList));
            }
        } 
    }
    
    @future
    public static void updateboxFolderURLonOppFuture(String oppFrupListJson){
        updateboxFolderURLonOpp(oppFrupListJson);
    }
    
    /**
	* This future method is used to update Box Folder URL on opportunities
	* @params String oppToFrupMapJson
	* @return void
	*/
    public static void updateboxFolderURLonOpp(String oppFrupListJson){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Opportunity.SobjectType
                    }
        );
        List<box__FRUP__c> oppFrupList = (List<box__FRUP__c>)JSON.deserialize(oppFrupListJson, List<box__FRUP__c>.class);
        Box_End_Point__c boxEndPoint = Box_End_Point__c.getOrgDefaults();
        String folderURL = boxEndPoint.End_Point__c;
        folderURL += '/folder/';
        Boolean toCommit = false;
        for(box__FRUP__c frupOpp : oppFrupList){
            String boxFolderURL = folderURL + frupOpp.box__Folder_ID__c;
            Opportunity opp = new Opportunity(Id = frupOpp.box__Record_ID__c, Box_Folder_Url__c = boxFolderURL);
            toCommit = true;
            if(toCommit){
                uow.registerDirty(opp);
            }
        }
        if(toCommit) {
            try {
                uow.commitWork();
            }catch(Exception e){
                String exception_List = e.getStackTraceString();
                Apex_Error_Log__c apexErrorLog = new Apex_Error_Log__c();
                apexErrorLog.Running_User__c = UserInfo.getUserId();
                apexErrorLog.Object__c = 'Opportunity';
                apexErrorLog.Error_Message__c = e.getStackTraceString();
                insert apexErrorLog;
                
                //send email on exception
                sendEmailOnException(exception_List);
            }
        } 
    }
    
    @TestVisible
    private static void sendEmailOnException(String exception_List){
        String body = exception_List;
        List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
        UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
        Survey_Setting__c surveySetting = Survey_Setting__c.getOrgDefaults();
        String emails = surveySetting.Survey_Error_Email_Ids__c;
        List<String> exceptionEmailList = emails.split(':');        
        String[] toAddresses = exceptionEmailList;
        message.toEmails = toAddresses;
        message.subject = 'Exceptions were thrown while updating Box Folder URL on Opportunity';
        message.staticContent = body;
        messageList.add(message);
        UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);
    }
}