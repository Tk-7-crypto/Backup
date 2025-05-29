/**
* This is QC Tracker Result trigger handler class.
* version : 1.0
*/
public class DAOH_QC_Tracker_Result {
    
/**
* This method is used to populate Aggregate Report Field on QC Tracker Result when record is inserted or updated.
* @params List<QC_Tracker_Result__c> newList
* @return void
*/
    public static void populateAggregateReportFieldOnQCT(List<QC_Tracker_Result__c> newList,Map<Id, QC_Tracker_Result__c> oldMap) {
        Set<string> aggRepNameSet = new Set<String>();
        Map<String, Id> nameToAggregateReportIdMap = new Map<String,Id>();
        for(QC_Tracker_Result__c newQct : newList) {
            if(newQct.Name != null){
                aggRepNameSet.add(newQct.Name);
            }
        }
        nameToAggregateReportIdMap = new SLT_Aggregate_Report(false,false).selectAggregateReportsByName(aggRepNameSet, new Set<String>{'Id','Name'});
        for(QC_Tracker_Result__c newQct : newList) {
            if(trigger.isInsert || (trigger.isUpdate && newQct.Name != oldMap.get(newQct.Id).Name)) {
                if(newQct.Name != null && nameToAggregateReportIdMap.containsKey(newQct.Name) && nameToAggregateReportIdMap.get(newQct.Name) != null){
                    newQct.Aggregate_Report__c = nameToAggregateReportIdMap.get(newQct.Name);
                } 
            }  
        }  
    }
    
