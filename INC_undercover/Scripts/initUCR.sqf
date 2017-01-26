/*
Undercover Unit Handler Script

Author: Incontinentia

*/

private ["_trespassMarkers","_civilianVests","_civilianUniforms","_civilianBackpacks","_civFactions","_civPackArray","_incogVests","_incogUniforms","_incogFactions"];

params [["_unit",objNull]];

waitUntil {!(isNull player)};

#include "..\UCR_setup.sqf"

//Can only be run once per unit.
if ((_unit getVariable ["INC_undercoverHandlerRunning",false]) || {(!local _unit)}) exitWith {};

_unit setVariable ["INC_compLoopActive", false];
_unit setVariable ["INC_isCompromised", false];
_unit setVariable ["INC_suspicious", false];
_unit setVariable ["INC_cooldown", false];
_unit setVariable ["INC_shotAt",false];
_unit setVariable ["INC_firedRecent",false];

_unit setVariable ["INC_undercoverHandlerRunning", true];

if (isPlayer _unit) then {{_x setVariable ["INC_notDismissable",true]} forEach (units group _unit)};

_unit setVariable ["isUndercover", true, true]; //Allow scripts to pick up sneaky units alongside undercover civilians (who do not have the isSneaky variable)

sleep 1;

if (((_debug) || {_hints}) && {isPlayer _unit}) then {hint "Undercover initialising..."};

