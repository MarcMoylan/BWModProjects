//=============================================================================
// M2020GaussDMR.
//
// Semi-Auto designated marksman rifle. Fufills the roll of semi-auto sniper since the Bulldog has
// no scope and the X83 has ludicrous recoil. Can trade RoF/Power via firemodes.
// 
// Special fire generates a heavy magnetic field which reduces incoming damage but will damage the gun.
// Heavy magnetic field shield will reduce incoming dmg by 30, but won't negate completely. (5 dmg)
// Magnets cannot accelerate bullets while shield is being generated.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class M2020GaussDMR extends BallisticWeapon;

var   Emitter		LaserDot;
var   bool			bLaserOn;
var	int	NumpadXOffset;
var	int	NumpadYOffset;
var bool		bFirstDraw;
var bool		bOverheat;
var() Sound		DrawSoundLong;		//For first draw
var() Sound		VentingSound;		//For DA MAGNETS
var() Sound		OverHeatSound;		//For vents
var Sound       ShieldHitSound;
var float		HeatLevel;			// Current Heat level, duh...
var float MaxHeat;

var name			BulletBone1; //What it says on the tin
var name			BulletBone2; //What it says on the tin

var Actor	Arc;				// The top arcs

var   float		MagnetSwitchTime;
var   name		MagnetOpenAnim;
var   name		MagnetCloseAnim;
var   name		MagnetForceCloseAnim;
var   bool		bMagnetOpen;
var   byte			LastWeaponMode;

var() ScriptedTexture WeaponScreen;

var() Material	Screen; //This is a self-illum Scipted Texture
var() Material	ScreenBaseX; //This is a texture that can be Base1 or Base2
var() Material	ScreenBase1; //This is the On Screen background
var() Material	ScreenBase2; //This is the Off Screen background
var() Material	Numbers;     //This is the font used by the screen
var protected const color MyFontColor; //Why do I even need this?


replication
{
	reliable if (Role == ROLE_Authority)
		ClientSwitchCannonMode, ClientScreenStart, ClientSetHeat;
}

//========================== AMMO COUNTER NON-STATIC TEXTURE ============

simulated function ClientScreenStart()
{
	ScreenStart();
}
// Called on clients from camera when it gets to postnetbegin
simulated function ScreenStart()
{
	if (Instigator.IsLocallyControlled())
		WeaponScreen.Client = self;
	Skins[3] = Screen;
	if (Instigator.IsLocallyControlled())
		WeaponScreen.Revision++;
}

simulated event Destroyed()
{
	if (Instigator != None && AIController(Instigator.Controller) == None)
		WeaponScreen.client=None;

	if (Arc != None)
		Arc.Destroy();
	Super.Destroyed();
}

simulated event RenderTexture( ScriptedTexture Tex )
{
	Tex.DrawTile(0,0,256,256,0,0,256,256,ScreenBaseX, MyFontColor);
	Tex.DrawTile(100,120,100,160,NumpadXOffset,NumpadYOffset,70,60,Numbers, MyFontColor);
}
	
simulated function UpdateScreen()
{

	if (Instigator != None && AIController(Instigator.Controller) != None)
		return;

	if (bMagnetOpen)
	{
		ScreenBaseX=ScreenBase2;
		Instigator.AmbientSound = VentingSound;
	}
	else
	{
		ScreenBaseX=ScreenBase1;
		Instigator.AmbientSound = UsedAmbientSound;
	}
}
	
// Consume ammo from one of the possible sources depending on various factors
simulated function bool ConsumeMagAmmo(int Mode, float Load, optional bool bAmountNeededIsMax)
{
	if (bNoMag || (BFireMode[Mode] != None && BFireMode[Mode].bUseWeaponMag == false))
		ConsumeAmmo(Mode, Load, bAmountNeededIsMax);
	else
	{
		if (MagAmmo < Load)
			MagAmmo = 0;
		else
			MagAmmo -= Load;
	}
	UpdateScreen();
	return true;
}

