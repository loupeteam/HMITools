(*
 * File: HMI_File_Browse.st
 * Copyright (c) 2023 Loupe
 * https://loupe.team
 * 
 * This file is part of HMITools, licensed under the MIT License.
 * 
  ********************************************************************
 * Implementation of library HMITools
 ********************************************************************) 

FUNCTION_BLOCK HMIFileBrowse
	// Error Checks
	
	IF pFileList = 0 THEN
		Status :=	'Invalid entry: FileList = 0';	
		RETURN;	
	END_IF;
	
	IF MaxFiles = 0 THEN
		Status :=	'Invalid entry: MaxFiles = 0';	
		RETURN;	
	END_IF;	
	
	IF pFileExtList = 0 
		AND MaxExt <> 0 THEN		
		Status :=	'Invalid entry: pFileExtList = 0';	
		RETURN;	
	END_IF;
	
	IF pFileExtList <> 0 
		AND MaxExt = 0 THEN		
		Status :=	'Invalid entry: MaxExt = 0';	
		RETURN;	
	END_IF;

	IF FileDevice = '' THEN
		Status :=	'Invalid entry: FileDevice = 0';	
		RETURN;
	END_IF;
	
	IF BrowseToDirectory AND EnableDirectorySearch = FALSE THEN
		BrowseToDirectory:=	FALSE;
		Status :=	'Please enable directory search';
	END_IF;
	
	IF Internal.TempFileList = 0 THEN
		TMP_alloc(SIZEOF(FileSelection) * MaxFiles ,ADR(Internal.TempFileList));
	END_IF
	
	Internal.FileExtensionSelector.IndexDP:=FileExtIndex;
	Internal.FileExtensionSelector.Enable:=Enable;
	Internal.FileExtensionSelector.MaxDP:=MaxExt;
	Internal.FileExtensionSelector.Selection:=ADR(FileExtSelection);
	IF pFileExtList <> 0 THEN
		Internal.FileExtensionSelector.SelectionList:=pFileExtList;	
	END_IF;
	Internal.FileExtensionSelector();



	Internal.Directory.Enable:=		Enable AND NOT EnableDataObjects;
	Internal.Directory.MaxValues:= 	MaxFiles;
	IF Internal.TempFileList <> 0 THEN
		Internal.Directory.FileList:=Internal.TempFileList;
	ELSE
		Internal.Directory.FileList:=pFileList;
	END_IF
	
	//If initial path given 
	IF pDirectorySearchPath <> 0 
		AND Internal.InternalBrowsingPath = '' THEN
		brsstrcpy(ADR(CurrentPath),pDirectorySearchPath);
	END_IF;
	
	//if command to add FileSelection to browsing path, 
	IF BrowseToDirectory 
		AND FileSelection <> '\..' 
		AND FileSelection <> '' THEN
		BrowseToDirectory := 	FALSE;
		Refresh := 1; // do an update and navigate to directory
		
		//Running directory path check
		brsmemcpy(ADR(Internal.IsolatedChar),ADR(FileSelection),SIZEOF(USINT));
		IF Internal.IsolatedChar = ASCII_BACKSLASH THEN
			//add selected file to internal path
			brsstrcat(ADR(Internal.InternalBrowsingPath),(ADR(FileSelection) + 1));//Don't add first character "\" to the browsing path
			brsstrcat(ADR(Internal.InternalBrowsingPath),ADR('\'));
			//reset current path	
			brsmemset(ADR(CurrentPath),0,SIZEOF(CurrentPath));
			//repopulate current path with directory path input
			IF pDirectorySearchPath <> 0 THEN
				brsstrcpy(ADR(CurrentPath),(pDirectorySearchPath));
			END_IF;
			brsstrcat(ADR(CurrentPath),ADR(Internal.InternalBrowsingPath));
			//RESET FileSelection
			FileIndex:=				-1;
			FileSelection:=			'';	
		ELSE
			Status:= 				'Invalid Internal.Directory';
		END_IF;
	//If command GoToParentInternal.Directory
	ELSIF BrowseToDirectory AND FileSelection = '\..' THEN
		BrowseToDirectory :=	FALSE;
		Refresh := 1; // do an update and navigate to directory
		Internal.PathStrSize:=		UDINT_TO_UINT(brsstrlen(ADR(Internal.InternalBrowsingPath)));
		IF Internal.InternalBrowsingPath = '' THEN//at highest allowed directory, indicated by input FileDevice and Path
			Status:= 				'Invalid Internal.Directory';
		ELSE
			brsmemset(ADR(Internal.InternalBrowsingPath) +(Internal.PathStrSize - 1 ),0,SIZEOF(USINT));//remove the last character "\"
			FOR Internal.i:= 1 TO Internal.PathStrSize DO
				//isolate a single character off of the path string
				brsmemcpy(ADR(Internal.IsolatedChar),ADR(Internal.InternalBrowsingPath)+(Internal.PathStrSize-Internal.i),SIZEOF(USINT));
				//if no characters left
				IF brsstrcmp(ADR(Internal.InternalBrowsingPath),ADR('')) = 0 THEN
					EXIT;
				//if found a backslash character at the end of the string, remove it and exit
				ELSIF Internal.IsolatedChar = ASCII_BACKSLASH  THEN
					EXIT;
				//else it's a normal character, remove it
				ELSE
					brsmemset(ADR(Internal.InternalBrowsingPath) +(Internal.PathStrSize-Internal.i),0,SIZEOF(USINT));
				END_IF;
			END_FOR;
		END_IF;
		//RESET FileSelection
		FileIndex:=		-1;
		FileSelection:=	'';
		//set output to current path
		brsmemset(ADR(CurrentPath),0,SIZEOF(CurrentPath));
		IF pDirectorySearchPath <> 0 THEN
			brsstrcpy(ADR(CurrentPath),pDirectorySearchPath);
		END_IF;
		brsstrcat(ADR(CurrentPath),ADR(Internal.InternalBrowsingPath));
	ELSIF BrowseToDirectory AND FileSelection = '' THEN
		BrowseToDirectory :=	FALSE;
		Status :=	'Invalid Internal.Directory';
	END_IF;
	
	//If selecting a file from listbox don't update name filter
	IF FileIndex < 0 THEN
		Internal.NameFilter :=	FileSelection;
	END_IF
	
	//temporarly display the filter being applied
	IF FileIndex < 0 AND Internal.NameFilter <> '' THEN
		Status :=		'Filter "';
		brsstrcat(ADR(Status),ADR(Internal.NameFilter));
		brsstrcat(ADR(Status),ADR('" applied'));
	END_IF
	
	//Reset Internal.NameFilter if a space character is the first character
	IF (brsmemcmp(ADR(FileSelection),ADR(' '),1) = 0) THEN
		Internal.NameFilter:=		'';
		FileSelection :=	'';
		Status :=			'Name filter removed';
	END_IF
	
	Internal.Directory.FileExt:=		FileExtSelection;
	Internal.Directory.FileDevice:=		FileDevice;
	Internal.Directory.EnableDirectorySearch:=	EnableDirectorySearch;
	Internal.Directory.pPath:=			ADR(CurrentPath);
	Internal.Directory.NameFilter:= 	Internal.NameFilter;
	
	IF (Refresh) THEN
		Internal.Directory.Refresh := 1;
	END_IF
	
	Internal.Directory();
	Refresh := 0;
	
	IF EnableDataObjects AND Enable THEN		
		NumFiles:= GetDataObjectList(Internal.Directory.FileList,MaxFiles);
	ELSE
		NumFiles:= 				Internal.Directory.NumFiles;		
	END_IF
	
	IF NOT Internal.Directory.Updating 
		AND Internal.TempFileList <> 0
		AND Enable
		THEN
		brsmemcpy(pFileList,Internal.TempFileList,Internal.Directory.MaxValues*(LIST_BOX_STRING_SIZE+1));	
	END_IF
	
	//If manually changing FileSelection, reset with FileIndex to update the Internal.NameFilter
	IF Internal.oldFileSelection <> FileSelection AND FileIndex = Internal.oldFileIndex THEN
		FileIndex:=	-1;
	END_IF;

	Internal.TempFileSelection := FileSelection;	
		
	Internal.FileNameSelector.IndexDP:=		FileIndex;
	Internal.FileNameSelector.Enable:=		Enable;
	Internal.FileNameSelector.Enable:=		TRUE;
	Internal.FileNameSelector.MaxDP:=		Internal.Directory.NumFiles;
	Internal.FileNameSelector.Selection:=	ADR(Internal.TempFileSelection);
	Internal.FileNameSelector.SelectionList:=	pFileList;
	Internal.FileNameSelector();
	
	//We need to read back the found index to ensure that we aren't constantly updating
	FileIndex:= Internal.FileNameSelector.IndexDP;	

	FileExtIndex:=	Internal.FileExtensionSelector.IndexDP;
	//FileIndex:=Internal.oldFileSelection.IndexDP;
	
	IF FileIndex > -1 THEN
		FileSelection:=		Internal.TempFileSelection;
		Internal.oldFileSelection:=	FileSelection;
	END_IF;
	
	CompletionDP:=Internal.FileNameSelector.CompletionDP;
	
	
	//If manually changing FileSelection, reset with FileIndex to update the Internal.NameFilter
	IF Internal.oldFileSelection <> FileSelection AND FileIndex = Internal.oldFileIndex THEN
		FileIndex:=	-1;
		Internal.oldFileSelection:=	FileSelection;
	ELSE
		Internal.oldFileSelection:=	FileSelection;
	END_IF;
	IF Internal.oldFileIndex <> FileIndex THEN
		Internal.oldFileIndex:=		FileIndex;
	END_IF;	

	
	//Reset Error String Handling
	IF Status <> '' THEN
		Internal.TON_0.IN := 	TRUE; 
		Internal.TON_0.PT := 	T#2s;
		IF Internal.TON_0.Q THEN
			Internal.TON_0.IN:=	FALSE;
			brsmemset(ADR(Status),0,SIZEOF(Status));
		END_IF;
	ELSE
		Internal.TON_0.IN := 	FALSE;
	END_IF;
	Internal.TON_0();
	
	//If no files or directories found
	IF NumFiles = 0 AND EnableDirectorySearch = FALSE THEN
		Status:=	'No files found';
	ELSIF NumFiles = 0 AND EnableDirectorySearch = TRUE THEN
		Status:=	'No items found';	
	END_IF;
	
	
END_FUNCTION_BLOCK
