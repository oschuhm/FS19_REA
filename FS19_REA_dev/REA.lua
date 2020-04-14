--
-- REA Script
-- author: 900Hasse
-- date: 30.07.2019
--
-- V1.2.0.0
--
-----------------------------------------
-- TO DO
---------------
-- 
-- Remake combine power need?
-- Can centor of gravity be calculated
-- User help when pushing a button
-- Turn on/off GUI
-- 


-----------------------------------------
-- KNOWN ISSUES
---------------
-- Combines harvesters get to high power demand on cutter turning the combine off?
-- Extreme load on small wheels can get vehicles into spin
-- 	

print("---------------------------")
print("----- REA by 900Hasse -----")
print("---------------------------")
REA = {};

function REA.prerequisitesPresent(specializations)
    return true
end;

function REA:loadMap(name)
end

function REA:deleteMap()
end

function REA:draw(dt)
end;

function REA:update(dt)

	-- If Client draw vehicle status on GUI
	local UseGUI = true;
	if g_client and not g_gui:getIsGuiVisible() and UseGUI then
		-- Check number of vehicles
		numVehicles = table.getn(g_currentMission.vehicles);
		-- If vehicles present run code
		if numVehicles ~= nil then
			-- Run code for vehicles
			if numVehicles >= 1 then
				-- Search for controlled vehicle
				for VehicleIndex=1, numVehicles do
					-- Save "vehicle" to local
					local vehicle = g_currentMission.vehicles[VehicleIndex];			
					-- Check if current vehicle exists
					if vehicle ~= nil then
						if vehicle.spec_motorized then
							if vehicle.spec_wheels ~= nil then	
								if vehicle:getIsControlled() then
									if g_currentMission.controlledVehicle == vehicle then
										REA:DrawStatus(vehicle,dt);
										break
									end;
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	end;

	-- If server run code for vehicles
	if g_server ~= nil then
		-- Save global values
		if REA.GlobalValuesSet ~= true then

			-- TireType sink parameters
			REA.TireTypeMaxSinkFrictionReduced = {1,1,1,1};
			REA.TireTypeSinkStuckLevel = {1,1,1,1};
			REA.TireTypeMinRollingCoeff = {1,1,1,1};
			REA.TireTypeSinkPerMeterSpinning = {0.1,0.1,0.1,0.1};

			-- Friction multipliers for implements
			REA.PlowMultiplier = {1,1,1,1,1,1};
			REA.CultivatorMultiplier = {1,1,1,1,1,1};
			REA.SowingMachineMultiplier = {1,1,1,1,1,1};
			-- Speed adjustments for implements
			REA.PlowSpeedAjust = {0,0,0,0,0,0};
			REA.CultivatorSpeedAjust = {0,0,0,0,0,0};
			REA.SowingMachineSpeedAjust = {0,0,0,0,0,0};

			-- Tiretypes
			local TireTypeMUD = 1;
			local TireTypeOFFROAD = 2;
			local TireTypeSTREET = 3;
			local TireTypeCRAWLER = 4;

			-- Groundtypes
			local ROAD = 1;
			local HARD_TERRAIN = 2;
			local SOFT_TERRAIN = 3;
			local FIELD = 4;

			-- Terrain values
			local Road = 0 -- Road
			local Cultivated = 1 -- Cultivated
			local Plowed = 2 -- Plowed
			local HarvestedSowed = 3 -- Harvested or sowed
			local RootCrops = 4 -- Rootcrops
			local Grass = 5 -- Grass

			-----------------------------------------------------------------------------------
			-- Global settings of wheel tiretypes and friction
			-----------------------------------------------------------------------------------
			-- Max sink of rootcrpos
			Wheels.MAX_SINK[RootCrops] = 0.1;
			-- Factor max sink of wheel based on radius(original value 0.2)
			REA.WheelRadiusMaxSinkFactor = 0.5;
			-- Sink parameters when wheel in conctact with a lowspot with water (percentage)
			REA.TireTypeMaxSinkFrictionReducedLowSpot = 100;
			REA.TireTypeSinkStuckLevelLowSpot = 75;
			-------------------------------------
			-- MUD
			-- TireType on different groundtypes
			WheelsUtil.tireTypes[TireTypeMUD].frictionCoeffs[ROAD] = 1.0;
			WheelsUtil.tireTypes[TireTypeMUD].frictionCoeffs[HARD_TERRAIN] = 0.8;
			WheelsUtil.tireTypes[TireTypeMUD].frictionCoeffs[SOFT_TERRAIN] = 0.7;
			WheelsUtil.tireTypes[TireTypeMUD].frictionCoeffs[FIELD] = 0.7;
			WheelsUtil.tireTypes[TireTypeMUD].frictionCoeffsWet[ROAD] = WheelsUtil.tireTypes[TireTypeMUD].frictionCoeffs[ROAD]*0.9;
			WheelsUtil.tireTypes[TireTypeMUD].frictionCoeffsWet[HARD_TERRAIN] = WheelsUtil.tireTypes[TireTypeMUD].frictionCoeffs[HARD_TERRAIN]*0.9;
			WheelsUtil.tireTypes[TireTypeMUD].frictionCoeffsWet[SOFT_TERRAIN] = WheelsUtil.tireTypes[TireTypeMUD].frictionCoeffs[SOFT_TERRAIN]*0.9;
			WheelsUtil.tireTypes[TireTypeMUD].frictionCoeffsWet[FIELD] = WheelsUtil.tireTypes[TireTypeMUD].frictionCoeffs[FIELD]*0.9;
			-- Sink parameters (percentage)
			REA.TireTypeMaxSinkFrictionReduced[TireTypeMUD] = 50;
			REA.TireTypeSinkStuckLevel[TireTypeMUD] = 101;
			REA.TireTypeSinkPerMeterSpinning[TireTypeMUD] = 0.05;
			-- Min rolling coefficient
			REA.TireTypeMinRollingCoeff[TireTypeMUD] = 0.04;
			-------------------------------------
			-- OFFROAD
			-- TireType on different groundtypes
			WheelsUtil.tireTypes[TireTypeOFFROAD].frictionCoeffs[ROAD] = 1.25;
			WheelsUtil.tireTypes[TireTypeOFFROAD].frictionCoeffs[HARD_TERRAIN] = 0.9;
			WheelsUtil.tireTypes[TireTypeOFFROAD].frictionCoeffs[SOFT_TERRAIN] = 0.7;
			WheelsUtil.tireTypes[TireTypeOFFROAD].frictionCoeffs[FIELD] = 0.6;
			WheelsUtil.tireTypes[TireTypeOFFROAD].frictionCoeffsWet[ROAD] = WheelsUtil.tireTypes[TireTypeOFFROAD].frictionCoeffs[ROAD]*0.9;
			WheelsUtil.tireTypes[TireTypeOFFROAD].frictionCoeffsWet[HARD_TERRAIN] = WheelsUtil.tireTypes[TireTypeOFFROAD].frictionCoeffs[HARD_TERRAIN]*0.8;
			WheelsUtil.tireTypes[TireTypeOFFROAD].frictionCoeffsWet[SOFT_TERRAIN] = WheelsUtil.tireTypes[TireTypeOFFROAD].frictionCoeffs[SOFT_TERRAIN]*0.8;
			WheelsUtil.tireTypes[TireTypeOFFROAD].frictionCoeffsWet[FIELD] = WheelsUtil.tireTypes[TireTypeOFFROAD].frictionCoeffs[FIELD]*0.7;
			-- Sink parameters (percentage)
			REA.TireTypeMaxSinkFrictionReduced[TireTypeOFFROAD] = 80;
			REA.TireTypeSinkStuckLevel[TireTypeOFFROAD] = 101;
			REA.TireTypeSinkPerMeterSpinning[TireTypeOFFROAD] = 0.035;
			-- Min rolling coefficient
			REA.TireTypeMinRollingCoeff[TireTypeOFFROAD] = 0.03;
			-------------------------------------
			-- STREET
			-- TireType on different groundtypes
			WheelsUtil.tireTypes[TireTypeSTREET].frictionCoeffs[ROAD] = 1.5;
			WheelsUtil.tireTypes[TireTypeSTREET].frictionCoeffs[HARD_TERRAIN] = 0.7;
			WheelsUtil.tireTypes[TireTypeSTREET].frictionCoeffs[SOFT_TERRAIN] = 0.6;
			WheelsUtil.tireTypes[TireTypeSTREET].frictionCoeffs[FIELD] = 0.55;
			WheelsUtil.tireTypes[TireTypeSTREET].frictionCoeffsWet[ROAD] = WheelsUtil.tireTypes[TireTypeSTREET].frictionCoeffs[ROAD]*0.9;
			WheelsUtil.tireTypes[TireTypeSTREET].frictionCoeffsWet[HARD_TERRAIN] = WheelsUtil.tireTypes[TireTypeSTREET].frictionCoeffs[HARD_TERRAIN]*0.8;
			WheelsUtil.tireTypes[TireTypeSTREET].frictionCoeffsWet[SOFT_TERRAIN] = WheelsUtil.tireTypes[TireTypeSTREET].frictionCoeffs[SOFT_TERRAIN]*0.8;
			WheelsUtil.tireTypes[TireTypeSTREET].frictionCoeffsWet[FIELD] = WheelsUtil.tireTypes[TireTypeSTREET].frictionCoeffs[FIELD]*0.7;
			-- Sink parameters (percentage)
			REA.TireTypeMaxSinkFrictionReduced[TireTypeSTREET] = 95;
			REA.TireTypeSinkStuckLevel[TireTypeSTREET] = 75;
			REA.TireTypeSinkPerMeterSpinning[TireTypeSTREET] = 0.02;
			-- Min rolling coefficient
			REA.TireTypeMinRollingCoeff[TireTypeSTREET] = 0.02;
			-------------------------------------
			-- CRAWLER
			-- TireType on different groundtypes
			WheelsUtil.tireTypes[TireTypeCRAWLER].frictionCoeffs[ROAD] = 1.0;
			WheelsUtil.tireTypes[TireTypeCRAWLER].frictionCoeffs[HARD_TERRAIN] = 1.0;
			WheelsUtil.tireTypes[TireTypeCRAWLER].frictionCoeffs[SOFT_TERRAIN] = 1.0;
			WheelsUtil.tireTypes[TireTypeCRAWLER].frictionCoeffs[FIELD] = 1.0;
			WheelsUtil.tireTypes[TireTypeCRAWLER].frictionCoeffsWet[ROAD] = WheelsUtil.tireTypes[TireTypeCRAWLER].frictionCoeffs[ROAD]*0.7;
			WheelsUtil.tireTypes[TireTypeCRAWLER].frictionCoeffsWet[HARD_TERRAIN] = WheelsUtil.tireTypes[TireTypeCRAWLER].frictionCoeffs[HARD_TERRAIN]*0.8;
			WheelsUtil.tireTypes[TireTypeCRAWLER].frictionCoeffsWet[SOFT_TERRAIN] = WheelsUtil.tireTypes[TireTypeCRAWLER].frictionCoeffs[SOFT_TERRAIN]*0.8;
			WheelsUtil.tireTypes[TireTypeCRAWLER].frictionCoeffsWet[FIELD] = WheelsUtil.tireTypes[TireTypeCRAWLER].frictionCoeffs[FIELD]*0.8;
			-- Sink parameters (percentage)
			REA.TireTypeMaxSinkFrictionReduced[TireTypeCRAWLER] = 30;
			REA.TireTypeSinkStuckLevel[TireTypeCRAWLER] = 101;
			REA.TireTypeSinkPerMeterSpinning[TireTypeCRAWLER] = 0.03;
			-- Min rolling coefficient
			REA.TireTypeMinRollingCoeff[TireTypeCRAWLER] = 0.1;


			-----------------------------------------------------------------------------------
			-- Settings for implement and groundtype
			-----------------------------------------------------------------------------------
			-- Pulling multiplier on different groundtypes
			-- Plow
			REA.PlowMultiplier[Plowed] = 0.7;
			REA.PlowMultiplier[Cultivated] = 0.8;
			REA.PlowMultiplier[RootCrops] = 0.9;
			REA.PlowMultiplier[HarvestedSowed] = 1;
			REA.PlowMultiplier[Grass] = 1.2;
			REA.PlowMultiplier[Road] = 1.3;
			-- Cultivator
			REA.CultivatorMultiplier[Plowed] = 0.7;
			REA.CultivatorMultiplier[Cultivated] = 0.8;
			REA.CultivatorMultiplier[RootCrops] = 0.9;
			REA.CultivatorMultiplier[HarvestedSowed] = 1;
			REA.CultivatorMultiplier[Grass] = 1.3;
			REA.CultivatorMultiplier[Road] = 2;
			-- Sowing machine
			REA.SowingMachineMultiplier[Plowed] = 0.6;
			REA.SowingMachineMultiplier[Cultivated] = 1;
			REA.SowingMachineMultiplier[RootCrops] = 1;
			REA.SowingMachineMultiplier[HarvestedSowed] = 1.2;
			REA.SowingMachineMultiplier[Grass] = 1.4;
			REA.SowingMachineMultiplier[Road] = 2;
			-- Power needed for balers and foragewagons to fill 100l/s for filltype with a mass of 1 ton/m2
			REA.FillspeedPowerNeed = 450;

			-- Global values set
			REA.GlobalValuesSet = true
			print("Global REA variables loaded")
		end;

		-----------------------------------------------------------------------------------
		-- Check if REA.Dynamic dirt is loadad and all map is scanned for low spots
		-----------------------------------------------------------------------------------
		-- Initialize variable for Dynamic dirt
		if REA.DynamicDirtActivated == nil then
			REA.DynamicDirtFound = false;
			REA.DynamicDirtActivated = false;
		end;
		-- Check if Dynamic dirt is loaded and all map scanned
		if not REA.DynamicDirtActivated then
			-- Check if dynamic dirt is loaded
			if not REA.DynamicDirtFound and g_modIsLoaded.FS19_READynamicDirt ~= nil then
				print("REA Dynamic dirt: Found by REA")
				REA.DynamicDirtFound = true;
			end;
			-- If dynamic dirt is loaded wait until all area is scanned before starting functions
			if REA.DynamicDirtFound then
				if WheelsUtil.LowspotScanCompleted ~= nil then
					if WheelsUtil.LowspotScanCompleted then
						print("REA Dynamic dirt: Scan completed detected by REA")
						REA.DynamicDirtActivated = true;
					end;
				end;
			end;
		end;

		-- Determine number of vehicles
		numVehicles = table.getn(g_currentMission.vehicles);
		-- Run wheel functions if vehicles present
		if numVehicles ~= nil then
			if numVehicles >= 1 then		
				-----------------------------------------------------------------------------------	
				-- Add wheel functions
				-----------------------------------------------------------------------------------
				for VehicleIndex=1, numVehicles do
					-- Save "vehicle" local
					local vehicle = g_currentMission.vehicles[VehicleIndex];			
					-- Check if active vehicle
					if vehicle ~= nil then					
						local MotorizedVehicle = false;
						-- If vehicle is motorized save speed to use for shifting gear
						if vehicle.spec_motorized ~= nil then
							if vehicle.spec_motorized.motor ~= nil then
								-- If vehicle is not motorized increase friction to avoid gliding
								MotorizedVehicle = true;
								-- Adjust speed of vehicle if PTO demands more power than motor can give
								if vehicle.spec_motorized.isMotorStarted then
									-- Adjust speed if PTO tourqe reaches high levels
									REA:AdjustSpeedIfPtpPowerMaxed(vehicle,dt);
								end;
							end;
						end;
						-- If vehicle have wheels calculate friction and add rolling resistance
						if vehicle.spec_wheels ~= nil then	
							-- If vehicle is a powerconsumer and rolling resistance should be ignored when implement is working
							local IgnoreRollingResistance = false;
							if vehicle.spec_powerConsumer ~= nil then
								if vehicle.spec_powerConsumer.IgnoreRollingResistance ~= nil then
									IgnoreRollingResistance = vehicle.spec_powerConsumer.IgnoreRollingResistance;
								end;
							end;
							-- Update wheels
							REA:UpdateWheels(vehicle.spec_wheels,vehicle.spec_crawlers,MotorizedVehicle,IgnoreRollingResistance,dt);
						end;
						-- Adjust power need and speed of power consuming vehicle
						REA:UpdatePowerMultiplier(vehicle,dt);
					end;
				end;
			end;
		end;
	end;
