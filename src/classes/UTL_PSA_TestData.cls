/************************************************************************************************************************
   // Name         psaTestDataFactory
   // Description  Utility class for creating and caching test data for test class execution
   //              for FF packages (psa, scm, ffa)
   //
   // Revisions    2019-Aug-05  jerry@cldpartners.com       Initial version
   //
   //
************************************************************************************************************************/
@isTest
public without sharing class UTL_PSA_TestData
{

/************************************************************************************************************
   //
   // BIG NOTE: Methods with the testSetup and testMethod modifiers are run in separate execution contexts.
   // This means static variables initialized with testSetup are not available within testMethod. Calling
   // any of the properties in this class in both the testSetup and testMethod contexts causes them to
   // initialize both times. This factory class can still be used for generating test data within the
   // testSetup context, but testMethods must query for the records before using them.
   //
   // ==========================================================================================================
   //
   // The companion class psaTestDataFactoryTest exercises all of the properties and methods in this factory
   // class. The test class provides a simple way to ensure the test data factory still functions as expected,
   // and should be run regularly during implementation to catch and incorporate new object requirements and
   // validations that prevent successsful object creation here. The test class should be updated at the same
   // time new object create methods are added to this factory class so the same validation occurs when the
   // test class is fired.
   //
   // ==========================================================================================================
   //
   // There are a lot of overloaded methods in this class. This is intentional and designed to make the test
   // class writing process easier. However, this technique can make this file more difficult to read through
   // when looking for create methods for a specific object. Most IDEs support code-folding, which can make
   // reviewing the file much easier. In Sublime Text, press and hold the CMD key, then type K followed by 2.
   // This will collapse (fold) the code down to property and method names. You can expand any section
   // individually to review the property or method body.
   //
   // ==========================================================================================================
   //
   // Opportunity line items require a price book with price book entries. Use the following sequence to
   // initialize the opportunity line items ...
   //
   //          1. Create the product catalog by calling createProducts() one or more times
   //          2. Create entries in the standard price book by calling InitStandardPriceBook()
   //          3. Create specialized price books by calling InitPriceBook() one or more times
   //          4. Create the opportunity and add the appropriate pricebook to the opportunity
   //          5. Create the opportunity line items
   //
   // Alternatively, you can use the initSampleOpportunity() method to create a test opty with line items.
   //
 *************************************************************************************************************/

/************************************************************************************************************
   // Properties
 *************************************************************************************************************/

// Optional key value. Set this property if you are getting "uniqueness" errors in your test data. The methods
// in this factory class use this key value in any text string that is required to be unique. This property
// typically needs to be set only when calling a createObject() method more than once in the same execution
// context. Multiple records created in the same method call (by setting the cnt parameter > 1) incorporate
// an internal counter to provide uniqueness.

public static string key { get; set; }

static
{
	key = 'FF';
}


// Start date. Set this property to control which start date the default records use. This property
// defaults to the current system date if not otherwise specified by the calling code.

public static date startDate { get; set; }

static
{
	startDate = system.today();
}


// Duration in days. Set this property to control length of projects/assignments/etc. This property
// defaults to 100 days if not otherwise specified by the calling code.

public static integer duration { get; set; }

static
{
	duration = 100;
}


// Currency code. All test data is created with an explicit currency code to avoid issues that can arise
// when test code is run by users with different currencies. All methods in this class use this property
// to set the currency code of the records they create. The property defaults to USD, but can be set to
// a different value as needed, including between different createObject method calls to create test
// data with a mix of currencies.

public static string currencyCode { get; set; }

static
{
	currencyCode = 'USD';
}


// Internal signaling variables. These variables are generally used by the init methods to allow multiple
// calls within the same execution context without wiping out previously created data. These variables are
// not designed to be used outside of the TestDataactory class.

private static boolean assignmentsInitialized;
private static boolean priceBooksInitialized;
private static boolean priceBookEntriesByPriceBookInitialized;
private static boolean priceBookEntriesByProductInitialized;
private static boolean productsInitialized;
private static boolean schedulesByIdInitialized;
private static boolean standardPriceBookInitialized;
private static boolean timePeriodsByTypeInitialized;

static
{
	assignmentsInitialized = false;
	priceBooksInitialized = false;
	priceBookEntriesByPriceBookInitialized = false;
	priceBookEntriesByProductInitialized = false;
	productsInitialized = false;
	schedulesByIdInitialized = false;
	standardPriceBookInitialized = false;
	timePeriodsByTypeInitialized = false;
}


/************************************************************************************************************
   // The following section contains test data cache properties. If any of these properties are uninitialized
   // when called, the getter will create a default object list. Otherwise, the getter returns the previously
   // set value. The calling code may also use the setter to cache a custom object list to be used throughout
   // the test execution context. To initialize a property with the default values, set it to itself in the
   // calling code. For example:
   //
   //          psaTestDataFactory.accounts = psaTestDataFactory.accounts;
   //
   // You can also use one of the default initXXX() functions. For example:
   //
   //          psaTestDataFactory.accounts = psaTestDataFactory.initAccounts();
   //
   // Both options produce the same result - a propery initialized with a list of default objects instances.
   //
   // Note: Many of these properties reference other properties when creating their default object list.
   // Projects use accounts, resources, regions, practices, and groups. By initializing the last object
   // list in a reference chain (e.g. Project), you automatically initialize the related object lists (e.g.
   // accounts, resources, regions, practices, groups). This can help speed up test code development and
   // make test methods easier to read.
 *************************************************************************************************************/

public static list<Account> accounts
{
	get
	{
		if (accounts == null)
		{
			system.debug('psaTestDataFactory.accounts: creating default accounts');
			accounts = createAccounts(1);
		}
		return accounts;
	}
	set;
}

public static list<pse__Assignment__c> assignments
{
	get
	{
		if (assignments == null)
		{
			system.debug('psaTestDataFactory.assignments: creating default assignments');
			assignments = createAssignments();
		}
		return assignments;
	}
	set
	{
		assignments = value;
		assignmentsInitialized = value != null;
	}

}

public static list<pse__Budget__c> budgets
{
	get
	{
		if (budgets == null)
		{
			system.debug('psaTestDataFactory.budgets: creating default budgets');
			budgets = createBudgets(1);
		}
		return budgets;
	}
	set;
}

public static list<Contact> contacts
{
	get
	{
		if (contacts == null)
		{
			system.debug('psaTestDataFactory.contacts: creating default contacts');
			contacts = createContacts(1);
		}
		return contacts;
	}
	set;
}

public static list<pse__Grp__c> groups
{
	get
	{
		if (groups == null)
		{
			system.debug('psaTestDataFactory.groups: creating default groups');
			groups = createGroups(1);
		}
		return groups;
	}
	set;
}

public static list<Service_Line__c> serviceLines
{
	get
	{
		if (serviceLines == null)
		{
			system.debug('service line');
			serviceLines = createServiceLine(1);
		}
		return serviceLines;
	}
	set;
}

public static list<Service__c> services
{
	get
	{
		if (services == null)
		{
			system.debug('Creating service');
			services = createService(1);
		}
		return services;
	}
	set;
}

public static list<pse__Milestone__c> milestones
{
	get
	{
		if (milestones == null)
		{
			system.debug('psaTestDataFactory.milestones: creating default milestones');
			milestones = createMilestones(1);
		}
		return milestones;
	}
	set;
}

public static list<Opportunity> opportunities
{
	get
	{
		if (opportunities == null)
		{
			system.debug('psaTestDataFactory.opportunities: creating default opportunities');
			opportunities = createOpportunities(1);
		}
		return opportunities;
	}
	set;
}

public static map<id, list<OpportunityLineItem> > opportunityLineItemsByOpportunity
{
	get
	{
		if (opportunityLineItemsByOpportunity == null)
		{
			system.assert (false, 'No default OLI available. Use initSampleOpportunity() to create an opty with OLIs automatically.');
		}
		return opportunityLineItemsByOpportunity;
	}
	set;
}

//public static map<id, list<OpportunityTeamMember>> opportunityTeamMembersByOpportunity
//{
//    get
//    {
//        if (opportunityTeamMembersByOpportunity == null)
//        {
//            system.debug('psaTestDataFactory.opportunityTeamMembersByOpportunity: creating default opportunity team members');
//            opportunityTeamMembersByOpportunity = new map<id, list<OpportunityTeamMember>>();
//            opportunityTeamMembersByOpportunity.put(opportunities[0].Id, createOpportunityTeamMembers());
//        }
//        return opportunityTeamMembersByOpportunity;
//    }
//    set;
//}

public static list<pse__Permission_Control__c> permissionControls
{
	get
	{
		if (permissionControls == null)
		{
			system.debug('psaTestDataFactory.permissionControls: creating default permission controls');

			// Create a permission control for the current user
			permissionControls = createPermissionControls();
		}
		return permissionControls;
	}
	set;
}

public static list<pse__Practice__c> practices
{
	get
	{
		if (practices == null)
		{
			system.debug('psaTestDataFactory.practices: creating default practices');
			practices = createPractices(1);
		}
		return practices;
	}
	set;
}

public static list<Pricebook2> priceBooks
{
	get
	{
		if (priceBooks == null)
		{
			system.debug('psaTestDataFactory.priceBooks: creating default price books');
			priceBooks = createPriceBooks(1);
			priceBooksInitialized = true;
		}
		return priceBooks;
	}
	set
	{
		priceBooks = value;
		priceBooksInitialized = (value != null);
	}
}

public static map<id, list<PricebookEntry> > priceBookEntriesByPriceBook
{
	get
	{
		if (priceBookEntriesByPriceBook == null)
		{
			system.debug('psaTestDataFactory.priceBookEntriesByPriceBook: creating default price book entries');
			initStandardPricebook();
			// initPricebook(CON_PSA.TEST_DEFAULT_PIPELINE);
			initPricebook('pbook');
			priceBookEntriesByPriceBookInitialized = true;
		}
		return priceBookEntriesByPriceBook;
	}
	set
	{
		priceBookEntriesByPriceBook = value;
		priceBookEntriesByPriceBookInitialized = (value != null);
	}
}

public static map<id, list<PricebookEntry> > priceBookEntriesByProduct
{
	get
	{
		if (priceBookEntriesByProduct == null)
		{
			system.debug('psaTestDataFactory.priceBookEntriesByProduct: creating default price book entries');
			initStandardPricebook();
			// initPricebook(CON_PSA.TEST_DEFAULT_PIPELINE);
			initPricebook('pbook');
			priceBookEntriesByProductInitialized = true;
		}
		return priceBookEntriesByProduct;
	}
	set
	{
		priceBookEntriesByProduct = value;
		priceBookEntriesByProductInitialized = (value != null);
	}
}

public static list<Product2> products
{
	get
	{
		if (products == null)
		{
			system.debug('psaTestDataFactory.products: creating default products');
			products = createProducts(1);
			productsInitialized = true;
		}
		return products;
	}
	set
	{
		products = value;
		productsInitialized = (value != null);
	}
}

public static list<pse__Proj__c> projects
{
	get
	{
		if (projects == null)
		{
			system.debug('psaTestDataFactory.projects: creating default projects');
			projects = createProjects(1);
		}
		return projects;
	}
	set;
}

public static list<Program__c> programs
{
	get
	{
		if (programs == null)
		{
			system.debug('psaTestDataFactory.programs: creating default programs');
			programs = createPrograms(1);
		}
		return programs;
	}
	set;
}


public static list<pse__Region__c> regions
{
	get
	{
		if (regions == null)
		{
			system.debug('psaTestDataFactory.regions: creating default regions');
			regions = createRegions(1);
		}
		return regions;
	}
	set;
}

public static list<pse__Resource_Request__c> resourceRequests
{
	get
	{
		if (resourceRequests == null)
		{
			system.debug('psaTestDataFactory.resourceRequests: creating default resource requests');
			resourceRequests = createResourceRequests(1);
		}
		return resourceRequests;
	}
	set;
}

public static list<Contact> resources
{
	get
	{
		if (resources == null)
		{
			system.debug('psaTestDataFactory.resources: creating default resources');
			resources = createResources(2);
		}
		return resources;
	}
	set;
}

public static map<id, pse__Schedule__c> schedulesById
{
	get
	{
		if (schedulesById == null)
		{
			system.debug('psaTestDataFactory.schedulesById: getting schedules from assignments');

			set<id> schIdSet = new set<id>();

			for (pse__Assignment__c ass : assignments)
			{
				schIdSet.add(ass.pse__Schedule__c);
			}

			schedulesById = new map<id, pse__Schedule__c>([SELECT Id,
			                                               CurrencyIsoCode,
			                                               pse__Start_Date__c,
			                                               pse__End_Date__c,
			                                               pse__Monday_Hours__c,
			                                               pse__Tuesday_Hours__c,
			                                               pse__Wednesday_Hours__c,
			                                               pse__Thursday_Hours__c,
			                                               pse__Friday_Hours__c,
			                                               pse__Saturday_Hours__c,
			                                               pse__Sunday_Hours__c
			                                               FROM pse__Schedule__c
			                                               WHERE Id IN: schIdSet]);
			schedulesByIdInitialized = true;
		}
		return schedulesById;
	}
	set
	{
		schedulesById = value;
		schedulesByIdInitialized = value != null;
	}
}


public static map<string, list<pse__Time_Period__c> > timePeriodsByType
{
	get
	{
		if (timePeriodsByType == null)
		{
			system.debug('psaTestDataFactory.timePeriodsByType: creating default time periods');

			initTimePeriods(CON_PSA.TIME_PERIOD_TYPE_PERPETUAL, system.today(), 2);
			timePeriodsByTypeInitialized = true;
		}
		return timePeriodsByType;
	}
	set
	{
		timePeriodsByType = value;
		timePeriodsByTypeInitialized = value != null;
	}
}

/**
   sirius_users  (manager and managers manager)
 **/
public static list<User> users
{
	get
	{
		if (users == null)
		{
			system.debug('psaTestDataFactory.users: creating default users');

			//// Create 2 users where user 2 is user 1's manager
			//users = createUsers(2);
			//users[0].ManagerId = users[1].Id;
			//update users[0];

			// Create 3 users where user 2 is user 1's manager and user 3 is 2s manager...
			users = createUsers(3);
			users[0].ManagerId = users[1].Id;
			users[1].ManagerId = users[2].Id;
			update new User[] {users[0], users[1]};
		}
		return users;
	}
	set;
}


public static list<pse__Work_Calendar__c> workCalendars
{
	get
	{
		if (workCalendars == null)
		{
			system.debug('psaTestDataFactory.workCalendars: creating default work calendars');
			workCalendars = createWorkCalendars(1);
		}
		return workCalendars;
	}
	set;
}


/************************************************************************************************************
   // The following section contains methods for creating test instances of objects. Use these methods to
   // create test data in your test classes to ensure consistency and resiliency in object creation across the
   // test suite. Use the curencyCode, start, duration, and key properties to control certain attributes of
   // the data created. Methods with no parameters or only a count parameter will create default object
   // instance(s). Use the methods with longer parameter lists to provide more input on the data created. Set
   // the insertRecords flag to false to prevent insertion if you need to make additional tweaks to the data
   // before insert.
 *************************************************************************************************************/


/************************************************************************************************************
   // Name         createAccounts
   // Description  Returns a list of test accounts
 *************************************************************************************************************/
public static list<Account> createAccounts(integer cnt)
{
	return createAccounts(cnt, true);
}
public static list<Account> createAccounts(integer cnt, boolean insertRecords)
{
	list<Account> acctList = new list<Account>();

	for (integer i=1; i<=cnt; i++)
	{
		Account acct = new Account();
		acct.CurrencyIsoCode = currencyCode;
		acct.Name = 'Test Account ' + i + ' ' + key;
		acct.AccountCountry__c = 'US';
		acct.BillingStreet = '1420 5th Ave #2200 ' + i + ' ' + key;
		acct.BillingCity = 'Seattle';
		acct.BillingState = 'Washington';
		acct.BillingPostalCode = '98101';
		acct.BillingCountry = 'United States';
		acct.CustomerSegment__c = 'GOVERNMENT';
		acct.Sub_Industry__c = 'STATE';


		acctList.add(acct);
	}

	if (insertRecords == true) { insert acctList; }
	return acctList;
}

/************************************************************************************************************
   // Name         createAssignments
   // Description  Returns a list of test assignments on the specified project, one per resource
 *************************************************************************************************************/
public static list<pse__Assignment__c> createAssignments()
{
	return createAssignments(true);
}
public static list<pse__Assignment__c> createAssignments(boolean insertRecords)
{
	return createAssignments(resources, projects[0], insertRecords);
}
public static list<pse__Assignment__c> createAssignments(list<Contact> resList, pse__Proj__c proj)
{
	return createAssignments(resList, proj, true);
}
public static list<pse__Assignment__c> createAssignments(list<Contact> resList, pse__Proj__c proj, boolean insertRecords)
{
	// Need schedules first
	list<pse__Schedule__c> schList = new list<pse__Schedule__c>();

	for (integer i=0; i<resList.size(); i++)
	{
		pse__Schedule__c sch = new pse__Schedule__c();
		sch.pse__Start_Date__c = proj.pse__Start_Date__c;
		sch.pse__End_Date__c = proj.pse__End_Date__c;
		sch.pse__Monday_Hours__c = 8;
		sch.pse__Tuesday_Hours__c = 8;
		sch.pse__Wednesday_Hours__c = 8;
		sch.pse__Thursday_Hours__c = 8;
		sch.pse__Friday_Hours__c = 8;
		sch.pse__Saturday_Hours__c = 0;
		sch.pse__Sunday_Hours__c = 0;
		schList.add(sch);
	}

	// Always insert the schedules
	insert schList;

	// Stash them away in the schedulesById property
	if (schedulesByIdInitialized == false)
	{
		schedulesById = new map<id, pse__Schedule__c>();

		for (pse__Schedule__c sch : schList)
		{
			schedulesById.put(sch.Id, sch);
		}

		schedulesByIdInitialized = true;
	}

	// Now create the assignments
	list<pse__Assignment__c> assList = new list<pse__Assignment__c>();
	Id rdsrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);

	for (integer i=0; i<resList.size(); i++)
	{
		pse__Assignment__c ass = new pse__Assignment__c();
		ass.pse__Is_Billable__c = proj.pse__Is_Billable__c;
		ass.pse__Bill_Rate__c = (ass.pse__Is_Billable__c && proj.pse__Billing_Type__c == CON_PSA.PROJ_BILL_TYPE_FIXED) ? 200 : 0;
		ass.pse__Planned_Hours__c = 100;
		ass.pse__Project__c = proj.Id;
		ass.pse__Resource__c = resList[i].Id;
		ass.pse__Role__c = CON_PSA.RESOURCE_ROLE_LINE_MANAGER;
		ass.pse__Schedule__c = schList[i].Id;
		ass.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_SCHEDULED;
		ass.pse__Time_Credited__c = proj.pse__Time_Credited__c;
		ass.pse__Time_Excluded__c = proj.pse__Time_Excluded__c;
		ass.RecordTypeId = rdsrecTypeId;

/**
   sirius specific ??
   ass.Budget__c = budgets[0].id;
 **/



		assList.add(ass);
	}

	if (insertRecords == true) { insert assList; }
	return assList;
}


