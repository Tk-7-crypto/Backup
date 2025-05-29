/** 
* Author : Babita Dadarwal
* Date   : 9 Dec 2016
* Name   : TPA_Manual_Vendor_Approval_Report_Cntrl
* Description : Controller of TPA_Manual_Vendor_Approval_Report Page
*/

public class CNT_TPA_ManualVendorApprovalReport {
    public List<String> submittingVendor { get; set; }
    public List<String> purposes { get; set; }
    public List<String> countries { get; set; }
    
    public CNT_TPA_ManualVendorApprovalReport(){
        submittingVendor = new List<String>();
        purposes = new List<String>();
        countries = new List<String>();
        for( Address__c vendorAddress :[ Select id, Name from Address__c where Is_TPA_Account__c = true AND (Vendor_Tier__c = 'Y' OR New_Vendor_Checklist__c = true) AND Primary_Vendor_Address__c = true order By Name ]){
            vendorAddress.Name = vendorAddress.Name.replace('"', '\\"');
            submittingVendor.add(vendorAddress.Name + '~');
        }
        for( IMS_TPA_Purpose_Category__c purp :[ Select i.IMS_TPA_Purpose__r.english_translation__c From IMS_TPA_Purpose_Category__c i where i.IMS_TPA_Purpose__r.Is_Active__c = true and i.TPA_Purpose_Category__r.isActive__c = true order by i.IMS_TPA_Purpose__r.Other_for_Sorting_Display__c,i.IMS_TPA_Purpose__r.Primary_Purpose_Name__c]){
            if(purp.IMS_TPA_Purpose__r.english_translation__c != null && purp.IMS_TPA_Purpose__r.english_translation__c != ''){
                purp.IMS_TPA_Purpose__r.english_translation__c = purp.IMS_TPA_Purpose__r.english_translation__c.replace('"', '\\"');
                purposes.add(purp.IMS_TPA_Purpose__r.english_translation__c + '~');
            }
        }
        for( TPA_Language_Cross_Walk__c lang :[ Select Id,English_Translation__c, Default_Value__c From TPA_Language_Cross_Walk__c WHERE IsDeleted__c = false and Object_Type__c='TPA_Request__c' and Control_Type__c = 'Picklist' and Field_Type__c = 'Region__c']){
            lang.Default_Value__c = lang.Default_Value__c.replace('"', '\\"');
            countries.add(lang.Default_Value__c + '~');
        }
        
    }

