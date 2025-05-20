pageextension 50112 ItemCardExt extends "Item Card"
{
    actions
    {
        addfirst(processing)
        {
            action(GenerateQRCode)
            {
                ApplicationArea = All;
                Caption = 'Generate QR Code';
                Image = CreateDocument;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    BarcodeAPIURL: Text;
                    Client: HttpClient;
                    HttpResponseMsg: HttpResponseMessage;
                    HttpRequestMsg: HttpRequestMessage;
                    InS: InStream;
                    OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?';
                    MustSpecifyDescriptionErr: Label 'You must add a description to the item before you can import a picture.';
                    FileName: Text;
                    BarcodeTypes: Label 'QR Code, Data Matrix, Aztec, Telepen, Swiss QR Code';
                    Selection: Integer;
                begin
                    if Rec.Description = '' then
                        Error(MustSpecifyDescriptionErr);
                    if Rec.Picture.Count > 0 then
                        if not Confirm(OverrideImageQst) then
                            Error('');
                    FileName := Rec.Description + '.png';
                    Selection := StrMenu(BarcodeTypes);
                    case
                        Selection of
                        1:
                            BarcodeAPIURL := 'https://quickchart.io/barcode?type=' + 'qrcode' + '&text=' + Rec."No." + '_' + Rec.Description + '&width=200&height=200&format=png';
                        2:
                            BarcodeAPIURL := 'https://quickchart.io/barcode?type=' + 'datamatrix' + '&text=' + Rec."No." + '_' + Rec.Description + '&width=200&height=200&format=png';
                        3:
                            BarcodeAPIURL := 'https://quickchart.io/barcode?type=' + 'azteccode' + '&text=' + Rec."No." + '_' + Rec.Description + '&width=200&height=200&format=png';
                        4:
                            BarcodeAPIURL := 'https://quickchart.io/barcode?type=' + 'telepen' + '&text=' + Rec."No." + '_' + Rec.Description + '&width=200&height=200&format=png';
                        5:
                            BarcodeAPIURL := 'https://quickchart.io/barcode?type=' + 'swissqrcode' + '&text=' + Rec."No." + '_' + Rec.Description + '&format=png';
                    end;
                    HttpRequestMsg.SetRequestUri(BarcodeAPIURL);
                    if Client.Send(HttpRequestMsg, HttpResponseMsg) then begin
                        if HttpResponseMsg.IsSuccessStatusCode() then begin
                            HttpResponseMsg.Content.ReadAs(InS);
                            Clear(Rec.Picture);
                            Rec.Picture.ImportStream(InS, FileName);
                            Rec.Modify(true);
                        end;
                    end else
                        Error('Failed to send request to the API.');
                end;
            }
        }
    }
}
