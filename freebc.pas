{
===============================================================
Console application converted color BMP files in grayscale.
By Yurij Bukatkin <Zaj87@bk.ru>
===============================================================
}

Program Bmp;

{$mode objfpc}


Type
TBMPHeader = packed record
 CodeA:Byte;
 CodeB:Byte;
 FileSize:Longint;
 Res1:Word;
 Res2:Word;
 PosBMP:Longint;
 HeaderSize:Longint;
 iWidth:Longint;
 iHeight:Longint;
 iPlanes:Word;
 iBitCount:Word;
 iCompress:Longint;
 iSizeImage:Longint;
 xResolution:Longint;
 yResolution:Longint;
 ColorUsed:Longint;
 ColorImportant:Longint;
end;

type
TRGB = record
 Blue:Byte;
 Green:Byte;
 Red:Byte;
end;


type
 TFunc = function(RGB:TRGB):Integer of object;
 
type
TBMP = class(TObject)
 private
  BMPFile:file;
  BMPHeader:TBMPHeader;
  function Lightness(RGB:TRGB):Integer;
  function Luminosity(RGB:TRGB):Integer;
  function Average(RGB:TRGB):Integer;
 public
  constructor Create(FileName:String);
  destructor Destroy;override;
  procedure ConvertToGray(F:TFunc;OutputFile:String);
end;


constructor TBMP.Create(FileName:String);
begin 
 Assign(BMPFile,FileName);
{$i-}
 Reset(BMPFile,1);
{$i+}
 if IOResult<>0 then begin
	Writeln('File ',FileName,' Not Found');
	Halt;
end;
 BlockRead(BMPFile,BMPHeader,Sizeof(TBMPHeader));
end;

destructor TBMP.Destroy;
begin
 close(BMPFile);
inherited;
end;

function TBMP.Lightness(RGB:TRGB):integer;
var
a:array[0..2] of Byte;
Max,Min:Byte;
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
 Result:=Round((max+min)/2);
end;


function TBMP.Luminosity(RGB:TRGB):Integer;
begin
 Result:=round(0.21*rgb.red+0.71*rgb.green+0.07*rgb.blue);
end;


function TBMP.Average(RGB:TRGB):Integer;
begin
 Result:=Round((rgb.red+rgb.green+rgb.blue)/3);
end;

procedure TBMP.ConvertToGray(F:TFunc;OutputFile:String);
var
 oBMP:File;
 RGB:TRGB;
 oHeader:TBMPHeader;
 i,j,bw:Integer;
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
 Assignfile(oBMP,OutputFile);
{$i-}
 Rewrite(oBMP,1);
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
