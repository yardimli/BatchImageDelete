unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, JvBaseDlg, JvBrowseFolder, ExtCtrls, Spin, JvDialogs,
  JvExControls, JvXPCore, JvXPButtons, ComCtrls, FindFile, ImgList, Menus,
  ShellApi,PicsLib;

type
  TForm2 = class(TForm)
    JvBrowseForFolderDialog1: TJvBrowseForFolderDialog;
    JvXPButton1: TJvXPButton;
    JvXPButton2: TJvXPButton;
    JvXPButton3: TJvXPButton;
    JvSaveDialog1: TJvSaveDialog;
    JvXPButton5: TJvXPButton;
    PageControl: TPageControl;
    TabSheet1: TTabSheet;
    Subfolders: TCheckBox;
    TabSheet3: TTabSheet;
    PageControl1: TPageControl;
    TabSheet4: TTabSheet;
    CreatedBeforeDate: TDateTimePicker;
    CreatedAfterDate: TDateTimePicker;
    CreatedBeforeTime: TDateTimePicker;
    CreatedAfterTime: TDateTimePicker;
    CBD: TCheckBox;
    CBT: TCheckBox;
    CAD: TCheckBox;
    CAT: TCheckBox;
    TabSheet5: TTabSheet;
    ModifiedBeforeDate: TDateTimePicker;
    ModifiedAfterDate: TDateTimePicker;
    ModifiedBeforeTime: TDateTimePicker;
    ModifiedAfterTime: TDateTimePicker;
    MBD: TCheckBox;
    MBT: TCheckBox;
    MAD: TCheckBox;
    MAT: TCheckBox;
    TabSheet6: TTabSheet;
    AccessedBeforeDate: TDateTimePicker;
    AccessedAfterDate: TDateTimePicker;
    AccessedBeforeTime: TDateTimePicker;
    AccessedAfterTime: TDateTimePicker;
    ABD: TCheckBox;
    ABT: TCheckBox;
    AAD: TCheckBox;
    AAT: TCheckBox;
    TabSheet2: TTabSheet;
    Attributes: TGroupBox;
    System: TCheckBox;
    Hidden: TCheckBox;
    Readonly: TCheckBox;
    Archive: TCheckBox;
    Directory: TCheckBox;
    Compressed: TCheckBox;
    Encrypted: TCheckBox;
    Offline: TCheckBox;
    SparseFile: TCheckBox;
    ReparsePoint: TCheckBox;
    Temporary: TCheckBox;
    Device: TCheckBox;
    Normal: TCheckBox;
    NotContentIndexed: TCheckBox;
    Virtual: TCheckBox;
    FileSize: TGroupBox;
    Label10: TLabel;
    Label11: TLabel;
    SizeMaxEdit: TEdit;
    SizeMinEdit: TEdit;
    SizeMin: TUpDown;
    SizeMax: TUpDown;
    SizeMinUnit: TComboBox;
    SizeMaxUnit: TComboBox;
    FoundFiles: TListView;
    StatusBar: TStatusBar;
    ProgressImagePanel: TPanel;
    ProgressImage: TImage;
    FindFile: TFindFile;
    PopupMenu: TPopupMenu;
    OpenFileItem: TMenuItem;
    OpenFileLocationItem: TMenuItem;
    ProgressImageTimer: TTimer;
    ProgressImages: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    WidthEdit: TSpinEdit;
    HeightEdit: TSpinEdit;
    WidthOption: TRadioGroup;
    HeightOption: TRadioGroup;
    Edit2: TEdit;
    procedure Edit1Click(Sender: TObject);
    procedure JvXPButton4Click(Sender: TObject);
    procedure JvXPButton5Click(Sender: TObject);
    procedure JvXPButton3Click(Sender: TObject);
    procedure JvXPButton1Click(Sender: TObject);
    procedure FindFileFileMatch(Sender: TObject; const FileInfo: TFileDetails);
    procedure FindFileFolderChange(Sender: TObject; const Folder: string;
      var IgnoreFolder: TFolderIgnore);
    procedure FindFileSearchAbort(Sender: TObject);
    procedure FindFileSearchBegin(Sender: TObject);
    procedure FindFileSearchFinish(Sender: TObject);
    procedure OpenFileItemClick(Sender: TObject);
    procedure OpenFileLocationItemClick(Sender: TObject);
    procedure PopupMenuPopup(Sender: TObject);
    procedure ProgressImageTimerTimer(Sender: TObject);
    procedure CBDClick(Sender: TObject);
    procedure CBTClick(Sender: TObject);
    procedure CADClick(Sender: TObject);
    procedure CATClick(Sender: TObject);
    procedure MBDClick(Sender: TObject);
    procedure MBTClick(Sender: TObject);
    procedure MADClick(Sender: TObject);
    procedure MATClick(Sender: TObject);
    procedure ABDClick(Sender: TObject);
    procedure ABTClick(Sender: TObject);
    procedure AADClick(Sender: TObject);
    procedure AATClick(Sender: TObject);
    procedure Edit2Click(Sender: TObject);
    procedure JvXPButton2Click(Sender: TObject);
  private
    { Private declarations }
    Folders: Integer;
    StartTime: DWord;
    SortedColumn: Integer;
    Descending: Boolean;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses Unit1;

