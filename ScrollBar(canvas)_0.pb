EnableExplicit

Structure Coordinate
  y.l[3]
  x.l[3]
  Height.l[3]
  Width.l[3]
EndStructure

Structure Scroll Extends Coordinate
  ButtonSize.l
  Max.l
  Min.l
  PageLength.l
  Area.l
  Pos.l
  ThumbSize.l
  ThumbPos.l
EndStructure

Structure Tree Extends Coordinate
  Canvas.l
  Text.s
  ImageID.l
  Image.Coordinate
  fSize.l
  
  Scroll.Scroll
  IsVertical.l
  bSize.l
  Type.l
  InnerCoordinate.Coordinate
  
  Repaint.l
  
  List Items.Tree()
  List Columns.Tree()
EndStructure






Procedure UpdateScrollPos(*This.Tree, ThumbPos)
  Protected Result
  
  With *This
    Result = Round((ThumbPos - \Scroll\ButtonSize - \bSize) / (\Scroll\Area / (\Scroll\Max-\Scroll\Min)), #PB_Round_Nearest)
    
    If (\IsVertical And \Type = #PB_GadgetType_TrackBar) 
      Result = ((\Scroll\Max-\Scroll\Min)-Result)
    EndIf
  EndWith
  
  ProcedureReturn Result
EndProcedure

Macro UpdateScrollThumbSize(_this_, _area_)
  Round(_area_ - (_area_ / (_this_\Scroll\Max-_this_\Scroll\Min))*((_this_\Scroll\Max-_this_\Scroll\Min) - _this_\Scroll\PageLength), #PB_Round_Nearest)
EndMacro

Procedure UpdateScrollThumbPos(*This.Tree, ScrollPos, Area)
  Protected Result 
  
  With *This
    
    If ScrollPos =< 0
      Result = \Scroll\ButtonSize 
      \Scroll\Pos = 0
    Else
      If ScrollPos>((\Scroll\Max-\Scroll\Min)-\Scroll\PageLength)
        \Scroll\Pos=((\Scroll\Max-\Scroll\Min)-\Scroll\PageLength)
        ScrollPos=\Scroll\Pos
      EndIf
      
      Result = (\Scroll\ButtonSize + Round(ScrollPos * (Area / (\Scroll\Max-\Scroll\Min)), #PB_Round_Nearest))
      
      If \IsVertical
        If (Result+\Scroll\ThumbSize) > (\Height[2]-\Scroll\ButtonSize)
          Result = \Height[2] - \Scroll\ButtonSize - \Scroll\ThumbSize
        EndIf
      Else
        If (Result+\Scroll\ThumbSize) > (\Width[2]-\Scroll\ButtonSize)
          Result = \Width[2] - \Scroll\ButtonSize - \Scroll\ThumbSize
        EndIf
      EndIf
    EndIf
    
  EndWith
  
  ProcedureReturn Result
EndProcedure

Procedure UpdateScrollCoordinate(*This.Tree)
  Protected Area, Result, ButtonSize 
  
  With *This
    If \IsVertical
      \Scroll\Area = \Height[2] - \Scroll\ButtonSize*2 
    Else
      \Scroll\Area = \Width[2] - \Scroll\ButtonSize*2 
    EndIf
    
    Area = \Scroll\Area
    ButtonSize = \Scroll\ButtonSize
    
;     If \Scroll\Max = 0 : \Scroll\Max = Area : EndIf
;     If \Scroll\PageLength = 0 : \Scroll\PageLength = 25 : EndIf
    
    If (\Scroll\Max-\Scroll\Min) > \Scroll\PageLength
      Result = UpdateScrollThumbSize(*This.Tree, Area)
    EndIf
    
    If (Area > ButtonSize)
      If (Result < ButtonSize)
        Area = Round(\Scroll\Area - (ButtonSize-Result), #PB_Round_Nearest)
        Result = ButtonSize 
      EndIf
    Else
      Result = Area 
    EndIf
    
    \Scroll\ThumbSize = Result
    
    If Area > 0
      \Scroll\ThumbPos = UpdateScrollThumbPos(*This.Tree, \Scroll\Pos, Area)
    EndIf
  EndWith
  
EndProcedure


Procedure GetAttribute(*This.Tree, Attribute)
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

Procedure SetAttribute(*This.Tree, Attribute, Value)
  Protected Update 
  
  With *This
    
    Select Attribute
      Case #PB_ScrollBar_Minimum
        If \Scroll\Min <> Value
          \Scroll\Min = Value
          Update = #True
        EndIf
        
      Case #PB_ScrollBar_Maximum
        If \Scroll\Max <> Value
          If \Scroll\Min > Value
            \Scroll\Max = (\Scroll\Min + 1)
          Else
            \Scroll\Max = Value
          EndIf
          Update = #True
        EndIf
        
      Case #PB_ScrollBar_PageLength
        If \Scroll\PageLength <> Value
          If Value > (\Scroll\Max-\Scroll\Min)
            \Scroll\PageLength = (\Scroll\Max-\Scroll\Min)
          Else
            \Scroll\PageLength = Value
          EndIf
          \Scroll\Pos = Abs(\Scroll\Pos)
          Update = #True
        EndIf
        
    EndSelect
    
    If Update
      UpdateScrollCoordinate(*This)
    EndIf
    
  EndWith
  
EndProcedure






Procedure Re(*This.Tree)
  With *This
    If Not *This\Repaint
      *This\Repaint = #True
    EndIf
    \Scroll\Height = 0
    
    ForEach \Items()
      If \IsVertical
        
        \Items()\X = \X[2]
        \Items()\Width = \Width[2]
        \Items()\Height = \Scroll\ButtonSize-1
        
        Select ListIndex(\Items())
          Case 0 ; Верхняя кнопка на скролл баре
            \Items()\Y = \Y[2]
            
          Case 1 ; Нижняя кнопка на скролл баре
            \Items()\Y = \Height[2]-\Items()\Height+1
            
          Case 2 ; Ползунок на скролл баре
            \Items()\Y = \Scroll\ThumbPos
            \Items()\Height = \Scroll\ThumbSize
            
        EndSelect
      Else
          
          \Items()\Y = \Y[2]
          \Items()\Height = \Height[2]
          \Items()\Width = \Scroll\ButtonSize
          
          ; Верхняя кнопка на скролл баре
          If ListIndex(\Items()) = 0 
            \Items()\X = \X[2]
            
          ; Нижняя кнопка на скролл баре
          ElseIf ListIndex(\Items()) = 1 
            \Items()\X = \Width[2]-\Items()\Width
            
          ; Ползунок на скролл баре
          ElseIf ListIndex(\Items()) = 2
            \Items()\X = \Scroll\ThumbPos
            \Items()\Width = \Scroll\ThumbSize
          EndIf
        EndIf
        
        
        
    Next
  EndWith  
EndProcedure

Procedure Draw(*This.Tree)
  Protected X=5,Y=10, height = 16, width = 16, w=20, level,iY,yy, Adress=-1
  
  With *This
    If *This\Repaint And StartDrawing(CanvasOutput(*This\Canvas))
      DrawingFont(GetGadgetFont(#PB_Default))
      Box(0,0,OutputWidth(), OutputHeight())
      
      DrawingMode(#PB_2DDrawing_Outlined)
        Box(\X, \Y,\Width,\Height,0)
      
      ForEach \Items()
        DrawingMode(#PB_2DDrawing_Outlined)
        
        Box(\Items()\X, \Items()\Y,\Items()\Width,\Items()\Height,$9D9C9D)
      Next
      
      *This\Repaint = #False
      StopDrawing()
    EndIf
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
  
  With *This
    AddElement(\Items()) 
    
    \Items()\Height = 17
    \Items()\Width = \Width
    
    If Text
      ;\Items()\Text\Change = #True
      \Items()\Text.s = Text
    EndIf
    
    If IsImage(Image)
      \Items()\ImageID = ImageID(Image)
      \Items()\Image\Width = ImageWidth(Image)
      \Items()\Image\Height = ImageHeight(Image)
    EndIf
    
    Re(*This)
    
    If *This\Height > *This\Scroll\Height
      Draw(*This)
    EndIf
    
  EndWith
EndProcedure

Procedure Gadget(Gadget, x, y, w, h, min.l, max.l, pagelength.l)
  Protected *This.Tree=AllocateStructure(Tree)
  Protected g = CanvasGadget(Gadget, x, y, w, h) : If Gadget=-1 : Gadget=g : EndIf
  
  If *This
    With *This
      \Canvas = Gadget
      \Width = w
      \Height = h
      \fSize = 1
      
      ; Inner coordinae
      \X[2]=\fSize
      \Y[2]=\fSize
      \Width[2] = w-\fSize*2
      \Height[2] = h-\fSize*2
      
      \IsVertical = 1
      \Scroll\ButtonSize = 17
      
      SetAttribute(*This, #PB_ScrollBar_Minimum, Min)
      SetAttribute(*This, #PB_ScrollBar_Maximum, Max)
      SetAttribute(*This, #PB_ScrollBar_PageLength, PageLength)
      
      
    EndWith
    
    SetGadgetData(Gadget, *This)
  EndIf
  
  AddItem(Gadget,#PB_Any,"",-1,0)
  AddItem(Gadget,#PB_Any,"",-1,0)
  AddItem(Gadget,#PB_Any,"",-1,0)
;   AddItem(Gadget,#PB_Any,"",-1,0)
;   AddItem(Gadget,#PB_Any,"",-1,0)
  
  BindGadgetEvent(Gadget, @CallBack())
  ProcedureReturn Gadget
EndProcedure

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
  
  ScrollBarGadget  (-1, 575, 10, 20, 210,0,max, 210, #PB_ScrollBar_Vertical)
    
  For g = 10 To 100
  Gadget(g, 600, 10, 20, 210,0,max, 210)                                         
  Next

  Debug "time "+Str(ElapsedMilliseconds()-t)
  
;   Define *This.Tree = GetGadgetData(g)
;   
;   With *This\Columns()
;     Debug "Scroll_Height "+*This\Scroll\Height
;   EndWith
;   
  
  Repeat : Until WaitWindowEvent() = #PB_Event_CloseWindow
EndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 388
; FirstLine = 357
; Folding = --
; EnableXP