if (isNil "INC_asymEnySide") then {

	missionNamespace setVariable ["INC_regEnySide",_regEnySide,true];
	missionNamespace setVariable ["INC_asymEnySide",_asymEnySide,true];
	missionNamespace setVariable ["INC_civilianRecruitEnabled",_civRecruitEnabled,true];
	sleep 0.1;
	missionNamespace setVariable ["INC_incogIdentities",(["possibleIdentities",_incogFactions] call INCON_fnc_getConfigInfo),true];
	sleep 0.1;
	missionNamespace setVariable ["INC_civIdentities",(["possibleIdentities",_civFactions] call INCON_fnc_getConfigInfo),true];
	sleep 0.1;

	if (_debug) then {
		diag_log format ["Incon undercover variable INC_regEnySide: %1", INC_regEnySide ];
		diag_log format ["Incon undercover variable INC_asymEnySide: %1", INC_asymEnySide ];
		diag_log format ["Incon undercover variable INC_civilianRecruitEnabled: %1", INC_civilianRecruitEnabled];
		diag_log format ["Incon undercover variable INC_incogIdentities: %1", INC_incogIdentities ];
		diag_log format ["Incon undercover variable INC_civIdentities: %1", INC_civIdentities ];
	};

	//Initial stuff
	_civVests = _civilianVests + [""] + (["vests",_civFactions] call INCON_fnc_getConfigInfo);
	sleep 0.1;
	_civUniforms = _civilianUniforms + [""] + (["uniforms",_civFactions] call INCON_fnc_getConfigInfo);
	sleep 0.1;
	_civHeadgear = _civilianHeadgear + [""] + (["headgear",_civFactions] call INCON_fnc_getConfigInfo) + (["possibleHeadgear",_civFactions] call INCON_fnc_getConfigInfo);
	sleep 0.1;
	_civPacks = _civilianBackpacks +  [""] + _civPackArray;
	sleep 0.1;
	_civVeh =  ([[_civFactions],"getFacVehs"] call INCON_fnc_ucrMain) + _civilianVehicleArray;
	sleep 0.1;

	missionNamespace setVariable ["INC_civilianVests",_civVests,true];
	missionNamespace setVariable ["INC_civilianUniforms",_civUniforms,true];
	missionNamespace setVariable ["INC_civilianHeadgear",_civHeadgear,true];
	sleep 0.1;
	missionNamespace setVariable ["INC_civilianBackpacks",_civPacks,true];
	missionNamespace setVariable ["INC_civilianVehicleArray",_civVeh,true];
	sleep 0.1;

	if (_debug) then {
		diag_log format ["Incon undercover variable INC_civilianVests: %1", INC_civilianVests ];
		diag_log format ["Incon undercover variable INC_civilianUniforms: %1", INC_civilianUniforms ];
		diag_log format ["Incon undercover variable INC_civilianHeadgear: %1", INC_civilianHeadgear ];
		diag_log format ["Incon undercover variable INC_civilianBackpacks: %1", INC_civilianBackpacks ];
		diag_log format ["Incon undercover variable INC_civilianVehicleArray: %1",INC_civilianVehicleArray  ];
	};

	sleep 0.5;

	_incogVests = [""] + (["vests",_incogFactions] call INCON_fnc_getConfigInfo);
	sleep 0.1;
	_incogUniforms = (["uniforms",_incogFactions] call INCON_fnc_getConfigInfo);
	sleep 0.1;
	_incogHeadgear = [""] + (["headgear",_incogFactions] call INCON_fnc_getConfigInfo) + (["possibleHeadgear",_incogFactions] call INCON_fnc_getConfigInfo);
	sleep 0.1;
	_incogBackpacks = [""] + (["backpacks",_incogFactions] call INCON_fnc_getConfigInfo);
	sleep 0.1;
	_incogWpns = [""] + (["weapons",_incogFactions] call INCON_fnc_getConfigInfo);
	sleep 0.1;
	_incogVeh = ([[_incogFactions],"getFacVehs"] call INCON_fnc_ucrMain) + _incogVehArray;
	sleep 0.1;
	missionNamespace setVariable ["INC_incogVests",_incogVests,true];
	missionNamespace setVariable ["INC_incogUniforms",(_incogUniforms - [""]),true];
	missionNamespace setVariable ["INC_incogHeadgear",_incogHeadgear,true];
	missionNamespace setVariable ["INC_incogBackpacks",_incogBackpacks,true];
	missionNamespace setVariable ["INC_incogVehArray",_incogVeh,true];
	missionNamespace setVariable ["INC_incogWpns",_incogWpns,true];

	sleep 0.2;

	if (_debug) then {
		diag_log format ["Incon undercover variable INC_incogVests: %1", INC_incogVests ];
		diag_log format ["Incon undercover variable INC_incogUniforms: %1", INC_incogUniforms ];
		diag_log format ["Incon undercover variable INC_incogHeadgear: %1", INC_incogHeadgear ];
		diag_log format ["Incon undercover variable INC_incogBackpacks: %1", INC_incogBackpacks ];
		diag_log format ["Incon undercover variable INC_incogVehArray: %1", INC_incogVehArray ];
		diag_log format ["Incon undercover variable INC_incogWpns: %1", INC_incogWpns ];
	};

	sleep 0.5;

	missionNamespace setVariable ["INC_sunrise",((date call BIS_fnc_sunriseSunsetTime) select 0),true];
	missionNamespace setVariable ["INC_sunset",((date call BIS_fnc_sunriseSunsetTime) select 1),true];

	if (_debug) then {
		diag_log format ["Incon undercover variable INC_sunrise: %1", INC_sunrise ];
		diag_log format ["Incon undercover variable INC_sunset: %1", INC_sunset ];
	};

	_daylightDuration = INC_sunset - INC_sunrise;
	_lightFactor = _daylightDuration / 24;

	missionNamespace setVariable ["INC_firstLight",(INC_sunrise - _lightFactor),true];
	missionNamespace setVariable ["INC_lastLight",(INC_sunset + _lightFactor),true];

	if (_debug) then {
		diag_log format ["Incon undercover variable INC_firstLight: %1",INC_firstLight  ];
		diag_log format ["Incon undercover variable INC_lastLight: %1",INC_lastLight  ];
	};

	sleep 0.2;

	if ((count (missionNamespace getVariable ["INC_trespassMarkers",[]])) == 0) then {
		//Find trespass markers
		{

		    _trespassMarkers pushBack _x;

		} forEach (allMapMarkers select {
		    ((_x find "INC_tre") >= 0)
		});

		{_x setMarkerAlpha 0} forEach _trespassMarkers;

		missionNamespace setVariable ["INC_trespassMarkers",_trespassMarkers,true];

		if (_debug) then {
			diag_log format ["Incon undercover variable INC_trespassMarkers: %1", INC_trespassMarkers ];
		};
	};

	sleep 0.5;

	//Spawn the rebel commader
	[_unit,"spawnRebelCommander"] remoteExecCall ["INCON_fnc_ucrMain",2];
};

