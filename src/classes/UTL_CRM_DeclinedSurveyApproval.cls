/*
 * Description   : This Apex class is Utility Handler Class for Email Service - Declined Survey Approval Service
 * Used as a Custom Approval Solution for Client Sat Survey Decline Request 
 */
public class UTL_CRM_DeclinedSurveyApproval implements Messaging.InboundEmailHandler{
    
    String emailSubject;
    String emailHtmlBody;
    String fromAddress;
    String fromName;
    String plainTextBody;
    String emailBody;
    fflib_SObjectUnitOfWork uow;
    
    /**
    * This method is used to handle the inbound mail for the email service
    * @params Messaging.InboundEmail email
    * @params Messaging.InboundEnvelope env
    * @return Messaging.InboundEmailResult
    */
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env){
        uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Opportunity.SObjectType, Client_Sat_Survey__c.SObjectType });
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        emailSubject = email.subject;
        emailHtmlBody = email.htmlBody;
        fromAddress = email.fromAddress;
        plainTextBody = email.plainTextBody;
        fromName = email.fromName;
        
        if(!String.isBlank(email.htmlBody)){
            emailBody = email.htmlBody;
        }else if(!String.isBlank(email.plainTextBody)){
            emailBody = email.plainTextBody;
        }
        if(!String.isBlank(emailBody)){
        Id clientSatSurveyId;
        Boolean isApproved;
        String replyString;
        String clientSatSurveyKeyPrefix = Client_Sat_Survey__c.sobjecttype.getDescribe().getKeyPrefix();
        system.debug(emailHtmlBody);
        system.debug(plainTextBody);
            system.debug(emailBody);
        system.debug(email);
            if(emailBody.contains(clientSatSurveyKeyPrefix)){
            try{
                    clientSatSurveyId = emailBody.substring(emailBody.indexOf(clientSatSurveyKeyPrefix), emailBody.indexOf(clientSatSurveyKeyPrefix)+15 );
            }catch(Exception ex){
                clientSatSurveyId = null; 
            }
            if(clientSatSurveyId != null){
                replyString = plainTextBody.trim().toUpperCase();
                if(replyString != null){
                    if(replyString.startsWith(CON_Qualtrics.ACCEPT) || replyString.startsWith(CON_Qualtrics.ACCEPTED) || replyString.startsWith(CON_Qualtrics.YES)){
                        isApproved = true;
                    } else if(replyString.startsWith(CON_Qualtrics.REJECT) || replyString.startsWith(CON_Qualtrics.REJECTED) || replyString.startsWith(CON_Qualtrics.NO)){
                        isApproved  = false;
                    }
                    if(isApproved != null){
                        approveOrRejectCSSurveyDeclineRequest(clientSatSurveyId, isApproved);
                    }
                }  
            }
        }
        result.success = true;
        }
        return result;                 
    }
    
    /**
    * This method is used to Approve or Reject the CS Survey Decline Request based on email reply String
    * @params Id clientSatSurveyId
    * @params Boolean isApproved
    * @return void
    */
    public void approveOrRejectCSSurveyDeclineRequest(Id clientSatSurveyId, Boolean isApproved){
        system.debug(isApproved);
        Client_Sat_Survey__c clientSatSurveyRecord;
        Boolean updateRecord = false;
        Date nearestFutureDate;
        Set<String> lineOfBusiness = new Set<String>{'Clinical','Data Sciences','Early Clinical Development','Connected Devices','Patient & DCT Solutions'};
        List<Client_Sat_Survey__c> clientSatSurveyRecordList = new SLT_ClientSatSurvey().getClientSurveyByIdAndStatus(new Set<Id> {clientSatSurveyId}, new List<String> {CON_Qualtrics.SURVEY_DECLINED_PENDING_MGR_APPROVAL, CON_Qualtrics.SURVEY_DELAYED_PENDING_APPROVAL });
        if(clientSatSurveyRecordList != null && clientSatSurveyRecordList.size() > 0){
            clientSatSurveyRecord = clientSatSurveyRecordList[0];
            
            Set<String> declineSurveyApproverEmails = new Set<String>{clientSatSurveyRecord.Declined_SurveyApprover_1__r.Email, clientSatSurveyRecord.Declined_SurveyApprover_2__r.Email, clientSatSurveyRecord.Declined_SurveyApprover_3__r.Email,clientSatSurveyRecord.Decline_Survey_Approver_Email__c};
            if(clientSatSurveyRecord.Need_Escalation__c){
                List<User> userFromReassignGroup = new SLT_User().getUsersByGroupName(CON_Qualtrics.DECLINE_SURVEY_REASSIGN_GROUP_LABEL);
                if(userFromReassignGroup.size() > 0){
                    if(userFromReassignGroup[0].Email != null && fromAddress.equals(userFromReassignGroup[0].Email)){
                        fromName = userFromReassignGroup[0].name;
                        updateRecord = true; 
                    }
                }
            }else if(declineSurveyApproverEmails.contains(fromAddress)){
                updateRecord = true;
            }
            if(updateRecord){
                if(isApproved){
                    Opportunity opp = clientSatSurveyRecord.Opportunity__r;
                    Date endDate;
                    Map<Id, Proxy_Project__c> proxyProject =  new SLT_Proxy_Project().getProxyProjectByOppIDAndRecordTypeName(new Set<Id>{opp.Id}, 'Engagement', new Set<String> {'Id','Opportunity__c','Name','Project_Start_Date__c','Project_End_Date__c'});
                    if(clientSatSurveyRecord.Don_t_Send_Survey_Reason__c == CON_Qualtrics.DECLINED ){
                        clientSatSurveyRecord.Survey_Initiation_Status__c = CON_Qualtrics.SURVEY_DECLINED_WITH_MGR_APPROVAL;
                        opp.Upcoming_Survey_Send_Date__c = null;
                        if(opp.Is_Survey_Eligible_for_RDS_Auto__c || opp.Is_Survey_Eligible_for_RDS_Manual__c){
                            nearestFutureDate = clientSatSurveyRecord.Survey_Send_Date__c.addMonths(6);
                            if(opp.ZREP_Product_Count__c > 0 && proxyProject.containsKey(opp.Id)) {
                                endDate = proxyProject.get(opp.Id).Project_End_Date__c;
                            }
                            else if(lineOfBusiness.contains(opp.Line_of_Business__c)) {
                                endDate = opp.Expected_Project_End_Date__c;
                            }
                            else{
                                endDate = opp.Contract_End_Date__c;
                            }
                            if(nearestFutureDate > = endDate){
                           		nearestFutureDate = endDate; 
                        	}
                        }else if(opp.Is_Survey_Eligible_for_Non_RDS__c){
                            nearestFutureDate = clientSatSurveyRecord.Survey_Send_Date__c.addMonths(12);
                            Date Date6more = nearestFutureDate.addMonths(6);
                            if(opp.ZREP_Product_Count__c > 0 && proxyProject.containsKey(opp.Id)) {
                                endDate = proxyProject.get(opp.Id).Project_End_Date__c;
                            }
                            else {
                                endDate = opp.Contract_End_Date__c;
                            }
                            if(Date6more >= endDate){
                                nearestFutureDate = endDate;
                            }
                        }
                        opp.Next_Survey_Send_Date__c = nearestFutureDate;
                        uow.registerDirty(opp);
                    }else if(clientSatSurveyRecord.Don_t_Send_Survey_Reason__c  == CON_Qualtrics.DELAYED){
                        clientSatSurveyRecord.Survey_Initiation_Status__c = CON_Qualtrics.SURVEY_DELAYED_WITH_MGR_APPROVAL;
                        opp.Upcoming_Survey_Send_Date__c = clientSatSurveyRecord.Survey_Send_Date__c;
                        if(opp.Is_Survey_Eligible_for_RDS_Auto__c || opp.Is_Survey_Eligible_for_RDS_Manual__c){
                            nearestFutureDate = clientSatSurveyRecord.Survey_Send_Date__c.addMonths(6);
                            if(opp.ZREP_Product_Count__c > 0 && proxyProject.containsKey(opp.Id)) {
                                endDate = proxyProject.get(opp.Id).Project_End_Date__c;
                            }
                            else if(lineOfBusiness.contains(opp.Line_of_Business__c)) {
                                endDate = opp.Expected_Project_End_Date__c;
                            }
                            else{
                                endDate = opp.Contract_End_Date__c;
                            }
                            if(nearestFutureDate > = endDate){
                                nearestFutureDate = endDate; 
                        	}
                        }
                    }else if(opp.Is_Survey_Eligible_for_Non_RDS__c){
                            nearestFutureDate = clientSatSurveyRecord.Survey_Send_Date__c.addMonths(12);
                            Date Date6more = nearestFutureDate.addMonths(6);
                            if(opp.ZREP_Product_Count__c > 0 && proxyProject.containsKey(opp.Id)) {
                                endDate = proxyProject.get(opp.Id).Project_End_Date__c;
                            }
                            else {
                                endDate = opp.Contract_End_Date__c;
                            }
                            if(Date6more >= endDate){
                                nearestFutureDate = endDate;
                            }
                    }
                    opp.Next_Survey_Send_Date__c = nearestFutureDate;
                    uow.registerDirty(opp);
                    addAttachement(clientSatSurveyRecord, CON_Qualtrics.ACCEPTED.toLowerCase());
                } else{
                    if(clientSatSurveyRecord.Don_t_Send_Survey_Reason__c  == CON_Qualtrics.DELAYED){
                        //reset survey send date to the original survey send date
                        clientSatSurveyRecord.Survey_Send_Date__c = clientSatSurveyRecord.Opportunity__r.Upcoming_Survey_Send_Date__c;
                    }
                    clientSatSurveyRecord.Send_Survey__c = CON_Qualtrics.SEND_SURVEY_YES;
                    clientSatSurveyRecord.Survey_Initiation_Status__c = CON_Qualtrics.SURVEY_APPROVED;
                    clientSatSurveyRecord.Don_t_Send_Survey_Reason__c = null;
                    clientSatSurveyRecord.Decline_Survey_Reason__c = null;
                    clientSatSurveyRecord.Decline_Survey_Reason_Other__c = '';
                    clientSatSurveyRecord.Delay_Survey_Reason__c = null;
                    clientSatSurveyRecord.Delay_Survey_Reason_Other__c = '';
                    addAttachement(clientSatSurveyRecord, CON_Qualtrics.REJECTED.toLowerCase());
                }
                uow.registerDirty(clientSatSurveyRecord);
                UTL_ExecutionControl.stopTriggerExecution = true;
                uow.commitWork();
                UTL_ExecutionControl.stopTriggerExecution = false;
            }
        }
    }
    
    /**
    * This method is used to add an Attachement on CS Survey to keep track of email reply detail 
    * @params Client_Sat_Survey__c clientSatSurveyRecord
    * @params String approvedOrRejected
    * @return void
    */
    public void addAttachement(Client_Sat_Survey__c clientSatSurveyRecord, String approvedOrRejected){
        Attachment csSurveyAttachement = new Attachment();
        csSurveyAttachement.Name = clientSatSurveyRecord.name + ' - Survey decline request ' + approvedOrRejected + ' by '+  fromName ;
        csSurveyAttachement.Body = Blob.valueOf(plainTextBody);
        csSurveyAttachement.ContentType = 'text/plain';
        csSurveyAttachement.ParentId = clientSatSurveyRecord.id;
        insert csSurveyAttachement;
    }
}