public class CNT_TPA_Report_Export {
    public String query{get;set;}
    public String reportType{get;set;}
    public String completedKeyword {
        get{
            return UTL_TPA.TPA_COMPLETED_KEYWORD;
        } 
        set; 
    } 
    public CNT_TPA_Report_Export(){
        reportType = ApexPages.currentPage().getParameters().get('type');
        query = ApexPages.currentPage().getParameters().get('query');
        
    }
    
    @remoteAction
    public static List<TPA_Request__c> loadRecords(String lastRecId,String query){
        DateTime lastRecordCretedDateTime;
        if(lastRecId != null){
            lastRecordCretedDateTime = [select createddate from tpa_request__c where id =: lastRecId limit 1][0].createddate;
        }
        if(lastRecordCretedDateTime != null || Test.isRunningTest()){
            query += ' and createddate >: lastRecordCretedDateTime ';
        }
        List<TPA_Request__c> reqList = new List<TPA_Request__c>();
        System.debug(query);
        reqList = Database.query(query + ' order by createddate asc Limit ' + 1000);
    
        return reqList;
    }
    
    @remoteAction
    public static List<OfferingWrapper> loadOffRecords(String lastRecId,String filteredCountries){
        list<OfferingWrapper> watchListWrapperList = new list<OfferingWrapper>();
        String query = 'Select Id,Asset_Name__c,BU__c, IMS_Legal_Entity__c, Is_Restricted_Data__c, (select id,Secondary_Asset_Name__c from IMS_Secondary_Data_Assets__r WHERE Is_Active__c = true) from IMS_Data_Asset__c WHERE  Is_Active__c = true and Asset_Name__c != \'Other\' ';
        if(!filteredCountries.contains('All')){
            query += 'and BU__c in (';
            for(String country:filteredCountries.split(';')){
                query += '\''+ country +'\',';
            }
            query = query.substring(0,query.length()-1);
            query += ') ';
        }
        DateTime lastRecordCretedDateTime;
        if(lastRecId != null){
            lastRecordCretedDateTime = [select createddate from IMS_Data_Asset__c where id =: lastRecId limit 1][0].createddate;
        }
        if(lastRecordCretedDateTime != null || Test.isRunningTest()){
            query += ' and createddate >: lastRecordCretedDateTime ';
        }
        
        
        List<IMS_Data_Asset__c> offRecords = new List<IMS_Data_Asset__c>();
        offRecords = Database.query(query + ' order by CreatedDate Limit 1000');
        for(IMS_Data_Asset__c IMSAssetObj : offRecords){
            if(IMSAssetObj.IMS_Secondary_Data_Assets__r != null && IMSAssetObj.IMS_Secondary_Data_Assets__r.size() >0 ){
                for(IMS_Secondary_Data_Asset__c secOff :IMSAssetObj.IMS_Secondary_Data_Assets__r){
                    watchListWrapperList.add(new OfferingWrapper(IMSAssetObj.Id, IMSAssetObj.BU__c, IMSAssetObj.Asset_Name__c, secOff.Secondary_Asset_Name__c, CNT_TPA_Workbook_Offering_Data.BUWithLegalEntityNameMap.get(IMSAssetObj.IMS_Legal_Entity__c), IMSAssetObj.IMS_Legal_Entity__c, CNT_TPA_Workbook_Offering_Data.BUWithTPProcessorNameMap.get(IMSAssetObj.BU__c),IMSAssetObj.Is_Restricted_Data__c));
                }
            }
            else{
                watchListWrapperList.add(new OfferingWrapper(IMSAssetObj.Id, IMSAssetObj.BU__c, IMSAssetObj.Asset_Name__c, '', CNT_TPA_Workbook_Offering_Data.BUWithLegalEntityNameMap.get(IMSAssetObj.IMS_Legal_Entity__c), IMSAssetObj.IMS_Legal_Entity__c, CNT_TPA_Workbook_Offering_Data.BUWithTPProcessorNameMap.get(IMSAssetObj.BU__c),IMSAssetObj.Is_Restricted_Data__c));
            }
        }
        
        return watchListWrapperList;
    }
    
