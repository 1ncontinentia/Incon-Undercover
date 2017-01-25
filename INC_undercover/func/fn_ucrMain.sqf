/*

Civilian Recruitment / Arming

Author: Incontinentia

*/


params [["_input",objNull],["_operation","addConcealedRifle"]];

private ["_return"];

_return = false;

#include "..\UCR_setup.sqf"

switch (_operation) do {

	case "spawnRebelCommander": {

		private ["_commander","_rebelGroup"];

		//private _rebelCommander = format ["INC_rebelCommander"];

		if (missionNamespace getVariable ["INC_rebelCommanderSpawned",false]) exitWith {};

		private _rebelGroup = [[(random 40),(random 40),10], _undercoverUnitSide, 1] call BIS_fnc_spawnGroup;
		_commander = leader _rebelGroup;
		_commander setRank "COLONEL";
		_commander disableAI "ALL";
		_commander enableAI "TARGET";
		_commander enableAI "FSM";
		_commander allowDamage false;
		_commander enableSimulation false;
		_commander hideObjectGlobal true;
		_commander hideObject true;
		_commander setUnitAbility 1;

		missionNamespace setVariable ["INC_rebelCommanderSpawned",true,true];

		missionNamespace setVariable ["INC_rebelCommander",_commander,true];

		_return = _commander;

	};

	case "runAway": {

		_input params ["_unit"];

		_unit doMove [
			(getPosASL _unit select 0) + (5 + (random 3) - (random 16)),
			(getPosASL _unit select 1) + (5 + (random 3)),
			getPosASL _unit select 2
		];
		_return = true;
	};

	case "addConcealActions": {

		_input params ["_unit","_groupLead",["_dismiss",true]];

		[_unit, [

			"<t color='#334FFF'>Conceal current weapon</t>", {
				params ["_unit"];

				[[_unit],"concealWeapon"] call INCON_fnc_gearHandler;

			},[],6,false,true,"","(_this == _target) && {_this getVariable ['INC_canConcealWeapon',false]}"

		]] remoteExec ["addAction", _groupLead];

		[_unit, [

			"<t color='#FF33BB'>Get concealed weapon out</t>", {
				params ["_unit"];

				[[_unit],"unConcealWeapon"] call INCON_fnc_gearHandler;

			},[],6,false,true,"","(_this == _target) && {_this getVariable ['INC_canGoLoud',false]}"

		]] remoteExec ["addAction", _groupLead];

		if (!isPlayer _unit) then {
			[[_unit,false],"SwitchUniformAction"] call INCON_fnc_ucrMain;

			[_unit, [

				"<t color='#F70707'>GROUP GO LOUD</t>", {
					params ["_unit"];

					{if ((_x getVariable ['INC_canGoLoud',false]) && {!isPlayer _x}) then {
						[[_x],"unConcealWeapon"] call INCON_fnc_gearHandler;
						(_x) setCombatMode "YELLOW";
					};} forEach (units _unit);

				},[],4,false,true,"","(_this == _target)"

			]] remoteExec ["addAction", _groupLead];
		} else {

			_unit addEventHandler ["InventoryClosed", {
				params ["_unit"];
				if ([[_unit,false],"switchUniforms"] call INCON_fnc_gearHandler) then {
					[[_unit,true,4],"SwitchUniformAction"] call INCON_fnc_ucrMain;
				};
			}];
		};

		if ((_dismiss) || {!(_unit getVariable ["INC_notDismissable",false])}) then {

			[_unit, [
				"<t color='#9933FF'>Dismiss</t>", {

					private _unit = _this select 0;
					private _civComment = selectRandom ["I'll just hang around here then I suppose.","My back is killing me anyway.","It's been a pleasure.","I'm just not cut out for this.","I'll continue our good work.","See you later.","I don't need you to have a good time.","I'm my own woman.","What time is it? I need to get high.","I've got some paperwork to do anyway.","Well thank God for that."];
					[[_unit, _civComment] remoteExec ["globalChat",0]];

					[_unit] join grpNull;
					_unit remoteExec ["removeAllActions",0];
					_unit setVariable ["isUndercover", false, true];

					_wp1 = (group _unit) addWaypoint [(getPosWorld _unit), 3];
					(group _unit) setBehaviour "SAFE";
					_wp1 setWaypointType "DISMISS";

				},[],5.8,false,true,"","((_this == _target) && (_this getVariable ['isUndercover',false]))"
			]] remoteExec ["addAction", _groupLead];
		} else {
			_unit setVariable ["INC_notDismissable",true];
		};

		_return = true;
	};

	case "profileGroup": {

		if (!(isClass(configFile >> "CfgPatches" >> "ALiVE_main")) || {!isServer}) exitWith {_return = grpNull};

		_input params ["_groupLead"];

		private ["_originalGroup","_newGroup","_nonPlayableArray","_playableArray"];

		_originalGroup = group _groupLead;

		_newGroup = createGroup _undercoverUnitSide;

		_nonPlayableArray = [];

		_playableArray = [];

		{
			if ((_x != leader group _x) && {!(_x in playableUnits)} && {!(_x getVariable ["INC_notDismissable",false])} && {count _nonPlayableArray <= 4}) then {
				_nonPlayableArray pushback _x;
				_x setCaptive false;
			};
		} forEach units _originalGroup;

		_return = [_newGroup,_playableArray,_nonPlayableArray];

		_nonPlayableArray join _newGroup;

		[_newGroup] spawn {
			params ["_newGroup"];

			sleep 5;

			{_x setCaptive false} forEach (units _newGroup);

			sleep 2;

			["",[],false,[_newGroup]] call ALiVE_fnc_CreateProfilesFromUnits;
		};
	};

	case "SwitchUniformAction": {

		_input params ["_unit",["_temporary",true],["_duration",12]];

		if (_unit getVariable ["INC_switchUniformActionActive",false]) exitWith {_return = false};

		_unit setVariable ["INC_switchUniformActionActive",true];

		INC_switchUniformAction = _unit addAction [
			"<t color='#33FF42'>Find new disguise nearby</t>", {
				params ["_unit"];

				private ["_success"];

				_success = [[_unit,true,1,true,7],"switchUniforms"] call INCON_fnc_gearHandler;

				if (_success) then {
					if (!isPlayer _unit) then {
						private _comment = selectRandom ["Found one.","Got something","This'll do","Found some new clothes.","Does my bum look big in this?","Fits nicely.","It's almost as if we're all the same dimensions.","Fits like a glove.","Beautiful.","I look like an idiot."];
						_unit groupChat _comment;
					} else {hint "Uniform changed."};
				} else {
					if (!isPlayer _unit) then {
						private _comment = selectRandom ["Which one?","I'm not sure where you want me to look.","Can you point it out a bit better?"];
						_unit groupChat _comment;
					} else {hint "No safe uniforms found nearby."};
				};

			},[],4,false,true,"","((_this == _target) && (_this getVariable ['isUndercover',false]))"
		];

		if (_temporary) then {

			[_unit,_duration] spawn {

				params ["_unit",["_timer",12]];

				waitUntil {
					sleep 3;
					_timer = _timer - 3;

					(!([[_unit,false],"switchUniforms"] call INCON_fnc_gearHandler) || {_timer <= 0})
				};

				_unit removeAction INC_switchUniformAction;

				_unit setVariable ["INC_switchUniformActionActive",false];
			};
		};

		_return = true;
	};

	case "getUnitIDs": {
		_input params ["_unit",["_checkType","face"]];
		private ["_cfgFaces"];

		switch (_checkType) do {

			case "face": {

				_cfgFaces = configFile >> "cfgFaces";

				for "_i" from 0 to (count _cfgFaces - 1) do {
			    _entry = _cfgFaces select _i;

			    if (isclass (_entry >> face _unit)) exitWith {
			        _return = (getArray (_entry >> (face _unit) >> "identityTypes"));
							true
			    };
				};
			};

			case "class": {
				_return = getArray (configFile >> "CfgVehicles" >> (typeOf _unit) >> "identityTypes");
			};

			case "full": {
				_return = ([[_unit],"getUnitIDs","class"] call INCON_fnc_ucrMain);
				{_return pushbackunique _x} forEach ([[_unit],"getUnitIDs","face"] call INCON_fnc_ucrMain);
			};
		};
	};

	case "factionIDcheck": {

		_input params ["_unit",["_factions",["OPF_F"]],["_checkType","full"],["_simpleCheck",true]];

		private ["_factionIDs","_unitIDs","_overlappingIDs"];

		_overlappingIDs = [];

		_factionIDs = (["possibleIdentities",_factions] call INCON_fnc_getConfigInfo);

		_unitIDs = [[_unit],"getUnitIDs",_checkType] call INCON_fnc_ucrMain;

		switch (_simpleCheck) do {
			case true: {
				{if (_x in _factionIDs) exitWith {_return = true}} forEach _unitIDs;
			};
			case false: {
				{if (_x in _factionIDs) then {_overlappingIDs pushbackunique _x}} forEach _unitIDs;
				_return = _overlappingIDs;
			};
		};
	};
};

_return
