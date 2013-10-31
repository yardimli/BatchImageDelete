unit PicsLib;

interface

uses Windows;

function GetBMPSize(const Fn: String; var Width, Height: dword):Boolean;
function GetGIFSize(const Fn: String; var Width, Height: dword):Boolean;
function GetJPGSize(const Fn: String; var Width, Height: dword):Boolean;
function GetPNGSize(const Fn: String; var Width, Height: dword):Boolean;
function GetImageSize(const Fn: String; var Width, Height: dword):Boolean;

procedure GetJPGSize2(const sFile: string; var wWidth, wHeight: dword);
procedure GetPNGSize2(const sFile: string; var wWidth, wHeight: dword);
procedure GetGIFSize2(const sGIFFile: string; var wWidth, wHeight: dword);

implementation

uses SysUtils, Classes;

type TBitmapFileHeader = Packed Record
ID: word;
FileSize: dword;
Reserved: dword;
BitmapDataOffset: dword;
end;
TBitmapInfo = Packed Record
BitmapHeaderSize: dword;
Width: dword;
Height: dword;
Planes: word;
BitsPerPixel: word;
Compression: dword;
BitmapDataSize: dword;
XpelsPerMeter: dword;
YPelsPerMeter: dword;
ColorsUsed: dword;
ColorsImportant: dword;
end;

TGIFHeader = Packed Record
ID: array[0..5] of ansichar;
Width, Height: Word;
end;

TPNGHeader = Packed Record
ID: array[0..7] of ansichar;
ChunkLength: dword;
ChunkType: array[0..3] of ansichar;
Width: dword;
Height: dword;
BitsPerPixel: byte;
ColorType: byte;
Compression: byte;
FilterMethod: byte;
CRC: dword;
end;

TJPGHeader = array[0..1] of Byte; //FFD8 = StartOfImage (SOI)
TSOFHeader = Packed record
Len: word;
DataPrecision: byte;
Height, Width: word;
NrComponents: byte;
end;


function ReadMWord(f: TFileStream): word;
type
  TMotorolaWord = record
    case byte of
      0: (Value: word);
      1: (Byte1, Byte2: byte);
  end;
var
  MW: TMotorolaWord;
