XIncludeFile "module(scroll).pbi"
;-
DeclareModule TrackBar
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
  Declare Gadget(Gadget, X.l, Y.l, Width.l, Height.l, Min.l, Max.l, Flag.l=0)
  
EndDeclareModule

Module TrackBar
  
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
    Protected ScrollPos, *This.Gadget = GetGadgetData(Gadget)
    
    With *This
      ScrollPos = \Scroll\Pos
      If (\Scroll\Vertical And \Scroll\Type = #PB_GadgetType_TrackBar) : ScrollPos = ((\Scroll\Max-\Scroll\Min)-ScrollPos) : EndIf
      ProcedureReturn ScrollPos
    EndWith
  EndProcedure
  
  Procedure Gadget(Gadget, X.l, Y.l, Width.l, Height.l, Min.l, Max.l, Flag.l=0)
    Protected *This.Gadget=AllocateStructure(Gadget)
    Protected g = CanvasGadget(Gadget, X, Y, Width, Height) : If Gadget=-1 : Gadget=g : EndIf
    Protected Pagelength.l
    
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
        
        ;\Scroll\ButtonLength = 7
        
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
        
        \Scroll\Type = #PB_GadgetType_TrackBar
        \Scroll\DrawingMode = #PB_2DDrawing_Gradient
        \Scroll\Vertical = Bool(Flag&#PB_TrackBar_Vertical)
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
  TrackBar::SetState(12, GetGadgetState(EventGadget()))
EndProcedure

Procedure v_CallBack()
  SetGadgetState(2, TrackBar::GetState(EventGadget()))
EndProcedure

Procedure h_GadgetCallBack()
  TrackBar::SetState(11, GetGadgetState(EventGadget()))
EndProcedure

Procedure h_CallBack()
  SetGadgetState(1, TrackBar::GetState(EventGadget()))
EndProcedure


If OpenWindow(0, 0, 0, 605, 200, "TrackBarGadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  TextGadget    (-1, 10,  20, 250, 20,"TrackBar Standard", #PB_Text_Center)
    TrackBarGadget(0, 10,  40, 250, 20, 0, 10000)
    SetGadgetState(0, 5000)
    TextGadget    (-1, 10, 100, 250, 20, "TrackBar Ticks", #PB_Text_Center)
    TrackBarGadget(1, 10, 120, 250, 20, 0, 30, #PB_TrackBar_Ticks)
    SetGadgetState(1, 3000)
    TextGadget    (-1,  90, 180, 200, 20, "TrackBar Vertical", #PB_Text_Right)
    TrackBarGadget(2, 270, 10, 20, 170, 0, 10000, #PB_TrackBar_Vertical)
    SetGadgetState(2, 8000)
    
  TextGadget    (-1, 300+10,  20, 250, 20,"TrackBar Standard", #PB_Text_Center)
    TrackBar::Gadget(10, 300+10,  40, 250, 20, 0, 10000)
    TrackBar::SetState(10, 5000)
    TextGadget    (-1, 300+10, 100, 250, 20, "TrackBar Ticks", #PB_Text_Center)
    TrackBar::Gadget(11, 300+10, 120, 250, 20, 0, 30, #PB_TrackBar_Ticks)
    TrackBar::SetState(11, 3000)
    TextGadget    (-1,  300+90, 180, 200, 20, "TrackBar Vertical", #PB_Text_Right)
    TrackBar::Gadget(12, 300+270, 10, 20, 170, 0, 10000, #PB_TrackBar_Vertical)
    TrackBar::SetState(12, 8000)
    
  BindGadgetEvent(1,@h_GadgetCallBack())
  BindGadgetEvent(11,@h_CallBack(), #PB_EventType_Change)
  BindGadgetEvent(2,@v_GadgetCallBack())
  BindGadgetEvent(12,@v_CallBack(), #PB_EventType_Change)
  Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
EndIf



; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 157
; FirstLine = 154
; Folding = ----
; EnableXP