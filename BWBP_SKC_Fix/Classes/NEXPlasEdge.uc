//=============================================================================
// NEX Plas-Edge
//
// The Plas-Edge. A crude weapon that replaces the edge of the blade with a
// plasma filled channel retained by a magnetic field. Each hit with the weapon
// destabilizes the field, bringing the weapon closer towards venting the plasma
// into the face of the user. As long as there is 'heat' built up, it will drain
// ammo at an accelerated rate. Alt fire will allow the user to charge up the
// 'heat' bar to make primary fire attacks more lethal, at the risk of a plasma
// vent.
//
// Azarael edits:
// Works properly online. Still a messy class and could use some cleanup.
// Moved Tick abuse code out of Tick and into NEXPrimaryFire.GetDamage.
//
// by Casey 'Xavious' Johnson, Marc 'Sergeant Kelly' and Matteo 'Azarael'
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class NEXPlasEdge extends BallisticMeleeWeapon;

var float NextAmmoTickTime;
var float		HeatLevel;			// Current heat level.
var bool		bPoweredDown;	// Cell is out, heat dropping
var bool		bNoSwing;           // Used for determining when the player can attack, based off anim.
var bool		bCriticalHeat;		// Heat is at critical levels
var() Sound		VentingSound;		// Sound to loop when venting
var() Sound		OverHeatSound;		// Sound to play when it overheats
var() Sound		ExtremeOverHeatSound;		// Sound to play when player captures and uses enemy plasma
var() Sound			PowerOnSound;
var() Sound			PowerOffSound;
var() Sound			PowerSurgeSound;	//Sound played on high power swings

var Actor	BladeGlow;				// Electric plasma effect

var() Sound			AltSwipeSound;	//Because alt fire won't play sounds and I am lazy


var() Sound		HighHeatSound;		// Sound to play when heat is dangerous
var bool		bWaterBurn;			// busy getting damaged in water
var()	Name		OverchargeAnim;

var() Material          MatPower;       // sword when power's on
var() Material          MatPowerUp;       // sword when power's high
var() Material          MatPowerSuper;       // sword when power's KERAZY
var() Material          MatOffline1;       // blade when power's off
var() Material          MatOffline2;     // vents when power's off

replication
{
	reliable if (ROLE==ROLE_Authority)
		ClientOverCharge, ClientSetHeat;
}

simulated function CommonCockGun(optional byte Type)
{
      PlayAnim('Seppuku', 1.0, 0.1);
      Super.CommonCockGun(Type);
}

simulated function AnimEnded (int Channel, name anim, float frame, float rate)
{		
	if (Anim == ZoomInAnim)
	{
		SightingState = SS_Active;
		ScopeUpAnimEnd();
		return;
	}
	else if (Anim == ZoomOutAnim)
	{
		SightingState = SS_None;
		ScopeDownAnimEnd();
		return;
	}

	if (anim == FireMode[0].FireAnim || (FireMode[1] != None && anim == FireMode[1].FireAnim))
		bPreventReload=false;

	// Modified stuff from Engine.Weapon
	if (ClientState == WS_ReadyToFire && ReloadState == RS_None)
    {
        if (anim == FireMode[0].FireAnim && HasAnim(FireMode[0].FireEndAnim)) // rocket hack
			SafePlayAnim(FireMode[0].FireEndAnim, FireMode[0].FireEndAnimRate, 0.0);
        else if (FireMode[1]!=None && anim== FireMode[1].FireAnim && HasAnim(FireMode[1].FireEndAnim))
            SafePlayAnim(FireMode[1].FireEndAnim, FireMode[1].FireEndAnimRate, 0.0);
        else if ((FireMode[0] == None || !FireMode[0].bIsFiring) && (FireMode[1] == None || !FireMode[1].bIsFiring))
        {
			bPreventReload=false;
            PlayIdle();
        }
    }
    
	// End stuff from Engine.Weapon
	
	if (Anim == OverchargeAnim)
	{
		//if (Role == ROLE_Authority)
		//	Level.Game.Broadcast(self, "Server: NEX overcharge anim ended.");

		PlayAnim('Reload', 1.0, 0.1);
		return;
	}

	//Cock anim ended, goto idle
	if (ReloadState == RS_Cocking)
	{
		bNeedCock=false;
		ReloadState = RS_None;
		ReloadFinished();
		PlayIdle();
		ReAim(0.05);
	}
}

