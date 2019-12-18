unit uclassExportJson;

{$mode objfpc}{$H+}

interface

uses
   Db, SqlDb, ibconnection,
   fpjson, jsonparser, httpDefs, custcgi,
   Classes, SysUtils;

Type
  TClassExportJson = class

  Private
   FConn: TSqlConnection;
   FQuery: TSqlQuery;
   FTransaction: TSqlTransaction;
   AResponse: TResponse;
   // Get
   function GetQuery: TSqlQuery;
   // Set
   procedure SetQuery( const Value: TSqlQuery );
  Public
    function Execute(): TStringList;
    property Query    : TSQLQuery read GetQuery write SetQuery;
end;


implementation


function TClassExportJson.Execute(): TStringList;
var
  lJsonArray: TJSONArray;
  lJson: TJSONObject;
  lRow: TJSONObject;
  slResposta: TStringList;
  i: integer;
begin

    lJsonArray := TJSONArray.Create;
    lJson := TJSONObject.Create;
    try
      while not FQuery.Eof do
      begin
        lRow := TJSONObject.Create;
        For i:= 0 to FQuery.FieldDefs.Count-1 do
        begin
          //TJSONIntegerNumber. TJsonString.
          lRow.Add(FQuery.FieldDefs.Items[i].Name,
              TJsonString.Create( FQuery.FieldByName( FQuery.FieldDefs.Items[i].Name ).asString ) );
        end;
        FQuery.Next;
        lJsonArray.Add(lRow);
      end;
      lJson.Add('rows', lJsonArray);
      slResposta:= TStringList.create;
      slResposta.Text:= lJson.AsJSON;
      result:= slResposta;
    finally
      lJson.Free;
    end;

end;


procedure TClassExportJson.SetQuery( const Value: TSQLQuery);
begin
  FQuery:= Value;
end;
                                               
function TClassExportJson.GetQuery(): TSQLQuery;
begin
  result:= FQuery;
end;

end.

