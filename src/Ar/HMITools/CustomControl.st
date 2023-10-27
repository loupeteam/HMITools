(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: HMITools
 * File: ControlTouch.st
 * Author: Josh
 * Created: November 09, 2012
 ********************************************************************
 * Implementation of library HMITools
 ********************************************************************) 

(* TODO: Add your comment here *)
FUNCTION ControlTouch
	
	ControlTouch:=0;
	
	State:= BOOL_TO_UINT(StatusDP.4)+BOOL_TO_UINT(StatusDP.5)*2;
	
	CASE State OF

		0:
			StatusDP.1:=1;
			IF StatusDP.13 = 1 THEN
				StatusDP.13:=0;
				//set state
				StatusDP.4:=1;
			END_IF
		1:			
			StatusDP.1:=1;
			ControlTouch:=1;

			IF StatusDP.13 = 1 THEN
				StatusDP.13:=0;
				StatusDP.1:=0;
				//set state
				StatusDP.4:=0;
				StatusDP.5:=1;
				StatusDP.3:=1;
			END_IF

		2:
			IF StatusDP.12 = 1 THEN
				StatusDP.4:=1;
				StatusDP.5:=1;				
			END_IF
			
		3:	
			IF StatusDP.12 = 0 THEN
				StatusDP.4:=0;
				StatusDP.5:=0;				
			END_IF
			
	END_CASE
	
END_FUNCTION

FUNCTION ControlDismiss
	
	ControlDismiss:=0;
	
	StatusDP.4:=0;
	StatusDP.5:=0;
	
END_FUNCTION