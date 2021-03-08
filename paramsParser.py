import argparse
import csv
import io
import os
import string

#parse arguments (CSV of paths, BW version (stock, fix, pro)
parser = argparse.ArgumentParser()
parser.add_argument('--csv', help='CSV File containing the paths of the .uc files to parameterize', required=True)
parser.add_argument('--ver', type=int, help='BW version to parse from. 0: stock, 1: fix, 2: pro, 3: real, 4: horde', default=0)
parser.add_argument('--nodef', help='Exclude default values', action="store_true")
parser.add_argument('--mult', help='Exclude default values', action="store_true")

args = vars(parser.parse_args())

#Import CSV as args
csvFile = args['csv']
version = args['ver']
noDefaults = args['nodef']
createMultFiles = args['mult']
masterOutput = ""

#set default dicts
defaultInstantDict = {
	'TraceRange': '(Min=5000.000000,Max=5000.000000)',
	'WaterTraceRange':'128.0',
	'DecayRange':'(Min=0f,Max=0f)',
	'RangeAtten':'1.0',
	'Damage':'0',
	'HeadMult':'1.25',
	'LimbMult':'0.7',
	'DamageType':'None',
	'DamageTypeHead':'None',
	'DamageTypeArm':'None',
	'UseRunningDamage':'False', #NO PREPENDED B?????
	'RunningSpeedThreshold':'300',
	'PenetrationEnergy':'0',
	'PenetrateForce':'0',
	'bPenetrate':'False',
	'PDamageFactor':'0.75',
	'WallPDamageFactor':'0.95',
	'MomentumTransfer':'0',
	'HookStopFactor':'0.0',
	'HookPullForce':'0.0',
	'SpreadMode':'FSM_Rectangle',
	'MuzzleFlashClass':'None',
	'FlashScaleFactor':'1.0',
	'FireSound':'(Volume=1.000000,Radius=512.000000,Pitch=1.000000,bNoOverride=True)',
	'Recoil':'0',
	'Chaos':'0',
	'PushbackForce':'0',
	'Inaccuracy':'(X=0,Y=0)',
	'SplashDamage':'False',
	'RecommendSplashDamage':'False',
	'BotRefireRate':'0.95',
	'WarnTargetPct':'0.0'
}
defaultProjectileDict = {
	'ERadiusFallOffType':'RFO_Linear',
	'ProjectileClass':'None',
	'SpawnOffset':'(X=0,Y=0,Z=0)',
	'Speed':'0',
	'MaxSpeed':'0.000000',
	'AccelSpeed':'0',
	'Damage':'0',
	'DamageRadius':'0.000000',
	'MomentumTransfer':'0',
	'HeadMult':'1.500000',
	'LimbMult':'0.700000',
	'MaxDamageGainFactor':'0',
	'DamageGainStartTime':'0',
	'DamageGainEndTime':'0',
	'SpreadMode':'FSM_Rectangle',
	'MuzzleFlashClass':'None',
	'FlashScaleFactor':'1.0',
	'FireSound':'(Volume=1.000000,Radius=512.000000,Pitch=1.000000,bNoOverride=True)',
	'Recoil':'0',
	'Chaos':'0',
	'PushbackForce':'0',
	'Inaccuracy':'(X=0,Y=0)',
	'SplashDamage':'False',
	'RecommendSplashDamage':'False',
	'BotRefireRate':'0.95',
	'WarnTargetPct':'0.0'
}
defaultShotgunDict = {
	'TracerChance':'0.500000',
	'TraceRange':'(Min=500.000000,Max=2000.000000)',
	'WaterTraceRange':'128.0',
	'DecayRange':'(Min=0.0,Max=0.0)',
	'RangeAtten':'1.0',
	'TraceCount':'0',
	'TracerClass':'None',
	'ImpactManager':'None',
	'bDoWaterSplash':'false',
	'MaxHits':'0',
	'Damage':'0',
	'HeadMult':'1.4',
	'LimbMult':'0.7',
	'DamageType':'None',
	'DamageTypeHead':'None',
	'DamageTypeArm':'None',
	'PenetrationEnergy':'0',
	'PenetrateForce':'0',
	'bPenetrate':'False',
	'PDamageFactor':'0.75',
	'WallPDamageFactor':'0.95',
	'bPenetrate':'False',
	'UseRunningDamage':'False',
	'RunningSpeedThreshold':'300',
	'HookStopFactor':'0.0',
	'HookPullForce':'0.0',
	'SpreadMode':'FSM_Scatter',
	'ShotTypeString':'shots',
	'MuzzleFlashClass':'None',
	'FlashScaleFactor':'1.0',
	'FireSound':'(Volume=1.000000,Radius=512.000000,Pitch=1.000000,bNoOverride=True)',
	'Recoil':'0',
	'Chaos':'0',
	'PushbackForce':'0',
	'MomentumTransfer':'0',
	'Inaccuracy':'(X=0,Y=0)',
	'SplashDamage':'False',
	'RecommendSplashDamage':'False',
	'BotRefireRate':'0.95',
	'WarnTargetPct':'0.0'
}
defaultMeleeDict = {
	'TraceRange':'(Min=145.000000,Max=145.000000)',
	'WaterTraceRange':'128.0',
	'DecayRange':'(Min=0.0,Max=0.0)',
	'RangeAtten':'1.0',
	'Damage':'50.000000',
	'HeadMult':'1.0',
	'LimbMult':'1.0',
	'DamageType':'None',
	'DamageTypeHead':'None',
	'DamageTypeArm':'None',
	'ChargeDamageBonusFactor':'1.0',
	'FlankDamageMult':'1.15',
	'BackDamageMult':'1.3',
	'PenetrationEnergy':'0',
	'PDamageFactor':'0.500000',
	'RunningSpeedThreshold':'1000.000000',
	'HookStopFactor':'0.0',
	'HookPullForce':'0.0',
	'SpreadMode':'FSM_Rectangle',
	'MuzzleFlashClass':'None',
	'FlashScaleFactor':'1.0',
	'FireSound':'(Volume=1.000000,Radius=512.000000,Pitch=1.000000,bNoOverride=True)',
	'Recoil':'0',
	'Chaos':'0',
	'PushbackForce':'0',
	'MomentumTransfer':'0',
	'Inaccuracy':'(X=0,Y=0)',
	'SplashDamage':'False',
	'RecommendSplashDamage':'False',
	'BotRefireRate':'0.95',
	'WarnTargetPct':'0.0'
}
defaultFireDataDict = {
	'FireInterval':'0.5',
	'AmmoPerFire':'1',
	'PreFireTime':'0.0',
	'MaxHoldTime':'0',
	'TargetState':'',
	'ModeName':'',
	'MaxFireCount':'0',
	'BurstFireRateFactor':'0.66',
	'bCockAfterFire':'False',
	'PreFireAnim':'"PreFire"',
	'FireAnim':'"Fire"',
	'FireLoopAnim':'"FireLoop"',
	'FireEndAnim':'"FireEnd"',
	'AimedFireAnim':'',
	'PreFireAnimRate':'1.0',
	'FireAnimRate':'1.0',
	'FireLoopAnimRate':'1.0',
	'FireEndAnimRate':'1.0'
}
defaultFireEffectDict = {
	'SpreadMode':'FSM_Rectangle',
	'MuzzleFlashClass':'None',
	'FlashScaleFactor':'1.0',
	'FireSound':'(Volume=1.000000,Radius=512.000000,Pitch=1.000000,bNoOverride=True)',
	'Recoil':'0',
	'Chaos':'0',
	'PushbackForce':'0',
	'Inaccuracy':'(X=0,Y=0)',
	'SplashDamage':'False',
	'RecommendSplashDamage':'False',
	'BotRefireRate':'0.95',
	'WarnTargetPct':'0.0'
}
defaultRecoilDict = {
	'XCurve': '(Points=(,(InVal=1.000000)))',
	'YCurve': '(Points=(,(InVal=1.000000,OutVal=1.000000)))',
	'PitchFactor': '1.000000',
	'YawFactor': '1.000000',
	'XRandFactor': '0.000000',
	'YRandFactor': '0.000000',
	'MaxRecoil': '4096.000000',
	'DeclineTime': '2.000000',
	'DeclineDelay': '0.300000',
	'ViewBindFactor': '1.000000',
	'ADSViewBindFactor': '1.000000',
	'HipMultiplier': '1.600000',
	'CrouchMultiplier': '0.750000',
	'bViewDecline': 'False'
}
defaultAimDict = {
	'AimSpread': '(Min=16,Max=128)',
	'AimAdjustTime': '0.500000',
	'OffsetAdjustTime': '0.300000',
	'CrouchMultiplier': '0.800000',
	'ADSMultiplier': '1.000000',
	'ViewBindFactor': '0.000000',
	'SprintChaos': '0.100000',
	'AimDamageThreshold': '100',
	'ChaosDeclineTime': '0.640000',
	'ChaosDeclineDelay': '0.000000',
	'ChaosSpeedThreshold': '500.000000'
}
defaultWeaponDict = {
	'PlayerSpeedFactor': '1.000000',
	'PlayerJumpFactor': '1.000000',
	'InventorySize': '12',
	'SightMoveSpeedFactor': '0.900000',
	'SightingTime': '0.350000',
	'DisplaceDurationMult': '1.000000',
	'MagAmmo': '30',
	'SightOffset': '(X=0,Y=0,Z=0)',
	'SightPivot':'(Pitch=0,Yaw=0,Roll=0)',
	'ZoomType': 'ZT_Irons'
}


