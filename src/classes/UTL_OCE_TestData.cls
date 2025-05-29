@IsTest
public with sharing class UTL_OCE_TestData {

    // Create Contact
    public static Contact createContact() {

        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Contact';
        contact.Email = 'test@email.com';
        contact.Phone = '+19195551212';
        return contact;
    }

    // Create Account
    public static Account createaccount() {

        Account account = UTL_TestData.createAccount();
        account.Name = CON_OCE.TEST_ACCOUNT_NAME;
        account.AccountCountry__c = 'US';
        account.CustomerSegment__c = 'GOVERNMENT';
        account.Sub_Industry__c = 'STATE';
        return account;
    }

    // Create Opportunity
    public static Opportunity createOpportunity(Id accountId) {

        Opportunity opportunity = UTL_TestData.createOpportunity(accountId);
        opportunity.Name = CON_OCE.TEST_OPPORTUNITY_NAME;
        return opportunity;
    }

    // Create Product
    public static Product2 createProduct(
        String productName,
        String productCode,
        String productLine,
        String productFamily) {

        Product2 product = UTL_TestData.createProduct();
        product.Name = productName;
        product.ProductCode = productCode;
        product.Unit_Name__c = productLine;
        product.Family = productFamily;
        product.IsActive = true;
        return product;
    }

    // Create Product/Service Line Item
    public static Apttus_Config2__LineItem__c createPrimaryConfigLineItem(
        Id configId,
        Integer lineNumber,
        Integer itemSequence,
        Id productId,
        Decimal quantity,
        Decimal price) {

        return createLineItem(configId, CON_OCE.PRODUCT_SERVICE, true, lineNumber, itemSequence, productId, null, quantity, price);
    }

    private static Apttus_Config2__LineItem__c createLineItem(
        Id configId,
        String lineType,
        Boolean isPrimary,
        Integer lineNumber,
        Integer itemSequence,
        Id productId,
        Id optionId,
        Decimal quantity,
        Decimal price) {

        Apttus_Config2__LineItem__c lineItem = new Apttus_Config2__LineItem__c();
        lineItem.Apttus_Config2__ConfigurationId__c = configId;
        lineItem.Apttus_Config2__LineNumber__c = lineNumber;
        lineItem.Apttus_Config2__PrimaryLineNumber__c = lineNumber;
        lineItem.Apttus_Config2__ItemSequence__c = itemSequence;
        lineItem.Apttus_Config2__LineType__c = lineType;
        lineItem.Apttus_Config2__IsPrimaryLine__c = isPrimary;
        lineItem.Apttus_Config2__ProductId__c = productId;
        lineItem.Apttus_Config2__OptionId__c = optionId;
        lineItem.Apttus_Config2__Quantity__c = quantity;
        lineItem.Apttus_Config2__NetPrice__c = price;
        return lineItem;
    }
}