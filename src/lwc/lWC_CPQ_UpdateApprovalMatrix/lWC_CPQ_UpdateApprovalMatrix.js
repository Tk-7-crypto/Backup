import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { refreshApex } from '@salesforce/apex';
import approvalMatrixDetails from '@salesforce/apex/CNT_CPQ_ApprovalMatrixController.fetchApprovalMatrix';
const columns1 = [
    {
        label: 'Levels',
        fieldName: 'Levels__c',
        type: 'text'
    },
    {
        label: 'Country',
        fieldName: 'Country__c',
        type: 'text'
    },
    {
        label: 'Max Amount',
        fieldName: 'Max_Amount__c',
        type: 'number'
    },
    {
        label: 'Min Amount',
        fieldName: 'Min_Amount__c',
        type: 'number'
    },
    {
        label: 'Max Discount Percent',
        fieldName: 'Max_Discount_Percent__c',
        type: 'percent'
    },
    {
        label: 'Min Discount Percent',
        fieldName: 'Min_Discount_Percent__c',
        type: 'percent'
    },
    {
        label: 'Max Discount Amount',
        fieldName: 'Max_Discount_Amount__c',
        type: 'number'
    },
    {
        label: 'Min Discount Amount',
        fieldName: 'Min_Discount_Amount__c',
        type: 'number'
    },
    {
        label: 'Approver 1',
        fieldName: 'approver1URL',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'approver1Name' },
            target: '_blank'
        }
    },
    {
        label: 'Approver 2',
        fieldName: 'approver2URL',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'approver2Name' },
            target: '_blank'
        }
    },
    {
        label: 'Approver 3',
        fieldName: 'approver3URL',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'approver3Name' },
            target: '_blank'
        }
    },
    {
        label: 'Approver 4',
        fieldName: 'approver4URL',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'approver4Name' },
            target: '_blank'
        }
    },
    {
        label: 'Approver 5',
        fieldName: 'approver5URL',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'approver5Name' },
            target: '_blank'
        }
    },
    {
        label: 'Notifier 1',
        fieldName: 'Notifier_1__c',
        type: 'text'
    },
    {
        label: 'Notifier 2',
        fieldName: 'Notifier_2__c',
        type: 'text'
    },
    {
        label: 'Notifier 3',
        fieldName: 'Notifier_3__c',
        type: 'text'
    },
    {
        label: 'Notifier 4',
        fieldName: 'Notifier_4__c',
        type: 'text'
    },
    {
        label: 'Notifier 5',
        fieldName: 'Notifier_5__c',
        type: 'text'
    },
    {
        label: 'Auto Approve',
        fieldName: 'Auto_Approve__c',
        type: 'boolean'
    },
    {
        label: 'Approve On First Response',
        fieldName: 'Approve_On_First_Response__c',
        type: 'boolean'
    },
    {
        type:  'button',
        initialWidth: 100,
        typeAttributes: 
           {
               variant: 'brand',
               label: 'Edit', 
               name: 'editRecord', 
               title: 'Edit', 
               disabled: false, 
           }
     }
];
const columns2 = [
    {
        label: 'Levels',
        fieldName: 'Levels__c',
        type: 'text'
    },
    {
        label: 'Country',
        fieldName: 'Country__c',
        type: 'text'
    },
    {
        label: 'Max Amount',
        fieldName: 'Max_Amount__c',
        type: 'number'
    },
    {
        label: 'Min Amount',
        fieldName: 'Min_Amount__c',
        type: 'number'
    },
    {
        label: 'Max Gross Margin',
        fieldName: 'Max_Gross_Margin__c',
        type: 'percent'
    },
    {
        label: 'Min Gross Margin',
        fieldName: 'Min_Gross_Margin__c',
        type: 'percent'
    },
    {
        label: 'Approver 1',
        fieldName: 'approver1URL',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'approver1Name' },
            target: '_blank'
        }
    },
    {
        label: 'Approver 2',
        fieldName: 'approver2URL',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'approver2Name' },
            target: '_blank'
        }
    },
    {
        label: 'Approver 3',
        fieldName: 'approver3URL',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'approver3Name' },
            target: '_blank'
        }
    },
    {
        label: 'Approver 4',
        fieldName: 'approver4URL',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'approver4Name' },
            target: '_blank'
        }
    },
    {
        label: 'Approver 5',
        fieldName: 'approver5URL',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'approver5Name' },
            target: '_blank'
        }
    },
    {
        label: 'Notifier 1',
        fieldName: 'Notifier_1__c',
        type: 'text'
    },
    {
        label: 'Notifier 2',
        fieldName: 'Notifier_2__c',
        type: 'text'
    },
    {
        label: 'Notifier 3',
        fieldName: 'Notifier_3__c',
        type: 'text'
    },
    {
        label: 'Notifier 4',
        fieldName: 'Notifier_4__c',
        type: 'text'
    },
    {
        label: 'Notifier 5',
        fieldName: 'Notifier_5__c',
        type: 'text'
    },
    {
        label: 'Auto Approve',
        fieldName: 'Auto_Approve__c',
        type: 'boolean'
    },
    {
        label: 'Approve On First Response',
        fieldName: 'Approve_On_First_Response__c',
        type: 'boolean'
    },
    {
        type:  'button',
        initialWidth: 100,
        typeAttributes: 
           {
               variant: 'brand',
               label: 'Edit', 
               name: 'editRecord', 
               title: 'Edit', 
               disabled: false, 
           }
     }
];
export default class LWC_CPQ_UpdateApprovalMatrix extends NavigationMixin (LightningElement) {