    @remoteAction
    public static List<CNT_TPA_IMSLegalEntity_with_Offering.watchListWrapper> loadLegalEntitywithOffRecords(String lastRecId,String query){
        list<CNT_TPA_IMSLegalEntity_with_Offering.watchListWrapper> watchListWrapperList = new list<CNT_TPA_IMSLegalEntity_with_Offering.watchListWrapper>();
        
        DateTime lastRecordCretedDateTime;
        if(lastRecId != null){
            lastRecordCretedDateTime = [select createddate from IMS_Data_Asset__c where id =: lastRecId limit 1][0].createddate;
        }
        if(lastRecordCretedDateTime != null || Test.isRunningTest()){
            query += ' and createddate >: lastRecordCretedDateTime ';
        }
        
        List<IMS_Data_Asset__c> offRecords = new List<IMS_Data_Asset__c>();
        offRecords = Database.query(query + ' order by CreatedDate Limit 1000');
        for(IMS_Data_Asset__c IMSAssetObj : offRecords){
            if(IMSAssetObj.IMS_Secondary_Data_Assets__r != null && IMSAssetObj.IMS_Secondary_Data_Assets__r.size() >0 ){
                for(IMS_Secondary_Data_Asset__c secOff :IMSAssetObj.IMS_Secondary_Data_Assets__r){
                    watchListWrapperList.add(new CNT_TPA_IMSLegalEntity_with_Offering.watchListWrapper(IMSAssetObj.Id , IMSAssetObj.BU__c, IMSAssetObj.Asset_Name__c, secOff.Secondary_Asset_Name__c, IMSAssetObj.IMS_Legal_Entity__c, CNT_TPA_IMSLegalEntity_with_Offering.BUWithLegalEntityNameMap.get(IMSAssetObj.IMS_Legal_Entity__c).substringBefore('|::|') ,CNT_TPA_IMSLegalEntity_with_Offering.BUWithLegalEntityNameMap.get(IMSAssetObj.IMS_Legal_Entity__c).substringAfter('|::|')));
                }
            }
            else{
                watchListWrapperList.add(new CNT_TPA_IMSLegalEntity_with_Offering.watchListWrapper(IMSAssetObj.Id, IMSAssetObj.BU__c, IMSAssetObj.Asset_Name__c, '',  IMSAssetObj.IMS_Legal_Entity__c, CNT_TPA_IMSLegalEntity_with_Offering.BUWithLegalEntityNameMap.get(IMSAssetObj.IMS_Legal_Entity__c).substringBefore('|::|'),CNT_TPA_IMSLegalEntity_with_Offering.BUWithLegalEntityNameMap.get(IMSAssetObj.IMS_Legal_Entity__c).substringAfter('|::|')));
            }
        }
        
        return watchListWrapperList;
    }
    