{$R *.dfm}

procedure TForm2.AADClick(Sender: TObject);
begin
  AccessedAfterDate.Enabled := AAD.Checked;
end;

procedure TForm2.AATClick(Sender: TObject);
begin
  AccessedAfterTime.Enabled := AAT.Checked;
end;

procedure TForm2.ABDClick(Sender: TObject);
begin
  AccessedBeforeDate.Enabled := ABD.Checked;
end;

procedure TForm2.ABTClick(Sender: TObject);
begin
  AccessedBeforeTime.Enabled := ABT.Checked;
end;

procedure TForm2.CADClick(Sender: TObject);
begin
  AccessedAfterDate.Enabled := AAD.Checked;
end;

procedure TForm2.CATClick(Sender: TObject);
begin
  AccessedAfterTime.Enabled := AAT.Checked;
end;

procedure TForm2.CBDClick(Sender: TObject);
begin
  AccessedBeforeDate.Enabled := ABD.Checked;
end;

procedure TForm2.CBTClick(Sender: TObject);
begin
  AccessedBeforeTime.Enabled := ABT.Checked;
end;

procedure TForm2.Edit1Click(Sender: TObject);
begin
if JvBrowseForFolderDialog1.Execute then
 Edit1.Text := JvBrowseForFolderDialog1.Directory;
end;

procedure TForm2.Edit2Click(Sender: TObject);
begin
if JvBrowseForFolderDialog1.Execute then
begin
 Edit2.Text := JvBrowseForFolderDialog1.Directory;
 JvXPButton2.Caption := 'Move Now';
end;
end;

function GetAttributeStatus(CB: TCheckBox): TFileAttributeStatus;
begin
  case CB.State of
    cbUnchecked: Result := fsUnset;
    cbChecked: Result := fsSet;
  else
    Result := fsIgnore;
  end;
end;

procedure TForm2.FindFileFileMatch(Sender: TObject;
  const FileInfo: TFileDetails);
var
 xw,xh:dword;
 AddThisW,AddThisH : Boolean;
begin
  GetImageSize(FileInfo.Location+FileInfo.Name,xw,xh);

  AddThisW := FALSE;
  if (WidthOption.ItemIndex<>3) then
  begin
    if (WidthOption.ItemIndex = 0) and (xw>WidthEdit.Value) then AddThisW := TRUE;
    if (WidthOption.ItemIndex = 1) and (xw<WidthEdit.Value) then AddThisW := TRUE;
    if (WidthOption.ItemIndex = 2) and (xw=WidthEdit.Value) then AddThisW := TRUE;
  end else AddThisW := TRUE;

  AddThisH := FALSE;
  if (HeightOption.ItemIndex<>3) then
  begin
    if (HeightOption.ItemIndex = 0) and (xh>HeightEdit.Value) then AddThisH := TRUE;
    if (HeightOption.ItemIndex = 1) and (xh<HeightEdit.Value) then AddThisH := TRUE;
    if (HeightOption.ItemIndex = 2) and (xh=HeightEdit.Value) then AddThisH := TRUE;
  end else AddThisH := TRUE;

  if (AddThisW) and (AddThisH) then
  begin
   with FoundFiles.Items.Add do
   begin
     Caption := FileInfo.Name;
     SubItems.Add(FileInfo.Location);
     if LongBool(FileInfo.Attributes and FILE_ATTRIBUTE_DIRECTORY) then
       SubItems.Add('Folder')
     else
       SubItems.Add(FormatFileSize(FileInfo.Size));
     SubItems.Add(DateTimeToStr(FileInfo.ModifiedTime));
     GetImageSize(FileInfo.Location+FileInfo.Name,xw,xh);
     if (xw=0) or (xh=0) then
      SubItems.Add('error') else
      SubItems.Add(inttostr(xw)+'x'+inttostr(xh)+'px');
   end;
  end;

  if not FindFile.Threaded then Application.ProcessMessages;
end;

procedure TForm2.FindFileFolderChange(Sender: TObject; const Folder: string;
  var IgnoreFolder: TFolderIgnore);
begin
  Inc(Folders);
  StatusBar.SimpleText := Folder;
  if not FindFile.Threaded then
    Application.ProcessMessages;
