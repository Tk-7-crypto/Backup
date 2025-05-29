/**
 * @File Name          : CNT_CLP_CallOut.cls
 * @Description        : 
 * @Author             : Anup Kage 
 * @Group              : 
 * @Last Modified By   : Anup Kage 
 * @Last Modified On   : 5/19/2020, 2:39:47 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/19/2020        Anup Kage               Initial Version
**/
public class CNT_CLP_CallOut {
    /**
    * @description 
    * @author Anup Kage  | 5/19/2020 
    * @param recId 
    * @return Integer 
    **/
    @AuraEnabled
    public static String getAgreementValues(String recId){
        Set<Id> agreementIdSet = new Set<Id>();
        agreementIdSet.add(recId);
        return getAgreementForCallout(agreementIdSet, false, true);
    }
    
    /**
     * This method is used to get Agreement record detail.
     * @params Id recordId
     * @return Apttus__APTS_Agreement__c
     */ 
    @AuraEnabled
    public static Bid_History__c getAgreementDetail(Id recordId){
        Set<String> agreementFieldSet = new Set<String>{'Unity_Living_Proposal__c', 'Record_Type_Developer_Name__c', 'CreatedDate'};
        return new SLT_Bid_History(false, false).getBidHistoryDetails(recordId,agreementFieldSet);
    }
    
    /**
     * This method is used to check record create with it 1 minute.
     * @params DateTime recordCreatedDate
     * @return Boolean
     */ 
    @AuraEnabled
    public static Boolean isRecordCreatedNow(DateTime recordCreatedDate){
        DateTime currentTime = System.now();
        if(recordCreatedDate.date() == currentTime.date()){
            if(getSecoundFromTime(currentTime) - getSecoundFromTime(recordCreatedDate) < 90){
                return true;
            }else
                return false;
        }else
            return false;
    }
    
    /**
     * This method is used to convert time in secound.
     * @params DateTime t_time
     * @return Integer
     */ 
    private static Integer getSecoundFromTime(DateTime t_time) {
        return (t_time.hour()*3600) + (t_time.minute()*60) + t_time.second();
    }
    
    @future(Callout = true)
    public static void getAgreementDetails(Set<Id> agreementIdSet){
        getAgreementForCallout(agreementIdSet, true, false);
    }
    
