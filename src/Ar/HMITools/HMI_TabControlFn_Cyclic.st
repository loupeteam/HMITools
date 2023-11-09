(*
* File: HMI_TabControlFn_Cyclic.st
* Copyright (c) 2023 Loupe
* https://loupe.team
* 
* This file is part of HMITools, licensed under the MIT License.
* 
*) 


(********************************************************************)
(* Handle tab based page switching 									*)
(********************************************************************)


(* Finding current tab						see HMI_FindCurrentTab.st *)

(* Primary tab changes						DONE and TESTED DFB 20110729 *)
	(* Changing within a group				DONE and TESTED DFB 20110729 *)
	(* Changing outside a group				DONE and TESTED DFB 20110729 *)
		(* From group to no group			DONE and TESTED DFB 20110729 *)
		(* From no group to group			DONE and TESTED DFB 20110729 *)
		(* From no group to no group		DONE and TESTED DFB 20110729 *)
	(* PageIndex = 0						DONE and TESTED DFB 20110729 *)

(* Secondary tab changes					DONE and TESTED DFB 20110729 *)

(* Clearing inappropriate SecondaryTabs		DONE and TESTED DFB 20110729 *)

(* Checking for no tabs active				DONE and TESTED DFB 20110729 *)
	(* Primary								DONE and TESTED DFB 20110729 *)
	(* Secondary							DONE and TESTED DFB 20110729 *)

(* Implementation with HMI					DONE and TESTED DFB 20110801 *)

(* Allowing external page changes			DONE and TESTED DFB 20110801 *)



FUNCTION HMI_TabControlFn_Cyclic
	

(********************************************************************************)
(* NOTE: THIS FUNCTION MUST RUN IN CYCLIC 8 WITH A CYCLE TIME < ~50ms			*)
(********************************************************************************)


(****************************************************)
(* Set return value to get rid of compile warning 	*)
(****************************************************)

HMI_TabControlFn_Cyclic:=	FALSE;

	
(****************************************************)
(* Find the current tab 							*)
(****************************************************)

HMI_FindCurrentTab( t );


(****************************************************)
(* Handle external page changes						*)
(****************************************************)


(* Check for ChangePage active *)

IF( 	(t.PageChangeDP <> 65535) 
	AND	(t.PageChangeDP <> 0)
 	)THEN


	(* If ChangePage is active, then reset 
		Current tab CMDs and do not execute rest of fn *)

	t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab].ChangeToPrimaryTab:=	0;
				
	t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab]
			.SecondaryTabArray[t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab].CurrentSecondaryTab]
			.ChangeToSecondaryTab:=	0;
			
	RETURN;


END_IF

		
(****************************************************)
(* Handle primary tab page changes 					*)
(****************************************************)

FOR p:=0 TO HMI_MAI_TABS BY 1 DO
	
	
	(* Do not check the CurrentPrimaryTab *)
	
	IF( p <> t.Tabs.CurrentPrimaryTab )THEN
	
	
		(* If a NEW primary tab is chosen, then reset current primary tab and change page *)
	
		IF( t.Tabs.PrimaryTabArray[p].ChangeToPrimaryTab )THEN
			
		
			//t.Tabs.PrimaryTabArray[p].ChangeToPrimaryTab:=	0;
			
			
			(* If desired tab (p) is in a group, and you are in that group, 
				change to the CurrentPrimaryTab's CurrentSecondaryTab *)
		
			IF( 	(t.Tabs.PrimaryTabArray[p].Group <> 0)
				AND	(t.Tabs.PrimaryTabArray[p].Group = t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab].Group)
				)THEN
			
				SecondaryTabIndex:=	t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab].CurrentSecondaryTab;

		
			(* Otherwise, change to the desired primary tab's (p) CurrentSecondaryTab *)
		
			ELSE
			
				SecondaryTabIndex:=	t.Tabs.PrimaryTabArray[p].CurrentSecondaryTab;
						
			END_IF
		
		
			(* Change to the correct secondary tab if it has a valid PageIndex and you are not already there *)
		
			IF( 	(t.Tabs.PrimaryTabArray[p].SecondaryTabArray[SecondaryTabIndex].PageIndex <> 0)
				AND	(t.Tabs.PrimaryTabArray[p].SecondaryTabArray[SecondaryTabIndex].PageIndex <> t.PageCurrentDP)
				)THEN
  				
				
				(* Change Page and set Tab CMDs accordingly *)
				
				t.PageChangeDP:=	
					t.Tabs.PrimaryTabArray[p].SecondaryTabArray[SecondaryTabIndex].PageIndex;
					
				
				(* Set current secondary tab *)
				
				t.Tabs.PrimaryTabArray[p]
						.SecondaryTabArray[SecondaryTabIndex]
						.ChangeToSecondaryTab:=	1;
				
				
				(* Reset previous primary and secondary tab *)
				
				t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab].ChangeToPrimaryTab:=	0;
				
				t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab]
						.SecondaryTabArray[t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab].CurrentSecondaryTab]
						.ChangeToSecondaryTab:=	0;
			
			
			ELSE
					
				
				(* Error - Reset CMD and do nothing *)
				
				t.Tabs.PrimaryTabArray[p].ChangeToPrimaryTab:=	0;
			
				
			END_IF // ChangePage
		
			RETURN;
		
		END_IF // ChangeToPrimaryTab
	
	END_IF // Not CurrentPrimaryTab
	

