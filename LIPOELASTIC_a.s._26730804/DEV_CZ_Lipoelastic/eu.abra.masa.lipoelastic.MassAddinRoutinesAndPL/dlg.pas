var
 mIssues, mUnits:TStringList;
 mCbStoreCard:TRollComboEdit;
 mStoreCardBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mMainUnit:integer;
 mIssueCB, mUnitsCB:TComboBox;
 mMainUnitCode:string;
 mIsProduct:Boolean;

Function GetDataForPLMPiecelist(var ASite : TSiteform; var aStorecard_ID, aStore_ID, aPhase_ID: String;var aQuantity:Extended;var aQUnit:string;var aIssue, aResult, aUsePhases:integer;):boolean;
var
 mButOk, mButCancel : TButton;
 mResult, mCount : integer;
 mForm : TForm;
 mLabel, mCbCcStoreCard, mCbCcStore, mCBCcPhase:TLabel;
 mCbStore, mCbPhase:TRollComboEdit;
 mNumEd:TNumEdit;
begin
 if ASite <> nil then begin
    mOS:=ASite.BaseObjectSpace;
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 510;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Údaje pro doplnění materiálu:';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mUnits:=TStringList.create;
    mIssues:=TStringList.create;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Skladová karta:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCbCcStoreCard:= TLabel.Create(mForm);
    mCbCcStoreCard.Parent:= mForm;
    mCbCcStoreCard.Left:= 236;
    mCbCcStoreCard.Top:= (mCount*25)+12;
    mCbCcStoreCard.Width:= 255;

    mCbStoreCard:= TRollComboEdit.Create(mForm);
    mCbStoreCard.Parent:= mForm;
    mCbStoreCard.ClassID:= Roll_StoreCards;
    mCbStoreCard.Complete:= True;
    mCbStoreCard.Prefilling:= pmNone;
    mCbStoreCard.TextField:= 'Code';  // položka podle které se bude vyhledávat TPOperation_ID
    mCbStoreCard.Top:= (mCount*25)+10;
    mCbStoreCard.Left:= 140;
    mCbStoreCard.Width:= 80;
    mCbStoreCard.OnExit:=@SetComboBoxes;
    mCbStoreCard.ConnectedControl:= mCbCcStoreCard;
    mCbStoreCard.ConnectedControlField:= 'Name';

    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Množství:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mNumEd := TNumEdit.Create(mForm);
    mNumEd.Left := 140;
    mNumEd.Top := (mCount*25)+10;
    mNumEd.Width := 80;
    mNumEd.Value := aQuantity;
    mNumEd.DecimalPlaces := 3;
    mNumEd.Parent := mForm;

    mUnitsCB:= TComboBox.Create(mForm);
    mUnitsCB.Parent:=mForm;
    mUnitsCB.Left := 227;
    mUnitsCB.Top := (mCount*25)+10;
    mUnitsCB.Width := 80;
    mUnitsCB.Text := '';

    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Výdej:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mIssueCB:= TComboBox.Create(mForm);
    mIssueCB.Parent:=mForm;
    mIssueCB.Left := 140;
    mIssueCB.Top := (mCount*25)+10;
    mIssueCB.Width := 80;
    mIssueCB.Text := '';

    mCount:= mCount+1;

    if not(aUsePhases=2) then begin

      mLabel := TLabel.Create(mForm);
      mLabel.Parent := mForm;
      mLabel.Caption := 'Etapa:';
      mLabel.Top := (mCount*25)+12;
      mLabel.Left := 17;
      mLabel.Height := 13;
      mLabel.Width := 100;
      mLabel.Font.Size := 10;

      mCbCCPhase:= TLabel.Create(mForm);
      mCbCCPhase.Parent:= mForm;
      mCbCCPhase.Left:= 236;
      mCbCCPhase.Top:= (mCount*25)+12;
      mCbCCPhase.Width:= 255;

      mCbPhase:= TRollComboEdit.Create(mForm);
      mCbPhase.Parent:= mForm;
      mCbPhase.ClassID:= Roll_PLMPhase;
      mCbPhase.Complete:= True;
      mCbPhase.Prefilling:= pmNone;
      mCbPhase.TextField:= 'Code';  // položka podle které se bude vyhledávat TPOperation_ID
      mCbPhase.Top:= (mCount*25)+10;
      mCbPhase.Left:= 140;
      mCbPhase.Width:= 80;
      mCbPhase.ConnectedControl:= mCbCCPhase;
      mCbPhase.ConnectedControlField:= 'Name';

      mCount:= mCount+1;

    end;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Sklad:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCbCcStore:= TLabel.Create(mForm);
    mCbCcStore.Parent:= mForm;
    mCbCcStore.Left:= 236;
    mCbCcStore.Top:= (mCount*25)+12;
    mCbCcStore.Width:= 255;

    mCbStore:= TRollComboEdit.Create(mForm);
    mCbStore.Parent:= mForm;
    mCbStore.ClassID:= Roll_Stores;
    mCbStore.Complete:= True;
    mCbStore.Prefilling:= pmNone;
    mCbStore.TextField:= 'Code';  // položka podle které se bude vyhledávat TPOperation_ID
    mCbStore.Top:= (mCount*25)+10;
    mCbStore.Left:= 140;
    mCbStore.Width:= 80;
    mCbStore.ConnectedControl:= mCbCcStore;
    mCbStore.ConnectedControlField:= 'Name';

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
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := (mCount*25)+20;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    mForm.Height:= (mCount*25)+95;

    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
         aResult:=1;
         Result:=true;
         aStorecard_ID:=mCbStoreCard.DataText;
         aQuantity:=mNumEd.value;
         aQUnit:=mUnitsCB.Text;
         aIssue:=mIssueCB.ItemIndex;
         aStore_ID:=mCbStore.DataText;
         aPhase_ID:=mCbPhase.DataText;
     end;
    mForm.free;
  end;