def createOutputString(paramsDict, version):
	if version == 0 or version == 1:
		gametypeString = 'Classic'
	elif version == 2:
		gametypeString = 'Arena'
	elif version == 3:
		gametypeString = 'Realistic'
	elif version == 4:
		gametypeString = 'Horde'
	else:
		gametypeString = 'Test'
	
	outputStringRecoil = '''
	//=================================================================
	// RECOIL
	//=================================================================

	Begin Object Class=RecoilParams Name='''+gametypeString+'''RecoilParams'''
	for property in defaultRecoilDict:
		if not noDefaults or defaultRecoilDict.get(property) != paramsDict.get(property):
			outputStringRecoil += '\n\t\t' + property + '=' + str(paramsDict.get(property))
	outputStringRecoil +='\n\tEnd Object'


	outputStringAim = '''
	//=================================================================
	// AIM
	//=================================================================

	Begin Object Class=AimParams Name='''+gametypeString+'''AimParams'''
	paramsDict['ViewBindFactor'] = paramsDict.get('ViewBindFactor2') #duplicate workaround
	for property in defaultAimDict:
		if not noDefaults or defaultAimDict.get(property) != paramsDict.get(property):
			outputStringAim += '\n\t\t' + property + '=' + str(paramsDict.get(property))
	outputStringAim +='\n\tEnd Object'

	outputStringBasic = '''    
	//=================================================================
	// BASIC PARAMS
	//=================================================================	
	
	Begin Object Class=WeaponParams Name='''+gametypeString+'''Params'''
	for property in defaultWeaponDict:
		if not noDefaults or defaultWeaponDict.get(property) != paramsDict.get(property):
			outputStringBasic += '\n\t\t' + property + '=' + str(paramsDict.get(property))
	outputStringBasic += '''
		RecoilParams(0)=RecoilParams\''''+gametypeString+'''RecoilParams'
		AimParams(0)=AimParams\''''+gametypeString+'''AimParams'
		FireParams(0)=FireParams\''''+gametypeString+'''PrimaryFireParams'
		AltFireParams(0)=FireParams\''''+gametypeString+'''SecondaryFireParams'
	End Object
	Layouts(0)=WeaponParams\''''+gametypeString+'''Params\'\n\n'''

	return outputStringRecoil + "\n" + outputStringAim + "\n" + outputStringBasic

