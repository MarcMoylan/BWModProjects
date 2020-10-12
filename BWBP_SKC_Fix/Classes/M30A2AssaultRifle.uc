//=============================================================================
// M30A2AssaultRifle.
//
// M30A2 Assault Rifle, aka thez Z. Med fire rate, good damage, high accuracy, good range, Burst, Semi-Auto
// Has underslung
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class M30A2AssaultRifle extends BallisticCamoWeapon;


var   Emitter		LaserDot;
var   bool		bLaserOn;
var() sound		SuperFireSound; //For camo pri
var() sound		SuperFireSoundAlt; //For camo alt

static function class<Pickup> RecommendAmmoPickup(int Mode)
{
	return class'AP_42MachineGun';
}

replication
{
	reliable if (Role < ROLE_Authority)
		ServerUpdateLaser;
	reliable if(Role == ROLE_Authority)
        	ClientSwitchCannonMode, ClientSwitchRapidMode;
}



simulated function ClientSwitchCannonMode (byte newMode)
{
	M30A2PrimaryFire(FireMode[0]).SwitchCannonMode(newMode);
}


//Modified burst
simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	if (CurrentWeaponMode == 1 && CamoIndex != 1)	
	{
		M30A2PrimaryFire(BFireMode[0]).bRapidMode = True;
 	}
}


simulated function BringUp(optional Weapon PrevWeapon)
{

	super.BringUp(PrevWeapon);

	if (Instigator != None && AIController(Instigator.Controller) != None)
	{
		AimSpread *= 0.5;
		ChaosAimSpread *= 0.3;
		BFireMode[0].FireRate = 0.150000;
	}

}

simulated function AdjustCamoProperties(optional int Index)
{
	local float f;

		f = FRand();
		if ((Index == -1 && f > 0.85 ) || Index == 1) //15%
		{
			Skins[1]=CamoMaterials[3];
			Skins[2]=CamoMaterials[4];
			WeaponModes[2].bUnavailable=false;
			WeaponModes[3].bUnavailable=false;
     			CurrentWeaponMode=2;
			M30A2PrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
			BallisticInstantFire(FireMode[0]).Damage = 40;
			BallisticInstantFire(FireMode[0]).DamageHead = 100;
			BallisticInstantFire(FireMode[0]).DamageLimb = 25;
			BallisticInstantFire(FireMode[1]).Damage = 100;
			BallisticInstantFire(FireMode[1]).DamageHead = 135;
			BallisticInstantFire(FireMode[1]).DamageLimb = 65;
			BallisticInstantFire(FireMode[1]).FireRate = 2;
     			BallisticInstantFire(FireMode[0]).RecoilPerShot=172;
			BallisticInstantFire(FireMode[0]).BallisticFireSound.Sound=SuperFireSound;
			BallisticInstantFire(FireMode[1]).BallisticFireSound.Sound=SuperFireSoundAlt;
	      		BallisticInstantFire(FireMode[0]).DamageType=Class'BWBP_SKC_Fix.DTM30A2Assault';
    	      		BallisticInstantFire(FireMode[0]).DamageTypeHead=Class'BWBP_SKC_Fix.DTM30A2AssaultHead';
    			BallisticInstantFire(FireMode[0]).DamageTypeArm=Class'BWBP_SKC_Fix.DTM30A2AssaultLimb';
	      		BallisticInstantFire(FireMode[1]).DamageType=Class'BWBP_SKC_Fix.DTM30A2AssaultPwr';
    	      		BallisticInstantFire(FireMode[1]).DamageTypeHead=Class'BWBP_SKC_Fix.DTM30A2AssaultHeadPwr';
    			BallisticInstantFire(FireMode[1]).DamageTypeArm=Class'BWBP_SKC_Fix.DTM30A2AssaultLimbPwr';
     			ItemName="M30A2 Tactical Rifle";
			CamoIndex=1;
		}
		else
		{
			Skins[1]=CamoMaterials[1];
			Skins[2]=CamoMaterials[2];
     			ItemName="M30A1 Tactical Rifle";
			CamoIndex=0;
		}

}




simulated function bool PutDown()
{
	if (super.PutDown())
	{
		bLaserOn=false;
		KillLaserDot();
		return true;
	}
	return false;
}


simulated function KillLaserDot()
{
	if (LaserDot != None)
	{
		LaserDot.Kill();
		LaserDot = None;
	}
}

