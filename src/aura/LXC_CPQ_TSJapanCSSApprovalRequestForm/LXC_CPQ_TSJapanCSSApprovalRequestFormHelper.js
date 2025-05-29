({
    getProposalWithLineItems: function (component) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getProposalWithLineItems");
        action.setParams({
            "proposalId": recordId
        });
        action.setCallback(this, function (actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                var records = actionResult.getReturnValue();
                this.getCSSApprovers(component);
                component.set("v.proposalDetails", records);
                var subject = "CSS Approval Request - " + component.get("v.proposalDetails.proposalSObject.Opportunity_Number__c") + " "
                    + component.get("v.proposalDetails.proposalSObject.Apttus_Proposal__Opportunity__r.Name") + " "
                    + component.get("v.proposalDetails.proposalSObject.Name");
                component.set("v.subject", subject);
            }
        });
        $A.enqueueAction(action);
    },

    getCSSApprovers: function (component) {
        var self = this;
        var action = component.get("c.getCSSApprovers");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var options = [];
                options.push({
                    label: "Please Select CSS Approver",
                    value: ""
                });
                var cssApprovers = response.getReturnValue();
                if (cssApprovers != undefined && cssApprovers.length > 0) {
                    for (var index = 0; index < cssApprovers.length; index++) {
                        options.push({
                            label: cssApprovers[index].Name + ' (' + cssApprovers[index].Email__c + ')',
                            value: cssApprovers[index].Email__c
                        });
                    }
                    component.set("v.cssApprovers", options);
                    this.setMailBody(component)
                }
            } else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": response.getError()[0].message,
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    setMailBody: function (component) {
        var thresholdValue;
        var styleClass = '';
        var richTextContent = '<p><b>Proposal Details:</b></p>';
        richTextContent += '<table class="ql-table-blob" border="1" style="width: 700px;margin-top: 0.5rem">';
        richTextContent += '<tr>';
        richTextContent += '<th style="text-align:left;">&nbsp;Notes to Reviewer</td>';
        richTextContent += '<td></td>';
        richTextContent += '</tr>';

        richTextContent += '<tr>';
        richTextContent += '<th style="text-align:left;">&nbsp;Opportunity Number</td>';
        richTextContent += '<td>&nbsp;' + component.get("v.proposalDetails.proposalSObject.Opportunity_Number__c") + '</td>';
        richTextContent += '</tr>';

        richTextContent += '<tr>';
        richTextContent += '<th style="text-align:left;">&nbsp;Opportunity Name</td>';
        richTextContent += '<td>&nbsp;' + component.get("v.proposalDetails.proposalSObject.Apttus_Proposal__Opportunity__r.Name") + '</td>';
        richTextContent += '</tr>';

        richTextContent += '<tr>';
        richTextContent += '<th style="text-align:left;">&nbsp;Account Name</td>';
        richTextContent += '<td>&nbsp;' + component.get("v.proposalDetails.proposalSObject.Apttus_Proposal__Account__r.Name") + '</td>';
        richTextContent += '</tr>';
        richTextContent += '<tr>';
        richTextContent += '<th style="text-align:left;">&nbsp;Under Target GM</td>';

        // Set threshold class (red font) for Account Tier
        thresholdValue = false;
        var accountTier = component.get("v.proposalDetails.proposalSObject.Account_Tier_0_5__c");
        if (!accountTier) {
            accountTier = '';
        } else if (accountTier === 'Yes') {
            thresholdValue = true;
        }
        styleClass = this.setThresholdClass(thresholdValue);
        richTextContent += '<td ' + styleClass + '>&nbsp;' + accountTier + '</td>';
        richTextContent += '</tr>';

        richTextContent += '<tr>';
        richTextContent += '<th style="text-align:left;">&nbsp;Project Period</td>';

        var startDate = component.get("v.proposalDetails.proposalSObject.Apttus_Proposal__ExpectedStartDate__c");
        var endDate = component.get("v.proposalDetails.proposalSObject.Apttus_Proposal__ExpectedEndDate__c");

        richTextContent += '<td>&nbsp;' + this.setDateFormat(startDate) + ' - ' + this.setDateFormat(endDate) + '</td>';
        richTextContent += '</tr>';
        richTextContent += '<tr>';
        richTextContent += '<th style="text-align:left;">&nbsp;Quote Amount</td>';

        var quoteAmountInJPY = component.get("v.proposalDetails.quoteAmountInJPY");
        var quoteAmountInUSD = component.get("v.proposalDetails.quoteAmountInUSD");

        // Set threshold class (red font) for Quote Amount
        thresholdValue = false;
        if (quoteAmountInJPY > 100000000) {
            thresholdValue = true;
        }
        styleClass = this.setThresholdClass(thresholdValue);
        richTextContent += '<td ' + styleClass + '>&nbsp;JPY ' + this.setNumberFormat(quoteAmountInJPY) + ' (USD ' + this.setNumberFormat(quoteAmountInUSD) + ')</td>';
        richTextContent += '</tr>';

        richTextContent += '<tr>';
        var specialPricingComments = component.get("v.proposalDetails.proposalSObject.Special_Pricing_Explanation_Comments__c");
        if (!specialPricingComments) {
            specialPricingComments = '';
        }
        richTextContent += '<th style="text-align:left;">&nbsp;Special Pricing &nbsp;Explanation/Comments</td>';
        richTextContent += '<td>&nbsp;' + specialPricingComments + '</td>';
        richTextContent += '</tr>';
        richTextContent += '<tr>';
        richTextContent += '<th style="text-align:left;">&nbsp;Special Discount</td>';

        var specialDiscount = component.get("v.proposalDetails.proposalSObject.Special_Discount__c") ? 'Yes' : 'No';

        // Set threshold class (red font) for Special Discount
        thresholdValue = false;
        if (specialDiscount === 'Yes') {
            thresholdValue = true;
        }
        styleClass = this.setThresholdClass(thresholdValue);
        richTextContent += '<td ' + styleClass + '>&nbsp;' + specialDiscount + '</td>';
        richTextContent += '</tr>';

        richTextContent += '<tr>';
        richTextContent += '<th style="text-align:left;">&nbsp;Vendor Use</td>';

        var vendorUse = component.get("v.proposalDetails.proposalSObject.Vendor_Use__c") ? 'Yes' : 'No';
        richTextContent += '<td>&nbsp;' + vendorUse + '</td>';
        richTextContent += '</tr>';

        richTextContent += '<tr>';
        var vendorSelectionReason = component.get("v.proposalDetails.proposalSObject.Vendor_Selection_Reason__c");
        if (!vendorSelectionReason) {
            vendorSelectionReason = '';
        }
        richTextContent += '<th style="text-align:left;">&nbsp;Vendor Selection &nbsp;Reason/Comments</td>';
        richTextContent += '<td>&nbsp;' + vendorSelectionReason + '</td>';
        richTextContent += '</tr>';

        richTextContent += '<tr>';
        var vendorCompetitionDone = component.get("v.proposalDetails.proposalSObject.Vendor_Competition_Done__c");
        if (!vendorCompetitionDone) {
            vendorCompetitionDone = '';
        }
        richTextContent += '<th style="text-align:left;">&nbsp;Vendor Competition Done</td>';
        richTextContent += '<td>&nbsp;' + vendorCompetitionDone + '</td>';
        richTextContent += '</tr>';
        richTextContent += '</table>';

        richTextContent += '<p><br></p><b>Product Information:</b>';
        richTextContent += '<table class="ql-table-blob" border="1" style="width: 700px;margin-top: 0.5rem">';
        richTextContent += '<tr>';
        richTextContent += '<th style="text-align:center;">Product</td>';
        richTextContent += '<th style="text-align:center; width: 12rem; ">Amount</td>';
        richTextContent += '<th style="text-align:center; width: 8rem; ">Gross Margin %</td>';
        richTextContent += '<th style="text-align:center; width: 7rem; ">Pass Through</td>';
        richTextContent += '</tr>';

        var lineItems = component.get("v.proposalDetails.proposalLineItems");
        lineItems.forEach(function (lineItem) {
            richTextContent += '<tr>';
            richTextContent += '<td width="">&nbsp;' + lineItem.proposalLineItemSObject.Apttus_Proposal__Product__r.Name + '</td>';
            richTextContent += '<td style="text-align:center; ">JPY ' + $A.localizationService.formatNumber(lineItem.proposalLineItemSObject.Apttus_QPConfig__NetPrice__c) + ' (USD ' + $A.localizationService.formatNumber(lineItem.netPriceInUSD) + ')</td>';
            
            var grossMargin = lineItem.proposalLineItemSObject.Gross_Margin__c;
            var passThrough = lineItem.proposalLineItemSObject.Pass_Through__c ? 'Yes' : 'No';
            richTextContent += '<td ';
            thresholdValue = false;
            if (passThrough === 'No' && grossMargin < 20) {
                richTextContent += 'style="text-align:center; color:red"';
            } else {
                richTextContent += 'style="text-align:center;"';
            }
            richTextContent += '>' + grossMargin + '</td>';
            richTextContent += '<td style="text-align:center; ">' + passThrough + '</td>';
            richTextContent += '</tr>';
        });
        richTextContent += '</table>';
        component.set("v.richTextContent", richTextContent);
        component.set("v.showSpinner", false);
    },

    setThresholdClass: function (thresholdValue) {
        return thresholdValue ? 'style=" color:red"' : '';
    },

    setDateFormat: function (dateValue) {
        return $A.localizationService.formatDate(dateValue);
    },

    setNumberFormat: function (numberValue) {
        return $A.localizationService.formatNumber(numberValue);
    },

    showToast: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },

    submitCSSApprovalRequest: function (component, approvalDetailsJSON) {
        var action = component.get("c.submitForCSSApproval");
        action.setParams({
            'approvalDetailsJSON': approvalDetailsJSON
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showPopUp", false);
                component.set("v.showSpinner", false);
                var parentPopUp = component.get("v.parent");
                parentPopUp.set("v.isDisplayCSSForm", false);
                $A.get('e.force:refreshView').fire();
                this.showToast('', 'CSS approval request submitted successfully.', 'success');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        if (errors[0].message.includes('ALREADY_IN_PROCESS')) {
                            this.showToast('', 'Record is already submitted for CSS approval', 'error');
                        }
                        else
                            this.showToast('ERROR', errors[0].message, 'error');
                    }
                    component.set("v.showSpinner", false);
                }
            }
        });
        $A.enqueueAction(action);
    }
})