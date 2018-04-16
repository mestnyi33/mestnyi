DeclareModule Scroll
  EnableExplicit
  
  Structure Struct
    y.l[4]
    x.l[4]
    Height.l[4]
    Width.l[4]
    
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
    BackColor.l[3]
    LineColor.l[3]
    FrameColor.l[3]
  EndStructure
  
  Declare Draw(*This.Struct)
  Declare.l ThumbLength(*This.Struct)
  Declare.l Pos(*This.Struct, ThumbPos.l)
  Declare.l ThumbPos(*This.Struct, ScrollPos.l)
  Declare.b SetState(*This.Struct, ScrollPos.l)
  Declare.b SetAttribute(*This.Struct, Attribute.l, Value.l)
  Declare.b CallBack(*This.Struct, EventType.l, MouseX.l, MouseY.l)
  Declare.b ReCoordinate(*This.Struct, iX.l,iY.l,iWidth.l,iHeight.l)
EndDeclareModule

Module Scroll
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
  
  Procedure Draw(*This.Struct)
    With *This
        DrawingMode(#PB_2DDrawing_Default)
        If \Vertical
          Box(\X[0],\Y[0],\Width[0],\Height[0],\Color[0])
          Line(\X[0]-1,\Y[1],1,\Height[0]+\Height[1]+\Height[2],\LineColor[0])
        Else
          Box(\X[0],\Y[0],\Width[0],\Height[0],\Color[0])
          Line(\X[1],\Y[0]-1,\Width[0]+\Width[1]+\Width[2],1,\LineColor[0])
        EndIf
        
        ;Case #PB_2DDrawing_Gradient
        DrawingMode(#PB_2DDrawing_Gradient)
        BackColor(\Color[0])
        FrontColor(\BackColor[0]);$E5E5E5)
        
        If \Vertical
          LinearGradient(\X[3], \Y[3], (\X[3]+\Width[3]), \Y[3])
        Else
          LinearGradient(\X[3], \Y[3], \X[3], (\Y[3]+\Height[3]))
        EndIf
        
        Box(\X[1],\Y[1],\Width[1],\Height[1])
        Box(\X[3],\Y[3],\Width[3],\Height[3])
        Box(\X[2],\Y[2],\Width[2],\Height[2])
        
        BackColor(#PB_Default)
        FrontColor(#PB_Default) ; bug
        
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(\X[1],\Y[1],\Width[1],\Height[1],\FrameColor[0])
        Box(\X[3],\Y[3],\Width[3],\Height[3],\FrameColor[0])
        Box(\X[2],\Y[2],\Width[2],\Height[2],\FrameColor[0])
        
        DrawingMode(#PB_2DDrawing_Default)
        DrawArrow(\X[1]+(\Width[1]-6)/2,\Y[1]+(\Height[1]-3)/2, 3, Bool(\Vertical), \FrameColor[2])
        DrawArrow(\X[2]+(\Width[2]-6)/2,\Y[2]+(\Height[2]-3)/2, 3, Bool(\Vertical)+2, \FrameColor[2])
        
        DrawingMode(#PB_2DDrawing_Default)
        If \Vertical
          Line(\X[3]+(\Width[3]-10)/2,\Y[3]+\Height[3]/2-3,10,1,\FrameColor[0])
          Line(\X[3]+(\Width[3]-10)/2,\Y[3]+\Height[3]/2,10,1,\FrameColor[0])
          Line(\X[3]+(\Width[3]-10)/2,\Y[3]+\Height[3]/2+3,10,1,\FrameColor[0])
        Else
          Line(\X[3]+\Width[3]/2-3,\Y[3]+(\Height[3]-10)/2,1,10,\FrameColor[0])
          Line(\X[3]+\Width[3]/2,\Y[3]+(\Height[3]-10)/2,1,10,\FrameColor[0])
          Line(\X[3]+\Width[3]/2+3,\Y[3]+(\Height[3]-10)/2,1,10,\FrameColor[0])
        EndIf
    EndWith  
  EndProcedure
  
  Procedure.l Pos(*This.Struct, ThumbPos.l)
    Protected ScrollPos.l
    
    With *This
      ScrollPos = \Min + Round((ThumbPos - \AreaPos) / (\AreaLength / (\Max-\Min)), #PB_Round_Nearest)
      If (\Vertical And \Type = #PB_GadgetType_TrackBar) : ScrollPos = ((\Max-\Min)-ScrollPos) : EndIf
    EndWith
    
    ProcedureReturn ScrollPos
  EndProcedure
  
  Procedure.l ThumbPos(*This.Struct, ScrollPos.l)
    Protected ThumbPos.l
    
    With *This
      ThumbPos = (\AreaPos + Round((ScrollPos-\Min) * (\AreaLength / (\Max-\Min)), #PB_Round_Nearest))
    EndWith
    
    ProcedureReturn ThumbPos
  EndProcedure
  
  Procedure.l ThumbLength(*This.Struct)
    Protected ThumbLength.l
    
    With *This
      ThumbLength = Round(\AreaLength - (\AreaLength / (\Max-\Min))*((\Max-\Min) - \PageLength), #PB_Round_Nearest)
    EndWith
    
    ProcedureReturn ThumbLength
  EndProcedure
  
  Procedure.b ReCoordinate(*This.Struct, iX.l,iY.l,iWidth.l,iHeight.l)
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
        ; скролл баре
        \X[0] = iX + 1
        \Y[0] = iY + \ButtonLength
        \Width[0] = iWidth - 1
        \Height[0] = iHeight - \ButtonLength*2
        
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
        \X[3] = iX + 1
        \Width[3] = iWidth - 1
        \Y[3] = \ThumbPos
        \Height[3] = \ThumbLength
        
      Else
        ; скролл баре
        \X[0] = iX + \ButtonLength
        \Y[0] = iY + 1
        \Width[0] = iWidth - \ButtonLength*2
        \Height[0] = iHeight - 1
        
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
        \Y[3] = iY + 1
        \Height[3] = iHeight - 1
        \X[3] = \ThumbPos
        \Width[3] = \ThumbLength
        
      EndIf
      
      
    EndWith
  EndProcedure
  
  Procedure.b SetState(*This.Struct, ScrollPos.l)
    Protected Result.b
    
    With *This
      If ScrollPos < \Min : ScrollPos = \Min : EndIf
      If ScrollPos > (\Max-\PageLength)
        ScrollPos = (\Max-\PageLength)
      EndIf
      
      If \Pos<>ScrollPos : \Pos=ScrollPos
        \ThumbPos = ThumbPos(*This, ScrollPos)
        
        If \Vertical
          \Y[3] = \ThumbPos
          \Height[3] = \ThumbLength
        Else
          \X[3] = \ThumbPos
          \Width[3] = \ThumbLength
        EndIf
        
        Result = #True
      EndIf
    EndWith
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.b SetAttribute(*This.Struct, Attribute.l, Value.l)
    Protected Change.b
    
    With *This
      Select Attribute
        Case #PB_ScrollBar_Minimum
          If \Min <> Value
            \Min = Value
            \Pos = Value
            Change = #True
          EndIf
          
        Case #PB_ScrollBar_Maximum
          If \Max <> Value
            If \Min > Value
              \Max = \Min + 1
            Else
              \Max = Value + 1
            EndIf
            Change = #True
          EndIf
          
        Case #PB_ScrollBar_PageLength
          If \PageLength <> Value
            If Value > (\Max-\Min)
              \PageLength = (\Max-\Min)
            Else
              \PageLength = Value
            EndIf
            \Pos = Abs(\Pos) ; ?
            Change = #True
          EndIf
          
      EndSelect
      
;       If Change
;         ReCoordinate(*This)
;       EndIf
      
    EndWith
    
    ProcedureReturn Change
  EndProcedure
  
  Procedure.b CallBack(*This.Struct, EventType.l, MouseX.l, MouseY.l)
    Protected Result
    Static LastX, LastY
    
    With *This
      Select EventType
        Case #PB_EventType_LeftButtonUp
          LastX = 0
          LastY = 0
          
        Case #PB_EventType_LeftButtonDown
          If (Mousex>\x[1] And Mousex=<\x[1]+\Width[1] And 
              Mousey>\y[1] And Mousey=<\y[1]+\Height[1])
             Result = SetState(*This, \Pos - 1)
            
          ElseIf (Mousex>\x[0] And Mousex=<\x[0]+\Width[0] And 
                  Mousey>\y[0] And Mousey=<\y[0]+\Height[0])
            LastX = MouseX - \ThumbPos
            LastY = MouseY - \ThumbPos
            
          ElseIf (Mousex>\x[2] And Mousex=<\x[2]+\Width[2] And 
                  Mousey>\y[2] And Mousey=<\y[2]+\Height[2])
             Result = SetState(*This, \Pos + 1)
            
          EndIf
          
        Case #PB_EventType_MouseMove
          If Bool(LastX|LastY)
            If \Vertical
              Result = SetState(*This, Pos(*This, (MouseY-LastY)))
            Else
              Result = SetState(*This, Pos(*This, (MouseX-LastX)))
            EndIf
          EndIf
          
      EndSelect
    EndWith
    
    ProcedureReturn Result
  EndProcedure
EndModule

;-
DeclareModule ListView
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
    Color.l[4]
    
    Image.Coordinate
    
    fSize.l
    bSize.l
    
    ;Scroll.Scroll::Struct
    vScroll.Scroll::Struct
    hScroll.Scroll::Struct
    
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
  
  Declare AddColumn(Gadget,Item,Text.s,Width.l,Image.l=-1)
  Declare AddItem(Gadget,Item,Text.s,Image.l,Flag.l=0)
EndDeclareModule

Module ListView
  
  ;- PROCEDURE
  Procedure ScrollPos(*This.Gadget, ThumbPos.l)
    ProcedureReturn Scroll::Pos(*This\vScroll, ThumbPos.l)
  EndProcedure
  
  Procedure ThumbPos(*This.Gadget, ScrollPos.l)
    ProcedureReturn Scroll::ThumbPos(*This\vScroll, ScrollPos.l)
  EndProcedure
  
  Procedure ThumbLength(*This.Gadget)
    ProcedureReturn Scroll::ThumbLength(*This\vScroll)
  EndProcedure
  
  
  Procedure Re(*This.Gadget)
  With *This\Columns()
    If Not *This\Repaint
      *This\Repaint = #True
    EndIf
    *This\vScroll\Width = 0
    
    ForEach *This\Columns()
      \X = *This\vScroll\Width
      \vScroll\Height = \Height
      
      ForEach \Items()
        \Items()\Y = \vScroll\Height-*This\vScroll\Pos
        
        \vScroll\Height+\Items()\height
      Next
      
      *This\vScroll\Width+\Width
      If *This\vScroll\Height<\vScroll\Height
        *This\vScroll\Height=\vScroll\Height
      EndIf
    Next
    
    
    *This\vScroll\Vertical = 1
    *This\vScroll\ButtonLength = 17
    Scroll::SetAttribute(*This\vScroll, #PB_ScrollBar_Maximum, *This\vScroll\Height)
    Scroll::SetAttribute(*This\vScroll, #PB_ScrollBar_PageLength, *This\Height)
    If *This\vScroll\Vertical
        Scroll::ReCoordinate(*This\vScroll, *This\Width[2]-17, *This\Y[2], 17, *This\Height[2])
      Else
        Scroll::ReCoordinate(*This\vScroll, *This\X[2], *This\Y[2], *This\Width[2], *This\Height[2])
      EndIf
      
;     Scroll::ReCoordinate(*This\vScroll, *This\Width-19,*This\y, 19, *This\Height)
  EndWith  
EndProcedure

Procedure Draw(*This.Gadget)
  Protected X=5,Y=10, height = 16, width = 16, w=20, level,iY,yy, Adress=-1
  
  With *This\Columns()
    If *This\Repaint And StartDrawing(CanvasOutput(*This\Canvas\Gadget))
      DrawingFont(GetGadgetFont(#PB_Default))
      Box(0,0,OutputWidth(), OutputHeight())
      
      If *This\fSize
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(*This\X[1],*This\Y[1],*This\Width[1],*This\Height[1],*This\Color[0])
        EndIf
      
      ForEach *This\Columns()
        ForEach \Items()
          If *This\Height > \Items()\Y
            If \Items()\ImageID : DrawImage(\Items()\ImageID, \x,\Items()\y+(\Items()\height-\Items()\Image\Height)/2) : EndIf
            DrawText(\x+5+\Items()\Image\Width, \Items()\y+(\Items()\height-TextHeight(\Items()\Text))/2, \Items()\Text.s, $000000, $FFFFFF)
          EndIf
        Next
        
        If *This\Width > \X
          Box(\x+\Width, 0,1,*This\Height,0)
          DrawText(\x+5, 5, \Text.s, $000000, $FFFFFF)
        EndIf
      Next
      
        
        Scroll::Draw(*This\vScroll)
        
        *This\Repaint = #False
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
    Protected Result, *This.Gadget = GetGadgetData(EventGadget())
    
    With *This
      \Canvas\Window = EventWindow()
      \Canvas\Mouse\X = GetGadgetAttribute(\Canvas\Gadget, #PB_Canvas_MouseX)
      \Canvas\Mouse\Y = GetGadgetAttribute(\Canvas\Gadget, #PB_Canvas_MouseY)
      \Canvas\Mouse\Buttons = GetGadgetAttribute(\Canvas\Gadget, #PB_Canvas_Buttons)
      
      Select EventType()
        Case #PB_EventType_Resize : ResizeGadget(\Canvas\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore) ; Bug (562)
          Re(*This)
        
      EndSelect
      
      *This\Repaint = Scroll::CallBack(*This\vScroll, EventType(), \Canvas\Mouse\X, \Canvas\Mouse\Y)
      If *This\Repaint 
        ReDraw(*This)
        PostEvent(#PB_Event_Gadget, EventWindow(), \Canvas\Gadget, #PB_EventType_Change)
      EndIf
    EndWith
    
    ; Draw(*This)
  EndProcedure
  
  ;- PUBLIC
  Procedure SetAttribute(Gadget.l, Attribute.l, Value.l)
    Protected *This.Gadget = GetGadgetData(Gadget)
    
    With *This
      If Scroll::SetAttribute(*This\vScroll, Attribute, Value)
        ReDraw(*This)
      EndIf
    EndWith
  EndProcedure
  
  Procedure GetAttribute(Gadget.l, Attribute.l)
    Protected Result, *This.Gadget = GetGadgetData(Gadget)
    
    With *This
      Select Attribute
        Case #PB_ScrollBar_Minimum    : Result = \vScroll\Min
        Case #PB_ScrollBar_Maximum    : Result = \vScroll\Max
        Case #PB_ScrollBar_PageLength : Result = \vScroll\PageLength
      EndSelect
    EndWith
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure SetState(Gadget.l, State.l)
    Protected *This.Gadget = GetGadgetData(Gadget)
    
    With *This
      If Scroll::SetState(*This\vScroll, State)
        ReDraw(*This)
        PostEvent(#PB_Event_Gadget, \Canvas\Window, \Canvas\Gadget, #PB_EventType_Change)
      EndIf
    EndWith
  EndProcedure
  
  Procedure GetState(Gadget.l)
    Protected *This.Gadget = GetGadgetData(Gadget)
    
    With *This
      ProcedureReturn \vScroll\Pos
    EndWith
  EndProcedure
  
  Procedure AddItem(Gadget,Item,Text.s,Image.l,Flag.l=0)
  Protected *This.Gadget = GetGadgetData(Gadget)
  
  With *This\Columns()
    ForEach *This\Columns()
      AddElement(\Items()) 
      
      \Items()\Height = 17
      
      If Text
        ;\Items()\Text\Change = #True
        \Items()\Text.s = StringField(Text, ListIndex(*This\Columns()) + 1, #LF$)
      EndIf
      
      If ListIndex(*This\Columns())=0 And IsImage(Image)
        \Items()\Image\Width = ImageWidth(Image)-5
        \Items()\ImageID = ImageID(Image)
        \Items()\Image\Width = ImageWidth(Image)
        \Items()\Image\Height = ImageHeight(Image)
      EndIf
    Next
    
    Re(*This)
    
    If *This\Height > *This\vScroll\Height
      Draw(*This)
    EndIf
    
  EndWith
EndProcedure

Procedure AddColumn(Gadget,Item,Text.s,Width.l,Image.l=-1)
  Protected *This.Gadget = GetGadgetData(Gadget)
  Static Adress
  
  With *This\Columns()
    
    LastElement(*This\Columns())
    AddElement(*This\Columns()) 
    
    \Text.s = Text.s
    \Width = Width
    \Height = 30
    
    If *This\Width > *This\vScroll\Width
      Draw(*This)
    EndIf
  EndWith
EndProcedure

Procedure Gadget(Gadget, X.l, Y.l, Width.l, Height.l, Min.l, Max.l, Pagelength.l, Flag.l=0)
    Protected *This.Gadget=AllocateStructure(Gadget)
    Protected g = CanvasGadget(Gadget, X, Y, Width, Height) : If Gadget=-1 : Gadget=g : EndIf
    
    If *This
      With *This
        \Canvas\Gadget = Gadget
        \Width[0] = Width
        \Height[0] = Height
        
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
        
        \Color[3] = $FFFFFF
        \Color[1] = $C0C0C0
        \Color[2] = $F0F0F0
        
        \vScroll\ButtonLength = 17
        
        \vScroll\Color[0] = $F0F0F0
        \vScroll\BackColor[0] = $E5E5E5
        
        \vScroll\LineColor[0] = $7E7E7E
        \vScroll\FrameColor[0] = $ACACAC
        
        ;\vScroll\BackColor[0] = $5B5B5B
        ;\vScroll\BackColor[2] = $5B5B5B
        \vScroll\Vertical = Bool(Flag&#PB_ScrollBar_Vertical)
        
        
        Re(*This)
        Draw(*This)
        SetGadgetData(Gadget, *This)
        SetAttribute(Gadget, #PB_ScrollBar_Minimum, Min)
        SetAttribute(Gadget, #PB_ScrollBar_Maximum, Max)
        SetAttribute(Gadget, #PB_ScrollBar_PageLength, PageLength)
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
  
  g = 10
  ListView::Gadget(g, 10, 230, 560, 210,0,max, 210, #PB_ScrollBar_Vertical)                                         
  ListView::AddColumn(g, 0,"Column_"+Str(1),100)
  For i=1 To 2
    ListView::AddColumn(g, i,"Column_"+Str(i+1),100)
  Next
  ; 1_example
  For i=0 To 15
    ListView::AddItem(g, i, Str(i)+"_Column_1"+#LF$+Str(i)+"_Column_2"+#LF$+Str(i)+"_Column_3"+#LF$+Str(i)+"_Column_4", 0)                                           
  Next
  
  Debug "time "+Str(ElapsedMilliseconds()-t)
  
  Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 356
; FirstLine = 355
; Folding = ------
; EnableXP