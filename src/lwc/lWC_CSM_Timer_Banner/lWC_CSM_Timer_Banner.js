import { LightningElement, api, track, wire } from 'lwc';
    import { ShowToastEvent } from 'lightning/platformShowToastEvent';
    import SendDataFromUser from '@salesforce/apex/CNT_CSM_Timer.SendDataFromUser';
    import RecordCreatedThisWeek_Count from '@salesforce/apex/CNT_CSM_Timer.RecordCreatedThisWeek_Count';
    import checkEligibilityForExplictUpdate from '@salesforce/apex/CNT_CSM_Timer.checkEligibilityForExplictUpdate';

    export default class LWC_CSM_Timer_Banner extends LightningElement {
        disableButton = false;
        showComponent =false;
        recordSynced;
        recordUnsynced;
        @api recordId;
    async connectedCallback() {
        console.log('OUTPUT : ',this.showComponent);
        
        RecordCreatedThisWeek_Count()
        .then(result=>{
            if(result!=null )
            {
                console.log('OUTPUT : ',result);
                if(result[0]>0){
                    this.showComponent = true;
                }
                this.recordSynced = result[1];
                this.recordUnsynced = result[2];
                if(result[2]==0)
                {
                    this.disableButton = true;
                }
            }
        }),checkEligibilityForExplictUpdate({recordId:this.recordId}).
        then(result=>{
            this.showComponent = result;
        })

        
    }


    async handleClick(event) {
        
            this.disableButton = true;
                SendDataFromUser()
                .then(result=>{
                    console.log('OUTPUT : log',result);
                    if(result!=null && result != ''){
                        if(result.indexOf('Success:') != -1){
                            this.showSuccess('Success',result.replace('Success:', ''));
                        }
                        else if(result.indexOf('Error:') != -1){
                            this.showError('Error',result.replace('Error:', ''));
                        }
                        else if (result.indexOf('Warning:') != -1){
                            this.showWarning('Warning',result.replace('Warning:', ''));
                        }
                        this.disableButton = false;
                    }
                    else{
                        this.showError('Error','Failed to update.');
                        this.disableButton = false;
                    }
                    this.connectedCallback();
                })
    }

    showError(title,msg) {
        const evt = new ShowToastEvent({
            title: title,
            message: msg,
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }
    showWarning(title,msg) {
        const evt = new ShowToastEvent({
            title: title,
            message: msg,
            variant: 'warning'
        });
        this.dispatchEvent(evt);
    }
    showSuccess(title,msg) {
        const evt = new ShowToastEvent({
            title: title,
            message: msg,
            variant: 'success'
        });
        this.dispatchEvent(evt);
    }

    handleShow(event) {
            this.template.querySelector('[data-id="divblock"]').className='slds-show';
            
                
    }
    handleHide(event) {
            this.template.querySelector('[data-id="divblock"]').className='slds-hide';
            
    }

    }