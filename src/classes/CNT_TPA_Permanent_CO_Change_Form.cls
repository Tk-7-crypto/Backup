public class CNT_TPA_Permanent_CO_Change_Form {
    public  static TPA_Assigned_TP_Processor__c assignedTPProcessorObj;
    public String tpProcessorEmail{
        get{
            if(tpProcessorEmail == null){
                List<TPA_Assigned_TP_Processor__c> assignTP = [select Id,TP_Processor__r.TP_Processor_Email__c from TPA_Assigned_TP_Processor__c where Email__c =: UserInfo.getUserEmail() Limit 1];
                if(assignTP != null && assignTP.size() > 0 && assignTP[0].TP_Processor__c != null && assignTP[0].TP_Processor__r.TP_Processor_Email__c != null){
                    return assignTP[0].TP_Processor__r.TP_Processor_Email__c;
                }
                return '';
            }
            return tpProcessorEmail;
        }
        set;
    }

    public String currentLoginUserName{
        get{
            if(currentLoginUserName == null){
                return UserInfo.getName();
            }
            return currentLoginUserName;
        }
        set;
    }
    
    public static String jsonOfferingList {
        get {
            if(jsonOfferingList == null || jsonOfferingList == '') {
                list<IMS_Data_Asset__c> offeringsList = new list<IMS_Data_Asset__c>();
                offeringsList  = [select id, name, Asset_Name__c, BU__c,Geo_Level__c,Commercial_Owner_Email__c, Commercial_Manager_Name__c,(select id,
                        Secondary_Asset_Name__c,Geo_Level__c,
                        Commercial_Manager_Email__c,Commercial_Manager_Name__c from IMS_Secondary_Data_Assets__r
                 where Is_Active__c = True) from IMS_Data_Asset__c where Is_Active__c = true];
                jsonOfferingList = JSON.serialize(offeringsList);
                system.debug('offeringsList size = ' + offeringsList.size());
                system.debug('jsonOfferingList = ' + jsonOfferingList + 'offeringsList = ' + offeringsList);
            }
            return jsonOfferingList;
        }
        set;
    }


    @remoteAction
    public static string saveRequest(string TPProcessorObj){
        List<WrapperOffRow> wrapperOffRowList = new List<WrapperOffRow>();
        try{            
            assignedTPProcessorObj = new TPA_Assigned_TP_Processor__c();
            wrapperClassPermanentOwnerDetails permComOwnerChange; 
            permComOwnerChange = (wrapperClassPermanentOwnerDetails)JSON.deserialize(TPProcessorObj, wrapperClassPermanentOwnerDetails.class);
            assignedTPProcessorObj.Is_Permanent_Commercial_Owner__c = true;
            assignedTPProcessorObj.Commercial_Owner_Email__c = permComOwnerChange.permanentOwnerEmail;
            assignedTPProcessorObj.New_Permanent_Commercial_Owner_Full_Name__c = permComOwnerChange.newPermanentOwnerName;
            assignedTPProcessorObj.New_Permanent_Commercial_Owner_Email__c = permComOwnerChange.newPermanentOwnerEmail;
            assignedTPProcessorObj.Action__c = permComOwnerChange.actionSelected;
            assignedTPProcessorObj.Effective_Date__c =  Date.valueOf(permComOwnerChange.effectiveDate);
            assignedTPProcessorObj.Offering_Names__c = '';
            for(WrapperOffRow wrapper: permComOwnerChange.uniqueOfferingCombinations){
                if(!wrapper.selected){
                    continue;
                }
                assignedTPProcessorObj.Offering_Names__c += wrapper.country+'->'+wrapper.offCat+'->'+wrapper.primOffName+(wrapper.secOffName == null ? '' : ('->'+ wrapper.secOffName))+';';
            }
            system.debug('assignedTPProcessorObj'+assignedTPProcessorObj);
	        	
            upsert assignedTPProcessorObj;
            
            Date todayDate = System.now().date();
            if(assignedTPProcessorObj.Effective_Date__c ==  todayDate){
                String comEmailId = '%' + assignedTPProcessorObj.Commercial_Owner_Email__c + '%';
                BCH_TPA_Permanent_Com_Owner_Email_Update bchObj = new BCH_TPA_Permanent_Com_Owner_Email_Update();
                bchObj.comEmailId = comEmailId;
                Database.executeBatch(bchObj,1);
            }
            if(assignedTPProcessorObj.id != null){
                permanentCOMails(permComOwnerChange, 'TP Processor');
                permanentCOMails(permComOwnerChange, 'Commercial Owner');
            }
        }
        catch(Exception ex){
            system.debug('ERROR: '+ex.getMessage());
            UTL_LogFactory.generateAndCommitLog(TRUE, 
                                                FALSE, 
                                                UTL_LogFactory.GUID, 
                                                'Exception: ' + ex.getLineNumber(), 
                                                'TPA', 
                                                'Exception', 
                                                'ERROR', 
                                                ':::CNT_TPA_Permanent_CO_Change_Form:::saveRequest :: ' + ex.getMessage(), 
                                                '');
        }
       // return ('success~'+'VFP_TPA_Page_Status?type=venOfferingReturnSubSuccess');
        //return ('success~'+'VFP_TPA_Com_Owner_Change_Request_Form');
        return 'Sucess';  

        

    }

    public static List<String> emailFormatter(String emailsList){
        List<String> lstemails = new List<String>();
        if(emailsList != null && emailsList != ''){
            for(String emailDescription : emailsList.split(';'))
                lstemails.add(emailDescription);
        }
        return lstemails;
    }
    public static String emailsString(String emailList, String targetEmails){
        String emailFormatted = '';
        if(emailList != null && targetEmails != null){
            Set<String> stTargetEmails = new Set<String>(targetEmails.split(';'));
            for(String emailDescription : emailList.split(',')){
                if(stTargetEmails.contains(emailDescription.substringBetween('<','>'))){
                    emailFormatted += '<strong>' + emailDescription.replaceAll('<', '&lt;').replaceall('>','&gt;') + '</strong><br/>';
                }else{
                    emailFormatted += emailDescription.replaceAll('<', '&lt;').replaceall('>','&gt;') + '<br/>';
                }
            }
        }
        return emailFormatted;
    }
    public static String dateFormatter(String rawDate){
        if(rawDate != null){
            Date dateElement = Date.valueOf(rawDate);
            if(dateElement != null){
                return DateTime.newInstance(dateElement, Time.newInstance(0,0,0,0)).format('dd MMMMMM, yyyy');
            }
        }
        return rawDate;
    }
    public static void permanentCOMails(wrapperClassPermanentOwnerDetails Data, String entity){
        final String FONT_STYLE = 'style = "border:2px solid;font-size:13px;font-family:arial;';
        List<String> ccAddresses = new List<String>();
        List<String> toAddresses = new List<String>();
        String emailBody;
        String action;
        String emailType = (entity == 'Commercial Owner' ? 'ConfirmPermChangeOfCO' : null);
        if(data.actionSelected != null){
            action = (data.actionSelected == 'addOwner' ? 'Add an Additional Commercial Owner to an Existing Offering(s) Review' : 
            (data.actionSelected == 'removeOwner' ? 'Remove Existing Commercial Owner from Offering(s) Review that has more than one Commercial Owner' : 
            (data.actionSelected == 'transferOwner' ? 'Transfer Current Commercial Owner Offering(s) Review to Another' : ''))) ;
        }
        
        if(entity == 'TP Processor'){
            if(data.tpProcessorEmail != null && data.tpProcessorEmail != '')
                toAddresses.add(data.tpProcessorEmail);
            if(UTL_TPA.Tpa50orMoreLicensesEmailIds != null && UTL_TPA.Tpa50orMoreLicensesEmailIds != ''){
                for(String emailID : UTL_TPA.Tpa50orMoreLicensesEmailIds.split(';')){
                    if(!toAddresses.contains(emailID)){
                        toAddresses.add(emailID);
                    }
                }
            }
            if(data.permanentOwnerEmail != null && data.permanentOwnerEmail != ''){
                for(String emailID : emailFormatter(data.permanentOwnerEmail))
                    ccAddresses.add(emailID);
            }
        }else{
            if(data.tpProcessorEmail != null && data.tpProcessorEmail != '')
                ccAddresses.add(data.tpProcessorEmail);
            if(UTL_TPA.Tpa50orMoreLicensesEmailIds != null && UTL_TPA.Tpa50orMoreLicensesEmailIds.split(';').size() > 1){
                if(!ccAddresses.contains(UTL_TPA.Tpa50orMoreLicensesEmailIds.split(';')[1])){
                    ccAddresses.add(UTL_TPA.Tpa50orMoreLicensesEmailIds.split(';')[1]);
                }
            } 
            if(data.newPermanentOwnerEmail != null && data.newPermanentOwnerEmail != ''){
                for(String emailID : emailFormatter(data.newPermanentOwnerEmail))
                    toAddresses.add(emailID);
            }
            // In case Remove Functionality
            if(data.actionSelected != null && data.actionSelected == 'removeOwner' && entity == 'Commercial Owner' && data.permanentOwnerEmail != null && data.permanentOwnerEmail != ''){
                for(String emailID : emailFormatter(data.permanentOwnerEmail))
                    toAddresses.add(emailID);
            }
        }
        
        String emailSubject = 'TPA Program Confirmation: Update of Commercial Ownership';
        if(entity == 'TP Processor' && data.actionSelected != null){
            emailBody = '<p>Thank you for submitting your request to update Third Party Access (TPA) commercial ownership for one or more related offering(s) to be updated for the following reason: ' + action + '. See the below for summary of requested change.</p>';
        }else if(entity == 'Commercial Owner' && data.tpProcessorName != null && data.actionSelected != null && data.tpProcessorEmail != null && data.effectiveDate != null){
            emailbody = '<p>Good Day,</p> ';
            emailbody += '<p>' + data.tpProcessorName + (data.actionSelected != 'removeOwner'? ' from ' + data.tpProcessorEmail : '');
            emailbody +=' has requested Third Party Access (TPA) commercial ownership for one or more related offering(s) to be updated for the following reason: ' + action;
            emailbody += (data.actionSelected == 'removeOwner' ? '. ' : '.</p><p>') + 'This update will be active as of '+ dateFormatter(data.effectiveDate) + ' in our system. '+ (data.actionSelected == 'removeOwner' ? 'Moving forward,' : 'As of this date,') + ' you will receive TPA Requests requiring manual review for these specific offerings:</p>';
        }
        emailBody += '<table style="border-collapse: collapse;width: 100%">' +
            			'<tr>' +
            				'<th></th><th></th><th></th><th></th><th></th><th></th>' +
							'<th ' + FONT_STYLE + '">Per ' + (entity == 'TP Processor' ? 'Your ' : '') + 'Request</th>' +
						'</tr>' +
            			'<tr>' +
            				'<th ' + FONT_STYLE + 'width:70px;">Select</th>' +
							'<th ' + FONT_STYLE + 'width:auto;">Country</th>' +
							'<th ' + FONT_STYLE + 'width:auto;">Category</th>' +
							'<th ' + FONT_STYLE + 'width:auto;">Primary Offering</th>' +
							'<th ' + FONT_STYLE + 'width:auto;">Secondary Offering</th>' +
							'<th ' + FONT_STYLE + 'width:auto;">Current Commercial Owners</th>' +
							'<th ' + FONT_STYLE + 'width:auto;">Commercial Owners Updated Based on Requested Changes</th>' +
						'</tr>';
        if(data.uniqueOfferingCombinations != null && data.uniqueOfferingCombinations.size() > 0){
            data.uniqueOfferingCombinations.sort();
            for(WrapperOffRow row : data.uniqueOfferingCombinations){
                if((row.selected == true && entity == 'Commercial Owner')||(entity == 'TP Processor')){
                    emailBody += '<tr>' + 
                                    '<td ' + FONT_STYLE + 'text-align: center; vertical-align: middle;"><span style="font-family:Wingdings">' + (row.selected != true ? '&uml;' : '&thorn;') +'</span></td>' + 
                                    '<td ' + FONT_STYLE + '">' + (row.country != null ? row.country : '') + '</td>' + 
                                    '<td ' + FONT_STYLE + '">' + (row.offCat != null ? row.offCat : '') + '</td>' + 
                                    '<td ' + FONT_STYLE + '">' + (row.primOffName != null ? row.primOffName : '') + '</td>' + 
                                    '<td ' + FONT_STYLE + '">' + (row.secOffName != null ? row.secOffName : '') + '</td>';
                        		if(data.actionSelected != null && data.actionSelected != 'addOwner'){
                                    emailBody += '<td ' + FONT_STYLE + '"><span>' + (row.oldValues != null ? emailsString(row.oldValues, data.permanentOwnerEmail) : '') + '</span></td>';
                        		}else if(data.actionSelected != null && data.actionSelected == 'addOwner'){
                                    emailBody += '<td ' + FONT_STYLE + '"><span>' + (row.oldValues != null ? String.join(row.oldValues.replaceAll('<', '&lt;').replaceall('>','&gt;').split(','),'<br/>') : '') + '</span></td>';
                        		}
                                if(row.selected == true){
                                    emailBody +='<td ' + FONT_STYLE + '"><span>' + (row.newValues != null ? emailsString(row.newValues,data.newPermanentOwnerEmail ) : '') + '</span></td>';
                    			}else{
                        			if(row.newValues != null && row.newValues != '[The Commercial Owner is currently the only owner. To change this, submit a separate ‘transfer’ request.]'){
                                   		emailBody +='<td ' + FONT_STYLE + '"><span><strong>[No Changes Requested]</strong></span></td>';
                        			}else if(row.newValues != null && row.newValues == '[The Commercial Owner is currently the only owner. To change this, submit a separate ‘transfer’ request.]'){
                                    	emailBody +='<td ' + FONT_STYLE + '"><span><strong>The Commercial Owner is currently the only owner. To change this, submit a separate ‘transfer’ request.</strong></span></td>';
                       				}
                    			}
                                 	emailBody += '</tr>';

                            if(data.actionSelected == 'removeOwner' && row.newValues != null && row.newValues != '' && row.newValues != '[The Commercial Owner is currently the only owner. To change this, submit a separate ‘transfer’ request.]' && entity == 'Commercial Owner'){
                                for(String tempEmail : row.newValues.split(',')){
                                    ccAddresses.add(tempEmail.subString( tempEmail.indexOf('<') + 1,  tempEmail.indexOf('>')));
                                }
                            }
                            
                                   
                }
            }   
        }
        emailBody += '</table><br/>';
            if(entity == 'TP Processor'){
                emailBody += '<p>Your request will be updated in our system as of ' + (data.effectiveDate != null ? dateFormatter(data.effectiveDate) : '');
                if(data.actionSelected != null)
                    emailBody += (data.actionSelected != 'removeOwner' ? ' and the related Commercial Owner(s) will be notified of this update in a separate email' : '');
                emailBody += '.</p>';
            }else {
                emailBody += '<p>If necessary, to help you get acquainted with the review process, we have attached a Commercial Owner Manual Review Quick Reference Guide. For further assistance to get up to speed quickly, please reply-all to this email to request one-on-one training and/or any inquiries.</p>';
            }
        
        emailBody += '<br/>';
        emailBody += '<p>Our Regards,<br/>';
        emailBody += 'Global Third Party Access Team<br/>';
        if(UTL_TPA.TPA_AdminEmailID != null && UTL_TPA.TPA_AdminEmailID != '')
            emailBody += '<a href = "mailto:' + UTL_TPA.TPA_AdminEmailID + '">' + UTL_TPA.TPA_AdminEmailID + '</a></p>';

        if(!Test.isRunningTest())
            SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddresses,ccAddresses,emailType,null,assignedTPProcessorObj.id,null,emailSubject,false, emailBody,false,false,null);
    }
    
    public class wrapperClassPermanentOwnerDetails {
        public string actionSelected {get;set;}
        public string permanentOwnerEmail {get;set;}
        public string newPermanentOwnerName {get;set;}
        public string newPermanentOwnerEmail {get;set;}
        public string effectiveDate {get;set;}
        public string tpProcessorName {get;set;}
        public string tpProcessorEmail {get;set;}
        public List<WrapperOffRow> uniqueOfferingCombinations {get;set;}
    }
    
    public class WrapperOffRow implements Comparable {
        public String country {get;set;}
        public String offCat {get;set;}
        public String primOffName {get;set;}
        public String secOffName {get;set;}
        public String oldValues {get;set;}
        public String newValues {get;set;}
        public Boolean selected {get;set;}
        
        public Integer compareTo(Object compareTo) {
            Integer returnVal = 0;
            WrapperOffRow compareWith = (WrapperOffRow)compareTo;
            if(selected != null && comparewith.selected != null){
                if( this.selected && !compareWith.selected)
                    returnVal = -1;
                if(!this.selected && compareWith.selected )
                    returnVal = 1;
            }
            return returnVal;
        }
    }
}
