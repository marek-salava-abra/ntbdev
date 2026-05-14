uses 'eu.spedos.KT.ParseData', 'eu.spedos.KT.Progress';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Generování KT';
  mAction.Items.Add('Nový import');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Provede import z csv';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportData;

end;

procedure ImportData(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mSMBO, mSMMasterBO, mbankBO, mUnitBO:TNxCustomBusinessObject;
 mPLRows:TNxCustomBusinessMonikerCollection;
 mPLRow:TNxCustomBusinessObject;
 mList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mMaster_ID:String;
 mNew:Boolean;
 mGRows : TMultiGrid;
 mFinalDate, mBaseDate:extended;
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
 mFinalDate:=0;
 mBaseDate:=0;
  if index=0 then begin
  try
      try
        GetDate(mFinalDate, mSite);
        mList:=TStringList.Create;
        mOS.SQLSelect('Select max(X_dateto) from defrolldata where clsid=''TH5C5PIBWSCOF301YTKOXOELIC''',mList);
        mBaseDate:=StrToFloat(mlist.strings[0]);
        j:= trunc(NxRoundByValue((mFinalDate-mBaseDate)/7,ctUp,1));
        try
           ProgressInit(mSite, 'Generuji týdny...', j);
           for i := 0 to j - 1 do begin
           mSMBO:=mos.CreateObject('TH5C5PIBWSCOF301YTKOXOELIC');
           mSMBO.New;
           mSMBO.Prefill;
           msmbo.SetFieldValueAsDateTime('X_DateFrom',(i*7)+1+mBaseDate);
           msmbo.SetFieldValueAsDateTime('X_DateTO',(i*7)+7+mBaseDate);
           //msmbo.SetFieldValueAsFloat('X_Capacity',60000);
           msmbo.SetFieldValueAsString('Code',IntToStr(YearOf(msmbo.GetFieldValueAsDateTime('X_Dateto')))+AnsiRightstr('0'+IntToStr(WeekOfTheYear(msmbo.GetFieldValueAsDateTime('X_Dateto'))),2));
           mSMBO.SetFieldValueAsString('Name',AnsiRightstr('0'+IntToStr(WeekOfTheYear(msmbo.GetFieldValueAsDateTime('X_Dateto'))),2)+'. kalendářní týden roku '+IntToStr(YearOf(msmbo.GetFieldValueAsDateTime('X_Dateto'))));

           mSMBO.save;
           mSMBO.free;

           ProgressSetPos(i+1);
           end;



        finally
          ProgressDispose();

        end;
      finally
      end;
  finally
  end;
 end;

end;


begin
end.