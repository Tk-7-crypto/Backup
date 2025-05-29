import { LightningElement,api,wire,track} from 'lwc';
import getRecepients from '@salesforce/apex/CNT_AEA_EmailBodyComposer.getRecepients';
import getRecord from '@salesforce/apex/CNT_AEA_EmailBodyComposer.getRecord';
import getEmailTemplates from '@salesforce/apex/CNT_AEA_EmailBodyComposer.getEmailTemplates';
import generatePreview from '@salesforce/apex/CNT_AEA_EmailBodyComposer.generatePreview';
import sendMail from '@salesforce/apex/CNT_AEA_EmailBodyComposer.sendMail';
import getOppRecord from '@salesforce/apex/CNT_AEA_EmailBodyComposer.getOppRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getParentAccountIds from '@salesforce/apex/CNT_AEA_EmailBodyComposer.getParentAccountIds';

export default class SendEmail extends LightningElement {
    @api recordId;
    @track options = [];
    @track templateList = [];
    @api record;
    @api toRecord;
    @api bccRecord;
    @api ccRecord;
    @api toReceipientIds;
    @api bccReceipientIds;
    @api ccReceipientIds;
    @api mailBody;
    @api subject;
    @api parentAcctIds = [];
    @api isTemplateSelected = false;
    @track activeSections = ['To', 'BCC', 'CC'];
    @track mailIds;
    @track manuallyAddedList;
    @track error = false;
    @wire(getRecord, { recordId: '$recordId'})
    sObjRec;
    @wire(getRecepients,{recId:'$recordId'})
    recipient({data,error}){
        if(data){
            this.record = data;
            this.allRecord = data;
            var toRec = [];
            var bccRec = [];
            var ccRec = [];
            console.log('data=>',data);
            data.forEach(key=>{
                if(key.Alerting_Email__c != null && key.Alerting_Email__c != undefined){
                    toRec.push(key);
                }
                if(key.Bcc_Recipient_Email__c != null && key.Bcc_Recipient_Email__c != undefined){
                    bccRec.push(key);
                }
                if(key.CC__c != null && key.Bcc_Recipient_Email__c != undefined){
                    ccRec.push(key);
                }
            })
            if(toRec.length > 0){
                this.toRecord = toRec;
            }
            if(bccRec.length > 0){
                this.bccRecord = bccRec;
            }
            if(ccRec.length > 0){
                this.ccRecord = ccRec;
            }

        }
        else if(error){
            console.log(error);
        }
    }
    @wire(getOppRecord, { recordId: '$recordId'})
    oppRecord;
    @wire(getEmailTemplates,{})
    emailTemplates({data,error}){
        if(data){
            let templates = [];
            data.forEach(key=>{
                templates.push({
                    label:key.Name,
                    value:key.Id
                });
            });
            this.templateList = templates;
        }
        else if(error){
            console.log(error);
        }
    }
    @wire(getParentAccountIds, { recordId: '$recordId'})
        parentAccounts ({error, data}) {
            if (data) {
                this.parentAcctIds = data;
            } else {
                this.error = error;
            }
        }
    get accountBCC(){
        var data = this.record;
        var isContainBCC = false;
        data.forEach(key=>{
            if(key.Bcc_Recipient_Email__c != null){
                isContainBCC = true;
            }
        })
        return isContainBCC;
    }
    get accountCC(){
        var data = this.record;
        var isContainCC = false;
        data.forEach(key=>{
            if(key.CC__c != null){
                isContainCC = true;
            }
        })
        return isContainCC;
    }
    
