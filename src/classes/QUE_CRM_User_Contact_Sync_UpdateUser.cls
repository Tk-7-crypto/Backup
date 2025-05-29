public class QUE_CRM_User_Contact_Sync_UpdateUser implements Queueable{
    
    List<user> userListUserContactSync = new List<User>();
    public QUE_CRM_User_Contact_Sync_UpdateUser(List<User> userListToUpdate) {
        this.userListUserContactSync = userListToUpdate;
    }
    
    public void execute(QueueableContext qc){
        if(userListUserContactSync.size() > 0){
            UTL_ExecutionControl.stopTriggerExecution = true;
            update userListUserContactSync;
            UTL_ExecutionControl.stopTriggerExecution = false;
        }
        List<User> exceptionUserList = new List<User>();
        for(User uRec : userListUserContactSync){ 
            if(uRec.User_To_Contact_Sync_Error__c != null && uRec.User_To_Contact_Sync_Error__c != ''){
                exceptionUserList.add(uRec);
            }       
        }
        if(exceptionUserList.size()>0){
        	sendEmailOnException(exceptionUserList);
        }    
    } 
    
    @TestVisible
    Private static void sendEmailOnException(List<User> exceptionUserList){
        List<UTL_CRM_SendEmail.MessageWrapper> messageList = new List<UTL_CRM_SendEmail.MessageWrapper>();
        UTL_CRM_SendEmail.MessageWrapper message = new UTL_CRM_SendEmail.MessageWrapper();
        Survey_Setting__c surveySetting = Survey_Setting__c.getOrgDefaults();
        String emails = surveySetting.Survey_Error_Email_Ids__c;
        List<String> exceptionEmailList = emails.split(',');        
        String[] toAddresses = exceptionEmailList;
        message.toEmails = toAddresses;
        message.subject = 'Errors DETECTED while user to contact sync';
        String emailBody = 'Hello,<br/><br/>';
        emailBody += 'Following errors were detected during user to contact sync: \n\n';
        emailBody += '<table style="border-collapse: collapse;border: 0.1px solid black;">';
        emailBody += '<colgroup span="2"></colgroup><colgroup span="2"></colgroup>';  
        emailBody += '<tr><th colspan="2" scope="colgroup" style="border-collapse: collapse;border: 0.1px solid black;">Employee Number </th>';
        emailBody += '<th colspan="2" scope="colgroup" style="border-collapse: collapse;border: 0.1px solid black;">User to contact sync error </th></tr>';
        for(User uRec : exceptionUserList){ 
           emailBody += '<tr><td colspan="2" scope="colgroup" style="border-collapse: collapse;border: 0.1px solid black;">'+ uRec.EmployeeNumber + '</td>'  ;
           emailBody += '<td colspan="2" scope="colgroup" style="text-align:right;border-collapse: collapse;border: 0.1px solid black;">' + uRec.User_To_Contact_Sync_Error__c  + '</td></tr>';
        }emailBody += '</table>' + '<br/><br/>';
        emailBody += 'Thanks.';
        message.staticContent = emailBody;
        messageList.add(message);
        UTL_CRM_SendEmail.sendEmailThroughWorkflow(messageList);
    }
}