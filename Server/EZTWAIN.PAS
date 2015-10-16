unit Eztwain;
{
 This unit is based on the eztwain.h for interfacing of the
 eztwain.dll by spike. I included the original comments from
 the source.

 The source of eztwain is available from:
     <ftp://ftp.caere.com/pub/twain>

 This unit is sample code as like as the original eztwain.h.
 Matthias Weingart '95.
}
{
// EZTWAIN.H - interface to Easy TWAIN library
//
// EZTWAIN is not a product, and is not the work of any company involved
// in promoting or using the TWAIN standard.  This code is sample code,
// provided without charge, and you use it entirely at your own risk.
// No rights or ownership is claimed by the author, or by any company
// or organization.
//
// 0.0	05/11/94	created
// 1.0a	06/23/94	first alpha version
// 1.04 05/03/95	added: WriteNativeToFile, WriteNativeToFilename,
//					FreeNative, SetHideUI, GetHideUI, SetCurrentUnits,
//					GetCurrentUnits, SetCurrentResolution, SetBitDepth,
//					SetCurrentPixelType, SetCapOneValue.
        11/12/95    interface for delphi by Matthias Weingart
}

interface

uses wintypes;

function TWAIN_AcquireNative(hwndApp: HWND; wPixTypes: word): HBitmap;
stdcall;  far;
{
// The minimal use of EZTWAIN.DLL is to just call this routine, with 0 for
// both params.  EZTWAIN creates a window if hwndApp is 0.
//
// Acquires a single image, from the currently selected Data Source, using
// Native-mode transfer. It waits until the source closes (if it's modal) or
// forces the source closed if not.  The return value is a handle to the
// acquired image.  Only one image can be acquired per call.
//
// Under Windows, the return value is a global memory handle - applying
// GlobalLock to it will return a (huge) pointer to the DIB, which
// starts with a BITMAPINFOHEADER.
// NOTE: You are responsible for disposing of the returned DIB - these things
// can eat up your Windows memory fast!  See TWAIN_FreeNative below.
//
// The image type can be restricted using the following masks.  A mask of 0
// means 'any pixel type is welcome'.
// Caution: You should not assume that the source will honor a pixel type
// restriction!  If you care, check the parameters of the DIB.
}
const
     TWAIN_BW=1;	  { 1-bit per pixel, B&W 	 (== TWPT_BW) }
     TWAIN_GRAY=2;	  { 1,4, or 8-bit grayscale  (== TWPT_GRAY) }
     TWAIN_RGB=4;	  { 24-bit RGB color         (== TWPT_RGB) }
     TWAIN_PALETTE=8; { 1,4, or 8-bit palette    (== TWPT_PALETTE) }
     TWAIN_ANYTYPE=0; { any of the above }

procedure TWAIN_FreeNative(hdib: HBitmap);
stdcall; far;
{
// Release the memory allocated to a native format image, as returned by
// TWAIN_AcquireNative. (If you are coding in C or C++, this is just a call
// to GlobalFree.)
// If you use TWAIN_AcquireNative and don't free the returned image handle,
// it stays around taking up Windows (virtual) memory until your application
// terminates.  Memory required per square inch:
//             1 bit B&W       8-bit grayscale     24-bit color
// 100 dpi      1.25KB              10KB               30KB
// 200 dpi        5KB               40KB              120KB
// 300 dpi      11.25KB             90KB              270KB
// 400 dpi       20KB              160KB              480KB
//
}
function TWAIN_AcquireToClipboard(hwndApp: HWND; wPixTypes: word): integer;
 far;
{
// Like AcquireNative, but puts the resulting image, if any, into the system
// clipboard.  Under Windows, this will put a CF_DIB item in the clipboard
// if successful.  If this call fails, the clipboard is either empty or
// contains the old contents.
// A return value of 1 indicates success, 0 indicates failure.
//
// Useful for environments like Visual Basic where it is hard to make direct
// use of a DIB handle.  In fact, TWAIN_AcquireToClipboard uses
// TWAIN_AcquireNative for all the hard work.
}
function TWAIN_SelectImageSource(hwnd: HWND): integer;
 far;
{
// This is the routine to call when the user chooses the "Select Source..."
// menu command from your application's File menu.  Your app has one of
// these, right?  The TWAIN spec calls for this feature to be available in
// your user interface, preferably as described.
// Note: If only one TWAIN device is installed on a system, it is selected
// automatically, so there is no need for the user to do Select Source.
// You should not require your users to do Select Source before Acquire.
//
// This function posts the Source Manager's Select Source dialog box.
// It returns after the user either OK's or CANCEL's that dialog.
// A return of 1 indicates OK, 0 indicates one of the following:
//   a) The user cancelled the dialog
//   b) The Source Manager found no data sources installed
//   c) There was a failure before the Select Source dialog could be posted
// -- details --
// Only sources that can return images (that are in the DG_IMAGE group) are
// displayed.  The current default source will be highlighted initially.
// In the standard implementation of "Select Source...", your application
// doesn't need to do anything except make this one call.
//
// If you want to be meticulous, disable your "Acquire" and "Select Source"
// menu items or buttons if TWAIN_IsAvailable() returns 0 - see below.
}

