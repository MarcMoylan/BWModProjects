//=============================================================================
// A49SkrithPistol.
//
// Alien energy SMG. Fires fairly slowly with decent accuracy. Has pulse alt fire.
// Overheating it will make it shoot much faster (inaccurate) but will damage gun.
// After 3 overheats gun performance degrades. After 4 it becomes hazardous.
// Alt fire pulse can be used for jumps of for inc. pri fire speed. Overheats often.
//
//
// It can be 'repaired' by throwing it at the ground. Handgun code doesn't store it.
//
// Coded by Sarge - Conical blast by Az
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class A49SkrithBlaster extends BallisticHandgun;

var float		HeatLevel;			// Current Heat level, duh...
var bool		bIsVenting;			// Busy venting
var() Sound		OverHeatSound;		// Sound to play when it overheats
var() Sound		DamageSound;		// Sound to play when it first breaks
var() Sound		BrokenSound;		// Sound to play when its very damaged

var actor VentSteam;
var actor VentSteam2;
var actor GlowFX;
var actor GlowFXDamaged;
var actor		TazerEffect;
var actor		TazerEffect2;
var float		TazerTime;
var int			DangerCount; //If this reaches 5 gun breaks!

//simulated function bool MasterCanSendMode(int Mode) {return Mode == 0;}
simulated function bool SlaveCanUseMode(int Mode)
{
	return Mode == 0 || A49SkrithBlaster(OtherGun) != None;
}
simulated function bool CanAlternate(int Mode)
{
	if (Mode != 0 && OtherGun != None && A49SkrithBlaster(Othergun) == None)
		return false;
	return super.CanAlternate(Mode);
}


simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);
	SoundPitch = 56;

	GunLength = default.GunLength;

    	if (DangerCount < 4 && Instigator.IsLocallyControlled() && level.DetailMode == DM_SuperHigh && class'BallisticMod'.default.EffectsDetailMode >= 2 && (GlowFX == None || GlowFX.bDeleteMe))
		class'BUtil'.static.InitMuzzleFlash (GlowFX, class'A49GlowFX', DrawScale, self, 'tip');

	if (DangerCount == 4)
	{

	AmbientSound = None;
	Instigator.AmbientSound = BrokenSound;
	Instigator.SoundVolume = default.SoundVolume;
	Instigator.SoundPitch = default.SoundPitch;
	Instigator.SoundRadius = default.SoundRadius;
	Instigator.bFullVolume = true;
		if (GlowFX != None)
			GlowFX.Destroy();
    		if (Instigator.IsLocallyControlled() && level.DetailMode == DM_SuperHigh && class'BallisticMod'.default.EffectsDetailMode >= 2 && (GlowFXDamaged == None || GlowFXDamaged.bDeleteMe))
			class'BUtil'.static.InitMuzzleFlash (GlowFX, class'A49GlowFXDamaged', DrawScale, self, 'tip');
	}

		class'BUtil'.static.InitMuzzleFlash (TazerEffect2, class'A49Sparks', DrawScale, self, 'RightVent');
		class'BUtil'.static.InitMuzzleFlash (TazerEffect, class'A49Sparks', DrawScale, self, 'leftvent');
	TazerEffect2.SetRelativeRotation(rot(10000,0,0));
	TazerEffect.SetRelativeRotation(rot(0,32768,0));
}

simulated event Timer()
{
	if (Clientstate == WS_PutDown)
		class'BUtil'.static.KillEmitterEffect (GlowFX);
	super.Timer();
}

static function class<Pickup> RecommendAmmoPickup(int Mode)
{
	return class'AP_A49Clip';
}

simulated event Destroyed()
{
	if (GlowFX != None)
		GlowFX.Destroy();
	if (GlowFXDamaged != None)
		GlowFXDamaged.Destroy();
	if (TazerEffect != None)
		TazerEffect.Destroy();
	if (TazerEffect2 != None)
		TazerEffect2.Destroy();
	if (Instigator.AmbientSound == BrokenSound)
	{
		Instigator.AmbientSound = None;
		Instigator.SoundVolume = Instigator.default.SoundVolume;
		Instigator.SoundPitch = Instigator.default.SoundPitch;
		Instigator.SoundRadius = Instigator.default.SoundRadius;
		Instigator.bFullVolume = Instigator.default.bFullVolume;
	}

	super.Destroyed();
}

