(*
* File: HMI_Unlock.st
* Copyright (c) 2023 Loupe
* https://loupe.team
* 
* This file is part of HMITools, licensed under the MIT License.
* 
*) 


(****************************************************************)
(* Unlock an item on the screen 								*)
(****************************************************************)


(* Function			DONE and TESTED DFB 20110503 *)


FUNCTION HMI_Unlock


(****************************************************************)
(* Set return value to get rid of compiler error				*)
(****************************************************************)

HMI_Unlock:=	FALSE;


(****************************************************************)
(* Set/clear proper bit in StatusDP								*)
(****************************************************************)

StatusDP.HMI_STATBIT_LOCK:=	HMI_UNLOCKED;


END_FUNCTION
