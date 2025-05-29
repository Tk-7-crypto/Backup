public class SLT_AMAAgreementDetail extends fflib_SObjectSelector {
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            AMA_Agreement_Detail__c.Id,
            AMA_Agreement_Detail__c.Name,
            AMA_Agreement_Detail__c.Agreement_Start_Date__c,
            AMA_Agreement_Detail__c.Initial_Termination_Date__c,
            AMA_Agreement_Detail__c.Agreement_End_Date__c,
            AMA_Agreement_Detail__c.AMA_TypeOfPrescriberLevelData__c,
            AMA_Agreement_Detail__c.AMA_Services_Provided__c,
            AMA_Agreement_Detail__c.Vendor_Contact_Name__c,
            AMA_Agreement_Detail__c.Vendor_Legal_Name__c,
            AMA_Agreement_Detail__c.Contract_Type__c,
            AMA_Agreement_Detail__c.AMA_Howlong_SP_has_Data_Access__c,
            AMA_Agreement_Detail__c.AMA_Response__c,
            AMA_Agreement_Detail__c.Date_of_AMA_Response_for_Offshore__c,
            AMA_Agreement_Detail__c.Date_of_AMA_Response_for_Offshore__c,
            AMA_Agreement_Detail__c.AMA_Project_Uses_Value__c,
            AMA_Agreement_Detail__c.Technologies_to_access_AMA_PPD_by_vendor__c,
            AMA_Agreement_Detail__c.Other_technology_to_access_AMA_PPD__c,
            AMA_Agreement_Detail__c.Vendor_employee_access_data_in_country__c,
            AMA_Agreement_Detail__c.Status_of_Offshore_Process__c,
            AMA_Agreement_Detail__c.Questions_for_Vendor_Response__c,
            AMA_Agreement_Detail__c.AMA_reasons_why_offshore_not_approved__c,
            AMA_Agreement_Detail__c.Vendor_Name_who_requested_offshore__c,
            AMA_Agreement_Detail__c.Title_for_vendor_who_requested_offshore__c,
            AMA_Agreement_Detail__c.Date_vendor_responded_for_offshore__c,
            AMA_Agreement_Detail__c.Last_AMA_offshore_reminder_mail_sent__c,
            AMA_Agreement_Detail__c.Client__c,
            AMA_Agreement_Detail__c.Vendor_Employee_Accessed_Data_in_country__c,
            AMA_Agreement_Detail__c.Other_Technology_for_Remote_Access__c,
            AMA_Agreement_Detail__c.Technology_s_selected_for_remote_access__c,
            AMA_Agreement_Detail__c.Vendor_Employee_Store_Data_in_country__c,
            AMA_Agreement_Detail__c.Vendor_require_Remote_Access_from_NonUS__c,
            AMA_Agreement_Detail__c.Vendor_req_Storage_Permission_from_NonUS__c,
            AMA_Agreement_Detail__c.Ex_US_Legal_Entity_Name_Remote_Access__c,
            AMA_Agreement_Detail__c.Ex_US_Legal_Entity_Name_Offshore_Storage__c,
            AMA_Agreement_Detail__c.TPA_Request__c
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return AMA_Agreement_Detail__c.sObjectType;
    }

    /**
     * This is the instance object of this class
     * @return static instance of class
     */
    public static SLT_AMAAgreementDetail instance {
        get {
            if(instance == null) {
                instance = new SLT_AMAAgreementDetail();
            }
            return instance;
        }
        set;
    }

    public List<AMA_Agreement_Detail__c> getAMAAgreementDetailsById(Id reqId, Set<String> fieldSet, Integer recordLimit) {
        return (List<AMA_Agreement_Detail__c>) Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition('Id = :reqId').setLimit(recordLimit).toSOQL());
    }
    
    public List<AMA_Agreement_Detail__c> getAMAAgreementDetailById(Boolean includeDefaultFields, Set<Id> idSet, Set<String> fieldSet){
        return (List<AMA_Agreement_Detail__c>)Database.query(newQueryFactory(includeDefaultFields).selectFields(fieldSet).setCondition('Id IN :idSet').toSOQL());
    }
}