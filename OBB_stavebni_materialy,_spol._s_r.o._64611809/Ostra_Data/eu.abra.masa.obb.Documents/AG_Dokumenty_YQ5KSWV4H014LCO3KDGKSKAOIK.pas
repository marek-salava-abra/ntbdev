const
 cSaveDir = '\\tsclient\c\abra_dokumenty\';
 cServerSaveDir = '\\192.168.200.65\ABRA_DATA\INT_dokumenty\';
 cLoadDir = '\\tsclient\c\abra_dokumenty\import\';

procedure FormShow_Hook(Self: TSiteForm);
var
  aList: TActionList;
  i: Integer;
  mUser:TNxCustomBusinessObject;
begin
   if not(NxIsEmptyOID(NxGetActualUserID(self.BaseObjectSpace))) then begin
   mUser:=self.BaseObjectSpace.CreateObject(Class_SecurityUser);
   mUser.Load(NxGetActualUserID(self.BaseObjectSpace),nil);
       if not(mUser.GetFieldValueAsBoolean('U_Documents')) then begin
       aList := Self.GetMainActionList;
          for i:=0 to aList.ActionCount -1 do begin
            //NxShowSimpleMessage(alist.Actions[i].name,nil);
            if aList.Actions[i].Name = 'actSaveContents' then aList.Actions[i].Category := 'DISABLE';
            if aList.Actions[i].Name = 'actLockDocument' then aList.Actions[i].Category := 'DISABLE';
            if aList.Actions[i].Name = 'actUnlockDocument' then aList.Actions[i].Category := 'DISABLE';
            if aList.Actions[i].Name = 'actProcessDocument' then aList.Actions[i].Category := 'DISABLE';
            if aList.Actions[i].Name = 'actCreateDocument' then aList.Actions[i].Category := 'DISABLE';
          end;
      end;
  end;
end;




procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mPage: TTabSheet;
  mControl: TControl;
  mUserFormPage: TTabSheet;
  mUser:TNxCustomBusinessObject;
begin
  if not(NxIsEmptyOID(NxGetActualUserID(self.BaseObjectSpace))) then begin
  mUser:=self.BaseObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID(self.BaseObjectSpace),nil);
    if not(mUser.GetFieldValueAsBoolean('U_Documents')) then begin
        try
          mControl := NxFindChildControl(NxGetSiteAppForm(Self), 'tabContents');
          if Assigned(mControl) then TTabSheet(mControl).TabVisible := False;
        finally
        end;
    end;
  end;
end;

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mUser:TNxCustomBusinessObject;
begin
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Name := 'actSaveDocument';
    mAction.Caption := 'Uložit dokument';
    mAction.Hint := 'Uloží dokument do lokální složky';
    mAction.Category := 'tabList,tabDetail';
    mAction.OnExecute := @SaveDocument;
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Name := 'actCreateDocument';
    mAction.Caption := 'Vytvořit dokument';
    mAction.Hint := 'Vytvoří dokument z lokální složky';
    mAction.Category := 'tabList,tabDetail';
    mAction.OnExecute := @CreateDocument;
end;

Procedure SaveDocument(Sender:TComponent);
var
 mSite:TSiteForm;
 mBO, mContent:TNxCustomBusinessObject;
 mDocContents:TNxCustomBusinessMonikerCollection;
 i:integer;
 mFileName:string;
 mM: TMemoryStream;
