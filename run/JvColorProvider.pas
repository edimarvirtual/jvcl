{-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JvColorProvider.pas, released on 2003-07-18.

The Initial Developer of the Original Code is Marcel Bestebroer
Portions created by Marcel Bestebroer are Copyright (C) 2002 - 2003 Marcel
Bestebroer
All Rights Reserved.

Contributor(s):

Last Modified: 2003-09-17

You may retrieve the latest version of this file at the Project JEDI's JVCL home page,
located at http://jvcl.sourceforge.net

Known Issues:
-----------------------------------------------------------------------------}

{$I JVCL.INC}

unit JvColorProvider;

interface

uses
  Classes, Contnrs, Graphics, Windows,
  JclBase,
  JvDataProvider, JvDataProviderImpl;

type
  TColorType = (ctStandard, ctSystem, ctCustom);
  TDefColorItem = record
    Value: TColor;
    Constant: string;
    English: string;
  end;
  TColorItem = record
    Value: TColor;
    Names: TDynStringArray;
  end;
  TColorItems = array of TColorItem;

  TJvColorProviderNameMappings = class;
  TJvColorProviderNameMapping = class;
  TJvColorProviderMapping = type Integer;

  IJvColorProvider = interface
    ['{3DF32721-553B-4759-A628-35F5CA62F3D5}']
    function IndexOfMapping(Mapping: TJvColorProviderNameMapping): Integer;
    function IndexOfMappingName(Name: string): Integer;
    function Get_MappingCount: Integer;
    function Get_Mapping(Index: Integer): TJvColorProviderNameMapping;
    function GetStandardCount: Integer;
    function GetSystemCount: Integer;
    function GetCustomCount: Integer;
    function GetStandardColor(Index: Integer; out Value: TColor; out Name: string): Boolean;
    function GetSystemColor(Index: Integer; out Value: TColor; out Name: string): Boolean;
    function GetCustomColor(Index: Integer; out Value: TColor; out Name: string): Boolean;
    function FindColor(Value: TColor; out ColorType: TColorType; out Index: Integer): Boolean;

    property MappingCount: Integer read Get_MappingCount;
    property Mappings[Index: Integer]: TJvColorProviderNameMapping read Get_Mapping;
  end;

  TJvColorProvider = class(TJvCustomDataProvider, IJvColorProvider)
  private
    FStdColors: TColorItems;
    FSysColors: TColorItems;
    FCstColors: TColorItems;
    FCtxList: TDynIntegerArray;
    FMappings: TJvColorProviderNameMappings;
  protected
    procedure AddColor(var List: TColorItems; Color: TColor);
    procedure DeleteColor(var List: TColorItems; Index: Integer);
    procedure RemoveContextList(Index: Integer); virtual;
    class function ItemsClass: TJvDataItemsClass; override;
    function ConsumerClasses: TClassArray; override;
    procedure ContextDestroying(Context: IJvDataContext); override;
    procedure InsertMapping(var Strings: TDynStringArray; Index: Integer);
    procedure DeleteMapping(var Strings: TDynStringArray; Index: Integer);
    procedure MappingAdded(Index: Integer);
    procedure MappingDestroying(Index: Integer);
    function GetColor(List, Index: Integer; out Value: TColor; out Name: string): Boolean;
    function GetColorCount(List: Integer): Integer;
    procedure GenDelphiConstantMapping;
    procedure GenEnglishMapping;
    procedure InitColorList(var List: TColorItems; const Definitions: array of TDefColorItem);
    procedure InitColors;
    function GetMappings: TJvColorProviderNameMappings;
    procedure SetMappings(Value: TJvColorProviderNameMappings);

    property StdColors: TColorItems read FStdColors write FStdColors;
    property SysColors: TColorItems read FSysColors write FSysColors;
    property CstColors: TColorItems read FCstColors write FCstColors;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function IndexOfMapping(Mapping: TJvColorProviderNameMapping): Integer;
    function IndexOfMappingName(Name: string): Integer;
    function Get_MappingCount: Integer;
    function Get_Mapping(Index: Integer): TJvColorProviderNameMapping;
    function GetStandardCount: Integer;
    function GetSystemCount: Integer;
    function GetCustomCount: Integer;
    function GetStandardColor(Index: Integer; out Value: TColor; out Name: string): Boolean;
    function GetSystemColor(Index: Integer; out Value: TColor; out Name: string): Boolean;
    function GetCustomColor(Index: Integer; out Value: TColor; out Name: string): Boolean;
    function FindColor(Value: TColor; out ColorType: TColorType; out Index: Integer): Boolean;
  published
    property Mappings: TJvColorProviderNameMappings read GetMappings write SetMappings;
  end;

  TJvColorProviderAddItemLocation = (ailUseHeader, ailTop, ailBottom);
  TJvColorProviderAddColorStyle = (aisBorland, aisEvent);
  TColorGroupHeaderAlign = (ghaLeft, ghaCenter, ghaColorText);
  TColorGroupHeaderStyle = (ghsBoldFont, ghsSingleCenterLine, ghsDoubleCenterLine);
  TColorGroupHeaderStyles = set of TColorGroupHeaderStyle;

  TJvColorProviderNameMappings = class(TObjectList)
  private
    FProvider: TJvColorProvider;
  protected
    function GetItem(Index: Integer): TJvColorProviderNameMapping;
    procedure SetItem(Index: Integer; AObject: TJvColorProviderNameMapping);

    property Provider: TJvColorProvider read FProvider;
  public
    constructor Create(AProvider: TJvColorProvider);
    function Add(Item: TJvColorProviderNameMapping): Integer;
    procedure Clear; override;
    procedure Delete(Index: Integer);
    property Items[Index: Integer]: TJvColorProviderNameMapping read GetItem write SetItem; default;
  end;

  TJvColorProviderNameMapping = class(TPersistent)
  private
    FName: string;
    FOwner: TJvColorProviderNameMappings;
  protected
    property Owner: TJvColorProviderNameMappings read FOwner;
  public
    constructor Create(AOwner: TJvColorProviderNameMappings; AName: string);
  published
    property Name: string read FName write FName;
  end;
  
  TJvColorProviderSubSettings = class(TPersistent)
  private
    FActive: Boolean;
    FConsumerServiceExt: TJvDataConsumerAggregatedObject;
  protected
    procedure Changed; virtual;
    procedure ViewChanged; virtual;
    procedure SetActive(Value: Boolean); virtual;
    property Active: Boolean read FActive write SetActive;
    property ConsumerServiceExt: TJvDataConsumerAggregatedObject read FConsumerServiceExt;
  public
    constructor Create(AConsumerService: TJvDataConsumerAggregatedObject);
  end;

  TJvColorProviderColorBoxSettings = class(TJvColorProviderSubSettings)
  private
    FHeight: Integer;
    FMargin: Integer;
    FShadowed: Boolean;
    FShadowSize: Integer;
    FSpacing: Integer;
    FWidth: Integer;
  protected
    procedure SetHeight(Value: Integer); virtual;
    procedure SetMargin(Value: Integer); virtual;
    procedure SetShadowed(Value: Boolean); virtual;
    procedure SetShadowSize(Value: Integer); virtual;
    procedure SetSpacing(Value: Integer); virtual;
    procedure SetWidth(Value: Integer); virtual;
  public
    constructor Create(AConsumerService: TJvDataConsumerAggregatedObject);
  published
    property Active default True;
    property Height: Integer read FHeight write SetHeight default 13;
    property Margin: Integer read FMargin write SetMargin default 2;
    property Shadowed: Boolean read FShadowed write SetShadowed default True;
    property ShadowSize: Integer read FShadowSize write SetShadowSize default 2;
    property Spacing: Integer read FSpacing write SetSpacing default 4;
    property Width: Integer read FWidth write SetWidth default 21;
  end;

  TJvColorProviderTextSettings = class(TJvColorProviderSubSettings)
  private
    FShowHex: Boolean;
    FShowName: Boolean;
    FShowRGB: Boolean;
  protected
    procedure SetShowHex(Value: Boolean); virtual;
    procedure SetShowName(Value: Boolean); virtual;
    procedure SetShowRGB(Value: Boolean); virtual;
  public
    constructor Create(AConsumerService: TJvDataConsumerAggregatedObject);
  published
    property Active default True;
    property ShowHex: Boolean read FShowHex write SetShowHex;
    property ShowName: Boolean read FShowName write SetShowName default True;
    property ShowRGB: Boolean read FShowRGB write SetShowRGB;
  end;

  TJvColorProviderGroupingSettings = class(TJvColorProviderSubSettings)
  private
    FFlatList: Boolean;
    FHeaderAlign: TColorGroupHeaderAlign;
    FHeaderStyle: TColorGroupHeaderStyles;
  protected
    procedure SetActive(Value: Boolean); override;
    procedure SetFlatList(Value: Boolean); virtual;
    procedure SetHeaderAlign(Value: TColorGroupHeaderAlign); virtual;
    procedure SetHeaderStyle(Value: TColorGroupHeaderStyles); virtual;
  public
    constructor Create(AConsumerService: TJvDataConsumerAggregatedObject);
  published
    property Active default True;
    property FlatList: Boolean read FFlatList write SetFlatList default True;
    property HeaderAlign: TColorGroupHeaderAlign read FHeaderAlign write SetHeaderAlign
      default ghaLeft;
    property HeaderStyle: TColorGroupHeaderStyles read FHeaderStyle write SetHeaderStyle
      default [ghsBoldFont, ghsSingleCenterLine];
  end;

  TJvColorProviderColorGroupSettings = class(TJvColorProviderSubSettings)
  private
    FCaption: string;
    FShowHeader: Boolean;
  protected
    procedure SetCaption(Value: string); virtual;
    procedure SetShowHeader(Value: Boolean); virtual;
  public
    constructor Create(AConsumerService: TJvDataConsumerAggregatedObject; ACaption: string);
  published
    property Active default True;
    property Caption: string read FCaption write SetCaption;
    property ShowHeader: Boolean read FShowHeader write SetShowHeader default False;
  end;

  TJvColorProviderAddColorSettings = class(TJvColorProviderSubSettings)
  private
    FLocation: TJvColorProviderAddItemLocation;
    FCaption: string;
    FStyle: TJvColorProviderAddColorStyle;
  protected
    procedure SetLocation(Value: TJvColorProviderAddItemLocation); virtual;
    procedure SetCaption(Value: string); virtual;
    procedure SetStyle(Value: TJvColorProviderAddColorStyle); virtual;
  public
    constructor Create(AConsumerService: TJvDataConsumerAggregatedObject);
  published
    property Location: TJvColorProviderAddItemLocation read FLocation write SetLocation
      default ailBottom;
    property Caption: string read FCaption write SetCaption;
    property Style: TJvColorProviderAddColorStyle read FStyle write SetStyle default aisBorland;
  end;

  TJvColorProviderCustomColorGroupSettings = class(TJvColorProviderColorGroupSettings)
  private
    FAddColorSettings: TJvColorProviderAddColorSettings;
  protected
    procedure SetAddColorSettings(Value: TJvColorProviderAddColorSettings); virtual;
  public
    constructor Create(AConsumerService: TJvDataConsumerAggregatedObject; ACaption: string);
    destructor Destroy; override;
  published
    property AddColorSettings: TJvColorProviderAddColorSettings read FAddColorSettings
      write SetAddColorSettings;
  end;

  IJvColorProviderSettings = interface
    ['{5381D2E0-D8EA-46E7-A3C6-42B5353B896B}']
    function Get_ColorBoxSettings: TJvColorProviderColorBoxSettings;
    function Get_CustomColorSettings: TJvColorProviderCustomColorGroupSettings;
    function Get_GroupingSettings: TJvColorProviderGroupingSettings;
    function Get_NameMapping: TJvColorProviderNameMapping;
    function Get_NameMappingIndex: Integer;
    function Get_StandardColorSettings: TJvColorProviderColorGroupSettings;
    function Get_SystemColorSettings: TJvColorProviderColorGroupSettings;
    function Get_TextSettings: TJvColorProviderTextSettings;
    procedure Set_NameMapping(Value: TJvColorProviderNameMapping);
    procedure Set_NameMappingIndex(Value: Integer);
    procedure MappingAdded(Index: Integer; Mapping: TJvColorProviderNameMapping);
    procedure MappingDestroying(Index: Integer; Mapping: TJvColorProviderNameMapping);

    property ColorBoxSettings: TJvColorProviderColorBoxSettings read Get_ColorBoxSettings;
    property CustomColorSettings: TJvColorProviderCustomColorGroupSettings
      read Get_CustomColorSettings;
    property GroupingSettings: TJvColorProviderGroupingSettings read Get_GroupingSettings;
    property NameMapping: TJvColorProviderNameMapping read Get_NameMapping write Set_NameMapping;
    property NameMappingIndex: Integer read Get_NameMappingIndex write Set_NameMappingIndex;
    property StandardColorSettings: TJvColorProviderColorGroupSettings
      read Get_StandardColorSettings;
    property SystemColorSettings: TJvColorProviderColorGroupSettings read Get_SystemColorSettings;
    property TextSettings: TJvColorProviderTextSettings read Get_TextSettings;
  end;

