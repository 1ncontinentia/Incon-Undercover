
class INC_undercover
{
	tag = "INCON";
	class undercoverRecruit
	{
		file = "INC_undercover\func";
		class addEH {description = "Handles enemy deaths including suspecting nearby undercover units and reprisals against civilians.";};
		class armedLoop  {description = "Contains functions for arming recruitable civilians."};
		class compromised {description = "Sets the unit as compromised while it is know to enemy units and is doing something naughty.";};
		class cooldown {description = "Initiates a cooldown after the unit has done something naughty";};
		class countAlerted {description = "Counts units of the defined side who have been alerted to a unit.";};
		class getAlerted {description = "Returns the number of given side who know about the unit";};
		class getConfigInfo {description = "Gets a faction's gear.";};
		class recruitAttempt {description = "Attempt to recruit - requires ALiVE.";};
		class recruitCiv {description = "Allows civilians to be recruited. Also gives them either a rifle or pistol.";};
		class ucrMain {description = "Contains functions for arming recruitable civilians."};
		class UCRhandler {description = "Gets detection scripts running on unit.";};
	};
};
