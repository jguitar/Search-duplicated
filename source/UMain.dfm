object FMain: TFMain
  Left = 0
  Top = 0
  Caption = 'Buscador de uses duplicados'
  ClientHeight = 82
  ClientWidth = 448
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lblGrupo: TLabel
    Left = 17
    Top = 18
    Width = 95
    Height = 13
    Caption = 'Grupo de proyectos'
  end
  object edtGrupo: TEdit
    Left = 118
    Top = 15
    Width = 301
    Height = 21
    TabOrder = 0
  end
  object btnBuscarArchivo: TButton
    Left = 425
    Top = 15
    Width = 21
    Height = 21
    Caption = '...'
    TabOrder = 1
    OnClick = btnBuscarArchivoClick
  end
  object btnProcesar: TButton
    Left = 200
    Top = 49
    Width = 75
    Height = 25
    Caption = 'Procesar'
    TabOrder = 2
    OnClick = btnProcesarClick
  end
  object XMLDocument1: TXMLDocument
    Left = 312
    Top = 24
    DOMVendorDesc = 'MSXML'
  end
  object dlgOpenProyectos: TOpenDialog
    DefaultExt = '*.groupproj'
    InitialDir = 'D:\Proyectos'
    Title = 'Buscar grupo de proyectos'
    Left = 128
    Top = 40
  end
end
