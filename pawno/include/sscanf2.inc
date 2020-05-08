/*  
 *  Version: MPL 1.1
 *  
 *  The contents of this file are subject to the Mozilla Public License Version
 *  1.1 (the "License"); you may not use this file except in compliance with
 *  the License. You may obtain a copy of the License at
 *  [url]http://www.mozilla.org/MPL/[/url]
 *  
 *  Software distributed under the License is distributed on an "AS IS" basis,
 *  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 *  for the specific language governing rights and limitations under the
 *  License.
 *  
 *  The Original Code is the sscanf 2.0 SA:MP plugin.
 *  
 *  The Initial Developer of the Original Code is Alex "Y_Less" Cole.
 *  Portions created by the Initial Developer are Copyright (C) 2010
 *  the Initial Developer. All Rights Reserved.
 *  
 *  Contributor(s):
 *  
 *  Special Thanks to:
 *  
 *  SA:MP Team past, present and future
 */

#define SSCANF:%0(%1) sscanf_%0(%1);public sscanf_%0(%1)

#if defined sscanf
    #error sscanf (possibly the PAWN version) already defined.
#endif
native sscanf(const data[], const format[], {Float,_}:...);
native unformat(const data[], const format[], {Float,_}:...) = sscanf;
native SSCANF_Init(players, invalid, len);
native SSCANF_Join(playerid, const name[], npc);
native SSCANF_Leave(playerid);

static stock
    SSCANF_gInit = 0xFFFFFFFF,
    SSCANF_gOPC,
    SSCANF_gOPDC;

public OnFilterScriptInit()
{
    //printf("OnFilter");
    SSCANF_Init(GetMaxPlayers(), INVALID_PLAYER_ID, MAX_PLAYER_NAME);
    SSCANF_gInit = funcidx("SSCANF_OnGameModeInit") != -1;
    SSCANF_gOPC  = funcidx("SSCANF_OnPlayerConnect") != -1;
    SSCANF_gOPDC = funcidx("SSCANF_OnPlayerDisconnect") != -1;
    return CallLocalFunction("SSCANF_OnFilterScriptInit", "");
}

#if defined _ALS_OnFilterScriptInit
    #undef OnFilterScriptInit
#else
    #define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit SSCANF_OnFilterScriptInit

forward OnFilterScriptInit();

public OnGameModeInit()
{
    //printf("OnGameo");
    if (SSCANF_gInit == -1)
    {
        SSCANF_Init(GetMaxPlayers(), INVALID_PLAYER_ID, MAX_PLAYER_NAME);
        SSCANF_gInit = funcidx("SSCANF_OnGameModeInit") != -1;
        SSCANF_gOPC  = funcidx("SSCANF_OnPlayerConnect") != -1;
        SSCANF_gOPDC = funcidx("SSCANF_OnPlayerDisconnect") != -1;
    }
    if (SSCANF_gInit)
    {
        // Can't do the clever assembly version without y_amx.
        /*#emit PUSH.S   reason
        #emit PUSH.S   playerid
        #emit PUSH.C   8
        #emit LCTRL    6
        #emit ADD.C    28
        #emit PUSH.pri
        #emit LOAD.pri SSCANF_gOPDC
        #emit SCTRL    6
        #emit RETN*/
        return CallLocalFunction("SSCANF_OnGameModeInit", "");
    }
    return 1;
}

#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit SSCANF_OnGameModeInit

forward OnGameModeInit();

public OnPlayerConnect(playerid)
{
    new
        name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof (name));
    SSCANF_Join(playerid, name, IsPlayerNPC(playerid));
    if (SSCANF_gOPC)
    {
        /*#emit PUSH.S   playerid
        #emit PUSH.C   4
        #emit LCTRL    6
        #emit ADD.C    28
        #emit PUSH.pri
        #emit LOAD.pri SSCANF_gOPC
        #emit SCTRL    6
        #emit RETN*/
        return CallLocalFunction("SSCANF_OnPlayerConnect", "i", playerid);
    }
    return 1;
}

