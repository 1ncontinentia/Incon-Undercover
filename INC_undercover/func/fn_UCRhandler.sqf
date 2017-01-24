/*
Checks for:
Suspicious behaviour
Weird behaviour
Nearby enemies who could blow the unit's cover

Creates:
Loops for all checks
Environmental loop
Eventhandlers that auto compromise the unit if seen shooting
*/


params [["_unit",objNull],["_operation","armedLoop"]];

#include "..\UCR_setup.sqf"

if ((_unit getVariable ["INC_undercoverLoopsActive",false]) || {(!local _unit)}) exitWith {};

_unit setVariable ["INC_undercoverLoopsActive", true]; // Stops the script running twice on the same unit

_unit setVariable ["INC_proxAlert",false]; //Proximity
_unit setVariable ["INC_trespassAlert",false]; //Trespassing
_unit setVariable ["INC_suspiciousValue", 1]; //How suspicious is the unit
_unit setVariable ["INC_weirdoLevel",1]; //How weird is the unit acting
_unit setVariable ["INC_weaponStore",[["",[""]],["",[""]]]];

if (isPlayer _unit) then {
	[[_unit,_unit,false],"addConcealActions"] call INCON_fnc_ucrMain;
};


//Proximity / Trespass Stuff - sets variables to be picked up by armed/suspicious loop
//=======================================================================//
[_unit,_regDetectRadius,_asymDetectRadius] spawn {
	params [["_unit",player],["_regDetectRadius",15],["_asymDetectRadius",25],["_radius3",60],["_radius4",200]];

	private ["_nearReg","_nearAsym","_nearHVT","_nearSuperHVT","_nearMines"];

	waitUntil {

		//Proximity check for players (doesn't run if the unit is compromised)
		if (isPlayer _unit) then {

			private ["_disguiseValue"];

			_disguiseValue = ((_unit getVariable ["INC_compromisedValue",1]) * (_unit getVariable ["INC_weirdoLevel",1]) * (missionNamespace getVariable ["INC_envDisgMulti",1]));

			sleep 0.5;

			_unit setVariable ["INC_disguiseValue",_disguiseValue];

			switch (_unit getVariable ["INC_goneIncognito",false]) do {

				case true: {

					_nearReg = count (
						(_unit nearEntities ((_regDetectRadius * _disguiseValue) * 0.7)) select {
							(side _x == INC_regEnySide) &&
							{((_x getHideFrom _unit) distanceSqr _unit < 10)} &&
							{(_x knowsAbout _unit) > 3.5} &&
							{alive _x} &&
							{(5 + (2 * _disguiseValue)) > (random 100)}
						}
					);

					sleep 0.5;

					_nearAsym = count (
						(_unit nearEntities ((_asymDetectRadius * _disguiseValue) * 2)) select {
							(side _x == INC_asymEnySide) &&
							{((_x getHideFrom _unit) distanceSqr _unit < 10)} &&
							{(_x knowsAbout _unit) > 3.5} &&
							{alive _x} &&
							{(5 + (3 * _disguiseValue)) > (random 100)}
						}
					);
				};

				case false: {

					_nearReg = count (
						(_unit nearEntities (_regDetectRadius * _disguiseValue)) select {
							(side _x == INC_regEnySide) &&
							{(_x knowsAbout _unit) > 3} &&
							{alive _x}
						}
					);

					sleep 0.5;

					_nearAsym = count (
						(_unit nearEntities (_asymDetectRadius * _disguiseValue)) select {
							(side _x == INC_asymEnySide) &&
							{(_x knowsAbout _unit) > 3} &&
							{alive _x}
						}
					);
				};
			};

			sleep 0.5;

			_nearMines = {_x isKindOf "timeBombCore"} count (nearestObjects [_unit,[],4]);

			sleep 0.5;

			if ((_nearAsym + _nearReg + _nearMines) != 0) then {
				_unit setVariable ["INC_proxAlert",true]
			} else {
				_unit setVariable ["INC_proxAlert",false]
			};
		};

        sleep 0.5;

		if !(_unit getVariable ["INC_trespassAlert",true]) then {
	        {
	            if (_unit inArea _x) exitWith {

	                private _activeMarker = _x;

	                _unit setVariable ["INC_trespassAlert",true];

					[_unit,_activeMarker] spawn {
						params ["_unit","_activeMarker"];

						waitUntil {

							sleep 1;

							!(_unit inArea _activeMarker);
						};
						_unit setVariable ["INC_trespassAlert",false];

					};
				};

	            false
	        } count INC_trespassMarkers;
		};

		sleep 0.2;

		(!(_unit getVariable ["isUndercover",false]) || {!(alive _unit)} || {!local _unit})
	};
};

