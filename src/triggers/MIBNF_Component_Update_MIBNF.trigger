trigger MIBNF_Component_Update_MIBNF on MIBNF_Component__c (after update)
{
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_MIBNF_Trigger__c) {
        Set<Id> opportunityIdsSetForBNF = new Set<Id>();
        for(MIBNF_Component__c bnfRecord : Trigger.new){
            if(bnfRecord.BNF_Status__c != Trigger.oldMap.get(bnfRecord.id).BNF_Status__c) {
                opportunityIdsSetForBNF.add(bnfRecord.Opportunity__c);
            }
        }
        if(opportunityIdsSetForBNF.size() > 0) {
            Map<Id,Opportunity> opportunityToUpdateMap = new Map<Id,Opportunity>();
            Set<String> bnfFieldsSet = new Set<String>{'Id','BNF_Status__c','MIBNF__c','Comp_Revenue_Analyst_user__c'};
                for(Integer i=2;i<=10;i++){
                    bnfFieldsSet.add('Comp_Revenue_Analyst_user_'+i+'__c');
                }
            Map<Id, Opportunity> opportunityMap = new SLT_Opportunity().selectByIdWithMIBNF(opportunityIdsSetForBNF, new Set<String>{'Id','Is_Any_BNF_Approved__c','Is_Any_BNF_Submitted__c','Approved_BNF_Count__c'},bnfFieldsSet);
            Map<Id,Set<String>> oppIdToIdMap = new Map<Id,Set<String>>();
            Set<Id> revenueAnalaystUserIdsSet = new Set<Id>();
            Set<Id> mibnf2CheckSet  = new Set<Id>();
            for(Id mapId : opportunityMap.keySet()){
                Opportunity currentOpp = opportunityMap.get(mapId);
                List<Sobject> sobjList = currentOpp.getSObjects(CON_CRM.OPPORTUNITY_MIBNF_COMPONENT_RELATIONSHIP);
                List<MIBNF_Component__c> bnfRecordsList = new List<MIBNF_Component__c>();
                if(sobjList != null && sobjList.size() > 0){
                    bnfRecordsList = (List<MIBNF_Component__c>)sobjList;
                }
                for(MIBNF_Component__c bnfRecord : bnfRecordsList ){
                    if(bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_PENDING')){
                        mibnf2CheckSet.add(bnfRecord.MIBNF__c);
                    }
                }                
            }          
            
            for(Id mapId : opportunityMap.keySet()){
                Opportunity currentOpp = opportunityMap.get(mapId);
                List<Sobject> sobjList = currentOpp.getSObjects(CON_CRM.OPPORTUNITY_MIBNF_COMPONENT_RELATIONSHIP);
                List<MIBNF_Component__c> bnfRecordsList = new List<MIBNF_Component__c>();
                if(sobjList != null && sobjList.size() > 0){
                    bnfRecordsList = (List<MIBNF_Component__c>)sobjList;
                }
                if(bnfRecordsList.size() > 0){
                    Boolean isAnyBnfApprovedOldValue = currentOpp.Is_Any_BNF_Approved__c;
                    Boolean isAnyBnfSubmittedOldValue = currentOpp.Is_Any_BNF_Submitted__c; 
                    Decimal approvedBnfCountOldValue = currentOpp.Approved_BNF_Count__c;
                    Boolean isAnyBnfApproved = false;
                    Boolean isAnyBnfSubmitted = false;
                    Decimal approvedBnfCount = 0;
                    Set<String> bnfRecordsApprovalList = new Set<String>();
                    for(MIBNF_Component__c bnfRecord : bnfRecordsList ){
                        if(bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('ACCEPTED') || bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CONFIRMED')){
                            if(!mibnf2CheckSet.contains(bnfRecord.MIBNF__c)){
                                approvedBnfCount++;    
                                currentOpp.Is_Any_BNF_Approved__c = true;
                                currentOpp.Approved_BNF_Count__c = approvedBnfCount;
                            }
                        }else if(bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED') || bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('LO_ACCEPTED') || bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('RA_ACCEPTED') || bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CREATED') || bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_PENDING')  || bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_PENDING') || bnfRecord.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_REJECTED')){
                            isAnyBnfSubmitted = true;
                            if(Trigger.newMap.containsKey(bnfRecord.Id)){
                                if(bnfRecord.get('Comp_Revenue_Analyst_user__c') != null && bnfRecord.get('Comp_Revenue_Analyst_user__c') != ''){
                                    bnfRecordsApprovalList.add(String.valueOf(bnfRecord.get('Comp_Revenue_Analyst_user__c')));
                                    revenueAnalaystUserIdsSet.add(String.valueOf(bnfRecord.get('Comp_Revenue_Analyst_user__c')));
                                }
                                for(Integer i=2;i<=10;i++){
                                    if(bnfRecord.get('Comp_Revenue_Analyst_user_'+i+'__c') != null && bnfRecord.get('Comp_Revenue_Analyst_user_'+i+'__c') != ''){
                                        bnfRecordsApprovalList.add(String.valueOf(bnfRecord.get('Comp_Revenue_Analyst_user_'+i+'__c')));
                                        revenueAnalaystUserIdsSet.add(String.valueOf(bnfRecord.get('Comp_Revenue_Analyst_user_'+i+'__c')));                            
                                    }
                                }
                            }
                        }
                    }
                    currentOpp.Is_Any_BNF_Submitted__c = isAnyBnfSubmitted;
                    if(bnfRecordsApprovalList.size() > 0){
                        oppIdToIdMap.put(currentOpp.Id, bnfRecordsApprovalList);
                    }
                    if(isAnyBnfApprovedOldValue != currentOpp.Is_Any_BNF_Approved__c || isAnyBnfSubmittedOldValue != currentOpp.Is_Any_BNF_Submitted__c || approvedBnfCountOldValue != currentOpp.Approved_BNF_Count__c){
                        opportunityToUpdateMap.put(currentOpp.Id,currentOpp);    
                    }
                }
            }
            if(opportunityToUpdateMap.size() > 0 && oppIdToIdMap.size() > 0){
                Map<Id, User> reveneuAnayalsytUsersMap = new SLT_User().selectByUserId(revenueAnalaystUserIdsSet,new Set<String>{'Id','LI_User_Id__c'});
                for(Id oppId : oppIdToIdMap.keySet()){
                    Opportunity currentOpp = opportunityMap.get(oppId);
                    Set<String> raUsersId = new Set<String>();
                    for(String raId : oppIdToIdMap.get(oppId)){
                        if(reveneuAnayalsytUsersMap.containsKey(raId)){
                            raUsersId.add(reveneuAnayalsytUsersMap.get(raId).LI_User_Id__c);
                        }
                    }
                    currentOpp.Current_Approvers__c = JSON.serialize(raUsersId);  
                    opportunityToUpdateMap.put(currentOpp.Id,currentOpp);
                }
            }
            if(opportunityToUpdateMap.size() > 0){
                CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
                CON_CRM.MULESOFT_OPP_SYNC_TRIGGER_HAS_RUN = false;
                CON_CRM.updateSkipValidation = true;
                update opportunityToUpdateMap.values();
                CON_CRM.updateSkipValidation = false;
            }
        }
        if (!Global_Variables.MIBNF_Component_Update_In_Progress)
        {
            Global_Variables.MIBNF_Component_Update_In_Progress = true;
            Set<Id> MIBNF_Id_Set = new Set<Id>();
            for (MIBNF_Component__c MIBNF_Comp:trigger.New)
            {
                MIBNF_Id_Set.add(MIBNF_Comp.MIBNF__c);
            }
            Map<Id,MIBNF2__c> MIBNF_Map = new Map<Id,MIBNF2__c>([select Id,SAP_Master_Contract__c from MIBNF2__c where Id in :MIBNF_Id_Set]);
            for (MIBNF_Component__c MIBNF_Comp:trigger.New)
            {
                if (MIBNF_Map.get(MIBNF_Comp.MIBNF__c).SAP_Master_Contract__c == null && MIBNF_Comp.SAP_Master_Contract__c != null)
                {
                    MIBNF_Map.get(MIBNF_Comp.MIBNF__c).SAP_Master_Contract__c = MIBNF_Comp.SAP_Master_Contract__c;
                }
            }
            update MIBNF_Map.values();
            Global_Variables.MIBNF_Component_Update_In_Progress = false;
        }
    }
    

}