/************************************************************************************************************
   // Name         createBudgets
   // Description  Returns a list of test budgets
 *************************************************************************************************************/
public static list<pse__Budget__c> createBudgets(integer cnt)
{
	return createBudgets(cnt, true);
}
public static list<pse__Budget__c> createBudgets(integer cnt, boolean insertRecords)
{
	return createBudgets(cnt, projects[0], insertRecords);
}
public static list<pse__Budget__c> createBudgets(integer cnt, pse__Proj__c proj)
{
	return createBudgets(cnt, proj, true);
}
public static list<pse__Budget__c> createBudgets(integer cnt, pse__Proj__c proj, boolean insertRecords)
{
	list<pse__Budget__c> bgtList = new list<pse__Budget__c>();

	for (integer i=1; i<=cnt; i++)
	{
		pse__Budget__c bgt = new pse__Budget__c();
		bgt.CurrencyIsoCode = currencyCode;
		bgt.Name = 'Test Budget ' + i + ' ' + key;
		bgt.pse__Project__c = proj.Id;
		bgt.pse__Account__c = proj.pse__Account__c;
		bgt.pse__Opportunity__c = proj.pse__Opportunity__c;
		bgt.pse__Amount__c = 100000.0;
		bgt.pse__Expense_Amount__c = 10000.0;
		bgt.pse__Description__c = 'Test Budget';
		bgt.pse__Effective_Date__c = proj.pse__Start_Date__c;
		bgt.pse__Type__c = CON_PSA.BUDGET_TYPE_FIXED;
		bgt.pse__Status__c = CON_PSA.BUDGET_STATUS_DRAFT;


		bgtList.add(bgt);
	}

	if (insertRecords == true) { insert bgtList; }
	return bgtList;
}


/************************************************************************************************************
   // Name         createContacts
   // Description  Returns a list of test contacts
 *************************************************************************************************************/
public static list<Contact> createContacts(integer cnt)
{
	return createContacts(cnt, true);
}
public static list<Contact> createContacts(integer cnt, boolean insertRecords)
{
	return createContacts(cnt, accounts[0], insertRecords);
}
public static list<Contact> createContacts(integer cnt, Account acct)
{
	return createContacts(cnt, acct, true);
}
public static list<Contact> createContacts(integer cnt, Account acct, boolean insertRecords)
{
	list<Contact> conList = new list<Contact>();
//        id recTypeId = [SELECT Id FROM RecordType WHERE Name = 'PSA Resource' AND SobjectType = 'Contact'][0].Id;

	for (integer i=1; i<=cnt; i++)
	{
		Contact c = new Contact();
		c.CurrencyIsoCode = currencyCode;
//            c.RecordTypeId = recTypeId;
		c.FirstName = 'Test';
		c.LastName = 'Contact ' + i + ' ' + key;
		c.Email = 'testcontact' + i + key + '@example.org';
		c.AccountId = acct.Id;
		c.EmployeeNumber__c = '0000';
		conList.add(c);
	}

	if (insertRecords == true) { insert conList; }
	return conList;
}


/************************************************************************************************************
   // Name         createGroups
   // Description  Returns a list of test PSA groups
 *************************************************************************************************************/
public static list<pse__Grp__c> createGroups(integer cnt)
{
	return createGroups(1, true);
}
public static list<pse__Grp__c> createGroups(integer cnt, boolean insertRecords)
{
	return createGroups(cnt, null, insertRecords);
}
public static list<pse__Grp__c> createGroups(integer cnt, pse__Grp__c parentGrp)
{
	return createGroups(cnt, parentGrp, true);
}
public static list<pse__Grp__c> createGroups(integer cnt, pse__Grp__c parentGrp, boolean insertRecords)
{
	list<pse__Grp__c> grpList = new list<pse__Grp__c>();

	for (integer i=1; i<=cnt; i++)
	{
		pse__Grp__c g = new pse__Grp__c();
		g.CurrencyIsoCode = currencyCode;
		g.Name = 'Test Region ' + i + ' ' + key;
		g.pse__Parent_Group__c = parentGrp != null ? parentGrp.Id : null;
		grpList.add(g);
	}

	if (insertRecords == true) { insert grpList; }
	return grpList;
}

/************************************************************************************************************
   // Name         createServiceLine
   // Description  Returns a list of test service line
 *************************************************************************************************************/
/*public static list<Service_Line__c> createServiceLine(integer cnt)
{
	return createServiceLine(cnt, true);
}
public static list<Service_Line__c> createServiceLine(integer cnt, boolean insertRecords)
{
	return createServiceLine(cnt, projects[0], insertRecords);

}
public static list<Service_Line__c> createServiceLine(integer cnt, pse__Proj__c proj)
{
	return createServiceLine(cnt, proj, true);
}
public static list<Service_Line__c> createServiceLine(integer cnt, pse__Proj__c proj, boolean insertRecords)
{
	list<Service_Line__c> slList = new list<Service_Line__c>();
	//id recTypeId = [SELECT Id FROM RecordType WHERE Name = :CON_PSA.MILESTONE_REC_TYPE_SERVICE AND SobjectType = 'pse__Milestone__c'][0].Id;
	for (integer i=1; i<=cnt; i++)
	{
		Service_Line__c serviceline = new Service_Line__c();
		serviceline.Name = 'Test Service Line ' + i + ' ' + key;
		serviceline.Service_Line_Code__c = 'pv';
		serviceline.Active__c = true;
		slList.add(serviceline);
	}


	if (insertRecords == true) { insert slList; }
	return slList;
}*/
////////

public static list<Service_Line__c> createServiceLine(integer cnt)
{
	return createServiceLine(cnt, true);
}
public static list<Service_Line__c> createServiceLine(integer cnt, boolean insertRecords)
{
	list<Service_Line__c> slList = new list<Service_Line__c>();

	for (integer i=1; i<=cnt; i++)
	{
		Service_Line__c serviceline = new Service_Line__c();
		serviceline.Name = 'Test Service Line ' + i + ' ' + key;
		serviceline.Service_Line_Code__c = 'pv' +i + '' + key;
		serviceline.Active__c = true;

		slList.add(serviceline);
	}

	if (insertRecords == true) { insert slList; }
	return slList;
}


/************************************************************************************************************
   // Name         createService
   // Description  Returns a list of test service
 *************************************************************************************************************/
public static list<Service__c> createService(integer cnt)
{
	return createService(cnt, true);
}
public static list<Service__c> createService(integer cnt, boolean insertRecords)
{
	return createService(cnt, serviceLines[0], insertRecords);
	//return createService(cnt, insertRecords);
}
public static list<Service__c> createService(integer cnt, Service_Line__c serviceline)
{
	return createService(cnt, serviceline, true);
}
public static list<Service__c> createService(integer cnt, Service_Line__c serviceline, boolean insertRecords)

{
	list<Service__c> serviceList = new list<Service__c>();
	//id recTypeId = [SELECT Id FROM RecordType WHERE Name = :CON_PSA.MILESTONE_REC_TYPE_SERVICE AND SobjectType = 'pse__Milestone__c'][0].Id;
	for (integer i=1; i<=cnt; i++)
	{
		Service__c service = new Service__c();
		service.Name = 'Test Service ' + i + ' ' + key;
		service.Service_Line__c = serviceline.id;
		service.Service_Code__c = 'sc' + i + key;
		service.Active__c = true;
		serviceList.add(service);
	}

	if (insertRecords == true) { insert serviceList; }
	return serviceList;
}
/*
public static list<Service__c> createService(integer cnt)
{
	return createService(cnt, true);
}
public static list<Service__c> createService(integer cnt, boolean insertRecords)
{
	list<Service__c> serviceList = new list<Service__c>();

	for (integer i=1; i<=cnt; i++)
	{
		Service__c service = new Service__c();
		service.Name = 'Test Service ' + i + ' ' + key;
		service.Service_Line__c = serviceline.id;
		service.Service_Code__c = 'code' + i + ' ' + key;
		service.Active__c = true;

		serviceList.add(service);
	}

	if (insertRecords == true) { insert serviceList; }
	return serviceList;

}*/
/************************************************************************************************************
   // Name         createMilestones
   // Description  Returns a list of test hybrid milestones
 *************************************************************************************************************/
public static list<pse__Milestone__c> createMilestones(integer cnt)
{
	return createMilestones(cnt, true);
}
public static list<pse__Milestone__c> createMilestones(integer cnt, boolean insertRecords)
{
	return createMilestones(cnt, projects[0], serviceLines[0], services[0], insertRecords);
}
public static list<pse__Milestone__c> createMilestones(integer cnt, pse__Proj__c proj, Service_Line__c serviceline, Service__c service)
{
	return createMilestones(cnt, proj, serviceline, service, true);
}

public static list<pse__Milestone__c> createMilestones(integer cnt, pse__Proj__c proj, Service_Line__c serviceline, Service__c service, boolean insertRecords)
{
	list<pse__Milestone__c> msList = new list<pse__Milestone__c>();
	//id recTypeId = [SELECT Id FROM RecordType WHERE Name = :CON_PSA.MILESTONE_REC_TYPE_SERVICE AND SobjectType = 'pse__Milestone__c'][0].Id;

	/*service line
	//static Service_Line__c serviceLine;
	Service_Line__c serviceLine = new Service_Line__c (
		Active__c = true,
		Service_Line_Code__c = 'code',
		Name = 'code'
		);
	insert serviceLine;

	// service
	//static Service__c service;
	Service__c service = new Service__c(
		Active__c = true,
		Service_Line__c = serviceLine.id,
		Service_Code__c = 'code'
		);
	insert service;*/

	for (integer i=1; i<=cnt; i++)
	{

		pse__Milestone__c ms = new pse__Milestone__c();
		ms.CurrencyIsoCode = currencyCode;
		ms.Name = 'Test Milestone ' + i + ' ' + key;
		// ms.RecordTypeId = recTypeId;
		ms.pse__Milestone_Amount__c = 1000.0;
		ms.pse__Milestone_Cost__c = 500.0;
		ms.pse__Project__c = proj.Id;
		ms.pse__Status__c = CON_PSA.MILESTONE_STATUS_PLANNED;
		ms.pse__Target_Date__c = proj.pse__End_Date__c;
		ms.Start_Date__c = system.today();
		ms.End_Date__c =  ms.Start_Date__c.addDays(30);
		ms.Service_Line__c = serviceLine.id;
		ms.Service__c = service.id;
		msList.add(ms);
	}

	if (insertRecords == true) { insert msList; }
	return msList;
}


