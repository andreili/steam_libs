constructor TList.Create();
begin
  inherited;
end;

destructor TList.Destroy;
begin
   Clear;
   inherited;
end;

//[procedure TList.Release]
{$IFDEF ASM_TLIST}
procedure TList.Release;
asm
       TEST      EAX, EAX
       JZ        @@e
       MOV       ECX, [EAX].fCount
       JECXZ     @@e
       MOV       EDX, [EAX].fItems
       PUSH      EAX
@@1:
       MOV       EAX, [EDX+ECX*4-4]
       TEST      EAX, EAX
       JZ        @@2
       PUSH      EDX
       PUSH      ECX
       CALL      System.@FreeMem
       POP       ECX
       POP       EDX
@@2:   LOOP      @@1
       POP       EAX
@@e:   CALL      TObj.RefDec
end;
{$ELSE ASM_VERSION} //Pascal
procedure TList.Release;
var I: Integer;
begin
  if @ Self = nil then Exit;
  for I := 0 to fCount - 1 do
    if {$IFDEF TLIST_FAST} Items {$ELSE} fItems {$ENDIF}[ I ] <> nil then
      FreeMem( {$IFDEF TLIST_FAST} Items {$ELSE} fItems {$ENDIF}[ I ] );
  Free;
end;
{$ENDIF ASM_VERSION}

//[procedure TList.ReleaseObjects]
procedure TList.ReleaseObjects;
var I: Integer;
begin
  if @ Self = nil then Exit;
  for I := fCount-1 downto 0 do
    TObject(fItems[i]).Free;
  Free;
end;

//[procedure TList.SetCapacity]
{$IFDEF ASM_VERSION}
{$ELSE ASM_VERSION} //Pascal
//var NewItems: PPointerList;
procedure TList.SetCapacity( Value: Integer );
begin
  {$IFDEF TLIST_FAST}
  if  Value > 256 then // Capacitity в обычном смысле работает только дл€ первого
      Value := 256;    // блока - до 256 элементов, далее оно смысла не имеет,
                       // т.к. все прочие блоки всегда содержат по 256 позиций
                       // дл€ элементов, независимо от процента использовани€.
  if fUseBlocks and (Assigned( fBlockList ) {or (Value > 256)}) then
  begin
    fCapacity := Value;
  end
  else
  {$ENDIF}
  begin
   if Value < Count then
      Value := Count;
   if Value = fCapacity then Exit;
   ReallocMem( fItems, Value * Sizeof( Pointer ) );
   fCapacity := Value;
  end;
end;
{$ENDIF ASM_VERSION}

//[procedure TList.Clear]
{$IFDEF ASM_VERSION}
{$ELSE ASM_VERSION} //Pascal
procedure TList.Clear;
{$IFDEF TLIST_FAST}
var i: Integer;
{$ENDIF}
begin
   if fItems <> nil then
      FreeMem( fItems );
   fItems := nil;
   fCount := 0;
   fCapacity := 0;
   {$IFDEF TLIST_FAST}
   if fBlockList <> nil then
   begin
     for i := 0 to fBlockList.Count div 2 - 1 do
       FreeMem( fBlockList.Items[ i*2 ] );
     Free_And_Nil( fBlockList );
   end;
   fLastKnownBlockIdx := 0;
   fLastKnownCountBefore := 0;
   {$ENDIF}
end;
{$ENDIF ASM_VERSION}

//[procedure TList.SetAddBy]
procedure TList.SetAddBy(Value: Integer);
begin
  if Value < 1 then Value := 1;
  fAddBy := Value;
end;

function Min(const A, B: Integer): Integer;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

