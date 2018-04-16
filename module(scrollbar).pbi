XIncludeFile "module(scroll).pbi"
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
    
    Scroll.Scroll::Struct
    
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
  
  Procedure Re(*This.Gadget)
    If Not *This\Repaint : *This\Repaint = #True : EndIf
    Scroll::Gadget(*This\Scroll, *This\X[2], *This\Y[2], *This\Width[2], *This\Height[2], *This\Scroll\Min, *This\Scroll\Max, *This\Scroll\PageLength)
  EndProcedure
  
  Procedure Draw(*This.Gadget)
    With *This
      If \Repaint And StartDrawing(CanvasOutput(\Canvas\Gadget))
        DrawingFont(GetGadgetFont(#PB_Default))
        
        If \fSize
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(\X[1],\Y[1],\Width[1],\Height[1],\Color[1])
        EndIf
        
        Scroll::Draw(*This\Scroll)
        
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
      \Canvas\Mouse\X = GetGadgetAttribute(\Canvas\Gadget, #PB_Canvas_MouseX)
      \Canvas\Mouse\Y = GetGadgetAttribute(\Canvas\Gadget, #PB_Canvas_MouseY)
      \Canvas\Mouse\Buttons = GetGadgetAttribute(\Canvas\Gadget, #PB_Canvas_Buttons)
      
      Select EventType()
        Case #PB_EventType_Resize : ResizeGadget(\Canvas\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore) ; Bug (562)
          Re(*This)
          
      EndSelect
      
      *This\Repaint = Scroll::CallBack(*This\Scroll, EventType(), \Canvas\Mouse\X, \Canvas\Mouse\Y)
      If *This\Repaint 
        ReDraw(*This)
        PostEvent(#PB_Event_Gadget, \Canvas\Window, \Canvas\Gadget, #PB_EventType_Change)
      EndIf
    EndWith
    
    ; Draw(*This)
  EndProcedure
  
  ;- PUBLIC
  Procedure SetAttribute(Gadget.l, Attribute.l, Value.l)
    Protected *This.Gadget = GetGadgetData(Gadget)
    
    With *This
      If Scroll::SetAttribute(*This\Scroll, Attribute, Value)
        ReDraw(*This)
      EndIf
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
      If Scroll::SetState(*This\Scroll, State)
        ReDraw(*This)
        PostEvent(#PB_Event_Gadget, \Canvas\Window, \Canvas\Gadget, #PB_EventType_Change)
      EndIf
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
        
        \Scroll\ForeColor = $F0F0F0
        \Scroll\BackColor = $E5E5E5
        \Scroll\LineColor = $FFFFFF
        \Scroll\FrameColor = $A0A0A0
        \Scroll\ArrowColor = $5B5B5B
        
        ;
        \Scroll\ForeColor[1] = $EAEAEA
        \Scroll\BackColor[1] = $CECECE
        \Scroll\LineColor[1] = $FFFFFF
        \Scroll\FrameColor[1] = $8F8F8F
        \Scroll\ArrowColor[1] = $5B5B5B
        
        ;
        \Scroll\ForeColor[2] = $E2E2E2
        \Scroll\BackColor[2] = $B4B4B4
        \Scroll\LineColor[2] = $FFFFFF
        \Scroll\FrameColor[2] = $6F6F6F
        \Scroll\ArrowColor[2] = $5B5B5B
        
        \Scroll\Type = #PB_GadgetType_ScrollBar
        \Scroll\DrawingMode = #PB_2DDrawing_Gradient
        \Scroll\Vertical = Bool(Flag&#PB_ScrollBar_Vertical)
        Scroll::Gadget(*This\Scroll, *This\X[2], *This\Y[2], *This\Width[2], *This\Height[2], Min, Max, PageLength, 1)
        
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
  ScrollBar::SetState(13, GetGadgetState(EventGadget()))
EndProcedure

Procedure v_CallBack()
  SetGadgetState(3, ScrollBar::GetState(EventGadget()))
EndProcedure

Procedure h_GadgetCallBack()
  ScrollBar::SetState(12, GetGadgetState(EventGadget()))
EndProcedure

Procedure h_CallBack()
  SetGadgetState(2, ScrollBar::GetState(EventGadget()))
EndProcedure


If OpenWindow(0, 0, 0, 605, 140, "ScrollBarGadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  TextGadget       (-1,  10, 25, 250,  20, "ScrollBar Standard  (start=50, page=30/100)",#PB_Text_Center)
  ScrollBarGadget  (2,  10, 42, 250,  20, 30, 100, 30)
  SetGadgetState   (2,  50)   ; set 1st scrollbar (ID = 0) to 50 of 100
  TextGadget       (-1,  10,115, 250,  20, "ScrollBar Vertical  (start=100, page=50/300)",#PB_Text_Right)
  ScrollBarGadget  (3, 270, 10,  25, 120 ,0, 300, 50, #PB_ScrollBar_Vertical)
  SetGadgetState   (3, 100)   ; set 2nd scrollbar (ID = 1) to 100 of 300
  
  TextGadget       (-1,  300+10, 25, 250,  20, "ScrollBar Standard  (start=50, page=30/100)",#PB_Text_Center)
  ScrollBar::Gadget  (12,  300+10, 42, 250,  20, 30, 100, 30)
  ScrollBar::SetState   (12,  50)   ; set 1st scrollbar (ID = 0) to 50 of 100
  TextGadget       (-1,  300+10,115, 250,  20, "ScrollBar Vertical  (start=100, page=50/300)",#PB_Text_Right)
  ScrollBar::Gadget  (13, 300+270, 10,  25, 120 ,0, 300, 50, #PB_ScrollBar_Vertical)
  ScrollBar::SetState   (13, 100)   ; set 2nd scrollbar (ID = 1) to 100 of 300
                                    ;     Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
                                    ;   EndIf
  
  BindGadgetEvent(2,@h_GadgetCallBack())
  BindGadgetEvent(12,@h_CallBack(), #PB_EventType_Change)
  BindGadgetEvent(3,@v_GadgetCallBack())
  BindGadgetEvent(13,@v_CallBack(), #PB_EventType_Change)
  Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 157
; FirstLine = 157
; Folding = ----
; EnableXP