/* ----------------------------------------------------------------------------
Function: compromised

Description:

Runs the compromised loop on the given unit.

If the unit is on foot, this sets captive off (returning the unit to his original side) and runs a cooldown which ends once a timer runs out or nobody knows about the undercover unit anymore, whichever happens first. After the cooldown, if any enemy units know about him still, the unit will remain compromised until he either changes disguise (out of sight of the enemy) or no living asymetric enemies know about him and regular knowsabout is less than 1.8 (if compromised by regular forces).

If the unit is in a vehicle, it runs a foot-only version of the compromised script on any units known to enemies in the vehicle and sets the vehicle as INC_naughtyVehicle = true, which is then picked up by the armed script and used to setcaptive false on the vehicle driver. After a cooldown or when no enemies know about the vehicle, if no enemies know about the vehicle, it sets INC_naughtyVehicle to false.

Parameters:
0: Unit <OBJECT>
1: Force compromised on foot units <BOOL>

Returns: Nil

Examples:

[_unit] call INCON_ucr_fnc_compromised;

Author: Incontinentia
---------------------------------------------------------------------------- */

params ["_unit",["_foot",false]];

#include "..\UCR_setup.sqf"

//Vehicle compromised loop
if ((!isNull objectParent _unit) && {!_foot}) exitWith {

	_activeVeh = (vehicle _unit);

	if (_activeVeh getVariable ["INC_naughtyVehicle",false]) exitWith {}; //Stops multiple instances of the code being ran on the unit

	if ((_debug) && {isPlayer _unit}) then {hint "Your vehicle has been compromised."};

	_suspiciousEnemies = ((_unit nearEntities [["Man","Car"],150]) select {
		((side _x == INC_regEnySide) || {side _x == INC_asymEnySide}) &&
		{((_x getHideFrom (_activeVeh)) distanceSqr _unit < 10)} &&
		{((_unit getVariable ["INC_disguiseValue",1])) > (random 100)}
	});

	private _eny = selectRandom _suspiciousEnemies;

	if (!isNil "_eny") then {

		[_eny,[_unit,2.5]] remoteExec ["reveal",_eny];
	};

	[_unit,true] call INCON_ucr_fnc_compromised;

	if !(_activeVeh getVariable ["INC_naughtyVehicle",false]) then {

		_activeVeh setVariable ["INC_naughtyVehicle",true];

		[_activeVeh] spawn {
			params ["_activeVeh"];

			private ["_vehSpotted"];

			_vehSpotted = false;

			_cooldownTimer = 270;
			sleep 30;

			waitUntil {
				sleep 10;
				_cooldownTimer = (_cooldownTimer - 10);

				if (

					([_activeVeh,INC_regEnySide,15] call INCON_ucr_fnc_isKnownExact) ||
					{([_activeVeh,INC_asymEnySide,15] call INCON_ucr_fnc_isKnownExact)}

				) then {

					_vehSpotted = true;
					_activeVeh setVariable ["INC_naughtyVehicle",true];
				};

				(!(([_activeVeh,INC_regEnySide,true] call INCON_ucr_fnc_isKnownToSide) || {[_activeVeh,INC_asymEnySide,true] call INCON_ucr_fnc_isKnownToSide}) || {_cooldownTimer <= 0})
			};

			//If the vehicle is no longer known when the timer runs out, set it to be uncompromised
			if !(_cooldownTimer <= 0) then {

				_activeVeh setVariable ["INC_naughtyVehicle",false];

				if ((_debug) && {isPlayer _unit}) then {hint "Vehicle no longer compromised."};
			};
		};
	};
};

if (_unit getVariable ["INC_isCompromised",false]) exitWith {}; //Stops multiple instances of the code being ran on the unit

if ((_debug) && {isPlayer _unit}) then {hint "You've been compromised."};