//[procedure TList.Add]
{$IFDEF ASM_NO_VERSION}  /// ASM-version disabled due some problems - 20-May-2010
{$ELSE ASM_VERSION} //Pascal
procedure TList.Add( Value: Pointer );
{$IFDEF TLIST_FAST}
var LastBlockCount: Integer;
    LastBlockStart: Pointer;
{$ENDIF}
begin
  {$IFDEF TLIST_FAST}
   if fUseBlocks and ((fCount >= 256) or Assigned( fBlockList )) then
   begin
     if fBlockList = nil then
     begin
       fBlockList := NewList;
       fBlockList.fUseBlocks := FALSE;
       fBlockList.Add( fItems );
       fBlockList.Add( Pointer( fCount ) );
       fItems := nil;
     end;
     if fBlockList.fCount = 0 then
     begin
       fBlockList.Add( nil );
       fBlockList.Add( nil );
       LastBlockCount := 0;
     end
       else
     begin
       LastBlockCount := Integer( fBlockList.fItems[ fBlockList.fCount-1 ] );
       if LastBlockCount >= 256 then
       begin
         fBlockList.Add( nil );
         fBlockList.Add( nil );
         LastBlockCount := 0;
       end;
     end;
     LastBlockStart := fBlockList.Items[ fBlockList.fCount-2 ];
     if LastBlockStart = nil then
     begin
       GetMem( LastBlockStart, 256 * Sizeof( Pointer ) );
       fBlockList.Items[ fBlockList.fCount-2 ] := LastBlockStart;
     end;
     fBlockList.Items[ fBlockList.fCount-1 ] := Pointer( LastBlockCount+1 );
     PDWORD( Integer(LastBlockStart) + Sizeof(Pointer)*LastBlockCount )^ :=
       DWORD( Value );
   end
     else
  {$ENDIF}
  begin
     if fCapacity <= fCount then
     begin
       if fAddBy <= 0 then
         Capacity := fCount + Min( 1000, fCount div 4 + 1 )
       else
         Capacity := fCount + fAddBy;
     end;
     fItems[ fCount ] := Value;
  end;
  Inc( fCount );
end;
{$ENDIF ASM_VERSION}

{$IFDEF _D4orHigher}
procedure TList.AddItems(const AItems: array of Pointer);
var i: Integer;
begin
  Capacity := Count + Length( AItems );
  for i := 0 to High( AItems ) do
    Add( AItems[ i ] );
end;
{$ENDIF}

//[procedure TList.Delete]
procedure TList.Delete( Idx: Integer );
begin
  DeleteRange( Idx, 1 );
end;

//[procedure TList.DeleteRange]
{$IFDEF ASM_TLIST}
procedure TList.DeleteRange(Idx, Len: Integer);
asm     //cmd    //opd
        TEST     ECX, ECX
        JLE      @@exit
        CMP      EDX, [EAX].fCount
        JGE      @@exit
        PUSH     EBX
        XCHG     EBX, EAX
        LEA      EAX, [EDX+ECX]
        CMP      EAX, [EBX].fCount
        JBE      @@1
        MOV      ECX, [EBX].fCount
        SUB      ECX, EDX
@@1:
        MOV      EAX, [EBX].fItems
        PUSH     [EBX].fCount
        SUB      [EBX].fCount, ECX
        MOV      EBX, EDX
        LEA      EDX, [EAX+EDX*4]
        LEA      EAX, [EDX+ECX*4]
        ADD      EBX, ECX
        POP      ECX
        SUB      ECX, EBX
        SHL      ECX, 2
        CALL     System.Move
        POP      EBX
@@exit:
end;
{$ELSE ASM_VERSION} //Pascal
procedure TList.DeleteRange(Idx, Len: Integer);
{$IFDEF TLIST_FAST}
var i, DelFromBlock: Integer;
    CountBefore, CountCurrent: Integer;
    BlockStart: Pointer;
{$ENDIF}
begin
  if Len <= 0 then Exit;
  if Idx >= Count then Exit;
  Assert( (Idx >= 0), 'TList.DeleteRange: index out of bounds' );
  if DWORD( Idx + Len ) > DWORD( Count ) then
    Len := Count - Idx;
  {$IFDEF TLIST_FAST}
  if fUseBlocks and Assigned( fBlockList ) then
  begin
    CountBefore := 0;
    i := 0;
    if (fLastKnownBlockIdx > 0) and
       (Idx >= fLastKnownCountBefore) then
    begin
      i := fLastKnownBlockIdx;
      CountBefore := fLastKnownCountBefore;
    end;
    while i < fBlockList.fCount div 2 do
    begin
      BlockStart := fBlockList.fItems[ i * 2 ];
      CountCurrent := Integer( fBlockList.fItems[ i * 2 + 1 ] );
      if (Idx >= CountBefore) and (Idx < CountBefore + CountCurrent) then
      begin
        DelFromBlock := CountBefore + CountCurrent - Idx;
        if DelFromBlock > Len then
          DelFromBlock := Len;
        if DelFromBlock < CountCurrent then
        begin
          move( Pointer( Integer( BlockStart ) + (Idx - CountBefore + DelFromBlock) * Sizeof( Pointer ) )^,
                Pointer( Integer( BlockStart ) + (Idx - CountBefore) * Sizeof( Pointer ) )^,
                (CountCurrent - (Idx - CountBefore) - DelFromBlock) * Sizeof( Pointer ) );
          dec( CountCurrent, DelFromBlock );
          fBlockList.fItems[ i * 2 + 1 ] := Pointer( CountCurrent );
          dec( fCount, DelFromBlock );
          dec( Len, DelFromBlock );
          if Len <= 0 then Exit;
        end
          else
        begin // delete entire block
          //++ fix added: 21.06.08 ++ VK
          fLastKnownBlockIdx := 0;
          fLastKnownCountBefore := 0;
          //++++++++++++++++++++++++++++
          FreeMem( BlockStart );
          fBlockList.DeleteRange( i * 2, 2 );
          dec( fCount, CountCurrent );
          dec( Len, CountCurrent );
          if Len <= 0 then Exit;
          CountCurrent := 0;
          dec( i );
        end;
      end;
      inc( i );
      inc( CountBefore, CountCurrent );
    end;
  end
    else
  {$ENDIF}
  begin
    Move( fItems[ Idx + Len ], fItems[ Idx ], Sizeof( Pointer ) * (Count - Idx - Len) );
    Dec( fCount, Len );
  end;
