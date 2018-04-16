;-
DeclareModule String
  EnableExplicit
  
  ;- STRUCTURE
  Structure Coordinate
    y.l[3]
    x.l[3]
    Height.l[3]
    Width.l[3]
  EndStructure
  
  Structure Mouse
    X.l
    Y.l
    Buttons.l
  EndStructure
  
  Structure Canvas
    Mouse.Mouse
    Gadget.l
    Window.l
    
    Input.c
    Key.l[2]
    
  EndStructure
  
  Structure Text Extends Coordinate
    ;     Char.c
    String.s[3]
    Change.b
    
    Align.b
    Lower.b
    Upper.b
    Pass.b
    Editable.b
    Numeric.b
    
    Length.l
    
    CaretPos.l[3] ; 0 = Pos ; 1 = PosFixed ; 2 = PosMoved
    CaretLength.l
    
    PosX.l
    PosY.l

    Mode.l
  EndStructure
  
  Structure Gadget Extends Coordinate
    FontID.l
    Canvas.Canvas
    
    Text.Text[3]
    ImageID.l[3]
    Color.l[3]
    
    Image.Coordinate
    
    fSize.l
    bSize.l
    Hide.b[2]
    Disable.b[2]
    
    Scroll.Coordinate
    
    Type.l
    InnerCoordinate.Coordinate
    
    Repaint.l
    
    List Items.Gadget()
    List Columns.Gadget()
  EndStructure
  
  
  ;- DECLARE
  Declare GetState(Gadget.l)
  Declare SetState(Gadget.l, State.l)
  Declare GetAttribute(Gadget.l, Attribute.l)
  Declare SetAttribute(Gadget.l, Attribute.l, Value.l)
  Declare Gadget(Gadget, X.l, Y.l, Width.l, Height.l, Text.s, Flag.l=0)
  
EndDeclareModule