END_FOR


(****************************************************)
(* Handle secondary tab page changes 				*)
(****************************************************)


(* Loop through CurrentPrimaryTab's secondary tabs to look for commands *)

FOR ss:=0 TO HMI_MAI_TABS BY 1 DO
	
	
	(* Do not check the current secondary tab *)
	
	IF( ss <> t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab].CurrentSecondaryTab )THEN
 	
	
		(* If a NEW secondary tab is chosen, then reset current secondary tab and change page *)
	
		IF( t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab].SecondaryTabArray[ss].ChangeToSecondaryTab )THEN
 
			
			//t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab].SecondaryTabArray[ss].ChangeToSecondaryTab:=	0;
		
		
			(* Change to the correct secondary tab if it has a valid PageIndex and you are not already there *)
		
			IF( 	(t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab].SecondaryTabArray[ss].PageIndex <> 0)
				AND	(t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab].SecondaryTabArray[ss].PageIndex <> t.PageCurrentDP)
				)THEN
				
				
				(* Change page and reset previous secondary tab CMD (CurrentPrimaryTab.CurrentSecondaryTab) *)
				
				t.PageChangeDP:=	t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab].SecondaryTabArray[ss].PageIndex;
				
				t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab]
						.SecondaryTabArray[t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab].CurrentSecondaryTab]
						.ChangeToSecondaryTab:=	0;
			
			
			ELSE
					
			
				(* Error - Reset CMD and do nothing *)
				
				t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab].SecondaryTabArray[ss].ChangeToSecondaryTab:=	0;
			
			
			END_IF // ChangePage
		
			RETURN; 		
		
		
		END_IF // new tab CMD
		
	END_IF // not CurrentSecondaryTab
	
END_FOR


(****************************************************)
(* Clear inactive Primary Tabs' Secondary Tabs		*)
(****************************************************)

FOR p:=0 TO HMI_MAI_TABS BY 1 DO


	(* Do not check the CurrentPrimaryTab *)
	
	IF( p <> t.Tabs.CurrentPrimaryTab )THEN
		
		FOR ss:=0 TO HMI_MAI_TABS BY 1 DO
			
			
			(* Clear ChangeToSecondaryTab *)
			
			t.Tabs.PrimaryTabArray[p].SecondaryTabArray[ss].ChangeToSecondaryTab:=	0;
	
	
		END_FOR (* Secondary tabs *)
		
	END_IF (* not current Primary *)
	
	
END_FOR (* Primary tabs *)
	

(****************************************************)
(* Check for 'no tab' condition						*)
(****************************************************)


(* Primary *)

PrimaryActive:=	0;

FOR p:=0 TO HMI_MAI_TABS BY 1 DO
	
	PrimaryActive:=	PrimaryActive OR t.Tabs.PrimaryTabArray[p].ChangeToPrimaryTab;
	
END_FOR


(* If no tab is active, make the current tab active *)

IF( NOT(PrimaryActive) )THEN

	t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab].ChangeToPrimaryTab:=	1;

END_IF


(* Secondary *)

SecondaryActive:=	0;

FOR ss:=0 TO HMI_MAI_TABS BY 1 DO
	
	SecondaryActive:=	SecondaryActive OR t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab].SecondaryTabArray[ss].ChangeToSecondaryTab;
	
END_FOR


(* If no tab is active, make the current tab active *)

IF( NOT(SecondaryActive) )THEN

	t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab]
			.SecondaryTabArray[t.Tabs.PrimaryTabArray[t.Tabs.CurrentPrimaryTab].CurrentSecondaryTab]
			.ChangeToSecondaryTab:=	1;

END_IF


END_FUNCTION