end;
{$ENDIF ASM_VERSION}

//[procedure TList.Remove]
procedure TList.Remove(Value: Pointer);
var I: Integer;
begin
  I := IndexOf( Value );
  if I >= 0 then
    Delete( I );
end;

function TList.ItemAddress(Idx: Integer): Pointer;
{$IFDEF TLIST_FAST}
var i: Integer;
    BlockStart: Pointer;
    CountBefore, CountCurrent: Integer;
{$ENDIF}
begin
  {$IFDEF TLIST_FAST}
  if fUseBlocks and Assigned( fBlockList ) then
  begin
    CountBefore := 0;
    i := 0;
    if (fLastKnownBlockIdx > 0) and
       (Idx >= fLastKnownCountBefore) then
    begin
      CountBefore := fLastKnownCountBefore;
      i := fLastKnownBlockIdx;
    end;
    CountCurrent := CountBefore + Integer( fBlockList.fItems[ i*2+1 ] );
    if Idx - CountCurrent > fCount - CountCurrent then
    begin // поиск в обратном направлении может оказатьс€ быстрее
      CountBefore := fCount;
      i := fBlockList.fCount div 2 - 1;
      while TRUE do
      begin
        BlockStart := fBlockList.fItems[ i * 2 ];
        CountCurrent := Integer( fBlockList.fItems[ i * 2 + 1 ] );
        if (CountBefore - CountCurrent <= Idx) and (Idx < CountBefore) then
        begin
          Result := Pointer( Integer( BlockStart ) +
                             (Idx - (CountBefore - CountCurrent))*Sizeof( Pointer ) );
          Exit;
        end;
        dec( CountBefore, CountCurrent );
        dec( i );
      end;
    end;
    while TRUE { i < fBlockList.Count div 2 } do
    begin
      BlockStart := fBlockList.fItems[ i * 2 ];
      CountCurrent := Integer( fBlockList.fItems[ i * 2 + 1 ] );
      if (CountBefore <= Idx) and (Idx < CountBefore + CountCurrent) then
      begin
        Result := Pointer( Integer( BlockStart ) + (Idx - CountBefore) * Sizeof( Pointer ) );
        Exit;
      end;
      inc( CountBefore, CountCurrent );
      inc( i );
    end;
  end
    else
  {$ENDIF}
  Result := Pointer( Integer( fItems ) + Idx * Sizeof( Pointer ) );
end;

//[procedure TList.Put]
{$IFDEF ASM_VERSION}
procedure TList.Put( Idx: Integer; Value: Pointer );
asm
  TEST   EDX, EDX
  JL     @@exit
  CMP    EDX, [EAX].fCount
  JGE    @@exit
  PUSH   ESI
  MOV    ESI, ECX
  {$IFDEF TLIST_FAST}
  CMP    [EAX].fUseBlocks, 0
  JZ     @@old
  MOV    ECX, [EAX].fBlockList
  JECXZ  @@old
  PUSH   EBX
  PUSH   ESI
  PUSH   EDI
  PUSH   EBP
  XCHG   EBX, EAX // EBX == @Self
  XOR    ECX, ECX // CountBefore := 0;
  XOR    EAX, EAX // i := 0;
  CMP    [EBX].fLastKnownBlockIdx, 0
  JLE    @@1
  CMP    EDX, [EBX].fLastKnownCountBefore
  JL     @@1
  MOV    ECX, [EBX].fLastKnownCountBefore
  MOV    EAX, [EBX].fLastKnownBlockIdx
