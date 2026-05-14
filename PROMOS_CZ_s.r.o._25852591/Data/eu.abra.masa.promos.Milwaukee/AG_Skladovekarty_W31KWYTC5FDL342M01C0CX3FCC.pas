const
 cMainDir = '\\10.0.0.15\abra_images';
 cMainDir2 = '\\10.0.0.15\abra_images\dokumenty';
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
  mAction.Name := 'actImportMilwaukee';
  mAction.Caption := 'Import Milwaukee';
  mAction.Hint := 'Naimportuje EAN z XLS (pozor jen z prvního listu)';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportMilwaukee;
end;

Procedure ImportMilwaukee(sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 mNewBO, mUnitBO, mStoreCardBO:TNxCustomBusinessObject;
 mUnits, mPictures:TNxCustomBusinessMonikerCollection;
 i,j,k,l,m,n,o:integer;
 mOpenDlg:TOpenDialog;
 mExcel, mWB, mSheet: Variant;
 mEAN, mFileName, mStoreCard_ID:String;
 mOrigFile:string;
 mFtp:TFTP;
begin
  mSite:=TComponent(sender).BusRollSite;
  mOS:=mSite.BaseObjectSpace;
    mOpenDlg := TOpenDialog.Create(Sender);
    mOpenDlg.Title := 'Import z Excelu';
      mOpenDlg.Filter := 'Soubory aplikace Excel (*.xls, *.xlsx)| *.xls;*.xlsx';
      if mOpenDlg.Execute then begin
        try
          j:=0;
          mExcel := CreateOleObject('Excel.Application');
          mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
          mSheet := mWB.Sheets[1];
          n:=mSheet.UsedRange.Rows.Count;
           WaitWin.StartProgress('Čekejte, prosím ...', '',  n);
                 i:=2;          //doopravdy druhý řádek XLS
                   while i<n+1 do begin
                    mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 2])),'');
                    if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                      mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
                      mStoreCardBO.Load(mStoreCard_ID,nil);
                      mUnits:=mStoreCardBO.GetLoadedCollectionMonikerForFieldCode(mStoreCardBO.GetFieldCode('StoreUnits'));
                      mUnitBO:=mUnits.BusinessObject[0];
                      mUnitBO.SetFieldValueAsString('EAN',VarToStr(mSheet.Cells[i, 409]));
                      mUnitBO.SetFieldValueAsFloat('Width',NxibstrtoFloat(VarToStr(mSheet.Cells[i, 913])));
                      mUnitBO.SetFieldValueAsFloat('Height',NxibstrtoFloat(VarToStr(mSheet.Cells[i, 918])));
                      mUnitBO.SetFieldValueAsFloat('Depth',NxibstrtoFloat(VarToStr(mSheet.Cells[i, 905])));
                      mUnitBO.SetFieldValueAsInteger('SizeUnit',3);
                      mUnitBO.SetFieldValueAsFloat('Weight',NxibstrtoFloat(VarToStr(mSheet.Cells[i, 904])));
                      mUnitBO.SetFieldValueAsInteger('WeightUnit',1);
                      //NxShowSimpleMessage(mStoreCardBO.GetFieldValueAsString('Note')+#13#10+'_________________________________________________________'+VarToStr(mSheet.Cells[i, 417]),msite);
                       // pokud je prázdná kolekce obrázků tak založit obrázek z sloupce 3,36,37,38 stejně tak jak je na eshop
                       // sloupec 1 product PDF
                       //  sloupec 417 popis v html
                       // sloupec 409 je ean
                       // sloupec 904 hmotnost
                       // délka 905 šířka 913, 918 výška (v mm)
                      mPictures:=mStoreCardBO.GetLoadedCollectionMonikerForFieldCode(mStoreCardBO.GetFieldCode('Pictures'));
                      if mPictures.count=0 then begin
                         if not(NxIsBlank(VarToStr(mSheet.Cells[i, 3]))) then begin
                           mFileName:=API_GET_PIcture(VarToStr(mSheet.Cells[i, 3]));
                           if FileExists(mFileName) then begin
                              mNewBO:=mPictures.AddNewObject;
                              mNewBO.SetFieldValueAsString('Picture_ID.PictureTitle',mStoreCardBO.GetFieldValueAsString('Name'));
                              mNewBO.SetFieldValueAsBoolean('Picture_ID.ExternalFile',true);
                              mNewBO.SetFieldValueAsString('Picture_ID.PathAndFileName',mFileName);
                           end;
                         end;
                         if not(NxIsBlank(VarToStr(mSheet.Cells[i, 36]))) then begin
                           mFileName:=API_GET_PIcture(VarToStr(mSheet.Cells[i, 36]));
                           if FileExists(mFileName) then begin
                              mNewBO:=mPictures.AddNewObject;
                              mNewBO.SetFieldValueAsString('Picture_ID.PictureTitle',mStoreCardBO.GetFieldValueAsString('Name'));
                              mNewBO.SetFieldValueAsBoolean('Picture_ID.ExternalFile',true);
                              mNewBO.SetFieldValueAsString('Picture_ID.PathAndFileName',mFileName);
                           end;
                         end;
                         if not(NxIsBlank(VarToStr(mSheet.Cells[i, 37]))) then begin
                           mFileName:=API_GET_PIcture(VarToStr(mSheet.Cells[i, 37]));
                           if FileExists(mFileName) then begin
                              mNewBO:=mPictures.AddNewObject;
                              mNewBO.SetFieldValueAsString('Picture_ID.PictureTitle',mStoreCardBO.GetFieldValueAsString('Name'));
                              mNewBO.SetFieldValueAsBoolean('Picture_ID.ExternalFile',true);
                              mNewBO.SetFieldValueAsString('Picture_ID.PathAndFileName',mFileName);
                           end;
                         end;
                         if not(NxIsBlank(VarToStr(mSheet.Cells[i, 38]))) then begin
                           mFileName:=API_GET_PIcture(VarToStr(mSheet.Cells[i, 38]));
                           if FileExists(mFileName) then begin
                              mNewBO:=mPictures.AddNewObject;
                              mNewBO.SetFieldValueAsString('Picture_ID.PictureTitle',mStoreCardBO.GetFieldValueAsString('Name'));
                              mNewBO.SetFieldValueAsBoolean('Picture_ID.ExternalFile',true);
                              mNewBO.SetFieldValueAsString('Picture_ID.PathAndFileName',mFileName);
                           end;
                         end;
                        if not(NxIsBlank(VarToStr(mSheet.Cells[i, 1]))) then begin
                          mFileName:='KT_'+mStoreCardBO.GetFieldValueAsString('Code')+'.pdf';
                          mOrigFile:=API_GET_PDF(VarToStr(mSheet.Cells[i, 1]),mFileName);
                          if not(DirectoryExists(cMainDir2+'\'+mStoreCardBO.oid)) then CreateDir(cMainDir2+'\'+mStoreCardBO.oid);
                              NxCopyFile(mOrigFile,cMainDir2+'\'+mStoreCardBO.oid+'\'+mFileName);
                              mStoreCardBO.SetFieldValueAsString('X_Product_Sheet_Filename',mFileName);
                              mStoreCardBO.SetFieldValueAsString('X_Product_Sheet_name','Produktový list');
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
                               NxShowSimpleMessage(ExceptionMessage,mSite);
                             end;
                        end;
                      end;
                      mStoreCardBO.SetFieldValueAsString('Note',VarToStr(mSheet.Cells[i, 417]));
                      mStoreCardBO.save;
                      j:=j+1;
                    end;
                    WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(n));
                    WaitWin.StepIt;
                    inc(i);
                   end;

                mWB.Close;
        finally
         WaitWin.Stop;
        end;

       NxShowSimpleMessage('Nahráno '+IntToStr(j)+' objektů z celkového počtu '+IntToStr(n-1)+'.',mSite);
    end;
end;

function API_GET_PIcture(AURL:string;): String;
var
  mWinHTTP: Variant;
  mFileName: string;
  mResponse:TMemoryStream;
  mLastSlash:Integer;
begin
  try
    Result:='';
    mLastSlash:=NxCharPosR('/',AURL);
    mFileName:=Copy(AURL,mLastSlash+1,100);
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('GET', AURL);
    mWinHTTP.Send('');
    if mWinHTTP.Status=200 then begin
      mResponse:=TMemoryStream.create;
      mResponse.setBytes(mWinHTTP.responsebody);
      mResponse.SaveToFile(NxGetTempDir+mFileName);
      Result:=NxGetTempDir+mFileName;
    end;
  except
    if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Při GET dotazu nastala neočekávaná chyba: '+ExceptionMessage);
  end;
end;
function API_GET_PDF(AURL, aFileName:string;): String;
var
  mWinHTTP: Variant;
  mFileName: string;
  mResponse:TMemoryStream;
  mLastSlash:Integer;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('GET', AURL);
    mWinHTTP.Send('');
    if mWinHTTP.Status=200 then begin
      mResponse:=TMemoryStream.create;
      mResponse.setBytes(mWinHTTP.responsebody);
      mResponse.SaveToFile(NxGetTempDir+aFileName);
      Result:=NxGetTempDir+aFileName;
    end;
  except
    if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Při GET dotazu nastala neočekávaná chyba: '+ExceptionMessage);
  end;
end;


begin
end.