simulated function SpawnLaserDot(optional vector Loc)
{
	if (LaserDot == None)
		LaserDot = Spawn(class'BallisticFix.M806LaserDot',,,Loc);
}

simulated function DrawLaserSight ( Canvas Canvas )
{
	local Vector HitLocation, Start, End, HitNormal;
	local Rotator AimDir;
	local Actor Other;

	if (ClientState != WS_ReadyToFire || !bLaserOn/* || !bScopeView */|| ReloadState != RS_None || IsInState('DualAction')/* || Level.TimeSeconds - FireMode[0].NextFireTime < 0.2*/)
	{
		KillLaserDot();
		return;
	}

	AimDir = BallisticFire(FireMode[0]).GetFireAim(Start);

	End = Start + Normal(Vector(AimDir))*5000;
	Other = FireMode[0].Trace (HitLocation, HitNormal, End, Start, true);
	if (Other == None)
		HitLocation = End;

	// Draw dot at end of beam
	SpawnLaserDot(HitLocation);
	if (LaserDot != None)
		LaserDot.SetLocation(HitLocation);
	Canvas.DrawActor(LaserDot, false, false, Instigator.Controller.FovAngle);
}

simulated event RenderOverlays( Canvas C )
{
	local float	ScaleFactor;//, XL, XY;


    if (!bScopeView)
	{
		super.RenderOverlays(C);
		if (!IsInState('Lowered'))
			DrawLaserSight(C);
		return;
	}

    SetLocation(Instigator.Location + Instigator.CalcDrawOffset(self));
	SetRotation(Instigator.GetViewRotation());
    ScaleFactor = C.ClipY / 1200;


    if (ScopeViewTex != None)
    {
        C.SetDrawColor(255,255,255,255);

        C.SetPos(C.OrgX, C.OrgY);
    	C.DrawTile(ScopeViewTex, (C.SizeX - C.SizeY)/2, C.SizeY, 0, 0, 1, 1);

        C.SetPos((C.SizeX - C.SizeY)/2, C.OrgY);
        C.DrawTile(ScopeViewTex, C.SizeY, C.SizeY, 0, 0, 1024, 1024);

        C.SetPos(C.SizeX - (C.SizeX - C.SizeY)/2, C.OrgY);
        C.DrawTile(ScopeViewTex, (C.SizeX - C.SizeY)/2, C.SizeY, 0, 0, 1, 1);
	}


}

function ServerUpdateLaser(bool bNewLaserOn)
{
	bUseNetAim = default.bUseNetAim || bScopeView || bNewLaserOn;
}

exec simulated function WeaponSpecial(optional byte i)
{
		if (!bLaserOn)
		{
			bLaserOn=true;
		}
		else
		{
			if (bLaserOn)
			{
				bLaserOn=false;
			}
			else
			{
				bLaserOn=true;
			}
		}
	bUseNetAim = default.bUseNetAim || bScopeView || bLaserOn;
	ServerUpdateLaser(bLaserOn);
}



//Draw special weapon info on the hud
simulated function NewDrawWeaponInfo(Canvas C, float YPos)
{
	if (bLaserOn)	{
		CrosshairCfg.Color1.A /= 2;
		CrosshairCfg.Color2.A /= 2;
	}
	Super.NewDrawWeaponInfo (C, YPos);

	if (bLaserOn)	{
		CrosshairCfg.Color1.A = default.CrosshairCfg.Color1.A ;
		CrosshairCfg.Color2.A = default.CrosshairCfg.Color2.A ;
	}
}







// Targeted hurt radius moved here to avoid crashing

simulated function TargetedHurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation, optional Pawn ExcludedPawn )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if( bHurtEntry ) //not handled well...
		return;

	bHurtEntry = true;
	
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') && (ExcludedPawn == None || Victims != ExcludedPawn))
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			class'BallisticDamageType'.static.GenericHurt
			(
				Victims,
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
		}
	}
	bHurtEntry = false;
}





//===============================================
// Azarael Fixed Burst Netcode
//===============================================


