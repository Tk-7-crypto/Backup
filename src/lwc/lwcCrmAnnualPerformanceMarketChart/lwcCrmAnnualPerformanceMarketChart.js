import { LightningElement } from 'lwc';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllData from '@salesforce/apex/CNT_CRM_AnnualPerformanceMarketChart.getAllData';
import getMetaData from '@salesforce/apex/CNT_CRM_AnnualPerformanceMarketChart.getMetaData';
import setMetaData from '@salesforce/apex/CNT_CRM_AnnualPerformanceMarketChart.setMetaData';

export default class LwcCrmAnnualPerformanceMarketChart extends LightningElement {
    isChartJsInitialized;
    config;
    chart;
    totalClosedAmount;
    goal;
    CurrencyIsoCode;
    optionStagesSelectedLabel= 'All';
    optionStagesSelectedValue = 'All';
    isEdit = false;
    showSpinner = false;

    connectedCallback() {
        getMetaData()
            .then(result => {
                if (result != undefined && result != null && result != '') {
                    this.goal = result.goal;
                    this.CurrencyIsoCode = result.CurrencyIsoCode;
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!',
                        message: JSON.stringify(error),
                        variant: 'error',
                    }),
                );
            });
    }

    renderedCallback() {
        if (this.isChartJsInitialized) {
            return;
        }
        this.isChartJsInitialized = true;
        Promise.all([
            loadScript(this, chartjs)
        ]).then((values) => {
            this.refreshChart();
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: JSON.stringify(error),
                    variant: 'error',
                }),
            );
        });
    }

    refreshChart() {
        getAllData({})
            .then(result => {
                this.totalClosedAmount = result.totalClosedAmount;
                this.config = {
                    type: 'line',
                    data: {
                        datasets: [
                            {
                                label: 'Goal',
                                data: result.goalOppdata,
                                borderColor: 'rgba(75, 202, 129, 1)',
                                backgroundColor: 'rgba(75, 202, 129, 1)',
                                fill: false,
                                pointHoverRadius: 0,
                                pointRadius: 0
                            },
                            {
                                label: 'Closed',
                                data: result.closeOppdata,
                                borderColor: 'rgba(83, 183, 216, 1)',
                                backgroundColor: 'rgba(237, 248,251, 1)',
                                fill: true,
                                pointHoverRadius: 5,
                                pointRadius: 0
                            }
                        ]
                    },
                    options: {
                        tooltips: {
                            intersect: false,
                            displayColors: false,
                            cornerRadius: 3,
                            backgroundColor: '#888888',
                            titleFontSize: 16,
                            titleFontColor: '#000000',
                            callbacks: {
                                title: function (tooltipItem, data) { return null },
                                labelTextColor: function (tooltipItem, chart) { return '#000000'; },
                                label: function (tooltipItem, data) {
                                    var date = new Date(tooltipItem.xLabel);
                                    var dd = date.getDate();
                                    var mm = date.getMonth() + 1;
                                    var yyyy = date.getFullYear();
                                    var label = mm + '/' + dd + '/' + yyyy + ' - ' + new Intl.NumberFormat().format(tooltipItem.yLabel);
                                    return label;
                                }
                            }
                        },
                        title: { 
                            display: true, 
                            text: 'Annual Performance (USD) by Expected Close Date', 
                            position: 'bottom',
                            titleFontColor: '#000000', 
                            displayColors: true,
                        },
                        elements: { line: { tension: 0 } },// prevent curved graph
                        scales: {
                            xAxes: [{ type: 'time', distribution: 'linear' }],
                            yAxes: [{
                                ticks: {
                                    beginAtZero: true,
                                    callback: function (value, index, values) {
                                        if (parseInt(value) < 1000){
                                            return value;
                                        }else if (parseInt(value) >= 1000 && parseInt(value) < 10000) {
                                            return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                                        } else if (parseInt(value) >= 10000 && parseInt(value) < 1000000) {
                                            return parseInt(value / 1000) + ' K'
                                        } else if (parseInt(value) >= 1000000 && parseInt(value) < 1000000000) {
                                            return parseInt(value / 1000000) + ' M';
                                        } else
                                            return parseInt(value / 1000000000) + ' B';
                                        }
                                    }
                                }]
                        },
                        legend: { position: 'bottom', padding: 10, onClick: null },//position of symbol
                        bezierCurve: false,
                        responsive: true
                    }
                };
                const ctx = this.template.querySelector('canvas.linechart').getContext('2d');
                this.chart = new window.Chart(ctx, this.config);
                this.chart.canvas.parentNode.style.height = '110%';
                this.chart.canvas.parentNode.style.width = '100%';
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!',
                        message: JSON.stringify(error),
                        variant: 'error',
                    }),
                );
            });

    }

    // Filter Cancel
    handleCancel(event) {
        this.isEdit = false;
    }

    // Filter Save
    handleSave(event) {
        this.showSpinner = true;
        var goal = parseFloat(this.template.querySelector('[data-id="Goal"]').value);

        if (goal == undefined || goal == null || goal == '' || isNaN(goal)) {
            goal = 0;
        }
        if (goal < 0 || !(Number.isInteger(goal))) {
            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: "Review the error on Goal.",
                    variant: 'error',
                }),
            );
        } else {
        setMetaData({ goal: goal})
            .then(result => {
                this.goal = goal;
                this.removeData();
                this.refreshChart();
                this.isEdit = false;
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
    }

    // Filter Changes
    enbleEdit(event) {
        this.isEdit = true;
    }

    removeData() {
        this.chart.data.labels = [];
        this.chart.data.datasets = [];
    }
}