trigger TGR_Update_Survey_Event on Update_Survey_Event__e (after insert) {
    //system.assert(false,UserInfo.getUserName());
    
    List<Client_Sat_Survey__c> surveyToUpdateList = new List<Client_Sat_Survey__c>();
    Map<Id,Update_Survey_Event__e> oppToEventMap = new Map<Id,Update_Survey_Event__e>();
    Map<Id,Proxy_Project__c> proxyProjectMap = new Map<Id,Proxy_Project__c>();

    Set<String> lineOfBusinessSet1 = new Set<String>{'Clinical','Data Sciences', 'Early Clinical Development','Connected Devices', 'Safety & Med Info','Patient & DCT Solutions'};
    Set<String> lineOfBusinessSet2 = lineOfBusinessSet1;
    lineOfBusinessSet2.add('Outcome');
    lineOfBusinessSet2.add('RWLP');
    Set<Id> recordtypeSet1 = new Set<Id>{CON_CRM.CONTRACT_RECORD_TYPE_WORK_ORDER_SALES_MEDICAL};
    Set<Id> recordTypeSet2 = new Set<Id>{CON_CRM.CONTRACT_RECORD_TYPE_CHANGE_ORDER, CON_CRM.CONTRACT_RECORD_TYPE_WORK_ORDER_SALES_MEDICAL, CON_CRM.CONTRACT_RECORD_TYPE_PRELIMINARY_AGREEMENT_GBO };
    Set<String> lobSet = lineOfBusinessSet2;
    List<Opportunity> filterOpportunityList = new List<Opportunity>();
    Boolean isTriggeredFromAgr = false;
    Boolean isTriggeredFromProxyProject = false;
    
    if(Trigger.new[0].Related_record_ID__c.startsWith(CON_CRM.APTTUS_APTS_AGREEMENT_KEY_PREFIX)){// || Trigger.new[0].Trigger_Origin__c  == 'AGREEMENT_EXTENSION'
        lobSet = lineOfBusinessSet1;
        isTriggeredFromAgr = true;
    }
    
    for(Update_Survey_Event__e updateSurveyEvent : Trigger.new){
        system.debug(updateSurveyEvent);
        oppToEventMap.put(updateSurveyEvent.Opportunity_ID__c, updateSurveyEvent);
    }
    if(Trigger.new[0].Related_record_ID__c.startsWith(Proxy_Project__c.sObjecttype.getDescribe().getKeyPrefix())){// || Trigger.new[0].Trigger_Origin__c  == 'AGREEMENT_EXTENSION'
        isTriggeredFromProxyProject = true;
        proxyProjectMap= new SLT_proxy_Project().getProxyProjectByOppIDAndRecordTypeName(oppToEventMap.keyset(), 'Engagement', new Set<String>{'ID','Name','Delivery_PIC_Name__c','Delivery_PIC_User_Country__c','Project_Start_Date__c','Project_End_Date__c','Opportunity__c','Delivery_PIC_Email__c','Delivery_PIC_EmployeeNumber__c'});    	
    }
    
    if(oppToEventMap.size() > 0){
        if(isTriggeredFromProxyProject){
            filterOpportunityList = new SLT_Opportunity().getLatestSurveyOfOpportunity(oppToEventMap.keyset());
        }
        else {
            filterOpportunityList = new SLT_Opportunity().getLatestSurveyOfOpportunitybyLOB(oppToEventMap.keyset(), lobSet);
        }
        
        for(Opportunity opp : filterOpportunityList) {
            Update_Survey_Event__e updateSurveyEvent = oppToEventMap.get(opp.id);
            if(opp.Client_Sat_Surveys__r.size() > 0){
                Client_Sat_Survey__c survey = opp.Client_Sat_Surveys__r[0];
                if(survey.Send_Survey__c != 'Yes' && survey.Send_Survey__c != 'No' ){
                    if(isTriggeredFromProxyProject) {
                        survey = new Client_Sat_Survey__c (Id = survey.id);
                        survey.Survey_PIC_Name__c = proxyProjectMap.get(opp.id).Delivery_PIC_Name__c ;
                        survey.Survey_PIC_Email__c =  proxyProjectMap.get(opp.id).Delivery_PIC_Email__c;
                        survey.Survey_PIC_Email1__c =  proxyProjectMap.get(opp.id).Delivery_PIC_Email__c;
                        survey.Survey_PIC_First_Name__c =  proxyProjectMap.get(opp.id).Delivery_PIC_Name__c.SubStringBefore(' ');
                        survey.Survey_PIC_Last_Name__c =  proxyProjectMap.get(opp.id).Delivery_PIC_Name__c.SubStringAfter(' ');
                        survey.Survey_PIC_EmployeeNumber__c =  proxyProjectMap.get(opp.id).Delivery_PIC_EmployeeNumber__c;
                        survey.PIC_Country__c =  proxyProjectMap.get(opp.id).Delivery_PIC_User_Country__c;
                        surveyToUpdateList.add(survey);
                    }
                    else if(updateSurveyEvent.Is_Insert__c || (!updateSurveyEvent.Is_Insert__c && (survey.Survey_PIC__c == null || updateSurveyEvent.Related_record_ID__c == survey.Related_Contract_Id__c))) {
                        if(isTriggeredFromAgr || (!isTriggeredFromAgr &&(recordtypeSet1.contains(updateSurveyEvent.Record_Type_ID__c) && lineOfBusinessSet1.contains(opp.Line_of_Business__c))|| (recordTypeSet2.contains(updateSurveyEvent.Record_Type_ID__c) && lineOfBusinessSet2.contains(opp.Line_of_Business__c)))){
                            survey = new Client_Sat_Survey__c (Id = survey.id);
                            survey.Survey_PIC__c = updateSurveyEvent.Survey_PIC_ID__c;
                            survey.Related_Contract_Id__c = updateSurveyEvent.Related_record_ID__c;
                            surveyToUpdateList.add(survey);
                        }
                    }
                }
            }
        }
    }
    
    if(surveyToUpdateList.size() > 0){
        Database.SaveResult [] updateResult = Database.update(surveyToUpdateList, false);
        system.debug(updateResult);
    }
    
}