@@1:
  MOV    ESI, [EBX].fBlockList
  MOV    ESI, [ESI].fItems
  MOV    EDI, [ESI+EAX*8]   // EDI = BlockStart
  MOV    ESI, [ESI+EAX*8+4] // ESI = CountCurrent
  CMP    ECX, EDX
  JG     @@next
  LEA    EBP, [ECX+ESI]
  CMP    EDX, EBP
  JGE    @@next
  MOV    [EBX].fLastKnownBlockIdx, EAX
  MOV    [EBX].fLastKnownCountBefore, ECX
  SUB    EDX, ECX
  LEA    EAX, [EDI+EDX*4]
  POP    EBP
  POP    EDI
  POP    ESI
  POP    EBX
  MOV    [EAX], ESI
  POP    ESI
  RET
@@next:
  ADD    ECX, ESI
  INC    EAX
  JMP    @@1
@@old:
  {$ENDIF}
  MOV    EAX, [EAX].fItems
  MOV    [EAX+EDX*4], ESI
  POP    ESI
@@exit:
end;
{$ELSE not ASM_VERSION}
procedure TList.Put( Idx: Integer; Value: Pointer );
{$IFDEF TLIST_FAST}
var i: Integer;
    BlockStart: Pointer;
    CountBefore, CountCurrent: Integer;
{$ENDIF}
begin
   if Idx < 0 then Exit;
   if Idx >= Count then Exit;
   {$IFDEF TLIST_FAST}
   if fUseBlocks and Assigned( fBlockList ) then
   begin
    CountBefore := 0;
    i := 0;
    if (fLastKnownBlockIdx > 0) and
       (Idx >= fLastKnownCountBefore) then
    begin
      i := fLastKnownBlockIdx;
      CountBefore := fLastKnownCountBefore;
    end;
    while i < fBlockList.fCount div 2 do
    begin
      BlockStart := fBlockList.fItems[ i * 2 ];
      CountCurrent := Integer( fBlockList.fItems[ i * 2 + 1 ] );
      if (CountBefore <= Idx) and (Idx < CountBefore + CountCurrent) then
      begin
        fLastKnownBlockIdx := i;
        fLastKnownCountBefore := CountBefore;
        PDWORD( Integer( BlockStart ) + (Idx - CountBefore) * Sizeof( Pointer ) )^ :=
          DWORD( Value );
        Exit;
      end;
      inc( CountBefore, CountCurrent );
      inc( i );
    end;
   end
     else
   {$ENDIF}
   fItems[ Idx ] := Value;
end;
{$ENDIF ASM_VERSION}

//[function TList.Get]
{$IFDEF ASM_VERSION}
function TList.Get( Idx: Integer ): Pointer;
asm
  TEST   EDX, EDX
  JL     @@ret_nil
  CMP    EDX, [EAX].fCount
  JGE    @@ret_nil
  {$IFDEF TLIST_FAST}
  CMP    [EAX].fUseBlocks, 0
  JZ     @@old
  MOV    ECX, [EAX].fBlockList
  JECXZ  @@old
  PUSH   EBX
  PUSH   ESI
  PUSH   EDI
  PUSH   EBP
  XCHG   EBX, EAX // EBX == @Self
  XOR    ECX, ECX // CountBefore := 0;
  XOR    EAX, EAX // i := 0;
  CMP    [EBX].fLastKnownBlockIdx, 0
  JLE    @@1
  CMP    EDX, [EBX].fLastKnownCountBefore
  JL     @@1
  MOV    ECX, [EBX].fLastKnownCountBefore
  MOV    EAX, [EBX].fLastKnownBlockIdx
@@1:
  MOV    ESI, [EBX].fBlockList
  MOV    ESI, [ESI].fItems
  MOV    EDI, [ESI+EAX*8]   // EDI = BlockStart
  MOV    ESI, [ESI+EAX*8+4] // ESI = CountCurrent
  CMP    ECX, EDX
  JG     @@next
  LEA    EBP, [ECX+ESI]
  CMP    EDX, EBP
  JGE    @@next
  MOV    [EBX].fLastKnownBlockIdx, EAX
  MOV    [EBX].fLastKnownCountBefore, ECX
  SUB    EDX, ECX
  MOV    EAX, [EDI+EDX*4]
  POP    EBP
  POP    EDI
  POP    ESI
  POP    EBX
  RET
