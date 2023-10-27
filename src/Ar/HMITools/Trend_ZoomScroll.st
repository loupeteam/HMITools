(********************************************************************
 * COPYRIGHT -- Automation Resources Group
 ********************************************************************
 * Library: HMITools
 * File: Trend_ZoomScroll.st
 * Author: David
 * Created: October 25, 2010
 ********************************************************************
 * Implementation of library HMITools
 ********************************************************************) 


(********************************************************************)
(* Smart handling of trend zooming and scaling 						*)
(********************************************************************)


(* Functionality			DONE and TESTED DFB *)


FUNCTION_BLOCK Trend_ZoomScroll
	

	(* Initialize values on startup *)
	
	IF( NOT(Init) )THEN
 
 		Init:=	1;
		Reset:=	1;
		
	END_IF
	
	
	(* Reset *)
	
	IF( Reset )THEN
 
 		Reset:=		0;	
	
		ZoomDP:=	1;
		ScrollDP:=	0;
		ModeDP:=	1;
		
	END_IF
	
	
	(* Zoom *)
	
	
	(* Check ZoomBase *)
	
	IF( ZoomBase < 1 )THEN
 
 		
		(* If ZoomBase is less than 1, this will cause problems. 
			Default to a ZoomBase of 1. This cancels out all Zooming *)
		
 		ZoomBase:=	1; 
		
		
	END_IF	
	
	
	IF( ZoomIn )THEN
 
 		ZoomIn:=	0;
		
		Midpt:=		ScrollDP + (0.5 / ZoomDP);	(* Midpt is ScrollDP (StartPt_curr) + Range_curr/2; Range_curr is 1/ZoomDP_curr *)
		ZoomDP:=	ZoomDP * ZoomBase; 			(* Zoom is increased by ZoomBase *)
		ScrollDP:=	Midpt - (0.5 / ZoomDP);		(* New Scroll is Midpt - Range_new/2; Range_new is 1/ZoomDP_new *)
		
	END_IF
	
	
	IF( ZoomOut )THEN
 
 		ZoomOut:=	0;

		Midpt:=		ScrollDP + (0.5 / ZoomDP);	(* Midpt is ScrollDP (StartPt_curr) + Range_curr/2; Range_curr is 1/ZoomDP_curr *)
		ZoomDP:=	ZoomDP / ZoomBase; 			(* Zoom is decreased by ZoomBase *)
		ScrollDP:=	Midpt - (0.5 / ZoomDP);		(* New Scroll is Midpt - Range_new/2; Range_new is 1/ZoomDP_new *)
		
	END_IF	
		
		
	(* Scroll *)
	
	
	(* Check ScrollBase *)
	
	IF( ScrollBase < 0 )THEN
 
 		
		(* If ScrollBase is less than 0, this will cause problems. 
			Default to a ScrollBase of 0. This cancels out all Scrolling *)
		
 		ScrollBase:=	0; 
		
		
	END_IF	
	
	
	IF( ScrollNeg )THEN
 
 		ScrollNeg:=	0;
		
		ScrollDP:=	ScrollDP - ScrollBase / ZoomDP;	(* Decrease ScrollDP by percentage (ScrollBase) of Range. Range is 1/ZoomDP *)
		
	END_IF
	
	
	IF( ScrollPos )THEN
 
 		ScrollPos:=	0;

		ScrollDP:=	ScrollDP + ScrollBase / ZoomDP; (* Increase ScrollDP by percentage (ScrollBase) of Range. Range is 1/ZoomDP *)
		
	END_IF	
		

END_FUNCTION_BLOCK