{--------- Basic TWAIN Inquiries  }

function TWAIN_IsAvailable: integer;
 far;
{
// Call this function any time to find out if TWAIN is installed on the
// system.  It takes a little time on the first call, after that it's fast,
// just testing a flag.  It returns 1 if the TWAIN Source Manager is
// installed & can be loaded, 0 otherwise.
}
function TWAIN_EasyVersion: integer;
 far;
{
// Returns the version number of EZTWAIN.DLL, multiplied by 100.
// So e.g. version 2.01 will return 201 from this call.
}
function TWAIN_State: integer;
 far;
{
// Returns the TWAIN Protocol State per the spec.
}
const
   TWAIN_PRESESSION=1;        {	source manager not loaded }
   TWAIN_SM_LOADED=2;	      { source manager loaded }
   TWAIN_SM_OPEN=3;           { source manager open }
   TWAIN_SOURCE_OPEN=4;       { source open but not enabled }
   TWAIN_SOURCE_ENABLED=5;    { source enabled to acquire }
   TWAIN_TRANSFER_READY=6;    { image ready to transfer }
   TWAIN_TRANSFERRING=7;	  { image in transit }

{--------- BMP file utilities  }

function TWAIN_WriteNativeToFilename(hdib: HBitmap; pszFile: Pchar ): integer;
 far;
{
// Writes a DIB handle to a .BMP file
//
// hdib		= DIB handle, as returned by TWAIN_AcquireNative
// pszFile	= far pointer to NUL-terminated filename
// If pszFile is NULL or points to a null string, prompts the user
// for the filename with a standard file-save dialog.
//
// Return values:
//	 0	success
//	-1	user cancelled File Save dialog
//	-2	file open error (invalid path or name, or access denied)
//	-3	(weird) unable to lock DIB - probably an invalid handle.
//	-4	writing BMP data failed, possibly output device is full
}
function TWAIN_WriteNativeToFile(hdib: HBitmap; fh: integer): integer;
 far;
{
// Writes a DIB to a file in .BMP format.
//
// hdib		= DIB handle, as returned by TWAIN_AcquireNative
// fh		= file handle, as returned by _open, _lopen or OpenFile
//
// Return value as for TWAIN_WriteNativeToFilename
}

{ --------- Application Registration  }

procedure TWAIN_RegisterApp(	        { record application information }
	nMajorNum,nMinorNum: integer;       { major and incremental revision of application. E.g. }
										{ for version 2.1, nMajorNum == 2 and nMinorNum == 1 }
	nLanguage: integer;					{ language of this version (use TWLG_xxx from TWAIN.H) }
	nCountry: integer;					{ country of this version (use TWCY_xxx from TWAIN.H) }
	lpszVersion: PChar;				    { version info string e.g. "1.0b3 Beta release" }
	lpszMfg: PChar;					    { name of manufacturer/developer e.g. "Crazbat Software" }
	lpszFamily: PChar;					{ product family e.g. "BitStomper" }
	lpszProduct: PChar);				{ specific product e.g. "BitStomper Deluxe Pro" }
 far;
{
// TWAIN_RegisterApp can be called *AS THE FIRST CALL*, to register the
// application. If this function is not called, the application is given a
// 'generic' registration by EZTWAIN.
// Registration only provides this information to the Source Manager and any
// sources you may open - it is used for debugging, and (frankly) by some
// sources to give special treatment to certain applications.
}

{ --------- Lower-level functions for greater control of the TWAIN protocol --------}

