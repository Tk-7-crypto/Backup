public class BidTeamDashboardController {

    public List<Bid_Team_Credit__c> wnihList {get; private set;}
    public List<Bid_Team_Credit__c> rihList {get; private set;}
    public List<Bid_Team_Credit__c> pipelineList {get; private set;}
    public String userId {get;set;}
    
    public User currentUser {get; private set;}
    
    //using opportunity object's Amount field to be bound to 
    //outputfield for showing totals
    public Opportunity wnihTotal {get; private set;}
    public Opportunity rihRecognizedTotal {get; private set;}
    public Opportunity rihUnRecognizedTotal {get; private set;}
    public Opportunity pipelineTotal{get; private set;}
    public Opportunity pipeline5Total{get; private set;}
    public Opportunity pipeline1To4Total{get; private set;}
    
    public Boolean hasErrMsg {get; private set;}
    public String refreshDate {get; private set;}
    
    public BidTeamDashboardController(){
        userId = '';
        reInitialize();
    }
    
    public PageReference updateRunAsUser()
    {  
        if(userId != null && userId != '') {
            reInitialize();
        }
        return null;
    }
    
    private void reInitialize() {
        
        Id currentUserid = Userinfo.getUserId(); //Current User's Id is fetched
               
        
        Profile P = [select Id,Name from Profile where Id = :userInfo.getProfileId()];
        //check for system administrator so that he/she can view any other users dashboard using runasid
        /*if (ApexPages.currentPage().getParameters().get('runasid') != null && P.Name.toLowerCase().contains('system administrator'))
        { 
            currentUserId = ApexPages.currentPage().getParameters().get('runasid');
        }*/
        
        if (userId != null && userId != '' && P.Name.toLowerCase().contains('system administrator'))
        { 
            //when any other user's dashboard can be viewed make it the current user in case of system admin & runasid parameter present
            //currentUserId = ApexPages.currentPage().getParameters().get('runasid');
            currentUserId = userId;
        }
        
        //retreive the details of current user
        currentUser = [select Id,Name,Bid_Team_Target__c, PIC_Eligible__c from User where Id = :CurrentUserId]; 
        BidTeamDashboardSettings__c dashboardLocked = BidTeamDashboardSettings__c.getOrgDefaults();
        if(dashboardLocked.DashboardLocked__c)
        {   
            hasErrMsg = true;         
            String error = dashboardLocked.Locked_Message__c + '<br/><br/><a  href="/home/home.jsp" target="_parent">Click here to return to the homepage</a>';
            ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.INFO , error );
            ApexPages.addMessage(infoMsg);
            return;
        }
        
        //Principal_In_Charge__c[] PIC = [select Id from Principal_In_Charge__c where User__c = :this.CurrentUser.Id];             
        if ((!currentUser.PIC_Eligible__c) || currentUser.Bid_Team_Target__c == null || currentUser.Bid_Team_Target__c <= 0){
            String msg = 'To display your Personal Dashboard additional information is required – Please contact your C&S operations team who will be able to help you.';
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, msg);                        
            ApexPages.addMessage(errMsg);
            hasErrMsg = true;
            return;
        }        
        
        pipelineList = [select Stage__c,Opportunity__r.Opportunity_Number__c,Opportunity__r.Account.Name,
                        Opportunity__r.Name,FY_Impact__c,Opportunity__r.CloseDate from Bid_Team_Credit__c 
                        where Stage__c in ('1','2','3','4','5') and Bid_Team_Member__c =:CurrentUserId
                        order by Stage__c desc nulls last,Opportunity__r.Opportunity_Number__c desc nulls last];
        
        rihList = [select Opportunity__r.Opportunity_Number__c,Opportunity__r.Account.Name,
                   Opportunity__r.Name, C_S_Recognised_Revenue__c, C_S_Unrecognised_Revenue__c,
                   Opportunity__r.Actual_Close_Date__c from Bid_Team_Credit__c where Stage__c = 'RIH'
                   and Bid_Team_Member__c =:CurrentUserId
                   order by Opportunity__r.Opportunity_Number__c desc nulls last];
        
        wnihList = [select Stage__c,Opportunity__r.Opportunity_Number__c,Opportunity__r.Account.Name,
                    Opportunity__r.Name,FY_Impact__c,Opportunity__r.Actual_Close_Date__c,Opportunity__r.AccountId 
                    from Bid_Team_Credit__c where Stage__c = '6' and Bid_Team_Member__c =:CurrentUserId
                    order by Opportunity__r.Opportunity_Number__c desc nulls last];
                    
       //sum group by stages
       
       List<AggregateResult> resList = [select SUM(FY_Impact__c) fyiSum , SUM(C_S_Recognised_Revenue__c) rSum, 
                      SUM(C_S_Unrecognised_Revenue__c) urSum, Stage__c
                      from Bid_Team_Credit__c where Bid_Team_Member__c =:CurrentUserId group by Stage__c ];
       
       wnihTotal = new Opportunity();
       wnihTotal.currencyISOCode = 'USD';
       wnihTotal.amount = 0.0;
       
       rihRecognizedTotal = new Opportunity();
       rihRecognizedTotal.currencyISOCode = 'USD';
       rihRecognizedTotal.amount = 0.0;
       
       rihUnRecognizedTotal = new Opportunity();
       rihUnRecognizedTotal.currencyISOCode = 'USD';
       rihUnRecognizedTotal.amount = 0.0;
       
       pipelineTotal = new Opportunity();
       pipelineTotal.currencyISOCode = 'USD';
       pipelineTotal.amount = 0.0;
       
       pipeline5Total = new Opportunity();
       pipeline5Total.currencyISOCode = 'USD';
       pipeline5Total.amount = 0.0;
       
       pipeline1To4Total = new Opportunity();
       pipeline1To4Total.currencyISOCode = 'USD';
       pipeline1To4Total.amount = 0.0;
       
       for(AggregateResult ag : resList){
            string stgStr = (String)ag.get('Stage__c');
            if(stgStr == '1' || stgStr == '2' || stgStr == '3' || stgStr == '4' || stgStr == '5') {
                pipelineTotal.amount += (decimal)ag.get('fyiSum');
                if(stgStr == '5') {
                    pipeline5Total.amount += (decimal)ag.get('fyiSum');
                }else{
                    pipeline1To4Total.amount += (decimal)ag.get('fyiSum');
                }
            } 
            if (stgStr == '6'){
                wnihTotal.amount += (decimal)ag.get('fyiSum');
            } 
            if(stgStr == 'RIH'){
                rihRecognizedTotal.amount += (decimal)ag.get('rSum');
                rihUnRecognizedTotal.amount += (decimal)ag.get('urSum');
            }
           
       }
       
       //set refresh date
       List<Bid_Team_Credit__c> bidTeamCreditList = [select LastModifiedDate from Bid_Team_Credit__c order by LastModifiedDate desc limit 1];
       if(bidTeamCreditList.size() > 0 ) {
           refreshDate = bidTeamCreditList[0].LastModifiedDate.addDays(-1).format('EEE d MMM yyyy');    
       } else {
           refreshDate = null;
       }
       //refreshDate = [select LastModifiedDate from Bid_Team_Credit__c order by LastModifiedDate desc limit 1][0].LastModifiedDate.addDays(-1).format('EEE d MMM yyyy');
        
    }
    //formatted amounts 
    public String getRecognisedTotal()
    {
        if(rihRecognizedTotal == null || rihRecognizedTotal.amount == null) return '';
        return rihRecognizedTotal.amount.format();
    }

    public String getUnRecognisedTotal()
    {
        if(rihUnRecognizedTotal == null || rihUnRecognizedTotal.amount == null) return '';
        return rihUnRecognizedTotal.amount.format();
    }
    
    public String getWnihTotalAmount()
    {
        if(wnihTotal == null || wnihTotal.amount == null) return '';
        return wnihTotal.amount.format();
    }
    
    public String getPipelineTotalAmount()
    {
        if(pipelineTotal == null || pipelineTotal.amount == null) return '';
        return pipelineTotal.amount.format();
    }
    
    public String getPipeline5TotalAmount()
    {
        if(pipeline5Total == null || pipeline5Total.amount == null) return '';
        return pipeline5Total.amount.format();
    }
    
    public String getPipeline1To4TotalAmount()
    {
        if(pipeline1To4Total == null || pipeline1To4Total.amount == null) return '';
        return pipeline1To4Total.amount.format();
    }
    
    public String getBidTeamTargetAmount()
    {
        if(currentUser.Bid_Team_Target__c == null || currentUser.Bid_Team_Target__c < 1) return '0';
        return currentUser.Bid_Team_Target__c.format();
    }
    
    public String getRihVsTargetPercentage()
    {
        if(currentUser.Bid_Team_Target__c == null || currentUser.Bid_Team_Target__c < 1) return 'N/A';
        return ((rihRecognizedTotal.amount + rihUnRecognizedTotal.amount)/this.currentUser.Bid_Team_Target__c*100).round().intValue().format() + '%';
    }
    
    public String getPipelineToGoPercentage()
    {
        //TODO: null check
        Decimal ToGo = this.currentUser.Bid_Team_Target__c - (rihRecognizedTotal.amount + rihUnRecognizedTotal.amount);
        Decimal Pipeline = wnihTotal.amount + pipelineTotal.amount;
        if (ToGo <= 0)
        {
                return 'N/A';
        }
        else
        {
                return (Pipeline*100/ToGo).round().intValue().format() + '%';
        }
    }
    
    public Decimal getBidTeamTarget()
    {
        return this.currentUser.Bid_Team_Target__c;
    }


}