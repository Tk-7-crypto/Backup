import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getProductTopics from '@salesforce/apex/CNT_CSM_CommunityTopics.getProductCommunityTopics';
import EXPLORE_BY_IQVIA_PRODUCTS_LABEL from '@salesforce/label/c.Explore_by_IQVIA_Products';
import SEE_FILES_LABEL from '@salesforce/label/c.See_files';
import DOCUMENTATION_LABEL from '@salesforce/label/c.Documentation';
import FORUM_LABEL from '@salesforce/label/c.Forum';
import SALES_LABEL from '@salesforce/label/c.Sales';


export default class Lwc_prm_product_topics extends NavigationMixin(LightningElement) {
    labels = {
        Explore_by_IQVIA_Products: EXPLORE_BY_IQVIA_PRODUCTS_LABEL,
        See_files: SEE_FILES_LABEL,
        Documentation: DOCUMENTATION_LABEL,
        Forum: FORUM_LABEL,
        Sales:SALES_LABEL,
    };
    products = [];
    @track isLoading = true;
    @wire(getProductTopics)
    wiredProductTopics({ error, data }) {
        if (data) {
            this.products = data.map((item) => ({
                label: item.Name,
                value: item.Name,
            }));
            this.isLoading = false;
        } else if (error) {
            console.error(error);
            this.isLoading = false;
        }
    }

    navigateToKb(event) {
        const productName = event.target.value;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/kb?p=' + productName
            },
            reload: true
        });
    }

    navigateToForum(event) {
        const productName = event.target.value;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/groups?p=' + productName
            },
            reload: true
        });
    }

    navigateToFiles(event) {
        const productName = event.target.value;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/product-files?p=' + productName
            },
            reload: true
        });
    }
    navigateToSales(event) {
        const productName = event.target.value;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/custom-files?p=' + productName
            },
            reload: true
        });
    }

}