    //IQVIACBEX-2245 Added Clinical Technology LOB for unity link
    //IQVIACBEX-3226 Added Boolean fromAura to create unity link via API call out in case the unity link is not coming.
    public static String getAgreementForCallout(Set<Id> agreementIdSet, Boolean fromTrigger, Boolean fromAura){
        List<String> lineOfBusinessLimitList = new List<String>{'Clinical', 'Early Clinical Development', 'Data Sciences', 'Safety & Med Info','Clinical Technology', 'Outcome', 'RWLP', 'Safety & Med Info', 'Patient & DCT Solutions'};
        Set<String> agreementFieldSet = new Set<String>{'Name', 'Bid_History_Account__c', 'Bid_History_Account__r.Name', 'Unity_Living_Proposal__c', 'Bid_History_Related_Opportunity__c', 'Number_of_Sites__c', 'Targeted_Countries__c', 'Indication__c', 'Intervention_Type__c', 'Opportunity_Type__c', 'Bid_Due_Date__c', 'Therapy_Area__c','RecordType.DeveloperName','Bid_History_Related_Opportunity__r.Line_of_Business__c','Opportunity_Number__c'};
        Set<String> opportunityFieldSet = new Set<String>{'Name', 'Owner.Name', 'Owner.Email',  'Phase_P__c', 'Indication_List__c', 'Line_of_Business__c', 'Drug_Product_Name__c', 'Phase_1_Study_Type__c','Is_this_IQVIA_Biotech__c', 
												'Legacy_Quintiles_Opportunity_Number__c', 'Verbatim_Indication_Term__c', 'Protocol_Number__c','FSP__c', 'Population_Age_Group__c', 'Is_this_a_Virtual_Trials_Study__c'};
        Set<String> eligibleRecordTypeSet = new Set<String>{'Clinical_Bid','Early_Engagement_Bid', 'Post_Award_Bid', 'RFI_Request'};
        Map<Id, HttpRequest> httpRequestBodyByAgreementId = new Map<Id,HttpRequest>();
        Map<Id, HttpResponse> httpResponseBodyByAgreementId = new Map<Id,HttpResponse>();
        Set<Id> opportunityIdSet = new Set<Id>();
        String response ='';
        list<Bid_History__c> bidsToUpdate = new List<Bid_History__c>();
        Map<Id,Bid_History__c> agreementById = new SLT_Bid_History().getBidHistoriesById(agreementIdSet, agreementFieldSet);
        for(Bid_History__c agRec : agreementById.values()){
            opportunityIdSet.add(agRec.Bid_History_Related_Opportunity__c);
        }
        Map<Id, Opportunity> opportunityById = new SLT_Opportunity().selectByOpportunityId(opportunityIdSet, opportunityFieldSet);
        Unity_Living_Proposal__c unityLivingData = Unity_Living_Proposal__c.getOrgDefaults();
        
        if(System.isFuture() || fromAura == true){
            if(unityLivingData.End_Point__c != null && unityLivingData.X_API_Key__c != null){
                for(Id agreementId: agreementIdSet){
                    Bid_History__c agreementRecord = agreementById.get(agreementId);
                    Opportunity oppRecord = opportunityById.get(agreementRecord.Bid_History_Related_Opportunity__c);
                    if(eligibleRecordTypeSet.contains(agreementRecord.RecordType.DeveloperName)) {
                        if(lineOfBusinessLimitList.contains(oppRecord?.Line_of_Business__c) && fromTrigger){
                            httpRequestBodyByAgreementId.put(agreementId,httpRequestBodyGenerator(agreementById.get(agreementId), oppRecord, unityLivingData));
                            } else if(!fromTrigger){
                                httpRequestBodyByAgreementId.put(agreementId,httpRequestBodyGenerator(agreementById.get(agreementId), oppRecord, unityLivingData));
                            }
                    }
                }
                for(Id agId : httpRequestBodyByAgreementId.keySet()){
                    httpResponseBodyByAgreementId.put(agId,unityAPICallout(agId, httpRequestBodyByAgreementId.get(agId)));
                }
                List<Bid_History__c> agreementList = new List<Bid_History__c>();
                for(id agId : httpResponseBodyByAgreementId.keySet()){
                    response = generateResponse(httpResponseBodyByAgreementId.get(agId));
                    Map<String, Object>  responseMap =   (Map<String, Object>) JSON.deserializeUntyped(response);
                    if(responseMap.get('statusCode') == '200'){
                        Bid_History__c agrement = new Bid_History__c();
                        agrement.Id = agId;
                        agrement.Unity_Living_Proposal__c = (String)responseMap.get('url');
                        agreementList.add(agrement);
                    }
                }
                if(!agreementList.isEmpty()){
                    UPDATE agreementList;
                    List<Id> updatedAgreementIdList = new List<Id>();
                    for(Bid_History__c agreement :agreementList){
                        updatedAgreementIdList.add(agreement.Id);
                    }
                    refreshUnityLink(updatedAgreementIdList);
                }
            }
        } else {
            //IQVIACBEX-3015 When we are not making callout to Unity and populating link when bid is created.
            for(Id bidRecId: agreementById.keySet()) {
                //IQVIACBEX-3015 Fetch Unity link prefix as per current org. custom setting contains org and Link prefix mappings
                Unity_Link_Prefix__c unityMappedPrefix = Unity_Link_Prefix__c.getInstance();
                String linkPrefix = unityMappedPrefix.UnityLink_URL__c;
                if(eligibleRecordTypeSet.contains(agreementById.get(bidRecId).RecordType.DeveloperName) && lineOfBusinessLimitList.contains(agreementById.get(bidRecId).Bid_History_Related_Opportunity__r.Line_of_Business__c)) {
                    Bid_History__c bdrecord = new Bid_History__c();
                    bdrecord.Id = bidRecId;
                    bdrecord.Unity_Living_Proposal__c = linkPrefix + String.valueOf(agreementById.get(bidRecId).Opportunity_Number__c);
                    bidsToUpdate.add(bdrecord);
                }
            }
            if(!bidsToUpdate.isEmpty()) {
                Update bidsToUpdate;
            }
        }
        return response;
    }

