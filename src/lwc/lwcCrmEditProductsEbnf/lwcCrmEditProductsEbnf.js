import { LightningElement, api } from 'lwc';
import fetchAllDetails from '@salesforce/apex/CNT_CRM_Edit_Products_eBNF.fetchAllDetails';
import save from '@salesforce/apex/CNT_CRM_Edit_Products_eBNF.save';

const VALIDATION_CHECK_REQ_ON = new Set(['Delivery_Media__c', 'Proj_Rpt_Frequency__c', 'Billing_Frequency__c', 'Billing_Date__c', 'Sale_Type__c', 'Revenue_Type__c', 'Therapy_Area__c', 'ProfitCenter__c', 'PO_line_item_number__c', 'Nbr_of_Users__c', 'Other_Ship_To__c']);

const HEADER_COL = new Set([
    { iniStyle: 'width:12rem;', showCheckBox: false, label: "Name", fieldName: "Name" },
    { iniStyle: 'width:06rem;', showCheckBox: false, label: "Sales Price", fieldName: "TotalPrice" },
    { iniStyle: 'width:08rem;', showCheckBox: false, label: "Product Code", fieldName: "ProductCode" },
    { iniStyle: 'width:08rem;', showCheckBox: false, label: "Delivery Country", fieldName: "Delivery_Country__c" },
    { iniStyle: 'width:10rem;', showCheckBox: false, label: "WBS Code", fieldName: "WBS_R_Element__c" },
    { iniStyle: 'width:10rem;', showCheckBox: true, label: "Data Period Start", fieldName: "Product_Start_Date__c" },
    { iniStyle: 'width:10rem;', showCheckBox: true, label: "Data Period End", fieldName: "Product_End_Date__c" },
    { iniStyle: 'width:12rem;', showCheckBox: true, label: "Delivery Media", fieldName: "Delivery_Media__c" },
    { iniStyle: 'width:12rem;', showCheckBox: true, label: "Delivery/Rpt Frequency", fieldName: "Proj_Rpt_Frequency__c" },
    { iniStyle: 'width:12rem;', showCheckBox: true, label: "Billing Frequency", fieldName: "Billing_Frequency__c" },
    { iniStyle: 'width:12rem;', showCheckBox: false, label: "Product Invoice Text", fieldName: "Product_Invoice_Text__c" },
    { iniStyle: 'width:08rem;', showCheckBox: false, label: "List Price", fieldName: "List_Price__c" },
    { iniStyle: 'width:08rem;', showCheckBox: false, label: "Discount %", fieldName: "Discount_Percentage_Formula__c" },
    { iniStyle: 'width:08rem;', showCheckBox: false, label: "Discount Amt", fieldName: "Discount_Amount_Formula__c" },
    { iniStyle: 'width:12rem;', showCheckBox: true, label: "Discount Reason", fieldName: "Discount_Reason__c" },
    { iniStyle: 'width:10rem;', showCheckBox: false, label: "PO line item number", fieldName: "PO_line_item_number__c" },
    { iniStyle: 'width:10rem;', showCheckBox: true, label: "Number of Users", fieldName: "Nbr_of_Users__c" },
    { iniStyle: 'width:10rem;', showCheckBox: true, label: "Other Ship To", fieldName: "Other_Ship_To__c" },
    { iniStyle: 'width:10rem;', showCheckBox: true, label: "Billing Date", fieldName: "Billing_Date__c" },
    { iniStyle: 'width:10rem;', showCheckBox: true, label: "Sales Type", fieldName: "Sale_Type__c" },
    { iniStyle: 'width:10rem;', showCheckBox: false, label: "Revenue Type", fieldName: "Revenue_Type__c" },
    { iniStyle: 'width:12rem;', showCheckBox: false, label: "Invoice Lag to Data Period", fieldName: "Invoice_Lag_to_Data_Period__c" },
    { iniStyle: 'width:12rem;', showCheckBox: true, label: "Therapy Area", fieldName: "Therapy_Area__c" },
    { iniStyle: 'width:10rem;', showCheckBox: false, label: "Audit Subscription Status", fieldName: "Audit_Subscription_Status__c" },
    { iniStyle: 'width:12rem;', showCheckBox: false, label: "Profit Center", fieldName: "ProfitCenter__c" },
]);