// Cycle through the various weapon modes
function ServerSwitchWeaponMode (byte NewMode)
{


	if (CurrentWeaponMode > 0 && FireMode[0].IsFiring())
		return;

	NewMode = CurrentWeaponMode + 1;
	while (NewMode != CurrentWeaponMode && (NewMode >= WeaponModes.length || WeaponModes[NewMode].bUnavailable) )
	{
		if (NewMode >= WeaponModes.length)
			NewMode = 0;
		else
			NewMode++;
	}
	if (!WeaponModes[NewMode].bUnavailable)
  		CurrentWeaponMode = NewMode;
  
	// Azarael - This assumes that all firemodes implementing burst modify the primary fire alone.
	// To my knowledge, this is the case.
	// Sarge - Hard coding to work with the M30A2 - Cut down
	if (CurrentWeaponMode == 1 && CamoIndex != 1)
	{
		M30A2PrimaryFire(BFireMode[0]).bRapidMode = True;
		if (!Instigator.IsLocallyControlled())
			ClientSwitchRapidMode(True);
	}
	else if (M30A2PrimaryFire(BFireMode[0]).bRapidMode)
	{ 
		M30A2PrimaryFire(BFireMode[0]).bRapidMode = False;
		if (!Instigator.IsLocallyControlled())
			ClientSwitchRapidMode(False);
	}

	if (!Instigator.IsLocallyControlled())
		M30A2PrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
	ClientSwitchCannonMode (CurrentWeaponMode);

}

simulated function ClientSwitchRapidMode(bool bRapid, optional int Max)
{
	M30A2PrimaryFire(BFireMode[0]).bRapidMode = bRapid;
}

//===============================================
// AI Crap
//===============================================

simulated function float RateSelf()
{
	if (!HasAmmo())
		CurrentRating = 0;
	else if (Ammo[0].AmmoAmount < 1 && MagAmmo < 1)
		CurrentRating = Instigator.Controller.RateWeapon(self)*0.3;
	else
		return Super.RateSelf();
	return CurrentRating;
}


// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()
{
	local Bot B;
	B = Bot(Instigator.Controller);
	if (B != None)
	{
		if (CurrentWeaponMode != 2 && VSize(B.Enemy.Location - Instigator.Location) > 200)
			CurrentWeaponMode = 2;
		else if (CurrentWeaponMode != 3 && VSize(B.Enemy.Location - Instigator.Location) < 200)
			CurrentWeaponMode = 3;
	}
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if (B.Skill > Rand(6))
	{
		if (Chaos < 0.1 || Chaos < 0.5 && VSize(B.Enemy.Location - Instigator.Location) > 500)
			return 1;
	}
	else if (FRand() > 0.75)
		return 1;
	return 0;
}

function float GetAIRating()
{
	local Bot B;
	local float Result, Dist;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	Dist = VSize(B.Enemy.Location - Instigator.Location);

	Result = Super.GetAIRating();
	if (Dist < 500)
		Result -= 1-Dist/500;
	else if (Dist < 3000)
		Result += (Dist-1000) / 2000;
	else
		Result = (Result + 0.66) - (Dist-3000) / 2500;
	if (Result < 0.34)
	{
		if (CurrentWeaponMode != 2)
		{
			CurrentWeaponMode = 2;
		}
	}

	return Result;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return 0.0;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.5;	}
// End AI Stuff =====


/*
simulated function TickFireCounter (float DT)
{
    if (CurrentWeaponMode == 1 && level.Netmode == NM_Standalone)
    {
        if (!IsFiring() && FireCount > 0 && FireMode[0].NextFireTime - level.TimeSeconds < -0.6)
            FireCount = 0;
    }
    else
        super.TickFireCounter(DT);
}*/