if (_racism) then {
	private ["_unitIDs","_looksLikeArray"];
	_unitIDs = ([[_unit],"getUnitIDs","full"] call INCON_fnc_ucrMain);
	_looksLikeArray = ([[_unitIDs,INC_civIdentities,INC_incogIdentities],"IDcheck"] call INCON_fnc_ucrMain);
	_looksLikeArray params ["_looksLikeCiv","_looksLikeIncog"];
	_unit setVariable ["INC_looksLikeCiv",_looksLikeCiv];
	_unit setVariable ["INC_looksLikeIncog",_looksLikeIncog];

	if ((_debug) && {isPlayer _unit}) then {
		diag_log format ["Player identities: %1", _unitIDs ];
		diag_log format ["Lookalike array: %1", _looksLikeArray];
	};
} else {
	_unit setVariable ["INC_looksLikeCiv",true];
	_unit setVariable ["INC_looksLikeIncog",true];
};

if ((_debug) && {isPlayer _unit}) then {
	diag_log format ["INC_ucr Racism checks active: %1",_racism];
	diag_log format ["Incon undercover variable INC_looksLikeCiv: %1", (_unit getVariable "INC_looksLikeCiv") ];
	diag_log format ["Incon undercover variable INC_looksLikeIncog: %1", (_unit getVariable "INC_looksLikeIncog") ];
};

sleep 0.5;

[_unit, true] remoteExec ["setCaptive", _unit]; //Makes enemies not hostile to the unit

if (isPlayer _unit) then {

	//Add respawn eventhandler so all scripts work properly on respawn
	_unit addMPEventHandler ["MPRespawn",{
		_this spawn {
	        params ["_unit"];
			_unit setVariable ["INC_undercoverHandlerRunning", false];
			_unit setVariable ["INC_undercoverLoopsActive", false];
			_unit setVariable ["INC_compLoopActive", false];
			_unit setVariable ["INC_isCompromised", false];
			_unit setVariable ["INC_suspicious", false];
			_unit setVariable ["INC_cooldown", false];
			sleep 1;
			[[_unit], "INC_undercover\Scripts\initUCR.sqf"] remoteExec ["execVM",_unit];
		};
	}];

	sleep 0.5;

	//Debug hints
	if (_debug) then {
		[_unit] spawn {
			params ["_unit"];
			sleep 5;

			waitUntil {
				sleep 1;
				_unit globalChat (format ["%1 cover intact: %2, compromised: %3",_unit,(captive _unit),(_unit getVariable ["INC_isCompromised",false])]);
				_unit globalChat (format ["%1 trespassing: %2",_unit,((_unit getVariable ["INC_proxAlert",false]) || {(_unit getVariable ["INC_trespassAlert",false])})]);
				_unit globalChat (format ["%1 suspicious level: %2",_unit,(_unit getVariable ["INC_suspiciousValue",1])]);
				_unit globalChat (format ["%1 weirdo check active: %2, value %3",_unit,(captive _unit),(_unit getVariable ["INC_disguiseValue",1])]);
				_unit globalChat (format ["%1 spot distance multiplier active: %2, value %3",_unit,(captive _unit),(_unit getVariable ["INC_radiusMulti",1])]);
				_unit globalChat (format ["Enemy know about %1: %2",_unit,(_unit getVariable ["INC_AnyKnowsSO",false])]);
				!(_unit getVariable ["isUndercover",false])
			};

			_unit globalChat (format ["%1 undercover status: %2",_unit,(_unit getVariable ["isUndercover",false])]);
		};
	};

	sleep 0.5;

	//Run a low-impact version of the undercover script on AI subordinates (no proximity check)
	if (_unit isEqualTo (leader group _unit)) then {
		[_unit] spawn {
			params ["_unit"];
			{
				if !(_x getVariable ["isUndercover",false]) then {
					sleep 0.2;
					[_x] execVM "INC_undercover\Scripts\initUCR.sqf";
					sleep 0.2;
					_x setVariable ["noChanges",true,true];
					_x setVariable ["isUndercover", true];
					sleep 0.2;
					[[_x,_unit],"addConcealActions"] call INCON_fnc_ucrMain;
				};
			} forEach units group _unit;
		};
	};
};

