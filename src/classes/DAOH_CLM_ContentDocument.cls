/*
* This class is used as helper class for DAO_ContentDocument for CLM Module
*/
public class DAOH_CLM_ContentDocument {
    /**
    * This method is used to user to delete the content document of activated agreement
    * @param List<ContentDocument> lstContentDocument
    */
    public static void validateCDForIQAGR(List<ContentDocument> lstContentDocument) {
        Map<Id, Id> mapCDAGRId = new Map<Id, Id>();
        Map<Id,Profile> mapAdminProfiles = new Map<Id,Profile>(new SLT_Profile().getAdminProfiles(new Set<String> {'Id', 'Name'}));
        if(!mapAdminProfiles.containsKey(UserInfo.getProfileId())) {
            Map<Id, IQVIA_Agreement__c> agreementMap = getAgreementMap(lstContentDocument,mapCDAGRId);  
            if(agreementMap != null && !agreementMap.isEmpty()) {  
                for(ContentDocument cd: lstContentDocument) {
                    if(mapCDAGRId.containsKey(cd.Id) && agreementMap.containsKey(mapCDAGRId.get(cd.Id))) {
                        cd.addError(System.Label.CLM_CL001_Validation_File_IQ_AGR);
                    }
                }
            }
        }
    }
            
    /**
    * This method is used to return Agreement Map 
    * @param List<ContentDocument> lstContentDocument
    * @return Map<Id, Apttus__APTS_Agreement__c> 
    */
    @testVisible
    private static Map<Id, IQVIA_Agreement__c> getAgreementMap(List<ContentDocument> lstContentDocument, Map<Id, Id> mapCDAGRId) {
        Map<Id, IQVIA_Agreement__c> activatedAGRMap = new Map<Id, IQVIA_Agreement__c>();
        Set<String> fieldSet = new Set<String>{'Id', 'LinkedEntityId', 'ContentDocumentId'};
        Set<Id> cdIdSet = new Set<Id>();
        for(ContentDocument cd : lstContentDocument) {           
            cdIdSet.add(cd.Id);
        }
        if(!cdIdSet.isEmpty()) {
            return UTL_CLM.getAgreementMapFromCD(cdIdSet, mapCDAGRId);
        }
        return null;
    }    
}