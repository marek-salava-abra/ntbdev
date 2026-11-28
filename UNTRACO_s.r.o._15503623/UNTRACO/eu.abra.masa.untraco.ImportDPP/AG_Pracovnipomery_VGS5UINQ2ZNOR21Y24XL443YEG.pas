Uses '.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Import PP z XLS ##';
  mAction.Hint := 'Vloží pracovní poměry dle zadané struktury';
  mAction.Category := 'tabList';
  mAction.OnExecute := @InsertRows;
end;

Procedure InsertRows(Sender:TComponent);
var
  mSite: TSiteForm;
  mOpenDlg: TOpenDialog;
  mExcel, mWB, mSheet: Variant;
  i,k:integer;
  mOS:TNxCustomObjectSpace;
  mEmployeeBO, mWorkingRelationBO:TNxCustomBusinessObject;
  mEmployee_ID, mBirthNumber, mSQL, mSelDefEmployee, mSQL2:string;
  mWRPattern_ID, mWorkingRelation_ID:string;
  mWRList, mEmployeeList:TStringList;
  mDate:extended;
begin
    mSite := TComponent(Sender).BusRollSite;
    mOS:=TBusRollSiteForm(mSite).BaseObjectSpace;
    mOpenDlg:=TOpenDialog.Create(sender);
    mOpenDlg.Title := 'Import z Excelu';
    mOpenDlg.Filter := 'Soubory aplikace Excel (*.xls, *.xlsx)| *.xls;*.xlsx';
    if mOpenDlg.Execute then begin
       try
          mExcel := CreateOleObject('Excel.Application');
          mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
          mSheet := mWB.Sheets[1];
          k:=mSheet.UsedRange.Rows.Count+1;
          mDate:=mOS.SQLSelectFirstAsExtended('Select first 1 datefrom$date from wageperiods where wperiodclosed='+QuotedStr('N'),0);
          mWRList:=TStringList.Create;
          mEmployeeList:=TStringList.Create;
          WaitWin.StartProgress('Čekejte, prosím ...', '', k);
            i:=2;
               while i<mSheet.UsedRange.Rows.Count+1 do begin
               if not(NxIsBlank(VarToStr(mSheet.Cells[i, 1]))) then begin
               try
                 mBirthNumber:=VarToStr(mSheet.Cells[i, 4]);
                 mSQL:=   'SELECT a.ID FROM'#13#10 +
                          '  EmployeeQuery('+IntToStr(Trunc(mDate))+', '''', ''N'', 0, 0,'#13#10 +
                          '  ''N'', 0, 0, '''','#13#10 +
                          '  '''','''', '''', '''','#13#10 +
                          '  -1, '''', ''*'', ''*'', ''*'','#13#10 +
                          '  ''*'', ''*'', -1, -1, -1, -1,'#13#10 +
                          '  -1, -1, ''*'', '''', '''','#13#10 +
                          '  '''', '''', '''', -1, -1,'#13#10 +
                          '  ''*'', ''*'', '''', '''', '''','#13#10 +
                          '  '''', '''', '''', -1, -1,'#13#10 +
                          '  -1, -1, -1, ''*'', '''', '''','#13#10 +
                          '  ''N'', 0, 0, '''', '''', '''')'#13#10 +
                          '  B'#13#10 +
                          'LEFT JOIN Employees A ON B.ID = A.ID'#13#10 +
                          #13#10 +
                          'LEFT JOIN Persons PR ON A.Person_ID = PR.ID'#13#10 +
                          'WHERE (A.Hidden = ''N'' ) AND (PR.BirthNumber LIKE '+QuotedStr(mBirthNumber)+' ESCAPE ''~'' ) ';
                 mEmployee_ID:=mOS.SQLSelectFirstAsString(mSQL,'');
                 if NxIsEmptyOID(mEmployee_ID) then begin
                    mEmployeeBO:=mOS.CreateObject(Class_Employee);
                    mEmployeeBO.New;
                    mEmployeeBO.Prefill;
                    mEmployeeBO.SetFieldValueAsString('Person_ID.FirstName', VarToStr(mSheet.Cells[i, 1]));
                    mEmployeeBO.SetFieldValueAsString('Person_ID.LastName', VarToStr(mSheet.Cells[i, 2]));
                    mEmployeeBO.SetFieldValueAsString('Person_ID.Title', VarToStr(mSheet.Cells[i, 3]));
                    mEmployeeBO.SetFieldValueAsString('Person_ID.BirthNumber', mBirthNumber);
                    mEmployeeBO.SetFieldValueAsString('Person_ID.PersonalNumber', VarToStr(mSheet.Cells[i, 5]));
                    mEmployeeBO.SetFieldValueAsDateTime('Person_ID.DateOfBirth$DATE', StrToDateTime(VarToStr(mSheet.Cells[i, 6])));
                    mEmployeeBO.SetFieldValueAsString('BirthName',VarToStr(mSheet.Cells[i, 7]));
                    mEmployeeBO.SetFieldValueAsString('BirthPlace',VarToStr(mSheet.Cells[i, 8]));
                    if UpperCase(VarToStr(mSheet.Cells[i, 9]))='ŽENA' then mEmployeeBO.SetFieldValueAsInteger('Sex',1);
                    mEmployeeBO.SetFieldValueAsString('BirthCountry_ID', mOS.SQLSelectFirstAsString('Select id from Countries where hidden=''N'' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 10])),'00000CZ000'));
                    mEmployeeBO.SetFieldValueAsString('EducationGrade_ID', mOS.SQLSelectFirstAsString('Select id from educationgrades where hidden=''N'' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 11])),'00000CZ000'));
                    mEmployeeBO.SetFieldValueAsString('Nationality_ID', mOS.SQLSelectFirstAsString('Select id from Countries where hidden=''N'' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 12])),'00000CZ000'));
                    mEmployeeBO.SetFieldValueAsString('Person_ID.Address_ID.Street', VarToStr(mSheet.Cells[i, 13]));
                    mEmployeeBO.SetFieldValueAsString('Person_ID.Address_ID.City', VarToStr(mSheet.Cells[i, 14]));
                    mEmployeeBO.SetFieldValueAsString('Person_ID.Address_ID.PostCode', VarToStr(mSheet.Cells[i, 15]));
                    mEmployeeBO.SetFieldValueAsString('Person_ID.Address_ID.Country', VarToStr(mSheet.Cells[i, 16]));
                    mEmployeeBO.SetFieldValueAsString('Person_ID.Address_ID.CountryCode', VarToStr(mSheet.Cells[i, 17]));
                    mEmployeeBO.SetFieldValueAsString('InsuranceComp_ID', mOS.SQLSelectFirstAsString('Select id from insuranceCOMPANIES where hidden=''N'' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 18])),'Z000000000'));
                    mEmployeeBO.save;
                    mEmployee_ID:=mEmployeeBO.OID;
                    mEmployeeBO.free;
                 end;
                mEmployeeList.Clear;
                mEmployeeList.Add(mEmployee_ID);
                mSelDefEmployee:=GenerateString(10);
                StringsToSelDat(mOS,mSelDefEmployee,mEmployeeList);
                mWRPattern_ID:=mOS.SQLSelectFirstAsString('Select id from employpatterns where hidden=''N'' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 20])),'');
                mSQL2:= 'SELECT  A.ID'#13#10 +
                        'FROM'#13#10 +
                        '  WorkingRelationQuery('+IntToStr(Trunc(mDate))+', '+QuotedStr(mSelDefEmployee)+', '''','#13#10 +
                        '  ''N'', 0, 0, ''0'','#13#10 +
                        '  ''N'', 0, 0, ''0'', '''','#13#10 +
                        '  ''*'', ''*'', ''*'', '''', ''0'','#13#10 +
                        '  '''', ''0'', '''', ''0'','#13#10 +
                        '  '''', ''0'','#13#10 +
                        '  -1, '''', ''0'', -1, -1, -1,'#13#10 +
                        '  -1, -1, '''', ''*'','#13#10 +
                        '  ''*'', ''*'', '''', '''','#13#10 +
                        '  '''', -1,'#13#10 +
                        '  '''', '''','#13#10 +
                        '  ''*'', ''*'', -1, -1)'#13#10 +
                        '   B'#13#10 +
                        '  LEFT JOIN WorkingRelations A ON B.ID = A.ID'#13#10 +
                        '  '#13#10 +
                        '  LEFT JOIN Divisions DIV ON B.HISTORYDIVISION_ID = DIV.ID'#13#10 +
                        '  LEFT JOIN Employees EMP ON A.Employee_ID=EMP.ID'#13#10 +
                        '  LEFT JOIN Persons P ON EMP.Person_ID=P.ID'#13#10 +
                        '  LEFT JOIN EmployPatterns EP ON B.EmployPattern_ID=EP.ID'#13#10 +
                        '  LEFT JOIN TypesOfBegin TB ON TB.ID = A.TypeOfBegin_ID'#13#10 +
                        '  LEFT JOIN TypesOfEnd TE ON TE.ID = A.TypeOfEnd_ID'#13#10 +
                        'WHERE (A.Hidden = ''N'' )';
                mWorkingRelation_ID:=mOS.SQLSelectFirstAsString(mSQL2,'');
                ClearSelDat(mOS,mSelDefEmployee);
                if NxIsEmptyOID(mWorkingRelation_ID) then begin
                    mWorkingRelationBO:=mOS.CreateObject(Class_WorkingRelation);
                    mWorkingRelationBO.New;
                    mWorkingRelationBO.Prefill;
                    mWorkingRelationBO.DateOfChange:=StrToDateTime(VarToStr(mSheet.Cells[i, 22]));
                    mWorkingRelationBO.SetFieldValueAsString('Employee_ID',mEmployee_ID);
                    mWorkingRelationBO.SetFieldValueAsString('EmployPattern_ID',mWRPattern_ID);
                    mWorkingRelationBO.SetFieldValueAsDateTime('DateOfBegin$DATE', StrToDateTime(VarToStr(mSheet.Cells[i, 22])));
                    mWorkingRelationBO.SetFieldValueAsString('TypeOfBegin_ID',mOS.SQLSelectFirstAsString('Select id from typesofbegin where hidden=''N'' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 23])),''));
                    mWorkingRelationBO.SetFieldValueAsDateTime('RealDateOfBegin$DATE', StrToDateTime(VarToStr(mSheet.Cells[i, 24])));
                    mWorkingRelationBO.SetFieldValueAsString('Division_ID',mOS.SQLSelectFirstAsString('Select id from divisions where hidden=''N'' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 25])),'1000000101'));
                    mWorkingRelationBO.SetFieldValueAsDateTime('NoticeDate$DATE', StrToDateTime(VarToStr(mSheet.Cells[i, 28])));
                    mWorkingRelationBO.SetFieldValueAsDateTime('DateOfEnd$DATE', StrToDateTime(VarToStr(mSheet.Cells[i, 29])));
                    mWorkingRelationBO.SetFieldValueAsString('TypeOfEnd_ID',mOS.SQLSelectFirstAsString('Select id from typesofend where hidden=''N'' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 30])),''));
                    mWorkingRelationBO.SetFieldValueAsString('ReasonOfEnd', VarToStr(mSheet.Cells[i, 31]));
                    mWorkingRelationBO.SetFieldValueAsInteger('ReasonNotProvideDocs',2);
                    mWorkingRelationBO.SetFieldValueAsString('ShiftCalendar_ID',mOS.SQLSelectFirstAsString('Select id from shiftcALENDAR where hidden=''N'' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 33])),''));
                    mWorkingRelationBO.SetFieldValueAsString('WorkPosition_ID',mOS.SQLSelectFirstAsString('Select id from workpositions where hidden=''N'' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 34])),''));
                    mWorkingRelationBO.SetFieldValueAsString('JobPosition_ID',mOS.SQLSelectFirstAsString('Select id from jobpositions where hidden=''N'' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 35])),''));
                    mWorkingRelationBO.SetFieldValueAsString('S_WorkScheduleType_ID',mOS.SQLSelectFirstAsString('Select id from workscheduletypes where hidden=''N'' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 37])),''));
                    mWorkingRelationBO.SetFieldValueAsString('S_WorkLocationType_ID',mOS.SQLSelectFirstAsString('Select id from worklocationtypes where hidden=''N'' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 38])),''));
                    mWorkingRelationBO.SetFieldValueAsString('S_RetirementReportCodeDet_ID',mOS.SQLSelectFirstAsString('Select id from retirementreportcodedetails where hidden=''N'' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 39])),''));
                    mWorkingRelationBO.SetFieldValueAsString('JobClasificationISCO_ID',mOS.SQLSelectFirstAsString('Select id from jobclasificationsiSCO where hidden=''N'' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 40])),''));
                    mWorkingRelationBO.SetFieldValueAsString('WorkingDestination',VarToStr(mSheet.Cells[i, 41]));
                    mWorkingRelationBO.SetFieldValueAsString('Municipality_ID',mOS.SQLSelectFirstAsString('Select id from municIPALITIES where hidden=''N'' and name='+QuotedStr(VarToStr(mSheet.Cells[i, 42])),''));
                    mWorkingRelationBO.SetFieldValueAsString('WorkingPlace',VarToStr(mSheet.Cells[i, 43]));
                    mWorkingRelationBO.save;
                    mWRList.add(QuotedStr(mWorkingRelationBO.OID));
                 end else begin
                   mWRList.add(QuotedStr(mWorkingRelation_ID));
                 end;
                except
                  NxShowSimpleMessage('Něco se nepovedlo, po zmáčknutí OK bude pokračovat dalším záznamem.'+
                  NxCrlf+nxCrLf+'Záznam na řádku '+inttostr(i)+NxCrLf+nxCrLf+nxCrLf+ExceptionMessage,mSite);
                end;
               end;
               Inc(i);
               WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(k));
               WaitWin.StepIt;
              end;
          WaitWin.stop;
        finally
          if not VarIsEmpty(mWB) and not VarIsClear(mWB) then begin
            mWB.Close(False); // False = uložit změny? Ne, soubor jen čteme
          end;
          if not VarIsEmpty(mExcel) and not VarIsClear(mExcel) then begin
            mExcel.Quit;
          end;
         if mWRList.count>0 then
          TBusRollSiteForm(mSite).ShowSite(Site_WorkingRelationsSite,true,'FilterByUserDynSQLCondition;A.ID in ('+mWRList.DelimitedText+');Nové poměry');
         mWRList.free;
         mEmployeeList.free;
        end;
    end;
end;

begin
end.