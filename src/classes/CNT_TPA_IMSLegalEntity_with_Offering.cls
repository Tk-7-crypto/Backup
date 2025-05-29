public class CNT_TPA_IMSLegalEntity_with_Offering {
    transient public list<watchListWrapper> watchListWrapperList {get; set;}
    public Boolean showData { get; set; }
    public List<String> selectedCountries { get; set; }
    
    
    public static Map<String, String> BUWithLegalEntityNameMap{
        get {
            if(BUWithLegalEntityNameMap == null){
                BUWithLegalEntityNameMap = new Map<String, String> ();
        		for(IMS_Master_Legal_Entity__c legalEntity: [select Name, Name_for_ESign__c, IMS_Entity_Address__c from IMS_Master_Legal_Entity__c	]){
            		BUWithLegalEntityNameMap.put(legalEntity.Name, legalEntity.Name_for_ESign__c + '|::|' + legalEntity.IMS_Entity_Address__c);
        		}
            }
            return BUWithLegalEntityNameMap;
        }
        set;
    }
    
    
    public List<SelectOption> getCountryList()
    {
        List<SelectOption> options = new List<SelectOption>();

        options.add( new SelectOption( '', '--None--',true ));
        options.add( new SelectOption( 'All', 'All' ));

        Schema.DescribeFieldResult fieldResult = IMS_Data_Asset__c.BU__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }

        return options;
    }
    
    @remoteAction
    public static list<watchListWrapper> searchData(String lastRecordId,String countries)
    {
        list<watchListWrapper> watchListWrapperList = new list<watchListWrapper>();
        
        String query = 'Select Id,Asset_Name__c,BU__c, IMS_Legal_Entity__c, (select id,Secondary_Asset_Name__c from IMS_Secondary_Data_Assets__r WHERE Is_Active__c = true) from IMS_Data_Asset__c WHERE  Is_Active__c = true and Asset_Name__c != \'Other\' ';
        if(!countries.contains('All')){
            query += 'and BU__c in (';
            for(String country:countries.split(';')){
                query += '\''+ country +'\',';
            }
            query = query.substring(0,query.length()-1);
            query += ') ';
        }
        
        DateTime lastRecordCretedDateTime;
        if(lastRecordId != null){
            lastRecordCretedDateTime = [select createddate from IMS_Data_Asset__c where id =: lastRecordId limit 1][0].createddate;
        }
        if(lastRecordCretedDateTime != null || Test.isRunningTest()){
            query += ' and createddate >: lastRecordCretedDateTime ';
        }
        
        
        List<IMS_Data_Asset__c> offRecords = new List<IMS_Data_Asset__c>();
        offRecords = Database.query(query + 'order by CreatedDate Limit 1000');
        for(IMS_Data_Asset__c IMSAssetObj : offRecords){
            if(IMSAssetObj.IMS_Secondary_Data_Assets__r != null && IMSAssetObj.IMS_Secondary_Data_Assets__r.size() >0 ){
                for(IMS_Secondary_Data_Asset__c secOff :IMSAssetObj.IMS_Secondary_Data_Assets__r){
                    watchListWrapperList.add(new watchListWrapper(IMSAssetObj.Id , IMSAssetObj.BU__c, IMSAssetObj.Asset_Name__c, secOff.Secondary_Asset_Name__c, IMSAssetObj.IMS_Legal_Entity__c, BUWithLegalEntityNameMap.get(IMSAssetObj.IMS_Legal_Entity__c).substringBefore('|::|'), BUWithLegalEntityNameMap.get(IMSAssetObj.IMS_Legal_Entity__c).substringAfter('|::|')));
                }
            }
            else{
                watchListWrapperList.add(new watchListWrapper(IMSAssetObj.Id, IMSAssetObj.BU__c, IMSAssetObj.Asset_Name__c, '',  IMSAssetObj.IMS_Legal_Entity__c, BUWithLegalEntityNameMap.get(IMSAssetObj.IMS_Legal_Entity__c).substringBefore('|::|') ,BUWithLegalEntityNameMap.get(IMSAssetObj.IMS_Legal_Entity__c).substringAfter('|::|')));
            }
        }

        return watchListWrapperList;
    }
    
    public PageReference redirectToExport(){
        PageReference pr = new PageReference('/apex/VFP_TPA_Report_Export?type=LEwO&query='+getFullQuery());
        pr.setRedirect(true);
        return pr;
    }
    
    public String getFullQuery(){
        String query = 'Select Id,Asset_Name__c,BU__c, IMS_Legal_Entity__c, (select id,Secondary_Asset_Name__c from IMS_Secondary_Data_Assets__r WHERE Is_Active__c = true) from IMS_Data_Asset__c WHERE  Is_Active__c = true and Asset_Name__c != \'Other\' ';
        if(!selectedCountries.contains('All')){
            query += 'and BU__c in (';
            for(String country:selectedCountries){
	            if(country.contains('&')){
	                    country = country.replace('&', '%26');
	                }
                query += '\''+ country +'\',';
            }
            query = query.substring(0,query.length()-1);
            query += ') ';
        }
        return query;
    }
    
    
    public class watchListWrapper
    {
        public string Id {get; set;}
        public string offCountry {get; set;}
        public String priOffName {get; set;}
        public String SecOffName {get; set;}
        public string iqviaLegalName {get; set;}
        public string legalEntityUnder {get; set;}
        public string legalEntityAddress {get;set;}
        
        public watchListWrapper(string Id,string offCountry, string priOffName, string SecOffName, string iqviaLegalName, string legalEntityUnder, String legalEntityAddress)
        {
            this.Id = Id;
            this.offCountry = offCountry;
            this.priOffName = priOffName;
            this.SecOffName = SecOffName;
            this.iqviaLegalName = iqviaLegalName;
            this.legalEntityUnder = legalEntityUnder;
            this.legalEntityAddress = legalEntityAddress;
        }
    }
}