    @track columns;
    @track approvalMatrixData = [];
    @track countryLabelMap = new Map();
    @track countryToApprovalMatrixMap = new Map();
    @track selectedCountry;
    @track countryOptions;
    @track showSpinner = true;
    @track showCountry = false;
    @track showApprovalMatrix = false;
    @track showPricingToolOptions = false;
    @track pricingToolOptions;
    @track selectedPricingToolOption;
    @track approvalMatrixObj;

    @wire(approvalMatrixDetails)
    wiredApprovalMatrixDetails(result) {
        this.approvalMatrixObj = result;
        this.columns = columns1;
        if (result.data) {
            for(var key in result.data.countryToApprovalMatrixMap){
                this.countryToApprovalMatrixMap.set(key, result.data.countryToApprovalMatrixMap[key]);
            }
            for(var key in result.data.countryLabelAndCodeMap){
                this.countryLabelMap.set(key, result.data.countryLabelAndCodeMap[key]);
            }
            let pricingOptions = [];
            result.data.pricingToolList.forEach(item => {
                pricingOptions.push({ label: item, value: item });
            })
            this.pricingToolOptions = pricingOptions;
            if(this.pricingToolOptions.length > 1){
                this.showPricingToolOptions = true;
            }
            else if(this.pricingToolOptions.length == 1){
                this.selectedPricingToolOption = this.pricingToolOptions[0].value;
                
                let tempCountryOptions = [];
                for(var key of this.countryToApprovalMatrixMap.keys()){
                    var arr = key.split(':')
                    var country = arr[0];
                    var pricingTool = arr[1];
                    if(this.selectedPricingToolOption == pricingTool){
                        if(this.selectedPricingToolOption == 'AMESA'){
                            this.columns = columns1;
                            tempCountryOptions.push({ label: this.countryLabelMap.get(country), value: country });
                        }
                        else{
                            this.columns = columns2;
                            tempCountryOptions.push({ label: country, value: country });
                        }
                    }
                }
                this.countryOptions = tempCountryOptions.sort();
                this.showCountry = true;
            }
            this.showSpinner = false;
        }else if (result.error) {
            this.error = error;
            this.showSpinner = false;
        }
    }