end;


-----------------------------------------------------------------------------------	
-- Draw status of vehicle
-----------------------------------------------------------------------------------
function REA:DrawStatus(vehicle,dt)
	-- Used motor
	local motor = vehicle.spec_motorized.motor;

	--------------------------------------------------------------------
	-- Init global variables
	--------------------------------------------------------------------
	if vehicle.timer == nil or vehicle.GUISlip == nil then
		vehicle.timer = 0;
		vehicle.GUIMotorLoad = 0;
		vehicle.GUISlip = 0;
	end;

--	-- Create overlays
--	if REA.OverlaysCreated == nil then
--		REA.overlay = {};
--		-- Transparancy
--		local Transparancy = 0.75;
--		-- Create overlay for slip
--		if REA.overlay["slip"] == nil then
--			REA.overlay["slip"] = createImageOverlay(REA.FilePath .. "media/SLIP_ICON.dds");
--			setOverlayColor(REA.overlay["slip"], 1, 0, 0, Transparancy);
--		end;
--		-- Create overlay for load
--		if REA.overlay["load"] == nil then
--			REA.overlay["load"] = createImageOverlay(REA.FilePath .. "media/LOAD_ICON.dds");
--			setOverlayColor(REA.overlay["load"], 0, 1, 0, Transparancy);
--		end;
--		-- Set overlays created
--		REA.OverlaysCreated = true;
--	end;

--	-- Text settings
--	local FontSize = 0.01;
--	local TextPadding = 0.001;
--	UiScale = 1;
--	if g_gameSettings.uiScale ~= nil then
--		UiScale = g_gameSettings.uiScale;
--	end
--	local Width = ((FontSize + TextPadding) * 1.4 ) * UiScale;
--	local Height = (((FontSize + TextPadding) * 1.4) * 2 ) * UiScale;

--	local posX = 0.5;
--	local posY = 0.5;
--	renderOverlay(REA.overlay["slip"], posX, posY, Width, Height);

--	local posX = 0.5;
--	local posY = 0.8;
--	renderOverlay(REA.overlay["load"], posX, posY, Width, Height);

	--------------------------------------------------------------------
	-- Get engine RPM
	--------------------------------------------------------------------
	-- Get actual RPM
	local RPM = 0;
	if motor.RPMGaugeSmoothed ~= nil then
		RPM = motor.RPMGaugeSmoothed;
	else
		RPM = motor.lastMotorRpm;
	end;
	-- Get min and max RPM
	local minRpm = motor.minRpm;
	local maxRpm = motor.maxRpm;
	-- Calculate RPM percentage
	local PRMPercentage = ((RPM - minRpm) / (maxRpm - minRpm));
	-- Calculate motor load
	local MotorLoad = REA:RoundValue(vehicle.spec_motorized.smoothedLoadPercentage * 100);
	-- Motor load is 0-100%
	if MotorLoad > 100 then
		MotorLoad = 100;
	elseif MotorLoad < 0 then
		MotorLoad = 0;
	end

	--------------------------------------------------------------------
	-- Calculate slip
	--------------------------------------------------------------------
	-- How many wheels do the vehicle have
	local numWheels = table.getn(vehicle.spec_wheels.wheels);
	-- Get speed
	local VehicleSpeed = vehicle:getLastSpeed();
	-- Loop to get average speed of all wheels
	local TotalWheelSpeed = 0;
	for Wheel=1,numWheels do
		-- Save active wheel to local wheel
		local Actwheel = vehicle.spec_wheels.wheels[Wheel];
		-- Get speed of wheel
		-- If speed was not calculated by server calculate speed based on xDrive
		if Actwheel.SpeedBasedOnXdrive == nil then
			TotalWheelSpeed = REA:WheelSpeedFromXdrive(Actwheel,dt) + TotalWheelSpeed;			
		else
			TotalWheelSpeed = Actwheel.SpeedBasedOnXdrive + TotalWheelSpeed;			
		end;
	end;
	-- Smoothe average wheelspeed
	if vehicle.spec_wheels.AverageSpeedSmoothed == nil then
		vehicle.spec_wheels.AverageSpeedSmoothed = 0;
	end;
	vehicle.spec_wheels.AverageSpeedSmoothed = REA:SmootheValue(vehicle.spec_wheels.AverageSpeedSmoothed,TotalWheelSpeed / numWheels);
	-- Calculate slip
	if vehicle.spec_wheels.AverageSpeedSmoothed > 0.2 then
		-- Calculate differance
		local SpeedDiff = math.abs(VehicleSpeed - vehicle.spec_wheels.AverageSpeedSmoothed);
		if SpeedDiff > 0.2 and VehicleSpeed < vehicle.spec_wheels.AverageSpeedSmoothed then
			-- Calculate slip
			local Slip = (SpeedDiff / vehicle.spec_wheels.AverageSpeedSmoothed) * 100;
			vehicle.spec_wheels.SlipSmoothed = REA:RoundValue(REA:SmootheValue(vehicle.spec_wheels.SlipSmoothed,Slip));
		else
			vehicle.spec_wheels.SlipSmoothed = 0;
		end;
	else
		vehicle.spec_wheels.SlipSmoothed = 0;
	end;
	-- Slip is 0-100%
	if vehicle.spec_wheels.SlipSmoothed > 100 then
		vehicle.spec_wheels.SlipSmoothed = 100;
	elseif vehicle.spec_wheels.SlipSmoothed < 0 then
		vehicle.spec_wheels.SlipSmoothed = 0;
	end

	--------------------------------------------------------------------
	-- Uppdate every 100ms
	if vehicle.timer > 100 then
		--------------------------------------------------------------------
		-- slip
		if vehicle.spec_wheels.SlipSmoothed ~= nil then
			vehicle.GUISlip = vehicle.spec_wheels.SlipSmoothed;
		end;
		-- Motor load
		if MotorLoad ~= nil then
			vehicle.GUIMotorLoad = MotorLoad;
		end;
		-- Reset timer
		vehicle.timer = 0;
	end;
	-- Add time
	vehicle.timer = vehicle.timer + dt;

	--------------------------------------------------------------------
	-- Write GUI
	local OffsetSideways = 0.07;
	local TextSize = 0.015;
	local offsetBetweenLines = TextSize * 1.2;
	local HorizontalPosition = 1 - (2*offsetBetweenLines);

	
	-- Draw motor load
	if vehicle.GUIMotorLoad < 10 then
		renderText(OffsetSideways, HorizontalPosition + offsetBetweenLines, TextSize,"Motor load:   " .. vehicle.GUIMotorLoad .. "%");
	elseif vehicle.GUIMotorLoad > 99 then
		renderText(OffsetSideways, HorizontalPosition + offsetBetweenLines, TextSize,"Motor load: " .. vehicle.GUIMotorLoad .. "%");
	else
		renderText(OffsetSideways, HorizontalPosition + offsetBetweenLines, TextSize,"Motor load:  " .. vehicle.GUIMotorLoad .. "%");
	end;
	-- Draw slip
	if vehicle.GUISlip < 10 then
		renderText(OffsetSideways, HorizontalPosition, TextSize,"Slip:   " .. vehicle.GUISlip .. "%");
	elseif vehicle.GUISlip > 99 then
		renderText(OffsetSideways, HorizontalPosition, TextSize,"Slip: " .. vehicle.GUISlip .. "%");
	else
		renderText(OffsetSideways, HorizontalPosition, TextSize,"Slip:  " .. vehicle.GUISlip .. "%");
	end;
