params [["_input",objNull],["_operation","addConcealedRifle"]];

private ["_return"];

_return = false;

#include "..\UCR_setup.sqf"

switch (_operation) do {

	case "getCompatMags": {

		_input params ["_weapon"];

		private _configEntry = configFile >> "CfgWeapons" >> _weapon;
		private _result = [];
		{
			_result pushBack (
				if (_x == "this") then {
					getArray(_configEntry >> "magazines")
				}
			);
		} forEach getArray(_configEntry >> "muzzles");

		_return = _result select 0;
	};

	case "addBackpack": {

		_input params ["_unit"];

		_unit addBackpack (selectRandom _civPackArray);
		unitBackpack _unit setVariable ["owner",_unit,true];

		[(unitBackpack _unit), {
			_this addEventHandler ["ContainerOpened", {
				_backpack  = _this select 0;
				_civ = _backpack getVariable "owner";
				private _civComment = selectRandom ["Get the fuck out of my backpack","What are you doing?","Leave me alone!","Get out!","What are you playing at?"];
				[[_civ, _civComment] remoteExec ["globalChat",0]];
				[[_civ,"runAway"] remoteExecCall ["INCON_ucr_fnc_ucrMain",_civ]];
				}
			];
		}] remoteExec ["call", 0,true];

		_return = unitBackpack _unit;
	};

	case "addWeapon": {

		_input params ["_unit"];

		private _wpn = selectRandom _civWpnArray;
		private _magsArray = ([_wpn,"getCompatMags"] call INCON_ucr_fnc_gearHandler);

		_return = true;

		if (_unit canAddItemToUniform _wpn) then {
			_unit addItemToUniform _wpn;
			_unit addMagazine (selectRandom _magsArray);
			for "_i" from 1 to (ceil random 5) do {
				_unit addMagazine (selectRandom _magsArray);
			};

		} else {

			if (_unit canAddItemToBackpack _wpn) then {

				_unit addMagazine (selectRandom _magsArray);
				_unit addItemToBackpack _wpn;
				for "_i" from 1 to (ceil random 8) do {
					_unit addMagazine (selectRandom _magsArray);
				};

			} else {

				_return = false;
			};
		};
	};

	case "addItems": {

		for "_i" from 0 to (round (random 3)) do {
			private _itemToAdd = selectRandom _civItemArray;
			_unit addItem _itemToAdd;
		};

		_return = true;
	};

	case "getStoredWeaponItems": {

		_input params ["_unit","_wpn",["_comparison",false]];

		_return = [];

		private ["_activeContainer","_weaponArray"];

		//Determine the weapon location, exit if not found
		_activeContainer = weaponsitemscargo uniformContainer _unit;

		if !((uniformItems _unit) find _wpn >= 0) then {

			if ((vestItems _unit) find _wpn >= 0) exitWith {
				_activeContainer = weaponsitemscargo vestContainer _unit;
			};

			if ((backpackItems _unit) find _wpn >= 0) exitWith {
				_activeContainer = weaponsitemscargo unitBackpack _unit;
			};

			_activeContainer = [];
		};

		if (_activeContainer isEqualTo []) exitWith {};

		_weaponArray = (_activeContainer select {(_x select 0) == _wpn}) select 0;

		if (_comparison) exitWith {
			_return = _weaponArray;
		};

		_return = _weaponArray select {(_x isEqualType "STRING") && {_x != _wpn}};
	};

	case "getStoredWeaponAmmoArray": {

		_input params ["_unit","_wpn"];

		_return = [];

		private ["_activeContainer","_weaponArray"];

		//Determine the weapon location, exit if not found
		_activeContainer = weaponsitemscargo uniformContainer _unit;

		if !((uniformItems _unit) find _wpn >= 0) then {

			if ((vestItems _unit) find _wpn >= 0) exitWith {
				_activeContainer = weaponsitemscargo vestContainer _unit;
			};

			if ((backpackItems _unit) find _wpn >= 0) exitWith {
				_activeContainer = weaponsitemscargo unitBackpack _unit;
			};

			_activeContainer = [];
		};

		if (_activeContainer isEqualTo []) exitWith {};

		_weaponArray = (_activeContainer select {(_x select 0) == _wpn}) select 0;

		_return = _weaponArray select 4;
	};

	case "ableToConceal": {

		_input params ["_unit"];

		private _wpn = currentWeapon _unit;

		if ((_wpn == "") || {_wpn == "Throw"} || {_wpn == binocular _unit}) exitWith {_return = false};

		_return = (
			(
				(isNull objectParent _unit) ||
				{((assignedVehicleRole _unit) select 0) == "Turret"}
			) && {
				((primaryWeapon _unit != "") && {(_unit canAddItemToUniform (primaryWeapon _unit)) || {_unit canAddItemToBackpack (primaryWeapon _unit)}}) ||
				{(handgunWeapon _unit != "") && {(_unit canAddItemToUniform (handgunWeapon _unit)) || {_unit canAddItemToBackpack (handgunWeapon _unit)}}}
			}
		);
	};

	case "ableToGoLoud": {

		_input params ["_unit"];

		_return = (
			(
				(isNull objectParent _unit) ||
				{((assignedVehicleRole _unit) select 0) == "Turret"}
			) && {
				(currentWeapon _unit == "") || {currentWeapon _unit == "Throw"} || {currentWeapon _unit == binocular _unit}
			} && {
				(handgunWeapon _unit == "") && {primaryWeapon _unit == ""}
			} && {
				({
					(_x isKindOf ['Pistol', configFile >> 'CfgWeapons']) ||
					{_x isKindOf ['Rifle', configFile >> 'CfgWeapons']}
				} count (weapons _unit) != 0)
			}
		);
	};

	case "concealWeapon": {

		private ["_wpnType","_wpn","_id"];

		_input params ["_unit"];

		_return = true;

		_wpn = currentWeapon _unit;

		if ((primaryWeapon _unit != _wpn) || {handgunWeapon _unit != _wpn}) then {
			_wpn = (([(primaryWeapon _unit),(handgunWeapon _unit)] select {
				(_x != "") &&
				{(_unit canAddItemToUniform _x) || {_unit canAddItemToBackpack _x}}
			}) select 0);
		};

		_id = 999;

		if (isNil "_wpn") exitWith {_return = false};

		if (_wpn isEqualTo primaryWeapon _unit) then {_id = 0};
		if (_wpn isEqualTo handgunWeapon _unit) then {_id = 1};

		if (_id == 999) exitWith {_return = false};

		_wpnType = "primary";

		if (_wpn == handgunWeapon _unit) then {
			_wpnType = "handgun";
		};

		[_unit,_wpn,_id,_wpnType] spawn {
			params ["_unit","_wpn","_id","_wpnType"];
			private ["_mag","_ammoCount","_items","_baseWpn","_itemsToAdd","_id","_weaponStore","_weaponArray","_origItems"];

			switch (_wpnType) do {
				case "primary": {
					_mag = primaryWeaponMagazine _unit select 0;
				};
				case "handgun": {
					_mag = handgunMagazine _unit select 0;
				};
			};

			_ammoCount = _unit ammo _wpn;
			_items = _unit weaponAccessories _wpn;
			_baseWpn = [_wpn] call BIS_fnc_baseWeapon;

			sleep 0.2;

			switch (_unit canAddItemToUniform _wpn) do {
				case true: {
					_unit addMagazine [_mag,_ammoCount];
					_unit removeWeaponGlobal _wpn;
					(uniformContainer _unit) addItemCargoGlobal [_baseWpn, 1];
					{(uniformContainer _unit) addItemCargoGlobal [_x, 1]} forEach _items;
				};
				case false: {
					_unit addMagazine [_mag,_ammoCount];
					_unit removeWeaponGlobal _wpn;
					(backpackContainer _unit) addItemCargoGlobal [_baseWpn, 1];
					{(backpackContainer _unit) addItemCargoGlobal [_x, 1]} forEach _items;
				};
			};

			_comparisonArray = ([[_unit,_baseWpn,true],"getStoredWeaponItems"] call INCON_ucr_fnc_gearHandler);

			_weaponArray = [_baseWpn,_items,_comparisonArray,[_mag,_ammoCount]];
			_weaponStore = _unit getVariable "INC_weaponStore";

			sleep 0.1;

			_weaponStore set [_id,_weaponArray];

			_unit setVariable ["INC_weaponStore",_weaponStore];
			_unit setVariable ["INC_weaponStoreActive",true];

			if ((isClass(configFile >> "CfgPatches" >> "ace_main")) && {primaryWeapon _unit == ""}) then {
				_unit call ace_weaponselect_fnc_putWeaponAway;
			};
		};
	};

	case "unConcealWeapon": {

		private ["_id","_wpn","_mag","_ammoCount","_items","_weaponArray","_weaponStore"];

		_input params ["_unit"];

		_return = true;
		_weapons = [];
		_id = 999;

		if ((primaryWeapon _unit != "") && {secondaryWeapon _unit != ""}) exitWith {_return = false};

		//Prioritising primary weapons, return an array of either primary or handgun weapons
		if (primaryWeapon _unit == "") then {
			{
				if ((_x isKindOf ["Rifle", configFile >> "CfgWeapons"]) && {primaryWeapon _unit == ""}) then {
					_weapons pushBack _x;
					_id = 0;
				};
			} forEach (weapons _unit);
		};

		if (handgunWeapon _unit == "") then {
			if (_weapons isEqualTo []) then {
				{
					if ((_x isKindOf ["Pistol", configFile >> "CfgWeapons"]) && {handgunWeapon _unit == ""}) then {
						_weapons pushBack _x;
						_id = 1;
					};
				} forEach (weapons _unit);
			};
		};

		//If there's no weapons of either type, exit
		if (_id == 999) exitWith {_return = false};

		[_unit,_weapons,_id] spawn {

			params ["_unit","_weapons","_id"];
			private ["_weapons","_itemsToAdd","_wpn","_mag","_ammoCount","_items","_weaponArray","_weaponStore","_unitItems"];

			//Find out if the unit's prioritised weapon of the given id (0 being rifles, 1 being pistols) has been stored before
			_weaponArray = ((_unit getVariable "INC_weaponStore") select _id);

			switch (
				!(_weaponArray isEqualTo []) &&
				{(_weaponArray select 0) in weapons _unit} &&
				{
					(_weaponArray select 2) isEqualTo ([[_unit,(_weaponArray select 0),true],"getStoredWeaponItems"] call INCON_ucr_fnc_gearHandler)
				}
			) do {
				case true: {
					_wpn = _weaponArray select 0;
					_itemsToAdd = _weaponArray select 1;

					_itemsToAdd = _itemsToAdd select {_x in ((uniformItems _unit) + (vestItems _unit) + (backPackItems _unit) + ([[_unit,(_weaponArray select 0)],"getStoredWeaponItems"] call INCON_ucr_fnc_gearHandler))};

					_unit removeItem _wpn;

					_unit addWeapon _wpn;

					sleep 0.1;

					switch (_id) do {
						case 0: {
							{
								_unit removeItem _x;
								_unit addPrimaryWeaponItem _x;
							} forEach _itemsToAdd;
						};

						case 1: {
							{
								_unit removeItem _x;
								_unit addHandgunItem _x
							} forEach _itemsToAdd;
						};
					};
				};

				case false: {
					_wpn = selectRandom _weapons;
					_ammoArray = ([[_unit,_wpn], "getStoredWeaponAmmoArray"] call INCON_ucr_fnc_gearHandler);
					_ammoArray params [["_mag",""],["_ammoCount",0]];
					_itemsToAdd = ([[_unit,_wpn], "getStoredWeaponItems"] call INCON_ucr_fnc_gearHandler);
					_unit removeItem _wpn;

					if !(_mag == "") then {_unit addMagazine _mag};

					_unit addWeapon _wpn;

					if !(_mag == "") then {_unit setAmmo [_wpn,_ammoCount]};


					removeAllPrimaryWeaponItems _unit;

					sleep 0.1;

					switch (_id) do {
						case 0: {
							{_unit addPrimaryWeaponItem _x} forEach _itemsToAdd;
						};

						case 1: {
							{_unit addHandgunItem _x} forEach _itemsToAdd;
						};
					};
				};
			};
		};
	};

	case "switchUniforms": {

		_input params ["_unit",["_switchUniform",true],["_attempt",1],["_autoReAttempt",true],["_radius",5]];

		private ["_activeContainer","_newUnif","_origUnif","_newUnifItems","_droppedUniform","_containerArray","_isMan"];

		_isMan = false;

		_containerArray = [];

		if (_attempt <= 1) then {_containerArray = (nearestObjects [_unit, ["GroundWeaponHolder"],_radius])};

		if ((count _containerArray == 0) && {_attempt <= 2}) then {_attempt = 2; _containerArray = (_unit nearEntities [["LandVehicle","Ship","Air"],_radius])};

		if ((count _containerArray == 0) && {_attempt <= 3}) then {_attempt = 3; _containerArray =  (nearestObjects [_unit, ["ReammoBox_F"],_radius])};

		if ((count _containerArray == 0) && {_attempt <= 4}) then {
			_attempt = 4;
			_isMan = true;
			_containerArray = (nearestObjects [_unit, ["Man"],_radius]) select {
				(!alive _x)
			};

		};

		if (count _containerArray == 0) exitWith {_return = false};

		_activeContainer = (_containerArray select 0);

		_origUnif = uniform _unit;
		_origUnifItems = uniformItems _unit;

		switch (_isMan) do {
			case true: {

				if (
					(uniform _activeContainer in (INC_civilianUniforms + INC_incogUniforms)) &&
					{(uniform _activeContainer) != _origUnif}
				) then {
					_newUnif = uniform _activeContainer;
				};

			};

			case false: {
				_newUnif = (((everyContainer _activeContainer) select {
				    (
						(
							(((_x select 0) find "U_") >= 0) ||
							{(((_x select 0) find "uniform") >= 0)} ||
							{(((_x select 0) find "Uniform") >= 0)}
						) &&
						{
							!(((_x select 0) find _origUnif) == 0) ||
							{_origUnif == ""}
						} &&
						{(_x select 0) in (INC_civilianUniforms + INC_incogUniforms)}
					)
				}) select 0);
			};
		};

		if (isNil "_newUnif") exitWith {
			_return = false;
			if (_autoReAttempt && {_attempt <= 3}) then {
				_return = [[_unit,_switchUniform,(_attempt + 1)],"switchUniforms"] call INCON_ucr_fnc_gearHandler;
			};
		};

		_return = true;

		if (_switchUniform) then {

			switch (_isMan) do {
				case true: {
					[_activeContainer,_unit] spawn {
						params ["_deadGuy","_opportunist"];
						private ["_gwh","_oldUniform","_deadUniform","_oldItems"];

						[_opportunist,"AinvPercMstpSnonWnonDnon_Putdown_AmovPercMstpSnonWnonDnon"] remoteExec ["playMove",0];

						_oldUniform = uniform _opportunist;
						_deadUniform = uniform _deadGuy;
						_oldItems = uniformItems _opportunist;
						_deadGuyItems = uniformItems _deadGuy;

						sleep 0.2;

						_gwh = createVehicle ["GroundWeaponHolder", getPosATL _opportunist, [], 0, "CAN_COLLIDE"];
						_gwh addItemCargoGlobal [_oldUniform, 1];
						{_gwh addItemCargoGlobal [_x, 1];} forEach (_deadGuyItems);

						sleep 2;

						removeUniform _deadGuy;
						_opportunist forceAddUniform _deadUniform;
						{(uniformContainer _opportunist) addItemCargoGlobal [_x, 1];} forEach (_oldItems);
					};
				};

				case false: {
					[_unit,_activeContainer,_origUnifItems,_origUnif,_newUnif] spawn {
						params ["_unit","_activeContainer","_origUnifItems","_origUnif","_newUnif"];

						private ["_newCrateCargo","_oldGwh"];

						_oldGwh = false;
						_newCrateCargo = [];

						if (_activeContainer isKindOf "GroundWeaponHolder") then {_oldGwh = true};

						_activeContainer addItemCargoGlobal [(_origUnif), 1];

						//_newUnifItems = (itemcargo (_newUnif select 1)) + (magazinecargo (_newUnif select 1)) + (weaponcargo (_newUnif select 1));

						[_unit,"AinvPercMstpSnonWnonDnon_Putdown_AmovPercMstpSnonWnonDnon"] remoteExec ["playMove",0];

						sleep 0.2;

						//{_activeContainer addItemCargoGlobal [_x, 1];} forEach (_newUnifItems);

						sleep 1;

						_unit forceAddUniform (_newUnif select 0);

						sleep 0.2;

						{(uniformContainer _unit) addItemCargoGlobal  [_x, 1]} forEach (_origUnifItems);

						sleep 0.1;

						//_newCrateCargo = (itemcargo _activeContainer) + (magazinecargo _activeContainer) + (weaponcargo _activeContainer);

						for "_i" from 0 to ((count (everyContainer _activeContainer))-1) do {
						    private ["_container","_contents"];
							_container = ((everyContainer _activeContainer) select _i);
							_contents = (itemcargo (_container select 1)) + (magazinecargo (_container select 1)) + (weaponcargo (_container select 1));
							{_newCrateCargo pushBack _x} forEach _contents;
							_newCrateCargo pushBack (_container select 0);
						};

						_newCrateCargo set [(_newCrateCargo find (_newUnif select 0)),-1];
						_newCrateCargo = _newCrateCargo - [-1];

						sleep 0.2;

						switch (_oldGwh) do {
							case true: {

								clearItemCargoGlobal _activeContainer;
								deleteVehicle _activeContainer;
								 _newActiveContainer = createVehicle ["GroundWeaponHolder", getPosATL _unit, [], 0, "CAN_COLLIDE"];
 								{_newActiveContainer addItemCargoGlobal [_x,1]} forEach (_newCrateCargo);

							};

							case false: {
								clearItemCargoGlobal _activeContainer;
								{_activeContainer addItemCargoGlobal [_x,1]} forEach (_newCrateCargo);

							};
						};
					};
				};
			};
		};
	};
};

_return
