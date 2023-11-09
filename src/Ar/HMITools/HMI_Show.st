(*
* File: HMI_Show.st
* Copyright (c) 2023 Loupe
* https://loupe.team
* 
* This file is part of HMITools, licensed under the MIT License.
* 
*) 


(****************************************************************)
(* Show an item on the screen 									*)
(****************************************************************)


(* Function			DONE and TESTED DFB 20110503 *)


FUNCTION HMI_Show


(****************************************************************)
(* Set return value to get rid of compiler error				*)
(****************************************************************)

HMI_Show:=	FALSE;


(****************************************************************)
(* Set/clear proper bit in StatusDP								*)
(****************************************************************)

StatusDP.HMI_STATBIT_VIS:=	HMI_VISIBLE;


END_FUNCTION
