import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import { refreshApex } from '@salesforce/apex';
import searchArticles from '@salesforce/apex/CNT_CSM_AttachArticle.searchArticles';
import getCaseArticle from '@salesforce/apex/CNT_CSM_AttachArticle.getCaseArticle';
import getDataCustomSetting from '@salesforce/apex/CNT_CSM_AttachArticle.getDataCustomSetting';
import deleteCaseArticle from '@salesforce/apex/CNT_CSM_AttachArticle.deleteCaseArticle';
import insertCaseArticle from '@salesforce/apex/CNT_CSM_AttachArticle.insertCaseArticle';
import draftEmailAction from '@salesforce/apex/CNT_CSM_AttachArticle.draftEmailAction';
import getCaseAssistance from '@salesforce/apex/CNT_CSM_SNOWChatGPT.getCaseAssistance';
import TIMEZONE from '@salesforce/i18n/timeZone';
import SUBJECT from '@salesforce/schema/Case.Subject';

export default class Lwc_csm_attachArticle extends NavigationMixin(LightningElement) {
    @track error;
    @track caseArticleList = [];
    @track suggestedArticleList = [];
    @track searchArticleList = [];
    @api recordId;
    showSpinner = true;
    timezone = TIMEZONE;
    suggestedArticle = true;
    limit = 15;
    offset;
    suggestedOffset = 0;
    searchOffset = 0;
    searchLoadMore = true;
    suggestedLoadMore = true;
    subject = '';
    queryTerm;
    queryToShort = false;
    event1;
    timeSpan = 10000;
    isDraftEmail = false;
    @wire(getCaseArticle, { caseId: '$recordId' })
    wiredCaseArticle(result) {
        this.wiredCaseArticleResults = result;
        const { error, data } = result;
        if (data) {
            this.caseArticleList = data;
            this.error = undefined;
            if (this.caseArticleList.length > 0)
                this.template.querySelector('lightning-tabset').activeTabValue = 'attached';
        } else if (error) {
            this.error = error;
            this.caseArticleList = undefined;
        }
        this.showSpinner = false;
    }

