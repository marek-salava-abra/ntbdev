uses 'eu.abra.matl.lipoelastic.inverzni_kusovnik.progress';

procedure InitSite_Hook(Self: TSiteForm);
Var
  mBut: TMultiAction;
begin
  mBut:=self.GetNewMultiAction;
  mBut.ShowControl:=True;
  mBut.ShowMenuItem:=True;
  mBut.Name:='multibutton';
  mBut.caption:='#NASTAVIT REŽIJNOST#';
  mBut.Items.Add('Režijní');
  mBut.Items.Add('NERežijní');
  mBut.category:='tabList';
  mBut.OnExecuteItem:=@TariffMaterialCheck;
end;

procedure TariffMaterialCheck(Sender: Tcomponent; Index:Integer);
Var
  msite:TSiteForm;
  mSClist:Tstringlist;
  i,j: integer;
  mBO, mPieceList:TNxCustomBusinessObject;
  mPlrows: TNxCustomBusinessMonikerCollection;
  mOS:TNxCustomObjectSpace;
  mResponse: integer;
begin
  msite:=TComponent(Sender).DynSite;
  mResponse:=NxMessageBox('', 'Chcete opravdu pokračovat?', mdConfirm, mdbYesNo, nil, nil, False, msite);

  if mResponse = mrNo then begin
    NxShowSimpleMessage('Dokončeno', msite);
    exit;
  end
  else begin
    mSClist:=Tstringlist.Create;
    mBO:=TDynSiteForm(msite).CurrentObject;
    if assigned(mBO) then begin
       mOS:=msite.BaseObjectSpace;
       mOS.SQLSelect('SELECT ID FROM PLMPieceLists A WHERE (A.ID IN (SELECT Y.Parent_ID '+
                    'FROM PLMPieceLists2 Y WHERE Y.Parent_ID=A.ID AND (Y.StoreCard_ID ='+QuotedStr(mBO.OID)+')) ) '+
                    'AND ((''N'' = ''A'') OR ((''N'' = ''N'') AND (A.Revided_ID IS NULL)) )',mSClist);
    end;
    mPieceList:=mOS.CreateObject(class_PLMPieceList);
    ProgressInit(mSite, 'Pracuji...', mSClist.count -1);
    FrmTeplomer(msite);
    for i:=0 to mSClist.count -1 do begin
      mPieceList.Load(mSClist[i],nil);
      mPLrows:=mPieceList.GetLoadedCollectionMonikerForFieldCode(mPieceList.GetFieldCode('Rows'));
      for j:=0 to mPlrows.Count-1 do begin
        if mPlrows.BusinessObject[j].GetFieldValueAsString('Storecard_ID.code')=mBO.GetFieldValueAsString('code') then begin
          if Index=0 then begin
            mPlrows.BusinessObject[j].SetFieldValueAsBoolean('X_TariffMaterial', True);
          end
          else if Index=1 then begin
            mPlrows.BusinessObject[j].SetFieldValueAsBoolean('X_TariffMaterial', False);
          end;
        end;
      end;
      mPieceList.Save;
      mPlrows.Free;
      ProgressSetPos(i);
    end;
  mPieceList.Free;
  ProgressDispose();
  end;
NxShowSimpleMessage('Dokončeno', msite);
end;

begin
end.