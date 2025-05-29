import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import searchForIds from '@salesforce/apex/CNT_CSM_CommunitySearch.searchForIds';
import getUserContact from '@salesforce/apex/CNT_CSM_CommunitySearch.getUserContact';
import getProductCommunityTopics from '@salesforce/apex/CNT_CSM_CommunityTopics.getProductCommunityTopics';
import LABEL_ALL_PRODUCTS from '@salesforce/label/c.All_Products';
import isGuest from "@salesforce/user/isGuest";
import SEARCH_KNOWLEDGE_ARTICLE_OR_EXISTING_CASE from '@salesforce/label/c.Search_knowledge_article_or_existing_case';

export default class LwcCshSearch extends NavigationMixin(LightningElement) {
    @api isRnDContact = false;
    @api limit = 50;
    @track selectedProduct = '';
    @track productOptions = [];

    labels = {
        Search_knowledge_article_or_existing_case: SEARCH_KNOWLEDGE_ARTICLE_OR_EXISTING_CASE
    };

    connectedCallback() {
        if(!this.isGuest) {
            this.getUser();
        }
        this.getProductOptions();
    }

    getUser() {
        getUserContact()
            .then(result => {
                const contact = result[0];
                if (contact) {
                    this.isRnDContact = contact.Portal_Case_Type__c == 'R&D';
                }
            })
            .catch(error => {
                console.log('Error: ' + JSON.stringify(error));
            });
    }

    getProductOptions() {
        getProductCommunityTopics()
            .then(result => {
                const products = result;
                const items = [];
                items.push({ label: LABEL_ALL_PRODUCTS, value: '' });
                products.forEach(prd => {
                    items.push({
                        label: prd.Name,
                        value: prd.Id
                    });
                });
                this.productOptions = items;
            })
            .catch(error => {
                console.log('Error: ' + JSON.stringify(error));
            });
    }

    handleProductChange(event) {
        this.selectedProduct = event.detail.value;
    }

    handleKeyUp(event) {
        const isEnterKey = event.keyCode === 13;
        if (!isEnterKey) {
            return;
        }
        const searchText = event.target.value;
        const regex = /[^a-zA-Z0-9"]/g;
        const filteredText = searchText.replace(regex, ' ');
        const searchTerms = filteredText.split(' ').filter(ele => ele.length > 2).join(' ');
        searchForIds({
            searchText: searchTerms,
            searchForPrd: this.selectedProduct,
            searchObject: '',
            rowLimit: this.limit,
            rowOffset: 0
        })
            .then(result => {
                sessionStorage.setItem('search--text', searchTerms);
                sessionStorage.setItem('search--prd', this.selectedProduct);
                sessionStorage.setItem('customSearch--results', JSON.stringify(result));
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: '/search-results'
                    },
                    reload: true
                });
            })
            .catch(error => {
                console.log('Error: ' + JSON.stringify(error));
            });
    }

    get isGuest() {
        return isGuest;
    }
}
