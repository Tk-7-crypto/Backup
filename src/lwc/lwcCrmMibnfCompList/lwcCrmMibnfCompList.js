import { LightningElement,api,track } from 'lwc';
import massUpdateBNF from '@salesforce/apex/CNT_CRM_OpportunityProductSearch.massUpdateBNF';


export default class LwcCrmMibnfCompList extends LightningElement {
    @api wiredMibnfComponentdata;
    @track mibnfCompDataToDisplay;
    @api headerTextValue;
    @api valueChangePerct; 
    @api finalBillingPlanMap;
    @api isError;
    showConfirmationdialog = false;
    selectedMibnfComponentId = '';
    disableUpdateButtonList = [];
    toastType;
    toastMessage;
    toastAutoCloseTime = 2500;
    showToastBar = false;
    showSpinner = false;
    @api setMibnfList(value){
        this.mibnfCompDataToDisplay = value;
    }
    connectedCallback(){
        this.mibnfCompDataToDisplay = JSON.parse(JSON.stringify(this.wiredMibnfComponentdata));
        console.log(this.mibnfCompDataToDisplay);
    }

    columns = [
        { label: 'Name', fieldName: 'name'},
        { label: 'Bill To', fieldName: 'billToName'},
        { label: 'PO Number', fieldName: 'poNumber'},
        { label: 'BNF Value', fieldName: 'contractValue', type :'currency',typeAttributes: { currencyCode: { fieldName: 'currencyisocode' }, currencyDisplayAs: 'code' }},
        { label: 'BNF Status', fieldName: 'bnfStatus'},
        { type:  'button', cellAttributes:{class:{fieldName:'buttoncenterStyle'}}, typeAttributes: {label: 'Update', name: 'Update', title: 'Update', disabled: {fieldName: 'disableUpdateButton'}}}
    ];
    
    
    selectBNF() {
        var selectedRow;
        var selectedData;
        selectedRow = this.template.querySelector('lightning-datatable').getSelectedRows();
        selectedData= JSON.parse(JSON.stringify(selectedRow))[0];
        console.log(selectedData);
        this.selectedMibnfComponentId = selectedData.id;
        const showeditabledata = new CustomEvent('loadeditabledata',{
            detail : this.selectedMibnfComponentId
        });
        this.dispatchEvent(showeditabledata);
    }

    confirmUpdate(event) {
        console.log(event.detail.row);
        this.showConfirmationdialog = true;
    }

    cancelUpdate() {
        this.showConfirmationdialog = false;
    }

    handleSingleUpdate(event) {
        var selectedId = event.target.value;
        var invoiceHeader = '';
        var bnfValueChange = '';
        var bill = new Map();
        var selectedList = [];
        var selectedDataToSent = '';
        var billingplan = '';
        this.showConfirmationdialog = false;
        if(this.headerTextValue !== undefined && this.headerTextValue !== null){
            invoiceHeader = this.headerTextValue;
        }
        if(this.valueChangePerct !== undefined && this.valueChangePerct !== null){
            bnfValueChange = this.valueChangePerct;
        }
        bill = Object.entries(this.finalBillingPlanMap);
        console.log(selectedId);
        console.log(invoiceHeader);
        console.log(bnfValueChange);
        console.log(bill);
        if(this.finalBillingPlanMap != null){
            billingplan = Object.fromEntries(new Map(bill)); 
        }
        if(invoiceHeader === '' && bnfValueChange === '' && bill.length === 0){
            this.showSpinner = false;
            this.dispatchSpinnerEvent(false);
            this.showToast('Error!', 'Please enter value in any fields of the header section to update.', 'error');
        }
        else{
            this.showSpinner = true;
            this.dispatchSpinnerEvent(true);
            if(selectedId != null){
                selectedList.push(selectedId);
                selectedDataToSent = JSON.stringify(selectedList);
                this.callMassUpdateMethod(event,selectedDataToSent, billingplan);
            }else{
                console.log('Id not Found');
            }
        }
    }


    callMassUpdateMethod(event,selectedDataToSent, billingplan) {
        var callServer = true;
        console.log('mass update bnf');
        
        if(this.isError){
            this.showSpinner = false;
            this.dispatchSpinnerEvent(false);
            callServer = false;
            this.showToast('Error!', 'Please enter valid inputs in the header section', 'error');
        } 
        if(callServer){
            massUpdateBNF({
                recordJSON: selectedDataToSent,
                invoiceTextValue: this.headerTextValue,
                billingPlanMap: JSON.stringify(billingplan),
                bnfValue: this.valueChangePerct
            }).then(result => {
                console.log(result);
                if(!result){
                    this.showToast('No Updates', 'No Updates were made', 'info');
                    this.showSpinner = false;
                    this.dispatchSpinnerEvent(false);
                }
                else if(result){
                    this.showToast('Success!', 'Record Updated successfully', 'success');
                    this.showSpinner = false;
                    this.dispatchSpinnerEvent(false);
                    this.dispatchEvent(new CustomEvent('refreshdata'));
                }
                
            }).catch(error => {
                console.log(JSON.stringify(error));
                this.error = error;
                this.showToast('Error!', error.body.message, 'error');
                this.showSpinner = false;
                this.dispatchSpinnerEvent(false);
            });
        }
    }

    dispatchSpinnerEvent(showSpinner){
        const spinnerEvent = new CustomEvent('loadspinner',{
            detail : showSpinner
        });
        this.dispatchEvent(spinnerEvent);
    }

    showToast(title, message, varient) {
        this.toastType = varient;
        this.toastMessage = message;    
        this.showToastBar = true;
        if(varient != 'error'){
            setTimeout(() => {
                this.closeModel();
            }, this.toastAutoCloseTime);
        }
    }
    closeModel() {
        this.showToastBar = false;
        this.toastType = '';
        this.toastMessage = '';
    }

    get getIconName() {
        return 'utility:' + this.toastType;
    }

    get innerClass() {
        return 'slds-icon_container slds-icon-utility-' + this.toastType + ' slds-icon-utility-success slds-m-right_small slds-no-flex slds-align-top';
    }

    get outerClass() {
        return 'slds-notify slds-notify_toast slds-theme_' + this.toastType;
    }
}