#include <stdarg.h>
#include <stdlib.h>
#include <stddef.h>
#include <stdio.h>

#include <windef.h>
#include <winbase.h>
#include <winuser.h>

#include <reason.h>
#include <shellapi.h>

int WINAPI wWinMain( HINSTANCE instance, HINSTANCE previous, WCHAR *cmdline, int cmdshow )
{
    SHELLEXECUTEINFOW info = {.cbSize = sizeof(SHELLEXECUTEINFOW)};
    TOKEN_PRIVILEGES npr;
    HANDLE token;
    WCHAR *tmp;

    Sleep( 10000 );

    info.fMask = SEE_MASK_NOCLOSEPROCESS;
    if (wcsncmp( cmdline, L"-u ", 3 )) info.lpVerb = L"runas";
    else cmdline += 3;
    info.lpFile = cmdline;
    if ((tmp = wcschr( cmdline, ' ' ))) *tmp++ = 0;
    info.lpParameters = tmp ? tmp : L"";   
    info.nShow = SW_SHOW;

    ShellExecuteExW( &info );
	WaitForSingleObject( info.hProcess, INFINITE );
	CloseHandle( info.hProcess );

    CopyFileW( L"C:\\users\\docker\\winetest.log", L"\\\\host.lan\\data\\winetest.log", FALSE );

    if (OpenProcessToken( GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, &token ))
    {
        LookupPrivilegeValueW( 0, L"SeShutdownPrivilege", &npr.Privileges[0].Luid );
        npr.PrivilegeCount = 1;
        npr.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
        AdjustTokenPrivileges( token, FALSE, &npr, 0, 0, 0 );
        CloseHandle( token );
    }

    ExitWindowsEx( EWX_SHUTDOWN | EWX_POWEROFF | EWX_FORCEIFHUNG, SHTDN_REASON_MAJOR_OTHER | SHTDN_REASON_MINOR_OTHER );
    return 0;
}