/************************************************************************************************************
   // Name         createOpportunities
   // Description  Returns a list of test opportunities
 *************************************************************************************************************/
public static list<Opportunity> createOpportunities(integer cnt)
{
	return createOpportunities(cnt, true);
}
public static list<Opportunity> createOpportunities(integer cnt, boolean insertRecords)
{
	return createOpportunities(cnt, accounts[0], regions[0], practices[0], groups[0], insertRecords);
}
public static list<Opportunity> createOpportunities(integer cnt, Account acct, pse__Region__c rgn, pse__Practice__c prac,
                                                    pse__Grp__c grp)
{
	return createOpportunities(cnt, acct, rgn, prac, grp, true);
}
public static list<Opportunity> createOpportunities(integer cnt, Account acct, pse__Region__c rgn, pse__Practice__c prac,
                                                    pse__Grp__c grp, boolean insertRecords)
{
	list<Opportunity> optyList = new list<Opportunity>();

	for (integer i=1; i<=cnt; i++)
	{
		Opportunity o = new Opportunity();
		o.CurrencyIsoCode = currencyCode;
		o.Name = 'Test Opportunity ' + i + ' ' + key;
		o.AccountId = acct != null ? acct.Id : null;
		o.StageName = CON_PSA.OPPORTUNITY_STAGE_QUALIFYING;
		o.CloseDate = startDate.addDays(30);
		o.pse__Region__c = rgn != null ? rgn.Id : null;
		o.pse__Practice__c = prac != null ? prac.Id : null;
		o.pse__Group__c = grp != null ? grp.Id : null;
		optyList.add(o);
	}

	if (insertRecords == true) { insert optyList; }
	return optyList;

}


/************************************************************************************************************
   // Name         createOpportunityLineItems
   // Description  Returns a list of test opportunities
   // Notes        1. The product catalog must be initialized before calling these methods.
   //              2. CurrencyIsoCode is not set in this method because OLI is master-detail to opportunity.
   //              3. There are no default OLI records created in the getter for this property. Use
   //                 initSampleOpportunity() to create an opty with a default set of OLIs.
 *************************************************************************************************************/
public static list<OpportunityLineItem> createOpportunityLineItems(integer cnt, Opportunity opty, PricebookEntry pbe)
{
	return createOpportunityLineItems(cnt, opty, pbe, true);
}
public static list<OpportunityLineItem> createOpportunityLineItems(integer cnt, Opportunity opty, PricebookEntry pbe, boolean insertRecords)
{
	list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();

	for (integer i=1; i<=cnt; i++)
	{
		OpportunityLineItem o = new OpportunityLineItem();
		o.OpportunityId = opty.Id;
		o.PricebookEntryId = pbe.Id;
		o.Quantity = 400;
		o.UnitPrice = 300;
		o.Delivery_Country__c = 'USA';
		o.Description = 'Test opty line item ' + i;
		o.pse__IsServicesProductLine__c = true;
		o.pse__Added_To_Project__c = false;
//            o.No_of_Resources__c = 1;
//            o.No_of_Weeks__c = 10;
//            o.Hrs_Week__c = 40;
//            o.Book_Rate__c = 300;
//            o.Negotiated_Rate__c = 200;
//           o.Cost__c = 75;
		oliList.add(o);
	}

	if (insertRecords == true) { insert oliList; }
	return oliList;
}


/************************************************************************************************************
   // Name         createOpportunities
   // Description  Returns a list of test opportunities
 *************************************************************************************************************/
//public static list<OpportunityTeamMember> createOpportunityTeamMembers()
//{
//    return createOpportunityTeamMembers(true);
//}
//public static list<OpportunityTeamMember> createOpportunityTeamMembers(boolean insertRecords)
//{
//    return createOpportunityTeamMembers(users, opportunities[0], CON_PSA.TEST_DEFAULT_OPTY_TEAM_ROLE, insertRecords);
//}
//public static list<OpportunityTeamMember> createOpportunityTeamMembers(list<User> userList, Opportunity opty, string role)
//{
//    return createOpportunityTeamMembers(userList, opty, role, true);
//}
//public static list<OpportunityTeamMember> createOpportunityTeamMembers(list<User> userList, Opportunity opty, string role, boolean insertRecords)
//{
//    list<OpportunityTeamMember> otmList = new list<OpportunityTeamMember>();

//    for (User u : userList)
//    {
//        OpportunityTeamMember otm = new OpportunityTeamMember();
//        otm.OpportunityId = opty.Id;
//        otm.UserId = u.Id;
//        otm.TeamMemberRole = role;
//        otmList.add(otm);
//    }

//    if (insertRecords == true) { insert otmList; }
//    return otmList;
//}


/************************************************************************************************************
   // Name         createPermissionControls
   // Description  Returns a list of 'global' permission controls for the specified users
 *************************************************************************************************************/
public static list<pse__Permission_Control__c> createPermissionControls()
{
	return createPermissionControls(true);
}
public static list<pse__Permission_Control__c> createPermissionControls(boolean insertRecords)
{
	// Create a permission control for the current user
	list<id> userIdList = new list<id>();
	userIdList.add(UserInfo.getUserId());
	return createPermissionControls(userIdList, insertRecords);
}
public static list<pse__Permission_Control__c> createPermissionControls(list<id> userIdList)
{
	return createPermissionControls(userIdList, true);
}
public static list<pse__Permission_Control__c> createPermissionControls(list<id> userIdList, boolean insertRecords)
{
	return createPermissionControls(userIdList, regions[0], insertRecords);
}
public static list<pse__Permission_Control__c> createPermissionControls(list<id> userIdList, pse__Region__c rgn)
{
	return createPermissionControls(userIdList, rgn, true);
}
public static list<pse__Permission_Control__c> createPermissionControls(list<id> userIdList, pse__Region__c rgn, boolean insertRecords)
{
	list<pse__Permission_Control__c> pcList = new list<pse__Permission_Control__c>();

	for (id userId : userIdList)
	{
		pse__Permission_Control__c pc = new pse__Permission_Control__c();
		pc.CurrencyIsoCode = currencyCode;
		pc.pse__User__c = userId;
		pc.pse__Region__c = rgn.Id;
		pc.pse__Cascading_Permission__c = true;
		pc.Unit_Entry_Ops_Edit__c = true;
		pc.pse__Billing__c = true;
		pc.pse__Expense_Entry__c = true;
		pc.pse__Expense_Ops_Edit__c = true;
		pc.pse__Forecast_Edit__c = true;
		pc.pse__Forecast_View__c = true;
		pc.pse__Invoicing__c = true;
		pc.pse__Edit_Task_Manager__c = true;
		pc.pse__View_Task_Manager__c = true;
		pc.pse__Resource_Request_Entry__c = true;
		pc.pse__Skills_And_Certifications_Entry__c = true;
		pc.pse__Skills_And_Certifications_View__c = true;
		pc.pse__Staffing__c = true;
		pc.pse__Timecard_Entry__c = true;
		pc.pse__Timecard_Ops_Edit__c = true;
		pc.Unit_Entry_Ops_Edit__c = true;
		pcList.add(pc);
	}

	if (insertRecords == true) { insert pcList; }
	return pcList;
}


/************************************************************************************************************
   // Name         createPractices
   // Description  Returns a list of test PSA practices
 *************************************************************************************************************/
public static list<pse__Practice__c> createPractices(integer cnt)
{
	return createPractices(cnt, true);
}
public static list<pse__Practice__c> createPractices(integer cnt, boolean insertRecords)
{
	return createPractices(cnt, null, insertRecords);
}
public static list<pse__Practice__c> createPractices(integer cnt, pse__Practice__c parentPrac)
{
	return createPractices(cnt, parentPrac, true);
}
public static list<pse__Practice__c> createPractices(integer cnt, pse__Practice__c parentPrac, boolean insertRecords)
{
	list<pse__Practice__c> pracList = new list<pse__Practice__c>();

	for (integer i=1; i<=cnt; i++)
	{
		pse__Practice__c p = new pse__Practice__c();
		p.CurrencyIsoCode = currencyCode;
		p.Name = 'Test Practice ' + i + ' ' + key;
		p.pse__Parent_Practice__c = parentPrac != null ? parentPrac.Id : null;
		pracList.add(p);
	}

	if (insertRecords == true) { insert pracList; }
	return pracList;
}


/************************************************************************************************************
   // Name         createPriceBooks
   // Description  Returns a list of test pricebooks
 *************************************************************************************************************/
public static list<Pricebook2> createPriceBooks(integer cnt)
{
	return createPriceBooks(cnt, true);
}
public static list<Pricebook2> createPriceBooks(integer cnt, boolean insertRecords)
{
	//return createPriceBooks(cnt, CON_PSA.TEST_DEFAULT_PIPELINE, insertRecords);
	return createPriceBooks(cnt, 'pbook', insertRecords);
}
public static list<Pricebook2> createPriceBooks(integer cnt, string pipeline)
{
	return createPriceBooks(cnt, pipeline, true);
}
public static list<Pricebook2> createPriceBooks(integer cnt, string pipeline, boolean insertRecords)
{
	list<Pricebook2> pbList = new list<Pricebook2>();

	for (integer i=1; i<=cnt; i++)
	{
		Pricebook2 pb = new Pricebook2();
		pb.CurrencyIsoCode = currencyCode;
		pb.Name = 'Test Price Book ' + i + ' ' + key;
		pb.Description = 'Test price book for ' + pipeline;
		pbList.add(pb);
	}

	if (insertRecords == true) { insert pbList; }
	return pbList;
}


/************************************************************************************************************
   // Name         createProducts
   // Description  Returns a list of test products
 *************************************************************************************************************/
public static list<Product2> createProducts(integer cnt)
{
	return createProducts(cnt, true);
}
public static list<Product2> createProducts(integer cnt, boolean insertRecords)
{
	//return createProducts(cnt, CON_PSA.TEST_DEFAULT_PRODUCT_FAMILY, insertRecords);
	return createProducts(cnt, 'DEFAULT-PRODUC-FAMILY?', insertRecords);
}
public static list<Product2> createProducts(integer cnt, string family)
{
	return createProducts(cnt, family, true);
}
public static list<Product2> createProducts(integer cnt, string family, boolean insertRecords)
{
	list<Product2> pList = new list<Product2>();

	for (integer i=1; i<=cnt; i++)
	{
		Product2 p = new Product2();
		p.CurrencyIsoCode = currencyCode;
		p.Name = 'Test Product ' + i + ' ' + key;
		p.Family = family;
		p.ProductCode = 'product_code_' + i + '_' + key;
		p.Description = 'Test ' + p.Family + ' product';
		p.IsActive = true;
		p.pse__IsServicesProduct__c = true;
		pList.add(p);
	}

	if (insertRecords == true) { insert pList; }
	return pList;
}


/************************************************************************************************************
   // Name         createProjects
   // Description  Returns a list of test projects
   // Notes        The paremeters acct, opty, rgn, prac, grp, and projMgr are optional for this method, but may
   //              be required by the specific functional implementation or test logic.
 *************************************************************************************************************/
public static list<pse__Proj__c> createProjects(integer cnt)
{
	return createProjects(cnt, true);
}
public static list<pse__Proj__c> createProjects(integer cnt, boolean insertRecords)
{
	return createProjects(cnt, accounts[0], null, regions[0], practices[0], groups[0], resources[0], insertRecords);
}
public static list<pse__Proj__c> createProjects(integer cnt, Account acct, Opportunity opty, pse__Region__c rgn,
                                                pse__Practice__c prac, pse__Grp__c grp, Contact projMgr)
{
	return createProjects(cnt, acct, opty, rgn, prac, grp, projMgr, true);
}
public static list<pse__Proj__c> createProjects(integer cnt, Account acct, Opportunity opty, pse__Region__c rgn,
                                                pse__Practice__c prac, pse__Grp__c grp, Contact projMgr,
                                                boolean insertRecords)
{
	list<pse__Proj__c> projList = new list<pse__Proj__c>();

	//To avoid validation errors, default project must have a recordtype
	Id rdsrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);

	for (integer i=1; i<=cnt; i++)
	{
		pse__Proj__c p = new pse__Proj__c();
		p.CurrencyIsoCode = currencyCode;
		p.Name = 'Test Project ' + i + ' ' + key;
		p.pse__Account__c = acct != null ? acct.Id : null;
		p.pse__Opportunity__c = opty != null ? opty.Id : null;
		p.pse__Opportunity_Owner__c = opty != null ? opty.OwnerId : UserInfo.getUserId();
		p.pse__Region__c = rgn != null ? rgn.Id : null;
		p.pse__Practice__c = prac != null ? prac.Id : null;
		p.pse__Group__c = grp != null ? grp.Id : null;
		p.pse__Project_Manager__c = projMgr != null ? projMgr.Id : null;
		p.pse__Start_Date__c = startDate;
		p.pse__End_Date__c = p.pse__Start_Date__c.addDays(duration);
		p.pse__Is_Active__c = true;
		p.pse__Is_Billable__c = true;
		p.pse__Daily_Timecard_Notes_Required__c = false;
		p.pse__Allow_Timecards_Without_Assignment__c = true;
		p.pse__Allow_Expenses_Without_Assignment__c = true;
		p.pse__Project_Type__c = CON_PSA.PROJ_TYPE_CUSTOMER;
		p.pse__Billing_Type__c = CON_PSA.PROJ_BILL_TYPE_FIXED;
		p.pse__Stage__c = CON_PSA.PROJ_STAGE_CONDUCT;
		p.recordTypeId = rdsrecTypeId;
        p.Setting__c = 'CT';
        p.Safety_Database_Location__c = 'Client';
        p.CT_Database_Location__c = 'IQVIA';
        p.Go_Live_Date__c = System.today();
        // p.Time_Approval_Method__c = CON_PSA.TEST_DEFAULT_PROJ_TIME_APPROVAL_METHOD;
        // p.Expense_Approval_Method__c = CON_PSA.TEST_DEFAULT_PROJ_EXP_APPROVAL_METHOD;
//            p.Entity__c = CON_PSA.TEST_DEFAULT_BUSINESS_ENTITY;
		projList.add(p);
	}
    Database.DMLOptions dml = new Database.DMLOptions(); 
    dml.DuplicateRuleHeader.AllowSave = true;
    if (insertRecords == true) { List<Database.SaveResult> sr = Database.insert(projList, dml); }
	return projList;
}