def createFiremodeOutputString(paramsDict, fireModeNum, version):

	gametypeString = ''
	firemodeNumberString = ''
	
	if not paramsDict:
		return ''
	
	firemodeType =  paramsDict.get("firemodeType")
		
	if version == 0 or version == 1:
		gametypeString = 'Classic'
	elif version == 2:
		gametypeString = 'Arena'
	elif version == 3:
		gametypeString = 'Realistic'
		
	if fireModeNum == 0:
		firemodeNumberString = 'Primary'
	else:
		firemodeNumberString = 'Secondary'
		
	effectString = '''
    //=================================================================
    // '''+firemodeNumberString.upper()+''' FIRE
    //=================================================================	
	
	'''
	if firemodeType == 0: #Instant fire
		effectString += '''
		Begin Object Class=InstantEffectParams Name='''+gametypeString+firemodeNumberString+'''EffectParams'''
		for property in defaultInstantDict:
			if not noDefaults or defaultInstantDict.get(property) != paramsDict.get(property):
				effectString += '\n\t\t\t' + property + '=' + str(paramsDict.get(property))
		effectString += '''
		End Object

		Begin Object Class=FireParams Name='''+gametypeString+firemodeNumberString+'''FireParams'''
		for property in defaultFireDataDict:
			if not noDefaults or defaultFireDataDict.get(property) != paramsDict.get(property):
				effectString += '\n\t\t\t' + property + '=' + str(paramsDict.get(property))
		effectString += '''	
		FireEffectParams(0)=InstantEffectParams\''''+gametypeString+firemodeNumberString+'''EffectParams\'
		End Object
		'''
	elif firemodeType == 1 or firemodeType == 4: #Projectile fire and grenade fire
		effectString += '''
		Begin Object Class=ProjectileEffectParams Name='''+gametypeString+firemodeNumberString+'''EffectParams'''
		for property in defaultProjectileDict:
			if not noDefaults or defaultProjectileDict.get(property) != paramsDict.get(property):
				effectString += '\n\t\t\t' + property + '=' + str(paramsDict.get(property))
		effectString += '''	
		End Object

		Begin Object Class=FireParams Name='''+gametypeString+firemodeNumberString+'''FireParams'''
		for property in defaultFireDataDict:
			if not noDefaults or defaultFireDataDict.get(property) != paramsDict.get(property):
				effectString += '\n\t\t\t' + property + '=' + str(paramsDict.get(property))
		effectString += '''	
		FireEffectParams(0)=ProjectileEffectParams\''''+gametypeString+firemodeNumberString+'''EffectParams\'
		End Object
		'''
	elif firemodeType == 2: #Shotgun fire
		effectString += '''
		Begin Object Class=ShotgunEffectParams Name='''+gametypeString+firemodeNumberString+'''EffectParams'''
		for property in defaultShotgunDict:
			if not noDefaults or defaultShotgunDict.get(property) != paramsDict.get(property):
				effectString += '\n\t\t\t' + property + '=' + str(paramsDict.get(property))
		effectString += '''	
		End Object

		Begin Object Class=FireParams Name='''+gametypeString+firemodeNumberString+'''FireParams'''
		for property in defaultFireDataDict:
			if not noDefaults or defaultFireDataDict.get(property) != paramsDict.get(property):
				effectString += '\n\t\t\t' + property + '=' + str(paramsDict.get(property))
		effectString += '''	
			FireEffectParams(0)=ShotgunEffectParams\''''+gametypeString+firemodeNumberString+'''EffectParams\'
		End Object
		'''
	elif firemodeType == 3: #Melee fire
		effectString += '''
		Begin Object Class=MeleeEffectParams Name='''+gametypeString+firemodeNumberString+'''EffectParams'''
		for property in defaultMeleeDict:
			if not noDefaults or defaultMeleeDict.get(property) != paramsDict.get(property):
				effectString += '\n\t\t\t' + property + '=' + str(paramsDict.get(property))
		effectString += '''
		End Object
		
		Begin Object Class=FireParams Name='''+gametypeString+firemodeNumberString+'''FireParams'''
		for property in defaultFireDataDict:
			if not noDefaults or defaultFireDataDict.get(property) != paramsDict.get(property):
				effectString += '\n\t\t\t' + property + '=' + str(paramsDict.get(property))
		effectString += '''
			FireEffectParams(0)=MeleeEffectParams\''''+gametypeString+firemodeNumberString+'''EffectParams\'
		End Object
		'''
	elif firemodeType == 5: #Other fire
		effectString += '''
		Begin Object Class=FireEffectParams Name='''+gametypeString+firemodeNumberString+'''EffectParams'''
		for property in defaultFireEffectDict:
			if not noDefaults or defaultFireEffectDict.get(property) != paramsDict.get(property):
				effectString += '\n\t\t\t' + property + '=' + str(paramsDict.get(property))
		effectString += '''
		End Object
		
		Begin Object Class=FireParams Name='''+gametypeString+firemodeNumberString+'''FireParams'''
		for property in defaultFireDataDict:
			if not noDefaults or defaultFireDataDict.get(property) != paramsDict.get(property):
				effectString += '\n\t\t\t' + property + '=' + str(paramsDict.get(property))
		effectString += '''
			FireEffectParams(0)=FireEffectParams\''''+gametypeString+firemodeNumberString+'''EffectParams\'
		End Object
		'''
	return effectString
	
	
