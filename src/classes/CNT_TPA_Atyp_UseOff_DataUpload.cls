/**
* Author : Babita Dadarwal
* Date : 16 Dec 2016
* Name : CNT_TPA_Atyp_UseOff_DataUpload
* Decs : Controller of VFP_TPA_Atypical_UseOffering_DataUplaod Page
* ER : 3045
*/

public class CNT_TPA_Atyp_UseOff_DataUpload {

    //Map of all exiting master use offering atypical combinations
    //Key : Use-Category-Id + Use-Id + Pri-Offering-Id [+ Sec_Offering-Id]
    //Value : IMS_Use_Offering_Atypical_Combination Object
    Public Static Map<String, IMS_Use_Offering_Atypical_Combination__c> atypicalUseOffCombMap {get; set;}
    
    public CNT_TPA_Atyp_UseOff_DataUpload() {
        loadData();
    }
    
    @RemoteAction
    public static Map<String, IMS_Use_Offering_Atypical_Combination__c > saveRequest(String useOffCombDetail) {
        Type t = Type.forName('IMS_Use_Offering_Atypical_Combination__c');
        IMS_Use_Offering_Atypical_Combination__c useOffCombObj = (IMS_Use_Offering_Atypical_Combination__c)JSON.deserialize(useOffCombDetail, t);
        if( useOffCombObj != null) {
            useOffCombObj.RecordTypeId  = Schema.SObjectType.IMS_Use_Offering_Atypical_Combination__c.getRecordTypeInfosByName().get('Use Offering Atypical Combination').getRecordTypeId();
            upsert useOffCombObj;
            CNT_TPA_Atyp_UseOff_DataUpload.loadData();
            return atypicalUseOffCombMap;
        }
        return null;
    }
    
    public static void loadData() {
        atypicalUseOffCombMap = new map<String, IMS_Use_Offering_Atypical_Combination__c >();
        List<IMS_Use_Offering_Atypical_Combination__c> atypicalUseOffCombList = new List<IMS_Use_Offering_Atypical_Combination__c>();
        Set<String> fieldSet = new Set<String> {'Use_Category__r.Category_Name__c', 
                                                'Use_Name__r.Primary_Purpose_Name__c',
                                                'Offering_Name__r.Asset_Name__c', 
                                                'Secondary_Offering_Name__r.Secondary_Asset_Name__c', 
                                                'LastModifiedBy.Name', 
                                                'LastModifiedDate'
                                               };
        atypicalUseOffCombList = SLT_IMSUseOfferingAtypicalCombination.instance.selectAllAtypicalUseOffComb(fieldSet);
        for(IMS_Use_Offering_Atypical_Combination__c combObj : atypicalUseOffCombList) { 
            String key = '';
            if(combObj.Secondary_Offering_Name__c == null)
                key = '' + combObj.Use_Category__c + combObj.Use_Name__c + combObj.Offering_Name__c;
            else
                key = '' + combObj.Use_Category__c + combObj.Use_Name__c + combObj.Offering_Name__c + combObj.Secondary_Offering_Name__c;
            
            atypicalUseOffCombMap.put(key, combObj);
        }
    }
    
    public string getJSONAtypicalUseOffCombMap() {
        system.debug('atypicalUseOffCombMap : ' + atypicalUseOffCombMap );
        return JSON.serialize(atypicalUseOffCombMap);       
    }
    
    //List of all master use categories
    public static String jsonUseCategoryList {
        get {
            if(jsonUseCategoryList == null || jsonUseCategoryList == '') { 
                list<TPA_Purpose_Category__c> useCategoryList = new list<TPA_Purpose_Category__c>();
                useCategoryList = SLT_TPAPurposeCategory.instance.selectAllPurposeCategory(new Set<String>(), 'Category_Name__c', 'asc');
                system.debug('useCategoryList = ' + useCategoryList);
                jsonUseCategoryList = JSON.serialize(useCategoryList);
                system.debug('jsonUseCategoryList = ' + jsonUseCategoryList);
            }
            return jsonUseCategoryList;
        }
        set;
    }    
    
    //List of all master uses-Category combinations
    public static String jsonUse_categoryCombList {
        get {
            if(jsonUse_categoryCombList == null || jsonUse_categoryCombList == '') {
                list<IMS_TPA_Purpose_Category__c> use_Category_combList = new list<IMS_TPA_Purpose_Category__c>();
                Set<String> fieldSet = new Set<String> {'IMS_TPA_Purpose__r.Primary_Purpose_Name__c'};
                use_Category_combList  = SLT_IMSTPAPurposeCategory.instance.selectAllActiveIMSTPAPurposeCategory(fieldSet, 'IMS_TPA_Purpose__r.Primary_Purpose_Name__c', 'asc');
                jsonUse_categoryCombList = JSON.serialize(use_Category_combList);
                system.debug('use_Category_combList size = ' + use_Category_combList.size());
                system.debug('jsonUse_categoryCombList = ' + jsonUse_categoryCombList + 'use_Category_combList = ' + use_Category_combList);
            }
            return jsonUse_categoryCombList;
        }
        set;
    }
    
    //List of all master offerings
    public static String jsonOfferingList {
        get {
            if(jsonOfferingList == null || jsonOfferingList == '') {
                list<IMS_Data_Asset__c> offeringsList = new list<IMS_Data_Asset__c>();
                offeringsList  = SLT_IMSDataAsset.instance.selectAllIMSDataAssetWithSec(new Set<String>(), 'Asset_Name__c', 'asc');
                jsonOfferingList = JSON.serialize(offeringsList);
                system.debug('offeringsList size = ' + offeringsList.size());
                system.debug('jsonOfferingList = ' + jsonOfferingList + 'offeringsList = ' + offeringsList);
            }
            return jsonOfferingList;
        }
        set;
    }
    
    //Get list of all offering countries
    public string getRegionList() {
        List<string> requestedData = new List<string>();
        requestedData.add('--None--');
        Schema.DescribeFieldResult fieldResult = TPA_Request__c.Region__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            requestedData.add(f.getLabel());
        }
        requestedData.sort();
        return JSON.serialize(requestedData);
    } 
    
    //Get List of all Offering Categories
    public string getOfferingCategoryList() {
        List<string> requestedData = new List<string>();
        requestedData.add('--None--');
        Schema.DescribeFieldResult fieldResult = IMS_Data_Asset__c.Geo_Level__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            requestedData.add(f.getLabel());
        }
        return JSON.serialize(requestedData);
    }
}