#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect SSCANF_OnPlayerConnect

forward OnPlayerConnect(playerid);

public OnPlayerDisconnect(playerid, reason)
{
    new
        ret = 1;
    if (SSCANF_gOPDC)
    {
        /*#emit PUSH.S   reason
        #emit PUSH.S   playerid
        #emit PUSH.C   8
        #emit LCTRL    6
        #emit ADD.C    28
        #emit PUSH.pri
        #emit LOAD.pri SSCANF_gOPDC
        #emit SCTRL    6
        #emit RETN*/
        ret = CallLocalFunction("SSCANF_OnPlayerDisconnect", "ii", playerid, reason);
    }
    SSCANF_Leave(playerid);
    return ret;
}

#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect SSCANF_OnPlayerDisconnect

forward OnPlayerDisconnect(playerid, reason);

#define SSCANF_Init
#define SSCANF_Join
#define SSCANF_Leave

#define extract%0->%1; EXTRN%1;unformat(_:EXTRZ:EXTRX:%0,##,%1,,);
#define unformat(_:EXTRZ:EXTRX:%0,##,%1);%2else%3; if (unformat(_:EXTRX:%0,##,%1))%3;

#define EXTRX:%0##,%9new%1,%2) EXTRY:%0##,|||%1|||%2)
#define EXTRY: EXTR8:EXTR9:EXTR0:EXTR1:EXTR2:EXTR3:EXTR4:

#define EXTR8:EXTR9:EXTR0:EXTR1:EXTR2:EXTR3:EXTR4:%0##%1,%2|||%6:%3=%9|||%4) %6_EXTRO:%0##%1,%2|||%3=%9|||%4)
#define EXTR9:EXTR0:EXTR1:EXTR2:EXTR3:EXTR4:%0##%1,%2|||%3=%9|||%4) __EXTRO:%0##%1,%2|||%3=%9|||%4)
#define EXTR0:EXTR1:EXTR2:EXTR3:EXTR4:%0##%1,%2|||%6:%3[%7]|||%4) %6_EXTRW:%0##%1,%2|||%3[%7]|||%4)
#define EXTR1:EXTR2:EXTR3:EXTR4:%0##%1,%2|||%3[%7]|||%4) __EXTRW:%0##%1,%2|||%3|||%4)
#define EXTR2:EXTR3:EXTR4:%0##%1,%2|||%6:%3|||%4) %6_EXTRN:%0##%1,%2|||%3|||%4)
#define EXTR3:EXTR4:%0##%1,,%2||||||%4) %0##%1,%2)
#define EXTR4:%0##%1,%2|||%3|||%4) __EXTRN:%0##%1,%2|||%3|||%4)

// Optional specifiers.
#define __EXTRO:%0##%1,%2|||%3=%9|||%4,%5) EXTRY:%0##%1I"("#%9")"#,%2,%3|||%4|||%5)
#define Float_EXTRO:%0##%1,%2|||%3=%9|||%4,%5) EXTRY:%0##%1F"("#%9")"#,%2,%3|||%4|||%5)
#define player_EXTRO:%0##%1,%2|||%3=%9|||%4,%5) EXTRY:%0##%1U"("#%9")"#,%2,%3|||%4|||%5)
#define string_EXTRO:%0##%1,%2|||%3[%7]=%9|||%4,%5) EXTRY:%0##%1S"("#%9")"#[%7],%2,%3|||%4|||%5)

// Normal specifiers (the double underscore is to work for "_:".
#define __EXTRN:%0##%1,%2|||%3|||%4,%5) EXTRY:%0##%1i,%2,%3|||%4|||%5)
#define Float_EXTRN:%0##%1,%2|||%3|||%4,%5) EXTRY:%0##%1f,%2,%3|||%4|||%5)
#define player_EXTRN:%0##%1,%2|||%3|||%4,%5) EXTRY:%0##%1u,%2,%3|||%4|||%5)
//#define string_EXTRW:%0##%1,%2|||%3[%7]|||%4,%5) EXTRY:%0##%1s[%7],%2,%3|||%4|||%5)