simulated function Notify_Seppuku()
{
    class'BallisticDamageType'.static.GenericHurt (Instigator, 9001, Instigator, Instigator.Location, -vector(Instigator.GetViewRotation()) * 30000 + vect(0,0,10000), class'DTNEXSeppuku');
}

simulated function Notify_TogglePower()
{
    if (!bPoweredDown)
	{
      	bPoweredDown = True;
		Skins[1]=MatOffline1;
		Skins[2]=MatOffline2;
		PlaySound(PowerOffSound,,3.7,,32);
		Instigator.AmbientSound = VentingSound;
		Instigator.SoundVolume = 0;
	}
	
    else
	{
      	bPoweredDown = False;
		Skins[1]=MatPower;
		Skins[2]=MatPower;
		PlaySound(PowerOnSound,,3.7,,32);
		Instigator.AmbientSound = UsedAmbientSound;
		Instigator.SoundVolume = default.SoundVolume;
		class'bUtil'.static.InitMuzzleFlash(BladeGlow, class'NEXBladeEffect', DrawScale, self, 'EmitterBase');
	}
}

simulated function Notify_PowerSurge()
{
	if (HeatLevel > 9)
		PlaySound(PowerSurgeSound,,5,,128);

	else
		PlaySound(AltSwipeSound,,5,,128);
}

simulated function Notify_CellOut()
{
	Skins[1]=MatOffline1;
	Skins[2]=MatOffline2;
	HeatLevel=0;
	PlaySound(PowerOffSound,,3.7,,32);
	Instigator.AmbientSound = VentingSound;
	Instigator.SoundVolume = 0;
	if (BladeGlow != None)	BladeGlow.Destroy();
}

simulated function Notify_CellIn()
{
		Skins[1]=MatPower;
		Skins[2]=MatPower;
		PlaySound(PowerOnSound,,3.7,,32);
		Instigator.AmbientSound = UsedAmbientSound;
		Instigator.SoundVolume = default.SoundVolume;
		class'bUtil'.static.InitMuzzleFlash(BladeGlow, class'NEXBladeEffect', DrawScale, self, 'EmitterBase');
}

// This is an attempt to make a more dynamic melee experiance by letting the fire
// rate be determined by the animations; careful timing will allow the user to
// follow up with next attack quicker than normal.
simulated function Notify_Idle()
{
    bNoSwing = False;
}
simulated function Notify_EndBlock()
{
    bNoSwing = False;
}
simulated function Notify_SwingStart()
{
    bNoSwing = True;
}
simulated function Notify_ComboStart()
{
    bNoSwing = False;
}
simulated function Notify_ComboEnd()
{
    bNoSwing = True;
}
simulated function Notify_SwingEnd()
{
    bNoSwing = False;
}

// This is all pretty much the HVPCMk5 Heat code, minus the emmiter stuff.
// Old emmiter stuff will probably be useful for new emitter stuff.

simulated function ClientOverCharge()
{
	if (Firemode[1].bIsFiring)
		StopFire(1);
}

simulated function float ChargeBar()
{
	return HeatLevel / 10;
}

simulated function OverPower()
{
		Skins[1]=MatPowerSuper;
		Skins[2]=MatPowerSuper;
		Instigator.AmbientSound = VentingSound;
		Instigator.SoundVolume = 155;
}

simulated function HighPower()
{
		Skins[1]=MatPowerUp;
		Skins[2]=MatPowerUp;
		Instigator.AmbientSound = UsedAmbientSound;
		Instigator.SoundVolume = 155;
}

simulated function LowPower()
{
		Skins[1]=MatPower;
		Skins[2]=MatPower;
		Instigator.AmbientSound = UsedAmbientSound;
		Instigator.SoundVolume = default.SoundVolume;
		if (BladeGlow == None) 
			class'bUtil'.static.InitMuzzleFlash(BladeGlow, class'NEXBladeEffect', DrawScale, self, 'EmitterBase');
}

