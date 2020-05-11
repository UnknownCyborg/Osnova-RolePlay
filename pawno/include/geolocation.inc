#if defined _player_geolocation_included
	#endinput
#endif
#define _player_geolocation_included

#if !defined _samp_included
	#error Please include <a_samp> first.
#endif

#if !defined sscanf
	#error Please include <sscanf2> first.
#endif

#define GEO_IP_INFO_DETECT_URL 			"ip-api.com/csv/"
#define GEO_IP_INFO_DETECT_URL_FIELDS	"?fields=131793"

#define GEO_MAX_IP_LENGTH 				16
#define GEO_MAX_COUNTRY_NAME_LENGTH 	32
#define GEO_MAX_CITY_NAME_LENGTH		32
#define GEO_MAX_LAT_LON_LENGTH 			12
#define GEO_MAX_PROVIDER_NAME_LENGTH	32
#define GEO_MAX_PROXY_LENGTH			6

enum e_PLAYER_GEO_INFORMATION
{
	player_ip[GEO_MAX_IP_LENGTH + 1],
	player_country[GEO_MAX_COUNTRY_NAME_LENGTH + 1],
	player_city[GEO_MAX_CITY_NAME_LENGTH + 1],
	player_lat[GEO_MAX_LAT_LON_LENGTH + 1],
	player_lon[GEO_MAX_LAT_LON_LENGTH + 1],
	player_provider[GEO_MAX_PROVIDER_NAME_LENGTH + 1],
	player_proxy[GEO_MAX_PROXY_LENGTH + 1]
};
new
	player_geoInfo[MAX_PLAYERS][e_PLAYER_GEO_INFORMATION];

#define GetPlayerCountry(%0)		player_geoInfo[%0][player_country]
#define GetPlayerCity(%0)			player_geoInfo[%0][player_city]
#define GetPlayerLatitude(%0)		player_geoInfo[%0][player_lat]
#define GetPlayerLongtitude(%0)		player_geoInfo[%0][player_lon]
#define GetPlayerProvider(%0)		player_geoInfo[%0][player_provider]
#define GetPlayerProxyStatus(%0)	player_geoInfo[%0][player_proxy]

public OnPlayerConnect(playerid)
{
    GetPlayerIp(playerid, player_geoInfo[playerid][player_ip], GEO_MAX_IP_LENGTH);

	new 
		request[31 - 2 + GEO_MAX_IP_LENGTH];

	strcat(request, GEO_IP_INFO_DETECT_URL);
	strcat(request, player_geoInfo[playerid][player_ip]);
	strcat(request, GEO_IP_INFO_DETECT_URL_FIELDS);

	HTTP(playerid, HTTP_GET, request, "", "p_geo_OnInformationRequested");

#if defined p_geo_OnPlayerConnect
    p_geo_OnPlayerConnect(playerid);
#endif
    return 1;
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect p_geo_OnPlayerConnect
#if defined p_geo_OnPlayerConnect
forward p_geo_OnPlayerConnect(playerid);
#endif

forward p_geo_OnInformationRequested(playerid, response_code, data[]);
public p_geo_OnInformationRequested(playerid, response_code, data[])
{
	if(response_code == 200)
	{
        sscanf(data, "p<,>s[32]s[32]s[12]s[12]s[32]s[6]",
        	player_geoInfo[playerid][player_country],
        	player_geoInfo[playerid][player_city],
        	player_geoInfo[playerid][player_lat],
        	player_geoInfo[playerid][player_lon],
        	player_geoInfo[playerid][player_provider],
        	player_geoInfo[playerid][player_proxy]);	
	}
	else
	{
        strmid(player_geoInfo[playerid][player_country], "-", 0, GEO_MAX_COUNTRY_NAME_LENGTH);
        strmid(player_geoInfo[playerid][player_city], "-", 0, GEO_MAX_CITY_NAME_LENGTH);
        strmid(player_geoInfo[playerid][player_lat], "-", 0, GEO_MAX_LAT_LON_LENGTH);
        strmid(player_geoInfo[playerid][player_lon], "-", 0, GEO_MAX_LAT_LON_LENGTH);
        strmid(player_geoInfo[playerid][player_provider], "-", 0, GEO_MAX_PROVIDER_NAME_LENGTH);
        strmid(player_geoInfo[playerid][player_proxy], "-", 0, GEO_MAX_PROXY_LENGTH);
	}
	return 1;
}