//=============================================================================
// M30A2AssaultRifle.
//
// M30A2 Assault Rifle, aka thez Z. Med fire rate, good damage, high accuracy, good range, Burst, Semi-Auto
// Has underslung
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class AIMS20AssaultRifle extends BallisticWeapon;

var   Pawn			Target;
var   float			TargetTime;
var   float			LastSendTargetTime;
var   vector		TargetLocation;

replication
{
	reliable if (Role == ROLE_Authority && bNetDirty && bNetOwner)
		Target;
	reliable if (Role == ROLE_Authority)
        	ClientSwitchCannonMode, ClientSwitchRapidMode;
}



simulated function ClientSwitchCannonMode (byte newMode)
{
	AIMS20PrimaryFire(FireMode[0]).SwitchCannonMode(newMode);
}

//Modified burst
simulated function PostNetBeginPlay()
{
	if (CurrentWeaponMode == 1)	
	{
		AIMS20PrimaryFire(BFireMode[0]).bRapidMode = True;
 	}
	super.PostNetBeginPlay();
}


simulated event WeaponTick(float DT)
{
	
	local float BestAim, BestDist;
	local Pawn Targ;

	local vector Start;

	super.WeaponTick(DT);

	if (!bScopeView || Role < Role_Authority)
		return;

	Start = Instigator.Location + Instigator.EyePosition();
	BestAim = 0.995;
	Targ = Instigator.Controller.PickTarget(BestAim, BestDist, Vector(Instigator.GetViewRotation()), Start, 20000);
	if (Targ != None)
	{
		if (Targ != Target)
		{
			Target = Targ;
			TargetTime = 0;
		}
		else if (Vehicle(Targ) != None)
			TargetTime += 1.2 * DT * (BestAim-0.95) * 20;
		else
			TargetTime += DT * (BestAim-0.95) * 20;
	}
	else
	{
		TargetTime = FMax(0, TargetTime - DT * 0.5);
	}

}


function AdjustPlayerDamage( out int Damage, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	Target = None;
	TargetTime = 0;
	super.AdjustPlayerDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
}

simulated event RenderOverlays (Canvas Canvas)
{

	if (!bScopeView)
	{
		Super.RenderOverlays(Canvas);
		if (SightFX != None)
			RenderSightFX(Canvas);
		return;
	}
	if (bScopeView && ( (PlayerController(Instigator.Controller).DesiredFOV == PlayerController(Instigator.Controller).DefaultFOV && PlayerController(Instigator.Controller).bZooming==false)
		|| (Level.bClassicView && (PlayerController(Instigator.Controller).DesiredFOV == 90)) ))
	{
		SetScopeView(false);
		PlayAnim(ZoomOutAnim);
	}

	if (!bNoMeshInScope)
	{
		Super.RenderOverlays(Canvas);
		if (SightFX != None)
			RenderSightFX(Canvas);
	}
	else
	{
		SetLocation(Instigator.Location + Instigator.CalcDrawOffset(self));
		SetRotation(Instigator.GetViewRotation());
	}

	// Draw Scope View
	// Draw the Scope View Tex

	// Draw Scope View
   	 if (ScopeViewTex != None)
    	{
   		Canvas.SetDrawColor(255,255,255,255);

        	Canvas.SetPos(Canvas.OrgX, Canvas.OrgY);
    		Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);

        	Canvas.SetPos((Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, Canvas.SizeY, Canvas.SizeY, 0, 0, 1024, 1024);

        	Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);
	}

		DrawMeatVisionMode(Canvas);
}

function ServerSetScopeView(bool bNewValue)
{
	super.ServerSetScopeView(bNewValue);
	if (!bScopeView)
	{
		Target = None;
		TargetTime=0;
	}
}
simulated function SetScopeView(bool bNewValue)
{
	bScopeView = bNewValue;
	if (!bScopeView)
	{
		Target = None;
		TargetTime=0;
	}
	if (Level.NetMode == NM_Client)
		ServerSetScopeView(bNewValue);
	bScopeView = bNewValue;
	SetScopeBehavior();
}


// draws red blob that moves, scanline, and target boxes.
simulated event DrawMeatVisionMode (Canvas C)
{
	local Vector V, V2, V3, X, Y, Z;
	local float ScaleFactor;


    C.Style = ERenderStyle.STY_Alpha;
	
	if (Target == None)
		return;

	// Draw Target Boxers
	ScaleFactor = C.ClipX / 1600;
	GetViewAxes(X, Y, Z);
	V  = C.WorldToScreen(Target.Location - Y*Target.CollisionRadius + Z*Target.CollisionHeight);
	V.X -= 32*ScaleFactor;
	V.Y -= 32*ScaleFactor;
	C.SetPos(V.X, V.Y);
	V2 = C.WorldToScreen(Target.Location + Y*Target.CollisionRadius - Z*Target.CollisionHeight);
	C.SetDrawColor(160,185,200,255);
      C.DrawTileStretched(Texture'BWBP_SKC_Tex.X82.X82Targetbox', (V2.X - V.X) + 32*ScaleFactor, (V2.Y - V.Y) + 32*ScaleFactor);

    V3 = C.WorldToScreen(Target.Location - Z*Target.CollisionHeight);
}