//Compromised loop
[_unit,_debug] spawn {

	params ["_unit",["_debug",false]];

	private ["_seenInDisguise","_naughtyUniforms","_naughtyHeadgears","_activeVeh","_regKnowsAboutUnit","_lastSeenLoc"];

	// Publicize isCompromised variable to true.
	_unit setVariable ["INC_isCompromised", true];

	//Checks if INC_regEnySide has seen him recently and sets variables accordingly
	_regKnowsAboutUnit = [_unit,INC_regEnySide,50] call INCON_ucr_fnc_isKnownExact;

	// SetCaptive after suspicious act has been committed
	[_unit, false] remoteExec ["setCaptive", _unit];

	_naughtyUniforms = [];
	_naughtyHeadgears = [];
	_seenInDisguise = false;
	_activeVeh = objNull;
	_lastSeenLoc = getPosWorld _unit;

	sleep 30;

	// Cooldown Timer to simulate how long it would take for word to get out
	_cooldownTimer = random 180;

	//If unit changes clothing / vehicle while seen then the description to be shared is updated
	waitUntil {

		sleep 10;

		_cooldownTimer = (_cooldownTimer - 5);

		if (

			([_unit,INC_regEnySide,10] call INCON_ucr_fnc_isKnownExact) ||
			{([_unit,INC_asymEnySide,10] call INCON_ucr_fnc_isKnownExact)}

		) then {

			_lastSeenLoc = getPosWorld _unit;

			switch (isNull objectParent _unit) do {

				case (true): {

					if (uniform _unit in INC_incogUniforms || {uniform _unit in INC_civilianUniforms}) then {
						if (50 > random 100) then {
							_naughtyUniforms pushBackUnique (uniform _unit);
							_seenInDisguise = true;
						};
					};

					if (20> random 100) then {_naughtyHeadgears pushBackUnique (headgear _unit)};
					if (10> random 100) then {_naughtyHeadgears pushBackUnique (goggles _unit)};
				};

				case (false): {

					if (uniform _unit in INC_incogUniforms || {uniform _unit in INC_civilianUniforms}) then {
						if (20 > random 100) then {
							_naughtyUniforms pushBackUnique (uniform _unit);
							_seenInDisguise = true;
						};
					};

					if (70 > random 100) then {_activeVeh = objectParent _unit};
					if (10 > random 100) then {_naughtyHeadgears pushBackUnique (headgear _unit)};
					if (5 > random 100) then {_naughtyHeadgears pushBackUnique (goggles _unit)};
				};
			};
		};

		((!(_unit getVariable ["INC_AnyKnowsSO",false]) && {isNull objectParent _unit || {!((objectParent _unit) getVariable ["INC_naughtyVehicle",false]) && {_cooldownTimer <= 0}}}) || {_cooldownTimer <= 0})
	};

	//If there are still alerted units alive...
	if (_unit getVariable ["INC_AnyKnowsSO",false]) then {

		switch (true) do {
			case ([_unit,INC_regEnySide,50] call INCON_ucr_fnc_isKnownExact): {
				{[_x,[_unit,3]] remoteExec ["reveal",_x]} forEach (
					(_unit nearEntities 1500) select {
						(side _x == INC_regEnySide) &&
						{"itemRadio" in assignedItems _x}
					}
				);

				if !(_regKnowsAboutUnit) then {

					_regKnowsAboutUnit = true;
				};
			};

			case ([_unit,INC_asymEnySide,50] call INCON_ucr_fnc_isKnownExact): {
				{[_x,[_unit,2]] remoteExec ["reveal",_x]} forEach (
					(_unit nearEntities 800) select {
						(side _x == INC_asymEnySide) &&
						{"itemRadio" in assignedItems _x}
					}
				);
			};
		};

		private ["_unitUniform","_unitGoggles","_unitHeadgear","_compUniform","_compHeadGear","_compVeh"];

		if ((_debug) && {isPlayer _unit}) then {hint "Your description has been shared."};

		//Shares last known vehicle if there is one
		if (!isNull _activeVeh) then {
			_activeVeh setVariable ["INC_naughtyVehicle",true];
			_compVeh = (_unit getVariable ["INC_compVehs",[]]);
			_compVeh pushBackUnique _activeVeh;
			_unit setVariable ["INC_compVehs",_compVeh];
		};

		//Shares compromised uniforms and items, as well as last seen location
		_compUniform = (_unit getVariable ["INC_compUniforms",[]]);
		{_compUniform pushBackUnique _x} forEach _naughtyUniforms;
		_unit setVariable ["INC_compUniforms",_compUniform];
		_unit setVariable ["INC_compUniform",_naughtyUniforms];
		_compHeadGear = (_unit getVariable ["INC_compHeadGear",[]]);
		{_compHeadGear pushBackUnique _x} forEach _naughtyHeadgears;
		_unit setVariable ["INC_compHeadGear",_compHeadGear];
		_unit setVariable ["INC_lastSeenLoc",_lastSeenLoc];

		// Wait until nobody knows nuffing and the unit isn't being naughty (or has changed disguise)
		waituntil {

			_compUniform = (_unit getVariable ["INC_compUniforms",[]]);
			_compHeadGear = (_unit getVariable ["INC_compHeadGear",[]]);
			_compVeh = (_unit getVariable ["INC_compVehs",[]]);

			//Sets last seen location for units in vehicles
			if (!isNull objectParent _unit) then {
				_activeVeh = (vehicle _unit);
				if !(

					([_unit, INC_regEnySide,10] call INCON_ucr_fnc_isKnownExact) &&
					{([_unit, INC_asymEnySide,10] call INCON_ucr_fnc_isKnownExact)}

				) then {
					_activeVeh setVariable ["INC_naughtyVehicle",true];
					_lastSeenLoc = getPosWorld _unit;
					_unit setVariable ["INC_lastSeenLoc",_lastSeenLoc];
				}
			};

			sleep 5;
			sleep 2;

			//Sets last seen location, compromised gear for units on foot
			if (

				!(uniform _unit in _compUniform) &&
				{!(goggles _unit in _compHeadGear) || {!(headgear _unit in _compHeadGear)} || {!(vehicle _unit in _compVeh)}} &&
				{((!isNull objectParent _unit) && {!((vehicle _unit) getVariable ["INC_naughtyVehicle",false])}) || {isNull objectParent _unit}}
			) then {

				if (

					([_unit,INC_regEnySide,15] call INCON_ucr_fnc_isKnownExact) ||
					{([_unit,INC_asymEnySide,15] call INCON_ucr_fnc_isKnownExact)}
				) then {

					if (uniform _unit in INC_incogUniforms || {uniform _unit in INC_civilianUniforms}) then {_seenInDisguise = true};

					_lastSeenLoc = getPosWorld _unit;
					_unit setVariable ["INC_lastSeenLoc",_lastSeenLoc];

					_compUniform pushBackUnique (uniform _unit);
					_unit setVariable ["INC_compUniforms",_compUniform];

					_compHeadGear pushBackUnique (goggles _unit);
					_compHeadGear pushBackUnique (headgear _unit);
					_unit setVariable ["INC_compHeadGear",_compHeadGear];
				} else {

					_unit setVariable ["INC_disguiseChanged",true];
				};
			};


			sleep 2;

			if (

				((_unit getVariable ["INC_disguiseChanged",false]) && {(80 > (random 100))})

			) exitWith {

				private ["_disguiseValue","_newDisguiseValue"];

				if ((_debug) && {isPlayer _unit}) then {hint "Disguise changed."};

				_disguiseValue = (_unit getVariable ["INC_compromisedValue",1]);

				//Limits the maximum weirdness level and does not add any if the unit hasn't tried to go incognito
				//Limits the maximum weirdness level and does not add any if the unit hasn't tried to go incognito. Also adds weirdness depending on whether the unit changed disguises in last seen location.
				if (_disguiseValue < 5 || {!_seenInDisguise}) then {
					if (

						([_unit,INC_regEnySide,55] call INCON_ucr_fnc_isKnownExact) ||
						{([_unit,INC_asymEnySide,75] call INCON_ucr_fnc_isKnownExact)}

					) then {

						_newDisguiseValue = _disguiseValue + (random 3);
					};

					_newDisguiseValue = _disguiseValue + (random 1);
				} else {
					_newDisguiseValue = _disguiseValue;
				};

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

		if ((_debug) && {isPlayer _unit}) then {hint "No longer compromised."};

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

		if ((_debug) && {isPlayer _unit}) then {hint "No longer compromised."};

		// Cooldown
		[_unit] call INCON_ucr_fnc_cooldown;

	};
};
