DeclareModule Scroll
  EnableExplicit
  
  Structure Struct
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
  
  Declare.l Pos(*This.Struct, ThumbPos.l)
  Declare.l ThumbLength(*This.Struct)
  Declare.l ThumbPos(*This.Struct, ScrollPos.l)
  Declare.b ReCoordinate(*This.Struct, iX.l,iY.l,iWidth.l,iHeight.l)
  
  Declare Set(*This.Struct, Attribute.l, Value.l)
  Declare Draw(*This.Struct)
  Declare CallBack(*This.Struct, EventType.l, MouseX.l,MouseY.l)
EndDeclareModule

Module Scroll
  Procedure Arrows(X,Y, Size, Direction, Color, Thickness = 1) ; Рисуем стрелки
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
      ;  Debug "pos "+\Pos
      ;       
      ;           If (ThumbPos + \ThumbLength) > (\AreaLength + \ButtonLength)
      ;             ThumbPos = ((\AreaLength + \ButtonLength) - \ThumbLength)
      ;           EndIf
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
  
  Procedure Draw(*This.Struct)
    With *This
;       If \Repaint And StartDrawing(CanvasOutput(\Canvas\Gadget))
;         DrawingFont(GetGadgetFont(#PB_Default))
        
;         If \fSize
;           DrawingMode(#PB_2DDrawing_Outlined)
;           Box(\X[1],\Y[1],\Width[1],\Height[1],\Color[1])
;         EndIf
        
;         DrawingMode(#PB_2DDrawing_Default)
;         If \Scroll\Vertical
;           Box(\X[2]+1,\Y[2],\Width[2]-1,\Height[2],\Color[2])
;           Line(\X[2],\Y[2],1,\Height[2],\Color[0])
;         Else
;           Box(\X[2],\Y[2]+1,\Width[2],\Height[2]-1,\Color[2])
;           Line(\X[2],\Y[2],\Width[2],1,\Color[0])
;         EndIf
        
        ;Case #PB_2DDrawing_Gradient
        DrawingMode(#PB_2DDrawing_Gradient)
        BackColor($F0F0F0)
        FrontColor($E5E5E5)
        
        If \Vertical
          LinearGradient(\X[0], \Y[0], (\X[0]+\Width[0]), \Y[0])
        Else
          LinearGradient(\X[0], \Y[0], \X[0], (\Y[0]+\Height[0]))
        EndIf
        
        Box(\X[1],\Y[1],\Width[1],\Height[1])
        Box(\X[0],\Y[0],\Width[0],\Height[0])
        Box(\X[2],\Y[2],\Width[2],\Height[2])
        
        BackColor(#PB_Default)
        FrontColor(#PB_Default) ; bug
        
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(\X[1],\Y[1],\Width[1],\Height[1],$ACACAC)
        Box(\X[0],\Y[0],\Width[0],\Height[0],$ACACAC)
        Box(\X[2],\Y[2],\Width[2],\Height[2],$ACACAC)
        
        DrawingMode(#PB_2DDrawing_Default)
        Arrows(\X[1]+(\Width[1]-6)/2,\Y[1]+(\Height[1]-3)/2, 3, Bool(\Vertical), \Color[1])
        Arrows(\X[2]+(\Width[2]-6)/2,\Y[2]+(\Height[2]-3)/2, 3, Bool(\Vertical)+2, \Color[1])
        
        DrawingMode(#PB_2DDrawing_Default)
        If \Vertical
          Line(\X[0]+(\Width[0]-10)/2,\Y[0]+\Height[0]/2-3,10,1,$ACACAC)
          Line(\X[0]+(\Width[0]-10)/2,\Y[0]+\Height[0]/2,10,1,$ACACAC)
          Line(\X[0]+(\Width[0]-10)/2,\Y[0]+\Height[0]/2+3,10,1,$ACACAC)
        Else
          Line(\X[0]+\Width[0]/2-3,\Y[0]+(\Height[0]-10)/2,1,10,$ACACAC)
          Line(\X[0]+\Width[0]/2,\Y[0]+(\Height[0]-10)/2,1,10,$ACACAC)
          Line(\X[0]+\Width[0]/2+3,\Y[0]+(\Height[0]-10)/2,1,10,$ACACAC)
        EndIf
        
;         \Repaint = #False
;         StopDrawing()
;       EndIf
    EndWith  
  EndProcedure
  
  Procedure Set(*This.Struct, Attribute.l, Value.l)
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
    
  EndProcedure
  
  Procedure ReDraw(*This.Struct)
    ;     ReCoordinate(*This)
    With *This
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
        \Y[0] = \ThumbPos
        \Height[0] = \ThumbLength
        
      Else
        \X[0] = \ThumbPos
        \Width[0] = \ThumbLength
        
      EndIf
      EndWith
    ;Draw(*This)
  EndProcedure
  
  Procedure SetPos(*This.Struct, ScrollPos.l)
    With *This
      If ScrollPos < \Min : ScrollPos = \Min : EndIf
      If ScrollPos > ((\Max)-\PageLength)
        ScrollPos = ((\Max)-\PageLength)
      EndIf
      
      If \Pos<>ScrollPos : \Pos=ScrollPos
        \ThumbPos = ThumbPos(*This, ScrollPos)
        
         ReDraw(*This)
;         PostEvent(#PB_Event_Gadget, EventWindow(), \Canvas\Gadget, #PB_EventType_Change)
      EndIf
    EndWith
  EndProcedure
  
  Procedure CallBack(*This.Struct, EventType.l, MouseX.l,MouseY.l)
    Static LastX, LastY
    
    With *This
;       \Mouse\X = GetGadgetAttribute(EventGadget(), #PB_Canvas_MouseX)
;       \Mouse\Y = GetGadgetAttribute(EventGadget(), #PB_Canvas_MouseY)
;       \Mouse\Buttons = GetGadgetAttribute(EventGadget(), #PB_Canvas_Buttons)
      
      Select EventType
;         Case #PB_EventType_Resize : ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore) ; Bug (562)
;           Re(*This)
          
        Case #PB_EventType_LeftButtonUp
          LastX = 0
          LastY = 0
          
        Case #PB_EventType_LeftButtonDown
          If (Mousex>\x[1] And Mousex=<\x[1]+\Width[1] And 
              Mousey>\y[1] And Mousey=<\y[1]+\Height[1])
            SetPos(*This, \Pos - 1)
            
          ElseIf (Mousex>\x[0] And Mousex=<\x[0]+\Width[0] And 
                  Mousey>\y[0] And Mousey=<\y[0]+\Height[0])
            LastX = MouseX - \ThumbPos
            LastY = MouseY - \ThumbPos
            
          ElseIf (Mousex>\x[2] And Mousex=<\x[2]+\Width[2] And 
                  Mousey>\y[2] And Mousey=<\y[2]+\Height[2])
            SetPos(*This, \Pos + 1)
            
          EndIf
          
        Case #PB_EventType_MouseMove
          If Bool(LastX|LastY)
            If \Vertical
              SetPos(*This, Pos(*This, (MouseY-LastY)))
            Else
              SetPos(*This, Pos(*This, (MouseX-LastX)))
            EndIf
          EndIf
          
      EndSelect
    EndWith
    
    ; Draw(*This)
  EndProcedure
  
  
EndModule



EnableExplicit

Structure Coordinate
  y.l
  x.l
  Height.l
  Width.l
EndStructure

Structure Tree Extends Coordinate
  Canvas.l
  Text.s
  ImageID.l
  Image.Coordinate
  
  Scroll.Scroll::Struct
  IsVertical.l
  bSize.l
  Type.l
  InnerCoordinate.Coordinate
  
  Repaint.l
  
  List Items.Tree()
  List Columns.Tree()
EndStructure









Procedure Re(*This.Tree)
  With *This\Columns()
    If Not *This\Repaint
      *This\Repaint = #True
    EndIf
    *This\Scroll\Width = 0
    
    ForEach *This\Columns()
      \X = *This\Scroll\Width
      \Scroll\Height = \Height
      
      ForEach \Items()
        \Items()\Y = \Scroll\Height
        
        \Scroll\Height+\Items()\height
      Next
      
      *This\Scroll\Width+\Width
      If *This\Scroll\Height<\Scroll\Height
        *This\Scroll\Height=\Scroll\Height
      EndIf
    Next
    
    *This\Scroll\Vertical = 1
    *This\Scroll\ButtonLength = 17
    Scroll::Set(*This\Scroll, #PB_ScrollBar_Maximum, *This\Scroll\Height)
    Scroll::Set(*This\Scroll, #PB_ScrollBar_PageLength, *This\Height)
    Scroll::ReCoordinate(*This\Scroll, *This\Width-19,*This\y, 19, *This\Height)
  EndWith  
EndProcedure

Procedure Draw(*This.Tree)
  Protected X=5,Y=10, height = 16, width = 16, w=20, level,iY,yy, Adress=-1
  
  With *This\Columns()
    If *This\Repaint And StartDrawing(CanvasOutput(*This\Canvas))
      DrawingFont(GetGadgetFont(#PB_Default))
      Box(0,0,OutputWidth(), OutputHeight())
      
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
      
      Scroll::Draw(*This\Scroll)
      *This\Repaint = #False
      StopDrawing()
    EndIf
  EndWith  
EndProcedure

Procedure CallBack()
  Protected *This.Tree = GetGadgetData(EventGadget())
  
  With *This\Columns()
    
  EndWith
  
  Scroll::CallBack(*This\Scroll, EventType(), GetGadgetAttribute(*This\Canvas, #PB_Canvas_MouseX),GetGadgetAttribute(*This\Canvas, #PB_Canvas_MouseY))
  ; Draw(*This)
EndProcedure

Procedure AddItem(Gadget,Item,Text.s,Image.l,Flag.l=0)
  Protected *This.Tree = GetGadgetData(Gadget)
  
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
    
    If *This\Height > *This\Scroll\Height
      Draw(*This)
    EndIf
    
  EndWith
EndProcedure

Procedure AddColumn(Gadget,Item,Text.s,Width.l,Image.l=-1)
  Protected *This.Tree = GetGadgetData(Gadget)
  Static Adress
  
  With *This\Columns()
    
    LastElement(*This\Columns())
    AddElement(*This\Columns()) 
    
    \Text.s = Text.s
    \Width = Width
    \Height = 30
    
    If *This\Width > *This\Scroll\Width
      Draw(*This)
    EndIf
  EndWith
EndProcedure

Procedure Gadget(Gadget, x, y, w, h, ColumnTitle.s, ColumnWidth.l)
  Protected *This.Tree=AllocateStructure(Tree)
  Protected g = CanvasGadget(Gadget, x, y, w, h) : If Gadget=-1 : Gadget=g : EndIf
  
  If *This
    With *This
      \Canvas = Gadget
      \Width = w
      \Height = h
    EndWith
    
    SetGadgetData(Gadget, *This)
    AddColumn(Gadget,0,ColumnTitle,ColumnWidth)
  EndIf
  
  BindGadgetEvent(Gadget, @CallBack())
  ProcedureReturn Gadget
EndProcedure

If LoadImage(0, #PB_Compiler_Home+"Examples\Sources\Data\File.bmp")     ; Измените путь/имя файла на собственное изображение 32x32 пикселя
EndIf
Define a,i

If OpenWindow(0, 0, 0, 630, 450, "TreeGadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  Define t=ElapsedMilliseconds()
  
  Define g = 1
  ListIconGadget(g, 10, 10, 610, 210,"Column_1",100)                                         
  For i=1 To 2
    AddGadgetColumn(g, i,"Column_"+Str(i+1),100)
  Next
  ; 1_example
  For i=0 To 25
    AddGadgetItem(g, i, Str(i)+"_Column_1"+#LF$+Str(i)+"_Column_2"+#LF$+Str(i)+"_Column_3"+#LF$+Str(i)+"_Column_4", ImageID(0))                                           
  Next
  
  Debug "time "+Str(ElapsedMilliseconds()-t)
  t=ElapsedMilliseconds()
  
  g = 10
  Gadget(g, 10, 230, 610, 210,"Column_1",100)                                         
  For i=1 To 2
    AddColumn(g, i,"Column_"+Str(i+1),100)
  Next
  ; 1_example
  For i=0 To 25
    AddItem(g, i, Str(i)+"_Column_1"+#LF$+Str(i)+"_Column_2"+#LF$+Str(i)+"_Column_3"+#LF$+Str(i)+"_Column_4", 0)                                           
  Next
  
  Debug "time "+Str(ElapsedMilliseconds()-t)
  
  Define *This.Tree = GetGadgetData(g)
  
  With *This\Columns()
    Debug "Scroll_Height "+*This\Scroll\Height
  EndWith
  
  
  Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 492
; FirstLine = 407
; Folding = 2-65
; EnableXP