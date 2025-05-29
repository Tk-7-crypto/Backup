public without sharing class CNT_TPA_VisualForceEmail {
    public string ObjRecId {get; set;}
    public Boolean isReportAttach {get; set;}
    public transient Workflow_Email_Record__c recSendEmail;
    public string baseOrgUrl {
        get {
            return UTL_TPA.TPA_SITEURL;
        }
    }
    public List<Attachment> attach;
    
    public string getSendEmail() {
        system.debug('recId00:::'+ObjRecId);
        string emailContent = '';
        if(ObjRecId == null) {
            return emailContent;
        }
        recSendEmail = [SELECT Id, Email_Action__c, content_1__c, content_2__c, content_3__c, content_4__c, Attachment_Details__c, isAttachmentRequired__c From Workflow_Email_Record__c Where id=:ObjRecId LIMIT 1];
        system.debug('wFDebug:::'+recSendEmail.Attachment_Details__c + '::::' + recSendEmail.isAttachmentRequired__c);
        string content = '<div style="width:100%;background-color:#cccccc;"><center>';
        emailContent += recSendEmail.content_1__c.replace('p{margin-top:0px; margin-bottom:0px;}', '');
        if(recSendEmail.content_2__c != null && recSendEmail.content_2__c != '') {
            emailContent += recSendEmail.content_2__c.replace('p{margin-top:0px; margin-bottom:0px;}', '');
        }
        if(recSendEmail.content_3__c != null && recSendEmail.content_3__c != '') {
            emailContent += recSendEmail.content_3__c.replace('p{margin-top:0px; margin-bottom:0px;}', '');
        }
        if(recSendEmail.content_4__c != null && recSendEmail.content_4__c != '') {
            emailContent += recSendEmail.content_4__c.replace('p{margin-top:0px; margin-bottom:0px;}', '');
        }
        //recSendEmail.content_1__c = recSendEmail.content_1__c.replace('p{margin-top:0px; margin-bottom:0px;}', '');
        if(recSendEmail.isAttachmentRequired__c && !isReportAttach) {
            if(String.isNotBlank(recSendEmail.Attachment_Details__c)) {
                string attachmentList = '<center style="margin-top:10px;"><b>--------------Attachments------------------</b></center><ul>';
                List<String> strList;
                for(String objStr: recSendEmail.Attachment_Details__c.split(';')) {
                    strList = objStr.split('~~');
                    if(strList.size() == 2) {
                        attachmentList += '<li><a href="'+baseOrgUrl+'/tpa/servlet/servlet.FileDownload?file='+strList[1]+'">'+strList[0]+'</a></li>';
                    }
                }
                attachmentList += '</ul>';
                emailContent = content + emailContent.replace('Slug_Attachments', attachmentList) + '</center></div>';
            }
        }
        return emailContent;
    }
}