begin
 mSite:=TComponent(Sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
   if not(DirectoryExists(cSaveDir)) then begin
      try
       if not(CreateDir(cSaveDir)) then NxShowSimpleMessage('Na vašem disku C:\ neexistuje adresář C:\abra_dokumenty\ a nepovedlo se ho ani vytvořit',mSite);
      except
       // ošetřit?
      end;
   end;
   if DirectoryExists(cSaveDir) then begin
    mDocContents:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Contents'));
    mFileName:=mDocContents.BusinessObject[0].GetFieldValueAsString('FileName');
    //Opravdu chcete uložit xxx ( název dle názvu souboru včetně koncovky ) do svého počítače
    if NxMessageBox('Dotaz','Opravdu chcete uložit '+mFileName+' do svého počítače?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
      mM:= TMemoryStream.Create;
      try
        if mDocContents.BusinessObject[0].GetFieldValueAsBoolean('ExternalFile') then
         mm.LoadFromFile(mDocContents.BusinessObject[0].GetFieldValueAsString('PathAndFileName'))
        else
         mM.SetBytes(mDocContents.BusinessObject[0].GetFieldValueAsBytes('Data_ID.BlobData'));
        mM.SaveToFile(cSaveDir+mFileName);
        NxShowSimpleMessage('Soubor byl úspěšně uložen do Vašeho počítače  C:\abra_dokumenty\'+mFileName,mSite);
      finally
        mM.Free;
      end;
    end;
   end;
 end;
end;

Procedure CreateDocument(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg:TOpenDialog;
 mFileName, mShortFileName, mDocumentType_ID, mDir:string;
 mDocBO, mDocContent :TNxCustomBusinessObject;
 mDocContents:TNxCustomBusinessMonikerCollection;
 mOS:TNxCustomObjectSpace;
begin
 mSite:=TComponent(Sender).DynSite;
 mOpenDlg := TOpenDialog.Create(Sender);
 if DirectoryExists(cLoadDir) then mOpenDlg.InitialDir:=cLoadDir;
 if mOpenDlg.Execute then begin
   mFileName:=mOpenDlg.FileName;
   mDocumentType_ID:='';
    if GetDocumentType_ID(mSite, mDocumentType_ID) then begin
     mDir:='';
     if not(NxIsEmptyOID(mDocumentType_ID)) then mDir:=mDocumentType_ID+'\';
     if not(DirectoryExists(cServerSaveDir+mDir)) then CreateDir(cServerSaveDir+mDir);
     if NxCopyFile(mFileName,cServerSaveDir+mDir+ExtractFileName(mFileName)) then begin
          mOS:=TDynSiteForm(mSite).BaseObjectSpace;
          mDocBO:=mOS.CreateObject(Class_Document);
          mDocBO.new;
          mDocBO.Prefill;
          mDocBO.SetFieldValueAsString('DocQueue_ID','~000000501');
          mDocBo.SetFieldValueAsString('Category_ID','5000000000');
          mdocBo.SetFieldValueAsString('Firm_ID', '1IA0000101');
          mDocBO.SetFieldValueAsString('U_DocumentTypeInt',mDocumentType_ID);
          mDocBo.SetFieldValueAsString('Description',AnsiLeftStr(ExtractFileName(mFileName),150));
          mDocContents:= mDocBO.GetLoadedCollectionMonikerForFieldCode(mDocBO.GetFieldCode('Contents'));
          mDocContent:= mDocContents.AddNewObject;
          mDocContent.SetFieldValueAsString('FileName',ExtractFileName(mFileName));
          mDocContent.SetFieldValueAsString('PathAndFileName',cServerSaveDir+mDir+ExtractFileName(mFileName));
          mDocContent.SetFieldValueAsBoolean('ExternalFile',true);
          mDocBO.save;
          TDynSiteForm(mSite).RefreshData;
          TDynSiteForm(mSite).ActiveDataSet.SeekID(mDocBO.oid);
          NxShowSimpleMessage('Založen dokument '+mDocBO.DisplayName,mSite);
          mDocBO.free;
      end;
  end;
 end;
end;

Function GetDocumentType_ID(var ASite : TSiteform; var aDocumentType_ID:string):Boolean;
var
    mLabel, mCbCCTemplate: TLabel;
    mAllowed:TStringList;
    mButOk, mButCancel : TButton;
    mResult, mCount : integer;
    mForm : TForm;
    mCBTemplate:TRollComboEdit;
    mED:TEdit;
 begin
 if ASite <> nil then begin
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 510;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Info:';
    mForm.OnCloseQuery:= @OnFormCloseAction;


    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Typ dokumentu:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCbCCTemplate:= TLabel.Create(mForm);
    mCbCCTemplate.Parent:= mForm;
    mCbCCTemplate.Left:= 236;
    mCbCCTemplate.Top:= (mCount*25)+12;
    mCbCCTemplate.Width:= 255;

    mCBTemplate:= TRollComboEdit.Create(mForm);
    mCBTemplate.Parent:= mForm;
    mCBTemplate.ClassID:= Roll_DocumentTypeInt;
    mCBTemplate.Complete:= True;
    mCBTemplate.Prefilling:= pmNone;
    mCBTemplate.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCBTemplate.Top:= (mCount*25)+10;
    mCBTemplate.Left:= 140;
    mCBTemplate.Width:= 80;
    mCBTemplate.ConnectedControl:= mCbCCTemplate;
    mCBTemplate.ConnectedControlField:= 'Name';



    mCount:= mCount+1;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Default:= true;
    mButOk.Caption := 'OK';
    mButOk.Top := (mCount*25)+20;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := (mCount*25)+20;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    mForm.Height:= (mCount*25)+95;

    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
         aDocumentType_ID:=mCBTemplate.DataText;
         Result:=True;
     end;
    mForm.free;
  end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;

begin
end.