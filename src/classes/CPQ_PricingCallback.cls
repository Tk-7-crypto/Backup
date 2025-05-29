/*
CHANGE HISTORY
===============================================================================
Created:        Sean McInturff
Date:           09/26/2018
Description:    PricingCallback class to supliment Apttus functionality in the cart.
Updated:        Gorantla Babu
Date:           08/25/2022    
===============================================================================
*/  
global with sharing class CPQ_PricingCallback implements Apttus_Config2.CustomClass.IPricingCallback3 {
    
    private Apttus_Config2.CustomClass.PricingMode mode = null;
    public Apttus_Config2.ProductConfiguration prodCart;
    public Map<String, CPQ_AMESA_Partial_Product_Pricings__c> productCodeMapingwithParticalCalculator = new Map<String, CPQ_AMESA_Partial_Product_Pricings__c>();
    public Map<String, Decimal> freqToDiscountedPriceFactor = new Map<String, Decimal>();
    public String pricingToolName;
    public UTL_PricingCallback.WPR_CPQ_PartialPricing pricingWrapper = new UTL_PricingCallback.WPR_CPQ_PartialPricing();
    public Map<String, String> isoCodeByCountryMap;
    String proposalCurrencyIsoCode;
    public Map<String, Currency_Exchange_Rates__c> isoCodeTocurrencyTypeMap;
    public Apttus_Proposal__Proposal__c proposal;
    public Boolean hasQuoteAccess;
    
    // *** START ***
    global void start(Apttus_Config2.ProductConfiguration cart) {
        prodCart = cart;
        if(UTL_PricingCallback.runStart) {
            pricingWrapper = UTL_PricingCallback.start(cart);
            UTL_PricingCallback.runStart = false;
        } else {
            pricingWrapper = UTL_PricingCallback.pricingWrapperGlobal;
        }
        proposal = pricingWrapper.proposal;
        pricingToolName = pricingWrapper.pricingToolName;
        hasQuoteAccess = pricingWrapper.hasQuoteAccess;
        if (pricingToolName != CON_CPQ.TS_JAPAN) {
            proposalCurrencyIsoCode = pricingWrapper.currencyIsoCode;
            isoCodeByCountryMap =  pricingWrapper.isoCodeByCountryMap;
            isoCodeTocurrencyTypeMap = pricingWrapper.isoCodeTocurrencyTypeMap;
            if (pricingToolName == CON_CPQ.AMESA) {
                productCodeMapingwithParticalCalculator = pricingWrapper.productCodeMapingwithParticalCalculator;
                freqToDiscountedPriceFactor = pricingWrapper.freqToDiscountedPriceFactor;
            }
        }
    }
    
    // *** SET MODE ***
    /*
    === === === === === === === === === === === === === === === === ===
    From Apttus:
    ADJUSTMENT: The mode of the call back when adjustments are made to the cart and you click Reprice.
    Mode is invoked for all items (including options) in the cart after applying adjustments to compute Net Price.
    ** ADJUSTMENT mode does not have all option items in Large Cart mode and hence it is preferable not to use this mode.
    ROLLOUT:    The mode of the callback when Apttus_Config2.CustomClass.PricingMode.BASEPRICE == mode)).
    Mode is invoked to apply the total or group level discounts at the line level.
    BASEPRICE:  The mode is base price when you click Go to Price.
    Mode is used primarily to set quantity, term and so on in the line item beforePricing() method. 
    Base price mode is called for each line number.
    === === === === === === === === === === === === === === === === ===
    */
    global void setMode(Apttus_Config2.CustomClass.PricingMode aMode) {
        this.mode = aMode;
    }

    // *** BEFORE PRICING ***
    /*
    === === === === === === === === === === === === === === === === ===
    From Apttus:
    Using this method, you can define the logic for net price calculation. 
    In beforePricing, no pricelist item is associated to the cart line items. 
    Price Matrix and Price Ruleset calculation occurs when the mode of the callback is Base Price Mode.
    Any modification to **custom fields** need to be done in the beforePricing method.
    === === === === === === === === === === === === === === === === ===
    */
    global void beforePricing(Apttus_Config2.ProductConfiguration.LineItemColl itemColl) {
        System.debug('***&&Inside BeforePricing ***********'+mode);
        if (pricingToolName != CON_CPQ.TS_JAPAN) {
            if (mode == Apttus_Config2.CustomClass.PricingMode.BASEPRICE) {     
                UTL_PricingCallback.beforePricing(itemColl, prodCart, productCodeMapingwithParticalCalculator, pricingToolName, proposalCurrencyIsoCode, isoCodeByCountryMap, isoCodeTocurrencyTypeMap, freqToDiscountedPriceFactor, proposal);
            }  else if (mode == Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT) {
                UTL_PricingCallback.beforePricingAdjustmentMode(itemColl, prodCart, productCodeMapingwithParticalCalculator, pricingToolName, proposalCurrencyIsoCode, isoCodeByCountryMap, isoCodeTocurrencyTypeMap, freqToDiscountedPriceFactor, proposal, true);
            }
        }
    }

    global void onPriceItemSet(Apttus_Config2__PriceListItem__c itemSO, Apttus_Config2.LineItem lineItemMO) {
    }

    global void beforePricingLineItem(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, Apttus_Config2.LineItem lineItemMO) {
    }

    /*
    === === === === === === === === === === === === === === === === ===
    From Apttus:
    In this method, define the logic to be executed after Net Price calculation, 
    that is after the system has already calculated Net Price when this method is invoked.
    === === === === === === === === === === === === === === === === ===
    */
    global void afterPricing(Apttus_Config2.ProductConfiguration.LineItemColl itemColl) {
        System.debug('***&&Inside AfterPricing ***********'+mode);
        if (pricingToolName != CON_CPQ.TS_JAPAN) {
		    if (mode == Apttus_Config2.CustomClass.PricingMode.BASEPRICE) {
                UTL_PricingCallback.afterPricingBaseMode(itemColl, prodCart, pricingToolName);
            } else if (mode == Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT) {
                UTL_PricingCallback.afterPricingAdjustmentMode(itemColl, prodCart, pricingToolName, proposalCurrencyIsoCode, isoCodeByCountryMap);
            }	
        }
    }

    global void afterPricingLineItem(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, Apttus_Config2.LineItem lineItemMO) {
    }

    global void finish() {
        if (pricingToolName != CON_CPQ.TS_JAPAN) {
            UTL_PricingCallback.updateConversionDateOnProposal(pricingWrapper.proposalId, pricingWrapper.conversionDate);
            if (hasQuoteAccess) {
                update new Quote__c(Id = pricingWrapper.proposal.IQVIA_Quote__c, Conversion_Date__c = pricingWrapper.conversionDate);
            }
        }
    }
}