@@next:
  ADD    ECX, ESI
  INC    EAX
  JMP    @@1
@@old:
  {$ENDIF}
  MOV    EAX, [EAX].fItems
  MOV    EAX, [EAX+EDX*4]
  RET
@@ret_nil:
  XOR    EAX, EAX
end;
{$ELSE not ASM_VERSION}
function TList.Get( Idx: Integer ): Pointer;
{$IFDEF TLIST_FAST}
var i: Integer;
    BlockStart: Pointer;
    CountBefore, CountCurrent: Integer;
{$ENDIF}
begin
  Result := nil;
  if Idx < 0 then Exit;
  if Idx >= fCount then Exit;
  {$IFDEF TLIST_FAST}
  if fUseBlocks and Assigned( fBlockList ) then
  begin
    CountBefore := 0;
    i := 0;
    if (fLastKnownBlockIdx > 0) and
       (Idx >= fLastKnownCountBefore) then
    begin
      i := fLastKnownBlockIdx;
      CountBefore := fLastKnownCountBefore;
    end;
    while {i < fBlockList.fCount div 2} TRUE do
    begin
      BlockStart := fBlockList.fItems[ i * 2 ];
      CountCurrent := Integer( fBlockList.fItems[ i * 2 + 1 ] );
      if (CountBefore <= Idx) and (Idx < CountBefore + CountCurrent) then
      begin
        fLastKnownBlockIdx := i;
        fLastKnownCountBefore := CountBefore;
        Result := Pointer( PDWORD( Integer( BlockStart ) + (Idx - CountBefore) * Sizeof( Pointer ) )^ );
        Exit;
      end;
      inc( CountBefore, CountCurrent );
      inc( i );
    end;
  end
    else
  {$ENDIF}
  Result := fItems[ Idx ];
end;
{$ENDIF ASM_VERSION}

//[function TList.IndexOf]
{$IFDEF ASM_TLIST}
function TList.IndexOf( Value: Pointer ): Integer;
asm
        PUSH      EDI

        MOV       EDI, [EAX].fItems
        MOV       ECX, [EAX].fCount
          PUSH      EDI
          DEC       EAX            // make "NZ" - EAX always <> 1
          MOV       EAX, EDX
          REPNZ     SCASD
          POP       EDX
        {$IFDEF USE_CMOV}
        CMOVNZ    EDI, EDX
        {$ELSE}
        JZ        @@succ
        MOV       EDI, EDX
@@succ: {$ENDIF}

        MOV       EAX, EDI
        STC
        SBB       EAX, EDX
        SAR       EAX, 2

        POP       EDI
end;
{$ELSE ASM_VERSION} //Pascal
function TList.IndexOf( Value: Pointer ): Integer;
var I: Integer;
    {$IFDEF TLIST_FAST}
    BlockStart: PDWORD;
    j: Integer;
    CountBefore, CountCurrent: Integer;
    {$ENDIF}
begin
  Result := -1;
  {$IFDEF DEBUG}
  TRY
  {$ENDIF}
     {$IFDEF TLIST_FAST}
     if fUseBlocks and Assigned( fBlockList ) then
     begin
       CountBefore := 0;
       for I := 0 to fBlockList.fCount div 2 - 1 do
       begin
         BlockStart := fBlockList.fItems[ I * 2 ];
         CountCurrent := Integer( fBlockList.fItems[ I * 2 + 1 ] );
         for j := 0 to CountCurrent-1 do
         begin
           if BlockStart^ = DWORD( Value ) then
           begin
             Result := CountBefore + j;
             Exit;
           end;
           inc( BlockStart );
         end;
         inc( CountBefore, CountCurrent );
       end;
     end
       else
     {$ENDIF}
     begin
       for I := 0 to fCount - 1 do
       begin
          if fItems[ I ] = Value then
          begin
             Result := I;
             break;
          end;
       end;
     end;
  {$IFDEF DEBUG}
  EXCEPT
    asm
      nop
    end;
  END;
  {$ENDIF}
end;
{$ENDIF ASM_VERSION}

