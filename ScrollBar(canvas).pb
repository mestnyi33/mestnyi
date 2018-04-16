EnableExplicit

;- STRUCTURE
Structure Coordinate
  y.l[3]
  x.l[3]
  Height.l[3]
  Width.l[3]
EndStructure

Structure Scroll Extends Coordinate
  ButtonLength.l
  
  Max.l
  Min.l
  *Step
  
  Pos.l
  PageLength.l
  
  AreaPos.l
  AreaLength.l
  
  ThumbPos.l
  ThumbLength.l
  
  Color.l[3]
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
EndStructure

Structure Gadget Extends Coordinate
  Canvas.Canvas
  
  Text.s[3]
  ImageID.l[3]
  Color.l[3]
  
  Image.Coordinate
  
  fSize.l
  bSize.l
  
  Scroll.Scroll
  IsVertical.l
  
  Type.l
  InnerCoordinate.Coordinate
  
  Repaint.l
  
  List Items.Gadget()
  List Columns.Gadget()
EndStructure





;- PROCEDURE
Procedure ScrollPos(*This.Gadget, ThumbPos.l)
  Protected Pos.l
  
  With *This
    Pos = \Scroll\Min + Round((ThumbPos - \Scroll\AreaPos) / (\Scroll\AreaLength / (\Scroll\Max-\Scroll\Min)), #PB_Round_Nearest)
    If (\IsVertical And \Type = #PB_GadgetType_TrackBar) : Pos = ((\Scroll\Max-\Scroll\Min)-Pos) : EndIf
  EndWith
  
  ProcedureReturn Pos
EndProcedure

Procedure ThumbPos(*This.Gadget, ScrollPos.l, AreaLength.l)
  Protected ThumbPos.l
  
  With *This
    ThumbPos = (\Scroll\AreaPos + Round((ScrollPos-\Scroll\Min) * (AreaLength / (\Scroll\Max-\Scroll\Min)), #PB_Round_Nearest))
   ;  Debug "pos "+\Scroll\Pos
    
    ;     If (ThumbPos + \Scroll\ThumbLength) > (\Scroll\AreaLength + \Scroll\ButtonLength)
    ;       ThumbPos = ((\Scroll\AreaLength + \Scroll\ButtonLength) - \Scroll\ThumbLength)
    ;     EndIf
  EndWith
  
  ProcedureReturn ThumbPos
EndProcedure

Procedure ThumbLength(*This.Gadget, AreaLength.l)
  Protected ThumbLength.l
  
  With *This
    If (\Scroll\Max-\Scroll\Min) > \Scroll\PageLength
      ThumbLength = Round((AreaLength) - ((AreaLength) / (\Scroll\Max-\Scroll\Min))*((\Scroll\Max-\Scroll\Min) - \Scroll\PageLength), #PB_Round_Nearest)
    EndIf
  EndWith
  
  ProcedureReturn ThumbLength
EndProcedure

Procedure ReCoordinate(*This.Gadget)
  Protected Area, Result, ButtonLength
  
  With *This
    If \IsVertical
      \Scroll\AreaPos = \Y[2]+\Scroll\ButtonLength
      \Scroll\AreaLength = (\Height[2]-\Scroll\ButtonLength*2)
    Else
      \Scroll\AreaPos = \X[2]+\Scroll\ButtonLength
      \Scroll\AreaLength = (\Width[2]-\Scroll\ButtonLength*2)
    EndIf
    
    Area = \Scroll\AreaLength
    ButtonLength = \Scroll\ButtonLength
    
    Result = ThumbLength(*This, Area)
    
    If (Area > ButtonLength)
      If (Result < ButtonLength)
        Area = Round(\Scroll\AreaLength - (ButtonLength-Result), #PB_Round_Nearest)
        Result = ButtonLength 
      EndIf
    Else
      Result = Area 
    EndIf
    
    \Scroll\ThumbLength = Result
    
    If Area > 0
      \Scroll\ThumbPos = ThumbPos(*This, \Scroll\Pos, Area)
    EndIf
  EndWith
  
EndProcedure


Procedure Re(*This.Gadget)
  With *This
    If Not *This\Repaint
      *This\Repaint = #True
    EndIf
    
    If \IsVertical
      ; Верхняя кнопка на скролл баре
      \Scroll\X[1] = \X[2] + 1
      \Scroll\Y[1] = \Y[2]
      \Scroll\Width[1] = \Width[2] - 1
      \Scroll\Height[1] = \Scroll\ButtonLength
      
      ; Нижняя кнопка на скролл баре
      \Scroll\X[2] = \X[2] + 1
      \Scroll\Width[2] = \Width[2] - 1
      \Scroll\Height[2] = \Scroll\ButtonLength
      \Scroll\Y[2] = \Y[2]+\Height[2]-\Scroll\Height[2]
      
      ; Ползунок на скролл баре
      \Scroll\X[0] = \X[2] + 1
      \Scroll\Width[0] = \Width[2] - 1
      \Scroll\Y[0] = \Scroll\ThumbPos
      \Scroll\Height[0] = \Scroll\ThumbLength
      
    Else
      ; Верхняя кнопка на скролл баре
      \Scroll\X[1] = \X[2]
      \Scroll\Y[1] = \Y[2] + 1
      \Scroll\Width[1] = \Scroll\ButtonLength
      \Scroll\Height[1] = \Height[2] - 1
      
      ; Нижняя кнопка на скролл баре
      \Scroll\Y[2] = \Y[2] + 1
      \Scroll\Height[2] = \Height[2] - 1
      \Scroll\Width[2] = \Scroll\ButtonLength
      \Scroll\X[2] = \X[2]+\Width[2]-\Scroll\Width[2]
      
      ; Ползунок на скролл баре
      \Scroll\Y[0] = \Y[2] + 1
      \Scroll\Height[0] = \Height[2] - 1
      \Scroll\X[0] = \Scroll\ThumbPos
      \Scroll\Width[0] = \Scroll\ThumbLength
      
    EndIf
  EndWith  
EndProcedure

Procedure Draw(*This.Gadget)
  With *This
    If \Repaint And StartDrawing(CanvasOutput(\Canvas\Gadget))
      DrawingFont(GetGadgetFont(#PB_Default))
      
      If \fSize
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(\X[1],\Y[1],\Width[1],\Height[1],\Color[1])
      EndIf
      
      DrawingMode(#PB_2DDrawing_Default)
      If \IsVertical
        Box(\X[2]+1,\Y[2],\Width[2]-1,\Height[2],\Color[2])
        Line(\X[2],\Y[2],1,\Height[2],\Color[0])
      Else
        Box(\X[2],\Y[2]+1,\Width[2],\Height[2]-1,\Color[2])
        Line(\X[2],\Y[2],\Width[2],1,\Color[0])
      EndIf
      
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(\Scroll\X[1],\Scroll\Y[1],\Scroll\Width[1],\Scroll\Height[1],\Scroll\Color[1])
      Box(\Scroll\X[0],\Scroll\Y[0],\Scroll\Width[0],\Scroll\Height[0],\Scroll\Color[0])
      Box(\Scroll\X[2],\Scroll\Y[2],\Scroll\Width[2],\Scroll\Height[2],\Scroll\Color[2])
      
      \Repaint = #False
      StopDrawing()
    EndIf
  EndWith  
EndProcedure

Procedure ReDraw(*This.Gadget)
  Re(*This)
  Draw(*This)
EndProcedure


Procedure GetAttribute(*This.Gadget, Attribute)
  Protected Result
  
  With *This
    Select Attribute
      Case #PB_ScrollBar_Minimum    : Result = \Scroll\Min
      Case #PB_ScrollBar_Maximum    : Result = \Scroll\Max
      Case #PB_ScrollBar_PageLength : Result = \Scroll\PageLength
    EndSelect
  EndWith
  
  ProcedureReturn Result
EndProcedure

Procedure SetAttribute(*This.Gadget, Attribute, Value)
  Protected Change.b
  
  With *This
    
    Select Attribute
      Case #PB_ScrollBar_Minimum
        If \Scroll\Min <> Value
          \Scroll\Min = Value
          \Scroll\Pos = Value
          Change = #True
        EndIf
        
      Case #PB_ScrollBar_Maximum
        If \Scroll\Max <> Value
          If \Scroll\Min > Value
            \Scroll\Max = \Scroll\Min + 1
          Else
            \Scroll\Max = Value + 1
          EndIf
          Change = #True
        EndIf
        
      Case #PB_ScrollBar_PageLength
        If \Scroll\PageLength <> Value
          If Value > (\Scroll\Max-\Scroll\Min)
            \Scroll\PageLength = (\Scroll\Max-\Scroll\Min)
          Else
            \Scroll\PageLength = Value
          EndIf
          \Scroll\Pos = Abs(\Scroll\Pos) ; ?
          Change = #True
        EndIf
        
    EndSelect
    
    If Change
      ReCoordinate(*This)
    EndIf
    
  EndWith
  
EndProcedure

Procedure GetPos(*This.Gadget)
  With *This
    ProcedureReturn \Scroll\Pos
  EndWith
EndProcedure

Procedure SetPos(*This.Gadget, ScrollPos)
  With *This
    If ScrollPos < \Scroll\Min : ScrollPos = \Scroll\Min : EndIf
    If ScrollPos > ((\Scroll\Max)-\Scroll\PageLength)
      ScrollPos = ((\Scroll\Max)-\Scroll\PageLength)
    EndIf
    
    If \Scroll\Pos<>ScrollPos : \Scroll\Pos=ScrollPos
      \Scroll\ThumbPos = ThumbPos(*This, ScrollPos, \Scroll\AreaLength)
      
      ReDraw(*This)
      PostEvent(#PB_Event_Gadget, EventWindow(), \Canvas\Gadget, #PB_EventType_Change)
    EndIf
  EndWith
EndProcedure


Procedure CallBack()
  Static LastX, LastY
  Protected *This.Gadget = GetGadgetData(EventGadget())
  
  With *This
    \Canvas\Mouse\X = GetGadgetAttribute(\Canvas\Gadget, #PB_Canvas_MouseX)
    \Canvas\Mouse\Y = GetGadgetAttribute(\Canvas\Gadget, #PB_Canvas_MouseY)
    \Canvas\Mouse\Buttons = GetGadgetAttribute(\Canvas\Gadget, #PB_Canvas_Buttons)
    
    Select EventType()
      Case #PB_EventType_LeftButtonUp
        LastX = 0
        LastY = 0
        
      Case #PB_EventType_LeftButtonDown
        If (\Canvas\Mouse\x>\Scroll\x[0] And \Canvas\Mouse\x=<\Scroll\x[0]+\Scroll\Width[0] And 
            \Canvas\Mouse\y>\Scroll\y[0] And \Canvas\Mouse\y=<\Scroll\y[0]+\Scroll\Height[0])
          LastX = \Canvas\Mouse\X - \Scroll\ThumbPos
          LastY = \Canvas\Mouse\Y - \Scroll\ThumbPos
        EndIf
        
      Case #PB_EventType_MouseMove
        If \Canvas\Mouse\Buttons And Bool(LastX|LastY)
          If \IsVertical
            SetPos(*This, ScrollPos(*This, ((\Canvas\Mouse\Y-LastY))))
          Else
            SetPos(*This, ScrollPos(*This, ((\Canvas\Mouse\X-LastX))))
          EndIf
        EndIf
        
    EndSelect
  EndWith
  
  ; Draw(*This)
EndProcedure


  Procedure Gadget(Gadget, X.l, Y.l, Width.l, Height.l, Min.l, Max.l, Pagelength.l, Flag.l=0)
    Protected *This.Gadget=AllocateStructure(Gadget)
    Protected g = CanvasGadget(Gadget, X, Y, Width, Height) : If Gadget=-1 : Gadget=g : EndIf
    
    If *This
      With *This
        \Canvas\Gadget = Gadget
        \Width = Width
        \Height = Height
        
        \fSize = 0
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
        
        \Scroll\ButtonLength = 17
        \IsVertical = Bool(Flag&#PB_ScrollBar_Vertical)
        
        \Color = $FFFFFF
        \Color[1] = $C0C0C0
        \Color[2] = $F0F0F0
        
        SetAttribute(*This, #PB_ScrollBar_Minimum, Min)
        SetAttribute(*This, #PB_ScrollBar_Maximum, Max)
        SetAttribute(*This, #PB_ScrollBar_PageLength, PageLength)
        
        Re(*This)
        Draw(*This)
        SetGadgetData(Gadget, *This)
        BindGadgetEvent(Gadget, @CallBack())
      EndIf
    EndWith
    
    ProcedureReturn Gadget
  EndProcedure

If LoadImage(0, #PB_Compiler_Home+"Examples\Sources\Data\File.bmp")     ; Измените путь/имя файла на собственное изображение 32x32 пикселя
EndIf
Define a,i


Procedure GadgetCallBack()
  Protected *This.Gadget = GetGadgetData(10)
  ;   SetAttribute(*This, #PB_ScrollBar_PageLength)
  
  SetPos(*This, GetGadgetState(EventGadget()))
EndProcedure

Procedure h_GadgetCallBack()
  Protected *This.Gadget = GetGadgetData(12)
  ;   SetAttribute(*This, #PB_ScrollBar_PageLength)
  ;Debug GetGadgetState(EventGadget())
  SetPos(*This, GetGadgetState(EventGadget()))
EndProcedure

Procedure h_CallBack()
  Protected *This.Gadget = GetGadgetData(EventGadget())
  ;   SetAttribute(*This, #PB_ScrollBar_PageLength)
  ;Debug GetGadgetState(EventGadget())
  SetGadgetState(2, GetPos(*This))
EndProcedure

If OpenWindow(0, 0, 0, 630, 450, "TreeGadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  Define t=ElapsedMilliseconds()
  
  Define g = 1
  ListIconGadget(g, 10, 10, 560, 210,"Column_1",100)                                         
  For i=1 To 2
    AddGadgetColumn(g, i,"Column_"+Str(i+1),100)
  Next
  ; 1_example
  For i=0 To 15
    AddGadgetItem(g, i, Str(i)+"_Column_1"+#LF$+Str(i)+"_Column_2"+#LF$+Str(i)+"_Column_3"+#LF$+Str(i)+"_Column_4", ImageID(0))                                           
  Next
  
  Debug "time "+Str(ElapsedMilliseconds()-t)
  t=ElapsedMilliseconds()
  
  Define max=CountGadgetItems(g)*21
  
  BindGadgetEvent(ScrollBarGadget  (-1, 575, 10, 20, 210,0,max, 210, #PB_ScrollBar_Vertical),@GadgetCallBack())
  
  g = 10
  Gadget(g, 600, 10, 20, 210,0,max, 210, #PB_ScrollBar_Vertical)                                         
  ;   For g = 10 To 100
  ;   Gadget(g, 600, 10, 20, 210,0,max, 210)                                         
  ;   Next
  
  Debug "time "+Str(ElapsedMilliseconds()-t)
  
  ;   Define *This.Gadget = GetGadgetData(g)
  ;   
  ;   With *This\Columns()
  ;     Debug "Scroll_Height "+*This\Scroll\Height
  ;   EndWith
  
  
  ;   If OpenWindow(0, 0, 0, 305, 140, "ScrollBarGadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  TextGadget       (-1,  10, 220+25, 250,  20, "ScrollBar Standard  (start=50, page=30/100)",#PB_Text_Center)
  ScrollBarGadget  (2,  10, 220+42, 250,  20, 30, 100, 30)
  SetGadgetState   (2,  50)   ; set 1st scrollbar (ID = 0) to 50 of 100
  TextGadget       (-1,  10,220+115, 250,  20, "ScrollBar Vertical  (start=100, page=50/300)",#PB_Text_Right)
  ScrollBarGadget  (3, 270, 220+10,  25, 120 ,0, 300, 50, #PB_ScrollBar_Vertical)
  SetGadgetState   (3, 100)   ; set 2nd scrollbar (ID = 1) to 100 of 300
  
  TextGadget       (-1,  300+10, 220+25, 250,  20, "ScrollBar Standard  (start=50, page=30/100)",#PB_Text_Center)
  Gadget  (12,  300+10, 220+42, 250,  20, 30, 100, 30)
  Define *This.Gadget = GetGadgetData(12)
  SetPos   (*This,  50)   ; set 1st scrollbar (ID = 0) to 50 of 100
  TextGadget       (-1,  300+10,220+115, 250,  20, "ScrollBar Vertical  (start=100, page=50/300)",#PB_Text_Right)
  Gadget  (13, 300+270, 220+10,  25, 120 ,0, 300, 50, #PB_ScrollBar_Vertical)
  Define *This.Gadget = GetGadgetData(13)
  SetPos   (*This, 100)   ; set 2nd scrollbar (ID = 1) to 100 of 300
                            ;     Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
                            ;   EndIf
  
  BindGadgetEvent(2,@h_GadgetCallBack())
  BindGadgetEvent(12,@h_CallBack(), #PB_EventType_Change)
  Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 346
; FirstLine = 270
; Folding = A---
; EnableXP