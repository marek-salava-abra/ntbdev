const
 cMainDir = '\\10.0.0.15\abra_images';
 cMainDir2 = '\\10.0.0.15\abra_images\dokumenty';
 cURL = 'server.eline.cz';
 cPass = 'xqUogyHQC8_8';
 cLogin = 'elinewebabra';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAct: TBasicAction;
begin
  mAct := Self.GetNewAction;
  mAct.Caption := '##B2B název##';
  mAct.Category := 'tabList';
  mAct.OnExecute := @B2BName;

  mAct := Self.GetNewAction;
  mAct.Caption := '##Obrázek hromadně##';
  mAct.Category := 'tabList';
  mAct.OnExecute := @AddPicture;

  mAct := Self.GetNewAction;
  mAct.Caption := '##Produktový list##';
  mAct.Hint := 'Jede od druhého řádku, struktura kód;URL';
  mAct.Category := 'tabList';
  mAct.OnExecute := @AddSheet;

  mAct := Self.GetNewAction;
  mAct.Caption := '##Seřadit obrázky na kartě##';
  mAct.Category := 'tabList';
  mAct.OnExecute := @SortPictures;

  mAct := Self.GetNewAction;
  mAct.Caption := '##EAN-EAN##';
  mAct.Category := 'tabList';
  mAct.OnExecute := @SetWeight;
end;

Procedure SortPictures(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 i,j:Integer;
 mStoreCard_ID:string;
 mPictures:TNxCustomBusinessMonikerCollection;
 mBO:TNxCustomBusinessObject;
begin
  mSite:=TComponent(Sender).BusRollSite;
  mList:=TStringList.Create;
  mOS:=mSite.BaseObjectSpace;
  TBusRollSiteForm(mSite).List.GetSelectedId(mList);
  if mlist.Count>0 then begin
     WaitWin.StartProgress('Čekejte, prosím ...', '', mList.count);
     for i:=0 to mlist.count-1 do begin
        mStoreCard_ID:=mOs.SQLSelectFirstAsString('select parent_id from storecardpictures where parent_id='+QuotedStr(mlist.strings[i])+' group by parent_id, posindex having count(*)>1','');
        if not(NxIsEmptyOID(mStoreCard_ID)) then begin
          mBO:=mOS.CreateObject(Class_StoreCard);
          mBO.Load(mStoreCard_ID,nil);
          mPictures:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Pictures'));
          for j:=0 to mPictures.count-1 do begin
            mPictures.BusinessObject[j].SetFieldValueAsInteger('PosIndex',j+1);
          end;
          mbo.save;
          mbo.free;
        end;
        WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mList.count));
        WaitWin.StepIt;
     end;
     WaitWin.Stop;
  end;
end;