end;

procedure TForm2.FindFileSearchAbort(Sender: TObject);
begin
  StatusBar.SimpleText := 'Cancelling search, please wait...';
end;

procedure TForm2.FindFileSearchBegin(Sender: TObject);
begin
  Folders := 0;
  SortedColumn := -1;
  FoundFiles.SortType := stNone;
  FoundFiles.Items.BeginUpdate;
  FoundFiles.Items.Clear;
  FoundFiles.Items.EndUpdate;
  JvXPButton1.Enabled := False;
  //StopButton.Enabled := True;
  //Threaded.Enabled := False;
  ProgressImagePanel.Visible := True;
  ProgressImageTimer.Enabled := True;
  StartTime := GetTickCount;
end;

procedure TForm2.FindFileSearchFinish(Sender: TObject);
begin
  StatusBar.SimpleText := Format('%d folder(s) searched and %d file(s) found - %.3f second(s)',
    [Folders, FoundFiles.Items.Count, (GetTickCount - StartTime) / 1000]);
  if FindFile.Aborted then
    StatusBar.SimpleText := 'Search cancelled - ' + StatusBar.SimpleText;
  ProgressImageTimer.Enabled := False;
  ProgressImagePanel.Visible := False;
  //Threaded.Enabled := True;
  //StopButton.Enabled := False;
  JvXPButton1.Enabled := True;
end;

procedure TForm2.JvXPButton1Click(Sender: TObject);
begin
  // Sets FileFile properties
  FindFile.Threaded := TRUE;
  // - Name & Location
  with FindFile.Criteria.Files do
  begin
    FileName := '*.jpg;*.bmp;*.gif;*.png';
    Location := Edit1.Text;
    Subfolders := Self.Subfolders.Checked;
    //Filters.Assign(Self.Filters.Lines);
  end;
  // - Containing Text
  (*
  with FindFile.Criteria.Content do
  begin
    Phrase := Self.Phrase.Text;
    Options := [];
    if Self.CaseSenstitive.Checked then
      Options := Options + [csoCaseSensitive];
    if Self.WholeWord.Checked then
      Options := Options + [csoWholeWord];
  end;
  *)
  // - Attributes
  with FindFile.Criteria.Attributes do
  begin
    Archive := GetAttributeStatus(Self.Archive);
    Readonly := GetAttributeStatus(Self.Readonly);
    Hidden := GetAttributeStatus(Self.Hidden);
    System := GetAttributeStatus(Self.System);
    Directory := GetAttributeStatus(Self.Directory);
    Compressed := GetAttributeStatus(Self.Compressed);
    Encrypted := GetAttributeStatus(Self.Encrypted);
    Offline := GetAttributeStatus(Self.Offline);
    ReparsePoint := GetAttributeStatus(Self.ReparsePoint);
    SparseFile := GetAttributeStatus(Self.SparseFile);
    Temporary := GetAttributeStatus(Self.Temporary);
    Device := GetAttributeStatus(Self.Device);
    Normal := GetAttributeStatus(Self.Normal);
    Virtual := GetAttributeStatus(Self.Virtual);
    NotContentIndexed := GetAttributeStatus(Self.NotContentIndexed);
  end;
  // - Size ranges
  with FindFile.Criteria.Size do
  begin
    Min := Self.SizeMin.Position;
    case Self.SizeMinUnit.ItemIndex of
      1: Min := Min * 1024;
      2: Min := Min * 1024 * 1024;
      3: Min := Min * 1024 * 1024 * 1024;
    end;
    Max := Self.SizeMax.Position;
    case Self.SizeMaxUnit.ItemIndex of
      1: Max := Max * 1024;
      2: Max := Max * 1024 * 1024;
      3: Max := Max * 1024 * 1024 * 1024;
    end;
  end;
  // - TimeStamp ranges
  with FindFile.Criteria.TimeStamp do
  begin
    Clear;
    // Created on
    if Self.CBD.Checked then
      CreatedBefore := Self.CreatedBeforeDate.Date;
    if Self.CBT.Checked then
      CreatedBefore := CreatedBefore + Self.CreatedBeforeTime.Time;
    if Self.CAD.Checked then
      CreatedAfter := Self.CreatedAfterDate.Date;
    if Self.CAT.Checked then
      CreatedAfter := CreatedAfter + Self.CreatedAfterTime.Time;
    // Modified on
    if Self.MBD.Checked then
      ModifiedBefore := Self.ModifiedBeforeDate.Date;
    if Self.MBT.Checked then
      ModifiedBefore := ModifiedBefore + Self.ModifiedBeforeTime.Time;
    if Self.MAD.Checked then
      ModifiedAfter := Self.ModifiedAfterDate.Date;
    if Self.MAT.Checked then
      ModifiedAfter := ModifiedAfter + Self.ModifiedAfterTime.Time;
    // Accessed on
    if Self.ABD.Checked then
      AccessedBefore := Self.AccessedBeforeDate.Date;
    if Self.ABT.Checked then
      AccessedBefore := AccessedBefore + Self.AccessedBeforeTime.Time;
    if Self.AAD.Checked then
      AccessedAfter := Self.AccessedAfterDate.Date;
    if Self.AAT.Checked then
      AccessedAfter := AccessedAfter + Self.AccessedAfterTime.Time;
  end;
  // Begins search
  FindFile.Execute;