procedure TWAIN_SetHideUI(fHide: integer);
stdcall; far;
function TWAIN_GetHideUI: integer;
 far;
{
// These functions control the 'hide source user interface' flag.
// This flag is cleared initially, but if you set it non-zero, then when
// a source is enabled it will be asked to hide its user interface.
// Note that this is only a request - some sources will ignore it!
// This affects AcquireNative, AcquireToClipboard, and EnableSource.
// If the user interface is hidden, you will probably want to set at least
// some of the basic acquisition parameters yourself - see
// SetCurrentUnits, SetBitDepth, SetCurrentPixelType and
// SetCurrentResolution below.
}
function TWAIN_GetResultCode: word;
 far;
{
// Return the result code (TWRC_xxx) from the last triplet sent to TWAIN
}
function TWAIN_GetConditionCode: word;
 far;
{
// Return the condition code from the last triplet sent to TWAIN.
// (To be precise, from the last call to TWAIN_DS below)
// If a source is NOT open, return the condition code of the source manager.
}
function TWAIN_LoadSourceManager: integer;
 far;
{
// Finds and loads the Data Source Manager, TWAIN.DLL.
// If Source Manager is already loaded, does nothing and returns TRUE.
// This can fail if TWAIN.DLL is not installed (in the right place), or
// if the library cannot load for some reason (insufficient memory?) or
// if TWAIN.DLL has been corrupted.
}
function TWAIN_OpenSourceManager(hwnd: HWND): integer;
 far;
{
// Opens the Data Source Manager, if not already open.
// If the Source Manager is already open, does nothing and returns TRUE.
// This call will fail if the Source Manager is not loaded.
}
function TWAIN_OpenDefaultSource: integer;
 far;
{
// This opens the source selected in the Select Source dialog.
// If a source is already open, does nothing and returns TRUE.
// Fails if the source manager is not loaded and open.
}
function TWAIN_EnableSource(hwnd: HWND): integer;
 far;
{
// Enables the open Data Source. This posts the source's user interface
// and allows image acquisition to begin.  If the source is already enabled,
// this call does nothing and returns TRUE.
}
function TWAIN_DisableSource: integer;
 far;
{
// Disables the open Data Source, if any.
// This closes the source's user interface.
// If there is not an enabled source, does nothing and returns TRUE.
}
function TWAIN_CloseSource: integer;
 far;
{
// Closes the open Data Source, if any.
// If the source is enabled, disables it first.
// If there is not an open source, does nothing and returns TRUE.
}
function TWAIN_CloseSourceManager(hwnd: HWND): integer;
 far;
{
// Closes the Data Source Manager, if it is open.
// If a source is open, disables and closes it as needed.
// If the Source Manager is not open, does nothing and returns TRUE.
}
function TWAIN_UnloadSourceManager: integer;
 far;
{
// Unloads the Data Source Manager i.e. TWAIN.DLL - releasing
// any associated memory or resources.
// This call will fail if the Source Manager is open, otherwise
// it always succeeds and returns TRUE.
}
function TWAIN_MessageHook(lpmsg: PMsg): integer;
 far;
(*
// This function detects Windows messages that should be routed
// to an enabled Data Source, and picks them off.  In a full TWAIN
// app, TWAIN_MessageHook is called inside the main GetMessage loop.
// The skeleton code looks like this:
//		MSG msg;
//  	while (GetMessage((LPMSG)&msg, NULL, 0, 0)) {
//			if (!TWAIN_MessageHook ((LPMSG)&msg)) {
//				TranslateMessage ((LPMSG)&msg);
//				DispatchMessage ((LPMSG)&msg);
//			}
//		} // while
*)
procedure TWAIN_ModalEventLoop;
 far;
{
// Process messages until termination, source disable, or image transfer.
//
// Executes exactly the sample code given above for TWAIN_MessageHook, but
// terminates as soon as the source is disabled or a transfer completes.
// This function is called by TWAIN_AcquireNative.
}
function TWAIN_AbortAllPendingXfers: integer;
 far;

function TWAIN_WriteDibToFile(lpDIB: PBITMAPINFOHEADER; fh: integer): integer;
 far;
{
// Writes a DIB to a file in .BMP format.
// Returns TRUE if successful, FALSE otherwise.
// (Likely causes of failure: device full, or permission denied to write to file or device
// lpDIB	= pointer to DIB, as from GlobalLock of DIB handle
// fh		= file handle, as returned by C _open or Windows _lopen or OpenFile
// For example of use, see TWAIN_WriteNativeToFilename in EZTWAIN.C
}
function TWAIN_NegotiateXferCount(nXfers: integer): integer;
 far;
{
// Negotiate with open Source the number of images application will accept.
// This is only allowed in State 4 (TWAIN_SOURCE_OPEN)
// nXfers = -1 means any number
}
function TWAIN_NegotiatePixelTypes(wPixTypes: word): integer;
 far;
{
// Negotiate with the source to restrict pixel types that can be acquired.
// This tries to restrict the source to a *set* of pixel types,
// See TWAIN_AcquireNative above for some mask constants.
// --> This is only allowed in State 4 (TWAIN_SOURCE_OPEN)
// A parameter of 0 (TWAIN_ANYTYPE) causes no negotiation & no restriction.
// You should not assume that the source will honor your restrictions, even
// if this call succeeds!
}
function TWAIN_GetCurrentUnits: integer;
 far;
{
// Ask the source what its current unit of measure is.
// If anything goes wrong, this function just returns TWUN_INCHES (0).
}
function TWAIN_SetCurrentUnits(nUnits: integer): integer;
 far;
{
// Set the current unit of measure for the source.
// Unit of measure codes are in TWAIN.H, but TWUN_INCHES is 0.
}
const
     TWUN_INCHES=0;
     TWUN_CENTIMETERS=1;
     TWUN_PICAS=2;
     TWUN_POINTS=3;
     TWUN_TWIPS=4;
     TWUN_PIXELS=5;

