(*
 * File: HMI_Hide.st
 * Copyright (c) 2023 Loupe
 * https://loupe.team
 * 
 * This file is part of HMITools, licensed under the MIT License.
 * 
  ********************************************************************
 * Implementation of library HMI_Basic
 ********************************************************************) 


(****************************************************************)
(* Hide an item on the screen 									*)
(****************************************************************)


(* Function			DONE and TESTED DFB 20110503 *)


FUNCTION HMI_Hide


(****************************************************************)
(* Set return value to get rid of compiler error				*)
(****************************************************************)

HMI_Hide:=	FALSE;


(****************************************************************)
(* Set/clear proper bit in StatusDP								*)
(****************************************************************)

StatusDP.HMI_STATBIT_VIS:=	HMI_INVISIBLE;


END_FUNCTION
