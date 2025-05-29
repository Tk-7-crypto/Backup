/*
 * Version       : 1.0
 * Description   : This Apex class is service class for Client Sat Survey Recipient Trigger
 */
public class DAOH_ClientSatSurveyRecipient {
    /**
    * This method is used to set Opp Date Fields
    * @params List<Client_Sat_Survey_Recipient__c> newSurveyList
    * @return void
    */
    public static void setOppDateFields(List<Client_Sat_Survey_Recipient__c> newSurveyRecipientList) {
        Set<Id> csSet = new Set<Id>();
        Set<Id> opportunityIDs = new Set<Id> {};
        List<Client_Sat_Survey__c> csList = new List<Client_Sat_Survey__c>();
        List<Opportunity> oppListSurveydateupdate = new List<Opportunity>();
        Map<Id, Client_Sat_Survey_Recipient__c> oppIdToRecipientMap = new Map<Id, Client_Sat_Survey_Recipient__c>();
        Map<Id, Client_Sat_Survey_Recipient__c> surveyIdToRecipientMap = new Map<Id, Client_Sat_Survey_Recipient__c>();
        Date nearestFutureDate;
        Date endDate;
        Map<Id,Proxy_Project__c> proxyProjectMap = new Map<Id,Proxy_Project__c>();
        Set<String> lineOfBusiness = new Set<String>{'Clinical','Data Sciences','Early Clinical Development','Connected Devices','Patient & DCT Solutions'};
        
        for(Client_Sat_Survey_Recipient__c csRec: newSurveyRecipientList){
            csSet.add(csRec.Client_Sat_Survey__c);
            surveyIdToRecipientMap.put(csRec.Client_Sat_Survey__c, csRec);
        }
        if(csSet.size() > 0){
            csList = new SLT_ClientSatSurvey().getClientSurveyById(csSet);
            Set<Id> OppIdSet = new Set<Id>();
            for(Client_Sat_Survey__c cs : csList) {
                opportunityIDs.add(cs.Opportunity__c);
            }
            proxyProjectMap= new SLT_proxy_Project().getProxyProjectByOppIDAndRecordTypeName(opportunityIDs, 'Engagement', new Set<String>{'ID','Name','Opportunity__c','Project_Start_Date__c', 'Project_End_Date__c'});
            for(Client_Sat_Survey__c cs : csList){
                if(OppIdSet.contains(cs.Opportunity__c)) {
                    continue;
                } else {
                    OppIdSet.add(cs.Opportunity__c);
                }
                if(cs.Opportunity__r != null){
                    Opportunity opp = cs.Opportunity__r;
                    oppIdToRecipientMap.put(cs.Opportunity__c, surveyIdToRecipientMap.get(cs.id));
                    if(opp.Is_Survey_eligible_for_RDS_Auto__c || opp.Is_Survey_eligible_for_RDS_Manual__c){
                        nearestFutureDate  = cs.Survey_Send_Date__c.addMonths(6);
                        if(opp.ZREP_Product_Count__c > 0  && (proxyProjectMap.containsKey(opp.ID))) {
                            endDate = proxyProjectMap.get(opp.ID).Project_End_Date__c;
                        }
                        else if(lineOfBusiness.contains(opp.Line_of_Business__c)) {
                            endDate = opp.Expected_Project_End_Date__c;
                        }
                        else{
                            endDate = opp.Contract_End_Date__c;
                        }
                        if (nearestFutureDate >= endDate) {
                            nearestFutureDate = endDate;
                        }
                    }else {
                        nearestFutureDate  = cs.Survey_Send_Date__c.addMonths(12);
                        Date Date6more = nearestFutureDate.addMonths(6);
                        if(opp.ZREP_Product_Count__c > 0  && (proxyProjectMap.containsKey(opp.ID))) {
                            endDate = proxyProjectMap.get(opp.ID).Project_End_Date__c;
                        } else {
                            endDate = opp.Contract_End_Date__c;
                        }
                        
                        if(Date6more >= endDate){
                            nearestFutureDate = endDate;
                        }
                    }
                    opp.Upcoming_Survey_Send_Date__c = nearestFutureDate;
                    opp.Next_Survey_Send_Date__c = nearestFutureDate;
                    opp.Previous_survey_sent_date__c = cs.Survey_Send_Date__c;
                    oppListSurveydateupdate.add(opp);
                }            
            }
            
            if(oppListSurveydateupdate.size() > 0){
                UTL_ExecutionControl.stopTriggerExecution = true;
                Database.SaveResult[] sr = Database.update(oppListSurveydateupdate, false);
                for(Integer i = 0; i < sr.size(); i++) {
                    Id oppId = oppListSurveydateupdate.get(i).Id;
                    if(!sr[i].isSuccess()) {
                        String msgStr = null;
                        Client_Sat_Survey_Recipient__c csRecObj = oppIdToRecipientMap.get(oppId);
                        Database.Error[] err = sr[i].getErrors();
                        csRecObj.addError(err[0].getMessage());
                    }
                }
                UTL_ExecutionControl.stopTriggerExecution = false;
                
            }
        }
    }
    
}