import { LightningElement, api } from 'lwc';
import fetchAllDetails from '@salesforce/apex/CNT_CRM_Edit_Products_iBNF.fetchAllDetails';
import getBillingSchList from '@salesforce/apex/CNT_CRM_Edit_Products_iBNF.getBillingSchList';
import save from '@salesforce/apex/CNT_CRM_Edit_Products_iBNF.save';

const VALIDATION_CHECK_REQ_ON = new Set(['Product_Start_Date__c', 'Product_End_Date__c', 'Delivery_Media__c', 'Proj_Rpt_Frequency__c', 'Billing_Frequency__c', 'List_Price__c', 'Discount_Reason__c', 'Surcharge_Text__c', 'Billing_Date__c', 'Delivery_Date__c', 'Sale_Type__c', 'Revenue_Type__c', 'Therapy_Area__c', 'ProfitCenter__c', 'PO_line_item_number__c', 'Nbr_of_Users__c', 'Revised_Price__c']);

const HEADER_FIXED_COL = new Set([
    { iniStyle: 'position: -webkit-sticky; position: sticky; width: 07rem; left: 00rem; z-index: 2;', showCheckBox: false, label: "Product Code", fieldName: "ProductCode" },
    { iniStyle: 'position: -webkit-sticky; position: sticky; width: 08rem; left: 07rem; z-index: 2;', showCheckBox: false, label: "Sales Price", fieldName: "TotalPrice" },
    { iniStyle: 'position: -webkit-sticky; position: sticky; width: 08rem; left: 15rem; z-index: 2;', showCheckBox: false, label: "Name", fieldName: "PricebookEntry.Name" },
    { iniStyle: 'position: -webkit-sticky; position: sticky; width: 08rem; left: 23rem; z-index: 2;', showCheckBox: false, label: "Delivery Country", fieldName: "Delivery_Country__c" },
    { iniStyle: 'position: -webkit-sticky; position: sticky; width: 06rem; left: 31rem; z-index: 2; border-right: 1px solid gray;', showCheckBox: false, label: "WBS codes", fieldName: "WBS_R_Element__c" }
]);

const HEADER_COL = new Set([
    { iniStyle: 'width:10rem;position: relative;', showCheckBox: true, label: "Data Period Start", fieldName: "Product_Start_Date__c", tooltip: "" },
    { iniStyle: 'width:10rem;position: relative;', showCheckBox: true, label: "Data Period End", fieldName: "Product_End_Date__c", tooltip: "" },
    { iniStyle: 'width:12rem;position: relative;', showCheckBox: true, label: "Delivery Media", fieldName: "Delivery_Media__c", tooltip: "" },
    { iniStyle: 'width:12rem;position: relative;', showCheckBox: true, label: "Delivery/Rpt Frequency", fieldName: "Proj_Rpt_Frequency__c", tooltip: "" },
    { iniStyle: 'width:12rem;position: relative;', showCheckBox: true, label: "Billing Frequency", fieldName: "Billing_Frequency__c", tooltip: "" },
    { iniStyle: 'width:12rem;position: relative;', showCheckBox: false, label: "Sales Text", fieldName: "Sales_Text__c", tooltip: "" },
    { iniStyle: 'width:12rem;position: relative;', showCheckBox: false, label: "PO Number", fieldName: "PO_Number__c", tooltip: "" },
    { iniStyle: 'width:08rem;position: relative;', showCheckBox: false, label: "List Price", fieldName: "List_Price__c", tooltip: "" },
    { iniStyle: 'width:08rem;position: relative;', showCheckBox: false, label: "Discount %", fieldName: "Discount_Percentage_Formula__c", tooltip: "" },
    { iniStyle: 'width:10rem;position: relative;', showCheckBox: false, label: "Discount / Surcharge Amt", fieldName: "Discount_Amount_Formula__c", tooltip: "" },
    { iniStyle: 'width:12rem;position: relative;', showCheckBox: true, label: "Discount Reason / Surcharge Text", fieldName: "Surcharge_Text__c", tooltip: "" },
    { iniStyle: 'width:10rem;position: relative;', showCheckBox: false, label: "PO line item number", fieldName: "PO_line_item_number__c", tooltip: "" },
    { iniStyle: 'width:10rem;position: relative;', showCheckBox: true, label: "Number of Users", fieldName: "Nbr_of_Users__c", tooltip: "" },
    { iniStyle: 'width:10rem;position: relative;', showCheckBox: false, label: "Other Ship To", fieldName: "Other_Ship_To_Address__c", tooltip: "" },
    { iniStyle: 'width:10rem;position: relative;', showCheckBox: false, label: "Billing Date", fieldName: "Billing_Date__c", tooltip: "" },
    { iniStyle: 'width:10rem;position: relative;', showCheckBox: false, label: "Delivery Date", fieldName: "Delivery_Date__c", tooltip: "" },
    { iniStyle: 'width:10rem;position: relative;', showCheckBox: false, label: "Sales Type", fieldName: "Sale_Type__c", tooltip: "" },
    { iniStyle: 'width:10rem;position: relative;', showCheckBox: false, label: "Revenue Type", fieldName: "Revenue_Type__c", tooltip: "" },
    { iniStyle: 'width:12rem;position: relative;', showCheckBox: false, label: "Invoice Lag to Data Period", fieldName: "Invoice_Lag_to_Data_Period__c", tooltip: "" },
    { iniStyle: 'width:12rem;position: relative;', showCheckBox: false, label: "Therapy Area", fieldName: "Therapy_Area__c", tooltip: "" },
    { iniStyle: 'width:13rem;position: relative;', showCheckBox: false, label: "Audit Subscription Status", fieldName: "Audit_Subscription_Status__c", tooltip: "Please send queries for Audit Subscription Status to MidasAdmin@uk.imshealth.com" },
    { iniStyle: 'width:12rem;position: relative;', showCheckBox: false, label: "Profit Center", fieldName: "ProfitCenter__c", tooltip: " " },
]);