    @remoteAction
    public static returnDataWrapper searchData(String lastRecId, String recievedConditions){
	
        list<watchListWrapper> watchListWrapperList = new list<watchListWrapper>();
        returnDataWrapper retDataWrapObj = new returnDataWrapper();
		allConditions selectedConditions = (allConditions)JSON.deserializeStrict(recievedConditions, allConditions.class);
        List<String> dateVals = new List<String>();
        if(selectedConditions.fromDate != null){
            dateVals = selectedConditions.fromDate.split('/');
        }
        Date fromDate = Date.newInstance(Integer.valueOf(dateVals[2]),Integer.valueOf(dateVals[0]),Integer.valueOf(dateVals[1]));
        if(selectedConditions.toDate != null){
            dateVals = selectedConditions.toDate.split('/');
        }
        Date toDate = Date.newInstance(Integer.valueOf(dateVals[2]),Integer.valueOf(dateVals[0]),Integer.valueOf(dateVals[1])); 
        Integer noOfReqToProcess = Integer.valueOf(selectedConditions.noOfRequestToProcess);
        String selectedVendor = String.valueOf(selectedConditions.selectedVendor);
        List<String> purposes = selectedConditions.purps != null && selectedConditions.purps != '' ? String.valueOf(selectedConditions.purps).replaceAll('&amp;','&').split('~') : new List<String>();
        List<String> priOffs = selectedConditions.priOffs != null && selectedConditions.priOffs != ''? String.valueOf(selectedConditions.priOffs).replaceAll('&amp;','&').split('~') : new List<String>();
        List<String> secOffs = selectedConditions.secOffs != null && selectedConditions.secOffs != ''? String.valueOf(selectedConditions.secOffs).replaceAll('&amp;','&').split('~') : new List<String>();
        List<String> countryOfOffs = selectedConditions.countries != null && selectedConditions.countries != ''? String.valueOf(selectedConditions.countries).split('~') : new List<String>();
        datetime lastRecordCretedDateTime ;
        if(lastRecId != null) {
            lastRecordCretedDateTime = [Select CreatedDate from TPA_Request__c where Id = :lastRecId][0].CreatedDate;
        }
        else {
            lastRecordCretedDateTime = fromDate.addDays(-1);
        }

        List<TPA_Request__C> requests = new List<TPA_Request__C>();

        String useQuery = '(Select Id, Name from Purposes__r';
        if(purposes != null && purposes.size() > 0){
            useQuery += ' where Name in: purposes';
        }
        String priOffQuery = '(Select Id, Name, A_Column_Use_For_Template__c, Asset_Name__c, BU__c From Data_Assets__r';
        if(priOffs != null && priOffs.size() > 0){
            priOffQuery += ' where Asset_Name__c  in: priOffs';
            if(countryOfOffs != null && countryOfOffs.size() > 0){
                priOffQuery += ' and BU__c in: countryOfOffs';
            }
        }
        else if(countryOfOffs != null && countryOfOffs.size() > 0){
            priOffQuery += ' where BU__c in: countryOfOffs';
        }
        String secOffQuery = '(Select id, Name,BU__c, TPA_Data_Asset__r.A_Column_Use_For_Template__c, Secondary_Asset_Name__c, TPA_Data_Asset__r.BU__c From TPA_Tertiary_Data_Assets__r ';
        if(secOffs != null && secOffs.size() > 0){
            secOffQuery += 'where Secondary_Asset_Name__c in: secOffs';
            if(priOffs != null && priOffs.size() > 0){
                secOffQuery += ' and TPA_Data_Asset__r.Asset_Name__c in: priOffs';
            }
            if(countryOfOffs != null && countryOfOffs.size() > 0){
                secOffQuery += ' and BU__c in: countryOfOffs';
            }
        }
        else if(priOffs != null && priOffs.size() > 0){
            secOffQuery += 'where TPA_Data_Asset__r.Asset_Name__c in: priOffs';
            if(countryOfOffs != null && countryOfOffs.size() > 0){
                secOffQuery += ' and BU__c in: countryOfOffs';
            }
        }
        else if(countryOfOffs != null && countryOfOffs.size() > 0){
            secOffQuery += 'where BU__c in: countryOfOffs';
        }
        String finalQuery = 'select id, Name, Service_Provider_Address__c, Service_Provider_Address__r.Vendor_Tier__c, Service_Provider_Address__r.Parent_Vendor_Name__c,Service_Provider_Address__r.Parent_Vendor_Name__r.Vendor_Tier__c, Service_Provider_Address__r.Name, Client_Address__c, Client_Address__r.Name, CreatedDate, ';
        
        finalQuery += useQuery + '),';
        if(secOffs == null || secOffs.size() == 0){
        	finalQuery += priOffQuery + '),';
        }
        finalQuery += secOffQuery + ') ';
        finalQuery += 'from TPA_Request__c where Is_Submitted__c = true and ((Service_Provider_Address__r.Parent_Vendor_Name__r.Vendor_Tier__c = \'Y\' OR Service_Provider_Address__r.Vendor_Tier__c = \'Y\') OR (Service_Provider_Address__r.New_Vendor_Checklist__c = true OR Service_Provider_Address__r.Parent_Vendor_Name__r.New_Vendor_Checklist__c = true)) and (Service_Provider_Address__r.Parent_Vendor_Name__r.Name = :selectedVendor OR Service_Provider_Address__r.Name = :selectedVendor) and CreatedDate >= :fromDate and CreatedDate <= :toDate and CreatedDate > :lastRecordCretedDateTime order by CreatedDate limit :noOfReqToProcess';
        requests = Database.query(finalQuery);
        Set<String> purposeList = new Set<String>();
        for(TPA_request__c nThRequest : requests){
            if(nThRequest.purposes__r != null){
                for(TPA_Purpose__c purpose : nThRequest.Purposes__r){
                    purposeList.add(purpose.Name);
                }
            }else {
                continue;
            }
        }
        Map<String, Watch_List__c> useOfferingsWatchMap = new Map<String, Watch_List__c>();
        for( Watch_List__c watch : [ Select Id, Always_Approved__c, Offering__c, Use__c, Vendor_Address__c
                                    from Watch_List__c where Vendor_Address__r.Name = :selectedVendor and Use__c in :purposeList and Always_Approved__c = false] )
        {
            transient String use = ( watch.Use__c != null ? watch.Use__c : '' );
            transient String offering = ( watch.Offering__c != null ? watch.Offering__c : '' );
            transient String vendor = watch.Vendor_Address__c;
            // Create unique key of use, offering and vendor ID, put into map           
            transient String uniqueKey = use+offering+vendor;
            
            useOfferingsWatchMap.put( uniqueKey, watch );
        }
        for(TPA_Request__c agg : requests)
        {
            transient String vendor = agg.Service_Provider_Address__r.Parent_Vendor_Name__c != null ? agg.Service_Provider_Address__r.Parent_Vendor_Name__c : agg.Service_Provider_Address__c;
            transient DateTime dT = agg.CreatedDate;
            transient Date d = dt.Date();
            
            transient Set<Id> priDataAssetIds = new set<Id>();
            for(TPA_Secondary_Data_Asset__c secDataAsset : agg.TPA_Tertiary_Data_Assets__r)
            {
                priDataAssetIds.add(secDataAsset.TPA_Data_Asset__c);
                
                transient String use = ( secDataAsset.TPA_Data_Asset__r.A_Column_Use_For_Template__c != null ? secDataAsset.TPA_Data_Asset__r.A_Column_Use_For_Template__c : '' );
                transient String offering = ( secDataAsset.Secondary_Asset_Name__c != null ? secDataAsset.Secondary_Asset_Name__c : '' );
                transient String uniqueKey = use + offering + vendor;
                
                if(useOfferingsWatchMap.containsKey( uniqueKey ) && !useOfferingsWatchMap.get(uniqueKey).Always_Approved__c)
                {
                    watchListWrapperList.add( new watchListWrapper(agg.id, agg.Name, agg.Service_Provider_Address__r.Name, agg.Client_Address__r.Name, use, offering, useOfferingsWatchMap.get(uniqueKey).Always_Approved__c, agg.CreatedDate.Date() , secDataAsset.TPA_Data_Asset__r.BU__c));
                }
                
            }
            
            for(TPA_Data_Asset__c dataAsset : agg.Data_Assets__r)
            {
                transient String use = ( dataAsset.A_Column_Use_For_Template__c != null ? dataAsset.A_Column_Use_For_Template__c : '' );
                transient String offering = ( dataAsset.Asset_Name__c != null ? dataAsset.Asset_Name__c : '' );
                transient String uniqueKey = use + offering + vendor;
                
                if(useOfferingsWatchMap.containsKey( uniqueKey ) && !useOfferingsWatchMap.get(uniqueKey).Always_Approved__c && !priDataAssetIds.contains(dataAsset.id))
                {
                    watchListWrapperList.add( new watchListWrapper(agg.id, agg.Name, agg.Service_Provider_Address__r.Name, agg.Client_Address__r.Name, use, offering, useOfferingsWatchMap.get(uniqueKey).Always_Approved__c, d, dataAsset.BU__c));
                }
                
            }
            
            
        }
        
        if(requests != null && requests.size() > 0) {
            retDataWrapObj.lastReqId = requests[requests.size()-1].Id;
            retDataWrapObj.noOfTPAReqProcessed = requests.size();
        }
        else {
            retDataWrapObj.lastReqId = '';
            retDataWrapObj.noOfTPAReqProcessed = 0;
        }    
        if(watchListWrapperList == null || watchListWrapperList.size() == 0) {
            retDataWrapObj.resultData = null;
            return retDataWrapObj;
        }
        retDataWrapObj.resultData = watchListWrapperList;
		return retDataWrapObj;
    }

