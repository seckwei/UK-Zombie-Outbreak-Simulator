DELIMITER $$
DROP PROCEDURE IF EXISTS spInfection$$
CREATE PROCEDURE spInfection(
	dName nvarchar(45))
    /*
    
    Name:			spInfection
    Description:	The main sproc called with in Backend.js.
    
    Outputs:		WeekNum Current Week number
					DistrictName Name of the Region
					Total Infected is the total infected in a 
                    reigion.
    
    */
BEGIN
	DECLARE CWeekNum int;
    DECLARE SpreadCount int;
    
    
    CREATE TABLE tmpResults (	WeekNum int,
											DistrictID int,
											DistrictName nvarchar(100),
                                            Longitude decimal(18,9),
                                            Latitude decimal (18,9),
                                            TotalPopulation int,
											TotalInfected int,
											Speed numeric(18,9),
                                            Multiplier numeric(18,9),
                                            Spread bit);
                                            
    SET CWeekNum = 0; 
    SET SpreadCount = 1;

    WHILE (CWeekNum < 52) DO
		IF (CWeekNum = 0) THEN
			INSERT INTO tmpResults (WeekNum, 
										DistrictID,
										DistrictName, 
                                        Longitude,
                                        Latitude,
                                        TotalPopulation,
										TotalInfected,
										Speed,
                                        Multiplier,
                                        Spread) 
				SELECT 	0, 
						D.ID,
						D.Name,
						D.Longitude,
						D.Latitude,
                        E.Employed+E.Unemployed,
						200,
                        D.StartSpeed,
                        D.Multiplier,
                        0
				FROM 	District D
						LEFT OUTER JOIN Employment E on E.DistrictID = D.ID
				WHERE	Name = dName;
		ELSE IF (CWeekNum < 26) THEN
         SET SpreadCount = SpreadCount +(SELECT COUNT(Spread) FROM tmpResults WHERE Spread = 1);
			IF EXISTS (SELECT * FROM tmpResults WHere Spread = 1 AND WeekNum = (SELECT MAX(WeekNum))) THEN
				INSERT INTO tmpResults (WeekNum, 
										DistrictID,
										DistrictName, 
                                        Longitude,
                                        Latitude,
									    TotalPopulation,
									    TotalInfected,
										Speed,
                                        Multiplier,
                                        Spread) 
					SELECT		DISTINCT CWeekNum,
								C.ToID,
								D.Name,
                                D.Longitude,
                                D.Latitude,
								E.Employed+E.Unemployed,
								20,
								D.StartSpeed,
								D.Multiplier,
								0
					FROM 		Commute C
                                LEFT OUTER JOIN District D ON C.ToID = D.ID
								LEFT OUTER JOIN Employment E on E.DistrictID = D.ID   
					ORDER BY 	C.Number DESC
					LIMIT 		5;
			END IF;
			INSERT INTO tmpResults (WeekNum, 
										DistrictID,
										DistrictName, 
                                        Longitude,
                                        Latitude, 
                                        TotalPopulation,
									    TotalInfected,
										Speed,
                                        Multiplier,
                                        Spread) 
				SELECT 	CWeekNum, 
						t.DistrictID,
						t.DistrictName, 
                        t.Longitude,
                        t.Latitude, 
                        t.TotalPopulation,
						t.TotalInfected * (t.Multiplier + 0.185),
                        CEILING(D.StartSpeed * (t.Multiplier + 0.185)),
                        (t.Multiplier * 0.989),
                        CASE 	WHEN (t.TotalPopulation/2) <= t.TotalInfected 
								THEN 1 
                                ELSE 0 
						END
				FROM 	District D
						LEFT OUTER JOIN tmpResults t ON t.DistrictID = D.ID
				WHERE	t.WeekNum = (SELECT MAX(WeekNum))
                   ORDER BY	WeekNum DESC
                limit SpreadCount;
               
		ELSE 
        SET SpreadCount = SpreadCount +(SELECT COUNT(Spread) FROM tmpResults WHERE Spread = 1);
			IF EXISTS (SELECT * FROM tmpResults WHere Spread = 1 AND WeekNum = (SELECT MAX(WeekNum))) THEN
				INSERT INTO tmpResults (WeekNum, 
										DistrictID,
										DistrictName, 
                                        Longitude,
                                        Latitude, 
									    TotalPopulation,
									    TotalInfected,
										Speed,
                                        Multiplier,
                                        Spread) 
					SELECT		DISTINCT CWeekNum,
								C.ToID,
								D.Name,
                                D.Longitude,
                                D.Latitude,
								E.Employed+E.Unemployed,
								20,
								D.StartSpeed,
								D.Multiplier,
								0
					FROM 		Commute C
                                LEFT OUTER JOIN District D ON C.ToID = D.ID
								LEFT OUTER JOIN Employment E on E.DistrictID = D.ID   
					ORDER BY 	C.Number DESC
					LIMIT 		5;
			END IF;
            
			INSERT INTO tmpResults (WeekNum, 
										DistrictID,
										DistrictName, 
                                        Longitude,
                                        Latitude, 
									    TotalPopulation,
									    TotalInfected,
										Speed,
                                        Multiplier,
                                        Spread) 
				SELECT 	CWeekNum, 
						t.DistrictID,
						t.DistrictName, 
                        t.Longitude,
                        t.Latitude,
                        t.TotalPopulation,
						t.TotalInfected,
						CEILING(D.StartSpeed * t.Multiplier),
                        (t.Multiplier * 0.989),
                        CASE 	WHEN (t.TotalPopulation/2) <= t.TotalInfected 
								THEN 1 
                                ELSE 0 
						END
				FROM 	District D
						LEFT OUTER JOIN tmpResults t ON t.DistrictID = D.ID
				WHERE	t.WeekNum = (SELECT MAX(WeekNum))
                ORDER BY	WeekNum DESC
                limit SpreadCount;
               

				-- UPDATE tmpResults Set TotalInfected = -- (SELECT a.TotalInfected * b.Multiplier FROM tmpResults a LEFT OUTER JOIN tmpResults b ON a.DistrictID = b.DistrictID WHERE a.WeekNum = (SELECT MAX(a.WeekNum)) AND b.WeekNum = CWeekNum);
		END IF;
		END IF;
		SET CWeekNum = CWeekNum + 1;
    END WHILE;
				
	SELECT	*
    FROM	tmpResults;

    DROP TABLE tmpResults;
    
END$$

CALL spInfection("Gloucester");