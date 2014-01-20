{
===============================================================
Console application converted color BMP files in grayscale.
By Yurij Bukatkin <Zaj87@bk.ru>
===============================================================
}

program bmp;

{$mode objfpc}


type
TBMPHeader = packed record
 CodeA:byte;
 CodeB:byte;
 FileSize:longint;
 Res1:word;
 Res2:word;
 PosBMP:longint;
 HeaderSize:longint;
 iWidth:longint;
 iHeight:longint;
 iPlanes:word;
 iBitCount:word;
 iCompress:longint;
 iSizeImage:longint;
 xResolution:longint;
 yResolution:longint;
 ColorUsed:longint;
 ColorImportant:longint;
end;

type
TRGB = record
 Blue:byte;
 Green:byte;
 Red:byte;
end;


type
 Tfunc = function(RGB:TRGB):integer of object;
 
type
TBMP = class(TObject)
 private
  BMPFile:file;
  BMPHeader:TBMPHeader;
  function Lightness(RGB:TRGB):integer;
  function Luminosity(RGB:TRGB):integer;
  function Average(RGB:TRGB):integer;
 public
  constructor Create(FileName:string);
  destructor Destroy;override;
  procedure ConvertToGray(f:Tfunc;OutputFile:string);
end;


constructor TBMP.Create(FileName:string);
begin 
 assign(BMPFile,FileName);
{$i-}
 reset(BMPFile,1);
{$i+}
 if IOResult<>0 then begin
	writeln('File ',FileName,' Not Found');
	Halt;
end;
 BlockRead(BMPFile,BMPHeader,sizeof(TBMPHeader));
end;

destructor TBMP.Destroy;
begin
 close(BMPFile);
inherited;
end;

function TBMP.Lightness(RGB:TRGB):integer;
var
a:array[0..2] of byte;
max,min:byte;
i:1..2;
begin
 a[0]:=rgb.red;
 a[1]:=rgb.green;
 a[2]:=rgb.blue;
 max:=a[0];
 min:=a[0];
 for i:=1 to 2 do begin
  if a[i]<min then min:=a[i];
  if a[i]>max then max:=a[i];
 end;
 Result:=round((max+min)/2);
end;


function TBMP.Luminosity(RGB:TRGB):integer;
begin
 Result:=round(0.21*rgb.red+0.71*rgb.green+0.07*rgb.blue);
end;


function TBMP.Average(RGB:TRGB):integer;
begin
 Result:=round((rgb.red+rgb.green+rgb.blue)/3);
end;

procedure TBMP.ConvertToGray(f:Tfunc;OutputFile:string);
var
 oBMP:file;
 RGB:TRGB;
 oHeader:TBMPHeader;
 i,j,bw:integer;
begin
with oHeader do begin
 CodeA:=$42;
 CodeB:=$4D;
 FileSize:=$00000000;
 Res1:=$00000;
 Res2:=$00000;
 PosBMP:=$36;
 HeaderSize:=$28;
 iWidth:=BMPHeader.iWidth;
 iHeight:=BMPHeader.iHeight;
 iPlanes:=BMPHeader.iPlanes;
 iBitCount:=BMPHeader.iBitCount;
 iCompress:=BMPHeader.iCompress;
 iSizeImage:=BMPHeader.iSizeImage;
 xResolution:=BMPHeader.xResolution;
 yResolution:=BMPHeader.yResolution;
 ColorUsed:=BMPHeader.Colorused;
 ColorImportant:=BMPHeader.ColorImportant;
end;
 assignfile(oBMP,OutputFile);
{$i-}
rewrite(oBMP,1);
{$i+}
if IOResult<>0 then begin
	Writeln('Error creating file ',OutputFile);
	Halt;
end;
BlockWrite(oBMP,oHeader,SizeOf(TBMPHeader));
for i:=0 to BMPHeader.iWidth-1 do begin
 for j:=0 to BMPHeader.iHeight-1 do begin
 BlockRead(BMPFile,RGB,sizeof(TRGB));
 bw:=f(RGB);
 rgb.red:=bw;
 rgb.green:=bw;
 rgb.blue:=bw;
 BlockWrite(oBMP,RGB,sizeof(TRGB));
 end;
end;
 close(oBMP);
end;

procedure ShowHelp();
begin
writeln('Free BMP converter color to grayscale 0.1.0 [2013/04/10] for i386');
writeln('Copyright (c) 2013 by Yurij Bukatkin');
writeln('Usage:');
writeln('freebc [bmpfile] [-algorithm]');
writeln('Algorithms:');
writeln('':5,'-avg ','':10,'Average algorithm');
writeln('':5,'-light ','':8,'Lightness algorithm');
writeln('':5,'-lum ','':10,'Luminosity algorithm');
writeln;
end;

var
 hBMP:TBMP;
 val1,key:string;
begin
 val1:=paramstr(1);
 key:=paramstr(2);
 if (paramcount<3) and (length(val1)<5) then begin
 ShowHelp();
 Halt;
 end;
 hBMP:=TBMP.Create(val1);
 if key = '-avg' then
  hBMP.ConverttoGray(@hbmp.Average,'grey_'+val1)
 else if key = '-light' then 
  hBMP.ConverttoGray(@hbmp.Lightness,'grey_'+val1)
 else if key = '-lum' then
  hBMP.ConverttoGray(@hbmp.Luminosity,'grey_'+val1)
 else
  ShowHelp();
 hBMP.Destroy;
end.
