//=============================================================================
// X8Knife.
//
// The X3's launchable brother! Designed as a bayonet and not a handheld knife!
//
// by Logan "BlackEagle" Richert.
// uses code by Nolan "Dark Carnivour" Richert.
// Copyright© 2011 RuneStorm. All Rights Reserved.
//=============================================================================
class X8Knife extends BallisticWeapon;

var() name				KnifeBone;		//Bone of whole grenade. Used to hide grenade at the right time
var() name				PinBone;			//Bone of pin. Used to hide pin
var() BUtil.FullSound	PinPullSound;		//Sound to play for pin pull


simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);

	SetBoneScale (0, 1.0, KnifeBone);
	SetBoneScale (1, 1.0, PinBone);
}

simulated function bool PutDown()
{
	local BCGhostWeapon GW;
	if (Super.PutDown())
	{
		SetBoneScale (1, 1.0, PinBone);
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

simulated function PlayIdle()
{
	super.PlayIdle();
	SetBoneScale (1, 0.0, PinBone);
}

simulated function Notify_KnifeLeaveHand()
{
	SetBoneScale (0, 0.0, KnifeBone);
}
// Anim Notify for pin pull
simulated function Notify_KnifePinPull ()
{
    class'BUtil'.static.PlayFullSound(self, PinPullSound);
}

simulated event AnimEnd (int Channel)
{
    local name Anim;
    local float Frame, Rate;

    GetAnimParams(0, Anim, Frame, Rate);

	if (Anim == FireMode[1].FireAnim)
	{
		SetBoneScale (1, 1.0, PinBone);
		SetBoneScale (0, 1.0, KnifeBone);
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


/*simulated event Tick (float DT) //Damn it. Resorting to tick for remote kills. No longer really remote...
{
	if (Ammo[0].AmmoAmount == 0)
	{
		RemoteKill();
	}

	super.Tick(DT);
}*/

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
     AIRating=0.200000
     AttachmentClass=Class'BWBP_SKC_Fix.X8Attachment'
     bAimDisabled=True
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     BigIconMaterial=Texture'BWBP_SKC_TexExp.AK490.BigIcon_X8'
	 bNonCocking=True
     bMeleeWeapon=True
     bNoMag=True
     BobDamping=1.700000
     BringUpSound=(Sound=Sound'BallisticSounds2.Knife.KnifePullOut')
     BringUpTime=0.800000
     bUseSights=False
     CenteredOffsetY=7.000000
     CenteredRoll=0
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.X3OutA',Pic2=Texture'BallisticUI2.Crosshairs.X3InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(R=129,A=192),Color2=(G=196,R=0,A=192),StartSize1=99,StartSize2=107)
     CrosshairInfo=(SpreadRatios=(X1=0.250000,Y1=0.375000,X2=1.000000,Y2=1.000000),MaxScale=8.000000)
     CurrentRating=0.200000
     CurrentWeaponMode=0
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     Description="X8 Ballistic Knife||Manufacturer: Zavod Tochnogo Voorujeniya|Primary: Slash / Stab|Secondary: Launch Blade||A counterpart to Enravion’s X3 Knife, the X8 Ballistic Knife is the Eastern Bloc’s preferred way to deal with CQC enemies. While primarily used as a bayonet on the venerable AK490, the X8 is still quite effective in hand to hand fighting thanks to its lethally sharp blade. When opponents are too far to gut personally, the unique gas propellant mechanism inside the hilt of the knife lets the user turn their knife into a fast moving spear. Several unfortunate accidents have caused the X8 to be considered unfit for civilian use."
     DrawScale=0.300000
     FireModeClass(0)=Class'BWBP_SKC_Fix.X8PrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.X8SecondaryFire'
     GunLength=0.000000
     IconCoords=(X2=128,Y2=32)
     IconMaterial=Texture'BWBP_SKC_TexExp.AK490.SmallIcon_X8'
     InventorySize=10
     ItemName="X8 Ballistic Knife"
     KnifeBone="Blade"
     MagAmmo=1
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.BalKnife_FP'
     PickupClass=Class'BWBP_SKC_Fix.X8Pickup'
     PinBone="Pin"
     PinPullSound=(Sound=Sound'BallisticSounds3.NRP57.NRP57-ClipOut',Volume=0.500000,Radius=48.000000,Pitch=1.600000,bAtten=True)
     PlayerSpeedFactor=1.150000
     PlayerViewOffset=(X=20.000000,Y=0.000000,Z=-10.000000)
     Priority=13
     PutDownSound=(Sound=Sound'BallisticSounds2.Knife.KnifePutaway')
     PutDownTime=0.500000
     SelectForce="SwitchToAssaultRifle"
     SpecialInfo(0)=(Info="180.0;12.0;-999.0;-1.0;-999.0;-999.0;-999.0")
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     WeaponModes(0)=(bUnavailable=True,ModeID="WM_None")
     WeaponModes(1)=(bUnavailable=True)
     WeaponModes(2)=(bUnavailable=True)
}