    @remoteAction
    public static ReturnWrapper loadTAT2Records(String lastRecId,String conditions){
        ReturnWrapper retDataWrapObj = new ReturnWrapper();
        if(conditions != null){
            CNT_TPA_TATReport2.allConditions allFilters = (CNT_TPA_TATReport2.allConditions)JSON.deserialize(conditions,CNT_TPA_TATReport2.allConditions.class);
        	String query = 'Select Id, Name, Client_Address__c, '
                        + 'Service_Provider_Address__c, Request_Status__c, '
                        + 'Client_Request_Submission__c, Vendor_App_Sent__c, Vendor_App_Submitted__c, In_IMS_Review__c, In_Effect_Date__c, '
                        + 'IMS_Denied__c, Sent_for_Signature__c, Signature_Received__c, Signature_Under_Validation__c, Cancelled__c, '
                        + 'Expired_Date__c, Service_Provider_Address__r.Name, Is_Manually_Approved__c, '
                        + 'Client_Contact_Territory__c, Client_Address__r.Name,Secondary_Client_Contact_Territory__c,'
                        + 'LastModifiedBy.Name, LastModifiedById, AMA_USPrescriberData__c, '
                		+ '(Select Id, Name, TPA_Purpose_Category__r.Category_Name__c from Purposes__r), '
                        + '(Select Data_Asset__c, Data_Asset__r.Geo_Level__c From Data_Assets__r), '
                        + 'Manual_Trigger_Reasons__c '
                        + 'from TPA_Request__c where Is_Submitted__c = true';
                        
        	if( allFilters.vendorName != null && allFilters.vendorName != '' ) {
            	query += ' AND Service_Provider_Address__r.Name like \'' + allFilters.vendorName + '%\'';
        	}
        	else if( allFilters.clientName != null && allFilters.clientName != '' ) {
            	query += ' AND Client_Address__r.Name like \'' + allFilters.clientName + '%\'';
        	}
        	Datetime fromDate = allFilters.fromDate;
        	Datetime toDate = allFilters.toDate.addDays(1);
        	query += ' AND ( CreatedDate >=: fromDate AND CreatedDate <: toDate )';
			String fromStatus = allFilters.statusCategorySelected.split('-')[0];
        	String toStatus = allFilters.statusCategorySelected.split('-')[1];
            Integer lowerDayRange = Integer.valueOf(allFilters.dayRange.split('-')[0]);
        	Integer upperDayRange = Integer.valueOf(allFilters.dayRange.split('-')[1]);
        	String fromStatusFieldName = '',toStatusFieldName = '',allCountriesSelected='';
        	for(String str : fromStatus.split(' ')) {
          		fromStatusFieldName += str+'_';
        	}
        	fromStatusFieldName += '_c';
        	for(String str : toStatus.split(' ')) {
          		toStatusFieldName += str+'_';
        	}
        	toStatusFieldName += '_c';
        	query += ' AND ' + fromStatusFieldName + ' != null';
        	query += ' AND ' + toStatusFieldName + ' != null';
        	if(!allFilters.submittingCountries.contains('All')){
            	Set<String> allCountriesSelectedSet = new Set<String>();
        		for(String selectedCountry: allFilters.submittingCountries) {
            		allCountriesSelectedSet.add(selectedCountry);
            		allCountriesSelectedSet.addAll(UTL_TPA_Multilingual.getCountryStateCodeSetWithName('C', selectedCountry));
        		}
            	query += ' AND Secondary_Client_Contact_Territory__c in: allCountriesSelectedSet ';
        	}
            DateTime lastRecordCretedDateTime;
            if(lastRecId != null){
                lastRecordCretedDateTime = [select createddate from tpa_request__c where id =: lastRecId limit 1][0].createddate;
            }
            if(lastRecordCretedDateTime != null){
                query += ' and createddate >: lastRecordCretedDateTime ';
            }
            List<TPA_Request__c> reqList = new List<TPA_Request__c>();
            System.debug(query);
            reqList = Database.query(query + ' order by createddate asc Limit ' + 4000);
            retDataWrapObj.resultData = CNT_TPA_TATReport2.getReportWrapperList(reqList,lowerDayRange,upperDayRange,fromStatusFieldName,toStatusFieldName);
            retDataWrapObj.noOfTPAReqProcessed = reqList.size();
            retDataWrapObj.lastReqId = Test.isRunningTest() ? '' : reqList[reqList.size()-1].Id;
        }
        return retDataWrapObj;
    }
    
