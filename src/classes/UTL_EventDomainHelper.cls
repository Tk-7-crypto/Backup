/**
 * Utility to help with handling salesforce platform events from
 * an apex trigger context
 *
 * ----------------------------------------------------------------------------
 * Date Modified             Modified By             Description of the update
 * ----------------------------------------------------------------------------
 * 21 May 2020               CLD                 		 Initial Version
 */
public with sharing class UTL_EventDomainHelper {

  /**
   * Process the Platform Event Apex Trigger context
   *
   * Method constructs the given Domain class with the current Platform Event Trigger context
	 * before calling the applicable override methods such as afterInsert
   *
   * Inteneded to be called from a trigger, e.g.
   *  UTL_EventDomainHelper.triggerPlatformEventHandler(DAO_Project_Task_ChangeEvent.class);
   */
  public static void triggerPlatformEventHandler(Type domainClass) {
    Boolean isAfter = Trigger.isAfter;
    Boolean isInsert = Trigger.isInsert;
    List<SObject> newRecords = Trigger.new;

    // Create the domain class
    String domainClassName = domainClass.getName();
    Type constructableClass = domainClassName.endsWith('Constructor') ? Type.forName(domainClassName) : Type.forName(domainClassName+'.Constructor');
    fflib_SObjectDomain.IConstructable domainConstructor = (fflib_SObjectDomain.IConstructable) constructableClass.newInstance();
    fflib_SObjectDomain domainObject = domainConstructor.construct(newRecords);

		// has this event been disabled?
		if(!fflib_SObjectDomain.getTriggerEvent(domainClass).isEnabled(false, isAfter, isInsert, false, false, false)) {
			return;
    }

    // Invoke the applicable handler (!AFTER INSERT ONLY!)
		if(isAfter && isInsert) {
      domainObject.handleAfterInsert();
	  }
  }

}