def setDefaultParams(version):
	paramsDict = {}
	if version == 0 or version == 1:
		#recoil params
		paramsDict['RecoilXCurve'] = '(Points=(,(InVal=1.000000,OutVal=1.000000)))'
		paramsDict['RecoilYCurve'] = '(Points=(,(InVal=1.000000,OutVal=1.000000)))'
		paramsDict['RecoilPitchFactor'] = '1.000000'
		paramsDict['RecoilYawFactor'] = '1.000000'
		paramsDict['RecoilXFactor'] = '0.500000'
		paramsDict['RecoilYFactor'] = '0.500000'
		paramsDict['RecoilMax'] = '2048.000000'
		paramsDict['RecoilDeclineTime'] = '2.000000'
		paramsDict['RecoilDeclineDelay'] = '0.300000'
		paramsDict['ViewRecoilFactor'] = '0.500000'
		paramsDict['CrouchAimFactor'] = '0.700000'
		paramsDict['HipMultiplier'] = '1.000000'
		paramsDict['bViewDecline'] = 'True'
		#aim params
		paramsDict['AimSpread'] = '(X=(Min=-16.000000,Max=16.000000),Y=(Min=-16.000000,Max=16.000000))'
		paramsDict['ChaosAimSpread'] = '(X=(Min=-2560.000000,Max=2560.000000),Y=(Min=-2560.000000,Max=2560.000000))'
		paramsDict['AimAdjustTime'] = '0.500000'
		paramsDict['CrouchAimFactor'] = '0.700000'
		paramsDict['SightAimFactor'] = '0.700000'
		paramsDict['ViewAimFactor'] = '0.500000'
		paramsDict['SprintChaos'] = '0.400000'
		paramsDict['AimDamageThreshold'] = '100'
		paramsDict['ChaosDeclineTime'] = '2.000000'
		paramsDict['ChaosSpeedThreshold'] = '500.000000'
		paramsDict['ChaosDeclineDelay'] = '0.000000'
		paramsDict['OffsetAdjustTime'] = '0.300000'
		#basic params
		paramsDict['MagAmmo'] = '30'
		paramsDict['InventorySize'] = '35'
		paramsDict['SightOffset'] = '(X=0,Y=0,Z=0)'
		paramsDict['SightPivot'] = '(Pitch=0,Yaw=0,Roll=0)'
		paramsDict['PlayerSpeedFactor'] = '1.000000'
		paramsDict['PlayerJumpFactor'] = '1.000000'
		paramsDict['DisplaceDurationMult'] = '1.000000'
		paramsDict['SightingTime'] = '0.350000'
		paramsDict['SightMoveSpeedFactor'] = '0.500000'
		paramsDict['ZoomType'] = 'ZT_Irons'
	elif version == 2:
		#recoil params
		paramsDict = defaultRecoilDict.copy()
		#aim params
		paramsDict = paramsDict.copy() | defaultAimDict.copy()
		#basic params
		paramsDict = paramsDict.copy() | defaultWeaponDict.copy()
	return paramsDict