const BILLING_SCH_COLUMNS = [
    {
        label: 'Billing Date', fieldName: 'Billing_Date__c', type: 'date', fixedWidth: 160, hideDefaultActions: true,
        typeAttributes: { month: "2-digit", day: "2-digit", year: "numeric" }
    },
    {
        label: 'Billing Amount', fieldName: 'Billing_Amount__c', type: 'currency', hideDefaultActions: true,
        typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, currencyDisplayAs: 'code' },
    }
];

export default class LwcCrmEditProductsIbnf extends LightningElement {
    headerCol = HEADER_COL;
    headerFixedCol = HEADER_FIXED_COL;
    fieldSetForOnChange = VALIDATION_CHECK_REQ_ON;
    @api recordId;
    showSpinner = false;
    showTable = false;
    showError = false;
    errorMsg = new Set();
    dataProcessingComplete = true;
    bnf = null;
    productSelected = [];
    fullResult = {};
    pic = {}; //comman picklist values shared amoing all OLI
    glossaryDocumentUrl = '/servlet/servlet.FileDownload?file=';
    isPrebillingSalesCode = false;

    //OLIAddressSelector fields
    openPopup = false;
    selectedProductIndex = '';
    selectedAddressId = '';
    selectedAddressName = '';
    selectedSapContactId = '';
    selectedSapContactName = '';

    billingSchCol = BILLING_SCH_COLUMNS;
    mouseHoverData = {};
    showBillingHover = false;
    showBillingSpinner = false;
    popupClass = '';

    connectedCallback() {
    }

    renderedCallback() {
        if (this.recordId && this.bnf == null && this.dataProcessingComplete) {
            this.dataProcessingComplete = false;
            this.showSpinner = true;
            this.fetchAllDetailsJS();

            // create new Style Child tag to make error msg wrap
            let style = document.createElement('style');
            style.innerText += '.slds-form-element__help{text-wrap: auto !important;}';
            this.template.querySelector('[data-id="containerDiv"]').appendChild(style);
        }
    }

    fetchAllDetailsJS() {
        fetchAllDetails({ recId: this.recordId })
            .then(result => {
                if (result) {
                    this.fullResult = result;
                    this.bnf = result.bnf;
                    this.isPrebillingSalesCode = (result.bnf.Sales_Org_Code__c == 'MX02' || result.bnf.Sales_Org_Code__c == 'GT01' || result.bnf.Sales_Org_Code__c == 'CO01' || result.bnf.Sales_Org_Code__c == 'CO71') ? true : false;
                    if (this.isPrebillingSalesCode) {
                        this.headerCol.add({ iniStyle: 'width:06rem;', showCheckBox: false, label: "Prebilling?", fieldName: "Prebilling__c" })
                    }
                    if (this.bnf.Addendum__c) {
                        this.headerCol.add({ iniStyle: 'width:10rem;', showCheckBox: false, label: "Revised Sales Price", fieldName: "Revised_Price__c" })
                        this.headerCol.add({ iniStyle: 'width:06rem;', showCheckBox: false, label: "Cancel", fieldName: "Cancel__c" })
                    }
                    if (result.isRecordLocked === true) {
                        this.errorMsg = new Set();
                        this.errorMsg.add('record is locked you can not edit product. please click cancel to go back to bnf');
                        this.showError = true;
                    } else {
                        this.productSelected = JSON.parse(JSON.stringify(result.opptyLineItem2));
                        if (result.glossaryDocumentId != null && result.glossaryDocumentId != undefined) {
                            this.glossaryDocumentUrl = this.glossaryDocumentUrl + result.glossaryDocumentId;
                        }
                    }
                }
            }).catch(error => {
                this.handleError(error, 'error while fetching Oli Data');
            }).finally(() => {
                this.setConditionalAndPickListVar();
            });
    }