sleep 1;

//Get the undercover loops running on the unit
[_unit] call INCON_fnc_UCRhandler;

sleep 1;

//Main loop
waitUntil {

	sleep 1;

	//Pause while the unit is compromised
	waitUntil {
		sleep 1;
		!(_unit getVariable ["INC_isCompromised",false]);
	};

	//wait until the unit is acting all suspicious
	waitUntil {
		sleep 1;
		((_unit getVariable ["INC_suspiciousValue",1]) >= 2);
	};

	//Tell them they are being suspicious
	if (((_debug) || {_hints}) && {isPlayer _unit}) then {
		[_unit] spawn {
			params ["_unit"];
			hint "Acting suspiciously.";
			waitUntil {
				sleep 1;
				!((_unit getVariable ["INC_suspiciousValue",1]) >= 2)
			};
			hint "No longer acting suspiciously.";
		};
	};

	//Once the player is doing suspicious stuff, make them vulnerable to being compromised
	_unit setVariable ["INC_suspicious", true]; //Hold the cooldown script until the unit is no longer doing suspicious things
	[_unit, false] remoteExec ["setCaptive", _unit]; //Makes enemies hostile to the unit

	//These variables shouldn't run while the unit isn't captive
	_unit setVariable ["INC_weirdoLevel",1];
	_unit setVariable ["INC_radiusMulti",1];

	[_unit] call INCON_fnc_cooldown; //Gets the cooldown script going

	//While he's acting suspiciously
	while {
		sleep 1;
		(((_unit getVariable ["INC_suspiciousValue",1]) >= 2) && {!(_unit getVariable ["INC_isCompromised",false])}) //While not compromised and either armed or trespassing
	} do {
		if (
			((_unit getVariable ["INC_suspiciousValue",1]) >= 3) &&
			{(_unit getVariable ["INC_AnyKnowsSO",false])}
		) then {
			private _regAlerted = [INC_regEnySide,_unit,50] call INCON_fnc_countAlerted;
			private _asymAlerted = [INC_asymEnySide,_unit,50] call INCON_fnc_countAlerted;

			//Once people know exactly where he is, who he is, and that he is both armed and trespassing, make him compromised
			if ((_regAlerted != 0) || {(_asymAlerted != 0)}) exitWith {

				[_unit] call INCON_fnc_compromised;
			};
		};
	};

	//Then stop the holding variable and allow cooldown to commence
	_unit setVariable ["INC_suspicious", false];

	sleep 2;

	//Wait until cooldown loop has finished
	waitUntil {
		sleep 2;
		!(_unit getVariable ["INC_cooldown",false]);
	};

	(!(_unit getVariable ["isUndercover",false]) || {!(alive _unit)} || {!local _unit})

};

_unit setVariable ["INC_undercoverHandlerRunning", false];
