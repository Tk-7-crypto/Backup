/**
* Author : Babita Dadarwal
* Date : 15 Dec 2016
* Name : TPA_Atypical_UseOfferings_ManualReview
* Decs : Controller for TPA_Atypical_UseOfferings_ManualReview Page
*/

global class CNT_TPA_AtypUseOffMnnualReview {
    public id requestID {get; set;}
    
    public list<wrapperClass> atypicalUseOfferingWrapperList {get; set;}
    public string JsonUseOfferingList {get; set;}
    
    public void loadData() {
        String requestID = ApexPages.currentPage().getParameters().get('requestID');
        atypicalUseOfferingWrapperList = new list<wrapperClass>();
        
        if(requestID != null && requestID != '') {
            for(TPA_Use_Offering_Atypical_Combination__c useOfferingCom : [select id,
                                              IMS_Use_Offering_Atypical_Combination__c,
                                              IMS_Use_Offering_Atypical_Combination__r.Use_Category__c, 
                                              IMS_Use_Offering_Atypical_Combination__r.Use_Category__r.Category_Name__c,
                                              IMS_Use_Offering_Atypical_Combination__r.Use_Name__c,
                                              IMS_Use_Offering_Atypical_Combination__r.Use_Name__r.Primary_Purpose_Name__c, 
                                              IMS_Use_Offering_Atypical_Combination__r.Offering_Name__c, 
                                              IMS_Use_Offering_Atypical_Combination__r.Offering_Name__r.Asset_Name__c, 
                                              IMS_Use_Offering_Atypical_Combination__r.Secondary_Offering_Name__c,
                                              IMS_Use_Offering_Atypical_Combination__r.Secondary_Offering_Name__r.Secondary_Asset_Name__c, 
                                              IMS_Use_Offering_Atypical_Combination__r.is_Approved_For_Future__c, 
                                              TPA_Request__r.Name,
                                              LastModifiedBy.Name, 
                                              LastModifiedDate
                                      from TPA_Use_Offering_Atypical_Combination__c
                                      where TPA_Request__c = : requestID])
            {
                atypicalUseOfferingWrapperList.add(new wrapperClass(useOfferingCom.IMS_Use_Offering_Atypical_Combination__c,
                                                                    useOfferingCom.IMS_Use_Offering_Atypical_Combination__r.Use_Category__r.Category_Name__c,
                                                                    useOfferingCom.IMS_Use_Offering_Atypical_Combination__r.Use_Name__r.Primary_Purpose_Name__c, 
                                                                    useOfferingCom.IMS_Use_Offering_Atypical_Combination__r.Offering_Name__r.Asset_Name__c,
                                                                    useOfferingCom.IMS_Use_Offering_Atypical_Combination__r.Secondary_Offering_Name__r.Secondary_Asset_Name__c,
                                                                    useOfferingCom.IMS_Use_Offering_Atypical_Combination__r.is_Approved_For_Future__c,
                                                                    useOfferingCom.TPA_Request__r.Name, 
                                                                    useOfferingCom.LastModifiedBy.Name, 
                                                                    useOfferingCom.LastModifiedDate
                                                                    ));
            }
        }
        
        JsonUseOfferingList = JSON.serialize( atypicalUseOfferingWrapperList );
        system.debug('JsonUseOfferingList = ' + JsonUseOfferingList);
    }
    
    @remoteAction
    global static String submitApproval(String JsonUseOfferingList)
    {
        List<wrapperClass> tpaAypicalUseOffWrapperList = (List<wrapperClass>)JSON.deserialize( JsonUseOfferingList, List<wrapperClass>.Class );
        system.debug('tpaAypicalUseOffWrapperList = ' + tpaAypicalUseOffWrapperList );
        
        map<id, wrapperClass> wrapperDataMap = new map<id, wrapperClass>();
        
        for(wrapperClass obj : tpaAypicalUseOffWrapperList)
        {
            wrapperDataMap.put(obj.parentId, obj);
        }
        
        list<IMS_Use_Offering_Atypical_Combination__c> imsAypicalUseOffList = new list<IMS_Use_Offering_Atypical_Combination__c>();
        
        for(IMS_Use_Offering_Atypical_Combination__c imsUseOffComb : [select id, is_Approved_For_Future__c from IMS_Use_Offering_Atypical_Combination__c where Id in : wrapperDataMap.keySet() ])
        {
            imsUseOffComb.is_Approved_For_Future__c = wrapperDataMap.get(imsUseOffComb.id).alwaysApproved;
            imsAypicalUseOffList.add(imsUseOffComb);
        }
        
        if( imsAypicalUseOffList.size() > 0 )
        {
            update imsAypicalUseOffList;
            return 'Success';
        }
        else
        {
            return 'No Change';
        }
        
    }
    
    public class wrapperClass
    {
        public ID parentId {get; set;}
        public String useCategory {get; set;}
        public String useName {get; set;}
        public String priOffering {get; set;}
        public String secOffering {get; set;}
        public Boolean alwaysApproved {get; set;}
        public String TPANumber {get; set;}
        public String LastModifiedBy {get; set;}
        public DateTime LastModifiedDate {get; set;}
        
        public wrapperClass(ID parentId, String useCategory, String useName, String priOffering, String secOffering, Boolean alwaysApproved, String TPANumber, String LastModifiedBy, DateTime LastModifiedDate)
        {
            this.parentID = parentId;
            this.useCategory = useCategory;
            this.useName = useName;
            this.priOffering = priOffering;
            this.secOffering = secOffering;
            this.alwaysApproved = alwaysApproved;
            this.TPANumber = TPANumber;
            this.LastModifiedBy = LastModifiedBy;
            this.LastModifiedDate = LastModifiedDate; 
        }
    }
    
}