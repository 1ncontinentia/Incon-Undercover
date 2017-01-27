/*
cooldown

Author: Incontinentia

Executes a cooldown after a unit has started doing something suspicious.
Returns unit to setcaptive once the detecting side/s (if any) have lost track of the unit, providing the unit isn't compromised by then.

Arguments
_unit

*/

params ["_unit"];

//Run the script locally on unit's machine
//if (!local _unit) exitWith {};

//Code can't be run on a unit that it's already running on
if ((_unit getVariable ["INC_cooldown",false]) || {!local _unit}) exitWith {};

_unit setVariable ["INC_cooldown", true];

[_unit,_debug] spawn {

	params ["_unit",["_debug",false]];

	private ["_asymKnowsAboutUnit","_regKnowsAboutUnit","_regAlerted","_asymAlerted"];

	//Holding variable while unit is armed / trespassing
	waitUntil {
		sleep 1;
		!(_unit getVariable ["INC_suspicious",false])
	};

	//Stop the script running while the unit is compromised
	waitUntil {
		sleep 2;
		!((_unit getVariable ["INC_isCompromised",false]) || {(_unit getVariable ["INC_suspiciousValue",1]) >= 2});
	};

	//Checks if INC_regEnySide has seen him recently and sets variables accordingly
	_regAlerted = [INC_regEnySide,_unit,50] call INCON_fnc_countAlerted;
	if (_regAlerted != 0) then {
		_regKnowsAboutUnit = true;
	} else {
		_regKnowsAboutUnit = false;
	};


	//Checks if INC_asymEnySide has seen him recently
	_asymAlerted = [INC_asymEnySide,_unit,50] call INCON_fnc_countAlerted;
	if (_asymAlerted != 0) then {
		_asymKnowsAboutUnit = true;
	} else {
		_asymKnowsAboutUnit = false;
	};

	if ((isPlayer _unit) && (_debug)) then {hint "Cooldown active."};

	//SetsCaptive back to true if nobody has seen him, unless he is already compromised
	if !((_asymKnowsAboutUnit) || {_regKnowsAboutUnit}) exitWith {

		if !((_unit getVariable ["INC_isCompromised",false]) || {(_unit getVariable ["INC_suspiciousValue",1]) >= 2}) then {
			[_unit, true] remoteExec ["setCaptive", _unit];
		};

		if (_debug && (isPlayer _unit)) then {hint "Cooldown complete."};

		_unit setVariable ["INC_cooldown", false, true];
	};

	//If both INC_regEnySide and INC_asymEnySide know about the unit, wait until neither does.
	if ((_asymKnowsAboutUnit) && {_regKnowsAboutUnit}) exitWith {

		waitUntil {
			sleep 2;
			(!(_unit getVariable ["INC_anyKnowsSO",false]) && {!((_unit getVariable ["INC_suspiciousValue",1]) >= 2)} && {!(_unit getVariable ["INC_isCompromised",false])})
		};

		if !(_unit getVariable ["INC_isCompromised",false]) then {
			[_unit, true] remoteExec ["setCaptive", _unit];
		};

		_unit setVariable ["INC_cooldown", false, true];

	};

	//If only INC_asymEnySide knows about the unit, wait until they no longer do.
	if (_asymKnowsAboutUnit) then {

		waitUntil {
			sleep 10;
			(!(_unit getVariable ["INC_asymKnowsSO",false]) && {!((_unit getVariable ["INC_suspiciousValue",1]) >= 2)} && {!(_unit getVariable ["INC_isCompromised",false])})
		};

	//Otherwise, only INC_regEnySide knows about the unit so wait until they no longer do.
	} else {

		waitUntil {
			sleep 10;
			(!(_unit getVariable ["INC_regKnowsSO",false]) && {!((_unit getVariable ["INC_suspiciousValue",1]) >= 2)} && {!(_unit getVariable ["INC_isCompromised",false])})
		};

		//Percentage chance that unit will become compromised anyway
		if ((45 > (random 100)) && {((INC_regEnySide knowsAbout _unit) > 3)}) then {

			[_unit] call INCON_fnc_compromised;
		};
	};

	//Then set captive back to true as long as the isCompromised loop isn't running
	if !(_unit getVariable ["INC_isCompromised",false]) then {
		[_unit, true] remoteExec ["setCaptive", _unit];
	};

	if (_debug && (isPlayer _unit)) then {hint "Cooldown complete."};

	//Allow the loop to be run again on the unit
	_unit setVariable ["INC_cooldown", false, true];
};
