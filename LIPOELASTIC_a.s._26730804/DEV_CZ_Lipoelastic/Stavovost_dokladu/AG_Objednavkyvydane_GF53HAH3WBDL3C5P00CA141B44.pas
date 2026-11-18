var
mSiteUser:TNxCustomBusinessObject;

procedure _CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);
var
mBoolean:Boolean;
mIButton:integer;
mText:string;
begin
                     // if self.CurrentObject.GetFieldValueAsinteger('PMState_ID.SequenceNumber')>=50 then begin

                                 if TDynSiteForm(self).CurrentObject.GetFieldValueAsinteger('PMState_ID.SequenceNumber')>=50 then begin
                                        MessageDlg('Aktuální doklad nelze editovat z těchto důvodů:' + #13#10
                                                  + 'Doklad ' + self.CurrentObject.DisplayName + ' je již ve stavu ' + self.CurrentObject.GetFieldValueAsstring('PMState_ID.Code') + #13#10
                                                  + '  u kterého již není umožněna editace.',
                                                  mtWarning, [mbCancel], 0);
                                       if (copy(mSiteUser.GetFieldValueAsString('X_Button_parametr'),11,1)='0') then begin
                                             ACanEdit := False;
                                       end else begin
                                         mText:= 'Chcete i přes to doklad opravit? ' ;
                                         if TDynSiteForm(self).CurrentObject.GetFieldValueAsstring('PMState_ID.Description')<>'' then begin
                                                   mText:=mText + #13#10   + #13#10 + ' S dokladem jsou vytvořeny tyto návaznosti , které je potřeba upravit' + #13#10 + #13#10
                                                           + TDynSiteForm(self).CurrentObject.GetFieldValueAsstring('PMState_ID.Description') ;
                                         end;
                                         mIButton:= MessageDlg( mText,mtWarning, [mbOK,mbCancel], 0);
                                          // NxShowSimpleMessage(inttostr(mIButton),nil);
                                           if mIButton=1 then ACanEdit := True ;
                                           if mIButton=2 then ACanEdit := False;
                                       end;
                                end else begin
                                    ACanEdit := True;
                                end;

end;


{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);

begin
    mSiteUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    try
      mSiteUser.Load(Self.CompanyCache.GetUserID, nil);
    finally
    end;
end;

begin
end.