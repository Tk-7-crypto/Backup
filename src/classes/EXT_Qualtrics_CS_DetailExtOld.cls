public class EXT_Qualtrics_CS_DetailExtOld {
    /*Client_Sat_Survey__c cs;
    public String grpNm {get; private set;}
    public String grpId {get; private set;}
    ApexPages.StandardController con;
    private Id opportunityId;
    private String oldDeclineSurveyReason;
    private String oldDeclineSurveyReasonOther;
    public Boolean canReadOnly{get;set;}
    public Double oppAmount{get;set;}
    */
    public EXT_Qualtrics_CS_DetailExtOld(){
        String demoString = '';
    }
    /*
    public EXT_Qualtrics_CS_DetailExt(ApexPages.StandardController controller){
        cs = (Client_Sat_Survey__c)controller.getRecord();
        canReadOnly = false;
        if( !getIsAdminUser() && ( (cs.Send_Survey__c == CON_Qualtrics.SEND_SURVEY_YES)  || 
                                  (cs.Send_Survey__c == CON_Qualtrics.SEND_SURVEY_NO && 
                                   cs.Survey_Initiation_Status__c == CON_Qualtrics.SURVEY_DECLINED_PENDING_MGR_APPROVAL)) ){
            canReadOnly = true;
            return;
        }
        con = controller;
        oldDeclineSurveyReason = cs.Decline_Survey_Reason__c;
        oldDeclineSurveyReasonOther = cs.Decline_Survey_Reason_Other__c;
        if(cs.Id == null){
            opportunityId = cs.Opportunity__c;
            If(opportunityId != null){
                Map<Id, Opportunity> oppMap = new SLT_Opportunity().getOpportunityById(new Set<Id>{opportunityId}, new Set<String>{'T_S_Contract_Value__c', 'StageName'});
                Opportunity opp = oppMap.get(opportunityId);
                if(checkContractValueAndStageName(opp)) {
                    List<Proxy_Project__c> listOfProxyProject = new SLT_Proxy_Project().selectByOpportunityId(new Set<Id>{opportunityId}, 
                                                                                                              new set<String> {'id','Opportunity__c','Opportunity__r.Name',
                                                                                                                  'Project_Start_Date__c', 'Opportunity__r.Id','Delivery_PIC_User_Country__c',
                                                                                                                  'Project_Manager_Name__c','Opportunity__r.BidTeam_2__r.Salesforce_User__r.Name','Opportunity__r.Principle_inCharge__r.Salesforce_User__r.Name',
                                                                                                                  'Opportunity__r.Survey_Recipient__c','Opportunity__r.Amount_In_USD__c','Project_End_Date__c', 'Project_Manager_Email__c',
                                                                                                                  'Delivery_PIC_Email__c', 'Delivery_PIC_Name__c', 'Delivery_PIC_EmployeeNumber__c', 'Project_Manager_EmployeeNumber__c'});
                    if(!listOfProxyProject.isEmpty()) {
                        Proxy_Project__c project =   listOfProxyProject[0];
                        cs.Opp_Engagement__c = project.Opportunity__r.Name;
                        cs.Opp_Engagement_start_date__c = project.Project_Start_Date__c;
                        cs.Opportunity__c = project.Opportunity__r.Id;
                        cs.Send_Survey__c = null;
                        cs.Survey_EM_Name__c = (project.Project_Manager_Name__c != null) ? project.Project_Manager_Name__c : ( 
                            (project.Opportunity__r.BidTeam_2__r.Salesforce_User__r.Name != null?project.Opportunity__r.BidTeam_2__r.Salesforce_User__r.Name:project.Opportunity__r.Principle_inCharge__r.Salesforce_User__r.Name ));
                        cs.Survey_EM_EmployeeNumber__c = project.Project_Manager_EmployeeNumber__c;
                        cs.Survey_EM_Email__c = project.Project_Manager_Email__c;
                        cs.Survey_EM_Email1__c = project.Project_Manager_Email__c;
                        cs.Survey_Initiation_Status__c = CON_Qualtrics.NEW_SURVEY;
                        cs.Survey_PIC_Name__c = project.Delivery_PIC_Name__c;
                        cs.Survey_PIC_EmployeeNumber__c = project.Delivery_PIC_EmployeeNumber__c;
                        cs.Survey_PIC_Email__c = project.Delivery_PIC_Email__c;
                        cs.Survey_PIC_Email1__c = project.Delivery_PIC_Email__c;
                        cs.Survey_Recipient_1__c = project.Opportunity__r.Survey_Recipient__c;
                        cs.Survey_Method__c = CON_Qualtrics.WEB_SURVEY;
                        cs.Survey_Type__c = (project.Project_End_Date__c <= system.today())?CON_Qualtrics.END_OF_ENGAGEMENT:CON_Qualtrics.ONGOING;
                        oppAmount = project.Opportunity__r.Amount_In_USD__c;
                        //List<Contact> surveyEMContactList = new SLT_Contact().getContactByUserEmployeeNumber(project.Project_Manager_EmployeeNumber__c);
                        //List<Contact> surveyPICContactList = new SLT_Contact().getContactByUserEmployeeNumber(project.Delivery_PIC_EmployeeNumber__c);
                        //cs.Survey_EM__c = (surveyEMContactList.size() > 0 && surveyEMContactList != null) ? surveyEMContactList[0].Id : project.Opportunity__r.BidTeam_2__c;
                        //cs.Survey_PIC__c = (surveyPICContactList.size() > 0 && surveyPICContactList != null) ? surveyEMContactList[0].Id : project.Opportunity__r.Principle_inCharge__c;
                    }
                }
                else {
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, CON_Qualtrics.CLIENT_SAT_SURVEY_INSERT_UPDATE_ERROR);
                    ApexPages.addMessage(errMsg);  
                }
            }   
        }
        
    }
    
    public Boolean getIsAdminUser()
    {
        return [select id,Profile.Name from User where id =:UserInfo.getUserId()][0].Profile.Name.contains(CON_Qualtrics.SYSTEM_ADMINISTRATOR)
            || UserInfo.getUserEmail() == CS_Config__c.getInstance().CS_Admin_Email__c;
    }
    
    public void SetApproverDetails(){
        Set<String> grpNameSet = new Set<String> ();
        if(opportunityId != null){
            List<Proxy_Project__c> listOfProxyProject = new SLT_Proxy_Project().selectByOpportunityId(new Set<Id>{opportunityId}, 
                                                                                                      new set<String> {'id','Opportunity__c','Opportunity__r.Name',
                                                                                                          'Project_Start_Date__c', 'Opportunity__r.Id',
                                                                                                          'Project_Manager_Name__c','Opportunity__r.BidTeam_2__r.Salesforce_User__r.Name','Opportunity__r.Principle_inCharge__r.Salesforce_User__r.Name',
                                                                                                          'Opportunity__r.Survey_Recipient__c','Opportunity__r.Amount_In_USD__c','Project_End_Date__c',
                                                                                                          'Business_Unit__c','Opportunity__r.Main_Delivery_Country__c',
                                                                                                          'Delivery_PIC_Offering_Segment__c', 'Delivery_PIC_Offering_Type__c',
                                                                                                          'Delivery_PIC_Product_COE__c', 'Delivery_PIC_Business_Unit__c',
                                                                                                          'Delivery_PIC_User_Country__c'});
            if(!listOfProxyProject.isEmpty()) {
                Proxy_Project__c project =   listOfProxyProject[0];
                String grpNm = DAOH_ClientSatSurvey.getApproverGroupName(project.Delivery_PIC_Offering_Segment__c,
                                                                         project.Delivery_PIC_Offering_Type__c,
                                                                         project.Delivery_PIC_Product_COE__c,
                                                                         project.Delivery_PIC_Business_Unit__c,
                                                                         project.Business_Unit__c, project.Opportunity__r.Main_Delivery_Country__c,
                                                                         project.Delivery_PIC_User_Country__c);
                cs.Declined_Survey_Approver_Group__c = grpNm;

                grpNameSet.add(grpNm);
                List<Group> grpList = new SLT_Groups().getGroupsWithGroupMembersByGroupName(grpNameSet); 
                Set<Id> userIdSet = new Set<Id>();
                if(grpList.size() > 0 ){
                    for(GroupMember gm : grpList.get(0).GroupMembers){
                        if(gm.UserOrGroupId.getSObjectType() == User.sObjectType){
                            userIdSet.add(gm.UserOrGroupId);
                        }
                    }
                }
                List<user> userList = new List<User>();
                if(!userIdSet.isEmpty()) {
                    userList = new SLT_User().selectActiveUserByUserId(userIdSet, new Set<String>{'Id'});
                }
                List<Approval.ProcessSubmitRequest> approvalList = new List<Approval.ProcessSubmitRequest>();
                cs.Declined_Survey_Approver_1__c = null;
                cs.Declined_Survey_Approver_2__c = null;
                cs.Declined_Survey_Approver_3__c = null;
                if(!userList.isEmpty()) {
                    if(userList.size() > 0){
                        cs.Declined_Survey_Approver_1__c = userList[0].Id;
                    }
                    
                    if(userList.size() > 1){
                        cs.Declined_Survey_Approver_2__c = userList[1].Id;
                    }
                    
                    if(userList.size() > 2){
                        cs.Declined_Survey_Approver_3__c = userList[2].Id;
                    }
                    cs.Declined_Survey_Approver_Group_ID__c = grpList.get(0).Id;
                }
                else {
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, CON_Qualtrics.THERE_SHOULD_BE_ATLEAST_ONE_APPROVER);
                    ApexPages.addMessage(errMsg);                    
                }
            }
            grpNm = cs.Declined_Survey_Approver_Group__c;
            grpId = cs.Declined_Survey_Approver_Group_ID__c;
        }
    }
    
    public PageReference saveCustom(){
        if(cs.Send_Survey__c == CON_Qualtrics.SEND_SURVEY_YES){
            cs.Decline_Survey_Reason__c = oldDeclineSurveyReason;
            cs.Decline_Survey_Reason_Other__c = oldDeclineSurveyReasonOther;
        }
        try{
            Map<Id, Opportunity> oppMap = new SLT_Opportunity().getOpportunityById(new Set<Id>{cs.Opportunity__c}, new Set<String>{'T_S_Contract_Value__c', 'StageName'});
            Opportunity opp = oppMap.get(cs.Opportunity__c);
            if(checkContractValueAndStageName(opp)) {
                upsert cs;                 
            } 
            else {
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, CON_Qualtrics.CLIENT_SAT_SURVEY_INSERT_UPDATE_ERROR);
                ApexPages.addMessage(errMsg);  
                return null;
            }
        } catch(DmlException dmlEx){
            String msg = '';
            for (Integer i = 0; i < dmlEx.getNumDml(); i++) {
                if(i != 0) msg += '\n';
                if(dmlEx.getDmlStatusCode(i) == CON_Qualtrics.FIELD_CUSTOM_VALIDATION_EXCEPTION)
                    msg += CON_Qualtrics.VALIDATION_ERROR;
                msg += dmlEx.getDmlMessage(i) ;
                
            }
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,msg); 
            ApexPages.addMessage(errMsg);
            return null;  
        } catch (Exception ex) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,CON_Qualtrics.ERROR_OCCURED_WHILE_PROCESSING_YOUR_REQUEST + ex.getMessage());                        
            ApexPages.addMessage(errMsg ); 
            return null;          
        }
        return (new PageReference('/' + cs.Id));
    }
    
    public static Boolean checkContractValueAndStageName(Opportunity opp) {
        if(opp.T_S_Contract_Value__c > 0 && (opp.StageName == CON_Qualtrics.FINALIZING_DEAL_STAGE || 
                                             opp.StageName == CON_Qualtrics.RECEIVED_ATP_OLI_STAGE || 
                                             opp.StageName == CON_Qualtrics.CLOSED_WON || 
                                             opp.StageName == CON_Qualtrics.IN_HAND)) {
            return true;                                     
       } 
       return false;
    }
	*/

}