end


-----------------------------------------------------------------------------------	
-- Function to calculate friction and add rolling resistance
-----------------------------------------------------------------------------------
function REA:UpdateWheels(spec_wheels,spec_crawlers,MotorizedVehicle,IgnoreRollingResistance,dt)

	-- How many wheels do the vehicle have
	local numWheels = table.getn(spec_wheels.wheels);

	-- Check if wheels added to physics
	if spec_wheels.isAddedToPhysics then

		-- Tiretypes
		local TireTypeMUD = 1;
		local TireTypeOFFROAD = 2;
		local TireTypeSTREET = 3;
		local TireTypeCRAWLER = 4;

		-- Loop to calculate and update fricton, rolling resistance and sideway resistance for each wheel
		for Wheel=1,numWheels do
			-- Save to local variable wheel
			local wheel = spec_wheels.wheels[Wheel];

			-- Check if wheel shape is created
			if wheel.wheelShapeCreated then
				-- Check if crawlertracks and if present in crawler
				local CrawlersFactor = 1;
				if wheel.tireType == TireTypeCRAWLER then
					CrawlersFactor = 0.4;
				end;

				-- Ground types
				local ROAD = 1;
				local HARD_TERRAIN = 2;
				local SOFT_TERRAIN = 3;
				local FIELD = 4;
				-- Get ground type
				local groundType = 0;
				if wheel.densityType ~= nil and wheel.lastColor[4] ~= nil then
					local isOnField = wheel.densityType ~= 0;
					local depth = wheel.lastColor[4];
					groundType = WheelsUtil.getGroundType(isOnField, wheel.contact ~= Wheels.WHEEL_GROUND_CONTACT, depth);
				end;
				-- Read width and Radius to use when calculating frictino
				local ActWheeleWidth = wheel.width;
				local ActWheeleRadius = wheel.radiusOriginal;
				-- Read sink into the ground
				local ActWheelSink = 0.01;
				if wheel.sink ~= nil then
					ActWheelSink = math.abs(wheel.sink);
				end;
				-- Update sideway speed and direction of active wheel
				REA:UpdateWheelDirectionAndSpeed(wheel,dt);
				-- Get speed based on xDrive
				wheel.SpeedBasedOnXdrive = REA:WheelSpeedFromXdrive(wheel,dt);
				-- If REA dynamic dirt activated check if wheel is in a lowspot with water
				local WheelInLowspotWithWater = false;
				if REA.DynamicDirtActivated then
					-- Get number of lowspots
					local NumOfLowspots = table.getn(WheelsUtil.LowspotWaterLevelNode);
					-- If any lowspot is created evaluate if wheel is in contact
					if NumOfLowspots > 0 then
						-- If wheel is moving update
						local MinSpeedForUpdate = 0.1;
						if wheel.SpeedBasedOnXdrive > MinSpeedForUpdate or wheel.RollingDirectionSpeed > MinSpeedForUpdate or wheel.SideWaySpeed > MinSpeedForUpdate then
							-- Get if wheel is in lowspot with water
							wheel.InLowspotWithWater = REA:GetIsInLowspotWithWater(wheel);
						end;
					else
						-- If no lowspots created
						wheel.InLowspotWithWater = false;
					end;
					WheelInLowspotWithWater = wheel.InLowspotWithWater;
				end;

				------------------------------------------------------
				-- Calculate and update friction for wheel
				------------------------------------------------------
				-- Calculate friction of wheel
				if MotorizedVehicle then
					------------------------------------------------------
					-- Friction calculation
					local TireFriction = (ActWheeleWidth*2)+(ActWheeleRadius/2);
					-- If additinal wheels add more friction
					if wheel.additionalWheels ~= nil then
						local numAdditionalWheels = table.getn(wheel.additionalWheels);
						TireFriction = TireFriction+(numAdditionalWheels*(TireFriction*0.5));
					end;
					------------------------------------------------------
					-- Sink Friction calculation
					-- Read parameters for current tiretype
					local ActWheelMaxSinkReducedFrictionPercentage = REA.TireTypeMaxSinkFrictionReduced[wheel.tireType];
					local ActWheelStuckPerectangeLevel = REA.TireTypeSinkStuckLevel[wheel.tireType];
					-- If wheel is in a lowspot make wheel able to get stuck
					if WheelInLowspotWithWater then
						ActWheelMaxSinkReducedFrictionPercentage = REA.TireTypeMaxSinkFrictionReducedLowSpot;
						ActWheelStuckPerectangeLevel = REA.TireTypeSinkStuckLevelLowSpot;
					end;
					-- Calculate sink percentage
					local ActWheelSinkPercentage = (ActWheelSink / (REA.WheelRadiusMaxSinkFactor*ActWheeleRadius))*100;
					local FrictionFactorBySink = 1;
					-- Update friction if wheel is turning
					if wheel.SpeedBasedOnXdrive > 0.1 then
						-- Calculate reduced friction casued by sink
						if ActWheelSinkPercentage < ActWheelStuckPerectangeLevel then
							FrictionFactorBySink = 1-((ActWheelMaxSinkReducedFrictionPercentage*(ActWheelSinkPercentage/100))/100);
							-- If wheel is in a lowspot with water decrease friction
							if WheelInLowspotWithWater then
								FrictionFactorBySink = FrictionFactorBySink * 0.5;
							end;
						else
							FrictionFactorBySink = 0;
						end;
					end;
	
					------------------------------------------------------
					-- Add the calculated friction to wheel
					wheel.frictionScale = TireFriction*FrictionFactorBySink;
				-- If vehicle not motorized use higher friction to avoid strange behavior when towing
				else
					-- use default value
				end;
	
				------------------------------------------------------
				-- Rolling and sideway resistance for wheel
				------------------------------------------------------
				if wheel.node ~= nil and wheel.wheelShape ~= nil then
					local MinSpeedToAddForce = 0.2;
					if wheel.RollingDirectionSpeed >= MinSpeedToAddForce or wheel.SideWaySpeed >= MinSpeedToAddForce then
						-- Save load on wheel to use for rolling resistance calculation
						local ActWheelLoad = 0.001;
						if getWheelShapeContactForce(wheel.node, wheel.wheelShape) ~= nil and wheel.contact ~= Wheels.WHEEL_NO_CONTACT then
							ActWheelLoad = getWheelShapeContactForce(wheel.node, wheel.wheelShape);
							-- If negative load set load to zero
							if ActWheelLoad < 0.001 then
								ActWheelLoad = 0.001;
							end;
						end;

						-- DEBUG
						--DebugUtil.drawDebugNode(wheel.driveNode,"Wheel: " .. Wheel .. ", Width: " .. ActWheeleWidth .. ", Radius: " .. ActWheeleRadius .. ", Load: " .. ActWheelLoad, false)

						-- Rolling resistance in rolling direction
						------------------------------------------------------
						-- Calculate force to add
						local RollingForceToAdd = 0;
						if wheel.RollingDirectionSpeed >= MinSpeedToAddForce and not IgnoreRollingResistance then
							-- Rolling reistance coefficient = sqrt(WheelSink(m)*((WheelRadius(m)*2)))
							-- Calculate coefficient
							local ActWheelRollConf = math.sqrt(ActWheelSink/(ActWheeleRadius*2));
							-- If coefficient to low use min value
							if ActWheelRollConf < REA.TireTypeMinRollingCoeff[wheel.tireType] then
								ActWheelRollConf  = REA.TireTypeMinRollingCoeff[wheel.tireType];
							end;
							-- Rolling resistance(kN) = coefficient*(Wheelload(kN)/WheelRadius(m))
							-- Calculate resistance force
							local ActWheelRollForce = ActWheelRollConf*(ActWheelLoad/ActWheeleRadius);
							-- In case of negative force, use zero force
							if ActWheelRollForce < 0 then
								ActWheelRollForce = 0;
							end;
							-- Factor of calulated farco to add
							local RollingResistanceForceFactor = 0.4 * CrawlersFactor;
							-- Calculate force with force factor
							RollingForceToAdd = ActWheelRollForce*RollingResistanceForceFactor;
							-- Add force slowly in low speed
							if wheel.RollingDirectionSpeed < 1 then
								RollingForceToAdd = RollingForceToAdd*wheel.RollingDirectionSpeed;
							end;
						end;
						-- Sideway resistance
						------------------------------------------------------
						-- Calculate force to add
						local SidewayForceToAdd = 0;
						if wheel.SideWaySpeed >= MinSpeedToAddForce then
							-- Rolling reistance coefficient = sqrt(WheelSink(m)*((WheelRadius(m)*2)))
							-- Min sink depending on groundtype
							local MinSink = 0;
							if groundType == SOFT_TERRAIN then
								MinSink = 0.04;
							elseif groundType == FIELD then
								MinSink = 0.06;
							end;
							-- Calculate coefficient
							local ActWheelRollConf = math.sqrt(math.max(MinSink,ActWheelSink)/(ActWheeleRadius*2));
							-- If coefficient to low use min value
							if ActWheelRollConf < REA.TireTypeMinRollingCoeff[wheel.tireType] then
								ActWheelRollConf  = REA.TireTypeMinRollingCoeff[wheel.tireType];
							end;
							-- Rolling resistance(kN) = coefficient*(Wheelload(kN)/WheelRadius(m))
							-- Calculate resistance force
							local ActWheelRollForce = ActWheelRollConf*(ActWheelLoad/ActWheeleRadius);
							-- In case of negative force, use zero force
							if ActWheelRollForce < 0 then
								ActWheelRollForce = 0;
							end;
							-- Factor of calulated farco to add
							local SidewayResistanceForceFactor = 1.0 * CrawlersFactor;
							if IgnoreRollingResistance then
								SidewayResistanceForceFactor = SidewayResistanceForceFactor / 2;
							end;
							-- Calculate force with force factor
							SidewayForceToAdd = ActWheelRollForce*SidewayResistanceForceFactor;
							-- Add force slowly in low speed
							if wheel.SideWaySpeed < 1 then
								SidewayForceToAdd = SidewayForceToAdd*wheel.SideWaySpeed;
							end;
						end;
						------------------------------------------------------
						-- Add force in the other direction fo the moving direction
						local LForceX, LForceY, LForceZ = localDirectionToLocal(wheel.driveNode,wheel.node,-(wheel.SideWayMovingDirection*SidewayForceToAdd),0,0);						
						local WForceX, WForceY, WForceZ = localDirectionToWorld(wheel.node,LForceX,LForceY,LForceZ+(-(wheel.RollingMovingDirection*RollingForceToAdd)));
						-- Get translation where force should be added
						local WheelX, WheelY, WheelZ = getTranslation(wheel.driveNode);
						-- Add the calculated force to physics
						addForce (wheel.node, WForceX, WForceY, WForceZ, WheelX, WheelY, WheelZ, true);
					end;
				end;
			end;
		end;
	end;
end;