implementation

uses
  {$IFNDEF COMPILER6_UP}Consts, {$ENDIF}Controls, {$IFDEF COMPILER6_UP}RTLConsts,{$ENDIF}SysUtils,
  JclRTTI,
  JvConsts;

function GetItemColorValue(Item: IJvDataItem; out Color: TColor): Boolean;
var
  S: string;
begin
  S := Item.GetID;
  Result := Copy(S, 1, 7) = 'TCOLOR=';
  if Result then
    Color := StrToInt('$0' + Copy(S, 8, 8));
end;

const
  {$IFNDEF COMPILER6_UP}
  clMoneyGreen = TColor($C0DCC0);
  clSkyBlue = TColor($F0CAA6);
  clCream = TColor($F0FBFF);
  clMedGray = TColor($A4A0A0);
  {$ENDIF}

  ColCount = 20;
  SysColCount = 25;
  ColorValues: array [0 .. ColCount - 1] of TDefColorItem = (
    (Value: clBlack;                Constant: 'clBlack';                English: 'Black'),
    (Value: clMaroon;               Constant: 'clMaroon';               English: 'Maroon'),
    (Value: clGreen;                Constant: 'clGreen';                English: 'Green'),
    (Value: clOlive;                Constant: 'clOlive';                English: 'Olive green'),
    (Value: clNavy;                 Constant: 'clNavy';                 English: 'Navy blue'),
    (Value: clPurple;               Constant: 'clPurple';               English: 'Purple'),
    (Value: clTeal;                 Constant: 'clTeal';                 English: 'Teal'),
    (Value: clGray;                 Constant: 'clGray';                 English: 'Gray'),
    (Value: clSilver;               Constant: 'clSilver';               English: 'Silver'),
    (Value: clRed;                  Constant: 'clRed';                  English: 'Red'),
    (Value: clLime;                 Constant: 'clLime';                 English: 'Lime'),
    (Value: clYellow;               Constant: 'clYellow';               English: 'Yellow'),
    (Value: clBlue;                 Constant: 'clBLue';                 English: 'Blue'),
    (Value: clFuchsia;              Constant: 'clFuchsia';              English: 'Fuchsia'),
    (Value: clAqua;                 Constant: 'clAqua';                 English: 'Aqua'),
    (Value: clWhite;                Constant: 'clWhite';                English: 'White'),
    (Value: clMoneyGreen;           Constant: 'clMoneyGreen';           English: 'Money green'),
    (Value: clSkyBlue;              Constant: 'clSkyBlue';              English: 'Sky blue'),
    (Value: clCream;                Constant: 'clCream';                English: 'Cream'),
    (Value: clMedGray;              Constant: 'clMedGray';              English: 'Medium gray')
  );

  SysColorValues: array [0 .. SysColCount - 1] of TDefColorItem = (
    (Value: clScrollBar;            Constant: 'clScrollBar';            English: 'Scrollbar'),
    (Value: clBackground;           Constant: 'clBackground';           English: 'Desktop background'),
    (Value: clActiveCaption;        Constant: 'clActiveCaption';        English: 'Active window title bar'),
    (Value: clInactiveCaption;      Constant: 'clInactiveCaption';      English: 'Inactive window title bar'),
    (Value: clMenu;                 Constant: 'clMenu';                 English: 'Menu background'),
    (Value: clWindow;               Constant: 'clWindow';               English: 'Window background'),
    (Value: clWindowFrame;          Constant: 'clWindowFrame';          English: 'Window frame'),
    (Value: clMenuText;             Constant: 'clMenuText';             English: 'Menu text'),
    (Value: clWindowText;           Constant: 'clWindowText';           English: 'Window text'),
    (Value: clCaptionText;          Constant: 'clCaptionText';          English: 'Active window title bar text'),
    (Value: clActiveBorder;         Constant: 'clActiveBorder';         English: 'Active window border'),
    (Value: clInactiveBorder;       Constant: 'clInactiveBorder';       English: 'Inactive window border'),
    (Value: clAppWorkSpace;         Constant: 'clAppWorkSpace';         English: 'Application workspace'),
    (Value: clHighlight;            Constant: 'clHighlight';            English: 'Selection background'),
    (Value: clHighlightText;        Constant: 'clHighlightText';        English: 'Selection text'),
    (Value: clBtnFace;              Constant: 'clBtnFace';              English: 'Button face'),
    (Value: clBtnShadow;            Constant: 'clBtnShadow';            English: 'Button shadow'),
    (Value: clGrayText;             Constant: 'clGrayText';             English: 'Dimmed text'),
    (Value: clBtnText;              Constant: 'clBtnText';              English: 'Button text'),
    (Value: clInactiveCaptionText;  Constant: 'clInactiveCaptionText';  English: 'Inactive window title bar text'),
    (Value: clBtnHighlight;         Constant: 'clBtnHighlight';         English: 'Button highlight'),
    (Value: cl3DDkShadow;           Constant: 'cl3DDkShadow';           English: 'Dark shadow three-dimensional elements'),
    (Value: cl3DLight;              Constant: 'cl3DLight';              English: 'Highlight three-dimensional elements'),
    (Value: clInfoText;             Constant: 'clInfoText';             English: 'Tooltip text'),
    (Value: clInfoBk;               Constant: 'clInfoBk';               English: 'Tooltip background')
  );

