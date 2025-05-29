/*
 * This Class is used to stop setting default Agreement name using Trigger
 * This Class is used to stop some Triggrs to be executed unnecessary on Agreement line item
 */
Public Class SCM_Static_FlagClass{
    public static Boolean AllowTriggerTOsetDefaultName= true ; 
    public static Boolean AllowTriggerToExecute = true ;
    public static Boolean AllowTriggerOnAGLIToExecute = false;
    // Added by Sandeep 14 Feb 2013 for issue #1714, ( To avoid cyclic trigegr between AGLI & OLI for to keep in sync)
    public static Boolean toAllowAGLICyclicTriggerWithOLI = true;
}