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
  
  Scroll.Coordinate
  
  Repaint.l
  
  List Items.Tree()
  List Columns.Tree()
EndStructure


Procedure Draw(*This.Tree)
  Protected X=5,Y=10, height = 16, width = 16, w=20, level,iY,yy, Adress=-1
  
  With *This\Columns()
    ;If *This\Scroll\Height<*This\Height
    *This\Scroll\Width = 0
    ;*This\Scroll\Height = 0
    
    If *This\Repaint And StartDrawing(CanvasOutput(*This\Canvas))
      DrawingFont(GetGadgetFont(#PB_Default))
      Box(0,0,OutputWidth(), OutputHeight())
    EndIf
    
    ForEach *This\Columns()
      \X = *This\Scroll\Width
      \Scroll\Height = \Height
      
      ForEach \Items()
        \Items()\Y = \Scroll\Height
        
        If *This\Repaint And *This\Height > \Items()\Y
          If \Items()\ImageID : DrawImage(\Items()\ImageID, \x,\Items()\y+(\Items()\height-\Items()\Image\Height)/2) : EndIf
          DrawText(\x+5+\Items()\Image\Width, \Items()\y+(\Items()\height-TextHeight(\Items()\Text))/2, \Items()\Text.s, $000000, $FFFFFF)
        EndIf
        
        \Scroll\Height+\Items()\height
      Next
      
      If *This\Repaint And *This\Width > \X
        Box(\x+\Width, 0,1,*This\Height,0)
        DrawText(\x+5, 5, \Text.s, $000000, $FFFFFF)
      EndIf
      
      *This\Scroll\Width+\Width
      If *This\Scroll\Height<\Scroll\Height
        *This\Scroll\Height=\Scroll\Height
      EndIf
    Next
    
    If *This\Repaint : *This\Repaint = 0
      StopDrawing()
    EndIf
    ;EndIf
  EndWith  
EndProcedure

Procedure CallBack()
  Protected *This.Tree = GetGadgetData(EventGadget())
  
  With *This\Columns()
    
  EndWith
  
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
        \Items()\ImageID = ImageID(Image)
        \Items()\Image\Width = ImageWidth(Image)
        \Items()\Image\Height = ImageHeight(Image)
      EndIf
    Next
    
    If *This\Height > *This\Scroll\Height
      *This\Repaint = 1
    EndIf
    
    Draw(*This)
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
  For i=0 To 555
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
  For i=0 To 555
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
; CursorPosition = 96
; FirstLine = 83
; Folding = -
; EnableXP