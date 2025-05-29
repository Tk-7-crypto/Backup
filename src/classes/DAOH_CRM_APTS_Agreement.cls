public class DAOH_CRM_APTS_Agreement {
    
    public static void updateRfpReceivedDate(List<Apttus__APTS_Agreement__c> newList, Map < Id, Apttus__APTS_Agreement__c > oldMap) {
    }
    
    /**
     * This method is used to update Survey PIC on latest Client_Sat_Survey__c object
     * @params  List<Apttus__APTS_Agreement__c> newList
     * @params  Map<Id, Apttus__APTS_Agreement__c> oldMap
     * @return  void
     */
    public static void updateSurveyPIC(List<Apttus__APTS_Agreement__c> newList, Map<Id, Apttus__APTS_Agreement__c> oldMap){
        Set<Id> agrIdSet = new Set<Id>();
        List<Apttus__APTS_Agreement__c> agrExtList = new List<Apttus__APTS_Agreement__c>();
        Set<ID> oppIdSet = new Set<ID>();
        List<Update_Survey_Event__e> updateSurveyEventList_e = new List<Update_Survey_Event__e>();
        Update_Survey_Event__e updateSurveyEvent = null;
        
        for(Apttus__APTS_Agreement__c agr : newList) {
            if( ((agr.RecordTypeId == CON_CLM.PSA_RECORDTYPEID && (agr.Apttus__Subtype__c == 'Work Order' || agr.Apttus__Subtype__c =='Change Order' )) || ( agr.RecordTypeId == CON_CLM.RWLP_RECORDTYPEID && (agr.Apttus__Subtype__c =='Change Order' || agr.Apttus__Subtype__c == 'ATP' || agr.Apttus__Subtype__c == 'SUWO' || agr.Apttus__Subtype__c == 'Amendment')) ) && (Trigger.isInsert || (Trigger.isUpdate && agr.IQVIA_Project_Manager_Con__c != oldMap.get(agr.id).IQVIA_Project_Manager_Con__c)) && agr.IQVIA_Project_Manager_Con__c != null){//PSA
                agrIdSet.add(agr.Id);
            }
        }
        if(agrIdSet.size() > 0) {
            //Map<Id, Apttus__APTS_Agreement__c> agridToAgrMap = new SLT_APTS_Agreement(false, false).getAgreementsById(agrIdSet, new Set<String>{'Id', 'Apttus__Related_Opportunity__c', 'IQVIA_Project_Manager_Con__c'});
            for(Apttus__APTS_Agreement__c agr : newList) {
                if(!oppIdSet.contains(agr.Apttus__Related_Opportunity__c) && agrIdSet.contains(agr.Id)) {
                    oppIdSet.add(agr.Apttus__Related_Opportunity__c);
                    updateSurveyEvent = new Update_Survey_Event__e(Related_record_ID__c = agr.Id, Survey_PIC_ID__c = agr.IQVIA_Project_Manager_Con__c, Opportunity_ID__c = agr.Apttus__Related_Opportunity__c, Is_Insert__c = Trigger.isInsert);
                    updateSurveyEventList_e.add(updateSurveyEvent);
                }
            }
            if(updateSurveyEventList_e.size() > 0){
                EventBus.publish(updateSurveyEventList_e); 
            }
        }
    }
}