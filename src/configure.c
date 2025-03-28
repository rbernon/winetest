#include <stdarg.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdio.h>

#include <windef.h>
#include <winbase.h>
#include <wingdi.h>
#include <winuser.h>

int WINAPI wWinMain( HINSTANCE instance, HINSTANCE previous, WCHAR *cmdline, int cmdshow )
{
    DEVMODEW mode = {.dmSize = sizeof(DEVMODEW)};

    mode.dmFields = DM_BITSPERPEL | DM_PELSWIDTH | DM_PELSHEIGHT | DM_POSITION;
    mode.dmBitsPerPel = 32;
    mode.dmPelsWidth = 1920;
    mode.dmPelsHeight = 1080;
    ChangeDisplaySettingsExW( L"\\\\.\\DISPLAY1", &mode, 0, CDS_UPDATEREGISTRY | CDS_NORESET, NULL );
    mode.dmPosition.x = 1920;
    ChangeDisplaySettingsExW( L"\\\\.\\DISPLAY2", &mode, 0, CDS_UPDATEREGISTRY | CDS_NORESET, NULL );
    mode.dmPosition.x = -1920;
    ChangeDisplaySettingsExW( L"\\\\.\\DISPLAY3", &mode, 0, CDS_UPDATEREGISTRY | CDS_NORESET, NULL );

    ChangeDisplaySettingsExW( NULL, NULL, NULL, 0, NULL );
    return 0;
}