// Animation notify for when the clip is stuck in
simulated function Notify_ClipIn()
{
	local int AmmoNeeded;

    bIsVenting=false;

	ReloadState = RS_PostClipIn;
	PlayOwnedSound(ClipInSound.Sound,ClipInSound.Slot,ClipInSound.Volume,ClipInSound.bNoOverride,ClipInSound.Radius,ClipInSound.Pitch,ClipInSound.bAtten);
	if (Level.NetMode != NM_Client)
	{
		// Not all A73 clips are alike...
		AmmoNeeded = default.MagAmmo+(-10 + Rand(31)) - MagAmmo;
		if (AmmoNeeded > Ammo[0].AmmoAmount)
			MagAmmo+=Ammo[0].AmmoAmount;
		else
			MagAmmo += AmmoNeeded;
		Ammo[0].UseAmmo (AmmoNeeded, True);
	}
}


//Heat Stuff

simulated function float ChargeBar()
{
	return HeatLevel / 10;
}
simulated event Tick (float DT)
{
	if (level.Netmode != NM_Standalone)
	{
		BFireMode[0].FireRate = 0.15;
		BFireMode[0].XInaccuracy = 512;
		BFireMode[0].YInaccuracy = 512;
	}
	if (HeatLevel > 0)
	{
		if (bIsVenting)
			Heatlevel = FMax(HeatLevel - 6.5 * DT, 0);
		else
			Heatlevel = FMax(HeatLevel - 3.5 * DT, 0);
	}
	if (TazerTime != 0 && level.TimeSeconds > TazerTime + 5)
	{
		if (TazerEffect != None)
			TazerEffect.Destroy();
		if (TazerEffect2 != None)
			TazerEffect2.Destroy();
		TazerTime = 0;
	}
	super.Tick(DT);
}

simulated function AddHeat(float Amount)
{
	if (HeatLevel >= 10.5 && HeatLevel < 15)
	{
		Heatlevel = 15;
		ConsumeMagAmmo(0, 10);
		DangerCount++;
		CommonCockGun();
	}
	if (DangerCount == 3)
	{
		BFireMode[0].XInaccuracy = 768;
		BFireMode[0].YInaccuracy = 768;
    	}
	else if (DangerCount > 3) //Gun is heavily damaged
	{
		BFireMode[0].XInaccuracy = 1200;
		BFireMode[0].YInaccuracy = 1200;
    	}
	else if (HeatLevel >= 9.0 && DangerCount < 3)
	{
		if (Firemode[0].bIsFiring)
		{
		BFireMode[0].XInaccuracy = 900;
		BFireMode[0].YInaccuracy = 900;
        	}
    	}
	else if (HeatLevel >= 7.0 && DangerCount < 3)
	{
		if (Firemode[0].bIsFiring)
		{
		BFireMode[0].XInaccuracy = 768;
		BFireMode[0].YInaccuracy = 768;
        	}
    	}
	else if (HeatLevel >= 5.5 && DangerCount < 3)
	{
		if (Firemode[0].bIsFiring)
		{
		BFireMode[0].XInaccuracy = 512;
		BFireMode[0].YInaccuracy = 512;
        	}
    	}
	else if (HeatLevel >= 3.5 && DangerCount < 3)
	{
		if (Firemode[0].bIsFiring)
		{
		BFireMode[0].XInaccuracy = 256;
		BFireMode[0].YInaccuracy = 256;
        	}
    	}
	else if (HeatLevel >= 1.8 && DangerCount < 3)
	{
		if (Firemode[0].bIsFiring)
		{
		BFireMode[0].XInaccuracy = 128.5;
		BFireMode[0].YInaccuracy = 128.5;
        	}
	}
	else if (HeatLevel >= 0.8 && DangerCount < 3)
	{
		if (Firemode[0].bIsFiring)
		{
		BFireMode[0].XInaccuracy = 16;
		BFireMode[0].YInaccuracy = 16;
        	}
	}
    else
	{
		if (Firemode[0].bIsFiring)
		{
		BFireMode[0].XInaccuracy = 128;
		BFireMode[0].YInaccuracy = 128;
        	}
	}
    HeatLevel += Amount;
}

simulated function ClientSetHeat(float NewHeat)
{
	HeatLevel = NewHeat;
}

