(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: Alarm
 * File: LogView.st
 * Author: Josh
 * Created: December 11, 2012
 ********************************************************************
 * Implementation of program Alarm
 ********************************************************************) 

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
			LogView.Internal.GetInfo.pName:=arlogBASE_SYSTEM_LOG_IDENT ;
		ELSIF FIND(LogView.IN.PAR.LoggerName, 'User') <> 0 THEN
			LogView.Internal.GetInfo.pName:=arlogBASE_USER_LOG_IDENT ;	
		ELSIF FIND(LogView.IN.PAR.LoggerName, 'FieldBus') <> 0 THEN
			LogView.Internal.GetInfo.pName:=arlogBASE_FIELDBUS_LOG_IDENT ;		
		ELSIF FIND(LogView.IN.PAR.LoggerName, 'Safety') <> 0 THEN
			LogView.Internal.GetInfo.pName:=arlogBASE_SAFETY_LOG_IDENT ;		
		ELSE
			LogView.Internal.GetInfo.pName:=ADR(LogView.IN.PAR.LoggerName);		
		END_IF
		
	END_IF

	///////////////////////////////////////////////////////////////
	//Ensure that we always know what the top alarm is
	///////////////////////////////////////////////////////////////
	
	LogView.Internal.GetInfo.enable:=1;
	LogView.Internal.GetInfo();

	IF LogView.Internal.GetInfo.status = ERR_OK THEN
		LogView.OUT.STAT.Error:=0;
		LogView.OUT.STAT.ErrorID:=0;
		LogView.OUT.STAT.ErrorString:='';
		//If this is a new ident, lets clear out the old data
		IF LogView.Internal.Ident <>  LogView.Internal.GetInfo.ident THEN		
			LogView.Internal.Ident:= LogView.Internal.GetInfo.ident;
			BufferClear(ADR(LogView.Internal.Buffer));			
		END_IF
	ELSIF LogView.Internal.GetInfo.status = ERR_FUB_BUSY THEN
		IF NOT LogView.OUT.STAT.Error THEN
			LogView.OUT.STAT.ErrorID:=LogView.Internal.GetInfo.status;
		END_IF		
	ELSE  (*Go to Error Step*)
		LogView.OUT.STAT.Error:=1;
		LogView.OUT.STAT.ErrorID:=LogView.Internal.GetInfo.status;
		LogView.OUT.STAT.ErrorString:='Error getting log info';	
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
				
			LogView.Internal.OffsetIndex:=LogView.Internal.GetInfo.actualIndex;
	
			//If we do have a top, use the top
		ELSE
	
			pEntry ACCESS BufferGetItemAdr(ADR(LogView.Internal.Buffer),0,0); 

			LogView.Internal.OffsetIndex:=pEntry.Index;
				
		END_IF
	END_IF
	
	//If there is an offset, the max is the offset before the offset was set
	//+- the current offset
	IF LogView.IN.PAR.Offset <> 0 OR ((LogView.Internal.OffsetIndex < LogView.Internal.GetInfo.actualIndex - 1) AND (LogView.Internal.OffsetIndex <> 0)) THEN

		//If the top value is less than or greater than where is should be in the offset
		//fill the top or bottom to allow it to get there
		
		MaxTopIndex:= LogView.Internal.OffsetIndex-LogView.IN.PAR.Offset;
		
		IF MaxTopIndex >= LogView.Internal.GetInfo.actualIndex THEN
	
			MaxTopIndex:=LogView.Internal.GetInfo.actualIndex;			
			LogView.IN.PAR.Offset:=0;
			LogView.Internal.OffsetIndex:=LogView.Internal.GetInfo.actualIndex;			
	
		END_IF

		//If there is no offset, fill the top
		//The bottom will fill automatically if the buffer is not full

	ELSIF LogView.IN.PAR.Offset = 0 THEN
	
		//Get top alarm in logger
			
		MaxTopIndex:=LogView.Internal.GetInfo.actualIndex;
				
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
		
		IF LogViewerGetAlarmString(LogView.Internal.GetTopAlarm,iNewEntry.Index,LogView.Internal.GetInfo.ident,iNewEntry.String) = ERR_OK THEN

			BufferAddToTop(ADR(LogView.Internal.Buffer),ADR(iNewEntry));			

		END_IF			

	ELSE

		pEntry ACCESS BufferGetItemAdr(ADR(LogView.Internal.Buffer),0,0);
		
		iNewEntry.Index:= pEntry.Index+1;
		
		IF iNewEntry.Index <= MaxTopIndex THEN
			
			IF LogViewerGetAlarmString(LogView.Internal.GetTopAlarm, iNewEntry.Index,LogView.Internal.GetInfo.ident,iNewEntry.String) = ERR_OK THEN

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
					
		IF LogViewerGetAlarmString(LogView.Internal.GetBottomAlarm, iNewEntry.Index,LogView.Internal.GetInfo.ident,iNewEntry.String) = ERR_OK THEN

			BufferAddToBottom(ADR(LogView.Internal.Buffer),ADR(iNewEntry));			

		END_IF				
					
	END_IF	
	
	LogView.OUT.NumberAlarms:= LogView.Internal.Buffer.NumberValues;
	
