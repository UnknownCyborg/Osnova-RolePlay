@___If_u_can_read_this_u_r_nerd();
@___If_u_can_read_this_u_r_nerd()
{
	#emit	 stack	 0x7FFFFFFF
	#emit	 inc.s	 cellmax
	static const ___[][] = {"pawn-wiki", ".ru"};
	#emit	 retn
	#emit	 load.s.pri	 ___
	#emit	 proc
	#emit	 proc
	#emit	 fill	 cellmax
	#emit	 proc
	#emit	 stack    1
	#emit	 stor.alt	 ___
	#emit	 strb.i    2
	#emit	 switch	   4
	#emit	 retn
L1:
	#emit	 jump	 L1
	#emit	 zero	 cellmin
}
#include <a_samp>
main()
{
    print(!"_______________________________________________________");
	print(!" Server by: hell'hell'							   	  ");
	print(!" vk.com/dykan_vallik							  	 ");
	print(!" Motion project � 2020, inc. all rights reserved. 	  ");
	print(!"_______________________________________________________");
}
#include <a_mysql> // MySQL
#include <streamer>
#include <Pawn.CMD> // ���������� ���������.
#include <sscanf2>
#include <foreach>
#include <Pawn.Regex>
#include <TOTP>
#include <geolocation> // � �������� ���������� ������� �������.
//#include <nex-ac> // Anti Cheat
#include <SKY> // ��� ������ � W-C
#include <weapon-config> // ��� W-C
#include <crashdetect>
#include <time_t>

#if defined MAX_PLAYER_NAME
	#undef MAX_PLAYER_NAME
#endif
#define MAX_PLAYER_NAME 20

#if defined MAX_PLAYERS
	#undef MAX_PLAYERS
#endif
#define MAX_PLAYERS 50

#define SQL_HOST  				!""
#define SQL_USER  				!""
#define SQL_PASS  				!""
#define SQL_BASE 		 		!""

#define SERVER_NAME 			"Osnova RolePlay"
#define SERVER_NAME2			"Osnova"
#define SERVER_NAME3			"O-RP"
#define SERVER_VER 				!"O-RP v0.03>v.0.04B"

#define MAX_ADMINS 				10 // ���� ����������� ������������ ���, ������� �� 50-100 (����� �����������).
#define DELAY_TO_KICK 			1250 // 1.2 ��� �� ��� ������, ����� �� �������� ���� �� ��������� � ���� ���!

#define TABLE_ACCOUNT			"accounts"
#define TABLE_BANLIST			"banlist" 
#define TABLE_BANLISTIP 		"banlistip" 

#define SERVER 					"{9ACD32}"

#define COLOR_SERVER			0x9ACD32FF
#define	COLOR_GREY				0x999999FF
#define COLOR_RED 				0xFF0000FF
#define COLOR_NOTIFICATION 		0xFF8C00FF
#define COLOR_LIGHTRED      	0xe93230FF
#define COLOR_TOMATO      		0xFF6347FF
#define COLOR_BLUE          	0x3657FFFF
#define COLOR_LIGHTBLUE     	0x3399FFFF
#define COLOR_YELLOW			0xFFFF00FF

#define pName(%0)   			PlayerInfo[%0][pName]
#define function:%0(%1)			forward %0(%1); public %0(%1)

// ============================== Variable's ======================
// TextDraws
new Text:GraphicPIN_TD;
new Text:LOGO[5];  
new PlayerText:GraphicPIN_PTD[MAX_PLAYERS][4];

static pPickupID[MAX_PLAYERS]; // ����� ����� ��������
new PlayerAFK[MAX_PLAYERS];
new expmultiply = 4;
new LoginTimer[MAX_PLAYERS];
new AntiFloodChat[MAX_PLAYERS]; // Anti Flood chat
new AntiFloodCommand[MAX_PLAYERS]; // Anti Flood command

// Iterator's
new Iterator:Admins_ITER<MAX_ADMINS>;

//
new MySQL:dbHandle; // MySQL connection

// Enum's
enum pInfo
{
	pID,
	pName[MAX_PLAYER_NAME],
	pPassword[65],
	pSalt[11],
	pEmail[65],
	pRef,
	pRefmoney,
	pSex,
	pRace,
	pAge,
	pSkin,
	pRegdate[13],
	pRegip[16],
	pAdmin,
	pMoney,
	pLvl,
	pExp,
	pPin[2],
	pLastip[16],
	tempPINCHECK[4],
	tempENTEREDPIN[4],
	pGoogleauth[17],
	pGoogleauthsetting,
	pSecondTimer,
	pWrongPassword,
	pTimePlayed,
	pInAdmCar,
	// bools
	bool:pLogged,
}
new PlayerInfo[MAX_PLAYERS][pInfo];

enum dialogs
{
	dNone,
	dReg,
	dRegEmail,
	dRegRef,
	dRegSex,
	dRegRace,
	dRegAge,
	dLog,
	dMainMenu,
	dStats,
	dSecuresettings,
	dNewpassword1,
	dNewpassword2,
	dSecretpincontrol,
	dSecretpinset,
	dSecretpinreset,
	dGoogleauthinstall,
	dGoogleauthinstallCheck,
	dGoogleauthcontrol,
	dCheckgoogleauth,
	dInformadm,
	dReport,
	dAhelp,
	dAhelpCMD,
	dQuestion,
	dAnswerplayer,
	dAddfastanswer,
}

new PlayerRaces[3][] = {"����������", "������������", "������������/���������"};

public OnGameModeInit()
{ 
	ConnectMySQL(); // Create MySQL connection.
	SetGameModeText(SERVER_VER);
	SendRconCommand(!"hostname "SERVER_NAME" | ��� ��� �� ���� �������� :)");
	
	LoadMapping();
	LoadTextDraws();
	LoadPickups();
	Load3DText();
	LoadDynamicZones();
	
	Iter_Clear(Admins_ITER);

	SetVehiclePassengerDamage(true); // W-C.
    SetDisableSyncBugs(true); // W-C.
	
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
	LimitPlayerMarkerRadius(45.0);
	
	SetTimer(!"GrandTimer", 1000, true);
	SetTimer(!"MinuteUpdate", 60000, true);
	new _mins, _seconds;
	gettime(_, _mins, _seconds);
	SetTimer(!"PayDay", ((60-_mins)*1000*60)+(60-_seconds)*10, false); // PayDay System
	printf("["SERVER_NAME3"] PayDay ����� ����� %d�:%d�.", (60-_mins), (60-_seconds));
	
 	SetWeather(12);
	return true;
}

stock KickEx(playerid, delay = DELAY_TO_KICK)
{
	if(!IsPlayerConnected(playerid)) return false;
	SetTimerEx(!"KickPlayer", delay, false, !"d", playerid);
	return false;
}

function: KickPlayer(playerid) Kick(playerid);

