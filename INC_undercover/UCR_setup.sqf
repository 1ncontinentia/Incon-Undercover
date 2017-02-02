/*

Setup options for INC_undercover undercover / civilian recruitment script by Incontinentia.

Please check each setting carefully otherwise the script may not function properly in your scenario.

*/

//-------------------------Player settings-------------------------

_undercoverUnitSide = west;             //What side is/are the undercover unit(s) on? (Can be east, west or independent - only one side supported)

//-------------------------General Settings-------------------------

_debug = false;                         //Set to true for debug hints
_hints = true;                          //Hints show changes of state etc
_fullAIfunctionality = true;            //Enable all checks on AI (may degrade performace very slightly for large groups, 15+)

_racism = true;                         //Enemies will notice if you aren't the race of the faction you're pretending to be (making you easier to detect if nothing is covering your face)
_racProfFacCiv = 1;                     //(Number) Multiplies the effect of racial profiling. Lower this number to simulate more multicultural civilian population
_racProfFacEny = 1;                     //(Number) Multiplies the effect of racial profiling. Lower this number to simulate more multicultural enemy forces

_regEnySide = east;                     //Units of this side will be classed as regular enemies (Side: can be east, west, independent) - if you don't need this, comment the line out (i.e. put // before _regEnySide, as in //_regEnySide = east;).
_regBarbaric = false;                   //(Bool - true or false) Will this side lash out on civilians if it takes casualties and doesn't know the attacker?
_regDetectRadius = 15;                  //Default detection radius for regular troops (this will expand and contract based on weather, time of day, and how the undercover unit is acting - civilians within this radius will be under much more scrutinty)

_asymEnySide = independent;             //Units of this side will be classed as asymetric enemies (Side: can be east, west, independent) - if you don't need this, comment the line out (i.e. put // before _asymEnySide, as in //_asymEnySide = east;).
_asymBarbaric = true;                   //(Bool - true or false) Will this side have a small chance of lashing out on civilians if it takes casualties and doesn't know the attacker?
_asymDetectRadius = 20;                 //Default detection radius for asym troops (this will expand and contract based on weather, time of day, and how the undercover unit is acting - civilians within this radius will be under much more scrutinty)

_trespassMarkers = [];                  //Names of additional markers for areas that would be considered trespassing (any with "INC_tre" - case sensitive - somewhere in the marker name will automatically be included)

//-------------------------Civilian Disguise settings-------------------------

_civFactions = ["CIV_F","CIV_F_TANOA"]; //Array of factions whose vests are safe for undercover units to wear (must have quotation marks around each item, as in ["Ping_Pong_1_F","Ping_Pong_2_F"])

//(Array of classnames) Safe vests (on top of the specific factions above - must have quotation marks around each item, as in ["Ping_Pong_1_F","Ping_Pong_2_F"])
_civilianVests = [];

//(Array of classnames) Safe uniforms (on top of the specific factions above - must have quotation marks around each item, as in ["Ping_Pong_1_F","Ping_Pong_2_F"])
_civilianUniforms = ["U_BG_Guerilla2_2","U_BG_Guerilla2_1","U_BG_Guerilla2_3","U_I_C_Soldier_Bandit_4_F","U_I_C_Soldier_Bandit_1_F","U_I_C_Soldier_Bandit_2_F","U_I_C_Soldier_Bandit_5_F","U_I_C_Soldier_Bandit_3_F"];

//(Array of classnames) Safe headgear (will automatically include civilian headgear classes - must have quotation marks around each item, as in ["Ping_Pong_1_F","Ping_Pong_2_F"])
_civilianHeadgear = [];

//(Array of classnames) Safe backpacks (will automatically include civilian backpack classes - must have quotation marks around each item, as in ["Ping_Pong_1_F","Ping_Pong_2_F"])
_civilianBackpacks = ["B_FieldPack_blk","B_FieldPack_cbr","B_FieldPack_khk","B_FieldPack_oucamo","G_FieldPack_Medic","B_Carryall_cbr","B_Carryall_khk","B_Carryall_oucamo","B_TacticalPack_blk","B_TacticalPack_rgr","B_TacticalPack_oli","B_Kitbag_cbr","B_Kitbag_rgr","B_Kitbag_sgg","B_Respawn_Sleeping_bag_blue_F","B_Respawn_Sleeping_bag_brown_F","B_Respawn_TentDome_F","B_Respawn_TentA_F","B_Parachute","ACE_NonSteerableParachute","ACE_TacticalLadder_Pack"];

//(Array of classnames) Safe vehicles to drive in (automatically includes vehicles from the civilian factions above).
_civilianVehicleArray = [];

_HMDallowed = false; //(Bool - true or false) Are HMDs (night vision goggles etc.) safe to wear for units pretending to be civilians? Set to false if wearing HMDs will cause suspicion (must be stored in backpack).

_noOffRoad = true; //Civilian vehicles driving more than 50 meters from the nearest road will be considered hostile

//-------------------------Enemy Disguise settings-------------------------
_incogFactions = ["OPF_F","OPF_T_F"]; //Array of enemy factions whose items and vehicles will allow the player to impersonate the enemy
_incogVehArray = []; //(Array of classnames) Additional incognito vehicles (vehicles from the faction above will automatically count)

//-------------------------Civilian recruitment settings-------------------------
/*
By enabling civilian recruitment, undercover can recruit any ambient civilians they see into their group (if their reputation allows / the civvy wants to join).
Civilians will operate under similar restrictions to the player.
You can also dismiss your new teammates and they will leave your group and carry on doing whatever it is they fancy doing (usually sitting cross-legged in the middle of a field).
*/

_civRecruitEnabled = true;          //(Bool - true or false) Set this to false to prevent undercover units from recruiting civilians
_armedCivPercentage = 70;           //(Number - 0 to 100) Max percentage of civilians armed with weapons from the array below, either on their person or in their backpacks (will only work if _civRecruitEnabled is set to true, otherwise this is ignored)

//Weapon classnames for armed civilians (array of classnames)
_civWpnArray = ["arifle_AKS_F","arifle_AKM_F","hgun_Pistol_01_F","hgun_Rook40_F","hgun_ACPC2_F","hgun_Rook40_F"];

//Items that civilians may carry
_civItemArray = ["ACE_Cellphone","ACE_Banana","ACE_Flashlight_KSF1","ACE_SpraypaintBlack","itemRadio","ACE_RangeCard","ACE_key_civ","ACE_key_lockpick","ACE_fieldDressing","IEDUrbanSmall_F","IEDUrbanSmall_F"];

//Civilian backpack classes (array of classnames)
_civPackArray = ["B_FieldPack_blk","B_FieldPack_cbr","B_FieldPack_khk","B_FieldPack_oucamo","B_Carryall_cbr"];