/************************************************************************************************************
   // Name         createPrograms
   // Description  Returns a list of test programs

 *************************************************************************************************************/
public static list<Program__c> createPrograms(integer cnt)
{

	return createPrograms(cnt, true);
}

public static List<Program__c> createPrograms(Integer cnt, boolean insertRecords) {

	list<Program__c> programList = new list<Program__c>();

	for (integer i=1; i<=cnt; i++){
		Program__c p = new Program__c();
		p.Name='Test Program';
		programList.add(p);
	}

	if (insertRecords == true) { insert programList;}
	return programList;
}

public static PSA_Date_Offset__c createDateOffset(Id programId, Id serviceId, Id serviceLineId, Id projectId,
												 String obj, Decimal offset, String unitType,
												 String sourceField, String targetField, boolean insertRecords) {

	PSA_Date_Offset__c os = new PSA_Date_Offset__c();
	os.Program__c = programId;
	os.Project__c = projectId;
	os.Service__c = serviceId;
	os.Service_Line__c = serviceLineId;
	os.Object__c = obj;
	os.Offset__c = offset;
	os.Unit_Type__c = unitType;
	os.Source_Date_Field__c = sourceField;
	os.Target_Date_Field__c = targetField;

	if (insertRecords == true) { insert os;}
	return os;
}


/*public static list<pse__Proj__c> createPrograms(integer cnt, Account acct, Opportunity opty, pse__Region__c rgn,
                                                   pse__Practice__c prac, pse__Grp__c grp, Contact projMgr,
                                                   boolean insertRecords)
   {
       list<pse__Proj__c> projList = new list<pse__Proj__c>();

       for (integer i=1; i<=cnt; i++)
       {
           pse__Proj__c p = new pse__Proj__c();
           p.CurrencyIsoCode = currencyCode;
           p.Name = 'Test Project ' + i + ' ' + key;
           p.pse__Account__c = acct != null ? acct.Id : null;
           p.pse__Opportunity__c = opty != null ? opty.Id : null;
           p.pse__Opportunity_Owner__c = opty != null ? opty.OwnerId : UserInfo.getUserId();
           p.pse__Region__c = rgn != null ? rgn.Id : null;
           p.pse__Practice__c = prac != null ? prac.Id : null;
           p.pse__Group__c = grp != null ? grp.Id : null;
           p.pse__Project_Manager__c = projMgr != null ? projMgr.Id : null;
           p.pse__Start_Date__c = startDate;
           p.pse__End_Date__c = p.pse__Start_Date__c.addDays(duration);
           p.pse__Is_Active__c = true;
           p.pse__Is_Billable__c = true;
           p.pse__Daily_Timecard_Notes_Required__c = false;
           p.pse__Allow_Timecards_Without_Assignment__c = true;
           p.pse__Allow_Expenses_Without_Assignment__c = true;
           p.pse__Project_Type__c = CON_PSA.PROJ_TYPE_CUSTOMER;
           p.pse__Billing_Type__c = CON_PSA.PROJ_BILL_TYPE_FIXED;
           p.pse__Stage__c = CON_PSA.PROJ_STAGE_CONDUCT;
           // p.Time_Approval_Method__c = CON_PSA.TEST_DEFAULT_PROJ_TIME_APPROVAL_METHOD;
           // p.Expense_Approval_Method__c = CON_PSA.TEST_DEFAULT_PROJ_EXP_APPROVAL_METHOD;
   //            p.Entity__c = CON_PSA.TEST_DEFAULT_BUSINESS_ENTITY;
           projList.add(p);
       }

       Database.DMLOptions dml = new Database.DMLOptions(); 
       dml.DuplicateRuleHeader.AllowSave = true;
       if (insertRecords == true) { List<Database.SaveResult> sr = Database.insert(projList, dml); }
       return projList;
   }*/





/************************************************************************************************************
   // Name         createRegions
   // Description  Returns a list of test PSA regions
 *************************************************************************************************************/
public static list<pse__Region__c> createRegions(integer cnt)
{
	return createRegions(cnt, true);
}
public static list<pse__Region__c> createRegions(integer cnt, boolean insertRecords)
{
	return createRegions(cnt, null, insertRecords);
}
public static list<pse__Region__c> createRegions(integer cnt, pse__Region__c parentRgn)
{
	return createRegions(cnt, parentRgn, true);
}
public static list<pse__Region__c> createRegions(integer cnt, pse__Region__c parentRgn, boolean insertRecords)
{
	list<pse__Region__c> rgnList = new list<pse__Region__c>();

	for (integer i=1; i<=cnt; i++)
	{
		pse__Region__c r = new pse__Region__c();
		r.CurrencyIsoCode = currencyCode;
		r.Name = 'Test Region ' + i + ' ' + key;
		r.pse__Parent_Region__c = parentRgn != null ? parentRgn.Id : null;
		rgnList.add(r);
	}

	if (insertRecords == true) { insert rgnList; }
	return rgnList;
}


/************************************************************************************************************
   // Name         createResourceRequests
   // Description  Returns a list of test resource requests
 *************************************************************************************************************/
public static list<pse__Resource_Request__c> createResourceRequests(integer cnt)
{
	return createResourceRequests(cnt, true);
}
public static list<pse__Resource_Request__c> createResourceRequests(integer cnt, boolean insertRecords)
{
	return createResourceRequests(cnt, projects[0], null, insertRecords);
}
public static list<pse__Resource_Request__c> createResourceRequests(integer cnt, pse__Proj__c proj)
{
	return createResourceRequests(cnt, proj, true);
}
public static list<pse__Resource_Request__c> createResourceRequests(integer cnt, Opportunity opty)
{
	return createResourceRequests(cnt, opty, true);
}
public static list<pse__Resource_Request__c> createResourceRequests(integer cnt, pse__Proj__c proj, boolean insertRecords)
{
	return createResourceRequests(cnt, proj, null, insertRecords);
}
public static list<pse__Resource_Request__c> createResourceRequests(integer cnt, Opportunity opty, boolean insertRecords)
{
	return createResourceRequests(cnt, null, opty, insertRecords);
}
public static list<pse__Resource_Request__c> createResourceRequests(integer cnt, pse__Proj__c proj, Opportunity opty, boolean insertRecords)
{
	list<pse__Resource_Request__c> reqList = new list<pse__Resource_Request__c>();
	Id rdsrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Resource_Request__c', CON_PSA.RESOURCE_REQUEST_REC_TYPE_RDS_REQUEST);

	for (integer i=1; i<=cnt; i++)
	{
		pse__Resource_Request__c req = new pse__Resource_Request__c();
		req.CurrencyIsoCode = currencyCode;
		req.pse__Resource_Request_Name__c = 'Test request ' + i + ' ' + key;
		req.pse__Project__c = proj != null ? proj.Id : null;
		req.pse__Opportunity__c = opty != null ? opty.Id : null;
		req.pse__Start_Date__c = startDate;
		req.pse__End_Date__c = startDate.addDays(duration);
		req.pse__Region__c = proj != null ? proj.pse__Region__c : opty.pse__Region__c;
		req.pse__Practice__c = proj != null ? proj.pse__Practice__c : opty.pse__Practice__c;
		req.pse__Group__c = proj != null ? proj.pse__Group__c : opty.pse__Group__c;
		req.pse__Resource_Role__c = CON_PSA.RESOURCE_ROLE_PROJECT_MANAGER;
		req.pse__Requested_Bill_Rate__c = 200.0;
		req.pse__SOW_Hours__c = 500;
		req.pse__Planned_Bill_Rate__c = 200.0;
		req.pse__Notes__c = 'Test';
		req.pse__Status__c = CON_PSA.RESOURCE_REQUEST_STATUS_DRAFT;
		req.recordTypeId = rdsrecTypeId;
		reqList.add(req);
	}

	if (insertRecords == true) { insert reqList; }
	return reqList;
}


/************************************************************************************************************
   // Name         createResources
   // Description  Returns a list of test PSA resources
 *************************************************************************************************************/
public static list<Contact> createResources(integer cnt)
{
	return createResources(cnt, true);
}
public static list<Contact> createResources(integer cnt, boolean insertRecords)
{
	return createResources(cnt, accounts[0], regions[0], practices[0], groups[0], workCalendars[0], insertRecords);
}
public static list<Contact> createResources(integer cnt, Account acct, pse__Region__c rgn, pse__Practice__c prac,
                                            pse__Grp__c grp, pse__Work_Calendar__c workCal)
{
	return createResources(cnt, acct, rgn, prac, grp, workCal, true);
}
public static list<Contact> createResources(integer cnt, Account acct, pse__Region__c rgn, pse__Practice__c prac,
                                            pse__Grp__c grp, pse__Work_Calendar__c workCal, boolean insertRecords)
{
	list<Contact> conList = new list<Contact>();
//        id recTypeId = [SELECT Id FROM RecordType WHERE Name = :CON_PSA.CONTACT_REC_TYPE_RESOURCE AND SobjectType = 'Contact'][0].Id;

	for (integer i=1; i<=cnt; i++)
	{
		Contact c = new Contact();
		c.CurrencyIsoCode = currencyCode;
		c.FirstName = 'Test';
		c.LastName = 'Resource ' + i + ' ' + key;
		c.Email = 'testresource' + i + key + '@example.org';
		c.AccountId = acct != null ? acct.Id : null;
		c.pse__Region__c = rgn != null ? rgn.Id : null;
		c.pse__Practice__c = prac != null ? prac.Id : null;
		c.pse__Group__c = grp != null ? grp.Id : null;
		c.pse__Work_Calendar__c = workCal != null ? workCal.Id : null;
		c.pse__Is_Resource__c = true;
		c.pse__Is_Resource_Active__c = true;
		c.pse__Start_Date__c = startDate.addYears(-1);
		c.pse__Resource_Role__c = CON_PSA.RESOURCE_ROLE_PROJECT_MANAGER;
		c.pse__Default_Cost_Rate__c = 50.0;
		c.pse__Utilization_Target__c = 90;
		c.EmployeeNumber__c = String.valueOf(System.currentTimeMillis() + i);
		c.Location_Code_text__c = 'USDUR1';
        
		conList.add(c);
	}
    Database.DMLOptions dml = new Database.DMLOptions(); 
    dml.DuplicateRuleHeader.AllowSave = true;
    if (insertRecords == true) { List<Database.SaveResult> sr = Database.insert(conList, dml); }
	return conList;
}


/************************************************************************************************************
   // Name         createSharedDocuments
   // Description  Returns a list of test shared documents
 *************************************************************************************************************/
//public static list<Shared_Document__c> createSharedDocuments(integer cnt)
//{
//    return createSharedDocuments(cnt, true);
//}
//public static list<Shared_Document__c> createSharedDocuments(integer cnt, boolean insertRecords)
//{
//    return createSharedDocuments(cnt, CON_PSA.TEST_DEFAULT_SHARED_DOC_TYPE, insertRecords);
//}
//public static list<Shared_Document__c> createSharedDocuments(integer cnt, string type)
//{
//    return createSharedDocuments(cnt, type, true);
//}
//public static list<Shared_Document__c> createSharedDocuments(integer cnt, string type, boolean insertRecords)
//{
//    list<Shared_Document__c> sdList = new list<Shared_Document__c>();

//    for (integer i=1; i<=cnt; i++)
//    {
//        Shared_Document__c sd = new Shared_Document__c();
//        sd.Contract_Value__c = 100;
//        sd.Description__c = 'Test doc';
//        sd.Effective_Date__c = startDate;
//        sd.Expiration_Date__c = startDate.addDays(duration);
//        sd.External_Link__c = 'www.google.com';
//        sd.Legal_Paper__c = CON_PSA.TEST_DEFAULT_SHARED_DOC_LEGAL_PAPER;
//        sd.Legal_Review_Date__c = system.today();
//        sd.Legal_Reviewer__c = users[0].Id;
//        sd.Point_B_Signer__c = users[0].Id;
//        sd.Status__c = CON_PSA.TEST_DEFAULT_SHARED_DOC_STATUS;
//        sd.Type__c = type;
//        sdList.add(sd);
//    }

//    if (insertRecords == true) { insert sdList; }
//    return sdList;
//}


/************************************************************************************************************
   // Name         createTimePeriods
   // Description  Returns a list of test time periods
 *************************************************************************************************************/
public static list<pse__Time_Period__c> createTimePeriods(integer cnt, string type, Date start, integer interval)
{
	return createTimePeriods(cnt, type, start, interval, true);
}
public static list<pse__Time_Period__c> createTimePeriods(integer cnt, string type, Date start, integer interval,
                                                          boolean insertRecords)
{
	list<pse__Time_Period__c> tpList = new list<pse__Time_Period__c>();
	Date stop = start.addDays(interval - 1);

	for (integer i=1; i<=cnt; i++)
	{
		tpList.add(initTimePeriod(type, start, stop, i));
		start = stop.addDays(1);
		stop = start.addDays(interval - 1);
	}

	if (insertRecords == true) { insert tpList; }
	return tpList;
}


/************************************************************************************************************
   // Name         createUsers
   // Description  Returns a list of test users
 *************************************************************************************************************/
public static list<User> createUsers(integer cnt)
{
	return createUsers(cnt, true);
}
public static list<User> createUsers(integer cnt, boolean insertRecords)
{
	list<User> userList = new list<User>();
	Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

	UserRole usrRole = [Select Id From UserRole Limit 1]; //new UserRole(Name= 'TestRole' + key);
	//insert usrRole;

	for (integer i=0; i<cnt; i++)
	{
		User u = new User();
		u.CurrencyIsoCode = currencyCode;
		u.alias = 't' + i;
		u.email = 'unitcoverage' + i + key + '@example.com';
		u.emailencodingkey = 'UTF-8';
		u.firstname = 'Unit';
		u.lastname ='Coverage ' + i + key;
		u.languagelocalekey = 'en_US';
		u.localesidkey = 'en_US';
		u.profileid = p.Id;
		u.timezonesidkey = 'America/New_York';
		u.username = u.email;
		u.UserRoleId = usrRole.Id;
                u.employeenumber= String.valueOf(System.currentTimeMillis());
		userList.add(u);
	}

	if (insertRecords == true) {
		User currentUser = [Select Id From User Where Id = :UserInfo.getUserId()];
		system.runAs(currentUser) {
			insert userList;
		}
	}
	return userList;
}


/************************************************************************************************************
   // Name         createWorkCalendars
   // Description  Returns a list of test work calendars
 *************************************************************************************************************/