stock LoadMapping()
{
	new map_spawn;
	map_spawn = CreateObject(5033, 1745.199951, -1882.849975, 26.140600, 0.000000, 0.000000, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 2, 16640, "a51", "concreteyellow256 copy", 0xFFFFFFFF);
	SetObjectMaterial(map_spawn, 3, 9901, "ferry_building", "skylight_windows", 0x00000000);
	SetObjectMaterial(map_spawn, 5, 10765, "airportgnd_sfse", "white", 0x00000000);
	SetObjectMaterial(map_spawn, 6, 16640, "a51", "concreteyellow256 copy", 0x00000000);
	SetObjectMaterial(map_spawn, 7, 9901, "ferry_building", "skylight_windows", 0x00000000);
	SetObjectMaterial(map_spawn, 9, 6404, "beafron1_law2", "woodroof01_128", 0x00000000);
	map_spawn = CreateObject(4821, 1745.199951, -1882.849975, 26.140600, 0.000000, 0.000000, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 2, 4830, "airport2", "bathtile01_int", 0x00000000);
	SetObjectMaterial(map_spawn, 5, 4552, "ammu_lan2", "sl_lavicdtwall1", 0x00000000);
	SetObjectMaterial(map_spawn, 7, 10765, "airportgnd_sfse", "ws_runwaytarmac", 0x00000000);
	SetObjectMaterial(map_spawn, 8, 7555, "bballcpark1", "ws_carparknew2", 0x00000000);
	SetObjectMaterial(map_spawn, 9, 4829, "airport_las", "sjmlahus28", 0x00000000);
	SetObjectMaterial(map_spawn, 10, 9514, "711_sfw", "mono2_sfe", 0x00000000);
	map_spawn = CreateObject(19399, 1793.759155, -1891.440307, 10.823890, 0.000000, -0.000030, 179.999816, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1793.759155, -1894.499511, 10.823890, 0.000000, -0.000030, 179.999816, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1793.759155, -1897.699218, 10.823890, 0.000000, -0.000030, 179.999816, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1793.759155, -1900.909423, 10.823890, 0.000000, -0.000038, 179.999771, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1793.759155, -1904.118774, 10.823890, 0.000000, -0.000038, 179.999771, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1793.759155, -1907.318481, 10.823890, 0.000000, -0.000038, 179.999771, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1793.759155, -1910.508666, 10.823890, 0.000000, -0.000045, 179.999725, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1793.759155, -1913.718017, 10.823890, 0.000000, -0.000045, 179.999725, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1793.759155, -1916.917724, 10.823890, 0.000000, -0.000045, 179.999725, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1793.759155, -1920.116699, 10.823890, 0.000000, -0.000053, 179.999679, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1793.759155, -1923.145874, 10.823890, 0.000000, -0.000053, 179.999679, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1787.526855, -1891.440307, 10.823890, 0.000000, -0.000045, 179.999725, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1787.526855, -1894.499511, 10.823890, 0.000000, -0.000045, 179.999725, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1787.526855, -1897.699218, 10.823890, 0.000000, -0.000045, 179.999725, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1787.526855, -1900.909423, 10.823890, 0.000000, -0.000053, 179.999679, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1787.526855, -1904.118774, 10.823890, 0.000000, -0.000053, 179.999679, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1787.526855, -1907.318481, 10.823890, 0.000000, -0.000053, 179.999679, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1787.526855, -1910.508666, 10.823890, 0.000000, -0.000061, 179.999633, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1787.526855, -1913.718017, 10.823890, 0.000000, -0.000061, 179.999633, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1787.526855, -1916.917724, 10.823890, 0.000000, -0.000061, 179.999633, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1787.526855, -1920.116699, 10.823890, 0.000000, -0.000068, 179.999588, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1787.526855, -1923.145874, 10.823890, 0.000000, -0.000068, 179.999588, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1792.240234, -1889.920288, 10.813890, 0.000007, 0.000000, 89.999977, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1789.030517, -1889.920288, 10.813890, 0.000007, 0.000000, 89.999977, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1792.240234, -1924.692871, 10.813890, 0.000022, 0.000000, 89.999931, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19399, 1789.030517, -1924.692871, 10.813890, 0.000022, 0.000000, 89.999931, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1890.801025, 12.415001, 0.000000, 90.000000, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1890.801025, 12.395001, 0.000000, 90.000000, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1892.351196, 12.415001, 0.000000, 90.000015, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1892.351196, 12.395001, 0.000000, 90.000015, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1893.871826, 12.415001, 0.000000, 90.000022, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1893.871826, 12.395001, 0.000000, 90.000022, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1895.373046, 12.415001, 0.000000, 90.000030, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1895.373046, 12.395001, 0.000000, 90.000030, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1896.943359, 12.415001, 0.000000, 90.000038, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1896.943359, 12.395001, 0.000000, 90.000038, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1898.523193, 12.415001, 0.000000, 90.000045, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1898.523193, 12.395001, 0.000000, 90.000045, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1900.053466, 12.415001, 0.000000, 90.000053, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1900.053466, 12.395001, 0.000000, 90.000053, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1901.634033, 12.415001, 0.000000, 90.000061, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1901.634033, 12.395001, 0.000000, 90.000061, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1903.185058, 12.415001, 0.000000, 90.000068, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1903.185058, 12.395001, 0.000000, 90.000068, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1904.774291, 12.415001, 0.000000, 90.000083, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1904.774291, 12.395001, 0.000000, 90.000083, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1906.354125, 12.415001, 0.000000, 90.000091, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1906.354125, 12.395001, 0.000000, 90.000091, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1907.934448, 12.415001, 0.000000, 90.000076, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1907.934448, 12.395001, 0.000000, 90.000076, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1909.523681, 12.415001, 0.000000, 90.000091, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1909.523681, 12.395001, 0.000000, 90.000091, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1911.103515, 12.415001, 0.000000, 90.000099, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1911.103515, 12.395001, 0.000000, 90.000099, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1912.684692, 12.415001, 0.000000, 90.000083, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1912.684692, 12.395001, 0.000000, 90.000083, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1914.273925, 12.415001, 0.000000, 90.000099, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1914.273925, 12.395001, 0.000000, 90.000099, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1915.853759, 12.415001, 0.000000, 90.000106, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1915.853759, 12.395001, 0.000000, 90.000106, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1917.424438, 12.415001, 0.000000, 90.000091, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1917.424438, 12.395001, 0.000000, 90.000091, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1919.013671, 12.415001, 0.000000, 90.000106, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1919.013671, 12.395001, 0.000000, 90.000106, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1920.593505, 12.415001, 0.000000, 90.000114, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1920.593505, 12.395001, 0.000000, 90.000114, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1922.194824, 12.415001, 0.000000, 90.000114, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1922.194824, 12.395001, 0.000000, 90.000114, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1791.962036, -1923.774658, 12.415001, 0.000000, 90.000122, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(19430, 1789.321166, -1923.774658, 12.395001, 0.000000, 90.000122, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10101, "2notherbuildsfe", "Bow_church_grass_alt", 0x00000000);
	map_spawn = CreateObject(970, 1809.586669, -1884.309814, 13.100625, 0.000000, 0.000000, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1805.426879, -1884.309814, 13.100625, 0.000000, 0.000000, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1801.266357, -1884.309814, 13.100625, 0.000000, 0.000000, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1797.105834, -1884.309814, 13.100625, 0.000000, 0.000000, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1792.965820, -1884.309814, 13.100625, 0.000000, 0.000000, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1784.684692, -1884.309814, 13.100625, 0.000000, 0.000000, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1788.845581, -1884.309814, 13.100625, 0.000000, 0.000000, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1780.545288, -1884.309814, 13.100625, 0.000000, 0.000000, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1776.406616, -1884.309814, 13.100625, 0.000000, 0.000000, 0.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1774.305297, -1886.370849, 13.100625, 0.000000, 0.000000, 90.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1774.305297, -1890.531372, 13.100625, 0.000000, 0.000000, 90.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1774.305297, -1896.791625, 13.100625, 0.000000, 0.000000, 90.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1774.305297, -1903.251831, 13.100625, 0.000000, 0.000000, 90.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1774.305297, -1907.412353, 13.100625, 0.000000, 0.000000, 90.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1774.305297, -1919.474975, 13.100625, 0.000000, 0.000000, 90.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1774.305297, -1931.514770, 13.100625, 0.000000, 0.000000, 90.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1774.305297, -1933.584594, 13.100625, 0.000000, 0.000000, 90.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1776.366821, -1935.695678, 13.100625, 0.000000, 0.000000, 180.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1780.517211, -1935.695678, 13.100625, 0.000000, 0.000000, 180.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1784.688354, -1935.695678, 13.100625, 0.000000, 0.000000, 180.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1788.828979, -1935.695678, 13.100625, 0.000000, 0.000000, 180.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1792.969848, -1935.695678, 13.100625, 0.000000, 0.000000, 180.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1797.110473, -1935.695678, 13.100625, 0.000000, 0.000000, 180.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1801.261230, -1935.695678, 13.100625, 0.000000, 0.000000, 180.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1804.701171, -1935.695678, 13.100625, 0.000000, 0.000000, 180.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1806.802612, -1933.633789, 13.100625, 0.000000, 0.000000, 270.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1806.802612, -1929.503173, 13.100625, 0.000000, 0.000000, 270.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1806.802612, -1925.372436, 13.100625, 0.000000, 0.000000, 270.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1806.802612, -1921.241943, 13.100625, 0.000000, 0.000000, 270.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1806.802612, -1917.111083, 13.100625, 0.000000, 0.000000, 270.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1806.802612, -1913.011108, 13.100625, 0.000000, 0.000000, 270.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1806.802612, -1908.900878, 13.100625, 0.000000, 0.000000, 270.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1806.802612, -1904.770629, 13.100625, 0.000000, 0.000000, 270.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1806.802612, -1901.370971, 13.100625, 0.000000, 0.000000, 270.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(970, 1807.874877, -1897.508911, 13.100625, 0.000000, 0.000000, -120.900039, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 6284, "bev_law2", "glass_fence_64hv", 0x00000000);
	SetObjectMaterial(map_spawn, 1, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0x00000000);
	map_spawn = CreateObject(19377, 1770.328735, -1883.590087, 19.347818, 0.000000, 0.000000, 90.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	SetObjectMaterial(map_spawn, 5, -1, "none", "none", 0xFFFFFFFF);
	map_spawn = CreateObject(19377, 1757.208496, -1883.600097, 19.297822, 0.000000, 0.000000, 90.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 10765, "airportgnd_sfse", "white", 0x00000000);
	SetObjectMaterial(map_spawn, 5, 14668, "711c", "forumstand1_LAe", 0x00000000);
	map_spawn = CreateObject(19377, 1742.139282, -1864.908569, 20.338226, 0.000000, 0.000000, 90.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 9901, "ferry_building", "skylight_windows", 0x00000000);
	map_spawn = CreateObject(19477, 1763.468017, -1883.767822, 16.166734, 0.000000, 0.000000, 270.000000, 2000.00); 
	SetObjectMaterialText(map_spawn, "Los Santos", 0, 120, "Calibri", 100, 1, 0xFFFFFFFF, 0x00000000, 1);
	map_spawn = CreateObject(19477, 1763.433959, -1883.731689, 16.135526, 0.000000, 0.000000, 90.000000, 2000.00); 
	SetObjectMaterial(map_spawn, 0, 19962, "samproadsigns", "streetsign", 0x00000000);
	/////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////
	map_spawn = CreateObject(4853, 1735.969970, -1951.219970, 15.050000, 356.859985, 0.000000, 0.140000, 2000.00); 
	map_spawn = CreateObject(19399, 1810.049072, -1889.770141, 10.663887, 0.000000, 0.000000, 90.000000, 2000.00); 
	map_spawn = CreateObject(19426, 1800.661743, -1889.771484, 10.665992, 0.000000, 0.000000, 90.000000, 2000.00); 
	map_spawn = CreateObject(19399, 1806.839233, -1889.770141, 10.663887, 0.000000, 0.000000, 90.000000, 2000.00); 
	map_spawn = CreateObject(19399, 1803.629272, -1889.770141, 10.663887, 0.000000, 0.000000, 90.000000, 2000.00); 
	map_spawn = CreateObject(19426, 1798.441284, -1889.771484, 10.665992, 0.000000, 0.000000, 90.000000, 2000.00); 
	map_spawn = CreateObject(19399, 1795.410156, -1889.770141, 10.663887, 0.000000, 0.000000, 90.000000, 2000.00); 
	map_spawn = CreateObject(19399, 1792.240234, -1889.770141, 10.663887, 0.000000, 0.000000, 90.000000, 2000.00); 
	map_spawn = CreateObject(19399, 1789.030517, -1889.770141, 10.663887, 0.000000, 0.000000, 90.000000, 2000.00); 
	map_spawn = CreateObject(19399, 1787.359985, -1891.290161, 10.663887, 0.000000, 0.000000, 180.000000, 2000.00); 
	map_spawn = CreateObject(19399, 1787.359985, -1894.499511, 10.663887, 0.000000, 0.000000, 180.000000, 2000.00); 
	map_spawn = CreateObject(19399, 1787.359985, -1897.699218, 10.663887, 0.000000, 0.000000, 180.000000, 2000.00); 
	map_spawn = CreateObject(19399, 1787.359985, -1900.909423, 10.663887, 0.000000, -0.000007, 179.999954, 2000.00); 
	map_spawn = CreateObject(19399, 1787.359985, -1904.118774, 10.663887, 0.000000, -0.000007, 179.999954, 2000.00); 
	map_spawn = CreateObject(19399, 1787.359985, -1907.318481, 10.663887, 0.000000, -0.000007, 179.999954, 2000.00); 
	map_spawn = CreateObject(19399, 1787.359985, -1910.508666, 10.663887, 0.000000, -0.000015, 179.999908, 2000.00); 
	map_spawn = CreateObject(19399, 1787.359985, -1913.718017, 10.663887, 0.000000, -0.000015, 179.999908, 2000.00); 
	map_spawn = CreateObject(19399, 1787.359985, -1916.917724, 10.663887, 0.000000, -0.000015, 179.999908, 2000.00); 
	map_spawn = CreateObject(19399, 1787.359985, -1920.116699, 10.663887, 0.000000, -0.000022, 179.999862, 2000.00); 
	map_spawn = CreateObject(19399, 1787.359985, -1923.326049, 10.663887, 0.000000, -0.000022, 179.999862, 2000.00); 
	map_spawn = CreateObject(19399, 1792.260253, -1924.833740, 10.663887, 0.000007, 0.000000, 89.999977, 2000.00); 
	map_spawn = CreateObject(19399, 1789.050537, -1924.833740, 10.663887, 0.000007, 0.000000, 89.999977, 2000.00); 
	map_spawn = CreateObject(19399, 1793.939331, -1891.450317, 10.663887, 0.000000, -0.000015, 179.999908, 2000.00); 
	map_spawn = CreateObject(19399, 1793.939331, -1894.499511, 10.663887, 0.000000, -0.000015, 179.999908, 2000.00); 
	map_spawn = CreateObject(19399, 1793.939331, -1897.699218, 10.663887, 0.000000, -0.000015, 179.999908, 2000.00); 
	map_spawn = CreateObject(19399, 1793.939331, -1900.909423, 10.663887, 0.000000, -0.000022, 179.999862, 2000.00); 
	map_spawn = CreateObject(19399, 1793.939331, -1904.118774, 10.663887, 0.000000, -0.000022, 179.999862, 2000.00); 
	map_spawn = CreateObject(19399, 1793.939331, -1907.318481, 10.663887, 0.000000, -0.000022, 179.999862, 2000.00); 
	map_spawn = CreateObject(19399, 1793.939331, -1910.508666, 10.663887, 0.000000, -0.000030, 179.999816, 2000.00); 
	map_spawn = CreateObject(19399, 1793.939331, -1913.718017, 10.663887, 0.000000, -0.000030, 179.999816, 2000.00); 
	map_spawn = CreateObject(19399, 1793.939331, -1916.917724, 10.663887, 0.000000, -0.000030, 179.999816, 2000.00); 
	map_spawn = CreateObject(19399, 1793.939331, -1920.116699, 10.663887, 0.000000, -0.000038, 179.999771, 2000.00); 
	map_spawn = CreateObject(19399, 1793.939331, -1923.326049, 10.663887, 0.000000, -0.000038, 179.999771, 2000.00); 
	map_spawn = CreateObject(738, 1790.949218, -1892.332153, 12.525765, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(738, 1790.949218, -1900.103515, 12.525765, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(738, 1790.949218, -1908.074462, 12.525765, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(738, 1790.949218, -1915.724365, 12.525765, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(738, 1790.949218, -1922.793945, 12.525765, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(870, 1791.737426, -1905.977294, 12.730065, 0.000000, 0.000015, 0.000000, 2000.00); 
	map_spawn = CreateObject(870, 1789.365966, -1904.137207, 12.730065, 0.000007, -0.000013, 152.299896, 2000.00); 
	map_spawn = CreateObject(870, 1791.996826, -1901.879638, 12.730065, 0.000007, -0.000013, 152.299896, 2000.00); 
	map_spawn = CreateObject(870, 1789.636108, -1894.094848, 12.730065, 0.000000, 0.000015, 179.699859, 2000.00); 
	map_spawn = CreateObject(870, 1791.997924, -1895.947265, 12.730065, 0.000007, -0.000013, -28.000148, 2000.00); 
	map_spawn = CreateObject(870, 1789.355224, -1898.191162, 12.730065, 0.000007, -0.000013, -28.000148, 2000.00); 
	map_spawn = CreateObject(870, 1789.636108, -1909.554687, 12.730065, 0.000000, 0.000007, 179.699813, 2000.00); 
	map_spawn = CreateObject(870, 1791.997924, -1911.407104, 12.730065, 0.000003, -0.000006, -28.000148, 2000.00); 
	map_spawn = CreateObject(870, 1789.355224, -1913.651000, 12.730065, 0.000003, -0.000006, -28.000148, 2000.00); 
	map_spawn = CreateObject(870, 1791.737426, -1921.236450, 12.730065, 0.000000, 0.000022, 0.000000, 2000.00); 
	map_spawn = CreateObject(870, 1789.365966, -1919.396362, 12.730065, 0.000010, -0.000020, 152.299865, 2000.00); 
	map_spawn = CreateObject(870, 1791.996826, -1917.138793, 12.730065, 0.000010, -0.000020, 152.299865, 2000.00); 
	map_spawn = CreateObject(870, 1792.328247, -1891.898803, 12.730065, 0.000000, 0.000015, 179.699859, 2000.00); 
	map_spawn = CreateObject(870, 1789.067871, -1922.909423, 12.730065, 0.000010, -0.000020, 152.299865, 2000.00); 
	map_spawn = CreateObject(1257, 1772.523071, -1924.336791, 13.780218, 0.000000, 0.000000, 180.000000, 2000.00); 
	map_spawn = CreateObject(1257, 1772.523071, -1914.682128, 13.780218, 0.000000, -0.000007, 179.999954, 2000.00); 
	map_spawn = CreateObject(19399, 1775.959594, -1928.577026, 10.663887, -0.000007, -0.000022, -90.000099, 2000.00); 
	map_spawn = CreateObject(19399, 1777.639526, -1927.066162, 10.663887, 0.000000, -0.000015, -0.000122, 2000.00); 
	map_spawn = CreateObject(19399, 1777.639526, -1923.895751, 10.663887, 0.000000, -0.000015, -0.000122, 2000.00); 
	map_spawn = CreateObject(19399, 1777.639526, -1922.025878, 10.663887, 0.000000, -0.000015, -0.000122, 2000.00); 
	map_spawn = CreateObject(19399, 1775.959594, -1920.506835, 10.663887, -0.000007, -0.000022, -90.000099, 2000.00); 
	map_spawn = CreateObject(19399, 1775.959594, -1918.654296, 10.663887, -0.000022, -0.000022, -90.000053, 2000.00); 
	map_spawn = CreateObject(19399, 1777.639526, -1917.143432, 10.663887, -0.000000, 0.000000, -0.000122, 2000.00); 
	map_spawn = CreateObject(19399, 1777.639526, -1913.973022, 10.663887, -0.000000, 0.000000, -0.000122, 2000.00); 
	map_spawn = CreateObject(19399, 1777.639526, -1912.103149, 10.663887, -0.000000, 0.000000, -0.000122, 2000.00); 
	map_spawn = CreateObject(19399, 1775.959594, -1910.584106, 10.663887, -0.000022, -0.000022, -90.000053, 2000.00); 
	map_spawn = CreateObject(19399, 1775.994140, -1919.594116, 10.663887, -0.000022, -0.000022, -54.600097, 2000.00); 
	map_spawn = CreateObject(19399, 1777.639526, -1919.693481, 10.663887, -0.000000, 0.000000, -0.000122, 2000.00); 
	map_spawn = CreateObject(1232, 1790.903442, -1919.114013, 15.068397, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1232, 1790.903442, -1912.003417, 15.068397, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1232, 1790.903442, -1904.072753, 15.068397, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1232, 1790.903442, -1896.202270, 15.068397, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1232, 1773.703369, -1896.902954, 15.068397, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1232, 1773.703369, -1885.640869, 15.068397, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1232, 1773.703369, -1907.551025, 15.068397, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1232, 1773.703369, -1919.491821, 15.068397, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1232, 1773.703369, -1932.632568, 15.068397, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1232, 1784.582397, -1935.983764, 15.068397, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1232, 1800.352172, -1935.983764, 15.068397, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1232, 1807.192382, -1925.412231, 15.068397, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1232, 1807.192382, -1913.182250, 15.068397, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1232, 1807.192382, -1903.491943, 15.068397, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1232, 1807.192382, -1883.882324, 15.068397, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1232, 1793.901489, -1883.882324, 15.068397, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(19399, 1810.049072, -1855.069335, 10.663887, 0.000000, 0.000000, 90.000000, 2000.00); 
	map_spawn = CreateObject(19399, 1806.849853, -1855.069335, 10.663887, 0.000000, 0.000000, 90.000000, 2000.00); 
	map_spawn = CreateObject(19399, 1803.639892, -1855.069335, 10.663887, 0.000000, 0.000000, 90.000000, 2000.00); 
	map_spawn = CreateObject(19399, 1800.450561, -1855.069335, 10.663887, 0.000000, 0.000000, 90.000000, 2000.00); 
	map_spawn = CreateObject(19399, 1797.269165, -1855.069335, 10.663887, 0.000007, 0.000000, 89.999977, 2000.00); 
	map_spawn = CreateObject(19399, 1794.069946, -1855.069335, 10.663887, 0.000007, 0.000000, 89.999977, 2000.00); 
	map_spawn = CreateObject(19399, 1790.859985, -1855.069335, 10.663887, 0.000007, 0.000000, 89.999977, 2000.00); 
	map_spawn = CreateObject(19399, 1787.670654, -1855.069335, 10.663887, 0.000007, 0.000000, 89.999977, 2000.00); 
	map_spawn = CreateObject(19399, 1784.459106, -1855.069335, 10.663887, 0.000015, 0.000000, 89.999954, 2000.00); 
	map_spawn = CreateObject(19399, 1781.259887, -1855.069335, 10.663887, 0.000015, 0.000000, 89.999954, 2000.00); 
	map_spawn = CreateObject(19399, 1778.049926, -1855.069335, 10.663887, 0.000015, 0.000000, 89.999954, 2000.00); 
	map_spawn = CreateObject(19399, 1774.860595, -1855.069335, 10.663887, 0.000015, 0.000000, 89.999954, 2000.00); 
	map_spawn = CreateObject(19399, 1771.659667, -1855.069335, 10.663887, 0.000022, 0.000000, 89.999931, 2000.00); 
	map_spawn = CreateObject(19399, 1768.460449, -1855.069335, 10.663887, 0.000022, 0.000000, 89.999931, 2000.00); 
	map_spawn = CreateObject(19399, 1765.250488, -1855.069335, 10.663887, 0.000022, 0.000000, 89.999931, 2000.00); 
	map_spawn = CreateObject(19399, 1762.061157, -1855.069335, 10.663887, 0.000022, 0.000000, 89.999931, 2000.00); 
	map_spawn = CreateObject(19399, 1758.880004, -1855.069335, 10.663887, 0.000030, 0.000000, 89.999908, 2000.00); 
	map_spawn = CreateObject(19399, 1755.680786, -1855.069335, 10.663887, 0.000030, 0.000000, 89.999908, 2000.00); 
	map_spawn = CreateObject(19399, 1752.470825, -1855.069335, 10.663887, 0.000030, 0.000000, 89.999908, 2000.00); 
	map_spawn = CreateObject(19399, 1749.281494, -1855.069335, 10.663887, 0.000030, 0.000000, 89.999908, 2000.00); 
	map_spawn = CreateObject(19399, 1746.071166, -1855.069335, 10.663887, 0.000038, 0.000000, 89.999885, 2000.00); 
	map_spawn = CreateObject(19399, 1742.871948, -1855.069335, 10.663887, 0.000038, 0.000000, 89.999885, 2000.00); 
	map_spawn = CreateObject(19399, 1739.661987, -1855.069335, 10.663887, 0.000038, 0.000000, 89.999885, 2000.00); 
	map_spawn = CreateObject(19399, 1736.472656, -1855.069335, 10.663887, 0.000038, 0.000000, 89.999885, 2000.00); 
	map_spawn = CreateObject(19399, 1732.119506, -1855.069335, 10.663887, 0.000045, 0.000000, 89.999862, 2000.00); 
	map_spawn = CreateObject(19399, 1727.759155, -1855.069335, 10.663887, 0.000045, 0.000000, 89.999862, 2000.00); 
	map_spawn = CreateObject(1346, 1771.640869, -1904.566894, 13.998662, 0.000000, 0.000000, 270.000000, 2000.00); 
	map_spawn = CreateObject(1285, 1768.602661, -1906.901855, 13.110745, 0.000000, 0.000007, 0.000000, 2000.00); 
	map_spawn = CreateObject(1286, 1768.141723, -1906.896362, 13.132098, 0.000000, 0.000007, 0.000000, 2000.00); 
	map_spawn = CreateObject(1287, 1767.648681, -1906.875366, 13.142859, 0.000000, 0.000007, 0.000000, 2000.00); 
	map_spawn = CreateObject(1288, 1767.169799, -1906.849487, 13.153707, 0.000000, 0.000007, 0.000000, 2000.00); 
	map_spawn = CreateObject(1340, 1758.583984, -1904.406494, 13.609810, 0.000000, 0.000000, 68.800003, 2000.00); 
	map_spawn = CreateObject(3862, 1765.959106, -1911.598022, 13.729010, 0.000000, 0.000000, 270.000000, 2000.00); 
	map_spawn = CreateObject(3862, 1765.959106, -1916.348388, 13.729010, 0.000000, 0.000000, 270.000000, 2000.00); 
	map_spawn = CreateObject(3861, 1765.919189, -1921.492553, 13.736182, 0.000000, 0.000000, 270.000000, 2000.00); 
	map_spawn = CreateObject(1215, 1759.748535, -1910.183105, 13.146018, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1215, 1759.748535, -1913.923339, 13.146018, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1215, 1759.748535, -1920.393554, 13.146018, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1215, 1759.748535, -1928.132934, 13.146018, 0.000000, 0.000000, 0.000000, 2000.00); 
	map_spawn = CreateObject(1342, 1761.989257, -1904.847167, 13.603018, 0.000000, 0.000000, 88.800025, 2000.00); 
	map_spawn = CreateObject(1341, 1764.408447, -1905.113769, 13.444880, 0.000000, 0.000000, 89.800018, 2000.00); 
	map_spawn = CreateObject(19324, 1771.722167, -1903.599121, 13.189965, 0.000000, 0.000000, 180.000000, 2000.00); 
	map_spawn = CreateObject(638, 1759.223510, -1885.116943, 13.255992, 0.000000, 0.000000, 90.000000, 2000.00); 
	map_spawn = CreateObject(638, 1755.513427, -1885.116943, 13.255992, 0.000000, 0.000000, 90.000000, 2000.00); 
	map_spawn = CreateObject(638, 1771.663940, -1885.116943, 13.255992, 0.000007, 0.000000, 89.999977, 2000.00); 
	map_spawn = CreateObject(638, 1767.953857, -1885.116943, 13.255992, 0.000007, 0.000000, 89.999977, 2000.00); 
}

stock LoadTextDraws()
{
    LOGO[0] = TextDrawCreate(551.500000, -4.355563, "hud:radarringplane"); 
	TextDrawLetterSize(LOGO[0], 0.000000, 0.000000); 
	TextDrawTextSize(LOGO[0], 19.500000, 28.622177); 
	TextDrawAlignment(LOGO[0], 1); 
	TextDrawColor(LOGO[0], -16776961); 
	TextDrawSetShadow(LOGO[0], 0); 
	TextDrawSetOutline(LOGO[0], 0); 
	TextDrawBackgroundColor(LOGO[0], -16776961); 
	TextDrawFont(LOGO[0], 4); 

	LOGO[1] = TextDrawCreate(556.000000, 8.088897, "O"); 
	TextDrawLetterSize(LOGO[1], 0.449999, 1.600000); 
	TextDrawAlignment(LOGO[1], 1); 
	TextDrawColor(LOGO[1], -16776961); 
	TextDrawSetShadow(LOGO[1], 0); 
	TextDrawSetOutline(LOGO[1], 1); 
	TextDrawBackgroundColor(LOGO[1], 51); 
	TextDrawFont(LOGO[1], 1); 
	TextDrawSetProportional(LOGO[1], 1); 

	LOGO[2] = TextDrawCreate(565.000000, 8.088858, "snova"); 
	TextDrawLetterSize(LOGO[2], 0.449999, 1.600000); 
	TextDrawAlignment(LOGO[2], 1); 
	TextDrawColor(LOGO[2], -16776961); 
	TextDrawSetShadow(LOGO[2], 0); 
	TextDrawSetOutline(LOGO[2], 1); 
	TextDrawBackgroundColor(LOGO[2], 51); 
	TextDrawFont(LOGO[2], 1); 
	TextDrawSetProportional(LOGO[2], 1); 

	LOGO[3] = TextDrawCreate(565.500000, 20.533287, "RolePlay"); 
	TextDrawLetterSize(LOGO[3], 0.165500, 0.840888); 
	TextDrawAlignment(LOGO[3], 1); 
	TextDrawColor(LOGO[3], -1); 
	TextDrawSetShadow(LOGO[3], 0); 
	TextDrawSetOutline(LOGO[3], 1); 
	TextDrawBackgroundColor(LOGO[3], 51); 
	TextDrawFont(LOGO[3], 2); 
	TextDrawSetProportional(LOGO[3], 1); 

	LOGO[4] = TextDrawCreate(603.000000, 3.111082, "ld_chat:badchat"); 
	TextDrawLetterSize(LOGO[4], 0.000000, 0.000000); 
	TextDrawTextSize(LOGO[4], 12.000000, 11.200004); 
	TextDrawAlignment(LOGO[4], 1); 
	TextDrawColor(LOGO[4], -1); 
	TextDrawSetShadow(LOGO[4], 0); 
	TextDrawSetOutline(LOGO[4], 0); 
	TextDrawFont(LOGO[4], 4);  
}

stock LoadPickups()
{
    return true;
}

stock Load3DText()
{
    return true;
}

stock LoadDynamicZones()
{
    return true;
}

stock ConnectMySQL()
{
    dbHandle = mysql_connect(SQL_HOST, SQL_USER, SQL_PASS, SQL_BASE);
	switch(mysql_errno())
    {
        case 0: print(!"����������� � ���� ������ �������!");
        case 1044: print(!"����������� � ���� ������ �� ������� [������� ����������� ��� ������������]");
        case 1045: print(!"����������� � ���� ������ �� ������� [������ ����������� ������]");
        case 1049: print(!"����������� � ���� ������ �� ������� [������� ����������� ���� ������]");
        case 2003: print(!"����������� � ���� ������ �� ������� [������� � ����� ������ ����������]");
        case 2005: print(!"����������� � ���� ������ �� ������� [������ ����������� ����� ��������]");
        default: printf("����������� � ���� ������ �� ������� [����������� ������. ��� ������: %d]", mysql_errno());
    }
	mysql_log(ERROR | WARNING); // MySQL logs.
	mysql_set_charset("cp1251"); // Set cyrylic.
}

stock SendErrorMessage(playerid, const text[])
{
    new str[134+1] = !"�{FFFFFF} ";
    strcat(str, text);
    PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
    return SendClientMessage(playerid, 0xAA3333FF, str);
}

stock SendInfoMessage(playerid, const text[])
{
    new str[134+1] = !"�{FFFFFF} ";
    strcat(str, text);
    PlayerPlaySound(playerid, 21001, 0.0, 0.0, 0.0);
    return SendClientMessage(playerid, 0xFFC800FF, str);
}

stock SendGoodMessage(playerid, const text[])
{
    new str[134+1] = !"�{FFFFFF} ";
    strcat(str, text);
    PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0);
    return SendClientMessage(playerid, 0xDC143CFF, str);
}

public OnGameModeExit()
{
	mysql_close(); // Close Connection to MySQL
	return true;
}

function: PayDay()
{
	new _mins, _seconds;
	gettime(_, _mins, _seconds);
	SetTimer(!"PayDay", ((60-_mins)*1000*60)+(60-_seconds)*10, false); // PayDay System
	foreach(new i:Player)
	{
		if(PlayerInfo[i][pTimePlayed] >= 300) GiveExp(i, 1);
	}
	return printf("["SERVER_NAME3"] PayDay ����� ����� %d�:%d�.", (60-_mins), (60-_seconds));
}

function: GrandTimer()
{
	return false;
}

function: PlayerSecondTimer(playerid)
{
	if(PlayerInfo[playerid][pLogged])
	{
		if(GetPlayerMoney(playerid) != PlayerInfo[playerid][pMoney])
		{
		    ResetPlayerMoney(playerid);
		    GivePlayerMoney(playerid, PlayerInfo[playerid][pMoney]);
		}
	    PlayerAFK[playerid]++;
	    if(PlayerAFK[playerid] >= 3)
	    {
	        new string[35];
	        format(string, sizeof(string), "%s {FFFFFF}%d ���",(PlayerAFK[playerid]) < 300 ? "{00e5ff}[������]" : (PlayerAFK[playerid]) < 1800 ? "{e0ff00}[������]" : "{ff6d00}[������]", PlayerAFK[playerid]);
	        SetPlayerChatBubble(playerid, string, -1, 20, 1050);
	    }
	    PlayerInfo[playerid][pTimePlayed]++;
	}
	return true;
}

stock PreloadAnimLib(playerid, animlib[])
{
	ApplyAnimation(playerid, animlib, !"null", 0.0, 0, 0, 0, 0, 0);
	return true;
}
stock PreloadAnim(playerid)
{
    PreloadAnimLib(playerid, !"PED");
    PreloadAnimLib(playerid, !"CRIB");
    PreloadAnimLib(playerid, !"ON_LOOKERS");
    PreloadAnimLib(playerid, !"BASEBALL");
    PreloadAnimLib(playerid, !"CARRY");
    PreloadAnimLib(playerid, !"CRACK");
	return true;
}

public OnPlayerRequestClass(playerid, classid)
{
	return true;
}

stock ResetVariables(playerid)
{
	PlayerInfo[playerid][pWrongPassword] = 3;
    PlayerInfo[playerid][pInAdmCar] = -1;
    AntiFloodChat[playerid] = 0;
    AntiFloodCommand[playerid] = 0;
    PlayerAFK[playerid] = 0;
}

public OnPlayerConnect(playerid)
{
	GetPlayerName(playerid, PlayerInfo[playerid][pName], MAX_PLAYER_NAME);
	GetPlayerIp(playerid, PlayerInfo[playerid][pLastip], 16);
	TogglePlayerSpectating(playerid, 1);
	
	if(!IsRPNick(PlayerInfo[playerid][pName]))
	{
		ShowPlayerDialog(playerid, dNone, DIALOG_STYLE_MSGBOX, !""SERVER"����������", !"{FFFFFF}��� ��� �� ������������� �������� �������.\n������� ����� ��� � ������ � ������� "SERVER"�����.\n\n{FFFFFF}������: "SERVER"Carl_Johnson", !"�����", "");
		return KickEx(playerid);
	}

	ResetVariables(playerid);
	
	SetPlayerColor(playerid, 0x99999900);
	
	LoadPlayerTextDraws(playerid);
	RemoveMappingForPlayer(playerid);
	
	for(new i; i < sizeof(LOGO); i++) TextDrawShowForPlayer(playerid, LOGO[i]);
	
	static const fmt_query[] = "SELECT * FROM `"TABLE_BANLIST"` WHERE `pName` = '%e' AND `status` > '0' LIMIT 1";
	new query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)];
	mysql_format(dbHandle, query, sizeof(query), fmt_query, pName(playerid));
	mysql_tquery(dbHandle, query, !"FindPlayerInTableBanlist", !"d", playerid);
	
	PlayerInfo[playerid][pSecondTimer] = SetTimerEx(!"PlayerSecondTimer", 1000, true, "i", playerid);
	printf("["SERVER_NAME3"] ������ �%d, ������ ��� ������ %s[%d]", PlayerInfo[playerid][pSecondTimer], pName(playerid), playerid);
	return true;
}

stock LoadPlayerTextDraws(playerid)
{
    GraphicPIN_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 249.333236, 196.222259, !"0");
	PlayerTextDrawLetterSize(playerid, GraphicPIN_PTD[playerid][0], 0.928999, 4.694519);
	PlayerTextDrawTextSize(playerid, GraphicPIN_PTD[playerid][0], 39.000000, 39.000000);
	PlayerTextDrawAlignment(playerid, GraphicPIN_PTD[playerid][0], 2);
	PlayerTextDrawColor(playerid, GraphicPIN_PTD[playerid][0], -1);
	PlayerTextDrawUseBox(playerid, GraphicPIN_PTD[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, GraphicPIN_PTD[playerid][0], -5963521);
	PlayerTextDrawSetShadow(playerid, GraphicPIN_PTD[playerid][0], 1);
	PlayerTextDrawSetOutline(playerid, GraphicPIN_PTD[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, GraphicPIN_PTD[playerid][0], 255);
	PlayerTextDrawFont(playerid, GraphicPIN_PTD[playerid][0], 3);
	PlayerTextDrawSetProportional(playerid, GraphicPIN_PTD[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, GraphicPIN_PTD[playerid][0], 1);
	PlayerTextDrawSetSelectable(playerid, GraphicPIN_PTD[playerid][0], true);

	GraphicPIN_PTD[playerid][1] = CreatePlayerTextDraw(playerid, 294.000000, 196.637100, !"1");
	PlayerTextDrawLetterSize(playerid, GraphicPIN_PTD[playerid][1], 0.928999, 4.694519);
	PlayerTextDrawTextSize(playerid, GraphicPIN_PTD[playerid][1], 39.000000, 39.000000);
	PlayerTextDrawAlignment(playerid, GraphicPIN_PTD[playerid][1], 2);
	PlayerTextDrawColor(playerid, GraphicPIN_PTD[playerid][1], -1);
	PlayerTextDrawUseBox(playerid, GraphicPIN_PTD[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, GraphicPIN_PTD[playerid][1], -5963521);
	PlayerTextDrawSetShadow(playerid, GraphicPIN_PTD[playerid][1], 1);
	PlayerTextDrawSetOutline(playerid, GraphicPIN_PTD[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, GraphicPIN_PTD[playerid][1], 255);
	PlayerTextDrawFont(playerid, GraphicPIN_PTD[playerid][1], 3);
	PlayerTextDrawSetProportional(playerid, GraphicPIN_PTD[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, GraphicPIN_PTD[playerid][1], 1);
	PlayerTextDrawSetSelectable(playerid, GraphicPIN_PTD[playerid][1], true);

	GraphicPIN_PTD[playerid][2] = CreatePlayerTextDraw(playerid, 339.000030, 196.637084, !"2");
	PlayerTextDrawLetterSize(playerid, GraphicPIN_PTD[playerid][2], 0.928999, 4.694519);
	PlayerTextDrawTextSize(playerid, GraphicPIN_PTD[playerid][2], 39.000000, 39.000000);
	PlayerTextDrawAlignment(playerid, GraphicPIN_PTD[playerid][2], 2);
	PlayerTextDrawColor(playerid, GraphicPIN_PTD[playerid][2], -1);
	PlayerTextDrawUseBox(playerid, GraphicPIN_PTD[playerid][2], 1);
	PlayerTextDrawBoxColor(playerid, GraphicPIN_PTD[playerid][2], -5963521);
	PlayerTextDrawSetShadow(playerid, GraphicPIN_PTD[playerid][2], 1);
	PlayerTextDrawSetOutline(playerid, GraphicPIN_PTD[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, GraphicPIN_PTD[playerid][2], 255);
	PlayerTextDrawFont(playerid, GraphicPIN_PTD[playerid][2], 3);
	PlayerTextDrawSetProportional(playerid, GraphicPIN_PTD[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, GraphicPIN_PTD[playerid][2], 1);
	PlayerTextDrawSetSelectable(playerid, GraphicPIN_PTD[playerid][2], true);

	GraphicPIN_PTD[playerid][3] = CreatePlayerTextDraw(playerid, 383.666778, 196.637084, !"3");
	PlayerTextDrawLetterSize(playerid, GraphicPIN_PTD[playerid][3], 0.928999, 4.694519);
	PlayerTextDrawTextSize(playerid, GraphicPIN_PTD[playerid][3], 39.000000, 39.000000);
	PlayerTextDrawAlignment(playerid, GraphicPIN_PTD[playerid][3], 2);
	PlayerTextDrawColor(playerid, GraphicPIN_PTD[playerid][3], -1);
	PlayerTextDrawUseBox(playerid, GraphicPIN_PTD[playerid][3], 1);
	PlayerTextDrawBoxColor(playerid, GraphicPIN_PTD[playerid][3], -5963521);
	PlayerTextDrawSetShadow(playerid, GraphicPIN_PTD[playerid][3], 1);
	PlayerTextDrawSetOutline(playerid, GraphicPIN_PTD[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, GraphicPIN_PTD[playerid][3], 255);
	PlayerTextDrawFont(playerid, GraphicPIN_PTD[playerid][3], 3);
	PlayerTextDrawSetProportional(playerid, GraphicPIN_PTD[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, GraphicPIN_PTD[playerid][3], 1);
	PlayerTextDrawSetSelectable(playerid, GraphicPIN_PTD[playerid][3], true);
	return false;
}

stock RemoveMappingForPlayer(playerid)
{
	// Remove To spawn
	RemoveBuildingForPlayer(playerid, 4853, 1736.976, -1960.656, 15.054, 0.250);
	RemoveBuildingForPlayer(playerid, 1226, 1724.875, -1859.539, 16.351, 0.250);
	RemoveBuildingForPlayer(playerid, 620, 1703.468, -1846.710, 10.804, 0.250);
	RemoveBuildingForPlayer(playerid, 620, 1710.835, -1846.710, 10.804, 0.250);
	RemoveBuildingForPlayer(playerid, 1226, 1714.976, -1841.851, 16.351, 0.250);
	RemoveBuildingForPlayer(playerid, 620, 1710.835, -1833.054, 10.804, 0.250);
	RemoveBuildingForPlayer(playerid, 620, 1703.468, -1833.054, 10.804, 0.250);
	RemoveBuildingForPlayer(playerid, 673, 1704.742, -1829.796, 11.445, 0.250);
	RemoveBuildingForPlayer(playerid, 620, 1721.156, -1846.710, 10.804, 0.250);
	RemoveBuildingForPlayer(playerid, 620, 1731.476, -1846.710, 10.804, 0.250);
	RemoveBuildingForPlayer(playerid, 620, 1741.796, -1833.054, 10.804, 0.250);
	RemoveBuildingForPlayer(playerid, 620, 1731.476, -1833.054, 10.804, 0.250);
	RemoveBuildingForPlayer(playerid, 620, 1721.156, -1833.054, 10.804, 0.250);
	RemoveBuildingForPlayer(playerid, 673, 1723.929, -1829.796, 11.445, 0.250);
	RemoveBuildingForPlayer(playerid, 700, 1732.671, -1830.078, 11.445, 0.250);
	RemoveBuildingForPlayer(playerid, 1226, 1774.757, -1931.312, 16.375, 0.250);
	RemoveBuildingForPlayer(playerid, 1226, 1806.429, -1931.601, 16.375, 0.250);
	RemoveBuildingForPlayer(playerid, 5024, 1748.843, -1883.031, 14.187, 0.250);
	RemoveBuildingForPlayer(playerid, 5083, 1748.843, -1883.031, 14.187, 0.250);
	RemoveBuildingForPlayer(playerid, 1226, 1774.757, -1901.539, 16.375, 0.250);
	RemoveBuildingForPlayer(playerid, 1226, 1806.429, -1901.828, 16.375, 0.250);
	RemoveBuildingForPlayer(playerid, 1226, 1755.820, -1859.539, 16.351, 0.250);
	RemoveBuildingForPlayer(playerid, 1226, 1808.125, -1859.539, 16.351, 0.250);
	RemoveBuildingForPlayer(playerid, 1226, 1783.671, -1859.539, 16.351, 0.250);
	RemoveBuildingForPlayer(playerid, 620, 1747.187, -1846.710, 10.804, 0.250);
	RemoveBuildingForPlayer(playerid, 1226, 1742.554, -1835.062, 16.351, 0.250);
	RemoveBuildingForPlayer(playerid, 620, 1762.828, -1846.710, 10.804, 0.250);
	RemoveBuildingForPlayer(playerid, 620, 1778.476, -1846.710, 10.804, 0.250);
	RemoveBuildingForPlayer(playerid, 620, 1794.117, -1846.710, 10.804, 0.250);
	RemoveBuildingForPlayer(playerid, 620, 1809.765, -1846.710, 10.804, 0.250);
	RemoveBuildingForPlayer(playerid, 5033, 1745.199, -1882.849, 26.140, 0.250);
	RemoveBuildingForPlayer(playerid, 5055, 1745.199, -1882.849, 26.140, 0.250);
	RemoveBuildingForPlayer(playerid, 5024, 1748.839, -1883.030, 14.187, 0.250);
	RemoveBuildingForPlayer(playerid, 5083, 1748.839, -1883.030, 14.187, 0.250);
	RemoveBuildingForPlayer(playerid, 4821, 1745.199, -1882.849, 26.140, 0.250);
	RemoveBuildingForPlayer(playerid, 4961, 1745.199, -1882.849, 26.140, 0.250);
}

stock ShowLogin(playerid)
{
	new dialog[171+(-2+MAX_PLAYER_NAME)];
	format(dialog, sizeof(dialog),
	"{FFFFFF}��������� {00ff2b}%s{FFFFFF}, � ������������ �� "SERVER""SERVER_NAME"{FFFFFF}\n\
	\t\t�� ���� ����� ������ ���!\n\n\
	��� ����������� ������� ���� ������ � ���� ����:", pName(playerid));
	ShowPlayerDialog(playerid, dLog, DIALOG_STYLE_PASSWORD, !""SERVER"�����������{FFFFFF}", dialog, !"�����", !"�����");
	KillTimer(LoginTimer[playerid]);
	LoginTimer[playerid] = SetTimerEx(!"LoginTimeExpired", 60000, false, !"d", playerid);
}

function: LoginTimeExpired(playerid)
{
	if(!PlayerInfo[playerid][pLogged])
	{
	    SendClientMessage(playerid, COLOR_LIGHTRED, !"����� �� ����������� ����������.");
	    SendClientMessage(playerid, COLOR_LIGHTRED, !"������� /q(/quit) ����� �����!");
	    ShowPlayerDialog(playerid, -1, 0, " ", " ", " ", " ");
	    KickEx(playerid);
	}
	return false;
}

stock ShowRegistration(playerid)
{
	new dialog[403+(-2+MAX_PLAYER_NAME)];
	format(dialog, sizeof(dialog),
	"{FFFFFF}��������� {FF0000}%s{FFFFFF}, �� ���� ������ ��� �� "SERVER""SERVER_NAME"{FFFFFF}\n\
	������� � ����� ����� �� ���������������\n\
	��� ���� �� ������� �� ������ ������ �����������\n\n\
	���������� ������� ������ ��� ������ �������� �������� � ������� \"�����\"\n\
	"SERVER"\t� ������ ������ ���� �� 8-�� �� 32-�� ��������\n\
	\t� ������ ������ �������� ������ �� ����� � ��������� �������� ������ ��������", pName(playerid));
 	ShowPlayerDialog(playerid, dReg, DIALOG_STYLE_INPUT, !""SERVER"�����������{FFFFFF} � ���� ������", dialog, !"�����", !"�����");
}

public OnPlayerDisconnect(playerid, reason)
{
    KillTimer(LoginTimer[playerid]);
    printf("["SERVER_NAME3"] ������ �%d ������ � ������ %s[%d]", PlayerInfo[playerid][pSecondTimer], pName(playerid), playerid);
    KillTimer(PlayerInfo[playerid][pSecondTimer]);
    UnLoadTextDraws(playerid);
    if(PlayerInfo[playerid][pLogged])
	{
	    if(PlayerInfo[playerid][pAdmin] > 0) Iter_Remove(Admins_ITER, playerid);
	    static const fmt_query[] = "UPDATE "TABLE_ACCOUNT" SET `pLastip` = '%e' WHERE `pID` = '%d'";
		new query[sizeof(fmt_query)+(-2+16)+(-2+8)];
		mysql_format(dbHandle, query, sizeof(query), fmt_query, PlayerInfo[playerid][pLastip], PlayerInfo[playerid][pID]);
		mysql_tquery(dbHandle, query);
		PlayerInfo[playerid][pLogged] = false;
	}
	if(PlayerInfo[playerid][pInAdmCar] != -1)
    {
        DestroyVehicle(PlayerInfo[playerid][pInAdmCar]);
        PlayerInfo[playerid][pInAdmCar] = -1;
    }
	return true;
}

stock UnLoadTextDraws(playerid)
{
    TextDrawHideForPlayer(playerid, GraphicPIN_TD);
    PlayerTextDrawDestroy(playerid, GraphicPIN_PTD[playerid][0]);
    PlayerTextDrawDestroy(playerid, GraphicPIN_PTD[playerid][1]);
    PlayerTextDrawDestroy(playerid, GraphicPIN_PTD[playerid][2]);
    PlayerTextDrawDestroy(playerid, GraphicPIN_PTD[playerid][3]);
    
	for(new i; i < sizeof(LOGO); i++) TextDrawHideForPlayer(playerid, LOGO[i]);  
}

public OnPlayerSpawn(playerid)
{
	if(!PlayerInfo[playerid][pLogged])
	{
	    SendErrorMessage(playerid, !"��� ���� �� ������� �� ������ ��������������!");
		return KickEx(playerid);
	}
	SetPlayerColor(playerid, 0xFFFFFF60);
	PreloadAnim(playerid);
	SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
	SetPlayerScore(playerid, PlayerInfo[playerid][pLvl]);
	SetPlayerPos(playerid, 1755.7334,-1903.0708,13.5638);
	SetPlayerFacingAngle(playerid, 268.2985);
	SetCameraBehindPlayer(playerid);
	return true;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    PlayerAFK[playerid] = -2;
    if(killerid != INVALID_PLAYER_ID)
    {
    	//
    }
	return true;
}

public OnVehicleSpawn(vehicleid)
{
	return true;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return true;
}

public OnPlayerText(playerid, text[])
{
    if(!PlayerInfo[playerid][pLogged])
	{
	    SendErrorMessage(playerid, !"��� ��������� ��������� � ���� �� ������ ��������������!");
	    KickEx(playerid);
		return false;
	}
	if(gettime() <= AntiFloodChat[playerid])
	{
		SendClientMessage(playerid, COLOR_GREY, !"�� �������..");
		return false;
	}
	new string[144];
	if(strlen(text) < 113)
	{
		format(string, sizeof(string), "%s[%d]: {FFFFFF}%s", pName(playerid), playerid, text);
		ProxDetector(20.0, playerid, string, GetPlayerColor(playerid), GetPlayerColor(playerid)-10, GetPlayerColor(playerid)-15, GetPlayerColor(playerid)-20, GetPlayerColor(playerid)-30);
		SetPlayerChatBubble(playerid, text, -1, 20, 7500);
		if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
		{
		    ApplyAnimation(playerid, !"PED", !"IDLE_chat", 4.1, 0, 1, 1, 1, 1);
		    SetTimerEx(!"StopChatAnim", 3200, false, !"d", playerid);
		}
		AntiFloodChat[playerid] = gettime() + 2;
	} else {
	    SendClientMessage(playerid, COLOR_GREY, !"������� ������� ���������");
	    return false;
	}
	return false;
}

function: StopChatAnim(playerid) return ApplyAnimation(playerid, !"PED", !"facanger", 4.1, 0, 1, 1, 1, 1);

public OnPlayerCommandText(playerid, cmdtext[])
{
	return false;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return true;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return true;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(oldstate == PLAYER_STATE_DRIVER)
	{
	    if(PlayerInfo[playerid][pInAdmCar] != -1)
	    {
	        DestroyVehicle(PlayerInfo[playerid][pInAdmCar]);
	       	PlayerInfo[playerid][pInAdmCar] = -1;
	    }
	}
	return true;
}

public OnPlayerDamage(&playerid, &Float:amount, &issuerid, &weapon, &bodypart)
{
	if(!PlayerInfo[playerid][pLogged]) return KickEx(issuerid);
	if(issuerid != INVALID_PLAYER_ID && playerid != INVALID_PLAYER_ID)
	{
		new string[5];
		format(string, sizeof(string), "-%d", floatround(amount));
		SetPlayerChatBubble(playerid, string, 0xFF6347AA, 15, 2500);
	}
	return true;
}
/*
function: OnCheatDetected(playerid, ip_address[], type, code)
{
	switch(code)
	{
		case 38: 
		{
			SendClientMessage(playerid, COLOR_RED, !"��������! � ��� ������ �������� ����������");
			SendClientMessage(playerid, COLOR_RED, !"��� ����� ���������� ���� ���������� �������������� ������ �������� ������ ��!");
			SendClientMessage(playerid, COLOR_RED, !"� �����, ������������ ����������� ��� ��������� �� �� ����������� ������������ ��!");
			return true;
		}
		default:
		{
			new _year, _month, _day;
			getdate( _year, _month, _day);
			static const fmt_str[] = "\
			{FF00AA}�� ���� ����������� �� ������� ����-��� ��������.\n\n\
			{FFFFFF}�� ���������, ��� ��� ����� ��������� �� ������, � ����� ������, �������� ���� ���������.\n\
			{CECECE}���-����: "SERVER"%s\n\
			{CECECE}�������������: "SERVER"#%03i\n\
			{CECECE}��������: "SERVER"%i ��.\n\
			{CECECE}����� �� ������ ������������: "SERVER"%02d:%02d:%02d\n\n\
			\t{FF6347}����������, ��� ������������� ���-�������� ������������ ����������� ��������!";
			new string[sizeof(fmt_str)+(-2+MAX_PLAYER_NAME)+(-4+3)+(-2+3)+(-12+11)];
			format(string, sizeof(string), fmt_str, pName(playerid), code, GetPlayerPing(playerid), _year, _month, _day);
			ShowPlayerDialog(playerid, dNone, DIALOG_STYLE_MSGBOX, !""SERVER"����-���", string, !"�����", "");
			AntiCheatKickWithDesync(playerid, code); // ��� ����� � �������
			format(string, sizeof(string), "[Nex-AC] %s[%d] ���(�) ������ �� ������������� ��� ���-��������. ���: #%03i", pName(playerid), playerid, code);
			SendAdminMessage(COLOR_TOMATO, string);
		}
	}
	return true;
}*/

public OnQueryError(errorid, const error[], const callback[], const query[], MySQL:handle)
{
	printf("[MySQL] Error: %d ID", errorid);
	printf("[MySQL] Text: %s", error);
	printf("[MySQL] Callback: %s", callback);
	printf("[MySQL] Query: %s", query);
	return true;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return true;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return true;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return true;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return true;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	return true;
}
public OnPlayerLeaveDynamicCP(playerid, checkpointid)
{
	return true;
}
public OnPlayerEnterDynamicRaceCP(playerid, checkpointid)
{
	return true;
}
public OnPlayerLeaveDynamicRaceCP(playerid, checkpointid)
{
	return true;
}

public OnRconCommand(cmd[])
{
	return true;
}

public OnPlayerRequestSpawn(playerid)
{
	return true;
}

public OnObjectMoved(objectid)
{
	return true;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return true;
}

public OnDynamicObjectMoved(objectid)
{
	return true;
}

public OnPlayerPickUpDynamicPickup(playerid, STREAMER_TAG_PICKUP pickupid)
{
    if(!IsValidDynamicPickup(pickupid) || pPickupID[playerid]) return false;
    pPickupID[playerid] = pickupid;
	return true;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return true;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return true;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return true;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return true;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return true;
}

public OnPlayerExitedMenu(playerid)
{
	return true;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return true;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return true;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return true;
}

public OnPlayerUpdate(playerid)
{
	if(PlayerAFK[playerid] >= 3)
	{
	    new string[45];
	    format(string, sizeof(string), "�� ��������� � AFK: {FFFFFF}%d ������.", PlayerAFK[playerid]);
	    SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
	}
    if(pPickupID[playerid])
    {
        new pickupid = pPickupID[playerid];
        if(!IsValidDynamicPickup(pickupid)) pPickupID[playerid] = 0;
        else
        {
            new Float:pos_x, Float:pos_y, Float:pos_z;
            Streamer_GetFloatData(STREAMER_TYPE_PICKUP, pickupid, E_STREAMER_X, pos_x);
            Streamer_GetFloatData(STREAMER_TYPE_PICKUP, pickupid, E_STREAMER_Y, pos_y);
            Streamer_GetFloatData(STREAMER_TYPE_PICKUP, pickupid, E_STREAMER_Z, pos_z);
            if(!IsPlayerInRangeOfPoint(playerid, 2.0, pos_x, pos_y, pos_z)) pPickupID[playerid] = 0;
        }
    }
    PlayerAFK[playerid] = 0;
	return true;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return true;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return true;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return true;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new str_len = strlen(inputtext);
	switch(dialogid)
	{
	    case dReg:
	    {
	        if(response)
	        {
	            if(!str_len)
	            {
	                ShowRegistration(playerid);
	                return SendErrorMessage(playerid, !"������� ������ � ���� ���� � ������� \"�����\"");
	            }
	            if(!(8 <= str_len <= 32))
	            {
	                ShowRegistration(playerid);
	                return SendErrorMessage(playerid, !"����� ������ ������ ���� �� 8-�� �� 32-�� ��������");
	            }
	            new regex:rg_passwordcheck = regex_new("^[a-zA-Z0-9]{1,}$");
	            if(regex_check(inputtext, rg_passwordcheck))
	            {
					new salt[11];
					for(new i; i < 10; i++)
					{
					    salt[i] = random(43) + 48;
					}
					salt[10] = 0;
					SHA256_PassHash(inputtext, salt, PlayerInfo[playerid][pPassword], 65);
					strmid(PlayerInfo[playerid][pSalt], salt, 0, 11, 11);
					ShowPlayerDialog(playerid, dRegEmail, DIALOG_STYLE_INPUT, !""SERVER"�����������{FFFFFF} � ���� Email",
				 		!"{FFFFFF}\t\t\t������� ��� ��������� Email �����\n\
				 		���� �� ��������� ������ � ��������, �� �� ������� ������������ ��� ����� Email\n\
						\t\t������� ��� Email � ���� ���� � ������� \"�����\"",
					!"�����", "");
	            }
	            else
	            {
	                ShowRegistration(playerid);
	                regex_delete(rg_passwordcheck);
	                return SendErrorMessage(playerid, !"������ ����� �������� ������ �� ����� � ��������� �������� ������ ��������");
	            }
	            regex_delete(rg_passwordcheck);
	        }
	        else
	        {
	            SendClientMessage(playerid, COLOR_RED, !"����������� \"/q\", ����� �������� ������");
				return KickEx(playerid);
	        }
	    }
	    case dRegEmail:
	    {
	        if(!str_len)
            {
                ShowPlayerDialog(playerid, dRegEmail, DIALOG_STYLE_INPUT, !""SERVER"�����������{FFFFFF} � ���� Email",
			 		!"{FFFFFF}\t\t\t������� ��� ��������� Email �����\n\
			 		���� �� ��������� ������ � ��������, �� �� ������� ������������ ��� ����� Email\n\
					\t\t������� ��� Email � ���� ���� � ������� \"�����\"",
				!"�����", "");
				return SendErrorMessage(playerid, !"������� ��� Email � ���� ���� � ������� \"�����\"");
            }
            new regex:rg_emailcheck = regex_new("^[a-zA-Z0-9.-_]{1,43}@[a-zA-Z]{1,12}\\.[a-zA-Z]{1,8}$");
            if(regex_check(inputtext, rg_emailcheck))
            {
                strmid(PlayerInfo[playerid][pEmail], inputtext, 0, str_len, 64);
                ShowPlayerDialog(playerid, dRegRef, DIALOG_STYLE_INPUT, !""SERVER"�����������{FFFFFF} � ���� �������������",
					!"{FFFFFF}���� �� ����� �� ������ �� �����������, ��\n\
					������ ������� ��� ������������� � ���� ����:",
				!"�����", !"����������");
            }
            else
            {
                ShowPlayerDialog(playerid, dRegEmail, DIALOG_STYLE_INPUT, !""SERVER"�����������{FFFFFF} � ���� Email",
			 		!"{FFFFFF}\t\t\t������� ��� ��������� Email �����\n\
			 		���� �� ��������� ������ � ��������, �� �� ������� ������������ ��� ����� Email\n\
					\t\t������� ��� Email � ���� ���� � ������� \"�����\"",
				!"�����", "");
				regex_delete(rg_emailcheck);
                return SendErrorMessage(playerid, !"������� ��������� ��� Email �����");
            }
            regex_delete(rg_emailcheck);
	    }
	    case dRegRef:
	    {
	        if(response)
	        {
				static const fmt_query[] = "SELECT * FROM "TABLE_ACCOUNT" WHERE `pName` = '%e'";
				new query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)];
				mysql_format(dbHandle, query, sizeof(query), fmt_query, inputtext);
				mysql_tquery(dbHandle, query, "CheckReferal", "is", playerid, inputtext);
	        }
	        else
	        {
	            ShowPlayerDialog(playerid, dRegSex, DIALOG_STYLE_MSGBOX, !""SERVER"�����������{FFFFFF} � ����� ���� ���������",
					!"{FFFFFF}�������� ��� ������ �������� ���������:",
				!"�������", !"�������");
	        }
	    }
	    case dRegSex:
	    {
			PlayerInfo[playerid][pSex] = (response) ? (1) : (2);
	        ShowPlayerDialog(playerid, dRegRace, DIALOG_STYLE_LIST, !""SERVER"�����������{FFFFFF} � ����� ���� ���������",
				!"����������\n\
				������������\n\
				������������/���������",
			!"�����", "");
	    }
	    case dRegRace:
	    {
	        PlayerInfo[playerid][pRace] = listitem+1;
	        ShowPlayerDialog(playerid, dRegAge, DIALOG_STYLE_INPUT, !""SERVER"�����������{FFFFFF} � ����� �������� ���������",
				!"{FFFFFF}������� ������� ������ �������� ���������:\n\
				"SERVER"\t� ������� ������� �� 18-�� �� 60-��",
			!"�����", "");
	    }
		case dRegAge:
		{
		    if(!str_len)
            {
                ShowPlayerDialog(playerid, dRegAge, DIALOG_STYLE_INPUT, !""SERVER"�����������{FFFFFF} � ����� �������� ���������",
					!"{FFFFFF}������� ������� ������ �������� ���������:\n\
					"SERVER"\t� ������� ������� �� 18-�� �� 60-��",
				!"�����", "");
				return SendErrorMessage(playerid, !"������� ��� ������� � ���� ���� � ������� \"�����\"");
			}
			if(!(18 <= strval(inputtext) <= 60))
			{
			    ShowPlayerDialog(playerid, dRegAge, DIALOG_STYLE_INPUT, !""SERVER"�����������{FFFFFF} � ����� �������� ���������",
					!"{FFFFFF}������� ������� ������ �������� ���������:\n\
					"SERVER"\t� ������� ������� �� 18-�� �� 60-��",
				!"�����", "");
				return SendErrorMessage(playerid, !"������� ������� �� 18-�� �� 60-��");
			}
			PlayerInfo[playerid][pAge] = strval(inputtext);
			new regmaleskins[9][4] =
			{
				{19,21,22,28},
				{24,25,36,67},
				{14,142,182,183},
				{29,96,101,26},
				{2,37,72,202},
				{1,3,234,290},
				{23,60,170,180},
				{20,47,48,206},
				{44,58,132,229}
			};
			new regfemaleskins[9][2] = 
			{
				{13,69},
				{9,190},
				{10,218},
				{41,56},
				{31,151},
				{39,89},
				{169,193},
				{207,225},
				{54,130}
			};
			new newskinindex;
			switch(PlayerInfo[playerid][pRace])
			{
				case 2: newskinindex+=3;
				case 3: newskinindex+=6;
			}
			switch(PlayerInfo[playerid][pAge])
			{
			    case 30..45: newskinindex++;
			    case 46..60: newskinindex+=2;
			}
			PlayerInfo[playerid][pSkin] = (PlayerInfo[playerid][pSex] == 1) ? (regmaleskins[newskinindex][random(4)]) : (regfemaleskins[newskinindex][random(2)]);
			new Year, Month, Day;
			getdate(Year, Month, Day);
			new date[13];
			format(date, sizeof(date), "%02d.%02d.%d", Day, Month, Year);
			new ip[16];
			GetPlayerIp(playerid, ip, sizeof(ip));
			static const fmt_query[] = "INSERT INTO "TABLE_ACCOUNT" (`pName`, `pPassword`, `pSalt`, `pEmail`, `pRef`, `pSex`, `pRace`, `pAge`, `pSkin`, `pRegdate`, `pRegip`) VALUES ('%e', '%e', '%e', '%e', '%d', '%d', '%d', '%d', '%d', '%e', '%e')";
			new query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)+(-2+64)+(-2+10)+(-2+64)+(-2+8)+(-2+1)+(-2+1)+(-2+2)+(-2+3)+(-2+12)+(-2+15)];
			mysql_format(dbHandle, query, sizeof(query), fmt_query, pName(playerid), PlayerInfo[playerid][pPassword], PlayerInfo[playerid][pSalt], PlayerInfo[playerid][pEmail], PlayerInfo[playerid][pRef], PlayerInfo[playerid][pSex], PlayerInfo[playerid][pRace], PlayerInfo[playerid][pAge], PlayerInfo[playerid][pSkin], date, ip);
			mysql_tquery(dbHandle, query);
		    PlayerGoLogin(playerid);
		}
		case dLog:
		{
		    if(response)
	        {
	            if(!str_len)
	            {
	                ShowLogin(playerid);
	                return true;
	            }
	            new checkpass[65];
	            SHA256_PassHash(inputtext, PlayerInfo[playerid][pSalt], checkpass, 65);
				if(strcmp(PlayerInfo[playerid][pPassword], checkpass, false, 64) == 0)
				{
				    if(PlayerInfo[playerid][pPin][0] != 0)
					{
						if(PlayerInfo[playerid][pPin][1] == 0)
						{
							if(CheckSubnet(playerid) == 1)//������� ���������
							{
							    if(strlen(PlayerInfo[playerid][pGoogleauth]) > 2)
								{
								    if(PlayerInfo[playerid][pGoogleauthsetting] == 0)
									{
										if(CheckSubnet(playerid) == 1) PlayerGoLogin(playerid);
										else ShowPlayerDialog(playerid, dCheckgoogleauth, DIALOG_STYLE_INPUT, !""SERVER"Google Authenticator", !"{FFFFFF}������� ��� �� ���������� Google Authenticator � ���� ����:", !"�����", "");
									}
									else
									{
									    ShowPlayerDialog(playerid, dCheckgoogleauth, DIALOG_STYLE_INPUT, !""SERVER"Google Authenticator", !"{FFFFFF}������� ��� �� ���������� Google Authenticator � ���� ����:", !"�����", "");
									}
								}
								else PlayerGoLogin(playerid);
							}
							else
							{
                                TextDrawShowForPlayer(playerid, GraphicPIN_TD);
                                GeneratePinCheck(playerid, GetPVarInt(playerid, "pinpos"));
                                SelectTextDraw(playerid, 0x00000030);
							}
						    return true;
						}
						else
						{
						    TextDrawShowForPlayer(playerid, GraphicPIN_TD);
							GeneratePinCheck(playerid, GetPVarInt(playerid, "pinpos"));
                            SelectTextDraw(playerid, 0x00000030);
							return true;
						}
					}
				    if(strlen(PlayerInfo[playerid][pGoogleauth]) > 2)
					{
					    if(PlayerInfo[playerid][pGoogleauthsetting] == 0)
						{
							if(CheckSubnet(playerid) == 1) PlayerGoLogin(playerid);
							else ShowPlayerDialog(playerid, dCheckgoogleauth, DIALOG_STYLE_INPUT, !""SERVER"Google Authenticator", !"{FFFFFF}������� ��� �� ���������� Google Authenticator � ���� ����:", !"�����", "");
						}
						else
						{
						    ShowPlayerDialog(playerid, dCheckgoogleauth, DIALOG_STYLE_INPUT, !""SERVER"Google Authenticator", !"{FFFFFF}������� ��� �� ���������� Google Authenticator � ���� ����:", !"�����", "");
						}
					}
					else PlayerGoLogin(playerid);
				}
				else
				{
				    new string[87];
				    PlayerInfo[playerid][pWrongPassword]--;
				    if(PlayerInfo[playerid][pWrongPassword] > 0)
				    {
				    	format(string, sizeof(string), "�� ����� �������� ������ �� ��������. � ��� �������� %d ������� �����.", PlayerInfo[playerid][pWrongPassword]);
				    	SendErrorMessage(playerid, string);
				    }
				    if(PlayerInfo[playerid][pWrongPassword] <= 0)
				    {
				        SendErrorMessage(playerid, !"�� ��������� ����� ������� ����� � ���� ��������� �� �������.");
				        ShowPlayerDialog(playerid, -1, 0, " ", " ", " ", " ");
				        return KickEx(playerid);
				    }
				    ShowLogin(playerid);
				}
		    }
	        else
	        {
	            SendClientMessage(playerid, COLOR_RED, !"����������� \"/q\", ����� �������� ������");
				return KickEx(playerid);
	        }
		}
		case dMainMenu:
		{
		    if(response)
	        {
	            switch(listitem)
	            {
	                case 0: ShowStats(playerid, 0);
					case 1: ShowPlayerDialog(playerid, dSecuresettings, DIALOG_STYLE_LIST, !""SERVER"��������� ������������", !"�������� ������\n����������� PIN ���\nGoogle Authenticator", !"�������", !"�����");
					case 2: ShowPlayerDialog(playerid, dInformadm, DIALOG_STYLE_LIST, !""SERVER"����� � ��������������", !"�������� {e93230}������\n������ {11dd77}������", !"�������", !"�����");
				}
	        }
		}
		case dStats: if(response) callcmd::menu(playerid);
		case dSecuresettings:
		{
		    if(response)
	        {
	            switch(listitem)
	            {
	                case 0: ShowPlayerDialog(playerid, dNewpassword1, DIALOG_STYLE_INPUT, !""SERVER"��������� ������{FFFFFF} � ��� ������", !"{FFFFFF}������� ��� ������� ������ � ���� ����:", !"�����", !"�������");
	                case 1:
					{
					    new dialog[81];
					    format(dialog, sizeof(dialog),
							"���������� PIN ���\n\
							������� PIN ���\n\
							���������� PIN ��� %s",
						(PlayerInfo[playerid][pPin][1] == 0) ? ("{32CD32}[��� ����� IP]") : (""SERVER"[������]"));
						ShowPlayerDialog(playerid, dSecretpincontrol, DIALOG_STYLE_LIST, !""SERVER"���������� ����������� PIN �����", dialog, !"�������", !"�������");
					}
					case 2:
					{
					    new dialog[120];
					    format(dialog, sizeof(dialog),
							"���������� Google Authenticator\n\
							������� Google Authenticator\n\
							���������� Google Authenticator %s",
						(PlayerInfo[playerid][pGoogleauthsetting] == 0) ? ("{32CD32}[��� ����� IP]") : (""SERVER"[������]"));
						ShowPlayerDialog(playerid, dGoogleauthcontrol, DIALOG_STYLE_LIST, !""SERVER"���������� Google Authenticator", dialog, !"�������", !"�������");
					}
	            }
			}
			else callcmd::menu(playerid);
		}
		case dNewpassword1:
		{
		    if(response)
	        {
			    if(!str_len) return ShowPlayerDialog(playerid, dNewpassword1, DIALOG_STYLE_INPUT, !""SERVER"��������� ������{FFFFFF} � ��� ������", !"{FFFFFF}������� ��� ������� ������ � ���� ����:", !"�����", !"�������");
			    new checkpass[65];
	            SHA256_PassHash(inputtext, PlayerInfo[playerid][pSalt], checkpass, 65);
				if(strcmp(PlayerInfo[playerid][pPassword], checkpass, false, 64) == 0)
				{
				    ShowPlayerDialog(playerid, dNewpassword2, DIALOG_STYLE_INPUT, !""SERVER"��������� ������{FFFFFF} � ��� ������", !"{FFFFFF}������� ��� ����� ������ � ���� ����:", !"���������", !"�������");
				}
				else
				{
	  				SendErrorMessage(playerid, !"�� ����� �������� ������ �� ��������");
	  				return ShowPlayerDialog(playerid, dNewpassword1, DIALOG_STYLE_INPUT, !""SERVER"��������� ������{FFFFFF} � ��� ������", !"{FFFFFF}������� ��� ������� ������ � ���� ����:", !"�����", !"�������");
				}
			}
		}
		case dNewpassword2:
		{
		    if(response)
	        {
			    if(!str_len) return ShowPlayerDialog(playerid, dNewpassword2, DIALOG_STYLE_INPUT, !""SERVER"��������� ������{FFFFFF} � ��� ������", !"{FFFFFF}������� ��� ����� ������ � ���� ����:", !"���������", !"�������");
	            if(!(8 <= str_len <= 32))
	            {
	                ShowPlayerDialog(playerid, dNewpassword2, DIALOG_STYLE_INPUT, !""SERVER"��������� ������{FFFFFF} � ��� ������", !"{FFFFFF}������� ��� ����� ������ � ���� ����:", !"���������", !"�������");
	                return SendErrorMessage(playerid, !"����� ������ ������ ���� �� 8-�� �� 32-�� ��������");
	            }
	            new regex:rg_passwordcheck = regex_new("^[a-zA-Z0-9]{1,}$");
	            if(regex_check(inputtext, rg_passwordcheck))
	            {
					new salt[11];
					for(new i; i < 10; i++) salt[i] = random(43) + 48;
					salt[10] = 0;
					SHA256_PassHash(inputtext, salt, PlayerInfo[playerid][pPassword], 65);
					strmid(PlayerInfo[playerid][pSalt], salt, 0, 11, 11);
					new string[51+(-2+32)];
					format(string, sizeof(string), "��� ����� ������: "SERVER"%s", inputtext);
					SendInfoMessage(playerid, string);
					SendClientMessage(playerid, COLOR_NOTIFICATION, !"[�����������] {FFFFFF}�������� �������� ������� "SERVER"F8{FFFFFF} ��� �������� ����� ������");
					static const fmt_query[] = "UPDATE "TABLE_ACCOUNT" SET `pPassword` = '%e', `pSalt` = '%e' WHERE `pID` = '%d'";
					new query[sizeof(fmt_query)+(-2+64)+(-2+10)+(-2+8)];
					mysql_format(dbHandle, query, sizeof(query), fmt_query, PlayerInfo[playerid][pPassword], PlayerInfo[playerid][pSalt], PlayerInfo[playerid][pID]);
					mysql_tquery(dbHandle, query);
	            }
	            else
	            {
	                ShowPlayerDialog(playerid, dNewpassword2, DIALOG_STYLE_INPUT, !""SERVER"��������� ������{FFFFFF} � ��� ������", !"{FFFFFF}������� ��� ����� ������ � ���� ����:", !"���������", !"�������");
	                regex_delete(rg_passwordcheck);
	                return SendErrorMessage(playerid, !"������ ����� �������� ������ �� ����� � ��������� �������� ������ ��������");
	            }
	            regex_delete(rg_passwordcheck);
			}
		}
		case dSecretpincontrol:
		{
		    if(response)
	        {
	            switch(listitem)
	            {
					case 0:
					{
					    if(PlayerInfo[playerid][pPin][0] != 0)
					    {
					        new dialog[81];
						    format(dialog, sizeof(dialog),
								"���������� PIN ���\n\
								������� PIN ���\n\
								���������� PIN ��� %s",
							(PlayerInfo[playerid][pPin][1] == 0) ? ("{32CD32}[��� ����� IP]") : (""SERVER"[������]"));
							ShowPlayerDialog(playerid, dSecretpincontrol, DIALOG_STYLE_LIST, !""SERVER"���������� ����������� PIN �����", dialog, !"�������", !"�������");
							return SendErrorMessage(playerid, !"� ��� ��� ���������� ����������� PIN ���");
					    }
						ShowPlayerDialog(playerid, dSecretpinset, DIALOG_STYLE_INPUT, !""SERVER"��������� ������������ PIN ����{FFFFFF}", !"{FFFFFF}������� ��� ������� ����������� PIN ��� � ���� ����:\n\n����������: PIN ��� ������ ���� 4-�� ������� � �� ��������� �� 0", !"���������", !"�������");
					}
					case 1:
					{
					    if(PlayerInfo[playerid][pPin][0] == 0)
					    {
					        new dialog[81];
						    format(dialog, sizeof(dialog),
								"���������� PIN ���\n\
								������� PIN ���\n\
								���������� PIN ��� %s",
							(PlayerInfo[playerid][pPin][1] == 0) ? ("{32CD32}[��� ����� IP]") : (""SERVER"[������]"));
							ShowPlayerDialog(playerid, dSecretpincontrol, DIALOG_STYLE_LIST, !""SERVER"���������� ����������� PIN �����", dialog, !"�������", !"�������");
							return SendErrorMessage(playerid, !"� ��� �� ���������� ����������� PIN ���");
					    }
					    ShowPlayerDialog(playerid, dSecretpinreset, DIALOG_STYLE_INPUT, !""SERVER"�������� ������������ PIN ����{FFFFFF}", !"{FFFFFF}������� ��� ������� ����������� PIN ��� � ���� ����:", !"�������", !"�������");
					}
					case 2:
					{
					    PlayerInfo[playerid][pPin][1] = !PlayerInfo[playerid][pPin][1];
						if(PlayerInfo[playerid][pPin][1] == 0) SendInfoMessage(playerid, !"��� ����������� PIN ��� ������ ����� ������������� ��� ������ ����� IP");
						else SendInfoMessage(playerid, !"��� ����������� PIN ��� ������ ����� ������������� ��� ������ �����");
						static const fmt_query[] = "UPDATE "TABLE_ACCOUNT" SET `pPin` = '%d,%d' WHERE `pID` = '%d'";
						new query[sizeof(fmt_query)+(-2+4)+(-2+1)+(-2+8)];
						format(query, sizeof(query), fmt_query, PlayerInfo[playerid][pPin][0], PlayerInfo[playerid][pPin][1], PlayerInfo[playerid][pID]);
						mysql_tquery(dbHandle, query);
						new dialog[81];
					    format(dialog, sizeof(dialog),
							"���������� PIN ���\n\
							������� PIN ���\n\
							���������� PIN ��� %s",
						(PlayerInfo[playerid][pPin][1] == 0) ? ("{32CD32}[��� ����� IP]") : (""SERVER"[������]"));
						ShowPlayerDialog(playerid, dSecretpincontrol, DIALOG_STYLE_LIST, !""SERVER"���������� ����������� PIN �����", dialog, !"�������", !"�������");
					}
	            }
			}
		}
		case dSecretpinset:
		{
		    if(!str_len) ShowPlayerDialog(playerid, dSecretpinset, DIALOG_STYLE_INPUT, !""SERVER"��������� ������������ PIN ����{FFFFFF}", !"{FFFFFF}������� ��� ������� ����������� PIN ��� � ���� ����:\n\n����������: PIN ��� ������ ���� 4-�� ������� � �� ��������� �� 0", !"���������", !"�������");
		    new regex:rg_secretpincheck = regex_new("^[1-9]{1}[0-9]{3}$");
            if(regex_check(inputtext, rg_secretpincheck))
            {
                PlayerInfo[playerid][pPin][0] = strval(inputtext);
                PlayerInfo[playerid][pPin][1] = 0;
                static const fmt_query[] = "UPDATE "TABLE_ACCOUNT" SET `pPin` = '%d,%d' WHERE `pID` = '%d'";
				new query[sizeof(fmt_query)+(-2+4)+(-2+1)+(-2+8)];
				format(query, sizeof(query), fmt_query, PlayerInfo[playerid][pPin][0], PlayerInfo[playerid][pPin][1], PlayerInfo[playerid][pID]);
				mysql_tquery(dbHandle, query);
				new string[58+(-2+4)];
				format(string, sizeof(string), "��� ����������� PIN ���: "SERVER"%s", inputtext);
				SendInfoMessage(playerid, string);
				SendClientMessage(playerid, COLOR_NOTIFICATION, !"[�����������] {FFFFFF}�������� �������� ������� "SERVER"F8{FFFFFF} ��� �������� ����� ����������� PIN ���");
            }
            else
            {
                ShowPlayerDialog(playerid, dSecretpinset, DIALOG_STYLE_INPUT, !""SERVER"��������� ������������ PIN ����{FFFFFF}", !"{FFFFFF}������� ��� ������� ����������� PIN ��� � ���� ����:\n\n����������: PIN ��� ������ ���� 4-�� ������� � �� ��������� �� 0", !"���������", !"�������");
                regex_delete(rg_secretpincheck);
                return SendErrorMessage(playerid, !"������� ��������� PIN ���");
            }
            regex_delete(rg_secretpincheck);
		}
		case dSecretpinreset:
		{
		    if(response)
	        {
			    if(!str_len) ShowPlayerDialog(playerid, dSecretpinreset, DIALOG_STYLE_INPUT, !""SERVER"�������� ������������ PIN ����{FFFFFF}", !"{FFFFFF}������� ��� ������� ����������� PIN ��� � ���� ����:", !"�������", !"�������");
				if(strval(inputtext) == PlayerInfo[playerid][pPin][0])
				{
				    PlayerInfo[playerid][pPin][0] = 0;
	                PlayerInfo[playerid][pPin][1] = 0;
	                static const fmt_query[] = "UPDATE "TABLE_ACCOUNT" SET `pPin` = '%d,%d' WHERE `pID` = '%d'";
					new query[sizeof(fmt_query)+(-2+4)+(-2+1)+(-2+8)];
					format(query, sizeof(query), fmt_query, PlayerInfo[playerid][pPin][0], PlayerInfo[playerid][pPin][1], PlayerInfo[playerid][pID]);
					mysql_tquery(dbHandle, query);
					SendInfoMessage(playerid, !"��� ����������� PIN ��� �����");
				}
				else
				{
				    ShowPlayerDialog(playerid, dSecretpinreset, DIALOG_STYLE_INPUT, !""SERVER"�������� ������������ PIN ����{FFFFFF}", !"{FFFFFF}������� ��� ������� ����������� PIN ��� � ���� ����:", !"�������", !"�������");
	                return SendErrorMessage(playerid, !"�� ����� ������������ PIN ���");
				}
			}
		}
		case dGoogleauthcontrol:
		{
		    if(response)
	        {
	            switch(listitem)
	            {
					case 0:
					{
					    if(strlen(PlayerInfo[playerid][pGoogleauth]) > 1)
					    {
					        new dialog[120];
						    format(dialog, sizeof(dialog),
								"���������� Google Authenticator\n\
								������� Google Authenticator\n\
								���������� Google Authenticator %s",
							(PlayerInfo[playerid][pGoogleauthsetting] == 0) ? ("{32CD32}[��� ����� IP]") : (""SERVER"[������]"));
							ShowPlayerDialog(playerid, dGoogleauthcontrol, DIALOG_STYLE_LIST, !""SERVER"���������� Google Authenticator", dialog, !"�������", !"�������");
							return SendErrorMessage(playerid, !"� ��� ��� ���������� Google Authenticator");
					    }
						PlayerInfo[playerid][pGoogleauth] = EOS;
						for(new i; i < 16; i++)
						{
						    PlayerInfo[playerid][pGoogleauth][i] = random(25) + 65;
						}
						new dialog[531+(-2+MAX_PLAYER_NAME)+(-2+16)];
					 	format(dialog, sizeof(dialog),
					 		"{FFFFFF}�������� � ���������� ���������� Google Authenticator �� ���� ��������� ����������\n\n\
						 	���� � ��� Android, �� ������� ������ '+' � ������ ������� ���� � �������� \"������ ����\"\n\
						 	���� � ��� IOS, �� ������� ������ '+' � ������ ������� ���� � �������� \"���� �������\"\n\n\
						 	� ���� \"�������\" �������: "SERVER"%s@foundationrp{FFFFFF}\n\
						 	� ���� \"����\" �������: "SERVER"%s{FFFFFF}\n\n\
					 		����� ���������� �������� ������� ������ \"�����\"\n\
						 	������� ���� ������������� �� ��������, ������ ��������� ����, ��� ���������� �� �������",
						pName(playerid),
						PlayerInfo[playerid][pGoogleauth]);
						ShowPlayerDialog(playerid, dGoogleauthinstall, DIALOG_STYLE_MSGBOX, !""SERVER"��������� Google Authenticator{FFFFFF} � ��� ������", dialog, !"�����", "");
					}
					case 1:
					{
					    if(strlen(PlayerInfo[playerid][pGoogleauth]) == 1)
						{
						    new dialog[120];
						    format(dialog, sizeof(dialog),
								"���������� Google Authenticator\n\
								������� Google Authenticator\n\
								���������� Google Authenticator %s",
							(PlayerInfo[playerid][pGoogleauthsetting] == 0) ? ("{32CD32}[��� ����� IP]") : (""SERVER"[������]"));
							ShowPlayerDialog(playerid, dGoogleauthcontrol, DIALOG_STYLE_LIST, !""SERVER"���������� Google Authenticator", dialog, !"�������", !"�������");
							return SendErrorMessage(playerid, !"� ��� �� ���������� Google Authenticator");
						}
						if(PlayerInfo[playerid][pAdmin] != 0)
						{
						    new dialog[120];
						    format(dialog, sizeof(dialog),
								"���������� Google Authenticator\n\
								������� Google Authenticator\n\
								���������� Google Authenticator %s",
							(PlayerInfo[playerid][pGoogleauthsetting] == 0) ? ("{32CD32}[��� ����� IP]") : (""SERVER"[������]"));
							ShowPlayerDialog(playerid, dGoogleauthcontrol, DIALOG_STYLE_LIST, !""SERVER"���������� Google Authenticator", dialog, !"�������", !"�������");
							return SendErrorMessage(playerid, !"��������������� ��������� ������� Google Authenticator");
						}
                        PlayerInfo[playerid][pGoogleauth] = EOS;
                        strcat(PlayerInfo[playerid][pGoogleauth], "0");
                        SendInfoMessage(playerid, !"Google Authenticator �����");
			            static const fmt_query[] = "UPDATE "TABLE_ACCOUNT" SET `pGoogleauth` = '%s' WHERE `pID` = '%d'";
						new query[sizeof(fmt_query)+(-2+16)+(-2+8)];
						format(query, sizeof(query), fmt_query, PlayerInfo[playerid][pGoogleauth], PlayerInfo[playerid][pID]);
						mysql_tquery(dbHandle, query);
					}
					case 2:
					{
					    PlayerInfo[playerid][pGoogleauthsetting] = !PlayerInfo[playerid][pGoogleauthsetting];
						if(PlayerInfo[playerid][pGoogleauthsetting] == 0) SendInfoMessage(playerid, !"��� Google Authenticator ������ ����� ������������� ��� ������ ����� IP");
                        else SendInfoMessage(playerid, !"��� Google Authenticator ��� ������ ����� ������������� ��� ������ �����");
						static const fmt_query[] = "UPDATE "TABLE_ACCOUNT" SET `pGs` = '%d' WHERE `pID` = '%d'";
						new query[sizeof(fmt_query)+(-2+1)+(-2+8)];
						format(query, sizeof(query), fmt_query, PlayerInfo[playerid][pGoogleauthsetting], PlayerInfo[playerid][pID]);
						mysql_tquery(dbHandle, query);
						new dialog[120];
					    format(dialog, sizeof(dialog),
							"���������� Google Authenticator\n\
							������� Google Authenticator\n\
							���������� Google Authenticator %s",
						(PlayerInfo[playerid][pGoogleauthsetting] == 0) ? ("{32CD32}[��� ����� IP]") : (""SERVER"[������]"));
						ShowPlayerDialog(playerid, dGoogleauthcontrol, DIALOG_STYLE_LIST, !""SERVER"���������� Google Authenticator", dialog, !"�������", !"�������");
					}
				}
			}
		}
		case dGoogleauthinstall:
		{
			if(response) ShowPlayerDialog(playerid, dGoogleauthinstallCheck, DIALOG_STYLE_INPUT, !""SERVER"��������� Google Authenticator{FFFFFF} � ��� ������", !"{FFFFFF}��� ���������� ��������� Google Authenticator\n������� ��� �� ���������� � ���� ����:", !"�����", "������");
			else PlayerInfo[playerid][pGoogleauth] = EOS; // Clear
		}
		case dGoogleauthinstallCheck:
		{
		    if(response)
		    {
		        new getcode = GoogleAuthenticatorCode(PlayerInfo[playerid][pGoogleauth], gettime());
		        if(strval(inputtext) == getcode)
		        {
		            SendInfoMessage(playerid, !"Google Authenticator �����������");
		            static const fmt_query[] = "UPDATE "TABLE_ACCOUNT" SET `pGoogleauth` = '%s' WHERE `pID` = '%d'";
					new query[sizeof(fmt_query)+(-2+16)+(-2+8)];
					format(query, sizeof(query), fmt_query, PlayerInfo[playerid][pGoogleauth], PlayerInfo[playerid][pID]);
					mysql_tquery(dbHandle, query);
		        }
		        else
		        {
		            ShowPlayerDialog(playerid, dGoogleauthinstallCheck, DIALOG_STYLE_INPUT, !""SERVER"��������� Google Authenticator{FFFFFF} � ��� ������", !"{FFFFFF}��� ���������� ��������� Google Authenticator\n������� ��� �� ���������� � ���� ����:", !"�����", "������");
		            return SendErrorMessage(playerid, !"��� �� ���������");
		        }
		    }
		    else PlayerInfo[playerid][pGoogleauth] = EOS;
		}
		case dCheckgoogleauth:
		{
		    new getcode = GoogleAuthenticatorCode(PlayerInfo[playerid][pGoogleauth], gettime());
	        if(strval(inputtext) == getcode) PlayerGoLogin(playerid);
	        else
	        {
	            KickEx(playerid);
	            return SendErrorMessage(playerid, !"��� �� ���������");
	        }
		
		}
		case dInformadm:
		{
		    if(response)
		    {
		        switch(listitem)
	            {
					case 0:
					{
					    ShowPlayerDialog(playerid, dReport, DIALOG_STYLE_INPUT, !"{FFFFFF}�������� {e93230}������",
							!"{FFFFFF}����� ���, ��� ���������� ������ �������������, �������������� ��� �� �� ��������� ������������� �������:\n\n\
							\t\t\t{e91432}���������:\n\
							\t\t\t1. �������� ������� (��� ����� ���� ������ \"{FFFFFF}������ {11dd77}������{e91432}\")\n\
							\t\t\t2. ����, ����, �����������, ������.\n\
							\t\t\t3. ������� �� ���� - \"����� �����, ����� ���\"\n\
							\t\t\t4. ������ ���������\n\n\
							{FFFFFF}��� ��������� ������������� ������ ������������� ����� �������� ��� ���������� ��� ����� ����������.\n\
							�������, ��� ���� ������ �� ������������, ������������� ����� ����� �� ��������� ���� ����������� �����",
						!"���������", !"�����");
					}
					case 1:
					{
						ShowPlayerDialog(playerid, dQuestion, DIALOG_STYLE_INPUT, !"{FFFFFF}������{11dd77} ������",
							!"{FFFFFF}����� ���, ��� ���������� ������ �������������, �������������� ��� �� �� ��������� ������������� �������:\n\n\
							\t\t\t{e91432}���������:\n\
							\t\t\t1. ������ ������ (��� ����� ���� ������ \"{FFFFFF}�������� {e93230}������{e91432}\")\n\
							\t\t\t2. ����, ����, �����������, ������.\n\
							\t\t\t3. ������� �� ���� - \"����� �����, ����� ���\"\n\n\
							{FFFFFF}��� ��������� ������������� ������ ������������� ����� �������� ��� ���������� ��� ����� ����������.\n\
							�������, ��� ��� ������ �� ������������, ������������� ����� ����� �� ��������� ���� ����������� ��������",
						!"���������", !"�����");
					}
				}
			}
			else callcmd::menu(playerid);
		}
		case dReport:
		{
		    if(response)
		    {
				if(!str_len)
				{
				    ShowPlayerDialog(playerid, dReport, DIALOG_STYLE_INPUT, !"{FFFFFF}�������� {e93230}������",
						!"{FFFFFF}����� ���, ��� ���������� ������ �������������, �������������� ��� �� �� ��������� ������������� �������:\n\n\
						\t\t\t{e91432}���������:\n\
						\t\t\t1. �������� ������� (��� ����� ���� ������ \"{FFFFFF}������ {11dd77}������{e91432}\")\n\
						\t\t\t2. ����, ����, �����������, ������.\n\
						\t\t\t3. ������� �� ���� - \"����� �����, ����� ���\"\n\
						\t\t\t4. ������ ���������\n\n\
						{FFFFFF}��� ��������� ������������� ������ ������������� ����� �������� ��� ���������� ��� ����� ����������.\n\
						�������, ��� ���� ������ �� ������������, ������������� ����� ����� �� ��������� ���� ����������� �����",
					!"���������", !"�����");
				}
				if(str_len > 97)
				{
				    ShowPlayerDialog(playerid, dReport, DIALOG_STYLE_INPUT, !"{FFFFFF}�������� {e93230}������",
						!"{FFFFFF}����� ���, ��� ���������� ������ �������������, �������������� ��� �� �� ��������� ������������� �������:\n\n\
						\t\t\t{e91432}���������:\n\
						\t\t\t1. �������� ������� (��� ����� ���� ������ \"{FFFFFF}������ {11dd77}������{e91432}\")\n\
						\t\t\t2. ����, ����, �����������, ������.\n\
						\t\t\t3. ������� �� ���� - \"����� �����, ����� ���\"\n\
						\t\t\t4. ������ ���������\n\n\
						{FFFFFF}��� ��������� ������������� ������ ������������� ����� �������� ��� ���������� ��� ����� ����������.\n\
						�������, ��� ���� ������ �� ������������, ������������� ����� ����� �� ��������� ���� ����������� �����",
					!"���������", !"�����");
				    return SendErrorMessage(playerid, !"������� ������� ���������");
				}
				new string[144];
				format(string, sizeof(string), "�� ��������� {e93230}������{FFFFFF}: %s", inputtext);
				SendClientMessage(playerid, -1, string);
				format(string, sizeof(string), "[������]{FFFFFF} %s[%d]: %s", pName(playerid), playerid, inputtext);
				SendAdminMessage(COLOR_LIGHTRED, string);
		    }
		    else ShowPlayerDialog(playerid, dInformadm, DIALOG_STYLE_LIST, !""SERVER"����� � ��������������", !"�������� {e93230}������\n������ {11dd77}������", !"�������", !"�����");
		}
		case dAhelp:
		{
		    if(response)
		    {
		        switch(listitem)
	            {
					case 0:
					{
					    ShowPlayerDialog(playerid, dAhelpCMD, DIALOG_STYLE_MSGBOX, !""SERVER"������� {FFFFFF}������� ������",
							!""SERVER"/admins{FFFFFF} - ���������� ������������� � ����\n\
							"SERVER"/a{FFFFFF} - ��� �������������\n\
							"SERVER"/rep{FFFFFF} - �������� �� ������",
						!"�����", "�������");
					}
					case 1:
					{
					    ShowPlayerDialog(playerid, dAhelpCMD, DIALOG_STYLE_MSGBOX, !""SERVER"������� {FFFFFF}������� ������",
							!"",
						!"�����", "�������");
					}
					case 2:
					{
					    ShowPlayerDialog(playerid, dAhelpCMD, DIALOG_STYLE_MSGBOX, !""SERVER"������� {FFFFFF}�������� ������",
							!""SERVER"/tpcor{FFFFFF} - ������������� �� ����������\n\
							"SERVER"/setint{FFFFFF} - ������������� � id ���������\n\
							"SERVER"/setworld{FFFFFF} - ������������� � id ����. ����\n\
							"SERVER"/goto{FFFFFF} - ����������������� � ������\n\
							"SERVER"/gethere{FFFFFF} - ��������������� ������ � ����\n\
							"SERVER"/plveh{FFFFFF} - ������ ������ ����������",
						!"�����", "�������");
					}
					case 3:
					{
					    ShowPlayerDialog(playerid, dAhelpCMD, DIALOG_STYLE_MSGBOX, !""SERVER"������� {FFFFFF}��������� ������",
							!""SERVER"/setweather{FFFFFF} - ���������� ������ �� �������\n\
							"SERVER"/reginfo{FFFFFF} - �������� ��������������� ������ ������ � ��������",
						!"�����", "�������");
					}
					case 4:
					{
					    ShowPlayerDialog(playerid, dAhelpCMD, DIALOG_STYLE_MSGBOX, !""SERVER"������� {FFFFFF}������ ������",
							!"",
						!"�����", "�������");
					}
					case 5:
					{
					    ShowPlayerDialog(playerid, dAhelpCMD, DIALOG_STYLE_MSGBOX, !""SERVER"������� {FFFFFF}������� ������",
							!""SERVER"/resetadm{FFFFFF} - ����� ��������������\n\
							"SERVER"/resetadmoff{FFFFFF} - ����� �������������� � ��������",
						!"�����", "�������");
					}
				}
			}
		}
		case dAhelpCMD: if(response) callcmd::ahelp(playerid);
		case dQuestion:
		{
		    if(response)
		    {
		        if(!(0 <= str_len <= 97))
				{
				    ShowPlayerDialog(playerid, dQuestion, DIALOG_STYLE_INPUT, !"{FFFFFF}������{11dd77} ������",
						!"{FFFFFF}����� ���, ��� ���������� ������ �������������, �������������� ��� �� �� ��������� ������������� �������:\n\n\
						\t\t\t{e91432}���������:\n\
						\t\t\t1. ������ ������ (��� ����� ���� ������ \"{FFFFFF}�������� {e93230}������{e91432}\")\n\
						\t\t\t2. ����, ����, �����������, ������.\n\
						\t\t\t3. ������� �� ���� - \"����� �����, ����� ���\"\n\n\
						{FFFFFF}��� ��������� ������������� ������ ������������� ����� �������� ��� ���������� ��� ����� ����������.\n\
						�������, ��� ��� ������ �� ������������, ������������� ����� ����� �� ��������� ���� ����������� ��������",
					!"���������", !"�����");
					return SendErrorMessage(playerid, !"������� ������� ���������");
				}
				new string[21+MAX_PLAYER_NAME+97];
				format(string, sizeof(string), "�� ��������� {11dd77}������{FFFFFF}: %s", inputtext);
				SendClientMessage(playerid, -1, string);
				format(string, sizeof(string), "[������]{FFFFFF} %s[%d]: %s", pName(playerid), playerid, inputtext);
				SendAdminMessage(0x11dd77FF, string);
		    }
		    else ShowPlayerDialog(playerid, dInformadm, DIALOG_STYLE_LIST, !""SERVER"����� � ��������������", !"�������� {e93230}������\n������ {11dd77}������", !"�������", !"�����");
		}	
	}
	return true;
}

function: PlayerLogin(playerid)
{
    static rows;
	cache_get_row_count(rows);
	if(rows)
	{
        cache_get_value_name_int(0, !"pID", PlayerInfo[playerid][pID]);
        cache_get_value_name(0, !"pEmail", PlayerInfo[playerid][pEmail], 65);
        cache_get_value_name_int(0, !"pRef", PlayerInfo[playerid][pRef]);
        cache_get_value_name_int(0, !"pRefmoney", PlayerInfo[playerid][pRefmoney]);
        cache_get_value_name_int(0, !"pSex", PlayerInfo[playerid][pSex]);
        cache_get_value_name_int(0, !"pRace", PlayerInfo[playerid][pRace]);
        cache_get_value_name_int(0, !"pAge", PlayerInfo[playerid][pAge]);
        cache_get_value_name_int(0, !"pSkin", PlayerInfo[playerid][pSkin]);
        cache_get_value_name(0, !"pRegdate", PlayerInfo[playerid][pRegdate], 13);
        cache_get_value_name(0, !"pRegip", PlayerInfo[playerid][pRegip], 16);
        cache_get_value_name_int(0, !"pAdmin", PlayerInfo[playerid][pAdmin]);
        cache_get_value_name_int(0, !"pMoney", PlayerInfo[playerid][pMoney]);
        cache_get_value_name_int(0, !"pLvl", PlayerInfo[playerid][pLvl]);
        cache_get_value_name_int(0, !"pExp", PlayerInfo[playerid][pExp]);
        
        if(PlayerInfo[playerid][pRefmoney] != 0)
        {
            SendClientMessage(playerid, COLOR_LIGHTBLUE, !"�� �������� �������������� �� ������������ �� ������ �������.");
            GiveMoney(playerid, PlayerInfo[playerid][pRefmoney]);
            PlayerInfo[playerid][pRefmoney] = 0;
            static const fmt_query[] = "UPDATE "TABLE_ACCOUNT" SET `pRefmoney` = '0' WHERE `pID` = '%d'";
			new query[sizeof(fmt_query)+(-2+8)];
			mysql_format(dbHandle, query, sizeof(query), fmt_query, PlayerInfo[playerid][pID]);
			mysql_tquery(dbHandle, query);
        }
        
        if(PlayerInfo[playerid][pAdmin] > 0) Iter_Add(Admins_ITER, playerid);

		SetSpawnInfo(playerid, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		
		PlayerInfo[playerid][pLogged] = true;
	    TogglePlayerSpectating(playerid, 0);
	} else {
		SendClientMessage(playerid, COLOR_RED, !"��������� �����! � ������ ������ ����� �������� � ��������!");
		SendClientMessage(playerid, COLOR_RED, !"���� ������ ����������� � �� ����� ���������� ��� �������!");
		SendClientMessage(playerid, COLOR_RED, !"������� ����� ��������� ����� (����� 2-5 �����).");
		SendClientMessage(playerid, COLOR_RED, !"�� ������ ���, ����� �������� ��� ������� �� �����!");
		SendClientMessage(playerid, COLOR_RED, !"�� ����������� ��������� �������� (F8) � ���� �������!");
		printf("["SERVER_NAME3"] Error Load Account. %s", PlayerInfo[playerid][pName]);
		return KickEx(playerid);
	}
	return true;
}

function: CheckReferal(playerid, const referal[])
{
	static rows;
	cache_get_row_count(rows);
	if(rows)
	{
	    cache_get_value_name_int(0, !"pID", PlayerInfo[playerid][pRef]);
	    ShowPlayerDialog(playerid, dRegSex, DIALOG_STYLE_MSGBOX, !""SERVER"�����������{FFFFFF} � ����� ���� ���������",
			!"{FFFFFF}�������� ��� ������ ���������:",
		!"�������", !"�������");
	}
	else
	{
	    ShowPlayerDialog(playerid, dRegRef, DIALOG_STYLE_INPUT, !""SERVER"�����������{FFFFFF} � ���� �������������",
			!"{FFFFFF}���� �� ����� �� ������ �� �����������, ��\n\
			������ ������� ��� ������������� � ���� ����:",
		!"�����", !"����������");
        return SendErrorMessage(playerid, !"�������� � ����� ����� �� ����������");
	}
	return true;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return true;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    if(PlayerInfo[playerid][pAdmin] >= 1)
    {
        if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
            SetVehiclePos(GetPlayerVehicleID(playerid), fX, fY, fZ);
            PutPlayerInVehicle(playerid, GetPlayerVehicleID(playerid), 0);
        }
        else SetPlayerPos(playerid, fX, fY, fZ);
    }
    return true;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == GraphicPIN_PTD[playerid][0] || playertextid == GraphicPIN_PTD[playerid][1] || playertextid == GraphicPIN_PTD[playerid][2] || playertextid == GraphicPIN_PTD[playerid][3])
    {
        if(playertextid == GraphicPIN_PTD[playerid][0]) PlayerInfo[playerid][tempENTEREDPIN][GetPVarInt(playerid, "pinpos")] = PlayerInfo[playerid][tempPINCHECK][0];
        else if(playertextid == GraphicPIN_PTD[playerid][1]) PlayerInfo[playerid][tempENTEREDPIN][GetPVarInt(playerid, "pinpos")] = PlayerInfo[playerid][tempPINCHECK][1];
        else if(playertextid == GraphicPIN_PTD[playerid][2]) PlayerInfo[playerid][tempENTEREDPIN][GetPVarInt(playerid, "pinpos")] = PlayerInfo[playerid][tempPINCHECK][2];
        else if(playertextid == GraphicPIN_PTD[playerid][3]) PlayerInfo[playerid][tempENTEREDPIN][GetPVarInt(playerid, "pinpos")] = PlayerInfo[playerid][tempPINCHECK][3];
        PlayerPlaySound(playerid, 4203, 0.0, 0.0, 0.0);
        if(GetPVarInt(playerid, "pinpos") == 3)
		{
		    new truepin[5];
			valstr(truepin, PlayerInfo[playerid][pPin][0]);
			new enteredpin[5];
			format(enteredpin, sizeof(enteredpin), "%d%d%d%d", PlayerInfo[playerid][tempENTEREDPIN][0], PlayerInfo[playerid][tempENTEREDPIN][1], PlayerInfo[playerid][tempENTEREDPIN][2], PlayerInfo[playerid][tempENTEREDPIN][3]);
            for(new i = 0; i < 4; i++)
		    {
		        PlayerTextDrawDestroy(playerid, GraphicPIN_PTD[playerid][i]);
		    }
		    TextDrawHideForPlayer(playerid, GraphicPIN_TD);
		    DeletePVar(playerid, "pinpos");
		    CancelSelectTextDraw(playerid);
			if(strcmp(truepin, enteredpin, false) == 0)
			{
				if(strlen(PlayerInfo[playerid][pGoogleauth]) > 2)
				{
				    if(PlayerInfo[playerid][pGoogleauthsetting] == 0)
					{
						if(CheckSubnet(playerid) == 1) PlayerGoLogin(playerid);
						else ShowPlayerDialog(playerid, dCheckgoogleauth, DIALOG_STYLE_INPUT, !""SERVER"Google Authenticator", !"{FFFFFF}������� ��� �� ���������� Google Authenticator � ���� ����:", !"�����", "");
					}
					else if(PlayerInfo[playerid][pGoogleauthsetting] == 1)
					{
					    ShowPlayerDialog(playerid, dCheckgoogleauth, DIALOG_STYLE_INPUT, !""SERVER"Google Authenticator", !"{FFFFFF}������� ��� �� ���������� Google Authenticator � ���� ����:", !"�����", "");
					}
				}
				else PlayerGoLogin(playerid);
			}
			else
			{
			    SendErrorMessage(playerid, !"�� ����� �������� ����������� PIN ���");
			    return KickEx(playerid);
			}
		}
		else
		{
		    SetPVarInt(playerid, "pinpos", GetPVarInt(playerid, "pinpos")+1);
		    GeneratePinCheck(playerid, GetPVarInt(playerid, "pinpos"));
		}
    }
    return true;
}

public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
    if(!PlayerInfo[playerid][pLogged]) return false;
    if(gettime() <= AntiFloodCommand[playerid])
    {
    	SendClientMessage(playerid, COLOR_GREY, !"�� �������..");
    	return false;
    }
    AntiFloodCommand[playerid] = gettime() + 2;
    return true;
}

stock GiveMoney(playerid, money)
{
	PlayerInfo[playerid][pMoney] += money;
	static const fmt_query[] = "UPDATE "TABLE_ACCOUNT" SET `pMoney` = '%d' WHERE `pID` = '%d'";
	new query[sizeof(fmt_query)+(-2+9)+(-2+8)];
	format(query, sizeof(query), fmt_query, PlayerInfo[playerid][pMoney], PlayerInfo[playerid][pID]);
	mysql_tquery(dbHandle, query);
}

stock ProxDetector(Float:radi, playerid, string[],col1,col2,col3,col4,col5)
{
	new Float:posx, Float:posy, Float:posz, Float:oldposx, Float:oldposy, Float:oldposz, Float:tempposx, Float:tempposy, Float:tempposz;
	GetPlayerPos(playerid, oldposx, oldposy, oldposz);
	foreach(new i: Player)
	{
		if(IsPlayerConnected(i))
		{
		    if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i))
			{
				GetPlayerPos(i, posx, posy, posz);
				tempposx = (oldposx -posx);
				tempposy = (oldposy -posy);
				tempposz = (oldposz -posz);
				if(((tempposx < radi/16) && (tempposx > -radi/16)) && ((tempposy < radi/16) && (tempposy > -radi/16)) && ((tempposz < radi/16) && (tempposz > -radi/16))) SendClientMessage(i, col1, string);
				else if(((tempposx < radi/8) && (tempposx > -radi/8)) && ((tempposy < radi/8) && (tempposy > -radi/8)) && ((tempposz < radi/8) && (tempposz > -radi/8))) SendClientMessage(i, col2, string);
				else if(((tempposx < radi/4) && (tempposx > -radi/4)) && ((tempposy < radi/4) && (tempposy > -radi/4)) && ((tempposz < radi/4) && (tempposz > -radi/4))) SendClientMessage(i, col3, string);
				else if(((tempposx < radi/2) && (tempposx > -radi/2)) && ((tempposy < radi/2) && (tempposy > -radi/2)) && ((tempposz < radi/2) && (tempposz > -radi/2))) SendClientMessage(i, col4, string);
				else if(((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi))) SendClientMessage(i, col5, string);
			}
		}
	}
	return true;
}

stock GiveExp(playerid, exp)
{
	PlayerInfo[playerid][pExp] += exp;
	new needexp = (PlayerInfo[playerid][pLvl]+1)*expmultiply;
    if(PlayerInfo[playerid][pExp] >= needexp)
    {
        PlayerInfo[playerid][pExp]-=needexp;
        PlayerInfo[playerid][pLvl]++;
        SendClientMessage(playerid, -1, !"��� ������� �������");
        if(PlayerInfo[playerid][pLvl] == 3 && PlayerInfo[playerid][pRef] != 0)
        {
            SendClientMessage(playerid, COLOR_BLUE, !"�� �������� �������� ������. �����, ������������ ��� �� ������ ������� ��������������.");
			new newquery[71+(-2+8)];
			format(newquery, sizeof(newquery), "UPDATE "TABLE_ACCOUNT" SET `pRefmoney` =  `pRefmoney` + '5000' WHERE `pID` = '%d'", PlayerInfo[playerid][pRef]);
			mysql_tquery(dbHandle, newquery);
        }
        SetPlayerScore(playerid, PlayerInfo[playerid][pLvl]);
    }
    static const fmt_query[] = "UPDATE "TABLE_ACCOUNT" SET `pLvl` = '%d', `pExp` = '%d' WHERE `pID` = '%d'";
	new query[sizeof(fmt_query)+(-2+10)+(-2+6)+(-2+8)];
	format(query, sizeof(query), fmt_query, PlayerInfo[playerid][pLvl], PlayerInfo[playerid][pExp], PlayerInfo[playerid][pID]);
	mysql_tquery(dbHandle, query);
}

stock ShowStats(playerid, checkadm)
{
    new needexp = (PlayerInfo[playerid][pLvl]+1)*expmultiply;
	new dialog[256];
	format(dialog, sizeof(dialog),
		"{FFFFFF}���:\t\t"SERVER"%s\n\
		{FFFFFF}���:\t\t"SERVER"%s\n\
		{FFFFFF}����:\t\t"SERVER"%s\n\
		{FFFFFF}�������:\t"SERVER"%d ���/���\n\
		{FFFFFF}�������:\t"SERVER"%d\n\
		{FFFFFF}����:\t\t"SERVER"%d/%d\n",
	pName(playerid),
	(PlayerInfo[playerid][pSex] == 1) ? ("�������") : ("�������"),
	PlayerRaces[PlayerInfo[playerid][pRace]-1],
	PlayerInfo[playerid][pAge],
	PlayerInfo[playerid][pLvl],
	PlayerInfo[playerid][pExp],needexp);
	if(checkadm == 0) ShowPlayerDialog(playerid, dStats, DIALOG_STYLE_MSGBOX, !""SERVER"���������� ���������", dialog, !"�����", !"�������");
	else ShowPlayerDialog(playerid, dNone, DIALOG_STYLE_MSGBOX, !""SERVER"���������� ���������", dialog, !"�������", "");
}

stock GetPlayerSubnet(buffer[])
{
    for(new i=0, dots=0; ; ++i)
    {
    	switch(buffer[i])
        {
            case '\0': break;
            case '.':
            {
                if(++dots == 2)
                {
                    buffer[i] = '\0';
                    break;
                }
            }
        }
    }
}

stock IsStringIP(const input_string[]) // By SooBad
{
	new regex:r_str = regex_new("([1-9]{1})([0-9]{0,2})\\.([0-9]{1,3})\\.([0-9|\\*]){1,3}\\.([0-9|\\*]){1,3}");
    new check = regex_check(input_string, r_str);
    regex_delete(r_str);
    return check;
}

stock IsRPNick(const input_string[]) // By SooBad
{
    new regex:r_str = regex_new("([A-Z]{1})([a-z]+)_([A-Z]{1})([a-z]+)");
    new check = regex_check(input_string, r_str);
    regex_delete(r_str);
    return check;
}

stock GeneratePinCheck(playerid, pos)
{
	new pinstr[5];
	valstr(pinstr, PlayerInfo[playerid][pPin][0]);
	new value[2];
    strmid(value, pinstr, pos, pos+1);
    new right = strval(value);
    PlayerInfo[playerid][tempPINCHECK][0] = randomEx(9, right);
    PlayerInfo[playerid][tempPINCHECK][1] = randomEx(9, right, PlayerInfo[playerid][tempPINCHECK][0]);
    PlayerInfo[playerid][tempPINCHECK][2] = randomEx(9, right, PlayerInfo[playerid][tempPINCHECK][0], PlayerInfo[playerid][tempPINCHECK][1]);
    PlayerInfo[playerid][tempPINCHECK][3] = randomEx(9, right, PlayerInfo[playerid][tempPINCHECK][0], PlayerInfo[playerid][tempPINCHECK][1], PlayerInfo[playerid][tempPINCHECK][2]);
    PlayerInfo[playerid][tempPINCHECK][random(4)] = right;
    for(new i = 0; i < 4; i++)
    {
        new buffer[2];
        valstr(buffer, PlayerInfo[playerid][tempPINCHECK][i]);
        PlayerTextDrawSetString(playerid, GraphicPIN_PTD[playerid][i], buffer);
    }
}

function: randomEx(const max_value, ...)
{
    new result;
    rerandom: result = random(max_value + 1);
    for(new i = numargs() + 1; --i != 0;)
        if(result == getarg(i))
            goto rerandom;
    return result;
}


function: CheckBanPlayer(playerid, const name[], days, const reason[], status)
{
	static rows;
	cache_get_row_count(rows);
	if(!rows)
	{
		new id;
		sscanf(name, "u", id);
		if(id == INVALID_PLAYER_ID) ServerBan(name, playerid, reason, days, status);
		else SendErrorMessage(playerid, !"����� ���������! ����������� /ban!");
	}
	else SendInfoMessage(playerid, !"������ ����� ��� ������������!");
	return true;
}

function: UnBanPlayer(playerid, const name[])
{
	static rows;
	cache_get_row_count(rows);
	if(rows)
	{
		static const fmt_query[] = "UPDATE `"TABLE_BANLIST"` SET `status` = '0' WHERE `pName` = '%e' LIMIT 1";
		new query[sizeof(fmt_query)+(-2+16)];
		mysql_format(dbHandle, query, sizeof(query), fmt_query, name);
		mysql_tquery(dbHandle, query);
		format(query, sizeof(query), "������������� %s[%d] ������������� %s", pName(playerid), playerid, name);
		SendAdminMessage(COLOR_TOMATO, query);
	} else SendInfoMessage(playerid, !"������ ������� �� ������������!");
	return true;
}

function: CheckIpBanned(playerid, const ip[], days, const reason[], status)
{
	static rows;
	cache_get_row_count(rows);
	if(!rows) return ServerBanIp(ip, playerid, reason, days, status);
 	else SendInfoMessage(playerid, !"������ IP ����� ��� ������������!");
	return true;
}

function: UnBanIp(playerid, const ip[])
{
	static rows;
	cache_get_row_count(rows);
	if(rows)
	{
		static const fmt_query[] = "UPDATE `"TABLE_BANLISTIP"` SET `status` = '0' WHERE `pIP` = '%e' LIMIT 1";
		new query[sizeof(fmt_query)+(-2+16)];
		mysql_format(dbHandle, query, sizeof(query), fmt_query, ip);
		mysql_tquery(dbHandle, query);
		format(query, sizeof(query), "������������� %s[%d] ������������� IP[%s]!", pName(playerid), playerid, ip);
		SendAdminMessage(COLOR_TOMATO, query);
	} else SendInfoMessage(playerid, !"������ IP ����� �� ������������!");
	return true;
}

function: FindPlayerInTableBanlist(playerid)
{
	static rows;
	cache_get_row_count(rows);
	new hour, minute, string[183+MAX_PLAYER_NAME+MAX_PLAYER_NAME+30+18+18];
	gettime(hour, minute);
 	SetPlayerTime(playerid, hour, minute);
 	InterpolateCameraPos(playerid, -2558.0396, 1335.6434, 12.0365, -2627.4841, 1505.5416, 80.8923, 5000);
	SetPlayerCameraLookAt(playerid, -2627.4841, 1505.5416, 80.8923);
	if(rows)
	{
		new AdmName[MAX_PLAYER_NAME],
			reason[30],
			dateban[11],
			timeban[7],
			dateunban[11],
			timeunban[7],
			timetounban,
			status;
		cache_get_value_name(0, !"pAdmName", AdmName, MAX_PLAYER_NAME);
		cache_get_value_name(0, !"reason", reason, 30);
		cache_get_value_name(0, !"dateban", dateban, 11);
		cache_get_value_name(0, !"timeban", timeban, 7);
		cache_get_value_name(0, !"dateunban", dateunban, 11);
		cache_get_value_name(0, !"timeunban", timeunban, 7);
		cache_get_value_name_int(0, !"timetounban", timetounban);
		cache_get_value_name_int(0, !"status", status);
		if(status == 1) 
		{
			if(gettime() >= timetounban)
			{
				mysql_format(dbHandle, string, sizeof(string), "UPDATE `"TABLE_BANLIST"` SET `status` = '0' WHERE `pName` = '%e' LIMIT 1", pName(playerid));
				mysql_tquery(dbHandle, string);
				mysql_format(dbHandle, string, sizeof(string), "SELECT * FROM `"TABLE_BANLISTIP"` WHERE `pIP` = '%e'", PlayerInfo[playerid][pLastip]);
				mysql_tquery(dbHandle, string, !"FindPlayerInTableBanlistIp", !"d", playerid);
				return true;
			} 
			format(string, sizeof(string), "\
			{FFFFFF}��� ���-����: "SERVER"%s\n\
			{FFFFFF}���-���� ��������������: "SERVER"%s\n\
			{FFFFFF}������� ����������: "SERVER"%s\n\
			{FFFFFF}���� ����������: "SERVER"%s | %s\n\
			{FFFFFF}���� �������������: "SERVER" %s | %s", pName(playerid), AdmName, reason, timeban, dateban, timeunban, dateunban);
			ShowPlayerDialog(playerid, dNone, DIALOG_STYLE_MSGBOX, !"���������� �������� "SERVER"���������", string, !"�����", "");
			return KickEx(playerid);
		} 
		else if(status == 2) 
		{
			format(string, sizeof(string), "\
			{FFFFFF}��� ���-����: "SERVER"%s\n\
			{FFFFFF}���-���� ��������������: "SERVER"%s\n\
			{FFFFFF}������� ����������: "SERVER"%s\n\
			{FFFFFF}���� ����������: "SERVER"%s | %s\n\
			{FFFFFF}���� �������������: "SERVER" �������", pName(playerid), AdmName, reason, timeban, dateban);
			ShowPlayerDialog(playerid, dNone, DIALOG_STYLE_MSGBOX, !"���������� �������� "SERVER"����������", string, !"�����", "");
			return KickEx(playerid);
		}
	} else {
		mysql_format(dbHandle, string, sizeof(string), "SELECT * FROM `"TABLE_BANLISTIP"` WHERE `pIP` = '%e' AND `status` > '0'", PlayerInfo[playerid][pLastip]);
		mysql_tquery(dbHandle, string, !"FindPlayerInTableBanlistIp", !"d", playerid);
	}
	return true;
}

function: FindPlayerInTableBanlistIp(playerid)
{
	static rows;
	new string[183+MAX_PLAYER_NAME+MAX_PLAYER_NAME+30+18+18];
	cache_get_row_count(rows);
	if(rows)
	{
		new AdmName[MAX_PLAYER_NAME],
			reason[30],
			dateban[11],
			timeban[7],
			dateunban[11],
			timeunban[7],
			timetounban,
			status;
		cache_get_value_name(0, !"pAdmName", AdmName, MAX_PLAYER_NAME);
		cache_get_value_name(0, !"reason", reason, 30);
		cache_get_value_name(0, !"dateban", dateban, 11);
		cache_get_value_name(0, !"timeban", timeban, 7);
		cache_get_value_name(0, !"dateunban", dateunban, 11);
		cache_get_value_name(0, !"timeunban", timeunban, 7);
		cache_get_value_name_int(0, !"timetounban", timetounban);
		cache_get_value_name_int(0, !"status", status);
		if(status == 1) 
		{
			if(gettime() >= timetounban)
			{
				mysql_format(dbHandle, string, sizeof(string), "UPDATE `"TABLE_BANLISTIP"` SET `status` = '0' WHERE `pIP` = '%e' LIMIT 1", PlayerInfo[playerid][pLastip]);
				mysql_tquery(dbHandle, string);
				mysql_format(dbHandle, string, sizeof(string), "SELECT `pPassword`, `pSalt`, `pPin`, `pLastip`, `pGoogleauth`, `pGs` FROM "TABLE_ACCOUNT" WHERE `pName` = '%e'", pName(playerid));
				mysql_tquery(dbHandle, string, !"CheckRegistration", !"d", playerid);
				return true;
			}
			format(string, sizeof(string), "\
			{FFFFFF}��� ���-����: "SERVER"%s\n\
			{FFFFFF}���-���� ��������������: "SERVER"%s\n\
			{FFFFFF}������� ����������: "SERVER"%s\n\
			{FFFFFF}���� ����������: "SERVER"%s | %s\n\
			{FFFFFF}���� �������������: "SERVER" %s | %s", pName(playerid), AdmName, reason, timeban, dateban, timeunban, dateunban);
			ShowPlayerDialog(playerid, dNone, DIALOG_STYLE_MSGBOX, !"���������� IP "SERVER"���������", string, !"�����", "");
			return KickEx(playerid);
		} 
		else if(status == 2) 
		{
			format(string, sizeof(string), "\
			{FFFFFF}��� ���-����: "SERVER"%s\n\
			{FFFFFF}���-���� ��������������: "SERVER"%s\n\
			{FFFFFF}������� ����������: "SERVER"%s\n\
			{FFFFFF}���� ����������: "SERVER"%s | %s\n\
			{FFFFFF}���� �������������: "SERVER" �������", pName(playerid), AdmName, reason, timeban, dateban);
			ShowPlayerDialog(playerid, dNone, DIALOG_STYLE_MSGBOX, !"���������� IP "SERVER"����������", string, !"�����", "");
			return KickEx(playerid);
		}
	} else {
		mysql_format(dbHandle, string, sizeof(string), "SELECT `pPassword`, `pSalt`, `pPin`, `pLastip`, `pGoogleauth`, `pGs` FROM "TABLE_ACCOUNT" WHERE `pName` = '%e'", pName(playerid));
		mysql_tquery(dbHandle, string, !"CheckRegistration", !"d", playerid);
	}
	return true;
}


function: CheckRegistration(playerid)
{
	static rows;
	cache_get_row_count(rows);
	if(rows)
	{
	    cache_get_value_name(0, !"pPassword", PlayerInfo[playerid][pPassword], 65);
	    cache_get_value_name(0, !"pSalt", PlayerInfo[playerid][pSalt], 11);
	    new buffer[14];
        cache_get_value_name(0, !"pPin", buffer, 16);
        sscanf(buffer, "p<,>a<i>[2]", PlayerInfo[playerid][pPin]);
        cache_get_value_name(0, !"pLastip", PlayerInfo[playerid][pLastip], 16);
        cache_get_value_name(0, !"pGoogleauth", PlayerInfo[playerid][pGoogleauth], 17);
        cache_get_value_name_int(0, !"pGs", PlayerInfo[playerid][pGoogleauthsetting]);
		ShowLogin(playerid);
	}
	else ShowRegistration(playerid);
	return true;
}

stock CheckSubnet(playerid)
{
    new nowip[16], oldip[16];
	GetPlayerIp(playerid, nowip, sizeof(nowip));
	GetPlayerSubnet(nowip);
	strmid(oldip, PlayerInfo[playerid][pLastip], 0, 16, 16);
	GetPlayerSubnet(oldip);
	if(strcmp(nowip, oldip, true) == 0) return true;
	else return false;
}

stock PlayerGoLogin(playerid)
{
    static const fmt_query[] = "SELECT * FROM "TABLE_ACCOUNT" WHERE `pName` = '%e' AND `pPassword` = '%e'";
    new query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)+(-2+64)];
	mysql_format(dbHandle, query, sizeof(query), fmt_query, pName(playerid), PlayerInfo[playerid][pPassword]);
	mysql_tquery(dbHandle, query, "PlayerLogin", "i", playerid);
}

stock SendAdminMessage(color, text[])
{
	foreach(new i: Admins_ITER) SendClientMessage(i, color, text);
}

stock ServerBan(const name[], playerid, const reason[], days, status = 1)
{
	static const fmt_str[] = "INSERT INTO `"TABLE_BANLIST"` (`pName`, `pAdmName`, `reason`, `dateban`, `timeban`, `dateunban`, `timeunban`, `timetounban`, `status`) VALUES ('%e', '%e', '%e', '%d-%02d-%02d', '%02d:%02d', '%d-%02d-%02d', '%02d:%02d', '%d', '%d')";
	new string[sizeof(fmt_str)+(2+MAX_PLAYER_NAME)+(-2+MAX_PLAYER_NAME)+(-2+30)+(-10+11)+(-8+6)+(-10+11)+(-8+6)+(-2+8)+(-2+1)],
		_year[2],
		_month[2],
		_day[2],
		_hour[2],
		_minute[2],
		timebanned = gettime() + (days * 86400);
	getdate(_year[0], _month[0], _day[0]);
	gettime(_hour[0], _minute[0], _);
	gmtime(timebanned, _year[1], _month[1], _day[1], _hour[1], _minute[1]);
	mysql_format(dbHandle, string, sizeof(string), fmt_str, name, pName(playerid), reason, _year[0], _month[0], _day[0], _hour[0], _minute[0],_year[1], _month[1], _day[1], _hour[1], _minute[1], timebanned, status);
	mysql_tquery(dbHandle, string);
	if(status == 1) format(string, sizeof(string), "������������� %s[%d] ������������ %s �� %d ����. �������: %s", pName(playerid), playerid, name, days, reason);
	else format(string, sizeof(string), "������������� %s[%d] �������� ������������ %s. �������: %s", pName(playerid), playerid, name, reason);
	SendAdminMessage(COLOR_TOMATO, string);
	return true;
}

stock ServerBanIp(const ip[], playerid, const reason[], days, status)
{
	foreach(new i:Player) if(strcmp(PlayerInfo[i][pLastip], ip, true) == 0) KickEx(i);
	static const fmt_str[] = "INSERT INTO `"TABLE_BANLISTIP"` (`pIP`, `pAdmName`, `reason`, `dateban`, `timeban`, `dateunban`, `timeunban`, `timetounban`, `status`) VALUES ('%e', '%e', '%e', '%d-%02d-%02d', '%02d:%02d', '%d-%02d-%02d', '%02d:%02d', '%d', '%d')";
	new string[sizeof(fmt_str)+(2+16)+(-2+MAX_PLAYER_NAME)+(-2+30)+(-10+11)+(-8+6)+(-10+11)+(-8+6)+(-2+8)+(-2+1)],
		_year[2],
		_month[2],
		_day[2],
		_hour[2],
		_minute[2],
		timebanned = gettime() + (days * 86400);
	getdate(_year[0], _month[0], _day[0]);
	gettime(_hour[0], _minute[0], _);
	gmtime(timebanned, _year[1], _month[1], _day[1], _hour[1], _minute[1]);
	mysql_format(dbHandle, string, sizeof(string), fmt_str, ip, pName(playerid), reason, _year[0], _month[0], _day[0], _hour[0], _minute[0],_year[1], _month[1], _day[1], _hour[1], _minute[1], timebanned, status);
	mysql_tquery(dbHandle, string);
	if(status == 1) format(string, sizeof(string), "������������� %s[%d] ������������ IP[%s] �� %d ����. �������: %s", pName(playerid), playerid, ip, days, reason);
	else format(string, sizeof(string), "������������� %s[%d] �������� ������������ IP[%s]", pName(playerid), playerid, ip);
	SendAdminMessage(COLOR_TOMATO, string);
	return true;
}

stock UpdatePlayerData(playerid, const fields[], data)
{
	static const fmt_str[] = "UPDATE `"TABLE_ACCOUNT"` SET `%s` = '%d' WHERE `pID` = '%d' LIMIT 1";
	new query[sizeof(fmt_str)+(-2+10)+(-2+11)+(-2+8)];
	mysql_format(dbHandle, query, sizeof(query), fmt_str, fields, data, PlayerInfo[playerid][pID]);
	mysql_tquery(dbHandle, query);
	return true;
}

stock UpdatePlayerDataEx(playerid, const fields[], data)
{
	static const fmt_str[] = "UPDATE `"TABLE_ACCOUNT"` SET `%s` = '%s' WHERE `pID` = '%d' LIMIT 1";
	new query[sizeof(fmt_str)+(-2+10)+(-2+30)+(-2+8)];
	mysql_format(dbHandle, query, sizeof(query), fmt_str, fields, data, PlayerInfo[playerid][pID]);
	mysql_tquery(dbHandle, query);
	return true;
}

stock UpdatePlayerDataFloat(playerid, const fields[], data)
{
	static const fmt_str[] = "UPDATE `"TABLE_ACCOUNT"` SET `%s` = '%0.2f' WHERE `pID` = '%d' LIMIT 1";
	new query[sizeof(fmt_str)+(-2+10)+(-2+30)+(-2+8)];
	mysql_format(dbHandle, query, sizeof(query), fmt_str, fields, data, PlayerInfo[playerid][pID]);
	mysql_tquery(dbHandle, query);
	return true;
}

//=====================================================   ������� ������   =====================================================
CMD:ahelp(playerid)
{
    if(PlayerInfo[playerid][pAdmin] < 1) return true;
	new dialog[97];
	format(dialog, sizeof(dialog),
		"������ �������%s%s%s%s%s",
    (PlayerInfo[playerid][pAdmin] >= 2) ? ("\n������ �������") : (""),
    (PlayerInfo[playerid][pAdmin] >= 3) ? ("\n������ �������") : (""),
    (PlayerInfo[playerid][pAdmin] >= 4) ? ("\n�������� �������") : (""),
    (PlayerInfo[playerid][pAdmin] >= 5) ? ("\n����� �������") : (""),
    (PlayerInfo[playerid][pAdmin] >= 6) ? ("\n������ �������") : (""));
	return ShowPlayerDialog(playerid, dAhelp, DIALOG_STYLE_LIST, !""SERVER"������� ��������������", dialog, !"�������", !"�������");
}

CMD:rep(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1) return true;
	if(sscanf(params, "ds[62]", params[0], params[1])) return SendClientMessage(playerid, COLOR_GREY, !"����������� /rep [id ������] [�����]");
	if(!PlayerInfo[playerid][pLogged]) return SendClientMessage(playerid, COLOR_GREY, !"����� �� �����������");
	new string[144];
	format(string, sizeof(string), "������������� %s[%d] ������� ���:{FFFFFF} %s", pName(playerid), playerid, params[1]);
	SendClientMessage(playerid, COLOR_LIGHTRED, string);
	format(string, sizeof(string), "[REPORT] %s[%d] ��� %s[%d]:{FFFFFF} %s", pName(playerid), playerid, pName(params[0]), params[0], params[1]);
	SendAdminMessage(COLOR_TOMATO, string);
	return true;
}
CMD:tpcor(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 3) return true;
	new Float:tpX, Float:tpY, Float:tpZ;
	if(sscanf(params, "fff", tpX, tpY, tpZ)) return SendClientMessage(playerid, COLOR_GREY, !"����������� /tpcor [x] [y] [z]");
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        SetVehiclePos(GetPlayerVehicleID(playerid), tpX, tpY, tpZ);
        PutPlayerInVehicle(playerid, GetPlayerVehicleID(playerid), 0);
    }
    else SetPlayerPos(playerid, tpX, tpY, tpZ);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerInterior(playerid, 0);
	return true;
}
CMD:setworld(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 3) return true;
    if(sscanf(params, "dd", params[0], params[1])) return SendClientMessage(playerid, COLOR_GREY, !"����������� /setworld [id ������] [id ����. ����]");
    if(!PlayerInfo[playerid][pLogged]) return SendClientMessage(playerid, COLOR_GREY, !"����� �� �����������");
    if(params[1] < 0 || params[1] > 999) return SendClientMessage(playerid, COLOR_GREY, !"������� id ����. ���� �� 0 �� 999");
    SetPlayerVirtualWorld(params[0], params[1]);
    new string[59+(-2+MAX_PLAYER_NAME)+(-2+3)+(-2+3)];
    format(string, sizeof(string), "�� ��������������� ������ %s[%d] � ����������� ��� � ID %d", pName(params[0]), params[0], params[1]);
	return SendClientMessage(playerid, -1, string);
}
CMD:setint(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 3) return true;
    if(sscanf(params, "dd", params[0], params[1])) return SendClientMessage(playerid, COLOR_GREY, !"����������� /setint [id ������] [id ���������]");
    if(!PlayerInfo[playerid][pLogged]) return SendClientMessage(playerid, COLOR_GREY, !"����� �� �����������");
    if(params[1] < 0 || params[1] > 50) return SendClientMessage(playerid, COLOR_GREY, !"������� id ��������� �� 0 �� 50");
    SetPlayerInterior(params[0], params[1]);
    new string[52+(-2+MAX_PLAYER_NAME)+(-2+3)+(-2+2)];
    format(string, sizeof(string), "�� ��������������� ������ %s[%d] � �������� � ID %d", pName(params[0]), params[0], params[1]);
	return SendClientMessage(playerid, -1, string);
}
CMD:a(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 1) return true;
    if(sscanf(params, "s[104]", params[0])) return SendClientMessage(playerid, COLOR_GREY, !"����������� /a [���������]");
    if(strlen(params[0]) > 104) return SendClientMessage(playerid, COLOR_GREY, !"������� ������� ���������");
    new string[144];
	format(string, sizeof(string), "[A-���] %s[%d]: %s", pName(playerid), playerid, params[0]);
    SendAdminMessage(COLOR_TOMATO, string);
	return true;
}
CMD:admins(playerid)
{
    if(PlayerInfo[playerid][pAdmin] < 1) return true;
    new dialog[1536] = "{FFFFFF}";
    foreach(new i: Admins_ITER)
	{
	    format(dialog, sizeof(dialog), "%s%s[%d] [%d adm lvl]%s\n", dialog, pName(i), i, PlayerInfo[i][pAdmin], (PlayerAFK[i] >= 2) ? (" {FF0000}AFK{FFFFFF}") : (""));
	}
	return ShowPlayerDialog(playerid, dNone, DIALOG_STYLE_MSGBOX, !""SERVER"������������� � ����", dialog, "�������", "");
}
CMD:goto(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 3) return true;
    if(sscanf(params, "d", params[0])) return SendClientMessage(playerid, COLOR_GREY, !"����������� /goto [id ������]");
    if(!PlayerInfo[playerid][pLogged]) return SendClientMessage(playerid, COLOR_GREY, !"����� �� �����������");
    if(params[0] == playerid) return SendClientMessage(playerid, COLOR_GREY, !"�� �� ������ ���� ���������������");
    new Float:x, Float:y, Float:z;
    GetPlayerPos(params[0], x, y, z);
    new vw = GetPlayerVirtualWorld(params[0]);
    new int = GetPlayerInterior(params[0]);
    SetPlayerPos(playerid, x+1.0, y+1.0, z);
    SetPlayerVirtualWorld(playerid, vw);
    SetPlayerInterior(playerid, int);
	return true;
}
CMD:gethere(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 3) return true;
    if(sscanf(params, "d", params[0])) return SendClientMessage(playerid, COLOR_GREY, !"����������� /gethere [id ������]");
    if(!PlayerInfo[playerid][pLogged]) return SendClientMessage(playerid, COLOR_GREY, !"����� �� �����������");
    if(params[0] == playerid) return SendClientMessage(playerid, COLOR_GREY, !"�� �� ������ ���� ���������������");
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    new vw = GetPlayerVirtualWorld(playerid);
    new int = GetPlayerInterior(playerid);
    SetPlayerPos(params[0], x+1.0, y+1.0, z);
    SetPlayerVirtualWorld(params[0], vw);
    SetPlayerInterior(params[0], int);
	new string[47+(-2+MAX_PLAYER_NAME)+(-2+3)];
	format(string, sizeof(string), "��� �������������� � ���� ������������� %s[%d]", pName(playerid), playerid);
	return SendClientMessage(params[0], -1, string);
}
CMD:setweather(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 4) return true;
    if(sscanf(params, "d", params[0])) return SendClientMessage(playerid, COLOR_GREY, !"����������� /setweather [id ������ (0-45)]");
	if(!(0 <= params[0] <= 45)) return SendClientMessage(playerid, COLOR_GREY, !"����������� id ������ �� 0 �� 45");
 	SetWeather(params[0]);
	new string[54+(-2+2)+(-2+MAX_PLAYER_NAME)+(-2+3)];
	format(string, sizeof(string), "[A] ������ � id:%d ����������� ��������������� %s[%d]", params[0], pName(playerid), playerid);
	SendAdminMessage(COLOR_TOMATO, string);
	return true;
}
CMD:reginfo(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 3) return true;
    if(sscanf(params, "d", params[0])) return SendClientMessage(playerid, COLOR_GREY, !"����������� /reginfo [id ������]");
    if(!PlayerInfo[playerid][pLogged]) return SendClientMessage(playerid, COLOR_GREY, !"����� �� �����������");

	new regcountry[20], regcity[30], regprovider[30];
    GetIPCountry(PlayerInfo[params[0]][pRegip], regcountry);
	GetIPCity(PlayerInfo[params[0]][pRegip], regcity);
	GetIPISP(PlayerInfo[params[0]][pRegip], regprovider);
	new nowcountry[20], nowcity[30], nowprovider[30];
	GetPlayerCountry(params[0], nowcountry);
	GetPlayerCity(params[0], nowcity);
	GetPlayerISP(params[0], nowprovider);
	new nowip[16];
 	GetPlayerIp(playerid, nowip, sizeof(nowip));
    
	new dialog[512];
	format(dialog, sizeof(dialog),
	"{FFFFFF}�������� ������: "SERVER"%s[%d]{FFFFFF}\n\n\
	���� ��� �����������: %s\n\
	IP ��� �����������: %s\n\
	������ ��� �����������: %s\n\
	����� ��� �����������: %s\n\
	��������� ��� �����������: %s\n\n\
	������� IP: %s\n\
	������� ������: %s\n\
	������� �����: %s\n\
	������� ���������: %s",
	pName(params[0]), params[0],
	PlayerInfo[params[0]][pRegdate],
	PlayerInfo[params[0]][pRegip],
	regcountry,
	regcity,
	regprovider,
	nowip,
	nowcountry,
	nowcity,
	nowprovider);
	return ShowPlayerDialog(playerid, dNone, DIALOG_STYLE_MSGBOX, !""SERVER"��������� ��������������� ������ � ��������", dialog, !"�������", "");
}