type
  TJvColorItems = class(TJvBaseDataItems)
  private
    FColorProvider: IJvColorProvider;
  protected
    function GetColorSettings: IJvColorProviderSettings;
    function GetCount: Integer; override;
    function GetItem(I: Integer): IJvDataItem; override;
    procedure InitImplementers; override;

    property ColorProvider: IJvColorProvider read FColorProvider write FColorProvider;
  public
    procedure AfterConstruction; override;
  end;

  TJvColorItemsList = class(TJvColorItems)
  private
    FListNum: Integer;
  protected
    function GetCount: Integer; override;
    function GetItem(I: Integer): IJvDataItem; override;

    property ListNum: Integer read FListNum write FListNum;
  public
    procedure AfterConstruction; override;
  end;

  TJvColorItem = class(TJvBaseDataItem, IJvDataItemText)
  private
    FListNumber: Integer; // 0 = StdColors, 1 = SysColors, 2 = CstColors
    FListIndex: Integer;  // Index in color list
  protected
    function GetCaption: string;
    procedure SetCaption(const Value: string);
    procedure InitID; override;
    property ListNumber: Integer read FListNumber;
    property ListIndex: Integer read FListIndex;
  public
    constructor Create(AOwner: IJvDataItems; AListNumber, AListIndex: Integer);
  end;

  TJvColorHeaderItem = class(TJvBaseDataItem, IJvDataItemText)
  private
    FListNumber: Integer; // 0 = StdColors, 1 = SysColors, 2 = CstColors
  protected
    function GetCaption: string;
    procedure SetCaption(const Value: string); 
    procedure InitID; override;
    procedure InitImplementers; override;
    property ListNumber: Integer read FListNumber;
  public
    constructor Create(AOwner: IJvDataItems; AListNumber: Integer);
  end;

  TJvColorItemsRenderer = class(TJvCustomDataItemsRenderer)
  protected
    CurrentCanvas: TCanvas;
    CurrentRect: TRect;
    CurrentItem: IJvDataItem;
    CurrentState: TProviderDrawStates;
    CurrentSettings: IJvColorProviderSettings;
    CurrentItemIsColorItem: Boolean;
    CurrentColorValue: TColor;
    function GetRenderText: string;
    procedure RenderColorBox;
    procedure RenderColorText;
    procedure RenderGroupHeader;
    procedure MeasureColorBox(var Size: TSize);
    procedure MeasureColorText(var Size: TSize);
    procedure DoDrawItem(ACanvas: TCanvas; var ARect: TRect; Item: IJvDataItem;
      State: TProviderDrawStates); override;
    function DoMeasureItem(ACanvas: TCanvas; Item: IJvDataItem): TSize; override;
    function AvgItemSize(ACanvas: TCanvas): TSize; override;
    function GetConsumerSettings: IJvColorProviderSettings;
  end;

  TOpenConsumerServiceExt = class(TJvDataConsumerAggregatedObject);

  TJvColorProviderSettings = class(TJvDataConsumerAggregatedObject, IJvColorProviderSettings)
  private
    FColorBoxSettings: TJvColorProviderColorBoxSettings;
    FCustomColorSettings: TJvColorProviderCustomColorGroupSettings;
    FGroupingSettings: TJvColorProviderGroupingSettings;
    FStandardColorSettings: TJvColorProviderColorGroupSettings;
    FSystemColorSettings: TJvColorProviderColorGroupSettings;
    FTextSettings: TJvColorProviderTextSettings;
    FMapping: Integer;
  protected
    function Get_ColorBoxSettings: TJvColorProviderColorBoxSettings;
    function Get_CustomColorSettings: TJvColorProviderCustomColorGroupSettings;
    function Get_GroupingSettings: TJvColorProviderGroupingSettings;
    function Get_NameMapping: TJvColorProviderNameMapping;
    function Get_NameMappingIndex: Integer;
    function Get_StandardColorSettings: TJvColorProviderColorGroupSettings;
    function Get_SystemColorSettings: TJvColorProviderColorGroupSettings;
    function Get_TextSettings: TJvColorProviderTextSettings;
    procedure Set_ColorBoxSettings(Value: TJvColorProviderColorBoxSettings);
    procedure Set_CustomColorSettings(Value: TJvColorProviderCustomColorGroupSettings);
    procedure Set_GroupingSettings(Value: TJvColorProviderGroupingSettings);
    procedure Set_NameMapping(Value: TJvColorProviderNameMapping);
    procedure Set_NameMappingIndex(Value: Integer);
    procedure Set_StandardColorSettings(Value: TJvColorProviderColorGroupSettings);
    procedure Set_SystemColorSettings(Value: TJvColorProviderColorGroupSettings);
    procedure Set_TextSettings(Value: TJvColorProviderTextSettings);
    procedure MappingAdded(Index: Integer; Mapping: TJvColorProviderNameMapping);
    procedure MappingDestroying(Index: Integer; Mapping: TJvColorProviderNameMapping);
    function GetNameMappingIndex: TJvColorProviderMapping;
    procedure SetNameMappingIndex(Value: TJvColorProviderMapping);
  public
    constructor Create(AOwner: TExtensibleInterfacedPersistent); override;
    destructor Destroy; override;
  published
    property ColorBoxSettings: TJvColorProviderColorBoxSettings read Get_ColorBoxSettings
      write Set_ColorBoxSettings;
    property CustomColorSettings: TJvColorProviderCustomColorGroupSettings
      read Get_CustomColorSettings write Set_CustomColorSettings;
    property TextSettings: TJvColorProviderTextSettings read Get_TextSettings
      write Set_TextSettings;
    property StandardColorSettings: TJvColorProviderColorGroupSettings
      read Get_StandardColorSettings write Set_StandardColorSettings;
    property SystemColorSettings: TJvColorProviderColorGroupSettings read Get_SystemColorSettings
      write Set_SystemColorSettings;
    property GroupingSettings: TJvColorProviderGroupingSettings read Get_GroupingSettings
      write Set_GroupingSettings;
    property Mapping: TJvColorProviderMapping read GetNameMappingIndex write SetNameMappingIndex
      default -1;
  end;

//===TJvColorProviderNameMapping====================================================================

constructor TJvColorProviderNameMapping.Create(AOwner: TJvColorProviderNameMappings; AName: string);
begin
  inherited Create;
  FOwner := AOwner;
  FName := AName;
end;

//===TJvColorProviderSubSettings====================================================================

procedure TJvColorProviderSubSettings.Changed;
begin
  TOpenConsumerServiceExt(ConsumerServiceExt).Changed(ccrOther);
end;

procedure TJvColorProviderSubSettings.ViewChanged;
begin
  TOpenConsumerServiceExt(ConsumerServiceExt).ViewChanged(ConsumerServiceExt);
end;

procedure TJvColorProviderSubSettings.SetActive(Value: Boolean);
begin
  if Value <> Active then
  begin
    FActive := Value;
    Changed;
  end;
end;

constructor TJvColorProviderSubSettings.Create(AConsumerService: TJvDataConsumerAggregatedObject);
begin
  inherited Create;
  FConsumerServiceExt := AConsumerService;
end;

//===TJvColorProviderColorBoxSettings===============================================================

procedure TJvColorProviderColorBoxSettings.SetHeight(Value: Integer);
begin
  if Value <> Height then
  begin
    FHeight := Value;
    Changed;
  end;
end;

