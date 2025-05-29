import { LightningElement, track,api,wire } from 'lwc';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import {IsConsoleNavigation,getFocusedTabInfo,closeTab} from 'lightning/platformWorkspaceApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitBulkForms from '@salesforce/apex/CNT_CSM_CreateInformationOffering.submitBulkForms';
export default class Lwc_csm_dataReportMaintenance extends NavigationMixin(LightningElement) {
    @api recordId;
    @api reportType;
    @api recordTypeName;
    @api productName;
    @track offeringWrapper;
    isReport = false;
    isMarket = false;
    formValue;
    keyIndex = 0;
    btnDisabled = false;
    showError = false;
    errorMsg = new Set();
    @track createform = {Form_Request_Type__c : '',ReportAction__c:'',Action__c:'',Audit_Type__c:'',ReportClientNumber__c:'',ReportClientNumber2__c:'',
    ReportNumber__c:'',Request_ID__c:'',MarketToCopyFrom__c:'',File_Code_Market_Description__c:''};
    @track itemList = [
        {
            id: 0,Form_Request_Type__c :  '',ReportAction__c:'',Action__c:'',Audit_Type__c:'',ReportClientNumber__c:'',ReportClientNumber2__c:'',
            ReportNumber__c:'',Request_ID__c:'',MarketToCopyFrom__c:'',File_Code_Market_Description__c:''

        }
    ];

    @wire(CurrentPageReference)
    currentPageReference;

    @wire(IsConsoleNavigation) isConsoleNavigation;

    focusedTabInfo;

    handleChange(event) {
        this.formValue = event.detail.value;
    }

    connectedCallback() {
        if(this.reportType != null && this.reportType == 'Report Maintenance') {
            this.isReport = true;
            this.createform.Form_Request_Type__c = 'Report Maintenance';
            this.itemList[0].Form_Request_Type__c = 'Report Maintenance';
            this.formValue = 'Report Maintenance';
        }else if(this.reportType != null && this.reportType == 'Market Definition'){
            this.isMarket = true;
            this.createform.Form_Request_Type__c = 'Market Maintenance';
            this.itemList[0].Form_Request_Type__c = 'Market Maintenance';
            this.createform.Action__c = 'New';
            this.itemList[0].Action__c = 'New';
            this.formValue = 'Market Maintenance';
        }
        let pathname = this.currentPageReference.state.ws;
        if(this.recordId == null && pathname.includes('Case') && pathname.includes('/500') && pathname.includes('/view')) {
            this.recordId = pathname.split('/')[4];
        }
        console.log('c__myParam ='+ JSON.stringify(this.currentPageReference));
    }

    renderedCallback() {
        this.checkFormTypeValidation(this.keyIndex);
    }

