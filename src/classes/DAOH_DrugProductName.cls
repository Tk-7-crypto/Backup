/**
 * Created by Ronak Mehta on 16-Nov-2023
 * Description : This is Drug_Product_Name__c trigger Helper class.
 */
public class DAOH_DrugProductName {
    
    /**
	 * This method is used to populate field value on DrugProductName record.
     * @params List<Drug_Product_Name__c> newList
     * @return void
	 */
    public static void updateFields(List<Drug_Product_Name__c> newList){
        for(Drug_Product_Name__c dpn: newList){
            dpn.External_Key__c = dpn.Opportunity__c + '-' + dpn.Drug_Product__c;
        }
    }
    
    /**
	 * This method is used to populate field value on Opportunity record.
     * @params List<Drug_Product_Name__c> newList
     * @return void
	 */
    public static void updateOpportunityRecord(List<Drug_Product_Name__c> newList){
        Boolean toCommit = false;
        Set<String> fieldSet = new Set<String> {'Id', 'Opportunity__c', 'Drug_Product__r.International_Drug_Name__c','Drug_Product__r.Molecule_Name__c'};
        Set<Id> oppIdSet = new Set<Id>();
        Map<Id, Set<String>> oppToDrugProductSetMap = new Map<Id, Set<String>>();
        Map<Id,Drug_Product_Name__c> OppIdToDrugProductMap = new Map<Id,Drug_Product_Name__c>();
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new Schema.SObjectType[] { Opportunity.SobjectType } );
        
        for(Drug_Product_Name__c dpn: newList){
            oppIdSet.add(dpn.Opportunity__c); // To Query all related record to opp
            OppIdToDrugProductMap.put(dpn.Opportunity__c, dpn); //To Throw Error to specific record
            oppToDrugProductSetMap.put(dpn.Opportunity__c,  new Set<String>()); // set default to blank(i.e delete all record)
        }
        
        for(Drug_Product_Name__c dpn: new SLT_DrugProductName().getOppDrugProductByOppId(oppIdSet, fieldSet)){
            Set<String> drugProductSet = oppToDrugProductSetMap.containsKey(dpn.Opportunity__c) ? oppToDrugProductSetMap.get(dpn.Opportunity__c) : new Set<String>();
            String MoleculeName = String.IsNotBlank(dpn.Drug_Product__r.Molecule_Name__c) ? '('+ dpn.Drug_Product__r.Molecule_Name__c.toLowerCase() +')' : '';
            drugProductSet.add(dpn.Drug_Product__r.International_Drug_Name__c + ' ' + MoleculeName);
            oppToDrugProductSetMap.put(dpn.Opportunity__c, drugProductSet);
        }
        
        for(Id oppId: oppToDrugProductSetMap.keySet()){
            Set<String> drugProductSet = oppToDrugProductSetMap.containsKey(oppId) ? oppToDrugProductSetMap.get(oppId) : new Set<String>();
            String drugProductNameWithMolecule = String.join(drugProductSet, '; ');
            if(drugProductNameWithMolecule.length() > 255){
                String drugProductName = '';
                if(drugProductSet.size() == 1){
                    drugProductName = drugProductNameWithMolecule.subString(0,250) + '...)';
                }else{
                    drugProductName = 'Multiple products/Multiple molecules';
                }
                uow.registerDirty(new Opportunity(Id = oppId, Drug_Product_Name__c = drugProductName, Drug_Product_Name_With_Molecules__c = drugProductNameWithMolecule));
                toCommit = true;
            }else{
                uow.registerDirty(new Opportunity(Id = oppId, Drug_Product_Name__c = drugProductNameWithMolecule, Drug_Product_Name_With_Molecules__c = drugProductNameWithMolecule));
                toCommit = true;
            }
        }
        if(toCommit){
            UTL_ExecutionControl.stopTriggerExecution = true;
            uow.commitWork();
            if(System.isQueueable() && !Test.isRunningTest()){
                CNT_RFP_IntakeUnityFlagSync.runprocessSyncLogicInFuture(CON_CBEx.OPPORTUNITY_OBJECT, new List<Id>(oppIdSet));
            }else {
                System.enqueueJob(new CNT_RFP_UnityFlag_Queuable(CON_CBEx.OPPORTUNITY_OBJECT, new List<Id>(oppIdSet)));
            }
            UTL_ExecutionControl.stopTriggerExecution = false;
        }
    }
}