/**
* Description: Controller class for lwcCrmOliAddressSelector
* Authour: Ronak Mehta
*/
public class CNT_CRM_OliAddressSelector {
    /*Additional Fields
Id, Bill_To_SAP_Contact__c,Revenue_Analyst__r.User__r.Id,Carbon_Copy_SAP_Contact__c,
Bill_To__c,Carbon_Copy__c,Cover_Sheet_SAP_Contact__c,Cover_Sheet__c, Ship_To_SAP_Contact__c,Ship_To__c, Sold_To__c, X2nd_Copy_SAP_Contact__c, 
X2nd_Copy__c,X2nd_Address__c,Manual_Handling_In_Sap__c,RecordTypeId,Sap_Contract__c,Sap_Master_Contract__c,
Renewal__c,Sales_Org_Code__c, Bill_To__r.PO_Required__c,Opportunity__r.Opportunity_Number__c, Revenue_Analyst__r.Owner.Type
*/
    
    public Static Final Set<String> addressFieldSet = new Set<String>{'Id', 'Name', 'Street__c', 'City__c', 'State__c', 'PostalCode__c', 'Country__c', 'International_Name__c', 'International_Street__c', 'International_City__c', 'International_State__c', 'International_PostalCode__c', 'International_Country__c', 'SAP_Reference__c'};
    public Static Final Set<String> sapContactFieldSet = new Set<String>{'Id', 'Name', 'First_Name__c', 'Last_Name__c', 'First_Name_Local__c', 'Last_Name_Local__c', 'SAP_Contact_Number__c', 'Address__r.Country__c', 'Address__c', 'Address__r.Id'};
    public Static Final Set<String> bnfFieldSet = new Set<String>{'Name', 'BNF_Status__c', 'Opportunity__r.Account.Name', 'Opportunity__r.Account.SAP_Reference__c', 'Opportunity__c', 'Opportunity__r.AccountId', 'Opportunity__r.Account.Region_Territory__c'};
    Public Static Final String BNF_SUBMITTED_ERROR = 'BNF is currently submitted for approval and cannot be edited.';
    Public Static Final String BNF_SAP_CONTRACT_CONFIRMED_ERROR = 'Contract/Order has been created in SAP and BNF cannot be edited.';
    Public Static Final String NO_ADDRESS_ERROR = 'There is no Validated address on the account please go to Account and created and validate.';
    
