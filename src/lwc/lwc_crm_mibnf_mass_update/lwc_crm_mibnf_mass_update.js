import { LightningElement, api, wire,track } from 'lwc';
import getMIBNFComponent from '@salesforce/apex/CNT_CRM_OpportunityProductSearch.getMIBNFComponent';
import { refreshApex } from '@salesforce/apex';

export default class Lwc_crm_mibnf_mass_update extends LightningElement {
    @api recordId;
    @track billingPlan;
    @track headerExistingValue;
    @track bnfExisitingValue; 
    @track currencyIsoCode;
    @track noRecordsFound;
    @track canUpdateOppPrice;
    billingSchWrapperMap= new Map();
    billingSchListForMibnf = [];
    mibnfName;
    selectedId;
    wiredMibnfComponentData;
    wiredMibnfComponentDataToSend;
    wiredMibnfComponentDataMap = new Map();
    billingScheduleData;
    billingScheduleDataMap = new Map();;
    headerTextValue;
    finalBillingPlanMap = new Map();
    finalBillingPlanMapToSend = new Map();
    valueChangePerct;
    oliData;
    showSpinner = false;
    apexResult;
    noBillingPlanMsg;
    noRecordSelectedMsg='No BNF selected';
    disableButton;

    connectedCallback(){
        console.log('inside constructor');
        this.showSpinner = true;
        this.noBillingPlanMsg = this.noRecordSelectedMsg;
    }

    @wire(getMIBNFComponent, { mibnfId: '$recordId' }) wiredMibnfComponent(result){
        var i;
        var mibnfcompwrapper;
        var mibnfList = [];
        this.apexResult = result;
        this.showSpinner = false;
        if (result.data) {
            mibnfcompwrapper= result.data;
            if(mibnfcompwrapper.length > 0){
                console.log(mibnfcompwrapper);
                for(i = 0; i<mibnfcompwrapper.length; i++){
                    mibnfList.push(mibnfcompwrapper[i].mibnfComp);
                    this.wiredMibnfComponentDataMap.set(mibnfcompwrapper[i].mibnfComp.Id, mibnfcompwrapper[i]);
                }
                this.wiredMibnfComponentData = mibnfList;
                this.canUpdateOppPrice = mibnfcompwrapper[0].canUpdateOppPrice;
                this.currencyIsoCode = this.wiredMibnfComponentData[0].CurrencyIsoCode;
                this.mibnfName = this.wiredMibnfComponentData[0].MIBNF__r.Name;
                console.log(this.canUpdateOppPrice);
                console.log(this.oliTobillingSchMap);
                this.compListTosend(JSON.parse(JSON.stringify(this.wiredMibnfComponentData)));
            }
            else{
                this.noRecordsFound = 'No New/Rejected records present to Update';
            }
        }
    };

     compListTosend = function(wiredMibnfComp){
        var compWrapper,i;
        var wrapperDataList = [];
        for(i=0;i<wiredMibnfComp.length; i++){
            console.log(wiredMibnfComp[i].CurrencyIsoCode);
            compWrapper = {
                id : wiredMibnfComp[i].Id,
                name :  wiredMibnfComp[i].Name,
                billToName : wiredMibnfComp[i].Bill_To__c ? wiredMibnfComp[i].Bill_To__r.Name: '',
                poNumber : wiredMibnfComp[i].Client_PO_Number__c,
                contractValue : wiredMibnfComp[i].Contract_Value__c,
                bnfStatus : wiredMibnfComp[i].BNF_Status__c,
                currencyisocode : wiredMibnfComp[i].CurrencyIsoCode,
                disableUpdateButton : true,
                buttoncenterStyle : 'slds-align_absolute-center'
            }
            wrapperDataList.push(compWrapper);
        }
        console.log(wrapperDataList);
        this.wiredMibnfComponentDataToSend = wrapperDataList;
    }