def setDefaultFiremodeParams(firemodeType, version):
	paramsDict = {}
	#stock/fix
	if version == 0 or version == 1:
		# fire effect params
		paramsDict['FireSpreadMode'] = 'FSM_Rectangle'
		paramsDict['MuzzleFlashClass'] = 'None'
		paramsDict['FlashScaleFactor'] = '1.0'
		paramsDict['BallisticFireSound'] = '(Volume=1.000000,Radius=255.000000,Pitch=1.000000,bNoOverride=True)'
		paramsDict['RecoilPerShot'] = '0.0'
		paramsDict['FireChaos'] = '-1.0'
		paramsDict['PushbackForce'] = '0'
		paramsDict['XInaccuracy'] = '0.0'
		paramsDict['YInaccuracy'] = '0.0'
		paramsDict['bSplashDamage'] = 'False'
		paramsDict['bRecommendSplashDamage'] = 'False'
		paramsDict['BotRefireRate'] = '0.95'
		paramsDict['WarnTargetPct'] = '0.0'
		# fire data params
		paramsDict['FireRate'] = '0.5'
		paramsDict['AmmoPerFire'] = '1'
		paramsDict['PreFireTime'] = '0.0'
		paramsDict['MaxHoldTime'] = '0'
		paramsDict['TargetState'] = ''
		paramsDict['ModeName'] = ''
		paramsDict['MaxFireCount'] = '0'
		paramsDict['BurstFireRateFactor'] = '1.00'
		paramsDict['bCockAfterFire'] = 'False'
		paramsDict['PreFireAnim'] = '"PreFire"'
		paramsDict['FireAnim'] = '"Fire"'
		paramsDict['FireLoopAnim'] = '"FireLoop"'
		paramsDict['FireEndAnim'] = '"FireEnd"'
		paramsDict['AimedFireAnim'] = ''
		paramsDict['PreFireAnimRate'] = '1.0'
		paramsDict['FireAnimRate'] = '1.0'
		paramsDict['FireLoopAnimRate'] = '1.0'
		paramsDict['FireEndAnimRate'] = '1.0'
		if firemodeType == 0 or firemodeType == 2 or firemodeType == 3:
			#instant fire params
			paramsDict['TraceRange'] = '(Min=5000.000000,Max=5000.000000)'
			paramsDict['WaterTraceRange'] = '5000.0'
			paramsDict['DecayRange'] = '(Min=0.0,Max=0.0)'
			paramsDict['RangeAtten'] = '1.0'
			paramsDict['Damage'] = '0'
			paramsDict['HeadMult'] = '2.0'
			paramsDict['LimbMult'] = '0.5'
			paramsDict['DamageType'] = 'None'
			paramsDict['DamageTypeHead'] = 'None'
			paramsDict['DamageTypeArm'] = 'None'
			paramsDict['UseRunningDamage'] = 'False'
			paramsDict['RunningSpeedThreshold'] = '300'
			paramsDict['MaxWallSize'] = '0'
			paramsDict['PenetrateForce'] = '0'
			paramsDict['bPenetrate'] = 'False'
			paramsDict['PDamageFactor'] = '0.6'
			paramsDict['WallPDamageFactor'] = '0.4'
			paramsDict['MomentumTransfer'] = '0'
			paramsDict['HookStopFactor'] = '0.0'
			paramsDict['HookPullForce'] = '0.0'
		if firemodeType == 1:
			#projectile fire params
			paramsDict['ERadiusFallOffType'] = 'RFO_Linear'
			paramsDict['ProjectileClass'] = 'None'
			paramsDict['SpawnOffset'] = '(X=0,Y=0,Z=0)'
			paramsDict['Speed'] = '0'
			paramsDict['MaxSpeed'] = '0.000000'
			paramsDict['AccelSpeed'] = '0'
			paramsDict['Damage'] = '0'
			paramsDict['DamageHead'] = '0'
			paramsDict['DamageLimb'] = '0'
			paramsDict['DamageRadius'] = '0.000000'
			paramsDict['MomentumTransfer'] = '0'
			paramsDict['HeadMult'] = '2.000000'
			paramsDict['LimbMult'] = '0.500000'
			paramsDict['MaxDamageGainFactor'] = '0'
			paramsDict['DamageGainStartTime'] = '0'
			paramsDict['DamageGainEndTime'] = '0'
			paramsDict['WarnTargetPct'] = '0.500000'
			#shotgun fire params
			paramsDict['TracerChance'] = '0.500000'
			paramsDict['TraceRange'] = '(Min=500.000000,Max=2000.000000)'
			paramsDict['TraceCount'] = '0'
			paramsDict['TracerClass'] = 'None'
			paramsDict['ImpactManager'] = 'None'
			paramsDict['bDoWaterSplash'] = 'false'
			paramsDict['MaxHits'] = '0'
			paramsDict['HeadMult'] = '1.8'
			paramsDict['LimbMult'] = '0.24'
			paramsDict['MaxWallSize'] = '16.000000'
			paramsDict['MaxWalls'] = '2'
			paramsDict['bPenetrate'] = 'False'
			paramsDict['FireSpreadMode'] = 'FSM_Scatter'
			paramsDict['ShotTypeString'] = 'shots'
		if firemodeType == 3:
			#melee fire params
			paramsDict['TraceRange'] = '(Min=128.000000,Max=128.000000)'
			paramsDict['Damage'] = '50.000000'
			paramsDict['HeadMult'] = '1.0'
			paramsDict['LimbMult'] = '1.0'
			paramsDict['RangeAtten'] = '1.0'
			paramsDict['ChargeDamageBonusFactor'] = '1'
			paramsDict['FlankDamageMult'] = '1.15'
			paramsDict['BackDamageMult'] = '1.3'
			paramsDict['MaxWallSize'] = '0.000000'
			paramsDict['PDamageFactor'] = '0.500000'
			paramsDict['RunningSpeedThreshold'] = '1000.000000'
		if firemodeType == 4:
			#grenade fire params
			paramsDict['ERadiusFallOffType'] = 'RFO_Linear'
			paramsDict['ProjectileClass'] = 'None'
			paramsDict['SpawnOffset'] = '(X=0,Y=0,Z=0)'
			paramsDict['Speed'] = '1000'
			paramsDict['MaxSpeed'] = '0.000000'
			paramsDict['AccelSpeed'] = '0'
			paramsDict['Damage'] = '70'
			paramsDict['DamageHead'] = '0'
			paramsDict['DamageLimb'] = '0'
			paramsDict['DamageRadius'] = '240.000000'
			paramsDict['MomentumTransfer'] = '75000'
			paramsDict['HeadMult'] = '2.000000'
			paramsDict['LimbMult'] = '0.500000'
			paramsDict['MaxDamageGainFactor'] = '0'
			paramsDict['DamageGainStartTime'] = '0'
			paramsDict['DamageGainEndTime'] = '0'
			paramsDict['WarnTargetPct'] = '0.500000'
	#pro
	elif version == 2:
		# fire data params
		paramsDict = defaultFireDataDict.copy()
		#instant fire params
		if firemodeType == 0 or firemodeType == 2 or firemodeType == 3:
			paramsDict = paramsDict.copy() | defaultInstantDict.copy()
		#projectile fire params
		if firemodeType == 1 or firemodeType == 4:
			paramsDict = paramsDict.copy() | defaultProjectileDict.copy()
		#shotgun fire params
		if firemodeType == 2:
			paramsDict = paramsDict.copy() | defaultShotgunDict.copy()
		#melee fire params
		if firemodeType == 3:
			paramsDict = paramsDict.copy() | defaultMeleeDict.copy()
	return paramsDict
	