    async setConditionalAndPickListVar() {
        let fullResult = this.fullResult;
        if (this.productSelected) {
            var deliveryMediaMap = fullResult.oliToDeliveryMediaMap;
            var deliveryFrequencyMap = fullResult.oliToDeliveryFrequencyMap;
            var therapyAreaMap = fullResult.oliToTherapyAreaMap;
            this.pic.BillingFrequency = fullResult.allBillingFrequencyList;
            this.pic.DiscountReason = fullResult.allDiscountReasonList;
            this.pic.SaleType = fullResult.allSaleTypeList;
            this.pic.RevenueType = fullResult.allRevenueTypeList;
            this.pic.InvoiceLagToDataPeriod = fullResult.allInvoiceLagToDataPeriodList;
            this.pic.ProfitCenter = fullResult.allProfitCenterList;

            this.productSelected.forEach(opptyLineItem => {
                if (opptyLineItem.Therapy_Area__c == null && opptyLineItem.Opportunity.Therapy_Area__c != null) {
                    opptyLineItem.Therapy_Area__c = opptyLineItem.Opportunity.Therapy_Area__c;
                }
                let oliId = opptyLineItem.Id;
                let oliMaterialType = opptyLineItem.PricebookEntry.Product2.Material_Type__c;
                let oliItemCategory = opptyLineItem.PricebookEntry.Product2.Item_Category_Group__c;
                let oliMaterialGroup = opptyLineItem.PricebookEntry.Product2.Material_Group_1__c;

                //setting picklist value to blank if Undefined or null
                opptyLineItem.Delivery_Media__c = (oliMaterialType === 'ZREP') ? 'Not Applicable [NA]' : opptyLineItem.Delivery_Media__c ? opptyLineItem.Delivery_Media__c : '';
                opptyLineItem.Proj_Rpt_Frequency__c = opptyLineItem.Proj_Rpt_Frequency__c ? opptyLineItem.Proj_Rpt_Frequency__c : '';
                opptyLineItem.Billing_Frequency__c = opptyLineItem.Billing_Frequency__c ? opptyLineItem.Billing_Frequency__c : '';
                opptyLineItem.Discount_Reason__c = opptyLineItem.Discount_Reason__c ? opptyLineItem.Discount_Reason__c : '';
                opptyLineItem.Sale_Type__c = opptyLineItem.Sale_Type__c ? opptyLineItem.Sale_Type__c : '';
                opptyLineItem.Revenue_Type__c = opptyLineItem.Revenue_Type__c ? opptyLineItem.Revenue_Type__c : '';
                opptyLineItem.Invoice_Lag_to_Data_Period__c = opptyLineItem.Invoice_Lag_to_Data_Period__c ? opptyLineItem.Invoice_Lag_to_Data_Period__c : '';
                opptyLineItem.Therapy_Area__c = opptyLineItem.Therapy_Area__c ? opptyLineItem.Therapy_Area__c : '';
                opptyLineItem.ProfitCenter__c = opptyLineItem.ProfitCenter__c ? opptyLineItem.ProfitCenter__c : '';
                opptyLineItem.DiscountPercentageFormula = opptyLineItem.Discount_Percentage_Formula__c ? (opptyLineItem.Discount_Percentage_Formula__c + ' %') : '';

                opptyLineItem.helpingVar = {};
                opptyLineItem.helpingVar.otherShipToAddressName = (opptyLineItem.Other_Ship_To_Address__c) ? opptyLineItem.Other_Ship_To_Address__r.Name : '';
                opptyLineItem.helpingVar.otherShipToSapContactName = (opptyLineItem.Other_Ship_To_SAP_Contact__c) ? opptyLineItem.Other_Ship_To_SAP_Contact__r.Name : '';
                opptyLineItem.helpingVar.isProductZREP = oliMaterialType === 'ZREP' ? true : false;
                opptyLineItem.helpingVar.isProductZREPAndNotRevisedBNF = (oliMaterialType === 'ZREP' && fullResult.bnf.Addendum__c == false) ? true : false;
                opptyLineItem.helpingVar.isProductNotZREP = oliMaterialType === 'ZREP' ? false : true;
                opptyLineItem.helpingVar.isProductNotZPLIorZPLU = (oliItemCategory != 'ZPLI' && oliItemCategory != 'ZPLU') ? true : false;
                opptyLineItem.helpingVar.setByOther = (oliMaterialType === 'ZREP' || (oliMaterialType === 'ZPUB' && oliItemCategory === 'ZLIC')) ? true : false;
                opptyLineItem.helpingVar.isProductZPUB = oliMaterialType === 'ZPUB' ? true : false;
                opptyLineItem.helpingVar.isMaterialGroupNotMAN = oliMaterialGroup == 'MAN' ? false : true;
                opptyLineItem.helpingVar.picDeliveryMedia = deliveryMediaMap.hasOwnProperty(oliId) == true ? deliveryMediaMap[oliId] : '';
                opptyLineItem.helpingVar.picDeliveryFrequency = deliveryFrequencyMap.hasOwnProperty(oliId) == true ? deliveryFrequencyMap[oliId] : '';
                opptyLineItem.helpingVar.picTherapyArea = therapyAreaMap.hasOwnProperty(oliId) == true ? therapyAreaMap[oliId] : '';
                opptyLineItem.helpingVar.discountAmount = opptyLineItem.Discount_Amount_Formula__c ? opptyLineItem.Discount_Amount_Formula__c : '0.0';
                opptyLineItem.helpingVar.showDiscountReason = opptyLineItem.helpingVar.discountAmount >= 0 ? true : false;
                opptyLineItem.helpingVar.disableDiscountReason = (opptyLineItem.List_Price__c == opptyLineItem.TotalPrice) ? true : false;
            });
        }
        await Promise.all([
            this.showTable = true
        ]).then(() => {
            this.validateOLI('all');
        }).finally(() => {
            this.dataProcessingComplete = true;
            this.showSpinner = false;
        });
    }