CMD:plveh(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < 3) return true;
    if(sscanf(params, "dddd", params[0], params[1], params[2], params[3])) return SendClientMessage(playerid, COLOR_GREY, !"����������� /plveh [id ������] [id ����] [id ������� �����] [id ������� �����]");
    if(!PlayerInfo[playerid][pLogged]) return SendClientMessage(playerid, COLOR_GREY, !"����� �� �����������");
    if(GetPlayerInterior(params[0]) != 0) return SendClientMessage(playerid, COLOR_GREY, !"����� �� ������ ���������� � ���������");
    if(!(400 <= params[1] <= 611)) return SendClientMessage(playerid, COLOR_GREY, !"ID ���������� ������ ���� �� 400 �� 611");
    if(!(0 <= params[2] <= 255)) return SendClientMessage(playerid, COLOR_GREY, !"ID ������� ����� ������ ���� �� 0 �� 255");
    if(!(0 <= params[3] <= 255)) return SendClientMessage(playerid, COLOR_GREY, !"ID ������� ����� ������ ���� �� 0 �� 255");
    new Float:x, Float:y, Float:z;
    GetPlayerPos(params[0], x, y, z);
    new Float:Angle;
	GetPlayerFacingAngle(playerid, Angle);
    PlayerInfo[params[0]][pInAdmCar] = CreateVehicle(params[1], x, y, z, Angle, params[2], params[3], -1);
	PutPlayerInVehicle(params[0], PlayerInfo[params[0]][pInAdmCar], 0);
	return true;
}

