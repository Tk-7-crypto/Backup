/**
 * This is Data Trim Account/Contact Sharing VF Page controller class.
 * version : 1.0
 */
public without sharing class AddAccountTeamMemberController 
{
    public Boolean VisibleFlag{get;set;}
    public Boolean AccFlag{get;set;}
    public Boolean ConFlag{get;set;}
    public List<Contact> ListCon {get;set;}
    public List<Account> ListAcc {get;set;}
    public Contact Con {get;set;}
    public Account Acc {get;set;}
    public AccountTeamMember teamMember{get; set;}
    private static string ERROR = 'Some unexpected error occurred. Cannot perform the Opertaion.';
    private static string READ = 'Read';
    private static string ROWCAUSE_TEAM = 'Team';
    private static string ATMAdded_ERROR = 'This Record has already been shared Please Contact Admins.';
    
    /**
     * This is the default constructor for this apex class
     */
    public AddAccountTeamMemberController() {
        VisibleFlag = False;
        ConFlag = False;
        AccFlag = False;
        string param = ApexPages.currentPage().getParameters().get('id');
        if(!String.isblank(param)) {
            VisibleFlag = True ;
            if(param.SubString(0,3) == '003') {
                ConFlag = True;
                ListCon = [select id,firstname,lastname,name,email,accountId,Account.Name from Contact where id = : param];
                if(ListCon.size() > 0) {
                    Con= ListCon.get(0);
                    teamMember = new AccountTeamMember(TeamMemberRole = 'OTHER', AccountId = Con.AccountId,UserId = Userinfo.getUserID());
                } else {
                    VisibleFlag = False;
                    ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.INFO , 'No Such Contact exists');
                    ApexPages.addMessage(infoMsg);
                }
            }
            if(param.SubString(0,3) == '001') {
                AccFlag = TRUE;
                ListAcc = [select id,Name,AccountCountry__c,SAPID__c,Owner.Name from Account where id = : param];
                if(ListAcc.size() > 0) {
                    Acc= ListAcc.get(0);
                    teamMember = new AccountTeamMember(TeamMemberRole = 'OTHER', AccountId = Acc.Id,UserId = Userinfo.getUserID());
                } else {
                    VisibleFlag = False;
                    ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.INFO , 'No Such Account exists');
                    ApexPages.addMessage(infoMsg);
                }
            }
        } else {
            //VisibleFlag = False;
            ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.INFO , 'Parameter RecordId is missing');
            ApexPages.addMessage(infoMsg);
        }  
    }
    
    /**
     * This method is used to add a record in the Account/Contact Team Member.
     * @return PageReference : Return to the current page
     */
    public pageReference addATM() {
        List<AccountTeamMember> tempLst = new List<AccountTeamMember> ();
        //Check if User is already an existing Account Team Member
        if(ConFlag)
            tempLst = [Select id From AccountTeamMember where UserId = :Userinfo.getUserID() And AccountId = :Con.Accountid];
        if(AccFlag)
            tempLst = [Select id From AccountTeamMember where UserId = :Userinfo.getUserID() And AccountId = :Acc.id];
        if(tempLst.size() == 0) {
            try {
                insert teamMember;
                // updating the Account Share 
                //for(AccountShare share : [select Id, OpportunityAccessLevel, RowCause from AccountShare where AccountId = :Con.AccountId and RowCause = :ROWCAUSE_TEAM and  UserOrGroupId =   :teamMember.UserId])
                List<AccountShare> shareList = new List<AccountShare>();
                shareList = [select Id, OpportunityAccessLevel, RowCause from AccountShare where id=:teamMember.Id];
                for(AccountShare share : shareList){
                   share.AccountAccessLevel = READ;
                   update share;
                }
                
            } catch(DmlException e) {
                ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.INFO , ERROR);
                ApexPages.addMessage(infoMsg);
                return null;
            }
            return null;
        } else  {
            VisibleFlag= False;
            ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.INFO , ATMAdded_ERROR);
            ApexPages.addMessage(infoMsg);
            return null;
        }
    }
    
    /**
     * This method is used to cancel any change being made on the page and return to the previous stage.
     * @return PageReference : Return to the previous page
     */
    public PageReference cancel() {
        if(ApexPages.currentPage().getParameters().get('id').SubString(0,3) == '001')
            return new pageReference('/apex/DataTrimEntryCheck_Custom?obj=001');
        if(ApexPages.currentPage().getParameters().get('id').SubString(0,3) == '003')
            return new pageReference('/apex/DataTrimEntryCheck_Custom?obj=003');
        else
            return new pageReference('/apex/DataTrimEntryCheck_Custom');           
    }
}