    handleChange(event) {
        try {
            this.showSpinner = true;
            let index = event.currentTarget.dataset.index;
            let xIndex = event.currentTarget.dataset.index;
            let fieldName = event.currentTarget.dataset.id;
            let newValue = '';
            if (fieldName === 'Cancel__c' || fieldName === 'Prebilling__c') {
                newValue = event.target.checked;
            } else {
                newValue = event.target.value;
            }
            this.productSelected[index][fieldName] = newValue;
            console.log('product[' + index + '][' + fieldName + '] = ' + newValue);

            if (fieldName == 'List_Price__c') {
                let opptyLineItem = this.productSelected[index];
                let salesPrice = this.productSelected[index].TotalPrice;
                let discountAmount = '0.0';
                if (newValue) {
                    discountAmount = (this.bnf.Addendum__c && opptyLineItem.Revised_Price__c) ? (newValue - opptyLineItem.Revised_Price__c) : ((newValue - opptyLineItem.TotalPrice));
                }
                this.productSelected[index].helpingVar.discountAmount = discountAmount;
                this.productSelected[index].helpingVar.showDiscountReason = discountAmount >= 0 ? true : false;
                this.productSelected[index].helpingVar.disableDiscountReason = (newValue == salesPrice) ? true : false;
            } else if (fieldName == 'Revised_Price__c') {
                let opptyLineItem = this.productSelected[index];
                let listPrice = this.productSelected[index].List_Price__c;
                let discountAmount = '0.0';
                if (listPrice) {
                    discountAmount = (this.bnf.Addendum__c && newValue) ? (listPrice - newValue) : ((listPrice - opptyLineItem.TotalPrice));
                }
                this.productSelected[index].helpingVar.discountAmount = discountAmount;
                this.productSelected[index].helpingVar.showDiscountReason = discountAmount >= 0 ? true : false;
                this.productSelected[index].helpingVar.disableDiscountReason = (discountAmount == 0) ? true : false;
            }

            //  update all record if checkbox is checked and 1st element is changed and not blank, null or undefined
            if (newValue) {
                var updateAllOli = false;
                this.template.querySelectorAll('[data-type="clonebox"]').forEach(item => {
                    if (item.checked && (item.dataset.id == fieldName || (item.dataset.id == 'Surcharge_Text__c' && fieldName == 'Discount_Reason__c'))) {
                        updateAllOli = true;
                    }
                });
                let queryTag = '[data-id="' + fieldName + '"]';
                let newValueIndex = '';
                this.template.querySelectorAll(queryTag).forEach(loopItem => {
                    if (newValueIndex == '' && loopItem.dataset.type != 'clonebox' && loopItem.disabled === false) {
                        newValueIndex = loopItem.dataset.index;
                    }
                });
                if (updateAllOli && newValueIndex === xIndex) {
                    xIndex = 'all';
                    this.template.querySelectorAll(queryTag).forEach(loopItem => {
                        if (loopItem.dataset.type != 'clonebox' && loopItem.disabled === false) {
                            let loopIndex = loopItem.dataset.index;
                            this.productSelected[loopIndex][fieldName] = newValue;
                        }
                    });
                }
            }
            this.reValidateProduct(fieldName, xIndex);
        } catch (error) {
            this.handleError(error, 'error while handling field value Change');
        }
    }

    reValidateProduct(fieldName, index) {
        console.log('reValidating OLI for field: ', fieldName);
        try {
            if (this.fieldSetForOnChange.has(fieldName)) {
                setTimeout(() => { this.validateOLI(index) }, 0);
            } else {
                this.showSpinner = false;
            }
        } catch (error) {
            this.handleError(error, 'error while reValidating OLI')
        }
    }

