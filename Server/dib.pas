(*
Device independant bitmap functions.
Copyright (C) 2000, Oliver George

{-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License 
Version 1.1 (the "License"); you may not use this file except in compliance 
with the License. You may obtain a copy of the License at 
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis, 
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for 
the specific language governing rights and limitations under the License. 

The Initial Developer of the Original Code is Oliver George.
Portions created by Oliver George are Copyright (C) 1999 Oliver George.  
All Rights Reserved. 

Contributor(s): (None at this stage)

Last Modified: 4th November 2000
Current Version: 0.9

You may retrieve the latest version of this file at the Project JEDI home page, 
located at http://www.delphi-jedi.org

Known Issues: 
-----------------------------------------------------------------------------}
  
(none as yet)

==================================================================
That was the license, general implications are:
- free to use
- free to modify
- source code of this library (not your whole app) must be available.

*)

unit dib;

interface

uses
  Windows, classes, graphics;

  procedure write_dib_to_stream(DIBHandle: HBITMAP;Stream: TStream);
  procedure load_dib_into_bitmap(DIBHandle: HBITMAP;Bitmap: TBitmap);

implementation

function ColourCount(lpDib: PBitmapInfo): integer;
var
  lpbi: PBITMAPINFOHEADER;
  lpbc: PBITMAPCOREHEADER;
  bits: integer;
begin

  lpbi := pointer(lpDib);
  lpbc := pointer(lpDib);

  if (lpbi.biSize <> sizeof(BITMAPCOREHEADER)) then
  begin
    if (lpbi.biClrUsed<>0) then
    begin
      result:=lpbi.biClrUsed;
      exit;
    end;
    bits:=lpbi.biBitCount;
  end else
    bits:=lpbc.bcBitCount;

  case bits of
    1: result:=2;
    4: result:=16;
    8: result:=256;
  else
    result:=0;
  end;
end;

function HeaderSize(lpDib: PBitmapInfo): DWORD;
var HeaderSize: DWORD;
begin
  if lpDib.bmiHeader.biBitCount > 8 then
  begin
    HeaderSize := SizeOf(TBitmapInfoHeader);
    if (lpDib.bmiHeader.biCompression and BI_BITFIELDS) <> 0 then
      Inc(HeaderSize, 12);
  end else begin
    HeaderSize := SizeOf(TBitmapInfoHeader) +
                  SizeOf(TRGBQuad) * (1 shl lpDib.bmiHeader.biBitCount);
  end;
  result := HeaderSize;
end;

procedure write_dib_to_stream(DIBHandle: HBITMAP;Stream: TStream);
var
  lpDib: PBitmapInfo;
  BMF: TBitmapFileHeader;
  hdrSize: DWORD;
begin
  lpDib := GlobalLock(DIBHandle);
  try
    hdrSize := HeaderSize(lpDib);
    BMF.bfType := $4D42;
    BMF.bfSize := lpDib.bmiHeader.biSizeImage;
    BMF.bfOffBits := sizeof(BMF) + hdrSize;
    Stream.WriteBuffer(BMF, Sizeof(BMF));
    Stream.WriteBuffer(lpDIB^, hdrSize + lpDib.bmiHeader.biSizeImage);
  finally
    GlobalUnlock(DIBHandle);
  end;
end;

procedure load_dib_into_bitmap(DIBHandle: HBITMAP;Bitmap: TBitmap);
var
  BMPHandle: HBITMAP;
  dc: HDC;
  lpDib: PBitmapInfo;
  lpBits: pchar;
begin
  lpDib := GlobalLock(DIBHandle);
  try
    lpBits := pointer(lpDIB);
    Inc(lpBits, lpDib.bmiHeader.biSize);
    Inc(lpBits, ColourCount(lpDib) * sizeof(RGBQUAD));
    dc := GetDC(0);
    try
      BMPHandle := CreateDIBitmap( dc,
                                   lpDib.bmiHeader,
                                   CBM_INIT,
                                   lpBits,
                                   lpDib^,
                                   DIB_RGB_COLORS );
      if BMPHandle <> 0 then
        bitmap.Handle := BMPHandle;
    finally
      releaseDC(0, dc);
    end;
  finally
    GlobalUnlock(DIBHandle);
  end;
end;

end.