public class DAOH_DocuSignEnvelopeDocument {
    
    public static string TpaBrandTemplateIds {
        get {
            if(TpaBrandTemplateIds == null || TpaBrandTemplateIds == '') {
                TpaBrandTemplateIds = '';
                for(TPA_Multilingual_Template_Setting__c templateObj : TPA_Multilingual_Template_Setting__c.getAll().values()) {
                    if(templateObj.label__c == 'Docusign Template') {
                        TpaBrandTemplateIds += templateObj.Translated_Template_Id__c + ';';
                    }
                }
            }
            return TpaBrandTemplateIds;
        }
        set;
    }
    
    public static void onBeforeDelete(List<dsfs__DocuSign_Envelope_Document__c> oldRecords) {
        for(dsfs__DocuSign_Envelope_Document__c  DSEnveDoc : oldRecords) {
            if(DSEnveDoc.dsfs__Document_ID__c != null && TpaBrandTemplateIds.containsIgnoreCase(DSEnveDoc.dsfs__External_Document_Id__c)) {
                try {
                    //Insert the cloned envelope document
                    insert DSEnveDoc.clone(false, false, false, false);
                    break;            
                }
                catch(Exception e) {
                    System.debug('::: Exception in Docusign Envelope Document Clone Process :::');
                }
            }
        }
    }
}