    handleReplicateValue(event) {
        this.showSpinner = true;
        try {
            let fieldName = event.currentTarget.dataset.id;
            let checked = event.target.checked;
            if (fieldName == 'Surcharge_Text__c' && this.productSelected[0].helpingVar.showDiscountReason) {
                fieldName = 'Discount_Reason__c';
            }
            let queryTag = '[data-id="' + fieldName + '"]';
            if (checked === true) {
                let newValue = '';
                this.template.querySelectorAll(queryTag).forEach(loopItem => {
                    if (newValue == '' && loopItem.dataset.type != 'clonebox' && loopItem.disabled === false) {
                        newValue = loopItem.value;
                    }
                    if (newValue != '' && loopItem.dataset.type != 'clonebox' && loopItem.disabled === false) {
                        let loopIndex = loopItem.dataset.index;
                        this.productSelected[loopIndex][fieldName] = newValue;
                    }
                });
                this.reValidateProduct(fieldName, 'all');
            } else {
                this.showSpinner = false;
            }
        } catch (error) {
            this.handleError(error, 'error while replicating value');
        }
    }

    handleCancel() {
        this.navigateToRecord(this.recordId);
    }

    navigateToRecord(recId) {
        window.open('/lightning/r/BNF2__c/' + recId + '/view', '_self');
    }

    handleSaveOnly() {
        try {
            this.showSpinner = true;
            this.showError = false;
            this.errorMsg = new Set();
            this.productSelected.forEach(currentItem => {
                currentItem.helpingVar.Revenue_Schedule_Error_Msg__c = '';
                currentItem.helpingVar.Billing_Schedule_Error_Msg__c = '';
            });
            this.saveOLI('saveOnly');
        } catch (error) {
            this.handleError(error, 'error while Save draft');
        }
    }

    handleValidateAndSave() {
        try {
            this.showSpinner = true;
            this.showError = false;
            this.errorMsg = new Set();
            this.productSelected.forEach(currentItem => {
                currentItem.helpingVar.Revenue_Schedule_Error_Msg__c = '';
                currentItem.helpingVar.Billing_Schedule_Error_Msg__c = '';
            });
            if (this.validateOLI('all')) {
                console.log('Validation level 1 complete with 0 error: ');
                this.saveOLI('validateAndSave');
            } else {
                this.showError = true;
                this.showSpinner = false;
            }
        } catch (error) {
            this.handleError(error, 'error while final Save')
        }
    }

    saveOLI(operationType) {
        console.log('saving OLI to db: ', operationType);
        let opptyLineItem2 = JSON.parse(JSON.stringify(this.productSelected));
        for (let i = 0; i < opptyLineItem2.length; i++) {
            delete opptyLineItem2[i].helpingVar;//remove extra JS var before passing to controller
        }

        save({ opptyLineItem2: opptyLineItem2, operationType: operationType, bnf: this.bnf })
            .then(result => {
                if (result.Success) {
                    this.navigateToRecord(this.recordId);
                } else if (result.errorCNT) {
                    this.handleControllerErrorMsg(result.errorCNT);
                } else if (result.error) {
                    this.handleError(result.error, 'error while saving data CNT');
                }
            }).catch(error => {
                this.handleError(error, 'error while saving data');
            });
    }

    handleControllerErrorMsg(errorWraper) {
        this.showSpinner = true;
        errorWraper.forEach(currentItem => {
            let oliId = currentItem.oliId;
            let fieldApi = currentItem.fieldApi;
            let fieldLabel = currentItem.fieldLabel;
            let errorMessage = currentItem.errorMessage;
            this.errorMsg.add(fieldLabel + ': ' + errorMessage);
            if (oliId) {
                let index = null;
                for (let i = 0; i < this.productSelected.length; i++) {
                    if (this.productSelected[i].Id == oliId) {
                        index = i;
                        break;
                    }
                }
                if (fieldApi === 'Revenue_Schedule_Error_Msg__c' || fieldApi === 'Billing_Schedule_Error_Msg__c') {
                    this.productSelected[index]['helpingVar'][fieldApi] = errorMessage;
                } else {
                    let queryTag = '[data-id="' + fieldApi + '"][data-index="' + index + '"]';
                    this.template.querySelectorAll(queryTag).forEach(tagLoopItem => {
                        if (tagLoopItem.dataset.index == index) {
                            tagLoopItem.setCustomValidity(errorMessage);
                            tagLoopItem.reportValidity();
                        }
                    });
                }
            } else {
                let tagName = '[data-id="' + fieldApi + '"]';
                this.template.querySelectorAll(tagName).forEach(tagLoopItem => {
                    tagLoopItem.setCustomValidity(errorMessage);
                    tagLoopItem.reportValidity();
                });
            }
        });
        this.showError = true;
        this.showSpinner = false;
    }