simulated function Notify_VentStart()
{
	TazerTime=0;
    	bIsVenting=true;
	if (DangerCount == 4)
	{
	AmbientSound = None;
	Instigator.AmbientSound = BrokenSound;
	Instigator.SoundVolume = default.SoundVolume;
	Instigator.SoundPitch = default.SoundPitch;
	Instigator.SoundRadius = default.SoundRadius;
	Instigator.bFullVolume = true;
	PickupClass=class'A49PickupCCT';
//	Skins[1] = Texture'BWBP_SKC_Tex.A6.A6SkinDMG';
	PlaySound(DamageSound,,3.7,,32);
		if (GlowFX != None)
			GlowFX.Destroy();
    		if (Instigator.IsLocallyControlled() && level.DetailMode == DM_SuperHigh && class'BallisticMod'.default.EffectsDetailMode >= 2 && (GlowFXDamaged == None || GlowFXDamaged.bDeleteMe))
			class'BUtil'.static.InitMuzzleFlash (GlowFX, class'A49GlowFXDamaged', DrawScale, self, 'tip');
	}
	if (DangerCount >= 5)
	{
	 	class'BallisticDamageType'.static.GenericHurt (Instigator, 75, Instigator, Instigator.Location, -vector(Instigator.GetViewRotation()) * 300 + vect(0,0,10000), class'DTA49Overheat');
	}
	if (VentSteam != None)
	{
		VentSteam.Destroy();
		VentSteam=None;
	}
	if (VentSteam2 != None)
	{
		VentSteam2.Destroy();
		VentSteam2=None;
	}
	class'BUtil'.static.InitMuzzleFlash (VentSteam2, class'RSNovaSteam', DrawScale, self, 'LeftVent');
	class'BUtil'.static.InitMuzzleFlash (VentSteam, class'RSNovaSteam', DrawScale, self, 'RightVent');

	VentSteam.SetRelativeRotation(rot(10000,0,0));
	VentSteam2.SetRelativeRotation(rot(0,32768,0));

}

simulated function Notify_VentEnd()
{
    	bIsVenting=false;
}
simulated function CommonCockGun(optional byte Type)
{
	local int m;
	if (bNonCocking)
		return;
	if (Role == ROLE_Authority)
		bServerReloading=true;
	ReloadState = RS_Cocking;
	PlayCocking(Type);
	for (m=0; m < NUM_FIRE_MODES; m++)
		if (BFireMode[m] != None)
			BFireMode[m].CockingGun(Type);
}

//Heat Stuff End






function ConicalBlast(float DamageAmount, float DamageRadius, vector Aim)
{
 local actor Victims;
 local float damageScale, dist;
 local vector dir;

 if( bHurtEntry )
  return;

 bHurtEntry = true;
 foreach CollidingActors( class 'Actor', Victims, DamageRadius, Location )
 {
  if( (Victims != Instigator) && (Victims.Role == ROLE_Authority) && (!Victims.IsA('FluidSurfaceInfo')) )
  {
   if ( Aim dot Normal (Victims.Location - Location) < 0.5)
    continue;
   
   if (!FastTrace(Victims.Location, Location))
    continue;
    
   dir = Victims.Location - Location;
   dist = FMax(1,VSize(dir));


   dir = dir/dist;
   damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
   class'BallisticDamageType'.static.GenericHurt
   (
    Victims,
    damageScale * DamageAmount,
    Instigator,
    Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
    vect(0,0,0),
    class'DTA49Shockwave'
   );
   
   if(Pawn(Victims) != None && Pawn(Victims).bProjTarget)
    Pawn(Victims).AddVelocity(vect(0,0,200) + (Normal(Victims.Acceleration) * -FMin(Pawn(Victims).GroundSpeed, VSize(Victims.Velocity)) + Normal(dir) * 3000 * damageScale));
      
   if (Instigator != None && Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
    Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, Instigator.Controller, class'DTA49Shockwave', 0.0f, Location);
  }
 }
 bHurtEntry = false;
}




// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()
{
	local Bot B;
	local float Dist;
	local Vector Dir;
	local Vehicle V;

	B = Bot(Instigator.Controller);
	if ( B == None  || B.Enemy == None)
		return Rand(2);

	Dir = Instigator.Location - B.Enemy.Location;
	Dist = VSize(Dir);

	if (AmmoAmount(0) < 40)
		return 0;

	if (B.Squad!=None)
	{
		if ( ( (DestroyableObjective(B.Squad.SquadObjective) != None && B.Squad.SquadObjective.TeamLink(B.GetTeamNum()))
			|| (B.Squad.SquadObjective == None && DestroyableObjective(B.Target) != None && B.Target.TeamLink(B.GetTeamNum())) )
	    	 && (B.Enemy == None || !B.EnemyVisible()) )
			return 0;
		if ( FocusOnLeader(B.Focus == B.Squad.SquadLeader.Pawn) )
			return 0;

		V = B.Squad.GetLinkVehicle(B);
		if ( V == None )
			V = Vehicle(B.MoveTarget);
		if ( V == B.Target )
			return 0;
		if ( (V != None) && (V.Health < V.HealthMax) && (V.LinkHealMult > 0) && B.LineOfSightTo(V) )
			return 0;
	}

	if (Dist < (FireMode[1].MaxRange()-100) && FRand() > 0.3)
		return 1;
	if (vector(B.Enemy.Rotation) dot Normal(Dir) < 0.0 && (VSize(B.Enemy.Velocity) < 100 || Normal(B.Enemy.Velocity) dot Normal(B.Velocity) < 0.5))
		return 1;
	return 0;
}