simulated function NoPower()
{
		Skins[1]=MatOffline1;
		Skins[2]=MatOffline2;
		Instigator.AmbientSound = UsedAmbientSound;
		Instigator.SoundVolume = 0;
		if (BladeGlow != None)	BladeGlow.Destroy();
}

simulated function ClientSetHeat(float NewHeat)
{
	HeatLevel = NewHeat;
	
	if (HeatLevel >= 10)
	{
		PlaySound(OverHeatSound,,6.7,,64);
						
		PlayAnim(OverchargeAnim, 1.0, 0.1); // Neat anim to play when it asplodes.
		ReloadState = RS_Cocking;

		HeatLevel = 10;
	}
}

simulated function AddHeat(float Amount)
{
	HeatLevel += Amount;
	
	//force update for primary fire
	ClientSetHeat(HeatLevel);
	
	if (HeatLevel >= 10)
	{
		//if (Role == ROLE_Authority)
		//	Level.Game.Broadcast(self, "Server: NEX starting overheat.");

		bServerReloading=True;
		
		PlaySound(OverHeatSound,,6.7,,64);
						
		PlayAnim(OverchargeAnim, 1.0, 0.1); // Neat anim to play when it asplodes.
		ReloadState = RS_Cocking;
		
		if (Role == ROLE_Authority)
			class'BallisticDamageType'.static.GenericHurt (Instigator, 30, Instigator, Instigator.Location, -vector(Instigator.GetViewRotation()) * 30000 + vect(0,0,10000), class'DTNEXOverheat');
		HeatLevel = 10;
	}
}

simulated event WeaponTick(float DT)
{
	super.WeaponTick(DT);
	if (!bPoweredDown)
		NEXAttachment(ThirdPersonActor).bmeleeing=false;
		
	else //If it's venting, you can still punch
	{
		if (BladeGlow != None)	BladeGlow.Destroy();
		NEXAttachment(ThirdPersonActor).bmeleeing=True;
	}

	if (HeatLevel >= 6 && HeatLevel < 20 && !bPoweredDown)
		HighPower();
	else if (HeatLevel < 6 && HeatLevel > 0 && !bPoweredDown)
		LowPower();
	else if (HeatLevel >= 20 && !bPoweredDown)
		OverPower();

	if (AIController(Instigator.Controller) != None)
	{
		if (HeatLevel > 0)
		{
			if (  BotShouldReload() && !Instigator.Controller.LineOfSightTo(AIController(Instigator.Controller).Enemy) && !IsGoingToVent())
				BotReload();
		}
		else if (bPoweredDown)
			ReloadRelease();
	}

	if (Instigator.PhysicsVolume.bWaterVolume)
	{
//		if (AmmoAmount(0) > 0)
			AddHeat(DT*2.5);
		if (!bWaterBurn && Role == ROLE_Authority && (Clientstate == WS_ReadyToFire || !Instigator.IsLocallyControlled()))
		{
			bWaterBurn=true;
			SetTimer(0.4, true);
		}
	}
	else if (bWaterBurn)
	{
		bWaterBurn = false;
		if (TimerRate == 0.2)
			SetTimer(0.0, false);

	}
	if (!Instigator.IsLocallyControlled())
		return;
}

simulated event Tick (float DT)
{
	if (HeatLevel > 0)
	{
		if (bPoweredDown && HeatLevel >= 10)
			HeatLevel = 10;
		if (bPoweredDown)
			Heatlevel = FMax(HeatLevel - 3.5 * DT, 0);
		else
			Heatlevel = FMax(HeatLevel - 0.3 * DT, 0);
	}
}

simulated function bool IsGoingToVent()
{
    local name anim;
    local float frame, rate;
    GetAnimParams(0, anim, frame, rate);
	if (Anim == 'TurnOnOff')
 		return true;
	return false;
}

function ServerStartReload (optional byte i)
{
	local int m;

	if (bPreventReload)
		return;
	if (ReloadState != RS_None)
		return;

	for (m=0; m < NUM_FIRE_MODES; m++)
		if (FireMode[m] != None && FireMode[m].bIsFiring)
			StopFire(m);

	bServerReloading = true;
	CommonStartReload(i);	//Server animation
	ClientStartReload(i);	//Client animation
}