    validateOLI(xindex) {
        xindex = xindex ? xindex : 'all';
        console.log('validating OLI...', xindex);
        this.template.querySelectorAll('lightning-input').forEach(item => {
            let fieldApi = item.dataset.id
            let fieldLabel = item.parentElement.dataset.label;
            let value = item.value ? item.value : null;
            let index = item.dataset.index;
            if (xindex == index || xindex == 'all') {
                if (item.dataset.type != 'clonebox') {
                    let isProductZPUB = this.productSelected[index].helpingVar.isProductZPUB;
                    let isProductZPLIorZPLU = !this.productSelected[index].helpingVar.isProductNotZPLIorZPLU;

                    if (value == null && fieldApi == 'Product_Start_Date__c' && (isProductZPUB || this.bnf.Addendum__c)) {
                        item.setCustomValidity("Complete this field.");
                        item.reportValidity();
                    } else if (value == null && fieldApi == 'Product_End_Date__c' && isProductZPUB) {
                        item.setCustomValidity("Complete this field.");
                        item.reportValidity();
                    } else if (value == null && (fieldApi == 'List_Price__c' || fieldApi == 'Surcharge_Text__c')) {
                        item.setCustomValidity("Complete this field.");
                        item.reportValidity();
                    } else if (value == null && fieldApi == 'Nbr_of_Users__c' && isProductZPLIorZPLU) {
                        item.setCustomValidity("Complete this field.");
                        item.reportValidity();
                    } else if ((fieldApi === 'PO_line_item_number__c' || fieldApi === 'Nbr_of_Users__c') && value != null && value % 1 != 0) {
                        item.setCustomValidity('It should be filled Numbers only');
                        item.reportValidity();
                        this.errorMsg.add(fieldLabel + ': ' + fieldLabel + ' should be filled Numbers only');
                    } else {
                        item.setCustomValidity("");
                        if (item.reportValidity() == false) {
                            this.errorMsg.add(fieldLabel + ': Complete this field.');
                        }
                    }
                }
            }
        });

        this.template.querySelectorAll('lightning-combobox').forEach(item => {
            let fieldName = item.dataset.id
            let fieldLabel = item.parentElement.dataset.label;
            let value = item.value ? item.value : '';
            let index = item.dataset.index;
            let isProductNotZREP = this.productSelected[index].helpingVar.isProductNotZREP;
            let setByOther = this.productSelected[index].helpingVar.setByOther;

            if (xindex == index || xindex == 'all') {
                if (value == '' && setByOther == false && (fieldName == 'Proj_Rpt_Frequency__c' || fieldName == 'Billing_Frequency__c')) {
                    item.setCustomValidity("Complete this field.");
                    item.reportValidity();
                    this.errorMsg.add(fieldLabel + ': You must enter a value.');
                } else if (value == '' && (fieldName == 'Sale_Type__c' || fieldName == 'Revenue_Type__c' || (fieldName == 'Discount_Reason__c' && this.productSelected[index].helpingVar.disableDiscountReason == false))) {
                    item.setCustomValidity("Complete this field.");
                    item.reportValidity();
                    this.errorMsg.add(fieldLabel + ': You must enter a value.');
                } else if (value == '' && isProductNotZREP && (fieldName == 'Delivery_Media__c' || fieldName == 'Therapy_Area__c')) {
                    item.setCustomValidity("Complete this field.");
                    item.reportValidity();
                    this.errorMsg.add(fieldLabel + ': You must enter a value.');
                } else if (fieldName == 'Billing_Frequency__c' && value == 'Once') {
                    item.setCustomValidity("");
                    if (item.reportValidity() == false) {
                        this.errorMsg.add(fieldLabel + ': Complete this field.');
                    }

                    //to make Billing_Date__c required if Billing_Frequency__c = Once
                    this.template.querySelectorAll('[data-id="Billing_Date__c"][data-type="date"]').forEach(billingDateLoopItem => {
                        if (billingDateLoopItem.dataset.index === index && !billingDateLoopItem.value) {
                            billingDateLoopItem.setCustomValidity('Billing date is mandatory when billing frequency "Once" is selected.');
                            this.errorMsg.add('Billing Date: Billing date is mandatory when billing frequency "Once" is selected');
                            billingDateLoopItem.reportValidity();
                        }
                    });
                } else if (fieldName == 'Proj_Rpt_Frequency__c' && value == 'Once [O]') {
                    item.setCustomValidity("");
                    if (item.reportValidity() == false) {
                        this.errorMsg.add(fieldLabel + ': Complete this field.');
                    }

                    //to make Delivery_Date__c required if Proj_Rpt_Frequency__c = Once [O]
                    this.template.querySelectorAll('[data-id="Delivery_Date__c"][data-type="date"]').forEach(deliveryDateLoopItem => {
                        if (deliveryDateLoopItem.dataset.index === index && !deliveryDateLoopItem.value) {
                            deliveryDateLoopItem.setCustomValidity('Delivery date is mandatory when Delivery frequency "Once" is selected.');
                            this.errorMsg.add('Delivery Date: Delivery date is mandatory when Delivery frequency "Once" is selected.');
                            deliveryDateLoopItem.reportValidity();
                        }
                    });
                } else if (value == '' && fieldName == 'ProfitCenter__c' && this.productSelected[index].PricebookEntry.Product2.Material_Group_1__c == 'MAN') {
                    item.setCustomValidity("Please Enter Profit Center.");
                    item.reportValidity();
                    this.errorMsg.add('Profit Center: Please Enter Profit Center.');
                } else {
                    // check remove custom error and check standard validity if exiest.
                    item.setCustomValidity("");
                    if (item.reportValidity() == false) {
                        this.errorMsg.add(fieldLabel + ': Complete this field.');
                    }
                }
            }
        });
        this.showSpinner = false;
        return (this.errorMsg.size == 0) ? true : false;
    }