function float GetAIRating()
{
	local Bot B;
	local float Result, Dist;
	local vector Dir;
	local DestroyableObjective O;
	local Vehicle V;

	if (IsSlave())
		return 0;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return AIRating;

	V = B.Squad.GetLinkVehicle(B);
	if ( (V != None)
		&& (VSize(Instigator.Location - V.Location) < 1.5 * FireMode[0].MaxRange())
		&& (V.Health < V.HealthMax) && (V.LinkHealMult > 0) )
		return 1.1;

	if ( Vehicle(B.RouteGoal) != None && B.Enemy == None && VSize(Instigator.Location - B.RouteGoal.Location) < 1.5 * FireMode[0].MaxRange()
	     && Vehicle(B.RouteGoal).TeamLink(B.GetTeamNum()) )
		return 1.1;

	O = DestroyableObjective(B.Squad.SquadObjective);
	if ( O != None && B.Enemy == None && O.TeamLink(B.GetTeamNum()) && O.Health < O.DamageCapacity
	     && VSize(Instigator.Location - O.Location) < 1.1 * FireMode[0].MaxRange() && B.LineOfSightTo(O) )
		return 1.1;

	if (B.Enemy == None)
		return Super.GetAIRating();

	Dir = B.Enemy.Location - Instigator.Location;
	Dist = VSize(Dir);

	Result = Super.GetAIRating();

	if (Dist > 1500)
		Result -= (Dist-1500) / 1500;
	else if (Dist < 500)
		Result -= 0.1;
	else if (Dist > 1000 && AmmoAmount(0) < 50)
		return Result -= 0.1;;

	return Result;
}

function bool FocusOnLeader(bool bLeaderFiring)
{
	local Bot B;
	local Pawn LeaderPawn;
	local Actor Other;
	local vector HitLocation, HitNormal, StartTrace;
	local Vehicle V;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return false;
	if ( PlayerController(B.Squad.SquadLeader) != None )
		LeaderPawn = B.Squad.SquadLeader.Pawn;
	else
	{
		V = B.Squad.GetLinkVehicle(B);
		if ( V != None )
		{
			LeaderPawn = V;
			bLeaderFiring = (LeaderPawn.Health < LeaderPawn.HealthMax) && (V.LinkHealMult > 0)
							&& ((B.Enemy == None) || V.bKeyVehicle);
		}
	}
	if ( LeaderPawn == None )
	{
		LeaderPawn = B.Squad.SquadLeader.Pawn;
		if ( LeaderPawn == None )
			return false;
	}
	if (!bLeaderFiring)
		return false;
	if ( (Vehicle(LeaderPawn) != None) )
	{
		StartTrace = Instigator.Location + Instigator.EyePosition();
		if ( VSize(LeaderPawn.Location - StartTrace) < FireMode[0].MaxRange() )
		{
			Other = Trace(HitLocation, HitNormal, LeaderPawn.Location, StartTrace, true);
			if ( Other == LeaderPawn )
			{
				B.Focus = Other;
				return true;
			}
		}
	}
	return false;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return 0.3;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.4;	}

function bool CanHeal(Actor Other)
{
	if (DestroyableObjective(Other) != None && DestroyableObjective(Other).LinkHealMult > 0)
		return true;
	if (Vehicle(Other) != None && Vehicle(Other).LinkHealMult > 0)
		return true;

	return false;
}
// End AI Stuff =====


