class Mut_BerserkSwap extends Mutator;

const numOptions = 6;
var config float UDamageChance;
var config float SuperHealthChance;
var config bool bFistsOnStart;
var config bool bInstagibOnStart;
var config bool bEnhancedDamage;
var config bool bRandomizedDamage;
var config bool bNoCamo;
var config bool bNoCamoEffects;
var const           string OptionNames[numOptions];
var const           string OptionType[numOptions];
var const           string OptionExtras[numOptions];
var const localized string OptionDescriptions[numOptions];
var const localized string OptionHelp[numOptions];


function ModifyPlayer(Pawn Other)
{
	if (bFistsOnStart)	
	{
		Other.GiveWeapon("BWBP_SKC_Fix.DoomFists");
	}
	if (bInstagibOnStart)	
	{
		Other.GiveWeapon("BWBP_SKC_Fix.LS440Instagib");
	}
		Super.ModifyPlayer(Other);
}
/*
function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
      local float i;
	if ( xPickupBase(Other) != None )
	{
		if (xPickupBase(Other).Powerup == class'XPickups.UDamagePack' || xPickupBase(Other).Powerup == class'BallisticFix.IP_UDamage')
		{
		    	i = FRand();
		    	if (i <= UDamageChance)
			{
		      		xPickupBase(Other).Powerup = class'BWBP_SKC_Fix.IP_Berserk';
				if (xPickupBase(Other).myEmitter != None)
					xPickupBase(Other).myEmitter.Destroy();
			}
            		else
                		xPickupBase(Other).Powerup = class'BallisticFix.IP_UDamage';
		}
        	if (xPickupBase(Other).Powerup == class'XPickups.SuperHealthPack' || xPickupBase(Other).Powerup == class'BallisticFix.IP_SuperHealthKit')
		{
		    	i = FRand();
		    	if (i <= SuperHealthChance)
		        	xPickupBase(Other).Powerup = class'BWBP_SKC_Fix.IP_BerserkAlt';
            	else
                	xPickupBase(Other).Powerup = class'BallisticFix.IP_SuperHealthKit';
		}
		else
			return true;
	}
	else
		return true;
}
*/
static function FillPlayInfo(PlayInfo PlayInfo)
{
    local int i;
    local byte b;
    local string desc, type;

    super.FillPlayInfo(PlayInfo);

    for (i = 0; i < numOptions; i++)
    {
        if (default.OptionNames[i] == "")
            continue;

        if (default.OptionDescriptions[i] == "")
            desc = default.OptionNames[i];
        else
            desc = default.OptionDescriptions[i];

        type = default.OptionType[i];
        if (type == "")
            type = "Text";

        if (default.OptionExtras[i] == "")
            PlayInfo.AddSetting(default.RulesGroup, default.OptionNames[i], desc, 0, b++, type);
        else
            PlayInfo.AddSetting(default.RulesGroup, default.OptionNames[i], desc, 0, b++, type, default.OptionExtras[i]);
    }
}

static event string GetDescriptionText(string PropName)
{
    local int i;

    for (i = 0; i < numOptions; i++)
        if (default.OptionNames[i] == PropName)
            return default.OptionHelp[i];

    return "";
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	if (bNoCamo)
	{
		class'BallisticCamoWeapon'.default.bAllowCamo=false;	
		class'BallisticCamoHandgun'.default.bAllowCamo=false;	
	}
	else
	{
		class'BallisticCamoWeapon'.default.bAllowCamo=true;
		class'BallisticCamoHandgun'.default.bAllowCamo=true;
	}	
	if (bNoCamoEffects)
	{
		class'BallisticCamoWeapon'.default.bAllowCamoEffects=false;
		class'BallisticCamoHandgun'.default.bAllowCamoEffects=false;
	}
	else
	{
		class'BallisticCamoWeapon'.default.bAllowCamoEffects=true;
		class'BallisticCamoHandgun'.default.bAllowCamoEffects=true;
	}
	if (bRandomizedDamage)
		class'BallisticWeapon'.default.bRandomDamage=True;
	else
		class'BallisticWeapon'.default.bRandomDamage=false;
	if (bEnhancedDamage)
		class'BallisticWeapon'.default.bEvenBodyDamage=True;
	else
		class'BallisticWeapon'.default.bEvenBodyDamage=False;
}

defaultproperties
{
//     UDamageChance=0.500000
     bFistsOnStart=True
     bInstagibOnStart=False
     bNoCamo=False
     bNoCamoEffects=False
//     OptionNames(0)="UDamageChance"
//     OptionNames(1)="SuperHealthChance"
     OptionNames(0)="bFistsOnStart"
     OptionNames(1)="bInstagibOnStart"
     OptionNames(2)="bEnhancedDamage"
     OptionNames(3)="bRandomizedDamage"
     OptionNames(4)="bNoCamo"
     OptionNames(5)="bNoCamoEffects"
     OptionType(0)="Check"
     OptionType(1)="Check"
     OptionType(2)="Check"
     OptionType(3)="Check"
     OptionType(4)="Check"
     OptionType(5)="Check"
//     OptionExtras(0)="1;0.0:1.0"
//     OptionExtras(1)="1;0.0:1.0"
//     OptionDescriptions(0)="UDamage Swap Probability"
//     OptionDescriptions(1)="Super Health Swap Probability"
     OptionDescriptions(0)="Spawn with Fists"
     OptionDescriptions(1)="Spawn with Instagib Rifles"
     OptionDescriptions(2)="Enable tactical damage"
     OptionDescriptions(3)="Enable variable damage"
     OptionDescriptions(4)="Disable random camouflage"
     OptionDescriptions(5)="Disable camouflage effects"
//     OptionHelp(0)="How probable a UDamage pickup will be swapped with the Berserk pack (O = Never, 1 = Always)."
//     OptionHelp(1)="How probable a Super Health pickup will be swapped with the Berserk pack (O = Never, 1 = Always)."
     OptionHelp(0)="Should players have the Fists as an additional starting weapon?"
     OptionHelp(1)="Should players have the all powerful Instagib Rifle?"
     OptionHelp(2)="Enhances limb damage to promote more tactical gameplay"
     OptionHelp(3)="Re-enables the Ballistic randomized damage for varied combat"
     OptionHelp(4)="Turns off random camo patterns for the weapons"
     OptionHelp(5)="Turns off most camouflage camo functionality changes"
     FriendlyName="Ballistic Recolors [Config]"
     Description="This mutator allows you to always spawn with fists. You can also use it to grant Instagib rifles and enable randomized or enhanced damage for the Ballistic mod.|Made by Sergeant Kelly and Captain Xavious."
}