    handleMouseHover(event) {
        //this.popupClass = `position: absolute; z-index:999999; background-color:red; top:${event.clientY}px; left:${event.clientX + 450}px`;
        this.popupClass = `position: absolute; z-index:999999; background-color:white; top:${event.pageY}px; left:${event.pageX}px`;
        let index = event.currentTarget.dataset.index;
        let billingSchList = [];
        this.showBillingHover = true;
        this.showBillingSpinner = true;
        getBillingSchList({ oppLiId: this.productSelected[index].Id })
            .then(result => {
                billingSchList = result;
            }).catch(error => {
                this.handleError(error, 'error while geting billingScheduleList');
            }).finally(() => {
                let billScheduleAmt = 0;
                billingSchList.forEach(currentItem => {
                    billScheduleAmt += currentItem.Billing_Amount__c;
                });
                this.mouseHoverData = {};
                this.mouseHoverData.selectedIndex = index;
                this.mouseHoverData.productName = this.productSelected[index].PricebookEntry.Name;
                this.mouseHoverData.productCode = this.productSelected[index].PricebookEntry.ProductCode;
                this.mouseHoverData.totalPrice = this.productSelected[index].TotalPrice;
                this.mouseHoverData.billingSchList = billingSchList;
                this.mouseHoverData.billScheduleAmt = billScheduleAmt;
                this.mouseHoverData.billScheduleNum = billingSchList.length;
                this.showBillingSpinner = false;
            });
    }

    handleMouseOut() {
        this.mouseHoverData = {};
        this.showBillingHover = false;
    }

    handleError(error, methodName) {
        console.log(methodName + ' : ' + JSON.stringify(error));
        console.log(error);
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
        this.showSpinner = false;
    }

    openRevenueSch(event) {
        let index = event.currentTarget.dataset.index;
        let OliId = this.productSelected[index].Id;
        let StartDate = this.productSelected[index].Product_Start_Date__c ? this.productSelected[index].Product_Start_Date__c : '';
        let EndDate = this.productSelected[index].Product_End_Date__c ? this.productSelected[index].Product_End_Date__c : '';
        let isOriginalBnf = this.bnf.Addendum__c == false;
        let windowWidth = 450;
        let windowHeight = 500;
        let centerWidth = (window.screen.width - windowWidth) / 2;
        let centerHeight = (window.screen.height - windowHeight) / 2;
        //window.open('/apex/revised_revenue_schedule?id=' + OliId + '&startdate=' + StartDate + '&enddate=' + EndDate + '&RevisedPriceId=' + RevisedPriceId + '&ListPriceId=' + ListPriceId + '&OriginalRevSchedules=' + '{!IF(bnf.Addendum__c==false,'true','false')}', 'ShowMessage', 'Width=' + windowWidth + 'px,Height=' + windowHeight + 'px,center=yes,Top=' + centerHeight + ',Left=' + centerWidth + ',scrollbars=yes');
        window.open('/apex/revised_revenue_schedule?isLWC=true&id=' + OliId + '&startdate=' + StartDate + '&enddate=' + EndDate + '&OriginalRevSchedules=' + isOriginalBnf, 'ShowMessage', 'Width=' + windowWidth + 'px,Height=' + windowHeight + 'px,center=yes,Top=' + centerHeight + ',Left=' + centerWidth + ',scrollbars=yes');
    }

    openAddSchedulePopup(event) {
        let index = event.currentTarget.dataset.index;
        let oliId = this.productSelected[index].Id;
        let StartDate = this.productSelected[index].Product_Start_Date__c ? this.productSelected[index].Product_Start_Date__c : '';
        let EndDate = this.productSelected[index].Product_End_Date__c ? this.productSelected[index].Product_End_Date__c : '';
        window.open("/apex/AddProductBillingSchedule?isLWC=true&id=" + oliId + "&bnfid=" + this.bnf.Id + "&startdate=" + StartDate + "&enddate=" + EndDate, oliId, "status = 1, height = 500, width = 1000, resizable = 0, scrollbars = 1");
    }

    openModal(event) {
        try {
            this.selectedProductIndex = event.currentTarget.dataset.index;
            this.selectedAddressId = this.productSelected[this.selectedProductIndex].Other_Ship_To_Address__c;
            this.selectedAddressName = this.productSelected[this.selectedProductIndex].helpingVar.otherShipToAddressName;
            this.selectedSapContactId = this.productSelected[this.selectedProductIndex].Other_Ship_To_SAP_Contact__c;
            this.selectedSapContactName = this.productSelected[this.selectedProductIndex].helpingVar.otherShipToSapContactName;
            this.openPopup = true;
            document.body.style.overflow = "hidden";
            document.body.style.height = "100%";
        } catch (error) {
            this.handleError(error, 'error while opening modal');
        }
    }

