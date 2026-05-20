uses
  'abra.cz.servis.fika.FolderSupport.Common';

const
  // Podadresar pro obrazky ke skladovym kartam
  C_ScImgSubPath = 'Abra_ESHOP_images\StoreCards';
  // Podadresar pro dokumenty ke skladovym kartam
  C_ScDocSubPath =  'documents';
  // Podadresar pro obrazky ke skladovemu menu
  C_SmImgSubPath = '\\\SRV-BMS-ABRA\Abra_ESHOP_images\StoreMenu';
  // Klicovy field, dle ktereho se nacitaji skladove karty na eshop. (Stejny musi byt uveden i we web.configu.)
  C_ScKeyField = 'X_Eshop';
  // Klicovy field, dle ktereho se nacita skladove menu na eshop. (Stejny musi byt uveden i we web.configu.)
  C_SmKeyField = 'X_Eshop';


// Vytvoreni adresaru pro skladovou kartu, vola se jak z agendy tak z BO
function CallCreateScFolder(ABo: TNxCustomBusinessObject; AShowErr: Boolean): Boolean;
begin
  Result := False;
//  if CreateFolderEshop2(C_ScImgSubPath, ABo.GetFieldValueAsString('X_ImagesPath'), AShowErr) then begin
  if CreateFolderEshop2(ABo.GetFieldValueAsString('X_ImagesPath'), '', AShowErr) then begin
    // U dokumentu se predpoklada, ze budou rozdilne dle lokalizace
    {if CreateFolderEshop2(C_ScDocSubPath, ABo.GetFieldValueAsString('X_DocumentsPath')+'\'+'CS', AShowErr) then begin
      if CreateFolderEshop2(C_ScDocSubPath, ABo.GetFieldValueAsString('X_DocumentsPath')+'\'+'ENUS', AShowErr) then begin
        if CreateFolderEshop2(C_ScDocSubPath, ABo.GetFieldValueAsString('X_DocumentsPath')+'\'+'SK', AShowErr) then begin
          if CreateFolderEshop2(C_ScDocSubPath, ABo.GetFieldValueAsString('X_DocumentsPath')+'\'+'DE', AShowErr) then begin
            Result := True;
          end;
        end;
      end;
    end;  }
  end;
end;


//Vytvoreni adresaru pro skladove menu, vola se jak z agendy tak z BO
function CallCreateSmFolder(ABo: TNxCustomBusinessObject; AShowErr: Boolean): Boolean;
begin
  if CreateFolderEshop3(C_SmImgSubPath, ABo.GetFieldValueAsString('ID'), AShowErr) then begin
    Result := True;
  end else begin
    Result := False;
  end;
end;


begin
end.