[_unit] call INCON_fnc_armedLoop;

//Detection Stuff
//=======================================================================//
[_unit] spawn {

	params ["_unit"];

	waitUntil {

		sleep 4;

		private _alertedRegKnows = ([_unit, INC_regEnySide] call INCON_fnc_getAlerted);

		private _alertedAsymKnows = ([_unit, INC_asymEnySide] call INCON_fnc_getAlerted);

		private _anyAlerted = false;

		if (_alertedRegKnows || {_alertedAsymKnows}) then {_anyAlerted = true};

		//Publicise variables on undercover unit for undercover handler, killed handler & cooldown.
		_unit setVariable ["INC_regKnowsSO", _alertedRegKnows, true];
		_unit setVariable ["INC_asymKnowsSO", _alertedAsymKnows, true];
		_unit setVariable ["INC_anyKnowsSO", _anyAlerted, true];

		(!(_unit getVariable ["isUndercover",false]) || !(alive _unit))
	};
};

//Fired EventHandler
_unit addEventHandler["FiredMan", {
	params["_unit"];

	//If he's compromised, do nothing
	if !(_unit getVariable ["INC_isCompromised",false]) then {

		//If anybody is aware of the unit and the unit isn't incognito, then compromise him
		if (_unit getVariable ["INC_anyKnowsSO",false]) then {

			//Do nothing unless they know where the dude is
			_regAlerted = [INC_regEnySide,_unit,50] call INCON_fnc_countAlerted;
			_asymAlerted = [INC_asymEnySide,_unit,50] call INCON_fnc_countAlerted;

			//Once people know where he is, who he is, and that he has fired a weapon, make him compromised
			if ((_regAlerted != 0) || {_asymAlerted != 0}) exitWith {

				[_unit] call INCON_fnc_compromised;
			};
		};

		//Smell of cordite on clothes...
		if !(_unit getVariable ["INC_firedRecent",false]) then {

			_unit setVariable ["INC_firedRecent",true];

			[_unit] spawn {
				params ["_unit"];
				sleep (15 + (random 5));
				_unit setVariable ["INC_firedRecent",false];
			};
		};
	};
}];

//Shot at nearby EventHandler
if (isPlayer _unit) then {
	_unit addEventHandler["FiredNear", {
		params["_unit"];

		if (_unit == (_this select 7)) exitWith {};

		//If he's doing crazy shit, do nothing
		if (captive _unit) then {

			//If unit hasn't been fired near before
			if !(_unit getVariable ["INC_shotNear",false]) then {

				_unit setVariable ["INC_shotNear",true];

				[_unit] spawn {
					params ["_unit"];
					sleep (200 + (random 120));
					_unit setVariable ["INC_shotNear",false];
				};
			};
		};
	}];
};

if ((isPlayer _unit) && {!(missionNamespace getVariable ["INC_envLoopActive",false])}) then {
	[_unit] spawn {
		params ["_unit"];
		private ["_daylightMulti","_jumpinessMulti"];

		missionNamespace setVariable ["INC_envLoopActive",true,true];

		waitUntil {

			if ((daytime > INC_firstLight) && {daytime < INC_lastLight}) then {
				_daylightMulti = 1;
				_jumpinessMulti = 1;
				missionNamespace setVariable ["INC_isDaytime",true,true];
			} else {
				_daylightMulti = (0.5 + (((moonIntensity - (overcast))/4)));
				_jumpinessMulti = 2;
				missionNamespace setVariable ["INC_isDaytime",false,true];
			};

			missionNamespace setVariable ["INC_envDisgMulti",(_daylightMulti - (fog/5))];

			missionNamespace setVariable ["INC_envJumpygMulti",_jumpinessMulti];

			sleep 15;

			(!local _unit)
		};
		missionNamespace setVariable ["INC_envLoopActive",false,true];
	};
};


//Add in suspicious level stuff for compromised variable and all that shizzlematiz, consolidate trespass loops into this function, consolidate detect, remove old shit
