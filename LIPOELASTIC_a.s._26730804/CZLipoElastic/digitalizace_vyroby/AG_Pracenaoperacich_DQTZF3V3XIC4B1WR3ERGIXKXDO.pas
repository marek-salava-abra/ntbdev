uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse';



var
mBookmark : TBookmarkList;
mMachine_ID:string;
mWorker_ID:string;
mOperace_ID:string;
mTicket:string;



{
Vyvolává se po načtení vlastností formuláře.
}
procedure LoadingProperties_Hook(Self: TSiteForm; AParams: TNxParameters);
begin

end;

procedure Machine(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mSite: TDynSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i:integer;
   mForm: TDynSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
begin
 // mtext:='Description=' + quotedstr('');
  msite:=TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mbo:= TDynSiteForm(mSite).CurrentObject;
    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);
    ProgressInit(msite, 'Načtení souboru ' , 100);
    NxShowSimpleMessage(mMachine_ID,nil);

    if mBookmark.count=0 then begin
               //if index=0 then begin
                              NxShowSimpleMessage(TDynSiteForm(mSite).CurrentObject.oid,nil);

              mMachine_ID:='AAA';
    end else begin
         for i := 0 to mBookmark.Count- 1 do begin
         ProgressSetPos(1+NxFloor((i/mBookmark.Count)*99), inttostr(i) +' z '+inttostr(mBookmark.Count));
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

         end;
    end;
ProgressDispose()

end;










Function CheckMaterial(msite:TDynSiteForm; mOperace_OD:string):boolean;
var
mr:tstringlist;
i:integer;
begin
// Kompetence
     mr:=TStringList.create;
          try
                 msite.BaseObjectSpace.SQLSelect('Select id from PLMJORoutinesMat where Parent_ID=' + quotedstr(mOperace_OD),mr);
                 if mr.count>0 then begin
                  //mBO_Materials:=msite.BaseObjectSpace.CreateObject('');
                  for i:=0 to mr.count-1  do begin
                        //mBO_Materials.load(mr.strings[i],nil);
                        //NxShowSimpleMessage('Vyzásobení materiálem ' + mBO_Materials.GetFieldValueAsString('Storecard_ID.Name'),nil);

                  end;
                     ///// nxshowsimplememes 'Material'
                 end;

          finally
              mr.free;
          end;

End;


Function CheckCompetence(msite:TDynSiteForm;mOperace_OD:string;mWorker_ID:string):boolean;
var
mr,mr1:tstringlist;
i,ii:integer;
mCompetence:boolean;
begin
 // kompetence
 mCompetence:=true;
          mr:=TStringList.create;
          mr1:=TStringList.create;
          try
                 msite.BaseObjectSpace.SQLSelect('Select Competence_ID from PLMJORoutinesRequireSkills where Parent_ID=' + quotedstr(mOperace_OD),mr);

                 if mr.count>0 then begin

                        for i:=0 to mr.count-1  do begin
                               mr1:=TStringList.create;
                               try
                                     msite.BaseObjectSpace.SQLSelect('Select id from PLMJORoutinesRequireSkills where mWorker_ID=' + quotedstr(mWorker_ID) + ' and Competence_ID=' + QuotedStr(mr.strings[i]),mr1);
                                     if mr1.count=0 then begin
                                               mCompetence:=false;
                                     end;
                               finally
                                   mr1.free;
                               end;
                       end;


                      //// '02MRKHKMUDHO3AWNGD1MKWHEC0 '
                      //  NxShowSimpleMessage('Kontrola kompetence  ' + mBO_Materials.GetFieldValueAsString('Storecard_ID.Name'),nil);

                 end;
          result:=mCompetence;


          finally
              mr.free;
          end;
end;