//[procedure TList.Insert]
{$IFDEF ASM_TLIST}
procedure TList.Insert(Idx: Integer; Value: Pointer);
asm
        PUSH      ECX
        PUSH      EAX
        PUSH      [EAX].fCount
          PUSH      EDX
          CALL      TList.Add   // don't matter what to add
          POP       EDX         // EDX = Idx, Eax = Count-1
        POP       EAX
        SUB       EAX, EDX

        SAL       EAX, 2
        MOV       ECX, EAX      // ECX = (Count - Idx - 1) * 4
        POP       EAX
        MOV       EAX, [EAX].fItems
        LEA       EAX, [EAX + EDX*4]
        JL        @@1
          PUSH      EAX
          LEA       EDX, [EAX + 4]
          CALL      System.Move

          POP       EAX          // EAX = @fItems[ Idx ]
@@1:
        POP       ECX            // ECX = Value
        MOV       [EAX], ECX
end;
{$ELSE ASM_VERSION} //Pascal
procedure TList.Insert(Idx: Integer; Value: Pointer);
{$IFDEF TLIST_FAST}
var i: Integer;
    CountBefore, CountCurrent: Integer;
    BlockStart, NewBlock: Pointer;
{$ENDIF}
begin
   Assert( (Idx >= 0) and (Idx <= FCount+1), 'List index out of bounds' );
   {$IFDEF TLIST_FAST}
   if fUseBlocks and (Assigned( fBlockList ) or (fCount >= 256)) then
   begin
     if not Assigned( fBlockList ) then
     begin
       fBlockList := NewList;
       fBlockList.fUseBlocks := FALSE;
       fBlockList.Add( fItems );
       fBlockList.Add( Pointer( fCount ) );
       fItems := nil;
     end;
     if fBlockList.fCount = 0 then
     begin
       GetMem( NewBlock, 256 * Sizeof( Pointer ) );
       fBlockList.Add( NewBlock );
       fBlockList.Add( nil );
     end;
     CountBefore := 0;
     i := 0;
     if (fLastKnownBlockIdx > 0) and
        (Idx >= fLastKnownCountBefore) then
     begin
       i := fLastKnownBlockIdx;
       CountBefore := fLastKnownCountBefore;
     end;
     while TRUE {i < fBlockList.fCount div 2} do
     begin
       CountCurrent := Integer( fBlockList.Items[ i * 2 + 1 ] );
       if (Idx >= CountBefore) and
          ((Idx < CountBefore + CountCurrent) or
           (Idx = CountBefore + CountCurrent) and
           (CountCurrent < 256)) then // insert in block i
       begin
         BlockStart := fBlockList.fItems[ i * 2 ];
         if BlockStart = nil then
         begin
           GetMem( BlockStart, 256 * Sizeof( Pointer ) );
           fBlockList.fItems[ i * 2 ] := BlockStart;
         end;
         Idx := Idx - CountBefore;
         if CountCurrent < 256 then
         begin
           if Idx < CountCurrent then
             Move( Pointer( Integer( BlockStart ) + Idx * Sizeof( Pointer ) )^,
                   Pointer( Integer( BlockStart ) + (Idx+1) * Sizeof( Pointer ) )^,
                   (CountCurrent - Idx) * Sizeof( Pointer ) );
           PDWORD( Integer( BlockStart ) + Idx * Sizeof( Pointer ) )^ :=
             DWORD( Value );
           fBlockList.fItems[ i * 2 + 1 ] := Pointer( CountCurrent + 1 );
         end
           else // new block is created since current block is full 256 items
         begin
           GetMem( NewBlock, 256 * Sizeof( Pointer ) );
           fBlockList.Insert( (i+1)*2, Pointer( 256-Idx ) );
           fBlockList.Insert( (i+1)*2, NewBlock );
           move( Pointer( Integer( BlockStart ) + Idx * Sizeof( Pointer ) )^,
                 NewBlock^, (256 - Idx) * Sizeof( Pointer ) );
           PDWORD( Integer( BlockStart ) + Idx * Sizeof( Pointer ) )^ :=
             DWORD( Value );
           fBlockList.fItems[ i * 2 + 1 ] := Pointer( Idx + 1 );
         end;
         fLastKnownBlockIdx := i;
         fLastKnownCountBefore := CountBefore;
         inc( fCount );
         Exit;
       end;
       inc( CountBefore, CountCurrent );
       inc( i );
       if i >= fBlockList.fCount div 2 then
       begin
         fBlockList.Add( nil );
         fBlockList.Add( nil );
       end;
     end;
   end
     else
   {$ENDIF}
   begin
     Add( nil );
     if fCount > Idx then
       Move( FItems[ Idx ], FItems[ Idx + 1 ], (fCount - Idx - 1) * Sizeof( Pointer ) );
     FItems[ Idx ] := Value;
   end;