CMD:skin(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 1) return true;
	if(sscanf(params, "d", params[0])) return SendInfoMessage(playerid, !"����������� /skin [id �����]");
	if(!(1 <= params[0] <= 311)) return SendErrorMessage(playerid, !"�� 1 �� 311.");
	if(params[0] == 74) return SendErrorMessage(playerid, !"����������� ����!");
	SetPlayerSkin(playerid, params[0]);
	return SendGoodMessage(playerid, !"�� ��������� ���� ������������ ����!");
}

CMD:ban(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 4) return true;
	if(sscanf(params, "uds[30]", params[0], params[1], params[2])) return SendInfoMessage(playerid, !"����������� /ban [id ������] [���-�� ����] [�������]");
	if(params[0] == INVALID_PLAYER_ID) return SendErrorMessage(playerid, !"����� �� ��������� ����������� /offban!");
	if(!(1 <= params[1] <= 30)) return SendInfoMessage(playerid, !"���-�� ���� �� 1 �� 30!");
	ServerBan(pName(params[0]), playerid, params[2], params[1], 1);
	return KickEx(params[0]);
}

CMD:iban(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 5) return true;
	if(sscanf(params, "us[30]", params[0], params[1])) return SendInfoMessage(playerid, !"����������� /iban [id ������] [�������]");
	if(params[0] == INVALID_PLAYER_ID) return SendErrorMessage(playerid, !"����� �� ��������� ����������� /offban!");
	ServerBan(pName(params[0]), playerid, params[1], 1, 2);
	return KickEx(params[0]);
}

