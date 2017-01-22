/*
Undercover Unit Handler Script

Author: Incontinentia

*/

private ["_trespassMarkers","_civilianVests","_civilianUniforms","_civilianBackpacks","_civilianFactionVests","_civilianFactionUniforms","_civPackArray","_incognitoVests","_incognitoUniforms","_incognitoFactions"];

params [["_unit",objNull]];

waitUntil {!(isNull player)};

#include "..\UCR_setup.sqf"

//Can only be run once per unit.
if ((_unit getVariable ["INC_undercoverHandlerRunning",false]) || {(!local _unit)}) exitWith {};

_unit setVariable ["INC_compromisedLoopRunning", false];
_unit setVariable ["INC_undercoverCompromised", false];
_unit setVariable ["INC_suspicious", false];
_unit setVariable ["INC_cooldown", false];
_unit setVariable ["INC_shotAt",false];
_unit setVariable ["INC_firedRecent",false];

_unit setVariable ["INC_undercoverHandlerRunning", true];

{_x setVariable ["INC_notDismissable",true]} forEach (units group _unit);

_unit setVariable ["isUndercover", true, true]; //Allow scripts to pick up sneaky units alongside undercover civilians (who do not have the isSneaky variable)

sleep 1;

if (((_debug) || {_hints}) && {isPlayer _unit}) then {hint "Undercover initialising..."};

if (isNil "INC_asymEnySide") then {

	//Initial stuff
	_civilianVests append [""];
	_civilianUniforms append [""];
	_civilianHeadgear append [""];
	_civilianBackpacks append [""];

	_civilianVests append (["vests",_civilianFactionVests] call INCON_fnc_getFactionGear);
	_civilianUniforms append (["uniforms",_civilianFactionUniforms] call INCON_fnc_getFactionGear);

	sleep 0.5;

	_civilianHeadgear append (["headgear",_civilianFactionHeadgear] call INCON_fnc_getFactionGear);
	_civilianHeadgear append (["possibleHeadgear",_civilianFactionHeadgear] call INCON_fnc_getFactionGear);
	_civilianBackpacks append _civPackArray;

	sleep 0.5;

	_incognitoVests = [""];
	_incognitoUniforms = [];
	_incognitoHeadgear = [""];
	_incognitoBackpacks = [""];
	_incognitoWpns = [""];

	_incognitoVests append (["vests",_incognitoFactions] call INCON_fnc_getFactionGear);
	_incognitoUniforms append (["uniforms",_incognitoFactions] call INCON_fnc_getFactionGear);
	_incognitoWpns append (["weapons",_incognitoFactions] call INCON_fnc_getFactionGear);

	sleep 0.5;

	_incognitoHeadgear append (["headgear",_incognitoFactions] call INCON_fnc_getFactionGear);
	_incognitoHeadgear append (["possibleHeadgear",_incognitoFactions] call INCON_fnc_getFactionGear);
	_incognitoBackpacks append (["backpacks",_incognitoFactions] call INCON_fnc_getFactionGear);

	sleep 0.5;

	missionNamespace setVariable ["INC_civilianVests",_civilianVests,true];
	missionNamespace setVariable ["INC_civilianUniforms",_civilianUniforms,true];
	missionNamespace setVariable ["INC_civilianHeadgear",_civilianHeadgear,true];
	missionNamespace setVariable ["INC_civilianBackpacks",_civilianBackpacks,true];
	missionNamespace setVariable ["INC_incognitoVests",_incognitoVests,true];
	missionNamespace setVariable ["INC_incognitoUniforms",(_incognitoUniforms - [""]),true];
	missionNamespace setVariable ["INC_incognitoWpns",_incognitoWpns,true];
	missionNamespace setVariable ["INC_incognitoBackpacks",_incognitoBackpacks,true];
	missionNamespace setVariable ["INC_incognitoHeadgear",_incognitoHeadgear,true];
	missionNamespace setVariable ["INC_incognitoVehArray",_incognitoVehArray,true];
	missionNamespace setVariable ["INC_civilianVehicleArray",_civilianVehicleArray,true];
	missionNamespace setVariable ["INC_regEnySide",_regEnySide,true];
	missionNamespace setVariable ["INC_asymEnySide",_asymEnySide,true];
	missionNamespace setVariable ["INC_civilianRecruitEnabled",_civRecruitEnabled,true];

	sleep 0.5;

	missionNamespace setVariable ["INC_sunrise",((date call BIS_fnc_sunriseSunsetTime) select 0),true];
	missionNamespace setVariable ["INC_sunset",((date call BIS_fnc_sunriseSunsetTime) select 1),true];

	_daylightDuration = INC_sunset - INC_sunrise;
	_lightFactor = _daylightDuration / 24;

	missionNamespace setVariable ["INC_firstLight",(INC_sunrise - _lightFactor),true];
	missionNamespace setVariable ["INC_lastLight",(INC_sunset + _lightFactor),true];

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
	};

	sleep 0.5;

	//Spawn the rebel commader
	[_unit,"spawnRebelCommander"] remoteExecCall ["INCON_fnc_ucrMain",2];
};

