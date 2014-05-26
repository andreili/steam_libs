unit IClientFriends_;

interface

uses
  SteamTypes, FriendsCommon;

type
  IClientFriends = class
    // returns the local players name - guaranteed to not be NULL.
    function GetPersonaName(): pAnsichar; virtual; abstract;
    // sets the player name, stores it on the server and publishes the changes to all friends who are online
    procedure SetPersonaName(pchPersonaName: pAnsiChar); virtual; abstract;
    function IsPersonaNameSet(): boolean; virtual; abstract;

    // gets the friend status of the current user
    function GetPersonaState(): EPersonaState; virtual; abstract;
    // sets the status, communicates to server, tells all friends
    procedure SetPersonaState(ePersonaState: EPersonaState); virtual; abstract;

    // friend iteration
    function GetFriendCount(iFriendFlags: int): int; virtual; abstract;
    function GetFriendByIndex(iFriend, iFriendFlags: int): CSteamID; virtual; abstract;

    // gets the relationship to a user
    function GetFriendRelationship(steamIDFriend: CSteamID): EFriendRelationship; virtual; abstract;
    function GetFriendPersonaState(steamIDFriend: CSteamID): EPersonaState; virtual; abstract;
    // returns the name of a friend - guaranteed to not be NULL.
    function GetFriendPersonaName(steamIDFriend: CSteamID): pAnsiChar; virtual; abstract;

    procedure SetFriendAlias(steamIDFriend: CSteamID; pchAlias: pAnsiChar); virtual; abstract;

    // gets the avatar of the current user, which is a handle to be used in IClientUtils::GetImageRGBA(), or 0 if none set
    function GetSmallFriendAvatar(steamIDFriend: CSteamID): int; virtual; abstract;
    function GetMediumFriendAvatar(steamIDFriend: CSteamID): int; virtual; abstract;
    function GetLargeFriendAvatar(steamIDFriend: CSteamID): int; virtual; abstract;

    // steam registry, accessed by friend
    procedure SetFriendRegValue(steamIDFriend: CSteamID; pchKey, pchValue: pAnsiChar); virtual; abstract;
    function GetFriendRegValue(steamIDFriend: CSteamID; pchKey: pAnsiChar): pAnsiChar; virtual; abstract;

    function DeleteFriendRegValue(steamID: CSteamID; pchKey: pAnsiChar): boolean; virtual; abstract;

    function GetFriendGamePlayed(steamID: CSteamID; var pGamePlayInfo: FriendGameInfo_t): boolean; virtual; abstract;
    function GetFriendGamePlayedExtraInfo(steamID: CSteamID): pAnsiChar; virtual; abstract;

    function GetFriendGameServer(steamID: CSteamID): CSteamID; virtual; abstract;

    // accesses old friends names - returns an empty string when their are no more items in the history
    function GetFriendPersonaNameHistory(steamIDFriend: CSteamID; iPersonaName: int): pAnsiChar; virtual; abstract;

    function AddFriend(steamID: CSteamID): boolean; virtual; abstract;
    function RemoveFriend(steamID: CSteamID): boolean; virtual; abstract;
    function HasFriend(steamID: CSteamID; iFriendFlags: int): boolean; virtual; abstract;

    // adds a friend by email address or account name - value returned in callback
    function AddFriendByName(pchEmailOrAccountName: pAnsiChar): HSteamCall; virtual; abstract;

    function InviteFriendByEmail(pchEmailAddress: pAnsiChar): boolean; virtual; abstract;

    function RequestUserInformation(steamID: CSteamID): boolean; virtual; abstract;

    function SetIgnoreFriend(steamID: CSteamID; bIgnore: boolean): boolean; virtual; abstract;

    function ReportChatDeclined(steamID: CSteamID): boolean; virtual; abstract;

    // chat message iteration
    // returns the number of bytes in the message, filling pvData with as many of those bytes as possible
    // returns 0 if the steamID or iChatID are invalid
    function GetChatMessage(steamIDFriend: CSteamID; iChatID: int; pvData: Pointer; cubData: int;
     var peChatEntryType: EChatEntryType; var pSteamIDChatter: CSteamID): int; virtual; abstract;

    // generic friend->friend message sending, takes a sized buffer
    function SendMsgToFriend(steamIDFriend: CSteamID; eChatEntryType: EChatEntryType; var pvMsgBody: int; cubMsgBody: int): boolean; virtual; abstract;

    // returns the chatID that a chat should be resumed from when switching chat contexts
    function GetChatIDOfChatHistoryStart(steamIDFriend: CSteamID): int; virtual; abstract;
    // sets where a chat with a user should resume
    procedure SetChatHistoryStart(steamIDFriend: CSteamID; iChatID: int); virtual; abstract;
    // clears the chat history - should be called when a chat dialog closes
    // the chat history can still be recovered by another context using SetChatHistoryStart() to reset the ChatIDOfChatHistoryStart
    procedure ClearChatHistory(steamIDFriend: CSteamID); virtual; abstract;

    function GetKnownClanCount(): int; virtual; abstract;
    function GetKnownClanByIndex(iClan: int): CSteamID; virtual; abstract;
    function GetClanCount(): int; virtual; abstract;
    function GetClanByIndex(iClan: int): CSteamID; virtual; abstract;

    function GetClanName(steamID: CSteamID): pAnsiChar; virtual; abstract;
    function GetClanTag(steamID: CSteamID): pAnsiChar; virtual; abstract;

    function GetFriendActivityCounts(var a, b: int): boolean; virtual; abstract;
    function GetClanActivityCounts(steamID: CSteamID; var pnOnline, pnInGame, pnChatting: int): boolean; virtual; abstract;

    function IsClanPublic(steamID:CSteamID): boolean; virtual; abstract;
    function IsClanLarge(steamID: CSteamID): boolean; virtual; abstract;

    function SubscribeToPersonaStateFeed(a1: CSteamID; a2: boolean): unknown_ret; virtual; abstract;

    function InviteFriendToClan(steamIDfriend, steamIDclan: CSteamID): boolean; virtual; abstract;
    function AcknowledgeInviteToClan(steamID: CSteamID; bAcceptOrDenyClanInvite: boolean): boolean; virtual; abstract;

    // iterators for any source
    function GetFriendCountFromSource(steamIDSource: CSteamID): int; virtual; abstract;
    function GetFriendFromSourceByIndex(steamIDSource: CSteamID; iFriend: int): CSteamID; virtual; abstract;
    function IsUserInSource(steamIDUser, steamIDSource: CSteamID): boolean; virtual; abstract;

    function GetCoplayFriendCount(): int; virtual; abstract;
    function GetCoplayFriend(v: int): CSteamID; virtual; abstract;

    // most likely a RTime32
    function GetFriendCoplayTime(steamID: CSteamID): RTime32; virtual; abstract;
    function GetFriendCoplayGame(steamID: CSteamID): CGameID; virtual; abstract;

    function JoinChatRoom(steamID: CSteamID): boolean; virtual; abstract;
    procedure LeaveChatRoom(steamID: CSteamID); virtual; abstract;

    function InviteUserToChatRoom(steamIDfriend, steamIDchat: CSteamID): boolean; virtual; abstract;

    function SendChatMsg(steamIDchat: CSteamID; eChatEntryType: EChatEntryType; pvMsgBody: Pointer; cubMsgBody: int): boolean; virtual; abstract;

    function GetChatRoomEntry(steamIDchat: CSteamID; iChatID: int; var steamIDuser: CSteamID; pvData: Pointer;
     cubData: int; var peChatEntryType: EChatEntryType): int; virtual; abstract;

    function GetChatIDOfChatRoomHistoryStart(steamIDchat: CSteamID): int; virtual; abstract;
    procedure SetChatRoomHistoryStart(steamIDchat: CSteamID; iChat: int); virtual; abstract;

    procedure ClearChatRoomHistory(steamID: CSteamID); virtual; abstract;

    function SerializeChatRoomDlg(steamIDchat: CSteamID; pvHistory: pAnsiChar; cubHistory: int): boolean; virtual; abstract;
    function GetSizeOfSerializedChatRoomDlg(steamIDchat: CSteamID): int; virtual; abstract;
    function GetSerializedChatRoomDlg(steamIDchat: CSteamID; pvHistory: Pointer; cubBuffer: int; var pcubData: int): boolean; virtual; abstract;
    function ClearSerializedChatRoomDlg(steamIDchat: CSteamID): boolean; virtual; abstract;

    function KickChatMember(steamIDchat: CSteamID; steamIDuser: CSteamID): boolean; virtual; abstract;
    function BanChatMember(steamIDchat: CSteamID; steamIDuser: CSteamID): boolean; virtual; abstract;
    function UnBanChatMember(steamIDchat: CSteamID; steamIDuser: CSteamID): boolean; virtual; abstract;

    function SetChatRoomType(steamIDchat: CSteamID; eLobbyType: ELobbyType): boolean; virtual; abstract;
    function GetChatRoomLockState(steamIDchat: CSteamID; var pbLocked: boolean): boolean; virtual; abstract;
    function GetChatRoomPermissions(steamIDchat: CSteamID; var prgfChatRoomPermissions: uint32): boolean; virtual; abstract;

    function SetChatRoomModerated(steamIDchat: CSteamID; bModerated: boolean): boolean; virtual; abstract;
    function ChatRoomModerated(steamIDChat: CSteamID): boolean; virtual; abstract;

    function NotifyChatRoomDlgsOfUIChange(steamIDchat: CSteamID; bShowAvatars, bBeepOnNewMsg, bShowSteamIDs, bShowTimestampOnNewMsg: boolean): boolean; virtual; abstract;

    function TerminateChatRoom(steamIDchat: CSteamID): boolean; virtual; abstract;

    function GetChatRoomCount(): int; virtual; abstract;
    function GetChatRoomByIndex(iChatRoom: int): CSteamID; virtual; abstract;

    function GetChatRoomName(steamIDchat: CSteamID): pAnsiChar; virtual; abstract;

    function GetChatRoomMemberDetails(steamIDchat, steamIDuser: CSteamID; var pChatMemberDetails, pChatMemberDetailsLocal: uint32): boolean;  virtual; abstract;

    procedure CreateChatRoom(eType: EChatRoomType; ulGameID: uint64; pchName: pAnsiChar; eLobbyType: ELobbyType;
     steamIDClan, steamIDFriendChat, steamIDInvited: CSteamID; chatPermissionOfficer, chatPermissionMember, chatPermissionAll: uint32); virtual; abstract;

    function GetChatRoomMetadata(steamIDchat, steamIDuser: CSteamID; pchKey: pAnsiChar): pAnsiChar; virtual; abstract;
    function SetChatRoomMetadata(steamIDChat, steamIDMember: CSteamID; pchKey, pchValue: pAnsiChar): boolean; virtual; abstract;

    function SetChatRoomPermissions(steamIDchat, steamIDmemeber: CSteamID; permissions: uint32; bMakeOwner: boolean): boolean; virtual; abstract;

    procedure VoiceCall(steamIDlocal, steamIDremote: CSteamID); virtual; abstract;
    procedure VoiceHangUp(hVoiceCall: HVoiceCall); virtual; abstract;

    function SetVoiceSpeakerVolume(flVolume: float): boolean; virtual; abstract;
    function SetVoiceMicrophoneVolume(flVolume: float): boolean; virtual; abstract;

    procedure SetAutoAnswer(bAutoAnswer: boolean); virtual; abstract;

    procedure VoiceAnswer(hVoiceCall: HVoiceCall); virtual; abstract;

    procedure VoicePutOnHold(hVoiceCall: HVoiceCall; bOnLocalHold: boolean); virtual; abstract;
    function VoiceIsLocalOnHold(hVoiceCall: HVoiceCall): boolean; virtual; abstract;
    function VoiceIsRemoteOnHold(hVoiceCall: HVoiceCall): boolean; virtual; abstract;

    procedure SetDoNotDisturb(bDoNotDisturb: boolean); virtual; abstract;

    procedure EnableVoiceNotificationSounds(bEnable: boolean); virtual; abstract;

    procedure SetPushToTalkEnabled(bEnabled: boolean); virtual; abstract;
    function IsPushToTalkEnabled(): boolean; virtual; abstract;

    procedure SetPushToTalkKey(nKey: int); virtual; abstract;
    function GetPushToTalkKey(): int; virtual; abstract;

    function IsPushToTalkKeyDown(): boolean; virtual; abstract;

    procedure EnableVoiceCalibration(bEnable: boolean); virtual; abstract;
    function IsVoiceCalibrating(): boolean; virtual; abstract;
    function GetVoiceCalibrationSamplePeak(): float; virtual; abstract;

    procedure SetForceMicRecord(bForce: boolean); virtual; abstract;
    function GetForceMicRecord(): boolean; virtual; abstract;

    procedure SetMicBoost(bBoost: boolean); virtual; abstract;
    function GetMicBoost(): boolean; virtual; abstract;

    function HasHardwareMicBoost(): boolean; virtual; abstract;

    function GetMicDeviceName(): pAnsiChar; virtual; abstract;

    procedure StartTalking(hVoiceCall: HVoiceCall); virtual; abstract;
    procedure EndTalking(hVoiceCall: HVoiceCall); virtual; abstract;

    procedure VoiceIsValid(hVoiceCall: HVoiceCall); virtual; abstract;

    procedure SetAutoReflectVoice(bAuto: boolean); virtual; abstract;

    function GetCallState(hVoiceCall: HVoiceCall): ECallState; virtual; abstract;

    function GetVoiceMicrophoneVolume(): float; virtual; abstract;
    function GetVoiceSpeakerVolume(): float;  virtual; abstract;

    function TimeSinceLastVoiceDataReceived(hVoiceCall: HVoiceCall): float; virtual; abstract;
    function TimeSinceLastVoiceDataSend(hVoiceCall: HVoiceCall): float; virtual; abstract;

    function CanSend(hVoiceCall: HVoiceCall): boolean; virtual; abstract;
    function CanReceive(hVoiceCall: HVoiceCall): boolean; virtual; abstract;

    function GetEstimatedBitsPerSecond(hVoiceCall: HVoiceCall; bIncoming: boolean): float; virtual; abstract;
    function GetPeakSample(hVoiceCall: HVoiceCall; bIncoming: boolean): float; virtual; abstract;

    procedure SendResumeRequest(hVoiceCall: HVoiceCall); virtual; abstract;

    procedure OpenChatDialog(steamID: CSteamID); virtual; abstract;

    procedure StartChatRoomVoiceSpeaking(steamIDchat, steamIDuser: CSteamID); virtual; abstract;
    procedure EndChatRoomVoiceSpeaking(steamIDchat, steamIDuser: CSteamID); virtual; abstract;

    function GetFriendLastLogonTime(steamID: CSteamID): RTime32; virtual; abstract;
    function GetFriendLastLogoffTime(steamID: CSteamID): RTime32; virtual; abstract;

    function GetChatRoomVoiceTotalSlotCount(steamIDchat: CSteamID): int; virtual; abstract;
    function GetChatRoomVoiceUsedSlotCount(steamIDchat: CSteamID): int; virtual; abstract;
    function GetChatRoomVoiceUsedSlot(steamID: CSteamID; iSlot: int): CSteamID; virtual; abstract;
    function GetChatRoomVoiceStatus(steamIDchat, steamIDuser: CSteamID): EChatRoomVoiceStatus; virtual; abstract;

    function ChatRoomHasAvailableVoiceSlots(steamID: CSteamID): boolean; virtual; abstract;

    function IsChatRoomVoiceSpeaking(steamIDchat, steamIDuser: CSteamID): boolean; virtual; abstract;

    function GetChatRoomPeakSample(steamIDchat, steamIDuser: CSteamID; bIncoming: boolean): boolean; virtual; abstract;

    procedure ChatRoomVoiceRetryConnections(steamIDchat: CSteamID); virtual; abstract;

    procedure SetPortTypes(unFlags: uint32); virtual; abstract;

    procedure ReinitAudio(); virtual; abstract;

    procedure SetInGameVoiceSpeaking(steamIDuser: CSteamID; bIsSpeaking: boolean); virtual; abstract;

    procedure ActivateGameOverlay(pchDialog: pAnsiChar); virtual; abstract;
    procedure ActivateGameOverlayToUser(pchDialog: pAnsiChar; steamID: CSteamID); virtual; abstract;
    procedure ActivateGameOverlayToWebPage(pchUrl: pAnsiChar); virtual; abstract;
    procedure ActivateGameOverlayToStore(nAppId: AppId_t); virtual; abstract;
    procedure ActivateGameOverlayInviteDialog(steamIDLobby: CSteamID); virtual; abstract;

    procedure NotifyGameOverlayStateChanged(bActive: boolean); virtual; abstract;
    procedure NotifyGameServerChangeRequested(pchServerAddress, pchPassword: pAnsiChar); virtual; abstract;
    function NotifyLobbyJoinRequested(nAppId: AppId_t; steamIDlobby, steamIDfriend: CSteamID): boolean; virtual; abstract;

    function GetClanRelationship(steamIDclan: CSteamID): EClanRelationship; virtual; abstract;

    function GetFriendClanRank(steamIDuser, steamIDclan: CSteamID): EClanRank; virtual; abstract;

    function VoiceIsAvailable(): boolean; virtual; abstract;

    procedure TestVoiceDisconnect(hVoiceCall: HVoiceCall); virtual; abstract;
    procedure TestChatRoomPeerDisconnect(steamIDchat, steamIDuser: CSteamID); virtual; abstract;
    procedure TestVoicePacketLoss(flPacketDropFraction: float); virtual; abstract;

    function FindFriendVoiceChatHandle(steamID: CSteamID): HVoiceCall; virtual; abstract;

    procedure RequestFriendsWhoPlayGame(gameId: CGameID); virtual; abstract;
    function GetCountFriendsWhoPlayGame(gameId: CGameID): uint32; virtual; abstract;

    function GetFriendWhoPlaysGame(a1: uint32; gameId: CGameID): CSteamID;  virtual; abstract;
    procedure SetPlayedWith(steamId: CSteamID); virtual; abstract;
  end;

implementation

end.