CMD:offban(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 5) return true;
	new name[MAX_PLAYER_NAME], days, reason[30];
	if(sscanf(params, "s[20]ds[30]", name, days, reason)) return SendInfoMessage(playerid, !"����������� /offban [��� ������] [���-�� ����] [�������]");
	static const fmt_query[] = "SELECT * FROM `"TABLE_BANLIST"` WHERE `pName` = '%e' LIMIT 1";
	new query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)];
	mysql_format(dbHandle, query, sizeof(query), fmt_query, name);
	mysql_tquery(dbHandle, query, !"CheckBanPlayer", !"dsdsd", playerid, name, days, reason, 1);
	return true;
}

CMD:banip(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 5) return true;
	if(sscanf(params, "uds[30]", params[0], params[1], params[2])) return SendInfoMessage(playerid, !"����������� /banip [id ������] [���-�� ����] [�������]");
	if(params[0] == INVALID_PLAYER_ID) return SendErrorMessage(playerid, !"����� �� ��������� ����������� /offbanip [ip]");
	if(!(1 <= params[1] <= 30)) return SendErrorMessage(playerid, !"�� 1 �� 30 ����.");
	return ServerBanIp(PlayerInfo[params[0]][pLastip], playerid, params[2], params[1], 1);
}

CMD:offbanip(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 5) return true;
	new ip[16], days, reason[30];
	if(sscanf(params, "s[16]ds[30]", ip, days, reason)) return SendInfoMessage(playerid, !"����������� /offbanip [ip] [���-�� ����] [�������]");
	if(IsStringIP(ip) == 0) return SendErrorMessage(playerid, !"������� ����� IP �����!");
	if(!(1 <= days <= 30)) return SendInfoMessage(playerid, !"�� 1 �� 30 ����!");
	static const fmt_query[] = "SELECT * FROM `"TABLE_BANLISTIP"` WHERE `pIP` = '%e' LIMIT 1";
	new query[sizeof(fmt_query)+(-2+16)];
	mysql_format(dbHandle, query, sizeof(query), fmt_query, params[0]);
	mysql_tquery(dbHandle, query, !"CheckIpBanned", !"dsdsd", playerid, ip, days, reason, 1);
	return true;
}