begin
  { It would probably be better to just read these two bytes in normally }
  { and then do a small ASM routine to swap them.  But we aren't talking }
  { about reading entire files, so I doubt the performance gain would be }
  { worth the trouble. }
  f.Read(MW.Byte2, SizeOf(Byte));
  f.Read(MW.Byte1, SizeOf(Byte));
  Result := MW.Value;
end;

procedure GetJPGSize2(const sFile: string; var wWidth, wHeight: dword);
const
  ValidSig : array[0..1] of byte = ($FF, $D8);
  Parameterless = [$01, $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7];
var
  Sig: array[0..1] of byte;
  f: TFileStream;
  x: integer;
  Seg: byte;
  Dummy: array[0..15] of byte;
  Len: word;
  ReadLen: LongInt;
begin
  FillChar(Sig, SizeOf(Sig), #0);
  f := TFileStream.Create(sFile, fmOpenRead);
  try
    ReadLen := f.Read(Sig[0], SizeOf(Sig));

    for x := Low(Sig) to High(Sig) do
      if Sig[x] <> ValidSig[x] then ReadLen := 0;

    if ReadLen > 0 then
    begin
      ReadLen := f.Read(Seg, 1);
      while (Seg = $FF) and (ReadLen > 0) do
      begin
        ReadLen := f.Read(Seg, 1);
        if Seg <> $FF then
        begin
          if (Seg = $C0) or (Seg = $C1) then
          begin
            ReadLen := f.Read(Dummy[0], 3); { don't need these bytes }
            wHeight := ReadMWord(f);
            wWidth := ReadMWord(f);
          end else begin
            if not (Seg in Parameterless) then
            begin
              Len := ReadMWord(f);
              f.Seek(Len-2, 1);
              f.Read(Seg, 1);
            end else
              Seg := $FF; { Fake it to keep looping. }
          end;
        end;
      end;
    end;
  finally
    f.Free;
  end;
end;

procedure GetPNGSize2(const sFile: string; var wWidth, wHeight: dword);
type
  TPNGSig = array[0..7] of byte;
const
  ValidSig: TPNGSig = (137,80,78,71,13,10,26,10);
var
  Sig: TPNGSig;
  f: tFileStream;
  x: integer;
begin
  FillChar(Sig, SizeOf(Sig), #0);
  f := TFileStream.Create(sFile, fmOpenRead);
  try
    f.Read(Sig[0], SizeOf(Sig));
    for x := Low(Sig) to High(Sig) do
      if Sig[x] <> ValidSig[x] then exit;
    f.Seek(18, 0);
    wWidth := ReadMWord(f);
    f.Seek(22, 0);
    wHeight := ReadMWord(f);
  finally
    f.Free;
  end;
end;


procedure GetGIFSize2(const sGIFFile: string; var wWidth, wHeight: dword);
type
  TGIFHeader = record
    Sig: array[0..5] of ansichar;
    ScreenWidth, ScreenHeight: word;
    Flags, Background, Aspect: byte;
  end;

  TGIFImageBlock = record
    Left, Top, Width, Height: word;
    Flags: byte;
  end;
var
  f: file;
  Header: TGifHeader;
  ImageBlock: TGifImageBlock;
  nResult: integer;
  x: integer;
  c: ansichar;
  DimensionsFound: boolean;
begin
  wWidth  := 0;
  wHeight := 0;

  if sGifFile = '' then
    exit;

  {$I-}
  FileMode := 0;   { read-only }
  AssignFile(f, sGifFile);
  reset(f, 1);
  if IOResult <> 0 then
    { Could not open file }
    exit;

  { Read header and ensure valid file. }
  BlockRead(f, Header, SizeOf(TGifHeader), nResult);
  if (nResult <> SizeOf(TGifHeader)) or (IOResult <> 0) or
     (StrLComp('GIF', Header.Sig, 3) <> 0) then
  begin
    { Image file invalid }
    close(f);
    exit;
  end;

  { Skip color map, if there is one }
  if (Header.Flags and $80) > 0 then
  begin
    x := 3 * (1 SHL ((Header.Flags and 7) + 1));
    Seek(f, x);
    if IOResult <> 0 then
    begin
      { Color map thrashed }
      close(f);
      exit;
    end;
  end;

  DimensionsFound := False;
  FillChar(ImageBlock, SizeOf(TGIFImageBlock), #0);
  { Step through blocks. }
  BlockRead(f, c, 1, nResult);
  while (not EOF(f)) and (not DimensionsFound) do
  begin
    case c of
      ',': { Found image }
        begin
          BlockRead(f, ImageBlock, SizeOf(TGIFImageBlock), nResult);
          if nResult <> SizeOf(TGIFImageBlock) then begin
            { Invalid image block encountered }
            close(f);
            exit;
          end;
          wWidth  := ImageBlock.Width;
          wHeight := ImageBlock.Height;
          DimensionsFound := True;
        end;
      'ÿ' : { Skip }
        begin
          { NOP }
        end;
    { nothing else.  just ignore }
    end;
    BlockRead(f, c, 1, nResult);
  end;

  close(f);
  {$I+}
end;


function MotorolaToIntelDW(DW: dword): dword;
var HiWd, LoWd: word;
begin
HiWd := HiWord(DW);
LoWd := LoWord(DW);
HiWd := Swap(HiWd);
LoWd := Swap(LoWd);
Result := HiWd + (LoWd shl 16);
end;


function GetImageSize(const Fn: String; var Width, Height: dword):
Boolean;
begin
if AnsiUpperCase(ExtractFileExt(Fn)) = '.BMP' then
begin
Result := GetBMPSize(Fn, Width, Height);
end
else if AnsiUpperCase(ExtractFileExt(Fn)) = '.GIF' then
begin
GetGIFSize2(Fn, Width, Height);
end
else if (AnsiUpperCase(ExtractFileExt(Fn)) = '.JPG')
or (AnsiUpperCase(ExtractFileExt(Fn)) = '.JPEG') then
begin
Result := GetJPGSize(Fn, Width, Height);
end
else if AnsiUpperCase(ExtractFileExt(Fn)) = '.PNG' then
begin
Result := GetPNGSize(Fn, Width, Height);
end
else
begin
Width := 0;
Height := 0;
Result := False;
end;
end;



function GetBMPSize(const Fn: String; var Width, Height: dword):
Boolean;
var BitmapFileHeader: TBitmapFileHeader;
BitmapInfo: TBitmapInfo;
F: File;
i:integer;
bRead: Integer;
IDStr: String;
begin
Result := False;
Width := 0;
Height := 0;
Try
AssignFile(F,Fn);
FileMode := fmOpenRead or fmShareDenyWrite;
Reset(F,1);
BlockRead(F,BitmapFileHeader,SizeOf(TBitmapFileHeader),bRead);
if bRead <> SizeOf(TBitmapFileHeader) then Raise
EInOutError.Create('');
BlockRead(F,BitmapInfo,SizeOf(TBitmapInfo),bRead);
if bRead <> SizeOf(TBitmapInfo) then Raise EInOutError.Create('');
CloseFile(F);
IDStr := ansiChar(Lo(BitmapFileHeader.ID)) +
ansiChar(Hi(BitmapFileHeader.ID));
//Klopt bestandsopmaak ?
if (not (IDStr = 'BM') or (IDStr = 'BA')) or
(not (BitmapInfo.BitmapHeaderSize in [$28,$0c,$f0])) or
(not (BitmapInfo.BitsPerPixel in [1,4,8,16,24,32])) then Exit;

Width := BitmapInfo.Width;
Height := BitmapInfo.Height;
Result := True;
Except
on EInOutError do
begin
{$I-}
CloseFile(F);
i := IOResult; //Negeer IO errors hier (mogelijk is bestand algeclosed)
Exit;
end;
end;//try...except
end;

function GetGIFSize(const Fn: String; var Width, Height: dword):
Boolean;
var GifHeader: TGIFHeader;
i:integer;
F: File;
bRead: Integer;
begin
Result := False;
Width := 0;
Height := 0;
Try
AssignFile(F,Fn);
FileMode := fmOpenRead or fmShareDenyWrite;
Reset(F,1);
BlockRead(F,GifHeader,SizeOf(TGIFHeader),bRead);
if bRead <> SizeOf(TGIFHeader) then Raise EInOutError.Create('');
CloseFile(F);
//Klopt bestandsopmaak ?
if not ((AnsiUpperCase(GifHeader.ID) = 'GIF87A') or
(AnsiUpperCase(GifHeader.ID) = 'GIF89A')) then Exit;
Width := GifHeader.Width;
Height := GifHeader.Height;
Result := True;
Except
on EInOutError do
begin
{$I-}
CloseFile(F);
i := IOResult; //Negeer IO errors hier (mogelijk is bestand algeclosed)geclosed)
Exit;
end;
end;//try...except
end;


function GetPNGSize(const Fn: String; var Width, Height: dword):
Boolean;
var PNGHeader: TPNGHeader;
F: File;
i:integer;
bRead: Integer;
begin
Result := False;
Width := 0;
Height := 0;
Try
AssignFile(F,Fn);
FileMode := fmOpenRead or fmShareDenyWrite;
Reset(F,1);
BlockRead(F,PNGHeader,SizeOf(TPNGHeader),bRead);
if bRead <> SizeOf(TPNGHeader) then Raise EInOutError.Create('');
CloseFile(F);
//Klopt bestandsopmaak ?
if (AnsiUpperCase(PNGHeader.ID) <> #137'PNG'#13#10#26#10) or
(AnsiUpperCase(PNGHeader.ChunkType) <> 'IHDR') then exit;
Width := MotorolaToIntelDW(PNGHeader.Width);
Height := MotorolaToIntelDW(PNGHeader.Height);
Result := true;
Except
on EInOutError do
begin
{$I-}
CloseFile(F);
i := IOResult; //Negeer IO errors hier (mogelijk is bestand algeclosed)
Exit;
end;
end;//try...except
end;


function GetJPGSize(const Fn: String; var Width, Height: dword):
Boolean;
const Parameterless = [$01, $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7];
var F: File;
bRead: Integer;
i:integer;
JPGHeader: TJPGHeader;
SOFHeader: TSOFHeader;
B, SegType: byte;
SegSize: Word; //Thumbnail Size
SOF_Found: boolean;
Dummy: array[0..65532] of byte; //Max segment length
begin
Result := False;
Width := 0;
Height := 0;
Try
AssignFile(F,Fn);
FileMode := fmOpenRead or fmShareDenyWrite;
Reset(F,1);
BlockRead(F,JPGHeader, SizeOf(TJPGHeader),bRead);
if bRead <> SizeOf(TJPGHeader) then Raise EInOutError.Create('');
if (JPGHeader[0] <> $FF) or (JPGHeader[1] <> $D8) then
begin
CloseFile(F);
Exit;
end;
SOF_Found := False;
// JFIF_Found := False;
//Op zoek naar JFIFF en StartOfFrame (SOF) segment
BlockRead(F,B,1,bRead);
if bRead <> 1 then Raise EInoutError.Create('');
While (not EOF(F)) and (B = $FF) and not (SOF_Found {and
JFIF_Found}) do //Alle segmenten beginnen met $FF
begin
BlockRead(F,SegType,1,bRead);
if bRead <> 1 then Raise EInoutError.Create('');
case SegType of
$c0,$c1,$c2 {,$c3,$c5,$c6,$c7,$c9,$ca,$cb,$cd,$ce,$cf ???}:
begin//StartOfFrame
BlockRead(F,SOFHeader,SizeOf(TSOFHeader),bRead);
if bRead <> SizeOf(TSOFHeader) then Raise
EInOutError.Create('');
//Motorola -> Intel
SOFHeader.Len := Swap(SOFHeader.Len);
SOFHeader.Height := Swap(SOFHeader.Height);
SOFHeader.Width := Swap(SOFHeader.Width);
BlockRead(F,Dummy,SOFHeader.NrComponents*3,bRead);
if bRead <> (SOFHeader.NrComponents * 3) then Raise
EInOutError.Create('');
Width := SOFHeader.Width;
Height := SOFHeader.Height;
SOF_Found := true;
end;
$01, $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7:
begin//Parameterloos segment
// Negeer
end;
$d9:
begin//EndOfImage
Break;
end;
$da:
begin//Start Of Scan: JPG Data
Break;
end;
else
begin//Lees segment in dummy en sla over
//De eerste 2 bytes zijn lengte v.h. segment
//inclusief de 2 lengte-bytes
//Lengtebytes zijn in Motorola formaat (Hi-Lo)
BlockRead(F,SegSize,SizeOf(SegSize),bRead);
if bRead <> SizeOf(SegSize) then Raise
EInOutError.Create('');
SegSize := Swap(SegSize);
if SegSize > 2 then
begin//RLees tot eind van segment
SegSize := SegSize - 2;
BlockRead(F,Dummy,SegSize,bRead);
if bRead <> SegSize then Raise EInOutError.Create('');
end;
end;
end;//case
//Lees volgense segmentbegin, B moet nu $FF zijn ...
BlockRead(F,B,1,bRead);
if bRead <> 1 then Raise EInoutError.Create('');
end;//While
//Alle info gevonden en opmaak klopt ?
if {JFIF_Found and} SOF_Found then Result := True;

CloseFile(F);
Except
on EInOutError do
begin
{$I-}
CloseFile(F);
i := IOResult; //Negeer IO errors hier (mogelijk is bestand algeclosed)
Exit;
end;
end;//try...except
end;




end.