#convert variable format from stock/fix to pro
def updateFiremodeVariableData(firemodeDict, firemodeType, version):
	if version == 2:
		firemodeDict['Recoil'] = firemodeDict.get("FireRecoil")
		firemodeDict['Chaos'] = firemodeDict.get("FireChaos")
		firemodeDict['FireInterval'] = firemodeDict.get("FireRate")
		if 'Damage' in firemodeDict:
			firemodeDict['Damage'] = int(float(firemodeDict.get("Damage")))		
		return firemodeDict
	
	if not firemodeType == 5: #convert damage and pen for regular fire types only
		if "DamageRange" in firemodeDict: 
			scanString="DamageRange"
		else:
			scanString="Damage"
			
		#Damage
		if 'Max=' in firemodeDict.get(scanString): #protect against incorrect version user input
			damageString = str(firemodeDict.get(scanString))
			damageMin = damageString[damageString.find('Min=')+4:damageString.find(',')].strip()
			damageMax = damageString[damageString.find('Max=')+4:damageString.find(')')].strip()
			try:
				convertedDamage = (float(damageMin)+float(damageMax))//2
				firemodeDict['Damage'] = convertedDamage
			except ValueError:
				firemodeDict['Damage'] = 0
			
			damageString = str(firemodeDict.get(scanString+"Head"))
			damageMin = damageString[damageString.find('Min=')+4:damageString.find(',')].strip()
			damageMax = damageString[damageString.find('Max=')+4:damageString.find(')')].strip()
			try:
				convertedDamageHead = (float(damageMin)+float(damageMax))//2
				headMultiplier = str(convertedDamageHead/convertedDamage)[:8]
			except ValueError:
				headMultiplier = 1.0
			firemodeDict['HeadMult'] = headMultiplier
			
			damageString = str(firemodeDict.get(scanString+"Limb"))
			damageMin = damageString[damageString.find('Min=')+4:damageString.find(',')].strip()
			damageMax = damageString[damageString.find('Max=')+4:damageString.find(')')].strip()
			try:
				convertedDamageLimb = (float(damageMin)+float(damageMax))//2
				limbMultiplier = str(convertedDamageLimb/convertedDamage)[:8]
			except ValueError:
				limbMultiplier = 1.0
			firemodeDict['LimbMult'] = limbMultiplier
			
		elif float(firemodeDict.get('Damage')) != 0:
			if float(firemodeDict.get('DamageHead')) != 0:
				firemodeDict['HeadMult'] = str(float(firemodeDict.get("DamageHead"))/float(firemodeDict.get('Damage')))[:8]
			else:
				firemodeDict['HeadMult'] = 1.0
			if float(firemodeDict.get('DamageLimb')) != 0:
				firemodeDict['LimbMult'] = str(float(firemodeDict.get("DamageLimb"))/float(firemodeDict.get('Damage')))[:8]
			else:
				firemodeDict['LimbMult'] = 1.0
			
		if not firemodeType == 1 and not firemodeType == 4:
			#water and walls
			traceRangeString = str(firemodeDict.get("TraceRange"))
			traceRangeMax = traceRangeString[traceRangeString.find('Max=')+4:traceRangeString.find(')')].strip()
			if firemodeDict.get("WaterRangeFactor") != None:
				waterTraceRange = float(traceRangeMax)*float(firemodeDict.get("WaterRangeFactor"))
				firemodeDict['WaterTraceRange'] = waterTraceRange
			firemodeDict['PenetrationEnergy'] = firemodeDict.get("MaxWallSize")
	
	#basic ones
	firemodeDict['Recoil'] = firemodeDict.get("RecoilPerShot")
	firemodeDict['Chaos'] = firemodeDict.get("FireChaos")
	try:
		#firemodeDict['Inaccuracy'] = '''(X=''' + str(int(firemodeDict.get("XInaccuracy"))) + ''',Y=''' + str(int(firemodeDict.get("YInaccuracy"))) + ''')'''
		firemodeDict['Inaccuracy'] = '(X={},Y={})'.format(int(float(firemodeDict.get("XInaccuracy"))),int(float(firemodeDict.get("YInaccuracy"))))
	except ValueError:
		firemodeDict['Inaccuracy'] = '(X=0,Y=0)'
	firemodeDict['FireSound'] = firemodeDict.get("BallisticFireSound")
	firemodeDict['SplashDamage'] = firemodeDict.get("bSplashDamage")
	firemodeDict['RecommendSplashDamage'] = firemodeDict.get("bRecommendSplashDamage")
	firemodeDict['FireInterval'] = firemodeDict.get("FireRate")
		
	return firemodeDict
		