function TWAIN_GetBitDepth: integer;
 far;
{
// Get the current bitdepth, which can depend on the current PixelType.
// Bit depth is per color channel e.g. 24-bit RGB has bit depth 8.
// If anything goes wrong, this function returns 0.
}
function TWAIN_SetBitDepth(nBits: integer): integer;
 far;
{
// (Try to) set the current bitdepth (for the current pixel type).
}
function TWAIN_GetPixelType: integer;
 far;
{
// Ask the source for the current pixel type.
// If anything goes wrong (it shouldn't), this function returns 0 (TWPT_BW).
}
function TWAIN_SetCurrentPixelType(nPixType: integer): integer;
 far;
{
// (Try to) set the current pixel type for acquisition.
// This is only allowed in State 4 (TWAIN_SOURCE_OPEN)
// The source may select this pixel type, but don't assume it will.
}
function TWAIN_GetCurrentResolution: double;
 far;
{
// Ask the source for the current resolution.
// Resolution is in dots per current unit! (See TWAIN_GetCurrentUnits above)
// If anything goes wrong (it shouldn't) this function returns 0.0
}
function TWAIN_SetCurrentResolution(dRes: double): integer;
 far;
{
// (Try to) set the current resolution for acquisition.
// Resolution is in dots per current unit! (See TWAIN_GetCurrentUnits above)
// This is only allowed in State 4 (TWAIN_SOURCE_OPEN)
// Note: The source may select this resolution, but don't assume it will.
}

{ --------- Low-level capability negotiation functions --------

// Setting a capability is valid only in State 4 (TWAIN_SOURCE_OPEN)
// Getting a capability is valid in State 4 or any higher state.
}
function TWAIN_SetCapOneValue( Cap:      word;
                               ItemType: word;
                               ItemVal:  longint): integer;
 far;
{
// Do a DAT_CAPABILITY/MSG_SET, on capability 'Cap' (e.g. ICAP_PIXELTYPE,
// CAP_AUTOFEED, etc.) using a TW_ONEVALUE container with the given item type
// and value.  Obviously, the item value must fit into 32 bits.
// Returns TRUE (1) if successful, FALSE (0) otherwise.
}
function TWAIN_GetCapCurrent( Cap:      word;
                              ItemType: word;
                              pVal: pointer): integer;  {far pointer!}
 far;
{
// Do a DAT_CAPABILITY/MSG_GETCURRENT on capability 'Cap'.
// Copy the current value out of the returned container into *pVal.
// If the operation fails (the source refuses the request), or if the
// container is not a ONEVALUE or ENUMERATION, or if the item type of the
// returned container is incompatible with the expected TWTY_ type in nType,
// returns FALSE.  If this function returns FALSE, *pVal is not touched.
}

{ --------- Lowest-level functions for TWAIN protocol -------- }

function TWAIN_DS(DG: longint; DAT: word; MSG: word; pData: Pointer): integer;
 far;
{
// Passes the triplet (DG, DAT, MSG, pData) to the open data source if any.
// Returns 1 (TRUE) if the result code is TWRC_SUCCESS, 0 (FALSE) otherwise.
// The last result code can be retrieved with TWAIN_GetResultCode(), and the corresponding
// condition code can be retrieved with TWAIN_GetConditionCode().
// If no source is open this call will fail, result code TWRC_FAILURE, condition code TWCC_NODS.
}
function TWAIN_Mgr(DG: longint; DAT: word; MSG: word; pData: Pointer): integer;
 far;
{
// Passes a triplet to the Data Source Manager (DSM).
// Returns 1 (TRUE) if the result code is TWRC_SUCCESS, 0 (FALSE) otherwise.
// The last result code can be retrieved with TWAIN_GetResultCode(), and the corresponding
// condition code can be retrieved with TWAIN_GetConditionCode().
// If the Source Manager is not open, this call will fail, and set the result code to TWRC_FAILURE,
// with a condition code of TWCC_SEQERROR (triplet out of sequence).
}