    addRow(event) {
        const indexId = event.target.accessKey;
        const forms = this.template.querySelectorAll('lightning-record-edit-form');
        let isVal = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            isVal = isVal && element.reportValidity();      
        });
        if(!isVal){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Add record',
                    message: 'Please enter all the required fields',
                    variant: 'error',
                }),
            );
        }
	    if(this.formValue == 'Report Maintenance' || this.formValue == 'Product Report' || this.formValue == 'Unit Reports' || (this.formValue == 'Market Maintenance' && this.productName != null && !(this.productName.toLowerCase().startsWith("fia") || this.productName.toLowerCase().startsWith("laad") || this.productName.toLowerCase().startsWith("xponent prescribing dynamics") || this.productName.toLowerCase().startsWith("npa market dynamics")))){
        const name1Field = this.template.querySelector('lightning-input-field[data-id="'+indexId+'"][data-name="reportClientNumber"]');
	        const name2Field = this.template.querySelector('lightning-input-field[data-id="'+indexId+'"][data-name="reportClientNumber2"]');
            const name1Value = name1Field.value ? name1Field.value : '';
            const name2Value = name2Field.value ? name2Field.value : '';
            if ((name1Value == '' && name2Value == '')) {
                isVal = false;
                const keyval = this.keyIndex+1;
                this.dispatchEvent(
                    new ShowToastEvent({title: 'Error Add record',
                        message: 'Please select either one of Client Number from 000 to 499 or 500 to 999 for '+keyval+' row.',
                        variant: 'error',
                    }),
                );
            }
            name1Field.reportValidity();
            name2Field.reportValidity();
        }
        if(isVal){
            ++this.keyIndex;
            var newItem = this.reportType == 'Report Maintenance' ? [{ id: this.keyIndex , Form_Request_Type__c : 'Report Maintenance'}] : [{ id: this.keyIndex }];
            this.itemList = this.itemList.concat(newItem);
        }
        
    }

    cloneRow(event) {
        const indexId = event.target.accessKey;
        const forms = this.template.querySelectorAll('lightning-record-edit-form');
        let isVal = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            isVal = isVal && element.reportValidity();      
        });
        if(!isVal){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Clone record',
                    message: 'Please enter all the required fields',
                    variant: 'error',
                }),
            ); 
        }
        if(this.formValue == 'Report Maintenance' || this.formValue == 'Product Report' || this.formValue == 'Unit Reports' || (this.formValue == 'Market Maintenance' && this.productName != null && !(this.productName.toLowerCase().startsWith("fia") || this.productName.toLowerCase().startsWith("laad") || this.productName.toLowerCase().startsWith("xponent prescribing dynamics") || this.productName.toLowerCase().startsWith("npa market dynamics")))){
            const name1Field = this.template.querySelector('lightning-input-field[data-id="'+indexId+'"][data-name="reportClientNumber"]');
	        const name2Field = this.template.querySelector('lightning-input-field[data-id="'+indexId+'"][data-name="reportClientNumber2"]');
            const name1Value = name1Field.value ? name1Field.value : '';
            const name2Value = name2Field.value ? name2Field.value : '';
            if ((name1Value == '' && name2Value == '')) {
                isVal = false;
                const keyval = this.keyIndex+1;
                this.dispatchEvent(
                    new ShowToastEvent({title: 'Error Add record',
                        message: 'Please select either one of Client Number from 000 to 499 or 500 to 999 for '+keyval+' row.',
                        variant: 'error',
                    }),
                );
            }
            name1Field.reportValidity();
            name2Field.reportValidity();
        }
        [...this.template.querySelectorAll('lightning-input-field[data-id="'+indexId+'"]')]
        .forEach((element) => {
            
            if(element.fieldName == 'Form_Request_Type__c'){
                this.createform.Form_Request_Type__c = element.value;
            }else if(element.fieldName == 'ReportAction__c'){
                this.createform.ReportAction__c = element.value;
            }else if(element.fieldName == 'Action__c'){
                this.createform.Action__c = element.value;
            }else if(element.fieldName == 'Audit_Type__c'){
                this.createform.Audit_Type__c = element.value;
            }else if(element.fieldName == 'ReportClientNumber__c'){
                this.createform.ReportClientNumber__c = element.value;
            }else if(element.fieldName == 'ReportClientNumber2__c'){
                this.createform.ReportClientNumber2__c = element.value;
            }else if(element.fieldName == 'ReportNumber__c'){
                this.createform.ReportNumber__c = element.value;
            }else if(element.fieldName == 'Request_ID__c'){
                this.createform.Request_ID__c = element.value;
            }else if(element.fieldName == 'MarketToCopyFrom__c'){
                this.createform.MarketToCopyFrom__c = element.value;
            }else if(element.fieldName == 'File_Code_Market_Description__c'){
                this.createform.File_Code_Market_Description__c = element.value;
            }
        });
        
        if(isVal){
            ++this.keyIndex;
            var newItem = [{ id: this.keyIndex,Form_Request_Type__c :this.createform.Form_Request_Type__c,ReportAction__c:this.createform.ReportAction__c,Action__c:this.createform.Action__c,
                Audit_Type__c:this.createform.Audit_Type__c,ReportClientNumber__c:this.createform.ReportClientNumber__c,ReportClientNumber2__c:this.createform.ReportClientNumber2__c,
            ReportNumber__c:this.createform.ReportNumber__c,Request_ID__c:this.createform.Request_ID__c,MarketToCopyFrom__c:this.createform.MarketToCopyFrom__c,
            File_Code_Market_Description__c:this.createform.File_Code_Market_Description__c }];
            this.itemList = this.itemList.concat(newItem);
            if(this.createform.Form_Request_Type__c == 'Market Maintenance' || this.createform.Form_Request_Type__c == 'Product Report'){
                [...this.template.querySelectorAll('div[data-id="'+this.keyIndex+'"]')].forEach((element) => {
                    element.className='slds-show';
                    
                });
            }
        }
        
    }

    removeRow(event) {
        if (this.itemList.length >= 2) {
            this.itemList = this.itemList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
    }
    handleFormTypeChange(event){
        this.createform.Form_Request_Type__c = event.target.value;
        if(event.target.value == 'Report Maintenance'){
            this.btnDisabled = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Report Maintenance is not supported for Case Type Market Definition.Please select other value',
                    variant: 'error',
                }),
            );
        }
        this.checkFormTypeValidation(event.target.dataset.id);
    }

    checkFormTypeValidation(indexid){

        if(this.createform.Form_Request_Type__c == 'Market Maintenance'){
            this.btnDisabled = false;
            [...this.template.querySelectorAll('[data-id="'+indexid+'"]')]
            .filter((element) => ['Action__c','ReportNumber__c','Request_ID__c'].includes(element.fieldName))
            .forEach((element) => {
                if(element.fieldName == 'Action__c' ){
                    element.disabled = false;
                }else if(element.fieldName == 'ReportNumber__c' ){
                    element.required = true;
                }else if(element.fieldName == 'Request_ID__c' && this.productName != null && (this.productName.toLowerCase().startsWith("ddd") || this.productName.toLowerCase().startsWith("xponent") || this.productName.toLowerCase().startsWith("ddd md")) ){
                    element.required = false;
                }else if(element.fieldName == 'Request_ID__c'){
                    element.required = true;
                }
            });
            [...this.template.querySelectorAll('div[data-id="'+indexid+'"]')].forEach((element) => {
                element.className='slds-show';
                
            });
        }else if(this.createform.Form_Request_Type__c == 'Product Report'){
            this.btnDisabled = false;
            [...this.template.querySelectorAll('[data-id="'+indexid+'"]')]
            .filter((element) => ['Action__c','ReportNumber__c','Request_ID__c','File_Code_Market_Description__c'].includes(element.fieldName))
            .forEach((element) => {
                if(element.fieldName == 'ReportNumber__c' || element.fieldName == 'Request_ID__c' || element.fieldName == 'File_Code_Market_Description__c'){
                    element.reset();
                    if(element.fieldName == 'ReportNumber__c'){
                        element.required = true;
                    }else{
                        element.required = false;
                    }
                }else if(element.fieldName == 'Action__c' ){
                    element.value = 'New';
                    element.disabled = true;
                }
                
            });
            [...this.template.querySelectorAll('div[data-id="'+indexid+'"]')].forEach((element) => {
                element.className='slds-hide';
            });
            [...this.template.querySelectorAll('div[data-id="'+indexid+'"][data-name="divReportNumber"]')].forEach((element) => {
                element.className='slds-show';
                
            });
        }else if(this.createform.Form_Request_Type__c == 'Unit Reports'){
            this.btnDisabled = false;
            [...this.template.querySelectorAll('[data-id="'+indexid+'"]')]
            .filter((element) => ['Action__c','ReportNumber__c','Request_ID__c','File_Code_Market_Description__c'].includes(element.fieldName))
            .forEach((element) => {
                if(element.fieldName == 'ReportNumber__c' || element.fieldName == 'Request_ID__c' || element.fieldName == 'File_Code_Market_Description__c'){
                    element.required = false;
                    element.reset();
                }
                if(element.fieldName == 'Action__c' ){
                    element.value = 'New';
                    element.disabled = true;
                }
                
            });
            [...this.template.querySelectorAll('div[data-id="'+indexid+'"]')].forEach((element) => {
                element.className='slds-hide';
            });
        }else{
            [...this.template.querySelectorAll('[data-id="'+indexid+'"]')]
            .filter((element) => ['Action__c'].includes(element.fieldName))
            .forEach((element) => {
                if(element.fieldName == 'Action__c' ){
                    element.disabled = false;
                }
            });
        }
        this.checkActiionValidation(indexid);
    }
    
    handleActionChange(event){
        this.createform.Action__c = event.target.value;
        this.checkActiionValidation(event.target.dataset.id);
    }

    checkActiionValidation(indexid){

        if(this.createform.Form_Request_Type__c == 'Market Maintenance' && this.createform.Action__c == 'Existing'){
            
            [...this.template.querySelectorAll('div[data-id="'+indexid+'"][data-name="divMarketToCopyFrom"]')].forEach((element) => {
                element.className='slds-hide';
                
            });
            [...this.template.querySelectorAll('div[data-id="'+indexid+'"][data-name="divFileCodeMarketDescription"]')].forEach((element) => {
                element.className='slds-hide';
                
            });
            [...this.template.querySelectorAll('[data-id="'+indexid+'"]')]
            .filter((element) => ['MarketToCopyFrom__c','File_Code_Market_Description__c'].includes(element.fieldName))
            .forEach((element) => {
                if(element.fieldName == 'MarketToCopyFrom__c' || element.fieldName == 'File_Code_Market_Description__c'){
                    element.reset();
                }
                
            });

        }else if(this.createform.Form_Request_Type__c == 'Market Maintenance' && this.createform.Action__c == 'Delete'){
            [...this.template.querySelectorAll('[data-id="'+indexid+'"]')]
            .filter((element) => ['MarketToCopyFrom__c','File_Code_Market_Description__c'].includes(element.fieldName))
            .forEach((element) => {
                if(element.fieldName == 'MarketToCopyFrom__c'){
                    element.reset();
                }
                if(element.fieldName == 'File_Code_Market_Description__c'){
                    element.required = true;
                }else{
                    element.required = false;
                }
                
            });
            [...this.template.querySelectorAll('div[data-id="'+indexid+'"][data-name="divMarketToCopyFrom"]')].forEach((element) => {
                element.className='slds-hide';
                
            });
            [...this.template.querySelectorAll('div[data-id="'+indexid+'"][data-name="divFileCodeMarketDescription"]')].forEach((element) => {
                element.className='slds-show';
                
            });
        }else if(this.createform.Form_Request_Type__c == 'Market Maintenance'){
            [...this.template.querySelectorAll('[data-id="'+indexid+'"]')]
            .filter((element) => ['Request_ID__c','MarketToCopyFrom__c','File_Code_Market_Description__c'].includes(element.fieldName))
            .forEach((element) => {
                if(element.fieldName == 'MarketToCopyFrom__c' || element.fieldName == 'File_Code_Market_Description__c'){
                    element.reset();
                }
                if(element.fieldName == 'Request_ID__c' && this.productName != null && (this.productName.toLowerCase().startsWith("ddd") || this.productName.toLowerCase().startsWith("xponent") || this.productName.toLowerCase().startsWith("ddd md")) ){
                    element.required = false;
                }else if(element.fieldName == 'Request_ID__c'){
                    element.required = true;
                }
                
            });
            [...this.template.querySelectorAll('div[data-id="'+indexid+'"][data-name="divMarketToCopyFrom"]')].forEach((element) => {
                element.className='slds-show';
                
            });
            [...this.template.querySelectorAll('div[data-id="'+indexid+'"][data-name="divFileCodeMarketDescription"]')].forEach((element) => {
                element.className='slds-show';
                
            });
        }
    }
    handleSubmit(event) {
        let isVal = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            isVal = isVal && element.reportValidity();
            //console.log(element.fieldName+' : '+element.reportValidity());
            if(element.fieldName == 'ReportClientNumber__c' || element.fieldName == 'ReportClientNumber2__c'){

            }
        });
        if(isVal){
            const forms = this.template.querySelectorAll('lightning-record-edit-form');
            forms.forEach((form) => {
                const formValue = form.querySelector('[data-name="FormRequestType"]').value;
                if(formValue == 'Report Maintenance' || formValue == 'Product Report' || formValue == 'Unit Reports' || (formValue == 'Market Maintenance' && this.productName != null && !(this.productName.toLowerCase().startsWith("fia") || this.productName.toLowerCase().startsWith("laad") || this.productName.toLowerCase().startsWith("xponent prescribing dynamics") || this.productName.toLowerCase().startsWith("npa market dynamics")))){
                const name1Field = form.querySelector('[data-name="reportClientNumber"]');
                const name2Field = form.querySelector('[data-name="reportClientNumber2"]');
                const name1Value = name1Field.value ? name1Field.value : '';
                const name2Value = name2Field.value ? name2Field.value : '';
                if ((name1Value == '' && name2Value == '')) {
                    isVal = false;
                    name1Field.setErrors('select one or other');
                    name2Field.setErrors('select one or other');
                } else {
                    name1Field.setErrors('');
                    name2Field.setErrors('');
                }
                name1Field.reportValidity();
                name2Field.reportValidity();
            }
            });
            if(isVal){

            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: 'Please select either one of Client Number from 000 to 499 or 500 to 999.',
                        variant: 'error',
                    }),
                );
            }    
        }else{ 
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: 'Please enter all the required fields',
                    variant: 'error',
                }),
            );
        }
        

        if (isVal) {
            
            var formList =[];
            for(let indexId = 0; indexId < this.itemList.length; indexId++) {

                [...this.template.querySelectorAll('lightning-input-field[data-id="'+indexId+'"]')]
            .forEach((element) => {
                
                 if(element.fieldName == 'Form_Request_Type__c'){
                    this.createform.Form_Request_Type__c = element.value;
                }else if(element.fieldName == 'ReportAction__c'){
                    this.createform.ReportAction__c = element.value;
                }else if(element.fieldName == 'Action__c'){
                    this.createform.Action__c = element.value;
                }else if(element.fieldName == 'Audit_Type__c'){
                    this.createform.Audit_Type__c = element.value;
                }else if(element.fieldName == 'ReportClientNumber__c'){
                    this.createform.ReportClientNumber__c = element.value;
                }else if(element.fieldName == 'ReportClientNumber2__c'){
                    this.createform.ReportClientNumber2__c = element.value;
                }else if(element.fieldName == 'ReportNumber__c'){
                    this.createform.ReportNumber__c = element.value;
                }else if(element.fieldName == 'Request_ID__c'){
                    this.createform.Request_ID__c = element.value;
                }else if(element.fieldName == 'MarketToCopyFrom__c'){
                    this.createform.MarketToCopyFrom__c = element.value;
                }else if(element.fieldName == 'File_Code_Market_Description__c'){
                    this.createform.File_Code_Market_Description__c = element.value;
                }
            });
            var newItem = { Case__c: this.recordId,Form_Request_Type__c :this.createform.Form_Request_Type__c,ReportAction__c:this.createform.ReportAction__c,Action__c:this.createform.Action__c,
                Audit_Type__c:this.createform.Audit_Type__c,ReportClientNumber__c:this.createform.ReportClientNumber__c,ReportClientNumber2__c:this.createform.ReportClientNumber2__c,
            ReportNumber__c:this.createform.ReportNumber__c,Request_ID__c:this.createform.Request_ID__c,MarketToCopyFrom__c:this.createform.MarketToCopyFrom__c,
            File_Code_Market_Description__c:this.createform.File_Code_Market_Description__c };
            formList.push(newItem);
            }
            submitBulkForms({jsonString : JSON.stringify(formList)})
            .then(result => {
                console.log('result :' + result);
                if(result == 'Ok'){
                    if (this.isConsoleNavigation) {
                        getFocusedTabInfo().then((tabInfo) => {
                            this.focusedTabInfo = tabInfo;
                            closeTab(tabInfo.tabId);
                        }).catch(function(error){
                            console.log(error);
                        });
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: this.reportType+' records created successfully.',
                            variant: 'success',
                        }),
                    );
                    // Navigate to the Case Record page
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordRelationshipPage',
                        attributes: {
                            recordId: this.recordId,
                            objectApiName: "Case",
                            relationshipApiName: "CSM_CREATE_FORMS__r",
                            actionName: "view",
                        },
                    });
                }
                
            })
            .catch(error => {
                this.handleError(error, 'submitBulkForms');
            });

            /*var count = 0;
            this.template.querySelectorAll('lightning-record-edit-form').forEach(element => {
                element.submit();
                count++;
                if(this.itemList.length == count){
                    if (this.isConsoleNavigation) {
                        getFocusedTabInfo().then((tabInfo) => {
                            this.focusedTabInfo = tabInfo;
                            closeTab(tabInfo.tabId);
                        }).catch(function(error){
                            console.log(error);
                        });
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Report Maintenance successfully created',
                            variant: 'success',
                        }),
                    );
                    // Navigate to the Case Record page
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordRelationshipPage',
                        attributes: {
                            recordId: this.recordId,
                            objectApiName: "Case",
                            relationshipApiName: "CSM_CREATE_FORMS__r",
                            actionName: "view",
                        },
                    });    
                }
            });*/
        }
    }
    handleError(error, methodName) {
        console.log(methodName + ' : ' + JSON.stringify(error));
        this.errorMsg = new Set();
        if (Array.isArray(error)) {
            error.forEach(currentError => {
                this.errorMsg.add(currentError);
            });
        } else {
            var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
            if (JSON.parse(err).fieldErrors) {
                let fieldError = JSON.parse(err).fieldErrors;
                for (let [key, value] of Object.entries(fieldError)) {
                    this.errorMsg.add(key + ': ' + value[0].message);
                }
            } else {
                this.errorMsg.add(err == "{}" ? 'Unexpected error !!!' : err);
            }
        }
        this.showError = true;
    }

}