Procedure AddSheet(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mOpenDlg : TOpenDialog;
 mList:TStringList;
 i:Integer;
 mBO:TNxCustomBusinessObject;
 mCode, mURL, mTempStr, mStoreCard_ID, mFileName,mOrigFile:string;
 mWinHTTP: Variant;
 mStream:TMemoryStream;
 mFtp:TFTP;
begin
  mSite:=TComponent(Sender).BusRollSite;
  mOS:=mSite.BaseObjectSpace;
  mOpenDlg := TOpenDialog.Create(Sender);
  if mOpenDlg.Execute then begin
     mList:=TStringList.Create;
     mList.LoadFromFile(mOpenDlg.FileName);
     WaitWin.StartProgress('Čekejte, prosím ...', '', mList.count);
     for i:=1 to mlist.count-1 do begin
        mTempStr:=mList.strings[i];
        mCode:=NxTrapStrTrim(mTempStr,';');
        mURL:=NxTrapStrTrim(mTempStr,';');
        mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden='+QuotedStr('N')+' and code='+QuotedStr(mCode),'');
        if not(NxIsEmptyOID(mStoreCard_ID)) then begin
          mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
          mWinHTTP.Open('GET', mURL);
          mWinHTTP.Send('');
          if mWinHTTP.Status=200 then begin
           if mWinHTTP.GetResponseHeader('Content-Type')='application/pdf' then begin
             mBO:=mOS.CreateObject(Class_StoreCard);
             mBO.Load(mStoreCard_ID,nil);
             mStream:=TMemoryStream.Create;
             mStream.SetBytes(mWinHTTP.ResponseBody);
             mfileName:='c:\ABRA_logs\pdf\'+mCode+'.pdf';
             mOrigFile:='c:\ABRA_logs\pdf\'+mCode+'.pdf';
             mStream.SaveToFile(mFileName);
              mFileName:=Copy(mFileName,NxCharPosR('\',mFileName)+1,300);
              mFileName:=TEncoding.RemoveDiacritics(mFileName);
              mFileName:=NxSearchReplace(mFileName,' ','_',[srAll]);
              mFileName:='KT_'+mbo.GetFieldValueAsString('Code')+'_'+mFileName;
              if not(DirectoryExists(cMainDir2+'\'+mBO.oid)) then CreateDir(cMainDir2+'\'+mBO.oid);
                  NxCopyFile(mOrigFile,cMainDir2+'\'+mBO.oid+'\'+mFileName);
                  mbo.SetFieldValueAsString('X_Product_Sheet_Filename',mFileName);
                  mbo.SetFieldValueAsString('X_Product_Sheet_name','Produktový list');
                  try
                   mFTP:= TFTP.Create;
                   mFTP.Host:=cURL;
                   mftp.UserName:=cLogin;
                   mFTP.Password:=cPass;
                   mftp.Connect;
                   mFTP.Passive:=true;
                   mFtp.ChangeDir('prilohy');
                   mFTP.TransferType:=ftBinary;
                   mftp.Put(mOrigFile,mfileName);
                   mFTP.Free;
                 except
                   //NxShowSimpleMessage(ExceptionMessage,mSite);
                 end;
               mbo.save;
               mBO.free;
           end;
          end;
        end;
      WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mList.count));
      WaitWin.StepIt;
    end;
    WaitWin.Stop;
  end;
end;


Procedure AddPicture(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 i,j,k, mResult:integer;
 mBO, mNewBO:TNxCustomBusinessObject;
 mPictures:TNxCustomBusinessMonikerCollection;
 mSelectedList:TStringList;
 mOpenDlg : TOpenDialog;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mSelectedList:=TStringList.Create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mSelectedList);
 if mSelectedList.Count>0 then begin
   if NxMessageBox('Dotaz','Přejete si přidat obrázek k '+IntToStr(mSelectedList.count)+' kartám?' , mdConfirm, mdbYesNo, 0, 0, False, mSite)= mrYes then begin
     mOpenDlg := TOpenDialog.Create(Sender);
     if mOpenDlg.Execute then begin
       mResult:=NxMessageBox('Dotaz','Smazat obrázky před nahráním?' , mdConfirm, mdbYesNo, 0, 0, False, mSite);
       for i:=0 to mSelectedList.count-1 do begin
         mBO:=mOS.CreateObject(Class_StoreCard);
         mBO.Load(mSelectedList.Strings[i],nil);
         mPictures:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Pictures'));
         if mResult=mrYes then begin
           for j:=0 to mPictures.Count-1 do begin
             mPictures.BusinessObject[j].MarkForDelete;
           end;
         end;
         mNewBO:=mPictures.AddNewObject;
         mNewBO.SetFieldValueAsString('Picture_ID.PictureTitle',mBO.GetFieldValueAsString('Name'));
         mNewBO.SetFieldValueAsBoolean('Picture_ID.ExternalFile',true);
         mNewBO.SetFieldValueAsString('Picture_ID.PathAndFileName',mOpenDlg.FileName);
         if mBO.NeedSave then mbo.save;
         mBO.free;
       end;
     end;
     TBusRollSiteForm(mSite).RefreshData;
     TBusRollSiteForm(mSite).DataSet.SeekID(mSelectedList.Strings[i]);
     NxShowSimpleMessage('Hotovo.',mSite);
   end;
 end;
end;

Procedure B2BName(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 i,j,k, mResult:integer;
 mBO, mUnitBO:TNxCustomBusinessObject;
 mUnits:TNxCustomBusinessMonikerCollection;
 mSelectedList:TStringList;
 mMOQ:Extended;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mSelectedList:=TStringList.Create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mSelectedList);
 if mSelectedList.Count>0 then begin
   if NxMessageBox('Dotaz','Přejete změnit minimální B2B název na '+IntToStr(mSelectedList.count)+' kartách?' , mdConfirm, mdbYesNo, 0, 0, False, mSite)= mrYes then begin
              k:=mSelectedList.Count;
              WaitWin.StartProgress('Čekejte, prosím ...', '', k);
              for i:=0 to mSelectedList.Count-1 do begin
                mBO:=mOS.CreateObject(Class_StoreCard);
                mBO.Load(mSelectedList.Strings[i],nil);
                mBO.SetFieldValueAsString('X_Name_B2B',NxSearchReplace(mbo.GetFieldValueAsString('Name'),'"','',[srAll]));
                mBO.save;
                mBO.free;
                WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
                WaitWin.StepIt;
              end;
              WaitWin.Stop;
              TBusRollSiteForm(mSite).RefreshData;
              TBusRollSiteForm(mSite).DataSet.SeekID(mSelectedList.Strings[i]);
              NxShowSimpleMessage('Provedeno',mSite);
   end;
 end;
end;

Procedure SetWeight(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mOpenDlg : TOpenDialog;
 mList:TStringList;
 i,j:Integer;
 mBO, mUnitBO:TNxCustomBusinessObject;
 mCode, mWeight, mTempStr, mStoreCard_ID, mUnitID:string;
 mUnits:TNxCustomBusinessMonikerCollection;
begin
  mSite:=TComponent(Sender).BusRollSite;
  mOS:=mSite.BaseObjectSpace;
  mOpenDlg := TOpenDialog.Create(Sender);
  if mOpenDlg.Execute then begin
     mList:=TStringList.Create;
     mList.LoadFromFile(mOpenDlg.FileName);
     WaitWin.StartProgress('Čekejte, prosím ...', '', mList.count);
     for i:=0 to mlist.count-1 do begin
        mTempStr:=mList.strings[i];
        mCode:=NxTrapStrTrim(mTempStr,';');
        mWeight:=NxTrapStrTrim(mTempStr,';');
        mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden='+QuotedStr('N')+' and code='+QuotedStr(mCode),'');
        if not(NxIsEmptyOID(mStoreCard_ID)) then begin
          mBO:=mOS.CreateObject(Class_StoreCard);
          mBO.load(mStoreCard_ID,nil);
          mUnits:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('StoreUnits'));
          for j:=0 to mUnits.count-1 do begin
           if munits.BusinessObject[j].GetFieldValueAsString('Code')=mBO.GetFieldValueAsString('MainUnitCode') then
             munits.BusinessObject[j].SetFieldValueAsString('EAN',mWeight);
          end;
          mbo.save;
          mbo.free;
        end;
      WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mList.count));
      WaitWin.StepIt;
    end;
    WaitWin.Stop;
  end;
end;

begin
end.