/* ----------------------------------------------------------------------------
Function: compromised

Description:

Runs the compromised loop on the given unit. This sets captive off (returning the unit to his original side) and runs a cooldown which ends once a timer runs out or nobody knows about the undercover unit anymore, whichever happens first. After the cooldown, if any enemy units know about him still, the unit will remain compromised until he either changes disguise (out of sight of the enemy) or no living asymetric enemies know about him and regular knowsabout is less than 1.8 (if compromised by regular forces).

Parameters:
0: Unit <OBJECT>

Returns: Nil

Examples:

[_unit] call INCON_ucr_fnc_compromised;

Author: Incontinentia
---------------------------------------------------------------------------- */

params ["_unit"];

#include "..\UCR_setup.sqf"

if ((_debug) && {isPlayer _unit}) then {hint "You've been compromised."};

if (_unit getVariable ["INC_isCompromised",false]) exitWith {}; //Stops multiple instances of the code being ran on the unit

//Compromised loop
[_unit,_debug] spawn {

	params ["_unit",["_debug",false]];

	private ["_activeVeh","_regKnowsAboutUnit"];

	// Publicize isCompromised variable to true.
	_unit setVariable ["INC_isCompromised", true];

	//Checks if INC_regEnySide has seen him recently and sets variables accordingly
	_regKnowsAboutUnit = [_unit,INC_regEnySide,50] call INCON_ucr_fnc_isKnownExact;

	// SetCaptive after suspicious act has been committed
	[_unit, false] remoteExec ["setCaptive", _unit];

	if (!isNull objectParent _unit) then {
		_activeVeh = (vehicle _unit);
		_activeVeh setVariable ["INC_naughtyVehicle",true];
		{[_x] call INCON_ucr_fnc_compromised} forEach ((units _unit) select {(_x distance _unit) < 8});
	};

	// Cooldown Timer to simulate how long it would take for word to get out
	_cooldownTimer = (30 + (random 240));
	sleep 30;

	waitUntil {
		sleep 3;
		_cooldownTimer = (_cooldownTimer - 3);
		(!(_unit getVariable ["INC_AnyKnowsSO",false]) || {_cooldownTimer <= 0})
	};

	if !(_regKnowsAboutUnit) then {

		//Checks if INC_regEnySide has seen him recently
		_regKnowsAboutUnit = [_unit,INC_regEnySide,250] call INCON_ucr_fnc_isKnownExact;
	};

	//If there are still alerted units alive...
	if (_unit getVariable ["INC_AnyKnowsSO",false]) then {

		switch (true) do {
			case ([_unit,INC_regEnySide] call INCON_ucr_fnc_isKnownToSide): {
				{[_x,[_unit,3]] remoteExec ["reveal",_x]} forEach (
					(_unit nearEntities 1500) select {
						(side _x == INC_regEnySide)
					};
				);
			};

			case ([_unit,INC_asymEnySide] call INCON_ucr_fnc_isKnownToSide): {
				{[_x,[_unit,2]] remoteExec ["reveal",_x]} forEach (
					(_unit nearEntities 800) select {
						(side _x == INC_asymEnySide) &&
						{"itemRadio" in assignedItems _x}
					};
				);
			};
		};

		private ["_unitUniform","_unitGoggles","_unitHeadgear","_compUniform","_compHeadGear","_compVeh"];

		if ((_debug) && {isPlayer _unit}) then {hint "Your description has been shared."};

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

					([_unit, INC_regEnySide,10] call INCON_ucr_fnc_isKnownExact) &&
					{([_unit, INC_asymEnySide,10] call INCON_ucr_fnc_isKnownExact)}

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

					([_unit,INC_regEnySide,40] call INCON_ucr_fnc_isKnownExact) &&
					{([_unit,INC_asymEnySide,40] call INCON_ucr_fnc_isKnownExact)}

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

				if ((_debug) && {isPlayer _unit}) then {hint "Disguise changed."};

				_disguiseValue = (_unit getVariable ["INC_compromisedValue",1]);

				_newDisguiseValue = _disguiseValue + (random 1);

				_unit setVariable ["INC_compromisedValue",_newDisguiseValue,true];

				_unit setVariable ["INC_disguiseChanged",false,true];

				true
			};

			sleep 1;

			(
				(!(_unit getVariable ["INC_AnyKnowsSO",false]) && {(1.8 > (INC_regEnySide knowsAbout _unit)) || {!_regKnowsAboutUnit}}) ||
				{!alive _unit}
			);
		};

		// Publicize isCompromised to false.
		_unit setVariable ["INC_isCompromised", false];

		if ((_debug) && {isPlayer _unit}) then {hint "Disguise intact."};

		// Cooldown
		[_unit] call INCON_ucr_fnc_cooldown;

		private ["_disguiseValue","_newDisguiseValue"];

		_disguiseValue = (_unit getVariable ["INC_compromisedValue",1]);

		_newDisguiseValue = _disguiseValue + (random 1.5);

		_unit setVariable ["INC_compromisedValue",_newDisguiseValue,true];

		_unit setVariable ["INC_disguiseChanged",false,true];

	//Otherwise he is no longer compromised
	} else {

		if !(isNil "_activeVeh") then {_activeVeh setVariable ["INC_naughtyVehicle",false]};

		// Publicize isCompromised to false.
		_unit setVariable ["INC_isCompromised", false];

		if ((_debug) && {isPlayer _unit}) then {hint "Disguise intact."};

		// Cooldown
		[_unit] call INCON_ucr_fnc_cooldown;

	};
};
