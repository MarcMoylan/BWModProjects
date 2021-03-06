//=============================================================================
// DragonsToothSword.
//
// A very large and powerful sword capable of one hit kills.
// It is incredibly strong but attacks slower than all other melee weapons.
// Has a secondary lunge capable of extreme damage.
//
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DragonsToothSword extends BallisticMeleeWeapon;

var Actor	BladeGlow;				// Nano replicators

simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);

	if ((Instigator.PlayerReplicationInfo != None) && (Instigator.PlayerReplicationInfo.Team != None) )
	{
		if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 0 )
		{
			Instigator.SoundPitch = 48;
			Skins[1] = Shader'BWBP_SKC_Tex.DragonToothSword.DTS-Red';
			if (ThirdPersonActor != None)
				DragonsToothAttachment(ThirdPersonActor).bRedTeam=true;	
		}
	}

	Instigator.AmbientSound = UsedAmbientSound;
	Instigator.SoundVolume = 192;
	Instigator.SoundPitch = 64;
	Instigator.SoundRadius = 384;
	Instigator.bFullVolume = false;
}

simulated function BladeEffectStart()
{
	if ((Instigator.PlayerReplicationInfo.Team != None) )
	{
		if (Instigator.PlayerReplicationInfo.Team.TeamIndex == 0 )
			class'bUtil'.static.InitMuzzleFlash(BladeGlow, class'DragonsToothBladeEffectR', DrawScale, self, 'BladeBase');
		else
			class'bUtil'.static.InitMuzzleFlash(BladeGlow, class'DragonsToothBladeEffect', DrawScale, self, 'BladeBase');
	}
	else
		class'bUtil'.static.InitMuzzleFlash(BladeGlow, class'DragonsToothBladeEffect', DrawScale, self, 'BladeBase');

}

simulated function bool PutDown()
{
	if (super.PutDown())
	{
		if (BladeGlow != None)	BladeGlow.Destroy();
		Instigator.AmbientSound = None;
		Instigator.SoundVolume = Instigator.default.SoundVolume;
		Instigator.SoundPitch = Instigator.default.SoundPitch;
		Instigator.SoundRadius = Instigator.default.SoundRadius;
		Instigator.bFullVolume = Instigator.default.bFullVolume;
		return true;
	}
	return false;
}

simulated function Destroyed()
{
	if (BladeGlow != None)	BladeGlow.Destroy();
	if (Instigator.AmbientSound != None)
	{
		Instigator.AmbientSound = None;
		Instigator.SoundVolume = Instigator.default.SoundVolume;
		Instigator.SoundPitch = Instigator.default.SoundPitch;
		Instigator.SoundRadius = Instigator.default.SoundRadius;
		Instigator.bFullVolume = Instigator.default.bFullVolume;
	}
	super.Destroyed();
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
     PlayerSpeedFactor=1.100000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     //UsedAmbientSound=Sound'BWBP_SKC_Sounds.DTS.DragonsTooth-Loop'
     BigIconMaterial=Texture'BWBP_SKC_Tex.DragonToothSword.BigIcon_DTS'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     SpecialInfo(0)=(Info="420.0;20.0;-999.0;-1.0;-999.0;0.9;-999.0")
     BringUpSound=(Sound=Sound'BWBP_SKC_Sounds.DTS.DragonsTooth-Draw',Volume=16.100000)
     MagAmmo=1
     bNoMag=True
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.X3OutA',Pic2=Texture'BallisticUI2.Crosshairs.Misc11',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(G=207),Color2=(B=255,G=27,R=71,A=93),StartSize1=98,StartSize2=101)
     CrosshairInfo=(SpreadRatios=(X1=0.250000,Y1=0.375000,X2=1.000000,Y2=1.000000),MaxScale=8.000000)
     GunLength=0.000000
     bAimDisabled=True
     FireModeClass(0)=Class'BWBP_SKC_Fix.DragonsToothPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.DragonsToothSecondaryFire'
     SelectAnim="PulloutFancy"
     HudColor=(B=255,G=125,R=75)
     PutDownTime=0.5
     BringUpTime=0.700000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.400000
     CurrentRating=0.400000
     SelectAnimRate=1.25
     bMeleeWeapon=True
     Description="XM300 Dragon Nanoblade||Manufacturer: XWI Elite Systems|Primary: Slash|Secondary: Double Slash|Special: Block||The Dragon Nanoblade is a technological marvel. A weapon consisting of a nanotechnologically created blade which is dynamically 'forged' on command into a non-eutactic solid. Nanoscale whetting devices ensure that the blade is both unbreakable and lethally sharp. The true weapon of a modern warrior."
     DisplayFOV=65.000000
     Priority=12
     CenteredOffsetY=7.000000
     CenteredRoll=0
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     GroupOffset=5
     PickupClass=Class'BWBP_SKC_Fix.DragonsToothPickup'
     BobDamping=1.000000
     AttachmentClass=Class'BWBP_SKC_Fix.DragonsToothAttachment'
     IconMaterial=Texture'BWBP_SKC_Tex.DragonToothSword.SmallIcon_DTS'
     IconCoords=(X2=127,Y2=31)
     ItemName="XM300 Dragon Nanoblade"
     Mesh=SkeletalMesh'BWBP_SKC_Anim.DragonToothFP'
     DrawScale=1.250000
     SoundRadius=32.000000
}