CMD:ibanip(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 6) return true;
	new ip[16];
	if(sscanf(params, "s[16]", ip)) return SendInfoMessage(playerid, !"����������� /ibanip [ip]");
	if(!IsStringIP(ip)) return SendErrorMessage(playerid, !"������� ����� IP �����!");
	static const fmt_query[] = "SELECT * FROM `"TABLE_BANLISTIP"` WHERE `pIP` = '%e' LIMIT 1";
	new query[sizeof(fmt_query)+(-2+16)];
	mysql_format(dbHandle, query, sizeof(query), fmt_query, params[0]);
	mysql_tquery(dbHandle, query, !"CheckIpBanned", !"dsdsd", playerid, ip, 1, "None", 2);
	return true;
}

CMD:unbanip(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 6) return true;
	new ip[16];
	if(sscanf(params, "s[16]", ip)) return SendInfoMessage(playerid, !"����������� /unbanip [ip]");
	if(!IsStringIP(ip)) return SendErrorMessage(playerid, !"������� ������ IP �����!");
	static const fmt_query[] = "SELECT * FROM `"TABLE_BANLISTIP"` WHERE `pIP` = '%e' AND `status` > '0' LIMIT 1";
	new query[sizeof(fmt_query)+(-2+16)];
	mysql_format(dbHandle, query, sizeof(query), fmt_query, ip);
	mysql_tquery(dbHandle, query, !"UnBanIp", !"ds", playerid, ip);
	return true;
}

