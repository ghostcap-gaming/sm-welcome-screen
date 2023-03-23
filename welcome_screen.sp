#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>

char g_sClientHudBuffer[MAXPLAYERS+1][64];
bool g_bClientInScreen[MAXPLAYERS+1];
bool g_bClientShowedScreen[MAXPLAYERS+1];
bool g_bVIP[MAXPLAYERS+1] = {false, ...};

public Plugin myinfo = {
	name = "Welcome screen", 
	author = "Lerrdy", 
	description = "Displays a Welcome screen on connection", 
	version = "0.2", 
	url = "https://ghostcap.com"
};

public void OnPluginStart() {
	RegConsoleCmd("sm_welcomescreen_test", Command_Test);
	
	HookEvent("player_team", EventPlayerTeamPost, EventHookMode_Post);
}

public void OnClientConnected(int client) {
	g_bClientInScreen[client] = false;
	g_bClientShowedScreen[client] = false;
}

public void OnClientDisconnect(int client) {
	g_bClientInScreen[client] = false;
	g_bClientShowedScreen[client] = false;
	g_bVIP[client] = false;
}

public void OnClientVIPAuthorized(int client, bool vip) {
	g_bVIP[client] = vip;
}

public Action EventPlayerTeamPost(Handle event, const char[] name, bool dontBroadcast) {
	int index = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsFakeClient(index) || g_bVIP[index])
		return Plugin_Continue;
		
	if (!g_bClientShowedScreen[index]) {
		PrintHudImage(index, "<img src='https://www.gcgfast.com/welcome_screen.png'>");
		
		g_bClientInScreen[index] = true;
		g_bClientShowedScreen[index] = true;
		
		CreateTimer(15.0, Timer_ClearScreen, GetClientUserId(index));
	}
	
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int& buttons) {
	if (!g_bClientInScreen[client])
		return Plugin_Continue;
		
	if(buttons & IN_USE) {
		g_bClientInScreen[client] = false;
		
		Event cs_win_panel_round = CreateEvent("cs_win_panel_round");
		if (cs_win_panel_round != null) {
			cs_win_panel_round.SetString("funfact_token", "");
			cs_win_panel_round.FireToClient(client);
			cs_win_panel_round.Cancel(); 
		}
	}
	
	return Plugin_Continue;
}

public Action Command_Test(int client, int args) {
	PrintHudImage(client, "<img src='https://www.gcgfast.com/welcome_screen.png>");
	
	g_bClientInScreen[client] = true;
	
	return Plugin_Handled;
}

stock void PrintHudImage(int client, const char[] message = NULL_STRING, bool refresh = true) {
	Event cs_win_panel_round = CreateEvent("cs_win_panel_round");
	if (cs_win_panel_round != null) {
		Format(g_sClientHudBuffer[client], 64, "%s", message);
		
		if (refresh)
			CreateTimer(2.0, Timer_RepeatMessage, GetClientUserId(client));
		
		cs_win_panel_round.SetString("funfact_token", message);
		cs_win_panel_round.FireToClient(client);
		cs_win_panel_round.Cancel(); 
    }
}

public Action Timer_RepeatMessage(Handle timer, any userid) {
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client))
		PrintHudImage(client, g_sClientHudBuffer[client], false);
	
	return Plugin_Handled;
}

public Action Timer_ClearScreen(Handle Timer, any userid) {
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client) || !g_bClientInScreen[client]) return Plugin_Handled;
	
	Event cs_win_panel_round = CreateEvent("cs_win_panel_round");
	if (cs_win_panel_round != null) {
		cs_win_panel_round.SetString("funfact_token", "");
		cs_win_panel_round.FireToClient(client);
		cs_win_panel_round.Cancel(); 
	}
	
	return Plugin_Handled;
}