    showHeaderData(event){
        var objDetail,i;
        var billPlan = [];
        var billingSchWrapper;
        this.noBillingPlanMsg = 'No Billing Plan for this record';
        this.selectedId = event.detail;
        console.log(event.detail);
        for(i=0;i<this.wiredMibnfComponentDataToSend.length;i++){
            if(this.wiredMibnfComponentDataToSend[i].id === this.selectedId){
                this.wiredMibnfComponentDataToSend[i].disableUpdateButton = false;
            }else{
                this.wiredMibnfComponentDataToSend[i].disableUpdateButton = true;
            }
        }
        
        this.template.querySelector('c-lwc-crm-mibnf-comp-list').setMibnfList(this.wiredMibnfComponentDataToSend);
        console.log(this.wiredMibnfComponentDataToSend);
        objDetail = this.wiredMibnfComponentDataMap.get(this.selectedId);
        console.log(objDetail);
        this.headerExistingValue = objDetail.mibnfComp.Invoice_Header_Text__c;
        this.bnfExisitingValue = objDetail.mibnfComp.Contract_Value__c;//Number((objDetail.mibnfComp.Contract_Value__c).toFixed(2));
        this.billingPlan = null;
        this.finalBillingPlanMap = new Map();
        this.billingSchListForMibnf = [];
        this.billingSchWrapperMap = new Map(Object.entries(objDetail.billischMap));
        this.oliData = Object.entries(objDetail.oliMap);
        for(i = 0; i < this.oliData.length; i++){
            if(this.billingSchWrapperMap.has(this.oliData[i][0])){   
                billingSchWrapper = {
                    Id : this.oliData[i][0],
                    oliName : this.oliData[i][1].Product2.Name,
                    oliPrice : Number((this.oliData[i][1].UnitPrice).toFixed(2)),
                    oliIsoCode: this.currencyIsoCode,
                    billingSchList : this.billingSchWrapperMap.get(this.oliData[i][0]) 
                };
                this.billingSchListForMibnf.push(...this.billingSchWrapperMap.get(this.oliData[i][0]));
                billPlan.push(billingSchWrapper);
            }
        }
        if(billPlan.length > 0){
            this.billingPlan = billPlan;
        }
        console.log(this.billingPlan);
    }

    changeHeaderText(event) {
        this.isheaderTextChanged = true;
        this.headerTextValue = event.target.value;
        if (this.headerTextValue ===  '') {
            this.isheaderTextChanged = false;
        }
    }

    changeBNFValue(event) {
        this.isBNFValueChanged = true;
        this.valueChangePerct = event.target.value;
        if (this.valueChangePerct === '') {
            this.isBNFValueChanged = false;
        }
    }

    changeBillingDate(event) {
        var schId = event.target.id;
        var buttonValue = event.target.value;
        console.dir(event.target);
        schId = schId.substr(0,18);
        console.log(schId);
        this.checkBillingDateValidity(event,schId,buttonValue);
        console.log(this.billingSchListForMibnf);

        if(buttonValue !== '' && buttonValue !== null){
            this.finalBillingPlanMap.set(schId, buttonValue);
        }else if(this.finalBillingPlanMap.has(schId)){
            this.finalBillingPlanMap.delete(schId);
        }
        console.log(this.finalBillingPlanMap);
        this.finalBillingPlanMapToSend = Object.fromEntries(this.finalBillingPlanMap);
        console.log(this.finalBillingPlanMapToSend);
    }

    checkBillingDateValidity(event,schId,buttonValue){
        var i;
        var isSameAsOld = false;
        var inputTarget = event.target;
        for(i = 0; i < this.billingSchListForMibnf.length; i++){
            if(this.billingSchListForMibnf[i].Id === schId && this.billingSchListForMibnf[i].Billing_Date__c === buttonValue){
                console.log("Same value as Old");
                inputTarget.setCustomValidity("New Billing Date can not be same as old Billing Date. Please input a different value.");
                isSameAsOld= true;
                break;
            }
        }
        if(!isSameAsOld){
            inputTarget.setCustomValidity("");
        }
    }

    setSpinner(event){
        console.log(event.detail);
        this.showSpinner = event.detail;
    }

    refreshData(){
        var inputList;
        console.log('refresh Apex');
        refreshApex(this.apexResult).then((value)=>{
            console.log(value);
            this.showHeaderData({detail:this.selectedId});
            inputList = this.template.querySelectorAll('.headerInput');
            inputList.forEach(element=>{
                if(element.type === 'date'){
                    element.value = null;
                }
            });
            //this.headerTextValue = null;
            //this.valueChangePerct = null;
            this.finalBillingPlanMapToSend = new Map();
        });        
    }
    
    get isError(){
        var isError = false;
        var inputList =this.template.querySelectorAll('.headerInput');
        inputList.forEach(element => {
            console.log(element);
            if(!element.checkValidity()){
                isError = true;
            }
        });
        return isError;
    }
}