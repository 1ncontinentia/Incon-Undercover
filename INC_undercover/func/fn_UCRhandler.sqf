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


//Armed / Incognito Stuff
//=======================================================================//
[_unit,_HMDallowed,_noOffRoad,_debug,_hints,_regDetectRadius,_asymDetectRadius] spawn {

	params ["_unit","_HMDallowed","_noOffRoad","_debug","_hints","_regDetectRadius","_asymDetectRadius"];

	private _responseTime = 0.3;

	if !(isPlayer _unit) then {_responseTime = (_responseTime * 3)}; //Repsonsiveness of script reduced for performance on AI

	sleep _responseTime;

	//Main loop
	waitUntil {

		//While on foot
		waitUntil {

			if !(isNull objectParent _unit) exitWith {true};

			private ["_suspiciousValue","_weirdoLevel","_nearShotAt"];

			_suspiciousValue = 1; //Suspicious behaviour value: higher = more suspicious

			_weirdoLevel = 1; //Multiplier of radius for units near the player

			//Incognito check - change to incognito if unit is wearing enemy uniform, but also compromise him if enemy sees him doing so
			if (uniform _unit in INC_incognitoUniforms) then {
				switch (_unit getVariable ["INC_goneIncognito",false]) do {
					case false: {
						private ["_regAlerted","_regKnowsAboutUnit","_asymAlerted","_asymKnowsAboutUnit"];

						if !(_unit getVariable ["INC_isCompromised",false]) then


							//Checks if INC_regEnySide has seen him recently and sets variables accordingly
							_regAlerted = [INC_regEnySide,_unit,20] call INCON_fnc_countAlerted;
							if (_regAlerted != 0) then {
								_regKnowsAboutUnit = true;
							} else {
								_regKnowsAboutUnit = false;
							};


							//Checks if INC_asymEnySide has seen him recently
							_asymAlerted = [INC_asymEnySide,_unit,20] call INCON_fnc_countAlerted;
							if (_asymAlerted != 0) then {
								_asymKnowsAboutUnit = true;
							} else {
								_asymKnowsAboutUnit = false;
							};

							//If either side has seen the unit, make him compromised
							if ((_asymKnowsAboutUnit) || {_regKnowsAboutUnit}) then {
								[_unit] call INCON_fnc_compromisedLoop;
							};
						};

						_unit setVariable ["INC_goneIncognito",true];
					};
				};
			} else {
				_unit setVariable ["INC_goneIncognito",false];
			};

			sleep _responseTime;

			_unit setVariable ["INC_canConcealWeapon",([[_unit],"ableToConceal"] call INCON_fnc_ucrMain)];
			_unit setVariable ["INC_canGoLoud",([[_unit],"ableToGoLoud"] call INCON_fnc_ucrMain)];

			sleep _responseTime;

			//Penalise people for being oddballs
			if (isPlayer _unit) then {

				switch (_unit getVariable ["INC_goneIncognito",false]) do {

					case true: {

						if !(backpack _unit in INC_incognitoBackpacks) then {
							_weirdoLevel = _weirdoLevel + 0.5;
						};

						if !(vest _unit in INC_incognitoVests) then {
							_weirdoLevel = _weirdoLevel + 2;
						};

						if !(headgear _unit in INC_incognitoHeadgear) then {
							_weirdoLevel = _weirdoLevel + 0.5;

							if (((headgear _unit) find "elmet") >= 0) then {
								_weirdoLevel = _weirdoLevel + 1;
							};
						};

						if !(currentWeapon _unit in INC_incognitoWpns) then {
							_weirdoLevel = _weirdoLevel + 0.8;
						};
					};

					case false: {

						//Check if unit is wearing anything suspicious
						if ((((headgear _unit) find "elmet") >= 0) || {((goggles _unit) find "alaclava") >= 0}) then {

							_weirdoLevel = _weirdoLevel + 2;
						};
					};
				};

				//Running and jumping are seen as weird unless there has been shooting near the unit
				if !(_unit getVariable ["INC_shotNear",false]) then {

			        switch !(stance _unit == "STAND") do {

						case true: {
							_weirdoLevel = _weirdoLevel + 2;

					        if (speed _unit > 2) then {
								_weirdoLevel = _weirdoLevel + 0.5;

						        if (speed _unit > 5) then {
									_weirdoLevel = _weirdoLevel + 0.5;
								};
							};
						};

						case false: {

						    if (speed _unit > 8) then {
								_weirdoLevel = _weirdoLevel + 0.5;

							    if (speed _unit > 17) then {
									_weirdoLevel = _weirdoLevel + 1.5;
								};
							};
						};
					};
				};

				//If the unit has shot his weapon recently...
				if (_unit getVariable ["INC_firedRecent",false]) then {
					_weirdoLevel = _weirdoLevel + 2;
				};


				sleep _responseTime;

				sleep _responseTime;

				if (uniform _unit isEqualTo (_unit getVariable ["INC_compUniform","NONEXISTANT"])) then {
					_weirdoLevel = _weirdoLevel + 3;
				};

				_unit setVariable ["INC_weirdoLevel",_weirdoLevel];  //This variable acts as a detection radius multiplier
			};

			sleep _responseTime;

			//Suspicious checks depending on incognito status
			if !(_unit getVariable ["INC_goneIncognito",false]) then {

				//Check if unit is wearing anything suspicious
				if (!(uniform _unit in INC_civilianUniforms) || {!(vest _unit in INC_civilianVests)} || {!(headgear _unit in INC_civilianHeadgear)}  || {!(backpack _unit in INC_civilianBackpacks)} || {(hmd _unit != "") && !(_HMDallowed)} || {uniform _unit isEqualTo (_unit getVariable ["INC_compUniform","NONEXISTANT"])}) then {

					_suspiciousValue = _suspiciousValue + 1;
				};

				sleep _responseTime;

				//Check if unit is armed
				if !(((currentWeapon _unit == "") || {currentWeapon _unit == "Throw"}) && {primaryweapon _unit == ""} && {secondaryWeapon _unit == ""}) then {

					_suspiciousValue = _suspiciousValue + 1;
				};

				sleep _responseTime;

				//Trespass check
				if (_unit getVariable ["INC_trespassAlert",false]) then {

					_suspiciousValue = _suspiciousValue + 1;
				};
			};

			if (_unit getVariable ["INC_firedRecent",false]) then {
				_suspiciousValue = _suspiciousValue + 2;
			};

			//Proximity alert scenario
			if ((_unit getVariable ["INC_proxAlert",false]) && {!(_unit getVariable ["INC_isCompromised",false])}) then {

				private ["_nearMines","_suspiciousEnemy"];

				_nearMines = {_x isKindOf "timeBombCore"} count (nearestObjects [_unit,[],5]);

				_suspiciousValue = _suspiciousValue + _nearMines;

				_suspiciousEnemy = selectRandom ((_unit nearEntities (_regDetectRadius * (_unit getVariable ["INC_disguiseValue",1]))) select {
					((side _x == INC_regEnySide) || {side _x == INC_asymEnySide}) &&
					{((_x getHideFrom _unit) distanceSqr _unit < 10)} &&
					{(_x knowsAbout _unit) > 3.5} &&
					{alive _x} &&
					{((6 * missionNamespace getVariable ["INC_envJumpygMulti",1]) * (_unit getVariable ["INC_disguiseValue",1])) > (random 100)}
				});

				if (!isNil "_suspiciousEnemy") then {

					if !(_suspiciousEnemy getVariable ["INC_isSuspicious",false]) then {

						[_unit,_suspiciousEnemy] spawn {
							params ["_unit","_suspiciousEnemy"];

							_suspiciousEnemy setVariable ["INC_isSuspicious",true];

							_suspiciousEnemy doWatch _unit;

							sleep (random 15);

							if !((40 * (_unit getVariable ["INC_disguiseValue",1])) > (random 100)) exitWith {
								_suspiciousEnemy setVariable ["INC_isSuspicious",false];
							};

							if (45 > (random 100)) then {
								private ["_comment"];
								switch (_unit getVariable ["INC_goneIncognito",false]) do {
									case true: {
										_comment = selectRandom ["Who the fuck are you?","I don't recognise you.","I don't like the look of you.","You look strange.","What are you doing?","I'd like to know which unit you're from.","Who are you with?","You're not supposed to be here.","You're not with us are you?"];
									};
									case false: {
										_comment = selectRandom ["I recognise you from somewhere.","You hiding something?","Stop right there, let me get a good look at you.","Stop. Don't move.","Stay right there."];
									};
								};
								[[_suspiciousEnemy, _comment] remoteExec ["globalChat",_unit]];
							};

							_suspiciousEnemy doWatch _unit;

							sleep (random 25);

							if !((40 * (_unit getVariable ["INC_disguiseValue",1])) > (random 100)) exitWith {
								_suspiciousEnemy setVariable ["INC_isSuspicious",false];
							};

							waitUntil {

								_suspiciousEnemy doMove ([(getPosWorld _unit),10] call CBA_fnc_Randpos);

								sleep (random 15);

								_suspiciousEnemy doWatch _unit;

								_suspiciousEnemy doTarget _unit;

								if (((((speed _unit) + 4) / 1.6) * (_unit getVariable ["INC_disguiseValue",1])) > (random 100)) exitWith {
									_suspiciousEnemy setVariable ["INC_isSuspicious",false];
									[_unit] call INCON_fnc_compromisedLoop;
									true
								};

								if !((70 * (_unit getVariable ["INC_disguiseValue",1])) > (random 100)) exitWith {
									_suspiciousEnemy setVariable ["INC_isSuspicious",false];
									true
								};

								(!((_suspiciousEnemy getHideFrom _unit) distanceSqr _unit < 30) || {!alive _suspiciousEnemy} || {!captive _unit})
							};
						};
					};
				};
			};

			_unit setVariable ["INC_suspiciousValue", _suspiciousValue];

			(!(isNull objectParent _unit) || {!alive _unit})
		};

		sleep _responseTime;

		//While in a vehicle
		waitUntil {

			if (isNull objectParent _unit) exitWith {true};

			private ["_suspiciousValue","_weirdoLevel"];

			_suspiciousValue = 1; //Suspicious behaviour value: higher = more suspicious

			_weirdoLevel = 0.5; //Multiplier of radius for units near the player

			//Incognito check to go here
			if (((typeOf vehicle _unit) in INC_incognitoVehArray) && {!((vehicle _unit) getVariable ["INC_naughtyVehicle",false])} && {uniform _unit in INC_incognitoUniforms}) then {

				_unit setVariable ["INC_goneIncognito",true];
				_unit setVariable ["INC_canConcealWeapon",false];
				_unit setVariable ["INC_canGoLoud",false];
			} else {
				_unit setVariable ["INC_goneIncognito",false];
				_unit setVariable ["INC_canConcealWeapon",([[_unit],"ableToConceal"] call INCON_fnc_ucrMain)];
				_unit setVariable ["INC_canGoLoud",([[_unit],"ableToGoLoud"] call INCON_fnc_ucrMain)];
			};

			//Penalise people for being oddballs by increasing the spotting radius - wearing wrong uniform / hmd
			if (isPlayer _unit) then {

				if !(_unit getVariable ["INC_goneIncognito",false]) then {

					sleep _responseTime;

					//Headlights check for moving vehicle at night
					if (
						!(missionNamespace getVariable ["INC_isDaytime",true]) &&
						{isLightOn vehicle _unit} &&
						{(vehicle _unit) isKindOf "LandVehicle"} &&
						{speed _unit > 5}
					) then {
						_suspiciousValue = _suspiciousValue + 1;
					};

					sleep _responseTime;

					_weirdoLevel = _weirdoLevel + ((speed _unit)/ 10);

			        switch (!(uniform _unit in INC_civilianUniforms) || {!(vest _unit in INC_civilianVests)}) do {

						case true: {

							_weirdoLevel = _weirdoLevel + 2.5;

							if ((hmd _unit != "") && {!(_HMDallowed)}) then {

								_weirdoLevel = _weirdoLevel + 1;
							};
						};

						case false: {

							if ((hmd _unit != "") && {!(_HMDallowed)}) then {

								_weirdoLevel = _weirdoLevel + 1.5;
							};
						};
					};
				} else {

					//Headlights check for moving vehicle at night
					if (
						!(missionNamespace getVariable ["INC_isDaytime",true]) &&
						{isLightOn vehicle _unit} &&
						{speed _unit > 5} &&
						{(vehicle _unit) isKindOf "LandVehicle"}
					) then {
						_weirdoLevel = _weirdoLevel + 2;
					};

					//Incognito uniform check for non-tank vehicles
					if (!((vehicle _unit) isKindOf "Tank") && {!(vest _unit in INC_incognitoVests)}) then {

						_weirdoLevel = _weirdoLevel + 2;
					};
				};

				if (uniform _unit isEqualTo (_unit getVariable ["INC_compUniform","NONEXISTANT"])) then {
					_weirdoLevel = _weirdoLevel + 2
				};

				_unit setVariable ["INC_weirdoLevel",_weirdoLevel]; //This variable acts as a detection radius multiplier
			};

			sleep _responseTime;

			if !(_unit getVariable ["INC_goneIncognito",false]) then {

				//Suspicious vehicle check
				if !(((typeof vehicle _unit) in INC_civilianVehicleArray) && {!((vehicle _unit) getVariable ["INC_naughtyVehicle",false])}) then {

					if ((isPlayer _unit) && {(_debug) || {_hints}}) then {
						hint "You are in a suspicious vehicle.";
					};

					_suspiciousValue = _suspiciousValue + 2;
				};

				sleep _responseTime;

				//Offroad check
				if ((_noOffRoad) && {((vehicle _unit) isKindOf "Land")} && {((count (_unit nearRoads 30)) == 0)}) then {

					if ((isPlayer _unit) && {(_debug) || {_hints}}) then {
						hint "You are in a suspicious vehicle.";
					};

					_suspiciousValue = _suspiciousValue + 1;
				};

				sleep _responseTime;

				//Trespass check
				if (_unit getVariable ["INC_trespassAlert",false]) then {

					_suspiciousValue = _suspiciousValue + 1;
				};
			};

			//Trespass check
			if (_unit getVariable ["INC_proxAlert",false]) then {

				_suspiciousValue = _suspiciousValue + 2;
			};

			_unit setVariable ["INC_suspiciousValue", _suspiciousValue];

			((isNull objectParent _unit) || {!alive _unit})
		};

		(!(_unit getVariable ["isUndercover",false]) || {!(alive _unit)} || {!local _unit})
	};

	_unit setVariable ["INC_undercoverLoopsActive", false]; // Stops the script running twice on the same unit
};


