uses '_GlobalSettings.konstanty';


  Var
mbo:TNxCustomBusinessObject;
mr:tstringlist;
mID:string;


  procedure iFillStores(AOS : TNxCustomObjectSpace; AList : Tstrings);
  const
    cSQL = 'SELECT Code FROM BusOrders WHERE Hidden=''N'' ORDER BY Code';
  begin
    AOS.SQLSelect(cSQL, AList);
  end;



procedure RowOperationOnExecute(Sender: TAction);
var
  mSite : TSiteForm;
  mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  cbStores : TComboBox;
  mRg : TRadioGroup;
  mRbS, mRbA : TRadioButton;
  mBookmark : TNxBookmarkList;
  mDBGrid : TMultiGrid;
  mActualRow : TBookmark;
  i ,j: integer;
  mBO, mBO_PohybSarze, mBO_Sarze : TNxCustomBusinessObject;
  mMon : TNxCustomBusinessMonikerCollection;
  mQuantity_pomoc,mpocet,mQuantityUsed, mSiciDavka:double;
  mr:tstringlist;
  mID_Sarze:string;
  mBatch_name,mBatch_name_pomoc:string;
  mbatch_number:integer;
  mxx:TStringList;
  mi:integer;
begin
 mSite := NxFindSiteForm(Sender);

        mBO := TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject;
        mMon := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
        for i := 0 to mMon.Count - 1 do begin
          //NxShowSimpleMessage(IntToStr(mMon.BusinessObject[i].getFieldValueAsInteger('Storecard_ID.category')),msite);
          //mMon.BusinessObject[i].SetFieldValueAsString('BusOrder_ID', iGetIDByCode(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.ObjectSpace, 'BusOrders', cbStores.Text));
          if mMon.BusinessObject[i].getFieldValueAsInteger('Storecard_ID.category')=2 then begin
               //NxShowSimpleMessage('Sarže',msite);
               mQuantity_pomoc:=mMon.BusinessObject[i].GetFieldValueAsFloat('quantity')*mMon.BusinessObject[i].GetFieldValueAsFloat('unitrate');
               mSiciDavka:=(mMon.BusinessObject[i].getFieldValueAsfloat('Storecard_ID.X_Davka_sici'));
               mr:= tstringlist.create;
               try
                    msite.BaseObjectSpace.SQLSelect('Select sum(a.X_quantity) from DefRollData A WHERE A.CLSID = ' + quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') +
                    ' AND (A.X_parent_id =' + QuotedStr(mMon.BusinessObject[i].OID) + ')' ,mr);
                    if mr.count>0 then begin
                        mQuantityUsed:=NxIBStrToFloat(mr.strings[0])
                        end else begin
                            mQuantityUsed:=0;
                        end;
                    mpocet:=(mQuantity_pomoc-mQuantityUsed);
                    if mQuantity_pomoc>mQuantityUsed then begin
                         mBatch_name_pomoc:=copy(mMon.BusinessObject[i].getFieldValueAsstring('Storecard_ID.EAN'),8,5) +FormatDateTime('YY',mbo.GetFieldValueAsDateTime('DocDate$Date')) +
                         RightStr('00' + inttostr(strtoint(FormatDateTime('MM',mbo.GetFieldValueAsDateTime('DocDate$Date'))) + GenMoveBatches),2);
                         mxx:=tstringlist.create;
                         try
                             mSite.BaseObjectSpace.SQLSelect('Select substring(name,10,3) from StoreBatches where substring(name,1,9) = ' + QuotedStr(mBatch_name_pomoc) + ' order by name desc',mxx);
                             if mxx.count>0 then begin
                                      //NxShowSimpleMessage(mxx.Strings[0],nil);
                                      mbatch_number:=strtoint(mxx.Strings[0])+1;
                             end else begin
                                      mbatch_number:=1;
                             end;
                         finally
                             mxx.free;
                         end;

                         // dogenerování šarží
                         for j:=0 to trunc((mQuantity_pomoc-mQuantityUsed)/mSiciDavka) do begin
                             mBO_Sarze:=msite.BaseObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
                             try
                                   mID_Sarze:='';
                                   mBO_Sarze.new;
                                   mBO_Sarze.Prefill;
                                   mBO_Sarze.SetFieldValueAsString('StoreCard_ID',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID'));


                                   mBO_Sarze.SetFieldValueAsString('X_parent_ID',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.X_parent_ID'));
                                   mBO_Sarze.SetFieldValueAsString('Name',mBatch_name_pomoc + (RightStr('00000' + inttostr(mbatch_number + j),3)));
                                   mBO_Sarze.SetFieldValueAsString('Specification',mBatch_name_pomoc);
                                   mBO_Sarze.SetFieldValueAsString('X_Specifikace_order',copy(mMon.BusinessObject[i].GetFieldValueAsString('X_ExternalSpecification'),1,80));  //    mBO.GetFieldValueAsString('ExternalNumber')
                                   mBO_Sarze.SetFieldValueAsString('X_Verze',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.X_parent_ID.X_verze'));
                                   mBO_Sarze.SetFieldValueAsBoolean('SerialNumber',False);
                                   mBO_Sarze.SetFieldValueAsDateTime('ProductionDate$DATE',Now);
//                                   mBO_Sarze.SetFieldValueAsDateTime('X_CreatedDate$date',Now);
                                  if not mBO_Sarze.GetFieldValueAsInteger('StoreCard_ID.ExpirationDue')=0 then
                                   mBO_Sarze.SetFieldValueAsDateTime('ExpirationDate$Date',NxIncDate(Now,mBO_Sarze.GetFieldValueAsInteger('StoreCard_ID.ExpirationDue'),0,0)) ;   //1096
                                  //mBO_Sarze.SetFieldValueAsDateTime('ExpirationDate$DATE',Now+1095);

                                  if not(nxisemptyoid(mbo.GetFieldValueAsString('U_Client'))) then
                                     mBO_Sarze.SetFieldValueAsString('U_Client',mbo.GetFieldValueAsString('U_Client'));

                                   // **** materiálové složení  *****
                                                    mBO_Sarze.SetFieldValueAsString('X_MAT1',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.X_MAT1'));
                                                    mBO_Sarze.SetFieldValueAsString('X_MAT2',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.X_MAT2'));
                                                    mBO_Sarze.SetFieldValueAsString('X_MAT3',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.X_MAT3'));
                                                    mBO_Sarze.SetFieldValueAsString('X_MAT4',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.X_MAT4'));
                                                    mBO_Sarze.SetFieldValueAsString('X_MAT5',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.X_MAT5'));
                                   //                                   mBO_Sarze.SetFieldValueAsString('MAT6',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.X_MAT6'));
                                                    mBO_Sarze.SetFieldValueAsInteger('X_MAT1_PROC',mMon.BusinessObject[i].GetFieldValueAsInteger('Storecard_ID.X_MAT1_PROC'));
                                                    mBO_Sarze.SetFieldValueAsInteger('X_MAT2_PROC',mMon.BusinessObject[i].GetFieldValueAsInteger('Storecard_ID.X_MAT2_PROC'));
                                                    mBO_Sarze.SetFieldValueAsInteger('X_MAT3_PROC',mMon.BusinessObject[i].GetFieldValueAsInteger('Storecard_ID.X_MAT3_PROC'));
                                                    mBO_Sarze.SetFieldValueAsInteger('X_MAT4_PROC',mMon.BusinessObject[i].GetFieldValueAsInteger('Storecard_ID.X_MAT4_PROC'));
                                                   mBO_Sarze.SetFieldValueAsInteger('X_MAT5_PROC',mMon.BusinessObject[i].GetFieldValueAsInteger('Storecard_ID.X_MAT5_PROC'));
                                   //                                   mBO_Sarze.SetFieldValueAsInteger('X_MAT6_PROC',mMon.BusinessObject[i].GetFieldValueAsInteger('Storecard_ID.X_MAT6_PROC'));



                                   mBO_Sarze.Save;
                                   mID_Sarze:=mBO_Sarze.oid;
                             finally
                                  mBO_Sarze.free;
                             end;
                             mBO_PohybSarze:=msite.BaseObjectSpace.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
                             try
                                    mBO_PohybSarze.new;
                                    mBO_PohybSarze.Prefill;
                                    if mpocet>=mSiciDavka then begin
                                        mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',mSiciDavka);
                                        mpocet:=mpocet-mSiciDavka;
                                    end else begin
                                        mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',mpocet);
                                    end;
                                    mBO_PohybSarze.SetFieldValueAsstring('Code',mBO.OID);
                                    mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mMon.BusinessObject[i].OID);
                                    mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mBO.GetFieldValueAsString('Firm_ID'));
                                    mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID'));
                                    mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mID_Sarze);
                                    mBO_PohybSarze.SetFieldValueAsstring('Name',
                                    copy(mbo.GetFieldValueAsString('Docqueue_ID.code') + '-' + inttostr(mbo.GetFieldValueAsinteger('Ordnumber')) + '/' + mbo.GetFieldValueAsString('Period_ID.code') +
                                     ' - ' + mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.name'),1,40));
                                    //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));

                                    if mBO_PohybSarze.getFieldValueAsFloat('X_quantity')>0 then mBO_PohybSarze.save;
                                    //NxShowSimpleMessage('pohyb šarže',nil);
                             finally
                                 mBO_PohybSarze.free;
                             end;
                         end;
                    end else begin
                         if mQuantity_pomoc<mQuantityUsed then NxShowSimpleMessage('Chyba, je generováno víc šarží, než je na dokladu',nil);

                    end;
               finally
                    mr.free;
               end;


          end;
//  mStore

        end;



end;









procedure FormCreate_Hook(Self: TSiteForm);
var

  mAction: TBasicAction;
  i: integer;
  mAct: TBasicAction;
begin


end;




function iGetIDByCode(AOS : TNxCustomObjectSpace; const ATableName : string; ACode : string) : TNxOID;
const
  cSQL = 'SELECT ID FROM %s WHERE Code=''%s'' AND Hidden=''N''';
var
  mR : TStrings;
begin
  Result := '';
  mR := TStringlist.Create;
  try
    AOS.SQLSelect(Format(cSQL, [ATableName, ACode]), mR);
    if mR.Count > 0 then
      Result := mR.strings[0];
  finally
    mR.Free;
  end;
end;

procedure ShowSelectedDynForm(AForm: TDynSiteForm; AOIDs: TStrings; AFormCLSID: string; ASelCaption: string);
var
  mPars: TNxParameters;
  mParameter: TNxParameter;
begin
  if AOIDs.Count> 0 then begin
    mPars := TNxParameters.Create;
    try
      mPars.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := ASelCaption;
      mParameter := mPars.NewFromDataType(dtList, '_DefaultSelection', pkUnknown);
      mParameter := mParameter.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown) ;
      mParameter := mParameter.AsList.NewFromDataType(dtList, 'ID', pkUnknown);
      mParameter.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 3;
      mParameter.AsList.NewFromDataType(dtString, 'VALUELIST', pkUnknown).AsString := NxStringsTockListStr(AOIDs);
      AForm.ShowDynForm(AFormCLSID, mPars, nil, True, '');
    finally
      mPars.Free;
    end;
  end ;
end ;


procedure ShowPohybItem(Sender: Tcomponent; Index: integer);
var
    mBO: TNxCustomBusinessObject;
    i,x : integer;
  mSite: TSiteForm;
  mbookmark:TBookmarkList;
  mdbgrid:TDBGrid;
  mstring:string;
  mWeight:double;
  mBoolean:Boolean;
   mTabList: TTabSheet;
   mMon:TNxCustomBusinessMonikerCollection;
   mFnetto,mFObal,mfBrutto:double;
   mr2:tstringlist;
   mtext:string;
   mFilter:string;
begin
    if Sender is TComponent then begin
       mSite := NxFindSiteForm(Sender);

          if Assigned(mSite) and (mSite is TDynSiteForm) then begin
                    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
                    if mTabList = nil then RaiseException('tabList nenalezen');
                    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
                    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
                     mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                                  mr2:=tstringlist.create;
              try

                                    if mBookmark.count=0 then begin
                                                mBO := TDynSiteForm(mSite).CurrentObject;


                                                mMon := mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
                                                for x:=0 to mMon.count-1 do begin

                                                      mr2.add(mMon.BusinessObject[x].OID);
                                                end;

                                    end else begin
                                       for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                                mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                                       mBO := TDynSiteForm(mSite).CurrentObject;
                                                        mMon := mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
                                                           for x:=0 to mMon.count-1 do begin
                                                                mr2.add(mMon.BusinessObject[x].OID);
                                                          end;
                                        end;
                                    end;

                                    mtext:='Pohyby na OP' ;

                                                if mr2.count>0 then begin
                                                   //if index=0 then begin
                                                         mFilter:= '';
                                                         for i:= 0 to mr2.Count - 1 do begin
                                                            mFilter:= mFilter + Format('''%s'',', [mr2[i]]);
                                                                if mFilter <> '' then begin
                                                                  mFilter:= copy(mFilter, 1, Length(mFilter) - 1);
                                                                end;
                                                         end;
                                                          //msite.ShowSite('T2FWDKF0NSSOBC2KLELLUBPBXW',true,'FilterByUserDynSQLCondition;A.ID in (' + mFilter + ') ');
                                                          ShowSelectedDynForm(tdynsiteform(msite), mr2, 'T2FWDKF0NSSOBC2KLELLUBPBXW', mtext);    // objednávka
                                                  // end;

                                                end else begin
                                                    NxShowSimpleMessage('Pro doklad nebyly nalezeny pohyby.',nil);
                                                end;




                           finally
                               mr2.free;
                           end;



          end;
    end;
end;

















procedure ShowParameterItem(Sender: Tcomponent; Index: integer);
var
 L : TStringList;
 mid:string;
 mPars:TNxParameters;
 mPar:TNxParameter;
 msite:TDynSiteForm;
 mr2:TStringList;
 mMon : TNxCustomBusinessMonikerCollection;
 mStrings:string;
 i:integer;
 mtext:string;
 mfilter:string;
begin
 mSite := TComponent(sender).DynSite;


                                          mbo:=TDynSiteForm(mSite).CurrentObject;
                                          mtext:='Pohyby šarží ' ;


                                           mr2:=TStringList.create;
                                           try
                                               mbo.ObjectSpace.SQLSelect('SELECT distinct a.id as hodnota FROM DefRollData A where A.CLSID=' + quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') +
                                                ' and a.code='+quotedstr(mbo.oid) ,mr2);

                                                if mr2.count>0 then begin
                                                   if index=0 then begin
                                                         mFilter:= '';
                                                         for i:= 0 to mr2.Count - 1 do
                                                            mFilter:= mFilter + Format('''%s'',', [mr2[i]]);
                                                          if mFilter <> '' then begin
                                                            mFilter:= copy(mFilter, 1, Length(mFilter) - 1);
                                                          msite.ShowSite('RFGU0E1AJ5OOBEZCAPI2CPRHDS',true,'FilterByUserDynSQLCondition;A.ID in (' + mFilter + ') ');
                                                        end;
                                                   end;

                                                end else begin
                                                    NxShowSimpleMessage('Pro doklad nebyly vygenerovány šarže.',nil);
                                                end;



                                           finally
                                              mr2.free;
                                           end;




end;


  {
Vyvoláva sa po vykonaní inicializácie agendy/formulára. V tomto okamihu je už na formulári dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
{
        mAction := Self.GetNewAction;
        mAction.ShowControl := True;
        mAction.ShowMenuItem := True;
        mAction.Caption := 'Generování šarží';
        mAction.Hint := 'Generování šarží';
        mAction.Category := 'tablist,tabdetail';
        mAction.OnExecute := @RowOperationOnExecute;


  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Pohyby šarží';
  mMAction.Hint := 'Pohyby šarží';
  mMAction.Category := 'tablist,tabdetail';
  mMAction.OnExecuteItem := @ShowParameterItem;
  mMAction.Items.Add('Šarže');

  }

  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Pohyby na OP';
  mMAction.Hint := 'Pohyby na OP';
  mMAction.Category := 'tablist,tabdetail';
  mMAction.OnExecuteItem := @ShowPohybItem;
  mMAction.Items.Add('Pohyb');
end;



begin
end.