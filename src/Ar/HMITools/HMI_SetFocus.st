(*
* File: HMI_SetFocus.st
* Copyright (c) 2023 Loupe
* https://loupe.team
* 
* This file is part of HMITools, licensed under the MIT License.
* 
*) 


(********************************************************************)
(* Sets the focus for an item on the screen. FOCUS MUST BE RESET!	*)
(********************************************************************)


(* Function			DONE and TESTED DFB 20110504 *)


FUNCTION HMI_SetFocus


(****************************************************************)
(* Set return value to get rid of compiler error				*)
(****************************************************************)

HMI_SetFocus:=	FALSE;


(****************************************************************)
(* Set/clear proper bit in StatusDP								*)
(****************************************************************)

StatusDP.HMI_STATBIT_FOCUS:=	1;


END_FUNCTION