procedure Listek(Sender: TMultiAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mSite: TDynSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i,ii:integer;
   mForm: TDynSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mBoolean:Boolean;
   mBoTicket:TNxCustomBusinessObject;
   mBoOperation,mBoJobOrder,mBOUzel,mBOListek,mBOOperace,mBO_Materials:TNxCustomBusinessObject;
   mMonVyrpolozky:TNxCustomBusinessMonikerCollection;
   mr,mr1,mxx:tstringlist;
   mJobOrder_ID:string;
   mOperation_ID:string;
begin
 // mtext:='Description=' + quotedstr('');
  msite:=TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mbo:= TDynSiteForm(mSite).CurrentObject;
    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);





    mJobOrder_ID:='3030000101';
    mJobOrder_ID:= TDynSiteForm(msite).CurrentObject.oid;

  //  mMachine_ID:='F360000101';

  //  mWorker_ID:='1100000101';



    if mWorker_ID='' then GetWorker_ID(msite);
    if mMachine_ID='' then GetMachine_ID(msite);


   mBOTicket:=msite.BaseObjectSpace.CreateObject('XTVGL0IK2F14PDPCEHMYNWX4T4');
   try
              mBoolean:=true;
              if index=0 then begin
                  if mJobOrder_ID='' then mBoolean:=InputQuery('Výrobní úloha', 'úloha', mJobOrder_ID);
                      if mBoolean then begin

                          mBoJobOrder:=msite.BaseObjectSpace.CreateObject('HTI3OTLGNRPO32EEISEPC0XZ0K');  // výrobní příkaz
                          try
                              mBoJobOrder.load(mJobOrder_ID,nil);

                                mr:=tstringlist.create;
                                try
                                    msite.BaseObjectSpace.SQLSelect('SELECT Routines.id ' +
                                                                    'FROM PLMJobOrders A ' +
                                                                    'join PLMJONodes N on N.Parent_ID = A.ID ' +
                                                                    'JOIN PLMJOOutputItems MI ON N.ID = MI.Owner_ID ' +
                                                                    'join PLMJobOrdersRoutines Routines on Routines.Parent_ID=MI.ID ' +
                                                                    ' where A.id=' + quotedstr(mJobOrder_ID) + ' And Routines.Ongoing=' + quotedstr('N') +
                                                                    'order by mi.id,Routines.Phase_ID,Routines.PosIndex', mr) ;

                                    //NxShowSimpleMessage('Počet Operací ' + inttostr(mr.count) ,nil);

                                    mBOOperace:=msite.BaseObjectSpace.CreateObject('HRKADG42X2H4BJ2RL5KUAUG3PK');   // výrobní uzel
                                    try
                                         // for i:=0 to mr.count-1 do begin
                                              mBOOperace.load(mr.Strings[i],nil);

                                              if  mBOOperace.GetFieldValueAsinteger('PosIndex')>1 then begin    // první operace

                                                  mxx:=tstringlist.create;
                                                  try
                                                       msite.BaseObjectSpace.SQLSelect('SELECT po.id ' +
                                                                    'FROM PLMJobOrders A ' +
                                                                    'join PLMJONodes N on N.Parent_ID = A.ID ' +
                                                                    'JOIN PLMJOOutputItems MI ON N.ID = MI.Owner_ID ' +
                                                                    'join PLMJobOrdersRoutines Routines on Routines.Parent_ID=MI.ID ' +
                                                                    'join PLMOperations PO on po.JobOrdersRoutines_ID=Routines.id ' +
                                                                    ' where A.id=' + quotedstr(mJobOrder_ID) + ' And Routines.Ongoing=' + quotedstr('N') +
                                                                    ' and po.FinishedAt$DATE =0 and Routines.PosIndex=' + inttostr(mBOOperace.GetFieldValueAsinteger('PosIndex')-1) +
                                                                    'order by mi.id,Routines.Phase_ID,Routines.PosIndex', mxx) ;
                                                        if mxx.count>0 then begin
                                                            NxShowSimpleMessage('Na předchozí operaci jsou ještě nedokončené lístky',nil);
                                                            exit;
                                                        end;
                                                  finally
                                                      mxx.free;
                                                  end;



                                              end;


                                              // předochozí opearace

                                              if mBOOperace.GetFieldValueAsString('WorkPlace_ID')<>mMachine_ID then begin
                                                 //NxShowSimpleMessage(mBOOperace.GetFieldValueAsString('WorkPlace_ID'),nil);
                                                 NxShowSimpleMessage('Operace není určena pro tento stroj' + mBOOperace.GetFieldValueAsString('WorkPlace_ID')+' ' + mMachine_ID ,nil);
                                              end else begin

                                                 mr1:=tstringlist.create;
                                                 msite.BaseObjectSpace.SQLSelect('select id from PLMOperations where JobOrdersRoutines_ID=' + quotedstr(mBOOperace.oid) + ' and FinishedAt$DATE =0',mr1);
                                                 mBOListek:=msite.BaseObjectSpace.CreateObject('XTVGL0IK2F14PDPCEHMYNWX4T4');
                                                 try
                                                       if mr1.count>0 then begin
                                                             //NxShowSimpleMessage('Lístek existuje',nil);
                                                             mBOListek.load(mr1.strings[0],nil);
                                                             if (mBOListek.getFieldValueAsString('PerformedBy_ID')<>mWorker_ID) or
                                                                   (mBOListek.getFieldValueAsString('WorkPlace_ID')<>mMachine_ID) then begin  // lístek není určen pro osobu a stroj
                                                                       mBoolean:=InputQuery('Na operaci pracuje', mBOListek.GetFieldValueAsString('PerformedBy_ID.WorkerName') +
                                                                            '  na stroji ' + mBOListek.GetFieldValueAsString('WorkPlace_ID.Name') +
                                                                            ' Chcete předchozí lístek ukončit a začít nový','');
                                                                       if mBoolean then begin         // při rozpracovaném lístku ukončení a založení
                                                                             mBOListek.SetFieldValueAsDateTime('FinishedAt$DATE',now);
                                                                             mBOListek.SetFieldValueAsFloat('TotalTime',SecondOfTheHour(mBOListek.getFieldValueAsDateTime('FinishedAt$DATE')-mBOListek.getFieldValueAsDateTime('StartedAt$DATE')));
                                                                             mBOListek.save;




                                                                             mBOListek.new;
                                                                                 mBOListek.prefill;
                                                                                 mBOListek.SetFieldValueAsString('JobOrdersRoutines_ID',mBOOperace.oid);
                                                                                 mBOListek.SetFieldValueAsString('PerformedBy_ID',mWorker_ID);
                                                                                 mBOListek.SetFieldValueAsString('WorkPlace_ID',mMachine_ID);
                                                                                 mBOListek.SetFieldValueAsDateTime('StartedAt$DATE',now);
                                                                                 mBOListek.SetFieldValueAsString('SalaryClass_ID','2000000101');
                                                                                 //mBOListek.SetFieldValueAsString('FinishedAt$DATE','');
                                                                                 //mBOListek.SetFieldValueAsString('HourlyRate ','');

                                                                                 //mBOListek.SetFieldValueAsString('Quantity','');
                                                                                 //mBOListek.SetFieldValueAsString('SalaryClass_ID','');
                                                                                 //mBOListek.SetFieldValueAsString('TotalTAC','');
                                                                                 //mBOListek.SetFieldValueAsString('TotalTBC','');
                                                                                 //mBOListek.SetFieldValueAsString('TotalTime','');

                                                                              mBOListek.save;
                                                                       end;

                                                             end else begin         // ukončení lístku
                                                                       mBOListek.SetFieldValueAsDateTime('FinishedAt$DATE',now);
                                                                       mBOListek.SetFieldValueAsFloat('TotalTime',SecondOfTheHour(mBOListek.getFieldValueAsDateTime('FinishedAt$DATE')-mBOListek.getFieldValueAsDateTime('StartedAt$DATE')));
                                                                  mBOListek.save;
                                                                  mBOOperace.SetFieldValueAsBoolean('Ongoing',true);
                                                                  mBOOperace.save;

                                                             end;


                                                       end else begin
                                                             //NxShowSimpleMessage('Lístek neexistuje',nil);
                                                             mBOListek.new;
                                                             mBOListek.prefill;



                                                             // kompetence



                                                             // materiál

                                                                   mBOListek.SetFieldValueAsString('JobOrdersRoutines_ID',mBOOperace.oid);
                                                                   mBOListek.SetFieldValueAsString('PerformedBy_ID',mWorker_ID);
                                                                   mBOListek.SetFieldValueAsString('WorkPlace_ID',mMachine_ID);
                                                                   mBOListek.SetFieldValueAsDateTime('StartedAt$DATE',now);
                                                                   mBOListek.SetFieldValueAsString('SalaryClass_ID','2000000101');
                                                                   //mBOListek.SetFieldValueAsString('FinishedAt$DATE','');
                                                                   //mBOListek.SetFieldValueAsString('HourlyRate ','');

                                                                   //mBOListek.SetFieldValueAsString('Quantity','');
                                                                   //mBOListek.SetFieldValueAsString('SalaryClass_ID','');
                                                                   //mBOListek.SetFieldValueAsString('TotalTAC','');
                                                                   //mBOListek.SetFieldValueAsString('TotalTBC','');
                                                                   //mBOListek.SetFieldValueAsString('TotalTime','');

                                                                   mBOListek.save;




                                                       end;
                                                 finally
                                                     mBOListek.free;
                                                 end;

                                              end;

                                         // end;
                                    finally
                                         mBOUzel.free;
                                    end;
                                finally
                                    mr.free;
                                end;
                          finally
                               mBoJobOrder.free;
                          end;

                          //mBOTicket.new;
                          //mBOTicket.save;
                      end;

                  //end else begin
                  //    NxShowSimpleMessage('Nebyla ukončena předchozí operace z BO ' ,nil);
                      //mBOTicket.load(
                  //end;
              end;

              if index=1 then begin
                  if mOperace_ID='' then begin
                      mBoolean:=InputQuery('Zadejte operaci k ukončení', 'Operace', mOperace_ID);
                      if mBoolean then begin
                          //mBOTicket.load();
                          //mBOTicket.save;
                      end;

                  end else begin
                      NxShowSimpleMessage('Ukončit běžící operaci',nil);
                      mOperace_ID:='';
                      //mBOTicket.load(
                  end;
              end;






   finally
       mBOTicket.free;
   end;