//=====================================================================

static function class<Pickup> RecommendAmmoPickup(int Mode)
{
	return class'AP_42MachineGun';
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	if (Instigator != None && AIController(Instigator.Controller) != None)
	{
		AimSpread *= 0.30;
		ChaosAimSpread *= 0.15;
	}
	else if (Instigator != None && AIController(Instigator.Controller) == None)
	{
		ScreenStart();
		if (!Instigator.IsLocallyControlled())
			ClientScreenStart();
	}


	bMagnetOpen=false;
	if (bFirstDraw && MagAmmo > 0)
	{
		BringUpSound.Sound=DrawSoundLong;
     		BringUpTime=2.900000;
     		SelectAnim='PulloutFancy';
		bFirstDraw=false;
	}
	else
	{
		BringUpSound.Sound=default.BringUpSound.sound;
     		BringUpTime=default.BringUpTime;
		SelectAnim='Pullout';
	}
	UpdateScreen();
	Super.BringUp(PrevWeapon);
//	FireMode[1].FireAnim = ZoomInAnim;
}

simulated function bool PutDown()
{
	if (super.PutDown())
	{
		if (bMagnetOpen)
		{
			bMagnetOpen=false;
			AdjustMagnetProperties();
		}
		if (Arc != None)	Arc.Destroy();
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

exec simulated function WeaponSpecial(optional byte i)
{
	if (bOverheat)
		return;
	if (level.TimeSeconds < MagnetSwitchTime || ReloadState != RS_None)
		return;
	if (Clientstate != WS_ReadyToFire)
		return;

	bMagnetOpen = !bMagnetOpen;

	TemporaryScopeDown(0.4);
	MagnetSwitchTime = level.TimeSeconds + 2.5;
	PlayMagnetSwitching(bMagnetOpen);
	AdjustMagnetProperties();
	if(Level.NetMode == NM_Client)
		ServerWeaponSpecial(byte(bMagnetOpen));
}

function ServerWeaponSpecial (byte i)
{
	if (bOverheat)
		return;
	
	bMagnetOpen = bool(i);
	PlayMagnetSwitching(bMagnetOpen);
	AdjustMagnetProperties();
}

//Animation for magnet
simulated function PlayMagnetSwitching(bool bOpen)
{
	if (bOpen)
		PlayAnim(MagnetOpenAnim);
	else
		PlayAnim(MagnetCloseAnim);
}

simulated function Overheat(bool bForceClose)
{
	if (bForceClose)
		PlayAnim(MagnetForceCloseAnim);
	else
		PlayAnim(MagnetCloseAnim);
	bMagnetOpen=false;
	AdjustMagnetProperties();
}

simulated function AdjustMagnetProperties ()
{
	ViewAimFactor		= default.ViewAimFactor;
	ViewRecoilFactor	= default.ViewRecoilFactor;
	ChaosDeclineTime	= default.ChaosDeclineTime;
	ChaosTurnThreshold	= default.ChaosTurnThreshold;
	ChaosSpeedThreshold	= default.ChaosSpeedThreshold;
	RecoilPitchFactor	= default.RecoilPitchFactor;
	RecoilYawFactor		= default.RecoilYawFactor;
	RecoilXFactor		= default.RecoilXFactor;
	RecoilYFactor		= default.RecoilYFactor;
	RecoilDeclineTime	= default.RecoilDeclineTime;
	
	if (bMagnetOpen)
	{
		if (Arc == None)
			class'bUtil'.static.InitMuzzleFlash(Arc, class'M2020ShieldEffect', DrawScale, self, 'tip');

		IdleAnim='IdleShield';
		BFireMode[0].RecoilPerShot = 64;
		CrouchAimFactor		= 0.8;
		RecoilYawFactor		*= 0.7;
		ChaosTurnThreshold	*= 0.8;
		ChaosDeclineTime	*= 1.2;
		RecoilXFactor		*= 0.6;
		RecoilYFactor		*= 0.6;
		ChaosSpeedThreshold	*= 0.8;
		
		WeaponModes[3].bUnavailable=false;
		
		LastWeaponMode = CurrentWeaponMode;
		CurrentWeaponMode = 3;
		
		M2020GaussPrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
		
		WeaponModes[0].bUnavailable=true;
		WeaponModes[1].bUnavailable=true;
		WeaponModes[2].bUnavailable=true;
	}
	else
	{
		if (Arc != None)
			Emitter(Arc).kill();

		IdleAnim='Idle';
		Instigator.AmbientSound = UsedAmbientSound;
		BFireMode[0].RecoilPerShot = BFireMode[0].default.RecoilPerShot;
		CrouchAimFactor		= default.CrouchAimFactor;
		
		WeaponModes[0].bUnavailable=false;
		WeaponModes[1].bUnavailable=false;
		WeaponModes[2].bUnavailable=false;
		
		CurrentWeaponMode = LastWeaponMode;
		
		M2020GaussPrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
		
		WeaponModes[3].bUnavailable=true;
	}
	UpdateScreen();
}
simulated event WeaponTick (float DT)
{
	if (bOverheat && Heatlevel == 1)
		Overheat(false);
	super.WeaponTick(DT);
}
simulated event Tick (float DT)
{
	if (bMagnetOpen)
		AddHeat(DT*2, false);
	else if (Heatlevel > 0)
		Heatlevel = FMax(HeatLevel - DT, 0);
	else
		Heatlevel = 0;

	super.Tick(DT);
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

// Draw the scope view
simulated event RenderOverlays (Canvas Canvas)
{

	if (MagAmmo == 0)
	{
		NumpadXOffset=160; NumpadYOffset=10;
	}
	else if (MagAmmo > 10)
	{
		NumpadXOffset=160; NumpadYOffset=60;
	}
	else
	{
		NumpadXOffset=50;
		NumpadYOffset=(10+(10-MagAmmo)*49);
	}
	if (Instigator.IsLocallyControlled())
	{
		WeaponScreen.Revision++;
	}

	if (!bScopeView)
	{
		Super.RenderOverlays(Canvas);
		if (SightFX != None)
			RenderSightFX(Canvas);
		return;
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
	if (!IsInState('Lowered'))
		DrawLaserSight(Canvas);
}

function ServerSwitchWeaponMode (byte newMode)
{
	super.ServerSwitchWeaponMode (newMode);
	if (!Instigator.IsLocallyControlled())
		M2020GaussPrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
	ClientSwitchCannonMode (CurrentWeaponMode);
}
simulated function ClientSwitchCannonMode (byte newMode)
{
	M2020GaussPrimaryFire(FireMode[0]).SwitchCannonMode(newMode);
}

// Secondary fire doesn't count for this weapon
simulated function bool HasAmmo()
{
	//First Check the magazine
	if (!bNoMag && FireMode[0] != None && MagAmmo >= FireMode[0].AmmoPerFire)
		return true;
	//If it is a non-mag or the magazine is empty
	if (Ammo[0] != None && FireMode[0] != None && Ammo[0].AmmoAmount >= FireMode[0].AmmoPerFire)
			return true;
	return false;	//This weapon is empty
}

simulated event AnimEnd (int Channel)
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);
	if (anim == MagnetCloseAnim && ReloadState == RS_StartShovel)
	{
		ReloadState = RS_PreClipOut;
		bMagnetOpen = False;
		AdjustMagnetProperties();
		PlayReload();
	}

	Super.AnimEnd(Channel);
}

simulated function PlayReload()
{
	if (bMagnetOpen)
		SafePlayAnim(MagnetCloseAnim, 1.2, , 0, "RELOAD");
	else
		SafePlayAnim(ReloadAnim, ReloadAnimRate, , 0, "RELOAD");
}

// Prepare to reload, set reload state, start anims. Called on client and server
simulated function CommonStartReload (optional byte i)
{
	local int m;
	if (ClientState == WS_BringUp)
		ClientState = WS_ReadyToFire;
	if (bMagnetOpen)
		ReloadState = RS_StartShovel;
	else
		ReloadState = RS_PreClipOut;
	PlayReload();

	if (bScopeView && Instigator.IsLocallyControlled())
		TemporaryScopeDown(Default.SightingTime*Default.SightingTimeScale);
	for (m=0; m < NUM_FIRE_MODES; m++)
		if (BFireMode[m] != None)
			BFireMode[m].ReloadingGun(i);

	if (bCockAfterReload)
		bNeedCock=true;
	if (bCockOnEmpty && MagAmmo < 1)
		bNeedCock=true;
	bNeedReload=false;
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



// Animation notify for when the clip is stuck in
simulated function Notify_ClipUp()
{
	SetBoneScale(0,1.0,BulletBone1);
	if (Ammo[0].AmmoAmount > 1)
		SetBoneScale(1,1.0,BulletBone2);
	
}


simulated function Notify_ClipOut()
{
	Super.Notify_ClipOut();
	if (MagAmmo < 3)
		SetBoneScale(1,0.0,BulletBone2);
	if(MagAmmo < 2)
		SetBoneScale(0,0.0,BulletBone1);
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
	return Result;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return 0.0;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.5;	}
// End AI Stuff =====

function AdjustPlayerDamage( out int Damage, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
    local int Drain;
	local vector Reflect;
    local vector HitNormal;
    local float DamageMax;

	DamageMax = 30.0;
	if( !DamageType.default.bArmorStops || !DamageType.default.bLocationalHit )
        return;

    if ( CheckReflect(HitLocation, HitNormal, 0) )
    {
	Drain = Min(Damage,DamageMax);
	Reflect = MirrorVectorByNormal( Normal(Location - HitLocation), Vector(Instigator.Rotation) );
        Damage -= Drain;
	if (Damage < 5)
	{
		Damage = 5;
		PlaySound(ShieldHitSound, SLOT_None);
	}
	
	AddHeat(Drain/5, true);
    Momentum *= 1.25;
	DoReflectEffect(Drain/2);
    }
}

function DoReflectEffect(int Drain)
{
    PlaySound(ShieldHitSound, SLOT_None);
    ClientTakeHit(Drain);
}

simulated function ClientTakeHit(int Drain)
{
}

function bool CheckReflect( Vector HitLocation, out Vector RefNormal, int AmmoDrain )
{
    local Vector HitDir;
    local Vector FaceDir;

    if (!bMagnetOpen) return false;

    FaceDir = Vector(Instigator.Controller.Rotation);
    HitDir = Normal(Instigator.Location - HitLocation + Vect(0,0,8));

    RefNormal = FaceDir;

    if ( FaceDir dot HitDir < -0.37 ) // 68 degree protection arc
        return true;

    return false;
}

simulated function AddHeat(float Amount, bool bReplicate)
{
	HeatLevel = FClamp(HeatLevel+Amount, 0, MaxHeat);
	
	if (bReplicate && !Instigator.IsLocallyControlled())
		ClientSetHeat(HeatLevel);
		
	if (HeatLevel == MaxHeat && bMagnetOpen)
	{
		PlaySound(OverHeatSound,,3.7,,32);
		Overheat(true);
	}
}

simulated function ClientSetHeat(float NewHeat)
{
	HeatLevel = NewHeat;
	
	if (HeatLevel == MaxHeat && bMagnetOpen)
	{
		PlaySound(OverHeatSound,,3.7,,32);
		Overheat(true);
	}
}

simulated function float ChargeBar()
{
	return (HeatLevel/MaxHeat);
}

defaultproperties
{
	 MyFontColor=(R=255,G=255,B=255,A=255)
	 Numbers=Texture'BWBP_SKC_TexExp.M2020.M2020-Numbers'
	 Screen=Shader'BWBP_SKC_TexExp.M2020.M2020-ScriptLCD-SD'
	 ScreenBase1=Texture'BWBP_SKC_TexExp.M2020.M2020-Screen'
	 ScreenBase2=Texture'BWBP_SKC_TexExp.M2020.M2020-ScreenOff'
     AimSpread=(X=(Min=-32.000000,Max=32.000000),Y=(Min=-32.000000,Max=32.000000))
     AIRating=0.600000
     AIReloadTime=1.000000
     AttachmentClass=Class'BWBP_SKC_Fix.M2020GaussAttachment'
     BallisticInventoryGroup=7
     BulletBone1="Bullet1"
     BulletBone2="Bullet2"
     CockSelectAnim="PulloutFancy"
     CockSelectAnimRate=1.000000
     CockingBringUpTime=2.900000
	 
     bCockOnEmpty=True
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bFirstDraw=True
     bFullVolume=True
     BigIconMaterial=Texture'BWBP_SKC_TexExp.Longhorn.BigIcon_M2020'
     bLaserOn=True

     bMagnetOpen=False
     bNeedCock=False
     bNoCrosshairInScope=True
     bNoMeshInScope=True
     BobDamping=2.000000
     BringUpSound=(Sound=Sound'WeaponSounds.LightningGun.SwitchToLightningGun')
     BringUpTime=1.500000
     bShowChargingBar=True
     bWT_Bullet=True
     ClipHitSound=(Sound=Sound'BWBP_SKC_SoundsExp.M2020.M2020-MagIn',Volume=3.700000)
     ClipInFrame=0.650000
     ClipInSound=(Sound=Sound'BWBP_SKC_SoundsExp.M2020.M2020-MagHit',Volume=3.700000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_SoundsExp.M2020.M2020-MagOut',Volume=3.700000)
     CockAnimPostReload="ReloadEndCock"
     CockSound=(Sound=Sound'BWBP_SKC_SoundsExp.M2020.M2020-Cock',Volume=3.700000)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M353InA',pic2=Texture'BallisticUI2.Crosshairs.Misc6',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=207,G=229,R=231,A=197),Color2=(B=226,G=0,R=0,A=255),StartSize1=77,StartSize2=68)
     CrouchAimFactor=0.700000
     CurrentRating=0.600000
     CurrentWeaponMode=0
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     Description="M2020 Gauss Designated Marksman Rifle||Manufacturer: UTC Defense Tech|Primary: Accelerated Rifle Fire|Secondary: Rifle Scope|Special: Magnetic Field||The M2020 is a 2nd generation Gauss rifle in use by UTC marksmen personnel, currently in the process of being phased out by Enravion 3rd generation M30 models. These 2nd generation Gauss rifles are significantly more portable and powerful than their predecessors, however troops have complained about the M2020 in particular's bulkiness and lack of ergonomics. The rifle itself uses two parallel heavy electromagnets to boost its special 7.62mm rounds to extreme velocities. Charge is variable, and the electromagnets can be disabled at will. |UTC Note: When operating this weapon, keep all metallic objects away from the reciprocaiting chargers. While locking the weapon's magnets open can be fun for pranks, troops are advised to not use it near sensitive military equipment."
     DrawScale=0.350000
     DrawSoundLong=Sound'BWBP_SKC_SoundsExp.M2020.M2020-DrawLong'
     FireModeClass(0)=Class'BWBP_SKC_Fix.M2020GaussPrimaryFire'
     FireModeClass(1)=Class'BCoreFix.BallisticScopeFire'
     FullZoomFOV=10.000000
	 ZoomType=ZT_Smooth
	 GroupOffset=11
     GunLength=80.000000
     IconCoords=(X2=127,Y2=31)
     IconMaterial=Texture'BWBP_SKC_TexExp.Longhorn.SmallIcon_M2020'
     InventoryGroup=9
     ItemName="M2020 Gauss Rifle"
     LightBrightness=150.000000
     LightEffect=LE_NonIncidence
     LightHue=30
     LightRadius=4.000000
     LightSaturation=150
     LightType=LT_Pulse
     MagAmmo=10
     MagnetCloseAnim="ShieldUndeploy"
     MagnetForceCloseAnim="Overheat"
     MagnetOpenAnim="ShieldDeploy"
	 MaxHeat=30
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.M2020_FP'
     OverHeatSound=Sound'BWBP_SKC_Sounds.XavPlas.Xav-Overload'
     PickupClass=Class'BWBP_SKC_Fix.M2020GaussPickup'
     PlayerViewOffset=(X=0.000000,Y=12.000000,Z=-12.000000)
     Priority=65
     PutDownSound=(Sound=Sound'BallisticSounds2.M50.M50Putaway')
     PutDownTime=0.700000
     RecoilDeclineDelay=0.000000
     RecoilDeclineTime=2.000000
     RecoilMax=8096
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.300000),(InVal=0.800000,OutVal=-0.400000),(InVal=1.000000,OutVal=-0.200000)))
     RecoilXFactor=1.000000
     RecoilYawFactor=0.400000
     RecoilYCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.650000),(InVal=0.600000,OutVal=0.800000),(InVal=0.800000,OutVal=0.900000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYFactor=0.200000
     ScopeViewTex=Texture'BWBP_SKC_TexExp.M2020.M2020ScopeView'
     SelectForce="SwitchToAssaultRifle"
     ShieldHitSound=ProceduralSound'WeaponSounds.ShieldGun.ShieldReflection'
     SightAimFactor=0.600000
     SightOffset=(X=0.000000,Y=-3.000000,Z=18.000000)
     Skins(0)=Shader'BWBP_SKC_TexExp.M2020.M2020-ShineAlt'
     Skins(1)=Shader'BWBP_SKC_TexExp.M2020.M2020-Shine'
     Skins(2)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     SoundRadius=128.000000
     SoundVolume=64
     SpecialInfo(0)=(Info="240.0;25.0;1.0;80.0;2.0;0.1;0.1")
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny',SkinNum=2)
     UsedAmbientSound=Sound'BWBP_SKC_SoundsExp.M2020.M2020-Idle'
     VentingSound=Sound'BWBP_SKC_SoundsExp.M2020.M2020-IdleShield'
     ViewAimFactor=0.200000
     ViewRecoilFactor=0.400000
     WeaponModes(0)=(ModeName="Gauss: Recharge")
     WeaponModes(1)=(ModeName="Gauss: Power",ModeID="WM_SemiAuto",Value=1.000000)
     WeaponModes(2)=(ModeName="Gauss: Offline",ModeID="WM_SemiAuto",Value=1.000000)
     WeaponModes(3)=(ModeName="Gauss: Deflecting",ModeID="WM_SemiAuto",Value=1.000000,bUnavailable=True)
     WeaponScreen=ScriptedTexture'BWBP_SKC_TexExp.M2020.M2020-ScriptLCD'
     ZoomInSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomIn',Volume=0.500000,Pitch=1.000000)
     ZoomOutSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomOut',Volume=0.500000,Pitch=1.000000)
//     AimSpread=(X=(Min=-128.000000,Max=128.000000),Y=(Min=-128.000000,Max=128.000000))
//     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
//     Skins(1)=Shader'BWBP_SKC_TexExp.FG50.FG50-ScreenOn'
//     Skins(1)=Texture'BWBP_SKC_TexExp.M2020.M2020-Secondary'
//     Skins(2)=Shader'BWBP_SKC_TexExp.M2020.M2020-Shine'

}