simulated function BringUp(optional Weapon PrevWeapon)
{

	if (Instigator != None && AIController(Instigator.Controller) != None)
	{
		AimSpread *= 0.30;
		ChaosAimSpread *= 0.30;
	}


	Super.BringUp(PrevWeapon);
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
	// Sarge - Hard coding to work with the AIMS20 - Cut down
	if (CurrentWeaponMode == 1)
	{
		AIMS20PrimaryFire(BFireMode[0]).bRapidMode = True;
		if (!Instigator.IsLocallyControlled())
			ClientSwitchRapidMode(True);
	}
	else if (AIMS20PrimaryFire(BFireMode[0]).bRapidMode)
	{ 
		AIMS20PrimaryFire(BFireMode[0]).bRapidMode = False;
		if (!Instigator.IsLocallyControlled())
			ClientSwitchRapidMode(False);
	}

	if (!Instigator.IsLocallyControlled())
		AIMS20PrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
	ClientSwitchCannonMode (CurrentWeaponMode);
}

simulated function ClientSwitchRapidMode(bool bRapid, optional int Max)
{
	AIMS20PrimaryFire(BFireMode[0]).bRapidMode = bRapid;
}





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
    if (CurrentWeaponMode == 1)
    {
        if (!IsFiring() && FireCount > 0 && FireMode[0].NextFireTime - level.TimeSeconds < -0.3)
            FireCount = 0;
    }
    else
        super.TickFireCounter(DT);
}*/

defaultproperties
{
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.000000
     BigIconMaterial=Texture'BWBP_SKC_Tex.M30A2.BigIcon_M30A2'
     BallisticInventoryGroup=5
     SightFXClass=Class'BallisticFix.M50SightLEDs'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     SpecialInfo(0)=(Info="240.0;25.0;1.0;80.0;2.0;0.1;0.1")
     BringUpSound=(Sound=Sound'BallisticSounds2.M50.M50Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.M50.M50Putaway')
     MagAmmo=450
     InventorySize=50
     CockAnimPostReload="ReloadEndCock"
     CockSound=(Sound=Sound'BallisticSounds2.M50.M50Cock')
     ClipHitSound=(Sound=Sound'BallisticSounds2.M50.M50ClipHit')
     ClipOutSound=(Sound=Sound'BallisticSounds2.M50.M50ClipOut')
     ClipInSound=(Sound=Sound'BallisticSounds2.M50.M50ClipIn')
     ClipInFrame=0.650000
     bNeedCock=True
     WeaponModes(0)=(ModeName="Burst 60,000 RPM")
     WeaponModes(1)=(ModeName="Burst 6,000 RPM")
     WeaponModes(2)=(ModeName="Auto 4,000 RPM")
     WeaponModes(3)=(ModeName="Auto 9,500 RPM",ModeID="WM_FullAuto")
     CurrentWeaponMode=1
     ScopeViewTex=Texture'BWBP_SKC_TexExp.AIMS.AIMS20ScopeView'
     ZoomInSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomIn',Volume=0.500000,Pitch=1.000000)
     ZoomOutSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomOut',Volume=0.500000,Pitch=1.000000)
     FullZoomFOV=30.000000
	 ZoomType=ZT_Smooth
     bNoMeshInScope=True
     SightPivot=(Pitch=600,Roll=-1024)
     SightOffset=(X=-1.000000,Y=-1.000000,Z=11.600000)
     SightDisplayFOV=20.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.G5OutA',pic2=Texture'BallisticUI2.Crosshairs.Dot1',USize1=256,VSize1=256,USize2=128,VSize2=128,Color1=(B=255,G=255,R=255,A=255),Color2=(B=0,G=0,R=255,A=255),StartSize1=25,StartSize2=13)
     CrouchAimFactor=0.500000
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     ViewAimFactor=0.200000
     ViewRecoilFactor=0.600000
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.300000),(InVal=0.800000,OutVal=-0.400000),(InVal=1.000000,OutVal=-0.200000)))
     RecoilYCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.650000),(InVal=0.600000,OutVal=0.800000),(InVal=0.800000,OutVal=0.900000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYawFactor=0.400000
     RecoilXFactor=0.300000
     RecoilYFactor=0.200000
     ChaosAimSpread=(X=(Min=-1024.000000,Max=1024.000000),Y=(Min=-64.000000,Max=1424.000000))
     RecoilMax=1424.000000
     FireModeClass(0)=Class'BWBP_SKC_Fix.AIMS20PrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.AIMS20SecondaryFire'
     PutDownTime=0.700000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     CurrentRating=0.600000
     Description="AIMS-20 'Terminator' Super Weapon System||Manufacturer: XWI Elite Systems|Primary: Accurate Rifle Fire|Secondary: Charged Gauss Fire|Special: Laser Dot||A further improvement on their crowning achievement, the M30A1 is the long range version of the famed rifle. With a forward mounted laser sight and heavy 7.62 rifle rounds, the M30A1 Tactical Rifle can accurately snipe targets at any distance. In order to compensate for the slower firing speed and increased recoil, Enravion added a secondary gauss projectile accelerator to the barrel. By simply depressing the trigger twice in quick succession, the user can activate the system and propel the bullet at a much higher velocity through the armor and flesh of unsuspecting victims. (With regards to a 2 second recharge time.) The A1 comes equipped with a mounted camera sight for increased accuracy."
     Priority=65
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     PickupClass=Class'BWBP_SKC_Fix.AIMS20Pickup'
     PlayerViewOffset=(X=0.500000,Y=6.000000,Z=-8.200000)
     BobDamping=2.000000
     AttachmentClass=Class'BWBP_SKC_Fix.AIMS20Attachment'
     IconMaterial=Texture'BWBP_SKC_Tex.M30A2.SmallIcon_M30A2'
     IconCoords=(X2=127,Y2=31)
     ItemName="[B] AIMS-20 Weapon System"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     Mesh=SkeletalMesh'BallisticAnims2.M50Assault'
     DrawScale=0.350000
}