-----------------------------------------------------------------------------------	
-- Function to determine which tireType based on tireTrackAtlasIndex
-----------------------------------------------------------------------------------
function REA:DetermineTireType(tireTrackAtlasIndex)
	-- Constants to use for each tireTypeName
	local TireTypeMUD = "mud";
	local TireTypeOFFROAD = "offRoad";
	local TireTypeSTREET = "street";
	local TireTypeCRAWLER = "crawler";
	-- Value to return
	local tireTypeName = TireTypeMUD;
	-- Check tiretrackindex to see if value present
	if tireTrackAtlasIndex ~= nil then
		-- Check number to determine which tiretypename
		if tireTrackAtlasIndex == 0 then
			tireTypeName = TireTypeMUD;
		elseif tireTrackAtlasIndex == 1 then
			tireTypeName = TireTypeSTREET;
		elseif tireTrackAtlasIndex == 2 then
			tireTypeName = TireTypeOFFROAD;
		elseif tireTrackAtlasIndex == 3 then
			tireTypeName = TireTypeOFFROAD;
		elseif tireTrackAtlasIndex == 4 then
			tireTypeName = TireTypeSTREET;
		elseif tireTrackAtlasIndex == 5 then
			tireTypeName = TireTypeCRAWLER;
		elseif tireTrackAtlasIndex == 6 then
			tireTypeName = TireTypeCRAWLER;
		elseif tireTrackAtlasIndex == 7 then
			tireTypeName = TireTypeCRAWLER;
		elseif tireTrackAtlasIndex == 8 then
			tireTypeName = TireTypeSTREET;
		elseif tireTrackAtlasIndex == 9 then
			tireTypeName = TireTypeMUD;
		elseif tireTrackAtlasIndex == 10 then
			tireTypeName = TireTypeOFFROAD;
		elseif tireTrackAtlasIndex == 11 then
			tireTypeName = TireTypeOFFROAD;
		elseif tireTrackAtlasIndex == 12 then
			tireTypeName = TireTypeOFFROAD;
		elseif tireTrackAtlasIndex == 13 then
			tireTypeName = TireTypeCRAWLER;
		elseif tireTrackAtlasIndex == 14 then
			-- Not used
			tireTypeName = TireTypeMUD;
		elseif tireTrackAtlasIndex == 15 then
			-- Not used
			tireTypeName = TireTypeMUD;
		else
			tireTypeName = TireTypeMUD;
		end
	end	
	-- Return tireType
	return WheelsUtil.getTireType(tireTypeName);
end


-----------------------------------------------------------------------------------	
-- Function to round value, delete decimals
-----------------------------------------------------------------------------------
function REA:RoundValue(x)
	return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end









-----------------------------------------------------------------------------------	
-- Function to determine if wheel is in a lowspot with
-----------------------------------------------------------------------------------
function REA:GetIsInLowspotWithWater(Wheel)
	-- Get translation of wheel
	local WheelX, WheelY, WheelZ = getWorldTranslation(Wheel.driveNode);
	-- Get number of lowspots
	local NumOfLowspots = table.getn(WheelsUtil.LowspotWaterLevelNode);
	-- Loop to calculate and update fricton, rolling resistance and sideway resistance for each wheel
	for LowSpot=1,NumOfLowspots do
		-- Get depth of first lospot to determine if water in low spots
		local lX, WaterLevel, lZ = getTranslation(WheelsUtil.LowspotWaterLevelNode[LowSpot]);
		-- Check if there is water in lowspots
		if WaterLevel > 0 then
			-- Get distance betweene wheel and lowspot
			local LowspotX, LowspotY, LowspotZ = getWorldTranslation(WheelsUtil.LowspotRootNode[LowSpot]);
			-- Calculate distance
			local DistanceX = math.abs(WheelX-LowspotX);
			local DistanceY = math.abs(WheelY-LowspotY);
			local DistanceZ = math.abs(WheelZ-LowspotZ);
			-- Determine if the wheel in range of lowspot
			if DistanceX <= WheelsUtil.LowspotSize[LowSpot] and DistanceZ <= WheelsUtil.LowspotSize[LowSpot] then
				-- Check if wheel is below waterlevel
				if (DistanceY - WaterLevel) - Wheel.radiusOriginal <= 0 then
					return true;
				end;
			end;
		else
			return false;
		end;
	end;
	return false;
end


-----------------------------------------------------------------------------------	
-- Function to smoothe value
-----------------------------------------------------------------------------------
function REA:SmootheValue(SmoothedValue,RealValue)
	-- If no smoothevalue use the real value
	if SmoothedValue == nil then
		ActValue = RealValue;
	else
		ActValue = SmoothedValue;
	end;
	-- Return the smoothed value
	return (ActValue*0.9)+(RealValue*0.1);
end


-----------------------------------------------------------------------------------	
-- Function to set new value during set time
-----------------------------------------------------------------------------------
function REA:SetValueWithTime(ActValue,TargetValue,OriginalValue,Time,dt)
	-- If values nil return zero
	if ActValue == nil or TargetValue == nil then
		return 0;
	end;
	-- If differens change value over time
	if ActValue ~= TargetValue then
		-- If difference betweene original value and target value calculate differens
		local DiffValue = TargetValue - OriginalValue;
		-- Calculate how much is target should change
		local NewValue = ActValue + (DiffValue * (dt / Time));
		-- Check if new value is outside target area
		if NewValue > TargetValue and TargetValue > OriginalValue then
			NewValue = TargetValue;
		elseif NewValue < TargetValue and TargetValue < OriginalValue then
			NewValue = TargetValue;
		end;
		-- Return new value
		return NewValue;
	else
		-- If no differens return Target value
		return TargetValue;
	end;
end


-----------------------------------------------------------------------------------	
-- Function to calculate filling speed in thousend liters per second
-----------------------------------------------------------------------------------
function REA:CalcFillSpeed(LastFillLevel,NewFillLevel,dt)
	-- Initialize liters per second
	local ThousendLiterPerSecond  = 0;
	-- If Fill level changed calculate fill speed
	if NewFillLevel > LastFillLevel then
		-- Calculate fill speed
		ThousendLiterPerSecond = ((NewFillLevel - LastFillLevel) / 1000) / (dt / 1000);
	end;
	-- Return last fill level and liter per seconds
	return NewFillLevel, ThousendLiterPerSecond;
end


-----------------------------------------------------------------------------------	
-- Function to calculate speed based on xDrive(wheel position)
-----------------------------------------------------------------------------------
function REA:WheelSpeedFromXdrive(wheel,dt)
	-- initialize last xDrive
	if wheel.xDriveLast == nil then
		wheel.xDriveLast = 0;
		wheel.xDriveLastMeterPerSecond = 0;
	end;
	-- Get differance from last call
	local RadDiff = math.abs(wheel.xDriveLast - wheel.netInfo.xDrive);
	-- Save last xDrive
	wheel.xDriveLast = wheel.netInfo.xDrive;
	-- If wheel starts a new turn assume that the speed is constant and return last calulated speed
	if RadDiff > 3.14 then
		-- Return speed in KMH
		return wheel.xDriveLastMeterPerSecond*3.6;
	-- If not a new turn calculate a neww speed
	else
		-- Calculate speed
		local DistanceTraveled = RadDiff * wheel.radiusOriginal;
		local MeterPerSecond = DistanceTraveled/(dt/1000);
		-- Save speed if wheel starts a new turn
		wheel.xDriveLastMeterPerSecond = MeterPerSecond;
		-- Convert to KMH
		local KMH = MeterPerSecond*3.6;
		-- Return speed in KMH
		return KMH;
	end;
end


-----------------------------------------------------------------------------------	
-- Function to calculate expected and actual moved distance of wheel 
-----------------------------------------------------------------------------------
function REA:WheelDistanceFromXdrive(wheel,dt)
	-- initialize last xDrive
	if wheel.DistancexDriveLast == nil then
		wheel.DistanceLastPosition = {0,0,0};
		wheel.DistancexDriveLast = 0;
	end;
	-- Get position of wheel
	local x,y,z = getWorldTranslation(wheel.driveNode);
	-- Calculate differance in position from last call
	local dx, dy, dz = worldDirectionToLocal(wheel.node, x-wheel.DistanceLastPosition[1], y-wheel.DistanceLastPosition[2], z-wheel.DistanceLastPosition[3]);
	-- Save position for next call
	wheel.DistanceLastPosition[1], wheel.DistanceLastPosition[2], wheel.DistanceLastPosition[3] = x, y, z;



	-- Get differance from last call
	local RadDiff = math.abs(wheel.DistancexDriveLast - wheel.netInfo.xDrive);
	-- Save last xDrive
	wheel.DistancexDriveLast = wheel.netInfo.xDrive;
	-- If wheel starts a new turn assume no change and return zero change
	if RadDiff > 3.14 then
		return 0,0;
	-- If not a new turn calculate distance traveled
	else
		-- Calculate expected moved distance
		local ExpectedDistanceTraveled = RadDiff * wheel.radiusOriginal;
		-- Calculate actual moved distance
		local ActualDistanceTraveled = math.max(math.abs(dx),math.abs(dz));
		-- Return speed in KMH
		return ExpectedDistanceTraveled,ActualDistanceTraveled;
	end;
end


-----------------------------------------------------------------------------------	
-- Calculate sideway speed of wheel
-----------------------------------------------------------------------------------
function REA:UpdateWheelDirectionAndSpeed(wheel,dt)
	local speedReal = 0;
	local movedDistance = 0;
	local MovingDirection = 0;
	local x,y,z = 0,0,0;
	local dx,dy,dz = 0,0,0;

	-- Rolling direction
	-- Calculate speed based on the position change
	x,y,z = getWorldTranslation(wheel.driveNode);
	if wheel.REARollingLastPosition == nil then
		wheel.REARollingLastPosition = {x,y,z};
	end;
	local dx, dy, dz = worldDirectionToLocal(wheel.node, x-wheel.REARollingLastPosition[1], y-wheel.REARollingLastPosition[2], z-wheel.REARollingLastPosition[3]);
	wheel.REARollingLastPosition[1], wheel.REARollingLastPosition[2], wheel.REARollingLastPosition[3] = x, y, z;
	-- Rolling direction
	speedReal = 0;
	movedDistance = 0;
	MovingDirection = 0;
	-- Moving direction
	if dz > 0.001 then
		MovingDirection = 1;
	elseif dz < -0.001 then
		MovingDirection = -1;
	end;
	-- Calculate speed of wheel in direction
	movedDistance = dz;
	speedReal = (movedDistance / dt)*3600;
	-- Remove sign
	if speedReal < 0 then
		speedReal = speedReal*(-1); 
	end;
	-- Save result to wheel
	wheel.RollingDirectionSpeed = REA:SmootheValue(wheel.RollingDirectionSpeed,speedReal);
	wheel.RollingMovingDirection = MovingDirection;

	-- SideWay direction
	-- Calculate speed based on the position change
	x,y,z = getWorldTranslation(wheel.driveNode);
	if wheel.REASideLastPosition == nil then
		wheel.REASideLastPosition = {x,y,z};
	end;
	dx, dy, dz = worldDirectionToLocal(wheel.driveNode, x-wheel.REASideLastPosition[1], y-wheel.REASideLastPosition[2], z-wheel.REASideLastPosition[3]);
	wheel.REASideLastPosition[1], wheel.REASideLastPosition[2], wheel.REASideLastPosition[3] = x, y, z;
	-- SideWay direction
	speedReal = 0;
	movedDistance = 0;
	MovingDirection = 0;
	-- Moving direction
	if dx > 0.001 then
		MovingDirection = 1;
	elseif dx < -0.001 then
		MovingDirection = -1;
	end;
	-- Calculate speed of wheel in direction
	movedDistance = dx;
	speedReal = (movedDistance / dt)*3600;
	-- Remove sign
	if speedReal < 0 then
		speedReal = speedReal*(-1); 
	end;
	-- Save result to wheel
	wheel.SideWaySpeed = REA:SmootheValue(wheel.SideWaySpeed,speedReal);
	wheel.SideWayMovingDirection = MovingDirection;
end;


