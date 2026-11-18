uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'abra.eu.mask.Lipoelastic.Archiv.lib'
      ;

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}


procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
begin
 mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Příloha do archivu';
  mmAction.Hint := 'Vytvoření dokladu zpětně';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Připojení souboru');
  mmAction.OnExecuteItem:= @NewCLExecute;
end;


procedure NewCLExecute(Sender: TAction; Index: integer);
var
  mSite: TDynSiteForm;
  mObj: TNxCustomBusinessObject;
  mID: string;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 mBookmark : TBookmarkList;
 i:integer;
begin
   //if Sender is TComponent then begin
    mSite := TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');


    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    if Assigned(mSite.CurrentObject) then begin

              if mBookmark.count=0 then begin

                       CreateFile(mSite.CurrentObject,index,msite);

               end else begin
                   ProgressInit(msite, 'Zpracování souboru ' + '', 100);
                   for i := 0 to mBookmark.Count- 1 do begin
                                    ProgressSetPos(1+NxFloor(i/mBookmark.Count*99), inttostr(i) +' z '+inttostr(mBookmark.Count));
                                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                    CreateFile(mSite.CurrentObject,index,msite);
                    end;
                   ProgressDispose()   ;
              end;






      end;
  NxShowSimpleMessage('Zpracování bylo dokončeno',nil);
end;



procedure CreateFile(mBO:TNxCustomBusinessObject;index:integer;mSite: TDynSiteForm);
var
  zadej:string;
  mfilename:string;
  mdir,mfile,mtargetdir,mtargetFile:string;
  mid:string;
  mXMLHead : TNxScriptingXMLWrapper;
  mdate:double;
  mdatestring:string;
  mhelpfilename:string;
  I:integer;
  mstring:string;
begin


              if index=0 then begin


                                     if true then begin
                                                 try
                                                      Create_folder(mbo);



                                                       PromptForFileName(mFileName, '*.pdf', mdir, 'Soubor *', '', False) ;
                                                           mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
                                                           mFile:=copy(mfilename,4+NxCharPosR('\',mfilename),Length(mfilename));
                                                           mFile:=copy(mFile,1,(Length(mFile)-4));

                                                          mtargetdir:=Format('%s\%s\%s', ['\\10.5.5.150\archiv', mbo.GetFieldValueAsString('Period_id.code'),mbo.GetFieldValueAsString('Docqueue_id.code')]);
                                                             mtargetFile:=Format('%s_%s_%s', [inttostr(mbo.GetFieldValueAsInteger('Ordnumber')),
                                                             mbo.GetFieldValueAsString('Docqueue_id.code'),
                                                             mbo.GetFieldValueAsString('Period_id.code')

                                                             ]);

                                                      // NxShowSimpleMessage(mtargetdir+'\'+mtargetFile + RightStr(mFileName,4),nil);


                                                       if not FileExists(mtargetdir+'\'+mtargetFile + RightStr(mFileName,4)) then begin
                                                         // NxShowSimpleMessage(mFileName   +   '   '   + mtargetdir+'\'+mtargetFile + RightStr(mFileName,4),nil);


                                                                                  if NxCopyFile(mFileName,(mtargetdir+'\'+mtargetFile + RightStr(mFileName,4))) then begin
                                                                                           DeleteFile(mFileName);
                                                                                  end;


                                                       end else begin

                                                       {
                                                              I:=1;
                                                               mhelpfilename:= mtargetdir+'\'+mtargetFile +'_'+IntToStr(I) + RightStr(mFileName,4);
                                                               while FileExists(mtargetdir+'\'+mtargetFile +'_'+IntToStr(I) + RightStr(mFileName,4)) do begin
                                                                      mhelpfilename:= mtargetdir+'\'+mtargetFile +'_'+IntToStr(I+1) + RightStr(mFileName,4);
                                                                   I:=I+1;
                                                               end;
                                                               //NxShowSimpleMessage('mhelpfilename',nil);
                                                               if NxCopyFile(mFileName,mhelpfilename) then begin
                                                                                           DeleteFile(mFileName);
                                                                end;

                                                        }

                                                       end;
                                                   finally

                                                   end;
                                     end;
             end;

end;



begin
end.