    closePopup() {
        this.selectedProductIndex = '';
        this.selectedAddressId = '';
        this.selectedAddressName = '';
        this.selectedSapContactId = '';
        this.selectedSapContactName = '';
        document.body.style.overflow = "auto";
        document.body.style.height = "auto";
        this.openPopup = false;
    }

    handleOtherShipToField(event) {
        try {
            this.showSpinner = true;
            let index = event.detail.selectedProductIndex;
            this.productSelected[index].Other_Ship_To_Address__c = event.detail.selectedAddressId;
            this.productSelected[index].helpingVar.otherShipToAddressName = event.detail.selectedAddressName;
            this.productSelected[index].Other_Ship_To_SAP_Contact__c = event.detail.selectedSapContactId;
            this.productSelected[index].helpingVar.otherShipToSapContactName = event.detail.selectedSapContactName;
        } catch (error) {
            this.handleError(error, 'error while handling data from popup');
        } finally {
            this.closePopup();
            this.showSpinner = false;
        }
    }

    get popupTitle() {
        let bnfName = (this.bnf.Name) ? this.bnf.Name : '';
        let accountName = (this.bnf.Opportunity__r.Account.Name) ? this.bnf.Opportunity__r.Account.Name : '';
        let sapCode = (this.bnf.Opportunity__r.Account.SAP_Reference__c) ? this.bnf.Opportunity__r.Account.SAP_Reference__c : '';
        return 'BNF ' + bnfName + ' : Address Selection for ' + accountName + ' (SAP PC Code ' + sapCode + ')';
    }


    get isRevisedBnf() {
        return (this.bnf && this.bnf.Addendum__c) ? true : false;
    }

    //***************** RESIZABLE COLUMNS STARTS *****************/
    //***************** https://salesforcesas.home.blog/2019/06/23/custom-table-in-lwc ***************** /

    // when  mouse button is released
    handlemouseup(e) {
        this._tableThColumn = undefined;
        this._tableThInnerDiv = undefined;
        this._pageX = undefined;
        this._tableThWidth = undefined;
    }

    // when  mouse button is presses
    handlemousedown(e) {
        if (!this._initWidths) {
            this._initWidths = [];
            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            tableThs.forEach(th => {
                this._initWidths.push(th.style.width);
            });
        }

        this._tableThColumn = e.target.parentElement;
        this._tableThInnerDiv = e.target.parentElement;
        while (this._tableThColumn.tagName !== "TH") {
            this._tableThColumn = this._tableThColumn.parentNode;
        }
        while (!this._tableThInnerDiv.className.includes("slds-cell-fixed")) {
            this._tableThInnerDiv = this._tableThInnerDiv.parentNode;
        }
        this._pageX = e.pageX;

        this._padding = this.paddingDiff(this._tableThColumn);

        this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
    }

    handlemousemove(e) {
        if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
            this._diffX = e.pageX - this._pageX;

            this.template.querySelector("table").style.width = (this.template.querySelector("table") - (this._diffX)) + 'px';

            this._tableThColumn.style.width = (this._tableThWidth + this._diffX) + 'px';
            this._tableThInnerDiv.style.width = this._tableThColumn.style.width;

            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            let tableBodyRows = this.template.querySelectorAll("table tbody tr");
            let tableBodyTds = this.template.querySelectorAll("table tbody .dv-dynamic-width");
            tableBodyRows.forEach(row => {
                let rowTds = row.querySelectorAll(".dv-dynamic-width");
                rowTds.forEach((td, ind) => {
                    rowTds[ind].style.width = tableThs[ind].style.width;
                });
            });
        }
    }

    handledblclickresizable() {
        let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
        let tableBodyRows = this.template.querySelectorAll("table tbody tr");
        tableThs.forEach((th, ind) => {
            th.style.width = this._initWidths[ind];
            th.querySelector(".slds-cell-fixed").style.width = this._initWidths[ind];
        });
        tableBodyRows.forEach(row => {
            let rowTds = row.querySelectorAll(".dv-dynamic-width");
            rowTds.forEach((td, ind) => {
                rowTds[ind].style.width = this._initWidths[ind];
            });
        });
    }

    paddingDiff(col) {
        if (this.getStyleVal(col, 'box-sizing') === 'border-box') {
            return 0;
        }
        this._padLeft = this.getStyleVal(col, 'padding-left');
        this._padRight = this.getStyleVal(col, 'padding-right');
        return (parseInt(this._padLeft, 10) + parseInt(this._padRight, 10));

    }

    getStyleVal(elm, css) {
        return (window.getComputedStyle(elm, null).getPropertyValue(css))
    }
    //***************** RESIZABLE COLUMNS END *****************/

}