// Array versions of normal specifiers.
#define __EXTRW:%0##%1,%2|||%3[%7]|||%4,%5) EXTRY:%0##%1a<i>[%7],%2,%3|||%4|||%5)
#define Float_EXTRW:%0##%1,%2|||%3[%7]|||%4,%5) EXTRY:%0##%1a<f>[%7],%2,%3|||%4|||%5)
#define player_EXTRW:%0##%1,%2|||%3[%7]|||%4,%5) EXTRY:%0##%1a<u>[%7],%2,%3|||%4|||%5)
#define string_EXTRW:%0##%1,%2|||%3[%7]|||%4,%5) EXTRY:%0##%1s[%7],%2,%3|||%4|||%5)

// Get rid of excess leading space which causes warnings.
#define EXTRN%0new%1; new%1;

#if !defined string
    #define string:
#endif

#define player:

#define hex:
#define hex_EXTRO:%0##%1,%2|||%3=%9|||%4,%5) EXTRY:%0##%1H"("#%9")"#,%2,%3|||%4|||%5)
#define hex_EXTRN:%0##%1,%2|||%3|||%4,%5) EXTRY:%0##%1h,%2,%3|||%4|||%5)
#define hex_EXTRW:%0##%1,%2|||%3[%7]|||%4,%5) EXTRY:%0##%1a<h>[%7],%2,%3|||%4|||%5)

#define bin:
#define bin_EXTRO:%0##%1,%2|||%3=%9|||%4,%5) EXTRY:%0##%1B"("#%9")"#,%2,%3|||%4|||%5)
#define bin_EXTRN:%0##%1,%2|||%3|||%4,%5) EXTRY:%0##%1b,%2,%3|||%4|||%5)
#define bin_EXTRW:%0##%1,%2|||%3[%7]|||%4,%5) EXTRY:%0##%1a<b>[%7],%2,%3|||%4|||%5)

#define kustom:%0<%1> %0
#define kustom_EXTRO:%0##%1,%2|||%3<%8>=%9|||%4,%5) EXTRY:%0##%1K<%8>"("#%9")"#,%2,%3|||%4|||%5)
#define kustom_EXTRN:%0##%1,%2|||%3<%8>|||%4,%5) EXTRY:%0##%1k<%8>,%2,%3|||%4|||%5)
//#define bin_EXTRW:%0##%1,%2|||%3[%7]|||%4,%5) EXTRY:%0##%1a<b>[%7],%2,%3|||%4|||%5)