end;



procedure Operator(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mSite: TDynSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i:integer;
   mForm: TDynSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mOLE, mRoll, mOResult, _ss: Variant;
   mID:string;
begin
 // mtext:='Description=' + quotedstr('');
  msite:=TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mbo:= TDynSiteForm(mSite).CurrentObject;
    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);
     mB_Result:=InputQuery('Přihlášení operátora', 'Identifikace :', mWorker_ID);
       if mB_Result then begin
          mB_Result:=InputQuery('Plán kam', 'Identifikace :', mMachine_ID);
             if mB_Result then begin
                      mOLE := GetAbraOLEApplication;
                            mroll := mOLE.GetAgenda('MHMY3UH1D3Z4T1DKS4XLO3HHKC');
                             //mRoll.Params.Add('@X_Parent_ID=' + quotedstr(mMachine_ID) );
                                   _ss := mOLE.CreateStrings;
                                   mID := mroll.SingleSelectFromSelected2(_ss, 'Vybrat umístění', '');


                    mB_Result:=InputQuery('Umístit', 'Cílové pracoviště :', mID);
             end;
      end;

end;





procedure Material(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mSite: TDynSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i:integer;
   mForm: TDynSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
begin
 // mtext:='Description=' + quotedstr('');
  msite:=TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mbo:= TDynSiteForm(mSite).CurrentObject;
    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);
    ProgressInit(msite, 'Načtení souboru ' , 100);
    NxShowSimpleMessage(mMachine_ID,nil);

    if mBookmark.count=0 then begin
               //if index=0 then begin
                              NxShowSimpleMessage(TDynSiteForm(mSite).CurrentObject.oid,nil);

              mMachine_ID:='AAA';
    end else begin
         for i := 0 to mBookmark.Count- 1 do begin
         ProgressSetPos(1+NxFloor((i/mBookmark.Count)*99), inttostr(i) +' z '+inttostr(mBookmark.Count));
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

         end;
    end;