    mailIdsToAdd(event){
        this.mailIds = event.target.value;
    }
    addMailId(event){
        var receipeiantsList = [];
        var InvalidMailIdsList = [];
        if(this.manuallyAddedList != undefined){
            receipeiantsList = this.manuallyAddedList;
        }
        if(this.mailIds != undefined && this.mailIds != ''){
            var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            var mailId = this.mailIds;
            var receipeiantIds = mailId.split(",");
                receipeiantIds.forEach(key=>{
                    if(key.match(regExpEmailformat)){
                        receipeiantsList.push(key);
                    }else{
                        InvalidMailIdsList.push(key);
                    }
                })
        }
        
        this.manuallyAddedList = receipeiantsList;
        var invalidIds = '';
        if(InvalidMailIdsList.length > 0){
            this.error = true;
            InvalidMailIdsList.forEach(key=>{
                if(invalidIds == ''){
                    invalidIds = key;
                }else{
                    invalidIds = invalidIds+', '+ key;
                }
            })
            const event = new ShowToastEvent({
                title: 'Invalid Email Address',
                message: invalidIds,
                variant: 'error',
            });
            this.dispatchEvent(event);
        }else{
            this.error = false;
        }
        this.mailIds = invalidIds;
    }
    get className(){
          return this.changeStyle ? 'error': '';
      }
    handleRemoveTo(event){
        var obj = [];
        for(var i=0; i<this.toRecord.length;i++){
            if(this.toRecord[i].Alerting_Email__c == event.target.label){}
            else{        
                obj.push(this.toRecord[i]);
            }
        }
        this.toRecord = obj;
    }
    handleRemoveBCC(event){
        var obj = [];
        for(var i=0; i<this.bccRecord.length;i++){
            if(this.bccRecord[i].Bcc_Recipient_Email__c == event.target.label){}
            else{        
                obj.push(this.bccRecord[i]);
            }
        }
        this.bccRecord = obj;
    }
    handleRemoveCC(event){
        var obj = [];
        for(var i=0; i<this.ccRecord.length;i++){
            if(this.ccRecord[i].CC__c == event.target.label){}
            else{        
                obj.push(this.ccRecord[i]);
            }
        }
        this.ccRecord = obj;
    }
    handleRemoveManual(event){
        var obj = [];
        for(var i=0; i<this.manuallyAddedList.length;i++){
            if(this.manuallyAddedList[i] != event.target.label){
                obj.push(this.manuallyAddedList[i]);
            }
        }
        this.manuallyAddedList = obj;
    }
    handleChange(event){
        this.templateId = event.detail.value;
        this.isTemplateSelected = true;
        generatePreview({templateId: this.templateId, recId :this.recordId})
                .then(result => {
                    this.subject = result.Subject;
                    this.mailBody = result.HtmlValue;
                })
                .catch(error => {
                    this.error = error;
                });
    }
    sendMail(){
        var toMailId = [];
        var bccMailId = [];
        var ccMailId = [];
        if(this.toRecord != undefined){
            for(var i=0; i<this.toRecord.length; i++){
                if(this.toRecord[i].Alerting_Email__c != null && this.toRecord[i].Alerting_Email__c != undefined){
                    toMailId.push(this.toRecord[i].Alerting_Email__c);
                }
            }
        }
        if(this.bccRecord != undefined){
            for(var i=0; i<this.bccRecord.length; i++){
                if(this.bccRecord[i].Bcc_Recipient_Email__c != null && this.bccRecord[i].Bcc_Recipient_Email__c != undefined){
                    bccMailId.push(this.bccRecord[i].Bcc_Recipient_Email__c);
                }
            }
        }
        if(this.ccRecord != undefined){
            for(var i=0; i<this.ccRecord.length; i++){
                if(this.ccRecord[i].CC__c != null && this.ccRecord[i].CC__c != undefined){
                    ccMailId.push(this.ccRecord[i].CC__c);
                }
            }
        }
        if(this.manuallyAddedList != undefined && this.manuallyAddedList.length > 0 ){
            this.manuallyAddedList.forEach(key=>{
                toMailId.push(key);
            })
        }
        this.toReceipientIds = toMailId;
        this.bccReceipientIds = bccMailId;
        this.ccReceipientIds = ccMailId;
        if(this.toReceipientIds.length > 0){
            sendMail({templateId : this.templateId, recId : this.recordId, toRecepients : this.toReceipientIds, bccRecepients : this.bccReceipientIds, ccRecepients : this.ccReceipientIds})
            .then(result=>{
                const closeQA = new CustomEvent('close');
                // Dispatches the event.
                this.dispatchEvent(closeQA);
            })
            .catch(error => {
                this.error = error;
            });

        }else{
            const event = new ShowToastEvent({
                title: 'No Receipeints',
                message: 'Add Receipeints.',
            });
            this.dispatchEvent(event);
        }
       
    }
    closeWindow(){
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
}