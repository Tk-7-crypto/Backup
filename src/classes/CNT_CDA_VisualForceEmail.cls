public class CNT_CDA_VisualForceEmail { 
	public string ObjRecId {get; set;}
    public Workflow_Email_Record__c recSendEmail;
    
    public Workflow_Email_Record__c getSendEmail() {system.debug('recId00:::'+ObjRecId);
        if(ObjRecId == null) {
            return null;
        }
        recSendEmail = [SELECT Id, Email_Action__c, content_1__c, Attachment_Details__c, isAttachmentRequired__c From Workflow_Email_Record__c Where id=:ObjRecId LIMIT 1];
        system.debug('wFDebug:::'+recSendEmail.Attachment_Details__c + '::::' + recSendEmail.isAttachmentRequired__c);
        string content = '<div style="width:100%;background-color:#cccccc;"><center>';
        recSendEmail.content_1__c = recSendEmail.content_1__c.replace('p{margin-top:0px; margin-bottom:0px;}', '');
        /*if(recSendEmail.isAttachmentRequired__c) {
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
                recSendEmail.content_1__c = content + recSendEmail.content_1__c.replace('Slug_Attachments', attachmentList) + '</center></div>';
            }
        }*/
        return recSendEmail;
    }
}