ProgressDispose()

end;



function GetWorker_ID(msite:TDynSiteForm):string;
var
    mBoolean:Boolean;
    mOlWorker_ID:string;
begin
    mOlWorker_ID:=mWorker_ID;
    mBoolean:=InputQuery('Přihlášení pracovníka', 'Nový pracovník', mWorker_ID);
    if not mBoolean then mWorker_ID:=mOlWorker_ID;
    //NxShowSimpleMessage(mWorker_ID,nil);
    result:= mWorker_ID;
end;

function GetMachine_ID(msite:TDynSiteForm):string;
var
    mBoolean:Boolean;
    mOlMachine_ID:string;
begin
    mOlMachine_ID:=mMachine_ID;
    mBoolean:=InputQuery('Přihlášení stroje', 'Stroj', mMachine_ID);
    if not mBoolean then mMachine_ID:=mOlMachine_ID;
    //NxShowSimpleMessage(mMachine_ID,nil);
    result:= mMachine_ID;
end;




procedure InitSite_Hook(Self: TDynSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
begin
if (NxGetActualUserID(self.BaseObjectSpace)='SUPER00000') or (NxGetActualUserID(self.BaseObjectSpace)='1Z10000101') then begin


  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Materiál';
  mmAction.Hint := 'Materiál';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Materiál');
  mmAction.OnExecuteItem:= @MAterial;

  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Digitalizace práce';
  mmAction.Hint := 'Práce';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Zahájení operace');
  mMAction.Items.Add('Ukončení operace');
  mmAction.OnExecuteItem:= @Listek;

  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Operátor';
  mmAction.Hint := 'Operátor';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Operátor');
  mmAction.OnExecuteItem:= @Operator;


end;

end;


begin
end.




