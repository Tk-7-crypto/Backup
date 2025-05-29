public class UTL_CPQ_DownloadExcel {
 
    public Id proposalID {get;Set;}
    public String returnString {get;Set;}
    
    public PageReference downloadExcel() {
	 
        proposalID = ApexPages.currentPage().getParameters().get(CON_CPQ.ID);
        String conditionForAttachment = ' ParentId = \'' + proposalID + '\' Order By LastModifiedDate Desc LIMIT 1';
        List<Attachment> attachmentList = new SLT_Attachment().getLatestAttachments(conditionForAttachment);

        if (attachmentList.size() == 0) {

            String templateName = '';
            String tool = ApexPages.currentPage().getParameters().get(CON_CPQ.TOOL);
            if (tool == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT) {																		   
                templateName = CON_CPQ.UPT_TEMPLATE_QUOTE;
            } else if (tool == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT) {
                templateName = CON_CPQ.LCS_UPT_TEMPLATE;
            } else if (tool == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_GRA_UPT) {
                templateName = CON_CPQ.GRA_TEMPLATE;
            } else if (tool == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_IQB_UPT) {
                templateName = CON_CPQ.BIOTECH_TEMPLATE;
            }
            if (!String.isBlank(templateName)) {
                for (Document d: new SLT_Document().selectUserByName(templateName)) {
                    Attachment attachment = new Attachment();
                    attachment.Body = d.Body;
                    attachment.Name = CON_CPQ.UPT_TEMPLATE_PREFIX + proposalID + CON_CPQ.UPT_TEMPLATE_EXTENSION;
                    attachment.ContentType = d.ContentType;
                    attachment.ParentId = proposalID;
                    insert attachment;
                    returnString = URL.getOrgDomainUrl().toExternalForm() + CON_CPQ.UPT_TARGET_URL + attachment.id;
                }
            }
            
        } else {
            returnString = URL.getOrgDomainUrl().toExternalForm() + CON_CPQ.UPT_TARGET_URL + attachmentList[0].id;
        }
        return null;
    }
}