sleep 0.5;

[_unit, true] remoteExec ["setCaptive", _unit]; //Makes enemies not hostile to the unit

if (isPlayer _unit) then {
	//Group persistence
	if ((_persistentGroup) && {!(isNil "INCON_fnc_groupPersist")}) then {
		["loadGroup",_unit] call INCON_fnc_groupPersist;
		["saveGroup",_unit] call INCON_fnc_groupPersist;
	};

	//Add respawn eventhandler so all scripts work properly on respawn
	_unit addMPEventHandler ["MPRespawn",{
		_this spawn {
	        params ["_unit"];
			_unit setVariable ["INC_undercoverHandlerRunning", false];
			_unit setVariable ["INC_undercoverLoopsActive", false];
			_unit setVariable ["INC_compromisedLoopRunning", false];
			_unit setVariable ["INC_undercoverCompromised", false];
			_unit setVariable ["INC_suspicious", false];
			_unit setVariable ["INC_cooldown", false];
			sleep 1;
			[[_unit], "INC_undercover\initUCR.sqf"] remoteExec ["execVM",_unit];
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
				_unit globalChat (format ["%1 cover intact: %2",_unit,(captive _unit)]);
				_unit globalChat (format ["%1 compromised: %2",_unit,(_unit getVariable ["INC_undercoverCompromised",false])]);
				_unit globalChat (format ["%1 trespassing: %2",_unit,((_unit getVariable ["INC_proxAlert",false]) || {(_unit getVariable ["INC_trespassAlert",false])})]);
				_unit globalChat (format ["%1 suspicious level: %2",_unit,(_unit getVariable ["INC_suspiciousValue",false])]);
				_unit globalChat (format ["%1 weirdo level: %2",_unit,(_unit getVariable ["INC_disguiseValue",1])]);
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
				if !(_x getVariable ["isSneaky",false]) then {
					sleep 0.2;
					[_x] execVM "INC_undercover\initUCR.sqf";
					sleep 0.2;
					_x setVariable ["noChanges",true,true];
					_x setVariable ["isUndercover", true, true];
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
		!(_unit getVariable ["INC_undercoverCompromised",false]);
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

	[_unit] remoteExecCall ["INCON_fnc_undercoverCooldown",_unit]; //Gets the cooldown script going

	//While he's acting suspiciously
	while {
		sleep 1;
		(((_unit getVariable ["INC_suspiciousValue",1]) >= 2) && {!(_unit getVariable ["INC_undercoverCompromised",false])}) //While not compromised and either armed or trespassing
	} do {
		if (
			((_unit getVariable ["INC_suspiciousValue",1]) >= 3) &&
			{(_unit getVariable ["INC_AnyKnowsSO",false])}
		) then {
			private _regAlerted = [INC_regEnySide,_unit,50] call INCON_fnc_countAlerted;
			private _asymAlerted = [INC_asymEnySide,_unit,50] call INCON_fnc_countAlerted;

			//Once people know exactly where he is, who he is, and that he is both armed and trespassing, make him compromised
			if ((_regAlerted != 0) || {(_asymAlerted != 0)}) exitWith {

				[_unit] remoteExecCall ["INCON_fnc_undercoverCompromised",_unit];
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