export default class LwcCrmEditProductsEbnf extends LightningElement {
    headerCol = HEADER_COL;
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

    connectedCallback() {
    }

    renderedCallback() {
        if (this.recordId && this.bnf == null && this.dataProcessingComplete) {
            this.dataProcessingComplete = false;
            this.showSpinner = true;
            this.fetchAllDetailsJS();
        }
    }

    fetchAllDetailsJS() {
        console.log('fetching Oli Data...');
        fetchAllDetails({ recId: this.recordId })
            .then(result => {
                if (result) {
                    this.fullResult = result;
                    if (result.isRecordLocked === true) {
                        this.errorMsg = new Set();
                        this.errorMsg.add('record is locked you can not edit product. please click cancel to go back to bnf');
                        this.showError = true;
                    } else {
                        this.bnf = result.bnf;
                        if (this.bnf.Addendum__c && this.headerCol.size == 25) {
                            this.headerCol.add({ iniStyle: 'width:08rem;', showCheckBox: false, label: "Revised Price", fieldName: "Revised_Price__c" })
                            this.headerCol.add({ iniStyle: 'width:06rem;', showCheckBox: false, label: "Cancel", fieldName: "Cancel__c" })
                        }
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
        console.log('Setting conditional and pickList variable');
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
                let oliMaterialGroup = opptyLineItem.PricebookEntry.Product2.Material_Group_1__c;

                //setting picklist value to blank if Undefined or null
                opptyLineItem.Delivery_Media__c = opptyLineItem.Delivery_Media__c ? opptyLineItem.Delivery_Media__c : '';
                opptyLineItem.Proj_Rpt_Frequency__c = opptyLineItem.Proj_Rpt_Frequency__c ? opptyLineItem.Proj_Rpt_Frequency__c : '';
                opptyLineItem.Billing_Frequency__c = opptyLineItem.Billing_Frequency__c ? opptyLineItem.Billing_Frequency__c : '';
                opptyLineItem.Discount_Reason__c = opptyLineItem.Discount_Reason__c ? opptyLineItem.Discount_Reason__c : '';
                opptyLineItem.Sale_Type__c = opptyLineItem.Sale_Type__c ? opptyLineItem.Sale_Type__c : '';
                opptyLineItem.Revenue_Type__c = opptyLineItem.Revenue_Type__c ? opptyLineItem.Revenue_Type__c : '';
                opptyLineItem.Invoice_Lag_to_Data_Period__c = opptyLineItem.Invoice_Lag_to_Data_Period__c ? opptyLineItem.Invoice_Lag_to_Data_Period__c : '';
                opptyLineItem.Therapy_Area__c = opptyLineItem.Therapy_Area__c ? opptyLineItem.Therapy_Area__c : '';
                opptyLineItem.ProfitCenter__c = opptyLineItem.ProfitCenter__c ? opptyLineItem.ProfitCenter__c : '';

                opptyLineItem.helpingVar = {};
                opptyLineItem.helpingVar.isProductZPUB = oliMaterialType === 'ZPUB' ? true : false;
                opptyLineItem.helpingVar.isMaterialGroupNotMAN = oliMaterialGroup == 'MAN' ? false : true;
                opptyLineItem.helpingVar.picDeliveryMedia = deliveryMediaMap.hasOwnProperty(oliId) == true ? deliveryMediaMap[oliId] : '';
                opptyLineItem.helpingVar.picDeliveryFrequency = deliveryFrequencyMap.hasOwnProperty(oliId) == true ? deliveryFrequencyMap[oliId] : '';
                opptyLineItem.helpingVar.picTherapyArea = therapyAreaMap.hasOwnProperty(oliId) == true ? therapyAreaMap[oliId] : '';
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
            let value = '';
            if (fieldName === 'Cancel__c') {
                value = event.target.checked;
            } else {
                value = event.target.value;
            }
            this.productSelected[index][fieldName] = value;
            console.log('product[' + index + '][' + fieldName + '] = ' + value);

            //  update all record if checkbox is checked and 1st element is changed and not blank, null or undefined
            if (index == 0 && value) {
                var updateAllOli = false;
                this.template.querySelectorAll('[data-type="clonebox"]').forEach(item => {
                    if (item.dataset.id == fieldName && item.checked) {
                        updateAllOli = true;
                    }
                });
                if (updateAllOli) {
                    xIndex = 'all';
                    this.productSelected.forEach(item => {
                        item[fieldName] = value;
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
            let value = this.productSelected[0][fieldName];
            if (checked === true && value) {
                this.productSelected.forEach(oli => {
                    oli[fieldName] = value;
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
        console.log('navigating to record: ', recId);
        window.open('/lightning/r/BNF2__c/' + recId + '/view', '_self');
    }

    handleSaveOnly() {
        try {
            this.showSpinner = true;
            this.showError = false;
            this.errorMsg = new Set();
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
            if (this.validateOLI('all')) {
                console.log('UI Validation complete with 0 error: ');
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

        save({ opptyLineItem2: opptyLineItem2, operationType: operationType })
            .then(result => {
                if (result.Success) {
                    this.navigateToRecord(this.recordId);
                } else if (result.error) {
                    this.handleError(result.error, 'error while saving data CNT');
                }
            }).catch(error => {
                this.handleError(error, 'error while saving data');
            });
    }

    validateOLI(xindex) {
        xindex = xindex ? xindex : 'all';
        console.log('validating OLI...', xindex);
        this.template.querySelectorAll('lightning-input').forEach(item => {
            let fieldLabel = item.parentElement.dataset.label;
            let index = item.dataset.index;
            let fieldApi = item.dataset.id;
            let value = item.value;
            if (xindex == index || xindex == 'all') {
                if ((fieldApi === 'PO_line_item_number__c' || fieldApi === 'Nbr_of_Users__c' || fieldApi === 'Other_Ship_To__c') && value != null && value != '' && value % 1 != 0) {
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
        });

        this.template.querySelectorAll('lightning-combobox').forEach(item => {
            let fieldName = item.dataset.id
            let fieldLabel = item.parentElement.dataset.label;
            let value = item.value ? item.value : '';
            let index = item.dataset.index;

            if (xindex == index || xindex == 'all') {
                if (value == '' && (fieldName == 'Delivery_Media__c' || fieldName == 'Proj_Rpt_Frequency__c' || fieldName == 'Billing_Frequency__c' || fieldName == 'Sale_Type__c' || fieldName == 'Revenue_Type__c' || fieldName == 'Therapy_Area__c')) {
                    item.setCustomValidity("Complete this field.");
                    item.reportValidity();
                    this.errorMsg.add(fieldLabel + ': You must enter a value.');
                } else if ((fieldName == 'Revenue_Type__c' && value == 'Ad Hoc') || fieldName == 'Billing_Frequency__c' && value == 'Once') {
                    //to make Billing_Date__c required if Revenue_Type__c = Ad Hoc or Billing_Frequency__c = Once
                    let billingDateitem = this.template.querySelectorAll('[data-id="Billing_Date__c"][data-type="date"]')[index];
                    if (!billingDateitem.value) {
                        if (fieldName == 'Revenue_Type__c') {
                            billingDateitem.setCustomValidity('Please enter Billing Date for Ad Hoc Product.');
                            this.errorMsg.add('Billing Date: Please enter Billing Date for Ad Hoc Product.');
                        }
                        else if (fieldName == 'Billing_Frequency__c') {
                            billingDateitem.setCustomValidity('Billing date is mandatory when billing frequency "Once" is selected.');
                            this.errorMsg.add('Billing Date: Billing date is mandatory when billing frequency "Once" is selected');
                        }
                        billingDateitem.reportValidity();
                    }
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

    get isRevisedBnf() {
        return (this.bnf && this.bnf.Addendum__c) ? true : false;
    }

    //***************** RESIZABLE COLUMNS END *****************/
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
    //***************** RESIZABLE COLUMNS END *************************************/

}