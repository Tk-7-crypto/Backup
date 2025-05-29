public class SRV_TPA_IMSUseOffAtypicalComb {  

    public static Map<String,String> mapATypicalCombination;
    public static Map<String,List<IMS_Use_Offering_Atypical_Combination__c>> mapSecReviewCombination;
    
    public static Map<String,String> getAtypicalCombinations()
    {
        if(mapATypicalCombination == null)
        {
            mapATypicalCombination = new Map<String,String>();
            List<IMS_Use_Offering_Atypical_Combination__c> lstATypicalCombinations = new List<IMS_Use_Offering_Atypical_Combination__c>();
            lstATypicalCombinations = [select id,Use_Category__c,Use_Name__c, Offering_Name__c,Secondary_Offering_Name__c,is_Approved_For_Future__c from IMS_Use_Offering_Atypical_Combination__c where isActive__c = true and RecordType.Name != 'TPA Secondary Reviews'];
            for(IMS_Use_Offering_Atypical_Combination__c objTypicalCombination : lstATypicalCombinations)
            {
                String key = objTypicalCombination.Use_Category__c+':'+objTypicalCombination.Use_Name__c+':'+objTypicalCombination.Offering_Name__c;
                if(objTypicalCombination.Secondary_Offering_Name__c != null)
                    key += ':'+ objTypicalCombination.Secondary_Offering_Name__c;
                String value = objTypicalCombination.is_Approved_For_Future__c+':'+objTypicalCombination.id;
                mapATypicalCombination.put(key, value); 
            }
        }
        return mapATypicalCombination;
    }
    
    
    public static Map<String, List<IMS_Use_Offering_Atypical_Combination__c>> getSecReviewCombinations(Set<Id> vendorIdSet) {
        if(mapSecReviewCombination == null || mapSecReviewCombination.size() == 0) {
            mapSecReviewCombination = new Map<String, List<IMS_Use_Offering_Atypical_Combination__c>>();
            List<IMS_Use_Offering_Atypical_Combination__c> lstATypicalCombinations = new List<IMS_Use_Offering_Atypical_Combination__c>();
            lstATypicalCombinations = [select id,Vendor_Name__c, Use_Name__r.Primary_Purpose_Name__c, Use_Category__r.Category_Name__c, Use_Category__c,Use_Name__c,Offering_Country_del__c,
            Offering_Name__c,Secondary_Offering_Name__c,Secondary_Offering_Name__r.Secondary_Asset_Name__c, Offering_Name__r.Asset_Name__c, Action_Needed_By__c, Mgmt_Review_email__c,Legal_Review_Email__c,is_Approved_For_Future__c, Vendor_Name__r.Name  
            from IMS_Use_Offering_Atypical_Combination__c where isActive__c = true and is_Approved_For_Future__c = false and Vendor_Name__c In :vendorIdSet and RecordType.Name = 'TPA Secondary Reviews' ];
            for(IMS_Use_Offering_Atypical_Combination__c objTypicalCombination : lstATypicalCombinations) {
                String key = ''; 
                if(objTypicalCombination.Vendor_Name__c != null) {
                    key += objTypicalCombination.Vendor_Name__c + ':';
                }
                key += objTypicalCombination.Use_Category__c+':'+objTypicalCombination.Use_Name__c+':';
                    key += objTypicalCombination.Offering_Name__c != null ? (objTypicalCombination.Offering_Name__c + '') : '';
                if(objTypicalCombination.Secondary_Offering_Name__c != null) {
                    key += ':'+ objTypicalCombination.Secondary_Offering_Name__c;
                }               
                if(!mapSecReviewCombination.containsKey(key)) {
                    mapSecReviewCombination.put(key, new list<IMS_Use_Offering_Atypical_Combination__c>{objTypicalCombination});
                } else {
                    mapSecReviewCombination.get(key).add(objTypicalCombination);
                }
            }
        }
        return mapSecReviewCombination;
    }
}