    @remoteAction
    public static List<TPA_Request__c> loadTPSAReport(string lastRecordId, string recievedConditions) {
        List<TPA_Request__c> agreementList;
        CNT_TPA_ReportingServices.TPSAReportConditions allConditions = (CNT_TPA_ReportingServices.TPSAReportConditions)JSON.deserializeStrict(recievedConditions, CNT_TPA_ReportingServices.TPSAReportConditions.class);
        datetime lastRecordCretedDateTime;
        date fromDate = date.parse(allConditions.fromDate);
        date toDate = date.parse(allConditions.toDate).addDays(1);
        Boolean isShowTestRequests = TPA_Settings__c.getInstance().Show_Test_Request__c;
        Integer pageSize = Integer.valueOf(allConditions.pageSize);
        if(lastRecordId != null) {
            lastRecordCretedDateTime = [SELECT createddate FROM TPA_Request__c WHERE id =: lastRecordId limit 1][0].createddate;
        }   
        if(lastRecordCretedDateTime == null) {
            if(isShowTestRequests) {
                agreementList = [SELECT id, Name, Client_Full_Name__c, Client_Address__c, Service_Provider_Address__c, Service_Provider_Address__r.Name, In_Effect_Date__c, Data_Access_Start_Date__c, Data_Access_End_Date__c, IsDeleted, CreatedDate, Signature_Under_Validation__c, (Select Name FROM Attachments WHERE (Name LIKE '%IQVIA Third Party Tech Amendment%' OR Name LIKE '%IQVIA Third Party Tech License Agreement%') AND IsDeleted = false ORDER BY createddate desc) FROM TPA_Request__c WHERE Is_Submitted__c = true AND In_Effect_Date__c >=: fromDate AND In_Effect_Date__c <=: toDate AND Request_Status__c = 'In Effect' AND ((Client_Full_Name__c LIKE 'TEST_%') OR (Service_Provider_Address__r.Name LIKE 'TEST_%')) ORDER BY createddate desc Limit :pageSize];
            }
            else {
                agreementList = [SELECT id, Name, Client_Full_Name__c, Client_Address__c, Service_Provider_Address__c, Service_Provider_Address__r.Name, In_Effect_Date__c, Data_Access_Start_Date__c, Data_Access_End_Date__c, IsDeleted, CreatedDate, Signature_Under_Validation__c, (Select Name FROM Attachments WHERE (Name LIKE '%IQVIA Third Party Tech Amendment%' OR Name LIKE '%IQVIA Third Party Tech License Agreement%') AND IsDeleted = false ORDER BY createddate desc) FROM TPA_Request__c WHERE Is_Submitted__c = true AND In_Effect_Date__c >=: fromDate AND In_Effect_Date__c <=: toDate AND Request_Status__c = 'In Effect' AND (NOT Client_Full_Name__c LIKE 'TEST_%') AND (NOT Service_Provider_Address__r.Name LIKE 'TEST_%') ORDER BY createddate desc Limit :pageSize];
            }
        }
        else {
            if(isShowTestRequests) {
                agreementList = [SELECT id, Name, Client_Full_Name__c, Client_Address__c, Service_Provider_Address__c, Service_Provider_Address__r.Name, In_Effect_Date__c, Data_Access_Start_Date__c, Data_Access_End_Date__c, IsDeleted, CreatedDate, Signature_Under_Validation__c, (Select Name FROM Attachments WHERE (Name LIKE '%IQVIA Third Party Tech Amendment%' OR Name LIKE '%IQVIA Third Party Tech License Agreement%') AND IsDeleted = false ORDER BY createddate desc) FROM TPA_Request__c WHERE Is_Submitted__c = true AND In_Effect_Date__c >=: fromDate AND In_Effect_Date__c <=: toDate AND Request_Status__c = 'In Effect' AND createddate <: lastRecordCretedDateTime AND ((Client_Full_Name__c LIKE 'TEST_%') OR (Service_Provider_Address__r.Name LIKE 'TEST_%')) ORDER BY createddate desc Limit :pageSize];
            }
            else {
                agreementList = [SELECT id, Name, Client_Full_Name__c, Client_Address__c, Service_Provider_Address__c, Service_Provider_Address__r.Name, In_Effect_Date__c, Data_Access_Start_Date__c, Data_Access_End_Date__c, IsDeleted, CreatedDate, Signature_Under_Validation__c, (Select Name FROM Attachments WHERE (Name LIKE '%IQVIA Third Party Tech Amendment%' OR Name LIKE '%IQVIA Third Party Tech License Agreement%') AND IsDeleted = false ORDER BY createddate desc) FROM TPA_Request__c WHERE Is_Submitted__c = true AND In_Effect_Date__c >=: fromDate AND In_Effect_Date__c <=: toDate AND Request_Status__c = 'In Effect' AND createddate <: lastRecordCretedDateTime AND (NOT Client_Full_Name__c LIKE 'TEST_%') AND (NOT Service_Provider_Address__r.Name LIKE 'TEST_%') ORDER BY createddate desc Limit :pageSize];
            }
        }
        return agreementList;
    }
     @remoteAction
    public static CNT_TPA_ManualVendorApprovalReport.returnDataWrapper manualVendorApproval(String lastRecId, String recievedConditions){
        
        list<CNT_TPA_ManualVendorApprovalReport.watchListWrapper> watchListWrapperList = new list<CNT_TPA_ManualVendorApprovalReport.watchListWrapper>();
        CNT_TPA_ManualVendorApprovalReport.returnDataWrapper retDataWrapObj = new CNT_TPA_ManualVendorApprovalReport.returnDataWrapper();
		CNT_TPA_ManualVendorApprovalReport.allConditions selectedConditions = (CNT_TPA_ManualVendorApprovalReport.allConditions)JSON.deserializeStrict(recievedConditions, CNT_TPA_ManualVendorApprovalReport.allConditions.class);
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
        List<String> purposes = selectedConditions.purps != null && selectedConditions.purps != '' ? String.valueOf(selectedConditions.purps).split('~') : new List<String>();
        List<String> priOffs = selectedConditions.priOffs != null && selectedConditions.priOffs != ''? String.valueOf(selectedConditions.priOffs).split('~') : new List<String>();
        List<String> secOffs = selectedConditions.secOffs != null && selectedConditions.secOffs != ''? String.valueOf(selectedConditions.secOffs).split('~') : new List<String>();
        List<String> countryOfOffs = selectedConditions.countries != null && selectedConditions.countries != ''? String.valueOf(selectedConditions.countries).split('~') : new List<String>();
        
        datetime lastRecordCretedDateTime;
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
            if(countryOfOffs != null && countryOfOffs.size() > 0){
                secOffQuery += ' and BU__c in: countryOfOffs';
            }
        }
        else if(countryOfOffs != null && countryOfOffs.size() > 0){
            secOffQuery += 'where BU__c in: countryOfOffs';
        }
        String finalQuery = 'select id, Name, Service_Provider_Address__c, Service_Provider_Address__r.Vendor_Tier__c, Service_Provider_Address__r.Parent_Vendor_Name__c,Service_Provider_Address__r.Parent_Vendor_Name__r.Vendor_Tier__c, Service_Provider_Address__r.Name, Client_Address__c, Client_Address__r.Name, CreatedDate, ';
        
