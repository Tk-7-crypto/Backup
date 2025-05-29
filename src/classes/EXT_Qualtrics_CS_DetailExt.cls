public class EXT_Qualtrics_CS_DetailExt {
    Client_Sat_Survey__c cs;
    public String grpNm {get; private set;}
    public String grpId {get; private set;}
    ApexPages.StandardController con;
    private Id opportunityId;
    private String oldDeclineSurveyReason;
    private String oldDeclineSurveyReasonOther;
    public Boolean canReadOnly{get;set;}
    public Double oppAmount{get;set;}
    public Opportunity opp{get; set;}
   
    public EXT_Qualtrics_CS_DetailExt(ApexPages.StandardController controller){
        cs = (Client_Sat_Survey__c)controller.getRecord();
        canReadOnly = false;
        if( !getIsAdminUser() && ( (cs.Send_Survey__c == CON_Qualtrics.SEND_SURVEY_YES)  ||
                                  (cs.Send_Survey__c == CON_Qualtrics.SEND_SURVEY_NO &&
                                   (cs.Survey_Initiation_Status__c == CON_Qualtrics.SURVEY_DELAYED_PENDING_APPROVAL ||
                                   cs.Survey_Initiation_Status__c == CON_Qualtrics.SURVEY_DECLINED_PENDING_MGR_APPROVAL))) ){
            canReadOnly = true;
            return;
        }
        con = controller;
        oldDeclineSurveyReason = cs.Decline_Survey_Reason__c;
        oldDeclineSurveyReasonOther = cs.Decline_Survey_Reason_Other__c;
        opportunityId = cs.Opportunity__c;
        
        If(opportunityId != null){
            
            Set<String> oppFieldSet = new set<String> {'Id','Name','Expected_Project_Start_Date__c','Survey_Recipient__c','Survey_Recipient_2__c','Survey_Recipient_3__c','OwnerId',
                'Expected_Project_End_Date__c','Contract_Start_Date__c','BidTeam_2__r.Salesforce_User__r.Name','Contract_End_Date__c','BidTeam_2__r.Salesforce_User__r.EmployeeNumber',
                'BidTeam_2__r.Salesforce_User__r.Email','is_Survey_Eligible_for_RDS_Manual__c','ownerId','StageName','Is_Survey_Eligible_for_Non_RDS__c', 'Line_of_Business__c',
                'Business_Unit__c', 'Main_Delivery_Country__c', 'Is_Survey_Eligible_for_RDS_Auto__c', 'Is_Survey_Eligible_for_RDS_Manual__c', 'CSMS_Product__c', 'CreatedDate','ZREP_Product_Count__c'};
            Map<Id, Opportunity> oppMap = new SLT_Opportunity().getOpportunityById(new Set<Id>{opportunityId}, oppFieldSet);
            opp = oppMap.get(opportunityId);
            Map<Id, Proxy_Project__c> proxyProject =  new SLT_Proxy_Project().getProxyProjectByOppIDAndRecordTypeName(new Set<Id>{opp.Id}, 'Engagement', new Set<String> {'Id','Name','Project_Start_Date__c','Opportunity__c'});
            Set<String> RDSlobSet = new Set<String>{'Clinical','Data Sciences','Early Clinical Development','Connected Devices','Safety & Med Info','Regulatory & Drug Development Solutions','Patient & DCT Solutions'};
            if(cs.Id == null){
                if(checkSurveyEligibility(opp)) {
                    if(opp.is_Survey_eligible_for_RDS_Manual__c) {
                        if(RDSlobSet.contains(opp.Line_of_Business__c)) {
                            cs.Opp_Engagement_start_date__c =  opp.Expected_Project_Start_Date__c;
                        } else {
                            cs.Opp_Engagement_start_date__c =  opp.Contract_Start_Date__c;
                        }
                    }else if(opp.Is_Survey_Eligible_for_Non_RDS__c) {
                        cs.Opp_Engagement_start_date__c =  opp.Contract_Start_Date__c;
                        cs.Survey_EM_Name__c = opp.BidTeam_2__r.Salesforce_User__r.Name;
                        cs.Survey_EM_Email__c = opp.BidTeam_2__r.Salesforce_User__r.Email;
                        cs.Survey_EM_Email1__c = opp.BidTeam_2__r.Salesforce_User__r.Email;
                        cs.Survey_EM_EmployeeNumber__c = opp.BidTeam_2__r.Salesforce_User__r.EmployeeNumber;
                    }
                    if(proxyProject.size() > 0 && opp.ZREP_Product_Count__c > 0){
                        cs.Opp_Engagement_start_date__c = proxyProject.get(opp.Id).Project_Start_Date__c;
                    }
                    cs.Opportunity__c = opp.Id;
                    cs.Opp_Engagement__c = opp.name;
                    cs.Survey_Method__c = CON_Qualtrics.WEB_SURVEY;
                    cs.Opportunity_Owner__c = opp.ownerId;
                    cs.Survey_Recipient_1__c = (opp.Survey_Recipient__c != null) ? opp.Survey_Recipient__c : Survey_Setting__c.getInstance().Default_Survey_Recipient__c;
                    cs.Survey_Recipient_2__c = opp.Survey_Recipient_2__c;
                    cs.Survey_Recipient_3__c = opp.Survey_Recipient_3__c;
                    cs.Survey_Initiation_Status__c = CON_Qualtrics.NEW_SURVEY;
                }
                else {
                    if(opp.is_Survey_Eligible_for_RDS_Manual__c && opp.CSMS_Product__c <= 0){
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, CON_Qualtrics.CLIENT_SAT_SURVEY_INSERT_UPDATE_ERROR_FOR_RDS_MANNUAL);
                        ApexPages.addMessage(errMsg); 
                    }
                    else{
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, CON_Qualtrics.CLIENT_SAT_SURVEY_INSERT_UPDATE_ERROR);
                        ApexPages.addMessage(errMsg); 
                    }
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
       /**if(cs.Send_Survey__c == CON_Qualtrics.SEND_SURVEY_NO){
            DAOH_ClientSatSurvey.setApproversDetail(cs, opp);
        }else if(cs.Send_Survey__c == CON_Qualtrics.SEND_SURVEY_YES){
            DAOH_ClientSatSurvey.resetApproversDetail(cs);
        }**/
    }
    
    public PageReference saveCustom(){
        if(cs.Send_Survey__c == CON_Qualtrics.SEND_SURVEY_YES){
            cs.Decline_Survey_Reason__c = oldDeclineSurveyReason;
            cs.Decline_Survey_Reason_Other__c = oldDeclineSurveyReasonOther;
        }
        resetValues();
        try{
            Map<Id, Opportunity> oppMap = new SLT_Opportunity().getOpportunityById(new Set<Id>{cs.Opportunity__c}, new Set<String>{'StageName', 'Is_Survey_Eligible_for_Non_RDS__c', 'is_Survey_Eligible_for_RDS_Manual__c', 'CSMS_Product__c', 'CreatedDate', 'Expected_Project_End_Date__c', 'Contract_End_Date__c'});
            Opportunity opp = oppMap.get(cs.Opportunity__c);
            if(checkSurveyEligibility(opp)) {
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
                if(i != 0){
                    msg += '\n';
                }
                if(dmlEx.getDmlStatusCode(i) == CON_Qualtrics.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                    msg += CON_Qualtrics.VALIDATION_ERROR;
                }
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
   
    public static Boolean checkSurveyEligibility(Opportunity opp) {
        Date fstJan2020 = Date.newInstance(2020, 01, 01);
        if(opp.is_Survey_Eligible_for_RDS_Manual__c && opp.CSMS_Product__c <= 0 && (opp.StageName == CON_CRM.FINALIZING_DEAL_STAGE || opp.StageName == CON_CRM.RECEIVED_ATP_STAGE)){
            return true;
        }
        else if((opp.Is_Survey_Eligible_for_Non_RDS__c || opp.Is_Survey_Eligible_for_RDS_Manual__c) && (opp.StageName == CON_CRM.CLOSED_WON_STAGE || opp.StageName == CON_CRM.IN_HAND_STAGE)) {
            return true;
        }
        return false;
    }
   
    public void resetValues(){
        
        if(cs.Don_t_Send_Survey_Reason__c == 'Delayed'){
            cs.Decline_Survey_Reason__c = null;
            cs.Decline_Survey_Reason_Other__c = '';
        }else if(cs.Don_t_Send_Survey_Reason__c == 'Declined'){
            cs.Delay_Survey_Reason__c = null;
            cs.Delay_Survey_Reason_Other__c = '';
        }
        if(cs.Decline_Survey_Reason__c != 'Other (please specify)'){
            cs.Decline_Survey_Reason_Other__c = '';
        }else if(cs.Delay_Survey_Reason__c != 'Other (Please Specify)'){
            cs.Delay_Survey_Reason_Other__c = '';
        }
        if(cs.Send_Survey__c == CON_Qualtrics.SEND_SURVEY_YES){
            cs.Don_t_Send_Survey_Reason__c = null;
            cs.Decline_Survey_Reason__c = null;
            cs.Decline_Survey_Reason_Other__c = '';
            cs.Delay_Survey_Reason__c = null;
            cs.Delay_Survey_Reason_Other__c = '';
        }
    }
}