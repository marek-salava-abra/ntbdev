function NewValueParam(msite:TSiteForm;mParametry:tstringlist;mSource_value:string;mChanegValue:string):string;
Var
mnovyzapis:string;
i:integer;
begin
    if trim(mSource_value)='' then begin
         mSource_value:='0000000000000000000000000' ;
         mSource_value:=copy(mSource_value,1,mParametry.Count);
    end;
    mnovyzapis:='';

    for i:=1 to mParametry.count do begin
        if (copy(mChanegValue,i,1)='0') or (copy(mChanegValue,i,1)='1') then begin
            mnovyzapis:=mnovyzapis+(copy(mSource_value,i,1));
        end else begin
            if (copy(mChanegValue,i,1)='A') then mnovyzapis:=mnovyzapis+'1';
            if (copy(mChanegValue,i,1)='N') then mnovyzapis:=mnovyzapis+'0';
        end;
    end;

    result:=mnovyzapis;
end;


function CreateStringParam(msite:TSiteForm;Name:string;mParametry:tstringlist;mhodnoty:string):string;
var
 mBtn:TButton;
 mB01,mB02,mB03,mB04,mB05,mB06,mB07,mB08,mB09,mB10,mB11,mB12,mB13,mB14,mB15,mB16,mB17,mB18,mB19,mB20,mB21,mB22,mB23,mB24,mB25:boolean;
 mCHE01,mCHE02,mCHE03,mCHE04,mCHE05,mCHE06,mCHE07,mCHE08,mCHE09,mCHE10,mCHE11,mCHE12,mCHE13,mCHE14,mCHE15,mCHE16,mCHE17,mCHE18,mCHE19,mCHE20,mCHE21,mCHE22,mCHE23,mCHE24,mCHE25:TCheckBox;
 mHod01,mHod02,mHod03,mHod04,mHod05,mHod06,mHod07,mHod08,mHod09,mHod10,mHod11,mHod12,mHod13,mHod14,mHod15,mHod16,mHod17,mHod18,mHod19,mHod20,mHod21,mHod22,mHod23,mHod24,mHod25:TCheckBox;
 mSHod01,mSHod02,mSHod03,mSHod04,mSHod05,mSHod06,mSHod07,mSHod08,mSHod09,mSHod10,mSHod11,mSHod12,mSHod13,mSHod14,mSHod15,mSHod16,mSHod17,mSHod18,mSHod19,mSHod20,mSHod21,mSHod22,mSHod23,mSHod24,mSHod25:string;
 mForm:TForm;
 mResult:integer;
 i:integer;
 mHelpName:string;
 mIButton:integer;
 mNewValue:string;
 mName:string;
