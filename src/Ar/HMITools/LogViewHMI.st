(*
 * File: LogViewHMI.st
 * Copyright (c) 2023 Loupe
 * https://loupe.team
 * 
 * This file is part of HMITools, licensed under the MIT License.
 * 
  ********************************************************************
 * Implementation of program Alarm
 ********************************************************************) 

(* Handles displaying alarms from buffer on HMI *)
FUNCTION LogView_HMI

	//Remove warning
	LogView_HMI:=0;
	
	IF LogViewHMI.GoToTopButton.CMD THEN
		LogViewHMI.GoToTopButton.CMD:=0;
		LogViewHMI.internal.Offset:=0;
		LogView.IN.CMD.GoToTop:=1;
	END_IF	
	IF LogViewHMI.PageUpButton.CMD THEN
		LogViewHMI.PageUpButton.CMD:=0;
		LogViewHMI.internal.Offset:=LogViewHMI.internal.Offset-10;
	END_IF
	IF LogViewHMI.PageDownButton.CMD THEN
		LogViewHMI.PageDownButton.CMD:=0;
		LogViewHMI.internal.Offset:=LogViewHMI.internal.Offset+10;
	END_IF
	IF LogViewHMI.UpButton.CMD THEN
		LogViewHMI.UpButton.CMD:=0;
		LogViewHMI.internal.Offset:=LogViewHMI.internal.Offset-1;
	END_IF
	IF LogViewHMI.DownButton.CMD THEN
		LogViewHMI.DownButton.CMD:=0;
		LogViewHMI.internal.Offset:=LogViewHMI.internal.Offset+1;
	END_IF	
	
	LogViewHMI.internal.SelectedListIndex:= DINT_TO_UINT(LogViewHMI.ListBox.IndexDP);
	
	IF FIND(LogViewHMI.FilterString,'ALARM FILTER') = 1 THEN
		LogViewHMI.FilterString:='';
	END_IF
	
	IF LogViewHMI.internal.Offset + UDINT_TO_DINT(LogViewHMI.MaxAlarms) > UINT_TO_DINT(LogView.IN.CFG.MaxLogs) THEN
		LogView.IN.PAR.Offset:=	LogViewHMI.internal.Offset + LogViewHMI.MaxAlarms - LogView.IN.CFG.MaxLogs;
		iOffset:=				LogView.IN.CFG.MaxLogs - LogViewHMI.MaxAlarms;
		iOffsetCount:=			iOffset;
	ELSIF LogViewHMI.internal.Offset <= 0 THEN
		LogView.IN.PAR.Offset:=LogViewHMI.internal.Offset;
		iOffset:=0;		
	ELSE	
		LogView.IN.PAR.Offset:=1;
		iOffset:=LogViewHMI.internal.Offset-1;
	END_IF
	

	
	IF LogViewHMI.AlarmList <> 0 THEN

		pLogList ACCESS LogViewHMI.AlarmList;
		
		//Clear list
		brsmemset(ADR(pLogList[0]) , 0 , SIZEOF(pLogList[0]) * LogViewHMI.MaxAlarms );
			
		iNumDisplay:=0;

		IF LogView.OUT.STAT.Error THEN
			brsitoa(LogView.OUT.STAT.ErrorID,ADR(TempErrorID));
			TempErrorID:=CONCAT(': ',TempErrorID);
			pLogList[iNumDisplay]:= CONCAT(LogView.OUT.STAT.ErrorString,TempErrorID);
			iNumDisplay:=iNumDisplay+1;
		END_IF

		IF LogViewHMI.internal.oSelectedListIndex <> LogViewHMI.internal.SelectedListIndex AND LogViewHMI.internal.SelectedListIndex <> DINT_TO_UINT(-1) THEN
			LogViewHMI.internal.oSelectedListIndex:=-1;
		ELSE
			LogViewHMI.internal.SelectedListIndex:=-1;			
		END_IF
		
		
		//Read data into array		
		FOR i:=0 TO BufferBottom(ADR(LogView.Internal.Buffer)) DO


			//If there is data here, filter it and put it in the list
			IF BufferGetItemAdr(ADR(LogView.Internal.Buffer),i,0) <> 0 THEN
								
				//Get the next alarm
				iLogData ACCESS BufferGetItemAdr(ADR(LogView.Internal.Buffer),i,0);

				//filter data
				IF FIND(iLogData.String,LogViewHMI.FilterString) <> 0 THEN

					IF iOffset > iOffsetCount THEN
						iOffsetCount:=iOffsetCount+1;
					ELSE
						IF iNumDisplay < LogViewHMI.MaxAlarms THEN
							pLogList[iNumDisplay] := iLogData.String;

							IF LogViewHMI.internal.oSelectedListIndex = DINT_TO_UINT(-1) THEN
								IF LogViewHMI.internal.SelectedListIndex = iNumDisplay THEN
									LogViewHMI.internal.SelectedAlarmIndex:= iLogData.Index; 
									LogViewHMI.internal.oSelectedListIndex:=	iNumDisplay;
									LogViewHMI.Text:=iLogData.String;
								END_IF
							ELSE
								IF LogViewHMI.internal.SelectedAlarmIndex =  iLogData.Index THEN
									LogViewHMI.internal.SelectedListIndex:=	iNumDisplay;
									LogViewHMI.Text:=iLogData.String;
								END_IF							
							END_IF
							iNumDisplay:=iNumDisplay+1;
						END_IF
					END_IF
				END_IF

			ELSE
				
				//The last data was empty, jump out
				
				i:= BufferBottom(ADR(LogView.Internal.Buffer));				

			END_IF	
			
			//Limit the number of values on the diplay
			IF iNumDisplay >= LogViewHMI.MaxAlarms THEN
				i:= BufferBottom(ADR(LogView.Internal.Buffer));
			END_IF

		END_FOR
		
	END_IF
	
	LogViewHMI.internal.NumberAlarms:=iNumDisplay;

	IF brsstrcmp(ADR(LogViewHMI.FilterString),ADR('')) = 0 OR brsstrcmp(ADR(LogViewHMI.FilterString),ADR(' ')) = 0  THEN
		LogViewHMI.FilterString:='ALARM FILTER';
	END_IF
	
	
	LogViewHMI.ListBox.MaxDP:= LogViewHMI.internal.NumberAlarms;
	LogViewHMI.ListBox.MinDP:= 0;
	LogViewHMI.ListBox.IndexDP:=LogViewHMI.internal.SelectedListIndex;
	
END_FUNCTION