public class CNT_PSA_PSSF_PDF {
    public string pssfParentId {get; set;}
    public List<PSSF__c> pssfParentRecList{get;set;}
    public List<PSSF__c> relatedRecordListArrangedDataSource {get;set;}
    public List<PSSF__c> relatedRecordListArrangedHistoryChanges {get;set;}
    public string projectCode {get;set;}
    public string pssfVersion {get;set;}
    public string userName {get;set;}
    public datetime onDateTime {get;set;}
    public Map<string,string> nameMap {get;set;}
    public string fileName {get; set;}
    
    public CNT_PSA_PSSF_PDF(){
        pssfParentId = Apexpages.currentPage().getParameters().get('pssfParent');
        pssfParentRecList = new List<PSSF__c>();
        pssfParentRecList  = new SLT_PSSF().getPSSFById(new Set<Id>{pssfParentId}, new Set<String>{'Id','Account__r.name','Prepared_by_IQVIA_SM_Lead__r.name','Project__c','QCed_by_SM_QC_Reviewer__r.name','Date_QC_Completed__c','Reviewed_by_Medical_Safety_Advisor__r.name','Date_Medical_Review_Completed__c','Document_Name__c','MedDRA_version_used_in_current_PSSF__c','URL__c','PSSF_Effective_Date__c','PSSF_Version__c','CreatedBy.name','LastModifiedBy.name','LastModifiedDate','CreatedDate','LastModifiedDate','Owner.name'});
        if(pssfParentRecList.size()>0){
            projectCode = pssfParentRecList[0].Project__c;
            pssfVersion = pssfParentRecList[0].PSSF_Version__c;
            fileName = projectCode  +  '-' + pssfVersion;
        }
        userName = UserInfo.getName();
        onDateTime = datetime.now();
        
        List<PSSF__c> relatedRecordListDataSource= new List<PSSF__c>();
        relatedRecordListDataSource  = new SLT_PSSF().getPSSFByPSSFParentDataSource(new Set<Id>{pssfParentId}, new Set<String>{'Id','Name','In_Scope__c','Location_of_Data_Source__c','Data_Source_Contact_Point_if_Relevant__c','Frequency_Of_Review__c','Other_Frequency_specify__c','Focus__c','Other_specify__c'});
        
        Map<string,PSSF__c> nameToPSSFMap = new Map<string,PSSF__c>();
       	nameToPSSFMap.put('Company Safety Database',null);
        nameToPSSFMap.put('Clinical Trial Database',null);
        nameToPSSFMap.put('Literature',null);
        nameToPSSFMap.put('Health Authority Websites',null);
        nameToPSSFMap.put('Eudravigilance',null);
        nameToPSSFMap.put('FAERS',null);
        nameToPSSFMap.put('VAERS',null);
        nameToPSSFMap.put('Competitors RSI',null);
        nameToPSSFMap.put('Others1',null);
        nameToPSSFMap.put('Others2',null);
        nameToPSSFMap.put('Others3',null);
        nameToPSSFMap.put('Others4',null);
        nameMap = new Map<string,string>();
        for(PSSF__c pssfRec : relatedRecordListDataSource){
            nameToPSSFMap.put(pssfRec.name,pssfRec);
            if(pssfRec.name == 'Others1' || pssfRec.name == 'Others2' || pssfRec.name == 'Others3' || pssfRec.name == 'Others4'){
                nameMap.put(pssfRec.name,pssfRec.Other_specify__c);
            }
            else{
                nameMap.put(pssfRec.name,pssfRec.name);
            }
        }
        
        relatedRecordListArrangedDataSource= new List<PSSF__c>();
        for (string key : nameToPSSFMap.keySet()) {
            Pssf__c rec  =  nameToPSSFMap.get(key);
            if(rec != null){
                if(rec.name == 'Others1' || rec.name == 'Others2' || rec.name == 'Others3' || rec.name == 'Others4'){
                    if(rec.Other_specify__c != null){
                        relatedRecordListArrangedDataSource.add(nameToPSSFMap.get(key));
                    }
                }
                else{
                    relatedRecordListArrangedDataSource.add(nameToPSSFMap.get(key));
                }
            }
        }
             
        //History Of Changes
        List<PSSF__c> relatedRecordListHistoryChanges= new List<PSSF__c>();
        relatedRecordListHistoryChanges  = new SLT_PSSF().getPSSFByPSSFParentHistoryChanges(new Set<Id>{pssfParentId}, new Set<String>{'Id','Name','PSSF_Version_when_Implemented__c','Description_of_Changes_Specify_Sheet__c','Date_PSSF_Version__c'});
        
        Map<string,PSSF__c> historyNameToPSSFMap = new Map<string,PSSF__c>();
        historyNameToPSSFMap.put('History Record 0',null);
       	historyNameToPSSFMap.put('History Record 1',null);
        historyNameToPSSFMap.put('History Record 2',null);
        historyNameToPSSFMap.put('History Record 3',null);
        historyNameToPSSFMap.put('History Record 4',null);
        historyNameToPSSFMap.put('History Record 5',null);
        historyNameToPSSFMap.put('History Record 6',null);
        historyNameToPSSFMap.put('History Record 7',null);
        historyNameToPSSFMap.put('History Record 8',null);
        historyNameToPSSFMap.put('History Record 9',null);
        historyNameToPSSFMap.put('History Record 10',null);
        historyNameToPSSFMap.put('History Record 11',null);
        historyNameToPSSFMap.put('History Record 12',null);
        historyNameToPSSFMap.put('History Record 13',null);
        historyNameToPSSFMap.put('History Record 14',null);
        historyNameToPSSFMap.put('History Record 15',null);
        historyNameToPSSFMap.put('History Record 16',null);
        
        for(PSSF__c pssfRec : relatedRecordListHistoryChanges){
            historyNameToPSSFMap.put(pssfRec.name,pssfRec);
        }
        relatedRecordListArrangedHistoryChanges= new List<PSSF__c>();
        for (string key : historyNameToPSSFMap.keySet()) {
            Pssf__c rec  =  historyNameToPSSFMap.get(key);
            if(rec != null){
                if(rec.PSSF_Version_when_Implemented__c == null  && rec.Description_of_Changes_Specify_Sheet__c == null && rec.Date_PSSF_Version__c == null){
                    system.debug('record not be included' + rec.id);
                }
                else{
                    relatedRecordListArrangedHistoryChanges.add(historyNameToPSSFMap.get(key));
                }
            }
        }
    }
}