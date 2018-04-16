DeclareModule Scroll
  EnableExplicit
  
  #PB_ScrollBar_Step = 4
  
  Structure Color
    ForeColor.l[3]
    BackColor.l[3]
    LineColor.l[3]
    FrameColor.l[3]
    ArrowColor.l[3]
  EndStructure
  
  Structure Struct Extends Color
    y.l[4]
    x.l[4]
    Height.l[4]
    Width.l[4]
    
    Type.l
    Vertical.l
    ButtonLength.l
    Buttons.Color[4]
    
    Hide.b[2]
    Disable.b[2]
    DrawingMode.l
    
    Max.l
    Min.l
    Steps.l
    
    Pos.l
    PageLength.l
    
    AreaPos.l
    AreaLength.l
    
    ThumbPos.l
    ThumbLength.l
  EndStructure
  
  Declare Draw(*This.Struct)
  Declare.b SetState(*This.Struct, ScrollPos.l)
  Declare.b SetAttribute(*This.Struct, Attribute.l, Value.l)
  Declare.b SetColor(*This.Struct, ColorType.l, Color.l, Item.l=0)
  Declare.b CallBack(*This.Struct, EventType.l, MouseX.l, MouseY.l)
  Declare.b Gadget(*This.Struct, iX.l,iY.l,iWidth.l,iHeight.l, Min.l, Max.l, Pagelength.l, Flag.l=0, Steps.l=1)
EndDeclareModule