end;

Function GetDataForPLMRoutine(var ASite : TSiteform; var aPosindex, aResult:integer; var aPhase_ID, aSalaryClass_ID, aWorkplace_ID, aName:string;
                              var aTAC, aTBC:Extended; var aTACUnit, aTBCUnit, aUsePhases: integer;var aKOO, aFinish: boolean; ):Boolean;
var
    mLabel, mCbCCOperation, mCbCCPhase, mCbCCWorkplace, mCbCCSalaryClass: TLabel;
    mEd1:TEdit;
    mNumEd, mTACEd, mTBCEd:TNumEdit;
    mButOk, mButCancel : TButton;
    mResult, mCount : integer;
    mForm : TForm;
    mCbOperation, mCbPhase, mCbWorkPlace, mCbSalaryClass: TRollComboEdit;
    mCBTACunit, mCBTBCunit:TComboBox;
    mUnits:TStringList;
    mBEd01, mBEd02:TCheckBox;
 begin
 if ASite <> nil then begin
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 510;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Údaje pro doplnění operace:';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mUnits:=TStringList.Create;
    mUnits.add('s');
    mUnits.add('min');
    mUnits.add('h');

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Pořadí operace:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mNumEd := TNumEdit.Create(mForm);
    mNumEd.Left := 140;
    mNumEd.Top := (mCount*25)+10;
    mNumEd.Width := 80;
    mNumEd.Value := aPosindex;
    mNumEd.DecimalPlaces := 0;
    mNumEd.Parent := mForm;

    mCount:= mCount+1;

    {mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Operace z číselníku:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCbCCOperation:= TLabel.Create(mForm);
    mCbCCOperation.Parent:= mForm;
    mCbCCOperation.Left:= 236;
    mCbCCOperation.Top:= (mCount*25)+12;
    mCbCCOperation.Width:= 255;

    mCbOperation:= TRollComboEdit.Create(mForm);
    mCbOperation.Parent:= mForm;
    mCbOperation.ClassID:= 'FIFQOFWLL0E4XIOR1WVITR4KSK';
    mCbOperation.Complete:= True;
    mCbOperation.Prefilling:= pmNone;
    mCbOperation.TextField:= 'Code';  // položka podle které se bude vyhledávat TPOperation_ID
    mCbOperation.Top:= (mCount*25)+10;
    mCbOperation.Left:= 140;
    mCbOperation.Width:= 80;
    mCbOperation.ConnectedControl:= mCbCCOperation;
    mCbOperation.ConnectedControlField:= 'Name';

    mCount:= mCount+1;
    }

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Název operace:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mEd1 := TEdit.Create(mForm);
    mEd1.Left := 140;
    mEd1.Top := (mCount*25)+10;
    mEd1.Width := 300;
    mEd1.Text := '';
    mEd1.Parent := mForm;

    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'TAC:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mTACEd := TNumEdit.Create(mForm);
    mTACEd.Left := 140;
    mTACEd.Top := (mCount*25)+10;
    mTACEd.Width := 80;
    mTACEd.Value := aTAC;
    mTACEd.DecimalPlaces := 2;
    mTACEd.Parent := mForm;

    mCBTACunit:= TComboBox.Create(mForm);
    mCBTACunit.Parent:=mForm;
    mCBTACunit.Left := 227;
    mCBTACunit.Top := (mCount*25)+10;
    mCBTACunit.Width := 50;
    mCBTACunit.Text := '';
    mCBTACunit.Items:=mUnits;
    mCBTACunit.ItemIndex:=1;

    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'TBC:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mTBCEd := TNumEdit.Create(mForm);
    mTBCEd.Left := 140;
    mTBCEd.Top := (mCount*25)+10;
    mTBCEd.Width := 80;
    mTBCEd.Value := aTBC;
    mTBCEd.DecimalPlaces := 2;
    mTBCEd.Parent := mForm;

    mCBTBCunit:= TComboBox.Create(mForm);
    mCBTBCunit.Parent:=mForm;
    mCBTBCunit.Left := 227;
    mCBTBCunit.Top := (mCount*25)+10;
    mCBTBCunit.Width := 50;
    mCBTBCunit.Text := '';
    mCBTBCunit.Items:=mUnits;
    mCBTBCunit.ItemIndex:=1;

    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Kooperace:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mBEd01:= TCheckBox.Create(mForm);
    mBEd01.Left := 140;
    mBEd01.Top := (mCount*25)+10;
    mBEd01.Checked := false;
    mBEd01.Parent := mForm;

    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Ukončující:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mBEd02:= TCheckBox.Create(mForm);
    mBEd02.Left := 140;
    mBEd02.Top := (mCount*25)+10;
    mBEd02.Checked := false;
    mBEd02.Parent := mForm;

    mCount:= mCount+1;

    if not(aUsePhases=2) then begin

      mLabel := TLabel.Create(mForm);
      mLabel.Parent := mForm;
      mLabel.Caption := 'Etapa:';
      mLabel.Top := (mCount*25)+12;
      mLabel.Left := 17;
      mLabel.Height := 13;
      mLabel.Width := 100;
      mLabel.Font.Size := 10;

      mCbCCPhase:= TLabel.Create(mForm);
      mCbCCPhase.Parent:= mForm;
      mCbCCPhase.Left:= 236;
      mCbCCPhase.Top:= (mCount*25)+12;
      mCbCCPhase.Width:= 255;

      mCbPhase:= TRollComboEdit.Create(mForm);
      mCbPhase.Parent:= mForm;
      mCbPhase.ClassID:= Roll_PLMPhase;
      mCbPhase.Complete:= True;
      mCbPhase.Prefilling:= pmNone;
      mCbPhase.TextField:= 'Code';  // položka podle které se bude vyhledávat TPOperation_ID
      mCbPhase.Top:= (mCount*25)+10;
      mCbPhase.Left:= 140;
      mCbPhase.Width:= 80;
      mCbPhase.ConnectedControl:= mCbCCPhase;
      mCbPhase.ConnectedControlField:= 'Name';

      mCount:= mCount+1;

    end;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Tarifní třída:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCbCCSalaryClass:= TLabel.Create(mForm);
    mCbCCSalaryClass.Parent:= mForm;
    mCbCCSalaryClass.Left:= 236;
    mCbCCSalaryClass.Top:= (mCount*25)+12;
    mCbCCSalaryClass.Width:= 255;

    mCbSalaryClass:= TRollComboEdit.Create(mForm);
    mCbSalaryClass.Parent:= mForm;
    mCbSalaryClass.ClassID:= Roll_PLMSalaryClasse;
    mCbSalaryClass.Complete:= True;
    mCbSalaryClass.Prefilling:= pmNone;
    mCbSalaryClass.TextField:= 'Code';  // položka podle které se bude vyhledávat TPOperation_ID
    mCbSalaryClass.Top:= (mCount*25)+10;
    mCbSalaryClass.Left:= 140;
    mCbSalaryClass.Width:= 80;
    mCbSalaryClass.ConnectedControl:= mCbCCSalaryClass;
    mCbSalaryClass.ConnectedControlField:= 'Code';

    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Pracoviště:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCbCCWorkplace:= TLabel.Create(mForm);
    mCbCCWorkplace.Parent:= mForm;
    mCbCCWorkplace.Left:= 236;
    mCbCCWorkplace.Top:= (mCount*25)+12;
    mCbCCWorkplace.Width:= 255;

    mCbWorkPlace:= TRollComboEdit.Create(mForm);
    mCbWorkPlace.Parent:= mForm;
    mCbWorkPlace.ClassID:= Roll_PLMWorkPlaces;
    mCbWorkPlace.Complete:= True;
    mCbWorkPlace.Prefilling:= pmNone;
    mCbWorkPlace.TextField:= 'Code';  // položka podle které se bude vyhledávat TPOperation_ID
    mCbWorkPlace.Top:= (mCount*25)+10;
    mCbWorkPlace.Left:= 140;
    mCbWorkPlace.Width:= 80;
    mCbWorkPlace.ConnectedControl:= mCbCCWorkplace;
    mCbWorkPlace.ConnectedControlField:= 'Name';

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
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := (mCount*25)+20;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    mForm.Height:= (mCount*25)+95;

    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
         aResult:=1;
         aPosindex:=trunc(mNumEd.Value);
         //aOperation_ID:=mCbOperation.DataText;
         aName:=mEd1.Text;
         aTAC:=mTACEd.value;
         aTACUnit:=mCBTACunit.ItemIndex;
         aTBC:=mTBCEd.value;
         aTBCUnit:=mCBTBCunit.ItemIndex;
         Result:=true;
         aPhase_ID:=mCbPhase.DataText;
         aWorkplace_ID:=mCbWorkPlace.DataText;
         aSalaryClass_ID:=mCbSalaryClass.DataText;
         aKOO:=mBEd01.Checked;
         aFinish:=mBEd02.Checked;
     end;
    mForm.free;
  end;