-----------------------------------------------------------------------------------	
-- Function for adjusting speed if PTO tourqe reaches max motor tourqe
-----------------------------------------------------------------------------------
function REA:AdjustSpeedIfPtpPowerMaxed(vehicle,dt)
	local motor = vehicle.spec_motorized.motor;

	-- Calculate avalible power
	local PowerAvalible = motor.motorAvailableTorque * motor.lastMotorRpm *math.pi/30
	-- Lowest speed setpoint
	local LowSpeedSetpoint = 3;
	-- Get speedlimit of motor
	local SpeedLimit = 1000;
	if motor.speedLimit ~= nil then
		if motor.speedLimit < SpeedLimit then
			SpeedLimit = motor.speedLimit;
		end;
	end;
	-- Get total power need by filling from all implements
	local TotalPowerNeedByFilling = 0;
	local HighestPowerNeed = 0;
	local attachedImplements;
	if vehicle.getAttachedImplements ~= nil then
		attachedImplements = vehicle:getAttachedImplements();
		for _, implement in pairs(attachedImplements) do
			if implement.object ~= nil then
				if implement.object.spec_powerConsumer ~= nil then
					-- Save to local power consumer
					local PowerConsumer = implement.object.spec_powerConsumer;
					-- If power is consumed by implement add power to total amount consumed by all implements
					if PowerConsumer.PowerToAddPTOSmoothed ~= nil then
						-- Initialize original speed limit of implement
						if PowerConsumer.OriginalSpeedlimit == nil then
							PowerConsumer.OriginalSpeedlimit = implement.object.speedLimit;
							PowerConsumer.CurrentSpeedLimit = PowerConsumer.OriginalSpeedlimit;
							PowerConsumer.SpeedRegulatorTimer = 0;
						end;
						-- Speedlimit of implement
						if implement.object:doCheckSpeedLimit() then
							-- Power consumed by filling
							TotalPowerNeedByFilling = PowerConsumer.PowerToAddPTOSmoothed + TotalPowerNeedByFilling;
							-- Save highest power need and speedlimit to know which implemnt to use as speedlimiter
							if PowerConsumer.PowerToAddPTOSmoothed > HighestPowerNeed then
								HighestPowerNeed = PowerConsumer.PowerToAddPTOSmoothed;
								SpeedLimit = PowerConsumer.OriginalSpeedlimit;
							end;
						end;
					end;
				end;
			end;
		end;
		-- Adjust speed depending on power need
		for _, implement in pairs(attachedImplements) do
			if implement.object ~= nil then
				if implement.object.spec_powerConsumer ~= nil then
					-- Save to local power consumer
					local PowerConsumer = implement.object.spec_powerConsumer;
					if PowerConsumer.PowerToAddPTOSmoothed ~= nil then
						-- If implement uses power from filling check if power needed and is the most consuming adjust speedlimit
						if PowerConsumer.PowerToAddPTOSmoothed == HighestPowerNeed and HighestPowerNeed ~= 0 then
							-- Regulator for adjusting speed depending on poweruse by filling
							PowerConsumer.CurrentSpeedLimit,PowerConsumer.SpeedRegulatorTimer = REA:SpeedPowerRegulator(TotalPowerNeedByFilling,PowerAvalible*0.9,LowSpeedSetpoint,SpeedLimit,PowerConsumer.CurrentSpeedLimit,PowerConsumer.SpeedRegulatorTimer,dt);
							-- Add speed limit to implement
							implement.object.speedLimit = PowerConsumer.CurrentSpeedLimit;
						-- Implement is not the one consuming the most set original speedlimt
						else
							implement.object.speedLimit = PowerConsumer.OriginalSpeedlimit;
						end;
					end;
				end;
			end;
		end;
	end;
end;


-----------------------------------------------------------------------------------	
-- Update power multiplier for power consumers
-----------------------------------------------------------------------------------
function REA:UpdatePowerMultiplier(vehicle,dt)
	---------------------------------------------------------------------
	-- Check if this is a Plow, cultivator or sowingmachine
	local Plow = false;
	local Cultivator = false;
	local SowingMachine = false;
	local Combine = false;
	local Baler = false;
	local ForageWagon = false;
	-- Plow
	if vehicle.spec_plow ~= nil then
		Plow = true;
	-- Cultivator
	elseif vehicle.spec_cultivator ~= nil then
		Cultivator = true;
	-- Sowing machine
	elseif vehicle.spec_sowingMachine ~= nil then
		SowingMachine = true;
	-- Combine
	elseif vehicle.spec_combine ~= nil then
		Combine = true;
	-- Baler
	elseif vehicle.spec_baler ~= nil then
		Baler = true;
	-- Forage wagon
	elseif vehicle.spec_forageWagon ~= nil then
		ForageWagon = true;
	end;
	-- Adjust force and speed for plows, Cultivators and sowing machines
	if vehicle.spec_powerConsumer ~= nil and ( Plow or Cultivator or SowingMachine ) then
		local PowerConsumer = vehicle.spec_powerConsumer;
		if PowerConsumer.forceNode ~= nil then
			-- Save original max force
			if PowerConsumer.OriginalMaxForce == nil then
				PowerConsumer.OriginalMaxForce = PowerConsumer.maxForce;
			end;
			-- Calculate multiplier depending on type of implement and ground type
			local TargetMaxForce = PowerConsumer.OriginalMaxForce;
			-- Do not ignore rolling resistance of wheels
			PowerConsumer.IgnoreRollingResistance = true;
			if vehicle:doCheckSpeedLimit() then
				-- Get density att "ForceNode"
				local SizeOfDenityArea = 0.5;
				local SizeOffset = SizeOfDenityArea/2;
				local x0,_,z0 = localToWorld(PowerConsumer.forceNode, SizeOffset, 0, -SizeOffset);
				local x1,_,z1 = localToWorld(PowerConsumer.forceNode, -SizeOffset, 0, -SizeOffset);
				local x2,_,z2 = localToWorld(PowerConsumer.forceNode, SizeOffset, 0, SizeOffset);
				local density, area = FSDensityMapUtil.getFieldValue(x0, z0, x1, z1, x2, z2);
				-- Determine which groundtype it is
				local terrainValue = 0;
				if area > 0 then
					terrainValue = math.floor(density/area + 0.5);
				end;
				-- Determine type of implement and which multiplier to use
				-- Initialize multiplier
				local multiplier = 1;
				-- Plow
				if Plow then
					if REA.PlowMultiplier[terrainValue] ~= nil and REA.PlowSpeedAjust[terrainValue] ~= nil then
						multiplier = REA.PlowMultiplier[terrainValue];
					end;
				-- Cultivator
				elseif Cultivator then
					if REA.CultivatorMultiplier[terrainValue] ~= nil and REA.CultivatorSpeedAjust[terrainValue] ~= nil then
						multiplier = REA.CultivatorMultiplier[terrainValue];
					end;
				-- Sowing machine
				elseif SowingMachine then
					if REA.SowingMachineMultiplier[terrainValue] ~= nil and REA.SowingMachineSpeedAjust[terrainValue] ~= nil then
						multiplier = REA.SowingMachineMultiplier[terrainValue];				
					end;
				end;
				-- Adjust pulling max force
				TargetMaxForce = PowerConsumer.OriginalMaxForce * multiplier;
				-- Ignore Wheele roling resistance
				PowerConsumer.IgnoreRollingResistance = true;
			end;
			-- Save new values
			PowerConsumer.maxForce = REA:SmootheValue(PowerConsumer.maxForce,TargetMaxForce);
		end;
	end;

	---------------------------------------------------------------------
	-- Adjust force needed on PTO by filling a fillunit
	-- !COMBINE IS DISABLED AND UNDER DEVELOPMENT!
	if vehicle.spec_fillUnit ~= nil and ((vehicle.spec_powerConsumer ~= nil and (Baler or ForageWagon)) or (Combine and false)) then
		-- Save local copy of FillUnit
		local FillUnit = vehicle.spec_fillUnit;
		-- Get number of fillunits
		local numFillUnits = table.getn(FillUnit.fillUnits);
		-- Total fillspeed for all fillunits
		local TotalFillSpeed = 0;
		-- Highest fillspeed
		local HighestFillSpeed = 0;
		-- Mass of filltype in Ton/m2
		local HighestFillspeedMassTM2 = 1;
		local HighestFillspeedMassTM2Name = "NoName";
		-- Search for correct fill unit and get current filllevel
		for FillUnitIndex=1, numFillUnits do
			local ActFillUnit = FillUnit.fillUnits[FillUnitIndex];
			if ActFillUnit.fillType ~= FillType.DIESEL and ActFillUnit.fillType ~= FillType.DEF then
				-- Create variables for calculating fill speed
				if ActFillUnit.TimeLastChange == nil then
					ActFillUnit.TimeLastChange = 0;
					ActFillUnit.LastFillLevel = 0;
					ActFillUnit.AddedFillLevel = 0;
					ActFillUnit.FillSpeedLS = 0;
					ActFillUnit.FillSpeedLSSmoothed = 0;
				end;
				-- Add time change since last fill, max 1 second
				if ActFillUnit.TimeLastChange < 1000 then
					ActFillUnit.TimeLastChange = ActFillUnit.TimeLastChange + dt;
				end;
				-- Calculate change in fill level
				ActFillUnit.AddedFillLevel = ActFillUnit.fillLevel - ActFillUnit.LastFillLevel;
				-- Save fill level
				ActFillUnit.LastFillLevel = ActFillUnit.fillLevel;
				-- If fillunit added fill since last update calculate fillspeed and reset value
				ActFillUnit.FillSpeedLS = 0;
				if ActFillUnit.AddedFillLevel > 0 then
					-- Calculate fillspeed Liter / second
					ActFillUnit.FillSpeedLS = ActFillUnit.AddedFillLevel / (ActFillUnit.TimeLastChange / 1000);
					ActFillUnit.TimeLastChange = 0;
					ActFillUnit.AddedFillLevel = 0;
				end;
				-- Smoothe fillspeed value
				ActFillUnit.FillSpeedLSSmoothed = REA:SmootheValue(ActFillUnit.FillSpeedLSSmoothed,ActFillUnit.FillSpeedLS);
				if ActFillUnit.FillSpeedLSSmoothed < 0.001 then
					ActFillUnit.FillSpeedLSSmoothed = 0;
				end;
				-- Calculate total fill speed
				TotalFillSpeed = TotalFillSpeed + ActFillUnit.FillSpeedLSSmoothed;
				-- Get mass of filltype from the fillunit with highest fillspeed, Ton/m2
				if ActFillUnit.FillSpeedLSSmoothed > HighestFillSpeed then
					HighestFillSpeed = ActFillUnit.FillSpeedLSSmoothed;
					HighestFillspeedMassTM2 = g_currentMission.fillTypeManager.fillTypes[ActFillUnit.fillType].massPerLiter * 1000;
					HighestFillspeedMassTM2Name = g_currentMission.fillTypeManager.fillTypes[ActFillUnit.fillType].name;
				end;
			end;
		end;

		-- DEBUG
		--renderText(0.2, 0.35, 0.05,"name: " .. HighestFillspeedMassTM2Name);
		--renderText(0.2, 0.15, 0.05,"Fillspeed smoothed: " .. tostring(TotalFillSpeed));

		-- If combine use cutter as power consumer
		local CutterWorking = false;
		local PowerConsumer;
		if Combine then
			if vehicle.spec_combine.attachedCutters ~= nil then
				local cutters = vehicle.spec_combine.attachedCutters;
				for cutter, _ in pairs(cutters) do
					if cutter:doCheckSpeedLimit() and cutter.spec_powerConsumer ~= nil then
						PowerConsumer = cutter.spec_powerConsumer;
						CutterWorking = true;
					end;
				end;
			end;
		elseif vehicle.spec_powerConsumer ~= nil then
			PowerConsumer = vehicle.spec_powerConsumer;
		end;
		-- If vehicle is working add fillspeed power need
		if PowerConsumer ~= nil then
			-- Initiate variables
			if PowerConsumer.PowerToAddPTOSmoothed == nil then
				PowerConsumer.PowerToAddPTOSmoothed = 0;
			end;
			-- Save original values
			if PowerConsumer.OriginalNeededMinPtoPower == nil and PowerConsumer.neededMinPtoPower ~= nil then
				PowerConsumer.OriginalNeededMinPtoPower = PowerConsumer.neededMinPtoPower;
			end;
			if PowerConsumer.OriginalNeededMaxPtoPower == nil and PowerConsumer.neededMaxPtoPower ~= nil then
				PowerConsumer.OriginalNeededMaxPtoPower = PowerConsumer.neededMaxPtoPower;
			end;
			-- Add power to PTO if vehicle is working
			if vehicle:doCheckSpeedLimit() or (Combine and CutterWorking) then
				local PowerToAddPTO = 0;
				local PowerNeedByFilling = 0;
				-- If fillspeed present add power
				if TotalFillSpeed > 0.001 then
					-- Calculate power to be added to PTO based on filling speed
					PowerNeedByFilling = (REA.FillspeedPowerNeed * (TotalFillSpeed/100)) * HighestFillspeedMassTM2;
					-- Power to add PTO
					local PowerFactorForImplement = 0.5;
					if PowerConsumer.neededMinPtoPower ~= nil then
						if PowerNeedByFilling > (PowerConsumer.OriginalNeededMinPtoPower * PowerFactorForImplement) then
							PowerToAddPTO = PowerNeedByFilling - (PowerConsumer.OriginalNeededMinPtoPower * PowerFactorForImplement);
						end;
					end;
					if PowerConsumer.neededMaxPtoPower ~= nil then
						if PowerToAddPTO == 0 then
							if PowerNeedByFilling > (PowerConsumer.OriginalNeededMaxPtoPower * PowerFactorForImplement) then
								PowerToAddPTO = PowerNeedByFilling - (PowerConsumer.OriginalNeededMaxPtoPower * PowerFactorForImplement);
							end;
						end;
					end;
				end;
				-- Smoothe power to add
				PowerConsumer.PowerToAddPTOSmoothed = REA:SmootheValue(PowerConsumer.PowerToAddPTOSmoothed,PowerToAddPTO);
				-- If power to add is low set zero value
				if PowerConsumer.PowerToAddPTOSmoothed < 0.001 then
					PowerConsumer.PowerToAddPTOSmoothed = 0;
				end;
				-- Add power need
				if PowerConsumer.PowerToAddPTOSmoothed > 0 then
					if PowerConsumer.neededMinPtoPower ~= nil then
						PowerConsumer.neededMinPtoPower = PowerConsumer.OriginalNeededMinPtoPower + PowerConsumer.PowerToAddPTOSmoothed;
					end;
					if PowerConsumer.neededMaxPtoPower ~= nil then
						PowerConsumer.neededMaxPtoPower = PowerConsumer.OriginalNeededMaxPtoPower + PowerConsumer.PowerToAddPTOSmoothed;
					end;
				end;

				-- DEBUG
				--renderText(0.2, 0.15, 0.05,"Mass: " .. tostring(HighestFillspeedMassTM2));
				--renderText(0.2, 0.20, 0.05,"Power need by filling: " .. tostring(PowerNeedByFilling));
				--renderText(0.2, 0.25, 0.05,"PTO Power to add: " .. tostring(PowerConsumer.PowerToAddPTOSmoothed));

			else
				-- No power needed
				PowerConsumer.PowerToAddPTOSmoothed = 0;
				-- Reset to original values
				if PowerConsumer.neededMinPtoPower ~= nil then
					PowerConsumer.neededMinPtoPower = PowerConsumer.OriginalNeededMinPtoPower;
				end;
				if PowerConsumer.neededMaxPtoPower ~= nil then
					PowerConsumer.neededMaxPtoPower = PowerConsumer.OriginalNeededMaxPtoPower;
				end;
			end;
		end;
	end;
