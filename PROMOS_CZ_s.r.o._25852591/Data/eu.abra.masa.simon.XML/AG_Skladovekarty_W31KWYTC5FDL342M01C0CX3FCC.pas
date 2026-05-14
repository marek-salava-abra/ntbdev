const
 cMainDir = '\\10.0.0.15\abra_images';
 cURL = 'server.eline.cz';
 cPass = 'xqUogyHQC8_8';
 cLogin = 'elinewebabra';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportXML';
  mAction.Caption := 'Import XML Simon';
  mAction.Hint := 'Naimportuje XML ze Simonu';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportData;
end;

Procedure ImportData(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg:TOpenDialog;
 mOS:TNxCustomObjectSpace;
 i,j, n:integer;
 mParCode, mParGroupcode, mPosIndex,mImageFile:string;
 mXMLHead:TNxScriptingXMLWrapper;
 mStoreCard_ID, mParam_ID, mParamGroup_ID:string;
 mBO, mParamBO, mGroupParamBO, mSCParamBO, mNewBO:TNxCustomBusinessObject;
 mFtp:TFTP;
 mIntPosindex:Integer;
 mPictures:TNxCustomBusinessMonikerCollection;
begin
  mSite:=TComponent(sender).BusRollSite;
  mOS:=mSite.BaseObjectSpace;
  mOpenDlg := TOpenDialog.Create(Sender);
  mOpenDlg.Title := 'Import z Simonu';
  mOpenDlg.Filter := 'Soubory XML (*.xml)| *.xml';
      if mOpenDlg.Execute then begin
        mXMLHead:=TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(mOpenDlg.FileName);
        n:=mXMLHead.getElementsCountInArray('StoreCard');
        WaitWin.StartProgress('Čekejte, prosím ...', '',  n);
        for i:=0 to mXMLHead.getElementsCountInArray('StoreCard')-1 do begin
         mStoreCard_ID:=mos.SQLSelectFirstAsString('Select id from storecards where hidden='+QuotedStr('N')+' and code='+QuotedStr(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].code')),'');
         if not(NxIsEmptyOID(mStoreCard_ID)) then begin
           try
            mBO:=mOS.CreateObject(Class_StoreCard);
            mBO.Load(mStoreCard_ID,nil);
            mBO.SetFieldValueAsString('Note',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Note'));
            mBO.SetFieldValueAsString('X_Name_eshop',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Name'));
            mBO.SetFieldValueAsString('X_Name_Eshop',NxSearchReplace(mBO.GetFieldValueAsString('X_Name_eshop'),'King Tony ','',[srAll]));
            if mXMLHead.getElementsCountInArray('StoreCard['+inttostr(i)+'].Parameters.Parameter')>0 then begin
              for j:=0 to mXMLHead.getElementsCountInArray('StoreCard['+inttostr(i)+'].Parameters.Parameter')-1 do begin
                mParam_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid='+Quotedstr('KCAWICC3H2O4DG0YEDMLO4X0PK')+' and name='+QuotedStr(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Parameters.Parameter['+IntToStr(j)+'].ParamName')),'');
                if NxIsEmptyOID(mParam_ID) then begin
                  mParamBO:=mOS.CreateObject('KCAWICC3H2O4DG0YEDMLO4X0PK');
                  mParamBO.new;
                  mParamBO.Prefill;
                  mParamBO.SetFieldValueAsString('Name',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Parameters.Parameter['+IntToStr(j)+'].ParamName'));
                  mParCode:=mOS.SQLSelectFirstAsString('Select max(code) from defrolldata where clsid='+QuotedStr('KCAWICC3H2O4DG0YEDMLO4X0PK'),'');
                  mParcode:='P'+AnsiRightStr('000'+inttostr(StrToInt(AnsiRightStr(mParCode,3))+1),3);
                  mParamBO.SetFieldValueAsString('Code',mParCode);
                  mParamBO.save;
                  mParamBO.free;
                end;
              end;
              mParamGroup_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid='+QuotedStr('OD4JP4GMMNRO5DTOIFTDVCLISC')+' and name='+Quotedstr(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].ParamGroupName')),'');
              if NxIsEmptyOID(mParamGroup_ID) then begin
                  mParamBO:=mOS.CreateObject('OD4JP4GMMNRO5DTOIFTDVCLISC');
                  mParamBO.new;
                  mParamBO.Prefill;
                  mParamBO.SetFieldValueAsString('Name',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].ParamGroupName'));
                  mParGroupcode:=mOS.SQLSelectFirstAsString('Select max(code) from defrolldata where clsid='+QuotedStr('OD4JP4GMMNRO5DTOIFTDVCLISC'),'');
                  mParGroupcode:=AnsiRightStr('000'+inttostr(StrToInt(AnsiRightStr(mParGroupcode,3))+1),3);
                  mParamBO.SetFieldValueAsString('Code',mParGroupcode);
                  mParamBO.save;
                  for j:=0 to mXMLHead.getElementsCountInArray('StoreCard['+inttostr(i)+'].Parameters.Parameter')-1 do begin
                     mParam_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid='+Quotedstr('KCAWICC3H2O4DG0YEDMLO4X0PK')+' and name='+QuotedStr(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Parameters.Parameter['+IntToStr(j)+'].ParamName')),'');
                     mGroupParamBO:=mOS.CreateObject('2TIIQXNXIXK4B5CZUIZ20K2W10');
                     mGroupParamBO.new;
                     mGroupParamBO.SetFieldValueAsString('X_parameter_ID',mParam_ID);
                     mGroupParamBO.SetFieldValueAsString('X_Rel_def','01');
                     mGroupParamBO.SetFieldValueAsString('X_Value_ID',mParamBO.OID);
                     mGroupParamBO.SetFieldValueAsString('X_posindex',AnsiRightStr('00'+inttostr(1+mOS.SQLSelectFirstAsInteger('Select count(id) from defrolldata where clsid='+Quotedstr('2TIIQXNXIXK4B5CZUIZ20K2W10')+' and x_rel_def='+quotedstr('01')+' and x_value_id='+Quotedstr(mParamBO.OID),0)),2));
                     mGroupParamBO.save;
                     mGroupParamBO.free;
                  end;
                  mParamBO.free;
              end;
              mParamGroup_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid='+QuotedStr('OD4JP4GMMNRO5DTOIFTDVCLISC')+' and name='+Quotedstr(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].ParamGroupName')),'');
              mBO.SetFieldValueAsString('X_ParamGroup_ID',mParamGroup_ID);
              mOS.SQLExecute('Delete from defrolldata where clsid='+Quotedstr('2TIIQXNXIXK4B5CZUIZ20K2W10')+' and x_rel_def='+quotedstr('03')+' and x_value_id='+Quotedstr(mBO.OID));
              for j:=0 to mXMLHead.getElementsCountInArray('StoreCard['+inttostr(i)+'].Parameters.Parameter')-1 do begin
                     mParam_ID:=mOS.SQLSelectFirstAsString('Select id from defrolldata where clsid='+Quotedstr('KCAWICC3H2O4DG0YEDMLO4X0PK')+' and name='+QuotedStr(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Parameters.Parameter['+IntToStr(j)+'].ParamName')),'');
                     mGroupParamBO:=mOS.CreateObject('2TIIQXNXIXK4B5CZUIZ20K2W10');
                     mGroupParamBO.new;
                     mGroupParamBO.SetFieldValueAsString('X_parameter_ID',mParam_ID);
                     mGroupParamBO.SetFieldValueAsString('X_Rel_def','03');
                     mGroupParamBO.SetFieldValueAsString('X_Value_ID',mbo.OID);
                     mGroupParamBO.SetFieldValueAsString('X_ParamValue',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Parameters.Parameter['+IntToStr(j)+'].ParamValue'));
                     mGroupParamBO.SetFieldValueAsString('X_posindex',AnsiRightStr('00'+inttostr(1+mOS.SQLSelectFirstAsInteger('Select count(id) from defrolldata where clsid='+Quotedstr('2TIIQXNXIXK4B5CZUIZ20K2W10')+' and x_rel_def='+quotedstr('03')+' and x_value_id='+Quotedstr(mBO.OID),0)),2));
                     mGroupParamBO.save;
                     mGroupParamBO.free;
              end;
            end;
            if mXMLHead.getElementsCountInArray('StoreCard['+inttostr(i)+'].RelatedProducts.RelatedProduct')>0 then begin
              mOS.SQLExecute('Delete from defrolldata where clsid='+Quotedstr('2TIIQXNXIXK4B5CZUIZ20K2W10')+' and x_rel_def='+quotedstr('02')+' and x_value_id='+Quotedstr(mBO.OID));
              for j:=0 to mXMLHead.getElementsCountInArray('StoreCard['+inttostr(i)+'].RelatedProducts.RelatedProduct')-1 do begin
                     mParam_ID:=mOS.SQLSelectFirstAsString('Select id from StoreCards where hidden='+Quotedstr('N')+' and name='+QuotedStr(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].RelatedProducts.RelatedProduct['+IntToStr(j)+'].Code')),'');
                    if not(NxIsEmptyOID(mParam_ID)) then begin
                     mGroupParamBO:=mOS.CreateObject('2TIIQXNXIXK4B5CZUIZ20K2W10');
                     mGroupParamBO.new;
                     mGroupParamBO.SetFieldValueAsString('X_StoreCard_ID',mParam_ID);
                     mGroupParamBO.SetFieldValueAsString('X_Rel_def','02');
                     mGroupParamBO.SetFieldValueAsString('X_Value_ID',mbo.OID);
                     mGroupParamBO.SetFieldValueAsString('X_posindex',AnsiRightStr('00'+inttostr(1+mOS.SQLSelectFirstAsInteger('Select count(id) from defrolldata where clsid='+Quotedstr('2TIIQXNXIXK4B5CZUIZ20K2W10')+' and x_rel_def='+quotedstr('02')+' and x_value_id='+Quotedstr(mBO.OID),0)),2));
                     mGroupParamBO.save;
                     mGroupParamBO.free;
                    end;
              end;
            end;
            mBO.save;
            mBO.free;
            mBO:=mOS.CreateObject(Class_StoreCard);
            mBO.Load(mStoreCard_ID,nil);
            if mXMLHead.getElementsCountInArray('StoreCard['+inttostr(i)+'].Pictures.Picture')>0 then begin
              mPictures:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Pictures'));
              for j:=0 to mPictures.count-1 do begin
                mPictures.BusinessObject[j].MarkForDelete;
              end;
              //mbo.save;
              for j:=0 to mXMLHead.getElementsCountInArray('StoreCard['+inttostr(i)+'].Pictures.Picture')-1 do begin
                 mImageFile:=cMainDir+'\'+mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Pictures.Picture['+IntToStr(j)+'].FileName');
                 if not(FileExists(mImageFile)) then begin
                   mFTP:= TFTP.Create;
                   mFTP.Host:=cURL;
                   mftp.UserName:=cLogin;
                   mFTP.Password:=cPass;
                   mftp.Connect;
                   mFTP.Passive:=true;
                   mFtp.ChangeDir('nejvetsi');
                   mFTP.TransferType:=ftBinary;
                   mftp.get(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Pictures.Picture['+IntToStr(j)+'].FileName'),mImageFile);
                   mFTP.Free;
                 end;
                 mPictures:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Pictures'));
                 mNewBO:=mPictures.AddNewObject;
                 mNewBO.SetFieldValueAsString('Picture_ID.PictureTitle',mBO.GetFieldValueAsString('Name'));
                 mNewBO.SetFieldValueAsBoolean('Picture_ID.ExternalFile',true);
                 mNewBO.SetFieldValueAsString('Picture_ID.PathAndFileName',mImageFile);
                 if mIntPosindex=0 then begin
                  mIntPosindex:=mOS.SQLSelectFirstAsInteger('select count(id) from storecardpictures where Parent_ID='+QuotedStr(mbo.OID)+' and not posindex=1',0);
                  mIntPosindex:=mIntPosindex+2;
                 end;
                 mNewBO.SetFieldValueAsInteger('PosIndex',mIntPosindex);
              end;
            end;

            mBO.save;
            mBO.free;
           except
            NxShowSimpleMessage(ExceptionMessage,mSite);
            WaitWin.Stop;
           end;
         end;
       WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(n));
       WaitWin.StepIt;
      end;
     WaitWin.Stop;
    end;
end;

begin
end.