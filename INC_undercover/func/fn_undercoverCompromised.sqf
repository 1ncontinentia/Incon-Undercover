/*
Changes the _percentage number of units of a given side to side enemy. Useful for simulating internal conflict.

Arguments

_unit: The compromised unit
_regEnySide: Regular / conventional enemy side
_asymEnySide: Asymmetric enemy side (doesn't remember as long due to lack of information sharing between cells)


Conditions to be met first:

1. Unit has killed an enemy while spotted (killed eventhandler)

2. Unit has killed several enemies while not spotted but known about (killed eventhandler)

3. Unit has been spotted while armed and trespassing

4: Unit has been seen shooting (fired EH)


Order of events:

Unit is hostile for a cooldown period.

Once cooldown period is over, if there are still alerted units, unit becomes wanted.

Wanted level will only descrease when nobody knows about the unit anymore (alerted units = 0 and knowsabout = 0).


*/


params ["_unit",["_regEnySide",sideEmpty],["_asymEnySide",sideEmpty]];

#include "..\UCR_setup.sqf"

if ((_debug) && {isPlayer _unit}) then {hint "You've been compromised."};

if (_unit getVariable ["INC_compromisedLoopRunning",false]) exitWith {}; //Stops multiple instances of the code being ran on the unit

//Compromised loop
[_unit,_regEnySide,_asymEnySide,_debug] spawn {

	params ["_unit",["_regEnySide",sideEmpty],["_asymEnySide",sideEmpty],["_debug",false]];

	private ["_activeVeh"];

	_unit setVariable ["INC_compromisedLoopRunning", true];

	// Publicize undercoverCompromised variable to true. This prevents other scripts from setting captive while unit is still compromised.
	_unit setVariable ["INC_undercoverCompromised", true];

	// SetCaptive after suspicious act has been committed
	[_unit, false] remoteExec ["setCaptive", _unit];

	if (!isNull objectParent _unit) then {
		_activeVeh = (vehicle _unit);
		_activeVeh setVariable ["INC_naughtyVehicle",true];
	};

	// Cooldown Timer to simulate how long it would take for word to get out
	_cooldownTimer = (30 + (random 240));
	sleep _cooldownTimer;


	//If there are still alerted units alive...
	if (_unit getVariable ["INC_AnyKnowsSO",false]) then {

		private ["_unitUniform","_unitGoggles","_unitHeadgear","_compUniform","_compHeadGear","_compVeh"];

		if (_debug) then {hint "Your description has been shared."};

		if (!isNull objectParent _unit) then {
			_activeVeh = (vehicle _unit);
			_activeVeh setVariable ["INC_naughtyVehicle",true];
		};

		_compVeh = (_unit getVariable ["INC_compVehs",[]]);
		_compVeh pushBackUnique (vehicle _unit);
		_unit setVariable ["INC_compVehs",_compVeh];

		_compUniform = (_unit getVariable ["INC_compUniforms",[]]);
		_compUniform pushBackUnique (uniform _unit);
		_unit setVariable ["INC_compUniforms",_compUniform];
		_unit setVariable ["INC_compUniform",(uniform _unit)];

		_compHeadGear = (_unit getVariable ["INC_compHeadGear",[]]);
		_compHeadGear pushBackUnique (goggles _unit);
		_compHeadGear pushBackUnique (headgear _unit);
		_unit setVariable ["INC_compHeadGear",_compHeadGear];

		// Wait until nobody knows nuffing and the unit isn't being naughty (or has changed disguise)
		waituntil {

			_compUniform = (_unit getVariable ["INC_compUniforms",[]]);
			_compHeadGear = (_unit getVariable ["INC_compHeadGear",[]]);
			_compVeh = (_unit getVariable ["INC_compVehs",[]]);


			if (!isNull objectParent _unit) then {
				_activeVeh = (vehicle _unit);
				if !(

					(([_regEnySide,_unit,10] call INCON_fnc_countAlerted) == 0) &&
					{(([_asymEnySide,_unit,10] call INCON_fnc_countAlerted) == 0)}

				) then {
					_activeVeh setVariable ["INC_naughtyVehicle",true];
				}
			};

			sleep 5;

			if (
				!(uniform _unit in _compUniform) &&
				{!(goggles _unit in _compHeadGear) || {!(headgear _unit in _compHeadGear)} ||  {!(vehicle _unit in _compVeh)}} &&
				{((!isNull objectParent _unit) && {!((vehicle _unit) getVariable ["INC_naughtyVehicle",false])}) || {isNull objectParent _unit}}

			) then {

				if (

					(([_regEnySide,_unit,30] call INCON_fnc_countAlerted) == 0) &&
					{(([_asymEnySide,_unit,30] call INCON_fnc_countAlerted) == 0)}

				) then {

					_unit setVariable ["INC_disguiseChanged",true];
				} else {

					_compUniform pushBackUnique (uniform _unit);
					_unit setVariable ["INC_compUniforms",_compUniform];

					_compHeadGear pushBackUnique (goggles _unit);
					_compHeadGear pushBackUnique (headgear _unit);
					_unit setVariable ["INC_compHeadGear",_compHeadGear];
				};
			};


			sleep 3;

			if (

				((_unit getVariable ["INC_disguiseChanged",false]) && {(80 > (random 100))})

			) exitWith {

				private ["_disguiseValue","_newDisguiseValue"];

				if (_debug) then {hint "Disguise changed."};

				_disguiseValue = (_unit getVariable ["INC_compromisedValue",1]);

				_newDisguiseValue = _disguiseValue + (random 1);

				_unit setVariable ["INC_compromisedValue",_newDisguiseValue,true];

				_unit setVariable ["INC_disguiseChanged",false,true];

				true
			};

			sleep 1;

			(
				(!(_unit getVariable ["INC_AnyKnowsSO",false]) && {(1.8 > (_regEnySide knowsAbout _unit))}) ||
				{!alive _unit}
			);
		};

		// Publicize undercoverCompromised to false.
		_unit setVariable ["INC_undercoverCompromised", false];

		if (_debug) then {hint "Disguise intact."};

		// Cooldown
		[_unit,_regEnySide,_asymEnySide] remoteExecCall ["INCON_fnc_undercoverCooldown",_unit];

		private ["_disguiseValue","_newDisguiseValue"];

		_disguiseValue = (_unit getVariable ["INC_compromisedValue",1]);

		_newDisguiseValue = _disguiseValue + (random 1.5);

		_unit setVariable ["INC_compromisedValue",_newDisguiseValue,true];

		_unit setVariable ["INC_disguiseChanged",false,true];

	//Otherwise he is no longer compromised
	} else {

		if !(isNil "_activeVeh") then {_activeVeh setVariable ["INC_naughtyVehicle",false]};

		// Publicize undercoverCompromised to false.
		_unit setVariable ["INC_undercoverCompromised", false];

		if (_debug) then {hint "Disguise intact."};

		// Cooldown
		[_unit,_regEnySide,_asymEnySide] remoteExecCall ["INCON_fnc_undercoverCooldown",_unit];

	};

	//Allow the loop to run again
	_unit setVariable ["INC_compromisedLoopRunning", false];

};