        finalQuery += useQuery + '),';
        finalQuery += priOffQuery + '),';
        finalQuery += secOffQuery + ') ';
        finalQuery += 'from TPA_Request__c where Is_Submitted__c = true and ((Service_Provider_Address__r.Parent_Vendor_Name__r.Vendor_Tier__c = \'Y\' OR Service_Provider_Address__r.Vendor_Tier__c = \'Y\') OR (Service_Provider_Address__r.New_Vendor_Checklist__c = true OR Service_Provider_Address__r.Parent_Vendor_Name__r.New_Vendor_Checklist__c = true)) and (Service_Provider_Address__r.Parent_Vendor_Name__r.Name = :selectedVendor OR Service_Provider_Address__r.Name = :selectedVendor) and CreatedDate >= :fromDate and CreatedDate <= :toDate and CreatedDate > :lastRecordCretedDateTime order by CreatedDate limit :noOfReqToProcess';
        requests = Database.query(finalQuery);
        
        system.debug(requests.size());
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
        system.debug(purposeList);
        Map<String, Watch_List__c> useOfferingsWatchMap = new Map<String, Watch_List__c>();
        for( Watch_List__c watch : [ Select Id, Always_Approved__c,  Offering__c, Use__c, Vendor_Address__c
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
                    watchListWrapperList.add( new CNT_TPA_ManualVendorApprovalReport.watchListWrapper(agg.id, agg.Name, agg.Service_Provider_Address__r.Name, agg.Client_Address__r.Name, use, offering, useOfferingsWatchMap.get(uniqueKey).Always_Approved__c, agg.CreatedDate.Date() , secDataAsset.TPA_Data_Asset__r.BU__c));
                }
                
            }
            
            for(TPA_Data_Asset__c dataAsset : agg.Data_Assets__r)
            {
                transient String use = ( dataAsset.A_Column_Use_For_Template__c != null ? dataAsset.A_Column_Use_For_Template__c : '' );
                transient String offering = ( dataAsset.Asset_Name__c != null ? dataAsset.Asset_Name__c : '' );
                transient String uniqueKey = use + offering + vendor;
                
                if(useOfferingsWatchMap.containsKey( uniqueKey ) && !useOfferingsWatchMap.get(uniqueKey).Always_Approved__c && !priDataAssetIds.contains(dataAsset.id))
                {
                    watchListWrapperList.add( new CNT_TPA_ManualVendorApprovalReport.watchListWrapper(agg.id, agg.Name, agg.Service_Provider_Address__r.Name, agg.Client_Address__r.Name, use, offering, useOfferingsWatchMap.get(uniqueKey).Always_Approved__c, d, dataAsset.BU__c));
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
		system.debug( retDataWrapObj.resultData[0] );
        return retDataWrapObj;
    }
   

    
    public class ReturnWrapper {
        Integer noOfTPAReqProcessed;
        String lastReqId;
        List<CNT_TPA_TATReport2.ReportWrapper> resultData;
    }
    
    
    public class OfferingWrapper
    {
        public string Id {get; set;}
        public string offCountry {get; set;}
        public String priOffName {get; set;}
        public String SecOffName {get; set;}
        public string iqviaLegalName {get; set;}
        public string legalEntityUnder {get; set;}
        public string TPProcessorEmail {get; set;}
        public boolean isResData {get; set;}
        
        public OfferingWrapper(String Id,string offCountry, string priOffName, string SecOffName, string iqviaLegalName, string legalEntityUnder, string TPProcessorEmail, boolean isResData)
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