(*
 * File: GetDataObjectList.st
 * Copyright (c) 2023 Loupe
 * https://loupe.team
 * 
 * This file is part of HMITools, licensed under the MIT License.
 * 
  *******************************************************************)
(*  *)
FUNCTION GetDataObjectList
	
	
		//Keep track of the objects that we've gone through
	//unsigned int objectIndex = 0;
	objectIndex:= 0;

	//Number of variables that have been found
	numberVariables:=0;
	duplicate:=0;
	index:=0;

	//Check for valid inputs
	IF( List = 0 ) THEN
		GetDataObjectList:=0;
		RETURN;
	END_IF
	
	//Clear out any bad data
	Files ACCESS List;
	brsmemset(ADR(Files ),0,MaxObjects*(LIST_BOX_STRING_SIZE+1));
	
	//Look through all the objects
	WHILE( MO_list(objectIndex, ADR(objectIndex), ADR(Item)) = 0 AND numberVariables < MaxObjects)DO
		//If it is a cyclic object check if it has the variable
		duplicate:=0;
		IF( Item.type = 16#41) THEN
			FOR index:= 0 TO numberVariables DO
				IF(brsstrcmp(ADR(Item.name),ADR(Files[index]))=0)THEN
					duplicate:=1;
					EXIT;
				END_IF		
			END_FOR
			IF(NOT duplicate) THEN
				brsstrcpy( ADR(Files[numberVariables]),ADR(Item.name));
				numberVariables:=numberVariables+1;				
			END_IF					
		END_IF
	END_WHILE
			
	//Return the number of found variables to make it easy to add to the list outside the function.
	GetDataObjectList:= numberVariables;
	
END_FUNCTION
