(*
 * File: HMI_ResetFocus.st
 * Copyright (c) 2023 Loupe
 * https://loupe.team
 * 
 * This file is part of HMITools, licensed under the MIT License.
 * 
  ********************************************************************
 * Implementation of library HMI_Basic
 ********************************************************************) 


(************************************************************************************)
(* Resets the focus bit for an item on the screen. THIS DOES NOT MOVE THE FOCUS!	*)
(************************************************************************************)


(* Function			DONE and TESTED DFB 20110504 *)


FUNCTION HMI_ResetFocus


(****************************************************************)
(* Set return value to get rid of compiler error				*)
(****************************************************************)

HMI_ResetFocus:=	FALSE;


(****************************************************************)
(* Set/clear proper bit in StatusDP								*)
(****************************************************************)

StatusDP.HMI_STATBIT_FOCUS:=	0;


END_FUNCTION