end;
{$ENDIF ASM_VERSION}

{$IFDEF ASM_VERSION} {$DEFINE MoveItem_ASM} {$ENDIF}
{$IFDEF TLIST_FAST}  {$UNDEF  MoveItem_ASM} {$ENDIF}

//[procedure TList.MoveItem]
{$IFDEF MoveItem_ASM}
{$ELSE ASM_VERSION} //Pascal
procedure TList.MoveItem(OldIdx, NewIdx: Integer);
var Item: Pointer;
begin
  if OldIdx = NewIdx then Exit;
  if NewIdx >= Count then Exit;
  Item := Items[ OldIdx ];
  Delete( OldIdx );
  Insert( NewIdx, Item );
end;
{$ENDIF ASM_VERSION}

//[function TList.Last]
{$IFDEF ASM_VERSION}
{$ELSE ASM_VERSION} //Pascal
function TList.Last: Pointer;
begin
  if Count = 0 then
    Result := nil
  else
    Result := Items[ Count-1 ];
end;
{$ENDIF ASM_VERSION}

//[procedure TList.Swap]
{$IFDEF ASM_TLIST}
procedure TList.Swap(Idx1, Idx2: Integer);
asm
        MOV       EAX, [EAX].fItems
          PUSH      dword ptr [EAX + EDX*4]
            PUSH      ECX
            MOV       ECX, [EAX + ECX*4]
            MOV       [EAX + EDX*4], ECX
            POP       ECX
          POP       EDX
        MOV       [EAX + ECX*4], EDX
end;
{$ELSE ASM_VERSION} //Pascal
procedure TList.Swap(Idx1, Idx2: Integer);
var Tmp: DWORD;
    AItem1, AItem2: PDWORD;
begin
  {$IFDEF TLIST_FAST}
  AItem1 := ItemAddress( Idx1 );
  AItem2 := ItemAddress( Idx2 );
  {$ELSE}
  AItem1 := Pointer( Integer( fItems ) + Idx1 * Sizeof( Pointer ) );
  AItem2 := Pointer( Integer( fItems ) + Idx2 * Sizeof( Pointer ) );
  {$ENDIF}
  Tmp := AItem1^;
  AItem1^ := AItem2^;
  AItem2^ := Tmp;
end;
{$ENDIF ASM_VERSION}

//[procedure TList.SetCount]
procedure TList.SetCount(const Value: Integer);
begin
  if Value >= Count then exit;
  fCount := Value;
end;

//[procedure TList.Assign]
procedure TList.Assign(SrcList: TList);
{$IFDEF TLIST_FAST}
var i, CountCurrent: Integer;
    SrcBlock, DstBlock: Pointer;
{$ENDIF}
begin
  Clear;
  if SrcList.fCount > 0 then
  begin
    {$IFDEF TLIST_FAST}
    if SrcList.fUseBlocks and Assigned( SrcList.fBlockList ) then
    begin
      fBlockList := NewList;
      fBlockList.Assign( SrcList.fBlockList );
      for i := 0 to fBlockList.Count div 2 - 1 do
      begin
        SrcBlock := SrcList.fBlockList.fItems[ i*2 ];
        CountCurrent := Integer( fBlockList.fItems[ i*2+1 ] );
        GetMem( DstBlock, 256 * Sizeof( Pointer ) );
        fBlockList.fItems[ i*2 ] := DstBlock;
        move( SrcBlock^, DstBlock^, CountCurrent );
      end;
    end
      else
    {$ENDIF}
    begin
      Capacity := SrcList.fCount;
      Move( SrcList.FItems[ 0 ], FItems[ 0 ], Sizeof( Pointer ) * SrcList.fCount );
    end;
  end;
  fCount := SrcList.fCount;
end;

///////////////////////////////////////////////////////////////////////////
//                        I  N  I  -  F  I  L  E  S
///////////////////////////////////////////////////////////////////////////

constructor TIniFile.Create(const FileName: String);
begin
  inherited Create();
  fFileName := FileName;
end;

destructor TIniFile.Destroy;
begin
  fFileName := '';
  fSection := '';
  inherited;
end;

procedure TIniFile.ClearAll;
begin
  WritePrivateProfileString( nil, nil, nil,
                             PChar( fFileName ) );
end;

