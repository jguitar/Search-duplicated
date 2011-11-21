unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, xmldom, XMLIntf, msxmldom, XMLDoc, Contnrs;

type
  TUses = class
  private
    FSoloNombreProyecto: string;
    FSoloNombreUnit: string;
    FProyecto: string;
    FNombre: string;
    procedure SetProyecto(const Value: string);
    function GetNombre: string;
    procedure SetNombre(const Value: string);
    function GetProyecto: string;
  public
    property Proyecto: string read GetProyecto write SetProyecto;
    property Nombre: string read GetNombre write SetNombre;
    function GetSoloNombreProyecto: string;
    function GetSoloNombreUnit: string;
  end;

  TFMain = class(TForm)
    lblGrupo: TLabel;
    edtGrupo: TEdit;
    btnBuscarArchivo: TButton;
    btnProcesar: TButton;
    XMLDocument1: TXMLDocument;
    dlgOpenProyectos: TOpenDialog;
    procedure btnProcesarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnBuscarArchivoClick(Sender: TObject);
  private
    FListaUses: TObjectList;
    procedure EliminarUsesSinDuplicar;
    procedure ExtraerUses(AProyectos: TStrings);
    procedure GenerarTxt;
    procedure GetProyectos(var AProyectos: TStrings; const AFileName: string);
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

{$R *.dfm}

procedure TFMain.btnProcesarClick(Sender: TObject);
var
  ListaProyectos: TStrings;
begin
   ListaProyectos := TStringList.Create;
  try
    GetProyectos(ListaProyectos, edtGrupo.Text);
    ExtraerUses(ListaProyectos);
  finally
    ListaProyectos.Free;
  end;

  EliminarUsesSinDuplicar;
  GenerarTxt;
  ShowMessage('Proceso terminado.');
end;

procedure TFMain.btnBuscarArchivoClick(Sender: TObject);
begin
  if dlgOpenProyectos.Execute then
    edtGrupo.Text := dlgOpenProyectos.FileName;
end;

procedure TFMain.EliminarUsesSinDuplicar;
var
  i, j: Integer;
  FileUses1, FileUses2: TUses;
  Duplicado: Boolean;
begin
  for i := FListaUses.Count - 1 downto 0 do
  begin
    FileUses1 := FListaUses.Items[i] as TUses;
    Duplicado := False;

    for j := 0 to FListaUses.Count - 1 do
    begin
      FileUses2 := FListaUses.Items[j] as TUses;

      if (UpperCase(FileUses1.GetSoloNombreUnit) = UpperCase(FileUses2.GetSoloNombreUnit)) and
        (UpperCase(FileUses1.Nombre) <> UpperCase(FileUses2.Nombre)) then
      begin
        Duplicado := True;
        Break;
      end;
    end;

    if not Duplicado then
      FListaUses.Delete(i);
  end;
end;

procedure TFMain.ExtraerUses(AProyectos: TStrings);
var
  ItemGroup: IXMLNode;
  DCCReference: IXMLNode;
  i, j, k: Integer;
  FileUses: TUses;
begin
  // Para cada proyecto extraer los uses
  for i := 0 to AProyectos.Count - 1 do
  begin
    XMLDocument1.FileName := AProyectos.Strings[i];
    XMLDocument1.Active := True;
    try
      for j := 0 to XMLDocument1.DocumentElement.ChildNodes.Count - 1 do
      begin
        ItemGroup := XMLDocument1.DocumentElement.ChildNodes.Nodes[j];
        if ItemGroup.NodeName = 'ItemGroup' then
        begin
          for k := 0 to ItemGroup.ChildNodes.Count - 1 do
          begin
            DCCReference := ItemGroup.ChildNodes.Nodes[k];
            if DCCReference.NodeName = 'DCCReference' then
            begin
              FileUses := TUses.Create;
              FileUses.Proyecto := AProyectos.Strings[i];
              FileUses.Nombre := DCCReference.Attributes['Include'];

              FListaUses.Add(FileUses);
            end;
          end;
        end;
      end;
    finally
      XMLDocument1.Active := False;
    end;
  end;
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  FListaUses := TObjectList.Create(True);
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  FListaUses.Free;
end;

procedure TFMain.GenerarTxt;
var
  i: Integer;
  Txt: TStringList;
  s: string;
  FileUses: TUses;
begin
  Txt := TStringList.Create;
  try
    for i := 0 to FListaUses.Count - 1 do
    begin
      FileUses := FListaUses.Items[i] as TUses;
      s := FileUses.GetSoloNombreUnit + #9 + FileUses.Nombre + #9 + FileUses.GetSoloNombreProyecto;
      Txt.Add(s);
    end;
    Txt.Sort;
    SetCurrentDir(ExtractFilePath(Application.ExeName));
    Txt.SaveToFile('UsesDuplicados.txt');
  finally
    Txt.Free;
  end;
end;

procedure TFMain.GetProyectos(var AProyectos: TStrings; const AFileName: string);
var
  ItemGroup: IXMLNode;
  Proyecto: IXMLNode;
  i, j: Integer;
begin
  // Encontrar los proyectos
  XMLDocument1.FileName := AFileName;
  XMLDocument1.Active := True;
  try
    for i := 0 to XMLDocument1.DocumentElement.ChildNodes.Count - 1 do
    begin
      ItemGroup := XMLDocument1.DocumentElement.ChildNodes.Nodes[i];
      if ItemGroup.NodeName = 'ItemGroup' then
      begin
        for j := 0 to ItemGroup.ChildNodes.Count - 1 do
        begin
          Proyecto := ItemGroup.ChildNodes.Nodes[j];
          if Proyecto.NodeName = 'Projects' then
            AProyectos.Add(ExtractFilePath(AFileName) + Proyecto.Attributes['Include']);
        end;
      end;
    end;
  finally
    XMLDocument1.Active := False;
  end;
end;

{ TUses }

function TUses.GetNombre: string;
begin
  if SetCurrentDir(ExtractFilePath(Proyecto)) then
    Result := ExpandFileName(FNombre)
  else
    Result := FNombre;
end;

function TUses.GetProyecto: string;
begin
  Result := FProyecto;
end;

function TUses.GetSoloNombreProyecto: string;
begin
  Result := FSoloNombreProyecto;
end;

function TUses.GetSoloNombreUnit: string;
begin
  Result := FSoloNombreUnit;
end;

procedure TUses.SetNombre(const Value: string);
begin
  FNombre := Value;
  FSoloNombreUnit := ChangeFileExt(ExtractFileName(Nombre), '');
end;

procedure TUses.SetProyecto(const Value: string);
begin
  FProyecto := Value;
  FSoloNombreProyecto := ChangeFileExt(ExtractFileName(Proyecto), '');
end;

end.
