const
 cIOForm_ID = 'A700000001';
 cEmailAccount_ID = '1010000101';
 cBody = '<!DOCTYPE html><html lang="cs"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">'+
         '<title>Potvrzení dokladu #CISLO#</title><style>'+
         ' body { margin: 0; padding: 0; font-family: sans-serif; display: flex; flex-direction: column; '+
         ' justify-content: center; align-items: center; height: 100vh; background-color: #f7f7f7; text-align: center; '+
         '     }'+
         ' .message-box {font-size: 1.5em; color: #333; padding: 20px; border: 2px solid #4caf50; border-radius: 10px; background-color: #e8f5e9; '+
         '   box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); } '+
         ' .thank-you { margin-top: 40px; font-size: 1.1em; color: #555; } '+
         '</style></head><body><div class="message-box">'+
         ' Doklad <strong>#CISLO#</strong> byl potvrzen '+
         ' </div><div class="thank-you"> #INFO# </div> </body></html>';
 cMailBody = '<!DOCTYPE html><html lang="cs"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">'+
             '<title>Potvrzení dokladu #CISLO#</title><style> '+
             ' body {margin: 0; padding: 0; font-family: sans-serif; display: flex; justify-content: center; align-items: center;'+
             ' height: 100vh; background-color: #f0f0f0; } '+
             ' .container {text-align: center;} '+
             ' .message {font-size: 1.4em; margin-bottom: 20px; color: #333;} '+
             ' .button {background-color: #4caf50; color: white; padding: 15px 30px; font-size: 1.2em;'+
             '  border: none; border-radius: 8px; text-decoration: none; display: inline-block; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); '+
             '  transition: background-color 0.2s ease-in-out; } '+
             ' .button:hover {background-color: #45a049; } '+
             '</style></head><body><div class="container"><br><br><div class="message">#DOKLAD# <strong>#CISLO#</strong> potvrdíte kliknutím na následující odkaz</div>'+
             '<a class="button" href="#URL#">Potvrdit</a></div></body></html>';
  cURL = 'http://masa-hp-ntb:822/Data/script/API/lib/Issuedorder?order_id=#DOCUMENTID#&Auth=QVBJOldlYkFQSQ';

begin
end.