(*
* File: LogView.st
* Copyright (c) 2023 Loupe
* https://loupe.team
* 
* This file is part of HMITools, licensed under the MIT License.
* 
*) 

(* TODO: Add your comment here *)
FUNCTION LogView_init
	
	IF LogView.IN.CFG.MaxLogs <> 0 THEN
		BufferInit(ADR(LogView.Internal.Buffer),LogView.IN.CFG.MaxLogs,SIZEOF(LogData));
		LogView_init:=1;
	ELSE
		LogView_init:=0;
	END_IF

END_FUNCTION

FUNCTION LogView_cyclic
	
	LogView_cyclic:=0;
	
	IF NOT BufferValid(ADR(LogView.Internal.Buffer)) THEN
		
		LogView.OUT.STAT.Error:=1;
		LogView.OUT.STAT.ErrorID:=0;
		LogView.OUT.STAT.ErrorString:='Buffer did not initialize';
		
		LogView_init(LogView);
		RETURN;
	END_IF

	///////////////////////////////////////////////////////////////
	//If the logger name changes, clear the buffer and get the new
	//logger data
	///////////////////////////////////////////////////////////////
	
	IF LogView.Internal.LoggerName<>LogView.IN.PAR.LoggerName THEN
		LogView.Internal.LoggerName:=	LogView.IN.PAR.LoggerName;				
		//Get the names of the systems logs.
		IF FIND(LogView.IN.PAR.LoggerName, 'System') <> 0 THEN
			LogView.Internal.GetIdent.Name:= '$$arlogsys'; // Double $ since it is the ST escape character
		ELSIF FIND(LogView.IN.PAR.LoggerName, 'User') <> 0 THEN
			LogView.Internal.GetIdent.Name:= '$$arlogusr';	
		ELSIF FIND(LogView.IN.PAR.LoggerName, 'FieldBus') <> 0 THEN
			LogView.Internal.GetIdent.Name:= '$$fieldbus';		
		ELSIF FIND(LogView.IN.PAR.LoggerName, 'Safety') <> 0 THEN
			LogView.Internal.GetIdent.Name:= '$$safety';		
		ELSE
			LogView.Internal.GetIdent.Name:=LogView.IN.PAR.LoggerName;
		END_IF
		
	END_IF

	///////////////////////////////////////////////////////////////
	//Ensure that we always know what the top alarm is
	///////////////////////////////////////////////////////////////
	
	LogView.Internal.GetIdent.Execute := TRUE; 
	LogView.Internal.GetIdent();
	IF LogView.Internal.GetIdent.Done THEN
		LogView.OUT.STAT.Error:=0;
		LogView.OUT.STAT.ErrorID:=0;
		LogView.OUT.STAT.ErrorString:='';
		//If this is a new ident, lets clear out the old data
		IF LogView.Internal.Ident <>  LogView.Internal.GetIdent.Ident THEN		
			LogView.Internal.Ident:= LogView.Internal.GetIdent.Ident;
			BufferClear(ADR(LogView.Internal.Buffer));			
		END_IF
	ELSE  (*Go to Error Step*)
		LogView.OUT.STAT.Error:=1;
		LogView.OUT.STAT.ErrorID:=LogView.Internal.GetIdent.StatusID;
		LogView.OUT.STAT.ErrorString:='Error getting log info';	
		BufferClear(ADR(LogView.Internal.Buffer));		
		RETURN;		
	END_IF
	
	IF LogView.IN.CMD.GoToTop THEN
		LogView.IN.CMD.GoToTop:=0;
		LogView.IN.PAR.Offset:=0;
		LogView.Internal.OffsetIndex:=0;
	END_IF
	
	// Get RecordID of latest alarm
	LogView.Internal.GetRecordID.Ident := LogView.Internal.Ident;
	LogView.Internal.GetRecordID.Execute := TRUE; 
	LogView.Internal.GetRecordID();
	IF LogView.Internal.GetRecordID.Error THEN
		LogView.OUT.STAT.Error:=1;
		LogView.OUT.STAT.ErrorID:=LogView.Internal.GetRecordID.StatusID;
		LogView.OUT.STAT.ErrorString:='Error getting record ID';	
		BufferClear(ADR(LogView.Internal.Buffer));		
		RETURN;		
	END_IF
	
	IF LogView.IN.CMD.GoToTop THEN
		LogView.IN.CMD.GoToTop:=0;
		LogView.IN.PAR.Offset:=0;
		LogView.Internal.OffsetIndex:=0;
	END_IF
	///////////////////////////////////////////////////////////////
	//Buffer control, tells the ring buffer which way to add values
	///////////////////////////////////////////////////////////////	

	//Reset offset index
	IF LogView.IN.PAR.Offset <> 0 AND LogView.Internal.OffsetIndex = 0 THEN

			
		//If we don't have a top, use the first alarm
		IF BufferGetItemAdr(ADR(LogView.Internal.Buffer),0,0) = 0 THEN
				
			LogView.Internal.OffsetIndex:=LogView.Internal.GetRecordID.RecordID;
	
			//If we do have a top, use the top
		ELSE
	
			pEntry ACCESS BufferGetItemAdr(ADR(LogView.Internal.Buffer),0,0); 

			LogView.Internal.OffsetIndex:=pEntry.Index;
				
		END_IF
	END_IF
	
	//If there is an offset, the max is the offset before the offset was set
	//+- the current offset
	IF LogView.IN.PAR.Offset <> 0 OR ((LogView.Internal.OffsetIndex < LogView.Internal.GetRecordID.RecordID - 1) AND (LogView.Internal.OffsetIndex <> 0)) THEN

		//If the top value is less than or greater than where is should be in the offset
		//fill the top or bottom to allow it to get there
		
		MaxTopIndex:= LogView.Internal.OffsetIndex-LogView.IN.PAR.Offset;
		
		IF MaxTopIndex >= LogView.Internal.GetRecordID.RecordID THEN
	
			MaxTopIndex:=LogView.Internal.GetRecordID.RecordID;			
			LogView.IN.PAR.Offset:=0;
			LogView.Internal.OffsetIndex:=LogView.Internal.GetRecordID.RecordID;			
	
		END_IF

		//If there is no offset, fill the top
		//The bottom will fill automatically if the buffer is not full

	ELSIF LogView.IN.PAR.Offset = 0 THEN
	
		//Get top alarm in logger
			
		MaxTopIndex:=LogView.Internal.GetRecordID.RecordID;
				
	END_IF		


	IF BufferGetItemAdr(ADR(LogView.Internal.Buffer),0,0) <> 0 THEN

		pEntry ACCESS BufferGetItemAdr(ADR(LogView.Internal.Buffer),0,0); 

		IF ABS(UDINT_TO_INT(MaxTopIndex - pEntry.Index)) > UINT_TO_DINT(LogView.Internal.Buffer.MaxValues/2) THEN
	
			BufferClear(ADR(LogView.Internal.Buffer));
	
		END_IF

	END_IF

	///////////////////////////////////////////////////////////////
	//Fill the top
	///////////////////////////////////////////////////////////////
	
	//Fill in the top data
			
 
		
	IF BufferGetItemAdr(ADR(LogView.Internal.Buffer),0,0) = 0 THEN
		
		iNewEntry.Index:= MaxTopIndex;
		
		IF LogViewerGetAlarmString(LogView.Internal.GetTopAlarm,iNewEntry.Index,LogView.Internal.GetIdent.Ident,iNewEntry.String) = ERR_OK THEN

			BufferAddToTop(ADR(LogView.Internal.Buffer),ADR(iNewEntry));			

		END_IF			

	ELSE

		pEntry ACCESS BufferGetItemAdr(ADR(LogView.Internal.Buffer),0,0);
		
		iNewEntry.Index:= pEntry.Index+1;
		
		IF iNewEntry.Index <= MaxTopIndex THEN
			
			IF LogViewerGetAlarmString(LogView.Internal.GetTopAlarm, iNewEntry.Index,LogView.Internal.GetIdent.Ident,iNewEntry.String) = ERR_OK THEN

				BufferAddToTop(ADR(LogView.Internal.Buffer),ADR(iNewEntry));			

			END_IF				
			
		END_IF
		
	END_IF
	
	
	///////////////////////////////////////////////////////////////
	//Fill the Bottom
	///////////////////////////////////////////////////////////////
	
	//Get the top value to check if we should continue filling the bottom					
	IF BufferGetItemAdr(ADR(LogView.Internal.Buffer),0,0) = 0 THEN
			
		//Do nothing let the top get one first
	
		//If we aren't full, OR the top index is too high, fill the bottom
		
	ELSIF NOT BufferFull(ADR(LogView.Internal.Buffer)) OR pEntry.Index > MaxTopIndex THEN

		//Get the last entry in the current list
		pEntry ACCESS BufferGetItemAdr(ADR(LogView.Internal.Buffer),BufferBottom(ADR(LogView.Internal.Buffer)),0);
		
		//Get the index lower than the last entry in the list
		iNewEntry.Index:= pEntry.Index-1;
					
		IF LogViewerGetAlarmString(LogView.Internal.GetBottomAlarm, iNewEntry.Index,LogView.Internal.GetIdent.Ident,iNewEntry.String) = ERR_OK THEN

			BufferAddToBottom(ADR(LogView.Internal.Buffer),ADR(iNewEntry));			

		END_IF				
					
	END_IF	
	
	LogView.OUT.NumberAlarms:= LogView.Internal.Buffer.NumberValues;


	// These only execute on rising edge, so reset execute at end of function
	LogView.Internal.GetIdent.Execute := FALSE; 
	LogView.Internal.GetIdent();
	LogView.Internal.GetRecordID.Execute := FALSE;
	LogView.Internal.GetRecordID();

	