    /**
     * This Method to return basic data to render lwc
     * @param Id bnfId
     * @return Map<String, Object>
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> fetchAllDetails(Id bnfId){
        Map<String, Object> returnMap = new Map<String, Object>();
        List<String> errorMsg = new List<String>();
        Map<Id,List<Map<String,String>>> addressToContactListMap = new Map<Id,List<Map<String,String>>>();
        List<Map<String,String>> countryOptions = new List<Map<String,String>>();
        BNF2__c bnf = new SLT_BNF().selectById(new Set<Id>{bnfId}, bnfFieldSet)[0];
        Id BnfAccountId = bnf.Opportunity__r.AccountId;
        
        User currentUser = new SLT_User().getUserById(new Set<Id> {UserInfo.getUserId()}, new Set<String>{'Profile.Name', 'User_Country__c'})[0];
        
        countryOptions.add(new Map<String,String> {'label'=>'--None--','value'=> ''});
        for(Schema.PicklistEntry pickEntry : Account.Region_Territory__c.getDescribe().getPicklistValues()){
            countryOptions.add(new Map<String,String> {'label'=>pickEntry.getLabel(), 'value'=> pickEntry.getValue()});
        }
        returnMap.put('bnf', bnf);
        returnMap.put('user', currentUser);
        returnMap.put('countryOptions', countryOptions);
        
        List<ProcessInstanceWorkitem> piwi = new SLT_ProcessInstanceWorkitem().getAllPendingWorkItems(new Set<String>{'ActorId'}, new Set<Id>{bnf.Id});
        if (piwi.size() > 0){
            Set<Id> ApproverId_Set = new Set<Id>();
            
            for (ProcessInstanceWorkitem PIW : piwi){
                ApproverId_Set.add(PIW.ActorId);
            }
            for(User DelegateApproverUser : new SLT_User().getUserById(ApproverId_Set, new Set<String>{'DelegatedApproverId'})){
                if(DelegateApproverUser.DelegatedApproverId!=null){
                    ApproverId_Set.add(DelegateApproverUser.DelegatedApproverId);
                }
            }
            
            List<PermissionSetAssignment> permSetAssList = new SLT_PermissionSetAssignment().selectByPermissionSetForUserId(new Set<String>{'Id'}, new Set<Id>{Userinfo.getUserId()}, 'Modify_all_privileges_on_BNF');
            Boolean hasAccessBNFAll = permSetAssList.size() > 0 ? true : false;
            if (bnf.BNF_Status__c != MDM_Defines.BnfStatus_Map.get('NEW') && !Pattern.matches('system administrator[\\s|[A-z]|[0-9]]*',currentUser.Profile.Name.toLowerCase()) && !hasAccessBNFAll){
                if (ApproverId_Set != null && !ApproverId_Set.contains(UserInfo.getUserId())){
                    errorMsg.add(BNF_SUBMITTED_ERROR);
                }
            }
        }
        
        if (bnf.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SAP_CONTRACT_CONFIRMED')){
            errorMsg.add(BNF_SAP_CONTRACT_CONFIRMED_ERROR);
        }
        
        Map<Id, Address__c> addressMap = new SLT_Address().getAddressByConditions(addressFieldSet, 'RecordType.DeveloperName = \'MDM_Validated\' AND Account__c = \''+ BnfAccountId +'\' AND Marked_For_Deletion__c = false AND Archived__c = false');
        if(addressMap.size() == 0){
            errorMsg.add(NO_ADDRESS_ERROR);
            returnMap.put('returnURL', '/apex/requestnewaddresswizard?AccountId='+BnfAccountId+'&ApprovalRequest=true&BnfId='+bnfId+'&retURL=/'+bnfId);
        }
        for(SAP_Contact__c sc: new SLT_SAP_Contact().getSapContactByAddressIdSet(sapContactFieldSet, 'Address__c = :addressIdSet AND Marked_For_Deletion__c = false AND RecordType.DeveloperName=\'MDM_Validated\'', addressMap.keyset())){
            Map<String,String> sapContactoptionMap = new Map<String,String>();
            String OptionLabel = '';
            if (currentUser.User_Country__c == sc.Address__r.Country__c && sc.Last_Name_Local__c != null){
                OptionLabel = sc.Last_Name_Local__c + '&nbsp;&nbsp;&nbsp;' + sc.First_Name_Local__c + ' - [' + sc.SAP_Contact_Number__c + ']';
            }else{
                OptionLabel = sc.Name;
            }
            sapContactoptionMap.put('label', OptionLabel);
            sapContactoptionMap.put('value', sc.Id);
            if(addressToContactListMap.containskey(sc.Address__c)){
                addressToContactListMap.get(sc.Address__c).add(sapContactoptionMap);
            }else{
                Map<String,String> optionMap = new Map<String,String> {'label'=>'No Contact Selected','value'=> ''};
                    addressToContactListMap.put(sc.Address__c, new List<Map<String,String>>{optionMap});
                addressToContactListMap.get(sc.Address__c).add(sapContactoptionMap);
            }
        }
        for(Address__c add: addressMap.values()){
            if(!addressToContactListMap.containskey(add.Id)){
                Map<String,String> optionMap = new Map<String,String> {'label'=>'N/A','value'=> ''};
                    addressToContactListMap.put(add.Id, new List<Map<String,String>>{optionMap});
            }
        }
        
        returnMap.put('addressList', addressMap.values());
        returnMap.put('addressToContactListMap', addressToContactListMap);
        if(errorMsg.size() > 0){
            returnMap.put('errorMsg', errorMsg);
        }
        return returnMap;
    }
    
    /**
     * This Method to return basic data to render lwc
     * @param String accountRegionTerritory
     * @param String accountRegionTerritory
     * @param String searchedCountry
     * @param String searchedName
     * @param String searchedCity
     * @return Map<String, Object>
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> searchAddressByfilter(String accountRegionTerritory, String searchedCountry, String searchedName, String searchedCity){
        searchedName = (searchedName != null) ? ('%' + searchedName + '%') : '%%';
        searchedCity = (searchedCity != null) ? ('%' + searchedCity.trim() + '%') : '%%';
        
        Map<String, Object> returnMap = new Map<String, Object>();
        Map<Id, Address__c> addressMap = new Map<Id, Address__c>();
        Map<Id,List<Map<String,String>>> addressToContactListMap = new Map<Id,List<Map<String,String>>>();
        
        User currentUser = new SLT_User().getUserById(new Set<Id> {UserInfo.getUserId()}, new Set<String>{'User_Country__c'})[0];
        
        //AND Account__c = :BnfAccountId
        if (searchedCountry == null || searchedCountry == '') {
            addressMap = new SLT_Address().getAddressByConditions(addressFieldSet, 'RecordType.DeveloperName = \'MDM_Validated\' AND (Name like \''+ searchedName +'\' OR International_Name__c like  \''+ searchedName + '\') AND (City__c like \''+ searchedCity + '\' OR International_City__c like \''+ searchedCity + '\') AND Marked_For_Deletion__c = false AND Archived__c = false');
        } else {
            addressMap =  new SLT_Address().getAddressByConditions(addressFieldSet, 'RecordType.DeveloperName = \'MDM_Validated\' AND (Name like \''+ searchedName +'\' OR International_Name__c like  \''+ searchedName + '\') AND (City__c like \''+ searchedCity + '\' OR International_City__c like \''+ searchedCity + '\') AND Marked_For_Deletion__c = false AND Archived__c = false AND Country__c =  \''+ searchedCountry +'\'');
        }
        
        for(SAP_Contact__c sc: new SLT_SAP_Contact().getSapContactByAddressIdSet(sapContactFieldSet, 'Address__c = :addressIdSet AND Marked_For_Deletion__c = false AND RecordType.DeveloperName=\'MDM_Validated\'', addressMap.keyset())){
            Map<String,String> sapContactoptionMap = new Map<String,String>();
            String OptionLabel = '';
            if (currentUser.User_Country__c == sc.Address__r.Country__c && sc.Last_Name_Local__c != null){
                OptionLabel = sc.Last_Name_Local__c + '&nbsp;&nbsp;&nbsp;' + sc.First_Name_Local__c + ' - [' + sc.SAP_Contact_Number__c + ']';
            }else{
                OptionLabel = sc.Name;
            }
            sapContactoptionMap.put('label', OptionLabel);
            sapContactoptionMap.put('value', sc.Id);
            
            if(addressToContactListMap.containskey(sc.Address__c)){
                addressToContactListMap.get(sc.Address__c).add(sapContactoptionMap);
            }else{
                Map<String,String> optionMap = new Map<String,String> {'label'=>'No Contact Selected','value'=> ''};
                    addressToContactListMap.put(sc.Address__c, new List<Map<String,String>>{optionMap});
                addressToContactListMap.get(sc.Address__c).add(sapContactoptionMap);
            }
        }
        
        // To add N/A if no SAP Contact exist on particular Address
        for(Address__c add: addressMap.values()){
            if(!addressToContactListMap.containskey(add.Id)){
                Map<String,String> optionMap = new Map<String,String> {'label'=>'N/A','value'=> ''};
                    addressToContactListMap.put(add.Id, new List<Map<String,String>>{optionMap});
            }
        }
        returnMap.put('addressToContactListMap', addressToContactListMap);
        returnMap.put('addressList', addressMap.values());
        return returnMap;
    }
}