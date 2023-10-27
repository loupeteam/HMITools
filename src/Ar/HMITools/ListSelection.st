(********************************************************************
 * COPYRIGHT -- Automation Resources Group
 ********************************************************************
 * Program: FileManager
 * File: FileSelection.st
 * Author: Josh
 * Created: April 02, 2012
 ********************************************************************
 * Implementation of program FileManager
 ********************************************************************) 

(* HMI Ready list box *)
FUNCTION_BLOCK ListBoxFub

	Files ACCESS SelectionList;
	pValue ACCESS Selection;

	MinDP:=MinDP;
	OptionDP:=OptionDP;
	StatusDP:=StatusDP;
	ColorDP:=ColorDP;
	PageSize:=PageSize;
	
	IF Selection = 0 OR SelectionList = 0 OR Enable = 0 THEN
		IndexDP:=intIndex:=-1;//Set index to -1 to ensure that when enable is true, it updates selection.
		RETURN;
	END_IF

	CompletionDP:=0;
	
	IF pValue<>oValue THEN
	
		intIndex:=FindIndexOfString(pValue,ADR(Files[0]),MaxDP);
		IF intIndex>=0 THEN
			IndexDP:=intIndex;
			pValue:= Files[intIndex];
			oValue:=pValue;
			CompletionDP:=1;
		ELSIF IndexDP >=0 THEN
			intIndex:=IndexDP;
			pValue:= Files[intIndex];
			oValue:=pValue;
			CompletionDP:=1;			
		END_IF
	
	ELSIF IndexDP<>intIndex THEN
	
		intIndex:=IndexDP;
		pValue:= Files[intIndex];
		oValue:=pValue;
		CompletionDP:=1;
		
	ELSIF pValue <> Files[IndexDP] THEN	

		intIndex:=FindIndexOfString(pValue,ADR(Files[0]),MaxDP);
		IndexDP:=intIndex;
		IF intIndex>=0 THEN		
			pValue:= Files[intIndex];
			oValue:=pValue;
			CompletionDP:=1;
		END_IF
		
	END_IF;

END_FUNCTION_BLOCK

FUNCTION FindIndexOfString

	Files ACCESS List;

	FindIndexOfString:=-1;
			
	FOR iteration:=0 TO MaxList DO

		IF Value='' 
			OR (Files[iteration] = '' AND iteration>0)	
			THEN
			iteration:= MaxList;
		ELSE
			TempString:=	Files[iteration];
			TempString1:=	Value;
			ToLower(ADR(TempString));
			ToLower(ADR(TempString1));
			
			IF brsstrcmp(ADR(TempString),ADR(TempString1)) = 0 THEN
				FindIndexOfString:=iteration;
				iteration:= MaxList;
			END_IF
		END_IF
	END_FOR;

END_FUNCTION