END_FUNCTION


FUNCTION LogViewerCreateString
	
	brsmemset(ADR(emptyDTStructure), 0, SIZEOF(emptyDTStructure));
	LogViewerCreateString:=0;
	
	iString:='';
	
	IF brsmemcmp(ADR(ReadData.errTime), ADR(emptyDTStructure), SIZEOF(ReadData.errTime)) <> 0 THEN
		//Year
		IF ReadData.errTime.year<10 THEN
			brsstrcat(ADR(iString),ADR('0'));				
		END_IF								
		brsitoa(ReadData.errTime.year,ADR(iConvString));			
		brsstrcat(ADR(iString),ADR(iConvString));
		brsstrcat(ADR(iString),ADR('-'));			

		//Month
		IF ReadData.errTime.month<10 THEN
			brsstrcat(ADR(iString),ADR('0'));				
		END_IF			
		brsitoa(ReadData.errTime.month,ADR(iConvString));
		brsstrcat(ADR(iString),ADR(iConvString));
		brsstrcat(ADR(iString),ADR('-'));			

		//Day
		IF ReadData.errTime.day<10 THEN
			brsstrcat(ADR(iString),ADR('0'));				
		END_IF			
		brsitoa(ReadData.errTime.day,ADR(iConvString));			
		brsstrcat(ADR(iString),ADR(iConvString));

		brsstrcat(ADR(iString),ADR(' '));	
		
		//Hour
		IF ReadData.errTime.hour<10 THEN
			brsstrcat(ADR(iString),ADR('0'));				
		END_IF			
		brsitoa(ReadData.errTime.hour,ADR(iConvString));			
		brsstrcat(ADR(iString),ADR(iConvString));
		brsstrcat(ADR(iString),ADR(':'));

		//Minute
		IF ReadData.errTime.minute<10 THEN
			brsstrcat(ADR(iString),ADR('0'));				
		END_IF			
		brsitoa(ReadData.errTime.minute,ADR(iConvString));			
		brsstrcat(ADR(iString),ADR(iConvString));
		brsstrcat(ADR(iString),ADR(':'));
		
		//Second
		IF ReadData.errTime.second<10 THEN
			brsstrcat(ADR(iString),ADR('0'));				
		END_IF			
		brsitoa(ReadData.errTime.second,ADR(iConvString));			
		brsstrcat(ADR(iString),ADR(iConvString));
		brsstrcat(ADR(iString),ADR('.'));	

		//Millisecond
		IF ReadData.errTime.millisec<100 THEN
			brsstrcat(ADR(iString),ADR('0'));				
		END_IF			
		IF ReadData.errTime.millisec<10 THEN
			brsstrcat(ADR(iString),ADR('0'));				
		END_IF				
		brsitoa(ReadData.errTime.millisec,ADR(iConvString));			
		brsstrcat(ADR(iString),ADR(iConvString));
	ELSE
		brsstrcat(ADR(iString),ADR('[Invalid timestamp]'));	
	END_IF
	
	
	//Error number
	brsstrcat(ADR(iString),ADR(' Err #'));					
	brsitoa(ReadData.errornr,ADR(iConvString));			
	brsstrcat(ADR(iString),ADR(iConvString));

	brsstrcat(ADR(iString),ADR(' '));
	brsstrcat(ADR(iString),ADR(ASCIIData));
				
	OutputString:= iString;	
	
