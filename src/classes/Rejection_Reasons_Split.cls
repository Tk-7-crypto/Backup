/*********************
Create by : Himanshu Parashar
Date : 29 nov 2012
This class split rejection reasons in Email template
***************************/
public class Rejection_Reasons_Split {
    
    public String  Rejectionstring{get;set;}
    public String  Rejection_SD_Message{get;set;}
    
    public Rejection_Reasons_Split()
    {
        
    }
    
    //Setter for Rejection strings
    public void setRejectionstring(String s)
    {
        Rejectionstring=s;
    }
    
    //Getter for Rejection strings
    public string getRejectionstring()
    {
      return this.Rejectionstring;
    }
    
    //Setter for Rejection SD Error Message
    public void setRejection_SD_Message(String s)
    {
        Rejection_SD_Message=s; 
    }
    
    //Getter for Rejection SD Error Message
    public string getRejection_SD_Message()
    {
        return this.Rejection_SD_Message;
    }
    
    // Getter for Rejection reasons
    public String[] getRejection_Reasons()
    {
        if(Rejectionstring!=null)
            return Rejectionstring.split('\\|');
        else
            return null;
    }
    
     // Getter for Rejection reasons
    public String getRejection_SD_Error_Message()
    {
        if(Rejection_SD_Message!=null)
            return Rejection_SD_Message.replaceall('\n','<br/>');
        else
            return null;
    }
     
    
}