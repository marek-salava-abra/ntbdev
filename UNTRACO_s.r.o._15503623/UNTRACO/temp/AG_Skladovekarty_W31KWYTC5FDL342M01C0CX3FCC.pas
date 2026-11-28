uses 'eu.untraco.XML.progress';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
  mMAction: TMultiAction;
  mUser:TNxCustomBusinessObject;
begin
  //if (mUser.GetFieldCode('U_StoreChanges')>0) and mUser.GetFieldValueAsBoolean('U_StoreChanges') then begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'XML';
  mAction.Hint := 'XML';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportXML_OnExecute;
end;

procedure ImportXML_OnExecute(Sender : TComponent; Index : integer);
var
  mSite : TSiteForm;
  mOpenDlg : TOpenDialog;
  mList, mFileList : TStringList;
  mBO, mRowBO : TNxCustomBusinessObject;
  mGRows : TMultiGrid;
  i,j: integer;
  mXMLHead : TNxScriptingXMLWrapper;
  mstrings : TStrings;
  mstring, mFileName : String;
  mOS:TNxCustomObjectSpace;
  mFile, mErrorFile : TstringList;
  mRows:TNxCustomBusinessMonikerCollection;
  mStorecard_ID, mFirm_ID:String;
begin
  mSite := TComponent(Sender).BusRollSite;
  mOpenDlg := TOpenDialog.create(mSite);
  //mOpenDlg.Options:=([ofAllowMultiSelect]);
  mOpenDlg.DefaultExt:='XML';
  mos:=msite.CompanyObjectSpace;
   try
    if mOpenDlg.Execute then begin
      mFileName:=mOpenDlg.FileName;
      try
        mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(mFileName);
        ProgressInit(mSite, 'Import dat...', mXMLHead.getElementsCountInArray('product'));
         for i:=0 to mXMLHead.getElementsCountInArray('product')-1 do begin
           mStoreCard_ID:=GetStoreCard_ID(mOS,mXMLHead.getElementAsString('product['+IntToStr(i)+'].system_id'));
           if not(NxIsEmptyOID(mStorecard_ID)) then begin
              mBO:=mOS.CreateObject(Class_StoreCard);
              mbo.Load(mStorecard_ID,nil);
               for j:=0 to mXMLHead.getElementsCountInArray('product['+IntToStr(i)+'].param')-1 do begin
                 if mXMLHead.getAttributeValue('product['+IntToStr(i)+'].param['+IntToStr(j)+']','name')='Barva lemu:' then
                    mBO.SetFieldValueAsString('U_barva_lemu',mXMLHead.getElementAsString('product['+IntToStr(i)+'].param['+IntToStr(j)+']'));
                 if mXMLHead.getAttributeValue('product['+IntToStr(i)+'].param['+IntToStr(j)+']','name')='Počet balení v kartonu:' then
                    mBO.SetFieldValueAsInteger('X_Prepocet',trunc(NxIBStrToFloat(mXMLHead.getElementAsString('product['+IntToStr(i)+'].param['+IntToStr(j)+']'))));
                 if mXMLHead.getAttributeValue('product['+IntToStr(i)+'].param['+IntToStr(j)+']','name')='Sací schopnost v ml:' then
                    mBO.SetFieldValueAsString('U_sacischopnost',mXMLHead.getElementAsString('product['+IntToStr(i)+'].param['+IntToStr(j)+']'));
                 if mXMLHead.getAttributeValue('product['+IntToStr(i)+'].param['+IntToStr(j)+']','name')='Rozměr v cm:' then
                    mBO.SetFieldValueAsString('U_rozmer',mXMLHead.getElementAsString('product['+IntToStr(i)+'].param['+IntToStr(j)+']'));
                  if mXMLHead.getAttributeValue('product['+IntToStr(i)+'].param['+IntToStr(j)+']','name')='Počet kusů v balení:' then
                    mBO.SetFieldValueAsInteger('U_ks_bal',trunc(NxIBStrToFloat(mXMLHead.getElementAsString('product['+IntToStr(i)+'].param['+IntToStr(j)+']'))));
                 if mXMLHead.getAttributeValue('product['+IntToStr(i)+'].param['+IntToStr(j)+']','name')='Obvod boků v cm:' then
                    mBO.SetFieldValueAsString('U_obvodbok',mXMLHead.getElementAsString('product['+IntToStr(i)+'].param['+IntToStr(j)+']'));
                 if mXMLHead.getAttributeValue('product['+IntToStr(i)+'].param['+IntToStr(j)+']','name')='Váhová kategorie v kg:' then
                    mBO.SetFieldValueAsString('U_vahova_kategorie',mXMLHead.getElementAsString('product['+IntToStr(i)+'].param['+IntToStr(j)+']'));
                 if mXMLHead.getAttributeValue('product['+IntToStr(i)+'].param['+IntToStr(j)+']','name')='Těsnost AQL stupeň' then
                    mBO.SetFieldValueAsString('U_tesnost',mXMLHead.getElementAsString('product['+IntToStr(i)+'].param['+IntToStr(j)+']'));
                 if mXMLHead.getAttributeValue('product['+IntToStr(i)+'].param['+IntToStr(j)+']','name')='Tloušťka v mm' then
                    mBO.SetFieldValueAsString('U_tloustka',mXMLHead.getElementAsString('product['+IntToStr(i)+'].param['+IntToStr(j)+']'));
               end;
              mbo.save;
              mbo.free;
           end;
         ProgressSetPos(i+1);
         end;
      ProgressDispose();
      finally

      end;
    end;
   finally

   end;

end;

function GetStoreCard_ID(AOS : TNxCustomObjectSpace;aID : string;):string;
const
  cSQL = 'SELECT sc.id  FROM StoreCards sc where sc.id=''%s'' and sc.Hidden=''N''';

var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [aID]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

begin
end.