Module String
  
  ;- PROCEDURE
  
  Procedure CaretPos(*This.Gadget)
    Protected X,Y,Result =- 1, i, CursorX, Distance.f, MinDistance.f = Infinity()
    
    With *This
      Protected len = Len(\Text\String.s) 
      
      For i=0 To len
        CursorX = (\Text\x + TextWidth(Left(\Text\String.s, i))) - \Text\PosX + 1
        Distance = (\Canvas\Mouse\X-CursorX)*(\Canvas\Mouse\X-CursorX)
        
        ; Получаем позицию коpректора
        If MinDistance > Distance 
          MinDistance = Distance
          Result = i
        EndIf
      Next
    EndWith
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure SelectionText(*This.Gadget)
    
    With *This
      If \Text\CaretPos[1] > \Text\CaretPos
        ; Если выделяем с право на лево
        \Text\CaretPos[2] = \Text\CaretPos
        \Text\CaretLength = (\Text\CaretPos[1]-\Text\CaretPos)
      Else
        ; Если выделяем с лева на право
        \Text\CaretPos[2] = \Text\CaretPos[1]
        \Text\CaretLength = \Text\CaretPos-\Text\CaretPos[1]
      EndIf
      If \Text\CaretPos[1] = \Text\CaretPos
        \Text\String.s[1] = ""
      Else
        \Text\String.s[1] = Mid(\Text\String.s, \Text\CaretPos[2] + 1, \Text\CaretLength)
      EndIf
    EndWith
    
  EndProcedure
  
  Procedure SelectionLimits(*This.Gadget)
    With *This
      Protected i, char = Asc(Mid(\Text\String.s, \Text\CaretPos + 1, 1))
      
      If (char > =  ' ' And char < =  '/') Or 
         (char > =  ':' And char < =  '@') Or 
         (char > =  '[' And char < =  96) Or 
         (char > =  '{' And char < =  '~')
        
        \Text\CaretPos[1] = \Text\CaretPos
        \Text\CaretPos + 1
        \Text\CaretLength = \Text\CaretPos[1] - \Text\CaretPos
      Else
        For i = \Text\CaretPos To 0 Step - 1
          char = Asc(Mid(\Text\String.s, i, 1))
          If (char > =  ' ' And char < =  '/') Or 
             (char > =  ':' And char < =  '@') Or 
             (char > =  '[' And char < =  96) Or 
             (char > =  '{' And char < =  '~')
            Break
          EndIf
        Next
        
        If i =- 1 : \Text\CaretPos[1] = 0 : Else : \Text\CaretPos[1] = i : EndIf
        
        For i = \Text\CaretPos + 1 To Len(\Text\String.s)
          char = Asc(Mid(\Text\String.s, i, 1))
          If (char > =  ' ' And char < =  '/') Or 
             (char > =  ':' And char < =  '@') Or
             (char > =  '[' And char < =  96) Or 
             (char > =  '{' And char < =  '~')
            Break
          EndIf
        Next
        
        \Text\CaretPos = i - 1
        
        \Text\CaretLength = \Text\CaretPos[1] - \Text\CaretPos
        
        If \Text\CaretLength < 0 : \Text\CaretLength = 0 : EndIf
      EndIf
    EndWith           
  EndProcedure
  
  Procedure EditableCallBack(*This.Gadget, EventType.l)
    Static Text$, DoubleClickCaretPos =- 1
    Protected PostEvent, Quit.b, Result, StartDrawing, Update_Text_Selected
    
    Protected ret, Input, Blink_Text$
    
    
    If *This
      With *This
        If Not \Disable
          If Bool(EventType = #PB_EventType_LeftDoubleClick Or EventType = #PB_EventType_LeftButtonDown Or *This\Canvas\Mouse\Buttons Or *This\Canvas\Key = #PB_Shortcut_Back)
            StartDrawing = StartDrawing(CanvasOutput(*This\Canvas\Gadget)) : If \FontID : DrawingFont(\FontID) : EndIf
          EndIf
          
          Select EventType
            Case #PB_EventType_LostFocus 
              \Text\String.s[1] = "" 
              \Text\CaretPos[1] = 0
              
            Case #PB_EventType_Focus
              \Text\CaretPos[1] = \Text\CaretPos
              Update_Text_Selected = #True
              
            Case #PB_EventType_Input
              If \Text\Editable
              Select #True
                Case \Text\Lower : Input = Asc(LCase(Chr(\Canvas\Input)))
                Case \Text\Upper : Input = Asc(UCase(Chr(\Canvas\Input)))
                Case \Text\Pass  : Input = 9679 ; "●" \Canvas\Input
                Case \Text\Numeric 
                  Select \Canvas\Input 
                    Case '.','0' To '9' : Input = \Canvas\Input
                  EndSelect
                Default
                  Input = \Canvas\Input 
              EndSelect
              
              If Input
                If \Text\String.s[1]
                  If \Text\CaretPos > \Text\CaretPos[1] : \Text\CaretPos = \Text\CaretPos[1] : EndIf
                  \Text\String.s = RemoveString(\Text\String.s, \Text\String.s[1], #PB_String_CaseSensitive, \Text\CaretPos, 1)
                  \Text\String.s[1] = ""
                EndIf
                
                \Text\CaretPos + 1
                \Text\CaretPos[1] = \Text\CaretPos
                ;\Text\String.s = Left(\Text\String.s, \Text\CaretPos-1) + Chr(Input) + Mid(\Text\String.s, \Text\CaretPos)
                \Text\String.s = InsertString(\Text\String.s, Chr(Input), \Text\CaretPos)
              EndIf
            EndIf
            
            Case #PB_EventType_KeyDown
              Select *This\Canvas\Key
                Case #PB_Shortcut_Home : \Text\String.s[1] = "" : \Text\CaretPos = 0 : \Text\CaretPos[1] = \Text\CaretPos
                Case #PB_Shortcut_End : \Text\String.s[1] = "" : \Text\CaretPos = Len(\Text\String.s) : \Text\CaretPos[1] = \Text\CaretPos
                  Case #PB_Shortcut_Left : \Text\String.s[1] = "" : If \Text\CaretPos > 0 : \Text\CaretPos - 1 : \Text\CaretPos[1] = \Text\CaretPos : EndIf
                  Case #PB_Shortcut_Right : \Text\String.s[1] = "" : If \Text\CaretPos < Len(\Text\String.s) : \Text\CaretPos + 1 : \Text\CaretPos[1] = \Text\CaretPos : EndIf
                Case #PB_Shortcut_Back 
                  If \Text\String.s[1]
                    If \Text\CaretPos > \Text\CaretPos[1] : \Text\CaretPos = \Text\CaretPos[1] : EndIf
                    \Text\String.s = RemoveString(\Text\String.s, \Text\String.s[1], #PB_String_CaseSensitive, \Text\CaretPos, 1)
                    Blink_Text$ = \Text\String.s[1]
                    \Text\String.s[1] = ""
                  Else
                    If \Text\CaretPos > 0
                      Blink_Text$ = Mid(\Text\String.s, \Text\CaretPos, 1)
                      \Text\String.s = Left(\Text\String.s, \Text\CaretPos - 1) + Right(\Text\String.s, Len(\Text\String.s)-\Text\CaretPos)
                      \Text\CaretPos - 1 
                    EndIf
                  EndIf
                  
                  If StartDrawing And Blink_Text$ And \Text\PosX > -2
                    \Text\PosX - TextWidth(Blink_Text$) : If \Text\PosX < -2 : \Text\PosX =- 2 : EndIf
                  EndIf
                  
                  \Text\CaretPos[1] = \Text\CaretPos
                  
                Case #PB_Shortcut_C
                  If (*This\Canvas\Key[1] & #PB_Canvas_Control)
                    SetClipboardText(\Text\String.s[1])
                  EndIf
                  
                Case #PB_Shortcut_V
                  If (*This\Canvas\Key[1] & #PB_Canvas_Control)
                    Protected ClipboardText.s = GetClipboardText()
                    
                    If \Text\String.s[1]
                      If \Text\CaretPos > \Text\CaretPos[1] : \Text\CaretPos = \Text\CaretPos[1] : EndIf
                      \Text\String.s = RemoveString(\Text\String.s, \Text\String.s[1], #PB_String_CaseSensitive, \Text\CaretPos, 1)
                      Blink_Text$ = \Text\String.s[1]
                      \Text\String.s[1] = ""
                    EndIf
                    
                    Select #True
                      Case \Text\Lower : ClipboardText.s = LCase(ClipboardText.s)
                      Case \Text\Upper : ClipboardText.s = UCase(ClipboardText.s)
                      Case \Text\Numeric : ClipboardText.s = Str(Val(ClipboardText.s))
                    EndSelect
                    
                    \Text\String.s = InsertString(\Text\String.s, ClipboardText.s, \Text\CaretPos + 1)
                    \Text\CaretPos + Len(ClipboardText.s)
                    \Text\CaretPos[1] = \Text\CaretPos
                    
                    If StartDrawing And Blink_Text$ And \Text\PosX > -2
                      \Text\PosX - TextWidth(Blink_Text$) : If \Text\PosX < -2 : \Text\PosX =- 2 : EndIf
                    EndIf
                    
                  EndIf
                  
              EndSelect 
              
              
            Case #PB_EventType_LeftDoubleClick 
              \Text\CaretPos = CaretPos(*This) 
              DoubleClickCaretPos = \Text\CaretPos
              
              If \Text\Pass
                \Text\CaretPos = Len(\Text\String.s)
                \Text\CaretLength = \Text\CaretPos
                \Text\CaretPos[1] = 0
              Else
                SelectionLimits(*This)
              EndIf
              
              Update_Text_Selected = #True
              
            Case #PB_EventType_LeftButtonDown
              \Text\CaretPos = CaretPos(*This)
              
              If \Text\CaretPos = DoubleClickCaretPos
                \Text\CaretPos = Len(\Text\String.s)
                \Text\CaretPos[1] = 0
              Else
                \Text\CaretPos[1] = \Text\CaretPos
              EndIf 
              
              DoubleClickCaretPos =- 1
              Update_Text_Selected = #True
              
            Case #PB_EventType_MouseMove
              If \Canvas\Mouse\Buttons & #PB_Canvas_LeftButton
                \Text\CaretPos = CaretPos(*This)
                Update_Text_Selected = #True
                Quit = #True 
              EndIf
              
          EndSelect
          
          If Update_Text_Selected 
            SelectionText(*This)
          EndIf
          
          If StartDrawing
            StopDrawing()
          EndIf
          
          If Quit
            ProcedureReturn #True
          EndIf
         EndIf
      EndWith
    EndIf
    
    ProcedureReturn 1
  EndProcedure
  
  Procedure ContrastColor(iColor)
    Protected luma.d
    ;  Counting the perceptive luminance (aka luma) - human eye favors green color... 
    luma  = (0.299 * Red(iColor) + 0.587 * Green(iColor) + 0.114 * Blue(iColor)) / 255
    
    ; Return black For bright colors, white For dark colors
    If luma > 0.6
      ProcedureReturn #Black
    Else
      ProcedureReturn #White
    EndIf
  EndProcedure
  
  Procedure Re(*This.Gadget)
    With *This
      If Not *This\Repaint : *This\Repaint = #True : EndIf
      
    EndWith   
  EndProcedure
  
  Procedure Draw(*This.Gadget)
    With *This
      If \Repaint And StartDrawing(CanvasOutput(\Canvas\Gadget))
        DrawingFont(\FontID)
        Box(\X[1],\Y[1],\Width[1],\Height[1],\Color[0])
        
        If \fSize
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(\X[1],\Y[1],\Width[1],\Height[1],\Color[1])
        EndIf
        
        \Text\Height = TextHeight("A")
        \Text\Width = TextWidth(\Text\String.s)
        \Text\Length = Len(\Text\String.s)
        \Text\Y = (\Height[1]-\Text\Height)/2
        
        Select \Text\Align 
          Case 9
          \Text\X = (\Width[1]-\Text\Width)/2
          Case 2
          \Text\X = (\Width[1]-\Text\Width)
          
        EndSelect
        
        If \ImageID : DrawImage(\ImageID, \x,\y+(\height-\Image\Height)/2) : EndIf
        
        
        
        Protected Txt_X=\Text\X, BackColor = $FFFFFF, FontColor = 0
        Protected iWidth=\Width,TextHeight=14, Text$=\Text\String.s
        
        
;         If \Text\Pass
;           Protected i, Len
;           Text$=""
;           \Text\String.s[1] = ""
; ; ;           If \Text\String.s[1]
; ; ;             Len = Len(\Text\String.s[1])
; ; ;             For i=0 To Len
; ; ;               Text$ + "●"
; ; ;             Next
; ; ;             \Text\String.s[1] = Text$
; ; ;             Text$=""
; ; ;           EndIf
;           For i=0 To \Text\Length
;             Text$ + "●"
;           Next
;         EndIf
        
        If Text$
          Protected Area = iWidth - (4+2)
          Protected cptWidth = TextWidth(Left(Text$, \Text\CaretPos)) - 2
          
          ; Перемещаем корректор
          If \Text\Editable
            If \Text\CaretPos = 0 : \Text\PosX =- 2 : Else
              If (cptWidth>Area) And ((cptWidth-Area)>\Text\PosX) : \Text\PosX = (cptWidth-Area) : EndIf
              If (\Text\PosX>cptWidth) : \Text\PosX = cptWidth : EndIf
            EndIf
          EndIf
          
          Protected TextPosX = \Text\PosX
          Txt_X - TextPosX
          
          
          If \Text\CaretPos=\Text\CaretPos[1]
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawText(Txt_X, \Text\Y, Text$, FontColor, BackColor)
          Else
            Protected Left_Text$ = Left(Text$, \Text\CaretPos[2])
            Protected Right_Text$ = Mid(Text$, \Text\CaretPos[2] +1+ Len(\Text\String.s[1]))
            
            If Left_Text$
              DrawingMode(#PB_2DDrawing_Transparent)
              DrawText(Txt_X, \Text\Y, Left_Text$, FontColor)
            EndIf
            ;
            If \Text\String.s[1]
              DrawingMode(#PB_2DDrawing_Default)
              DrawText(Txt_X + (TextWidth(Left(Text$, \Text\CaretPos[2]))), \Text\Y, \Text\String.s[1], $FFFFFF, $D77800)
            EndIf
            
            If Right_Text$
              DrawingMode(#PB_2DDrawing_Transparent)
              DrawText(Txt_X + (TextWidth(Left(Text$, \Text\CaretPos[2])) + TextWidth(\Text\String.s[1])), \Text\Y, Right_Text$, FontColor)
            EndIf
          EndIf
        EndIf
        
        If \Text\Editable ; Перерисовка коректора 
          If \Text\CaretPos=\Text\CaretPos[1] ; And Property_GadgetTimer( 300 )
            DrawingMode(#PB_2DDrawing_XOr)             
            Line(Txt_X+TextWidth(Left(Text$, \Text\CaretPos)), \Text\Y, 1, \Text\Height, $FFFFFF)
          EndIf
        EndIf
        
        
        
        
        
        \Repaint = #False
        StopDrawing()
      EndIf
    EndWith  
  EndProcedure
  
  Procedure ReDraw(*This.Gadget)
    Re(*This)
    Draw(*This)
  EndProcedure
  
  
  Procedure CallBack()
    Static LastX, LastY
    Protected *This.Gadget = GetGadgetData(EventGadget())
    
    With *This
      \Canvas\Window = EventWindow()
      \Canvas\Input = GetGadgetAttribute(\Canvas\Gadget, #PB_Canvas_Input)
      \Canvas\Key = GetGadgetAttribute(\Canvas\Gadget, #PB_Canvas_Key)
      \Canvas\Key[1] = GetGadgetAttribute(\Canvas\Gadget, #PB_Canvas_Modifiers)
      \Canvas\Mouse\X = GetGadgetAttribute(\Canvas\Gadget, #PB_Canvas_MouseX)
      \Canvas\Mouse\Y = GetGadgetAttribute(\Canvas\Gadget, #PB_Canvas_MouseY)
      \Canvas\Mouse\Buttons = GetGadgetAttribute(\Canvas\Gadget, #PB_Canvas_Buttons)
      
      Select EventType()
        Case #PB_EventType_Resize : ResizeGadget(\Canvas\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore) ; Bug (562)
          Re(*This)
          
      EndSelect
      
      
      If EditableCallBack(*This, EventType())
        ReDraw(*This)
      EndIf
      
      ;       *This\Repaint = Scroll::CallBack(*This\Scroll, EventType(), \Canvas\Mouse\X, \Canvas\Mouse\Y)
      ;       If *This\Repaint 
      ;         ReDraw(*This)
      ;         PostEvent(#PB_Event_Gadget, \Canvas\Window, \Canvas\Gadget, #PB_EventType_Change)
      ;       EndIf
    EndWith
    
    ; Draw(*This)
  EndProcedure
  
  ;- PUBLIC
  Procedure SetAttribute(Gadget.l, Attribute.l, Value.l)
    Protected *This.Gadget = GetGadgetData(Gadget)
    
    With *This
      
    EndWith
  EndProcedure
  
  Procedure GetAttribute(Gadget.l, Attribute.l)
    Protected Result, *This.Gadget = GetGadgetData(Gadget)
    
    With *This
;       Select Attribute
;         Case #PB_ScrollBar_Minimum    : Result = \Scroll\Min
;         Case #PB_ScrollBar_Maximum    : Result = \Scroll\Max
;         Case #PB_ScrollBar_PageLength : Result = \Scroll\PageLength
;       EndSelect
    EndWith
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure SetState(Gadget.l, State.l)
    Protected *This.Gadget = GetGadgetData(Gadget)
    
    With *This
      
    EndWith
  EndProcedure
  
  Procedure GetState(Gadget.l)
    Protected ScrollPos, *This.Gadget = GetGadgetData(Gadget)
    
    With *This
      
    EndWith
  EndProcedure
  
  Procedure Gadget(Gadget, X.l, Y.l, Width.l, Height.l, Text.s, Flag.l=0)
    Protected *This.Gadget=AllocateStructure(Gadget)
    Protected g = CanvasGadget(Gadget, X, Y, Width, Height, #PB_Canvas_Keyboard) : If Gadget=-1 : Gadget=g : EndIf
    Protected Min.l, Max.l, PageLength.l
    
    If *This
      With *This
        \Canvas\Gadget = Gadget
        \Width = Width
        \Height = Height
        
        \fSize = Bool(Not Flag&#PB_String_BorderLess)
        \bSize = \fSize
        
        ; Inner coordinae
        \X[2]=\bSize
        \Y[2]=\bSize
        \Width[2] = \Width-\bSize*2
        \Height[2] = \Height-\bSize*2
        
        ; Frame coordinae
        \X[1]=\X[2]-\fSize
        \Y[1]=\Y[2]-\fSize
        \Width[1] = \Width[2]+\fSize*2
        \Height[1] = \Height[2]+\fSize*2
        
        \Color[1] = $C0C0C0
        \Color[2] = $F0F0F0
        
        ;\Scroll\ButtonLength = 7
        \Text\Numeric = Bool(Flag&#PB_String_Numeric)
        \Text\Editable = Bool(Not Flag&#PB_String_ReadOnly)
        \Text\Lower = Bool(Flag&#PB_String_LowerCase)
        \Text\Upper = Bool(Flag&#PB_String_UpperCase)
        \Text\Pass = Bool(Flag&#PB_String_Password)
        
        If Bool(Flag&#PB_Text_Center)
          \Text\Align = 9 
        EndIf
     
        If Bool(Flag&#PB_Text_Right)
          \Text\Align = 2 
        EndIf
        
        If \Text\Pass
          Protected i,Len = Len(Text.s)
          Text.s = ""
          For i=0 To Len
            Text.s + "●"
          Next
        EndIf
        
        If \Text\Editable
          \Color[0] = $FFFFFF
        Else
          \Color[0] = $F0F0F0
        EndIf
        
        Select #True
          Case \Text\Lower : \Text\String.s = LCase(Text.s)
          Case \Text\Upper : \Text\String.s = UCase(Text.s)
;           Case \Text\Numeric 
;             Select \Canvas\Input 
;               Case '.','0' To '9' : Input = \Canvas\Input
;             EndSelect
          Default
           \Text\String.s = Text.s
        EndSelect
        
        \FontID = GetGadgetFont(#PB_Default)
        \Text\CaretPos =- 1
        ;         \Text\CaretPos[1] =- 1
        ;         \Text\CaretPos[2] =- 1
        
        ReDraw(*This)
        SetGadgetData(Gadget, *This)
        BindGadgetEvent(Gadget, @CallBack())
      EndIf
    EndWith
    
    ProcedureReturn Gadget
  EndProcedure
EndModule


;- EXAMPLE
If LoadImage(0, #PB_Compiler_Home+"Examples\Sources\Data\File.bmp")     ; Измените путь/имя файла на собственное изображение 32x32 пикселя
EndIf
Define a,i


Procedure v_GadgetCallBack()
  String::SetState(12, GetGadgetState(EventGadget()))
EndProcedure

Procedure v_CallBack()
  SetGadgetState(2, String::GetState(EventGadget()))
EndProcedure

Procedure h_GadgetCallBack()
  String::SetState(11, GetGadgetState(EventGadget()))
EndProcedure

Procedure h_CallBack()
  SetGadgetState(1, String::GetState(EventGadget()))
EndProcedure


If OpenWindow(0, 0, 0, 605, 205, "StringGadget Flags", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  StringGadget(0, 8,  10, 290, 20, "Normal StringGadget...")
  StringGadget(1, 8,  35, 290, 20, "1234567", #PB_String_Numeric|#PB_Text_Center)
  StringGadget(2, 8,  60, 290, 20, "Read-only StringGadget", #PB_String_ReadOnly|#PB_Text_Right)
  StringGadget(3, 8,  85, 290, 20, "LOWERCASE...", #PB_String_LowerCase)
  StringGadget(4, 8, 110, 290, 20, "uppercase...", #PB_String_UpperCase)
  StringGadget(5, 8, 140, 290, 20, "Borderless StringGadget", #PB_String_BorderLess)
  StringGadget(6, 8, 170, 290, 20, "Password", #PB_String_Password)
  
  
  String::Gadget(10, 300+8,  10, 290, 20, "Normal StringGadget...")
  String::Gadget(11, 300+8,  35, 290, 20, "1234567", #PB_String_Numeric|#PB_Text_Center)
  String::Gadget(12, 300+8,  60, 290, 20, "Read-only StringGadget", #PB_String_ReadOnly|#PB_Text_Right)
  String::Gadget(13, 300+8,  85, 290, 20, "LOWERCASE...", #PB_String_LowerCase)
  String::Gadget(14, 300+8, 110, 290, 20, "uppercase...", #PB_String_UpperCase)
  String::Gadget(15, 300+8, 140, 290, 20, "Borderless StringGadget", #PB_String_BorderLess)
  String::Gadget(16, 300+8, 170, 290, 20, "Password", #PB_String_Password)
  
  
  ;   BindGadgetEvent(1,@h_GadgetCallBack())
  ;   BindGadgetEvent(11,@h_CallBack(), #PB_EventType_Change)
  ;   BindGadgetEvent(2,@v_GadgetCallBack())
  ;   BindGadgetEvent(12,@v_CallBack(), #PB_EventType_Change)
  Repeat 
    Event = WaitWindowEvent()
    
    Select Event
      Case #PB_Event_LeftClick  
        SetActiveGadget(0)
      Case #PB_Event_RightClick 
        SetActiveGadget(10)
    EndSelect
  Until Event = #PB_Event_CloseWindow
EndIf



; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 233
; FirstLine = 225
; Folding = ----------------
; EnableXP