begin
 mIButton:=0;
     mform:=CreateFormDialoga('mform', Name,mSite, 500, ((mParametry.Count+5)*25));
                         try

                          mB01:=false;
                          mB02:=false;
                          mB03:=false;
                          mB04:=false;
                          mB05:=false;
                          mB06:=false;
                          mB07:=false;
                          mB08:=false;
                          mB07:=false;
                          mB10:=false;
                          mB11:=false;
                          mB12:=false;
                          mB13:=false;
                          mB14:=false;
                          mB15:=false;
                          mB16:=false;
                          mB17:=false;
                          mB18:=false;
                          mB19:=false;
                          mB20:=false;
                          mB21:=false;
                          mB22:=false;
                          mB23:=false;
                          mB25:=false;

                          if trim(mhodnoty)='' then begin
                              mhodnoty:='0000000000000000000000000' ;
                              mhodnoty:=copy(mhodnoty,1,mParametry.Count);
                          end;


                          i:=0;
                          //for i:=0 to mParametry.Count-1 do begin
                          //   if Length(i)=1 then begin
                          //       mHelpName:='0' + IntToStr(i);
                          //   end else begin
                          //       mHelpName:=IntToStr(i);
                          //   end;

                             if i<=mParametry.Count-1 then begin
                                mCHE01:=CreateCheckBoxa('mCHE01' ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod01:=CreateCheckBoxa('mHod01',mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;


                             if i<=mParametry.Count-1 then begin

                                mCHE02:=CreateCheckBoxa('mCHE02'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod02:=CreateCheckBoxa('mHod02'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;


                            if i<=mParametry.Count-1 then begin
                                mCHE03:=CreateCheckBoxa('mCHE03'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod03:=CreateCheckBoxa('mHod03'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;


                            if i<=mParametry.Count-1 then begin
                                mCHE04:=CreateCheckBoxa('mCHE04'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod04:=CreateCheckBoxa('mHod04'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;


                             if i<=mParametry.Count-1 then begin
                                mCHE05:=CreateCheckBoxa('mCHE05'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod05:=CreateCheckBoxa('mHod05'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;


                             if i<=mParametry.Count-1 then begin
                                mCHE06:=CreateCheckBoxa('mCHE06'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod06:=CreateCheckBoxa('mHod06'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;


                             if i<=mParametry.Count-1 then begin
                                mCHE07:=CreateCheckBoxa('mCHE07'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod07:=CreateCheckBoxa('mHod07'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;


                             if i<=mParametry.Count-1 then begin
                                mCHE08:=CreateCheckBoxa('mCHE08'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod08:=CreateCheckBoxa('mHod08'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;


                             if i<=mParametry.Count-1 then begin
                                mCHE09:=CreateCheckBoxa('mCHE09'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod09:=CreateCheckBoxa('mHod09'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;


                             if i<=mParametry.Count-1 then begin
                                mCHE10:=CreateCheckBoxa('mCHE10'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod10:=CreateCheckBoxa('mHod10'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;

                             if i<=mParametry.Count-1 then begin
                                mCHE10:=CreateCheckBoxa('mCHE11'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod10:=CreateCheckBoxa('mHod11'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;

                             if i<=mParametry.Count-1 then begin
                                mCHE10:=CreateCheckBoxa('mCHE12'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod10:=CreateCheckBoxa('mHod12'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;

                             if i<=mParametry.Count-1 then begin
                                mCHE10:=CreateCheckBoxa('mCHE13'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod10:=CreateCheckBoxa('mHod13'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;

                             if i<=mParametry.Count-1 then begin
                                mCHE10:=CreateCheckBoxa('mCHE14'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod10:=CreateCheckBoxa('mHod14'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;

                             if i<=mParametry.Count-1 then begin
                                mCHE10:=CreateCheckBoxa('mCHE15'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod10:=CreateCheckBoxa('mHod15'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;

                             if i<=mParametry.Count-1 then begin
                                mCHE10:=CreateCheckBoxa('mCHE16'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod10:=CreateCheckBoxa('mHod16'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;

                             if i<=mParametry.Count-1 then begin
                                mCHE10:=CreateCheckBoxa('mCHE17'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod10:=CreateCheckBoxa('mHod17'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;

                             if i<=mParametry.Count-1 then begin
                                mCHE10:=CreateCheckBoxa('mCHE18'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod10:=CreateCheckBoxa('mHod18'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;

                             if i<=mParametry.Count-1 then begin
                                mCHE10:=CreateCheckBoxa('mCHE19'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod10:=CreateCheckBoxa('mHod19'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;

                             if i<=mParametry.Count-1 then begin
                                mCHE10:=CreateCheckBoxa('mCHE20'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod10:=CreateCheckBoxa('mHod20'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;

                             if i<=mParametry.Count-1 then begin
                                mCHE10:=CreateCheckBoxa('mCHE21'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod10:=CreateCheckBoxa('mHod21'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;

                             if i<=mParametry.Count-1 then begin
                                mCHE10:=CreateCheckBoxa('mCHE22'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod10:=CreateCheckBoxa('mHod22'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;

                             if i<=mParametry.Count-1 then begin
                                mCHE10:=CreateCheckBoxa('mCHE23'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod10:=CreateCheckBoxa('mHod23'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;

                             if i<=mParametry.Count-1 then begin
                                mCHE10:=CreateCheckBoxa('mCHE24'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod10:=CreateCheckBoxa('mHod24'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;

                             if i<=mParametry.Count-1 then begin
                                mCHE10:=CreateCheckBoxa('mCHE25'   ,'Použít ', false, 5, 10+(i*25),120,20, mform);
                                mHod10:=CreateCheckBoxa('mHod25'  ,mParametry.Strings[i], copy(mhodnoty,i+1,1)='1', 70, 10+(i*25), 300,20, mform);
                                i:=i+1;
                             end;



                             mIButton:=40+(i*25);
                          //end;

                            mBtn := TButton.Create(mForm);mBtn.Width := 200 ;mBtn.Height := 40;mBtn.Caption := 'Zápis'; mBtn.ModalResult := 2; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=30;mBtn.Top :=mIButton ;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                            mBtn := TButton.Create(mForm);mBtn.Width := 200 ;mBtn.Height := 40;mBtn.Caption := 'Storno';mBtn.ModalResult := 99;mBtn.Cancel := False;mBtn.Left := 270;mBtn.Top := mIButton;mBtn.Name := 'btn99';mForm.InsertControl(mBtn);

                               mResult := mForm.ShowModal(mSite);
                               if mResult= 2 then begin
                                      try
                                            mNewvalue:='';
                                           I:=1 ;
                                           if i<=mParametry.Count then begin
                                                  if mCHE01.Checked then begin
                                                     if mHod01.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;


                                            if i<=mParametry.Count then begin
                                                  if mCHE02.Checked then begin
                                                     if mHod02.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;



                                            if i<=mParametry.Count then begin
                                                  if mCHE03.Checked then begin
                                                     if mHod03.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;



                                            if i<=mParametry.Count then begin
                                                  if mCHE04.Checked then begin
                                                     if mHod04.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;



                                            if i<=mParametry.Count then begin
                                                  if mCHE05.Checked then begin
                                                     if mHod05.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;



                                            if i<=mParametry.Count then begin
                                                  if mCHE06.Checked then begin
                                                     if mHod06.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;



                                            if i<=mParametry.Count then begin
                                                  if mCHE07.Checked then begin
                                                     if mHod07.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;



                                            if i<=mParametry.Count then begin
                                                  if mCHE08.Checked then begin
                                                     if mHod08.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;



                                            if i<=mParametry.Count then begin
                                                  if mCHE09.Checked then begin
                                                     if mHod09.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;



                                            if i<=mParametry.Count then begin
                                                  if mCHE10.Checked then begin
                                                     if mHod10.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;



                                            if i<=mParametry.Count then begin
                                                  if mCHE11.Checked then begin
                                                     if mHod11.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;



                                            if i<=mParametry.Count then begin
                                                  if mCHE12.Checked then begin
                                                     if mHod12.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;



                                            if i<=mParametry.Count then begin
                                                  if mCHE13.Checked then begin
                                                     if mHod13.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;



                                            if i<=mParametry.Count then begin
                                                  if mCHE14.Checked then begin
                                                     if mHod14.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;



                                            if i<=mParametry.Count then begin
                                                  if mCHE15.Checked then begin
                                                     if mHod15.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;



                                            if i<=mParametry.Count then begin
                                                  if mCHE16.Checked then begin
                                                     if mHod16.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;


                                            if i<=mParametry.Count then begin
                                                  if mCHE17.Checked then begin
                                                     if mHod17.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;

                                            if i<=mParametry.Count then begin
                                                  if mCHE18.Checked then begin
                                                     if mHod18.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;

                                            if i<=mParametry.Count then begin
                                                  if mCHE19.Checked then begin
                                                     if mHod19.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;

                                            if i<=mParametry.Count then begin
                                                  if mCHE20.Checked then begin
                                                     if mHod20.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;

                                            if i<=mParametry.Count then begin
                                                  if mCHE21.Checked then begin
                                                     if mHod21.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;

                                            if i<=mParametry.Count then begin
                                                  if mCHE22.Checked then begin
                                                     if mHod22.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;

                                            if i<=mParametry.Count then begin
                                                  if mCHE23.Checked then begin
                                                     if mHod23.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;

                                            if i<=mParametry.Count then begin
                                                  if mCHE24.Checked then begin
                                                     if mHod24.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;

                                            if i<=mParametry.Count then begin
                                                  if mCHE25.Checked then begin
                                                     if mHod25.Checked then begin
                                                           mNewvalue:=mNewvalue + 'A';
                                                     end else begin
                                                           mNewvalue:=mNewvalue + 'N';
                                                     end;
                                                  end else begin
                                                     mNewvalue:=mNewvalue + copy(mhodnoty,i,1);
                                                  end ;
                                                  i:=i+1;
                                            end;






                                            result:=copy(mNewValue,1,mParametry.Count);
                                       finally
                                         result:=copy(mNewValue,1,mParametry.Count);
                                       end;






                            end;       //


                               if mResult= 99 then begin
                                   NxShowSimpleMessage('Operace byla přerušena uživatelem',nil);
                                   result:='Storno';
                                   //exit;
                               end;
                         finally
                             mform.free;
                         end;
end;


function CreateCheckBoxa(AName, ACaption: string; ADefaultValue: Boolean;
  ALeft, ATop, AWidth, AHeight: Integer; AParent: TWinControl): TCheckBox;
begin
  Result:= TCheckBox.Create(AParent);
  Result.Parent:= AParent;
  Result.Top:= ATop;
  Result.Left:= ALeft;
  if AName <> '' then
    Result.Name:= 'ch_' + AName;
  Result.Width:= AWidth;
  if AHeight > -1 then
    Result.Height:= AHeight;
  Result.Caption:= ACaption;
  Result.Checked:= ADefaultValue;
  Result.WordWrap:= True;
end;


function CreateEdita(AName, ACaption: string;
  ALeft, ATop, AWidth: Integer; ALblWidth: Integer; ADefaultValue: string; AParent: TWinControl;
  AEditToNewLine: Boolean = False): TEdit;
var mLbl: TLabel;
begin
  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 5;
  mLbl.Left:= ALeft;
  mLbl.AutoSize:= False;
  if AName <> '' then
    mLbl.Name:= 'lbl_' + AName;
  if ALblWidth > -1 then
  begin
    mLbl.Width:= ALblWidth
  end else
  begin
    mLbl.AutoSize:= True;
    ALblWidth:= mLbl.Width + 10;
  end;
  mLbl.Caption:= ACaption;

  Result:= TEdit.Create(AParent);
  Result.Parent:= AParent;
  if not AEditToNewLine then
  begin
    Result.Top:= ATop;
    Result.Left:= ALeft + ALblWidth;
    Result.Width:= AWidth - ALblWidth;
  end else
  begin
    mLbl.Top:= ATop;
    Result.Top:= ATop + mLbl.Height + 2;
    Result.Width:= AWidth;
    Result.Left:= ALeft;
  end;
  if AName <> '' then
    Result.Name:= 'ed_' + AName;

  Result.Text:= ADefaultValue;
end;




function CreateNxComboEdita(AName, ACaption: string;
                           AParent: TWinControl;
                           ALeft, ATop, AWidth, AHeight,
                           ALblWidth, ABevelWidth: Integer;
                           AClassID, ATextField, AControlField, AID: string;
                           AParam: string = ''; AChange: string =''): TRollComboEdit;
var mLbl, mLbl1,
    mLblChange: TLabel;
begin
  if AID = '' then
    AID:= '0000000000';
  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 5;
  mLbl.Left:= ALeft;
  mLbl.AutoSize:= False;
  if AName <> '' then
    mLbl.Name:= 'lbl_' + AName;
  if ALblWidth > -1 then
  begin
    mLbl.Width:= ALblWidth
  end else
  begin
    mLbl.AutoSize:= True;
    ALblWidth:= mLbl.Width + 10;
  end;
  mLbl.Caption:= ACaption;

  mLbl1:= TLabel.Create(AParent);
  mLbl1.Parent:= AParent;
  mLbl1.Top:= ATop + 5;
  mLbl1.Left:= ALeft +AWidth ;
  mLbl1.AutoSize:= False;
  mLbl1.Caption:= '';
  if AName <> '' then
    mLbl1.Name:= 'lblBev_' + AName;
  mLbl1.Width:= ABevelWidth;
  mLbl1.Visible:= ABevelWidth > 0;

  Result:= TRollComboEdit.Create(AParent);
  Result.Parent:= AParent;
  Result.ClassID:= AClassID;
  Result.ForcedField:= True;
  Result.Prefilling:= pmNone;
  Result.TextField:= ATextField;
  Result.Parameters.Add(AParam);
  Result.Top:= ATop + 3;
  Result.Left:= ALeft + ALblWidth;
  if AControlField <> '' then
  begin
    Result.ConnectedControlField:= AControlField;
    Result.ConnectedControl:= mLbl1;
  end;

  if AName <> '' then
    Result.Name:= 'ced_' + AName;
  Result.DataText:= AID;
  Result.Width:= AWidth - ALblWidth - ABevelWidth;


  if (AChange <> '') and (AName <> '') then
  begin
    mLblChange:= TLabel.Create(AParent);
    mLblChange.Parent:= AParent;
    mLblChange.Top:= 0;
    mLblChange.Left:= 0;
    mLblChange.ViSible:= False;
    mLblChange.Name:= 'lblCh_' + AName;
    mLblChange.Caption:= AChange;
    Result.OnChange:= @NxDBComboEditChange;
  end;


  mLbl1.Left:= mLbl1.Left + 10;
  mLbl1.Width:= mLbl1.Width - 10;
end;



  function CreateFormDialoga(AName, ACaption: String;
                          AParent: TWinControl;
                          AWidth, AHeight: Integer; ): TForm;
var
  mForm: TForm;
begin
  mForm := TForm.Create(AParent);
  mForm.Name := 'fm_'+AName;
  mForm.Caption := ACaption;
  mForm.FormStyle := fsStayOnTop;
  mForm.BorderStyle := bsDialog;
  mForm.Position := poScreenCenter;
  mForm.Width := AWidth;
  mForm.Height := AHeight;
  mForm.Scaled := False;

  Result := mForm;
end;



function CreateDateEditA(AName, ACaption: string;
  ALeft, ATop, AWidth: Integer; ALblWidth: Integer; ADefaultValue: TDate; AParent: TWinControl;
  AEditToNewLine: Boolean = False): TDateEdit;
var
  mLbl: TLabel;
begin

  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 5;
  mLbl.Left:= ALeft;
  mLbl.AutoSize:= False;
  if AName <> '' then
    mLbl.Name:= 'lbl_' + AName;
  if ALblWidth > -1 then
  begin
    mLbl.Width:= ALblWidth
  end else
  begin
    mLbl.AutoSize:= True;
    ALblWidth:= mLbl.Width + 10;
  end;
  mLbl.Caption:= ACaption;

  Result:= TDateEdit.Create(AParent);
  Result.Parent:= AParent;
  if not AEditToNewLine then
  begin
    Result.Top:= ATop;
    Result.Left:= ALeft + ALblWidth;
    Result.Width:= AWidth - ALblWidth;
  end else
  begin
    mLbl.Top:= ATop;
    Result.Top:= ATop + mLbl.Height + 2;
    Result.Width:= AWidth;
    Result.Left:= ALeft;
  end;
  if AName <> '' then
    Result.Name:= 'ed_' + AName;

  Result.Date:= ADefaultValue;
end;




begin
end.