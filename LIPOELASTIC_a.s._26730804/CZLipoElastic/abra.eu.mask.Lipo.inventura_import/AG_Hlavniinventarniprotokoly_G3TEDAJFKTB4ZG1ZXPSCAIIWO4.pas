uses 'abra.eu.mask.Lipo.inventura_import.Rows_RO',
     'abra.eu.mask.Lipo.inventura_import.fce' ,
     'abra.eu.mask.Lipo.inventura_import.lib'

;

const
    mFilter='*.xml';





procedure FormCreate_Hook(Self: TSiteForm);
var
mMAction: TMultiAction;
  mAction: TBasicAction;
  mAList: TActionList;
  mAct: TBasicAction;
  i:integer;
begin
  mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Uvolnění skladových dokladů';
          mMAction.Caption := 'Uvolnění skladových dokladů';
          mMAction.Items.Add('Uvolnění skladových dokladů');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @INMPOnExec;

          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Generování neinvenrtarizovaných položek';
          mMAction.Caption := 'Generování neinvenrtarizovaných položek';
          mMAction.Items.Add('Generování neinvenrtarizovaných položek');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @GenOnExec;


end;


procedure GenOnExec(Sender: TComponent;index:integer);
var
  mi:integer;
  mID_head_protocol:string;
  mr:tstringlist;
  msite:TSiteForm;
  mbo:TNxCustomBusinessObject;
  mbo_child,mbo_child_row,mRowBO:TNxCustomBusinessObject;
  mMainInvProtocolRow_ID:string;
  mpocet:double;
begin
 mSite := NxFindSiteForm(TComponent(Sender));
      mID_head_protocol:= tdynsiteform(msite).CurrentObject.oid;
      //NxShowSimpleMessage(mID_head_protocol,nil);
      mr:=TStringList.create;
      try
          mbo_child:=msite.BaseObjectSpace.CreateObject(Class_PartialInvProtocol);
          mbo_child.new;
          mbo_child.Prefill;
          mbo_child.SetFieldValueAsString('DocQueue_ID','1L20000101');
          mbo_child.SetFieldValueAsString('MainProtocol_ID',mID_head_protocol);
          mbo_child.SetFieldValueAsBoolean('AddRows',True);
          mbo_child.SetFieldValueAsString('Description','Generate');


         mbo_child.save;
          msite.BaseObjectSpace.SQLSelect('select HPR.id from MainInvProtocolRows HPR where HPR.parent_id=' + quotedstr(mID_head_protocol)

          + ' and (not exists (SELECT 1 FROM StoreCardMenuItemLinks SM where sm.Storecard_id=HPR.Storecard_ID and sm.StoreMenuItem_ID=''3XE0000101''))'


          ,mr);

       //   NxShowSimpleMessage(inttostr(mr.count),nil);

          if mr.count>0 then begin
             for i:=0 to mr.count-1 do begin


                    mbo:=msite.BaseObjectSpace.CreateObject('GMWHU0T5VA24512H254OBXCPBG');
                    try
                         mbo.load(mr.Strings[i],nil);
                         if mbo.GetFieldValueAsFloat('DocumentedQuantity') - mbo.GetFieldValueAsFloat('RealQuantity')>0 then begin
                        //    if true then begin

                                    //  NxShowSimpleMessage('Nahráno',nil);

                                      mMainInvProtocolRow_ID := iGetOrCreateMainInvProtocolRow_ID(msite.BaseObjectSpace, mbo_child.GetFieldValueAsString('MainProtocol_ID'),
                                                              mbo.GetFieldValueAsString('StoreCard_id'), mbo_child.GetFieldValueAsBoolean('AddRows'));
                                        //  NxShowSimpleMessage('Dohledano',nil);
                                          mRowBO := msite.BaseObjectSpace.CreateObject(Class_PartialInvProtocolRow);
                                          try
                                                 // NxShowSimpleMessage('Nový',nil);
                                                mRowBO.New;
                                                mRowBO.Prefill;
                                                mRowBO.SetFieldValueAsString('Parent_ID', mbo_child.oid);
                                                mRowBO.SetFieldValueAsString('MIPRow_ID', mMainInvProtocolRow_ID);

                                                mRowBO.SetFieldValueAsDateTime('TimeStamp$DATE',Now);
                                                 mpocet:=mbo.GetFieldValueAsFloat('DocumentedQuantity') - mbo.GetFieldValueAsFloat('RealQuantity');

                                                if (mRowBO.getFieldValueAsinteger('MIPRow_ID.Storecard_ID.Category')=1) or
                                                   (mRowBO.getFieldValueAsinteger('MIPRow_ID.Storecard_ID.Category')=2) then begin
                                                      // mRowBO.SetFieldValueAsBoolean('RealQuantityChanged',true);
                                                         mpocet:=mbo.GetFieldValueAsFloat('DocumentedQuantity') - mbo.GetFieldValueAsFloat('RealQuantity');
                                                         //mpocet:=5;
                                                           mRowBO.Save;
                                                           //  NxShowSimpleMessage('Šarže uložena',nil);
                                                           if mpocet<>0 then begin
                                                              mi:=msite.BaseObjectSpace.SQLExecute('update PartialInvProtocolRows set RealQuantity=' + NxFloatToIBStr(mpocet) + ',RealQuantityChanged='+quotedstr('A')+ ' where id=' + QuotedStr(mRowBO.oid));
                                                           end;

                                                end else begin
                                                       if mpocet<>0 then begin
                                                              mRowBO.SetFieldValueAsBoolean('RealQuantityChanged',true);
                                                       //mpocet:=5;
                                                              mRowBO.SetFieldValueAsFloat('RealQuantity',mpocet);
                                                       end;
                                                      mRowBO.Save;
                                                    //  NxShowSimpleMessage('Položka uložena',nil);
                                               end;



                                            finally
                                                mRowBO.free;
                                            end;
















                         end;
                    finally
                         mbo.free;
                    end;

              end;
          end;
      finally

      end;


   NxShowSimpleMessage('Operace ukončena',nil);
end;






procedure INMPOnExec(Sender: TComponent;index:integer);
var
  mi:integer;
begin
 mSite := NxFindSiteForm(TComponent(Sender));


   mi:=msite.baseobjectspace.SQLExecute('Update storedocuments set MasterDocCLSID=''00000000000000000000000000'',MasterDocument_ID=''0000000000'' where (documenttype=''25'' or documenttype=''26'') and MasterDocument_ID='
    + quotedstr(tdynsiteform(msite).CurrentObject.oid ));


end;












begin
end.
