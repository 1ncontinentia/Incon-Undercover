
class INC_undercover
{
	tag = "Incon Undercover Operations";
	class UCR
	{
		file = "INC_undercover\func";
		class ucrMain {description = "Contains functions for arming recruitable civilians."};
		class countAlerted {description = "Counts units of the defined side who have been alerted to a unit.";};
		class getFactionGear {description = "Gets a faction's gear.";};
		class recruitAttempt {description = "Attempt to recruit - requires ALiVE.";};
		class recruitCiv {description = "Allows civilians to be recruited. Also gives them either a rifle or pistol.";};
		class undercoverCompromised {description = "Sets the unit as compromised while it is know to enemy units and is doing something naughty.";};
		class undercoverCooldown {description = "Initiates a cooldown after the unit has done something naughty";};
		class undercoverGetAlerted {description = "Returns the number of given side who know about the unit";};
		class UCRhandler {description = "Gets detection scripts running on unit.";};
		class undercoverKilledHandler {description = "Handles enemy deaths - enemies may become suspicious if they know about a nearby undercover unit. Also includes options for reprisals against civilians if the side is predefined as brutal in the setup.";};
	};
};