    @remoteAction
    public static String getPrimaryOfferings(String countries){
        List<String> listOfCountry = new List<String>();
        if(countries != null && countries != ''){
            listOfCountry = countries.split('~');
        }
        String retVal = '';
        for(IMS_Data_Asset__c imsDA:[Select Id,Asset_Name__c From IMS_Data_Asset__c where BU__c in: listOfCountry]){
            retVal += imsDA.Asset_Name__c + '~';
        }
        return retVal;
    }

    @remoteAction
    public static String getSecondaryOfferings(String primaryOffs,String countries){
        List<String> listOfOffs = new List<String>();
        if(primaryOffs != null && primaryOffs != ''){
            listOfOffs = primaryOffs.split('~');
        }
        List<String> listOfCountry = new List<String>();
        if(countries != null && countries != ''){
            listOfCountry = countries.split('~');
        }
        String retVal = '';
        for(IMS_Secondary_Data_Asset__c imsSecDA:[Select Id,Secondary_Asset_Name__c From IMS_Secondary_Data_Asset__c where Primary_Data_Asset__r.Asset_Name__c in: listOfOffs and Primary_Data_Asset__r.BU__c in: listOfCountry]){
            retVal += imsSecDA.Secondary_Asset_Name__c + '~';
        }
        return retVal;
    }

    
    public PageReference redirectToExportVAR(){
        String conditions = Apexpages.currentPage().getParameters().get('filterParams');
        if(conditions != null){
            conditions = conditions.replace('&', '%26');
        }
        PageReference pr = new PageReference('/apex/VFP_TPA_Report_Export?type=ManualVendor&query='+conditions);
        pr.setRedirect(true);
        return pr;
    }

    
    public List<SelectOption> getGroupingOptions()
    {
        // List of select options to store grouping options
        List<SelectOption> options = new List<SelectOption>();
        
        // Add default option in the select option list
        options.add( new SelectOption( 'TPANumber', 'TPA #' ));
        options.add( new SelectOption( 'vendorName-use-offering', 'Vendor - Use and Offering' ));
        options.add( new SelectOption( 'vendorName', 'Vendor Name' ));
        options.add( new SelectOption( 'OfferingCountry', 'Offering Country' ));
        
        // Return list of select options
        return options;
    }
    public class allConditions{
        public String fromDate;
        public String toDate;
        public String noOfRequestToProcess;
        public String selectedVendor;
        public String purps;
        public String countries;
        public String prioffs;
        public String secOffs;
    }
    
    
    public class watchListWrapper
    {
        public string id {get; set;}
        public string TPANumber {get; set;}
        public String vendorName {get; set;}
        public String clientName {get; set;}
        public string use {get; set;}
        public string offering {get; set;}
        public boolean isApproved {get; set;}
        public Date CreatedDate {get; set;}
        public string OfferingCountry {get; set;}
        
        public watchListWrapper(string id,string tpaNumber, String vendorName, String clientName, string use, string offering, boolean isApproved, Date createdDate, string offeringCountry)
        {
            this.id = id;
            this.TPANumber = tpaNumber;
            this.vendorName = vendorName;
            this.clientName = clientName;
            this.use = use;
            this.offering = offering;
            this.isApproved = isApproved;
            this.CreatedDate = createdDate;
            this.OfferingCountry = offeringCountry;
        }
    }

    public class returnDataWrapper{
        public list<watchListWrapper> resultData;
        public Integer noOfTPAReqProcessed;
        public String lastReqId;
    }
}