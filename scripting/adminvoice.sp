#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

public Plugin MyInfo = { 
	name = "Admin Voice", 
	author = "-_- (Karol Skupień)", 
	description = "Admin Voice",
	version = "1.0", 
	url = "https://github.com/Qesik" 
};

ConVar g_cResetOnSpawn;

public void OnPluginStart(/*void*/) {
	RegConsoleCmd("admin_voice", cmd_AdminVoice);
	HookEvent("player_spawn", ev_PlayerSpawn);

	g_cResetOnSpawn = CreateConVar("av_reset_on_spawn", "1", "Reset admin_voice on spawn");
	AutoExecConfig(true, "AdminVoice");
}

public Action cmd_AdminVoice(int iClient, int iArgs) {
	if ( !IsValidClient(iClient) || !CheckCommandAccess(iClient, "admin_voice", ADMFLAG_CHAT) )
		return Plugin_Continue;

	if ( iArgs != 1 ) {
		ReplyToCommand(iClient, "Use: admin_voice <1/0>");
		return Plugin_Continue;
	}

	char sValue[4];
	GetCmdArg(1, sValue, sizeof(sValue));
	bool bAllVoice = view_as<bool>(StringToInt(sValue));
	SetClientListeningFlags(iClient, bAllVoice ? (VOICE_SPEAKALL | VOICE_LISTENALL) : VOICE_NORMAL);
	ReplyToCommand(iClient, "*** ADMIN VOICE %s ***", bAllVoice ? "ON" : "OFF");

	return Plugin_Continue;
}

public Action ev_PlayerSpawn(Event eEvent, const char[] sName, bool bDontBroadcast) {
	int iClient = GetClientOfUserId(eEvent.GetInt("userid"));
	if ( !IsValidClient(iClient) || !g_cResetOnSpawn.BoolValue || !CheckCommandAccess(iClient, "admin_voice", ADMFLAG_CHAT) )
		return Plugin_Continue;

	if ( GetClientListeningFlags(iClient) != VOICE_NORMAL )
		SetClientListeningFlags(iClient, VOICE_NORMAL);

	return Plugin_Continue;
}

bool IsValidClient(int iClient) {
	return iClient > 0 && iClient <= MaxClients && IsClientConnected(iClient) && IsClientInGame(iClient);
}