END_FUNCTION
	
FUNCTION LogViewerGetAlarmString 

	t.ReadItem.Execute := 1;
	t.ReadItem.Ident := LoggerIdent;  (*Ident of AR logger user module from AsARLogGetIdent*)
	t.ReadItem.RecordID := recordId;
	t.ReadItem;  (* Call the Functionblock*)

	
	IF t.ReadItem.Done AND t.ReadItem.StatusID = 0 THEN  (*ArEventLogRead successful or last log entry read. No additional (older) entry present.*)
		t.convertUTC;
		IF t.convertUTC.status = ERR_FUB_BUSY THEN // Busy
			t.convertUTC.enable := TRUE;
			LogViewerGetAlarmString:=ERR_FUB_BUSY;
			RETURN;
		ELSIF t.convertUTC.status = ERR_FUB_ENABLE_FALSE THEN // Ready to start new conversion
			t.convertUTC.enable := TRUE;
			brsmemcpy(ADR(t.convertUTC.DT1), ADR(t.ReadItem.TimeStamp.sec), SIZEOF(t.ReadItem.TimeStamp.sec)); // DATE_AND_TIME is just a UDINT
			t.convertUTC.pDTStructure := ADR(t.ReadData.errTime);
			LogViewerGetAlarmString:=ERR_FUB_BUSY;
			RETURN;
		ELSIF t.convertUTC.status = timERR_INVALID_PARAMETER THEN
			brsmemset(ADR(t.ReadData.errTime), 0, SIZEOF(t.ReadData.errTime)); // Indicates error reading time
			t.convertUTC.enable := FALSE;
		ELSE // Done
			t.convertUTC.enable := FALSE;
			t.ReadData.errTime.millisec := UDINT_TO_UINT(t.ReadItem.TimeStamp.nsec/1000);
		END_IF

		IF t.ReadItem.AddDataFormat = arEVENTLOG_ADDFORMAT_TEXT THEN
			t.ReadAddData.Execute := 1;
			t.ReadAddData.Ident := LoggerIdent;
			t.ReadAddData.RecordID := recordId;
			t.ReadAddData.AddData := ADR(t.ASCIIData);
			t.ReadAddData.BytesToRead := SIZEOF(t.ASCIIData);
			t.ReadAddData; (* Call the function block *)
		END_IF
		
		LogViewerCreateString(t.ReadData,t.ASCIIData,OutputString);
		LogViewerGetAlarmString:=0;
		
	ELSIF t.ReadItem.StatusID = ERR_FUB_BUSY THEN

		LogViewerGetAlarmString:=ERR_FUB_BUSY;

	ELSE 
					
		LogViewerGetAlarmString:=t.ReadItem.StatusID;
		
	END_IF
	
END_FUNCTION