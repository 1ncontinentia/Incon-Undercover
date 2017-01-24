/*

Author: Spyderblack723

Modified by: Incontinentia
*/

private ["_unit","_linkedItems","_pack","_uniform","_headgearList"];

params ["_gearType","_factions"];

private _result = [];

private _units = [];
private _cfgVehicles = configFile >> "CfgVehicles";

for "_i" from 0 to (count _cfgVehicles - 1) do {
    _entry = _cfgVehicles select _i;

    if (isclass _entry) then {
        if (
            (getText(_entry >> "faction") in _factions) &&
            {getNumber(_entry >> "scope") >= 2} &&
            {configname _entry isKindOf "Man"}
        ) then {
            _units pushback _entry;
        };
    };
};

switch (_gearType) do {

    case "backpacks": {
        {
            _pack =  getText (_x >> "backpack");;
            _result pushbackunique _pack;
        } forEach _units;
    };

    case "headgear": {
        {
            _unit = _x;
            _linkedItems = getArray (_unit >> "linkedItems");

            {
                _item = _x;
                _configPath = configFile >> "CfgWeapons" >> _item;
                    if (isClass _configPath) then {
                        _itemInfo = getNumber (_configPath >> "ItemInfo" >> "Type");

                        switch (str _itemInfo) do {
                            case "605": {
                                _result pushbackunique _item;
                            };
                        };
                    };
            } forEach _linkedItems;
        } forEach _units;
    };

    case "possibleHeadgear": {
        {
            _unit = _x;
            _headgearList = (getArray (_unit >> "headgearList")) select {typeName _x == "STRING"};

            {
                _item = _x;
                _configPath = configFile >> "CfgWeapons" >> _item;
                    if (isClass _configPath) then {
                        _itemInfo = getNumber (_configPath >> "ItemInfo" >> "Type");

                        switch (str _itemInfo) do {
                            case "605": {
                                _result pushbackunique _item;
                            };
                        };
                    };
            } forEach _headgearList;
        } forEach _units;
    };

    case "vests": {
        {
            _unit = _x;
            _linkedItems = getArray (_unit >> "linkedItems");
            {
                _item = _x;
                _configPath = configFile >> "CfgWeapons" >> _item;
                    if (isClass _configPath) then {
                        _itemInfo = getNumber (_configPath >> "ItemInfo" >> "Type");

                        switch (str _itemInfo) do {
                            case "701": {
                                _result pushbackunique _item;
                            };
                        };
                    };
            } forEach _linkedItems;
        } forEach _units;
    };

    case "uniforms": {
        {
            _uniform = getText (_x >> "uniformClass");
            _result pushbackunique _uniform;
        } forEach _units;
    };

    case "units": {
        {
            _unit = configName _x;
            if ((_unit isKindOf "Man") && {(((str _x) find "Pilot") == -1)} && {(((str _x) find "pilot") == -1)}) then {
                _result pushbackunique _unit
            };
        } forEach _units;
    };

    case "weapons": {
        {
            _unit = _x;
            _weaponArray = getArray (_unit >> "weapons");
            {
                _item = _x;
                _configPath = configFile >> "CfgWeapons" >> _item;
                    if (isClass _configPath) then {
						_result pushbackunique _item;
                    };
            } forEach _weaponArray;
        } forEach _units;
    };
};

_result