CMD:unban(playerid, params[])
{
	if(PlayerInfo[playerid][pAdmin] < 5) return true;
	new name[MAX_PLAYER_NAME];
	if(sscanf(params, "s[20]", name)) return SendInfoMessage(playerid, !"����������� /unban [��� ������]");
	static const fmt_query[] = "SELECT * FROM `"TABLE_BANLIST"` WHERE `pName` = '%e' AND `status` > '0' LIMIT 1";
	new query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)];
	mysql_format(dbHandle, query, sizeof(query), fmt_query, name);
	mysql_tquery(dbHandle, query, !"UnBanPlayer", !"ds", playerid, name);
	return true;
}
//==============================================================================================================================

//=====================================================   ������� ������   =====================================================
CMD:me(playerid, params[])
{
	if(sscanf(params, "s[118]", params[0])) return SendClientMessage(playerid, COLOR_GREY, !"����������� /me [�����]");
	new string[144];
	format(string, sizeof(string), "%s %s", pName(playerid), params[0]);
	SetPlayerChatBubble(playerid, params[0], 0xDE92FFFF, 20, 7500);
	return ProxDetector(20.0, playerid, string, 0xDE92FFFF, 0xDE92FFFF, 0xDE92FFFF, 0xDE92FFFF, 0xDE92FFFF);
}
CMD:ame(playerid, params[])
{
	if(sscanf(params, "s[144]", params[0])) return SendClientMessage(playerid, COLOR_GREY, !"����������� /ame [�����]");
	SetPlayerChatBubble(playerid, params[0], 0xDE92FFFF, 20, 7500);
	return true;
}