SSCANF:weapon(str[])
{
    // This function is VERY basic, needs VASTLY improving to detect variations.
    if ('0' <= str[0] <= '9')
    {
        new
            ret = strval(str);
        if (0 <= ret <= 18 || 22 <= ret <= 46)
        {
            return ret;
        }
    }
    else if (!strcmp(str, "Unarmed")) return 0;
    else if (!strcmp(str, "Brass Knuckles")) return 1;
    else if (!strcmp(str, "Golf Club")) return 2;
    else if (!strcmp(str, "Night Stick")) return 3;
    else if (!strcmp(str, "Knife")) return 4;
    else if (!strcmp(str, "Baseball Bat")) return 5;
    else if (!strcmp(str, "Shovel")) return 6;
    else if (!strcmp(str, "Pool cue")) return 7;
    else if (!strcmp(str, "Katana")) return 8;
    else if (!strcmp(str, "Chainsaw")) return 9;
    else if (!strcmp(str, "Purple Dildo")) return 10;
    else if (!strcmp(str, "White Dildo")) return 11;
    else if (!strcmp(str, "Long White Dildo")) return 12;
    else if (!strcmp(str, "White Dildo 2")) return 13;
    else if (!strcmp(str, "Flowers")) return 14;
    else if (!strcmp(str, "Cane")) return 15;
    else if (!strcmp(str, "Grenades")) return 16;
    else if (!strcmp(str, "Tear Gas")) return 17;
    else if (!strcmp(str, "Molotovs")) return 18;
    else if (!strcmp(str, "Pistol")) return 22;
    else if (!strcmp(str, "Silenced Pistol")) return 23;
    else if (!strcmp(str, "Desert Eagle")) return 24;
    else if (!strcmp(str, "Shotgun")) return 25;
    else if (!strcmp(str, "Sawn Off Shotgun")) return 26;
    else if (!strcmp(str, "Combat Shotgun")) return 27;
    else if (!strcmp(str, "Micro Uzi")) return 28;
    else if (!strcmp(str, "Mac 10")) return 28;
    else if (!strcmp(str, "MP5")) return 29;
    else if (!strcmp(str, "AK47")) return 30;
    else if (!strcmp(str, "M4")) return 31;
    else if (!strcmp(str, "Tec9")) return 32;
    else if (!strcmp(str, "Rifle")) return 33;
    else if (!strcmp(str, "Sniper Rifle")) return 34;
    else if (!strcmp(str, "RPG")) return 35;
    else if (!strcmp(str, "Missile Launcher")) return 36;
    else if (!strcmp(str, "Flame Thrower")) return 37;
    else if (!strcmp(str, "Minigun")) return 38;
    else if (!strcmp(str, "Sachel Charges")) return 39;
    else if (!strcmp(str, "Detonator")) return 40;
    else if (!strcmp(str, "Spray Paint")) return 41;
    else if (!strcmp(str, "Fire Extinguisher")) return 42;
    else if (!strcmp(str, "Camera")) return 43;
    else if (!strcmp(str, "Nightvision Goggles")) return 44;
    else if (!strcmp(str, "Thermal Goggles")) return 45;
    else if (!strcmp(str, "Parachute")) return 46;
    return -1;
}

