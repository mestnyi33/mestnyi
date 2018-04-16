XIncludeFile "module(scroll).pbi"
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
    Drawing.l
    
    Text.s[3]
    ImageID.l[3]
    Color.l[4]
    
    Image.Coordinate
    
    fSize.l
    bSize.l
    
    Scroll.Coordinate
    vScroll.Scroll::Struct
    hScroll.Scroll::Struct
    
    Type.l
    InnerCoordinate.Coordinate
    
    Repaint.l
    
    List Items.Gadget()
    List Columns.Gadget()
  EndStructure
  
  
  ;- DECLARE
  Declare Gadget(Gadget, X.l, Y.l, Width.l, Height.l, Min.l, Max.l, Pagelength.l, Flag.l=0)
  
  Declare AddColumn(Gadget,Item,Text.s,Width.l,Image.l=-1)
  Declare AddItem(Gadget,Item,Text.s,Image.l,Flag.l=0)
EndDeclareModule

Module ListView
 Procedure Re(*This.Gadget)
  With *This\Columns()
    If Not *This\Repaint
      *This\Repaint = #True
    EndIf
    *This\Scroll\Width = 0
    
    ForEach *This\Columns()
      \X = *This\Scroll\Width
      \Scroll\Height = \Height
      
      ForEach \Items()
        \Items()\Y = \Scroll\Height-*This\vScroll\Pos
        
        \Scroll\Height+\Items()\height
      Next
      
      *This\Scroll\Width+\Width
      If *This\Scroll\Height<\Scroll\Height
        *This\Scroll\Height=\Scroll\Height
      EndIf
    Next
    
    *This\vScroll\Hide = Scroll::Gadget(*This\vScroll, *This\Width[2]-17, *This\Y[2], 17, *This\Height[2], *This\vScroll\Min, *This\Scroll\Height, *This\Height);, 0, *This\vScroll\ScrollStep)
    *This\hScroll\Hide = Scroll::Gadget(*This\hScroll, *This\X[2], *This\Height[2]-17, *This\Width[2], 17, *This\vScroll\Min, *This\Scroll\Width, *This\Width)
    
  EndWith  
EndProcedure

Procedure Draw(*This.Gadget)
  Protected X=5,Y=10, height = 16, width = 16, w=20, level,iY,yy, Adress=-1
  
  With *This\Columns()