defaultproperties
{
     BrokenSound=Sound'BWBP2-Sounds.LightningGun.LG-Ambient'
     DamageSound=Sound'BWBP_SKC_Sounds.XavPlas.Xav-Overload'
     PlayerSpeedFactor=1.000000
     UsedAmbientSound=Sound'BallisticSounds2.A73.A73Hum1'
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     BigIconMaterial=Texture'BWBP_SKC_Tex.A6.BigIcon_A49'
     BallisticInventoryGroup=4
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_RapidProj=True
     bWT_Energy=True
     GunLength=0.100000
     SpecialInfo(0)=(Info="0.0;-15.0;-999.0;-1.0;-999.0;-999.0;-999.0")
     BringUpSound=(Sound=Sound'BallisticSounds2.A42.A42-Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.A42.A42-Putaway')
     ClipOutSound=(Sound=Sound'BallisticSounds2.A73.A73-ClipOut',Volume=1.000000)
     ClipInSound=(Sound=Sound'BallisticSounds2.A73.A73-ClipHit',Volume=1.000000)
     MagAmmo=50
     bNonCocking=False
     CockAnim="Overheat"
     SightPivot=(Pitch=2000,Roll=-768)
     SightOffset=(X=-12.000000,Y=33.000000,Z=65.000000)
     SightDisplayFOV=40.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.Misc7',Pic2=Texture'BallisticUI2.Crosshairs.Misc10',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=160,G=44,R=89,A=137),Color2=(B=151,R=0,A=202),StartSize1=84,StartSize2=61)
     CrosshairInfo=(SpreadRatios=(X1=0.300000,Y1=0.300000,X2=1.000000,Y2=1.000000),MaxScale=3.000000)
     CrosshairChaosFactor=0.700000
     JumpOffSet=(Pitch=2000)
     JumpChaos=0.200000
     AimSpread=(X=(Min=-64.000000,Max=64.000000),Y=(Min=-64.000000,Max=64.000000))
     ViewAimFactor=0.050000
     ViewRecoilFactor=0.100000
     ChaosDeclineTime=1.000000
     ChaosTurnThreshold=180000.000000
     ChaosSpeedThreshold=1300.000000
     ChaosAimSpread=(X=(Min=-2048.000000,Max=2048.000000))
     RecoilXCurve=(Points=(,(InVal=0.100000,OutVal=0.000000),(InVal=0.200000,OutVal=-0.100000),(InVal=0.400000,OutVal=0.500000),(InVal=0.600000,OutVal=-0.500000),(InVal=0.700000),(InVal=1.000000,OutVal=0.100000)))
     RecoilYCurve=(Points=(,(InVal=0.100000,OutVal=0.100000),(InVal=0.200000,OutVal=0.200000),(InVal=0.400000,OutVal=0.300000),(InVal=0.600000,OutVal=-0.200000),(InVal=0.700000,OutVal=0.200000),(InVal=1.000000,OutVal=0.300000)))
     RecoilXFactor=0.200000
     RecoilYFactor=0.200000
     RecoilMax=512.000000
     RecoilDeclineTime=1.000000
     RecoilDeclineDelay=0.100000
     FireModeClass(0)=Class'BWBP_SKC_Fix.A49PrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.A49SecondaryFire'
     BringUpTime=0.500000
     PutDownTime=0.600000
     PutDownAnimRate=1.800000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.400000
     CurrentRating=0.400000
     bShowChargingBar=True
     Description="A49 Skrith Blaster||Manufacturer: Unknown Skrith Engineers|Primary: Rapid Energy Pulses|Secondary: Disorienting Blast||An interesting piece of Skrith technology, the A49 Skrith Blaster seems to be an attempt at a miniaturized A73 Skrith Rifle, to fill an intermediary role somewhere between that of a side arm and full sized assault weapon, roughly equivalent to a human sub-machine gun or sub-assault rifle. Its compact size and respectable power makes it considerably better than its cousin, the A42 Whip, but an unexplainable lack of samples found on skrith fighters, plus the weapon's unreliable rate of fire and tendency to overheat suggest that this was an unsuccessful weapon that failed to see full scale use. || The weapon's curious defensive light and sound based function is capable of disorienting attackers at point blank, but its very existence is brought to question by scientists and soldiers alike. Veterans of Skrith assaults argue that Skrith would have no need of this function, often being able to strike quickly without being seen. Researchers theorize that perhaps this weapon was a mark of shame, given to skrith unable to remain hidden from view of their enemy."
     Priority=16
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=5
     GroupOffset=13
     PickupClass=Class'BWBP_SKC_Fix.A49Pickup'
     PlayerViewOffset=(X=0.000000,Y=10.000000,Z=-25.000000)
     BobDamping=1.600000
     AttachmentClass=Class'BWBP_SKC_Fix.A49Attachment'
     IconMaterial=Texture'BWBP_SKC_Tex.A6.SmallIcon_A49'
     IconCoords=(X2=127,Y2=31)
     ItemName="A49 Skrith Blaster"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=180
     LightSaturation=100
     LightBrightness=192.000000
     LightRadius=12.000000
     Mesh=SkeletalMesh'BWBP_SKC_Anim.SkrithBlaster'
     DrawScale=1.0000
     SoundPitch=56
     SoundRadius=32.000000
}