CMD:do(playerid, params[])
{
	if(sscanf(params, "s[116]", params[0])) return SendClientMessage(playerid, COLOR_GREY, !"����������� /do [�����]");
	new string[144];
	format(string, sizeof(string), "%s (%s)", params[0], pName(playerid));
	SetPlayerChatBubble(playerid, params[0], 0xDE92FFFF, 20, 7500);
	return ProxDetector(20.0, playerid, string, 0xDE92FFFF, 0xDE92FFFF, 0xDE92FFFF, 0xDE92FFFF, 0xDE92FFFF);
}

CMD:try(playerid, params[])
{
	if(sscanf(params, "s[99]", params[0])) return SendClientMessage(playerid, COLOR_GREY, !"����������� /try [�����]");
	new string[144];
	format(string, sizeof(string), "%s %s | %s", pName(playerid), params[0], (!random(2)) ? ("{FF0000}��������") : ("{32CD32}������"));
	return ProxDetector(20.0, playerid, string, 0xDE92FFFF, 0xDE92FFFF, 0xDE92FFFF, 0xDE92FFFF, 0xDE92FFFF);
}

CMD:todo(playerid, params[])
{
    if(strlen(params) > 95) return SendClientMessage(playerid, COLOR_GREY, !"������� ������� ����� � ��������");
    new message[48], action[49];
	if(sscanf(params, "p<*>s[47]s[48]", message, action)) return SendClientMessage(playerid, COLOR_GREY, !"����������� /todo [�����*��������]");
	if(strlen(message) < 2 || strlen(action) < 2) return SendClientMessage(playerid, COLOR_GREY, !"����������� /todo [�����*��������]");
	new string[144];
	format(string, sizeof(string), "- '%s' - {DE92FF}������%s %s, %s", message, (PlayerInfo[playerid][pSex] == 1) ? ("") : ("�"), pName(playerid), action);
	return ProxDetector(20.0, playerid, string, -1, -1, -1, -1, -1);
}

CMD:n(playerid, params[])
{
    if(sscanf(params, "s[107]", params[0])) return SendClientMessage(playerid, COLOR_GREY, !"����������� /n [���������]");
    new string[144];
    format(string, sizeof(string), "(( %s[%d]: %s ))", pName(playerid), playerid, params[0]);
	return ProxDetector(20.0, playerid, string, 0xCCCC99FF, 0xCCCC99FF, 0xCCCC99FF, 0xCCCC99FF, 0xCCCC99FF);
}

CMD:s(playerid, params[])
{
	if(sscanf(params, "s[105]", params[0])) return SendClientMessage(playerid, COLOR_GREY, !"����������� /s [�����]");
	new string[144];
    format(string, sizeof(string), "%s[%d] �������: %s", pName(playerid), playerid, params[0]);
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) ApplyAnimation(playerid, !"ON_LOOKERS", !"shout_01", 4.1,0,0,0,0,0);
	SetPlayerChatBubble(playerid, params[0], -1, 25, 7500);
	return ProxDetector(30.0, playerid, string, -1, -1, -1, -1, -1);
}

CMD:menu(playerid)
{
	ShowPlayerDialog(playerid, dMainMenu, DIALOG_STYLE_LIST, !""SERVER"������� ����",
	!""SERVER"[1]{FFFFFF} ���������� ���������\n\
	"SERVER"[2]{FFFFFF} ��������� ������������\n\
	"SERVER"[3]{FFFFFF} ����� � ��������������",
	!"�������", !"�������");
	return true;
}
alias:menu("mn", "mm", "mainmenu");

CMD:myreferals(playerid)
{
    static const fmt_query[] = "SELECT `pName`, `pLvl` FROM "TABLE_ACCOUNT" WHERE `pRef` = '%d'";
	new query[sizeof(fmt_query)+(-2+8)];
	mysql_format(dbHandle, query, sizeof(query), fmt_query, PlayerInfo[playerid][pID]);
	mysql_tquery(dbHandle, query, !"FindMyReferals", "i", playerid);
	return true;
}

function: FindMyReferals(playerid)
{
    static rows;
	cache_get_row_count(rows);
	if(rows)
	{
	    new dialog[2048] = !"�������\t�������", refname[MAX_PLAYER_NAME], reflvl;
	    for(new i = 0; i < rows; i++)
	    {
	        cache_get_value_name(i, !"pName", refname, MAX_PLAYER_NAME);
	        cache_get_value_name_int(i, !"pName", reflvl);
			format(dialog, sizeof(dialog), "%s\n%s\t%d", dialog, refname, reflvl);
	    }
	    ShowPlayerDialog(playerid, dNone, DIALOG_STYLE_TABLIST_HEADERS, !""SERVER"���� ��������", dialog, !"�������", "");
	}
	else ShowPlayerDialog(playerid, dNone, DIALOG_STYLE_MSGBOX, !""SERVER"���� ��������", "{FFFFFF}� ��� ��� ���������", !"�������", "");
	return true;
}
//==============================================================================================================================