public static list<pse__Work_Calendar__c> createWorkCalendars(integer cnt)
{
	return createWorkCalendars(cnt, true);
}
public static list<pse__Work_Calendar__c> createWorkCalendars(integer cnt, boolean insertRecords)
{
	list<pse__Work_Calendar__c> wcList = new list<pse__Work_Calendar__c>();

	for (integer i=1; i<=cnt; i++)
	{
		pse__Work_Calendar__c wc = new pse__Work_Calendar__c();
		wc.CurrencyIsoCode = currencyCode;
		wc.Name = 'Test Work Calendar ' + i + ' ' + key;
		wc.pse__Monday_Hours__c = 8;
		wc.pse__Tuesday_Hours__c = 8;
		wc.pse__Wednesday_Hours__c = 8;
		wc.pse__Thursday_Hours__c = 8;
		wc.pse__Friday_Hours__c = 8;
		wc.pse__Saturday_Hours__c = 0;
		wc.pse__Sunday_Hours__c = 0;
		wcList.add(wc);
	}

	if (insertRecords == true) { insert wcList; }
	return wcList;
}






/************************************************************************************************************
   //
   // The following section contains methods that create specific data scenarios commonly needed within test
   // classes. They go a step beyond just creating a sample record with default values to configuring the
   // records for a specific scenario.
   //
 *************************************************************************************************************/


/************************************************************************************************************
   // Name         initAdjustmentProducts
   // Description  Creates the standard set of FFA adjustment products
 *************************************************************************************************************/
public static void initAdjustmentProducts(string pipeline)
{
//TODO: Finish
}


/************************************************************************************************************
   // Name         initGroupHierarchy
   // Description  Creates a sample 3-level group hierarchy
 *************************************************************************************************************/
public static void initGroupHierarchy()
{
	// Create a 3-level sample group hierarchy
	groups = createGroups(1);
	string oldKey = key;
	key = 'a';
	groups.addAll(createGroups(2, groups[0]));
	key = 'b';
	groups.addAll(createGroups(2, groups[1]));
	key = 'c';
	groups.addAll(createGroups(2, groups[2]));
	key = oldKey;
}


/************************************************************************************************************
   // Name         initPracticeHierarchy
   // Description  Creates a sample 2-level practice hierarchy
 *************************************************************************************************************/
public static void initPracticeHierarchy()
{
	// Create a 2-level sample practice hierarchy
	practices = createPractices(1);
	string oldKey = key;
	key = 'a';
	practices.addAll(createPractices(2, practices[0]));
	key = oldKey;
}


/************************************************************************************************************
   // Name         initPricebook
   // Description  Creates a pricebook with pricebook entries for the given pipeline and adds it to the
   //              priceBooks list.
 *************************************************************************************************************/
public static void initPricebook(string pipeline)
{
	system.assert (standardPriceBookInitialized, 'Cannot call psaTestDataFactory.initPriceBook() before calling psaTestDataFactory.initStandardPriceBook()');

	// Create the price book
	Pricebook2 pb = createPriceBooks(1, pipeline)[0];

	// Stash in the property
	if (priceBooksInitialized == false)
	{
		priceBooks = new list<Pricebook2>();
	}

	priceBooks.add(pb);

	// Add all products to the pricebook
	initPricebookEntries(pb.Id);
}


/************************************************************************************************************
   // Name         initPricebookEntries
   // Description  Creates pricebook entries on the specified pricebook for all records in the products
   //              property.
 *************************************************************************************************************/
public static void initPricebookEntries(id pricebookId)
{
	// Create the price book entries for all products except Adjustments products
	list<PricebookEntry> pbeInsertList = new list<PricebookEntry>();

	for (Product2 p : products)
	{
		PricebookEntry pbe = new PricebookEntry();
		pbe.IsActive = true;
		pbe.UnitPrice = 300.0;
		pbe.Pricebook2Id = pricebookId;
		pbe.Product2Id = p.Id;
		pbeInsertList.add(pbe);

		if (priceBookEntriesByPriceBook.get(pbe.Pricebook2Id) == null)
		{
			priceBookEntriesByPriceBook.put(pbe.Pricebook2Id, new list<PricebookEntry>());
		}

		if (priceBookEntriesByProduct.get(pbe.Product2Id) == null)
		{
			priceBookEntriesByProduct.put(pbe.Product2Id, new list<PricebookEntry>());
		}

		priceBookEntriesByPriceBook.get(pbe.Pricebook2Id).add(pbe);
		priceBookEntriesByProduct.get(pbe.Product2Id).add(pbe);
	}

	if (pbeInsertList.isEmpty() == false)
	{
		insert pbeInsertList;
	}
}


/************************************************************************************************************
   // Name         initSampleOpportunity
   // Description  Creates a sample opportunity with multiple opportunity line items
   // Notes        Assumes pricebooks and opportunity have not previously been initialized.
 *************************************************************************************************************/
public static void initSampleOpportunity()
{
	initStandardPricebook();
	// initPricebook(CON_PSA.TEST_DEFAULT_PIPELINE);
	initPricebook('pbook');
	opportunities = createOpportunities(1);

	opportunityLineItemsByOpportunity = new map<id, list<OpportunityLineItem> >();
	opportunityLineItemsByOpportunity.put(opportunities[0].Id, new list<OpportunityLineItem>());

	for (PricebookEntry pbe : priceBookEntriesByPriceBook.get(priceBooks[0].Id))
	{
		opportunityLineItemsByOpportunity.get(opportunities[0].Id).addAll(createOpportunityLineItems(1, opportunities[0], pbe, false));
	}

	insert opportunityLineItemsByOpportunity.get(opportunities[0].Id);
}


/************************************************************************************************************
   // Name         initStandardPricebook
   // Description  Creates price book entries for all products on the standard pricebook.
 *************************************************************************************************************/
public static void initStandardPricebook()
{
	if (standardPriceBookInitialized == false)
	{
		// Init price book entry maps
		if (priceBookEntriesByPriceBookInitialized == false)
		{
			priceBookEntriesByPriceBook = new map<id, list<PricebookEntry> >();
		}

		if (priceBookEntriesByProductInitialized == false)
		{
			priceBookEntriesByProduct = new map<id, list<PricebookEntry> >();
		}

		// Add all products to the standard pricebook
		initPricebookEntries(system.test.getStandardPricebookId());

		// Flag standard price book as initialized
		standardPriceBookInitialized = true;
	}
}


/************************************************************************************************************
   // Name         initRegionHierarchy
   // Description  Creates a sample 2-level region hierarchy
 *************************************************************************************************************/
public static void initRegionHierarchy()
{
	// Create a 2-level sample region hierarchy
	regions = createRegions(1);
	string oldKey = key;
	key = 'a';
	regions.addAll(createRegions(2, regions[0]));
	key = oldKey;
}


/************************************************************************************************************
   // Name         initTimePeriods
   // Description  Creates a sample set of time periods for the given type.
   // Notes        Dates are aligned with the calendar periods to accomodate logic that expects calendar-aligned
   //              time periods. All time period sets start at the beginning of the calendar year containing the
   //              seed date and run for the number of years specified. Call this method multiple times to
   //              create time periods of different types.
 *************************************************************************************************************/
public static void initTimePeriods(string type, date seedDate, integer years)
{
	system.assert (type != null && type != '', 'type must be specified');
	system.assert (seedDate != null, 'seedDate must be specified');
	system.assert (years != null, 'years must be specified');

	// Local collection to queue time period insert
	list<pse__Time_Period__c> tpList = new list<pse__Time_Period__c>();

	// Always start at the beginning of the calendar year containing the seedDate
	Date start = Date.newInstance(seedDate.year(), 1, 1);

	// Generate time periods based on type
	if (type == CON_PSA.TIME_PERIOD_TYPE_PERPETUAL)
	{
		tpList.add(initTimePeriod(type, start, start.addYears(years).addDays(-1), null));
	}
	else if (type == CON_PSA.TIME_PERIOD_TYPE_YEAR)
	{
		Date stop = start.addYears(1).addDays(-1);

		for (integer i=1; i<=years; i++)
		{
			tpList.add(initTimePeriod(type, start, stop, i));
			start = stop.addDays(1);
			stop = start.addYears(1).addDays(-1);
		}
	}
	else if (type == CON_PSA.TIME_PERIOD_TYPE_QUARTER)
	{
		Date stop = start.addMonths(3).addDays(-1);

		for (integer i=1; i<=years*4; i++)
		{
			tpList.add(initTimePeriod(type, start, stop, i));
			start = stop.addDays(1);
			stop = start.addMonths(3).addDays(-1);
		}
	}
	else if (type == CON_PSA.TIME_PERIOD_TYPE_MONTH)
	{
		Date stop = start.addMonths(1).addDays(-1);

		for (integer i=1; i<=years*12; i++)
		{
			tpList.add(initTimePeriod(type, start, stop, i));
			start = stop.addDays(1);
			stop = start.addMonths(1).addDays(-1);
		}
	}
	// else if (type == CON_PSA.TIME_PERIOD_TYPE_SEMIMONTH)
	// {
	//     // Create time periods that span 1->15 and 16->last day of month
	//     Date stop = start.addDays(14);

	//     for (integer i=1; i<=years*24; i++)
	//     {
	//         tpList.add(initTimePeriod(type, start, stop, i));
	//         start = stop.addDays(1);

	//         if (math.mod(i,2) == 1)
	//         {
	//             // current period is first half of month --> advance stop to end of current month
	//             stop = start.addMonths(1).toStartOfMonth().addDays(-1);
	//         }
	//         else
	//         {
	//             // current period is second half of month --> advance stop to 15th of the next month
	//             stop = start.addDays(14);
	//         }
	//     }
	// }
	else if (type == CON_PSA.TIME_PERIOD_TYPE_WEEK)
	{
		Date stop = start.addDays(6);

		for (integer i=1; i<=years*52; i++)
		{
			tpList.add(initTimePeriod(type, start, stop, i));
			start = stop.addDays(1);
			stop = start.addDays(6);
		}
	}
	else
	{
		// No default for any other type of time period
		system.assert (false, 'Unsupported time period type for initTimePeriods(): ' + type);
	}

	// Insert the new time periods
	if (tpList.isEmpty() == false)
	{
		insert tpList;
	}

	// Stash the new time periods in the local property
	if (timePeriodsByTypeInitialized == false)
	{
		timePeriodsByType = new map<string, list<pse__Time_Period__c> >();
		timePeriodsByTypeInitialized = true;
	}

	if (timePeriodsByType.get(type) == null)
	{
		timePeriodsByType.put(type, tpList);
	}
	else
	{
		timePeriodsByType.get(type).addAll(tpList);
	}
}






/************************************************************************************************************
   //
   // The following section contains helper methods used by the createXXX and initXXX methods to create object
   // instances in a consistent manner.
   //
 *************************************************************************************************************/


/************************************************************************************************************
   // Name         initTimePeriod
   // Description  Helper method for initTimePeriods() and createTimePeriods(). Returns a new time period
   //              instance with the given parameters.
 *************************************************************************************************************/
public static pse__Time_Period__c initTimePeriod(string type, Date start, Date stop, integer counter)
{
	string n = counter != null ? (' ' + counter) : '';
	string k = (key != null && key != '') ? (' ' + key) : '';

	pse__Time_Period__c tp = new pse__Time_Period__c();
	tp.CurrencyIsoCode = currencyCode;
	tp.Name = 'Test ' + type + ' Time Period' + n + k;
	tp.pse__Type__c = type;
	tp.pse__Start_Date__c = start;
	tp.pse__End_Date__c = stop;
	return tp;
}


/************************************************************************************************************
   //
   // The following section contains helper methods for initializing the properties. These are not explicitly
   // necessary since the properties can be initialized by setting them to themselves, but these methods
   // provide (perhaps) a cleaner looking, more understandable way to initialize default values for the
   // properties within your test classes. To use these methods, follow this pattern in your test class:
   //
   //          psaTestDataFactory.accounts = initAccounts();
   //
   // Note: All of these methods rely on the default getter implementation for each property. The same "property
   // chaining" applies here. If you use psaTestDataFactory.projects = initProjects(), the class will call other
   // properties (regions, practices, groups, resources, accounts), which will be initialized with default
   // values if not already initialized.
   //
   // Note: Not all properties have init methods here. In some cases, the specialized initXXX() methods should
   // be used instead (mainly the prodcut catalog related properties), or the property gets initialized when
   // another property is initialized (e.g. schedulesById is initialized at the same time assignments is
   // initialized).
   //
 *************************************************************************************************************/

public static list<Account> initAccounts()
{
	return accounts;
}

public static list<pse__Assignment__c> initAssignments()
{
	return assignments;
}

public static list<pse__Budget__c> initBudgets()
{
	return budgets;
}

public static list<Contact> initContacts()
{
	return contacts;
}

public static list<pse__Grp__c> initGroups()
{
	return groups;
}

public static list<pse__Milestone__c> initMilestones()
{
	return milestones;
}

public static list<Opportunity> initOpportunities()
{
	return opportunities;
}

//public static map<id, list<OpportunityTeamMember>> initOpportunityTeamMembers()
//{
//    return opportunityTeamMembersByOpportunity;
//}

public static list<pse__Permission_Control__c> initPermissionControls()
{
	return permissionControls;
}

public static list<pse__Practice__c> initPractices()
{
	return practices;
}

public static list<Product2> initProducts()
{
	return products;
}

public static list<pse__Proj__c> initProjects()
{
	return projects;
}

public static list<pse__Region__c> initRegions()
{
	return regions;
}

public static list<pse__Resource_Request__c> initResourceRequests()
{
	return resourceRequests;
}

public static list<Contact> initResources()
{
	return resources;
}

//public static list<Shared_Document__c> initSharedDocuments()
//{
//    return sharedDocuments;
//}

public static map<string, list<pse__Time_Period__c> > initTimePeriods()
{
	return timePeriodsByType;
}

public static list<User> initUsers()
{
	return users;
}

public static list<pse__Work_Calendar__c> initWorkCalendars()
{
	return workCalendars;
}


