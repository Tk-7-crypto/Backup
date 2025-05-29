import { LightningElement, api } from 'lwc';
import { RecordFieldDataType } from 'lightning/uiRecordApi';
import saveOLI from '@salesforce/apex/MIBNF_ProductControllerLockedGridM.saveOLI';
import getRevisedPrice from '@salesforce/apex/CNT_CRM_Edit_products.getRevisedPrice';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class LwcCrmEditProductMibnf extends LightningElement {
    @api product;
    validateProduct = {};
    @api bnfrecord;
    isErrorFound = false;
    allErrorList = [];
    toggle = true;
    showSpinner = false;
    productMaterialType = '';
    isProductZQUI = false;
    isProductZREP = false;
    isProductZPUB = false;
    isProductStartDateRequired = false;
    isProductStartDateDisbaled = false;
    isNewBnf = true;
    errorMsg;
    @api allFetchData;
    isRevisedBNF = false;
    allFetchDataLocal;
    isDeliveryMediaRequired= false;
    isSetByRevenueScheduleLink = false;
    itemCategoryGroup = '';
    zlicValue = 'ZLIC';
    zpubValue = 'ZPUB';
    zrepValue = 'ZREP';
    zquiValue = 'ZQUI';
    setRevisedtext = '';
    setRevisedLinktext = '';
    isDeliveryFreqVisible= false;
    isSetByBillingSchLink = false;
    isBillingFrequencyVisible = false;
    openPopup = false;
    apexPageLink ='';
    isListPriceRequired = false;
    offeringType = '';
    us_SalesOrg = false;
    label_CES_TOT_Offering_Type = '';
    discountAmount = 0.0;
    isNbrOfUserRequired = false;
    isNbrOfUserDisabled = false;
    isSetByRevenueScheduleLinkTag = false;
    isSetByBillingSchLinkTag = false;
    isSecondBillingDateVisible = false;
    isSecondBillingDateRequired = false;
    isAuditSubscriptionStatusRequired= false;
    isAuditSubscriptionStatusDisabled= false;
    materialGroup1 = '';
    DiscountPercentage = '';
    isProfitCenterVisible = false;
    isProfitCenterDisable = false;
    showDiscountReason = false;
    isNotPreventEdit = false;
    isDiscountRequired = true;
    connectedCallback(){
        this.validateProduct = JSON.parse(JSON.stringify(this.product));
        this.allFetchDataLocal = JSON.parse(JSON.stringify(this.allFetchData));
        this.assignAllFields();
        this.setDiscountAmount();
        this.SetShowDiscountReason();
        this.setDiscountPercentage();
        this.closePopup();
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
        if(this.isProductZPUB || this.bnfrecord.Addendum__c){
            this.isProductStartDateRequired = true;
        }
        if(this.isProductZREP && !this.bnfrecord.Addendum__c && this.allFetchDataLocal.isNewBnf){ // need code for isNewBnf
            this.isProductStartDateDisbaled = true;
        }
        if(!this.isProductZREP){
            this.isDeliveryMediaRequired = true;
            if(this.itemCategoryGroup != this.zlicValue){
                this.isSecondBillingDateVisible = true;
                if(this.validateProduct.Billing_Frequency__c=='Once'){
                    this.isSecondBillingDateRequired = true;
                }
            }
        }
        if(this.isProductZREP || (this.isProductZPUB && this.itemCategoryGroup == this.zlicValue)){
            this.isSetByRevenueScheduleLink = true;
            this.isSetByBillingSchLink = true;
        }
        if(this.isProductZREP || this.itemCategoryGroup == this.zlicValue){
            this.isSetByRevenueScheduleLinkTag = true;
            this.isSetByBillingSchLinkTag = true;
        }
        if(this.bnfrecord.Addendum__c){
            this.setRevisedtext = 'Revised';
            this.setRevisedLinktext = 'Edit Revised Rev Schedule';
        }else{
            this.setRevisedLinktext = 'Edit Rev Schedule Dates';
        }
        if(this.isProductZPUB && this.itemCategoryGroup != this.zlicValue){
            this.isDeliveryFreqVisible = true;
            this.isBillingFrequencyVisible = true;
        }
        if(this.itemCategoryGroup == 'ZPLI' || this.itemCategoryGroup == 'ZPLU'){
            this.isNbrOfUserRequired = true;
        }else{
            this.isNbrOfUserDisabled = true;
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
    setDiscountPercentage() {
        if (this.validateProduct.UnitPrice > 0) {
            var UnitPrice2 = (this.validateProduct.Revised_Price__c == null || this.validateProduct.Revised_Price__c == '') ? this.validateProduct.UnitPrice : this.validateProduct.Revised_Price__c;
            var ListPrice2 = (this.validateProduct.List_Price__c == null || this.validateProduct.List_Price__c == '') ? UnitPrice2 : this.validateProduct.List_Price__c;
            if (this.validateProduct.List_Price__c > UnitPrice2) {
                var x = (ListPrice2 - UnitPrice2) *100/ ListPrice2;
                this.DiscountPercentage = Number.parseFloat(x).toFixed(2) + ' %'
            } else
                this.DiscountPercentage = '';
        }
        else
            this.DiscountPercentage = '';
    }
  
    openRevisedSchPage(event){
        var originalRevSchedules = true;
        if(this.bnfrecord.Addendum__c){
            originalRevSchedules = false
        }
        var StartDate = this.getFormattedDate(this.validateProduct.Product_Start_Date__c);
        var EndDate = this.getFormattedDate(this.validateProduct.Product_End_Date__c);
        this.openPopup = true;
        this.apexPageLink = '/apex/revised_revenue_schedule?id='+ this.validateProduct.Id + '&startdate=' + StartDate + '&enddate=' + EndDate + '&RevisedPriceId=' + this.validateProduct.Revised_Price__c + '&ListPriceId=' + this.validateProduct.List_Price__c +'&OriginalRevSchedules=' +originalRevSchedules;
        //window.open('/apex/revised_revenue_schedule?id='+ this.validateProduct.Id + '&startdate=' + StartDate + '&enddate=' + EndDate + '&RevisedPriceId=' + this.validateProduct.Revised_Price__c + '&ListPriceId=' + this.validateProduct.List_Price__c +'&OriginalRevSchedules=' +originalRevSchedules,'ShowMessage','Width=' + windowWidth + 'px,Height=' + windowHeight + 'px,center=yes,Top=' + centerHeight +',Left=' + centerWidth + ',scrollbars=yes');
    }
    handleSubmit(event) {
        event.preventDefault();
        this.showSpinner = true;
        var requiredFieldName = '';
        var isErroFound = false;
        if(this.isDeliveryMediaRequired && (this.validateProduct.Delivery_Media__c == null || this.validateProduct.Delivery_Media__c == '') ){
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
    SetShowDiscountReason() {
        if (this.validateProduct.Revised_Price__c == null || this.validateProduct.Revised_Price__c == '') {
            if ((this.validateProduct.List_Price__c - this.validateProduct.TotalPrice) >= 0) {
                this.showDiscountReason = true;
            } else
                this.showDiscountReason = false;
        } else {
            if ((this.validateProduct.List_Price__c - this.validateProduct.Revised_Price__c) >= 0) {
                this.showDiscountReason = true;
            }
            this.showDiscountReason = false;
        }
    }


    saveOLIJS(){
        this.isErrorFound = false;
        console.log('--save called----');
        saveOLI({bnfRec : this.bnfrecord, oliRec : this.validateProduct})
            .then(result => { 
                console.log(result);
                if(result != null){ 
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
        }else if(fieldName == 'Sales_Text__c'){
            this.validateProduct.Sales_Text__c = event.target.value;
        }else if(fieldName == 'PO_Number__c'){
            this.validateProduct.PO_Number__c = event.target.value;
        }else if(fieldName == 'List_Price__c'){
            this.validateProduct.List_Price__c = event.target.value;
            this.setDiscountAmount();
            this.SetShowDiscountReason();
            this.setDiscountPercentage();
        }else if(fieldName == 'Discount_Percentage_Formula__c'){
            this.validateProduct.Discount_Percentage_Formula__c = event.target.value;
        }else if(fieldName == 'Discount_Reason__c'){
            this.validateProduct.Discount_Reason__c = event.target.value;
        }else if(fieldName == 'Surcharge_Text__c'){
            this.validateProduct.Surcharge_Text__c = event.target.value;
        }else if(fieldName == 'Nbr_of_Users__c'){
            this.validateProduct.Nbr_of_Users__c = event.target.value;
        }else if(fieldName == 'Other_Ship_To_Address__c'){
            this.validateProduct.Other_Ship_To_Address__c = event.target.value;
        }else if(fieldName == 'Other_Ship_To_SAP_Contact__c'){
            this.validateProduct.Other_Ship_To_SAP_Contact__c = event.target.value;
        }else if(fieldName == 'Billing_Date__c'){
            this.validateProduct.Billing_Date__c = event.target.value;
        }else if(fieldName == 'Delivery_Date__c'){
            this.validateProduct.Delivery_Date__c = event.target.value;
        }else if(fieldName == 'Sale_Type__c'){
            this.validateProduct.Sale_Type__c = event.target.value;
        }else if(fieldName == 'Revenue_Type__c'){
            this.validateProduct.Revenue_Type__c = event.target.value;
        }else if(fieldName == 'Invoice_Lag_to_Data_Period__c'){
            this.validateProduct.Invoice_Lag_to_Data_Period__c = event.target.value;
        }else if(fieldName == 'Therapy_Area__c'){
            this.validateProduct.Therapy_Area__c = event.target.value;
        }else if(fieldName == 'ProfitCenter__c'){
            this.validateProduct.ProfitCenter__c = event.target.value;
        }else if(fieldName == 'Revised_Price__c'){ 
            this.validateProduct.Revised_Price__c = event.target.value;
            this.setDiscountAmount();
            this.SetShowDiscountReason();
            this.setDiscountPercentage();
        }else if(fieldName == 'Revenue_Schedule_Error_Msg__c'){
            this.validateProduct.Revenue_Schedule_Error_Msg__c = event.target.value;
        }else if(fieldName == 'Audit_Subscription_Status__c'){
            this.validateProduct.Audit_Subscription_Status__c = event.target.value;
        }
        
    }

    editBillingSchedule(event) {
        var sDate = this.getFormattedDate(this.bnfrecord.Contract_Start_Date__c);
        var eDate = this.getFormattedDate(this.bnfrecord.Contract_End_Date__c);
        this.openPopup = true;
        this.apexPageLink = "/apex/AddProductBillingSchedule?id=" + this.validateProduct.Id + "&bnfid="+this.bnfrecord.Id+ "&startdate=" + sDate +"&enddate=" + eDate;
        //window.location.href = "/apex/AddProductBillingSchedule?id=" + this.product.Id + "&bnfid="+this.bnfrecord.Id+ "&startdate=" + sDate +"&enddate=" + eDate;
        //window.open( "/apex/AddProductBillingSchedule?id=" + this.product.Id + "&bnfid="+this.bnfrecord.Id+ "&startdate=" + sDate +"&enddate=" + eDate , this.product.Id, "status = 1, height = 500, width = 1000, resizable = 0, scrollbars = 1" );
        //window.open("/apex/AddProductBillingSchedule?id=" + this.product.Id + "&bnfid=" + this.bnfrecord.Id, "status = 1, height = 500, width = 1000, resizable = 0, scrollbars = 1");
    }

    getFormattedDate(dt){
        var date = new Date(dt);
        var yyyy = date.getUTCFullYear();
        var mm = date.getUTCMonth()+1;
        var dd = date.getUTCDate();
        return  mm + '/' + dd + '/' + yyyy; 
    }
    closePopup(event) {
        this.showSpinner = true;
        this.openPopup = false;
        this.apexPageLink = '';
        getRevisedPrice({oliId : this.validateProduct.Id,isOriginalRevSchedules : !this.isRevisedBNF})
        .then(result => {
            this.validateProduct.Revised_Price__c = result;
            this.showSpinner = false;
        })
        .catch(error => {
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
    setDiscountAmount() {
        this.discountAmount = 0.0;
        if (this.validateProduct.List_Price__c == null || this.validateProduct.List_Price__c == ''){
            this.discountAmount = '0.0';
        }
        else if (this.bnfrecord.Addendum__c && this.validateProduct.List_Price__c != undefined && this.validateProduct.Revised_Price__c != undefined )
            this.discountAmount = (this.validateProduct.List_Price__c - this.validateProduct.Revised_Price__c);
        else if(this.validateProduct.List_Price__c != undefined && this.validateProduct.TotalPrice != undefined)
            this.discountAmount = (this.validateProduct.List_Price__c - this.validateProduct.TotalPrice);
        if (this.discountAmount == null || this.discountAmount == '' || this.discountAmount == 0) {
            this.discountAmount = '0.0';
        }
        if(typeof this.discountAmount == 'NaN' || this.discountAmount == 'NaN' || isNaN(this.discountAmount)) {
            this.discountAmount = '0.0';
        }
        this.setDiscountRequired();
    }

    setDiscountRequired(){
        this.isDiscountRequired = true;
        if(this.bnfrecord.Addendum__c && this.validateProduct.Revised_Price__c != null){
            if(this.validateProduct.List_Price__c == this.validateProduct.Revised_Price__c || (this.offeringType =='Management Consulting')){
                this.isDiscountRequired = false;
            }
        }
        else{
            if(this.validateProduct.List_Price__c == this.validateProduct.TotalPrice || (this.offeringType =='Management Consulting')){
                this.isDiscountRequired = false;
            }
        }
    }
}