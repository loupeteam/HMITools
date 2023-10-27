(*
 * File: UpdateFiles.st
 * Copyright (c) 2023 Loupe
 * https://loupe.team
 * 
 * This file is part of HMITools, licensed under the MIT License.
 * 
  ********************************************************************
 * Implementation of program RecipeUpdater
 ********************************************************************) 

(* TODO: Add your comment here *)
FUNCTION_BLOCK FileQueue
		
	CASE internal.State OF

		RecipeUpdater_ST_IDLE:
			Busy := FALSE;
			IF Next THEN
				Busy:=	TRUE;
				internal.DirRead.entry:= 0;				
				internal.State:= RecipeUpdater_ST_ReadDirectory;	
			END_IF	

		RecipeUpdater_ST_ReadDirectory:

			IF internal.DirRead.status = 0 THEN
				internal.DirRead.enable:= FALSE;
				IF internal.CurrentFile.Filename[0] <> 46 THEN
					internal.State:= RecipeUpdater_ST_ReadFile;
					brsstrcpy(ADR(FileName),ADR(internal.CurrentFile.Filename));				
				ELSE
					internal.DirRead.entry:= internal.DirRead.entry+1;									
				END_IF				
			ELSIF internal.DirRead.status = ERR_FUB_BUSY
				OR internal.DirRead.status = ERR_FUB_ENABLE_FALSE
				THEN
				internal.DirRead.enable:= TRUE;
			ELSIF internal.DirRead.status = fiERR_NO_MORE_ENTRIES 
				THEN
				internal.State:= RecipeUpdater_ST_Done;				
			ELSE
				Error:=	TRUE;
				ErrorID:=	internal.DirRead.status;
				internal.State:= RecipeUpdater_ST_Done;								
			END_IF

		RecipeUpdater_ST_ReadFile:

			Execute:=	TRUE;				
			IF NOT Next THEN
				Execute:=	FALSE;				
				internal.State:= RecipeUpdater_ST_WAIT;				
			ELSIF Cancel THEN
				Execute:=	FALSE;				
				internal.State:= RecipeUpdater_ST_Done;								
			END_IF	
			
		RecipeUpdater_ST_WAIT:
			
			Execute:=	FALSE;				
			IF Next THEN
				internal.State:= RecipeUpdater_ST_ReadDirectory;
				internal.DirRead.entry:= internal.DirRead.entry+1;
			ELSIF Cancel THEN
				Execute:=	FALSE;				
				internal.State:= RecipeUpdater_ST_Done;								
			END_IF	
		
		RecipeUpdater_ST_Done:

			Done:= TRUE;
			Busy:=0;

			IF NOT Next
				AND NOT Cancel
				THEN
				Error:=0;
				Done:=0;
				ErrorID:=0;
				internal.State:= RecipeUpdater_ST_IDLE;
			END_IF
				
		RecipeUpdater_ST_:


	END_CASE	

	internal.DirRead.option:=	fiFILE;	
	internal.DirRead.pData:=	ADR(internal.CurrentFile);
	internal.DirRead.data_len:= SIZEOF(internal.CurrentFile);
	internal.DirRead.pDevice:=	ADR(FileDevice);
	internal.DirRead.pPath:=	ADR(Path);
	internal.DirRead();
	internal.DirRead.enable:= FALSE;
	
END_FUNCTION_BLOCK