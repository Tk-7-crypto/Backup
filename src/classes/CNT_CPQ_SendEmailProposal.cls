public class CNT_CPQ_SendEmailProposal {
    
    @AuraEnabled
    public static void sendMailMethod(String emailObjJSON) {
        EmailDetailsWrapper emailObj = (EmailDetailsWrapper) System.JSON.deserialize(emailObjJSON, EmailDetailsWrapper.class);
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        List<String> emails = new List<String>();
        if (!String.isBlank(emailObj.toEmailIds))
            emails = emailObj.toEmailIds.split(CON_CPQ.COMMA);
        List<ContentVersion> attachmentList = getAttachments(emailObj.attachmentIds);
        Map<String, String> mimeTypeMap = new Map<String, String>();
        mimeTypeMap.put(CON_CPQ.POWER_POINT_X, CON_CPQ.APPLICATION_OPENXMLFORMAT);
        mimeTypeMap.put(CON_CPQ.POWER_POINT, CON_CPQ.APPLICATION_POWERPOINT);
        mimeTypeMap.put(CON_CPQ.EXCEL_M, CON_CPQ.APPLICATION_EXCEL);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail = CPQ_Utility.getSingleMessage(emailObj.templateName, emailObj.proposalID, UserInfo.getUserId(), emails);
        if (emailObj.ccEmailIds != '' && emailObj.ccEmailIds != null) {
            List <String> ccEmails = emailObj.ccEmailIds.split(CON_CPQ.COMMA);
            mail.setCcAddresses(ccEmails);
        }

        if (emailObj.bccEmailIds != '' && emailObj.bccEmailIds != null) {
            List <String> bccEmails = emailObj.bccEmailIds.split(CON_CPQ.COMMA);
            mail.setBccAddresses(bccEmails);
        }
            
        String mailBody = '';
        mailBody += '<span style="display:none;visibility:hidden" id="remove_this_line"></span>' + emailObj.htmlBody;
        mailBody += '<div class="proposalId" style="display:none;width:0px;max-height:0px;overflow:hidden;mso-hide:all;height:0;font-size:0;max-height:0;line-height:0;margin:0 auto;">'+emailObj.proposalId+'</div>';       
        mail.setSubject(emailObj.subject);
        mail.setHtmlBody(mailBody);
        mail.setSaveAsActivity(true);
        mail.setWhatId(emailObj.proposalId);
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        if (attachmentList.size() > 0) {
            for (ContentVersion attachment : attachmentList) {
                Messaging.Emailfileattachment fileAttachment = new Messaging.Emailfileattachment();
                fileAttachment.setBody(attachment.VersionData);
                fileAttachment.setFileName(attachment.Title + '.' + attachment.FileExtension);
                fileAttachment.setcontenttype(mimeTypeMap.get(attachment.FileType));
                fileAttachments.add(fileAttachment);
            }
        }

        mail.setFileAttachments(fileAttachments);
        mails.add(mail);
        Messaging.sendEmail(mails);
        
        if (emailObj.approvalStatus == CON_CPQ.APPROVAL_STATUS_FOR_FUNCTIONAL_REVIEW && emailObj.templateName == CON_CPQ.CPQ_SEND_EMAIL_TO_FUNCTIONAL_REVIEWER) {
            Apttus_Proposal__Proposal__c proposal = new SLT_Proposal().getProposalDetails(emailObj.proposalId, new Set<String>{CON_CPQ.APPROVAL_STATUS, CON_CPQ.APPROVAL_STAGE});
            proposal.Approval_Status__c = CON_CPQ.SUBMITTED_FOR_FUNCTIONAL_REVIEW;
            proposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.SUBMIT_FOR_REVIEW;
            update proposal;
        }
        deleteAttachments(emailObj.attachmentIds);
    }

    private static List<ContentVersion> getAttachments(List<Id> attachmentIds) {
        Set<String> fieldSet = new Set<String>{CON_CPQ.ID, CON_CPQ.VERSION_DATA, CON_CPQ.FILE_TYPE, CON_CPQ.FILE_EXTENSION, CON_CPQ.TITLE};
        return new SLT_ContentVersion().getContentVersionByDocumentIds(new Set<Id>((List<Id>)attachmentIds), fieldSet);
    }    

    @AuraEnabled
    public static void deleteAttachments(List<Id> attachmentIds) {
        List<ContentDocument> documentList = new SLT_ContentDocument().selectById(new Set<Id>(attachmentIds));
        delete documentList;
    }

    @AuraEnabled
    public static EmailDetailsWrapper getEmailTemplate(Id recordId, String emailFor) {
        List<EmailTemplate> emailTemplate = new List<EmailTemplate>();
        
        EmailDetailsWrapper wrapperObj = new EmailDetailsWrapper();
        wrapperObj.proposalId = recordId;
        Set<String> fieldSet = new Set<String>{CON_CPQ.ID, CON_CPQ.APTTUS_PROPOSAL_PARENT_BID, CON_CPQ.PROPOSAL_OPPORTUNITY_NAME, CON_CPQ.PROPOSAL_RELATED_ACCOUNT_NAME, 
            CON_CPQ.RELATED_CLINICAL_TSL_USER, CON_CPQ.APPROVAL_STATUS, CON_CPQ.RELATED_CLINICAL_INDICATION, 
            CON_CPQ.RELATED_CLINICAL_BID_DUE_DATE, CON_CPQ.RELATED_CLINICAL_OPPORTUNITY_NUMBER, CON_CPQ.TOTAL_IQVIA_FEES,
            CON_CPQ.TOTAL_INV_GRANTS, CON_CPQ.TOTAL_EXPENSES_OTHER, CON_CPQ.TOTAL_IQVIA_FEES_BOTTOM_LINE_DISCOUNT,
            CON_CPQ.PROPOSAL_OPPORTUNITY_NUMBER, CON_CPQ.PROPOSAL_CATEGORY, CON_CPQ.SCENARIO_NUMBER,
            CON_CPQ.RFP_SCENARIO, CON_CPQ.BUDGET_ITERATION, CON_CPQ.TOTAL_IQVIA_FEES_BID,CON_CPQ.CURRENCYISOCODE, CON_CPQ.OPPORTUNITY_NUMBER,
            CON_CPQ.EXTERNAL_LINK, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL, CON_CPQ.SCENARIO_DESCRIPTION};
        List<Apttus_Proposal__Proposal__c> proposalList = new SLT_Proposal().getProposalsById(new Set<Id>{recordId}, fieldSet);
        wrapperObj.approvalStatus = proposalList[0].Approval_Status__c;
        Decimal totalStudyFees = proposalList[0].Total_IQVIA_Fees__c + proposalList[0].Total_INV_Grants__c + proposalList[0].Total_Expenses_Other__c + proposalList[0].Total_IQVIA_Fees_Bottom_Line_Discount__c;
        Decimal totalIqviaFeeCDS = proposalList[0].Total_IQVIA_Fees_BID__c;
        Id recordTypeId = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CON_CPQ.IQVIA_USER_CONTACT).getRecordTypeId();
        wrapperObj.whereClause = 'RecordTypeId = \'' + recordTypeId + '\' AND EmployeeNumber__c != null';
        if (emailFor == CON_CPQ.CHALLENGE_REVIEW) {
            emailTemplate = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(
            	CON_CPQ.CPQ_SEND_EMAIL_FOR_CHALLENGE_CALL_REVIEW, new Set<String>{CON_CPQ.Id, CON_CPQ.DeveloperName});
            wrapperObj.templateName = CON_CPQ.CPQ_SEND_EMAIL_FOR_CHALLENGE_CALL_REVIEW;
        } else if (emailFor == CON_CPQ.SIGN_OFF) {
            emailTemplate = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(
            	CON_CPQ.CPQ_SEND_EMAIL_FOR_FINAL_SIGNOFF_REVIEW, new Set<String>{CON_CPQ.Id, CON_CPQ.DeveloperName});
            wrapperObj.templateName = CON_CPQ.CPQ_SEND_EMAIL_FOR_FINAL_SIGNOFF_REVIEW;
        } else if (proposalList[0].Approval_Status__c == CON_CPQ.APPROVAL_STATUS_FOR_FUNCTIONAL_REVIEW) {
            wrapperObj.selectedEmailIds = getDSBReviewer(proposalList[0].Id);
            emailTemplate = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(
                CON_CPQ.CPQ_SEND_EMAIL_TO_FUNCTIONAL_REVIEWER, new Set<String>{CON_CPQ.Id, CON_CPQ.DeveloperName});
            wrapperObj.templateName = CON_CPQ.CPQ_SEND_EMAIL_TO_FUNCTIONAL_REVIEWER;
        } 
        
        if (emailTemplate.size() > 0) {
            Messaging.SingleEmailMessage mailTemp = Messaging.renderStoredEmailTemplate(
                emailTemplate[0].Id, UserInfo.getUserId(), recordId);
            
            if (emailTemplate[0].DeveloperName == CON_CPQ.CPQ_SEND_EMAIL_TO_FUNCTIONAL_REVIEWER) {
                if(String.IsNotBlank(proposalList[0].External_Link__c)
                  && (proposalList[0].Select_Pricing_Tool__c == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT ||
                      proposalList[0].Select_Pricing_Tool__c == CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT))
                {   
                    String htmlSubject = mailTemp.getSubject();
                    htmlSubject = htmlSubject.remove(', Scenario scenarioNumberPlaceHolder, scenarioPlaceHolder, Budget Iteration budgetIterationPlaceHolder');
                    mailTemp.setSubject(htmlSubject);
                    
                    String htmlBody = mailTemp.getHtmlBody();
                    htmlBody = htmlBody.remove(', Scenario scenarioNumberPlaceHolder, scenarioPlaceHolder, scenarioDescriptionPlaceHolder, Budget Iteration budgetIterationPlaceHolder');
                    mailTemp.setHtmlBody(htmlBody);
                }
                CPQ_ReplaceEmailPlaceHolders.replaceMailBody(mailTemp, proposalList[0], false);
                CPQ_ReplaceEmailPlaceHolders.replaceMailSubjectFunctionalReview(mailTemp, proposalList[0].Apttus_Proposal__Account__r.Name, proposalList[0].Apttus_Proposal__Opportunity__r.Name,
                    proposalList[0].Opportunity_Number__c, proposalList[0].Apttus_Proposal__Proposal_Category__c,
                    proposalList[0].Scenario_Number__c, proposalList[0].RFP_Scenario__c, proposalList[0].Budget_Iteration__c);
            } else {
                if (emailFor == CON_CPQ.SIGN_OFF) {
                    CPQ_ReplaceEmailPlaceHolders.replaceMailBody(mailTemp, proposalList[0], true);
                } else {
                    CPQ_ReplaceEmailPlaceHolders.replaceMailBody(mailTemp, proposalList[0], false);
                }
                CPQ_ReplaceEmailPlaceHolders.replaceMailSubject(mailTemp, proposalList[0].Apttus_Proposal__Opportunity__r.Name,
                    proposalList[0].Apttus_Proposal__Account__r.Name);
                CPQ_ReplaceEmailPlaceHolders.replaceTotalStudyFees(mailTemp,totalStudyFees);
                CPQ_ReplaceEmailPlaceHolders.replaceTotalIQVIAFeesCDS(mailTemp, proposalList[0], totalIqviaFeeCDS);
            }            
            wrapperObj.subject = mailTemp.getSubject();
            wrapperObj.htmlBody = mailTemp.getHtmlbody();
            wrapperObj.attachmentIds = new List<String>();
        }
        return wrapperObj;
    }
    
    private static String getDSBReviewer(Id recordId) {
        String dsbReviewers = '';
        Set<String> dsbEmails = New Set<String>();
        Set<String> teamMemberFieldSet = new Set<String>{CON_CPQ.ID, CON_CPQ.USER_FIELD, CON_CPQ.MEMBER_ROLE, CON_CPQ.ROLE_FROM_RR, CON_CPQ.AGREEMENT_User_EMAIL};
        List<Team_Member__c> teamMemberList =  new SLT_TeamMember().getTeamMemberByProposalIdANDMemberRole(new Set<Id> {recordId}, teamMemberFieldSet, new List<String>{CON_CPQ.FUNCTIONAL_REVIEWER});

        if (teamMemberList.size() > 0) {
            for (Team_Member__c teamMember : teamMemberList) {
                dsbEmails.add(teamMember.User__r.Email);
            }
        }
        for (String email : dsbEmails) {
            dsbReviewers += (dsbReviewers == '' ? '' : CON_CPQ.COMMA) + email;
        }
        return dsbReviewers;
    }
    
    public class EmailDetailsWrapper {
        @AuraEnabled public Id proposalId{get;set;}
        @AuraEnabled public String approvalStatus{get;set;}
        @AuraEnabled public String whereClause{get;set;}
        @AuraEnabled public String subject{get;set;}
        @AuraEnabled public String htmlBody{get;set;}        
        @AuraEnabled public String selectedEmailIds{get;set;}   
        @AuraEnabled public String toEmailIds{get;set;}   
        @AuraEnabled public String ccEmailIds{get;set;}   
        @AuraEnabled public String bccEmailIds{get;set;}   
        @AuraEnabled public String templateName{get;set;}
        @AuraEnabled public List<String> attachmentIds{get;set;}
    }
}