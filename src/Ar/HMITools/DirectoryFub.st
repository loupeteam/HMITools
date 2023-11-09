(*
* File: DirectoryFub.st
* Copyright (c) 2023 Loupe
* https://loupe.team
* 
* This file is part of HMITools, licensed under the MIT License.
* 
*) 

(*  *)
FUNCTION_BLOCK DirectoryFub

IF FileList = 0 OR Enable = 0 THEN
	Updating:=0;
	RETURN;
END_IF

Files ACCESS FileList;

	// Step through all states faster by looping 5 times
	FOR index:=0 TO 5 DO
		
		CASE State OF
			0:
				DirectoryRead.enable:=0;
				//CurrentFileIndex:=0; This variable is never used again.
				Updating:=1;			
				State:=1;
			
			1:
				DirectoryOpen.enable := 	TRUE;
				DirectoryOpen.pDevice := 	ADR(FileDevice);
				DirectoryOpen.pName := 		pPath;
				DirectoryOpen();
				IF DirectoryOpen.status < ERR_FUB_ENABLE_FALSE THEN
					IF DirectoryOpen.status = ERR_OK THEN
						Ident :=			DirectoryOpen.ident;
						DirectoryOpen.enable:=	 FALSE;
						State:= 			State+1;
					ELSE
						status:= 			DirectoryOpen.status;
						State:=				10;
					END_IF;	
				ELSE
					EXIT;					
				END_IF;
				brsmemset(ADR(Files),0,MaxValues*(LIST_BOX_STRING_SIZE+1));
				ListFileIndex:=		0;		
				status:=			ERR_FUB_BUSY;
			
			2:
				//read directory
				DirectoryRead.enable := 	TRUE;
				DirectoryRead.ident := 		Ident;
				DirectoryRead.pData := 		ADR(DirData);
				DirectoryRead.data_len := 	SIZEOF(DirData);
				DirectoryRead();
				IF DirectoryRead.status < ERR_FUB_ENABLE_FALSE THEN
					IF DirectoryRead.status = ERR_OK THEN
						DirectoryRead.enable := FALSE;
						State:= 			State+1;
					ELSIF DirectoryRead.status = fiERR_NO_MORE_ENTRIES THEN
						NumFiles:= 			ListFileIndex;
						status:=			ERR_OK;
						State:=				5;
					ELSE
						IF DirectoryRead.status = 20799 THEN
							status:= FileIoGetSysError();
						ELSE
							status:= DirectoryRead.status;	
						END_IF;
						State:=				10;
					END_IF;
				ELSE
					EXIT;					
				END_IF;
			
			
			3:
				brsstrcpy(ADR(TempString),ADR(DirData.Filename));
				iNameFilter:=NameFilter;
				//If file extension filter defined
				IF FileExt <> '' THEN
					brsmemset(ADR(TempExtension),0,SIZEOF(TempExtension));
					TempExtension:=	'.';
					brsstrcat(ADR(TempExtension),ADR(FileExt));
					//item is a File, files are filtered
					IF DirData.Mode = fiFILE THEN
						//compare just the selected extension from the file name + extension (e.g. compare ".csv" from "testing.csv")
						IF ( brsmemcmp((ADR(TempString)+(brsstrlen(ADR(TempString))-(brsstrlen(ADR(TempExtension)))))
							, ADR(TempExtension)
							, brsstrlen(ADR(TempExtension))) = 0) THEN
							
							//convert NameFilter to lowercase 
							brsmemset(ADR(lcNameFilter),0,SIZEOF(lcNameFilter));
							FOR i:= 0 TO (SIZEOF(NameFilter) - 1) DO
								brsmemcpy(ADR(IsolatedChar),(ADR(NameFilter) + i),SIZEOF(USINT));
								IF IsolatedChar = 0 THEN// OR IsolatedChar = 46 THEN//if null or '.', dont convert file extension to lc
									EXIT;
								ELSIF IsolatedChar >=  65 AND IsolatedChar <=  90  THEN//Uppser case ascii
									brsmemset((ADR(lcNameFilter) + i),(IsolatedChar + 32),SIZEOF(USINT));
								ELSE//lower case ascii
									brsmemset((ADR(lcNameFilter) + i),IsolatedChar,SIZEOF(USINT));
								END_IF;
							END_FOR;
							//convert TempString to lowercase 
							brsmemset(ADR(lcTempString),0,SIZEOF(lcTempString));
							FOR i:= 0 TO (SIZEOF(TempString) - 1) DO
								brsmemcpy(ADR(IsolatedChar),(ADR(TempString) + i),SIZEOF(USINT));
								IF IsolatedChar = 0 THEN// OR IsolatedChar = 46 THEN//if null or '.', dont convert file extension to lc
									EXIT;
								ELSIF IsolatedChar >=  65 AND IsolatedChar <=  90  THEN//Uppser case ascii
									brsmemset((ADR(lcTempString) + i),(IsolatedChar + 32),SIZEOF(USINT));
								ELSE//lower case ascii
									brsmemset((ADR(lcTempString) + i),IsolatedChar,SIZEOF(USINT));
								END_IF;
							END_FOR;
							brsmemcpy(ADR(IsolatedChar),ADR(TempString),SIZEOF(USINT));
						
							//Compare both lower case strings
							//Check for hidden files
							IF (FIND(lcTempString, lcNameFilter) <> 0) AND (ShowHiddenFiles OR IsolatedChar <> 46) THEN
								brsstrcpy(ADR(Files[ListFileIndex]),ADR(DirData.Filename));
								ListFileIndex:=		ListFileIndex+1;
								State:= 			State+1;
							ELSE
								State:= 			State+1;
							END_IF;

						ELSE
							State:= 			State+1;
						END_IF
					//item is a Directory, directories are not filtered
					ELSIF EnableDirectorySearch AND (brsstrcmp(ADR(DirData.Filename),ADR('.')) <> 0) THEN 
						IF ((brsstrcmp(pPath,ADR('')) = 0) AND ((brsstrcmp(ADR(DirData.Filename),ADR('..')) = 0))) THEN 
							State:=				State+1;
						ELSE
							brsstrcpy(ADR(Files[ListFileIndex]),ADR('\'));
							brsstrcat(ADR(Files[ListFileIndex]),ADR(DirData.Filename));
							ListFileIndex:=		ListFileIndex+1;
							State:=				State+1;
						END_IF;  		
					ELSE//if a directory and enabledirectorysearch is false
						State:= 				State+1;
					END_IF;
				//No extension filter defined
				ELSE
					//item is a File, files are filtered
					IF DirData.Mode = fiFILE THEN
						//convert NameFilter to lowercase 
						brsmemset(ADR(lcNameFilter),0,SIZEOF(lcNameFilter));
						FOR i:= 0 TO (SIZEOF(NameFilter) - 1) DO
							brsmemcpy(ADR(IsolatedChar),(ADR(NameFilter) + i),SIZEOF(USINT));
							IF IsolatedChar = 0 THEN// OR IsolatedChar = 46 THEN//if null or '.', dont convert file extension to lc
								EXIT;
							ELSIF IsolatedChar >=  65 AND IsolatedChar <=  90  THEN//Uppser case ascii
								brsmemset((ADR(lcNameFilter) + i),(IsolatedChar + 32),SIZEOF(USINT));
							ELSE//lower case ascii
								brsmemset((ADR(lcNameFilter) + i),IsolatedChar,SIZEOF(USINT));
							END_IF;
						END_FOR;
						//convert TempString to lowercase 
						brsmemset(ADR(lcTempString),0,SIZEOF(lcTempString));
						FOR i:= 0 TO (SIZEOF(TempString) - 1) DO
							brsmemcpy(ADR(IsolatedChar),(ADR(TempString) + i),SIZEOF(USINT));
							IF IsolatedChar = 0 THEN//OR IsolatedChar = 46 THEN//if null or '.', dont convert file extension to lc
								EXIT;
							ELSIF IsolatedChar >=  65 AND IsolatedChar <=  90  THEN//Uppser case ascii
								brsmemset((ADR(lcTempString) + i),(IsolatedChar + 32),SIZEOF(USINT));
							ELSE//lower case ascii
								brsmemset((ADR(lcTempString) + i),IsolatedChar,SIZEOF(USINT));			
							END_IF;
						END_FOR;
						
						brsmemcpy(ADR(IsolatedChar),ADR(TempString),SIZEOF(USINT));
						
						//Compare both lower case strings
						//Check for hidden files
						IF (FIND(lcTempString, lcNameFilter) <> 0) AND (ShowHiddenFiles OR IsolatedChar <> 46) THEN
							brsstrcpy(ADR(Files[ListFileIndex]),ADR(DirData.Filename));
							ListFileIndex:=		ListFileIndex+1;
							State:= 			State+1;
						ELSE
							State:= 			State+1;
						END_IF;

						
					//item is a Directory, directories are not filtered
					ELSIF EnableDirectorySearch AND (brsstrcmp(ADR(DirData.Filename),ADR('.')) <> 0) THEN //item is a Directory, directories are not filtered
						IF ((brsstrcmp(pPath,ADR('')) = 0) AND ((brsstrcmp(ADR(DirData.Filename),ADR('..')) = 0))) THEN 
							State:=				State+1;
						ELSE
							brsstrcpy(ADR(Files[ListFileIndex]),ADR('\'));
							brsstrcat(ADR(Files[ListFileIndex]),ADR(DirData.Filename));
							ListFileIndex:=		ListFileIndex+1;
							State:=				State+1;
						END_IF; 
					ELSE//if a directory and enabledirectorysearch is false
						State:= 				State+1;
					END_IF;				
				END_IF;				
			
						
			4:					
				IF ListFileIndex = MaxValues THEN
					status:=	ERR_OK;
					NumFiles:= 	ListFileIndex;
					State:=		5;
				ELSE
					State:=		2;
				END_IF;

			
			
			5:
				DirectoryClose.enable := 	TRUE;
				DirectoryClose.ident := 	Ident;
				DirectoryClose();
				IF DirectoryClose.status = ERR_OK THEN
					DirectoryClose.enable := FALSE;
					State:= 				6;
				END_IF;
				
				
			10:
				Initialized:=	1;					
				UpdateTimer.IN:=1;		
				IF UpdateTimer.Q OR iNameFilter<>NameFilter OR Refresh THEN
					Refresh:= 	0;
					State:=		0;
				END_IF
				
			ELSE
				Initialized:=	1;					
				Updating:=		0;
				UpdateTimer.IN:=1;		
				IF UpdateTimer.Q OR iNameFilter<>NameFilter OR Refresh THEN
					Refresh:= 	0;
					State:=		0;
				END_IF
		END_CASE;	
	END_FOR;
	
UpdateTimer.PT:=T#60s;
UpdateTimer();
UpdateTimer.IN:=0;	
		
END_FUNCTION_BLOCK
