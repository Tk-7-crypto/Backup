/*
* This class is used as helper class for DAO_ContentVersion for CLM Module
*/
public class DAOH_CLM_ContentVersion {
    /**
    * This method is used to prevent the Sales User from making any editing or upload new version in the attachments of the submitted GCE agreement
    * @param List<ContentVersion> lstContentVersion
    */
    public static void validateCVForIQAGR(List<ContentVersion> lstContentVersion, Map<Id, ContentVersion> oldMap) {
        Map<Id, Id> mapCDAGRId = new Map<Id, Id>();
        Map<Id,Profile> mapAdminProfiles = new Map<Id,Profile>(new SLT_Profile().getAdminProfiles(new Set<String> {'Id', 'Name'}));
        if(!mapAdminProfiles.containsKey(UserInfo.getProfileId())) {
            Map<Id, IQVIA_Agreement__c> agreementMap = getAgreementMap(lstContentVersion, mapCDAGRId);     
            if(agreementMap != null && !agreementMap.isEmpty()) { 
                for(ContentVersion cv : lstContentVersion) {
                    if(oldMap == null || (oldMap != null  
                        && ((oldMap.get(cv.Id).Description != cv.Description 
                        && oldMap.get(cv.Id).Description != null && cv.Description != null)
                        ||  oldMap.get(cv.Id).Title != cv.Title
                        ||  oldMap.get(cv.Id).CurrencyIsoCode != cv.CurrencyIsoCode))) {
                        
                    	if(mapCDAGRId.containsKey(cv.ContentDocumentId) 
                        	&& agreementMap.containsKey(mapCDAGRId.get(cv.ContentDocumentId))) {
                        	cv.addError(System.Label.CLM_CL001_Validation_File_IQ_AGR);
                    	}
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
    private static Map<Id, IQVIA_Agreement__c> getAgreementMap(List<ContentVersion> lstCV, Map<Id, Id> mapCDAGRId) {
        Map<Id, IQVIA_Agreement__c> activatedAGRMap = new Map<Id, IQVIA_Agreement__c>();
        Set<String> fieldSet = new Set<String>{'Id', 'LinkedEntityId', 'ContentDocumentId'};
        Set<Id> cdIdSet = new Set<Id>();
        for(ContentVersion cv : lstCV) {
            if(cv.ContentDocumentId != null) {
            	cdIdSet.add(cv.ContentDocumentId);
            }
        }
        if(!cdIdSet.isEmpty()) {
            return UTL_CLM.getAgreementMapFromCD(cdIdSet, mapCDAGRId);
        }
        return null;
    } 
}