;     If *This\Drawing 
;       *This\Drawing = 0
;       StopDrawing()
;     EndIf
;     
;     If *This\Repaint And StartDrawing(CanvasOutput(*This\Canvas\Gadget))
      DrawingFont(GetGadgetFont(#PB_Default))
      Box(0,0,OutputWidth()-17, OutputHeight())
      
      If *This\fSize
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(*This\X[1],*This\Y[1],*This\Width[1],*This\Height[1],*This\Color[0])
        EndIf
        
        Scroll::Draw(*This\vScroll)
        Scroll::Draw(*This\hScroll)
        
     
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
      
        
;         *This\Repaint = #False
;       StopDrawing()
;     EndIf
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
    
    If *This\Height > *This\Scroll\Height
      Draw(*This)
    Else
;       If \Drawing
;         ;StopDrawing()
;       Else
;         \Drawing = StartDrawing(CanvasOutput(*This\Canvas\Gadget))
;       EndIf
;       
      Scroll::Draw(*This\vScroll)
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
    
    If *This\Width > *This\Scroll\Width
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
        
        \vScroll\ForeColor[0] = $F0F0F0
        \vScroll\BackColor[0] = $E5E5E5
        \vScroll\LineColor[0] = $FFFFFF
        \vScroll\FrameColor[0] = $A0A0A0
        \vScroll\ArrowColor[0] = $5B5B5B
        
        ;
        \vScroll\ForeColor[1] = $EAEAEA
        \vScroll\BackColor[1] = $CECECE
        \vScroll\LineColor[1] = $FFFFFF
        \vScroll\FrameColor[1] = $8F8F8F
        \vScroll\ArrowColor[1] = $5B5B5B
        
        ;
        \vScroll\ForeColor[2] = $E2E2E2
        \vScroll\BackColor[2] = $B4B4B4
        \vScroll\LineColor[2] = $FFFFFF
        \vScroll\FrameColor[2] = $6F6F6F
        \vScroll\ArrowColor[2] = $5B5B5B
        
        \vScroll\Vertical = Bool(Flag&#PB_ScrollBar_Vertical)
        Scroll::Gadget(*This\vScroll, *This\X[2], *This\Y[2], *This\Width[2], *This\Height[2], Min, Max, PageLength, 1, 17)
        
        \hScroll\ButtonLength = 17
        
        \hScroll\ForeColor[0] = $F0F0F0
        \hScroll\BackColor[0] = $E5E5E5
        \hScroll\LineColor[0] = $FFFFFF
        \hScroll\FrameColor[0] = $A0A0A0
        \hScroll\ArrowColor[0] = $5B5B5B
        
        ;
        \hScroll\ForeColor[1] = $EAEAEA
        \hScroll\BackColor[1] = $CECECE
        \hScroll\LineColor[1] = $FFFFFF
        \hScroll\FrameColor[1] = $8F8F8F
        \hScroll\ArrowColor[1] = $5B5B5B
        
        ;
        \hScroll\ForeColor[2] = $E2E2E2
        \hScroll\BackColor[2] = $B4B4B4
        \hScroll\LineColor[2] = $FFFFFF
        \hScroll\FrameColor[2] = $6F6F6F
        \hScroll\ArrowColor[2] = $5B5B5B
        
        ;\hScroll\hertical = Bool(Flag&#PB_ScrollBar_Vertical)
        Scroll::Gadget(*This\hScroll, *This\X[2], *This\Y[2], *This\Width[2], *This\Height[2], Min, Max, PageLength, 1)
        
        If \Drawing
        ;StopDrawing()
      Else
        \Drawing = StartDrawing(CanvasOutput(*This\Canvas\Gadget))
      EndIf
      
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


If OpenWindow(0, 0, 0, 630, 450, "TreeGadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  Define t=ElapsedMilliseconds()
  
  Define g = 1
  ListIconGadget(g, 10, 10, 560, 210,"Column_1",100)                                         
  For i=1 To 2
    AddGadgetColumn(g, i,"Column_"+Str(i+1),100)
  Next
  ; 1_example
  For i=0 To 515
    AddGadgetItem(g, i, Str(i)+"_Column_1"+#LF$+Str(i)+"_Column_2"+#LF$+Str(i)+"_Column_3"+#LF$+Str(i)+"_Column_4", ImageID(0))                                           
  Next
  
  Debug "time "+Str(ElapsedMilliseconds()-t)
  Define max=CountGadgetItems(g)*21
   
  
  t=ElapsedMilliseconds()
  g = 10
  ListView::Gadget(g, 10, 230, 560, 210,0,max, 210, #PB_ScrollBar_Vertical)                                         
  ListView::AddColumn(g, 0,"Column_"+Str(1),100)
  For i=1 To 2
    ListView::AddColumn(g, i,"Column_"+Str(i+1),100)
  Next
  ; 1_example
  For i=0 To 515
    ListView::AddItem(g, i, Str(i)+"_Column_1"+#LF$+Str(i)+"_Column_2"+#LF$+Str(i)+"_Column_3"+#LF$+Str(i)+"_Column_4", 0)                                           
  Next
  
  Define *This.ListView::Gadget = GetGadgetData(g)
  If *This\Drawing
    StopDrawing()
  EndIf
  
  Debug "time "+Str(ElapsedMilliseconds()-t)
  
  Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 72
; FirstLine = 72
; Folding = ---
; EnableXP