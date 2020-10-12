//=============================================================================
// ICISKnife.
//
// Radiation poisoning in a syringe! Get 35 hp! Lose 40 garduallalrlaly!
//
// by me
// Copyright© 2011 RuneStorm. All Rights Reserved.
//=============================================================================
class ICISStimpack extends BallisticWeapon;

var() sound		HealSound;		// The sound of stabbing Calypstostostso



simulated function Notify_SelfInject()
{
	PlaySound(HealSound, SLOT_Misc, 1.5, ,64);
	Instigator.GiveHealth(60, Instigator.SuperHealthMax);
	DoDartEffect(Instigator, Instigator);
	Ammo[1].UseAmmo (1, True);
}

static function DoDartEffect(Actor Victim, Pawn Instigator)
{
	local ICISPoisoner IP;

	if(Pawn(Victim) == None || Vehicle(Victim) != None || Pawn(Victim).Health <= 0)
		Return;


	IP = Victim.Level.Spawn(class'ICISPoisoner', Pawn(Victim).Owner);

	IP.Instigator = Instigator;

    if(Victim.Role == ROLE_Authority && Instigator != None && Instigator.Controller != None)
		IP.InstigatorController = Instigator.Controller;

	IP.Initialize(Victim);
}


simulated function bool PutDown()
{
	local BCGhostWeapon GW;
	if (Super.PutDown())
	{
		if (Ammo[0].AmmoAmount < 1)
		{
			// Save a ghost of this weapon so it can be brought back
			GW = Spawn(class'BCGhostWeapon',,,Instigator.Location);
        		if(GW != None)
	        	{
    	    			GW.MyWeaponClass = class;
				GW.GiveTo(Instigator);
			}
			Timer();
			PickupClass=None;
			DropFrom(Location);
			return true;
		}
		return true;
	}
	return false;
}

simulated event AnimEnd (int Channel)
{
    local name Anim;
    local float Frame, Rate;

    GetAnimParams(0, Anim, Frame, Rate);
	if (Anim == FireMode[0].FireAnim)
	{
		CheckNoGrenades();
	}
	else if (Anim == SelectAnim)
		PlayIdle();
	else
		Super.AnimEnd(Channel);
}


simulated function CheckNoGrenades()
{
	local BCGhostWeapon GW;
	if (Ammo[0]!= None && ( Ammo[0].AmmoAmount < 1 || (Ammo[0].AmmoAmount == 1 && (BFireMode[0].ConsumedLoad > 0  || BFireMode[1].ConsumedLoad > 0)) ))
	{
		AIRating = -999;
		Priority = -999;
		Instigator.Weapon = None;
		// Save a ghost of this wepaon so it can be brought back
		if (Role == ROLE_Authority)
		{
			GW = Spawn(class'BCGhostWeapon',,,Instigator.Location);
    	    		if(GW != None)
        		{
        			GW.MyWeaponClass = class;
				GW.GiveTo(Instigator);
			}
		}

		if (Instigator!=None && Instigator.Controller!=None)
			Instigator.Controller.ClientSwitchToBestWeapon();
		Destroy();
	}
	else
		PlayAnim(SelectAnim, SelectAnimRate, 0.0);
}

simulated function RemoteKill()
{
	local BCGhostWeapon GW;
	AIRating = -999;
	Priority = -999;
	// Save a ghost of this wepaon so it can be brought back
	if (Role == ROLE_Authority)
	{
		GW = Spawn(class'BCGhostWeapon',,,Instigator.Location);
    	    	if(GW != None)
        	{
        		GW.MyWeaponClass = class;
			GW.GiveTo(Instigator);
		}
	}
	Destroy();
}

// AI Interface =====
function bool CanAttack(Actor Other)
{
	return true;
}

// choose between regular or alt-fire
function byte BestMode()
{
	local Bot B;
	local float Result;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if (VSize(B.Enemy.Location - Instigator.Location) > FireMode[0].MaxRange()*1.5)
		return 1;
	Result = FRand();
	if (vector(B.Enemy.Rotation) dot Normal(Instigator.Location - B.Enemy.Location) < 0.0)
		Result += 0.3;
	else
		Result -= 0.3;

	if (Result > 0.5)
		return 1;
	return 0;
}