implementation

function TWAIN_AcquireNative(hwndApp: HWND; wPixTypes: word): HBitmap;
stdcall;  external 'EZTWAIN';
procedure TWAIN_FreeNative(hdib: HBitmap);
stdcall;  external 'EZTWAIN';
function TWAIN_AcquireToClipboard(hwndApp: HWND; wPixTypes: word): integer;
  external 'EZTWAIN';
function TWAIN_SelectImageSource(hwnd: HWND): integer;
  external 'EZTWAIN';
function TWAIN_IsAvailable: integer;
  external 'EZTWAIN';
function TWAIN_EasyVersion: integer;
  external 'EZTWAIN';
function TWAIN_State: integer;
  external 'EZTWAIN';
function TWAIN_WriteNativeToFilename(hdib: HBitmap; pszFile: PChar ): integer;
  external 'EZTWAIN';
function TWAIN_WriteNativeToFile(hdib: HBitmap; fh: integer): integer;
  external 'EZTWAIN';
procedure TWAIN_RegisterApp( nMajorNum,nMinorNum: integer;
                             nLanguage: integer;
                             nCountry: integer;
                             lpszVersion: PChar;
                             lpszMfg: PChar;
                             lpszFamily: PChar;
                             lpszProduct: PChar);
  external 'EZTWAIN';
procedure TWAIN_SetHideUI(fHide: integer);
stdcall;  external 'EZTWAIN';
function TWAIN_GetHideUI: integer;
  external 'EZTWAIN';
function TWAIN_GetResultCode: word;
  external 'EZTWAIN';
function TWAIN_GetConditionCode: word;
  external 'EZTWAIN';
function TWAIN_LoadSourceManager: integer;
  external 'EZTWAIN';
function TWAIN_OpenSourceManager(hwnd: HWND): integer;
  external 'EZTWAIN';
function TWAIN_OpenDefaultSource: integer;
  external 'EZTWAIN';
function TWAIN_EnableSource(hwnd: HWND): integer;
  external 'EZTWAIN';
function TWAIN_DisableSource: integer;
  external 'EZTWAIN';
function TWAIN_CloseSource: integer;
  external 'EZTWAIN';
function TWAIN_CloseSourceManager(hwnd: HWND): integer;
  external 'EZTWAIN';
function TWAIN_UnloadSourceManager: integer;
  external 'EZTWAIN';
function TWAIN_MessageHook(lpmsg: PMsg): integer;
  external 'EZTWAIN';
procedure TWAIN_ModalEventLoop;
  external 'EZTWAIN';
function TWAIN_AbortAllPendingXfers: integer;
  external 'EZTWAIN';
function TWAIN_WriteDibToFile(lpDIB: PBITMAPINFOHEADER; fh: integer): integer;
  external 'EZTWAIN';
function TWAIN_NegotiateXferCount(nXfers: integer): integer;
  external 'EZTWAIN';
function TWAIN_NegotiatePixelTypes(wPixTypes: word): integer;
  external 'EZTWAIN';
function TWAIN_GetCurrentUnits: integer;
  external 'EZTWAIN';
function TWAIN_SetCurrentUnits(nUnits: integer): integer;
  external 'EZTWAIN';
function TWAIN_GetBitDepth: integer;
  external 'EZTWAIN';
function TWAIN_SetBitDepth(nBits: integer): integer;
  external 'EZTWAIN';
function TWAIN_GetPixelType: integer;
  external 'EZTWAIN';
function TWAIN_SetCurrentPixelType(nPixType: integer): integer;
  external 'EZTWAIN';
function TWAIN_GetCurrentResolution: double;
  external 'EZTWAIN';
function TWAIN_SetCurrentResolution(dRes: double): integer;
  external 'EZTWAIN';
function TWAIN_SetCapOneValue( Cap: word;
                               ItemType: word;
                               ItemVal: longint): integer;
  external 'EZTWAIN';
function TWAIN_GetCapCurrent( Cap:      word;
                              ItemType: word;
                              pVal: pointer): integer;
  external 'EZTWAIN';
function TWAIN_DS(DG: longint; DAT: word; MSG: word; pData: Pointer): integer;
  external 'EZTWAIN';
function TWAIN_Mgr(DG: longint; DAT: word; MSG: word; pData: Pointer): integer;
  external 'EZTWAIN';

end.