procedure TJvColorProviderColorBoxSettings.SetMargin(Value: Integer);
begin
  if Value <> Margin then
  begin
    FMargin := Value;
    Changed;
  end;
end;

procedure TJvColorProviderColorBoxSettings.SetShadowed(Value: Boolean);
begin
  if Value <> Shadowed then
  begin
    FShadowed := Value;
    Changed;
  end;
end;

procedure TJvColorProviderColorBoxSettings.SetShadowSize(Value: Integer);
begin
  if Value <> ShadowSize then
  begin
    FShadowSize := Value;
    Changed;
  end;
end;

procedure TJvColorProviderColorBoxSettings.SetSpacing(Value: Integer);
begin
  if Value <> Spacing then
  begin
    FSpacing := Value;
    Changed;
  end;
end;

procedure TJvColorProviderColorBoxSettings.SetWidth(Value: Integer);
begin
  if Value <> Width then
  begin
    FWidth := Value;
    Changed;
  end;
end;

constructor TJvColorProviderColorBoxSettings.Create(
  AConsumerService: TJvDataConsumerAggregatedObject);
begin
  inherited Create(AConsumerService);
  FActive := True;
  FHeight := 13;
  FMargin := 2;
  FShadowed := True;
  FShadowSize := 2;
  FSpacing := 4;
  FWidth := 21;
end;

//===TJvColorProviderTextSettings===================================================================

procedure TJvColorProviderTextSettings.SetShowHex(Value: Boolean);
begin
  if Value <> ShowHex then
  begin
    FShowHex := Value;
    Changed;
  end;
end;

procedure TJvColorProviderTextSettings.SetShowName(Value: Boolean);
begin
  if Value <> ShowName then
  begin
    FShowName := Value;
    Changed;
  end;
end;

procedure TJvColorProviderTextSettings.SetShowRGB(Value: Boolean);
begin
  if Value <> ShowRGB then
  begin
    FShowRGB := Value;
    Changed;
  end;
end;

constructor TJvColorProviderTextSettings.Create(AConsumerService: TJvDataConsumerAggregatedObject);
begin
  inherited Create(AConsumerService);
  FActive := True;
  FShowName := True;
end;

//===TJvColorProviderGroupingSettings===============================================================

procedure TJvColorProviderGroupingSettings.SetActive(Value: Boolean);
begin
  if Value <> Active then
  begin
    inherited SetActive(Value);
    ViewChanged;
  end;
end;

procedure TJvColorProviderGroupingSettings.SetFlatList(Value: Boolean);
begin
  if Value <> FlatList then
  begin
    FFlatList := Value;
    Changed;
    ViewChanged;
  end;
end;

procedure TJvColorProviderGroupingSettings.SetHeaderAlign(Value: TColorGroupHeaderAlign);
begin
  if Value <> HeaderAlign then
  begin
    FHeaderAlign := Value;
    Changed;
  end;
end;

procedure TJvColorProviderGroupingSettings.SetHeaderStyle(Value: TColorGroupHeaderStyles);
begin
  if (ghsSingleCenterLine in Value) and not (ghsSingleCenterLine in HeaderStyle) then
    Exclude(Value, ghsDoubleCenterLine)
  else
  if (ghsDoubleCenterLine in Value) and not (ghsDoubleCenterLine in HeaderStyle) then
    Exclude(Value, ghsSingleCenterLine);
  if Value <> HeaderStyle then
  begin
    FHeaderStyle := Value;
    Changed;
  end;
end;

constructor TJvColorProviderGroupingSettings.Create(
  AConsumerService: TJvDataConsumerAggregatedObject);
begin
  inherited Create(AConsumerService);
  FActive := True;
  FFlatList := True;
  FHeaderAlign := ghaLeft;
  FHeaderStyle := [ghsBoldFont, ghsSingleCenterLine];
end;

//===TJvColorProviderColorGroupSettings=============================================================

procedure TJvColorProviderColorGroupSettings.SetCaption(Value: string);
begin
  if Value <> Caption then
  begin
    FCaption := Value;
    Changed;
  end;
end;

procedure TJvColorProviderColorGroupSettings.SetShowHeader(Value: Boolean);
begin
  if Value <> ShowHeader then
  begin
    FShowHeader := Value;
    Changed;
    ViewChanged;
  end;
end;

constructor TJvColorProviderColorGroupSettings.Create(
  AConsumerService: TJvDataConsumerAggregatedObject; ACaption: string);
begin
  inherited Create(AConsumerService);
  FActive := True;
  FCaption := ACaption;
end;

//===TJvColorProviderAddColorSettings===============================================================

procedure TJvColorProviderAddColorSettings.SetLocation(Value: TJvColorProviderAddItemLocation);
begin
  if Value <> Location then
  begin
    FLocation := Value;
    Changed;
    ViewChanged;
  end;
end;

procedure TJvColorProviderAddColorSettings.SetCaption(Value: string);
begin
  if Value <> Caption then
  begin
    FCaption := Value;
    Changed;
  end;
end;

procedure TJvColorProviderAddColorSettings.SetStyle(Value: TJvColorProviderAddColorStyle);
begin
  if Value <> Style then
  begin
    FStyle := Value;
    Changed;
  end;
end;

constructor TJvColorProviderAddColorSettings.Create(
  AConsumerService: TJvDataConsumerAggregatedObject);
begin
  inherited Create(AConsumerService);
  FLocation := ailBottom;
  FStyle := aisBorland;
end;

//===TJvColorProviderCustomColorGroupSettings=======================================================

procedure TJvColorProviderCustomColorGroupSettings.SetAddColorSettings(
  Value: TJvColorProviderAddColorSettings);
begin
end;

constructor TJvColorProviderCustomColorGroupSettings.Create(
  AConsumerService: TJvDataConsumerAggregatedObject; ACaption: string);
begin
  inherited Create(AConsumerService, ACaption);
  FAddColorSettings := TJvColorProviderAddColorSettings.Create(AConsumerService);
end;

destructor TJvColorProviderCustomColorGroupSettings.Destroy;
begin
  FreeAndNil(FAddColorSettings);
  inherited Destroy;
end;

//===TJvColorItems==================================================================================

function TJvColorItems.GetColorSettings: IJvColorProviderSettings;
begin
  if GetProvider = nil then
    Result := nil
  else
    Supports(GetProvider.SelectedConsumer, IJvColorProviderSettings, Result);
end;

function TJvColorItems.GetCount: Integer;
var
  Settings: IJvColorProviderSettings;
begin
  Settings := GetColorSettings;
  Result := 0;
  if Settings = nil then
    Exit;
  if Settings.GroupingSettings.Active and not Settings.GroupingSettings.FlatList then
  begin
    Inc(Result, Ord(Settings.StandardColorSettings.Active) +
      Ord(Settings.SystemColorSettings.Active) + Ord(Settings.CustomColorSettings.Active));
  end
  else
  begin
    if Settings.StandardColorSettings.Active then
      Inc(Result, ColorProvider.GetStandardCount +
        Ord(Settings.StandardColorSettings.ShowHeader and Settings.GroupingSettings.Active));
    if Settings.SystemColorSettings.Active then
      Inc(Result, ColorProvider.GetSystemCount +
        Ord(Settings.SystemColorSettings.ShowHeader and Settings.GroupingSettings.Active));
  end;
end;

function TJvColorItems.GetItem(I: Integer): IJvDataItem;
var
  OrgIdx: Integer;
  Settings: IJvColorProviderSettings;
  ListNum: Integer;
begin
  if I < 0 then
    TList.Error(SListIndexError, I);
  OrgIdx := I;
  Settings := GetColorSettings;
  if Settings = nil then
    Exit;
  ListNum := -1;
  if Settings.GroupingSettings.Active and not Settings.GroupingSettings.FlatList then
  begin
    if Settings.StandardColorSettings.Active then
      Dec(I);
    if I < 0 then
      ListNum := 0;
    if (ListNum < 0) and Settings.SystemColorSettings.Active then
    begin
      Dec(I);
      if I < 0 then
        ListNum := 1;
    end;
    if (ListNum < 0) and Settings.CustomColorSettings.Active then
    begin
      Dec(I);
      if I < 0 then
        ListNum := 2;
    end;
  end
  else
  begin
    if Settings.StandardColorSettings.Active then
    begin
      if Settings.StandardColorSettings.ShowHeader and Settings.GroupingSettings.Active then
        Dec(I);
      if I < ColorProvider.GetStandardCount then
        ListNum := 0
      else
        Dec(I, ColorProvider.GetStandardCount);
    end;
    if (ListNum < 0) and Settings.SystemColorSettings.Active then
    begin
      if Settings.SystemColorSettings.ShowHeader and Settings.GroupingSettings.Active then
        Dec(I);
      if I < ColorProvider.GetSystemCount then
        ListNum := 1
      else
        Dec(I, ColorProvider.GetSystemCount);
    end;
  end;
  if ListNum < 0 then
    TList.Error(SListIndexError, OrgIdx);
  if I < 0 then
    Result := TJvColorHeaderItem.Create(Self, ListNum)
  else
    Result := TJvColorItem.Create(Self, ListNum, I);
