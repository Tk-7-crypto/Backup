public class ContractChart {
    
    public List<selectOption> lstProducts {get;set;}
    public String contractStatus {get;set;}
    public List<String> contractType {get;set;}
    public String AccountId {get;set;}
    public String panelwidth {get;set;}
    public String ProductId {get;set;}
    public boolean showDataBlock{get;set;}
    public integer productSize {get;set;}
    public string selectedProducts {get;set;}
    public string strQuery {get;set;}
    public Map<Id,List<Agreement__c>> mapParentChildDetails {get;set;}
    public Map<Id,Agreement__c> mapAgreementList {get;set;}
    public List<ChartHierarchyDataWrapper> lstChartDataWrapper {get;set;}
    public boolean showSearchResults {get;set;}
    public date dataPeriodStart{get; set;}
    public date dataPeriodEnd{get; set;}
    public Contract_Management_Setting__c contractColorSettings{get;set;}
    public String AccountName{get;set;}
    public String RecordTypeName{get;set;}
    public Boolean isShowMessage{get;set;}
    public String JPAggRecordTypeId;
    public String JPMasterRecordTypeId;
    
    public ContractChart(ApexPages.StandardController controller) {
        lstProducts = new List<SelectOption>();
        contractType = new List<String>() ;
        mapParentChildDetails = new Map<Id,List<Agreement__c>>();
        showDataBlock = false;
        showSearchResults = false;
        productSize = lstProducts.size();
        contractStatus = '';
        isShowMessage = false;
        AccountId = Apexpages.currentPage().getParameters().get('accId');
        List<Account> accountList = new List<Account>([Select Name,RecordType.Name from Account where id =:AccountId]);
        Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
        String profileName = p.name;
        if(AccountId !=null){
            AccountName=accountList.get(0).Name;
            RecordTypeName=accountList.get(0).RecordType.Name;
            LoadProducts();
        }
        else {
            AccountId = '';
        }
        contractType.add('all') ;
        contractColorSettings = Contract_Management_Setting__c.getInstance();
        JPAggRecordTypeId = (contractColorSettings.Japan_Master_Agreement__c != null) ?contractColorSettings.Japan_Agreement__c:''; 
        JPMasterRecordTypeId =(contractColorSettings.Japan_Master_Agreement__c != null)?contractColorSettings.Japan_Master_Agreement__c:'';
    }

    public void AssignAccount() {
        AccountId = Apexpages.currentPage().getParameters().get('accId');
        LoadProducts();
    }
    
    public void LoadProducts() {   
        ProductId = '';
        set<Id> productIds = new set<Id>();
        lstProducts = new List<SelectOption>();
        
        for(Agreement_Line_item__c objAgreements : [select AgreementId__r.Account__r.Name,ProductId__r.Name,ProductId__r.id from Agreement_Line_item__c where AgreementId__r.Account__c =: accountId]) {
            if(objAgreements.ProductId__r != null) {
                if(!productIds.contains(objAgreements.ProductId__r.id)) {
                    productIds.add(objAgreements.ProductId__r.id);
                    lstProducts.add(new selectOption(objAgreements.ProductId__r.id,objAgreements.ProductId__r.name));
                }
            }
        }
        productSize = lstProducts.size();
    }
    
    public void searchResults() {
        panelwidth = Apexpages.currentPage().getParameters().get('panelwidth');
        
        if(String.isBlank(AccountName) || String.isBlank(accountId)) {
            ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.Error,  Label.Error_Msg_SelectAccount);
            ApexPages.addMessage(infoMsg);
            showDataBlock = false;
            return;
        }
        
        List<Agreement__c> lstAgreementData = new List<Agreement__c>();
        Map<Id, Agreement__c> mapAgreementData = new Map<Id, Agreement__c>();
        Boolean conStatus = Boolean.valueOf(contractStatus);
        String query;
        showSearchResults = true;
        showDataBlock = false;
        ProductId = ProductId.replace('[', '').replace(']', '').replace('--None--', '');
        selectedProducts = ProductId;

        if(contractType.size() > 1) {
            for(Integer i = 0; i < contractType.size(); i++) {
                if(contractType.get(i) == 'All') {
                    contractType.remove(i);
                    break;
                }
            }
        }
        
        query = 'Select CurrencyISOCode, Id, Name, Active__c, Contract_Start_Date__c, Parent_Agreement__c, Parent_Agreement__r.Parent_Agreement__c, '
            +'Status_Category__c, Account__c, FF_Agreement_Number__c, Attach_Number__c, Contract_Type__c, Agreement_Term__c, Total_Contract_Value__c, '
            +'(Select Id, CurrencyISOCode, Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c, Termination_Date__c, Attach_Number__c '
            +'From AgreementLineItems__r ';
        if(ProductId != '') {
            set<Id> lstProductId = new set<id>();
            for(string idValue : ProductId.split(',')) {
                if(idValue != '') {
                    lstProductId.add(ID.ValueOf(idvalue.trim()));
                }
            }
            query += 'where ProductId__r.id in:lstProductId order by ProductId__r.Name Asc) From Agreement__c where Account__c = :accountId and ';
        } else {
            query += 'Order By ProductId__r.Name ASC) From Agreement__c WHERE Account__c = :accountId and ';
        }
        if(contractStatus != 'All') {
            query += 'Active__c = :conStatus and ';
        }
        if(contractType != null && contractType.size() > 0 && contractType.get(0)!= 'All') {
            query += 'Contract_Type__c IN :contractType and ';
        }
        if(dataPeriodStart != null) {
            query += 'Company_Signed_Date__c >= :dataPeriodStart and ';
        } 
        if(dataPeriodEnd != null) {
            query += 'Company_Signed_Date__c <= : dataPeriodEnd  and ';
        }
        query += '(RecordTypeID = :JPAggRecordTypeId OR RecordTypeID = :JPMasterRecordTypeId) Order By Contract_Start_Date__c DESC, Name ASC';
        mapAgreementData = new Map<id,Agreement__c>((List<Agreement__c>)Database.query(query));
        lstAgreementData.addAll(mapAgreementData.values());
        
        UpdateParentAgreement(lstAgreementData, mapAgreementData.keySet());
            
        mapAgreementList =  new map<Id, Agreement__c>();
        mapParentChildDetails = new Map<Id, List<Agreement__c>>();
        lstChartDataWrapper = new List<ChartHierarchyDataWrapper>();
        for(Agreement__c  objAgr : lstAgreementData) {
            // Details:validation for too many script statements error
            // if(limits.getScriptStatements() > 180000) {
            //     ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.Error , 'Too many results, please refine search criteria.' );
            //     ApexPages.addMessage(infoMsg);
            //     return;
            // }
            mapAgreementList.put(objAgr.id, objAgr);
            if(ProductId != '') {
                if(!mapParentChildDetails.containsKey(objAgr.id)) {
                    mapParentChildDetails.put(objAgr.id, new List<Agreement__c>());
                }
                            
                if(objAgr.Parent_Agreement__c != null) {
                    if(!mapParentChildDetails.containsKey(objAgr.Parent_Agreement__c)) {
                        List<Agreement__c> lstTemp = new List<Agreement__c>();
                        lstTemp.Add(objAgr);
                        mapParentChildDetails.put(objAgr.Parent_Agreement__c, lstTemp);
                    } else {
                        List<Agreement__c> lstTemp = new List<Agreement__c>();
                        if(mapParentChildDetails.containsKey(objAgr.Parent_Agreement__c)) {
                            lstTemp = mapParentChildDetails.get(objAgr.Parent_Agreement__c);
                            lstTemp.Add(objAgr);
                        }
                        mapParentChildDetails.put(objAgr.Parent_Agreement__c, lstTemp);
                    }
                }
                Map<Id,List<Agreement__c>> mapParentChildDetailsTemp = new Map<Id,List<Agreement__c>>();
                mapParentChildDetailsTemp  = mapParentChildDetails.clone();
                for(Id aggrId : mapParentChildDetailsTemp.keyset()) {
                    List<Agreement__c> lstAgreements = new List<Agreement__c>();
                    lstAgreements =  mapParentChildDetailsTemp.get(aggrId);
                    if(lstAgreements.size() == 0  && mapAgreementList.get(aggrId).AgreementLineItems__r.size() == 0) {
                        mapParentChildDetails.remove(aggrId);
                    }
                }
                
                mapParentChildDetailsTemp  = mapParentChildDetails.clone();    
                for(Id aggrId : mapParentChildDetailsTemp.keyset()) {
                    List<Agreement__c> lstAgreements = new List<Agreement__c>();
                    List<Agreement__c> lstAgreementTemp = new List<Agreement__c>();
                    lstAgreements =  mapParentChildDetails.get(aggrId);
                    lstAgreementTemp = lstAgreements.clone();
                    integer lstCounter = 0;
                    for(Agreement__c objAggr : lstAgreements ) {
                        lstCounter ++;
                        if(!mapParentChildDetailsTemp.containsKey(objAggr.id)) {
                            lstAgreementTemp.remove(lstCounter-1);
                            lstCounter --;
                        }
                    }
                    if(mapAgreementList.containsKey(aggrId)) {
                        if(lstAgreementTemp.size() == 0 && mapAgreementList.get(aggrId).AgreementLineItems__r.size() == 0) {
                            mapParentChildDetails.remove(aggrId);
                        } else {
                            mapParentChildDetails.put(aggrId, lstAgreementTemp);
                        }
                    }
                }
            } else {
                if(!mapParentChildDetails.containsKey(objAgr.id)) {
                    mapParentChildDetails.put(objAgr.id, new List<Agreement__c>());
                }
                            
                if(objAgr.Parent_Agreement__c != null) {
                    if(!mapParentChildDetails.containsKey(objAgr.Parent_Agreement__c )) {
                        List<Agreement__c> lstTemp = new List<Agreement__c>();
                        lstTemp.Add(objAgr);
                        mapParentChildDetails.put(objAgr.Parent_Agreement__c, lstTemp);
                    } else {
                        List<Agreement__c> lstTemp = new List<Agreement__c>();
                        if(mapParentChildDetails.containsKey(objAgr.Parent_Agreement__c)) {
                            lstTemp = mapParentChildDetails.get(objAgr.Parent_Agreement__c);
                            lstTemp.Add(objAgr);                               
                        }
                        mapParentChildDetails.put(objAgr.Parent_Agreement__c, lstTemp);  
                    }
                }        
            }
        }   
        
        GenerateHierarchy(mapParentChildDetails,lstAgreementData);

        if(lstChartDataWrapper.size() > 0) {
            updatehasPreviousLevelSibling();
            showDataBlock = true;
        }
    }
    
    public void UpdateParentAgreement(List<Agreement__c> lstAgreements, set<Id> setFilteredAgreementIds) {
        Map<id,Agreement__c> mapAllAgreements = new Map<id,Agreement__c>([Select CurrencyISOCode,id,Name,Active__c,Contract_Start_Date__c,Parent_Agreement__c,Parent_Agreement__r.Parent_Agreement__c,Status_Category__c,Account__c,FF_Agreement_Number__c,Attach_Number__c,Contract_Type__c,Agreement_Term__c,Total_Contract_Value__c, (Select id,CurrencyISOCode,Net_Price__c, ProductId__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Termination_Date__c, Attach_Number__c From AgreementLineItems__r order by ProductId__r.Name Asc ) From Agreement__c where Account__c =: accountId order by Contract_Start_Date__c desc,Name asc]);//getAllAgreementsWithoutFilter();
        for(Agreement__c objAgr : lstAgreements) {
            objAgr.Parent_Agreement__c = getParent(objAgr, setFilteredAgreementIds, mapAllAgreements);
        }
    }
        
    public Id getParent(Agreement__c objAgreement, set<Id> setFilteredAgreementIds, Map<id,Agreement__c> mapAllAgreements) {
        if(objAgreement != null && objAgreement.Parent_Agreement__c != null) {
            if(setFilteredAgreementIds.contains(objAgreement.Parent_Agreement__c)) {
                return objAgreement.Parent_Agreement__c;
            } else {
                return getParent(mapAllAgreements.get(objAgreement.Parent_Agreement__c), setFilteredAgreementIds, mapAllAgreements);
            }
        } else {
            return null;
        }
    }
        
    public void GenerateHierarchy(Map<Id,List<Agreement__c>> mapData, List<Agreement__c> lstAgreementData) {
        lstChartDataWrapper = new List<ChartHierarchyDataWrapper>();
        for(Agreement__c  objAgr : lstAgreementData) { 
            if(mapAgreementList.containsKey(objAgr.id) && mapData.containsKey(objAgr.id)) {
                Agreement__c objAggrement = mapAgreementList.get(objAgr.id);
                if(objAggrement.Parent_Agreement__c == null) {
                    GetChildRecords(objAggrement.id, 0, mapData, 0, '', true, false,-1);            
                }
            }
        }
    }   
    
    public void GetChildRecords(Id agreementId,integer count,Map<Id,List<Agreement__c>> mapData, integer sibCount,string tdString,boolean flag, boolean hasSibling, integer parentIndex) {
        string prevString = '';
        count++;
        lstChartDataWrapper.add(new ChartHierarchyDataWrapper(mapAgreementList.get(agreementId), count, mapData, sibCount, tdString, hasSibling, parentIndex));
        integer siblingCount = 0;
        if(mapParentChildDetails.containsKey(agreementId)) {
            parentIndex = lstChartDataWrapper.size()-1;
            for(Agreement__c objAgreement : mapParentChildDetails.get(agreementId))
            {
                siblingCount = siblingCount + 1;
                boolean hasSib = false;
                if(mapParentChildDetails.get(agreementId).size() > siblingCount) {
                    hasSib = true;
                }
                getChildRecords(objAgreement.Id, count, mapParentChildDetails, siblingCount, tdString , true, hasSib, parentIndex);
            }
        }
    }
    
    public void ExporttoExcel() {
        String contType= '';
        for(String conType :contractType) {
            contType = contType + conType +',';                
        }
        if(contType.length() >0)
            contType = contType.substring(0,contType.length()-1 );
        
        string qryStr =  '?' + 'prodId=' + selectedProducts + '&startDate=' + dataPeriodStart + '&endDate=' + dataPeriodEnd + '&accId=' + accountId + '&status=' + contractStatus + '&type=' + contType;
        strQuery = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/apex/Contract_Chart_Excel' + qryStr;
    }

    public PageReference resetFilters() {           
        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(true);
        return pageRef; 
    } 

    public void updatehasPreviousLevelSibling() {
        for(ChartHierarchyDataWrapper obj: lstChartDataWrapper) {
            ChartHierarchyDataWrapper obj1 = obj;
            List<Boolean> tempList = new List<Boolean>();
            for(integer i=0;i<obj.levelOfAgreement-1;i++) {
                if(lstChartDataWrapper[obj1.parentIndex].hasSibling) {
                    tempList.add(true);
                } else {
                    tempList.add(false);
                }
                obj1 = lstChartDataWrapper[obj1.parentIndex];
            }

            for(Integer i = tempList.size() - 1; i >= 0; i--){
                obj.preLevelSibling.add(tempList[i]);
            }
        }
    }
    
    public class ChartHierarchyDataWrapper {
        public String AgreementName {get;set;}
        public String AgreementStatus {get;set;}
        public String AttachNumber {get;set;}
        public String ContractType {get;set;}
        public String AgreementTerm {get;set;}
        public String AgreementId {get;set;}
        public boolean hasChild {get;set;}
        public string tdStringData {get;set;}
        public string tdProductString {get;set;}
        public string AgreementNumber {get;set;}
        public date AgreementStartDate {get;set;}
        public string status {get;set;}
        public string bgColor {get;set;}
        public List<ChartLineItemDataWrapper> lstItems {get;set;} 
        public boolean IsLastNode{get;set;}
        public boolean hasParent {get;set;}
        public string ISOCode {get;set;}
        public Agreement__c objAgr{get;set;}
        public integer siblingcount{get;set;}
        public integer totalChild{get;set;}
        public Id parentId{get;set;}
        public boolean hasSibling{get;set;}
        public integer levelOfAgreement{get;set;}
        public integer parentIndex{get;set;}
        public List<boolean> preLevelSibling{get;set;}
        
        public ChartHierarchyDataWrapper(Agreement__c objAgreement, integer count,Map<Id,List<Agreement__c>> mapData,integer sibCount,string tdString,boolean hasSibling,integer parentIndex) {
            tdStringData = '';
            tdProductString ='';
            Contract_Management_Setting__c contractSettings = Contract_Management_Setting__c.getInstance();
            bgColor = contractSettings.Default_Node_Color__c; 
            lstItems = new List<ChartLineItemDataWrapper>();
            AgreementName = objAgreement.name;
            AgreementId = objAgreement.id;
            objAgr = new Agreement__c();
            preLevelSibling = new List<boolean>();
            objAgr = objAgreement;
            AgreementStatus = objAgreement.Status_Category__c;
            AttachNumber = objAgreement.Attach_Number__c;
            ContractType = objAgreement.Contract_Type__c;
            AgreementTerm = objAgreement.Agreement_Term__c;
            AgreementNumber = objAgreement.FF_Agreement_Number__c;
            AgreementStartDate = objAgreement.Contract_Start_Date__c;
            siblingcount = sibCount;
            totalChild = 0;
            parentId = objAgreement.Parent_Agreement__c;
            this.hasParent = true;
            this.hasSibling = hasSibling;
            this.parentIndex = parentIndex;
            this.levelOfAgreement = count;
            if(objAgreement.Total_Contract_Value__c != null) {
                ISOCode = objAgr.CurrencyISOCode;
            } else {
                ISOCode = '';
            }
                
            if(objAgreement.Active__c) {
                    status = 'Active';
            } else {
                status = 'InActive';
            }
            if(objAgreement.Contract_Type__c == 'Memorandum' || objAgreement.Contract_Type__c == 'Agreement' || objAgreement.Contract_Type__c == 'Order Form') {
                bgColor = contractSettings.Case1_Node_Color__c;
            } else if(objAgreement.Contract_Type__c == 'Third party access agreement' || objAgreement.Contract_Type__c == 'Co-promotion agreement' || objAgreement.Contract_Type__c == 'Non Disclosure Agreement' || objAgreement.Contract_Type__c == 'Personal information protection agreement' || objAgreement.Contract_Type__c == 'Other') {
                bgColor = contractSettings.Case2_Node_Color__c;
            } else if(objAgreement.Contract_Type__c == 'Information Service Agreement' || objAgreement.Contract_Type__c == 'Master Agreement of Consulting' || objAgreement.Contract_Type__c == 'Master Agreement of Services') {
                bgColor = contractSettings.Case3_Node_Color__c;
            }
            IsLastNode = false;
            hasChild = false;
            
            if(mapData.containsKey(objAgreement.Parent_Agreement__c)) {
                if(mapData.get(objAgreement.Parent_Agreement__c).size() == sibCount) {
                    IsLastNode = true;
                }
            }
                
            if(mapData.containsKey(objAgreement.id)) {
                if(mapData.get(objAgreement.id).size() > 0) {
                    totalChild = mapData.get(objAgreement.id).size();
                    hasChild = true;
                }
            }
            
            if(objAgreement.Parent_Agreement__c == null) {
                    hasParent = false ;
            }

            for(Agreement_Line_item__c objLI: objAgreement.AgreementLineItems__r) {
                lstItems.add(new ChartLineItemDataWrapper(objLI));
            }
            
            if(lstItems.size() > 0) {
                lstItems[objAgreement.AgreementLineItems__r.size() - 1].IsLastNode = true;
            }
        }
    }
        
    public class ChartLineItemDataWrapper {
        public string LineItemId {get;set;}
        public string ProductName {get;set;}
        public Agreement_Line_item__c objALI{get;set;} 
        public Date ContractEndDate {get;set;}
        public Date terminationDate {get;set;}
        public boolean IsLastNode {get;set;}
        public string ISOCode {get;set;}
        public boolean isActive {get;set;}
        public string attachNumber {get; set;}
        
        public ChartLineItemDataWrapper(Agreement_Line_item__c objLI) {
            isActive = false;
            LineItemId = objLI.id;
            ProductName = objLI.ProductId__r.Name;
            ContractEndDate = objLI.Contract_End_Date__c;
            terminationDate = objLI.Termination_Date__c;
            objALI = objLI;
            
            if(!string.isBlank(objLI.Attach_Number__c)) {
                attachNumber = objLI.Attach_Number__c;
            } else {
                attachNumber = '';
            }
            
            if((objLI.Termination_Date__c == null && objLI.Contract_End_Date__c == null) || (objLI.Termination_Date__c == null && objLI.Contract_End_Date__c >= Date.today())) {
                isActive = true;  
            } else if( objLI.Termination_Date__c != null && objLI.Termination_Date__c >= Date.today()) {
                isActive = true;        
            }
            
            if(objLI.Net_Price__c != null) {
                ISOCode = objLI.CurrencyISOCode;
            } else {
                ISOCode = '';
            }
            IsLastNode = false;
        }
    }
}