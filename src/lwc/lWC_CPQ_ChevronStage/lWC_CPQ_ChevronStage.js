import { LightningElement, api, wire, track } from 'lwc';
import getPicklistValues from "@salesforce/apex/CNT_CPQ_ChevronStage.getPicklistValues";
import getCurrentAndPreviousStage from "@salesforce/apex/CNT_CPQ_ChevronStage.getCurrentAndPreviousStage";
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import GLOBALMC from "@salesforce/messageChannel/CPQ_GlobalChevron__c";
import { refreshApex } from '@salesforce/apex';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import Status__c from "@salesforce/schema/Quote__c.Status__c";
export default class Chevron extends LightningElement {
    @api objectApiName;
    @api recordId; 
    @track picklistvalues;
    @track chevrondata=[];
    @track currentStage;
    @track previousStage;
    subscription = null;
    stages;
    listOffieldHistoryRecords = [];
    oldStages = new Set();
    newStages = new Set();
    skippedStages = new Set();
    nextStages = new Set();
    @wire(MessageContext) messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    @wire(getPicklistValues, {recordId: '$recordId'})

    getStages(result) {
        if(result.data) {
            this.picklistvalues = result.data;
            this.getCurrentAndPreviousStages();
        } else if (result.error) {
            console.log('error = ' + result.error);
        }
    }

    @wire(getRecord, {
        recordId: "$recordId",
        fields: [Status__c],
      })
      handleStatusChange(wireResult) {
        if (wireResult.data) {
            this.getCurrentAndPreviousStages();
        } else if (wireResult.error) {
            console.log('error = ' + wireResult.error);
        }
      }

    getCurrentAndPreviousStages() {
        getCurrentAndPreviousStage({"recordId": this.recordId}).then(data => {
            this.oldStages = new Set();
            this.newStages = new Set();
            this.skippedStages = new Set();
            this.nextStages = new Set();

            this.stages = this.picklistvalues;
            this.listOffieldHistoryRecords = data;
            this.currentStage =  this.listOffieldHistoryRecords[0].New_Value__c;
            this.previousStage = this.listOffieldHistoryRecords[0].Old_Value__c;
            this.listOffieldHistoryRecords.forEach(currentItem => {
                if (currentItem.Old_Value__c != null && currentItem.Old_Value__c != this.currentStage) {
                    this.oldStages.add(currentItem.Old_Value__c);
                }
                if (currentItem.New_Value__c != null && currentItem.New_Value__c != this.currentStage) {
                    this.newStages.add(currentItem.New_Value__c);
                }
            });
            this.stages.forEach(currentItem => {
                if ((!this.oldStages.has(currentItem) && !this.newStages.has(currentItem))) {
                    if (currentItem != this.currentStage) {
                        this.skippedStages.add(currentItem);
                    }
                }
            });
            this.oldStages.forEach(currentItem => {
                if (this.stages.indexOf(currentItem) > this.stages.indexOf(this.currentStage)){
                    this.nextStages.add(currentItem);
                } else if (this.stages.indexOf(currentItem) < this.stages.indexOf(this.currentStage)) {
                    if (this.stages.indexOf(this.previousStage) < this.stages.indexOf(currentItem)) {
                        this.nextStages.add(currentItem);
                    }
                }
            });
            if (this.currentStage == 'Draft') {
                this.previousStage = '';
            }
            this.computeStageClass();
        }).catch(error => {
            console.log('error = ' + error);
        });
    }
    
    computeStageClass() {
        this.chevrondata = [];
        this.stages.forEach(currentItem => {
            if (this.nextStages.has(currentItem)){
                this.chevrondata.push({
                    stages :currentItem,
                    classType:'slds-path__item  slds-is-current'
                });
            } else if (this.oldStages.has(currentItem)) {
                this.chevrondata.push({
                    stages :currentItem,
                    classType:'slds-path__item slds-is-complete'
                });
            } else if (this.currentStage == currentItem) {
                if (currentItem == 'Cancelled') {
                    this.chevrondata.push({
                        stages :currentItem,
                        classType:'slds-path__item slds-is-lost slds-is-active slds-is-current'
                    });
                } else {
                    this.chevrondata.push({
                        stages :currentItem,
                        classType:'slds-path__item slds-is-current slds-is-active'
                    });
                }
            } else if (this.skippedStages.has(currentItem)) {
                this.chevrondata.push({
                    stages :currentItem,
                    classType:'slds-path__item slds-is-incomplete'
                });
            }  
        });
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            GLOBALMC,
            (message) =>this.handleChannelMessage(message)
        );
    }

    handleChannelMessage (message) {
        if (message.isStageUpdated) {
            this.getCurrentAndPreviousStages();
        }
    }
}