end;

procedure TJvColorItems.InitImplementers;
begin
  inherited InitImplementers;
  if GetParent = nil then
    TJvColorItemsRenderer.Create(Self);
end;

procedure TJvColorItems.AfterConstruction;
begin
  inherited AfterConstruction;
  Supports(GetProvider, IJvColorProvider, FColorProvider);
end;

//===TJvColorItemsList==============================================================================

function TJvColorItemsList.GetCount: Integer;
begin
  case ListNum of
    0:
      Result := ColorProvider.GetStandardCount;
    1:
      Result := ColorProvider.GetSystemCount;
    2:
      Result := ColorProvider.GetCustomCount;
    else
      Result := 0;
  end;
end;

function TJvColorItemsList.GetItem(I: Integer): IJvDataItem;
begin
  if I < 0 then
    TList.Error(SListIndexError, I);
  case ListNum of
    0:
      begin
        if I >= ColorProvider.GetStandardCount then
          TList.Error(SListIndexError, I)
        else
          Result := TJvColorItem.Create(Self, 0, I);
      end;
    1:
      begin
        if I >= ColorProvider.GetSystemCount then
          TList.Error(SListIndexError, I)
        else
          Result := TJvColorItem.Create(Self, 1, I);
      end;
    2:
      begin
        if I >= ColorProvider.GetCustomCount then
          TList.Error(SListIndexError, I)
        else
          Result := TJvColorItem.Create(Self, 1, I);
      end;
    else
      TList.Error(SListIndexError, I);
  end;
end;

procedure TJvColorItemsList.AfterConstruction;
begin
  inherited AfterConstruction;
  ListNum := TJvColorHeaderItem(GetParent.GetImplementer).ListNumber;
end;

//===TJvColorItem===================================================================================

function TJvColorItem.GetCaption: string;
var
  ColorFound: Boolean;
  ColorValue: TColor;
begin
  case ListNumber of
    0:
      ColorFound := (GetItems.GetProvider as IJvColorProvider).GetStandardColor(ListIndex, ColorValue, Result);
    1:
      ColorFound := (GetItems.GetProvider as IJvColorProvider).GetSystemColor(ListIndex, ColorValue, Result);
    2:
      ColorFound := (GetItems.GetProvider as IJvColorProvider).GetCustomColor(ListIndex, ColorValue, Result);
    else
    begin
      ColorFound := False;
      Result := '';
    end;
  end;
  if (Result = '') and ColorFound then
    ColorToIdent(ColorValue, Result);
end;

procedure TJvColorItem.SetCaption(const Value: string);
begin
end;

procedure TJvColorItem.InitID;
var
  ColorFound: Boolean;
  ColorValue: TColor;
  ColorName: string;
begin
  case ListNumber of
    0:
      ColorFound := (GetItems.GetProvider as IJvColorProvider).GetStandardColor(ListIndex, ColorValue, ColorName);
    1:
      ColorFound := (GetItems.GetProvider as IJvColorProvider).GetSystemColor(ListIndex, ColorValue, ColorName);
    2:
      ColorFound := (GetItems.GetProvider as IJvColorProvider).GetCustomColor(ListIndex, ColorValue, ColorName);
    else
    begin
      ColorFound := False;
      ColorValue := -1;
    end;
  end;
  if ColorFound then
    SetID('TCOLOR=' + IntToHex(ColorValue, 8))
  else
    SetID('Item' + IntToStr(ListNumber) + '.' + IntToStr(ListIndex));
end;

constructor TJvColorItem.Create(AOwner: IJvDataItems; AListNumber, AListIndex: Integer);
begin
  inherited Create(AOwner);
  FListNumber := AListNumber;
  FListIndex := AListIndex;
end;

//===TJvColorHeaderItem=============================================================================

function TJvColorHeaderItem.GetCaption: string;
var
  Settings: IJvColorProviderSettings;
begin
  Supports(GetItems.GetProvider.SelectedConsumer, IJvColorProviderSettings, Settings);
  if Settings = nil then
    Result := '(no settings)'
  else
    case ListNumber of
      0:
        Result := Settings.StandardColorSettings.Caption;
      1:
        Result := Settings.SystemColorSettings.Caption;
      2:
        Result := Settings.CustomColorSettings.Caption;
    end;
end;

procedure TJvColorHeaderItem.SetCaption(const Value: string);
begin
end;

procedure TJvColorHeaderItem.InitID;
begin
  SetID('ColorGroupHeader_' + IntToStr(ListNumber));
end;

procedure TJvColorHeaderItem.InitImplementers;
var
  Settings: IJvColorProviderSettings;
begin
  inherited InitImplementers;
  if Supports(GetItems.GetProvider.SelectedConsumer, IJvColorProviderSettings, Settings) and
    not Settings.GroupingSettings.FlatList then
  begin
    {$WARNINGS OFF}
    TJvColorItemsList.Create(Self);
    {$WARNINGS ON}
  end;
end;

constructor TJvColorHeaderItem.Create(AOwner: IJvDataItems; AListNumber: Integer);
begin
  inherited Create(AOwner);
  FListNumber := AListNumber;
end;

//===TJvColorProvider===============================================================================

procedure TJvColorProvider.AddColor(var List: TColorItems; Color: TColor);
begin
  SetLength(List, Length(List) + 1);
  List[High(List)].Value := Color;
  SetLength(List[High(List)].Names, Mappings.Count);
end;

procedure TJvColorProvider.DeleteColor(var List: TColorItems; Index: Integer);
begin
  SetLength(List[Index].Names, 0);
  if (Index < High(List)) then
  begin
    Move(List[Index + 1], List[Index], SizeOf(List[0]) * (High(List) - Index));
    FillChar(List[High(List)], 0, SizeOf(List[0]));
  end;
  SetLength(List, High(List));
end;

procedure TJvColorProvider.RemoveContextList(Index: Integer);
begin
  if (Index > -1) and (Index < Length(FCtxList)) then
  begin
    if Index < High(FCtxList) then
      Move(FCtxList[Index + 1], FCtxList[Index], SizeOf(Integer) * (High(FCtxList) - Index));
    SetLength(FCtxList, High(FCtxList));
  end;
end;

class function TJvColorProvider.ItemsClass: TJvDataItemsClass;
begin
  Result := TJvColorItems;
end;

function TJvColorProvider.ConsumerClasses: TClassArray;
begin
  Result := inherited ConsumerClasses;
  AddToArray(Result, TJvColorProviderSettings);
end;

procedure TJvColorProvider.ContextDestroying(Context: IJvDataContext);
var
  CtxIdx: Integer;
begin
  CtxIdx := Context.Contexts.IndexOf(Context);
  if CtxIdx > -1 then
    RemoveContextList(CtxIdx);
end;

procedure TJvColorProvider.InsertMapping(var Strings: TDynStringArray; Index: Integer);
begin
  SetLength(Strings, Length(Strings) + 1);
  if Index < High(Strings) then
  begin
    Move(Strings[Index], Strings[Index + 1], (High(Strings) - Index) * SizeOf(string));
    FillChar(Strings[Index], 0, SizeOf(string));;
  end;
end;

procedure TJvColorProvider.DeleteMapping(var Strings: TDynStringArray; Index: Integer);
begin
  Strings[Index] := '';
  if Index < High(Strings) then
  begin
    Move(Strings[Index + 1], Strings[Index], (High(Strings) - Index) * SizeOf(string));
    FillChar(Strings[High(Strings)], 0, SizeOf(string));
  end;
  SetLength(Strings, High(Strings));
end;

procedure TJvColorProvider.MappingAdded(Index: Integer);
var
  Instance: TJvColorProviderNameMapping;
  I: Integer;
  ColorSettings: IJvColorProviderSettings;
begin
  Instance := Mappings[Index];
  { Iterate all consumers and notify them of the addition. }
  for I := GetNotifierCount - 1 downto 0 do
    if Supports(GetNotifier(I).Consumer, IJvColorProviderSettings, ColorSettings) then
      ColorSettings.MappingAdded(Index, Instance);
  { Iterate the colors lists and insert the new mapping. }
  for I := 0 to High(FStdColors) do
    InsertMapping(FStdColors[I].Names, Index);
  for I := 0 to High(FSysColors) do
    InsertMapping(FSysColors[I].Names, Index);
  for I := 0 to High(FCstColors) do
    InsertMapping(FCstColors[I].Names, Index);
