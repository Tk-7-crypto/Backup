public class CNT_CSM_CaseHierarchy {
@AuraEnabled
    public static List<HierarchyData> findHierarchyData(string recId){
        List<HierarchyData> returnValue = new List<HierarchyData>();
        List<String> caseSource = new List<String>{};
        if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)) {
            caseSource.add('Customer');
        }else{
            caseSource = null;
        }
        List<String> currentParent = new List<String>{};
        Integer level = 0;
        Boolean endOfStructure = false;
        string topMostparent = GetUltimateParentId(recId);
        currentParent.add(topMostparent);
        List<sObject> queryOutput = new List<sObject>();
        while ( !endOfStructure ){
            try{
                if(Limits.getLimitQueries()-Limits.getQueries()>0){
                    if( level == 0 ){
                        queryOutput = new SLT_Case().getCaseListHierarchy('Id', currentParent, caseSource);
                    } 
                    else {
                        queryOutput = new SLT_Case().getCaseListHierarchy('ParentId', currentParent, caseSource);
                    }
                }else{
                    endOfStructure = true;
                }
                
            }catch(exception ex){ 
                endOfStructure = true;
            }
            
            if( queryOutput.size() == 0 ){
                endOfStructure = true;
            }
            else{
                currentParent.clear();
                for ( Integer i = 0 ; i < queryOutput.size(); i++ ){
                    sobject sb= queryOutput[i];
                    currentParent.add(string.valueof(sb.get('id')) );
                    HierarchyData ss = new HierarchyData();
                    if(sb.get('Id') == recId || level == 0){
                        ss.expanded = true;
                    }else{
                        ss.expanded = false;
                    }
                    ss.rec = sb;
                    returnValue.add(ss);
                 }
            }
            level++;
        }
        return returnValue;
    }
    
    public static String GetUltimateParentId( string recId){
        Boolean top = false;
        while ( !top ) {
            Case record = new SLT_Case().getParentCaseHierarchy(recId);
            if(record !=null){
                if ( record.get('ParentId') != null ) {
                    recId = string.valueof(record.get('ParentId'));
                }else {
                    top = true;
                }    
            }
            else{
                top = true;
            }
        }
        return recId ;
    }

    @AuraEnabled
    public static Boolean showMassEditActivityButton(String recordId){
        Boolean isShowActivityEditButton = false;
        Map<Id, Case> childCaseMap;
        Set<Id> caseIdSet = new Set<Id>();
        List<Case> caseList = new SLT_Case().selectByCaseIdList(new Set<Id>{recordId}, new Set<String>{'Id', 'ParentId', 'RecordTypeName__c', 'Status'});
        Case caseRecord = (caseList != null && caseList.size() > 0) ? caseList[0] : null;
        if(caseRecord != null && (caseRecord.RecordTypeName__c == CON_CSM.S_RDCASE || caseRecord.RecordTypeName__c == CON_CSM.S_ACTIVITY_R_T) && caseRecord.Status != CON_CSM.S_CLOSED) {
            if (caseRecord.ParentId == null) {
                List<Activity__c> parentActivities = new SLT_ActivityC().selectActivityByCaseId(new Set<Id>{recordId}, new Set<String>{'Id'});
                if(parentActivities != null && parentActivities.size() > 0) {
                    isShowActivityEditButton = true;
                } 
                else {
                    childCaseMap = new Map<Id, Case>(new SLT_Case().getCaseListHierarchy('ParentId', new List<String>{recordId}, null));
                    if(childCaseMap != null && !childCaseMap.isEmpty() && childCaseMap.size() > 0) {
                        caseIdSet.addAll(childCaseMap.keySet());
                    }
                    if(!caseIdSet.isEmpty()) {
                        List<Activity__c> relatedActivities = new SLT_ActivityC().selectActivityByCaseId(caseIdSet, new Set<String>{'Id'});
                        if(relatedActivities != null && relatedActivities.size() > 0) {
                            isShowActivityEditButton = true;
                        }
                    }
                }    
            }
        }
        return isShowActivityEditButton;
    }
    
    public class HierarchyData{
        @AuraEnabled
        public sObject rec{get;set;}
        @AuraEnabled
        public boolean expanded{get;set;}
        public HierarchyData(){
            expanded = false;
        }
    }
}