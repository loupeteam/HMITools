(*
 * File: HMI_OpenTouchpad.st
 * Copyright (c) 2023 Loupe
 * https://loupe.team
 * 
 * This file is part of HMITools, licensed under the MIT License.
 * 
  ********************************************************************
 * Implementation of library HMI_Basic
 ********************************************************************) 


(********************************************************************)
(* Opens the touchpad for an item on the screen 					*)
(********************************************************************)


(* Function			DONE and TESTED DFB 20110504 *)


FUNCTION HMI_OpenTouchpad


(****************************************************************)
(* Set return value to get rid of compiler error				*)
(****************************************************************)

HMI_OpenTouchpad:=	FALSE;


(****************************************************************)
(* Set/clear proper bit in StatusDP								*)
(****************************************************************)

StatusDP.HMI_STATBIT_TOUCHPAD:=	1;


END_FUNCTION
