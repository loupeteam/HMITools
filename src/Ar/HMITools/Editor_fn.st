(*
 * File: Editor_fn.st
 * Copyright (c) 2023 Loupe
 * https://loupe.team
 * 
 * This file is part of HMITools, licensed under the MIT License.
 * 
  ********************************************************************
 * Implementation of library HMITools
 ********************************************************************) 

(* TODO: Add your comment here *)
FUNCTION Editor_fn
	
	Editor_fn:=0;
	
	IF EditorController.CMD.Save THEN
		EditorController.HMI.Command:= EC_SAVE;
		EditorController.Internal.CMD.Save:=1;
	ELSIF EditorController.CMD.Load THEN
		EditorController.HMI.Command:= EC_LOAD;	
		EditorController.Internal.CMD.Load:=1;		
	ELSIF EditorController.CMD.Clear THEN
		EditorController.HMI.Command:= EC_CLEAR;		
		EditorController.Internal.CMD.Clear:=1;
	END_IF
	
	IF NOT EditorController.CMD.Save THEN
		EditorController.Internal.CMD.Save:=0;
	ELSIF NOT EditorController.CMD.Load THEN	
		EditorController.Internal.CMD.Load:=0;		
	ELSIF NOT EditorController.CMD.Clear THEN		
		EditorController.Internal.CMD.Clear:=0;
	END_IF	
	
	
	EditorControl(EditorController.HMI);
	
END_FUNCTION

(* Controls an HMI edit control *)
FUNCTION EditorControl
	
	EditorControl:=0;
	
	CASE Editor.internal.CommandState OF
		0:
			Editor.internal.CommandState:=Editor.internal.CommandState+1;

			CASE Editor.Command OF
				EC_APPEND://append
					EditControl_CS_append(Editor.internal.EditText,Editor.Runtime.Commands.RequestDp);
				EC_CLEAR://clear
					Editor.Runtime.Commands.RequestDp:='clear';
				EC_DELETE://delete
					Editor.Runtime.Commands.RequestDp:='delete';
				EC_GET_LINE://getline
					EditControl_CS_getline(Editor.internal.CurrentLineIndex,Editor.Runtime.Commands.RequestDp);							
				EC_GET_MARKED_TEXT://getmarkedtext
					Editor.Runtime.Commands.RequestDp:='getmarkedtext';
				EC_GET_TEXT_SIZE://gettextsize
					Editor.Runtime.Commands.RequestDp:='gettextsize';
				EC_GOTO://goto
					EditControl_CS_goto(Editor.internal.DesiredLine,Editor.internal.DesiredColumn,Editor.Runtime.Commands.RequestDp);
				EC_HIGHLIGHT://highlight
					EditControl_CS_highlight(Editor.internal.DesiredLine,Editor.internal.highlightmode,Editor.Runtime.Commands.RequestDp);
				EC_INSERT://insert
					EditControl_CS_insert(Editor.internal.EditText,Editor.internal.DesiredLine,Editor.Runtime.Commands.RequestDp);
				EC_LOAD://load
					Editor.Runtime.Commands.RequestDp:='load';
				EC_READ://read
					EditControl_CS_read(Editor.internal.Offset,Editor.internal.Count,Editor.Runtime.Commands.RequestDp);
				EC_REPLACE_MARKED_TEXT://replacemarkedtext
					EditControl_CS_replacemarked(Editor.internal.EditText,Editor.Runtime.Commands.RequestDp);
				EC_SAVE://save
					Editor.Runtime.Commands.RequestDp:='save';
				EC_UPDATE://update
					Editor.Runtime.Commands.RequestDp:='update';					
				ELSE
					Editor.internal.CommandState:=0;
			END_CASE

		1:
			IF Editor.Runtime.Commands.StatusDP = 0 THEN						
				Editor.internal.CommandState:=Editor.internal.CommandState+1;
			END_IF
		
		2:
			Editor.Command:=0;
			Editor.Runtime.Commands.StatusDP:=	1;	
			Editor.internal.CommandState:=Editor.internal.CommandState+1;
		
		3:
			IF Editor.Runtime.Commands.StatusDP = 0 THEN						
				Editor.internal.CurrentLineText:=Editor.Runtime.Commands.ResponseDp;				
				Editor.internal.CommandState:=0;	
			END_IF
	END_CASE;
	
END_FUNCTION

FUNCTION EditControl_CS_append
	
	EditControl_CS_append:=0;
	
	Output:=CONCAT('append text=',Text);
	
END_FUNCTION

FUNCTION EditControl_CS_getline

	EditControl_CS_getline:=0;

	brsitoa(Line,ADR(temp));
	Output:=CONCAT('getline line=',temp);
	
END_FUNCTION

FUNCTION EditControl_CS_goto
	
	EditControl_CS_goto:=0;
	
	brsitoa(Col,ADR(temp));
	Output:=CONCAT('goto col=',temp);
	Output:=CONCAT(Output,' line=');
	brsitoa(Line,ADR(temp));	
	Output:=CONCAT(Output,temp);	

END_FUNCTION

FUNCTION EditControl_CS_highlight
	
	EditControl_CS_highlight:=0;
	
	brsitoa(Value,ADR(temp));		
	IF Mode = 0 THEN
		Output:=CONCAT('highlight offset=',temp);
	ELSE
		Output:=CONCAT('highlight line=',temp);		
	END_IF
END_FUNCTION

FUNCTION EditControl_CS_insert
	
	EditControl_CS_insert:=0;
	
	brsitoa(Line,ADR(temp));			
	Output:=CONCAT('insert line=',temp);
	Output:=CONCAT(Output,' text=');	
	Output:=CONCAT(Output,Text);	
END_FUNCTION

FUNCTION EditControl_CS_read
	
	EditControl_CS_read:=0;
	
	brsitoa(Offset,ADR(temp));	
	Output:=CONCAT('read offset=',temp);
	Output:=CONCAT(Output,' count=');	
	brsitoa(Count,ADR(temp));	
	Output:=CONCAT(Output,temp);

END_FUNCTION

FUNCTION EditControl_CS_replacemarked
	
	EditControl_CS_replacemarked:=0;
	
	Output:=CONCAT('replacemarkedtext text=',Text);
	
END_FUNCTION

FUNCTION EditControl_CS_replaceline

	EditControl_CS_replaceline:=0;
	
	brsitoa(Line,ADR(temp));			
	Output:=CONCAT('update line=',temp);
	Output:=CONCAT(Output,' text=');	
	Output:=CONCAT(Output,Text);

END_FUNCTION