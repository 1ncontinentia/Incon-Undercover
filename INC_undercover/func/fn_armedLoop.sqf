/* ----------------------------------------------------------------------------
Function:

Description:

Parameters:

Returns:

Examples:

Author:
---------------------------------------------------------------------------- */


params [["_unit",objNull],["_operation","armedLoop"]];

#include "..\UCR_setup.sqf"

if (!local _unit) exitWith {};


//Armed / Incognito Stuff
//=======================================================================//
[_unit,_HMDallowed,_noOffRoad,_debug,_hints,_regDetectRadius,_asymDetectRadius,_fullAIfunctionality,_racism,_racProfFacCiv,_racProfFacEny] spawn {

	params ["_unit","_HMDallowed","_noOffRoad","_debug","_hints","_regDetectRadius","_asymDetectRadius","_fullAIfunctionality","_racism","_racProfFacCiv","_racProfFacEny"];

	private _responseTime = 0.2;

	if !(isPlayer _unit) then {_responseTime = (_responseTime * 2)}; //Repsonsiveness of script reduced for performance on AI

	sleep _responseTime;

	//Main loop
	waitUntil {

		//Handles incognito status and checks on leaving vehicle
		if ((uniform _unit in INC_incogUniforms) && {!(_unit getVariable ["INC_goneIncog",false])}) then {

			_unit setVariable ["INC_goneIncog",true];
		} else {

			if ((_unit getVariable ["INC_goneIncog",false]) && {!(uniform _unit in INC_incogUniforms)}) then {

				if !(_unit getVariable ["INC_isCompromised",false]) then {

					//If either side has seen the unit, make him compromised
					if (([INC_regEnySide,_unit,10] call INCON_ucr_fnc_isKnownExact) || {[INC_asymEnySide,_unit,10] call INCON_ucr_fnc_isKnownExact}) then {

						[_unit] call INCON_ucr_fnc_compromised;
					};
				};
			};
		};

		//While on foot
		waitUntil {

			if !(isNull objectParent _unit) exitWith {true};

			private ["_suspiciousValue","_weirdoLevel","_spotDistance","_incog"];

			_suspiciousValue = 1;
			_weirdoLevel = 1;
			_spotDistance = 1;
			_unit setVariable ["INC_canConcealWeapon",([[_unit],"ableToConceal"] call INCON_ucr_fnc_gearHandler)];
			_unit setVariable ["INC_canGoLoud",([[_unit],"ableToGoLoud"] call INCON_ucr_fnc_gearHandler)];

			sleep _responseTime;

			//Incognito check
			_incog = [[_unit],"checkIncogFoot"] call INCON_ucr_fnc_ucrMain;

			sleep _responseTime;

			switch (_incog) do {

				case true: {

					if (captive _unit) then {

						if !(backpack _unit in INC_incogBackpacks) then {
							_weirdoLevel = _weirdoLevel + 1;
							_spotDistance = _spotDistance + 1;
						};

						if !(vest _unit in INC_incogVests) then {
							_weirdoLevel = _weirdoLevel + 2;
							_spotDistance = _spotDistance + 1;
						};

						sleep _responseTime;

						if !(headgear _unit in INC_incogHeadgear) then {
							_weirdoLevel = _weirdoLevel + 0.5;

							if (((headgear _unit) find "elmet") >= 0) then {
								_weirdoLevel = _weirdoLevel + 2;
								_spotDistance = _spotDistance + 0.3;
							};
						};

						sleep _responseTime;

						if !(currentWeapon _unit in INC_incogWpns) then {
							_weirdoLevel = _weirdoLevel + 1.5;
							_spotDistance = _spotDistance + 0.5;
						};

						//Maybe disableAI autotarget / autocombat when captive, safe, incognito and holding fire?
						if ((isPlayer _unit) && {(currentWeapon _unit == primaryWeapon _unit) && {!(weaponLowered _unit)}}) then {
							_weirdoLevel = _weirdoLevel + 0.5;
						};

						if (uniform _unit isEqualTo (_unit getVariable ["INC_compUniform","NONEXISTANT"])) then {
							_weirdoLevel = _weirdoLevel + 3;
						};

						sleep _responseTime;

						if !(_unit getVariable ["INC_shotNear",false]) then {

					        switch (stance _unit == "STAND") do {

								case true: {

									if (speed _unit > 8) then {
										_weirdoLevel = _weirdoLevel + 0.3;
										_spotDistance = _spotDistance + 1.5;

										if (speed _unit > 17) then {
											_weirdoLevel = _weirdoLevel + 1;
											_spotDistance = _spotDistance + 3;
										};
									};
								};

								case false: {
									_weirdoLevel = _weirdoLevel + 2;
									_spotDistance = _spotDistance + 2;

							        if (speed _unit > 2) then {
										_weirdoLevel = _weirdoLevel + 1;
										_spotDistance = _spotDistance + 2;

								        if (speed _unit > 5) then {
											_weirdoLevel = _weirdoLevel + 1;
											_spotDistance = _spotDistance + 1;
										};
									};
								};
							};
						};

						sleep _responseTime;

						//Racial profiling checks
						if (!(_unit getVariable ["INC_faceFits",true]) && {_racism}) then {

							if (headgear _unit == "") then {
								_weirdoLevel = _weirdoLevel + (2 * _racProfFacEny);
								_spotDistance = _spotDistance + (2 * _racProfFacEny);
							};

							if (goggles _unit == "") then {

								_weirdoLevel = _weirdoLevel + (4 * _racProfFacEny);
								_spotDistance = _spotDistance + (2 * _racProfFacEny);

							} else {

								if ((((goggles _unit) find "andanna") >= 0) || {((goggles _unit) find "carf") >= 0}) then {
									_weirdoLevel = _weirdoLevel + (2 * _racProfFacEny);
									_spotDistance = _spotDistance + (0.5 * _racProfFacEny);

								} else {

									//If the unit isn't wearing a bandana but is wearing something else, and is either dressed as a civilian or incognito and not wearing a balaclava...
									if (((goggles _unit) find "alaclava") == -1) then {

										_weirdoLevel = _weirdoLevel + (3 * _racProfFacEny);
										_spotDistance = _spotDistance + (1.5 * _racProfFacEny);
									} else {

										//If the unit is wearing a balaclava
										_weirdoLevel = _weirdoLevel + (1.5 * _racProfFacEny);
									};
								};
							};
						};
					};
				};

				case false: {

					//Check if unit is wearing anything suspicious
					if (!(uniform _unit in INC_civilianUniforms) || {!(vest _unit in INC_civilianVests)}) then {

						_suspiciousValue = _suspiciousValue + 1;
					};

					if (uniform _unit isEqualTo (_unit getVariable ["INC_compUniform","NONEXISTANT"])) then {

						_suspiciousValue = _suspiciousValue + 1;
					};

					sleep _responseTime;

					//Check if unit is armed
					if !(((currentWeapon _unit == "") || {currentWeapon _unit == "Throw"} || {currentWeapon _unit == binocular _unit}) && {primaryweapon _unit == ""} && {secondaryWeapon _unit == ""}) then {

						_suspiciousValue = _suspiciousValue + 1;
					};

					//Trespass check
					if (_unit getVariable ["INC_trespassAlert",false]) then {

						_suspiciousValue = _suspiciousValue + 1;
					};

					sleep _responseTime;

					//Oddball check
					if ((captive _unit) && {_suspiciousValue == 1}) then {

						//Check if unit is wearing anything suspicious
						if ((((headgear _unit) find "elmet") >= 0) || {((goggles _unit) find "alaclava") >= 0}) then {

							_weirdoLevel = _weirdoLevel + 3;
							_spotDistance = _spotDistance + 1.5;
						};

						{
							if (side _x == INC_regEnySide) exitWith {
								_weirdoLevel = _weirdoLevel + (_regDetectRadius - (_x distance _unit));
								true
							};
							if (side _x == INC_asymEnySide) exitWith {
								_weirdoLevel = _weirdoLevel + (_asymDetectRadius - (_x distance _unit));
								true
							};
						} forEach (_unit nearEntities ((_regDetectRadius + _asymDetectRadius)/2));

						sleep _responseTime;

						if !(headgear _unit in INC_civilianHeadgear) then {
							_weirdoLevel = _weirdoLevel + 1;
							_spotDistance = _spotDistance + 0.5;
						};

						if ((hmd _unit != "") && !(_HMDallowed)) then {
							_weirdoLevel = _weirdoLevel + 3;
							_spotDistance = _spotDistance + 1;
						};

						sleep _responseTime;

						if !(backpack _unit in INC_civilianBackpacks) then {
							_weirdoLevel = _weirdoLevel + 1;
							_spotDistance = _spotDistance + 0.5;
						};

						if ((binocular _unit == currentWeapon _unit) && {binocular _unit != ""}) then {
							_weirdoLevel = _weirdoLevel + 5;
							_spotDistance = _spotDistance + 3;
						};

						if (_unit getVariable ["INC_firedRecent",false]) then {
							_weirdoLevel = _weirdoLevel + 2;
						};

						if (uniform _unit isEqualTo (_unit getVariable ["INC_compUniform","NONEXISTANT"])) then {
							_weirdoLevel = _weirdoLevel + 3;
						};

						sleep _responseTime;

						if !(_unit getVariable ["INC_shotNear",false]) then {

					        switch (stance _unit == "STAND") do {

								case true: {
									if (speed _unit > 8) then {
										_weirdoLevel = _weirdoLevel + 0.3;
										_spotDistance = _spotDistance + 1.5;

										if (speed _unit > 17) then {
											_weirdoLevel = _weirdoLevel + 1;
											_spotDistance = _spotDistance + 3;
										};
									};
								};

								case false: {
									_weirdoLevel = _weirdoLevel + 4;
									_spotDistance = _spotDistance + 3;

							        if (speed _unit > 2) then {
										_weirdoLevel = _weirdoLevel + 1;
										_spotDistance = _spotDistance + 1.5;

								        if (speed _unit > 5) then {
											_weirdoLevel = _weirdoLevel + 1;
											_spotDistance = _spotDistance + 1.5;
										};
									};
								};
							};
						};

						sleep _responseTime;

						//Racial profiling checks
						if (!(_unit getVariable ["INC_faceFits",true]) && {_racism}) then {

							if (headgear _unit == "") then {
								_weirdoLevel = _weirdoLevel + (1 * _racProfFacCiv);
								_spotDistance = _spotDistance + (2 * _racProfFacCiv);
							};

							if (goggles _unit == "") then {

								_weirdoLevel = _weirdoLevel + (3 * _racProfFacCiv);
								_spotDistance = _spotDistance + (1.5 * _racProfFacCiv);

							} else {

								if ((((goggles _unit) find "andanna") >= 0) || {((goggles _unit) find "carf") >= 0}) then {
									_weirdoLevel = _weirdoLevel + (2 * _racProfFacCiv);
									_spotDistance = _spotDistance + (1 * _racProfFacCiv);

								} else {
									_weirdoLevel = _weirdoLevel + (2 * _racProfFacCiv);
									_spotDistance = _spotDistance + (1 * _racProfFacCiv);
								};
							};
						};
					};
				};
			};

			sleep _responseTime;

			if (_unit getVariable ["INC_justFired",false]) then {
				_suspiciousValue = _suspiciousValue + 2;

				if !(_unit getVariable ["INC_firedRecent",false]) then {

					_unit setVariable ["INC_firedRecent",true];

					[_unit] spawn {
						params ["_unit"];
						sleep (60 + (random 300));
						_unit setVariable ["INC_firedRecent",false];
					};
				};
			};

			//Proximity alert scenario
			if ((_unit getVariable ["INC_proxAlert",false]) && {!(_unit getVariable ["INC_isCompromised",false])}) then {

				private ["_nearMines","_suspiciousEnemies"];

				sleep _responseTime;

				_nearMines = {_x isKindOf "timeBombCore"} count (nearestObjects [_unit,[],5]);
				_suspiciousValue = _suspiciousValue + _nearMines;

				_suspiciousEnemies = ((_unit nearEntities [["Man","Car"],(_regDetectRadius * (_unit getVariable ["INC_disguiseValue",1]))]) select {
					((side _x == INC_regEnySide) || {side _x == INC_asymEnySide}) &&
					{((_x getHideFrom _unit) distanceSqr _unit < 10)} &&
					{(_x knowsAbout _unit) > 3} &&
					{alive _x} &&
					{((missionNamespace getVariable ["INC_envJumpygMulti",1]) * (_unit getVariable ["INC_disguiseValue",1])) > (random 100)}
				});

				if (count _suspiciousEnemies != 0) then {
					{if !(_x getVariable ["INC_isSuspicious",false]) then {[_unit,_x] call INCON_ucr_fnc_suspiciousEny}} forEach _suspiciousEnemies;
				};
			};

			sleep _responseTime;

			_unit setVariable ["INC_suspiciousValue", _suspiciousValue];
			_unit setVariable ["INC_weirdoLevel",_weirdoLevel];
			_unit setVariable ["INC_radiusMulti",_spotDistance];

			(!(isNull objectParent _unit) || {!alive _unit})
		};


		sleep _responseTime;


		//While in a vehicle
		waitUntil {

			if (isNull objectParent _unit) exitWith {true};

			private ["_suspiciousValue","_weirdoLevel","_spotDistance","_displayName","_vehicle"];

			_vehicle = vehicle _unit;

			if ((_vehicle getVariable ["INC_displayName","UNASSIGNED"]) == "UNASSIGNED") then {

				_displayName = (getText (configfile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName"));

				_vehicle setVariable ["INC_displayName",_displayName];
			};

			_displayName = _vehicle getVariable ["INC_displayName","UNASSIGNED"];

			_suspiciousValue = 1;
			_weirdoLevel = 1;
			_spotDistance = 1;
			_unit setVariable ["INC_canConcealWeapon",([[_unit],"ableToConceal"] call INCON_ucr_fnc_gearHandler)];
			_unit setVariable ["INC_canGoLoud",([[_unit],"ableToGoLoud"] call INCON_ucr_fnc_gearHandler)];

			sleep _responseTime;

			//Incognito check
			_incog = [[_unit],"checkIncogVeh"] call INCON_ucr_fnc_ucrMain;

			sleep _responseTime;

			switch (_incog) do {

				case true: {

					//Trespass check
					if (_unit getVariable ["INC_proxAlert",false]) then {

						_suspiciousValue = _suspiciousValue + 1;
					};

					//Suspicious vehicle check
					if (_vehicle getVariable ["INC_naughtyVehicle",false]) then {

						_suspiciousValue = _suspiciousValue + 1;
					};

					sleep _responseTime;

					//Oddball check
					if (captive _unit) then {

						_weirdoLevel = _weirdoLevel + (((speed _unit) + 1)/ 40);
						_spotDistance = _spotDistance + (((speed _unit) + 1)/ 8);

						//Headlights check for moving vehicle at night
						if (
							!(missionNamespace getVariable ["INC_isDaytime",true]) &&
							{!isLightOn _vehicle} &&
							{speed _unit > 5} &&
							{_vehicle isKindOf "LandVehicle"}
						) then {
							_weirdoLevel = _weirdoLevel + 4;
							_spotDistance = _spotDistance + 3;
						};

						sleep _responseTime;

						//Incognito uniform check for non-tank, non-covered vehicles
						if !((_vehicle isKindOf "Tank") || {(_displayName find "overed") >= 1}) then {

							//Open vehicles
							if (((((typeOf _vehicle) find "ffroad") >= 1) || {(_displayName find "pen") >= 1}) && {_unit != driver _vehicle}) then {

						    	if !(uniform _unit in INC_incogUniforms) then {
									_weirdoLevel = _weirdoLevel + 12;
									_spotDistance = _spotDistance + 10;

									if (((currentWeapon _unit == primaryWeapon _unit) || {currentWeapon _unit == secondaryWeapon _unit} || {currentWeapon _unit == handgunWeapon _unit})) then {

										if !(weaponLowered _unit) then {

											_weirdoLevel = _weirdoLevel + 9;
											_spotDistance = _spotDistance + 4;
										} else {

											_weirdoLevel = _weirdoLevel + 5;
											_spotDistance = _spotDistance + 2;
										};
									};
								};

								//Incognito uniform check for non-tank vehicles
								if !(vest _unit in INC_incogVests) then {

									_weirdoLevel = _weirdoLevel + 2;
									_spotDistance = _spotDistance + 1;
								};
							} else {
								//Closed vehicles
								if (!(((_displayName find "ffroad") >= 1) || {(_displayName find "pen") >= 1}) || {_unit == driver _vehicle}) then {

									if !(uniform _unit in INC_incogUniforms) then {
										_weirdoLevel = _weirdoLevel + 10;
										_spotDistance = _spotDistance + 2;

										if (((currentWeapon _unit == primaryWeapon _unit) || {currentWeapon _unit == secondaryWeapon _unit} || {currentWeapon _unit == handgunWeapon _unit})) then {

											if !(weaponLowered _unit) then {

												_weirdoLevel = _weirdoLevel + 6;
												_spotDistance = _spotDistance + 3;
											};
										};
									};

									//Incognito uniform check for non-tank vehicles
									if !(vest _unit in INC_incogVests) then {

										_weirdoLevel = _weirdoLevel + 1;
									};
								};
							};

							sleep _responseTime;

							//Racial profiling checks
							if (!(_unit getVariable ["INC_faceFits",true]) && {_racism} && {!(_vehicle isKindOf "Tank")}) then {

								if (headgear _unit == "") then {
									_weirdoLevel = _weirdoLevel + (1 * _racProfFacEny);
									_spotDistance = _spotDistance + (0.5 * _racProfFacEny);
								};

								if (goggles _unit == "") then {

									_weirdoLevel = _weirdoLevel + (3 * _racProfFacEny);
									_spotDistance = _spotDistance + (1 * _racProfFacEny);

								} else {

									if ((((goggles _unit) find "andanna") >= 0) || {((goggles _unit) find "carf") >= 0}) then {
										_weirdoLevel = _weirdoLevel + (0.5 * _racProfFacEny);
										_spotDistance = _spotDistance + (0.5 * _racProfFacEny);

									} else {

										if (((goggles _unit) find "alaclava") >= 0) then {

											if !(goggles _unit in INC_incogHeadgear) then {
												_weirdoLevel = _weirdoLevel + (0.5 * _racProfFacEny);
											};

										} else {

											if !(goggles _unit in INC_incogHeadgear) then {
												_weirdoLevel = _weirdoLevel + (1 * _racProfFacEny);
											};
											_weirdoLevel = _weirdoLevel + (0.5 * _racProfFacEny);
										};
									};
								};
							};
						};

						sleep _responseTime;

						//Offroad check
						if ((_noOffRoad) && {(_vehicle isKindOf "Land")} && {((count (_unit nearRoads 30)) == 0)}) then {

							_weirdoLevel = _weirdoLevel + 2;
							_spotDistance = _spotDistance + 3;
						};

						//Trespass check
						if (_unit getVariable ["INC_trespassAlert",false]) then {

							_weirdoLevel = _weirdoLevel + 2;
							_spotDistance = _spotDistance + 1;
						};
					};
				};

				case false: {

					if (driver _vehicle == _unit) then {

						//Headlights check for moving land vehicle at night
						if (
							!(missionNamespace getVariable ["INC_isDaytime",true]) &&
							{!isLightOn _vehicle} &&
							{_vehicle isKindOf "LandVehicle"} &&
							{speed _unit > 5}
						) then {
							_suspiciousValue = _suspiciousValue + 1;
						};

						//Suspicious vehicle check
						if (!((typeof _vehicle) in INC_civilianVehicleArray) || {(_vehicle getVariable ["INC_naughtyVehicle",false])}) then {

							_suspiciousValue = _suspiciousValue + 2;
						};

						sleep _responseTime;

						//Offroad check
						if ((_noOffRoad) && {(_vehicle isKindOf "Land")} && {((count (_unit nearRoads 30)) == 0)}) then {

							_suspiciousValue = _suspiciousValue + 1;
						};

						//Trespass check
						if (_unit getVariable ["INC_trespassAlert",false]) then {

							_suspiciousValue = _suspiciousValue + 1;
						};
					};

					if (_unit getVariable ["INC_proxAlert",false]) then {

						[_unit] call INCON_ucr_fnc_compromised;
					};

					sleep _responseTime;

					//Oddball check
					if ((captive _unit) && {_suspiciousValue == 1}) then {

						if ((!_noOffRoad) && {(_vehicle isKindOf "Land")} && {((count (_unit nearRoads 30)) == 0)}) then {

							_weirdoLevel = _weirdoLevel + 4;
							_spotDistance = _spotDistance + 4;
						};

						_weirdoLevel = _weirdoLevel + (((speed _unit) + 1)/ 40);
						_spotDistance = _spotDistance + (((speed _unit) + 1)/ 8);

						sleep _responseTime;

						//Oddball check for non-covered vehicles
						if !((_displayName find "overed") >= 1) then {

							//Open vehicles
							if ((((_displayName find "ffroad") >= 1) || {(_displayName find "pen") >= 1}) && {_unit != driver _vehicle}) then {

						    	if (!((uniform _unit in INC_civilianUniforms) && {!(uniform _unit in INC_incogUniforms)})) then {
									_weirdoLevel = _weirdoLevel + 9;
									_spotDistance = _spotDistance + 3;
								};

								if (((currentWeapon _unit == primaryWeapon _unit) || {currentWeapon _unit == secondaryWeapon _unit} || {currentWeapon _unit == handgunWeapon _unit})) then {

									if !(weaponLowered _unit) then {

										_weirdoLevel = _weirdoLevel + 15;
										_spotDistance = _spotDistance + 10;
									} else {

										_weirdoLevel = _weirdoLevel + 15;
										_spotDistance = _spotDistance + 2;
									};
								};
							} else {
								//Closed vehicles & driver
								if (!(((_displayName find "ffroad") >= 1) || {(_displayName find "pen") >= 1}) || {_unit == driver _vehicle}) then {


							    	if (!((uniform _unit in INC_civilianUniforms) && {!(uniform _unit in INC_incogUniforms)})) then {
										_weirdoLevel = _weirdoLevel + 4;
										_spotDistance = _spotDistance + 1;
									};


									if (((currentWeapon _unit == primaryWeapon _unit) || {currentWeapon _unit == secondaryWeapon _unit} || {currentWeapon _unit == handgunWeapon _unit})) then {

										if !(weaponLowered _unit) then {
											_weirdoLevel = _weirdoLevel + 15;
											_spotDistance = _spotDistance + 3;
										} else {
											_weirdoLevel = _weirdoLevel + 15;
											_spotDistance = _spotDistance + 1;
										};
									};
								};
							};

							sleep _responseTime;

							//Racial profiling checks
							if (!(_unit getVariable ["INC_faceFits",true]) && {_racism}) then {

								switch (true) do {

									case (headgear _unit == ""): {
										_weirdoLevel = _weirdoLevel + (0.5 * _racProfFacCiv);
									};

									case (goggles _unit == ""): {

										_weirdoLevel = _weirdoLevel + (2 * _racProfFacCiv);
										_spotDistance = _spotDistance + (1 * _racProfFacCiv);
									};

									case !((((goggles _unit) find "andanna") >= 0) || {((goggles _unit) find "carf") >= 0}): {

										_weirdoLevel = _weirdoLevel + (1 * _racProfFacCiv);
										_spotDistance = _spotDistance + (1 * _racProfFacCiv);
									};

									_weirdoLevel = _weirdoLevel + (1 * _racProfFacCiv);
								};
							};
						};

						sleep _responseTime;

				    	if !(vest _unit in INC_civilianVests) then {
							_weirdoLevel = _weirdoLevel + 3;
							_spotDistance = _spotDistance + 1;
						};

						if ((hmd _unit != "") && {!(_HMDallowed)}) then {
							_weirdoLevel = _weirdoLevel + 2;
						};

						if (uniform _unit isEqualTo (_unit getVariable ["INC_compUniform","NONEXISTANT"])) then {
							_weirdoLevel = _weirdoLevel + 3;
							_spotDistance = _spotDistance + 1;
						};
					};
				};
			};

			sleep _responseTime;

			if (_unit getVariable ["INC_justFired",false]) then {
				_suspiciousValue = _suspiciousValue + 2;

				if !(_unit getVariable ["INC_firedRecent",false]) then {
					_unit setVariable ["INC_firedRecent",true];

					[_unit] spawn {
						params ["_unit"];
						sleep (60 + (random 300));
						_unit setVariable ["INC_firedRecent",false];
					};
				};
			};

			sleep _responseTime;

			_unit setVariable ["INC_suspiciousValue", _suspiciousValue];

			_unit setVariable ["INC_weirdoLevel",_weirdoLevel];

			_unit setVariable ["INC_radiusMulti",_spotDistance];

			((isNull objectParent _unit) || {!alive _unit})
		};

		(!(_unit getVariable ["isUndercover",false]) || {!(alive _unit)} || {!local _unit})
	};

	_unit setVariable ["INC_undercoverLoopsActive", false]; // Stops the script running twice on the same unit
};
