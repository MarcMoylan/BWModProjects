//=============================================================================
// ChaffGrenadeWeapon.
//
// Handheld rifle smoke grenade.
// Can be thrown or used for melee, but once primed will explode on contact with any surfaces
// Meleeing once primed is fairly suicidal. Auto-throw may not be the best choice...
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class ChaffGrenadeWeapon extends BallisticHandGrenade;

var bool bPrimed; //Did we twist the HELL OUT OF THAT CAP?!!?!?
var() name				PutdownAltAnim;	//Anim to play when grenade is unprimed
var() name				ClipReleaseAltAnim;	//Anim to play when grenade is unprimed AGAIN
var() name				GrenadeBone2;		//Bone ofmroegnread


// Fuse ran out before grenade was tossed
simulated function ExplodeInHand()
{
	ClipReleaseTime=666;
	KillSmoke();
	HandExplodeTime = Level.TimeSeconds + 1.0;
	if (IsFiring())
	{
		FireMode[0].bIsFiring=false;
		FireMode[1].bIsFiring=false;
	}
	if (Role == Role_Authority)
	{
		DoExplosionEffects();
		MakeNoise(1.0);
		ConsumeAmmo(0, 1);
		bPrimed=false;
		IdleAnim = 'Idle';
	}
	SetTimer(0.1, false);
}

// This is called as soon as grenade explodes. Don't put anything in here that could kill the player.
simulated function DoExplosionEffects()
{
	BallisticGrenadeAttachment(ThirdPersonActor).HandExplode();
	if (level.NetMode == NM_Client)
		CheckNoGrenades();
}
// Anything that does damage for the explosion should happen here.
// This delayed to prevent player being killed before ammo stuff is sorted out.
function DoExplosion()
{
	if (Role == ROLE_Authority)
	{
		SpecialHurtRadius(HeldDamage, HeldRadius, HeldDamageType, HeldMomentum, Location);
		CheckNoGrenades();
	}
}

simulated event AnimEnd (int Channel)
{
    local name Anim;
    local float Frame, Rate;

    GetAnimParams(0, Anim, Frame, Rate);
	if (Anim == ClipReleaseAnim)
	{
		IdleAnim = 'IdlePrimed';
		PlayIdle();
	}
	else if (Anim == ClipReleaseAltAnim)
	{
		IdleAnim = 'Idle';
		PlayIdle();
	}
	else if (Anim == FireMode[0].FireAnim)
	{
		SetBoneScale (0, 1.0, GrenadeBone);
		SetBoneScale (1, 1.0, GrenadeBone2);
		CheckNoGrenades();
	}
	else if (Anim == SelectAnim)
	{
		IdleAnim = 'Idle';
		PlayIdle();
	}
	else	
    		AnimEnded(Channel, anim, frame, rate);
}