public static void disableASMTriggers() {
	//disable timecard ASM triggers
	appirio_core__Config_Value__c[] tcsCoreValues = [
		select Id,
		appirio_core__Value__c,
		appirio_core__Config_Option__c
		from appirio_core__Config_Value__c
		where appirio_core__config_Option__r.appirio_core__Group_Key__c = 'asm-triggers'
		                                                                  and (appirio_core__config_Option__r.name = 'handlebillingeventitemchange'
		                                                                                                             or appirio_core__config_Option__r.name = 'handletransactionfortimecard'
		                                                                                                                                                      or appirio_core__config_Option__r.name = 'handlebillingeventchange'
		                                                                                                                                                                                               or appirio_core__config_Option__r.name = 'handletransactionformilestone'
		                                                                                                                                                                                                                                        or appirio_core__config_Option__r.name = 'beforeMiscellaneousAdjustmentChange'
		                                                                                                                                                                                                                                                                                 or appirio_core__config_Option__r.name = 'beforeMilestoneChange'
		                                                                                                                                                                                                                                                                                                                          or appirio_core__config_Option__r.name = 'afterExpenseReportChange'
		                                                                                                                                                                                                                                                                                                                                                                   or appirio_core__config_Option__r.name = 'handleExpenseLineChange'
		                                                                                                                                                                                                                                                                                                                                                                                                            or appirio_core__config_Option__r.name = 'handleExpenseReportUpdate'
		                                                                                                                                                                                                                                                                                                                                                                                                                                                     or appirio_core__config_Option__r.name = 'updateExpenseReportForExpense'
		                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              or appirio_core__config_Option__r.name = 'ShareMilestoneWithApprover'
		                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       or appirio_core__config_Option__r.name = 'beforeBudgetChange'
		                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                or appirio_core__config_Option__r.name = 'handleTransactionForBudget'
		                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         or appirio_core__config_Option__r.name = 'handleactualsfortransaction')
		                                                                  order by appirio_core__config_Option__r.name
	];
	if (tcsCoreValues != null && !tcsCoreValues.isEmpty())
	{
		for(appirio_core__Config_Value__c tsc : tcsCoreValues) {
			tsc.appirio_core__Value__c = 'false';
		}
		update tcsCoreValues;
	}
}

/******************************************************
 * Method Name	:  lookupRecordTypeId
 * Description	:  Find the Id of a Record Type by the record type name
 * Return Type	:  Id
 * Parameters	:  The SObject type (string) and record type name (string)
 *******************************************************/
public static Id lookupRecordTypeId(String sobjType, String recTypeName)
{
	Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sobjType);
	Map<String, Schema.RecordTypeInfo> rectypeInfo = targetType.getDescribe().getRecordTypeInfosByName();
	return (rectypeInfo.containsKey(recTypeName) ? rectypeInfo.get(recTypeName).recordTypeId : null);
}

/******************************************************
 * creates an IQVIA parent project
 *******************************************************/
public static pse__Proj__c createParentProject() {
	return createParentProject(true);
}
public static pse__Proj__c createParentProject(Boolean insertRecords) {
	return createParentProject('Test Parent Project', true);
}
public static pse__Proj__c createParentProject(String projName, Boolean insertRecords) {
	return createParentProject(UTL_PSA_TestData.accounts[0], projName, 'Start-up', true);
}
public static pse__Proj__c createParentProject(Account account, String projName, String projStatus,  Boolean insertRecords) {
	// Parent Project
	pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
	Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);

	parentproject.recordTypeId = parentrecTypeId;
	parentProject.pse__Account__c = account.id;
	parentproject.pse__Project_Status__c = projStatus;
        parentproject.Go_Live_Date__c = System.today();
	parentProject.Name = projName;

	if (insertRecords) {
		insert parentproject;
	}
	return parentproject;
}

/******************************************************
 * creates an IQVIA service line project, including parent project
 *******************************************************/
public static pse__Proj__c createServiceLineProject() {
	return createServiceLineProject(true);
}
public static pse__Proj__c createServiceLineProject(Boolean insertRecords) {
	pse__Proj__c parentProj = createParentProject();
	return createServiceLineProject(parentProj, insertRecords);
}
public static pse__Proj__c createServiceLineProject(pse__Proj__c parentProj, Boolean insertRecords) {
	return createServiceLineProject(parentProj, null, insertRecords);
}
public static pse__Proj__c createServiceLineProject(pse__Proj__c parentProj, String projName, Boolean insertRecords) {
	pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
	Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);

	project.recordTypeId = recTypeId;
	project.pse__Project_Status__c = 'Start-up';
	project.pse__Parent_Project__c = parentProj.id;
	project.pse__Account__c = parentProj.pse__Account__c;
        project.Go_Live_Date__c = System.today();
	if (String.isNotEmpty(projName)) {
		project.Name = projName;
	}

	if (insertRecords) {
		insert project;
	}

	return project;
}


/******************************************************
 * creates an IQVIA service line assigning, on a service line project
 *******************************************************/
public static pse__Assignment__c createServiceLineAssignment () {
	return createServiceLineAssignment(true);
}
public static pse__Assignment__c createServiceLineAssignment (Boolean insertRecords) {
	return createServiceLineAssignment(createServiceLineProject(), insertRecords);
}
public static pse__Assignment__c createServiceLineAssignment (pse__Proj__c serviceLineProj, Boolean insertRecords) {
	pse__Assignment__c assignment = UTL_PSA_TestData.createAssignments(false)[0];
	assignment.pse__Project__c = serviceLineProj.Id;
	if (insertRecords) {
		insert assignment;
	}
	return assignment;
}

/**
 * Stubs up basic items for a project task and returns the initialized, (not inserted)
 * project task
 */
