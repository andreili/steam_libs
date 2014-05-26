unit ISteamUser014_;

interface

uses
  SteamTypes, UserCommon;

type
  ISteamUser014 = class
    // returns the HSteamUser this interface represents
    // this is only used internally by the API, and by a few select interfaces that support multi-user
    function GetHSteamUser(): HSteamUser; virtual; stdcall;

    // returns true if the Steam client current has a live connection to the Steam servers.
    // If false, it means there is no active connection due to either a networking issue on the local machine, or the Steam server is down/busy.
    // The Steam client will automatically be trying to recreate the connection as often as possible.
    function BLoggedOn(): boolean; virtual; stdcall;

    // returns the CSteamID of the account currently logged into the Steam client
    // a CSteamID is a unique identifier for an account, and used to differentiate users in all parts of the Steamworks API
    function GetSteamID(): CSteamID; virtual; stdcall;

    // Multiplayer Authentication functions

    // InitiateGameConnection() starts the state machine for authenticating the game client with the game server
    // It is the client portion of a three-way handshake between the client, the game server, and the steam servers
    //
    // Parameters:
    // void *pAuthBlob - a pointer to empty memory that will be filled in with the authentication token.
    // int cbMaxAuthBlob - the number of bytes of allocated memory in pBlob. Should be at least 2048 bytes.
    // CSteamID steamIDGameServer - the steamID of the game server, received from the game server by the client
    // CGameID gameID - the ID of the current game. For games without mods, this is just CGameID( <appID> )
    // uint32 unIPServer, uint16 usPortServer - the IP address of the game server
    // bool bSecure - whether or not the client thinks that the game server is reporting itself as secure (i.e. VAC is running)
    // void pvSteam2GetEncryptionKey - unknown
    // int cbSteam2GetEncryptionKey - unknown
    //
    // return value - returns the number of bytes written to pBlob. If the return is 0, then the buffer passed in was too small, and the call has failed
    // The contents of pBlob should then be sent to the game server, for it to use to complete the authentication process.
    function InitiateGameConnection(pAuthBlob: Pointer; cbMaxAuthBlob: int; steamIDGameServer: CSteamID;
     unIPServer: uint32; usPortServer: uint16; bSecure: boolean): boolean; virtual; stdcall;

    // notify of disconnect
    // needs to occur when the game client leaves the specified game server, needs to match with the InitiateGameConnection() call
    procedure TerminateGameConnection(unIPServer: uint32; usPortServer: uint16); virtual; stdcall;

    // Legacy functions

    // legacy authentication support - need to be called if the game server rejects the user with a 'bad ticket' error
    procedure RefreshSteam2Login(); virtual; stdcall;

    // get the local storage folder for current Steam account to write application data, e.g. save games, configs etc.
    // this will usually be something like "C:\Progam Files\Steam\userdata\<SteamID>\<AppID>\local"
    function GetUserDataFolder(gameID: CGameID; pchBuffer: pAnsiChar; cubBuffer: int): boolean; virtual; stdcall;

    // Starts voice recording. Once started, use GetVoice() to get the data
    procedure StartVoiceRecording(); virtual; stdcall;

    // Stops voice recording. Because people often release push-to-talk keys early, the system will keep recording for
    // a little bit after this function is called. GetCompressedVoice() should continue to be called until it returns
    // k_eVoiceResultNotRecording
    procedure StopVoiceRecording(); virtual; stdcall;

    // Determine the amount of captured audio data that is available in bytes.
    // This provides both the compressed and uncompressed data. Please note that the uncompressed
    // data is not the raw feed from the microphone: data may only be available if audible
    // levels of speech are detected.
    function GetAvailableVoice(var pcbCompressed, pcbUncompressed: uint32): EVoiceResult; virtual; stdcall;

    // Gets the latest voice data from the microphone. Compressed data is an arbitrary format, and is meant to be handed back to
    // DecompressVoice() for playback later as a binary blob. Uncompressed data is 16-bit, signed integer, 11025Hz PCM format.
    // Please note that the uncompressed data is not the raw feed from the microphone: data may only be available if audible
    // levels of speech are detected, and may have passed through denoising filters, etc.
    // This function should be called as often as possible once recording has started; once per frame at least.
    // nBytesWritten is set to the number of bytes written to pDestBuffer.
    // nUncompressedBytesWritten is set to the number of bytes written to pUncompressedDestBuffer.
    // You must grab both compressed and uncompressed here at the same time, if you want both.
    // Matching data that is not read during this call will be thrown away.
    // GetAvailableVoice() can be used to determine how much data is actually available.
    function GetVoice(bWantCompressed: boolean; pDestBuffer: Pointer; cbDestBufferSize: uint32;
     var nBytesWritten: uint32; bWantRaw: boolean; pRawDestBuffer: Pointer;
     cbRawDestBufferSize: uint32; var nRawBytesWritten: uint32): EVoiceResult; virtual; stdcall;

    // Decompresses a chunk of compressed data produced by GetVoice().
    // nBytesWritten is set to the number of bytes written to pDestBuffer unless the return value is k_EVoiceResultBufferTooSmall.
    // In that case, nBytesWritten is set to the size of the buffer required to decompress the given
    // data. The suggested buffer size for the destination buffer is 22 kilobytes.
    // The output format of the data is 16-bit signed at 11025 samples per second.
    function DecompressVoice(pCompressed: Pointer; cbCompressed: uint32; pDestBuffer: Pointer; cbDestBufferSize: uint32;
     var nBytesWritten: uint32): EVoiceResult; virtual; stdcall;

    // Retrieve ticket to be sent to the entity who wishes to authenticate you.
    // pcbTicket retrieves the length of the actual ticket.
    function GetAuthSessionTicket(pMyAuthTicket: Pointer; cbMaxMyAuthTicket: int;
     var pcbAuthTicket: uint32): HAuthTicket; virtual; stdcall;

    // Authenticate ticket from entity steamID to be sure it is valid and isnt reused
    // Registers for callbacks if the entity goes offline or cancels the ticket ( see ValidateAuthTicketResponse_t callback and EAuthSessionResponse )
    function BeginAuthSession(pTheirAuthTicket: Pointer; cbTicket: int;
     steamID: CSteamID): EBeginAuthSessionResult; virtual; stdcall;

    // Stop tracking started by BeginAuthSession - called when no longer playing game with this entity
    procedure EndAuthSession(steamID: CSteamID); virtual; stdcall;

    // Cancel auth ticket from GetAuthSessionTicket, called when no longer playing game with the entity you gave the ticket to
    procedure CancelAuthTicket(hAuthTicket: HAuthTicket); virtual; stdcall;

    // After receiving a user's authentication data, and passing it to BeginAuthSession, use this function
    // to determine if the user owns downloadable content specified by the provided AppID.
    function UserHasLicenseForApp(steamID: CSteamID; appID: AppId_t): EUserHasLicenseForAppResult; virtual; stdcall;

    function IsBehindNAT(): boolean; virtual; stdcall;

    function AdvertiseGame(gameID: CGameID; steamIDGameServer: CSteamID;
     unIPServer: uint32; usPortServer: uint16): boolean; virtual; stdcall;

    function RequestEncryptedAppTicket(): unknown_ret; virtual; stdcall;
    function GetEncryptedAppTicket(): unknown_ret; virtual; stdcall;
  private
    fCpp: Pointer;
  end;

