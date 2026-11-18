procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TdbGrid;
  mFieldDef: TFieldDef;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol, mMGColJednotka,mMGColVychystano,mMGColDeliveredQuantity: TNxMultiGridColumn;
  mMGColRoll: TNxMultiGridObjectRollColumn;
  b: Boolean;
begin
  mMG := Tdbgrid(NxFindChildControl(Self.GetSiteAppForm, 'grdRows'));
    if Assigned(mMG) then begin
           NxResetDBGridColumns(mMG, 2, 0)     ;
           //NxResetDBGridColumns(mMG, 5, 0)     ;

            //NxResetDBGridColumns(mMG, 3, 0)     ;

       { for i:=mMG.count -1 downto 0 do begin
          if mMG.Columns[i].FieldName = 'UnitrealQuantity' then
                 NxResetDBGridColumns(mMG, i, 0)     ;

         end;    }
    end;

end;



begin
end.