    private static HttpResponse unityAPICallout(Id agreementId, HttpRequest requestBody){
        Http http = new Http();
        HttpResponse response;
        if(!Test.isRunningTest()){
            response = http.send(requestBody);
            if(response.getStatusCode() != 200){
                response = http.send(requestBody);
            }
        }
        return response;
    }

    public static String generateResponse( HttpResponse response){
        Map<String, String> values = new Map<String, String>();
        String message = '';
        try {
            Object objResponse = JSON.deserializeUntyped(response.getBody());
            if (objResponse instanceof Map<String,Object>){
                values = (Map<String, String>)JSON.deserialize(response.getBody(), Map<String, String>.class);
                if(values.containsKey('message')){
                    message += values.get('message');
                }else if(values.containsKey('msg')){
                    message += values.get('msg');
                }                
            } else if (objResponse instanceof List<Object>){
                List<Object> errorList = (List<Object>)JSON.deserializeUntyped( response.getBody());
                for(Object obj : errorList){
                    Map<String, Object> valueparse = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                    if(valueparse.containsKey('message')){
                        message += String.valueOf(valueparse.get('message'));
                    }else if(valueparse.containsKey('msg')){
                        message += String.valueOf(valueparse.get('msg'));
                    }
                }
            }            
        } catch (exception e) {
            return responseReturn(e.getmessage(), 000, 'Failed', 'error', null);
        }
        String type = '';
        String url = '';
        if(response.getStatusCode() == 200){
            type = 'success';
            url = values.get('url');
        } else {
            type = 'error';
            url = null;
        }
        return responseReturn(message, response.getStatusCode(), response.getStatus(), type, url);
    }