//Detection Stuff
//=======================================================================//
[_unit] spawn {

	params ["_unit"];

	waitUntil {

		sleep 4;

		private _alertedRegKnows = ([_unit, INC_regEnySide] call INCON_fnc_undercoverGetAlerted);

		private _alertedAsymKnows = ([_unit, INC_asymEnySide] call INCON_fnc_undercoverGetAlerted);

		private _anyAlerted = false;

		if (_alertedRegKnows || {_alertedAsymKnows}) then {_anyAlerted = true};

		//Publicise variables on undercover unit for undercover handler, killed handler & cooldown.
		_unit setVariable ["INC_RegKnowsSO", _alertedRegKnows, true];
		_unit setVariable ["INC_AsymKnowsSO", _alertedAsymKnows, true];
		_unit setVariable ["INC_AnyKnowsSO", _anyAlerted, true];

		(!(_unit getVariable ["isUndercover",false]) || !(alive _unit))
	};
};

//Fired EventHandler
_unit addEventHandler["FiredMan", {
	params["_unit"];

	//If he's compromised, do nothing
	if !(_unit getVariable ["INC_isCompromised",false]) then {

		//If anybody is aware of the unit and the unit isn't incognito, then compromise him
		if (_unit getVariable ["INC_AnyKnowsSO",false]) then {

			//Do nothing unless they know where the dude is
			_regAlerted = [INC_regEnySide,_unit,50] call INCON_fnc_countAlerted;
			_asymAlerted = [INC_asymEnySide,_unit,50] call INCON_fnc_countAlerted;

			//Once people know where he is, who he is, and that he has fired a weapon, make him compromised
			if ((_regAlerted != 0) || {_asymAlerted != 0}) exitWith {

				[_unit] call INCON_fnc_compromisedLoop;
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

if (isPlayer _unit) then {
	//Shot at nearby EventHandler
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

if ((isPlayer _unit) && {!(missionNamespace getVariable ["INC_environmentMultiLoopActive",false])}) then {
	[_unit] spawn {
		params ["_unit"];
		private ["_daylightMulti","_jumpinessMulti"];

		missionNamespace setVariable ["INC_environmentMultiLoopActive",true,true];

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
		missionNamespace setVariable ["INC_environmentMultiLoopActive",false,true];
	};
};


//Add in suspicious level stuff for compromised variable and all that shizzlematiz, consolidate trespass loops into this function, consolidate detect, remove old shit