END_FUNCTION


FUNCTION LogViewerCreateString
	
	LogViewerCreateString:=0;
	
	iString:='';
			
	//Year
	IF ReadData.errYear<10 THEN
		brsstrcat(ADR(iString),ADR('0'));				
	END_IF								
	brsitoa(ReadData.errYear,ADR(iConvString));			
	brsstrcat(ADR(iString),ADR(iConvString));
	brsstrcat(ADR(iString),ADR('-'));			

	//Month
	IF ReadData.errMonth<10 THEN
		brsstrcat(ADR(iString),ADR('0'));				
	END_IF			
	brsitoa(ReadData.errMonth,ADR(iConvString));
	brsstrcat(ADR(iString),ADR(iConvString));
	brsstrcat(ADR(iString),ADR('-'));			

	//Day
	IF ReadData.errDay<10 THEN
		brsstrcat(ADR(iString),ADR('0'));				
	END_IF			
	brsitoa(ReadData.errDay,ADR(iConvString));			
	brsstrcat(ADR(iString),ADR(iConvString));

	brsstrcat(ADR(iString),ADR(' '));	
	
	//Hour
	IF ReadData.errHour<10 THEN
		brsstrcat(ADR(iString),ADR('0'));				
	END_IF			
	brsitoa(ReadData.errHour,ADR(iConvString));			
	brsstrcat(ADR(iString),ADR(iConvString));
	brsstrcat(ADR(iString),ADR(':'));

	//Minute
	IF ReadData.errMinute<10 THEN
		brsstrcat(ADR(iString),ADR('0'));				
	END_IF			
	brsitoa(ReadData.errMinute,ADR(iConvString));			
	brsstrcat(ADR(iString),ADR(iConvString));
	brsstrcat(ADR(iString),ADR(':'));
	
	//Second
	IF ReadData.errSecond<10 THEN
		brsstrcat(ADR(iString),ADR('0'));				
	END_IF			
	brsitoa(ReadData.errSecond,ADR(iConvString));			
	brsstrcat(ADR(iString),ADR(iConvString));
	brsstrcat(ADR(iString),ADR('.'));	

	//Millisecond
	IF ReadData.errMilliSec<100 THEN
		brsstrcat(ADR(iString),ADR('0'));				
	END_IF			
	IF ReadData.errMilliSec<10 THEN
		brsstrcat(ADR(iString),ADR('0'));				
	END_IF				
	brsitoa(ReadData.errMilliSec,ADR(iConvString));			
	brsstrcat(ADR(iString),ADR(iConvString));
	
	//Error number
	brsstrcat(ADR(iString),ADR(' Err #'));					
	brsitoa(ReadData.errornr,ADR(iConvString));			
	brsstrcat(ADR(iString),ADR(iConvString));

	CASE ReadData.logLevel OF
		arlogLEVEL_INFO:
			brsstrcat(ADR(iString),ADR(' Info: '));
		arlogLEVEL_FATAL:
			brsstrcat(ADR(iString),ADR(' Error: '));
		arlogLEVEL_WARNING:	
			brsstrcat(ADR(iString),ADR(' Warning: '));
	END_CASE
			
	brsstrcat(ADR(iString),ADR(ASCIIData));
				
	OutputString:= iString;	
	
END_FUNCTION
	
FUNCTION LogViewerGetAlarmString

	t.ReadItem.index:=AlarmIndex;
	t.ReadItem.enable := 1;
	t.ReadItem.ident := LoggerIdent;  (*Ident of AR logger user module from AsARLogGetInfo*)
	t.ReadItem.arlogRead := ADR(t.ReadData);  (*header data for the log entry *)
	t.ReadItem.memBin := ADR(t.BinaryData);  (*Buffer for binary log data*)
	t.ReadItem.lenBin := SIZEOF(t.BinaryData);  (*Length if binary buffer*)
	t.ReadItem.memAscii := ADR(t.ASCIIData);  (*Buffer for ASCII string*)
	t.ReadItem.lenAscii :=  SIZEOF(t.ASCIIData);  (*Length if ASCII buffer*)
	t.ReadItem;  (* Call the Functionblock*)
	
	IF t.ReadItem.status = 0 THEN  (*AsArLogRead successful or last log entry read. No additional (older) entry present.*)
		
		LogViewerCreateString(t.ReadData,t.ASCIIData,OutputString);
		LogViewerGetAlarmString:=0;
		
	ELSIF t.ReadItem.status = ERR_FUB_BUSY THEN

		LogViewerGetAlarmString:=ERR_FUB_BUSY;

	ELSE 
					
		LogViewerGetAlarmString:=t.ReadItem.status;
		
	END_IF
	
END_FUNCTION