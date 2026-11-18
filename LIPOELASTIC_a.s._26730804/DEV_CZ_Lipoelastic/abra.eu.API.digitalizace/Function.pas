Function CheckMachineMaterial(msite:TDynSiteForm; mOperace_OD:string):String;
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

Function CheckBigMaterial(msite:TDynSiteForm; mOperace_OD:string):String;
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


Function CheckCompetence(msite:TDynSiteForm;mOperace_OD:string;mWorker_ID:string):String;
var
mr,mr1:tstringlist;
i,ii:integer;
mCompetence:String;
begin
 // kompetence
          mr:=TStringList.create;
          mr1:=TStringList.create;
          mCompetence:='';
          try
                 msite.BaseObjectSpace.SQLSelect('Select C.id from PLMJORoutinesRequireSkills A join CRPCompetences C on c.id=a.Competence_ID  where Parent_ID=' + quotedstr(mOperace_OD),mr);
                 if mr.count>0 then begin
                        for i:=0 to mr.count-1  do begin
                               mr1:=TStringList.create;
                               try
                                     msite.BaseObjectSpace.SQLSelect('Select C.code||C.name||C.Description from PLMJORoutinesRequireSkills A join CRPCompetences C on c.id=a.Competence_ID  where A.mWorker_ID=' + quotedstr(mWorker_ID) + ' and C.id=' + QuotedStr(mr.strings[i]),mr1) ;
                                     if mr1.count=0 then begin
                                               mCompetence:=mcompetence + mr1.Strings[0] + ' , ' + chr(13) + chr(29);
                                     end;
                               finally
                                   mr1.free;
                               end;
                       end;
                end;
          result:=mCompetence;
          finally
              mr.free;
          end;
end;





Function CheckOpenPreviewTicket(msite:TDynSiteForm;mJobOrder_ID:string;mOperace_OD:string;mPosIndex:integer):string;
var
mr,mr1:tstringlist;
i,ii:integer;
mCompetence:boolean;
begin
 // kompetence
 mCompetence:=true;
          mr:=TStringList.create;
          try
                 msite.BaseObjectSpace.SQLSelect('SELECT po.id ' +
                                                                    'FROM PLMJobOrders A ' +
                                                                    'join PLMJONodes N on N.Parent_ID = A.ID ' +
                                                                    'JOIN PLMJOOutputItems MI ON N.ID = MI.Owner_ID ' +
                                                                    'join PLMJobOrdersRoutines Routines on Routines.Parent_ID=MI.ID ' +
                                                                    'join PLMOperations PO on po.JobOrdersRoutines_ID=Routines.id ' +
                                                                    ' where A.id=' + quotedstr(mJobOrder_ID) + ' And Routines.Ongoing=' + quotedstr('N') +
                                                                    ' and po.FinishedAt$DATE =0 and Routines.PosIndex=' + inttostr(mPosIndex-1) +
                                                                    ' order by mi.id,Routines.Phase_ID,Routines.PosIndex', mr) ;

                 if mr.count>0 then result:=mr.Strings[0] else result:='';
          finally
              mr.free;
          end;
end;




Function GetOperation_ID(msite:TDynSiteForm;mJobOrder_ID:string;mMachine_ID:string;mWorker_ID:string;mPosIndex:integer):string;
var
mr,mr1:tstringlist;
i,ii:integer;
mCompetence:boolean;
begin
 // kompetence
          mr:=TStringList.create;
          try
                 msite.BaseObjectSpace.SQLSelect('SELECT Routines.id ' +
                                                                    'FROM PLMJobOrders A ' +
                                                                    'join PLMJONodes N on N.Parent_ID = A.ID ' +
                                                                    'JOIN PLMJOOutputItems MI ON N.ID = MI.Owner_ID ' +
                                                                    'join PLMJobOrdersRoutines Routines on Routines.Parent_ID=MI.ID ' +
                                                                    ' where A.id=' + quotedstr(mJobOrder_ID) +
                                                                    ' AND Routines.WorkPlace_ID=' +QuotedStr(mMachine_ID) +
                                                                    ' AND Routines.X_closed=' +QuotedStr('N') +
                                                                    ' order by mi.id,Routines.Phase_ID,Routines.PosIndex', mr) ;



                     if mr.count>0 then result:=mr.strings[0] else result:='' ;
          finally
              mr.free;
          end;
end;









Function Ticket(msite:TDynSiteForm;mJobOrder_ID:string;mOperace_OD:string;mWorker_ID:string;mMachine_ID:string;mPosIndex:integer):string;
var
mr,mr1:tstringlist;
i,ii:integer;
mBOListek:TNxCustomBusinessObject;
begin
mBOListek:=msite.BaseObjectSpace.CreateObject('');
mBOListek.new;
                                                                                 mBOListek.prefill;
                                                                                 mBOListek.SetFieldValueAsString('JobOrdersRoutines_ID',mOperace_OD);
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


























begin
end.