end;

procedure TJvColorProvider.MappingDestroying(Index: Integer);
var
  Instance: TJvColorProviderNameMapping;
  I: Integer;
  ColorSettings: IJvColorProviderSettings;
begin
  if not (csDestroying in ComponentState) then
  begin
    Instance := Mappings[Index];
    { Iterate all consumers and notify them of the removal of that mapping. }
    for I := GetNotifierCount - 1 downto 0 do
      if Supports(GetNotifier(I).Consumer, IJvColorProviderSettings, ColorSettings) then
        ColorSettings.MappingDestroying(Index, Instance);
    { Iterate the colors lists and delete the mapping. }
    for I := 0 to High(FStdColors) do
      DeleteMapping(FStdColors[I].Names, Index);
    for I := 0 to High(FSysColors) do
      DeleteMapping(FSysColors[I].Names, Index);
    for I := 0 to High(FCstColors) do
      DeleteMapping(FCstColors[I].Names, Index);
  end;
end;

function TJvColorProvider.GetColor(List, Index: Integer; out Value: TColor;
  out Name: string): Boolean;
var
  ColorArray: TColorItems;
  ColorSettings: IJvColorProviderSettings;
  MapIdx: Integer;
begin
  case List of
    0:
      ColorArray := FStdColors;
    1:
      ColorArray := FSysColors;
    2:
      ColorArray := FCstColors;
    else
      begin
        Result := False;
        Exit;
      end;
  end;
  Result := (Index >= 0) and (Index < Length(ColorArray));
  if Result then
  begin
    Value := ColorArray[Index].Value;
    Name := '';
    if Mappings.Count > 0 then
    begin
      if Supports(SelectedConsumer, IJvColorProviderSettings, ColorSettings) then
        MapIdx := ColorSettings.NameMappingIndex
      else
        MapIdx := 0;
      if MapIdx = -1 then
        MapIdx := 0;
      Name := ColorArray[Index].Names[MapIdx];
      if (Name = '') and (MapIdx <> 0) then
        Name := ColorArray[Index].Names[MapIdx];
    end;
  end;
end;

function TJvColorProvider.GetColorCount(List: Integer): Integer;
begin
  case List of
    0:
      Result := Length(FStdColors);
    1:
      Result := Length(FSysColors);
    2:
      Result := Length(FCstColors);
    else
      Result := 0;
  end;
end;

procedure TJvColorProvider.GenDelphiConstantMapping;
begin
  Mappings.Add(TJvColorProviderNameMapping.Create(Mappings, 'Delphi constant names'));
end;

procedure TJvColorProvider.GenEnglishMapping;
begin
  Mappings.Add(TJvColorProviderNameMapping.Create(Mappings, 'English names'));
end;

procedure TJvColorProvider.InitColorList(var List: TColorItems;
  const Definitions: array of TDefColorItem);
var
  I: Integer;
begin
  SetLength(List, Length(Definitions));
  for I := 0 to High(List) do
  begin
    List[I].Value := Definitions[I].Value;
    SetLength(List[I].Names, Mappings.Count);
    List[I].Names[0] := Definitions[I].Constant;
    List[I].Names[1] := Definitions[I].English;
  end;
end;

procedure TJvColorProvider.InitColors;
begin
  InitColorList(FStdColors, ColorValues);
  InitColorList(FSysColors, SysColorValues);
end;

function TJvColorProvider.GetMappings: TJvColorProviderNameMappings;
begin
  Result := FMappings;
end;

procedure TJvColorProvider.SetMappings(Value: TJvColorProviderNameMappings);
begin
end;

constructor TJvColorProvider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMappings := TJvColorProviderNameMappings.Create(Self);
  GenDelphiConstantMapping;
  GenEnglishMapping;
  InitColors;
end;

destructor TJvColorProvider.Destroy;
begin
  FreeAndNil(FMappings);
  inherited Destroy;
end;

function TJvColorProvider.IndexOfMapping(Mapping: TJvColorProviderNameMapping): Integer;
begin
  Result := Mappings.IndexOf(Mapping);
end;

function TJvColorProvider.IndexOfMappingName(Name: string): Integer;
begin
  Result := 0;
  while (Result < Get_MappingCount) and not AnsiSameText(Mappings[Result].Name, Name) do
    Inc(Result);
  if Result > Get_MappingCount then
    Result := -1;
end;

function TJvColorProvider.Get_MappingCount: Integer;
begin
  Result := Mappings.Count;
end;

function TJvColorProvider.Get_Mapping(Index: Integer): TJvColorProviderNameMapping;
begin
  Result := TJvColorProviderNameMapping(Mappings[Index]);
end;

function TJvColorProvider.GetStandardCount: Integer;
begin
  Result := GetColorCount(0);
end;

function TJvColorProvider.GetSystemCount: Integer;
begin
  Result := GetColorCount(1);
end;

function TJvColorProvider.GetCustomCount: Integer;
begin
  Result := GetColorCount(2);
end;

function TJvColorProvider.GetStandardColor(Index: Integer; out Value: TColor; out Name: string): Boolean;
begin
  Result := GetColor(0, Index, Value, Name);
end;

function TJvColorProvider.GetSystemColor(Index: Integer; out Value: TColor; out Name: string): Boolean;
begin
  Result := GetColor(1, Index, Value, Name);
end;

function TJvColorProvider.GetCustomColor(Index: Integer; out Value: TColor; out Name: string): Boolean;
begin
  Result := GetColor(2, Index, Value, Name);
end;

function TJvColorProvider.FindColor(Value: TColor; out ColorType: TColorType; out Index: Integer): Boolean;
begin
  Index := High(FStdColors);
  while (Index >= 0) and (FStdColors[Index].Value <> Value) do
    Dec(Index);
  if Index >= 0 then
    ColorType := ctStandard
  else
  begin
    Index := High(FSysColors);
    while (Index >= 0) and (FSysColors[Index].Value <> Value) do
      Dec(Index);
    if Index >= 0 then
      ColorType := ctSystem
    else
    begin
      Index := High(FCstColors);
      while (Index >= 0) and (FCstColors[Index].Value <> Value) do
        Dec(Index);
      if Index >= 0 then
        ColorType := ctCustom;
    end;
  end;
  Result := Index >= 0;
end;

//===TJvColorProviderNameMappings===================================================================

function TJvColorProviderNameMappings.GetItem(Index: Integer): TJvColorProviderNameMapping;
begin
  Result := TJvColorProviderNameMapping(inherited GetItem(Index));
end;

procedure TJvColorProviderNameMappings.SetItem(Index: Integer;
  AObject: TJvColorProviderNameMapping);
begin
  inherited SetItem(Index, AObject);
end;

constructor TJvColorProviderNameMappings.Create(AProvider: TJvColorProvider);
begin
  inherited Create(True);
  FProvider := AProvider;
end;

function TJvColorProviderNameMappings.Add(Item: TJvColorProviderNameMapping): Integer;
begin
  Result := inherited Add(Item);
  Provider.MappingAdded(Result);
end;

procedure TJvColorProviderNameMappings.Clear;
var
  I: Integer;
begin
  I := Count - 1;
  while I >= 0 do
  begin
    Delete(I);
    Dec(I);
  end;
end;

procedure TJvColorProviderNameMappings.Delete(Index: Integer);
begin
  if (Index >= 0) and (Index < Count) then
    Provider.MappingDestroying(Index);
  inherited Delete(Index);
end;

//===TJvColorItemsRenderer==========================================================================

function TJvColorItemsRenderer.GetRenderText: string;
var
  ItemText: IJvDataItemText;
begin
  with CurrentSettings.TextSettings do
  begin
    if Active or (CurrentItemIsColorItem and (CurrentColorValue >= clNone)) then
    begin
      if ShowName and Supports(CurrentItem, IJvDataItemText, ItemText) then
        Result := ItemText.Caption
      else
        Result := '';
      if CurrentItemIsColorItem then
      begin
        if ShowHex or (Result = '') then
        begin
          if Result <> '' then
            Result := Result + Format(' (%s%.8x)', [HexDisplayPrefix, CurrentColorValue])
          else
            Result := Format('%s%.8x', [HexDisplayPrefix, CurrentColorValue]);
        end;
        if ShowRGB then
        begin
          if Result <> '' then
            Result := Result + Format(' (%d, %d, %d)', [
              GetRValue(ColorToRGB(CurrentColorValue)),
              GetGValue(ColorToRGB(CurrentColorValue)),
              GetBValue(ColorToRGB(CurrentColorValue))])
          else
            Result := Format('(%d, %d, %d)', [
              GetRValue(ColorToRGB(CurrentColorValue)),
              GetGValue(ColorToRGB(CurrentColorValue)),
              GetBValue(ColorToRGB(CurrentColorValue))]);
        end;
      end;
    end
    else
    if not CurrentItemIsColorItem then
    begin
      if Supports(CurrentItem, IJvDataItemText, ItemText) then
        Result := ItemText.Caption
      else
        Result := SDataItemRenderHasNoText;
    end
    else
      Result := '';
  end;
