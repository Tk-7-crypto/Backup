import { LightningElement, api, wire } from 'lwc';
import getCurrentQuarterData from '@salesforce/apex/CNT_CRM_QuarterPerformance.getCurrentQuarterData';
import { NavigationMixin } from 'lightning/navigation';

export default class LwcCrmQuarterPerformance extends NavigationMixin(LightningElement) {
    totalCommitAmount;
    totalCallAmount;
    totalBestAmount;
    reportName;
    error;
    errorMsg;
    showSpinner = true;

    connectedCallback() {
        this.refreshQuarterPerformanceChart();
    }

    refreshQuarterPerformanceChart() {
        getCurrentQuarterData({})
            .then(result => {
                this.totalCommitAmount = this.amountConversion(result.totalCommitAmount);
                this.totalCallAmount = this.amountConversion(result.totalCallAmount);
                this.totalBestAmount = this.amountConversion(result.totalBestAmount);
                this.showSpinner = false;
            })
            .catch(error => {
                this.error = true;
                var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
                this.errorMsg = err == "{}" ? 'Unexpected error !!!' : err;
                this.showSpinner = false;
            });;
    }

    amountConversion(value) {
        if (parseInt(value) < 1000) {
            return value;
        } else if (parseInt(value) >= 1000 && parseInt(value) < 10000) {
            return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        } else if (parseInt(value) >= 10000 && parseInt(value) < 1000000) {
            return parseInt(value / 1000) + ' K'
        } else if (parseInt(value) >= 1000000 && parseInt(value) < 1000000000) {
            return parseInt(value / 1000000) + ' M';
        } else {
            return parseInt(value / 1000000000) + ' B';
        }
    }

    navigateToReport(event) {
        this.reportName = event.target.name;
        this[NavigationMixin.GenerateUrl]({
            "type": "standard__component",
            "attributes": {
                "componentName": "c__LXC_CRM_QuarterPerformanceReport",
            },
            state: {
                c__ReportName: this.reportName,
            }
        }).then(generatedUrl => {
            window.open(generatedUrl);
        });
    }
}