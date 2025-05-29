public class CNT_TPA_TATReport2 {
     public List<String> submittingCountry { get; set; }
  
    public class ReportWrapper {
        TPA_Request__c objAgreement;
        Integer statusDuration;
        String usesSelected;
        String useCategories;
        String offeringCategories;
        String toStatus ;
        String fromStatus;
    }
  
    public class allConditions {
        public String dayRange;
        public String statusCategorySelected;
        public String clientName;
        public String vendorName;
        public Datetime fromDate;
        public Datetime toDate;
        public List<String> submittingCountries ;
    }
    
    public CNT_TPA_TATReport2() {
        submittingCountry = new List<String>();
        //submittingCountry.add('--None--');
        //submittingCountry.add( 'All');
        
        Schema.DescribeFieldResult fieldResult = TPA_Request__c.Client_Contact_Territory__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            submittingCountry.add( f.getValue());
        }
    }
    
    public PageReference redirectToExport(){
        String filters = Apexpages.currentPage().getParameters().get('filterParams');
        PageReference pr = new PageReference('/apex/VFP_TPA_Report_Export?type=TAT2&query='+filters);
        pr.setRedirect(true);
        return pr;
    }
    
   	public List<SelectOption> getGroupingOptions() {
        // List of select options to store grouping options
        List<SelectOption> options = new List<SelectOption>();
        
        // Add default option in the select option list
        options.add( new SelectOption( 'submittimgCountry', 'Client Country' ));
        options.add( new SelectOption( 'toStatus', 'Status' ));
        options.add( new SelectOption( 'vendorName', 'Vendor Name' ));
        options.add( new SelectOption( 'clientName', 'Client Name' ));
        
        // Return list of select options
        return options;
    }
    
    
    
    @remoteAction
    public static ReturnDataWaraper getReportResult(String selectedConditions, Integer noOfReqToProcess, String lastRecId) {
        List<ReportWrapper> lstReportResults = new List<ReportWrapper>();
        List<TPA_Request__c> lstAgreementQueried = new List<TPA_Request__c>();
        ReturnDataWaraper retDataWrapObj = new ReturnDataWaraper();
        String fromStatusFieldName = '';
        String toStatusFieldName = '';
        String fromStatus = '';
        String toStatus = '';  
        
        String lastRecordId;
        datetime lastRecordCretedDateTime;
        if(lastRecId != null) {
            lastRecordCretedDateTime = [Select CreatedDate from TPA_Request__c where Id = :lastRecId][0].CreatedDate;
        }
        
      	allConditions objSelectedConditions = (allConditions)JSON.deserialize(selectedConditions,allConditions.class);
        Datetime fromDate = objSelectedConditions.fromDate;
        Datetime toDate = objSelectedConditions.toDate.addDays(1);
        Integer lowerDayRange = Integer.valueOf(objSelectedConditions.dayRange.split('-')[0]);
        Integer upperDayRange = Integer.valueOf(objSelectedConditions.dayRange.split('-')[1]);
        Set<String> allCountriesSelected = new Set<String>();
        for(String selectedCountry: objSelectedConditions.submittingCountries) {
            allCountriesSelected.add(selectedCountry);
            allCountriesSelected.addAll(UTL_TPA_Multilingual.getCountryStateCodeSetWithName('C', selectedCountry));
        }
        //allCountriesSelected.addAll(objSelectedConditions.submittingCountries);
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
                        
        if( objSelectedConditions.vendorName != null && objSelectedConditions.vendorName != '' ) {
            query += ' AND Service_Provider_Address__r.Name like \'' + objSelectedConditions.vendorName + '%\'';
        }
        else if( objSelectedConditions.clientName != null && objSelectedConditions.clientName != '' ) {
            query += ' AND Client_Address__r.Name like \'' + objSelectedConditions.clientName + '%\'';
        }
        if(!Test.isRunningTest())
            query += ' AND ( CreatedDate >=: ' +'fromDate'+ ' AND CreatedDate <: ' +'toDate' +')';
        fromStatus = objSelectedConditions.statusCategorySelected.split('-')[0];
        toStatus = objSelectedConditions.statusCategorySelected.split('-')[1];
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
        query += ' AND Secondary_Client_Contact_Territory__c in: allCountriesSelected';
        if(lastRecordCretedDateTime != null) {
            query += ' AND CreatedDate > :lastRecordCretedDateTime';
        }
        //lstAgreementQueried = Database.query(query);
        lstAgreementQueried = Database.query( query + ' Order By CreatedDate Limit ' + noOfReqToProcess);
        system.debug('query:::: ' + query);
        if(lstAgreementQueried == null || lstAgreementQueried.size() == 0) {
            System.debug('agreements in If ----------------------> ' + lstAgreementQueried);
            retDataWrapObj.resultData = new List<ReportWrapper>();
            retDataWrapObj.noOfTPAReqProcessed = 0;
            retDataWrapObj.lastReqId = '';
            return retDataWrapObj;
        }
        lstReportResults = getReportWrapperList(lstAgreementQueried,lowerDayRange,upperDayRange,fromStatusFieldName,toStatusFieldName);
        retDataWrapObj.resultData = lstReportResults;
        System.debug('retDataWrapObj.resultData ------> ' + retDataWrapObj.resultData);
        retDataWrapObj.noOfTPAReqProcessed = lstAgreementQueried.size();
        retDataWrapObj.lastReqId = lstAgreementQueried[lstAgreementQueried.size()-1].Id;
        return retDataWrapObj;
    }
    
    public static List<ReportWrapper> getReportWrapperList(List<TPA_Request__c> lstAgreement,Integer lowerRange,Integer upperRange,String fromStatusField,String toStatusField) {
        Map<String,String> mapStatusStampWithStatus = new Map<String,String>();
        mapStatusStampWithStatus.put('Client_Request_Submission__c','Awaiting Vendor Submission');
        mapStatusStampWithStatus.put('In_Effect_Date__c','In Effect');
        mapStatusStampWithStatus.put('In_IMS_Review__c',Label.TPA_In_Review_By_IQVIA_Status);
        mapStatusStampWithStatus.put('Sent_for_Signature__c','Awaiting Vendor Signature');
        String purpose = '';
        String purposeCategory = '';
        String offeringCategory = '';
        List<ReportWrapper> lstInsert = new List<ReportWrapper>();
        for(TPA_Request__c agg : lstAgreement) {
            DateTime fromStatusDateTime = DateTime.valueof(agg.get(fromStatusField));
            DateTime toStatusDateTime = DateTime.valueof(agg.get(toStatusField));
            integer dateDiff = Integer.valueOf((toStatusDateTime.getTime() - fromStatusDateTime.getTime())/(1000*60*60*24));
            System.debug('date diff is::'+dateDiff);
            agg.Secondary_Client_Contact_Territory__c = UTL_TPA_Multilingual.mapCountryStatesCodes.get(agg.Secondary_Client_Contact_Territory__c+'~'+'C');
            if(dateDiff >= lowerRange && dateDiff <= upperRange) {
                ReportWrapper obReportWrapper = new ReportWrapper();
                obReportWrapper.objAgreement = agg;
                purpose = '';
                purposeCategory = '';
                offeringCategory = '';

                for( TPA_Purpose__c purp : agg.Purposes__r ) {
                    purpose += purp.Name + ', ';
                    if( purp.TPA_Purpose_Category__r.Category_Name__c != null && purp.TPA_Purpose_Category__r.Category_Name__c != ''
                    && purposeCategory.indexOf( purp.TPA_Purpose_Category__r.Category_Name__c ) == -1 )
                        purposeCategory += purp.TPA_Purpose_Category__r.Category_Name__c + ', ';
                }
                  
                for( TPA_Data_Asset__c asset : agg.Data_Assets__r ) {
                    if( asset.Data_Asset__c != null && asset.Data_Asset__r.Geo_Level__c != null && asset.Data_Asset__r.Geo_Level__c != ''
                    && offeringCategory.indexOf( asset.Data_Asset__r.Geo_Level__c ) == -1 )
                        offeringCategory += asset.Data_Asset__r.Geo_Level__c + ', ';
                }
                  
                purpose = ( purpose.length() != 0 ? purpose.subString( 0, purpose.length() - 2 ) : purpose );
                purposeCategory = ( purposeCategory.length() != 0 ? purposeCategory.subString( 0, purposeCategory.length() - 2 ) : purposeCategory );
                offeringCategory = ( offeringCategory.length() != 0 ? offeringCategory.subString( 0, offeringCategory.length() - 2 ) : offeringCategory );
                obReportWrapper.usesSelected = purpose;
                obReportWrapper.useCategories = purposeCategory;
                obReportWrapper.offeringCategories = offeringCategory;
                obReportWrapper.statusDuration = dateDiff;
                obReportWrapper.fromStatus = mapStatusStampWithStatus.get(fromStatusField);
                obReportWrapper.toStatus = mapStatusStampWithStatus.get(toStatusField);
                lstInsert.add(obReportWrapper);
            }        
        }
        return lstInsert;
    }
	
    public Class ReturnDataWaraper{
        List<ReportWrapper> resultData;
        Integer noOfTPAReqProcessed;
        String lastReqId;
    }
}