#convert variable format from stock/fix to pro
def updateVariableData(paramsDict, version):
	if version == 1 or version == 0:
		#aimspread
		aimString = str(paramsDict.get("AimSpread"))
		chaosAimString = str(paramsDict.get("ChaosAimSpread"))
		aimMax = aimString[aimString.find('Max=')+4:aimString.find(')')].strip()
		chaosAimMax = chaosAimString[chaosAimString.find('Max=')+4:chaosAimString.find(')')].strip()
		paramsDict['AimSpread']='(Min={},Max={})'.format(int(float(aimMax)),int(float(chaosAimMax))) #dont judge me
		
		#basic ones
		paramsDict['XCurve'] = paramsDict.get("RecoilXCurve")
		paramsDict['YCurve'] = paramsDict.get("RecoilYCurve")
		paramsDict['PitchFactor'] = paramsDict.get("RecoilPitchFactor")
		paramsDict['YawFactor'] = paramsDict.get("RecoilYawFactor")
		paramsDict['XRandFactor'] = paramsDict.get("RecoilXFactor")
		paramsDict['YRandFactor'] = paramsDict.get("RecoilYFactor")
		paramsDict['MaxRecoil'] = paramsDict.get("RecoilMax")
		paramsDict['DeclineTime'] = paramsDict.get("RecoilDeclineTime")
		paramsDict['DeclineDelay'] = paramsDict.get("RecoilDeclineDelay")
		paramsDict['ViewBindFactor'] = paramsDict.get("ViewRecoilFactor")
		paramsDict['ADSViewBindFactor'] =paramsDict.get("ViewRecoilFactor")
		paramsDict['CrouchMultiplier'] = paramsDict.get("CrouchAimFactor")
		paramsDict['ADSMultiplier'] = paramsDict.get("SightAimFactor")
		paramsDict['ViewBindFactor2'] = paramsDict.get("ViewAimFactor") #dict's cant's store multiples
		if 'bNoMeshInScope' in paramsDict and 'ZoomType' not in paramsDict and paramsDict.get("bNoMeshInScope") == True:
			paramsDict['ZoomType'] = paramsDict.get("ZT_Smooth")
			
		
	