    public static void validateQCTonAggRep(List<QC_Tracker_Result__c> newList,Map<Id, QC_Tracker_Result__c> oldMap) {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        Set<Id> aggRepIdSet = new Set<Id>();
        Boolean qctInvalidChkBox = false;
        Map<Id, List<QC_Tracker_Result__c>> aggRepIdToQCTListMap = new Map<Id, List<QC_Tracker_Result__c>>();
        List<String> qcFormTypeList = new List<String>();
        List<String> qcRecToChkFormTypeList = new List<String>();
        Set<QC_Tracker_Result__c> chkDuplValSet = new Set<QC_Tracker_Result__c>();
        String aggRepType = '';
        List<QC_Tracker_Result__c> qctList = new List<QC_Tracker_Result__c>();
        List<Aggregate_Report__c> aggRepToUpdtList = new List<Aggregate_Report__c>();
        If(!mulesoftSetting.Ignore_Validation_Rules__c){
            for(QC_Tracker_Result__c newQct : newList) {
                if(newQct.Aggregate_Report__c != null){
                    aggRepIdSet.add(newQct.Aggregate_Report__c);
                }
            }
            String whereClause = 'Aggregate_Report__c IN :rltdAggRepId AND Date_Deleted__c = null AND Aggregate_Report__r.Status__c != \'Completed\' AND (Aggregate_Report__r.RecordType.Name = \'General Report\' OR Aggregate_Report__r.RecordType.Name = \'Takeda Report\')';
            aggRepIdToQCTListMap = new SLT_QC_Tracker(false,false).getActiveQCTrackerRecordsforAggReps(aggRepIdSet, new Set<String>{'Id','Name','REP_QC_Form_Type__c','Aggregate_Report__r.Report_Type__c'}, whereClause);
            if(aggRepIdToQCTListMap != null && aggRepIdToQCTListMap.size() > 0){
                for(Id aggRepId : aggRepIdToQCTListMap.keyset()){
                    qctList = aggRepIdToQCTListMap.get(aggRepId);
                    if(qctList != null && qctList.size() > 0){
                        aggRepType = qctList.get(0).Aggregate_Report__r.Report_Type__c;
                        if(aggRepType != null && aggRepType != ''){
                            qcFormTypeList = CON_PSA.aggRepValToQCFormTypeMap.get(aggRepType);
                            chkDuplValSet.addAll(qctList);
                            if(qcFormTypeList != null && qcFormTypeList.size() > 0){
                                System.debug(qcFormTypeList+ ' '+chkDuplValSet+ ' '+'qctList'+qctList );
                                if((qctList.size() != qcFormTypeList.size()) || (chkDuplValSet.size() < qcFormTypeList.size())){
                                    qctInvalidChkBox = true;
                                }else{
                                    for(QC_Tracker_Result__c qc : qctList){
                                        qcRecToChkFormTypeList.add(qc.REP_QC_Form_Type__c);
                                    }
                                    for(String formType : qcFormTypeList){
                                        if(qcRecToChkFormTypeList.size() > 0 && !qcRecToChkFormTypeList.contains(formType)){
                                            qctInvalidChkBox = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if(qctInvalidChkBox == true){
                        Aggregate_Report__c aggRepToUpdt = new Aggregate_Report__c(Id = aggRepId, Override__c = false, Override_done_by_system__c = false);
                        aggRepToUpdtList.add(aggRepToUpdt);
                    }else{
                        Aggregate_Report__c aggRepToUpdt = new Aggregate_Report__c(Id = aggRepId, Override__c = true, Override_done_by_system__c = true);
                        aggRepToUpdtList.add(aggRepToUpdt);
                    }
                }
            }
            if(aggRepToUpdtList != null && aggRepToUpdtList.size() > 0){
                update aggRepToUpdtList;
            }
        }
    }
    
    public static void validateQCTonSandozAggRep(List<QC_Tracker_Result__c> newList,Map<Id, QC_Tracker_Result__c> oldMap) {
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        Set<Id> aggRepIdSet = new Set<Id>();
        Boolean qctInvalidChkBox = false;
        Map<Id, List<QC_Tracker_Result__c>> aggRepIdToQCTListMap = new Map<Id, List<QC_Tracker_Result__c>>();
        List<String> qcFormTypeList = new List<String>();
        List<String> qcRecToChkFormTypeList = new List<String>();
        Set<QC_Tracker_Result__c> chkDuplValSet = new Set<QC_Tracker_Result__c>();
        String aggRepType = '';
        List<QC_Tracker_Result__c> qctList = new List<QC_Tracker_Result__c>();
        List<Aggregate_Report__c> aggRepToUpdtList = new List<Aggregate_Report__c>();
        If(!mulesoftSetting.Ignore_Validation_Rules__c){
            for(QC_Tracker_Result__c newQct : newList) {
                if(newQct.Aggregate_Report__c != null){
                    aggRepIdSet.add(newQct.Aggregate_Report__c);
                }
            }
            String whereClause = 'Aggregate_Report__c IN :rltdAggRepId AND Date_Deleted__c = null AND (Aggregate_Report__r.Status__c != \'Completed\' AND Aggregate_Report__r.RecordType.Name = \'Sandoz Report\')';
            aggRepIdToQCTListMap = new SLT_QC_Tracker(false,false).getActiveQCTrackerRecordsforAggReps(aggRepIdSet, new Set<String>{'Id','Name','REP_QC_Form_Type__c','Aggregate_Report__r.Report_Type__c'}, whereClause);
            if(aggRepIdToQCTListMap != null && aggRepIdToQCTListMap.size() > 0){
                for(Id aggRepId : aggRepIdToQCTListMap.keyset()){
                    qctList = aggRepIdToQCTListMap.get(aggRepId);
                    if(qctList != null && qctList.size() > 0){
                        aggRepType = qctList.get(0).Aggregate_Report__r.Report_Type__c;
                        if(aggRepType != null && aggRepType != ''){
                            qcFormTypeList = CON_PSA.aggRepValToQCFormTypeMapForSandoz.get(aggRepType);
                            chkDuplValSet.addAll(qctList);
                            if(qcFormTypeList != null && qcFormTypeList.size() > 0){
                                if((qctList.size() != qcFormTypeList.size()) || (chkDuplValSet.size() < qcFormTypeList.size())){
                                    qctInvalidChkBox = true;
                                }else{
                                    for(QC_Tracker_Result__c qc : qctList){
                                        qcRecToChkFormTypeList.add(qc.REP_QC_Form_Type__c);
                                    }
                                    for(String formType : qcFormTypeList){
                                        if(qcRecToChkFormTypeList.size() > 0 && !qcRecToChkFormTypeList.contains(formType)){
                                            qctInvalidChkBox = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if(qctInvalidChkBox == true){
                        Aggregate_Report__c aggRepToUpdt = new Aggregate_Report__c(Id = aggRepId, Override__c = false, Override_done_by_system__c = false);
                        aggRepToUpdtList.add(aggRepToUpdt);
                    }else{
                        Aggregate_Report__c aggRepToUpdt = new Aggregate_Report__c(Id = aggRepId, Override__c = true, Override_done_by_system__c = true);
                        aggRepToUpdtList.add(aggRepToUpdt);
                    }
                }
            }
            if(aggRepToUpdtList != null && aggRepToUpdtList.size() > 0){
                update aggRepToUpdtList;
            }
        }
    }
        
}