function ConverUser014CppToI(Cpp: Pointer): ISteamUser014;

implementation

function ConverUser014CppToI(Cpp: Pointer): ISteamUser014;
begin
  result:=ISteamUser014.Create();
  result.fCpp:=Cpp;
end;

function ISteamUser014.GetHSteamUser(): HSteamUser;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+00]
  mov ESP, EBP
end;

function ISteamUser014.BLoggedOn(): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push ECX
  call [EAX+04]
  mov ESP, EBP
end;

function ISteamUser014.GetSteamID(): CSteamID;
asm
  mov EAX, [EBP+$0c]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push ECX
  call [EAX+08]

  mov EBP, [ESP]
  mov ECX, [EAX+4]
  mov [EBP-$14], ECX
  mov ECX, [EAX]
  mov [EBP-$18], ECX
end;

function ISteamUser014.InitiateGameConnection(pAuthBlob: Pointer; cbMaxAuthBlob: int; steamIDGameServer: CSteamID;
     unIPServer: uint32; usPortServer: uint16; bSecure: boolean): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push integer(bSecure)
  push usPortServer
  push unIPServer
  push integer(steamIDGameServer)
  push cbMaxAuthBlob
  push pAuthBlob
  call [EAX+12]
end;

procedure ISteamUser014.TerminateGameConnection(unIPServer: uint32; usPortServer: uint16);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push usPortServer
  push unIPServer
  call [EAX+16]