end


-----------------------------------------------------------------------------------	
-- Update power multiplier for power consumers
-----------------------------------------------------------------------------------
function REA:SpeedPowerRegulator(Input,Setpoint,outputMin,outputMax,LastOutput,Timer,dt)
	local timeStep = 50
	-- Add time to timer
	Timer = Timer + dt
	-- Run regulator
	if Timer > timeStep then
		-- Restart intervall timer
		Timer = 0;
		-- Calculate error
		local err = Setpoint - Input;
		-- Calculate ajustment value
		local Adjust = 0;
		if err ~= 0 then
			Adjust = err / 100;
		end;
		-- Calculate new output value
		local output = Adjust + LastOutput;
		-- Check if output in bounds
		if output > outputMax then
			output = outputMax
		elseif output < outputMin then
			output = outputMin
		end
		-- Smoothe value
		LastOutput = REA:SmootheValue(LastOutput,output);
		-- Return new output
		return LastOutput, Timer;
	end;
	-- Return last output
	return LastOutput, Timer;
end;


-----------------------------------------------------------------------------------	
-- Edited loadWheelData
-----------------------------------------------------------------------------------
function Wheels:loadWheelData(wheel, xmlFile, configKey)
	local key = "nodeLeft"
	if not wheel.isLeft then
		key = "nodeRight"
	end
	
	wheel.radius = getXMLFloat(xmlFile, configKey..".physics#radius") or wheel.radius
	if wheel.radius == nil then
		g_logManager:xmlWarning(self.configFileName, "No radius defined for wheel '%s'! Using default value of 0.5!", configKey..".physics#radius")
		wheel.radius = 0.5
	end
	
	wheel.width = getXMLFloat(xmlFile, configKey..".physics#width") or wheel.width
	if wheel.width == nil then
		g_logManager:xmlWarning(self.configFileName, "No width defined for wheel '%s'! Using default value of 0.5!", configKey..".physics#width")
		wheel.width = 0.5
	end
	
	wheel.mass = getXMLFloat(xmlFile, configKey..".physics#mass") or wheel.mass or 0.1
	local tireTypeName = getXMLString(xmlFile, configKey..".tire#tireType")
	wheel.frictionScale = getXMLFloat(xmlFile, configKey..".physics#frictionScale") or wheel.frictionScale
	wheel.maxLongStiffness = getXMLFloat(xmlFile, configKey..".physics#maxLongStiffness") or wheel.maxLongStiffness -- [t / rad]
	wheel.maxLatStiffness = getXMLFloat(xmlFile, configKey..".physics#maxLatStiffness") or wheel.maxLatStiffness -- xml is ratio to restLoad [1/rad], final value is [t / rad]
	wheel.maxLatStiffnessLoad = getXMLFloat(xmlFile, configKey..".physics#maxLatStiffnessLoad") or wheel.maxLatStiffnessLoad -- xml is ratio to restLoad, final value is [t]
	wheel.tireTrackAtlasIndex = getXMLInt(xmlFile, configKey..".tire#tireTrackAtlasIndex") or wheel.tireTrackAtlasIndex or 0

	wheel.tireType = WheelsUtil.getTireType(tireTypeName)

	wheel.widthOffset = getXMLFloat(xmlFile, configKey..".tire#widthOffset") or wheel.widthOffset or 0.0
	wheel.xOffset = getXMLFloat(xmlFile, configKey..".tire#xOffset") or wheel.xOffset or 0
	wheel.maxDeformation = getXMLFloat(xmlFile, configKey..".tire#maxDeformation") or wheel.maxDeformation or 0
	wheel.deformation = 0
	wheel.isCareWheel = Utils.getNoNil(Utils.getNoNil(getXMLBool(xmlFile, configKey..".tire#isCareWheel"), wheel.isCareWheel), true)
	wheel.smoothGroundRadius = getXMLFloat(xmlFile, configKey..".physics#smoothGroundRadius") or math.max(0.6, wheel.width*0.75)
	
	wheel.tireFilename = XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".tire#filename", "", getXMLString, wheel.tireFilename)
	wheel.tireIsInverted = XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".tire#isInverted", "", getXMLBool, wheel.tireIsInverted)
	wheel.tireNodeStr = XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".tire#node", "", getXMLString, nil) or XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".tire#"..key, "", getXMLString, wheel.tireNodeStr)
	wheel.outerRimFilename = XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".outerRim#filename", "", getXMLString, wheel.outerRimFilename)
	wheel.outerRimNodeStr = XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".outerRim#node", "", getXMLString, wheel.outerRimNodeStr) or "0|0"
	wheel.outerRimWidthAndDiam = XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".outerRim#widthAndDiam", "", getXMLString,  wheel.outerRimWidthAndDiam, StringUtil.getVectorNFromString, 2)
	wheel.outerRimScale = XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".outerRim#scale", "", getXMLString, wheel.outerRimScale, StringUtil.getVectorNFromString, 3)
	wheel.innerRimFilename = XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".innerRim#filename", "", getXMLString, wheel.innerRimFilename)
	wheel.innerRimNodeStr = XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".innerRim#node", "", getXMLString, nil) or XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".innerRim#"..key, "", getXMLString, wheel.innerRimNodeStr)
	wheel.innerRimWidthAndDiam = XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".innerRim#widthAndDiam", "", getXMLString, wheel.innerRimWidthAndDiam, StringUtil.getVectorNFromString, 2)
	wheel.innerRimOffset = XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".innerRim#offset", "", getXMLFloat, wheel.innerRimOffset) or 0
	wheel.innerRimScale = XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".innerRim#scale", "", getXMLString, wheel.innerRimScale, StringUtil.getVectorNFromString, 3);
	wheel.additionalFilename = XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".additional#filename", "", getXMLString, wheel.additionalFilename)
	wheel.additionalNodeStr = XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".additional#node", "", getXMLString, nil) or XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".additional#"..key, "", getXMLString, wheel.additionalNodeStr)
	wheel.additionalOffset = XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".additional#offset", "", getXMLFloat,  wheel.additionalOffset) or 0
	wheel.additionalScale = XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".additional#scale", "", getXMLString, wheel.additionalScale, StringUtil.getVectorNFromString, 3)
	wheel.additionalMass = XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".additional#mass", "", getXMLFloat, wheel.additionalMass) or 0
	wheel.additionalWidthAndDiam = XMLUtil.getXMLOverwrittenValue(xmlFile, configKey, ".additional#widthAndDiam", "", getXMLString, wheel.additionalWidthAndDiam, StringUtil.getVectorNFromString, 2)
end