end;

procedure TJvColorItemsRenderer.RenderColorBox;
var
  Margin: Integer;
  BoxW: Integer;
  BoxH: Integer;
  ShadowSize: Integer;
  R: TRect;
  SaveColor: TColor;
begin
  if CurrentSettings.ColorBoxSettings.Active then
  begin
    Margin := CurrentSettings.ColorBoxSettings.Margin;
    if CurrentSettings.TextSettings.Active then
      BoxW := CurrentSettings.ColorBoxSettings.Width
    else
      BoxW := CurrentRect.Right - CurrentRect.Left - (2 * Margin);
    BoxH := CurrentSettings.ColorBoxSettings.Height;
    if CurrentSettings.ColorBoxSettings.Shadowed then
      ShadowSize := CurrentSettings.ColorBoxSettings.ShadowSize
    else
      ShadowSize := 0;
    R := CurrentRect;
    OffsetRect(R, Margin, Margin);
    R.Right := R.Left + BoxW - ShadowSize;
    R.Bottom := R.Top + BoxH - ShadowSize;
    if (CurrentItemIsColorItem) and (CurrentColorValue < clNone) then
      with CurrentCanvas do
      begin
        SaveColor := Brush.Color;
        try
          Brush.Color := CurrentColorValue;
          FillRect(R);
          if CurrentSettings.ColorBoxSettings.Shadowed then
          begin
            Brush.Color := clGray;
            OffsetRect(R, ShadowSize, ShadowSize);
            FillRect(R);
            OffsetRect(R, -ShadowSize, -ShadowSize);
          end;
          Brush.Color := CurrentColorValue;
          Rectangle(R);
        finally
          Brush.Color := SaveColor;
        end;
      end;
    if CurrentSettings.TextSettings.Active then
      CurrentRect.Left := R.Right + CurrentSettings.ColorBoxSettings.Spacing;
  end;
end;

procedure TJvColorItemsRenderer.RenderColorText;
var
  S: string;
  R: TRect;
  OldBkMode: Integer;
begin
  if CurrentSettings.TextSettings.Active or (CurrentColorValue >= clNone) then
  begin
    S := GetRenderText;
    R := CurrentRect;
    OldBkMode := SetBkMode(CurrentCanvas.Handle, TRANSPARENT);
    try
      DrawText(CurrentCanvas.Handle, PChar(S), Length(S), R, DT_SINGLELINE or DT_END_ELLIPSIS or
        DT_VCENTER or DT_NOPREFIX);
    finally
      SetBkMode(CurrentCanvas.Handle, OldBkMode);
    end;
  end;
end;

procedure TJvColorItemsRenderer.RenderGroupHeader;
var
  S: string;
  OldFont: TFont;
  R: TRect;
  ha: TColorGroupHeaderAlign;
  RWidth: Integer;
  RVCenter: Integer;
  OldBkMode: Integer;
begin
  S := GetRenderText;
  OldFont := TFont.Create;
  try
    OldFont.Assign(CurrentCanvas.Font);
    try
      if ghsBoldFont in CurrentSettings.GroupingSettings.HeaderStyle then
        CurrentCanvas.Font.Style := CurrentCanvas.Font.Style + [fsBold];
      R := CurrentRect;
      Dec(R.Right, 2);
      if not CurrentSettings.GroupingSettings.FlatList then
        ha := ghaLeft
      else
        ha := CurrentSettings.GroupingSettings.HeaderAlign;
      case ha of
        ghaLeft:
          Inc(R.Left, 2);
        ghaColorText:
          begin
            if not CurrentSettings.TextSettings.Active or not CurrentSettings.ColorBoxSettings.Active then
              Inc(R.Left, 2)
            else
              with CurrentSettings.ColorBoxSettings do
                Inc(R.Left, Margin + Width + Spacing);
          end;
        ghaCenter:
          begin
            R.Left := 0;
            DrawText(CurrentCanvas.Handle, PChar(S), Length(S), R, DT_SINGLELINE or DT_NOPREFIX or
              DT_CALCRECT);
            RWidth := R.Right;
            R := CurrentRect;
            Inc(R.Left, 2);
            Dec(R.Right, 2);
            if RWidth < (R.Right - R.Left) then
            begin
              R.Left := R.Left + ((R.Right - R.Left - RWidth) div 2);
              R.Right := R.Left + RWidth;
            end;
          end;
      end;
      OldBkMode := SetBkMode(CurrentCanvas.Handle, TRANSPARENT);
      try
        DrawText(CurrentCanvas.Handle, PChar(S), Length(S), R, DT_SINGLELINE or DT_END_ELLIPSIS or
          DT_VCENTER or DT_NOPREFIX);
      finally
        SetBkMode(CurrentCanvas.Handle, OldBkMode);
      end;
      with CurrentSettings.GroupingSettings do
        if ([ghsSingleCenterLine, ghsDoubleCenterLine] * HeaderStyle) <> [] then
        begin
          RVCenter := CurrentRect.Top + (CurrentRect.Bottom - CurrentRect.Top) div 2;
          if R.Left > (CurrentRect.Left + 6) then
          begin
            if ghsSingleCenterLine in HeaderStyle then
            begin
              CurrentCanvas.MoveTo(CurrentRect.Left + 2, RVCenter);
              CurrentCanvas.LineTo(R.Left - 1, RVCenter);
            end
            else
            begin
              CurrentCanvas.MoveTo(CurrentRect.Left + 2, RVCenter - 1);
              CurrentCanvas.LineTo(R.Left - 1, RVCenter - 1);
              CurrentCanvas.MoveTo(CurrentRect.Left + 2, RVCenter + 1);
              CurrentCanvas.LineTo(R.Left - 1, RVCenter + 1);
            end
          end;
          DrawText(CurrentCanvas.Handle, PChar(S), Length(S), R, DT_SINGLELINE or DT_CALCRECT or
            DT_NOPREFIX);
          if R.Right < (CurrentRect.Right - 6) then
          begin
            if ghsSingleCenterLine in HeaderStyle then
            begin
              CurrentCanvas.MoveTo(R.Right + 2, RVCenter);
              CurrentCanvas.LineTo(CurrentRect.Right - 1, RVCenter);
            end
            else
            begin
              CurrentCanvas.MoveTo(R.Right + 2, RVCenter - 1);
              CurrentCanvas.LineTo(CurrentRect.Right - 1, RVCenter - 1);
              CurrentCanvas.MoveTo(R.Right + 2, RVCenter + 1);
              CurrentCanvas.LineTo(CurrentRect.Right - 1, RVCenter + 1);
            end;
          end;
        end;
    finally
      CurrentCanvas.Font.Assign(OldFont);
    end;
  finally
    OldFont.Free;
  end;
end;

procedure TJvColorItemsRenderer.MeasureColorBox(var Size: TSize);
var
  Margin: Integer;
  BoxW: Integer;
  BoxH: Integer;
  XSize: Integer;
  YSize: Integer;
begin
  if CurrentSettings.ColorBoxSettings.Active then
  begin
    Margin := CurrentSettings.ColorBoxSettings.Margin;
    if CurrentSettings.TextSettings.Active then
      BoxW := CurrentSettings.ColorBoxSettings.Width
    else
      BoxW := CurrentSettings.ColorBoxSettings.Width + Margin;
    BoxH := CurrentSettings.ColorBoxSettings.Height;

    XSize := Margin + BoxW;
    YSize := 2 * Margin + BoxH;
    if Size.cx < XSize then
      Size.cx := XSize;
    if Size.cy < YSize then
      Size.cy := YSize;
  end;
end;

procedure TJvColorItemsRenderer.MeasureColorText(var Size: TSize);
var
  XAdd: Integer;
  S: string;
  R: TRect;
begin
  if CurrentSettings.TextSettings.Active then
  begin
    XAdd := Size.cx;
    if XAdd > 0 then
      Inc(XAdd, CurrentSettings.ColorBoxSettings.Spacing);
    S := GetRenderText;
    R := Rect(0, 0, 0, 0);
    DrawText(CurrentCanvas.Handle, PChar(S), Length(S), R, DT_SINGLELINE or DT_NOPREFIX or
      DT_CALCRECT);
    Inc(R.Right, XAdd);
    if R.Right > Size.cx then
      Size.cx := R.Right;
    if R.Bottom > Size.cy then
      Size.cy := R.Bottom;
  end;
