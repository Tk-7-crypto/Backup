public class CNT_TPA_OfferingsWithCategory {

    public static string currentUserProfileName {
        get {
            if(currentUserProfileName == null) {
                currentUserProfileName = UTL_TPA.getCurrentUserDetails().Profile.Name;
            }
            return currentUserProfileName;
        }
        set;
    }
    @remoteAction
    public static List<Offering_Record> getOfferingRecords(String reqId,String lastRecId,Integer pageSize){
        DateTime lastRecordCretedDateTime;
        if(lastRecId != null){
            lastRecordCretedDateTime = [select createddate from TPA_Data_Asset__c where id =: lastRecId limit 1][0].createddate;
        }
        
        List<Offering_Record> offRecordsToReturn = new List<Offering_Record>();
        List<TPA_Data_Asset__c> primaryOfferingsWithSec;
        if(lastRecordCretedDateTime == null){
            primaryOfferingsWithSec = [Select Id,Primary_Asset_Geo_Level__c,BU__c,Purpose__r.Name,Purpose__r.Other_Text__c,Asset_Name__c,RWE_Study_Name__c,RWE_Delivery_Date__c,Consumer_Profile_Study_Name__c,Consumer_Profile_Delivery_Date__c,Promotional_ROI_Study_Name__c,Promotional_ROI_Delivery_Date__c,APLD_Study_Name__c,APLD_Delivery_Date__c,STI_Data_Report_Name__c,Longitudanal_Patient_Diagonsis__c,Nostradata_Source_of_Business_LRx__c,CH_Retail_Profits__c,CH_Other_Outlet_Profits__c,CH_Hospital_Profits__c,CH_Combined_Hos_and_Ret_Profit_AU__c,Health_Plan_Claims_Data__c,LAAD_Longitudinal_Access_and_Adj_data__c,Payer_Companion_File__c,Provider_Companion_File__c,Patient_Reference_File__c,CWH_NZ_Scan_data__c,Customized_Data_Text__c,Other_Text__c,(Select Id,Secondary_Asset_Name__c,BrandImpact_Study_Name__c,BrandImpact_Delivery_Date__c,Channel_Dynamics_Study_Name__c,Channel_Dynamics_Delivery_Date__c,Pro_Voice_Study_Name__c,Pro_Voice_Delivery_Date__c,Pharmacy_Scan__c,Combined_Hos_and_Ret_Profit_AU__c,AU_Other_Outlet_Data_Profits__c,AU_DDD_Hospital_Profits__c,Nostradata_LRx_Volume__c,Nostradata_Source_of_Business_LRx__c,AU_Profits__c,STI_Data_Custom_Report_Name__c,Outliner_Label_Code__c,Outliner_Data_Period_Text__c,TPA_Data_Asset__r.APLD_Study_Name__c,TPA_Data_Asset__r.APLD_Delivery_Date__c,TPA_Data_Asset__r.Asset_Name__c From TPA_Secondary_Data_Assets__r) From TPA_Data_Asset__c where Request__c =: reqId order by CreatedDate Limit: pageSize];
        }
        else {
            primaryOfferingsWithSec = [Select Id,Primary_Asset_Geo_Level__c,BU__c,Purpose__r.Name,Purpose__r.Other_Text__c,Asset_Name__c,RWE_Study_Name__c,RWE_Delivery_Date__c,Consumer_Profile_Study_Name__c,Consumer_Profile_Delivery_Date__c,Promotional_ROI_Study_Name__c,Promotional_ROI_Delivery_Date__c,APLD_Study_Name__c,APLD_Delivery_Date__c,STI_Data_Report_Name__c,Longitudanal_Patient_Diagonsis__c,Nostradata_Source_of_Business_LRx__c,CH_Retail_Profits__c,CH_Other_Outlet_Profits__c,CH_Hospital_Profits__c,CH_Combined_Hos_and_Ret_Profit_AU__c,Health_Plan_Claims_Data__c,LAAD_Longitudinal_Access_and_Adj_data__c,Payer_Companion_File__c,Provider_Companion_File__c,Patient_Reference_File__c,CWH_NZ_Scan_data__c,Customized_Data_Text__c,Other_Text__c,(Select Id,Secondary_Asset_Name__c,BrandImpact_Study_Name__c,BrandImpact_Delivery_Date__c,Channel_Dynamics_Study_Name__c,Channel_Dynamics_Delivery_Date__c,Pro_Voice_Study_Name__c,Pro_Voice_Delivery_Date__c,Pharmacy_Scan__c,Combined_Hos_and_Ret_Profit_AU__c,AU_Other_Outlet_Data_Profits__c,AU_DDD_Hospital_Profits__c,Nostradata_LRx_Volume__c,Nostradata_Source_of_Business_LRx__c,AU_Profits__c,STI_Data_Custom_Report_Name__c,Outliner_Label_Code__c,Outliner_Data_Period_Text__c,TPA_Data_Asset__r.APLD_Study_Name__c,TPA_Data_Asset__r.APLD_Delivery_Date__c,TPA_Data_Asset__r.Asset_Name__c From TPA_Secondary_Data_Assets__r) From TPA_Data_Asset__c where Request__c =: reqId and CreatedDate >: lastRecordCretedDateTime order by CreatedDate Limit: pageSize];
        }
        String offNames = '';
        String useNames = '';
        for(TPA_Data_Asset__c tpaDataAsset : primaryOfferingsWithSec){
            offNames = '';
            useNames = '';
            if(tpaDataAsset.TPA_Secondary_Data_Assets__r != null && tpaDataAsset.TPA_Secondary_Data_Assets__r.size() > 0){
                String tempSecNames = '';
                for(TPA_Secondary_Data_Asset__c tpaSecDataAsset : tpaDataAsset.TPA_Secondary_Data_Assets__r){
                    tempSecNames += SRV_TPA_TPARequest.fullOfferingName(null,tpaSecDataAsset) + ' ,';
                }
                offNames += SRV_TPA_TPARequest.fullOfferingName(tpaDataAsset,null)+'<'+tempSecNames.subStringBeforeLast(',')+'>' + ' ,';
            }
            else{
                offNames += SRV_TPA_TPARequest.fullOfferingName(tpaDataAsset,null) + ' ,';
            }
            if(tpaDataAsset.Purpose__r.Name == 'Other'){
                useNames += 'Other Use Selected : ' + tpaDataAsset.Purpose__r.Other_Text__c;
            }
            else{
                useNames += tpaDataAsset.Purpose__r.Name;
            }
            
            offRecordsToReturn.add(new Offering_Record(tpaDataAsset.Id,offNames,tpaDataAsset.Primary_Asset_Geo_Level__c	,tpaDataAsset.BU__c,useNames));
        }

        return offRecordsToReturn;
    }

    public class Offering_Record {
        public Id recId;
        public String fullOfferingNames;
        public String BU;
        public String purposeName;
        public String offCategory;

        public Offering_Record(Id rId,String offNames,String cate,String country,String useName){
            recId = rId;
            fullOfferingNames = offNames;
            BU = country;
            purposeName = useName;
            offCategory = cate;
        }
    }
}