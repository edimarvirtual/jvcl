{$I JVCL.INC}

unit JvCtrlsReg;

interface

procedure Register;

implementation
uses
  Classes, Controls, DesignIntf,
  JvZoom, JvAnalogClock, JvBehaviorLabel, JvArrowButton, JvaScrollText, JvCaptionButton,
  JvClock, JvContentScroller, JvColorBox, JvColorButton, JvDice,
  JvDriveCtrls, JvFooter, JvGroupHeader, JvHtControls, JvInstallLabel, JvItemsPanel,
  JvListComb, JvPageScroller, JvRegistryTreeView, JvRollOut, JvScrollPanel,
  JvScrollText, JvSpacer, JvSpeedBar, JvSplit, JvSplitter, JvSwitch, JvSyncSplitter,
  JvTransparentButton, JvTransLED, JvxClock, JvSpeedbarSetupForm,
  JvColorForm, JvDsgnIntf, JvImageDrawThread, JvRegAuto, JvWinampLabel,
  JvButtons, JvCaptionPanel, JvScrollMax,
  JvRegAutoEditor, JvScrollMaxEditor, JvBehaviorLabelEditor, JvGroupHeaderEditor, JvFooterEditor,
  JvDsgnEditors;

{.$R ..\resources\JvCtrlsReg.dcr}

procedure Register;
begin
  RegisterComponents('Jv Controls',[
    TJvZoom, TJvAnalogClock, TJvBehaviorLabel, TJvArrowButton, TJvaScrollText,
    TJvCaptionButton, TJvClock, TJvContentScroller, TJvColorButton, TJvDice,
    TJvDriveCombo, TJvDriveList, TJvFileListBox, TJvDirectoryListBox,
    TJvFooter, TJvGroupHeader, TJvInstallLabel, TJvItemsPanel,
    TJvHtListBox, TJvHTComboBox, TJvHTLabel,
    TJvImageComboBox, TJvImageListBox, TJvPageScroller, TJvRegistryTreeView,
    TJvRollOut, TJvScrollingWindow, TJvScrollText, TJvSpacer, TJvSpeedBar,
    TJvSplitter, TJvxSplitter, TJvSwitch, TJvSyncSplitter,  TJvTransparentButton,
    TJvTransparentButton2, TJvTransLED, TJvxClock, TJvRegAuto, TJvWinampLabel,
    TJvHTButton, TJvCaptionPanel, TJvScrollMax, TJvBehaviorLabel
    ]);

  RegisterPropertyEditor(typeinfo(TCaption), TJvHTLabel, 'Caption', TJvHintProperty);
  RegisterPropertyEditor(typeinfo(TJvLabelBehaviorName),TJvBehaviorLabel,'Behavior',TJvLabelBehaviorProperty);
  RegisterPropertyEditor(TypeInfo(TCursor), TJvxSplitter, 'Cursor', nil);
  RegisterPropertyEditor(TypeInfo(TDateTime),TJvAlarmInfo,'Date',TJvDateTimeExProperty);
  
  RegisterComponentEditor(TJvScrollMax, TJvScrollMaxEditor);
  RegisterComponentEditor(TJvGroupHeader, TJvGroupHeaderEditor);
  RegisterComponentEditor(TJvFooter, TJvFooterEditor);

  RegisterComponentEditor(TJvRegAuto, TJvRegAutoEditor);

  RegisterClass(TJvScrollMaxBand);

end;

end.
