uses '_GlobalSettings.Konstanty';

Function NxGetAPIHeadJSON(os:TNxCustomObjectSpace;self:TNxCustomBusinessObject;mTypImportu:string;mUser:string):string;
var
mquery:String;
i:integer;
mfind:boolean;
begin
 try
 mquery:='{'   +chr(10);



                                                                  if (mTypImportu='Routine') or (mTypImportu='PieceList') then begin
                                                                      mquery:=mquery + ' "input_document_clsid":"' +  ''  +'", ';
                                                                              if (mTypImportu='Routine') then mquery:=mquery + ' "output_document_clsid":"' +  'RW2YIIHUHP3OZCQ5RQR5SJQWI4'  +'", '+chr(10);
                                                                              if (mTypImportu='PieceList') then mquery:=mquery + ' "output_document_clsid":"' +  '031N4GRZ4OT4TC5LYFK2WV1IFS'  +'", '+chr(10);

                                                                              mfind:=false;

                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  ''  +'", ';
                                                                                                // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  ''  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;


                                                                   end;
                                                                   // op
                                                                   if mTypImportu='OP' then begin
                                                                              mquery:=mquery + ' "input_document_clsid":"' +  '01CPMINJW3DL342X01C0CX3FCC'  +'", ';
                                                                              mquery:=mquery + ' "output_document_clsid":"' +  '01CPMINJW3DL342X01C0CX3FCC'  +'", '+chr(10);
                                                                              mfind:=false;
                                                                                   case self.GetFieldValueAsString('DocQueue_ID.CODE') of
                                                                                     'OVG': begin
                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'SOPG'  +'", ';
                                                                                                // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  self.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  'mskacel@lipoelastic.com;kondrickova@lipoelastic.sk;zorlikova@lipoelastic.sk'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  'YP00000101'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  'Supervisor'  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;

                                                                                             end;
                                                                                      'OV1': begin
                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'SOP1'  +'", ';
                                                                                                // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  self.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S999'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  '0'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  'mskacel@lipoelastic.com;kondrickova@lipoelastic.sk;zorlikova@lipoelastic.sk'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  'YP00000101'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  'Supervisor'  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;

                                                                                             end;


                                                                                   end;
                                                                                     if not mFind then begin
                                                                                          mquery:=mquery + ' "DocQueue_Code":"' +  'SOP1'  +'", ';
                                                                                           // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  self.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                     end;

                                                                   end;

                                                                   // ov
                                                                   if mTypImportu='OV' then begin
                                                                              mquery:=mquery + ' "input_document_clsid":"' +  '01CPMINJW3DL342X01C0CX3FCC'  +'", ';
                                                                              mquery:=mquery + ' "output_document_clsid":"' +  'CDMK5QAWZZDL342X01C0CX3FCC'  +'", '+chr(10);
                                                                              mfind:=false;
                                                                                   case self.GetFieldValueAsString('DocQueue_ID.CODE') of
                                                                                     'OPSE': begin
                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'SOVE'  +'", ';
                                                                                                // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  self.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                             end;
                                                                                        'OPSB': begin
                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'SOVB'  +'", ';
                                                                                                // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  self.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  'mskacel@lipoelastic.com'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  '2NI0000101'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  'SUPER00000'  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                             end;
                                                                                         'OVG': begin
                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'SOVG'  +'", ';
                                                                                                // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  self.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  'mskacel@lipoelastic.com;kondrickova@lipoelastic.sk;zorlikova@lipoelastic.sk'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  '2NI0000101'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  'SUPER00000'  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                             end;
                                                                                              'OV1': begin
                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'SOV1'  +'", ';
                                                                                                // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  self.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S999'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  'mskacel@lipoelastic.com;kondrickova@lipoelastic.sk;zorlikova@lipoelastic.sk'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  '2NI0000101'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  'SUPER00000'  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                             end;

                                                                         end;




                                                                                     if not mFind then begin
                                                                                          mquery:=mquery + ' "DocQueue_Code":"' +  'SOVE'  +'", ';
                                                                                           // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  self.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  'mskacel@lipoelastic.com'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  '2NI0000101'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  'SUPER00000'  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                     end;

                                                                   end;


                                                                   // pr
                                                                   if mTypImportu='PR' then begin
                                                                              mquery:=mquery + ' "input_document_clsid":"' +  'CDMK5QAWZZDL342X01C0CX3FCC'  +'", ';
                                                                              mquery:=mquery + ' "output_document_clsid":"' +  'E03ZNUMDTCC4PDAUIEY1MBTJC0'  +'", '+chr(10);
                                                                              mfind:=false;
                                                                                   case self.GetFieldValueAsString('DocQueue_ID.CODE') of
                                                                                     'DPPO': begin
                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'SPVM'  +'", ';
                                                                                                // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  'LIPOELASTIC a.s.'  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S0103'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                             end;
                                                                                     'DPE': begin
                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'SPPT'  +'", ';
                                                                                                // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  'LIPOELASTIC a.s.'  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                             end;
                                                                                      'DPVZ': begin
                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'SPPT'  +'", ';
                                                                                                // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  'LIPOELASTIC a.s.'  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                             end;
                                                                                        'DMA': begin
                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'SPVM'  +'", ';
                                                                                                // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  'LIPOELASTIC a.s.'  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S0103'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  'HD00000101'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  'mskacel@lipoelastic.com;akrenkova@lipoelastic.com'  +'",'+chr(10);         //mskacel@lipoelastic.com;kondrickova@lipoelastic.sk;zorlikova@lipoelastic.sk
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                             end;
                                                                                   end;
                                                                                     if not mFind then begin
                                                                                          mquery:=mquery + ' "DocQueue_Code":"' +  'SPPT'  +'", ';
                                                                                           // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  self.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                     end;

                                                                   end;

                                                                   // dl
                                                                   if mTypImportu='DL' then begin
                                                                              mquery:=mquery + ' "input_document_clsid":"' +  '01CPMINJW3DL342X01C0CX3FCC'  +'", ';
                                                                              mquery:=mquery + ' "output_document_clsid":"' +  '050I5SAOS3DL3ACU03KIU0CLP4'  +'", '+chr(10);
                                                                              mfind:=false;
                                                                                   case self.GetFieldValueAsString('DocQueue_ID.CODE') of
                                                                                     'DPE': begin
                                                                                             if os.SQLSelectFirstAsString('select DQ.Code from storedocuments2 sd2 left join Receivedorders RO on ro.id=sd2.Provide_ID left join docqueues DQ on dq.id=ro.docqueue_ID where parent_ID=' + QuotedStr(self.oid),'') = 'OPSB' then begin
                                                                                                          mquery:=mquery + ' "DocQueue_Code":"' +  'SDPE'  +'", ';
                                                                                                        // nastavení
                                                                                                            mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                            mquery:=mquery + ' "Firm_Name":"' + '' +'", ';
                                                                                                            mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                            mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                        // volby
                                                                                                            mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                            mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                            mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                            mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                            mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                        // reporting
                                                                                                            mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                            mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                            mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                        // lazení
                                                                                                            mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                            mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                            mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                            mfind:=true;
                                                                                                end else begin
                                                                                                        mquery:=mquery + ' "DocQueue_Code":"' +  'SDPI'  +'", ';
                                                                                                        // nastavení
                                                                                                            mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                            mquery:=mquery + ' "Firm_Name":"' + '' +'", ';
                                                                                                            mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                            mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                        // volby
                                                                                                            mquery:=mquery + ' "ImportAllDocument":"' +  'True'  +'",'+chr(10);
                                                                                                            mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                            mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                            mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                            mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                        // reporting
                                                                                                            mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                            mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                            mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                        // lazení
                                                                                                            mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                            mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                            mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                            mfind:=true;
                                                                                                end;

                                                                                              end;
                                                                                     'DPVZ': begin
                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'SDPV'  +'", ';
                                                                                                // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' + '' +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'TRUE'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                          end;
                                                                                   end;




                                                                                   if not mfind then begin
                                                                                   case copy(self.GetFieldValueAsString('Description'),1,4) of
                                                                                              'SOVB': begin
                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'SDPE'  +'", ';
                                                                                                // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' + '' +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'TRUE'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                             end;
                                                                                             'SOVE': begin
                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'SDPI'  +'", ';
                                                                                                // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'TRUE'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                             end;
                                                                                         end;

                                                                                     end;
                                                                                     if not mFind then begin
                                                                                         mquery:=mquery + ' "DocQueue_Code":"' +  'SDPI'  +'", ';
                                                                                          // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                     end;

                                                                   end;

                                                                   // prev
                                                                   if mTypImportu='PRV' then begin
                                                                              mquery:=mquery + ' "input_document_clsid":"' +  '01CPMINJW3DL342X01C0CX3FCC'  +'", ';
                                                                              mquery:=mquery + ' "output_document_clsid":"' +  '0P0I5SAOS3DL3ACU03KIU0CLP4'  +'", '+chr(10);
                                                                              mfind:=false;
                                                                                   case self.GetFieldValueAsString('DocQueue_ID.CODE') of
                                                                                     '': begin
                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'XPT'  +'", ';
                                                                                                // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  self.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                             end;
                                                                                   end;
                                                                                     if not mFind then begin
                                                                                           mquery:=mquery + ' "DocQueue_Code":"' +  'XPT'  +'", ';
                                                                                           // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  self.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                     end;

                                                                   end;
                                                                   // prep
                                                                   if mTypImportu='PRP' then begin
                                                                              mquery:=mquery + ' "input_document_clsid":"' +  '0P0I5SAOS3DL3ACU03KIU0CLP4'  +'", ';
                                                                              mquery:=mquery + ' "output_document_clsid":"' +  'E03ZNUMDTCC4PDAUIEY1MBTJC0'  +'", '+chr(10);
                                                                              mfind:=false;
                                                                                   case self.GetFieldValueAsString('DocQueue_ID.CODE') of
                                                                                     '': begin
                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'YPT'  +'", ';
                                                                                                // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  self.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                             end;
                                                                                   end;
                                                                                     if not mFind then begin
                                                                                         mquery:=mquery + ' "DocQueue_Code":"' +  'YPT'  +'", ';
                                                                                          // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  self.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                     end;

                                                                   end;
                                                                   if mTypImportu='FV' then begin
                                                                              mquery:=mquery + ' "input_document_clsid":"' +  '01CPMINJW3DL342X01C0CX3FCC'  +'", ';
                                                                              mquery:=mquery + ' "output_document_clsid":"' +  'O3BDOKTWEFD13ACM03KIU0CLP4'  +'", '+chr(10);
                                                                              mfind:=false;
                                                                                   case self.GetFieldValueAsString('DocQueue_ID.CODE') of
                                                                                     '': begin
                                                                                               mquery:=mquery + ' "DocQueue_Code":"' +  'FVT'  +'", ';
                                                                                                // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  self.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Import":"' +  'A'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                             end;
                                                                                   end;
                                                                                     if not mFind then begin
                                                                                          mquery:=mquery + ' "DocQueue_Code":"' +  'FVT'  +'", ';
                                                                                           // nastavení
                                                                                                    mquery:=mquery + ' "User":"' +  mUser  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Firm_Name":"' +  self.GetFieldValueAsString('Firm_ID.name')  +'", ';
                                                                                                    mquery:=mquery + ' "Store_Code":"' +  'S22'  +'", ';
                                                                                                    mquery:=mquery + ' "Division_Code":"' +  'SK'  +'", '+chr(10);
                                                                                                // volby
                                                                                                    mquery:=mquery + ' "ImportAllDocument":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "WithPrices":"' +  'True'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Sales":"' +  'False'  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "ImportBatches":"' +  'True'  +'", ';
                                                                                                // reporting
                                                                                                    mquery:=mquery + ' "Email":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Report_ID":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Msg":"' +  ''  +'",'+chr(10);
                                                                                                // lazení
                                                                                                    mquery:=mquery + ' "StoreDocQueue_Code":"' +  ''  +'", ';
                                                                                                    mquery:=mquery + ' "DocumentType":"' +  ''  +'",'+chr(10);
                                                                                                    mquery:=mquery + ' "Debug":"' +  'False'  +'",'+chr(10);
                                                                                                 mfind:=true;
                                                                                     end;


                                                                   end;

                                                                              mquery:=mquery + ' "InputDocuments":["' +  ''  +'" ' + '],';
                                                                              mquery:=mquery + ' "SelectedHeader":"' +  ''  +'" ,';
                                                                              mquery:=mquery + ' "SelectedRows":["' +  ''  +'" ' + '],'+chr(10);

                                                                              mquery:=mquery + ' "AbraDocuments":[';


       finally
            result:=mquery;
       end;
end;










begin
end.