/**
 * Version : 1.0
 * An apex controller that exposes the OpportunitySplit Component.
 */
public class CNT_CRM_OpportunitySplit {

    /**
     * This method returns OpportunitySplit Records for any opportunity.
     * @params  Id opportinityId
     * @params  String splitType
     * @params  List<String> fieldList
     * @return  List<OpportunitySplit>
     */
    @AuraEnabled
    public static List<OpportunitySplit> getOpportunitySplitRecords(Id opportinityId, String splitType, List<String> fieldList) {
        List<OpportunitySplit> opportunitySplitList = new List<OpportunitySplit>();
        try {
            opportunitySplitList = SRV_CRM_OpportunitySplit.getOpportunitySplitRecords(new Set<Id>{opportinityId}, splitType, new Set<String>(fieldList));
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return opportunitySplitList;
    }
    
    
    /**
     * This method returns OpportunitySplit Records for any opportunity.
     * @params  Id opportinityId
     * @params  String splitType
     * @params  List<String> fieldList
     * @return  List<OpportunitySplit>
     */
    @AuraEnabled
    public static OpportunityWrapper getOppByIdWithOppTeamSplits(Id opportinityId, List<String> oppfieldList, List<String> oppSplitFieldList, List<String> oppTeamFieldList, String splitType) {
        OpportunityWrapper oppWrapper = new OpportunityWrapper();
        Map<Id, Opportunity> idToOpportunityMap = new Map<Id, Opportunity>();
        try {
            idToOpportunityMap = SRV_CRM_Opportunity.getOppByIdWithOppTeamSplits(new Set<Id>{opportinityId}, new Set<String>(oppfieldList), new Set<String>(oppSplitFieldList), new Set<String>(oppTeamFieldList), splitType);
            if(idToOpportunityMap.size() > 0) {
                Opportunity oppRecord =  idToOpportunityMap.values()[0];
                List<OpportunityWrapper.OpportunitySplitWrapper> splitWrapperList = new List<OpportunityWrapper.OpportunitySplitWrapper>();
                OpportunityWrapper.OpportunitySplitWrapper splitWrapper = null;
                for(OpportunitySplit oppSplit : oppRecord.OpportunitySplits) {
                    splitWrapper = new OpportunityWrapper.OpportunitySplitWrapper(oppSplit, CON_CRM.EDIT_LABEL);
                    splitWrapperList.add(splitWrapper);
                }
                CurrencyType currTpe = [SELECT DecimalPlaces FROM CurrencyType where IsoCode =: oppRecord.CurrencyIsoCode];
                Decimal decimalPlace = currTpe.DecimalPlaces;
                Decimal decimalPlaceStep;
                if(currTpe.DecimalPlaces != 0) {
                    Decimal num = Math.pow(10, currTpe.DecimalPlaces);
                    decimalPlaceStep = 1/num;
                } else {
                    decimalPlaceStep = currTpe.DecimalPlaces;
                }
                system.debug(decimalPlace);
                system.debug(decimalPlaceStep);
                oppWrapper = new OpportunityWrapper(oppRecord, splitWrapperList, oppRecord.OpportunityTeamMembers, decimalPlace, decimalPlaceStep);
            }
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return oppWrapper;
    }
    
    /**
     * This method update OpportunitySplit Records
     * @params  List<OpportunitySplit>
     * @return  void
     */
    @AuraEnabled
    public static void updateOpportunitySplitRecords(String oppSplitWrapperListJsonStr) {
        try {
            List<OpportunityWrapper.OpportunitySplitWrapper> oppSplitWrapperList = (List<OpportunityWrapper.OpportunitySplitWrapper>)JSON.deserialize(oppSplitWrapperListJsonStr, List<OpportunityWrapper.OpportunitySplitWrapper>.Class);
            List<OpportunityWrapper.OpportunitySplitWrapper> oppSplitWrapperToDel = new List<OpportunityWrapper.OpportunitySplitWrapper>();
            Id oppSplitTypeId = SRV_CRM_OpportunitySplit.getOpportunitySplitTypeIdByName(CON_CRM.SPLIT_TYPE_NAME);
            for(OpportunityWrapper.OpportunitySplitWrapper oppSplitWrapper : oppSplitWrapperList) {
                if(oppSplitWrapper.operationType == CON_CRM.CREATE_LABEL) {
                    oppSplitWrapper.splitRecord.SplitTypeId = oppSplitTypeId;
                    if(oppSplitWrapper.splitRecord.Id != null) {
                        OpportunitySplit oppSplitClone = oppSplitWrapper.splitRecord.clone(true, false, false, false);
                        oppSplitWrapperToDel.add(new OpportunityWrapper.OpportunitySplitWrapper(oppSplitClone, CON_CRM.DELETE_LABEL));
                        oppSplitWrapper.splitRecord.Id = null;
                    }
                }
            }
            if(oppSplitWrapperToDel.size() > 0) {
                oppSplitWrapperList.addAll(oppSplitWrapperToDel);
            }
            SRV_CRM_OpportunitySplit.updateOpportunitySplits(oppSplitWrapperList);
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }
    
    /**
     * This method check User has Opportunity Split Permission has or not
     * @params  String permissionApiName
     * @return  Boolean
     */
    @AuraEnabled
    public static Boolean hasEditSplitPermission(String permissionApiName) {
        return FeatureManagement.checkPermission(permissionApiName);
    }
}