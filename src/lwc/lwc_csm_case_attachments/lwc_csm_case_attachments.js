import { LightningElement,wire,track,api } from 'lwc';  
import getAllAttachments from '@salesforce/apex/CNT_CSM_CaseAttachmentController.fetchAttachmentList';
import saveAttachmentToDraftEmail from '@salesforce/apex/CNT_CSM_CaseAttachmentController.saveAttachmentToDraftEmail';
import sendDraftEmail from '@salesforce/apex/CNT_CSM_CaseAttachmentController.sendDraftEmail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
export default class lwc_csm_case_attachments extends NavigationMixin(LightningElement) {
    @api recordId; 
    @track mylists;
    @track alreadyExistlists;
    @track bShowModal = false;
    @track active = false;
    
    /* javaScipt functions start */ 
    openModal() { 
        this.active = true;   
        // to open modal window set 'bShowModal' tarck value as true
        this.bShowModal = true;
    }
 
    closeModal() {    
        // to close modal window set 'bShowModal' tarck value as false
        this.bShowModal = false;
        window.location.reload();
    }
    @api isLoadeding = false;
    @track columns = [{
        label: 'Attachment namee',
        fieldName: 'nameUrl', 
        type: "url",  
        typeAttributes: { label: { fieldName: "name" }, tooltip:"Name", target: "_blank"  
  }  
    },{
        label: 'Id',
        fieldName: 'id',
        type: 'text'}]
    @track error;
    connectedCallback() {
        this.recordId = this.recordId;
        this.isLoadeding = true;
    }
    
    @wire(getAllAttachments, {caseId: '$recordId' })
    wiredFlows({ error, data }) {
        if (data) {
            this.mylists = data;
            this.error = undefined;
            this.isLoadeding = false;
        } else if (error) {
            this.error = error;
            this.mylists = undefined;
        }
    }
    selectAttachmentHandler(evt){
        var changedRecordId = evt.target.value;
        let tmpObj = this.proxyToObj(this.mylists);
        tmpObj.forEach(function(acc){
            if(acc.id === changedRecordId){
                if(acc.isSelected === true){
                    acc.isSelected = false;
                }
                else{
                    acc.isSelected = true;
                }
            }
        });
        this.mylists = tmpObj;
    }

    proxyToObj(obj){
        return JSON.parse(JSON.stringify(obj));
    }
    updateRecordView(recordId) {
        updateRecord({fields: { Id: recordId }});
    }
   
    navigateToAttachment() {
        /*this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'ContentDocument',
                actionName: 'home'
            },
        });*/
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Case',
                relationshipApiName: 'CombinedAttachments',
                actionName: 'view'
            },
        });
    }
    handleReset(){
        let tmpObj = this.proxyToObj(this.mylists);
        tmpObj.forEach(function(acc){
            acc.isSelected = false;
        });
        this.mylists = tmpObj;
    }
    handleEmailSend(){
        this.isLoadeding = true;
        this.bShowModal = false;
        sendDraftEmail({  
            caseId : this.recordId
        }).then(result =>{
            this.isLoadeding = false;
            
           let title = 'Success';
           let message = 'Email has been sent';
           let variant = 'success';
           this.bShowModal = false;
        
        const event = new ShowToastEvent({
            title : title,
            message : message,
            variant : variant
        });
        this.dispatchEvent(event);
    }).catch(error =>{
        this.isLoadeding = false;
        console.log(error);
        const event = new ShowToastEvent({
             title : 'Error',
             message : 'Error in Sending Email',
             variant : 'error'
         });
         this.dispatchEvent(event);
    })
      this.active = false;
    }

    handleSave(){
        this.isLoadeding = true;
        let attachmentIds = '';
        this.mylists.forEach(function(acc){
            if(acc.isSelected === true){
                attachmentIds = attachmentIds + acc.id + ',';
            }
        });
        const copyattachmentIds = attachmentIds.slice(0, -1);
        saveAttachmentToDraftEmail({ 
             attachments : copyattachmentIds, 
             caseId : this.recordId
         }).then(result =>{
             this.isLoadeding = false;
            let title = 'Success';
            let message = 'Saved Attachment to Draft Email';
            let variant = 'success';
            this.bShowModal = true;
            if(result === null){
                title = 'Warning';
                message = 'There is no Email available in draft.';
                variant = 'warning';
                this.bShowModal = false;
            }
            const event = new ShowToastEvent({
                 title : title,
                 message : message,
                 variant : variant
             });
             this.dispatchEvent(event);
        }).catch(error =>{
            this.isLoadeding = false;
            console.log(error);
            const event = new ShowToastEvent({
                 title : 'Error',
                 message : 'Error Saving Attachment to Draft Email',
                 variant : 'error'
             });
             this.dispatchEvent(event);
        })
        this.handleReset();
        this.active = true;
        
    }
}