simulated function Timer()
{
	//Do damage
	if (ClipReleaseTime == 666)
	{
		ClipReleaseTime=0.0;
		DoExplosion();
	}
	// Reset
	else if (ClipReleaseTime < 0)
		ClipReleaseTime=0.0;
	// Explode in hand
	else if (ClipReleaseTime > 0)
		ExplodeInHand();
	// Something else
	else
		Super.Timer();
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
	{
		PlayAnim(SelectAnim, 1, 0.0);
		SetBoneRotation('MOACTop', rot(0,0,0));
	}
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

simulated function bool PutDown()
{
	local BCGhostWeapon GW;
	if (bPrimed)
	{
		PutDownAnim=PutdownAltAnim;
		bPrimed=false;
	}
	else
		PutDownAnim=default.PutDownAnim;
	if (Super.PutDown())
	{
		ClipReleaseTime=0.0;
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

simulated function Notify_TurnSound()
{
	class'BUtil'.static.PlayFullSound(self, ClipReleaseSound);
}


simulated function Notify_GrenadeLeaveHand()
{
	SetBoneScale (0, 0.0, GrenadeBone);
	SetBoneScale (1, 0.0, GrenadeBone2);
	if (ClipReleaseTime > 0)
		ClipReleaseTime=-1.0;
}

simulated function ClientStartReload(optional byte i)
{
//	class'BUtil'.static.PlayFullSound(self, ClipReleaseSound);
	if (!bPrimed)
	{
		bPrimed=true;
		if(!IsFiring())
			PlayAnim(ClipReleaseAnim, 1.0, 0.1);
	}
	else
	{
		bPrimed=false;
		if(!IsFiring())
			PlayAnim(ClipReleaseAltAnim, 1.0, 0.1);

	}
}
// Reload releases clip
function ServerStartReload (optional byte i)
{
	if (Ammo[0].AmmoAmount < 1)
		return;
	if (AIController(Instigator.Controller) != None)
		return;
	if (FireMode[0].NextFireTime > Level.TimeSeconds || FireMode[1].NextFireTime > Level.TimeSeconds)
		return;
	ClientStartReload(i);
}
// Weapon special releases clip
//simulated function DoWeaponSpecial(optional byte i)
exec simulated function WeaponSpecial(optional byte i)
{
	if (ClientState == WS_ReadyToFire)
		ServerStartReload();
}

// Charging bar shows throw strength
simulated function float ChargeBar()
{
	return FClamp(FireMode[0].HoldTime - 0.5,  0, 2) / 2;
}


// AI Interface =====
function byte BestMode()
{
	local Bot B;
	local float Dist, Height, result;
	local Vector Dir;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	Dir = Instigator.Location - B.Enemy.Location;
	Dist = VSize(Dir);
	Height = B.Enemy.Location.Z - Instigator.Location.Z;
	result = 0.5;

	if (Dist > 500)
		result -= 0.4;
	else
		result += 0.4;
	if (Abs(Height) > 32)
		result -= Height / Dist;
	if (result > 0.5)
		return 1;
	return 0;
}

function float GetAIRating()
{
	local Bot B;
	local float Result, Dist, Height;
	local vector Dir;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	Dir = B.Enemy.Location - Instigator.Location;
	Dist = VSize(Dir);
	Height = B.Enemy.Location.Z - Instigator.Location.Z;

	Result = AIRating;
	// Enemy too far away
	result += Height/-500;
	if (Height > -200)
	{
		if (Dist > 800)
			Result -= (Dist-800) / 2000;
		if (Dist < 500)
			Result -= 1 - Dist/500;
	}
	return Result;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return 0.2;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return -0.5;	}
// End AI Stuff =====

defaultproperties
{
     PutdownAltAnim="PutawayClipIn"
     ClipReleaseAltAnim="ClipIn"
     GrenadeBone="MOAC"
     GrenadeBone2="MOACTop"
     HeldDamage=70
     HeldRadius=350
     HeldMomentum=75000
     FuseDelay=14.0
     bPrimed=False
     bShowChargingBar=False
     HeldDamageType=Class'BWBP_SKC_Fix.DTChaffGrenade_H'
     GrenadeSmokeClass=Class'BWBP_SKC_Fix.ChaffTrail'
     ClipReleaseSound=(Sound=Sound'BallisticSounds2.BX5.BX5-SecOn',Volume=0.500000,Radius=48.000000,Pitch=1.700000,bAtten=True)
     PinPullSound=(Sound=Sound'BallisticSounds2.NRP57.NRP57-PinOut',Volume=0.500000,Radius=48.000000,Pitch=1.000000,bAtten=True)
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     BigIconMaterial=Texture'BWBP_SKC_TexExp.M4A1.BigIcon_MOAC'
     BallisticInventoryGroup=0
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Hazardous=True
     bWT_Splash=True
     bWT_Grenade=True
	SelectAnimRate=2
     	BringUpTime=0.900000
	PutDownAnimRate=2
     SpecialInfo(0)=(Info="20.0;-666.0;-666.00;-666.0;-666.0;-666.0;-666.0")
     BringUpSound=(Sound=Sound'BallisticSounds2.NRP57.NRP57-Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.NRP57.NRP57-Putaway')
     WeaponModes(0)=(ModeName="Throw",ModeID="WM_None",Value=0.000000)
     WeaponModes(1)=(bUnavailable=True)
     WeaponModes(2)=(bUnavailable=True)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.NRP57OutA',pic2=Texture'BallisticUI2.Crosshairs.NRP57InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=7,G=255,R=255,A=166),Color2=(B=255,G=26,R=12,A=229),StartSize1=112,StartSize2=210)
     CrosshairInfo=(SpreadRatios=(Y2=0.500000),MaxScale=8.000000)
     FireModeClass(0)=Class'BWBP_SKC_Fix.ChaffPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.ChaffSecondaryFire'
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.400000
     CurrentRating=0.400000
     Description="MOA-C Chaff Rifle Grenade||Manufacturer: Majestic Firearms 12|Primary: Throw Grenade|Secondary: Melee |Special: Release Clip||Majestic Firearm 12's MOA-C Chaff Grenade is designed to be barrel fired with any* type of rifle round on the market. There's no need to unload your rifle to fire a grenade; the grenade stem's primer catches the bullet to ignite the shaped charge of the stem while leaving the barrel, offering a two stage propellant system that gives the grenade a greater velocity than standard rifle grenades. The MOA-C Chaff Grenade can also be utilized by infantry not equipped with the MJ51 Carbine as a hand thrown grenade. The soldier simply primes the grenade by twisting the cap and throws it. Due to the shaped charge still being present at the time of impact, the grenade tends to produce a higher explosive yield when thrown rather than shot from the rifle. Majestic Firearms 12 is not responsible injuries caused by inappropriate use of the grenade in this manner."
     Priority=13
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=3
     PickupClass=Class'BWBP_SKC_Fix.ChaffPickup'
     PlayerViewOffset=(X=0.000000,Y=4.000000,Z=-15.000000)
     PlayerViewPivot=(Pitch=1024,Yaw=-1024)
     BobDamping=1.000000
     AttachmentClass=Class'BWBP_SKC_Fix.ChaffAttachment'
     IconMaterial=Texture'BWBP_SKC_TexExp.M4A1.SmallIcon_MOAC'
     IconCoords=(X2=127,Y2=31)
     ItemName="MOA-C Chaff Grenade"
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.MOAC_FP'
     DrawScale=0.400000
}
