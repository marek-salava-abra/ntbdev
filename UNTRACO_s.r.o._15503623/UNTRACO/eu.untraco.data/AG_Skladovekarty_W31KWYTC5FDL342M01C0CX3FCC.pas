uses 'eu.untraco.data.ParseData', 'eu.untraco.data.Progress';
{
procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import dodavatelů';
  mAction.Items.Add('Nový import');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Provede import z csv';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportData;

end;
 }
procedure ImportData(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mSMBO, mSM, mFirmBO, mbankBO, mSupplierBO, mSCBO:TNxCustomBusinessObject;
 mUnits:TNxCustomBusinessMonikerCollection;
 mUnit:TNxCustomBusinessObject;
 mList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mStoreCard_ID, mParent_ID, mSupplier_ID, mFirm_ID:String;
 mNew:Boolean;
 mGRows : TMultiGrid;
 mXMlHead:TNxScriptingXMLWrapper;
 {'code','name','date','price','quantity','odpis','stredisko','SN'}
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
  if index=0 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mXMlHead:=TNxScriptingXMLWrapper.Create;
        mXMlHead.loadFromFile(mOpenDlg.FileName);
        j:=mXMlHead.getElementsCountInArray('Categories.Category');
        for i:=0 to j-1 do begin
         if not(mXMlHead.getAttributeValue('Categories.Category['+IntToStr(i)+']','id_parent')='0') then begin
           mSMBO:=mOS.CreateObject(Class_StoreMenuItem);
           msmbo.New;
           msmbo.Prefill;
           msmbo.SetFieldValueAsString('Text',AnsiLeftStr(mXMlHead.getAttributeValue('Categories.Category['+IntToStr(i)+']','name'),30));
           msmbo.SetFieldValueAsString('X_idp',mXMlHead.getAttributeValue('Categories.Category['+IntToStr(i)+']','id'));
           msmbo.SetFieldValueAsString('Parent_ID',GetPArent_ID(mOS,mXMlHead.getAttributeValue('Categories.Category['+IntToStr(i)+']','id_parent')));
           msmbo.Save;
           msmbo.free;
         end;
        end;
        j:=mXMlHead.getElementsCountInArray('Products.Product');
        try
           ProgressInit(mSite, 'Import dodavatelů...', j);
           for i := 0 to j - 1 do begin
              mstorecard_ID:=GetStoreCard_ID(mOS,mXMlHead.getAttributeValue('Products.Product['+IntToStr(i)+']','reference'));
              if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                mSMBO:=mOS.CreateObject(Class_StoreCard);
                mSMBO.Load(mStoreCard_ID,nil);
                msmbo.SetFieldValueAsBoolean('X_Eshop',True);
                mSMBO.SetFieldValueAsString('StoreMenuItem_ID',GetPArent_ID(mOS,mXMlHead.getAttributeValue('Products.Product['+IntToStr(i)+']','id_category')));
                mSMBO.SetFieldValueAsString('X_note',
                NxSearchReplace(
                NxSearchReplace(
                NxSearchReplace(
                NxSearchReplace(
                mXMlHead.getAttributeValue('Products.Product['+IntToStr(i)+']','description'),
                '&lt;','<',[srall]),
                '&gt;','<',[srall]),
                '&#13;',chr(13),[srall]),
                '&#10;',chr(10),[srall])
                );
                mSMBO.SetFieldValueAsString('X_note2',
                NxSearchReplace(
                NxSearchReplace(
                NxSearchReplace(
                NxSearchReplace(
                mXMlHead.getAttributeValue('Products.Product['+IntToStr(i)+']','description_short'),
                '&lt;','<',[srall]),
                '&gt;','<',[srall]),
                '&#13;',chr(13),[srall]),
                '&#10;',chr(10),[srall])
                );
                mSMBO.Save;
                msmbo.Free;

              end;

           ProgressSetPos(i+1);
           end;
          ProgressDispose();
        finally


        end;
      finally
      end;
    end;
  finally
  end;
  end;

end;
begin
end.