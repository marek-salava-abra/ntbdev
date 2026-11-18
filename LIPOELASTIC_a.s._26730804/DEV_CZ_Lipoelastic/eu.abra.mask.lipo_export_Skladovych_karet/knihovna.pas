procedure Export(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mContext: TNxContext;
  mIDs: TStrings;
  mDynSourceID, mExportID, mFileName, mSQL: String;
  mCommand: Integer;
  mFTP: TFTP;
begin
  Success := True;
  LogInfoStr := '';
  mContext := NxCreateContext(OS);
  mDynSourceID := 'WA5RFWVCCS1OZBTMPPWMQN252O';
  mExportID := '1E00000101';
  mCommand := 2;
   mFileName := 'D:\E_SHOP\EXPORT\Storecards\storecards.xml';     //pozor, cesta je vzhledem k autoserveru

  mSQL:='Select id from storecards where hidden = ''N'' ';





  try
    mIDs := TStringList.Create;
    OS.SQLSelect(mSQL,mIDs);
//    showmessage(inttostr(mids.count));
    NxExportByIDs(mContext, mIDs, mDynSourceID, mExportID, mCommand, '', mFileName);
        mFTP := TFTP.Create;
          try
            // pasivní režim komunikace není třeba explicitně nastavovat, defaultní hodnot je True
            //mFTP.Passive := True;
            // nastavíme přístupové parametry spojení
            mFTP.Host := 'lipoelastic-medical-products.com.uvirt35.active24.cz';
            mFTP.Username:= 'lipoelasti7';
            mFTP.Password:= 'z1m7OqTEBC';


            mFTP.Connect;   // otevřeme spojení na FTP server
                  try
                       mFTP.Put('D:\E_SHOP\EXPORT\Storecards\storecards.xml','storecards.xml');
                  finally
                    // uzavřeme spojení na FTP server
                    mFTP.Disconnect;
                  end;
          finally
            mFTP.Free;
          end;
  finally
    mIDs.Free;
  end;
end;




procedure ftp_OnExecute(Sender: TObject);
var
  mParent: TForm;
  mFTP: TFTP;
  mList: TStringList;
  mStream: TMemoryStream;
  mBytes: TBytes;
begin
  mParent := TComponent(Sender).Site.GetParentForm;
  mFTP := TFTP.Create;
  try
    // pasivní režim komunikace není třeba explicitně nastavovat, defaultní hodnot je True
    //mFTP.Passive := True;
    // nastavíme přístupové parametry spojení
    mFTP.Host := 'lipoelastic-medical-products.com.uvirt35.active24.cz';
    mFTP.Username:= 'lipoelasti7';
    mFTP.Password:= 'z1m7OqTEBC';


    mFTP.Connect;   // otevřeme spojení na FTP server
    try

      mList := TStringList.Create;          // *** přečteme obsah rootu otevřeného FTP bez detailů
      try
        mFTP.MakeDir('StoreBatch');        // *** vytvoříme adresář ...
//        mFTP.ChangeDir('StoreBatch');        // nastavíme nový adresář jako aktuální
        mStream := TMemoryStream.Create;          // *** připravíme stream k uložení do souboru na FTP serveru
        try
          mStream.WriteString('erlklh hj ghergj herkjg hkejh gkewjr ghjkew hgkwjegr hkwrgjkwjhgkwrjgjk', TEncoding.ANSI.GetCodePage);

          // *** nastavíme stream na začátek a uložíme jeho data streamu do souboru v aktuálním adresáři
          mStream.Position := 0;
          //mFTP.PutFromStream(mStream, 'StoreBatch.txt');
          mFTP.Put('StoreBatch.txt','StoreBatch.txt');
  //        mFTP.List(mList); ShowMessage('Obsah adresáře StoreBatch:'#13#10#13#10 + mList.Text, mParent);// přečteme obsah aktuálního adresáře


   //       mStream.Clear; mFTP.GetToStream('StoreBatch.txt', mStream); // *** načteme soubor z FTP do streamu
   //       mStream.Position := 0;

   //       ShowMessage('Obsah souboru StoreBatch.txt přečteného z FTP serveru:'#13#10#13#10 +  '"' + TEncoding.ANSI.GetString(mStream.GetBytes) + '".', mParent);   // *** zobrazíme přečtená data

          // *** vymažeme soubor FTP_TEST.txt z FTP serveru
          //mFTP.Delete('FTP_TEST.txt');
          // *** přepneme se zpět do rootu, vymažeme adresář FTP_TEST
          //mFTP.ChangeDirUp;
          //mFTP.RemoveDir('StoreBatch');
        finally
          mStream.Free;
        end;
      finally
        mList.Free;
      end;
    finally
      // uzavřeme spojení na FTP server
      mFTP.Disconnect;
    end;
  finally
    mFTP.Free;
  end;
  ShowMessage('HOTOVO.', mParent);
end;






begin
end.