function float GetAIRating()
{
	local Bot B;
	local float Result, Dist;
	local vector Dir;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	Dir = B.Enemy.Location - Instigator.Location;
	Dist = VSize(Dir);

	Result = AIRating;
	// Enemy too far away
	if (Dist > 1500)
		return 0.1;			// Enemy too far away
	// Better if we can get him in the back
	if (vector(B.Enemy.Rotation) dot Normal(Dir) < 0.0)
		Result += 0.08 * B.Skill;
	// If the enemy has a knife too, a gun looks better
	if (B.Enemy.Weapon != None && B.Enemy.Weapon.bMeleeWeapon)
		Result = FMax(0.0, Result *= 0.7 - (Dist/1000));
	// The further we are, the worse it is
	else
		Result = FMax(0.0, Result *= 1 - (Dist/1000));

	return Result;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()
{
	if (AIController(Instigator.Controller) == None)
		return 0.5;
	return AIController(Instigator.Controller).Skill / 4;
}

// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()
{
	local Bot B;
	local float Result, Dist;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return -0.5;

	Dist = VSize(B.Enemy.Location - Instigator.Location);

	Result = -1 * (B.Skill / 6);
	Result *= (1 - (Dist/1500));
    return FClamp(Result, -1.0, -0.3);
}
// End AI Stuff =====

defaultproperties
{
     HealSound=Sound'BWBP_SKC_SoundsExp.Stealth.Stealth-Heal'

     PlayerSpeedFactor=1.150000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     BigIconMaterial=Texture'BWBP_SKC_TexExp.Stim.BigIcon_Stim'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     InventorySize=10
     SpecialInfo(0)=(Info="0.0;-999.0;-999.0;-1.0;-999.0;-999.0;-999.0")
     BringUpSound=(Sound=Sound'BallisticSounds2.Knife.KnifePullOut')
     PutDownSound=(Sound=Sound'BallisticSounds2.Knife.KnifePutaway')
     MagAmmo=1
     InventoryGroup=7
     bNoMag=True
     WeaponModes(0)=(bUnavailable=True,ModeID="WM_None")
     WeaponModes(1)=(bUnavailable=True)
     WeaponModes(2)=(bUnavailable=True)
     CurrentWeaponMode=0
     bUseSights=False
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.X3OutA',Pic2=Texture'BallisticUI2.Crosshairs.X3InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(R=129,A=192),Color2=(G=196,R=0,A=192),StartSize1=99,StartSize2=107)
     CrosshairInfo=(SpreadRatios=(X1=0.250000,Y1=0.375000,X2=1.000000,Y2=1.000000),MaxScale=8.000000)
     GunLength=0.000000
     bAimDisabled=True
     FireModeClass(0)=Class'BWBP_SKC_Fix.ICISPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.ICISSecondaryFire'
     PutDownTime=0.200000
     BringUpTime=0.200000
     SelectAnimRate=2.500000
     PutDownAnimRate=1.500000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.200000
     CurrentRating=0.200000
     bMeleeWeapon=True
     Description="FMD ICIS 25 Experimental Stimulant Autoinjector||Manufacturer: UTC Defense Tech|Primary: Self Heal|Secondary: Stab/Inject||Chemical Formula KFBR382, serum #25 is one in a long line of exerimental military stimulants, and is one of the more successful prototypes. It is supplied alongside the heavy-duty Intravenous Chemical Injection System for troop use in dangerous situations, and while previous serums were never able to breach the 50% mortality mark, No. 25 is showing serious potential and is being fielded to select testing groups. Studies show that #25 increases aggression, suppresses pain receptors, and allows troops to continue fighting past fatigue points that were previously thought impossible. Unfortunately, some #25-injected troops are already showing signs of severe psychosis and a few others have already died of unforeseen cardiac explosions."
     Priority=13
     CenteredOffsetY=7.000000
     CenteredRoll=0
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     PickupClass=Class'BWBP_SKC_Fix.ICISPickup'
     PlayerViewOffset=(X=20.000000,Y=0.000000,Z=-10.000000)
     BobDamping=1.700000
     AttachmentClass=Class'BWBP_SKC_Fix.ICISAttachment'
     IconMaterial=Texture'BWBP_SKC_TexExp.AK490.SmallIcon_Stim'
     IconCoords=(X2=128,Y2=32)
     ItemName="FMD ICIS-25 Stimpack"
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.Stimpack_FP'
     DrawScale=0.300000
}
