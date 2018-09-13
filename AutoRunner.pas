{*************************************************************}
{            Auto-Runner Component for Delphi 32              }
{ Version:   1.0                                              }
{ Author:    Aleksey Kuznetsov, Ukraine                       }
{ E-Mail:    info@utilmind.com                                }
{ Home Page: http://www.utilmind.com                          }
{ Created:   April, 18, 1999                                  }
{ Modified:  April, 18, 1999                                  }
{ Legal:     Copyright (c) 1999, UtilMind Solutions           }
{*************************************************************}
{ PROPERTIES:                                                 }
{   AutoRun: Boolean - Run-time only!                         }
{   AppName: String - Application name or string identifier   }
{   RegLocation: (CurrentUser, LocalMachine) - Autostart for  }
{                current user only or for all computer's users}
{*************************************************************}
{ Please see demo program for more information.               }
{*************************************************************}
{                     IMPORTANT NOTE:                         }
{ This software is provided 'as-is', without any express or   }
{ implied warranty. In no event will the author be held       }
{ liable for any damages arising from the use of this         }
{ software.                                                   }
{ Permission is granted to anyone to use this software for    }
{ any purpose, including commercial applications, and to      }
{ alter it and redistribute it freely, subject to the         }
{ following restrictions:                                     }
{ 1. The origin of this software must not be misrepresented,  }
{    you must not claim that you wrote the original software. }
{    If you use this software in a product, an acknowledgment }
{    in the product documentation would be appreciated but is }
{    not required.                                            }
{ 2. Altered source versions must be plainly marked as such,  }
{    and must not be misrepresented as being the original     }
{    software.                                                }
{ 3. This notice may not be removed or altered from any       }
{    source distribution.                                     }
{*************************************************************}


{*************************************************************}
{            Auto-Runner Component AddOn for Delphi 32        }
{ Version:   1.1                                              }
{ Author:    J.Huet, FRANCE                                   }
{ E-Mail:    jhuet@creaweb.fr                                 }
{ Created:   August, 3, 1999                                  }
{ Modified:  August, 3, 1999                                  }
{ Legal:     AddOn Copyright (c) 1999 by J.Huet               }
{                                                             }
{*************************************************************}
{ NEW PROPERTIES:                                             }
{                                                             }
{ AutoRunWhere: (Run, RunOnce, RunServices, RunServicesOne)   }
{               - [Run, RunOnce] for 'CurrentUser' and [Run,  }
{                 RunOnce, RunServices, RunServicesOnce]      }
{                 for 'LocalMachine' only !!                  }
{                                                             }
{                                                             }
{*************************************************************}
{ INFORMATION:                                                }
{            The 'AddOn' modifications are marked by          }
{            the string  *** AddOn ***                        }
{                                                             }
{*************************************************************}



unit AutoRunner;

interface

uses
  Windows, Classes, Forms, Registry;

type
  TRegLocation = (CurrentUser, LocalMachine);
  TAutoRunWhere = (Run, RunOnce, RunServices, RunServicesOnce);   {*** AddOn ***}
  TAutoRunner = class(TComponent)
  private
    FRegLocation: TRegLocation;
    FAutoRunWhere: TAutoRunWhere;   {*** AddOn ***}
    FAutoRun: Boolean;
    FAppName: String;


    procedure ModifyRegistry(Location: TRegLocation; AppName: String);
    procedure SetRegLocation(Value: TRegLocation);
    procedure SetAutoRunWhere(Value: TAutoRunWhere);   {*** AddOn ***}
    procedure SetAutoRun(Value: Boolean);
    procedure SetAppName(Value: String);
    function RunTime: Boolean;

  protected
    RunKey : String;            {*** AddOn ***}
    Procedure VerifRunWhere;    {*** AddOn ***}

  public
    constructor Create(aOwner: TComponent); override;
  published
    property RegLocation: TRegLocation read FRegLocation write SetRegLocation;
    property AutoRunWhere: TAutoRunWhere read FAutoRunWhere write SetAutoRunWhere;   {*** AddOn ***}
    property AutoRun: Boolean read FAutoRun write SetAutoRun;
    property AppName: String read FAppName write SetAppName;
  end;

procedure Register;

implementation
Const
     RunWhere = '\Software\Microsoft\Windows\CurrentVersion\';    {*** AddOn ***}


constructor TAutoRunner.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  if not RunTime then AppName := 'MyApplication';
  Runkey := RunWhere + 'Run';    {*** AddOn ***}
end;


procedure TAutoRunner.ModifyRegistry(Location:TRegLocation; AppName: String);
var
  Reg: TRegistry;
begin
  if RunTime then
   begin
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.OpenKey(RunKey, False);
      try
       Reg.DeleteValue(FAppName);
      except
      end;
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      Reg.OpenKey(RunKey, False);
      try
       Reg.DeleteValue(FAppName);
      except
      end;
      if Location = CurrentUser then
       Reg.RootKey := HKEY_CURRENT_USER
      else
       Reg.RootKey := HKEY_LOCAL_MACHINE;
      Reg.OpenKey(RunKey, False);
      if FAutoRun then
       Reg.WriteString(AppName, Application.ExeName);
    except
    end;
    Reg.Free;
   end;
end;


{*** AddOn PROCEDURE ***}
Procedure TAutoRunner.VerifRunWhere;
begin

  If FRegLocation = CurrentUser then
    begin
         If (FAutoRunWhere = RunServices) or (FAutoRunWhere = RunServicesOnce) then FAutoRunWhere := Run;
    end;

end;





procedure TAutoRunner.SetRegLocation(Value: TRegLocation);
begin
  if FRegLocation <> Value then
   begin
    ModifyRegistry(Value, FAppName);
    FRegLocation := Value;

    VerifRunWhere;   {*** AddOn ***}

   end;
end;

{*** AddOn PROCEDURE ***}
procedure TAutoRunner.SetAutoRunWhere(Value: TAutoRunWhere);
begin
  if FAutoRunWhere <> Value then
   begin
        FAutoRunWhere := Value;

        VerifRunWhere;


    case FAutoRunWhere of
         Run:              RunKey := 'Run';
         RunOnce:          RunKey := 'RunOnce';
         RunServices :     RunKey := 'RunServices';
         RunServicesOnce : RunKey := 'RunServicesOnce';
    end;

    Runkey := RunWhere + Runkey;

    end;
end;

procedure TAutoRunner.SetAutoRun(Value: Boolean);
begin
  if (FAutoRun <> Value) and RunTime then
   begin
    FAutoRun := Value;

    VerifRunWhere;   {*** AddOn ***}

    ModifyRegistry(FRegLocation, FAppName);
   end;
end;

procedure TAutoRunner.SetAppName(Value: String);
var
  Reg: TRegistry;
  St: String;
begin
  if csLoading in ComponentState then
   begin
    FAppName := Value;
    St := '';
    Reg := TRegistry.Create;
    try
     Reg.RootKey := HKEY_CURRENT_USER;
     Reg.OpenKey(RunKey, False);
     try
      St := Reg.ReadString(FAppName);
      if St <> '' then FRegLocation := CurrentUser;
     except
      St := '';
     end;
     if St = '' then
      begin
       Reg.RootKey := HKEY_LOCAL_MACHINE;
       Reg.OpenKey(RunKey, False);
       try
        St := Reg.ReadString(FAppName);
        if St <> '' then FRegLocation := LocalMachine;
       except
        St := '';
       end;
      end
    except
    end;
    FAutoRun := St <> '';
    Reg.Free;
   end
  else
   if not RunTime then
    if (Value <> '') and (FAppName <> Value) then
      FAppName := Value
end;

function TAutoRunner.RunTime: Boolean;
begin
  Result := not ((csDesigning in ComponentState) or
                 (csReading in ComponentState) or
                 (csLoading in ComponentState));
end;

procedure Register;
begin
  RegisterComponents('UtilMind', [TAutoRunner]);
end;

end.                                   
