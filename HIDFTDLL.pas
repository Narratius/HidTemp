unit HIDFTDLL;

interface
uses
 Windows;

const
 HIDFTDLL_NAME = 'HidFTDll.dll';

function  EMyDetectDevice(aHWND: HWND): Integer; stdcall;
procedure EMySetCurrentDev(aCurrent: Integer); stdcall;
procedure EMyInitConfig(aOrc: Boolean); stdcall;
function  EMyReadTemp(aFlag: Boolean): Double; stdcall;
procedure EMyCloseDevice; stdcall;

implementation

function EMyDetectDevice; external HIDFTDLL_NAME name 'EMyDetectDevice';
procedure EMySetCurrentDev; external HIDFTDLL_NAME name 'EMySetCurrentDev';
procedure EMyInitConfig; external HIDFTDLL_NAME name 'EMyInitConfig';
function EMyReadTemp; external HIDFTDLL_NAME name 'EMyReadTemp';
procedure EMyCloseDevice; external HIDFTDLL_NAME name 'EMyCloseDevice';

end.