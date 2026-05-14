 uses 'abra.eu.mask.Spedos.ucto.ColorChoosea.libs';

//barva řádku
procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mGrid: TDBGrid;
begin
  mGrid := TDBGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdList'));
  if Assigned(mGrid) then begin
    mGrid.OnGetCellParams := @OnGetCellParams;
  end;
end;

procedure OnGetCellParams(Sender: TObject; Field: TField; AFont: TFont; var Background: TColor; Highlight: Boolean);
var
  mGrid: TDBGrid;
  mDS: TNxCustomObjectDataSet;
  mAO: TNxCustomBusinessObject;
  mContext: TNxContext;
  mSite: TDynSiteForm;
begin
  if Highlight then
    exit;
  mGrid := TDBGrid(Sender);
  mSite := TDynSiteForm(mGrid.Owner);
  if Assigned(mSite.CurrentObject) then
  //  if not NxIsEmptyOID(msite.CurrentObject.GetFieldValueAsString('ServiceDocument_ID.BusProject_ID')) then begin
  //      Background:=1676767;
  //  end;
    //AFont.Color := mSite.CurrentObject.GetFieldValueAsInteger('Docqueue_id.X_Color');
  Background:=mColorbackground;
  if mSite.CurrentObject.GetFieldValueAsDateTime('Accdate$date') < 42736 then begin


                if not( (mSite.CurrentObject.GetFieldValueAsString('CreditDivision_ID.code')='200-x') or
                   (mSite.CurrentObject.GetFieldValueAsString('CreditDivision_ID.code')='300-x') or
                   (mSite.CurrentObject.GetFieldValueAsString('DebitDivision_ID.code')='200-x') or
                   (mSite.CurrentObject.GetFieldValueAsString('DebitDivision_ID.code')='300-x') ) and (mSite.CurrentObject.GetFieldValueAsDateTime('AccDate$DATE')<42736)

                then begin
                     AFont.Color:=255;
                end;
               // if (mSite.CurrentObject.GetFieldValueAsString('Division.code')='200x') or
               //    (mSite.CurrentObject.GetFieldValueAsString('Division.code')='300x')
               // then begin
               //      AFont.Color:=32768;
               // end;

                   if not((mSite.CurrentObject.GetFieldValueAsString('CreditDivision_ID.code')='200-x') or
                   (mSite.CurrentObject.GetFieldValueAsString('CreditDivision_ID.code')='300-x') or
                   (mSite.CurrentObject.GetFieldValueAsString('DebitDivision_ID.code')='200-x') or
                   (mSite.CurrentObject.GetFieldValueAsString('DebitDivision_ID.code')='300-x') ) and (mSite.CurrentObject.GetFieldValueAsDateTime('AccDate$DATE')<42736)

                then begin
                    AFont.Style:=[fsStrikeOut] ;
                end;

            //    if mSite.CurrentObject.GetFieldValueAsInteger('ServiceDocument_ID.Docqueue_id.X_Color')> 0 then begin

                   //    end else begin
            //
            //    end;
            end;
end;



begin
end.
