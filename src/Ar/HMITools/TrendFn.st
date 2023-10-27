(*
 * File: TrendFn.st
 * Copyright (c) 2023 Loupe
 * https://loupe.team
 * 
 * This file is part of HMITools, licensed under the MIT License.
 * 
  ********************************************************************
 * Implementation of library HMITools
 ********************************************************************) 


(************************************************************************************************************)
(* Function for controlling a trend object. Function should be called in the Init and Cyclic subroutines.	*)
(************************************************************************************************************)


(* Functionality		DONE and TESTED DFB *)


FUNCTION TrendFn

	
(************************************************************)
(* Set return value to get rid of compile warning 			*)
(************************************************************)

TrendFn:=	FALSE;


(************************************)
(* Call ZoomScroll FUBs 			*)
(************************************)


(* Trend *)

t.GlobalXZoomScroll();
t.GlobalYZoomScroll();


(* TimeContainer *)

t.TimeContainer.ZoomScroll();


(* ValueScale *)

FOR i:=0 TO HMI_TREND_MAI_VALUESCALE BY 1 DO
	
	t.ValueScale[i].ZoomScroll();
	
END_FOR


END_FUNCTION
