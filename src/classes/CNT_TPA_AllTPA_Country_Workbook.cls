public class CNT_TPA_AllTPA_Country_Workbook {
    transient public list<watchListWrapper> watchListWrapperList {get; set;}
    public List<String> listCountries { get; set; }
    public Set<String> listOfProcessorName { get; set; }
    
    public CNT_TPA_AllTPA_Country_Workbook(){
        listCountries = new List<String>();
        listCountries.add('All' + '~');
        String country = '';
        Schema.DescribeFieldResult fieldResult = IMS_Data_Asset__c.BU__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            country = f.getValue();
            country = country.replace('"', '\\"');
            listCountries.add( country + '~');
        }
        listOfProcessorName = new Set<String>();
        for(String name: BUWithTPProcessorNameMap.values()){
            listOfProcessorName.add(name.replace('"','\\"') + '~');
        }
    }
    public CNT_TPA_AllTPA_Country_Workbook(CNT_TPA_Report_Export cntReportExport){
        
    }
    
    public static Map<String, String> BUWithTPProcessorNameMap{
        get {
            if(BUWithTPProcessorNameMap == null){
                BUWithTPProcessorNameMap = new Map<String, String> ();
                for(TPA_Region_Country__c regioncountry: [select TP_Processor__r.TP_Processor_Name__c, Country__c from TPA_Region_Country__c]){
                    BUWithTPProcessorNameMap.put(regioncountry.Country__c,  regioncountry.TP_Processor__r.TP_Processor_Name__c);
                }
            }
            return BUWithTPProcessorNameMap;
        }
        set;
    }

    public static Map<String, IMS_Master_Legal_Entity__c> legalEntityNameWithDetails{
        get {
            if(legalEntityNameWithDetails == null){
                legalEntityNameWithDetails = new Map<String, IMS_Master_Legal_Entity__c> ();
                for(IMS_Master_Legal_Entity__c lglEntity: [Select Name,IMS_Entity_Address__c,Name_for_ESign__c From IMS_Master_Legal_Entity__c]){
                    legalEntityNameWithDetails.put(lglEntity.Name, lglEntity);
                }
            }
            return legalEntityNameWithDetails;
        }
        set;
    }
    
    @remoteAction
    public static list<watchListWrapper> searchData(String lastRecordId,String countriesAndProcessors)
    {
        list<watchListWrapper> watchListWrapperList = new list<watchListWrapper>();
        List<String> tempList = new List<String>();
        if(countriesAndProcessors != null && countriesAndProcessors != ''){
            tempList = countriesAndProcessors.split(':');
        }
        Set<String> processorNames = new Set<String>();
        if(tempList != null && tempList.size() > 1 && tempList[1] != ''){
            for(String name: tempList[1].split(';')){
                processorNames.add(name);
            }
        }
        String query = 'select BU__c, Geo_Level__c, Asset_Name__c,  IMS_Legal_Name__c, IMS_Legal_Entity__c, Commercial_Manager_Name__c, Commercial_Owner_Email__c,Secondary_Commercial_Reviewer_Name__c, Secondary_Commercial_Reviewer_Email__c, Needs_license_or_data_supplier_response__c, Is_AMA_Required__c, Requires_Fee__c, Requires_Manual_Review__c, Additional_Data_Protection_Terms__c,  Additional_Terms_Required__c,(select Secondary_Asset_Name__c, Commercial_Manager_Email__c, Commercial_Manager_Name__c, Need_license_or_data_supplier_permission__c, Is_AMA_Required__c, Requires_Manual_Review__c, Primary_Data_Asset__r.BU__c ,Secondary_Commercial_Reviewer_Name__c, Secondary_Commercial_Reviewer_Email__c, Additional_Terms_Required__c from IMS_Secondary_Data_Assets__r where Is_Active__c = true ) from IMS_Data_Asset__c where asset_name__c != \'Other\' AND is_Active__c = true '; 
        if ((tempList != null && tempList.size() > 0)&&(tempList[0] != null && tempList[0].length() == 0 || String.isEmpty(tempList[0]) || String.isBlank(tempList[0])) && (tempList[1] != null && tempList[1].length() > 0 && !String.isEmpty(tempList[1]) && !String.isBlank(tempList[1]))) {


            List<TPA_Region_Country__c> tpaRegionList = [select TP_Processor__r.TP_Processor_Name__c, Country__c from TPA_Region_Country__c where TP_Processor__r.TP_Processor_Name__c IN :processorNames ];

            if (tpaRegionList.size() > 0) {
                query += 'and BU__c in (';
                for(TPA_Region_Country__c tpaRegion : tpaRegionList){
                    query += '\''+ String.escapeSingleQuotes(tpaRegion.Country__c) +'\',';
                }
                query = query.substring(0,query.length()-1);
                query += ') ';
            }
        }else {
              if(tempList != null && tempList.size() > 0 && !tempList[0].contains('All')){
                query += 'and BU__c in (';
                for(String country:tempList[0].split(';')){
                    query += '\''+ String.escapeSingleQuotes(country) +'\',';
                }
                query = query.substring(0,query.length()-1);
                query += ') ';
            }
        }
       
        DateTime lastRecordCretedDateTime;
        if(lastRecordId != null){
            lastRecordCretedDateTime = [select createddate from IMS_Data_Asset__c where id =: lastRecordId limit 1][0].createddate;
        }
        if(lastRecordCretedDateTime != null || Test.isRunningTest()){
            query += ' and createddate >: lastRecordCretedDateTime ';
        }
        List<IMS_Data_Asset__c> offRecords = new List<IMS_Data_Asset__c>();
        offRecords = Database.query(query + 'order by CreatedDate Limit 2000');
        for(IMS_Data_Asset__c IMSAssetObj : offRecords){
            if(processorNames.size() > 0 && (BUWithTPProcessorNameMap.get(IMSAssetObj.BU__c) == null || !processorNames.contains(BUWithTPProcessorNameMap.get(IMSAssetObj.BU__c)))){
                continue;
            }
            if(IMSAssetObj.IMS_Secondary_Data_Assets__r != null && IMSAssetObj.IMS_Secondary_Data_Assets__r.size() >0 ){
                for(IMS_Secondary_Data_Asset__c secOff :IMSAssetObj.IMS_Secondary_Data_Assets__r){
                    watchListWrapperList.add(new watchListWrapper(IMSAssetObj,secOff,BUWithTPProcessorNameMap.get(IMSAssetObj.BU__c),getAdditionalTerms(null,secOff),legalEntityNameWithDetails.get(IMSAssetObj.IMS_Legal_Entity__c),getHoverDescription(secOff.Secondary_Asset_Name__c,IMSAssetObj.BU__c)));
                    //watchListWrapperList.add(new watchListWrapper(IMSAssetObj.BU__c, IMSAssetObj.Geo_Level__c , secOff.Commercial_Manager_Name__c, secOff.Commercial_Manager_Email__c, IMSAssetObj.Asset_Name__c, secOff.Secondary_Asset_Name__c, IMSAssetObj.IMS_Legal_Name__c, IMSAssetObj.IMS_Legal_Entity__c, BUWithTPProcessorNameMap.get(IMSAssetObj.BU__c), secOff.Additional_Terms_Required__c , secOff.Requires_Manual_Review__c, IMSAssetObj.Requires_Fee__c, secOff.Is_AMA_Required__c, IMSAssetObj.Additional_Data_Protection_Terms__c, secOff.Need_license_or_data_supplier_permission__c == 'Yes'? true : false ,getAdditionalTerms(null,secOff)));
                }
            }
            else{
                watchListWrapperList.add(new watchListWrapper(IMSAssetObj,null,BUWithTPProcessorNameMap.get(IMSAssetObj.BU__c),getAdditionalTerms(IMSAssetObj,null),legalEntityNameWithDetails.get(IMSAssetObj.IMS_Legal_Entity__c),getHoverDescription(IMSAssetObj.Asset_Name__c,IMSAssetObj.BU__c)));
                //watchListWrapperList.add(new watchListWrapper(IMSAssetObj.BU__c, IMSAssetObj.Geo_Level__c, IMSAssetObj.Commercial_Manager_Name__c, IMSAssetObj.Commercial_Owner_Email__c, IMSAssetObj.Asset_Name__c, '', IMSAssetObj.IMS_Legal_Name__c, IMSAssetObj.IMS_Legal_Entity__c, BUWithTPProcessorNameMap.get(IMSAssetObj.BU__c),IMSAssetObj.Additional_Terms_Required__c, IMSAssetObj.Requires_Manual_Review__c, IMSAssetObj.Requires_Fee__c, IMSAssetObj.Is_AMA_Required__c, IMSAssetObj.Additional_Data_Protection_Terms__c, IMSAssetObj.Needs_license_or_data_supplier_response__c == 'Yes'? true : false ,getAdditionalTerms(IMSAssetObj,null)));
            }
        }
        return watchListWrapperList;
    }

    public static Set<String> setPromoOffering = new Set<String>(Label.Promotrack_Offerings.split(';'));        
    public static String globalPTOffering = Label.TPA_Global_Promotrak_Offerings;
    public static Set<String> setDDDOffering = new Set<String>(Label.TPA_DDD_Offering.split(';'));
    public static Map<String,String> AdditionalTermMap;

    public static void populateAdditionalTermMap(){
        if(AdditionalTermMap == null){
            AdditionalTermMap = new Map<String,String>();
            for(TPA_Text_Editor__c tpaText:[Select Page_Name__c,English_Translation__c From TPA_Text_Editor__c where Page_Type__c in ('IMS_Legal_Entity__c','Hover Descriptions')]){
                AdditionalTermMap.put(tpaText.Page_Name__c,tpaText.English_Translation__c);
            }
        }
        return;
    }

    public static String getHoverDescription(String assetName,String bu){
        populateAdditionalTermMap();
        if(assetName != null && assetName.contains('Medpages Data') ){
            return AdditionalTermMap.get('Medpages Data');
        }
        else if(assetName != null && assetName.contains('Medpages Pro Search') ){
            return AdditionalTermMap.get('Medpages Pro Search');
        }
        else if(bu == 'South Africa'){
            return AdditionalTermMap.get(assetName+'~'+bu);
        }
        if(AdditionalTermMap.containsKey(assetName)){
            return AdditionalTermMap.get(assetName);
        }
        return '';
    }

    public static String getAdditionalTerms(IMS_Data_Asset__c imsDa,IMS_Secondary_Data_Asset__c imsSecDa){

        String additionalTerms = '';
        populateAdditionalTermMap();
        if(imsDa != null){
            if(imsDa.BU__c == 'United States' && imsDa.Asset_Name__c == 'Ambulatory electronic medical records data') {
                additionalTerms += AdditionalTermMap.get('Is_Ambulatory_EMR__c') + ' ; ';
            }
            else if(imsDa.BU__c == 'South Africa' && imsDa.Geo_Level__c == 'Sub-National') {
                additionalTerms += AdditionalTermMap.get('Is_South_Africa_Sub_Off__c') + ' ; ';
            }
            else if(imsDa.BU__c == 'South Africa' && imsDa.Asset_Name__c == 'IQVIA Consumer Aisle') {
                additionalTerms += AdditionalTermMap.get('is_South_Africa_Consumer_Health__c') + ' ; ';
            }
            else if(imsDa.Asset_Name__c == 'MIDAS') {
                additionalTerms += AdditionalTermMap.get('is_Midas__c') + ' ; ';
            }
            else if(imsDa.BU__c == 'United States' && imsDa.Asset_Name__c == 'Patient Companion File (PatCo) - Formerly Patient Reference File') {
                additionalTerms += AdditionalTermMap.get('is_Patient_Companion_File__c') + ' ; ';
            }
            else if(imsDa.BU__c == 'United States' && imsDa.Asset_Name__c.indexOf('Provider Companion File') != -1 ) {
                additionalTerms += AdditionalTermMap.get('is_Provider_Companion_File__c') + ' ; ';
            }
            else if(imsDa.Asset_Name__c == 'Patient Reference File') {
                additionalTerms += AdditionalTermMap.get('is_Patient_Reference_File__c') + ' ; ';
            } 
            else if(imsDa.Asset_Name__c == 'GE Centricity EMR') {
                additionalTerms += AdditionalTermMap.get('is_GE_Centricity_EMR__c') + ' ; ';
            } 
            else if(setPromoOffering.contains( imsDa.Asset_Name__c ) ) {
                additionalTerms += AdditionalTermMap.get('is_Promotrak__c') + ' ; ';
            } 
            else if((imsDa.Asset_Name__c == 'Managed Care Workbook - New View' || imsDa.Asset_Name__c == 'Managed Care Workbook - PBM Plans' ) && imsDa.BU__c == 'United States') {
                additionalTerms += AdditionalTermMap.get('is_Managed_Workbook__c') + ' ; ';
            } 
            else if(globalPTOffering.equalsIgnoreCase( imsDa.Asset_Name__c)  && imsDa.BU__c == 'Global') {
                additionalTerms += AdditionalTermMap.get('Is_Glbl_PromoTrack_Selected__c') + ' ; ';
            } 
            else if(imsDa.BU__c == 'United States' && imsDa.Asset_Name__c == 'PharMetrics® Plus (Health Plan Claims)') {
                additionalTerms += AdditionalTermMap.get('IS_Health_Plan_Claims__c') + ' ; ';
            } 
            else if(imsDa.BU__c == 'United States' && imsDa.Asset_Name__c.indexOf('Payer Companion File') != -1) {
                additionalTerms += AdditionalTermMap.get('is_Payer_Companion_File__c') + ' ; ';
            }
            else if(imsDa.Asset_Name__c == 'LAAD - Longitudinal Access and Adjudication Data') {
                additionalTerms += AdditionalTermMap.get('is_LAAD_Offering__c') + ' ; ';
            }
            else if(imsDa.BU__c == 'United States' && imsDa.Asset_Name__c == 'Oncology electronic medical records data') {
                additionalTerms += AdditionalTermMap.get('Is_Oncology_EMR__c') + ' ; ';
            }
            else if((imsDa.Asset_Name__c == 'Xponent' || imsDa.Asset_Name__c == 'OneKey Emails' || imsDa.Asset_Name__c == 'OneKey Organizations (formerly HCOS)' || imsDa.Asset_Name__c == 'OneKey Professionals (formerly HCPS)' || imsDa.Asset_Name__c == 'OneKey Select') && imsDa.BU__c == 'United States') {
                additionalTerms += AdditionalTermMap.get('is_Xponent_or_OneKey__c') + ' ; ';
            } 
            else if((imsDa.Asset_Name__c == 'Xponent' || imsDa.Asset_Name__c == 'OneKey - Facilities' || imsDa.Asset_Name__c == 'OneKey - Professionals') && imsDa.BU__c == 'Canada') {
                additionalTerms += AdditionalTermMap.get('is_Xponent_or_OneKey__c') + ' ; ';
            } 
            else if( imsDa.Asset_Name__c.indexOf('Medpages Data') != -1 ){
                additionalTerms += AdditionalTermMap.get('Is_MedPages_Data__c') + ' ; ';
            }
            else if( imsDa.Asset_Name__c.indexOf('AIM XR Web Search/Social Insights') != -1 ){
                additionalTerms += AdditionalTermMap.get('is_AIM_XR__c ') + ' ; ';
            }
            else if( imsDa.Asset_Name__c.indexOf('Analytics Link – Client Extract Only – No 3rd Party tool access included') != -1 ){
                additionalTerms += AdditionalTermMap.get('is_Analytics_Link__c') + ' ; ';
            }

            if(imsDa.BU__c == 'Canada' && imsDa.Additional_Terms_Required__c){
                additionalTerms += AdditionalTermMap.get('is_Canada__c') + ' ; ';
            }

            if(imsDa.BU__c == 'United States') {
                additionalTerms += AdditionalTermMap.get('containUS__c') == null ? '' : (AdditionalTermMap.get('containUS__c') + ' ; ');
            } 

        }
        else{
            if(setPromoOffering.contains( imsSecDa.Secondary_Asset_Name__c) ) {
                additionalTerms += AdditionalTermMap.get('is_Promotrak__c') + ' ; ';
            } 
            else if(setDDDOffering.contains( imsSecDa.Secondary_Asset_Name__c) ) {
                additionalTerms += AdditionalTermMap.get('isDDDOffering__c') + ' ; ';
            } 
            else if(imsSecDa.Secondary_Asset_Name__c == 'Xponent PlanTrak' && imsSecDa.Primary_Data_Asset__r.BU__c == 'United States') {
                additionalTerms += AdditionalTermMap.get('is_Xponent__c') + ' ; ';
            } 
            
            if(imsSecDa.Primary_Data_Asset__r.BU__c == 'Canada' && imsSecDa.Additional_Terms_Required__c ){
                additionalTerms += AdditionalTermMap.get('is_Canada__c') + ' ; ';
            }
            
        }
        return additionalTerms;
    }
    
    public PageReference redirectToExport(){
        String filteredCountries = Apexpages.currentPage().getParameters().get('filteredCountries');
        String filteredProcessors = Apexpages.currentPage().getParameters().get('filteredProcessors');
        
        if(filteredCountries.contains('&') || filteredProcessors.contains('&')){
            filteredCountries = filteredCountries.replaceAll('&', '%26');
            filteredProcessors = filteredProcessors.replaceAll('&', '%26');
        }
        PageReference pr = new PageReference('/apex/VFP_TPA_Report_Export?type=ATPACW&query=' + filteredCountries +':'+filteredProcessors);
        pr.setRedirect(true);
        return pr;
    }
    

    
    public class watchListWrapper
    {
        public String offCountry;
        public String offCategory;
        public String comManagerName;
        public String comManagerEmail;
        public String priOffName;
        public String SecOffName;
        public String iqviaLegalName;
        public String legalEntityUnder;
        public String TPProcessorName;
        public String isManualReviewRequired;
        public String isfeeAssociated; 
        public String isAMARequired;
        public String isDataProtectionRequired;
        public String isaddInfoOnTLLA;
        public String isExtLicReq; 
        public String legalEntityAddress;
        public String authorizeSigner;
        public String secondaryCommOwner;
        public String secondaryCommEmail; 
        public String additionalTerm;
        public String descriptionText;

        public watchListWrapper(IMS_Data_Asset__c IMSAssetObj,IMS_Secondary_Data_Asset__c secOff,String TPProcessorName,String AdditionalTerms,IMS_Master_Legal_Entity__c masterEntity,String description){
            this.offCountry = IMSAssetObj.BU__c;
            this.offCategory = IMSAssetObj.Geo_Level__c;
            this.comManagerName = secOff != null ? secOff.Commercial_Manager_Name__c :IMSAssetObj.Commercial_Manager_Name__c;
            this.comManagerEmail = secOff != null ? secOff.Commercial_Manager_Email__c :IMSAssetObj.Commercial_Owner_Email__c;
            this.priOffName = IMSAssetObj.Asset_Name__c;
            this.SecOffName = secOff != null ? secOff.Secondary_Asset_Name__c : '';
            this.iqviaLegalName = IMSAssetObj.IMS_Legal_Name__c;
            this.legalEntityUnder = IMSAssetObj.IMS_Legal_Entity__c;
            this.TPProcessorName = TPProcessorName;
            this.isDataProtectionRequired = IMSAssetObj.Additional_Data_Protection_Terms__c == true ? 'Yes' : 'No'; 
            this.isaddInfoOnTLLA = ((secOff != null ? secOff.Additional_Terms_Required__c : IMSAssetObj.Additional_Terms_Required__c)  == true  ) ? 'Yes' : 'No';
            this.isManualReviewRequired = ((secOff != null ? secOff.Requires_Manual_Review__c : IMSAssetObj.Requires_Manual_Review__c)  == true  ) ? 'Yes' : 'No';
            this.isfeeAssociated = IMSAssetObj.Requires_Fee__c == true ? 'Yes' : 'No';
            this.isAMARequired = ((secOff != null ? secOff.Is_AMA_Required__c : IMSAssetObj.Is_AMA_Required__c)  == true  )? 'Yes' : 'No';
        	this.isExtLicReq = secOff != null ? secOff.Need_license_or_data_supplier_permission__c : IMSAssetObj.Needs_license_or_data_supplier_response__c;
            this.additionalTerm = AdditionalTerms;
            this.legalEntityAddress = masterEntity.IMS_Entity_Address__c;
            this.authorizeSigner = masterEntity.Name_for_ESign__c;
            this.secondaryCommOwner = secOff != null ? secOff.Secondary_Commercial_Reviewer_Name__c : IMSAssetObj.Secondary_Commercial_Reviewer_Name__c;
            this.secondaryCommEmail = secOff != null ? secOff.Secondary_Commercial_Reviewer_Email__c : IMSAssetObj.Secondary_Commercial_Reviewer_Email__c;
            this.descriptionText = description;
        }

        
    }
}
