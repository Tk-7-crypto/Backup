public class CNT_CPQ_RequestToUnlockBudget 
{    
    @AuraEnabled 
    public static Boolean isNotifyCurrentXAEOwner(String pricingTool)
    {
        Set<Id> adminUserIds = new Set<Id>();
        
        String groupName = '';
        if(pricingTool == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT || pricingTool == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_GRA_UPT)
            groupName = CON_CPQ.CPQ_ADMINS_FOR_BUDGET_UNLOCKING;
        else if(pricingTool == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT)
            groupName = CON_CPQ.LCS_CPQ_ADMINS_FOR_BUDGET_UNLOCKING;
        
        List<GroupMember> unlockingGroupMemebr = [SELECT UserOrGroupId FROM GroupMember WHERE Group.Name =:groupName]; 
        if(unlockingGroupMemebr.size() > 0){  
            for (GroupMember gm : unlockingGroupMemebr) {
                adminUserIds.add(gm.UserOrGroupId);
            }
        }
        if(adminUserIds.contains(UserInfo.getUserId()))
            return false;
        else
            return true;
    }
    
    @AuraEnabled 
    public static void notifyXAEOwner(Id userId, Id budgetId){
        
        List<String> adminUserEmailAddresses = new List<String>();
        List<OrgWideEmailAddress> orgWideEmailAddress = new SLT_OrgWideEmailAddress().selectOrgWideEmailAddressByName(
                                                            CON_CPQ.CPQ_Foundation_Tool_Display_Name, new Set<String>{CON_CPQ.ADDRESS});
        if(orgWideEmailAddress.size() > 0)
            adminUserEmailAddresses.add(orgWideEmailAddress[0].Address);
        
        List<EmailTemplate> emailTemplate = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(CON_CPQ.CPQ_PROPOSAL_ANOTHER_USER_REQUEST_TO_UNLOCK_BUDGET, new Set<String>{CON_CPQ.Id});
        if(emailTemplate.size() > 0){
            Messaging.SingleEmailMessage mailTemp = Messaging.renderStoredEmailTemplate(emailTemplate[0].Id, userId, budgetId);
            Messaging.SingleEmailMessage mailToXAEOwner = new Messaging.SingleEmailMessage();
            mailToXAEOwner.setSubject(mailTemp.getSubject());
            mailToXAEOwner.setHTMLBody(mailTemp.getHtmlbody());
            mailToXAEOwner.setTargetObjectId(userId);
            mailToXAEOwner.setSaveAsActivity(false);
            mailToXAEOwner.setCcAddresses(adminUserEmailAddresses);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mailToXAEOwner});
        }
    }
    
    @AuraEnabled 
    public static void notifyAdminUser(Id userId, Id budgetId){
        
        List<String> adminUserEmailAddresses = new List<String>();
        List<OrgWideEmailAddress> orgWideEmailAddress = new SLT_OrgWideEmailAddress().selectOrgWideEmailAddressByName(
                                                            CON_CPQ.CPQ_Foundation_Tool_Display_Name, new Set<String>{CON_CPQ.ADDRESS});
        if(orgWideEmailAddress.size() > 0)
            adminUserEmailAddresses.add(orgWideEmailAddress[0].Address);
                
        List<EmailTemplate> emailTemplate = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(CON_CPQ.CPQ_PROPOSAL_SAME_USER_REQUEST_TO_UNLOCK_BUDGET,
            new Set<String>{CON_CPQ.Id});
        if(emailTemplate.size() > 0){
            Messaging.SingleEmailMessage mailTemp = Messaging.renderStoredEmailTemplate(emailTemplate[0].Id, userId, budgetId);
            Messaging.SingleEmailMessage mailToXAEOwner = new Messaging.SingleEmailMessage();
            mailToXAEOwner.setSubject(mailTemp.getSubject());
            mailToXAEOwner.setHTMLBody(mailTemp.getHtmlbody());
            mailToXAEOwner.setTargetObjectId(userId);
            mailToXAEOwner.setUseSignature(false); 
            mailToXAEOwner.setBccSender(false); 
            mailToXAEOwner.setTreatTargetObjectAsRecipient(false);
            mailToXAEOwner.setToAddresses(adminUserEmailAddresses);
            mailToXAEOwner.setSaveAsActivity(false);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mailToXAEOwner});
        }
    }
    
    @AuraEnabled 
    public static void unlockBudget(Id userId, Id budgetId){
		
        Apttus_Proposal__Proposal__c budgetRecord = new Apttus_Proposal__Proposal__c(Id = budgetId);
        budgetRecord.Pricing_Tool_Locked__c = false;
        budgetRecord.Budget_Checked_Out_By__c = null;
        budgetRecord.XAE_Lock_Timestamp__c = null;
        update budgetRecord;
    }
}