end;

procedure TForm2.JvXPButton2Click(Sender: TObject);
var
 i,j,k:integer;
 ii : TListItem;
begin
  ProgressImagePanel.Visible := True;
  ProgressImageTimer.Enabled := True;
  StartTime := GetTickCount;
  for i := 1 to 100 do begin sleep(15); Application.ProcessMessages; end;
    

 if FoundFiles.Items.Count=0 then
 begin
  MessageBox(Application.Handle,'No files found, so nothing can be done.','Result',mb_ok);
  ProgressImagePanel.Visible := FALSE;
  ProgressImageTimer.Enabled := FALSE;

  exit;
 end;

 if Dialogs.MessageDlg('This operation is not reversible. Continue?',
    mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
 begin
  if pos('click here',Edit2.Text)=0 then
  //move files
  begin
   for i := 0 to FoundFiles.Items.Count-1 do
   begin
    ii := FoundFiles.Items[i];
    movefile ( pchar( ii.SubItems[0] + ii.Caption ),pchar(Edit2.Text + '\' +ii.Caption) );
   end;
   MessageBox(Application.Handle,'Move operation has been completed.','Result',mb_ok);
  end else
  begin
  //delete files
   for i := 0 to FoundFiles.Items.Count-1 do
   begin
    ii := FoundFiles.Items[i];
    DeleteFile  ( pchar( ii.SubItems[0] + ii.caption ));
   end;
   MessageBox(Application.Handle,'Delete operation has been completed.','Result',mb_ok);
  end;
 end else
 MessageBox(Application.Handle,'Nothing was done.','Result',mb_ok);

  ProgressImagePanel.Visible := FALSE;
  ProgressImageTimer.Enabled := FALSE;

end;

procedure TForm2.JvXPButton3Click(Sender: TObject);
begin
 StatusBar.SimpleText := 'Cancelling search, please wait...';
 FindFile.Abort;
 Close;
end;

procedure TForm2.JvXPButton4Click(Sender: TObject);
var
 i,j,k:integer;
begin
 if JvSaveDialog1.Execute  then
 begin
  //Memo1.Lines.SaveToFile(JvSaveDialog1.FileName);
 end;
end;

procedure TForm2.JvXPButton5Click(Sender: TObject);
begin
 Form1 := TForm1.Create(Application);
 Form1.ShowModal;
 Form1.Close;
end;

procedure TForm2.MADClick(Sender: TObject);
begin
  ModifiedAfterDate.Enabled := MAD.Checked;
end;

procedure TForm2.MATClick(Sender: TObject);
begin
  ModifiedAfterTime.Enabled := MAT.Checked;
end;

procedure TForm2.MBDClick(Sender: TObject);
begin
  ModifiedBeforeDate.Enabled := MBD.Checked;
end;

procedure TForm2.MBTClick(Sender: TObject);
begin
  ModifiedBeforeTime.Enabled := MBT.Checked;
end;

procedure TForm2.OpenFileItemClick(Sender: TObject);
begin
  if FoundFiles.Selected <> nil then
    with FoundFiles.Selected do
      ShellExecute(0, 'Open', PChar(Caption), nil, PChar(SubItems[0]), SW_NORMAL);
end;

procedure TForm2.OpenFileLocationItemClick(Sender: TObject);
begin
  if FoundFiles.Selected <> nil then
    with FoundFiles.Selected do
      ShellExecute(0, 'Open', PChar(SubItems[0]), nil, nil, SW_NORMAL);
end;

procedure TForm2.PopupMenuPopup(Sender: TObject);
begin
  OpenFileItem.Enabled := (FoundFiles.Selected <> nil);
  OpenFileLocationItem.Enabled := (FoundFiles.Selected <> nil);
end;

procedure TForm2.ProgressImageTimerTimer(Sender: TObject);
begin
  ProgressImages.Tag := (ProgressImages.Tag + 1) mod ProgressImages.Count;
  ProgressImages.GetBitmap(ProgressImages.Tag, ProgressImage.Picture.Bitmap);
  ProgressImage.Refresh;
end;

end.