-----------------------------------------------------------------------------------	
-- Edited loadWheelPhysicsData
-----------------------------------------------------------------------------------
function Wheels:loadWheelPhysicsData(xmlFile, key, wheelnamei, wheel)
	local physicsKey = wheelnamei .. ".physics"
	if wheel.repr ~= nil then
		wheel.node = self:getParentComponent(wheel.repr)
		if wheel.node ~= 0 then
			XMLUtil.checkDeprecatedXMLElements(xmlFile, self.configFileName, key..wheelnamei.."#steeringNode", string.format("vehicle.wheels.wheelConfigurations.wheelConfiguration.wheels%s.steering#node", wheelnamei))
			local driveNodeStr = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#driveNode", getXMLString, nil, nil, nil)
			wheel.driveNode = I3DUtil.indexToObject(self.components, driveNodeStr, self.i3dMappings)
			if wheel.driveNode == wheel.repr then
				g_logManager:xmlWarning(self.configFileName, "repr and driveNode may not be equal for '%s'. Using default driveNode instead!", key.."."..physicsKey)
				wheel.driveNode = nil
			end
			wheel.linkNode = I3DUtil.indexToObject(self.components, ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#linkNode", getXMLString, nil, nil, nil), self.i3dMappings)
			if wheel.driveNode == nil then
				-- create a new repr and use repr as drivenode
				local newRepr = createTransformGroup("wheelReprNode")
				local reprIndex = getChildIndex(wheel.repr)
				link(getParent(wheel.repr), newRepr, reprIndex)
				setTranslation(newRepr, getTranslation(wheel.repr))
				setRotation(newRepr, getRotation(wheel.repr))
				setScale(newRepr, getScale(wheel.repr))
				wheel.driveNode = wheel.repr
				link(newRepr, wheel.driveNode)
				setTranslation(wheel.driveNode, 0, 0, 0)
				setRotation(wheel.driveNode, 0, 0, 0)
				setScale(wheel.driveNode, 1, 1, 1)
				wheel.repr = newRepr
			end
			if wheel.driveNode ~= nil then
				local driveNodeDirectionNode = createTransformGroup("driveNodeDirectionNode")
				link(getParent(wheel.repr), driveNodeDirectionNode)
				setWorldTranslation(driveNodeDirectionNode, getWorldTranslation(wheel.driveNode))
				setWorldRotation(driveNodeDirectionNode, getWorldRotation(wheel.driveNode))
				wheel.driveNodeDirectionNode = driveNodeDirectionNode
			end
			if wheel.linkNode == nil then
				wheel.linkNode = wheel.driveNode
			end
			wheel.yOffset = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#yOffset", getXMLFloat, 0.0, nil, nil)
			if wheel.yOffset ~= 0 then
				-- move drivenode in y direction. Use convert yOffset from driveNode local space to driveNodeParent local space to translate according to directions
				setTranslation(wheel.driveNode, localToLocal(wheel.driveNode, getParent(wheel.driveNode), 0, wheel.yOffset, 0))
			end
			wheel.showSteeringAngle = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#showSteeringAngle", getXMLBool, true, nil, nil)
			wheel.suspTravel = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#suspTravel", getXMLFloat, 0.01, nil, nil)
			local initialCompression = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#initialCompression", getXMLFloat, nil, nil, nil)
			if initialCompression ~= nil then
				wheel.deltaY = (1-initialCompression*0.01)*wheel.suspTravel
			else
				wheel.deltaY = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#deltaY", getXMLFloat, 0.0, nil, nil)
			end
			wheel.spring = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#spring", getXMLFloat, 0, nil, nil)*Vehicle.SPRING_SCALE
			wheel.torque = 0
			wheel.brakeFactor = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#brakeFactor", getXMLFloat, 1, nil, nil)
			wheel.autoHoldBrakeFactor = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#autoHoldBrakeFactor", getXMLFloat, wheel.brakeFactor, nil, nil)
			wheel.damperCompressionLowSpeed = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#damperCompressionLowSpeed", getXMLFloat, nil, nil, nil)
			wheel.damperRelaxationLowSpeed = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#damperRelaxationLowSpeed", getXMLFloat, nil, nil, nil)
			if wheel.damperRelaxationLowSpeed == nil then
				wheel.damperRelaxationLowSpeed = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#damper", getXMLFloat, Utils.getNoNil(wheel.damperCompressionLowSpeed, 0), nil, nil)
			end
			-- by default, the high speed relaxation damper is set to 90% of the low speed relaxation damper
			wheel.damperRelaxationHighSpeed = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#damperRelaxationHighSpeed", getXMLFloat, wheel.damperRelaxationLowSpeed * 0.7, nil, nil)
			-- by default, we set the low speed compression damper to 90% of the low speed relaxation damper
			if wheel.damperCompressionLowSpeed == nil then
				wheel.damperCompressionLowSpeed = wheel.damperRelaxationLowSpeed * 0.9
			end
			-- by default, the high speed compression damper is set to 20% of the low speed compression damper
			wheel.damperCompressionHighSpeed = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#damperCompressionHighSpeed", getXMLFloat, wheel.damperCompressionLowSpeed * 0.2, nil, nil)
			wheel.damperCompressionLowSpeedThreshold = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#damperCompressionLowSpeedThreshold", getXMLFloat, 0.1016, nil, nil) -- default 4 inch / s
			wheel.damperRelaxationLowSpeedThreshold = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#damperRelaxationLowSpeedThreshold", getXMLFloat, 0.1524, nil, nil) -- default 6 inch / s
			wheel.forcePointRatio = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#forcePointRatio", getXMLFloat, 0, nil, nil)
			wheel.driveMode = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#driveMode", getXMLInt, 0, nil, nil)
			wheel.xOffset = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#xOffset", getXMLFloat, 0, nil, nil)
			wheel.transRatio = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#transRatio", getXMLFloat, 0.0, nil, nil)
			wheel.isSynchronized = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#isSynchronized", getXMLBool, true, nil, nil)
			wheel.tipOcclusionAreaGroupId = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#tipOcclusionAreaGroupId", getXMLInt, nil, nil, nil)
			wheel.positionX, wheel.positionY, wheel.positionZ = localToLocal(wheel.driveNode, wheel.node, 0,0,0)
			wheel.useReprDirection = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#useReprDirection", getXMLBool, false, nil, nil)
			wheel.useDriveNodeDirection = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#useDriveNodeDirection", getXMLBool, false, nil, nil)
			wheel.mass = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#mass", getXMLFloat, wheel.mass, nil, nil)
			wheel.radius = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#radius", getXMLFloat, Utils.getNoNil(wheel.radius, 0.5), nil, nil)
			wheel.width = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#width", getXMLFloat, Utils.getNoNil(wheel.width, 0.6), nil, nil)
			wheel.wheelshapeWidth = wheel.width
			wheel.widthOffset = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#widthOffset", getXMLFloat, 0, nil, nil)
			wheel.restLoad = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#restLoad", getXMLFloat, Utils.getNoNil(wheel.restLoad, 1.0), nil, nil) -- [t]
			wheel.maxLongStiffness = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#maxLongStiffness", getXMLFloat, Utils.getNoNil(wheel.maxLongStiffness, 30.0), nil, nil) -- [t / rad]
			wheel.maxLatStiffness = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#maxLatStiffness", getXMLFloat, Utils.getNoNil(wheel.maxLatStiffness, 40.0), nil, nil) -- xml is ratio to restLoad [1/rad], final value is [t / rad]
			wheel.maxLatStiffnessLoad = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#maxLatStiffnessLoad", getXMLFloat, Utils.getNoNil(wheel.maxLatStiffnessLoad, 2), nil, nil) -- xml is ratio to restLoad, final value is [t]
			wheel.frictionScale = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#frictionScale", getXMLFloat, Utils.getNoNil(wheel.frictionScale, 1.0), nil, nil)
			wheel.rotationDamping = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#rotationDamping", getXMLFloat, wheel.mass * 0.035, nil, nil)
			wheel.tireGroundFrictionCoeff = 1.0 -- This will be changed dynamically based on the tire-ground pair

			if wheel.tireType == nil then
				local tireTypeName = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#tireType", getXMLString, nil, nil, nil)				
				if tireTypeName == nil then
					-- Check if tiretrackindex present else use "mud"
					wheel.tireType = REA:DetermineTireType(wheel.tireTrackAtlasIndex)
				else
					wheel.tireType = WheelsUtil.getTireType(tireTypeName)
				end
			end

			wheel.fieldDirtMultiplier = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#fieldDirtMultiplier", getXMLFloat, 75, nil, nil)
			wheel.streetDirtMultiplier = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#streetDirtMultiplier", getXMLFloat, -150, nil, nil)
			wheel.minDirtPercentage = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#minDirtPercentage", getXMLFloat, 0.35, nil, nil)
	
			wheel.smoothGroundRadius = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#smoothGroundRadius", getXMLFloat, Utils.getNoNil(wheel.smoothGroundRadius, math.max(0.6, wheel.width*0.75)), nil, nil)
			wheel.versatileYRot = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#versatileYRot", getXMLBool, false, nil, nil)
			wheel.forceVersatility = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#forceVersatility", getXMLBool, false, nil, nil)
			wheel.supportsWheelSink = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#supportsWheelSink", getXMLBool, true, nil, nil)
			wheel.maxWheelSink = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#maxWheelSink", getXMLFloat, math.huge, nil, nil)
	
			wheel.hasTireTracks = ConfigurationUtil.getConfigurationValue(xmlFile, key, wheelnamei, "#hasTireTracks", getXMLBool, false, nil, nil)
			wheel.hasParticles = ConfigurationUtil.getConfigurationValue(xmlFile, key, wheelnamei, "#hasParticles", getXMLBool, false, nil, nil)
	
			local steeringKey = wheelnamei .. ".steering"
			wheel.steeringNode = I3DUtil.indexToObject(self.components, ConfigurationUtil.getConfigurationValue(xmlFile, key, steeringKey, "#node", getXMLString, nil, nil, nil), self.i3dMappings)
			wheel.steeringRotNode = I3DUtil.indexToObject(self.components, ConfigurationUtil.getConfigurationValue(xmlFile, key, steeringKey, "#rotNode", getXMLString, nil, nil, nil), self.i3dMappings)
			wheel.steeringNodeMinTransX = ConfigurationUtil.getConfigurationValue(xmlFile, key, steeringKey, "#nodeMinTransX", getXMLFloat, nil, nil, nil)
			wheel.steeringNodeMaxTransX = ConfigurationUtil.getConfigurationValue(xmlFile, key, steeringKey, "#nodeMaxTransX", getXMLFloat, nil, nil, nil)
			wheel.steeringNodeMinRotY = MathUtil.degToRad(ConfigurationUtil.getConfigurationValue(xmlFile, key, steeringKey, "#nodeMinRotY", getXMLFloat, nil, nil, nil))
			wheel.steeringNodeMaxRotY = MathUtil.degToRad(ConfigurationUtil.getConfigurationValue(xmlFile, key, steeringKey, "#nodeMaxRotY", getXMLFloat, nil, nil, nil))
	
			local fenderKey = wheelnamei .. ".fender"
			wheel.fenderNode = I3DUtil.indexToObject(self.components, ConfigurationUtil.getConfigurationValue(xmlFile, key, fenderKey, "#node", getXMLString, nil, nil, nil), self.i3dMappings)
			wheel.fenderRotMax = ConfigurationUtil.getConfigurationValue(xmlFile, key, fenderKey, "#rotMax", getXMLFloat, nil, nil, nil)
			wheel.fenderRotMin = ConfigurationUtil.getConfigurationValue(xmlFile, key, fenderKey, "#rotMin", getXMLFloat, nil, nil, nil)
	
			local steeringAxleKey = wheelnamei .. ".steeringAxle"
			wheel.steeringAxleScale = ConfigurationUtil.getConfigurationValue(xmlFile, key, steeringAxleKey, "#scale", getXMLFloat, 0, nil, nil)
			wheel.steeringAxleRotMax = MathUtil.degToRad(ConfigurationUtil.getConfigurationValue(xmlFile, key, steeringAxleKey, "#rotMax", getXMLFloat, 0, nil, nil))
			wheel.steeringAxleRotMin = MathUtil.degToRad(ConfigurationUtil.getConfigurationValue(xmlFile, key, steeringAxleKey, "#rotMin", getXMLFloat, -0, nil, nil))
	
			wheel.rotSpeed = MathUtil.degToRad(ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#rotSpeed", getXMLFloat, nil, nil, nil))
			wheel.rotSpeedNeg = Utils.getNoNilRad(ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#rotSpeedNeg", getXMLFloat, nil, nil, nil), nil)
			wheel.rotMax = MathUtil.degToRad(ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#rotMax", getXMLFloat, nil, nil, nil))
			wheel.rotMin = MathUtil.degToRad(ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#rotMin", getXMLFloat, nil, nil, nil))
	
			wheel.rotSpeedLimit = ConfigurationUtil.getConfigurationValue(xmlFile, key, physicsKey, "#rotSpeedLimit", getXMLFloat, nil, nil, nil)
		else
			g_logManager:xmlWarning(self.configFileName, "Invalid repr for wheel '%s'. Needs to be a child of a collision!", key..physicsKey)
		end
	else
		g_logManager:xmlWarning(self.configFileName, "Invalid repr for wheel '%s'!", key..physicsKey)
	end
    return true
end


-----------------------------------------------------------------------------------	
-- Edited update wheel sink
-----------------------------------------------------------------------------------
function REA:REAupdateWheelSink(wheel, dt)
    if wheel.supportsWheelSink then
        if self.isServer and self.isAddedToPhysics then
            local spec = self.spec_wheels

			-- Get wheel speed
			local WheelSpeed = 0;
			if wheel.RollingDirectionSpeed ~= nil and wheel.SideWaySpeed ~= nil and wheel.xDriveLastMeterPerSecond ~= nil then
				WheelSpeed = math.max(wheel.RollingDirectionSpeed, wheel.SideWaySpeed, math.max(wheel.xDriveLastMeterPerSecond * 3.6,5));
			else
				WheelSpeed = self:getLastSpeed();
			end;
			-- Sink update min speed
			local MinWheelSpeed = 0.1

            -- map noise to an asbolute value or to a certain percentage of the wheel radius?
            local maxSink = 0.20
            local sinkTarget = 0

            if wheel.mirroredWheel == nil then
                for _, mirWheel in ipairs(spec.wheels) do
                    if mirWheel.mirroredWheel == nil and mirWheel ~= wheel then -- only the first wheel got the mirrored one
                        local x1, y1, z1 = localToLocal(wheel.node, wheel.repr, 0, 0, 0)
                        local x2, y2, z2 = localToLocal(wheel.node, mirWheel.repr, 0, 0, 0)
                        local diff = math.abs(x1-(-x2)) + math.abs(y1-y2) + math.abs(z1-z2)
                        if diff < 0.25 then
                            wheel.mirroredWheel = mirWheel
                            mirWheel.invMirroredWheel = wheel
                        end
                    end
                end
            end

            local force = false
			-- Min force for adjusting sink
			if WheelSpeed >= MinWheelSpeed then
				-- If wheel has contact add sink
				local noiseValue = 0
				if wheel.contact ~= Wheels.WHEEL_NO_CONTACT then
					wheel.avgSink = nil
					local width = 0.25 * wheel.width
					local length = 0.25 * wheel.width
					local x,_,z = localToLocal(wheel.driveNode, wheel.repr, 0,0,0)
					local x0,_,z0 = localToWorld(wheel.repr, x + width, 0, z - length)
					local x1,_,z1 = localToWorld(wheel.repr, x - width, 0, z - length)
					local x2,_,z2 = localToWorld(wheel.repr, x + width, 0, z + length)
					local x,z, widthX,widthZ, heightX,heightZ = MathUtil.getXZWidthAndHeight(x0, z0, x1, z1, x2, z2)
					local density, area = FSDensityMapUtil.getFieldValue(x0, z0, x1, z1, x2, z2)
					local terrainValue = 0
					if area > 0 then
						terrainValue = math.floor(density/area + 0.5)
					end
					wheel.lastTerrainValue = terrainValue
					if terrainValue > 0 then
						local xPerlin = x + 0.5*widthX + 0.5*heightX
						local zPerlin = z + 0.5*widthZ + 0.5*heightZ
						-- REA: increased from 1cm to 2cm
						-- Round to 2cm to avoid sliding when not moving
						xPerlin = math.floor(xPerlin*100)*0.02
						zPerlin = math.floor(zPerlin*100)*0.02

						local perlinNoise;
						perlinNoise = Wheels.perlinNoiseSink
						local noiseSink = 0.5 * (1 + getPerlinNoise2D(xPerlin*perlinNoise.randomFrequency, zPerlin*perlinNoise.randomFrequency, perlinNoise.persistence, perlinNoise.numOctaves, perlinNoise.randomSeed))
						perlinNoise = Wheels.perlinNoiseWobble
						local noiseWobble = 0.5 * (1 + getPerlinNoise2D(xPerlin*perlinNoise.randomFrequency, zPerlin*perlinNoise.randomFrequency, perlinNoise.persistence, perlinNoise.numOctaves, perlinNoise.randomSeed))
	
						-- estimiate pressure on surface
						local gravity = 9.81
						local tireLoad = getWheelShapeContactForce(wheel.node, wheel.wheelShape)
						if tireLoad ~= nil then
							local nx,ny,nz = getWheelShapeContactNormal(wheel.node, wheel.wheelShape)
							local dx,dy,dz = localDirectionToWorld(wheel.node, 0,-1,0)
							tireLoad = -tireLoad*MathUtil.dotProduct(dx,dy,dz, nx,ny,nz)
							tireLoad = tireLoad + math.max(ny*gravity, 0.0) * wheel.mass -- add gravity force of tire
						else
							tireLoad = 0
						end
						tireLoad = tireLoad / gravity
						local loadFactor = math.min(1.0, math.max(0, tireLoad / wheel.maxLatStiffnessLoad))
						local wetnessFactor = g_currentMission.environment.weather:getGroundWetness()
						-- Id REA dynamic dirt is loaded and wheel in standing
						if REA.DynamicDirtActivated and wheel.InLowspotWithWater then
							wetnessFactor = 1;
						end;
						noiseSink = 0.333*(2*loadFactor + wetnessFactor) * noiseSink
						noiseValue = math.max(noiseSink, noiseWobble)
	
					end
				end
				-- Get max sink
				maxSink = Wheels.MAX_SINK[wheel.lastTerrainValue] or maxSink
				local WheelRadiusMaxSink = REA.WheelRadiusMaxSinkFactor*wheel.radiusOriginal;


				-- plowing effect
				if wheel.lastTerrainValue == 2 and wheel.oppositeWheelIndex ~= nil then
					local oppositeWheel = spec.wheels[wheel.oppositeWheelIndex]
					if oppositeWheel.lastTerrainValue ~= nil and oppositeWheel.lastTerrainValue ~= 2 then
						maxSink = maxSink * 1.3
					end
				end

				-- Minimum max sink if wheel is in lowspot with water
				local SinkOfLowSpot = 0.1;
				if REA.DynamicDirtActivated and wheel.InLowspotWithWater then
					maxSink = math.max(maxSink,SinkOfLowSpot);
				end;

				-- Get ground type
				local groundType = 0;
				if wheel.densityType ~= nil and wheel.lastColor[4] ~= nil then
					local isOnField = wheel.densityType ~= 0;
					local depth = wheel.lastColor[4];
					groundType = WheelsUtil.getGroundType(isOnField, wheel.contact ~= Wheels.WHEEL_GROUND_CONTACT, depth);
				end;
				-- DEBUG
				--DebugUtil.drawDebugNode(wheel.driveNode, "max sink: " .. maxSink, false)

				------------------------------------------------------
				-- Sink from spinning the wheel
				------------------------------------------------------
				-- initialize sink from spinning the wheel without movement
				if wheel.SinkFromSpinning == nil then
					wheel.SinkFromSpinning = 0;
				end;
				-- Get expected and actual moved distance for wheel
				local ExpectedDistance,ActualDistance = REA:WheelDistanceFromXdrive(wheel,dt)
				-- Increas sink
				if wheel.contact ~= Wheels.WHEEL_NO_CONTACT and (groundType == 3 or groundType == 4) then
					if ExpectedDistance > ActualDistance then
						-- If sink has not reached the limit add more sink
						if wheel.SinkFromSpinning >= WheelRadiusMaxSink then
							-- Max sink reached
							wheel.SinkFromSpinning = WheelRadiusMaxSink;
						else
							-- Constant for sink per meter
							local AddSinkPerMeter = REA.TireTypeSinkPerMeterSpinning[wheel.tireType];
							-- Lower sink when not in field
							if wheel.densityType == 0 then
								AddSinkPerMeter = AddSinkPerMeter * 0.5;
							end;
							-- Calculate sink by spinning
							local DistanceDiff = ExpectedDistance - ActualDistance;
							local SinkToAddFromSpinning = DistanceDiff * AddSinkPerMeter;
							-- Increase sink when low
							local ExtraSinkFromSpinningFactor = 1;
							if wheel.SinkFromSpinning < (WheelRadiusMaxSink/2) and wheel.SinkFromSpinning > 0 then
								ExtraSinkFromSpinningFactor = 2 - (wheel.SinkFromSpinning / (WheelRadiusMaxSink/2));
							end;
							-- Add sink
							wheel.SinkFromSpinning = math.min(wheel.SinkFromSpinning + (SinkToAddFromSpinning * ExtraSinkFromSpinningFactor),WheelRadiusMaxSink);

							-- DEBUG
							--DebugUtil.drawDebugNode(wheel.driveNode, "factor: " .. ExtraSinkFromSpinningFactor, false)

						end;
					end;
				end;
				-- Decrease sink
				if ActualDistance > 0 then
					if wheel.SinkFromSpinning > 0 then
						-- Calculate how much sink should be lowered
						local MinDecreaseSinkPerMeter = 0.3;
						wheel.SinkFromSpinning = wheel.SinkFromSpinning - (ActualDistance * MinDecreaseSinkPerMeter);
					end;
					if wheel.SinkFromSpinning < 0 then
						wheel.SinkFromSpinning = 0;
					end;
				end;

				-- Sinktarget
				-- Sink fom wobble, max 65% of max sink
				local sinkTargetNoise = math.min(math.min(maxSink, wheel.maxWheelSink) * noiseValue, WheelRadiusMaxSink*0.65);
				-- Add sink from spinning
				sinkTarget = math.min(wheel.SinkFromSpinning+sinkTargetNoise, WheelRadiusMaxSink);

			else
				-- REA: removed the equalizing of sink when stoping as the vehicle makes a jump if done in field
				if wheel.sinkTarget ~= nil then
					sinkTarget = wheel.sinkTarget;
				else
					sinkTarget = 0;
				end
			end

            if wheel.sinkTarget < sinkTarget then
                wheel.sinkTarget = math.min(sinkTarget, wheel.sinkTarget + (0.05 * math.min(30, math.max(0, WheelSpeed-(MinWheelSpeed/2))) * (dt/1000)))
            elseif wheel.sinkTarget > sinkTarget then
                wheel.sinkTarget = math.max(sinkTarget, wheel.sinkTarget - (0.05 * math.min(30, math.max(0, WheelSpeed-(MinWheelSpeed/2))) * (dt/1000)))
            end

            if math.abs(wheel.sink - wheel.sinkTarget) > 0.001 or force then
                wheel.sink = wheel.sinkTarget

                local radius = wheel.radiusOriginal - wheel.sink
                if radius ~= wheel.radius then
                    wheel.radius = radius
                    if self.isServer then
                        self:setWheelPositionDirty(wheel)
                        local sinkFactor = (wheel.sink/maxSink) * (1 + (0.4 * g_currentMission.environment.weather:getGroundWetness()))
                        wheel.sinkLongStiffnessFactor = (1.0 - (0.10 * sinkFactor))
                        wheel.sinkLatStiffnessFactor  = (1.0 - (0.20 * sinkFactor))
                        self:setWheelTireFrictionDirty(wheel)
                    end
                end
            end
        end
    end
end


if REA.ModActivated == nil then
	addModEventListener(REA);
	REA.ModActivated = true;
	REA.FilePath = g_currentModDirectory;
	print("mod activated")

	-- Exchange standard GIANT'S functions for editet by REA
	-- Change Giant's "updateWheelSink" to "REAupdateWheelSink"
	Wheels.updateWheelSink = REA.REAupdateWheelSink;

	-- Standard functions exchanged
	print("New REA functions loaded")

end;


