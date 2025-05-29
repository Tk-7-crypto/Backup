import { LightningElement, api } from 'lwc';
import { RecordFieldDataType } from 'lightning/uiRecordApi';
import saveOLI from '@salesforce/apex/BNFProductControllerMobile.saveOLI';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class lwcCrmEditSingleProductEbnf extends LightningElement {
    @api product;
    validateProduct = {};
    @api bnfrecord;
    isErrorFound = false;
    allErrorList = [];
    showSpinner = false;
    productMaterialType = '';
    isProductZQUI = false;
    isProductZREP = false;
    isProductZPUB = false;
    isProductStartDateDisbaled = false;
    isNewBnf = true;
    errorMsg;
    @api allFetchData;
    isRevisedBNF = false;
    allFetchDataLocal;
    isDeliveryMediaRequired= false;
    itemCategoryGroup = '';
    zlicValue = 'ZLIC';
    zpubValue = 'ZPUB';
    zrepValue = 'ZREP';
    zquiValue = 'ZQUI';
    isListPriceRequired = false;
    offeringType = '';
    us_SalesOrg = false;
    label_CES_TOT_Offering_Type = '';
    isSecondBillingDateVisible = false;
    isSecondBillingDateRequired = false;
    isAuditSubscriptionStatusRequired= false;
    isAuditSubscriptionStatusDisabled= false;
    materialGroup1 = '';
    isProfitCenterVisible = false;
    isProfitCenterDisable = false;
    isNotPreventEdit = false;
    
    connectedCallback(){
        this.validateProduct = JSON.parse(JSON.stringify(this.product));
        this.allFetchDataLocal = JSON.parse(JSON.stringify(this.allFetchData));
        this.assignAllFields();
    }

    assignAllFields(){
        if(this.allFetchDataLocal.oliIdToTherapyAreaOptionsMap != null && this.allFetchDataLocal.oliIdToTherapyAreaOptionsMap[this.validateProduct.Id] != undefined){
            this.allFetchDataLocal.therapyAreaOptions = this.allFetchDataLocal.oliIdToTherapyAreaOptionsMap[this.validateProduct.Id];
        }
        if(this.allFetchDataLocal.DeliveryMedia_Map != null && this.allFetchDataLocal.DeliveryMedia_Map[this.validateProduct.Id] != undefined){
            this.allFetchDataLocal.deliveryMediaOptions = this.allFetchDataLocal.DeliveryMedia_Map[this.validateProduct.Id];
        }
        if(this.allFetchDataLocal.DeliveryFrequency_Map != null && this.allFetchDataLocal.DeliveryFrequency_Map[this.validateProduct.Id] != undefined){
            this.allFetchDataLocal.deliveryFrequencyOptions = this.allFetchDataLocal.DeliveryFrequency_Map[this.validateProduct.Id];
        }
        this.isRevisedBNF = this.bnfrecord.Addendum__c;
        this.productMaterialType = this.validateProduct.PricebookEntry.Product2.Material_Type__c;
        this.itemCategoryGroup = this.validateProduct.PricebookEntry.Product2.Item_Category_Group__c;
        this.offeringType = this.validateProduct.PricebookEntry.Product2.Offering_Type__c;
        this.materialGroup1 = this.validateProduct.PricebookEntry.Product2.Material_Group_1__c;
        this.us_SalesOrg = this.allFetchDataLocal.us_SalesOrg;
        this.label_CES_TOT_Offering_Type = this.allFetchDataLocal.Label_CES_TOT_Offering_Type;
        if(this.allFetchDataLocal.PreventEdit){
            this.isNotPreventEdit = false;
            this.isErrorFound = true;
            this.allErrorList = [this.allFetchDataLocal.PreventEdit_Msg];
        }else{
            this.isNotPreventEdit = true;
        }
        if(this.offeringType != 'Management Consulting' && this.offeringType != this.label_CES_TOT_Offering_Type && !this.us_SalesOrg){
            this.isListPriceRequired= true;
        }
        if(this.offeringType == 'National Tracking'){
            this.isAuditSubscriptionStatusRequired = true;
        }else{
            this.isAuditSubscriptionStatusDisabled = true;
        }
        if(this.materialGroup1 == 'MAN'){
            this.isProfitCenterVisible = true;
        }else{
            this.isProfitCenterDisable =true;
        }
        if(this.productMaterialType == 'ZPUB'){
            this.isProductZPUB = true;
        }else if(this.productMaterialType == 'ZREP'){
            this.isProductZREP = true
        }else if(this.productMaterialType == 'ZQUI'){
            this.isProductZQUI = true;
        }
        if(this.isProductZREP && (this.validateProduct.Delivery_Media__c == '' || this.validateProduct.Delivery_Media__c == null)){
            this.validateProduct.Delivery_Media__c = 'Not Applicable [NA]';
        }
        if(this.validateProduct.Revenue_Type__c == 'Ad Hoc'){
            this.isSecondBillingDateRequired = true;
        }
        
    }   
    handleChange(event){
        var fieldName = event.target.name;
        if(fieldName == 'Delivery_Media__c'){
            this.validateProduct.Delivery_Media__c = event.target.value;
        }else if(fieldName == 'Proj_Rpt_Frequency__c'){
            this.validateProduct.Proj_Rpt_Frequency__c = event.target.value;
        }else if(fieldName == 'Therapy_Area__c'){
            this.validateProduct.Therapy_Area__c = event.target.value;
        }
    }
  
    handleSubmit(event) {
        event.preventDefault();
        this.showSpinner = true;
        console.log(this.validateProduct);
        var requiredFieldName = '';
        var isErroFound = false;
        if((this.validateProduct.Delivery_Media__c == null || this.validateProduct.Delivery_Media__c == '') ){
            requiredFieldName = 'Delivery Media';
            isErroFound = true;
        }
        if(isErroFound){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: requiredFieldName +' is required',
                    variant: 'error',
                }),
            );
            this.showSpinner = false;
        }else{
            this.saveOLIJS();
        }
    }

    handleListPrice(event){

    }

    saveOLIJS(){
        this.isErrorFound = false;
        console.log('--save called----');
        saveOLI({bnfRec : this.bnfrecord, oliRec : this.validateProduct})
            .then(result => { 
                console.log(result);
                if(result != null){ 
                    console.log('--result.error---', JSON.stringify(result.error));
                    if(result.error != undefined && result.error.length > 0){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!',
                                message: 'Errors found, please review them.',
                                variant: 'error',
                            }),
                        );
                        this.isErrorFound = true;
                        this.allErrorList = result.error;
                        this.showSpinner = false;
                    }else if(result.success != undefined){
                        this.showSpinner = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success!',
                                message: 'Record updated.',
                                variant: 'success',
                            }),
                        );
                        //window.location.reload();
                    }else{
                        this.showSpinner = false;
                    }
                }
            })
            .catch(error => {
                console.log(error);
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!',
                        message: error,
                        variant: 'error',
                    }),
                );
            });
    }

    setInputValues(event){
        var fieldName = event.target.fieldName;
        if (fieldName == undefined || fieldName == null || fieldName == '') {
            fieldName = event.target.dataset.id;
        }
        if(fieldName == 'Product_Start_Date__c'){
            this.validateProduct.Product_Start_Date__c = event.target.value;
        }else if(fieldName == 'Product_End_Date__c'){
            this.validateProduct.Product_End_Date__c = event.target.value;
        }else if(fieldName == 'Delivery_Media__c'){
            this.validateProduct.Delivery_Media__c = event.target.value;
        }else if(fieldName == 'Proj_Rpt_Frequency__c'){
            this.validateProduct.Proj_Rpt_Frequency__c = event.target.value;
        }else if(fieldName == 'Billing_Frequency__c'){
            this.validateProduct.Billing_Frequency__c = event.target.value;
        }else if(fieldName == 'Billing_Schedule_Error_Msg__c'){
            this.validateProduct.Billing_Schedule_Error_Msg__c = event.target.value;
        }else if(fieldName == 'Product_Invoice_Text__c'){
            this.validateProduct.Product_Invoice_Text__c = event.target.value;
        }else if(fieldName == 'PO_Number__c'){
            this.validateProduct.PO_Number__c = event.target.value;
        }else if(fieldName == 'List_Price__c'){
            this.validateProduct.List_Price__c = event.target.value;
        }else if(fieldName == 'Discount_Percentage_Formula__c'){
            this.validateProduct.Discount_Percentage_Formula__c = event.target.value;
        }else if(fieldName == 'Discount_Reason__c'){
            this.validateProduct.Discount_Reason__c = event.target.value;
        }else if(fieldName == 'Discount_Amount_Formula__c'){
            this.validateProduct.Discount_Amount_Formula__c = event.target.value;
        }else if(fieldName == 'Nbr_of_Users__c'){
            this.validateProduct.Nbr_of_Users__c = event.target.value;
        }else if(fieldName == 'Other_Ship_To_Address__c'){
            this.validateProduct.Other_Ship_To_Address__c = event.target.value;
        }else if(fieldName == 'Other_Ship_To__c'){
            this.validateProduct.Other_Ship_To__c = event.target.value;
        }else if(fieldName == 'Billing_Date__c'){
            this.validateProduct.Billing_Date__c = event.target.value;
        }else if(fieldName == 'Delivery_Date__c'){
            this.validateProduct.Delivery_Date__c = event.target.value;
        }else if(fieldName == 'Sale_Type__c'){
            this.validateProduct.Sale_Type__c = event.target.value;
        }else if(fieldName == 'Revenue_Type__c'){
            this.validateProduct.Revenue_Type__c = event.target.value;
            if(this.validateProduct.Revenue_Type__c == 'Ad Hoc'){
                this.isSecondBillingDateRequired = true;
            }else{
                this.isSecondBillingDateRequired = false;
            }
        }else if(fieldName == 'Invoice_Lag_to_Data_Period__c'){
            this.validateProduct.Invoice_Lag_to_Data_Period__c = event.target.value;
        }else if(fieldName == 'Therapy_Area__c'){
            this.validateProduct.Therapy_Area__c = event.target.value;
        }else if(fieldName == 'ProfitCenter__c'){
            this.validateProduct.ProfitCenter__c = event.target.value;
        }else if(fieldName == 'Revised_Price__c'){ 
            this.validateProduct.Revised_Price__c = event.target.value;
        }else if(fieldName == 'Discount_Percentage_Formula__c'){
            this.validateProduct.Discount_Percentage_Formula__c = event.target.value;
        }else if(fieldName == 'Audit_Subscription_Status__c'){
            this.validateProduct.Audit_Subscription_Status__c = event.target.value;
        }
        
    }
}