#check supertype, return supertype
def extractFileFiremodeType(data):
	if data.find('InstantFire') != -1 or data.find('RangeAttenFire') != -1:
		firemodeType=0
	elif data.find('ProjectileFire') != -1:
		firemodeType=1
	elif data.find('ShotgunFire') != -1:
		firemodeType=2
	elif data.find('MeleeFire') != -1:
		firemodeType=3
	elif data.find('GrenadeFire') != -1:
		firemodeType=4
	else:
		firemodeType=5 #wtf are you feeding me?? scopefires?!
	return firemodeType

#get the params after defaultproperties, return as a dictionary
def extractFileParams(data, paramsDict, filePath):
	if data.find('defaultproperties') != -1:
		defaultParams = data.split("defaultproperties")[1]
		defaultParams = defaultParams[defaultParams.find('{')+1:defaultParams.find('}')]
		for param in defaultParams.strip().split('\n'):
			if param.find('=') != -1:
				paramName = param[:param.find('=')].strip()
				paramValue = param[param.find('=')+1:].strip()
				paramsDict[paramName] = paramValue
		#paramsDict = dict((x.strip(), y.strip()) 
		#         for x, y in (param.split('=')  
		#         for param in dataString.split('\n'))) 
	else:
		print("File " + filePath + " has no default properties")

	#print(paramsDict)
	return paramsDict
	
#try and open the projectile file and grab the params
def processProjectileFile(filePath, inputDict, version):
	processedDict = {}
	projectileClassName = inputDict['ProjectileClass']
	#build file path
	rootFilePath = filePath[:filePath.rfind('\\')]
	filePath = rootFilePath + '\\' + projectileClassName[projectileClassName.find('.')+1:-1] + '.uc'
	if os.path.exists(filePath):
		with open(filePath) as file:
			#initialize
			data = file.read()
			#pull file data
			processedDict = processedDict | extractFileParams(data, inputDict, filePath)
			#convert data to pro
			#processedDict = updateFiremodeVariableData(processedDict, firemodeType, version)
	else:
		print(filePath + ": Unable to find projectile class.")
		return inputDict
	return processedDict
	
#try and open the firemodes and grab the params
def processFiremodeFile(filePath, firemodeClassName, version):
	processedDict = {}
	#build file path
	rootFilePath = filePath[:filePath.rfind('\\')]
	filePath = rootFilePath + '\\' + firemodeClassName[firemodeClassName.find('.')+1:-1] + '.uc'
	if os.path.exists(filePath):
		with open(filePath) as file:
			#initialize
			data = file.read()
			firemodeType = extractFileFiremodeType(data)
			defaultDict = setDefaultFiremodeParams(firemodeType, version)
			#pull file data
			processedDict = extractFileParams(data, defaultDict, filePath)
			processedDict['firemodeType'] = firemodeType
			#pull projectile data if applicable
			if firemodeType == 1 or firemodeType == 4:
				processedDict = processProjectileFile(filePath, processedDict, version)
			#convert data to pro
			processedDict = updateFiremodeVariableData(processedDict, firemodeType, version)
	else:
		print(filePath + ": Unable to find firemode class.")
	return processedDict
	
#process the file, it's firemodes and return the params as a dict
def processBaseFile(filePath, version):
	outputString = ""
	if os.path.exists(filePath):
		with open(filePath) as file:
			#initialize
			print(filePath)
			standardDict = setDefaultParams(version)
			#update
			processedDict = extractFileParams(file.read(), standardDict, filePath) 
			#grab firemodes
			if "FireModeClass(0)" and "FireModeClass(1)" in processedDict:
				firemodeOneDict = processFiremodeFile(filePath, processedDict["FireModeClass(0)"], version)
				firemodeTwoDict = processFiremodeFile(filePath, processedDict["FireModeClass(1)"], version)
				#convert
				updateVariableData(processedDict, version)
				#write
				outputString += createFiremodeOutputString(firemodeOneDict, 0, version)
				outputString += createFiremodeOutputString(firemodeTwoDict, 1, version)
				outputString += createOutputString(processedDict, version)
			else: 
				return "//Data Process Failure\n"
			return outputString
	else:
		print(filePath + " is not a valid path.")
		return "//Data Process Failure\n"
		
#for each thing in CSV
def parseCSVFile(csvFile, version):
	outputData = ""
	with open(csvFile) as file:
		reader = csv.reader(file)
		for row in reader:
			if createMultFiles:
				rowString = str(row)
				rowStringMod = rowString[rowString.rfind('\\')+1:rowString.find('.')]
				outputData = "class "+ rowStringMod +"WeaponParamsClassic extends BallisticWeaponParams;\n\ndefaultproperties\n{\n"
				outputData += processBaseFile(row[0], version)
				f = open(rowStringMod+"WeaponParamsClassic.uc", "w")
				f.write(outputData + "\n}")
			else:
				outputData += "//========================== "+ str(row)+" ==============\n//\n"
				outputData += processBaseFile(row[0], version)

	return outputData

#MAIN METHOD
if createMultFiles:
	parseCSVFile(csvFile, version)
else:
	f = open("parserOutput.uc", "w")
	f.write(parseCSVFile(csvFile, version))