defaultproperties
{
     SuperFireSound=Sound'BWBP_SKC_Sounds.M50A2.M30A2-Fire'
     SuperFireSoundAlt=Sound'BWBP_SKC_Sounds.M50A2.M30A2-SilenceFire'

     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.000000
     BigIconMaterial=Texture'BWBP_SKC_Tex.M30A2.BigIcon_M30A2'
     BallisticInventoryGroup=7
     SightFXClass=Class'BallisticFix.M50SightLEDs'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     SpecialInfo(0)=(Info="240.0;25.0;1.0;80.0;2.0;0.1;0.1")
     BringUpSound=(Sound=Sound'BallisticSounds2.M50.M50Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.M50.M50Putaway')
     MagAmmo=21

     CamoMaterials[1]=Texture'BWBP_SKC_Tex.M30A2.M30A2-SA'
     CamoMaterials[2]=Texture'BWBP_SKC_Tex.M30A2.M30A2-SB'
     CamoMaterials[3]=Texture'BWBP_SKC_Tex.M30A2.M30A2-SATiger'
     CamoMaterials[4]=Texture'BWBP_SKC_Tex.M30A2.M30A2-SBTiger'

     CockAnimPostReload="ReloadEndCock"
     CockSound=(Sound=Sound'BallisticSounds2.M50.M50Cock')
     ClipHitSound=(Sound=Sound'BallisticSounds2.M50.M50ClipHit')
     ClipOutSound=(Sound=Sound'BallisticSounds2.M50.M50ClipOut')
     ClipInSound=(Sound=Sound'BallisticSounds2.M50.M50ClipIn')
     ClipInFrame=0.650000
     bNeedCock=True
     WeaponModes(0)=(ModeName="Semi-Automatic")
     WeaponModes(1)=(ModeName="Burst Fire")
     WeaponModes(2)=(ModeName="Automatic",bUnavailable=True)
     WeaponModes(3)=(ModeName="Suppression",bUnavailable=True,ModeID="WM_FullAuto")
     CurrentWeaponMode=1
     ScopeViewTex=Texture'BWBP_SKC_Tex.M30A2.M30A2-Scope'
     ZoomInSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomIn',Volume=0.500000,Pitch=1.000000)
     ZoomOutSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomOut',Volume=0.500000,Pitch=1.000000)
     FullZoomFOV=30.000000
	 ZoomType=ZT_Logarithmic
     bNoMeshInScope=True
     bNoCrosshairInScope=true
     SightPivot=(Pitch=600,Roll=-1024)
     SightOffset=(X=-1.000000,Y=-1.000000,Z=11.600000)
     SightDisplayFOV=20.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M806InA',Pic2=Texture'BallisticUI2.Crosshairs.Misc8',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(R=0),Color2=(G=0),StartSize1=123,StartSize2=13)
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     ViewAimFactor=0.200000
     ViewRecoilFactor=0.600000
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.300000),(InVal=0.800000,OutVal=-0.400000),(InVal=1.000000,OutVal=-0.200000)))
     RecoilYCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.650000),(InVal=0.600000,OutVal=0.800000),(InVal=0.800000,OutVal=0.900000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYawFactor=0.400000
     RecoilXFactor=0.300000
     RecoilYFactor=0.200000
     CrouchAimFactor=0.300000
     FireModeClass(0)=Class'BWBP_SKC_Fix.M30A2PrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.M30A2SecondaryFire'
     PutDownTime=0.700000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     CurrentRating=0.600000
     Description="M30A1 Tactical Rifle||Manufacturer: Enravion Combat Solutions|Primary: Accurate Rifle Fire|Secondary: Charged Gauss Fire|Special: Laser Dot||A further improvement on their crowning achievement, the M30A1 is the long range version of the famed rifle. With a forward mounted laser sight and heavy 7.62 rifle rounds, the M30A1 Tactical Rifle can accurately snipe targets at any distance. In order to compensate for the slower firing speed and increased recoil, Enravion added a secondary gauss projectile accelerator to the barrel. By simply depressing the trigger twice in quick succession, the user can activate the system and propel the bullet at a much higher velocity through the armor and flesh of unsuspecting victims. (With regards to a minor recharge time.) The A1 comes equipped with a mounted camera sight for increased accuracy."
     Priority=65
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     PickupClass=Class'BWBP_SKC_Fix.M30A2Pickup'
     PlayerViewOffset=(X=0.500000,Y=6.000000,Z=-8.200000)
     BobDamping=2.000000
     AttachmentClass=Class'BWBP_SKC_Fix.M30A2Attachment'
     IconMaterial=Texture'BWBP_SKC_Tex.M30A2.SmallIcon_M30A2'
     IconCoords=(X2=127,Y2=31)
     ItemName="M30A1 Tactical Rifle"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     Mesh=SkeletalMesh'BallisticAnims2.M50Assault'
     DrawScale=0.350000
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Texture'BWBP_SKC_Tex.M30A2.M30A2-SA'
     Skins(2)=Texture'BWBP_SKC_Tex.M30A2.M30A2-SB'
     Skins(3)=Combiner'BWBP_SKC_Tex.M30A2.M30A2-GunScope'
     Skins(4)=Texture'BWBP_SKC_Tex.M30A2.M30A2-Laser'
     Skins(5)=Texture'BWBP_SKC_Tex.M30A2.M30A2-Gauss'
     Skins(6)=Texture'ONSstructureTextures.CoreGroup.Invisible'
}
