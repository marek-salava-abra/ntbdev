procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Pokusy s časem';
  mAction.Hint := 'pokus';
  mAction.Category := 'tabList';
  mAction.OnExecute := @PokusA;
end;


Procedure PokusA(sender:TComponent);
var
 mSite:TSiteForm;
 mTimeMinus, mTimePlus, mTime:Extended;
begin
 mSite:=TComponent(sender).BusRollSite;
 mTime:=Now;
 if Trunc(NxRoundByValue(MinuteOfTheHour(mtime),ctUp,15))<60 then
  mTimePlus:=EncodeDateTime(NxExtractYear(mTime),NxExtractMonth(mTime),NxExtractDay(mTime),HourOfTheDay(mTime),Trunc(NxRoundByValue(MinuteOfTheHour(mtime),ctUp,15)),0,0) else
 mTimePlus:=EncodeDateTime(NxExtractYear(mTime),NxExtractMonth(mTime),NxExtractDay(mTime),HourOfTheDay(mTime)+1,0,0,0);

 mTimeMinus:=EncodeDateTime(NxExtractYear(mTime),NxExtractMonth(mTime),NxExtractDay(mTime),HourOfTheDay(mTime),Trunc(NxRoundByValue(MinuteOfTheHour(mtime),ctDown,15)),0,0);
 NxShowSimpleMessage(DateTimeToStr(mTime)+#13#10+
                     FloatToStr(mTime)+#13#10+
                     inttostr(MinuteOfTheHour(mTime))+#13#10+
                     DateTimeToStr(mTimePlus)+#13#10+
                     DateTimeToStr(mTimeMinus),msite);
end;

begin
end.