{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
var
  mr:TStringList;
  i,j:integer;
  mlist:string;
  mB:Boolean;
  mKarton:integer;
  mWeight:double;

begin
 mlist:='';
 mkarton:=0;
 if self.OutputDocument.GetFieldValueAsString('Docqueue_ID')='O200000101' then begin
 //NxShowSimpleMessage(inttostr(self.InputDocumentCount),nil);
    for i:=0 to self.InputDocumentCount-1 do begin
          if i<>0 then mlist:=mlist + ','  ;
              if self.InputDocuments[i].GetFieldValueAsInteger('U_karton')>0 then mkarton:=mkarton + self.InputDocuments[i].GetFieldValueAsInteger('U_karton');

          mlist:=mlist+QuotedStr(self.InputDocuments[i].oid);
         // NxShowSimpleMessage(mlist,nil);
          i:=i+1;
    end;
    if mkarton=0 then mkarton:=1;
  //  NxShowSimpleMessage(mlist,nil);
   // NxShowSimpleMessage(IntToStr(mKarton),nil);


         //    mb:=InputQuery('AA','AA', 'SELECT sum(((SU.Weight* CASE WHEN (SU.WeightUnit=0) THEN 0.001 WHEN (SU.WeightUnit=2) THEN 1000 ELSE 1 END )*(CAST(RO2.Quantity as Float) / RO2.Unitrate)) + ((select sum(susc.Weight* CASE WHEN (SUSC.WeightUnit=0) THEN 0.001  WHEN (SUSC.WeightUnit=2) THEN 1000 ELSE 1 END) From storecards sc left join storecards scsc on sc.X_krabicka_ID=scsc.ID left join StoreUnits susc on SUsc.Parent_ID=scsc.id  where sc.id=RO2.StoreCard_ID) *(CAST(RO2.Quantity as Float) / RO2.Unitrate))) ' +
         //     ' FROM StoreDocuments2 RO2, StoreUnits SU WHERE (RO2.StoreCard_ID IS NOT NULL) AND SU.Parent_ID=RO2.StoreCard_ID AND SU.Code=RO2.QUnit and (RO2.Parent_ID in (' +
         //     mlist   +
         //
         //     '))') ;



    mr:=tstringlist.create;
    try


    //      self.OutputDocument.ObjectSpace.SQLSelect('SELECT sum(((SU.Weight* CASE WHEN (SU.WeightUnit=0) THEN 0.001 WHEN (SU.WeightUnit=2) THEN 1000 ELSE 1 END )*(CAST(RO2.Quantity as Float) / RO2.Unitrate)) + ((select sum(susc.Weight* CASE WHEN (SUSC.WeightUnit=0) THEN 0.001  WHEN (SUSC.WeightUnit=2) THEN 1000 ELSE 1 END) From storecards sc left join storecards scsc on sc.X_krabicka_ID=scsc.ID left join StoreUnits susc on SUsc.Parent_ID=scsc.id  where sc.id=RO2.StoreCard_ID) *(CAST(RO2.Quantity as Float) / RO2.Unitrate))) ' +
    //          ' FROM StoreDocuments2 RO2, StoreUnits SU WHERE (RO2.StoreCard_ID IS NOT NULL) AND SU.Parent_ID=RO2.StoreCard_ID AND SU.Code=RO2.QUnit and (RO2.Parent_ID in (' +
    //          mlist   +
    //
    //          '))',mr);


//              self.OutputDocument.ObjectSpace.SQLSelect('SELECT SUM((SU.Weight* CASE WHEN (SU.WeightUnit=0) THEN 0.001 ' +
//                                                        ' WHEN (SU.WeightUnit=2) THEN 1000 ELSE 1 END )*(CAST(RO2.Quantity as Float) / RO2.Unitrate)), ' +
//                                                        ' ro2.parent_ID FROM StoreDocuments2 RO2, StoreUnits SU WHERE ' +
//                                                        ' (RO2.StoreCard_ID IS NOT NULL) AND SU.Parent_ID=RO2.StoreCard_ID AND SU.Code=RO2.QUnit and ' +
//                                                        ' (RO2.Parent_ID in (' + mlist   + ')) GROUP BY RO2.Parent_ID ',mr);



            self.OutputDocument.ObjectSpace.SQLSelect('SELECT ((SU.Weight* CASE WHEN (SU.WeightUnit=0) THEN 0.001 WHEN (SU.WeightUnit=2) THEN 1000 ELSE 1 END )*(CAST(RO2.Quantity as Float) / RO2.Unitrate))+ ' +

                  ' ((select sum(susc.Weight* CASE WHEN (SUSC.WeightUnit=0) THEN 0.001  WHEN (SUSC.WeightUnit=2) THEN 1000 ELSE 1 END) ' +
' From storecards sc left join storecards scsc on sc.X_krabicka_ID=scsc.ID left join StoreUnits susc on SUsc.Parent_ID=scsc.id  ' +
' where sc.id=RO2.StoreCard_ID) *(CAST(RO2.Quantity as Float) / RO2.Unitrate)) ' +



                                                        ' FROM StoreDocuments2 RO2, StoreUnits SU '+

                                                        ' WHERE '+
                                                        ' (RO2.StoreCard_ID IS NOT NULL) AND SU.Parent_ID=RO2.StoreCard_ID AND SU.Code=RO2.QUnit and '+
                                                        ' (RO2.Parent_ID in (' + mlist   + '))',mr);



                                                   if mr.count>0 then begin
                                                      //NxShowSimpleMessage(mr.Strings[0],nil);
                                                      mWeight:=0;
                                                      for j:=0 to mr.count-1 do begin
                                                               mWeight:=mWeight + NxIBStrToFloat(mr.Strings[j]);
                                                      end;

                                                      mWeight:=mWeight+ (0.2*mKarton);
                                                      if self.OutputDocument.getFieldValueAsFloat('U_weight')=0 then self.OutputDocument.SetFieldValueAsFloat('U_weight',mWeight)
//                                                      else self.OutputDocument.SetFieldValueAsFloat('U_weight',(self.OutputDocument.getFieldValueAsFloat('U_weight') + mWeight))
                                                      ;
                                                   end;




    finally
        mr.free;
    end;

end;
end;


begin
end.