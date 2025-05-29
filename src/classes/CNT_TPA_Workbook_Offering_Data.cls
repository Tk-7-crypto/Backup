public class CNT_TPA_Workbook_Offering_Data {
    transient public list<watchListWrapper> watchListWrapperList {get; set;}
    public Boolean showData { get; set; }
    public List<String> listCountries { get; set; }
    
    public CNT_TPA_Workbook_Offering_Data(){
        listCountries = new List<String>();
        String country = '';
        Schema.DescribeFieldResult fieldResult = IMS_Data_Asset__c.BU__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            country = f.getValue();
            country = country.replace('"', '\'');
            listCountries.add( country + '~');
        }
    }
    
    public static Map<String, String> BUWithTPProcessorNameMap{
        get {
            if(BUWithTPProcessorNameMap == null){
                BUWithTPProcessorNameMap = new Map<String, String> ();
                for(TPA_Region_Country__c regioncountry: [select TP_Processor__r.TP_Processor_Email__c, Country__c from TPA_Region_Country__c]){
            		BUWithTPProcessorNameMap.put(regioncountry.Country__c, regioncountry.TP_Processor__r.TP_Processor_Email__c);
        		}
            }
            return BUWithTPProcessorNameMap;
        }
        set;
    }
    
    public static Map<String, String> BUWithLegalEntityNameMap{
        get {
            if(BUWithLegalEntityNameMap == null){
                BUWithLegalEntityNameMap = new Map<String, String> ();
        		for(IMS_Master_Legal_Entity__c legalEntity: [select Name, Name_for_ESign__c from IMS_Master_Legal_Entity__c	]){
            		BUWithLegalEntityNameMap.put(legalEntity.Name, legalEntity.Name_for_ESign__c);
        		}
            }
            return BUWithLegalEntityNameMap;
        }
        set;
    }
    
    
    
    @remoteAction
    public static list<watchListWrapper> searchData(String lastRecordId,String countries)
    {
        list<watchListWrapper> watchListWrapperList = new list<watchListWrapper>();
        String query = 'Select Id,Asset_Name__c,BU__c, IMS_Legal_Entity__c, Is_Restricted_Data__c, (select id,Secondary_Asset_Name__c from IMS_Secondary_Data_Assets__r WHERE Is_Active__c = true) from IMS_Data_Asset__c WHERE  Is_Active__c = true and Asset_Name__c != \'Other\' ';
        if(!countries.contains('All')){
            query += 'and BU__c in (';
            for(String country:countries.split(';')){
                query += '\''+ country +'\',';
            }
            query = query.substring(0,query.length()-1);
            query += ') ';
        }
        system.debug(query.substring(240));
        DateTime lastRecordCretedDateTime;
        if(lastRecordId != null){
            lastRecordCretedDateTime = [select createddate from IMS_Data_Asset__c where id =: lastRecordId limit 1][0].createddate;
        }
        if(lastRecordCretedDateTime != null || Test.isRunningTest()){
            query += ' and createddate >: lastRecordCretedDateTime ';
        }
        
        
        List<IMS_Data_Asset__c> offRecords = new List<IMS_Data_Asset__c>();
        offRecords = Database.query(query + 'order by CreatedDate Limit 1000');
        system.debug(offRecords.size());
        for(IMS_Data_Asset__c IMSAssetObj : offRecords){
            if(IMSAssetObj.IMS_Secondary_Data_Assets__r != null && IMSAssetObj.IMS_Secondary_Data_Assets__r.size() >0 ){
                for(IMS_Secondary_Data_Asset__c secOff :IMSAssetObj.IMS_Secondary_Data_Assets__r){
                    watchListWrapperList.add(new watchListWrapper(IMSAssetObj.Id , IMSAssetObj.BU__c, IMSAssetObj.Asset_Name__c, secOff.Secondary_Asset_Name__c, BUWithLegalEntityNameMap.get(IMSAssetObj.IMS_Legal_Entity__c), IMSAssetObj.IMS_Legal_Entity__c, BUWithTPProcessorNameMap.get(IMSAssetObj.BU__c),IMSAssetObj.Is_Restricted_Data__c));
                }
            }
            else{
                watchListWrapperList.add(new watchListWrapper(IMSAssetObj.Id, IMSAssetObj.BU__c, IMSAssetObj.Asset_Name__c, '', BUWithLegalEntityNameMap.get(IMSAssetObj.IMS_Legal_Entity__c), IMSAssetObj.IMS_Legal_Entity__c, BUWithTPProcessorNameMap.get(IMSAssetObj.BU__c),IMSAssetObj.Is_Restricted_Data__c));
            }
        }

        return watchListWrapperList;
    }
    
    public PageReference redirectToExport(){
        String filteredCountries = Apexpages.currentPage().getParameters().get('filteredCountries');
        if(filteredCountries.contains('&')){
            filteredCountries = filteredCountries.replace('&', '%26');
        }
        PageReference pr = new PageReference('/apex/VFP_TPA_Report_Export?type=Workbook&query=' + filteredCountries);
        pr.setRedirect(true);
        return pr;
    }
    

    
    public class watchListWrapper
    {
        public string Id {get; set;}
        public string offCountry {get; set;}
        public String priOffName {get; set;}
        public String SecOffName {get; set;}
        public string iqviaLegalName {get; set;}
        public string legalEntityUnder {get; set;}
        public string TPProcessorEmail {get; set;}
        public boolean isResData {get; set;}
        
        public watchListWrapper(string Id,string offCountry, string priOffName, string SecOffName, string iqviaLegalName, string legalEntityUnder, string TPProcessorEmail, boolean isResData)
        {
            this.Id = Id;
            this.offCountry = offCountry;
            this.priOffName = priOffName;
            this.SecOffName = SecOffName;
            this.iqviaLegalName = iqviaLegalName;
            this.legalEntityUnder = legalEntityUnder;
            this.TPProcessorEmail = TPProcessorEmail;
            this.isResData = isResData;
        }
    }
}