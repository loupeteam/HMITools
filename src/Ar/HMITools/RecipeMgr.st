
(*
* File: RecipeMgr.st
* Copyright (c) 2023 Loupe
* https://loupe.team
* 
* This file is part of HMITools, licensed under the MIT License.
* 
*) 

 
(* Manage copying recipes to and from a running system and the HMI *)


FUNCTION RecipeMgr


	//**********************************************************
	// Error checking											
	//**********************************************************

	IF( 	(Rec.IN.pHMIRecipe = 0)
		OR	(Rec.IN.pSystemRecipe = 0)
		OR	(Rec.IN.RecipeLength = 0)
		)THEN

		RecipeMgr:=	HMI_ERR_INVALIDINPUT;
		RETURN;	

	END_IF;

		
	//**********************************************************
	// Handle CMDs			 									
	//**********************************************************
	
	IF( Rec.HMI.RetrieveFromSystem.CMD )THEN
	
		// Copy from system to HMI and log
		Rec.HMI.RetrieveFromSystem.CMD:=	0;
		brsmemcpy( Rec.IN.pHMIRecipe, Rec.IN.pSystemRecipe, Rec.IN.RecipeLength );

		logInfo( Rec.IN.LoggerName, 50000, 'Recipe retrieved from system', 0 );

	END_IF;
	
	
	IF(	Rec.HMI.ApplyToSystem.CMD )THEN
		
		// Copy from HMI to system and log
		Rec.HMI.ApplyToSystem.CMD:=			0;
		brsmemcpy( Rec.IN.pSystemRecipe, Rec.IN.pHMIRecipe, Rec.IN.RecipeLength );
			
		logInfo( Rec.IN.LoggerName, 50000, 'Recipe applied to system', 0 );

	END_IF;

	
	IF brsmemcmp( Rec.IN.pSystemRecipe, Rec.IN.pHMIRecipe, Rec.IN.RecipeLength ) <> 0 THEN
		HMI_Show(Rec.HMI.Modified.StatusDP);
	ELSE
		HMI_Hide(Rec.HMI.Modified.StatusDP);		
	END_IF
		
	
	RecipeMgr:=	HMI_ERR_OK;
	RETURN;	
	
	
END_FUNCTION