simulated function CommonStartReload(optional byte i)
{
	SafePlayAnim('TurnOnOff', 1.0, 0.1);
	ReloadState = RS_Cocking;
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);
	SoundPitch = default.SoundPitch;
	class'bUtil'.static.InitMuzzleFlash(BladeGlow, class'NEXBladeEffect', DrawScale, self, 'EmitterBase');
	GunLength = default.GunLength;
	if (bPoweredDown)
		bPoweredDown = False;

	Skins[1]=MatPower;
	Skins[2]=MatPower;
}

simulated function bool PutDown()
{
	if (super.PutDown())
	{
		if (bPoweredDown)
		{
			if (level.NetMode == NM_Client)
				bPoweredDown = false;
			ServerReloadRelease();
		}

		if (BladeGlow != None)	BladeGlow.Destroy();
		bWaterBurn=false;
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
	if (Instigator.AmbientSound == UsedAmbientSound || Instigator.AmbientSound == VentingSound)
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

// Is reloading a good idea???
function bool BotShouldReload ()
{
	if ( (!bPoweredDown) && (HeatLevel > 2) && (Level.TimeSeconds - AIController(Instigator.Controller).LastSeenTime > AIReloadTime) &&
		 (Level.TimeSeconds - Instigator.LastPainTime > AIReloadTime) )
		return true;
	return false;
}

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


function AdjustPlayerDamage( out int Damage, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	if (bBlocked && !bPoweredDown && !IsFiring() && level.TimeSeconds > LastFireTime + 1 && class<BallisticDamageType>(DamageType) != None &&
		Normal(HitLocation-(Instigator.Location+Instigator.EyePosition())) Dot Vector(Instigator.GetViewRotation()) > 0.4)
	{
		if (class<BallisticDamageType>(DamageType).default.bCanBeBlocked)
		{
			Damage = 0;
			HeatLevel += 0.5;
		}
		else if (class<DT_BWMiscDamage>(DamageType)!=none && !bPoweredDown && class<DTT10Gas>(DamageType)==none && class<DT_BFGCharge>(DamageType)==none)
		{
			Damage = 0;
			HeatLevel += 3.5;
		}
		else if (class<DT_BWBullet>(DamageType)!=none && !bPoweredDown)
		{
		    	Damage *= 0.6;
			HeatLevel += 0.5;
		}
		BallisticAttachment(ThirdPersonActor).UpdateBlockHit();
	}

	if (class<BallisticDamageType>(DamageType) != None && !bPoweredDown && class<DT_BWMiscDamage>(DamageType)!=none && !bPoweredDown && class<DTT10Gas>(DamageType)==none && class<DT_BFGCharge>(DamageType)==none)
	{
		Damage *= 0.8;
		HeatLevel += 0.5;
	}
	super.AdjustPlayerDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType);
}

defaultproperties
{
	AIRating=0.300000
	AltSwipeSound=SoundGroup'BWBP_SKC_Sounds.NEX.NEX-Slash'
	AttachmentClass=Class'BWBP_SKC_Fix.NEXAttachment'
	bAimDisabled=True
	BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
	BigIconMaterial=Texture'BWBP_SKC_Tex.NEX.BigIcon_NEX'
	bMeleeWeapon=True
	bNoMag=True
	BobDamping=1.000000
	BringUpSound=(Sound=Sound'BWBP_SKC_Sounds.NEX.NEX-Pullout')
	BringUpTime=0.500000
	bShowChargingBar=True
	bNetNotify=True
	bWT_Energy=True
	bWT_Hazardous=True
	CenteredOffsetY=7.000000
	CenteredRoll=0
	CockAnim="Seppuku"
	CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.Misc4',Pic2=Texture'BallisticUI2.Crosshairs.Dot1',USize1=256,VSize1=256,Color1=(B=255,R=0,A=157),Color2=(B=153,G=152,R=149),StartSize1=48,StartSize2=17)
	CurrentRating=0.300000
	CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
	Description="NEX Plas-Edge Sword||Manufacturer: Nexron Defence|Primary: Slash|Secondary: Charged Slash|Special: Block|| The NEX Plas-Edge Mod 0 is the first in a line of high tech energy based swords pioneered by Nexron defense. Unlike the later nanosword designs, the NEX Mod 0 uses only the supercharged ionic gas channel for energy and relies on a traditional metal sword for the cutting. This approach was quickly abandoned as Element 115's plasma field unfortunately proved to be highly unstable with erratic charge levels and random dangerous overheats. The blade's excessive heat also required a different approach - scientists noted that after prolonged exposure the blade ionized the surrounding atmosphere and made breathing difficult. When using the NEX in combat, be careful not to overcharge it as the blade is prone to discharge when completely energized. It should be noted that the plas-edge's coils are incredibly unstable and will absorb any and all incoming energy. With an effect similar to skrith anti-energy armor, this can be used to the user's advantage in the field by absorbing enemy plasma charges and using them to strike a supercharged blow."
	DisplayFOV=65.000000
	DrawScale=1.150000
	ExtremeOverHeatSound=Sound'BWBP_SKC_Sounds.Glock_Gold.G-Glk-LaserFire'
	FireModeClass(0)=Class'BWBP_SKC_Fix.NEXPrimaryFire'
	FireModeClass(1)=Class'BWBP_SKC_Fix.NEXSecondaryFire'
	GroupOffset=1
	GunLength=0.000000
	HighHeatSound=SoundGroup'BWBP_SKC_Sounds.NEX.Nex-HitBod'
	IconCoords=(X2=127,Y2=31)
	IconMaterial=Texture'BWBP_SKC_Tex.NEX.SmallIcon_NEX'
	InventorySize=20
	ItemName="NEX Plas-Edge Sword"
	LightBrightness=224.000000
	LightEffect=LE_WateryShimmer
	LightHue=160
	LightRadius=4.000000
	LightSaturation=64
	LightType=LT_Steady
	MagAmmo=100
	MatOffline1=Shader'BWBP_SKC_Tex.NEX.NEX-OffShine'
	MatOffline2=Texture'BWBP_SKC_Tex.NEX.NEX-MainOff'
	MatPower=Shader'BWBP_SKC_Tex.NEX.NEX-MainShine'
	MatPowerSuper=Shader'BWBP_SKC_Tex.NEX.Nex-MegaShine'
	MatPowerUp=Shader'BWBP_SKC_Tex.NEX.NEX-UltraShine'
	Mesh=SkeletalMesh'BWBP_SKC_Anim.NEXPlasEdge'
	OverHeatSound=Sound'BWBP_SKC_Sounds.NEX.NEX-Overload'
	OverchargeAnim="Asplode"
	PickupClass=Class'BWBP_SKC_Fix.NEXPickup'
	PlayerJumpFactor=0.950000
	PlayerSpeedFactor=0.950000
	PlayerViewOffset=(X=10.000000,Y=10.000000,Z=5.000000)
	PowerOffSound=Sound'BWBP4-Sounds.DarkStar.Dark-Open'
	PowerOnSound=Sound'BWBP4-Sounds.DarkStar.Dark-Close'
	PowerSurgeSound=Sound'BWBP_SKC_Sounds.HyperBeamCannon.343Primary-Fail'
	Priority=12
	PutDownSound=(Sound=Sound'BallisticSounds2.EKS43.EKS-Putaway')
	PutDownTime=0.500000
	ReloadAnim="TurnOnOff"
	SelectForce="SwitchToAssaultRifle"
	Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
	Skins(1)=Shader'BWBP_SKC_Tex.NEX.NEX-MainShine'
	Skins(2)=Shader'BWBP_SKC_Tex.NEX.NEX-MainShine'
	SpecialInfo(0)=(Info="300.0;15.0;0.0;0.0;0.0;0.7;0.0")
	TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
	UsedAmbientSound=Sound'BWBP_SKC_Sounds.NEX.NEX-Idle'
	VentingSound=Sound'BWBP_SKC_Sounds.BFG.BFG-Critical'

}