    handlePricingToolOption(event) {
        this.selectedPricingToolOption = event.detail.value;
        let tempCountryOptions = [];
        for(var key of this.countryToApprovalMatrixMap.keys()){
            var arr = key.split(':')
            var country = arr[0];
            var pricingTool = arr[1];
            if(this.selectedPricingToolOption == pricingTool){
                if(this.selectedPricingToolOption == 'AMESA'){
                    this.columns = columns1;
                    tempCountryOptions.push({ label: this.countryLabelMap.get(country), value: country });
                }
                else{
                    this.columns = columns2;
                    tempCountryOptions.push({ label: country, value: country });
                }
            }
        }
        this.countryOptions = tempCountryOptions.sort();
        this.showCountry = true;
        this.showApprovalMatrix = false;
        if (this.countryOptions.length == 1) {
            this.selectedCountry = this.countryOptions[0].value;
            this.handleDataChange();
        }
    }

    handleSelectedCountry(event) {
        if(event != undefined){
            this.selectedCountry = event.detail.value;
        }
        this.handleDataChange();
    }
    handleDataChange() {
        var key = this.selectedCountry+':'+this.selectedPricingToolOption;
        let tempPickList  = JSON.parse(JSON.stringify(this.countryToApprovalMatrixMap.get(key)));
        tempPickList.forEach(record => {
            record.approver1URL =  record.Approver_1__r != undefined ? `/lightning/r/${record.Approver_1__r.Id}/view` : "";
            record.approver1Name = record.Approver_1__r != undefined ? record.Approver_1__r.Name : "";
            record.approver2URL = record.Approver_2__r != undefined ? `/lightning/r/${record.Approver_2__r.Id}/view` : "";
            record.approver2Name = record.Approver_2__r != undefined ? record.Approver_2__r.Name : "";
            record.approver3URL = record.Approver_3__r != undefined ? `/lightning/r/${record.Approver_3__r.Id}/view` : "";
            record.approver3Name = record.Approver_3__r != undefined ? record.Approver_3__r.Name : "";
            record.approver4URL = record.Approver_4__r != undefined ? `/lightning/r/${record.Approver_4__r.Id}/view` : "";
            record.approver4Name = record.Approver_4__r != undefined ? record.Approver_4__r.Name : "";
            record.approver5URL = record.Approver_5__r != undefined ? `/lightning/r/${record.Approver_5__r.Id}/view` : "";
            record.approver5Name =record.Approver_5__r != undefined ? record.Approver_5__r.Name : "";

            record.Max_Discount_Percent__c = record.Max_Discount_Percent__c != undefined && record.Max_Discount_Percent__c != 0 ? record.Max_Discount_Percent__c/100 : record.Max_Discount_Percent__c;
            record.Min_Discount_Percent__c = record.Min_Discount_Percent__c != undefined && record.Min_Discount_Percent__c != 0 ? record.Min_Discount_Percent__c/100 : record.Min_Discount_Percent__c;
            record.Max_Gross_Margin__c = record.Max_Gross_Margin__c != undefined && record.Max_Gross_Margin__c != 0 ? record.Max_Gross_Margin__c/100 : record.Max_Gross_Margin__c;
            record.Min_Gross_Margin__c = record.Min_Gross_Margin__c != undefined && record.Min_Gross_Margin__c != 0 ? record.Min_Gross_Margin__c/100 : record.Min_Gross_Margin__c;
        })
        this.approvalMatrixData = this.sortingMethod('Levels__c', 'asc', tempPickList);
        this.showApprovalMatrix = true;
        this.showSpinner = false;
    }
    handleEditAction(event) {
        var selectedRowId = event.detail.row.Id;
        const config = {
          type: "standard__recordPage",
          attributes: {
            recordId: selectedRowId,
            objectApiName: "Approval_Matrix__c",
            actionName: "edit"
          }
        };
        this[NavigationMixin.Navigate](config);
        
    }
	handleRefresh(){
        this.showSpinner = true;
        refreshApex(this.approvalMatrixObj)
        .then(() => this.handleSelectedCountry())
        .catch(() => this.showSpinner = false);
    }

    sortingMethod(fieldname, direction, data){
        let parseData = JSON.parse(JSON.stringify(data));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        return parseData;
    }
}