end;

Procedure SetComboBoxes(Sender:TRollComboEdit);
begin
   if not(NxIsEmptyOID(mCbStoreCard.DataText)) then begin
     mOS.SQLSelect('Select code from storeunits where parent_id='+QuotedStr(mCbStoreCard.DataText),mUnits);
     mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
     mStoreCardBO.Load(mCbStoreCard.DataText, nil);
     mIsProduct:=mStoreCardBO.GetFieldValueAsBoolean('IsProduct');
     mMainUnitCode:=mStoreCardBO.GetFieldValueAsString('MainUnitCode');
     mMainUnit:=mUnits.IndexOf(mMainUnitCode);
     mUnitsCB.Items:=mUnits;
     mUnitsCB.ItemIndex:=mMainUnit;
     if mIsProduct then begin
       mIssues.add('Sklad');
       mIssues.add('Výroba');
       mIssues.add('Kooperace');
       mIssues.add('Spotřební materiál');
       mIssues.add('Informativní');
     end else begin
       mIssues.add('Sklad');
       mIssues.add('Kooperace');
       mIssues.add('Spotřební materiál');
       mIssues.add('Informativní');
     end;
     mIssueCB.Items:=mIssues;
     mIssueCB.ItemIndex:=0;
     mStoreCardBO.free;
   end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;

function FxCompanyParameters_Get(var mOS:TNxCustomObjectSpace; var AGUID: string): Integer;
var
  mContext: TNxContext;
  mCompanyCache: TNxCompanyCache;
begin
  mContext := NxCreateContext(mOS);
  try
    mCompanyCache := mContext.GetCompanyCache;
    Result := mCompanyCache.GetParameterValue(AGUID);
    mCompanyCache := nil;
  finally
    mContext.Free;
  end;
end;

begin
end.