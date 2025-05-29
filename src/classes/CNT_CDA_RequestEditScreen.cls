/**
* Controller for LXC_CDA_RequestEditScreen
*/
public with sharing class CNT_CDA_RequestEditScreen {
    
    @AuraEnabled  
    public static Map<String, List<String>> getDependentOptionsImpl(string objApiName, string contrfieldApiName, string depfieldApiName) {
        Map<String, List<String>> objResults = UTL_CDA_BitSet.getDependentOptions(objApiName, contrfieldApiName, depfieldApiName);
        return objResults;
    } 
    
    @AuraEnabled
    public static CDA_Account__c getCdaAccountInfo(String recordId) {
        return [SELECT Id, 
                CDA_Account_Name__c, 
                Complete_Address__c, 
                Competitor_flag__c,
                Individual_Indicator__c,
		Is_Master_Account__c 
                FROM CDA_Account__c
                WHERE Id =: recordId LIMIT 1];
    }
    
    /* @AuraEnabled
    public static CDA_Settings__c getcdaCustomSetting() {
        return CDA_Settings__c.getOrgDefaults();
    } */
    
    @AuraEnabled
    public static QI_Legal_Entity__c getQiLegalEntityInfo(String recordId) {
        return [SELECT Id, 
                       Name, 
                       QI_Legal_Entity_Address__c,
                       Location_of_Governing_Law__c,
                       IQVIA_Business_Area__c,
                       is_For_RDS_Q2_Broad__c,
                       Is_Signatories_Not_Available__c,
                       Is_Active__c
                FROM QI_Legal_Entity__c
                WHERE Id =: recordId LIMIT 1];
    }
    
    @AuraEnabled 
    public static UTL_CDA_RequestEditWrapper getRequestEditDefaultValues(ID cdaRequestId) {
        UTL_CDA_RequestEditWrapper wrapperObj = new UTL_CDA_RequestEditWrapper();
        
        List<String> fieldsList = new List<String>{ 'QuintilesIMS_Business__c',
            'CDA_Type__c',
            'CDA_Id__c',
            'CDA_Effective_Date__c',
            'Disclosure_Period__c', 
            'CDA_Language__c',
            'Requestor_Carbon_Copies__c',
            'CDA_Source__c',
            'Competitor_Flag__c',
            'Project_Specific_Indicator__c', 
            'Customer_Specified_Vendor_Template__c',
            'CDA_Format__c', 
            'Originating_Requestor_Flag__c',
            'Customer_Consent_to_Disclose__c',
            'Audit_Type__c', 
            'Cust_Legal_Entity_Name__c', 
            'Cust_Legal_Entity_Address__c',
            'Customer_Legal_Entity_Name_Other__c',
            'Customer_Legal_Entity_Street_Other__c',
            'Customer_Legal_Entity_Country_Other_PL__c',
            'Customer_Legal_Entity_State_Other_PL__c',
            'Customer_Legal_Entity_City_Other__c',
            'Customer_Legal_Entity_ZipCode_Other__c',
            'Competitor_Contracting_Capacity__c',
            'Competitor_Originating_from_Sponsor__c', 
            'What_is_the_Study_Sponsor_situation__c',
            'Colaboration_Business_Line_Services__c',
            'Sponsor_Legal_Entity__c',
            'Sponsor_Legal_Entity_Address__c',
            'Sponsor_Legal_Entity_Name_Other__c',
            'Sponsor_Consent_to_Disclose__c',
            'Competitor_System_Access__c',
            'Systems_To_Be_Accessed__c',
            'Purpose_for_Working_for_a_Competitor__c',
            'Description_of_work_provided_to_Customer__c',
            'Desc_of_Work_provided_to_Cust_By_Comp__c',
            'Competitor_information_disclosed_to_QI__c',
            'QI_information_disclosed_to_competitor__c',
            'Is_Protocol_Number_Known__c',
            'Protocol_Number__c',
            'Is_Protocol_Title_Known__c',
            'Protocol_Title__c',
            'Project_Description_Textarea__c',
            'Protocol_Title_Long_Textarea__c',
            'Project_Description_Long_Textarea__c',
            'Originating_Requestor_First_Name__c',
            'Originating_Requestor_Last_Name__c',
            'Originating_Requestor_IQVIA_Email__c',
            'Requestor_Admin_Email_Flag__c',
            'QI_Legal_Entity_Name__c',
            'Location_of_Governing_Law__c',
            'Recipient_Account__c',
            'Recipient_Account_Address__c',
            'Recipient_Account_Name_Other__c',
            'Recipient_Account_Street_Other__c',
            'Recipient_Account_Country_Other_PL__c',
            'Recipient_Account_State_Other_PL__c',
            'Recipient_Account_City_Other__c',
            'Recipient_Account_ZipCode_Other__c',
            'Recipient_Point_of_Contact_First_Name__c',
            'Recipient_Point_of_Contact_Last_Name__c',
            'Recipient_Point_of_Contact_Email_Address__c',
            'Recipient_Point_of_Contact_Title__c',
            'Recipient_Point_of_Contact_Telephone_Num__c',
            'Additional_Contact_Flag__c',
            'Additional_Contact_Details__c',
            'Individual_Indicator__c',
            'IsSiteSignatorySameAsSiteContact__c',
            'Site_Contact_Email_Address__c',
            'Site_Contact_First_Name__c',
            'Site_Contact_Last_Name__c'};
                
        wrapperObj.cdaRequestFieldsDetailMap = new UTL_Sobject('CDA_Request__c').getSobjectFieldsDetailMap(fieldsList);
        
        wrapperObj.loggedIdUserDetail = UTL_CDAUtility.getUserDetails();
        
        wrapperObj.iqviaBusinessCdaTypeDependencyMap = UTL_CDA_BitSet.getDependentOptions('CDA_Request__c', 'QuintilesIMS_Business__c', 'CDA_Type__c');
        
        wrapperObj.iqviaBusinessDisclosurePeriodDependencyMap = UTL_CDA_BitSet.getDependentOptions('CDA_Request__c', 'QuintilesIMS_Business__c', 'Disclosure_Period__c');
        
        wrapperObj.cdaTypeCdaLanguageDependencyMap = UTL_CDA_BitSet.getDependentOptions('CDA_Request__c', 'CDA_Type__c', 'CDA_Language__c');
        
        wrapperObj.cdaTypeCompetContractCapDependencyMap = UTL_CDA_BitSet.getDependentOptions('CDA_Request__c', 'CDA_Type__c', 'Competitor_Contracting_Capacity__c');
        
        wrapperObj.competContractStudySponDependencyMap = UTL_CDA_BitSet.getDependentOptions('CDA_Request__c', 'Competitor_Contracting_Capacity__c', 'What_is_the_Study_Sponsor_situation__c');
        
        wrapperObj.custLegalEntityCountryStateDependencyMap = UTL_CDA_BitSet.getDependentOptions('CDA_Request__c', 'Customer_Legal_Entity_Country_Other_PL__c', 'Customer_Legal_Entity_State_Other_PL__c');
        
        wrapperObj.recipientAccCountryStateDependencyMap = UTL_CDA_BitSet.getDependentOptions('CDA_Request__c', 'Recipient_Account_Country_Other_PL__c', 'Recipient_Account_State_Other_PL__c');
        
        wrapperObj.loggedInUserType = SRV_CDA_CDARequest.getUserPermission();
        
        wrapperObj.cdaSettingValues = CDA_Settings__c.getOrgDefaults();
        
        wrapperObj.cdaRequest = SRV_CDA_CDARequest.getCDARequest(cdaRequestId);

        //loading Additional IQVIA contact details
        wrapperObj.cdaAdditionalContactWrapperList = UTL_CDAUtility.getAdditionalContactsDetails(cdaRequestId);

        return wrapperObj;
    }
    
    @AuraEnabled
    public static CDA_Request__c saveRequest(CDA_Request__c cdaRecord) {
        system.debug('In saveRequest: edit part: ' + cdaRecord);
        //try{
            if(cdaRecord != null) {
                if(cdaRecord.Status__c == UTL_CDAUtility.STATUS_INDRAFT) {
                    upsert cdaRecord;
                }
                else {
                    system.debug('In saveRequest: edit part: ' + cdaRecord);
                    Map<Id, CDA_Account__c> accountToBeUpdated =  new Map<Id, CDA_Account__c>();
                    CDA_Account__c cdaAccountC = new CDA_Account__c();
                    CDA_Legal_POC_Cross_Walk__c cdaLegalPOC = new CDA_Legal_POC_Cross_Walk__c();
                    
                    if(cdaRecord.Sponsor_Legal_Entity__c != null) {
                        if(accountToBeUpdated.containsKey(cdaRecord.Sponsor_Legal_Entity__c)) {
                            cdaAccountC = accountToBeUpdated.get(cdaRecord.Sponsor_Legal_Entity__c);
                        } else {
                            cdaAccountC = SRV_CDA_CDARequest.getCDAAccount(cdaRecord.Sponsor_Legal_Entity__c);
                        }
                        if(cdaRecord.What_is_the_Study_Sponsor_situation__c == UTL_CDAUtility.STUDYSPONSORIDENTIFIED) {
                            cdaAccountC.CDA_Sponsor_Indicator__c = true;
                        }
                        
                        if(cdaAccountC.Id != null ) {
                            accountToBeUpdated.put(cdaAccountC.Id, cdaAccountC);
                        }
                    }
                    if(cdaRecord.Recipient_Account__c != null) {
                        cdaAccountC = new CDA_Account__c();
                        if(accountToBeUpdated.containsKey(cdaRecord.Recipient_Account__c)) {
                            cdaAccountC = accountToBeUpdated.get(cdaRecord.Recipient_Account__c);
                        }
                        else {
                            cdaAccountC = SRV_CDA_CDARequest.getCDAAccount(cdaRecord.Recipient_Account__c);
                        }
                        if(cdaRecord.Competitor_Flag__c == UTL_CDAUtility.YES) {
                            cdaAccountC.Competitor_flag__c = true;
                        }
                        if(cdaRecord.CDA_Type__c == UTL_CDAUtility.AUDITOR) {
                            cdaAccountC.CDA_Auditor_Indicator__c = true;
                        } else if (cdaRecord.CDA_Type__c == UTL_CDAUtility.CUSTOMER) {
                            cdaAccountC.CDA_Customer_Indicator__c = true;
                        } else if (cdaRecord.CDA_Type__c == UTL_CDAUtility.VENDOR) {
                            cdaAccountC.CDA_Vendor_Indicator__c = true;
                        } else if(cdaRecord.CDA_Type__c == UTL_CDAUtility.CEVA) {
                            cdaAccountC.CEVA_Committee_Member__c = true;
                        }
                        if(cdaAccountC.Id != null ){
                            accountToBeUpdated.put(cdaAccountC.Id, cdaAccountC);
                        }
                    }
                    
                    if(cdaRecord.Location_of_Governing_Law__c != null) {
                        CDA_Approved_Governing_Law_Location__c governingLawRecord = SRV_CDA_CDARequest.getGoverningLaw(cdaRecord.Location_of_Governing_Law__c);
                        
                        String glStr = governingLawRecord.Name;
                        if(UTL_CDAUtility.governingLawNameAndPrintNameMap.containsKey(glStr)) {
                            String glDisplayStr = UTL_CDAUtility.governingLawNameAndPrintNameMap.get(glStr).Display_Text__c != null ? UTL_CDAUtility.governingLawNameAndPrintNameMap.get(glStr).Display_Text__c : glStr;
                            cdaRecord.Governing_Law_Display_Text__c = glDisplayStr;
                        } else {
                            cdaRecord.Governing_Law_Display_Text__c = glStr;
                        }
                    }
                    
                    cdaRecord.Awaiting_Requestor_Submission_Date__c = System.now();
                    
                    if(cdaRecord.Negotiator_Assigned_List__c == UTL_CDAUtility.SELF_SERVICE_ONLY) {
                        cdaRecord.Negotiator_Assigned_List__c = UTL_CDAUtility.NEGO_NOT_ASSIGN;
                    }
                    
                    if(SRV_CDA_CDARequest.isRequestorAdmin && cdaRecord.Originating_Requestor_Flag__c == UTL_CDAUtility.YES){
                        cdaRecord.On_Behalf_of_User_Full_Name__c = cdaRecord.Originating_Requestor_Full_Name__c != null ? cdaRecord.Originating_Requestor_Full_Name__c : cdaRecord.Originating_Requestor_First_Name__c +' '+cdaRecord.Originating_Requestor_Last_Name__c;
                        cdaRecord.On_Behalf_of_User_Email__c = cdaRecord.Originating_Requestor_IQVIA_Email__c;
                    }else {
                        cdaRecord.On_Behalf_of_User_Full_Name__c = cdaRecord.Owner.Name != null ? cdaRecord.Owner.Name : UTL_CDAUtility.getUserDetails().Name;
                        cdaRecord.On_Behalf_of_User_Email__c = cdaRecord.Owner.Email != null ? cdaRecord.Owner.Email : UTL_CDAUtility.getUserDetails().Email; 
                    }

                    //this handles the non-english attorney scenario
                    if(cdaRecord.CDA_Language__c != 'English' && ((cdaRecord.CDA_Source__c == UTL_CDAUtility.CDASOURCE_QUINTILESIMS && cdaRecord.CDA_Format__c == UTL_CDAUtility.CDA_FORMAT_PROWORD) || cdaRecord.CDA_Source__c == UTL_CDAUtility.CDASOURCE_EXTERNAL)) {
                        cdaLegalPOC = SRV_CDA_CDARequest.getCDALegalPOC(cdaRecord.CDA_Language__c);
                        System.debug('####CNT_CDA_RequestEditScreen.saveRequest cdaLegalPOC for '+cdaRecord.CDA_Language__c+': '+cdaLegalPOC);
                        //update the Legal POC under CDA Request to show in View page
                        if(cdaLegalPOC != null) {
                            cdaRecord.Legal_POC_Cross_Walk__c = cdaLegalPOC.Id;
                        }
                    }
                    
                    upsert cdaRecord;
                    
                    system.debug('In EditController: cdaRecord Upserted.');

                    if(cdaRecord.get('CDA_Id__c') != null) {
                        Set<string> cdaIds = new Set<string>();
                        cdaIds.add((String)cdaRecord.get('CDA_Id__c'));
                        SRV_CDA_DocusignStatus.setVoidToDocusignEnvelope(cdaIds);
                    }
                    
                    if(accountToBeUpdated != null && accountToBeUpdated.size() > 0) {
                        update accountToBeUpdated.values();
                    }
                    
                    
                }
            }
        return cdaRecord; 
    }
}