end;

procedure TJvColorItemsRenderer.DoDrawItem(ACanvas: TCanvas; var ARect: TRect; Item: IJvDataItem;
  State: TProviderDrawStates);
begin
  // setup protected fields
  CurrentCanvas := ACanvas;
  CurrentRect := ARect;
  CurrentItem := Item;
  try
    CurrentState := State;
    CurrentSettings := GetConsumerSettings;
    try
      CurrentItemIsColorItem := GetItemColorValue(Item, CurrentColorValue);
      if CurrentItemIsColorItem then
      begin
        // render the color box and/or text
        RenderColorBox;
        RenderColorText;
      end
      else
        RenderGroupHeader;
    finally
      CurrentSettings := nil;
    end;
  finally
    CurrentItem := nil;
  end;
end;

function TJvColorItemsRenderer.DoMeasureItem(ACanvas: TCanvas; Item: IJvDataItem): TSize;
begin
  // setup protected fields
  CurrentCanvas := ACanvas;
  CurrentItem := Item;
  try
    CurrentSettings := GetConsumerSettings;
    try
      CurrentItemIsColorItem := GetItemColorValue(Item, CurrentColorValue);
      Result.cx := 0;
      Result.cy := 0;
      MeasureColorBox(Result);
      MeasureColorText(Result);
    finally
      CurrentSettings := nil;
    end;
  finally
    CurrentItem := nil;
  end;
end;

type
  TOpenControl = class(TControl);

function TJvColorItemsRenderer.AvgItemSize(ACanvas: TCanvas): TSize;
var
//  Comp: TComponent;
  ChHeight: Integer;
  Metrics: TTextMetric;
  ChWdth: Integer;
begin
  CurrentSettings := GetConsumerSettings;
  try
    Result.cx := 0;
    Result.cy := 0;
    MeasureColorBox(Result);
    if CurrentSettings.TextSettings.Active then
    begin
      ChHeight := ACanvas.TextHeight('Wy');
      if ChHeight > Result.cy then
        Result.cy := ChHeight;
      GetTextMetrics(ACanvas.Handle, Metrics);
      ChWdth := Metrics.tmAveCharWidth;
(*      Comp := Items.GetProvider.SelectedConsumer.VCLComponent;
      if (Comp <> nil) and (Comp is TControl) then
      begin
        with TOpenControl(Comp) do
        begin
          if (Abs(Font.Height) + 2) > Result.cy then
            Result.cy := Abs(Font.Height) + 2;
          ChWdth := Abs(Font.Height) div 3;
        end;
      end
      else
      begin
        if Result.cy < 15 then
          Result.cy := 15;
        ChWdth := 4;
      end;*)
      if CurrentSettings.ColorBoxSettings.Active then
        Result.cx := Result.cx + CurrentSettings.ColorBoxSettings.Spacing + (10 * ChWdth)
      else
        Result.cx := 10 * ChWdth;
    end;
  finally
    CurrentSettings := nil;
  end;
end;

function TJvColorItemsRenderer.GetConsumerSettings: IJvColorProviderSettings;
begin
  Supports(Items.GetProvider.SelectedConsumer, IJvColorProviderSettings, Result);
end;

//===TJvColorProviderSettings=======================================================================

function TJvColorProviderSettings.Get_ColorBoxSettings: TJvColorProviderColorBoxSettings;
begin
  Result := FColorBoxSettings;
end;

function TJvColorProviderSettings.Get_CustomColorSettings: TJvColorProviderCustomColorGroupSettings;
begin
  Result := FCustomColorSettings;
end;

function TJvColorProviderSettings.Get_GroupingSettings: TJvColorProviderGroupingSettings;
begin
  Result := FGroupingSettings;
end;

function TJvColorProviderSettings.Get_NameMapping: TJvColorProviderNameMapping;
var
  ColorProvider: IJvColorProvider;
begin
  if (FMapping > -1) and Supports(ConsumerImpl.ProviderIntf, IJvColorProvider, ColorProvider) then
    Result := ColorProvider.Mappings[FMapping]
  else
    Result := nil;
end;

function TJvColorProviderSettings.Get_NameMappingIndex: Integer;
begin
  Result := FMapping;
end;

function TJvColorProviderSettings.Get_StandardColorSettings: TJvColorProviderColorGroupSettings;
begin
  Result := FStandardColorSettings;
end;

function TJvColorProviderSettings.Get_SystemColorSettings: TJvColorProviderColorGroupSettings;
begin
  Result := FSystemColorSettings;
end;

function TJvColorProviderSettings.Get_TextSettings: TJvColorProviderTextSettings;
begin
  Result := FTextSettings;
end;

procedure TJvColorProviderSettings.Set_ColorBoxSettings(Value: TJvColorProviderColorBoxSettings);
begin
end;

procedure TJvColorProviderSettings.Set_CustomColorSettings(
  Value: TJvColorProviderCustomColorGroupSettings);
begin
end;

procedure TJvColorProviderSettings.Set_GroupingSettings(Value: TJvColorProviderGroupingSettings);
begin
end;

procedure TJvColorProviderSettings.Set_NameMapping(Value: TJvColorProviderNameMapping);
var
  Idx: Integer;
  ColorProvider: IJvColorProvider;
begin
  if Value = nil then
    Idx := -2
  else
  begin
    if Supports(ConsumerImpl.ProviderIntf, IJvColorProvider, ColorProvider) then
      Idx := ColorProvider.IndexOfMapping(Value)
    else
      Idx := -1;
  end;
  if Idx <> -1 then
  begin
    if Idx < 0 then
      Idx := -1;
    Set_NameMappingIndex(Idx);
  end
  else
    raise EJVCLDataConsumer.Create('Specified mapping does not belong to the current provider.');
end;

procedure TJvColorProviderSettings.Set_NameMappingIndex(Value: Integer);
begin
  if FMapping <> Value then
  begin
    FMapping := Value;
    Changed(ccrOther);
  end;
end;

procedure TJvColorProviderSettings.Set_StandardColorSettings(
  Value: TJvColorProviderColorGroupSettings);
begin
end;

procedure TJvColorProviderSettings.Set_SystemColorSettings(
  Value: TJvColorProviderColorGroupSettings);
begin
end;

procedure TJvColorProviderSettings.Set_TextSettings(Value: TJvColorProviderTextSettings);
begin
end;

procedure TJvColorProviderSettings.MappingAdded(Index: Integer; Mapping: TJvColorProviderNameMapping);
begin
  if FMapping >= Index then
  begin
    Inc(FMapping);
    Changed(ccrOther);
  end;
end;

procedure TJvColorProviderSettings.MappingDestroying(Index: Integer;
  Mapping: TJvColorProviderNameMapping);
begin
  if FMapping = Index then
  begin
    FMapping := -1;
    Changed(ccrOther);
  end
  else
  if FMapping > Index then
  begin
    Dec(FMapping);
    Changed(ccrOther);
  end;
end;

function TJvColorProviderSettings.GetNameMappingIndex: TJvColorProviderMapping;
begin
  Result := Get_NameMappingIndex;
end;

procedure TJvColorProviderSettings.SetNameMappingIndex(Value: TJvColorProviderMapping);
begin
  Set_NameMappingIndex(Value);
end;

constructor TJvColorProviderSettings.Create(AOwner: TExtensibleInterfacedPersistent);
begin
  inherited Create(AOwner);
  FColorBoxSettings := TJvColorProviderColorBoxSettings.Create(Self);
  FCustomColorSettings := TJvColorProviderCustomColorGroupSettings.Create(Self, 'Custom colors');
  FGroupingSettings := TJvColorProviderGroupingSettings.Create(Self);
  FTextSettings := TJvColorProviderTextSettings.Create(Self);
  FStandardColorSettings := TJvColorProviderColorGroupSettings.Create(Self, 'Standard colors');
  FSystemColorSettings := TJvColorProviderColorGroupSettings.Create(Self, 'System colors');
  FMapping := -1;
end;

destructor TJvColorProviderSettings.Destroy;
begin
  FreeAndNil(FColorBoxSettings);
  FreeAndNil(FCustomColorSettings);
  FreeAndNil(FGroupingSettings);
  FreeAndNil(FTextSettings);
  FreeAndNil(FStandardColorSettings);
  FreeAndNil(FSystemColorSettings);
  inherited Destroy;
end;

initialization
  RegisterClasses([TJvColorProviderSettings]);
end.