SSCANF:vehicle(str[])
{
    // This function is VERY basic, needs VASTLY improving to detect variations.
    if ('0' <= str[0] <= '9')
    {
        new
            ret = strval(str);
        if (400 <= ret <= 611)
        {
            return ret;
        }
    }
    else if (!strcmp(str, "Landstalker")) return 400;
    else if (!strcmp(str, "Bravura")) return 401;
    else if (!strcmp(str, "Buffalo")) return 402;
    else if (!strcmp(str, "Linerunner")) return 403;
    else if (!strcmp(str, "Perenniel")) return 404;
    else if (!strcmp(str, "Sentinel")) return 405;
    else if (!strcmp(str, "Dumper")) return 406;
    else if (!strcmp(str, "Firetruck")) return 407;
    else if (!strcmp(str, "Trashmaster")) return 408;
    else if (!strcmp(str, "Stretch")) return 409;
    else if (!strcmp(str, "Manana")) return 410;
    else if (!strcmp(str, "Infernus")) return 411;
    else if (!strcmp(str, "Voodoo")) return 412;
    else if (!strcmp(str, "Pony")) return 413;
    else if (!strcmp(str, "Mule")) return 414;
    else if (!strcmp(str, "Cheetah")) return 415;
    else if (!strcmp(str, "Ambulance")) return 416;
    else if (!strcmp(str, "Leviathan")) return 417;
    else if (!strcmp(str, "Moonbeam")) return 418;
    else if (!strcmp(str, "Esperanto")) return 419;
    else if (!strcmp(str, "Taxi")) return 420;
    else if (!strcmp(str, "Washington")) return 421;
    else if (!strcmp(str, "Bobcat")) return 422;
    else if (!strcmp(str, "Mr Whoopee")) return 423;
    else if (!strcmp(str, "BF Injection")) return 424;
    else if (!strcmp(str, "Hunter")) return 425;
    else if (!strcmp(str, "Premier")) return 426;
    else if (!strcmp(str, "Enforcer")) return 427;
    else if (!strcmp(str, "Securicar")) return 428;
    else if (!strcmp(str, "Banshee")) return 429;
    else if (!strcmp(str, "Predator")) return 430;
    else if (!strcmp(str, "Bus")) return 431;
    else if (!strcmp(str, "Rhino")) return 432;
    else if (!strcmp(str, "Barracks")) return 433;
    else if (!strcmp(str, "Hotknife")) return 434;
    else if (!strcmp(str, "Article Trailer")) return 435;
    else if (!strcmp(str, "Previon")) return 436;
    else if (!strcmp(str, "Coach")) return 437;
    else if (!strcmp(str, "Cabbie")) return 438;
    else if (!strcmp(str, "Stallion")) return 439;
    else if (!strcmp(str, "Rumpo")) return 440;
    else if (!strcmp(str, "RC Bandit")) return 441;
    else if (!strcmp(str, "Romero")) return 442;
    else if (!strcmp(str, "Packer")) return 443;
    else if (!strcmp(str, "Monster")) return 444;
    else if (!strcmp(str, "Admiral")) return 445;
    else if (!strcmp(str, "Squallo")) return 446;
    else if (!strcmp(str, "Seasparrow")) return 447;
    else if (!strcmp(str, "Pizzaboy")) return 448;
    else if (!strcmp(str, "Tram")) return 449;
    else if (!strcmp(str, "Article Trailer 2")) return 450;
    else if (!strcmp(str, "Turismo")) return 451;
    else if (!strcmp(str, "Speeder")) return 452;
    else if (!strcmp(str, "Reefer")) return 453;
    else if (!strcmp(str, "Tropic")) return 454;
    else if (!strcmp(str, "Flatbed")) return 455;
    else if (!strcmp(str, "Yankee")) return 456;
    else if (!strcmp(str, "Caddy")) return 457;
    else if (!strcmp(str, "Solair")) return 458;
    else if (!strcmp(str, "Berkley's RC Van")) return 459;
    else if (!strcmp(str, "Skimmer")) return 460;
    else if (!strcmp(str, "PCJ-600")) return 461;
    else if (!strcmp(str, "Faggio")) return 462;
    else if (!strcmp(str, "Freeway")) return 463;
    else if (!strcmp(str, "RC Baron")) return 464;
    else if (!strcmp(str, "RC Raider")) return 465;
    else if (!strcmp(str, "Glendale")) return 466;
    else if (!strcmp(str, "Oceanic")) return 467;
    else if (!strcmp(str, "Sanchez")) return 468;
    else if (!strcmp(str, "Sparrow")) return 469;
    else if (!strcmp(str, "Patriot")) return 470;
    else if (!strcmp(str, "Quad")) return 471;
    else if (!strcmp(str, "Coastguard")) return 472;
    else if (!strcmp(str, "Dinghy")) return 473;
    else if (!strcmp(str, "Hermes")) return 474;
    else if (!strcmp(str, "Sabre")) return 475;
    else if (!strcmp(str, "Rustler")) return 476;
    else if (!strcmp(str, "ZR-350")) return 477;
    else if (!strcmp(str, "Walton")) return 478;
    else if (!strcmp(str, "Regina")) return 479;
    else if (!strcmp(str, "Comet")) return 480;
    else if (!strcmp(str, "BMX")) return 481;
    else if (!strcmp(str, "Burrito")) return 482;
    else if (!strcmp(str, "Camper")) return 483;
    else if (!strcmp(str, "Marquis")) return 484;
    else if (!strcmp(str, "Baggage")) return 485;
    else if (!strcmp(str, "Dozer")) return 486;
    else if (!strcmp(str, "Maverick")) return 487;
    else if (!strcmp(str, "SAN News Maverick")) return 488;
    else if (!strcmp(str, "Rancher")) return 489;
    else if (!strcmp(str, "FBI Rancher")) return 490;
    else if (!strcmp(str, "Virgo")) return 491;
    else if (!strcmp(str, "Greenwood")) return 492;
    else if (!strcmp(str, "Jetmax")) return 493;
    else if (!strcmp(str, "Hotring Racer")) return 494;
    else if (!strcmp(str, "Sandking")) return 495;
    else if (!strcmp(str, "Blista Compact")) return 496;
    else if (!strcmp(str, "Police Maverick")) return 497;
    else if (!strcmp(str, "Boxville")) return 498;
    else if (!strcmp(str, "Benson")) return 499;
    else if (!strcmp(str, "Mesa")) return 500;
    else if (!strcmp(str, "RC Goblin")) return 501;
    else if (!strcmp(str, "Hotring Racer")) return 502;
    else if (!strcmp(str, "Hotring Racer")) return 503;
    else if (!strcmp(str, "Bloodring Banger")) return 504;
    else if (!strcmp(str, "Rancher")) return 505;
    else if (!strcmp(str, "Super GT")) return 506;
    else if (!strcmp(str, "Elegant")) return 507;
    else if (!strcmp(str, "Journey")) return 508;
    else if (!strcmp(str, "Bike")) return 509;
    else if (!strcmp(str, "Mountain Bike")) return 510;
    else if (!strcmp(str, "Beagle")) return 511;
    else if (!strcmp(str, "Cropduster")) return 512;
    else if (!strcmp(str, "Stuntplane")) return 513;
    else if (!strcmp(str, "Tanker")) return 514;
    else if (!strcmp(str, "Roadtrain")) return 515;
    else if (!strcmp(str, "Nebula")) return 516;
    else if (!strcmp(str, "Majestic")) return 517;
    else if (!strcmp(str, "Buccaneer")) return 518;
    else if (!strcmp(str, "Shamal")) return 519;
    else if (!strcmp(str, "Hydra")) return 520;
    else if (!strcmp(str, "FCR-900")) return 521;
    else if (!strcmp(str, "NRG-500")) return 522;
    else if (!strcmp(str, "HPV1000")) return 523;
    else if (!strcmp(str, "Cement Truck")) return 524;
    else if (!strcmp(str, "Towtruck")) return 525;
    else if (!strcmp(str, "Fortune")) return 526;
    else if (!strcmp(str, "Cadrona")) return 527;
    else if (!strcmp(str, "FBI Truck")) return 528;
    else if (!strcmp(str, "Willard")) return 529;
    else if (!strcmp(str, "Forklift")) return 530;
    else if (!strcmp(str, "Tractor")) return 531;
    else if (!strcmp(str, "Combine Harvester")) return 532;
    else if (!strcmp(str, "Feltzer")) return 533;
    else if (!strcmp(str, "Remington")) return 534;
    else if (!strcmp(str, "Slamvan")) return 535;
    else if (!strcmp(str, "Blade")) return 536;
    else if (!strcmp(str, "Freight (Train)")) return 537;
    else if (!strcmp(str, "Brownstreak (Train)")) return 538;
    else if (!strcmp(str, "Vortex")) return 539;
    else if (!strcmp(str, "Vincent")) return 540;
    else if (!strcmp(str, "Bullet")) return 541;
    else if (!strcmp(str, "Clover")) return 542;
    else if (!strcmp(str, "Sadler")) return 543;
    else if (!strcmp(str, "Firetruck LA")) return 544;
    else if (!strcmp(str, "Hustler")) return 545;
    else if (!strcmp(str, "Intruder")) return 546;
    else if (!strcmp(str, "Primo")) return 547;
    else if (!strcmp(str, "Cargobob")) return 548;
    else if (!strcmp(str, "Tampa")) return 549;
    else if (!strcmp(str, "Sunrise")) return 550;
    else if (!strcmp(str, "Merit")) return 551;
    else if (!strcmp(str, "Utility Van")) return 552;
    else if (!strcmp(str, "Nevada")) return 553;
    else if (!strcmp(str, "Yosemite")) return 554;
    else if (!strcmp(str, "Windsor")) return 555;
    else if (!strcmp(str, "Monster \"A\"")) return 556;
    else if (!strcmp(str, "Monster \"B\"")) return 557;
    else if (!strcmp(str, "Uranus")) return 558;
    else if (!strcmp(str, "Jester")) return 559;
    else if (!strcmp(str, "Sultan")) return 560;
    else if (!strcmp(str, "Stratum")) return 561;
    else if (!strcmp(str, "Elegy")) return 562;
    else if (!strcmp(str, "Raindance")) return 563;
    else if (!strcmp(str, "RC Tiger")) return 564;
    else if (!strcmp(str, "Flash")) return 565;
    else if (!strcmp(str, "Tahoma")) return 566;
    else if (!strcmp(str, "Savanna")) return 567;
    else if (!strcmp(str, "Bandito")) return 568;
    else if (!strcmp(str, "Freight Flat Trailer (Train)")) return 569;
    else if (!strcmp(str, "Streak Trailer (Train)")) return 570;
    else if (!strcmp(str, "Kart")) return 571;
    else if (!strcmp(str, "Mower")) return 572;
    else if (!strcmp(str, "Dune")) return 573;
    else if (!strcmp(str, "Sweeper")) return 574;
    else if (!strcmp(str, "Broadway")) return 575;
    else if (!strcmp(str, "Tornado")) return 576;
    else if (!strcmp(str, "AT400")) return 577;
    else if (!strcmp(str, "DFT-30")) return 578;
    else if (!strcmp(str, "Huntley")) return 579;
    else if (!strcmp(str, "Stafford")) return 580;
    else if (!strcmp(str, "BF-400")) return 581;
    else if (!strcmp(str, "Newsvan")) return 582;
    else if (!strcmp(str, "Tug")) return 583;
    else if (!strcmp(str, "Petrol Trailer")) return 584;
    else if (!strcmp(str, "Emperor")) return 585;
    else if (!strcmp(str, "Wayfarer")) return 586;
    else if (!strcmp(str, "Euros")) return 587;
    else if (!strcmp(str, "Hotdog")) return 588;
    else if (!strcmp(str, "Club")) return 589;
    else if (!strcmp(str, "Freight Box Trailer (Train)")) return 590;
    else if (!strcmp(str, "Article Trailer 3")) return 591;
    else if (!strcmp(str, "Andromada")) return 592;
    else if (!strcmp(str, "Dodo")) return 593;
    else if (!strcmp(str, "RC Cam")) return 594;
    else if (!strcmp(str, "Launch")) return 595;
    else if (!strcmp(str, "Police Car (LSPD)")) return 596;
    else if (!strcmp(str, "Police Car (SFPD)")) return 597;
    else if (!strcmp(str, "Police Car (LVPD)")) return 598;
    else if (!strcmp(str, "Police Ranger")) return 599;
    else if (!strcmp(str, "Picador")) return 600;
    else if (!strcmp(str, "S.W.A.T.")) return 601;
    else if (!strcmp(str, "Alpha")) return 602;
    else if (!strcmp(str, "Phoenix")) return 603;
    else if (!strcmp(str, "Glendale Shit")) return 604;
    else if (!strcmp(str, "Sadler Shit")) return 605;
    else if (!strcmp(str, "Baggage Trailer \"A\"")) return 606;
    else if (!strcmp(str, "Baggage Trailer \"B\"")) return 607;
    else if (!strcmp(str, "Tug Stairs Trailer")) return 608;
    else if (!strcmp(str, "Boxville")) return 609;
    else if (!strcmp(str, "Farm Trailer")) return 610;
    else if (!strcmp(str, "Utility Trailer")) return 611;
    return -1;
}

// Fix the compiler crash when both the PAWN and Plugin versions of sscanf are
// found by renaming the old version at declaration.  (fixes.inc compatible
// naming scheme: "BAD_Function()").
#define sscanf(%0:...) BAD_sscanf(%0:...)
