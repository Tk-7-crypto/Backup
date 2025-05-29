public class DAOH_CRM_Agreement_Extension {
    
    /**
     * This method is used to update Survey PIC on latest Client_Sat_Survey__c object
     * @params  List<Agreement_Extension__c> newList
     * @params  Map<Id, Agreement_Extension__c> oldMap
     * @return  void
     */
    public static void updateSurveyPIC(List<Agreement_Extension__c> newList, Map<Id, Agreement_Extension__c> oldMap){
        /*Set<Id> agrExtIdSet = new Set<Id>();
        List<Agreement_Extension__c> agrExtList = new List<Agreement_Extension__c>();
        Set<ID> oppIdSet = new Set<ID>();
        List<Update_Survey_Event__e> updateSurveyEventList_e = new List<Update_Survey_Event__e>();
        Update_Survey_Event__e updateSurveyEvent = null;
        
        for(Agreement_Extension__c agrExt : newList) {
            if((Trigger.isInsert || (Trigger.isUpdate && agrExt.IQVIA_Project_Manager_Con__c != oldMap.get(agrExt.id).IQVIA_Project_Manager_Con__c)) && agrExt.IQVIA_Project_Manager_Con__c != null){//PSA
                agrExtIdSet.add(agrExt.Id);
            }
        }
        if(agrExtIdSet.size() > 0){
            agrExtList = new SLT_Agreement_Extension(false, false).getAgreementExtByOpps(agrExtIdSet, null, new Set<String>{'IQVIA_Project_Manager_Con__c', 'Agreement__r.Apttus__Related_Opportunity__c'});
            for(Agreement_Extension__c agrExt : agrExtList) {
                if(!oppIdSet.contains(agrExt.Agreement__r.Apttus__Related_Opportunity__c)) {
                    oppIdSet.add(agrExt.Agreement__r.Apttus__Related_Opportunity__c);
                    updateSurveyEvent = new Update_Survey_Event__e(Related_record_ID__c = agrExt.Id, Survey_PIC_ID__c = agrExt.IQVIA_Project_Manager_Con__c, Opportunity_ID__c = agrExt.Agreement__r.Apttus__Related_Opportunity__c, Is_Insert__c = Trigger.isInsert);
                    updateSurveyEventList_e.add(updateSurveyEvent);
                }
            }
            if(updateSurveyEventList_e.size()>0){
                EventBus.publish(updateSurveyEventList_e); 
            }
        }*/
    }
}