    @wire(getDataCustomSetting)
    getDataCustomSetting(result){
        if(result != undefined && result.data != undefined) {
            this.isDraftEmail = result.data;
        }
        
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [SUBJECT]
    })
    wirearticle({ error = {}, data } = {}) {
        this.showSpinner = false;
        if (error.data) {
            this.error = error;
            return;
        }
        if (data) {
            this.subject = data.fields.Subject?.value;
            this.error = undefined;
            this.initSearch();
        }
    }

    initSearch() {
        this.queryTerm = this.subject;
        this.suggestedArticle = true;
        this.suggestedOffset = 0;
        this.suggestedArticleList = [];
        this.searchArticleList = [];
        this.searchOffset = 0;
        this.searchArticles();
        this.getDataCustomSetting();
    }

    async insertCaseArticle(knowledgeArticleId) {
        this.showSpinner = true;
        try {
            await insertCaseArticle({
              caseId: this.recordId,
              knowledgeArticleId: knowledgeArticleId
            });
            eval("$A.get('e.force:refreshView').fire();");
            this.initSearch();
            await refreshApex(this.wiredCaseArticleResults);
          } catch (error) {
            console.log(error);
            this.showSpinner = false;
          }
          
    }

    async deleteCaseArticle(knowledgeArticleId) {
        this.showSpinner = true;
        try {
            await deleteCaseArticle({
                caseId: this.recordId,
                knowledgeArticleId: knowledgeArticleId
            });
            eval("$A.get('e.force:refreshView').fire();");
            this.initSearch();
            await refreshApex(this.wiredCaseArticleResults);
        } catch(error) {
            console.log(error);
            this.showSpinner = false;
        }
    }
    

    searchArticles() {
        if (this.queryTerm === null) {
            return false;
        }

        this.queryTerm = this.queryTerm.replace(/[^a-zA-Z0-9"]/g, ' ');
        this.queryTerm = this.queryTerm.split(' ').filter((ele) => ele.length > 2).join(' ');

        this.showSpinner = true;

        if (this.suggestedArticle) {
            this.offset = this.suggestedOffset;
        } else {
            this.offset = this.searchOffset;
        }
        searchArticles({
            searchText: this.queryTerm,
            caseId: this.recordId,
            rowLimit: this.limit,
            rowOffset: this.offset
        })
            .then(result => {
                // Split the query term into phrases and words, removing any double quotes and common stop words
                const phrasesAndWords = this.queryTerm.match(/(".*?"|\S+)/g).map(term => term.replaceAll('"', '').trim());
                const phrases = phrasesAndWords.filter(term => term.startsWith('"') && term.endsWith('"'));
                const words = phrasesAndWords.filter(term => !phrases.includes(term) && !['and', 'or'].includes(term));

                result.forEach(element => {
                    element.Content = '';
                    if (element.RecordTypeId === '0126A000000hC38QAE') {
                        element.Content += [element.Content__c, element.L1Content__c, element.L2L3Content__c].filter(Boolean).join(' ');
                    } else {
                        element.Content += [element.Answer__c, element.L1Answer__c, element.L2L3Answer__c].filter(Boolean).join(' ');
                    }
                    
                    element.Content = element.Content.replace(/(<([^>]+)>)/ig, '');

                    phrases.forEach(phrase => {
                        const markTag = '<mark>' + phrase + '</mark>';
                        element.Title = element.Title.replaceAll(new RegExp(phrase, 'ig'), markTag);
                        if (element.Question__c) {
                            element.Question__c = element.Question__c.replaceAll(new RegExp(phrase, 'ig'), markTag);
                        }
                        element.Content = element.Content.replaceAll(new RegExp(phrase, 'ig'), markTag);
                    });

                    words.forEach(word => {
                        const markTag = '<mark>' + word + '</mark>';
                        element.Title = element.Title.replaceAll(new RegExp(word, 'ig'), markTag);
                        if (element.Question__c) {
                            element.Question__c = element.Question__c.replaceAll(new RegExp(word, 'ig'), markTag);
                        }
                        element.Content = element.Content.replaceAll(new RegExp(word, 'ig'), markTag);
                    });


                    // Split the content into blocks of 150 characters and keep the one with the highest weighted score
                    const blocks = element.Content.match(/.{0,150}/g);
                    let maxWeightedScore = -1;
                    let bestBlock = '';
                    blocks.forEach(block => {
                        const wordsCount = words.reduce((count, word) => count + (block.match(new RegExp(word, 'ig')) || []).length, 0);
                        const phrasesCount = phrases.reduce((count, phrase) => count + (block.match(new RegExp(phrase, 'ig')) || []).length, 0);
                        const weightedScore = phrasesCount * 3 + wordsCount;
                        if (weightedScore > maxWeightedScore) {
                            maxWeightedScore = weightedScore;
                            bestBlock = block;
                        }
                    });
                    element.Content = maxWeightedScore >= 0 ? bestBlock : '';
                });




                if (this.suggestedArticle) {
                    this.suggestedArticleList.push(...result);
                    this.suggestedOffset = this.offset + this.limit;
                    this.suggestedLoadMore = result.length > 0;
                } else {
                    this.searchArticleList.push(...result);
                    this.searchOffset = this.offset + this.limit;
                    this.searchLoadMore = result.length > 0;
                }

                this.showSpinner = false;
            })
            .catch(error => {
                console.log(error);
                this.showSpinner = false;
            });
    }

    navigateToArticle(event) {
        event.preventDefault();
        const selectedRecordId = event.currentTarget.dataset.value;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedRecordId,
                objectApiName: 'Knowledge__kav',
                actionName: 'view'
            },
        });
    }

    handleLoadMore() {
        this.searchArticles();
    }

    backToSuggestions() {
        this.suggestedArticle = true;
    }

    handleKeyUp(event) {
        const isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
            this.suggestedArticle = false;
            this.queryToShort = false;
            this.searchArticleList = [];
            this.searchOffset = 0;
            this.searchLoadMore = true;
            this.queryTerm = event.target.value;
            if (this.queryTerm.length > 1)
                this.searchArticles();
            else
                this.queryToShort = true;
        }
    }

    attachArticle(event) {
        event.preventDefault();
        const knowledgeArticleId = event.target.value;
        this.insertCaseArticle(knowledgeArticleId);
    }

    detachArticle(event) {
        event.preventDefault();
        const knowledgeArticleId = event.target.value;
        this.deleteCaseArticle(knowledgeArticleId);
    }

    draftEmail(event) {
        event.preventDefault();
        const knowledgeArticleId = event.target.value;
        this.showSpinner = true;
        
       draftEmailAction({caseId: this.recordId, knowledgeArticleId : knowledgeArticleId})
        .then(result => {
            this.showSpinner = true;
            this.event1 = setInterval(() => {
                if(result){
                  getCaseAssistance({caseId : this.recordId, sys_id : result[0].sys_Id__c, askType : this.askType})
                       .then(getresult => {
                        if (getresult.length > 0){
                            getresult.forEach(cont => {
                                var pageRef = {
                                    type: "standard__quickAction",
                                    attributes: {
                                      apiName: "Case.SendEmail",
                                    },
                                    state: {
                                      objectApiName: 'Case',
                                      recordId: this.recordId,
                                      defaultFieldValues: encodeDefaultFieldValues({
                                        HtmlBody: cont.Content__c
                                      }),
                                    },
                                  };
                              
                                  this[NavigationMixin.Navigate](pageRef,true);
                            });
                           clearInterval(this.event1);
                           this.showSpinner = false;
                           
                       }
                   })
                   .catch(error => {
                     clearInterval(this.event1);
                     this.error = error;
                     this.showSpinner = false;
                   });
               }
               }, this.timeSpan);
        })
        .catch(error => {
            this.showSpinner = false;
        });
    }

    get canLoadMoreSuggestions() {
        return (this.suggestedLoadMore && this.suggestedArticleList.length >= this.limit) ? true : false;
    }

    get canLoadMoreSearchResults() {
        return (this.searchLoadMore && this.searchArticleList.length >= this.limit) ? true : false;
    }

    get hasCaseArticle() {
        return this.caseArticleList.length > 0;
    }

    get nbCaseArticle() {
        return this.caseArticleList.length;
    }

    get hasSuggestedArticle() {
        return this.suggestedArticleList.length > 0;
    }

    get nbSuggestedArticle() {
        return this.suggestedArticleList.length;
    }

    get hasSearchArticle() {
        return this.searchArticleList.length > 0;
    }

    get nbSearchArticle() {
        return this.searchArticleList.length;
    }
}
