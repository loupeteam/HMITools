(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: HMI_Basic
 * File: HMI_FindCurrentTab.st
 * Author: David
 * Created: May 17, 2011
 ********************************************************************
 * Implementation of library HMI_Basic
 ********************************************************************) 


(****************************************************************************************)
(* Function to find the current primary and secondary tab based on the current page 	*)
(****************************************************************************************)


(* Setting CurrentPrimaryTab		DONE and TESTED DFB 20110519 *)
(* Setting CurrentSecondaryTab		DONE and TESTED DFB 20110519 *)


FUNCTION HMI_FindCurrentTab


(****************************************************)
(* Set return value to get rid of compile warning 	*)
(****************************************************)

HMI_FindCurrentTab:=	FALSE;


(* Loop through primary and secondary tabs. 
	If the current page matches a secondary page,
	set the secondary tab accordingly.
	If a match is not found, do nothing. *) 

(* 0 IS NOT A VALID TAB PAGE INDEX *)
	

FOR p:=0 TO HMI_MAI_TABS BY 1 DO
	
	FOR ss:=0 TO HMI_MAI_TABS BY 1 DO
 	
	
		IF( 	(t.PageCurrentDP = t.Tabs.PrimaryTabArray[p].SecondaryTabArray[ss].PageIndex)
			AND	(t.Tabs.PrimaryTabArray[p].SecondaryTabArray[ss].PageIndex <> 0)
   			)THEN
  			
			
			t.Tabs.CurrentPrimaryTab:=	p;
			
			t.Tabs.PrimaryTabArray[p].CurrentSecondaryTab:=	ss;
			
			RETURN;
   		
		
		END_IF

	
	END_FOR
	
END_FOR


END_FUNCTION
