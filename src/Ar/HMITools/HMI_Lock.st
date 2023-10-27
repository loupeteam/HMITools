(*
 * File: HMI_Lock.st
 * Copyright (c) 2023 Loupe
 * https://loupe.team
 * 
 * This file is part of HMITools, licensed under the MIT License.
 * 
  ********************************************************************
 * Implementation of library HMI_Basic
 ********************************************************************) 


(****************************************************************)
(* Lock an item on the screen 									*)
(****************************************************************)


(* Function			DONE and TESTED DFB 20110503 *)


FUNCTION HMI_Lock


(****************************************************************)
(* Set return value to get rid of compiler error				*)
(****************************************************************)

HMI_Lock:=	FALSE;


(****************************************************************)
(* Set/clear proper bit in StatusDP								*)
(****************************************************************)

StatusDP.HMI_STATBIT_LOCK:=	HMI_LOCKED;


END_FUNCTION