Module Scroll
  Macro BoxGradient(Type, X,Y,Width,Height,Color1,Color2)
    BackColor(Color1)
    FrontColor(Color2)
    If Type
      LinearGradient(X, Y, (X+Width), Y)
    Else
      LinearGradient(X, Y, X, (Y+Height))
    EndIf
    Box(X,Y,Width,Height)
  EndMacro
  
  Macro ResetColor(This)
    This\Buttons[0]\ForeColor = This\ForeColor
    This\Buttons[0]\BackColor = This\BackColor
    This\Buttons[0]\LineColor = This\LineColor
    This\Buttons[0]\FrameColor = This\FrameColor
    This\Buttons[0]\ArrowColor = This\ArrowColor
    
    This\Buttons[1]\ForeColor = This\ForeColor
    This\Buttons[1]\BackColor = This\BackColor
    This\Buttons[1]\LineColor = This\LineColor
    This\Buttons[1]\FrameColor = This\FrameColor
    This\Buttons[1]\ArrowColor = This\ArrowColor
    
    This\Buttons[2]\ForeColor = This\ForeColor
    This\Buttons[2]\BackColor = This\BackColor
    This\Buttons[2]\LineColor = This\LineColor
    This\Buttons[2]\FrameColor = This\FrameColor
    This\Buttons[2]\ArrowColor = This\ArrowColor
    
    This\Buttons[3]\ForeColor = This\ForeColor
    This\Buttons[3]\BackColor = This\BackColor
    This\Buttons[3]\LineColor = This\LineColor
    This\Buttons[3]\FrameColor = This\FrameColor
    This\Buttons[3]\ArrowColor = This\ArrowColor
  EndMacro
  
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
      If Not \Hide
        DrawingMode(#PB_2DDrawing_Default)
        If \Vertical
          Line(\X[0]-1,\Y[0],1,\Height[0],\Buttons[0]\LineColor[0])
          Box(\X[0],\Y[0],\Width[0],\Height[0],\Buttons[0]\ForeColor[0])
          Line(\X[0]+\Width[0],\Y[0],1,\Height[0],\Buttons[0]\LineColor[0])
        Else
          Line(\X[0],\Y[0]-1,\Width[0],1,\Buttons[0]\LineColor[0])
          Box(\X[0],\Y[0],\Width[0],\Height[0],\Buttons[0]\ForeColor[0])
          Line(\X[0],\Y[0]+\Height[0],\Width[0],1,\Buttons[0]\LineColor[0])
        EndIf
        
        ;Case #PB_2DDrawing_Gradient
        DrawingMode(\DrawingMode)
        BoxGradient(\Vertical,\X[3],\Y[3],\Width[3],\Height[3],\Buttons[3]\ForeColor,\Buttons[3]\BackColor)
        
        BackColor(#PB_Default)
        FrontColor(#PB_Default) ; bug
        
        If \DrawingMode = #PB_2DDrawing_Gradient
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(\X[3],\Y[3],\Width[3],\Height[3],\Buttons[3]\FrameColor[0])
        EndIf
      
        If \ButtonLength
          DrawingMode(\DrawingMode)
          BoxGradient(\Vertical,\X[1],\Y[1],\Width[1],\Height[1],\Buttons[1]\ForeColor,\Buttons[1]\BackColor)
          BoxGradient(\Vertical,\X[2],\Y[2],\Width[2],\Height[2],\Buttons[2]\ForeColor,\Buttons[2]\BackColor)
          
          If \DrawingMode = #PB_2DDrawing_Gradient
            DrawingMode(#PB_2DDrawing_Outlined)
            Box(\X[1],\Y[1],\Width[1],\Height[1],\Buttons[1]\FrameColor[0])
            Box(\X[2],\Y[2],\Width[2],\Height[2],\Buttons[2]\FrameColor[0])
          EndIf
          
          DrawingMode(#PB_2DDrawing_Default)
          DrawArrow(\X[1]+(\Width[1]-6)/2,\Y[1]+(\Height[1]-3)/2, 3, Bool(\Vertical), \ArrowColor[0])
          DrawArrow(\X[2]+(\Width[2]-6)/2,\Y[2]+(\Height[2]-3)/2, 3, Bool(\Vertical)+2, \ArrowColor[0])
        EndIf
        
        DrawingMode(#PB_2DDrawing_Default)
        If \Vertical
          Line(\X[3]+(\Width[3]-10)/2,\Y[3]+\Height[3]/2-3,10,1,\ArrowColor[0])
          Line(\X[3]+(\Width[3]-10)/2,\Y[3]+\Height[3]/2,10,1,\ArrowColor[0])
          Line(\X[3]+(\Width[3]-10)/2,\Y[3]+\Height[3]/2+3,10,1,\ArrowColor[0])
        Else
          Line(\X[3]+\Width[3]/2-3,\Y[3]+(\Height[3]-10)/2,1,10,\ArrowColor[0])
          Line(\X[3]+\Width[3]/2,\Y[3]+(\Height[3]-10)/2,1,10,\ArrowColor[0])
          Line(\X[3]+\Width[3]/2+3,\Y[3]+(\Height[3]-10)/2,1,10,\ArrowColor[0])
        EndIf
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
  
  Procedure.b SetState(*This.Struct, ScrollPos.l)
    Protected Result.b
    
    With *This
      If (\Vertical And \Type = #PB_GadgetType_TrackBar) : ScrollPos = ((\Max-\Min)-ScrollPos) : EndIf
      
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
    Protected Result.b
    
    With *This
      Select Attribute
        Case #PB_ScrollBar_Step
          If \Steps <> Value
            \Steps = Value
            Result = #True
          EndIf
          
        Case #PB_ScrollBar_Minimum
          If \Min <> Value
            \Min = Value
            \Pos = Value
            Result = #True
          EndIf
          
        Case #PB_ScrollBar_Maximum
          If \Max <> Value
            If \Min > Value
              \Max = \Min + 1
            Else
              \Max = Value + 1
            EndIf
            Result = #True
          EndIf
          
        Case #PB_ScrollBar_PageLength
          If \PageLength <> Value
            If Value > (\Max-\Min)
              \PageLength = (\Max-\Min)
            Else
              \PageLength = Value
            EndIf
            \Pos = Abs(\Pos) ; ?
            Result = #True
          EndIf
          
      EndSelect
    
;       If Result
;         If Not \Steps
;           \Steps = 1
;         EndIf
;       EndIf
    EndWith
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.b CallBack(*This.Struct, EventType.l, MouseX.l, MouseY.l)
    Protected Result, Buttons
    Static LastX, LastY, Last, *Scroll
    
    With *This
      If (Mousex>\x[1] And Mousex=<\x[1]+\Width[1] And  Mousey>\y[1] And Mousey=<\y[1]+\Height[1])
        Buttons = 1
      ElseIf (Mousex>\x[3] And Mousex=<\x[3]+\Width[3] And Mousey>\y[3] And Mousey=<\y[3]+\Height[3])
        Buttons = 3
      ElseIf (Mousex>\x[2] And Mousex=<\x[2]+\Width[2] And Mousey>\y[2] And Mousey=<\y[2]+\Height[2])
        Buttons = 2
      EndIf
           
      Select EventType
        Case #PB_EventType_MouseLeave : LastX = 0 : LastY = 0 : Buttons = 0
        Case #PB_EventType_LeftButtonUp :  LastX = 0 : LastY = 0
        Case #PB_EventType_LeftButtonDown
          If Buttons : *Scroll = *This : EndIf
          Select Buttons
            Case 1 : Result = SetState(*Scroll, \Pos - \Steps)
            Case 2 : Result = SetState(*Scroll, \Pos + \Steps)
            Case 3 : LastX = MouseX - \ThumbPos : LastY = MouseY - \ThumbPos
          EndSelect
          
        Case #PB_EventType_MouseMove
          If Bool(LastX|LastY) 
            If *Scroll = *This
              If \Vertical
                Result = SetState(*This, Pos(*This, ((MouseY-LastY) / \Steps) * \Steps))
              Else
                Result = SetState(*This, Pos(*This, ((MouseX-LastX) / \Steps) * \Steps))
              EndIf
            EndIf
          Else
            If (Mousex>=\x And Mousex<\x+\Width And Mousey>\y And Mousey=<\y+\Height) And Buttons
              If Last<>Buttons
                If *Scroll
                  CallBack(*Scroll, #PB_EventType_MouseLeave, MouseX, MouseY)
                EndIf
                EventType = #PB_EventType_MouseEnter
                *Scroll = *This
                Last = Buttons
              EndIf
            ElseIf *Scroll = *This
              EventType = #PB_EventType_MouseLeave
              *Scroll = 0
              Last = 0
            EndIf
          EndIf
          
      EndSelect
      
      Select EventType
        Case #PB_EventType_LeftButtonDown, #PB_EventType_LeftButtonUp, #PB_EventType_MouseEnter, #PB_EventType_MouseLeave
;           Debug ""+EventType +" "+ Buttons
          If Buttons
            \Buttons[Buttons]\ForeColor = \ForeColor[1+Bool(EventType=#PB_EventType_LeftButtonDown)]
            \Buttons[Buttons]\BackColor = \BackColor[1+Bool(EventType=#PB_EventType_LeftButtonDown)]
            \Buttons[Buttons]\FrameColor = \FrameColor[1+Bool(EventType=#PB_EventType_LeftButtonDown)]
          Else
            ResetColor(*This)
          EndIf
          
          Result = #True
            
      EndSelect   
    EndWith
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.b SetColor(*This.Struct, ColorType.l, Color.l, Item.l=0)
    Protected Result
    
    With *This
      Select ColorType
        Case #PB_Gadget_LineColor
          \Buttons[Item]\LineColor = Color
          
        Case #PB_Gadget_BackColor
          \Buttons[Item]\BackColor = Color
          
        Case #PB_Gadget_FrontColor
        Default ; Case #PB_Gadget_FrameColor
          \Buttons[Item]\FrameColor = Color
          
      EndSelect
    EndWith
    
    ProcedureReturn Bool(Color)
  EndProcedure
  
  Procedure.b Gadget(*This.Struct, iX.l,iY.l,iWidth.l,iHeight.l, Min.l, Max.l, Pagelength.l, Flag.l=0, Steps.l=1)
    Protected Result
    
    With *This
      \Steps = Steps
      If \Min <> Min : SetAttribute(*This, #PB_ScrollBar_Minimum, Min) : EndIf
      If \Max <> Max : SetAttribute(*This, #PB_ScrollBar_Maximum, Max) : EndIf
      If \PageLength <> Pagelength : SetAttribute(*This, #PB_ScrollBar_PageLength, Pagelength) : EndIf
      
      If ((\Max-\Min) >= \PageLength)
        If \Vertical
          \AreaPos = iY+\ButtonLength
          \AreaLength = (iHeight-\ButtonLength*2)
        Else
          \AreaPos = iX+\ButtonLength
          \AreaLength = (iWidth-\ButtonLength*2)
        EndIf
        
        \ThumbLength = ThumbLength(*This)
        
        If (\AreaLength > \ButtonLength)
          If \ButtonLength
            If (\ThumbLength < \ButtonLength)
              \AreaLength = Round(\AreaLength - (\ButtonLength-\ThumbLength), #PB_Round_Nearest)
              \ThumbLength = \ButtonLength 
            EndIf
          Else
            If (\ThumbLength < 7)
              \AreaLength = Round(\AreaLength - (7-\ThumbLength), #PB_Round_Nearest)
              \ThumbLength = 7
            EndIf
          EndIf
        Else
          \ThumbLength = \AreaLength 
        EndIf
        
        If \AreaLength > 0
          \ThumbPos = ThumbPos(*This, \Pos)
        EndIf
      EndIf
      
      If \Vertical
        ; скролл баре
        \X[0] = iX + Bool(\Type=#PB_GadgetType_ScrollBar)
        \Y[0] = iY 
        \Width[0] = iWidth - 1
        \Height[0] = iHeight 
        
        ; Верхняя кнопка на скролл баре
        \X[1] = iX + Bool(\Type=#PB_GadgetType_ScrollBar)
        \Y[1] = iY
        \Width[1] = iWidth - 1
        \Height[1] = \ButtonLength
        
        ; Нижняя кнопка на скролл баре
        \X[2] = iX + Bool(\Type=#PB_GadgetType_ScrollBar)
        \Width[2] = iWidth - 1
        \Height[2] = \ButtonLength
        \Y[2] = iY+iHeight-\Height[2]
        
        ; Ползунок на скролл баре
        \X[3] = iX + Bool(\Type=#PB_GadgetType_ScrollBar)
        \Width[3] = iWidth - 1
        \Y[3] = \ThumbPos
        \Height[3] = \ThumbLength
        
      Else
        ; скролл баре
        \X[0] = iX 
        \Y[0] = iY + Bool(\Type=#PB_GadgetType_ScrollBar)
        \Width[0] = iWidth
        \Height[0] = iHeight - 1
        
        ; Верхняя кнопка на скролл баре
        \X[1] = iX
        \Y[1] = iY + Bool(\Type=#PB_GadgetType_ScrollBar)
        \Width[1] = \ButtonLength
        \Height[1] = iHeight - 1
        
        ; Нижняя кнопка на скролл баре
        \Y[2] = iY + Bool(\Type=#PB_GadgetType_ScrollBar)
        \Height[2] = iHeight - 1
        \Width[2] = \ButtonLength
        \X[2] = iX+iWidth-\Width[2]
        
        ; Ползунок на скролл баре
        \Y[3] = iY + Bool(\Type=#PB_GadgetType_ScrollBar)
        \Height[3] = iHeight - 1
        \X[3] = \ThumbPos
        \Width[3] = \ThumbLength
        
      EndIf
      
      If Flag
        ResetColor(*This)
      EndIf
      
      ProcedureReturn Bool(Not ((\Max-\Min) > \PageLength))
    EndWith
  EndProcedure
  
EndModule

;- EXAMPLE
CompilerIf #PB_Compiler_IsMainFile
  If LoadImage(0, #PB_Compiler_Home+"Examples\Sources\Data\File.bmp")     ; Измените путь/имя файла на собственное изображение 32x32 пикселя
  EndIf
  Define a,i
  
  Global *Vertical.Scroll::Struct=AllocateStructure(Scroll::Struct)
  Global *Horisontal.Scroll::Struct=AllocateStructure(Scroll::Struct)
  
  
  Procedure CallBack()
    If Scroll::CallBack(*Vertical, EventType(), GetGadgetAttribute(EventGadget(), #PB_Canvas_MouseX), GetGadgetAttribute(EventGadget(), #PB_Canvas_MouseY)) 
      If StartDrawing(CanvasOutput(EventGadget()))
        Scroll::Draw(*Vertical)
        StopDrawing()
      EndIf
    EndIf
    
    If Scroll::CallBack(*Horisontal, EventType(), GetGadgetAttribute(EventGadget(), #PB_Canvas_MouseX), GetGadgetAttribute(EventGadget(), #PB_Canvas_MouseY))
      If StartDrawing(CanvasOutput(EventGadget()))
        Scroll::Draw(*Horisontal)
        StopDrawing()
      EndIf
    EndIf
  EndProcedure
  
  
  If OpenWindow(0, 0, 0, 325, 160, "Scroll on the canvas", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    CanvasGadget(1,  10,10,305,140)
    
    With *Vertical
      \ButtonLength=17
      
      \DrawingMode = #PB_2DDrawing_Gradient
      
      \ForeColor = $F0F0F0
      \BackColor = $E5E5E5
      \LineColor = $FFFFFF
      \FrameColor = $A0A0A0
      \ArrowColor = $5B5B5B
      
      ;
      \ForeColor[1] = $EAEAEA
      \BackColor[1] = $CECECE
      \LineColor[1] = $FFFFFF
      \FrameColor[1] = $8F8F8F
      \ArrowColor[1] = $5B5B5B
      
      ;
      \ForeColor[2] = $E2E2E2
      \BackColor[2] = $B4B4B4
      \LineColor[2] = $FFFFFF
      \FrameColor[2] = $6F6F6F
      \ArrowColor[2] = $5B5B5B
      
      Scroll::Gadget(*Vertical, 10, 42, 250,  20, 30, 100, 30, 1)
      Scroll::SetState(*Vertical, 50) 
    EndWith
    
    With *Horisontal
      \ButtonLength=17
      
      \ForeColor = $F0F0F0
      \BackColor = $E5E5E5
      \LineColor = $FFFFFF
      \FrameColor = $A0A0A0
      \ArrowColor = $5B5B5B
      
      ;
      \ForeColor[1] = $EAEAEA
      \BackColor[1] = $CECECE
      \LineColor[1] = $FFFFFF
      \FrameColor[1] = $8F8F8F
      \ArrowColor[1] = $5B5B5B
      
      ;
      \ForeColor[2] = $E2E2E2
      \BackColor[2] = $B4B4B4
      \LineColor[2] = $FFFFFF
      \FrameColor[2] = $6F6F6F
      \ArrowColor[2] = $5B5B5B
      
      \Vertical = 1
      
      Scroll::Gadget(*Horisontal, 270, 10,  25, 120 ,0, 300, 50, 1)
      Scroll::SetState(*Horisontal, 100) 
    EndWith
    
    If StartDrawing(CanvasOutput(1))
      Scroll::Draw(*Vertical)
      Scroll::Draw(*Horisontal)
      StopDrawing()
    EndIf
    
    BindGadgetEvent(1, @CallBack())
    
    Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
  EndIf
CompilerEndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 5
; Folding = -+--
; EnableXP