public static pse__Project_Task__c createProjectTaskTestSubject () {
	//contacts
	Contact contact = UTL_PSA_TestData.resources[0];
	contact.pse__Salesforce_User__c = UserInfo.getUserId();
	update contact;

	Program__c program = UTL_PSA_TestData.programs[0];

	// Account
	Account account = UTL_PSA_TestData.accounts[0];
	UTL_PSA_TestData.createPermissionControls();

	// parent project
	pse__Proj__c parentProject = UTL_PSA_TestData.createProjects(1, false)[0];
	Id rdsrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
	parentProject.recordTypeId = rdsrecTypeId;
	parentProject.Name = 'Test Parent Project';
	parentProject.pse__Account__c = account.id;
        parentProject.Go_Live_Date__c = System.today();
	insert parentProject;

	// Service line project
	pse__Proj__c servicelineproject = UTL_PSA_TestData.createProjects(1, false)[0];
	Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
	servicelineproject.recordTypeId = recTypeId;
	servicelineproject.pse__Parent_Project__c = parentProject.id;
	servicelineproject.pse__Account__c= account.id;
	servicelineproject.pse__Exclude_From_Billing__c = false;
	servicelineproject.Program__c = program.Id;
        servicelineproject.Go_Live_Date__c = System.today();
	insert servicelineproject;
	
	//Assignment 
	List<pse__Assignment__c> assignments = UTL_PSA_TestData.createAssignments(new List<Contact> {contact, contact, contact},servicelineproject,false);
	assignments[0].pse__Bill_Rate__c = 200;
	assignments[0].Sub_role__c = 'IQVIA Primary GSO';
	assignments[1].pse__Bill_Rate__c = 200;
	assignments[1].Sub_role__c = 'IQVIA GSO LM';
	assignments[2].pse__Bill_Rate__c = 200;
	assignments[2].Sub_role__c = 'IQVIA TAH';
	insert assignments;

	// service line
	Service_Line__c serviceLine = new Service_Line__c (
			Active__c = true,
			Service_Line_Code__c = 'ADP',
			Name = 'ADP'
			);
	insert serviceLine;

	// service
	Service__c service = new Service__c(
			Active__c = true,
			Service_Line__c = serviceLine.id,
			Service_Code__c = 'ADP'
			);
	insert service;

	//milestones
	pse__Milestone__c milestone = UTL_PSA_TestData.createMilestones(1, false)[0];
	Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
	milestone.RecordTypeId = milestonerecTypeId;
	milestone.pse__Project__c = servicelineproject.Id;
	milestone.Service_Line__c = serviceLine.Id;
	milestone.Service__c = service.id;
	milestone.Start_Date__c = system.today();
	milestone.End_Date__c =  milestone.Start_Date__c.addDays(30);
	milestone.pse__Exclude_from_Billing__c = false;
	insert milestone;

	//Deliverable for milestone
	Id deliverableRecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', CON_PSA.RDS_DELIVERABLE);
	
	//Parent Project Task
	pse__Project_Task__c parentprojecttask = new pse__Project_Task__c(Name = 'ParentPT');
	parentprojecttask.recordTypeId = deliverableRecTypeId;
	parentprojecttask.pse__Project__c = servicelineproject.id;
	parentprojecttask.pse__Milestone__c = milestone.id;
	parentprojecttask.Countries__c = 'US;';
	parentprojecttask.pse__Start_Date_Time__c = date.today().addDays(-30);
	parentprojecttask.pse__End_Date_Time__c = date.today().addDays(-3);
	parentprojecttask.Service_Line__c = serviceline.id;
	parentprojecttask.pse__End_Date_Time__c = date.today().addDays(-3);
	parentprojecttask.pse__Status__c = 'Planned';
	parentprojecttask.Unit_Price__c = 200;
	parentprojecttask.Budgeted_Hours__c = 10;
	parentprojecttask.Role__c = 'Coordinator';
	parentprojecttask.Include_in_Financials__c = true;
	parentprojecttask.Resource__c = Contact.Id;
    
	pse__Project_Task_Assignment__c PTA2 = new pse__Project_Task_Assignment__c();
	PTA2.pse__Project_Task__c = parentprojecttask.id;
	PTA2.pse__Resource__c = contact.Id;
	PTA2.Is_Primary__c = true;
	
	pse__Project_Task__c deliverable = new pse__Project_Task__c(
			RecordTypeId=deliverableRecTypeId,
			Quantity__c = 100,
			Billing_Hold__c = true,
			Include_in_Financials__c=true,
			Service__c = service.Id,
			Service_Line__c= serviceLine.id,
			pse__Milestone__c = milestone.id,
			pse__Project__c = servicelineproject.id,
			Billable__c=true,
			pse__Parent_Task__c = parentprojecttask.id,
			Resource__c = Contact.Id
	);
	return  deliverable;
}
    
    public static Topics_of_Interest__c createTopicOfInterest(Integer record){
        UTL_PSA_TestData.createPermissionControls();
        
        Program__c program = UTL_PSA_TestData.programs[0];
        Account account = UTL_PSA_TestData.accounts[0];
        Service_Line__c serviceline = UTL_PSA_TestData.createSMServiceLine();
        insert serviceline;
        
        //contacts
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        testResource.Location_Code_text__c = 'USDUR1';
        insert testResource;
        
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Actual_Go_Live_Date__c = System.today();
        parentproject.Go_Live_Date__c = System.today();
        parentproject.Program__c = program.id;
        insert parentproject;
        
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        project.Go_Live_Date__c = System.today();
        insert project;
        
        Target__c target =UTL_PSA_TestData.createTarget();
        target.Indication__c = 'abcd';
        target.Protocol_Number__c = '1234';
        target.Therapeutic_Area__c = 'Acute Care';
        target.Inactivated_Date__c = system.today();
        target.Date_Activated__c = system.today();
            
        insert target;
        
        if(record ==  0){
            Topics_of_Interest__c toi = new Topics_of_Interest__c();
            toi.project__c = project.id;
            toi.Account__c = account.id;
            return toi;
        }
        else{
            Topics_of_Interest__c toiRecord = new Topics_of_Interest__c();
            toiRecord.Product__c = target.id;
            toiRecord.Account__c = account.id;
            toiRecord.project__c = project.id;
            toiRecord.Status__c = 'New';
            toiRecord.Topic_Term__c = 'Test';
            toiRecord.Topic_Category__c = 'Potential Risk (important)';
            toiRecord.Search_Variable_in_Data_Source__c = '	Adverse Events';
            toiRecord.Type_of_MedDRA_Query__c = 'HLGT' ;
            toiRecord.MedDRA_Search_Specifications__c = 'Test';
            toiRecord.Date_Started__c  =  Date.newInstance(2021, 1, 2);
            toiRecord.Date_Reminder_Calendar__c = Date.newInstance(2021, 4, 5);
            toiRecord.Part_of_Additional_RMM__c = 'No';
            toiRecord.In_RMP__c = 'No';
            toiRecord.Part_of_Commitment_to_HA__c = 'No';
            toiRecord.Rationale_Started__c = 'test';
            toiRecord.Document_Link_1__c = 'test';
            toiRecord.Document_Name_1__c = 'test';
            return toiRecord;
        }
        
    }
    
    public static Signal__c createSignal(){
        UTL_PSA_TestData.createPermissionControls();
        
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        Service_Line__c serviceline = new Service_Line__c(
            Name = 'Signal Management',
            Active__c=true,
            Service_Line_Code__c = 'SM');
        insert serviceline;
        
        Service__c service = new Service__c (Name='Signal Validation',Service_Line__c=serviceline.id,service_code__c='SM3');
        insert service;
        
        //contacts
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        testResource.Location_Code_text__c = 'USDUR1';
        insert testResource;
        
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Program__c = program.id;
        insert parentproject;
        
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        insert project;
        
        pse__Milestone__c serviceMilestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id serviceMilestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
        serviceMilestone.RecordTypeId = serviceMilestonerecTypeId;
        serviceMilestone.Actual_Quantity__c = 10;
        serviceMilestone.Billed_Quantity__c = 15;
        serviceMilestone.pse__Project__c = project.Id;
        serviceMilestone.pse__Target_Date__c = system.today();
        serviceMilestone.Actual_Amount__c = 20;
        serviceMilestone.pse__Milestone_Amount__c = 100;
        serviceMilestone.Billed_Amount__c = 30;
        serviceMilestone.Include_Tasks_on_Deliverables__c = true;
        serviceMilestone.Service__c = service.id;
        serviceMilestone.Service_Line__c = serviceline.id;
        insert serviceMilestone;     
        
        Id targetRecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('Target__c', CON_PSA.TARGET_REC_TYPE_RDS_PRODUCT_LINE);
        Target__c target = new Target__c(
            recordTypeId=targetRecordTypeId,
            Name='Test Target',
            API__c='Test API',
            Strength__c='Super strong',
            Dosage_Form__c='Huge pill',
            Program__c=program.Id,
            Inactivated_Date__c = system.today(),
            Countries_NA__c = true
        );
        target.Indication__c = 'abcd';
        target.Protocol_Number__c = '1234';
        target.Therapeutic_Area__c = 'Acute Care';
        target.Date_Activated__c = System.today();
        target.Inactivated_Date__c = System.today();
        insert target;
        
        pse__Permission_Control__c pc = new pse__Permission_Control__c();
        pc.CurrencyIsoCode = project.CurrencyIsoCode;
        pc.pse__User__c = UserInfo.getUserId();
        pc.pse__Region__c = project.pse__region__c;
        pc.pse__Cascading_Permission__c = true;
        pc.Unit_Entry_Ops_Edit__c = true;
        pc.pse__Billing__c = true;
        pc.pse__Expense_Entry__c = true;
        pc.pse__Expense_Ops_Edit__c = true;
        pc.pse__Forecast_Edit__c = true;
        pc.pse__Forecast_View__c = true;
        pc.pse__Invoicing__c = true;
        pc.pse__Edit_Task_Manager__c = true;
        pc.pse__View_Task_Manager__c = true;
        pc.pse__Resource_Request_Entry__c = true;
        pc.pse__Skills_And_Certifications_Entry__c = true;
        pc.pse__Skills_And_Certifications_View__c = true;
        pc.pse__Staffing__c = true;
        pc.pse__Timecard_Entry__c = true;
        pc.pse__Timecard_Ops_Edit__c = true;
        pc.Unit_Entry_Ops_Edit__c = true;
        insert pc;
        
        pse__Resource_Request__c resourcerequest = new pse__resource_request__c();
        resourcerequest.CurrencyIsoCode = project.CurrencyIsoCode;
        resourcerequest.pse__Resource_Request_Name__c = 'Test request 1';
        resourcerequest.pse__Project__c = project.id;
        resourcerequest.pse__Start_Date__c = project.pse__start_date__c;
        resourcerequest.pse__End_Date__c = project.pse__start_date__c.addDays(1);
        resourcerequest.pse__Region__c = project.pse__Region__c;
        resourcerequest.pse__Group__c = project.pse__Group__c;
        resourcerequest.pse__Resource_Role__c = CON_PSA.RESOURCE_ROLE_SERVICELINE_LEAD;
        resourcerequest.pse__Requested_Bill_Rate__c = 200.0;
        resourcerequest.pse__SOW_Hours__c = 500;
        resourcerequest.pse__Planned_Bill_Rate__c = 200.0;
        resourcerequest.pse__Notes__c = 'Test';
        resourcerequest.pse__Status__c = CON_PSA.RESOURCE_REQUEST_STATUS_DRAFT;
        resourcerequest.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Resource_Request__c', CON_PSA.RESOURCE_REQUEST_REC_TYPE_RDS_REQUEST); 
        insert resourcerequest;

        pse__Schedule__c sch = new pse__Schedule__c();
        sch.pse__Start_Date__c = project.pse__Start_Date__c;
        sch.pse__End_Date__c = project.pse__End_Date__c;
        sch.pse__Monday_Hours__c = 8;
        sch.pse__Tuesday_Hours__c = 8;
        sch.pse__Wednesday_Hours__c = 8;
        sch.pse__Thursday_Hours__c = 8;
        sch.pse__Friday_Hours__c = 8;
        sch.pse__Saturday_Hours__c = 0;
        sch.pse__Sunday_Hours__c = 0;
        insert sch;
        
        pse__Assignment__c assignment = new pse__assignment__c();
        assignment.pse__Is_Billable__c = project.pse__Is_Billable__c;
        assignment.pse__Bill_Rate__c = (assignment.pse__Is_Billable__c && project.pse__Billing_Type__c == CON_PSA.PROJ_BILL_TYPE_FIXED) ? 200 : 0;
        assignment.pse__Planned_Hours__c = 100;
        assignment.pse__Project__c = project.Id;
        assignment.pse__Resource__c = testResource.id;
        assignment.pse__Role__c = CON_PSA.RESOURCE_ROLE_SERVICELINE_LEAD;
        assignment.pse__Schedule__c = sch.Id;
        assignment.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_SCHEDULED;
        assignment.pse__Time_Credited__c = project.pse__Time_Credited__c;
        assignment.pse__Time_Excluded__c = project.pse__Time_Excluded__c;
        assignment.RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);
        assignment.Primary_Service_Line_Lead__c = true;
        assignment.Active__c = true;
        insert assignment;
        
        Signal__c sigRec = new Signal__c();
        sigRec.project__c = project.id;
        sigRec.Source_or_Trigger_of_Signal__c = 'FAERS';
        sigRec.Product__c = target.Id;
        sigRec.Date_Detected__c = Date.newInstance(2020, 3, 4);
        sigRec.Signal_Term__c = 'Test';
        sigRec.Signal_Unique_ID__c = 'IQVIA-SIGNAL-00054';
        sigRec.SM_Service_Line_Lead_New__c = testResource.id;
        sigRec.Incl_Signal_Val_in_Metrics_Invoices__c = 'Yes';
        sigRec.Signal_Validation_Complexity__c = 'Simple';
        sigRec.Incl_Signal_Eval_in_Metrics_Invoices__c = 'Yes';
        sigRec.SVF_SM_Specialist__c = testResource.id;
        sigRec.SVF_SM_QC_Reviewer__c = testResource.id;
        sigRec.SER_SM_Specialist__c = testResource.id;
        sigRec.SER_SM_QC_Reviewer__c = testResource.id;
        sigRec.Evaluation_Due_Date__c = Date.newInstance(2021, 3, 4);
        return sigRec;
    }
    
    public static Service_Line__c createSMServiceLine() {
        Service_Line__c serviceline = new Service_Line__c(
            Name = 'Signal Management',
            Active__c=true,
            Service_Line_Code__c = 'SM');
        return serviceline;
    }
    
    public static Service_Line__c createLitrServiceLine() {
        Service_Line__c serviceline = new Service_Line__c(
            Name = 'Literature',
            Active__c=true,
            Service_Line_Code__c = 'LIT');
        return serviceline;
    }
    
    public static Target__c createTarget() {
        Program__c program = UTL_PSA_TestData.programs[0];
        Id targetRecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('Target__c', CON_PSA.TARGET_REC_TYPE_RDS_PRODUCT_LINE);
        Target__c target = new Target__c(
            recordTypeId=targetRecordTypeId,
            Name='Test Target',
            API__c='Test API',
            Strength__c='Super strong',
            Dosage_Form__c='Huge pill',
            Program__c=program.Id,
            Inactivated_Date__c = system.today(),
            Countries_NA__c = true
        );
        return target;
    }
        
    public static PSA_Metric__c createPSAmetric(){
        PSA_Metric__c psaMetric = new PSA_Metric__c(
		Active__c = true,
		Non_Standard__c = true,
		External_Id__c = 'psa metric external id for this test class.',
		Frequency__c = 'Monthly'
		);
		return psaMetric;        
    }

    public static PSA_Metric__c createPSAmetric(Id serviceId, Id serviceLineId){
        PSA_Metric__c psaMetric = new PSA_Metric__c(
		Active__c = true,
		Non_Standard__c = true,
		External_Id__c = 'psa metric external id for this test class.',
		Frequency__c = 'Monthly',
		Service__c = serviceId,
		Service_Line__c = serviceLineId
		);
		return psaMetric;        
    }
    
    public static Project_Metric__c createProjectMetric(Id psaMetric, Id project){
        Project_Metric__c projectMetric = new Project_Metric__c(
            PSA_Metric__c = psaMetric,
            Project__c = project
		);
		return projectMetric;        
    }
    
    public static Project_Metric_Actual__c createProjectMetricActual(Id parentProject, Id projectMetric, Id psaMetric){
        Project_Metric_Actual__c projectMetricActual = new Project_Metric_Actual__c(
            Project__c = parentProject,
            Project_Metric__c = projectMetric,
            PSA_Metric__c = psaMetric,
            Quantity__c = 10,
            Date__c = Date.today(),
            Comments__c = 'test comment'
        );
		return projectMetricActual;        
    }
	
    public static void createSdRun(){
        UTL_PSA_TestData.createPermissionControls();
        
        Program__c program = UTL_PSA_TestData.programs[0];
        Account testAccount = new Account();
        testAccount.name = 'Test Account';
        testAccount.CustomerSegment__c = 'GOVERNMENT';
        testAccount.Sub_Industry__c = 'STATE';
        insert testAccount;
        
        Service_Line__c serviceline = UTL_PSA_TestData.createSMServiceLine();
        insert serviceline;
        
        //service
        Service__c service = new Service__c(Name = 'Test Service');
        service.Service_Code__c = '12345678';
        service.Service_Line__c = serviceline.Id;
        insert service;
        
        //contacts
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        testResource.Location_Code_text__c = 'USDUR1';
        insert testResource;
        
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Program__c = program.id;
        insert parentproject;
        
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        insert project;
        
        Target__c target =UTL_PSA_TestData.createTarget();
        target.Indication__c = 'abcd';
        target.Protocol_Number__c = '1234';
        target.Therapeutic_Area__c = 'Acute Care';
        target.Date_Activated__c = System.today();
        target.Inactivated_Date__c = System.today();
        insert target;
        
         pse__Permission_Control__c pc = new pse__Permission_Control__c();
        pc.CurrencyIsoCode = project.CurrencyIsoCode;
        pc.pse__User__c = UserInfo.getUserId();
        pc.pse__Region__c = project.pse__region__c;
        pc.pse__Cascading_Permission__c = true;
        pc.Unit_Entry_Ops_Edit__c = true;
        pc.pse__Billing__c = true;
        pc.pse__Expense_Entry__c = true;
        pc.pse__Expense_Ops_Edit__c = true;
        pc.pse__Forecast_Edit__c = true;
        pc.pse__Forecast_View__c = true;
        pc.pse__Invoicing__c = true;
        pc.pse__Edit_Task_Manager__c = true;
        pc.pse__View_Task_Manager__c = true;
        pc.pse__Resource_Request_Entry__c = true;
        pc.pse__Skills_And_Certifications_Entry__c = true;
        pc.pse__Skills_And_Certifications_View__c = true;
        pc.pse__Staffing__c = true;
        pc.pse__Timecard_Entry__c = true;
        pc.pse__Timecard_Ops_Edit__c = true;
        pc.Unit_Entry_Ops_Edit__c = true;
        insert pc;

       
        pse__Resource_Request__c resourcerequest = new pse__resource_request__c();
        resourcerequest.CurrencyIsoCode = project.CurrencyIsoCode;
        resourcerequest.pse__Resource_Request_Name__c = 'Test request 1';
        resourcerequest.pse__Project__c = project.id;
        resourcerequest.pse__Start_Date__c = project.pse__start_date__c;
        resourcerequest.pse__End_Date__c = project.pse__start_date__c.addDays(1);
        resourcerequest.pse__Region__c = project.pse__Region__c;
        resourcerequest.pse__Group__c = project.pse__Group__c;
        resourcerequest.pse__Resource_Role__c = CON_PSA.RESOURCE_ROLE_SERVICELINE_LEAD;
        resourcerequest.pse__Requested_Bill_Rate__c = 200.0;
        resourcerequest.pse__SOW_Hours__c = 500;
        resourcerequest.pse__Planned_Bill_Rate__c = 200.0;
        resourcerequest.pse__Notes__c = 'Test';
        resourcerequest.pse__Status__c = CON_PSA.RESOURCE_REQUEST_STATUS_DRAFT;
        resourcerequest.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Resource_Request__c', CON_PSA.RESOURCE_REQUEST_REC_TYPE_RDS_REQUEST); 
        insert resourcerequest;

        pse__Schedule__c sch = new pse__Schedule__c();
        sch.pse__Start_Date__c = project.pse__Start_Date__c;
        sch.pse__End_Date__c = project.pse__End_Date__c;
        sch.pse__Monday_Hours__c = 8;
        sch.pse__Tuesday_Hours__c = 8;
        sch.pse__Wednesday_Hours__c = 8;
        sch.pse__Thursday_Hours__c = 8;
        sch.pse__Friday_Hours__c = 8;
        sch.pse__Saturday_Hours__c = 0;
        sch.pse__Sunday_Hours__c = 0;
        insert sch;
        
        pse__Assignment__c assignment = new pse__assignment__c();
        assignment.pse__Is_Billable__c = project.pse__Is_Billable__c;
        assignment.pse__Bill_Rate__c = (assignment.pse__Is_Billable__c && project.pse__Billing_Type__c == CON_PSA.PROJ_BILL_TYPE_FIXED) ? 200 : 0;
        assignment.pse__Planned_Hours__c = 100;
        assignment.pse__Project__c = project.Id;
        assignment.pse__Resource__c = testResource.id;
        assignment.pse__Role__c = CON_PSA.RESOURCE_ROLE_SERVICELINE_LEAD;
        assignment.pse__Schedule__c = sch.Id;
        assignment.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_SCHEDULED;
        assignment.pse__Time_Credited__c = project.pse__Time_Credited__c;
        assignment.pse__Time_Excluded__c = project.pse__Time_Excluded__c;
        assignment.RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);
        assignment.Primary_Service_Line_Lead__c = true;
        assignment.Active__c = true;
        insert assignment;
        
        SD_Runs__c sdrunRec = new SD_Runs__c();
        sdrunRec.Frequency__c = 'Weekly';
        sdrunRec.Project__c = project.id;
        sdrunRec.Product__c = target.id;
        sdrunRec.Service_Line_Lead__c = testResource.id;
        sdRunRec.Account__c = testAccount.id;
        insert sdrunRec;
        
        try{
            SD_Runs__c sdrunRec1 = new SD_Runs__c();
            sdrunRec1.Frequency__c = 'Weekly';
            sdrunRec1.Project__c = project.id;
            sdrunRec1.Product__c = target.id;
            sdrunRec1.SD_Run_Date_Completed__c = Date.newInstance(2030, 3, 4);
            sdrunRec1.Date_Medical_Review_Completed__c = Date.newInstance(2030, 3, 4);
            sdrunRec1.Date_QC_Completed__c = Date.newInstance(2030, 3, 4);
            sdrunRec1.Date_BRM_Review_Completed__c = Date.newInstance(2030, 3, 4);
            sdrunRec1.SD_Run_Start_Date__c = Date.newInstance(2030, 3, 4);
            sdrunRec1.Service_Line_Lead__c = testResource.id;
            sdrunRec1.SM_Specialist__c = testResource.id;
            sdrunRec1.SM_QC_Reviewer__c = testResource.id;
            sdrunRec1.Service_Line_Lead__c = testResource.id;
            sdrunRec1.Date_Draft_Sent_for_QC__c = Date.today();
            sdrunRec1.Date_QC_Completed__c = Date.today();
            sdrunRec1.Date_Draft_sent_for_Medical_Review__c = Date.today();
            sdrunRec1.Date_Medical_Review_Completed__c = Date.today();
            sdrunRec1.Date_final_Draft_Ready_for_SMT_Review__c = Date.today();
            insert sdrunRec1;
        }
        catch(Exception ex)
        {
            SD_Runs__c sdrunRec2 = new SD_Runs__c();
            sdrunRec2.Frequency__c = 'Weekly';
            sdrunRec2.Project__c = project.id;
            sdrunRec2.Product__c = target.id;
            sdrunRec2.Service_Line_Lead__c = testResource.id;
            sdrunRec2.SM_Specialist__c = testResource.id;
            sdrunRec2.SM_QC_Reviewer__c = testResource.id;
            sdrunRec2.Service_Line_Lead__c = testResource.id;
            sdrunRec2.Date_Draft_Sent_for_QC__c = Date.today();
            sdrunRec2.Date_QC_Completed__c = Date.today();
            sdrunRec2.Date_Draft_sent_for_Medical_Review__c = Date.today();
            sdrunRec2.Date_Medical_Review_Completed__c = Date.today();
            sdrunRec2.Date_final_Draft_Ready_for_SMT_Review__c = Date.today();
            insert sdrunRec2;
        }
    }
    
    public static void createPSSF(){
        UTL_PSA_TestData.createPermissionControls();
        Program__c program = UTL_PSA_TestData.programs[0];
        
        Service_Line__c serviceline = UTL_PSA_TestData.createSMServiceLine();
        insert serviceline;
        
        //contacts
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        testResource.Location_Code_text__c = 'USDUR1';
        insert testResource;
        
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Program__c = program.id;
        insert parentproject;
        
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        insert project;
        
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1',RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct2;
        
        PSA_Event__c psaEvent = new PSA_Event__c();
        psaEvent.RecordTypes__c = 'NA';
        psaEvent.Object__c = 'PSSF__c';
        psaEvent.Planned_Date_Field__c = 'PSSF_Effective_Date__c';
        psaEvent.Primary_Resource_Field__c = 'Service_Line_Lead__c';
        psaEvent.Stakeholder_Fields__c = 'Service_Line_Lead__c';
        psaEvent.Notification_Offset__c = -2;
        psaEvent.Event_Name__c = 'TEST pssf';
        insert psaEvent;
        
        try{
            PSSF__c pssf1 = new PSSF__c();
            pssf1.Prepared_by_IQVIA_SM_Lead__c = testResource.Id;
            pssf1.PSSF_Version__c = 'Draft';
            pssf1.Project_Name__c = project.id;
            pssf1.Account__c =acct2.id;
            pssf1.PSSF_Effective_Date__c = Date.newInstance(2021, 3, 4);
            insert pssf1;
            
            PSSF__c pssf2 = new PSSF__c();
            pssf2.In_Scope__c = 'Yes';
            pssf2.PSSF_Parent__c = pssf1.Id;
            pssf2.Name = 'Company Safety Database';
            insert pssf2;
            
            PSSF__c pssf3 = new PSSF__c();
            pssf3.In_Scope__c = 'Yes';
            pssf3.PSSF_Parent__c = pssf1.Id;
            pssf3.Name = 'Clinical Trial Database';
            insert pssf3;
            
            PSSF__c pssf4 = new PSSF__c();
            pssf4.In_Scope__c = 'Yes';
            pssf4.PSSF_Parent__c = pssf1.Id;
            pssf4.Name = 'Literature';
            insert pssf4;
            
            PSSF__c pssf5 = new PSSF__c();
            pssf5.In_Scope__c = 'Yes';
            pssf5.PSSF_Parent__c = pssf1.Id;
            pssf5.Name = 'Health Authority Websites';
            insert pssf5;
            
            PSSF__c pssf6 = new PSSF__c();
            pssf6.In_Scope__c = 'Yes';
            pssf6.PSSF_Parent__c = pssf1.Id;
            pssf6.Name = 'FAERS';
            insert pssf6;
            
            PSSF__c pssf7 = new PSSF__c();
            pssf7.In_Scope__c = 'Yes';
            pssf7.PSSF_Parent__c = pssf1.Id;
            pssf7.Name = 'Competitors RSI';
            insert pssf7;
            
            PSSF__c pssf8 = new PSSF__c();
            pssf8.In_Scope__c = 'Yes';
            pssf8.PSSF_Parent__c = pssf1.Id;
            pssf8.Name = 'Others1';
            insert pssf8;
            
            PSSF__c pssf9 = new PSSF__c();
            pssf9.In_Scope__c = 'Yes';
            pssf9.PSSF_Parent__c = pssf1.Id;
            pssf9.Name = 'Others2';
            insert pssf9;
            
            PSSF__c pssf10 = new PSSF__c();
            pssf10.In_Scope__c = 'Yes';
            pssf10.PSSF_Parent__c = pssf1.Id;
            pssf10.Name = 'Others3';
            insert pssf10;
            
            PSSF__c pssf11 = new PSSF__c();
            pssf11.In_Scope__c = 'Yes';
            pssf11.PSSF_Parent__c = pssf1.Id;
            pssf11.Name = 'Others4';
            insert pssf11;
            
            PSSF__c pssf12 = new PSSF__c();
            pssf12.In_Scope__c = 'Yes';
            pssf12.PSSF_Parent__c = pssf1.Id;
            pssf12.Name = 'Eudravigilance';
            insert pssf12;
            
            PSSF__c pssf13 = new PSSF__c();
            pssf13.PSSF_Version_when_Implemented__c = 'Yes';
            pssf13.PSSF_Parent__c = pssf1.Id;
            pssf13.Name = 'History Record 0' ;
            pssf13.Is_History_of_Changes_Record__c = true;
            insert pssf13;
            
            PSSF__c pssf14 = new PSSF__c();
            pssf14.PSSF_Version_when_Implemented__c = 'Yes';
            pssf14.PSSF_Parent__c = pssf1.Id;
            pssf14.Name = 'History Record 1' ;
            pssf14.Is_History_of_Changes_Record__c = true;
            insert pssf14;
            
            PSSF__c pssf15 = new PSSF__c();
            pssf15.PSSF_Version_when_Implemented__c = 'Yes';
            pssf15.PSSF_Parent__c = pssf1.Id;
            pssf15.Name = 'History Record 2' ;
            pssf15.Is_History_of_Changes_Record__c = true;
            insert pssf15;
            
            PSSF__c pssf16 = new PSSF__c();
            pssf16.PSSF_Version_when_Implemented__c = 'Yes';
            pssf16.PSSF_Parent__c = pssf1.Id;
            pssf16.Name = 'History Record 3' ;
            pssf16.Is_History_of_Changes_Record__c = true;
            insert pssf16;
        }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false, 'Test');
        }
    }

    public static void createHAWebsite(){
        UTL_PSA_TestData.createPermissionControls();
        
        Program__c program = UTL_PSA_TestData.programs[0];
        
        Service_Line__c serviceline = UTL_PSA_TestData.createSMServiceLine();
        insert serviceline;
        
        //contacts
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        testResource.Location_Code_text__c = 'USDUR1';
        insert testResource;
        
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Program__c = program.id;
        insert parentproject;
        
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        insert project;
        
        Target__c target =UTL_PSA_TestData.createTarget();
        target.Date_Activated__c = System.today();
        target.Inactivated_Date__c = System.today();
        insert target;
        
        HA_Websites_Review__c ha = new HA_Websites_Review__c();
        ha.Project__c = project.id;
        ha.Product__c = target.id;
        ha.Client_marketing_author_in_the_country__c = 'No';
        insert ha;
    }
    
    public static void createARAndRC(){
        UTL_PSA_TestData.createPermissionControls();

        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;

        Service_Line__c serviceline = new Service_Line__c(
            Name = 'Aggregate Reporting',
            Active__c=true,
            Service_Line_Code__c = 'AR');
        insert serviceline;

        //service
        Service__c service = new Service__c(Name = 'Test Service');
        service.Service_Code__c = '12345678';
        service.Service_Line__c = serviceline.Id;
        insert service;

        //contacts
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        testResource.Location_Code_text__c = 'USDUR1';
        insert testResource;


        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Program__c = program.id;
        insert parentproject;

        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        insert project;

        //milestone
        pse__Milestone__c milestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
        milestone.RecordTypeId = milestonerecTypeId;
        milestone.Actual_Quantity__c = 10;
        milestone.Billed_Quantity__c = 15;
        milestone.pse__Project__c = project.Id;
        milestone.pse__Target_Date__c = system.today();
        milestone.Actual_Amount__c = 20;
        milestone.pse__Milestone_Amount__c = 100;
        milestone.Billed_Amount__c = 30;
        milestone.Include_Tasks_on_Deliverables__c = false;
        milestone.Service__c = service.id;
        milestone.Service_Line__c = serviceline.id;
        insert milestone;

        PSA_Event__c psaEvent = new PSA_Event__c();
        psaEvent.RecordTypes__c = 'General_Report';
        psaEvent.Object__c = 'Aggregate_Report__c';
        psaEvent.Planned_Date_Field__c = 'Client_First_Draft_Due__c';
        psaEvent.Primary_Resource_Field__c = 'Primary_Author__c';
        psaEvent.Stakeholder_Fields__c = 'Primary_Author__c';
        psaEvent.Notification_Offset__c = -2;
        psaEvent.Event_Name__c = 'Test Event';
        insert psaEvent;

        pse__Assignment__c assignment = UTL_PSA_TestData.createAssignments(new List<Contact> {testResource},project,false)[0];
        assignment.pse__Bill_Rate__c = 200;
        insert assignment;


        RecordType recordId = [SELECT Id from RecordType where Name='General Report'];
        Aggregate_Report__c ar = new Aggregate_Report__c();
        ar.Project__c = project.Id;
        ar.Client_First_Draft_Due__c = Date.today().addDays(7);
        ar.Primary_Author__c = testResource.Id;
        ar.Project_Files_SMP__c = 'http://salesforce.com';
        ar.Client_Final_Report__c = 'http://salesforce.com';
        ar.Report_Countries_Required__c = 'Yes';
        ar.RecordTypeId = recordId.Id;
        ar.Service_Milestone__c = milestone.Id;
        DAOH_Aggregate_Report.makeReportValid(ar);
        ar.Report_Writing__c = 'IQVIA';
        insert ar;
        
        
        Report_Country__c reportCountry = new Report_Country__c();
        reportCountry.Country__c = 'US';
        reportCountry.Aggregate_Report__c = ar.Id;
        insert reportCountry;
    }
	public static Journals_Main_Catalogue__c createJournalMainCatalogue(){
    	Journals_Main_Catalogue__c journalMainCatalogue=new Journals_Main_Catalogue__c();
        journalMainCatalogue.Journal_Name__c='journal';
        journalMainCatalogue.Name='123';
        journalMainCatalogue.URL__c='www.xyz.com';
        journalMainCatalogue.Periodicity__c='periodicity';
        journalMainCatalogue.Regulatory_requirement__c='Yes';
        journalMainCatalogue.Subscription__c='Yes';
        journalMainCatalogue.Therapeutic_Area__c='Therapeutic Area';
        journalMainCatalogue.Country__c='AF';
        journalMainCatalogue.Paper_Journal__c='Yes';
        return journalMainCatalogue;
    }
    
    public static Search_Strategy__c createSeachStrategyOverview(){
        Date newDate1 = Date.newInstance(2021, 2,22);
        Search_Strategy__c SearchStrategyOverview=new Search_Strategy__c();
        //SearchStrategyOverview.Name='Test Name';
        SearchStrategyOverview.Date_Search_Strategy_got_Client_Approval__c=newDate1;
        return SearchStrategyOverview;
}
    
    public static Archive_Search_Strategy__c createArchiveSeachStrategy(){
        Date newDate1 = System.today()-1;
        Archive_Search_Strategy__c ArchiveSearchStrategyOverview=new Archive_Search_Strategy__c();
        //SearchStrategyOverview.Name='Test Name';
        ArchiveSearchStrategyOverview.Date_Search_Strategy_got_Client_Approval__c=newDate1;
        return ArchiveSearchStrategyOverview;
}
    
    public static Archive_Event_Journal__c createArchiveEventJournal(){
        Date newDate1 = System.today()+1;
        Archive_Event_Journal__c ArchiveEventJournalOverview=new Archive_Event_Journal__c();
        //SearchStrategyOverview.Name='Test Name';
        ArchiveEventJournalOverview.Date_Next_Journal_Search_is_Due__c=newDate1;
        return ArchiveEventJournalOverview;
}

    public static LR_Project_Overview__c createLRProjectOverview(){
        
        // LR Project OverView
        LR_Project_Overview__c LRProjectOverview=new LR_Project_Overview__c();
        LRProjectOverview.Status__c='Assigned - Not Yet Started';
        LRProjectOverview.LR_Type__c ='Local';
        LRProjectOverview.LR_Database__c='DistillerSR';
        LRProjectOverview.Other_LR_Type_Specify__c = 'test';
        LRProjectOverview.Countries_Searched__c ='test';
        LRProjectOverview.Journals_Screened_Reviewed__c = 'test';
        LRProjectOverview.Search_Strategy_Created__c ='Yes';
        return LRProjectOverview;       
    }
    public static Event_Journals__c createEventJournal(){
        Event_Journals__c eventJournal=new Event_Journals__c();
        eventJournal.Name='123';
        eventJournal.Country__c='AF';
        eventJournal.Journal_Name__c='Jou1';
        eventJournal.URL__c='www.xyz.com';
        eventJournal.Periodicity__c='per';
        eventJournal.Regulatory_requirement__c='Yes';
        eventJournal.Subscription__c='Yes';
        eventJournal.Paper_Journal__c='Yes';
        eventJournal.Therapeutic_Area__c='Area';
        eventJournal.QPPV_LPS_Comments__c='Comments';
        eventJournal.Frequency_of_Journal__c='Monthly';
        eventJournal.Other_Journal_Frequency_Specify__c='Other Journal Frequency Specify';
        eventJournal.Date_Initial_Search_Started__c=Date.newInstance(2016, 12, 9);
        eventJournal.Date_Last_Journal_Search_was_Performed__c=Date.newInstance(2021, 12, 9);
        eventJournal.Date_Next_Journal_Search_is_Due__c=System.today();
        eventJournal.Active__c='No';
        eventJournal.Inactive_since__c=Date.newInstance(2016, 12, 9);
        return eventJournal;
    }
    
    public static LR_Search_Strategy_Relationship__c createLRSearchStrategyRelationship(){
        LR_Search_Strategy_Relationship__c lrssList = new LR_Search_Strategy_Relationship__c();
        lrssList.Name = '12';
        return lrssList;
    }
    
    public static LR_Event_Journals_Relationship__c createLREventJournalRelationship(){
        LR_Event_Journals_Relationship__c lrEJList = new LR_Event_Journals_Relationship__c();
        lrEJList.Name = '123';
        return lrEJList;
    }
    
    public static CFI_Meetings__c createCfiMeetings(){
        CFI_Meetings__c cfi = new CFI_Meetings__c();
        cfi.Date_Held__c =Date.newInstance(2016, 12, 9);
        return cfi;
    }
    
    public static Address__c createAddress(){
        Address__c addr = new Address__c();
        addr.Name = 'test Address';
        addr.SAP_Validation_Status__c = 'Validated';
        addr.SAP_Reference__c = '0123456789';
        return addr;
    }
}