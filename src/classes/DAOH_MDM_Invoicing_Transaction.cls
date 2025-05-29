/**
* Created by Ronak Mehta on 19-Jun-2023
* Description : Contain helper Methods to run for MDM_Invoicing_Transaction__c trigger
*/
public class DAOH_MDM_Invoicing_Transaction {
    
    /**
     * This Method to update SAP_Contact.Enabled_Sales_Orgs_for_e_invoicing__c field
     * @params List<MDM_Invoicing_Transaction__c> newList
     * @return Map<Id, MDM_Invoicing_Transaction__c> oldMap
     */
    public static void updateSapContactFields(List<MDM_Invoicing_Transaction__c> newList, Map<Id, MDM_Invoicing_Transaction__c> oldMap){
        Set<Id> sapContactIdSet = new Set<Id>();
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new Schema.SObjectType[] { SAP_Contact__c.SobjectType } );
        
        for(MDM_Invoicing_Transaction__c mit: newList){
            if(mit.Type__c == '1'){
                if(mit.SAP_Contact_1__c != null && (Trigger.isInsert || (Trigger.isUpdate && mit.SAP_Contact_1__c != oldMap.get(mit.Id).SAP_Contact_1__c))){
                    sapContactIdSet.add(mit.SAP_Contact_1__c);
                }
                if(mit.SAP_Contact_2__c != null && (Trigger.isInsert || (Trigger.isUpdate && mit.SAP_Contact_2__c != oldMap.get(mit.Id).SAP_Contact_2__c))){
                    sapContactIdSet.add(mit.SAP_Contact_2__c);
                }
                if(mit.SAP_Contact_3__c != null && (Trigger.isInsert || (Trigger.isUpdate && mit.SAP_Contact_3__c != oldMap.get(mit.Id).SAP_Contact_3__c))){
                    sapContactIdSet.add(mit.SAP_Contact_3__c);
                }
            }
        }
        
        if(sapContactIdSet.size() > 0){
            Boolean toCommit = false;
            Set<String> fieldSet = new Set<String>{};
                Map<Id,String> sapContactToSalesOrgMap = new Map<Id,String>();
            for(MDM_Invoicing_Transaction__c mdt : new SLT_MDM_Invoicing_Transaction().getInvoiceBySapContact(fieldSet, sapContactIdSet)){
                if(sapContactIdSet.contains(mdt.SAP_Contact_1__c) && mdt.SAP_Contact_1__c != null){
                    if(sapContactToSalesOrgMap.containsKey(mdt.SAP_Contact_1__c)){
                        String salesOrg = sapContactToSalesOrgMap.get(mdt.SAP_Contact_1__c) + ':' + mdt.Sales_Org__c;
                        sapContactToSalesOrgMap.put(mdt.SAP_Contact_1__c, salesOrg);
                    }else{
                        sapContactToSalesOrgMap.put(mdt.SAP_Contact_1__c, mdt.Sales_Org__c);
                    }
                }
                if(sapContactIdSet.contains(mdt.SAP_Contact_2__c) && mdt.SAP_Contact_2__c != null){
                    if(sapContactToSalesOrgMap.containsKey(mdt.SAP_Contact_2__c)){
                        String salesOrg = sapContactToSalesOrgMap.get(mdt.SAP_Contact_2__c) + ':' + mdt.Sales_Org__c;
                        sapContactToSalesOrgMap.put(mdt.SAP_Contact_2__c, salesOrg);
                    }else{
                        sapContactToSalesOrgMap.put(mdt.SAP_Contact_2__c, mdt.Sales_Org__c);
                    }
                }
                if(sapContactIdSet.contains(mdt.SAP_Contact_3__c) && mdt.SAP_Contact_3__c != null){
                    if(sapContactToSalesOrgMap.containsKey(mdt.SAP_Contact_3__c)){
                        String salesOrg = sapContactToSalesOrgMap.get(mdt.SAP_Contact_3__c) + ':' + mdt.Sales_Org__c;
                        sapContactToSalesOrgMap.put(mdt.SAP_Contact_3__c, salesOrg);
                    }else{
                        sapContactToSalesOrgMap.put(mdt.SAP_Contact_3__c, mdt.Sales_Org__c);
                    }
                }
            }
            
            for(Id i: sapContactToSalesOrgMap.KeySet()){
                Sap_contact__c sc =new SAP_Contact__c();
                sc.Id = i;
                sc.Enabled_Sales_Orgs_for_e_invoicing__c = sapContactToSalesOrgMap.get(i);
                uow.registerDirty(sc);
                toCommit = true;
            }
            
            if(toCommit){
                uow.commitWork();
            }
        }
    }
    
}