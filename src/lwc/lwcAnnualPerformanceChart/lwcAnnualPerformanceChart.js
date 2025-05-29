import { LightningElement } from 'lwc';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllData from '@salesforce/apex/CNT_CRM_AnnualPerformanceChart.getAllData';
import getMetaData from '@salesforce/apex/CNT_CRM_AnnualPerformanceChart.getMetaData';
import setMetaData from '@salesforce/apex/CNT_CRM_AnnualPerformanceChart.setMetaData';

export default class LwcAnnualPerformanceChart extends LightningElement {
    isChartJsInitialized;
    config;
    chart;
    totalClosedAmount;
    goal;
    totalOpenAmount;
    CurrencyIsoCode;
    optionStagesSelectedLabel;
    optionStagesSelectedValue;
    OptionQuaterSelected;
    isEdit = false;
    showSpinner = false;

    connectedCallback() {
        getMetaData()
            .then(result => {
                if (result != undefined && result != null && result != '') {
                    this.goal = result.goal;
                    this.optionStagesSelectedValue = result.stages;
                    this.OptionQuaterSelected = result.quater;
                    this.CurrencyIsoCode = result.CurrencyIsoCode;
                    this.optionStagesSelectedLabel = result.label;
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
                this.totalOpenAmount = result.totalOpenAmount;
                this.optionStagesSelectedLabel;
                var stages = this.optionStagesSelectedLabel;

                //var chartGoalData = [{ t: YearStartDate, y: this.goal }, { t: YearEndDate, y: this.goal }];

                this.config = {
                    type: 'line',
                    data: {
                        //labels: ['Jan 2020', 'Feb 2020', 'Mar 2020', 'Apr 2020', 'May 2020', 'Jun 2020','Jul 2020','Aug 2020','Sep 2020','Oct 2020','Nov 2020','Des 2020'],
                        //labels: result.axislabel,
                        datasets: [
                            {
                                label: 'Closed',
                                data: result.closeOppdata,
                                borderColor: 'rgba(255, 183,93, 1)',
                                backgroundColor: 'rgba(255, 183,93, 1)',
                                fill: false,
                                pointHoverRadius: 0,
                                pointRadius: 0
                            },
                            {
                                label: 'GOAL',
                                data: result.goalOppdata,
                                borderColor: 'rgba(75, 202, 129, 1)',
                                backgroundColor: 'rgba(75, 202, 129, 1)',
                                fill: false,
                                pointHoverRadius: 0,
                                pointRadius: 0
                            },
                            {
                                label: 'Open (' + result.stageslabel +')',
                                data: result.openOppdata,
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
                        title: { display: false, text: 'Chart Title' },
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

    // filter Picklist
    get OptionQuater() {
        return [
            { label: 'All', value: 'All' },
            { label: 'Q1', value: 'Q1' },
            { label: 'Q2', value: 'Q2' },
            { label: 'Q3', value: 'Q3' },
            { label: 'Q4', value: 'Q4' }
        ];
    }

    get optionStages() {
        return [
            { label: '1', value: '1. Identifying Opportunity' },
            { label: '2', value: '2. Qualifying Opportunity' },
            { label: '3', value: '3. Developing Proposal' },
            { label: '4', value: '4. Delivering Proposal' },
            { label: '5', value: '5. Finalizing Deal' },
            { label: '6', value: '6. Received ATP/LOI' },
        ];
    }

    // Filter Cancel
    handleCancel(event) {
        this.isEdit = false;
    }

    // Filter Save
    handleSave(event) {
        this.showSpinner = true;
        var stagevalue = this.template.querySelector('[data-id="Stage"]').value;
        var Quartervalue = this.template.querySelector('[data-id="Quarter"]').value;
        var goal = parseFloat(this.template.querySelector('[data-id="Goal"]').value);
        var label = this.getLabel(JSON.stringify(stagevalue));
        if (label == undefined || label == null || label == '') {
            label = 'n/a';
        }
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
        setMetaData({ goal: goal, quater: Quartervalue, oppstageV: JSON.stringify(stagevalue), oppstagel: label })
            .then(result => {
                this.optionStagesSelectedValue = stagevalue;
                this.OptionQuaterSelected = Quartervalue;
                this.goal = goal;
                this.optionStagesSelectedLabel = label;

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

    getLabel(stagevalue) {
        var optionList = JSON.stringify(this.template.querySelector('[data-id="Stage"]').options);
        var stageLabel = '';
        JSON.parse(optionList).forEach(element => {
            if (stagevalue.includes(element.value)) {
                stageLabel = stageLabel + element.label + ', ';
            }
        });
        return stageLabel.substring(0, stageLabel.length - 2);
    }
}