end;

procedure ISteamUser014.RefreshSteam2Login();
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+20]
end;

function ISteamUser014.GetUserDataFolder(gameID: CGameID; pchBuffer: pAnsiChar; cubBuffer: int): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push cubBuffer
  push pchBuffer
  push integer(gameID)
  call [EAX+24]
end;

procedure ISteamUser014.StartVoiceRecording();
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+28]
end;

procedure ISteamUser014.StopVoiceRecording();
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+32]
end;

function ISteamUser014.GetAvailableVoice(var pcbCompressed, pcbUncompressed: uint32): EVoiceResult;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push pcbUncompressed
  push pcbCompressed
  call [EAX+36]
end;

function ISteamUser014.GetVoice(bWantCompressed: boolean; pDestBuffer: Pointer; cbDestBufferSize: uint32;
     var nBytesWritten: uint32; bWantRaw: boolean; pRawDestBuffer: Pointer;
     cbRawDestBufferSize: uint32; var nRawBytesWritten: uint32): EVoiceResult;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push nRawBytesWritten
  push cbRawDestBufferSize
  push pRawDestBuffer
  push integer(bWantRaw)
  push nBytesWritten
  push cbDestBufferSize
  push pDestBuffer
  push integer(bWantCompressed)
  call [EAX+40]
end;

function ISteamUser014.DecompressVoice(pCompressed: Pointer; cbCompressed: uint32; pDestBuffer: Pointer; cbDestBufferSize: uint32;
     var nBytesWritten: uint32): EVoiceResult;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push nBytesWritten
  push cbDestBufferSize
  push pDestBuffer
  push cbCompressed
  push pCompressed
  call [EAX+44]
end;

function ISteamUser014.GetAuthSessionTicket(pMyAuthTicket: Pointer; cbMaxMyAuthTicket: int;
     var pcbAuthTicket: uint32): HAuthTicket;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push pcbAuthTicket
  push cbMaxMyAuthTicket
  push pMyAuthTicket
  call [EAX+48]
end;

function ISteamUser014.BeginAuthSession(pTheirAuthTicket: Pointer; cbTicket: int;
     steamID: CSteamID): EBeginAuthSessionResult;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push integer(steamID)
  push cbTicket
  push pTheirAuthTicket
  call [EAX+52]
end;

procedure ISteamUser014.EndAuthSession(steamID: CSteamID);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push integer(steamID)
  call [EAX+56]
end;

procedure ISteamUser014.CancelAuthTicket(hAuthTicket: HAuthTicket);
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push hAuthTicket
  call [EAX+60]
end;

function ISteamUser014.UserHasLicenseForApp(steamID: CSteamID; appID: AppId_t): EUserHasLicenseForAppResult;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push appID
  push integer(steamID)
  call [EAX+64]
end;

function ISteamUser014.IsBehindNAT(): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+68]
end;

function ISteamUser014.AdvertiseGame(gameID: CGameID; steamIDGameServer: CSteamID;
     unIPServer: uint32; usPortServer: uint16): boolean;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  push usPortServer
  push unIPServer
  push integer(steamIDGameServer)
  push integer(gameID)
  call [EAX+72]
end;

function ISteamUser014.RequestEncryptedAppTicket(): unknown_ret;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+76]
end;

function ISteamUser014.GetEncryptedAppTicket(): unknown_ret;
asm
  mov EAX, [EBP+$08]
  mov EAX, [EAX+$04]
  mov ECX, EAX
  mov EAX, [EAX]
  call [EAX+80]
end;

end.