procedure TIniFile.ClearKey(const Key: String);
begin
  WritePrivateProfileString( PChar( fSection ), PChar( Key ), nil,
                             PChar( fFileName ) );
end;

procedure TIniFile.ClearSection;
begin
  WritePrivateProfileString( PChar( fSection ), nil, nil,
                             PChar( fFileName ) );
end;

function TIniFile.ValueBoolean(const Key: String; Value: Boolean): Boolean;
begin
  if fMode = ifmRead then
     Result := GetPrivateProfileInt( pChar( fSection ), pChar( Key ),
               Integer( Value ), pChar( fFileName ) ) <> 0
  else
  begin
    WritePrivateProfileString( pChar( fSection ), pChar( Key ),
              pChar( string( Int2Str( Integer( Value ) ) ) ),
              pChar( fFileName ) );
    Result := Value;
  end;
end;

//[function TIniFile.ValueData]
function TIniFile.ValueData(const Key: string; Value: Pointer;
  Count: Integer): Boolean;
begin
  if fMode = ifmRead then
     Result := GetPrivateProfileStruct( pChar( fSection ), pChar( Key ),
               Value, Count, pChar( fFileName ) )
  else
     Result := WritePrivateProfileStruct( pChar( fSection ), pChar( Key ),
               Value, Count, pChar( fFileName ) );
end;

//[function TIniFile.ValueInteger]
function TIniFile.ValueInteger(const Key: string; Value: Integer): Integer;
begin
  if fMode = ifmRead then
     Result := GetPrivateProfileInt( pChar( fSection ), pChar( Key ),
               Integer( Value ), pChar( fFileName ) )
  else
  begin
     Result := Value;
     WritePrivateProfileString( pChar( fSection ), pChar( Key ),
               pChar( string( Int2Str( Value ) ) ), pChar( fFileName ) );
  end;
end;

//[function TIniFile.ValueString]
function TIniFile.ValueString(const Key, Value: string): string;
var
  Buffer: array[0..4095] of Char;
begin
  if fMode = ifmRead then
  begin
    Buffer[ 0 ] := #0;
    if GetPrivateProfileString(pChar(fSection),
         pChar(Key), pChar(Value), Buffer, SizeOf(Buffer) div Sizeof(Char),
         pChar(fFileName)) <> 0 then
     Result := Buffer
    else
     Result := ''; // ѕо причине того, что FPC выдает ошибку при отсутствии Key в INI-файле // MTsv DN
  end
    else
  begin
     Result := Value;
     WritePrivateProfileString( pChar( fSection ), pChar( Key ),
               pChar( Value ), pChar( fFileName ) );
  end;
end;
(*
procedure TIniFile.GetSectionNames(Names:PKOLStrList);
var
  i:integer;
  Pc:pChar;
  PcEnd:pChar;
  Buffer:Pointer;
begin
  GetMem(Buffer,IniBufferSize * Sizeof( KOLChar ));
  Pc:=Buffer;
  i := GetPrivateProfileSectionNames(Buffer, IniBufferSize, pChar(fFileName));
  PcEnd:=Pc+i;
  repeat
    Names.Add(Pc);
    Pc:=PC+Length(PC)+1;
  until PC>=PcEnd;
  FreeMem(Buffer);
end;

//[procedure TIniFile.SectionData]
procedure TIniFile.SectionData(Names: PKOLStrList);
var
  i:integer;
  Pc:pChar;
  PcEnd:pChar;
  Buffer:Pointer;
begin
  GetMem(Buffer,IniBufferSize * Sizeof(KOLChar));
  Pc:=Buffer;
  if fMode = ifmRead then
  begin
    i:=GetPrivateProfileSection(pChar(fSection), Buffer, IniBufferSize, pChar(fFileName));
    PcEnd:=Pc+i;
    while PC < PcEnd do // Chg by ECM from REPEAT-UNTIL: i=0 (empty section) => Names.Count=1
    begin
      Names.Add(Pc);
      Pc:=PC+Length(PC)+1;
    end;
  end else
  begin
    for i:= 0 to Names.Count-1 do
    begin
      {$IFDEF UNICODE_CTRLS} WStrCopy {$ELSE} StrCopy {$ENDIF}
        (Pc,Names.ItemPtrs[i]);
      Pc:=PC+Length(PC)+1;
    end;
    Pc[0]:=#0;
    ClearSection;
    WritePrivateProfileSection(pChar(fSection), Buffer, pChar(fFileName));

  end;
  FreeMem(Buffer);
end;
*)