    private static HttpRequest httpRequestBodyGenerator(Bid_History__c agRecord, Opportunity oppRecord, Unity_Living_Proposal__c unityLivingData){
        proposalDetails propDetailObj = new proposalDetails();
        propDetailObj.accountExecutive = 'String';
        propDetailObj.BusinessDevelopmentRepName = oppRecord.Owner.Name;
        propDetailObj.BusinessDevelopmentRepEmail = oppRecord.Owner.Email;
        propDetailObj.countries = agRecord.Targeted_Countries__c;
        
        propDetailObj.numberOfSites = agRecord.Number_of_Sites__c;
        propDetailObj.labs = 'String';
        propDetailObj.proposalDirector = 'String';
        propDetailObj.synopsisSent = 'String';
        wrapperReqBody wrapperReqObj = new wrapperReqBody();
        wrapperReqObj.lineOfBusiness = oppRecord.Line_of_Business__c;// line of business
        wrapperReqObj.fsp = oppRecord.FSP__c;// FSP
        wrapperReqObj.isThisIqviaBiotech = oppRecord.Is_this_IQVIA_Biotech__c;// is this IQVIA biotech		
        wrapperReqObj.legacyQopportunityNumber = oppRecord.Legacy_Quintiles_Opportunity_Number__c;// Legacy Q opportunity number		
        
        wrapperReqObj.indication = agRecord.Indication__c; //Opportunity Overview	R&D details	indication	Apttus_APTS_Agreement_c	
        wrapperReqObj.therapyArea = agRecord.Therapy_Area__c;
        
        wrapperReqObj.interventionType = agRecord.Intervention_Type__c; //Opportunity Overview	Opportunity details	intervention type	Apttus_APTS_Agreement_c	
        wrapperReqObj.opportunityType = agRecord.Opportunity_Type__c; //Opportunity Overview	Agreement	opportunity type	Apttus_APTS_Agreement_c	
        wrapperReqObj.bidDueDate = agRecord.Bid_Due_Date__c;
        wrapperReqObj.phase = oppRecord.Phase_P__c;
        wrapperReqObj.verbatimIndicationTerm = oppRecord.Verbatim_Indication_Term__c;
        wrapperReqObj.protocolNumber = oppRecord.Protocol_Number__c;
        wrapperReqObj.drugProductName = oppRecord.Drug_Product_Name__c;
        wrapperReqObj.phaseOneStudyType = oppRecord.Phase_1_Study_Type__c;
        wrapperReqObj.accountId = agRecord.Bid_History_Account__c;
        wrapperReqObj.accountName = agRecord.Bid_History_Account__r.Name;
        wrapperReqObj.agreementName = agRecord.Name; 
        wrapperReqObj.opportunityName = oppRecord.Name;
        wrapperReqObj.proposalDate = Date.today();
        wrapperReqObj.agreementId = agRecord.Id;
        wrapperReqObj.linkToOpportunity = system.URL.getOrgDomainUrl().toExternalForm()+'/'+oppRecord.Id;
        wrapperReqObj.proposalDetails = propDetailObj;
        Http http = new Http();
        HttpRequest request = new HttpRequest();//'https://r0udo916g4.execute-api.us-east-2.amazonaws.com/dev/api/proposals'
        request.setEndpoint(unityLivingData.End_Point__c);
        request.setTimeout(Integer.valueOf(unityLivingData.Unity_Api_Time_Out__c));
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('x-api-key', unityLivingData.X_API_Key__c);//'LodOBHeBPI5zGMDaq2Ppv8N2oHialSkR9t4cnQlH'
     
        String jsonBody = JSON.serialize(wrapperReqObj);
        request.setBody(jsonBody);
        return request;
    }
    /**
    * @description 
    * @author Anup Kage | 10-01-2020 
    * @param agreementIdList 
    **/
    public static void refreshUnityLink(List<Id> agreementIdList)
    {   
        List<Unity_Link_Generation__e> unityLinkRefresherList = new List<Unity_Link_Generation__e>();
        for (String recordId: agreementIdList) {
            unityLinkRefresherList.add(new Unity_Link_Generation__e(Record_Id__c = recordId));
        }
        if(!unityLinkRefresherList.isEmpty()){
            List<Database.SaveResult> results = EventBus.publish(unityLinkRefresherList);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    for (Database.Error error : result.getErrors()) {
                        System.debug('Error returned: ' + error.getStatusCode() +' - '+ error.getMessage());
                    }
                }
            }
        }
    }
    public static string responseReturn(String message, Integer statusCode, String status, String type, string url){
        Map<String, String> returnResponse = new Map<String, String>();
        returnResponse.put('message', message);
        returnResponse.put('status', status);
        returnResponse.put('statusCode', String.valueOf(statusCode));
        returnResponse.put('type', type);
        returnResponse.put('url', url);
        return JSON.serialize(returnResponse);
    }
    public class resposeWrapper{
        public String message;
        public Integer statusCode;
        public String status;
    }
    public class wrapperReqBody{
        public String accountId;
        public String accountName;
        public String opportunityName;
        public String agreementName;
        public String agreementId;
        public Date proposalDate;
        public String linkToOpportunity;
        public List<proposalUsers> proposalUsers;
        public proposalDetails proposalDetails;
        public String legacyQopportunityNumber;
        public Date bidDueDate;
        public String lineOfBusiness;
        public String fsp;
        public String isThisIqviaBiotech;
        public String phase;
        public String verbatimIndicationTerm;
        public String therapyArea;
        public String protocolNumber;
        public String drugProductName;
        public String indication;
        public String interventionType;
        public String opportunityType;
        public String phaseOneStudyType;
        public String isThisOpportunityApotentialBcoi;
    }
    public class proposalUsers{
        public String name;
        public String email;
        public String team;
    }
    public class proposalDetails{
        public String accountExecutive;
        public String BusinessDevelopmentRepName;
        public String BusinessDevelopmentRepEmail;
        public String proposalDirector;
        public String labs;
        public String synopsisSent;
        public String phase;
        public String countries;
        public Decimal numberOfSites;
        public String indication;
    }
        
}