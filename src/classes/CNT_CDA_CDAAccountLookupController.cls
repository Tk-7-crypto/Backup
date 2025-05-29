public class CNT_CDA_CDAAccountLookupController {

    public string recipientAccountName{get;set;}
    public Boolean idsearchPerformed{get;set;}
    public Boolean isRecipientAccountFound{get;set;}
    public Integer noOfRecords{get; set;}
    public Integer size {get;set;}
    public string entityType{get;set;}
    public CDA_Account__c cdaAccountRecords{get;set;}
    public QI_Legal_Entity__c qiLegalEntityRecord{get;set;}
    public CDA_Approved_Governing_Law_Location__c governingLawRecord{get;set;}  //Added by Vikram Singh under CR-11576
    public string businessArea {get;set;}   //Added by Vikram Singh under CR-11576

    public String sortField {
        get {
            if(sortField == null) {
                sortField = 'Name';
            }
            return sortField;
        }
        set;
    }

    public String sortDir {
        get {
            if(sortDir == null) {
                sortDir = 'asc';
            }
            return sortDir;
        }
        set;
    }

    private Integer MAX_RECORDLIMIT {get;set;}

    //Constructor
    public CNT_CDA_CDAAccountLookupController() {
        MAX_RECORDLIMIT = 5000;
        recipientAccountName = ApexPages.currentPage().getparameters().get('value') == null ? '': ApexPages.currentPage().getparameters().get('value');
        entityType = ApexPages.currentPage().getparameters().get('entityType') == null ? '': ApexPages.currentPage().getparameters().get('entityType');
        businessArea = ApexPages.currentPage().getparameters().get('businessArea') == null ? '': ApexPages.currentPage().getparameters().get('businessArea');   //Added by Vikram Singh under CR-11576
        if(entityType == UTL_CDAUtility.LEGAL_ENTITY_QI){   //Updated by Vikram Singh under CR-11576
            qiLegalEntityRecord = new QI_Legal_Entity__c();
        } else if(entityType == UTL_CDAUtility.GOVERNING_LAW){    //Added by Vikram Singh under CR-11576
            governingLawRecord = new CDA_Approved_Governing_Law_Location__c();   //Added by Vikram Singh under CR-11576
        } else {    //Updated by Vikram Singh under CR-11576
            cdaAccountRecords = new CDA_Account__c();
        }
        runQuery();
    }

    //Public methods

    public List<SelectOption> getRecordsPerPage() {
        List<SelectOption> recordsPerPag = new List<SelectOption>();
        recordsPerPag.add(new SelectOption('10','10'));
        recordsPerPag.add(new SelectOption('20','20'));
        recordsPerPag.add(new SelectOption('50','50'));
        recordsPerPag.add(new SelectOption('100','100'));
        recordsPerPag.add(new SelectOption('200','200'));
        return recordsPerPag;
    }

    //Updated by Vikram Singh under CR-11576 Start
    public string getQuery() {
        string query = '';
        string queryCondition = '';
        if(entityType == UTL_CDAUtility.LEGAL_ENTITY_QI) {//Updated by Vikram Singh under CR-11576
            query = 'Select Name, IQVIA_Business_Area__c, Location_of_Governing_Law__c, Location_of_Governing_Law__r.Name, Court_of_Jurisdiction__c, QI_Legal_Entity_Address__c FROM QI_Legal_Entity__c';  //Updated by Vikram Singh under CR-11576, CR-12167
            if(businessArea != null && businessArea.trim().length() > 0) {  //Added by Vikram Singh under CR-11576
                queryCondition = ' WHERE IQVIA_Business_Area__c = \''+businessArea+'\'';    //Added by Vikram Singh under CR-11576

                if(recipientAccountName != null && recipientAccountName.trim().length() > 0) {
                    queryCondition += ' AND Name LIKE \'%'+recipientAccountName+'%\'';   //Updated by Vikram Singh under CR-11576
                }
            }   //Added by Vikram Singh under CR-11576
            noOfRecords = Database.countquery('Select count() from QI_Legal_Entity__c'+queryCondition);
            //Added by Vikram Singh under CR-11576 Start
        } else if(entityType == UTL_CDAUtility.GOVERNING_LAW) {
            query = 'Select Name, Court_of_Jurisdiction__c FROM CDA_Approved_Governing_Law_Location__c';
            if(recipientAccountName != null && recipientAccountName.trim().length() > 0) {
                queryCondition = ' WHERE Name LIKE \''+recipientAccountName+'%\'';  // Updated by Ajinkya pande Under Item #1005
            }
            noOfRecords = Database.countquery('Select count() from CDA_Approved_Governing_Law_Location__c'+queryCondition);
            //Added by Vikram Singh under CR-11576 End
        } else {    //Updated by Vikram Singh under CR-11576
            noOfRecords = Database.countquery('Select count() from CDA_Account__c'+queryCondition);
            query = 'Select Name, Complete_Address__c ,Competitor_flag__c FROM CDA_Account__c';
            if(recipientAccountName != null && recipientAccountName.trim().length() > 0) {
                queryCondition = ' WHERE Name LIKE \'%'+recipientAccountName+'%\'';
            }
            noOfRecords = Database.countquery('Select count() from QI_Legal_Entity__c'+queryCondition);
        }
        query += queryCondition;
        return query;
    }
    //Updated by Vikram Singh under CR-11576 End

    public PageReference runQuery() {
       setCon = null;
       idsearchPerformed=true;
       return null;
   }

   public List<CDA_Account__c> getCDAAccounts() {
        List<CDA_Account__c> cdaAccounts = new List<CDA_Account__c>();
        for(CDA_Account__c account : (List<CDA_Account__c>)setCon.getRecords()) {
            cdaAccounts.add(account);
        }
        return cdaAccounts;
    }


    public List<QI_Legal_Entity__c> getQILegalEntity() {
        List<QI_Legal_Entity__c> qiRecords = new List<QI_Legal_Entity__c>();
        for(QI_Legal_Entity__c account : (List<QI_Legal_Entity__c>)setCon.getRecords()) {
            qiRecords.add(account);
        }
        return qiRecords;
    }

    //Added by Vikram Singh under CR-11576 Start
    public List<CDA_Approved_Governing_Law_Location__c> getGoverningLaw() {
        List<CDA_Approved_Governing_Law_Location__c> glRecords = new List<CDA_Approved_Governing_Law_Location__c>();
        for(CDA_Approved_Governing_Law_Location__c account : (List<CDA_Approved_Governing_Law_Location__c>)setCon.getRecords()) {
            glRecords.add(account);
        }
        return glRecords;
    }
    //Added by Vikram Singh under CR-11576 End

    public void clearSearch() {
        recipientAccountName = '';
        if(entityType == UTL_CDAUtility.LEGAL_ENTITY_QI) {  //Updated by Vikram Singh under CR-11576
            qiLegalEntityRecord = new QI_Legal_Entity__c();
        } else if(entityType == UTL_CDAUtility.GOVERNING_LAW) { //Added by Vikram Singh under CR-11576
            governingLawRecord = new CDA_Approved_Governing_Law_Location__c();  //Added by Vikram Singh under CR-11576
        } else {    //Updated by Vikram Singh under CR-11576
            cdaAccountRecords = new CDA_Account__c();
        }
    }

    public void toggleSort() {
        // simply toggle the direction
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        setCon = null;
    }

    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                if(size == null) {
                    size = 10;
                }
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(getQuery()+' order by ' + sortField +' ' + sortDir+' limit '+ MAX_RECORDLIMIT));

                setCon.setPageSize(size);
            }
            return setCon;
        }set;
    }

    //Updated by Vikram Singh under CR-11576 Start
    public pageReference refresh() {
        setCon = null;
        if(entityType == UTL_CDAUtility.LEGAL_ENTITY_QI) {  //Updated by Vikram Singh under CR-11576
            getQILegalEntity();
        } else if(entityType == UTL_CDAUtility.GOVERNING_LAW) { //Added by Vikram Singh under CR-11576
            getGoverningLaw();  //Added by Vikram Singh under CR-11576
        } else {    //Updated by Vikram Singh under CR-11576
            getCDAAccounts();
        }
        setCon.setPageNumber(1);
        return null;
    }
    //Updated by Vikram Singh under CR-11576 End
}