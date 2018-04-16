DeclareModule Scroll
  EnableExplicit
  
  Structure Scroll
    y.l[3]
    x.l[3]
    Height.l[3]
    Width.l[3]
    
    Type.l
    Vertical.l
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
  
  Declare.l Pos(*This.Scroll, ThumbPos.l)
  Declare.l ThumbLength(*This.Scroll)
  Declare.l ThumbPos(*This.Scroll, ScrollPos.l)
  Declare.b ReCoordinate(*This.Scroll, iX.l,iY.l,iWidth.l,iHeight.l)
EndDeclareModule

Module Scroll
  Procedure.l Pos(*This.Scroll, ThumbPos.l)
    Protected ScrollPos.l
    
    With *This
      ScrollPos = \Min + Round((ThumbPos - \AreaPos) / (\AreaLength / (\Max-\Min)), #PB_Round_Nearest)
      If (\Vertical And \Type = #PB_GadgetType_TrackBar) : ScrollPos = ((\Max-\Min)-ScrollPos) : EndIf
    EndWith
    
    ProcedureReturn ScrollPos
  EndProcedure
  
  Procedure.l ThumbPos(*This.Scroll, ScrollPos.l)
    Protected ThumbPos.l
    
    With *This
      ThumbPos = (\AreaPos + Round((ScrollPos-\Min) * (\AreaLength / (\Max-\Min)), #PB_Round_Nearest))
      ;  Debug "pos "+\Pos
      ;       
      ;           If (ThumbPos + \ThumbLength) > (\AreaLength + \ButtonLength)
      ;             ThumbPos = ((\AreaLength + \ButtonLength) - \ThumbLength)
      ;           EndIf
    EndWith
    
    ProcedureReturn ThumbPos
  EndProcedure
  
  Procedure.l ThumbLength(*This.Scroll)
    Protected ThumbLength.l
    
    With *This
      ThumbLength = Round(\AreaLength - (\AreaLength / (\Max-\Min))*((\Max-\Min) - \PageLength), #PB_Round_Nearest)
    EndWith
    
    ProcedureReturn ThumbLength
  EndProcedure
  
  Procedure.b ReCoordinate(*This.Scroll, iX.l,iY.l,iWidth.l,iHeight.l)
    With *This
      If \Vertical
        \AreaPos = iY+\ButtonLength
        \AreaLength = (iHeight-\ButtonLength*2)
      Else
        \AreaPos = iX+\ButtonLength
        \AreaLength = (iWidth-\ButtonLength*2)
      EndIf
      
      If (\Max-\Min) > \PageLength
        \ThumbLength = ThumbLength(*This)
      EndIf
      
      If (\AreaLength > \ButtonLength)
        If (\ThumbLength < \ButtonLength)
          \AreaLength = Round(\AreaLength - (\ButtonLength-\ThumbLength), #PB_Round_Nearest)
          \ThumbLength = \ButtonLength 
        EndIf
      Else
        \ThumbLength = \AreaLength 
      EndIf
      
      If \AreaLength > 0
        \ThumbPos = ThumbPos(*This, \Pos)
      EndIf
      
      If \Vertical
        ; Верхняя кнопка на скролл баре
        \X[1] = iX + 1
        \Y[1] = iY
        \Width[1] = iWidth - 1
        \Height[1] = \ButtonLength
        
        ; Нижняя кнопка на скролл баре
        \X[2] = iX + 1
        \Width[2] = iWidth - 1
        \Height[2] = \ButtonLength
        \Y[2] = iY+iHeight-\Height[2]
        
        ; Ползунок на скролл баре
        \X[0] = iX + 1
        \Width[0] = iWidth - 1
        \Y[0] = \ThumbPos
        \Height[0] = \ThumbLength
        
      Else
        ; Верхняя кнопка на скролл баре
        \X[1] = iX
        \Y[1] = iY + 1
        \Width[1] = \ButtonLength
        \Height[1] = iHeight - 1
        
        ; Нижняя кнопка на скролл баре
        \Y[2] = iY + 1
        \Height[2] = iHeight - 1
        \Width[2] = \ButtonLength
        \X[2] = iX+iWidth-\Width[2]
        
        ; Ползунок на скролл баре
        \Y[0] = iY + 1
        \Height[0] = iHeight - 1
        \X[0] = \ThumbPos
        \Width[0] = \ThumbLength
        
      EndIf
      
      
    EndWith
  EndProcedure
  
EndModule

;-
DeclareModule ScrollBar
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
  EndStructure
  
  Structure Gadget Extends Coordinate
    Canvas.Canvas
    
    Text.s[3]
    ImageID.l[3]
    Color.l[3]
    
    Image.Coordinate
    
    fSize.l
    bSize.l
    
    Scroll.Scroll::Scroll
    
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
  Declare Gadget(Gadget, X.l, Y.l, Width.l, Height.l, Min.l, Max.l, Pagelength.l, Flag.l=0)
  
EndDeclareModule

Module ScrollBar
  
  ;- PROCEDURE
  Procedure DrawArrow(X,Y, Size, Direction, Color, Thickness = 1) ; Рисуем стрелки
    Protected I
    
    ;ClipOutput(X-Thickness , Y-Thickness, Size*2+Thickness, Size*2+Thickness)
    
    If Direction = 1
      For i = 0 To Size 
        ; в верх
        LineXY((X+i)+Size,(Y+i-1)-(Thickness),(X+i)+Size,(Y+i-1)+(Thickness),Color) ; Левая линия
        LineXY(((X+(Size))-i),(Y+i-1)-(Thickness),((X+(Size))-i),(Y+i-1)+(Thickness),Color) ; правая линия
      Next
    ElseIf Direction = 3
      For i = 0 To Size
        ; в низ
        LineXY((X+i),(Y+i)-(Thickness),(X+i),(Y+i)+(Thickness),Color) ; Левая линия
        LineXY(((X+(Size*2))-i),(Y+i)-(Thickness),((X+(Size*2))-i),(Y+i)+(Thickness),Color) ; правая линия
      Next
    ElseIf Direction = 0 ; в лево
      For i = 0 To Size  
        ; в лево
        LineXY(((X+1)+i)-(Thickness),(((Y-2)+(Size))-i),((X+1)+i)+(Thickness),(((Y-2)+(Size))-i),Color) ; правая линия
        LineXY(((X+1)+i)-(Thickness),((Y-2)+i)+Size,((X+1)+i)+(Thickness),((Y-2)+i)+Size,Color)         ; Левая линия
      Next
    ElseIf Direction = 2 ; в право
      For i = 0 To Size
        ; в право
        LineXY(((X+2)+i)-(Thickness),((Y-2)+i),((X+2)+i)+(Thickness),((Y-2)+i),Color) ; Левая линия
        LineXY(((X+2)+i)-(Thickness),(((Y-2)+(Size*2))-i),((X+2)+i)+(Thickness),(((Y-2)+(Size*2))-i),Color) ; правая линия
      Next
    EndIf
    
    ;UnclipOutput()
  EndProcedure
  
  Procedure ScrollPos(*This.Gadget, ThumbPos.l)
    ProcedureReturn Scroll::Pos(*This\Scroll, ThumbPos.l)
  EndProcedure
  
  Procedure ThumbPos(*This.Gadget, ScrollPos.l)
    ProcedureReturn Scroll::ThumbPos(*This\Scroll, ScrollPos.l)
  EndProcedure
  
  Procedure ThumbLength(*This.Gadget)
    ProcedureReturn Scroll::ThumbLength(*This\Scroll)
  EndProcedure
  
  Procedure Re(*This.Gadget)
    If Not *This\Repaint : *This\Repaint = #True : EndIf
    Scroll::ReCoordinate(*This\Scroll, *This\X[2], *This\Y[2], *This\Width[2], *This\Height[2])
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
        If \Scroll\Vertical
          Box(\X[2]+1,\Y[2],\Width[2]-1,\Height[2],\Color[2])
          Line(\X[2],\Y[2],1,\Height[2],\Color[0])
        Else
          Box(\X[2],\Y[2]+1,\Width[2],\Height[2]-1,\Color[2])
          Line(\X[2],\Y[2],\Width[2],1,\Color[0])
        EndIf
        
        ;Case #PB_2DDrawing_Gradient
        DrawingMode(#PB_2DDrawing_Gradient)
        BackColor($F0F0F0)
        FrontColor($E5E5E5)
        
        If \Scroll\Vertical
          LinearGradient(\Scroll\X[0], \Scroll\Y[0], (\Scroll\X[0]+\Scroll\Width[0]), \Scroll\Y[0])
        Else
          LinearGradient(\Scroll\X[0], \Scroll\Y[0], \Scroll\X[0], (\Scroll\Y[0]+\Scroll\Height[0]))
        EndIf
        
        Box(\Scroll\X[1],\Scroll\Y[1],\Scroll\Width[1],\Scroll\Height[1])
        Box(\Scroll\X[0],\Scroll\Y[0],\Scroll\Width[0],\Scroll\Height[0])
        Box(\Scroll\X[2],\Scroll\Y[2],\Scroll\Width[2],\Scroll\Height[2])
        
        BackColor(#PB_Default)
        FrontColor(#PB_Default) ; bug
        
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(\Scroll\X[1],\Scroll\Y[1],\Scroll\Width[1],\Scroll\Height[1],$ACACAC)
        Box(\Scroll\X[0],\Scroll\Y[0],\Scroll\Width[0],\Scroll\Height[0],$ACACAC)
        Box(\Scroll\X[2],\Scroll\Y[2],\Scroll\Width[2],\Scroll\Height[2],$ACACAC)
        
        DrawingMode(#PB_2DDrawing_Default)
        DrawArrow(\Scroll\X[1]+(\Scroll\Width[1]-6)/2,\Scroll\Y[1]+(\Scroll\Height[1]-3)/2, 3, Bool(\Scroll\Vertical), \Scroll\Color[1])
        DrawArrow(\Scroll\X[2]+(\Scroll\Width[2]-6)/2,\Scroll\Y[2]+(\Scroll\Height[2]-3)/2, 3, Bool(\Scroll\Vertical)+2, \Scroll\Color[1])
        
        DrawingMode(#PB_2DDrawing_Default)
        If \Scroll\Vertical
          Line(\Scroll\X[0]+(\Scroll\Width[0]-10)/2,\Scroll\Y[0]+\Scroll\Height[0]/2-3,10,1,$ACACAC)
          Line(\Scroll\X[0]+(\Scroll\Width[0]-10)/2,\Scroll\Y[0]+\Scroll\Height[0]/2,10,1,$ACACAC)
          Line(\Scroll\X[0]+(\Scroll\Width[0]-10)/2,\Scroll\Y[0]+\Scroll\Height[0]/2+3,10,1,$ACACAC)
        Else
          Line(\Scroll\X[0]+\Scroll\Width[0]/2-3,\Scroll\Y[0]+(\Scroll\Height[0]-10)/2,1,10,$ACACAC)
          Line(\Scroll\X[0]+\Scroll\Width[0]/2,\Scroll\Y[0]+(\Scroll\Height[0]-10)/2,1,10,$ACACAC)
          Line(\Scroll\X[0]+\Scroll\Width[0]/2+3,\Scroll\Y[0]+(\Scroll\Height[0]-10)/2,1,10,$ACACAC)
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
  
  
  Procedure Set(*This.Gadget, Attribute.l, Value.l)
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
        Re(*This)
      EndIf
      
    EndWith
    
  EndProcedure
  
  Procedure SetPos(*This.Gadget, ScrollPos.l)
    With *This
      If ScrollPos < \Scroll\Min : ScrollPos = \Scroll\Min : EndIf
      If ScrollPos > ((\Scroll\Max)-\Scroll\PageLength)
        ScrollPos = ((\Scroll\Max)-\Scroll\PageLength)
      EndIf
      
      If \Scroll\Pos<>ScrollPos : \Scroll\Pos=ScrollPos
        \Scroll\ThumbPos = ThumbPos(*This, ScrollPos)
        
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
        Case #PB_EventType_Resize : ResizeGadget(\Canvas\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore) ; Bug (562)
          Re(*This)
          
        Case #PB_EventType_LeftButtonUp
          LastX = 0
          LastY = 0
          
        Case #PB_EventType_LeftButtonDown
          If (\Canvas\Mouse\x>\Scroll\x[1] And \Canvas\Mouse\x=<\Scroll\x[1]+\Scroll\Width[1] And 
              \Canvas\Mouse\y>\Scroll\y[1] And \Canvas\Mouse\y=<\Scroll\y[1]+\Scroll\Height[1])
            SetPos(*This, \Scroll\Pos - 1)
            
          ElseIf (\Canvas\Mouse\x>\Scroll\x[0] And \Canvas\Mouse\x=<\Scroll\x[0]+\Scroll\Width[0] And 
                  \Canvas\Mouse\y>\Scroll\y[0] And \Canvas\Mouse\y=<\Scroll\y[0]+\Scroll\Height[0])
            LastX = \Canvas\Mouse\X - \Scroll\ThumbPos
            LastY = \Canvas\Mouse\Y - \Scroll\ThumbPos
            
          ElseIf (\Canvas\Mouse\x>\Scroll\x[2] And \Canvas\Mouse\x=<\Scroll\x[2]+\Scroll\Width[2] And 
                  \Canvas\Mouse\y>\Scroll\y[2] And \Canvas\Mouse\y=<\Scroll\y[2]+\Scroll\Height[2])
            SetPos(*This, \Scroll\Pos + 1)
            
          EndIf
          
        Case #PB_EventType_MouseMove
          If \Canvas\Mouse\Buttons And Bool(LastX|LastY)
            If \Scroll\Vertical
              SetPos(*This, ScrollPos(*This, (\Canvas\Mouse\Y-LastY)))
            Else
              SetPos(*This, ScrollPos(*This, (\Canvas\Mouse\X-LastX)))
            EndIf
          EndIf
          
      EndSelect
    EndWith
    
    ; Draw(*This)
  EndProcedure
  
  ;- PUBLIC
  Procedure SetAttribute(Gadget.l, Attribute.l, Value.l)
    Protected *This.Gadget = GetGadgetData(Gadget)
    
    With *This
      Set(*This, Attribute, Value)
    EndWith
  EndProcedure
  
  Procedure GetAttribute(Gadget.l, Attribute.l)
    Protected Result, *This.Gadget = GetGadgetData(Gadget)
    
    With *This
      Select Attribute
        Case #PB_ScrollBar_Minimum    : Result = \Scroll\Min
        Case #PB_ScrollBar_Maximum    : Result = \Scroll\Max
        Case #PB_ScrollBar_PageLength : Result = \Scroll\PageLength
      EndSelect
    EndWith
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure SetState(Gadget.l, State.l)
    Protected *This.Gadget = GetGadgetData(Gadget)
    
    With *This
      SetPos(*This, State)
    EndWith
  EndProcedure
  
  Procedure GetState(Gadget.l)
    Protected *This.Gadget = GetGadgetData(Gadget)
    
    With *This
      ProcedureReturn \Scroll\Pos
    EndWith
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
        
        \Color[0] = $FFFFFF
        \Color[1] = $C0C0C0
        \Color[2] = $F0F0F0
        
        \Scroll\ButtonLength = 17
        \Scroll\Color[0] = $5B5B5B
        \Scroll\Color[1] = $5B5B5B
        \Scroll\Color[2] = $5B5B5B
        \Scroll\Vertical = Bool(Flag&#PB_ScrollBar_Vertical)
        
        Set(*This, #PB_ScrollBar_Minimum, Min)
        Set(*This, #PB_ScrollBar_Maximum, Max)
        Set(*This, #PB_ScrollBar_PageLength, PageLength)
        
        Re(*This)
        Draw(*This)
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


Procedure GadgetCallBack()
  ScrollBar::SetState(10, GetGadgetState(EventGadget()))
EndProcedure

Procedure h_GadgetCallBack()
  ScrollBar::SetState(12, GetGadgetState(EventGadget()))
EndProcedure

Procedure h_CallBack()
  SetGadgetState(2, ScrollBar::GetState(EventGadget()))
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
  ScrollBar::Gadget(g, 600, 10, 20, 210,0,max, 210, #PB_ScrollBar_Vertical)                                         
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
  ScrollBar::Gadget  (12,  300+10, 220+42, 250,  20, 30, 100, 30)
  ScrollBar::SetState   (12,  50)   ; set 1st scrollbar (ID = 0) to 50 of 100
  TextGadget       (-1,  300+10,220+115, 250,  20, "ScrollBar Vertical  (start=100, page=50/300)",#PB_Text_Right)
  ScrollBar::Gadget  (13, 300+270, 220+10,  25, 120 ,0, 300, 50, #PB_ScrollBar_Vertical)
  ScrollBar::SetState   (13, 100)   ; set 2nd scrollbar (ID = 1) to 100 of 300
                                    ;     Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
                                    ;   EndIf
  
  BindGadgetEvent(2,@h_GadgetCallBack())
  BindGadgetEvent(12,@h_CallBack(), #PB_EventType_Change)
  Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 597
; FirstLine = 569
; Folding = ------
; EnableXP