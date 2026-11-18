uses
 'eu.abra.autoserver.import.fce';

procedure  ImportStoreQuantity(OS: TNxCustomObjectSpace; var ProcessContinue: Boolean;
  Directory: string; FileName: string);
var
i :Integer;
mstore_id, mStoreCardCode: String;
mQuantity:Extended;
mList: TStringList;

  
begin
   mList := TStringLIst.Create;
      try
        mList.LoadFromFile(Directory+'\'+FileName);
       for i:= 0 to mlist.Count-1 do begin
          mStore_ID:=scrGetStore_ID(OS,'Code',NxToken(mlist.Strings[i],';'));
          mStoreCardCode:=(NxToken(mlist.Strings[i],';'));
          mQuantity:= NxIBStrToFloat(NxToken(mlist.Strings[i],';'));
          updatequantity(OS,mQuantity, mStoreCardCode,mStore_ID);
       end;
     finally
     mlist.Free;
     end;
end;

begin
end.