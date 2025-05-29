/*
 * Version       : 1.0
 * Description   : This Apex class is service class for Client Sat Survey Trigger
 */
public class DAOH_ClientSatSurveyOld {
    public DAOH_ClientSatSurveyOld(){
        String demoString = '';
    }
    /**
    * This method is used to check survey has billable project
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @return void
    */
    /*commenting method for reference
    public static void validateSurvey_HasBillableProject(List<Client_Sat_Survey__c> newSurveyList) {
    	Set<Id> oppId = new Set<Id>();
        for(Client_Sat_Survey__c cs : newSurveyList){
            if(cs.Opportunity__c != null){
                oppId.add(cs.Opportunity__c);
            }
        }
        Map<Id,Opportunity> oppMap = new SLT_Opportunity().getMapOfOpportunitiesWithProjectsById(oppId);
        for(Client_Sat_Survey__c cs : newSurveyList){
            if(cs.Opportunity__c != null && oppMap.get(cs.Opportunity__c) != null && oppMap.get(cs.Opportunity__c).Proxy_Projects__r.size() > 0){
                boolean hasBillable = false;
                for(Proxy_Project__c  project : oppMap.get(cs.Opportunity__c).Proxy_Projects__r){
                    if(project.Is_Project_Billable__c){
                        hasBillable = true;
                        break;
                    }
                }
                if(!hasBillable) {
                    cs.addError(CON_Qualtrics.OPPORTUNITY_ATLEAST_HAVE_ONE_BILLABLE_PROJECT_ERROR_MSG);                    
                }
            }
        }
    }
    */
    /**
    * This method is used to update initiation status of survey
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @params Map<Id, Client_Sat_Survey__c> oldMap
    * @return void
    */
    /*commenting method for reference    
    public static void updateSurvey_InitiationStatus(List<Client_Sat_Survey__c> newSurveyList, Map<Id, Client_Sat_Survey__c> oldMap) {
        for(Client_Sat_Survey__c cs : newSurveyList){
            if(cs.Send_Survey__c == CON_Qualtrics.SEND_SURVEY_NO && (Trigger.isInsert || (Trigger.isUpdate && oldMap.get(cs.Id).Send_Survey__c != CON_Qualtrics.SEND_SURVEY_NO))){
                cs.Survey_Initiation_Status__c = CON_Qualtrics.SURVEY_DECLINED_PENDING_MGR_APPROVAL;
            }
            if(cs.Send_Survey__c == CON_Qualtrics.SEND_SURVEY_YES && (Trigger.isInsert || (Trigger.isUpdate && oldMap.get(cs.Id).Send_Survey__c != CON_Qualtrics.SEND_SURVEY_YES))) {
                cs.Survey_Initiation_Status__c = CON_Qualtrics.SURVEY_APPROVED;                
            }
        }    
    }
    */
    /**
    * This method is used to validate survey exists or not
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @return void
    */  
    /*commenting method for reference
    public static void validateSurvey_SurveyExists(List<Client_Sat_Survey__c> newSurveyList) {
        Set<Id> oppIdSet = new Set<Id> ();
        Date Date6Back = Date.today().addMonths(-6);
        for(Client_Sat_Survey__c cs : newSurveyList) {
            if(cs.Opportunity__c != null)
                oppIdSet.add(cs.Opportunity__c);
        }
        if(!oppIdSet.isEmpty() ) {
            List<Client_Sat_Survey__c> csList = new List<Client_Sat_Survey__c>();
            csList = new SLT_ClientSatSurvey().getClientSurveyByOpportunityAndCreatedDate(oppIdSet, Date6Back);
            oppIdSet.clear();
            if(!csList.isEmpty()) {
                for(Client_Sat_Survey__c cs : csList) {            
                    oppIdSet.add(cs.Opportunity__c);
                }
                for(Client_Sat_Survey__c newCS : newSurveyList){
                    if(oppIdSet.contains(newCS.Opportunity__c)) {
                        newCS.addError(CON_Qualtrics.SURVEY_HAS_ALREADY_BEEN_CREATED_WITHIN_LAST_6_MONTHS_ERROR_MSG);
                    }
                }
            }
        } 
    }
    */
    /**
    * This method is used to update opportunity codes on survey
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @return void
    */  
    /*commenting method for reference
    public static void updateSurvey_OpportunityProductCodes(List<Client_Sat_Survey__c> newSurveyList) {
        Set<Id> oppIdSet = new Set<Id>();
        for(Client_Sat_Survey__c cs : newSurveyList){
            oppIdSet.add(cs.Opportunity__c);
        }
        if(!oppIdSet.isEmpty()){
            List<OpportunityLineItem> oppLines;
            oppLines = new SLT_OpportunityLineItems().selectOLIByOpportunityId(oppIdSet);
            Map<id, String> oppProdCodeMap = new Map<id, String>();
            
            if(!oppLines.isEmpty()){
                for(OpportunityLineItem oli : oppLines) {
                    String prodCode = oppProdCodeMap.get(oli.OpportunityId);
                    if(prodCode == null || (prodCode != null && !prodCode.contains(oli.PricebookEntry.Product2.Global_Product_Code__c)))
                        prodCode = (prodCode == null) ? oli.PricebookEntry.Product2.Global_Product_Code__c : (prodCode + '; ' + oli.PricebookEntry.Product2.Global_Product_Code__c);
                            oppProdCodeMap.put(oli.OpportunityId, prodCode);
                }
            }
            for(Client_Sat_Survey__c cs : newSurveyList){
                cs.Opportunity_Product_Codes__c = oppProdCodeMap.get(cs.Opportunity__c);
            }
        }
    }
    */
    /**
    * This method is used to filter declined surveys
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @params Map<Id, Client_Sat_Survey__c> oldMapOfSurveys
    * @return Set<Client_Sat_Survey__c>
    */   
    /*commenting method for reference
    public static Set<Client_Sat_Survey__c> filterSurvey_DeclinedSurveys(List<Client_Sat_Survey__c> newSurveyList, Map<Id, Client_Sat_Survey__c> oldMapOfSurveys) {
        Set<Client_Sat_Survey__c> declinedCSSet = new Set<Client_Sat_Survey__c> ();
        for(Client_Sat_Survey__c cs : newSurveyList){
            if(cs.Send_Survey__c == CON_Qualtrics.SEND_SURVEY_NO && cs.Send_Survey__c != oldMapOfSurveys.get(cs.Id).Send_Survey__c ){
                declinedCSSet.add(cs);
            }
        }
        return declinedCSSet;
    }
    */
    /**
    * This method is used to update declined survey approver group id on survey
    * @params Set<Client_Sat_Survey__c> csSet
    * @return void
    */    
    /*commenting method for reference
    public static void updateSurvey_DeclinedSurveyApprovers(Set<Client_Sat_Survey__c> csSet) {
        Map<Id, Client_Sat_Survey__c> csIdMap = new Map<Id, Client_Sat_Survey__c> ();
        Set<String> grpNameSet = new Set<String> ();
        Set<String> oppIdSet = new Set<String> ();
        Map<Id, Proxy_Project__c> mapOfOpportunityToProject = new Map<Id, Proxy_Project__c>();
        for(Client_Sat_Survey__c cs : csSet) {
            csIdMap.put(cs.id, cs);
            oppIdSet.add(cs.Opportunity__c);
        }
        List<Proxy_Project__c> projectList = 
            new SLT_Proxy_Project().getProjectsByOpportunityIdAndRecordType(oppIdSet, CON_Qualtrics.RECORD_TYPE_ENGAGEMENT);
        for(Proxy_Project__c project: projectList) {
            mapOfOpportunityToProject.put(project.Opportunity__c, project);
        }
        List<Client_Sat_Survey__c> csList = new SLT_ClientSatSurvey().getClientSurveyById(csIdMap.keySet());
        for(Client_Sat_Survey__c cs1 :csList ){
            if(mapOfOpportunityToProject.containsKey(cs1.Opportunity__c) && mapOfOpportunityToProject.get(cs1.Opportunity__c) != null) {
                Proxy_Project__c project = mapOfOpportunityToProject.get(cs1.Opportunity__c);
                String grpNm = getApproverGroupName(project.Delivery_PIC_Offering_Segment__c,
                                                    project.Delivery_PIC_Offering_Type__c,
                                                    project.Delivery_PIC_Product_COE__c,
                                                    project.Delivery_PIC_Business_Unit__c,
                                                    project.Business_Unit__c, cs1.Opportunity__r.Main_Delivery_Country__c,
                                                    project.Delivery_PIC_User_Country__c
                                                   );
                csIdMap.get(cs1.id).Declined_Survey_Approver_Group__c = grpNm;
                grpNameSet.add(grpNm);
            }
        }
        List<Group> grpList = new SLT_Groups().getGroupsWithGroupMembersByGroupName(grpNameSet);
        Map<String,List<GroupMember>> grpNmMembersMap = new Map<String,List<GroupMember>>();
        Map<String, Id> grpNameIdMap = new Map<String, Id>();
        Set<Id> userIdSet = new Set<Id>();
        for(Group grp : grpList){
            grpNmMembersMap.put(grp.name, grp.GroupMembers);
            grpNameIdMap.put(grp.name, grp.id);
            for(GroupMember gm : grp.GroupMembers){
                if(gm.UserOrGroupId.getSObjectType() == User.sObjectType){
                    userIdSet.add(gm.UserOrGroupId);
                }
            }
        }
        Map<Id, User> userMap = new Map<Id, User>(new SLT_User().selectActiveUserByUserId(userIdSet, new Set<String>{'Id'}));
        List<Approval.ProcessSubmitRequest> approvalList = new List<Approval.ProcessSubmitRequest> ();
        for(Client_Sat_Survey__c cs2 : csSet) {
            cs2.Declined_Survey_Approver_1__c = null;
            cs2.Declined_Survey_Approver_2__c = null;
            cs2.Declined_Survey_Approver_3__c = null;
            String grpNm = cs2.Declined_Survey_Approver_Group__c;
            List<GroupMember> grpMembers = ((List<GroupMember>)grpNmMembersMap.get(grpNm));
            if(grpMembers != null && grpMembers.size() > 0){
                List<Id> activeMemberIdList = new List<Id>();
                for(GroupMember gm : grpMembers){
                    if(gm.UserOrGroupId.getSObjectType() == User.sObjectType && userMap.containsKey(gm.UserOrGroupId)){
                        activeMemberIdList.add(gm.UserOrGroupId);
                    }
                }
                if(activeMemberIdList.size() > 0){
                    cs2.Declined_Survey_Approver_1__c = activeMemberIdList[0];
                }
                if(activeMemberIdList.size() > 1){
                    cs2.Declined_Survey_Approver_2__c = activeMemberIdList[1];
                }
                if(activeMemberIdList.size() > 2){
                    cs2.Declined_Survey_Approver_3__c = activeMemberIdList[2];
                }
            }
            cs2.Declined_Survey_Approver_Group_ID__c = grpNameIdMap.get(grpNm);
        }        
    }
    */
    /*
    (i) engPIC_productOfferingType - PeopleSoft Product Offering Type of the Delivery PIC on the Engagement 
        - Opportunity__r.pse__Primary_Project__r.DeliveryPIC__r.pse__Salesforce_User__r.PeopleSoft_Product_Offering_Type__c
    (ii) engPIC_ProductCOE - PeopleSoft Product COE of the Delivery PIC on the Engagement 
        - Opportunity__r.pse__Primary_Project__r.DeliveryPIC__r.pse__Salesforce_User__r.PeopleSoft_Product_COE__c
    (iiii) engPIC_BU - Peoplesoft Business Unit of the Delivery PIC on the Engagement 
        - Opportunity__r.pse__Primary_Project__r.DeliveryPIC__r.pse__Salesforce_User__r.Business_Unit__c
    (iv) oppBU - Business Unit of the Opportunity
        - Opportunity__r.Region__c 
    (v) mainDelCntry - Main Delivery Country  of the Opportunity
        - Opportunity__r.Region_Territory__c  
    */  
    /*commenting method for reference
    public static String getApproverGroupName(String engPIC_productOfferingSegment, String engPIC_productOfferingType, String engPIC_ProductCOE, String engPIC_BU, String oppBU, String mainDelCntry, String userCntry){
        List<DeclinedSurveyApproverGroup__c> declinedApproverGroupList = [SELECT BusinessUnit__c, DeclinedSurveyApproverGroup__c, 
                                                                          PeopleSoft_Product_Offering_Segment__c, PeopleSoftBusinessUnit__c, 
                                                                          PeopleSoft_User_Country__c, MainDeliveryCountry__c, PeopleSoftProductCOE__c, 
                                                                          PeopleSoftProductOfferingType__c, Priority__c
                                                                          FROM DeclinedSurveyApproverGroup__c ORDER BY Priority__c];
        List<DeclinedSurveyApproverGroup__c> filterDeclinedApproverGroupListPre = new List<DeclinedSurveyApproverGroup__c>();
        List<DeclinedSurveyApproverGroup__c> filterDeclinedApproverGroupList = new List<DeclinedSurveyApproverGroup__c>();
        
        for(DeclinedSurveyApproverGroup__c declinedApproverGroup : declinedApproverGroupList){
            if(declinedApproverGroup.PeopleSoft_Product_Offering_Segment__c == engPIC_productOfferingSegment){
                filterDeclinedApproverGroupList.add(declinedApproverGroup);
            }
        }
        if(filterDeclinedApproverGroupList.size() == 0){
            for(DeclinedSurveyApproverGroup__c declinedApproverGroup : declinedApproverGroupList){
                if(declinedApproverGroup.PeopleSoft_Product_Offering_Segment__c == null || declinedApproverGroup.PeopleSoft_Product_Offering_Segment__c == ''){
                    filterDeclinedApproverGroupList.add(declinedApproverGroup);
                }
            }
        }
            
        filterDeclinedApproverGroupListPre = filterDeclinedApproverGroupList;
        filterDeclinedApproverGroupList = new List<DeclinedSurveyApproverGroup__c>();
        for(DeclinedSurveyApproverGroup__c declinedApproverGroup : filterDeclinedApproverGroupListPre){
            if(declinedApproverGroup.PeopleSoftProductOfferingType__c == engPIC_productOfferingType){
                filterDeclinedApproverGroupList.add(declinedApproverGroup);
            }
        }
        if(filterDeclinedApproverGroupList.size() == 0){
            for(DeclinedSurveyApproverGroup__c declinedApproverGroup : filterDeclinedApproverGroupListPre){
                if(declinedApproverGroup.PeopleSoftProductOfferingType__c == null || declinedApproverGroup.PeopleSoftProductOfferingType__c == ''){
                    filterDeclinedApproverGroupList.add(declinedApproverGroup);
                }
            }
        }
        
        filterDeclinedApproverGroupListPre = filterDeclinedApproverGroupList;
        filterDeclinedApproverGroupList = new List<DeclinedSurveyApproverGroup__c>();
        for(DeclinedSurveyApproverGroup__c declinedApproverGroup : filterDeclinedApproverGroupListPre){
            if(declinedApproverGroup.PeopleSoftProductCOE__c == engPIC_ProductCOE){
                filterDeclinedApproverGroupList.add(declinedApproverGroup);
            }
        }
        if(filterDeclinedApproverGroupList.size() == 0){
            for(DeclinedSurveyApproverGroup__c declinedApproverGroup : filterDeclinedApproverGroupListPre){
                if(declinedApproverGroup.PeopleSoftProductCOE__c == null || declinedApproverGroup.PeopleSoftProductCOE__c == ''){
                    filterDeclinedApproverGroupList.add(declinedApproverGroup);
                }
            }
        }
        
        filterDeclinedApproverGroupListPre = filterDeclinedApproverGroupList;
        filterDeclinedApproverGroupList = new List<DeclinedSurveyApproverGroup__c>();
        for(DeclinedSurveyApproverGroup__c declinedApproverGroup : filterDeclinedApproverGroupListPre){
            if(declinedApproverGroup.PeopleSoftBusinessUnit__c == engPIC_BU){
                filterDeclinedApproverGroupList.add(declinedApproverGroup);
            }
        }
        if(filterDeclinedApproverGroupList.size() == 0){
            for(DeclinedSurveyApproverGroup__c declinedApproverGroup : filterDeclinedApproverGroupListPre){
                if(declinedApproverGroup.PeopleSoftBusinessUnit__c == null || declinedApproverGroup.PeopleSoftBusinessUnit__c == ''){
                    filterDeclinedApproverGroupList.add(declinedApproverGroup);
                }
            }
        }
        
        filterDeclinedApproverGroupListPre = filterDeclinedApproverGroupList;
        filterDeclinedApproverGroupList = new List<DeclinedSurveyApproverGroup__c>();
        for(DeclinedSurveyApproverGroup__c declinedApproverGroup : filterDeclinedApproverGroupListPre){
            if(declinedApproverGroup.PeopleSoft_User_Country__c == userCntry){
                filterDeclinedApproverGroupList.add(declinedApproverGroup);
            }
        }
        if(filterDeclinedApproverGroupList.size() == 0){
            for(DeclinedSurveyApproverGroup__c declinedApproverGroup : filterDeclinedApproverGroupListPre){
                if(declinedApproverGroup.PeopleSoft_User_Country__c == null || declinedApproverGroup.PeopleSoft_User_Country__c == ''){
                    filterDeclinedApproverGroupList.add(declinedApproverGroup);
                }
            }
        }
        
        filterDeclinedApproverGroupListPre = filterDeclinedApproverGroupList;
        filterDeclinedApproverGroupList = new List<DeclinedSurveyApproverGroup__c>();
        for(DeclinedSurveyApproverGroup__c declinedApproverGroup : filterDeclinedApproverGroupListPre){
            if(declinedApproverGroup.BusinessUnit__c == oppBU){
                filterDeclinedApproverGroupList.add(declinedApproverGroup);
            }
        }
        if(filterDeclinedApproverGroupList.size() == 0){
            for(DeclinedSurveyApproverGroup__c declinedApproverGroup : filterDeclinedApproverGroupListPre){
                if(declinedApproverGroup.BusinessUnit__c == null || declinedApproverGroup.BusinessUnit__c == ''){
                    filterDeclinedApproverGroupList.add(declinedApproverGroup);
                }
            }
        }
        
        filterDeclinedApproverGroupListPre = filterDeclinedApproverGroupList;
        filterDeclinedApproverGroupList = new List<DeclinedSurveyApproverGroup__c>();
        for(DeclinedSurveyApproverGroup__c declinedApproverGroup : filterDeclinedApproverGroupListPre){
            if(declinedApproverGroup.MainDeliveryCountry__c == mainDelCntry){
                filterDeclinedApproverGroupList.add(declinedApproverGroup);
            }
        }
        if(filterDeclinedApproverGroupList.size() == 0){
            for(DeclinedSurveyApproverGroup__c declinedApproverGroup : filterDeclinedApproverGroupListPre){
                if(declinedApproverGroup.MainDeliveryCountry__c == null || declinedApproverGroup.MainDeliveryCountry__c == ''){
                    filterDeclinedApproverGroupList.add(declinedApproverGroup);
                }
            }
        }
        
        if(filterDeclinedApproverGroupList != null && filterDeclinedApproverGroupList.size() > 0){
            return(filterDeclinedApproverGroupList.get(0).DeclinedSurveyApproverGroup__c);
        }
        return(Label.CS_Admins);
    }
	*/
    /**
    * This method is used to submit surveys for approval
    * @params List<Client_Sat_Survey__c> newSurveyList
    * @params Map<Id, Client_Sat_Survey__c> oldMapOfSurveys
    * @return void
    */      
    /*commenting method for reference
    public static void submitForApproval(List<Client_Sat_Survey__c> newSurveyList, Map<Id, Client_Sat_Survey__c> oldMapOfSurveys) {
        List<Approval.ProcessSubmitRequest> approvalList = new List<Approval.ProcessSubmitRequest> ();
        for(Client_Sat_Survey__c cs : newSurveyList){
            if(cs.Send_Survey__c == CON_Qualtrics.SEND_SURVEY_NO && (Trigger.isInsert || (Trigger.isUpdate && oldMapOfSurveys.get(cs.id).Send_Survey__c != cs.Send_Survey__c))){
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(cs.id);
                approvalList.add(req1);
            }
        }
        if(approvalList.size() > 0)
            Approval.process(approvalList, false);        
    }
	*/
}