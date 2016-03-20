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
    DECLARE CMultiplier numeric(18,9);
    
    CREATE TABLE tmpResults (	WeekNum int,
											DistrictID int,
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
                                        TotalPopulation,
										TotalInfected,
										Speed,
                                        Multiplier,
                                        Spread) 
				SELECT 	0, 
						D.ID,
                        E.Employed+E.Unemployed,
						200,
                        D.StartSpeed,
                        D.Multiplier,
                        0
				FROM 	District D
						LEFT OUTER JOIN Employment E on E.DistrictID = D.ID
				WHERE	Name = dName;
		ELSEIF (CWeekNum < 26) THEN
			SET SpreadCount = CASE (SELECT COUNT(Spread) FROM tmpResults WHERE Spread = 1) WHEN 0 THEN 1 ELSE (SELECT COUNT(Spread) FROM tmpResults WHERE Spread = 1) END;
			IF EXISTS (SELECT * FROM tmpResults WHERE Spread = 1 AND WeekNum = CWeekNum - 1) THEN
            
				INSERT INTO tmpResults (WeekNum, 
										DistrictID,
									    TotalPopulation,
									    TotalInfected,
										Speed,
                                        Multiplier,
                                        Spread) 
					SELECT	    CWeekNum,
								C.ToID,
								E.Employed+E.Unemployed,
								20,
								D.StartSpeed,
								D.Multiplier,
								0
					FROM 		Commute C
                                LEFT OUTER JOIN District D ON C.ToID = D.ID
								LEFT OUTER JOIN Employment E on E.DistrictID = D.ID
					WHERE		NOT EXISTS (SELECT * FROM tmpResults WHERE DistrictID = D.ID)
					ORDER BY 	C.Number DESC
					LIMIT 		5;
				
			END IF;
			INSERT INTO tmpResults (WeekNum, 
										DistrictID,
                                        TotalPopulation,
									    TotalInfected,
										Speed,
                                        Multiplier,
                                        Spread) 
				SELECT 	CWeekNum, 
						t.DistrictID,
                        t.TotalPopulation,
						t.TotalInfected * ((t.Multiplier * 0.989) + 0.185),
                        CEILING(D.StartSpeed * ((t.Multiplier * 0.989) + 0.185)),
                        (t.Multiplier * 0.989),
                        CASE ((t.TotalPopulation/4) <= t.TotalInfected) 
								WHEN TRUE
									THEN 1 
								ELSE 0 
						END
				FROM 	District D
						LEFT OUTER JOIN tmpResults t ON t.DistrictID = D.ID
				WHERE	t.WeekNum = (SELECT MAX(WeekNum))
                AND		(
							SELECT 	t2.DistrictID 
                            FROM 	tmpResults t2 
                            WHERE 	t2.DistrictID = D.ID 
                            AND 	t2.WeekNum = CWeekNum
                            LIMIT	1
						) IS NULL
				ORDER BY	WeekNum DESC
				LIMIT 	SpreadCount;
               
		ELSE 
			SET SpreadCount = CASE (SELECT COUNT(Spread) FROM tmpResults WHERE Spread = 1) WHEN 0 THEN 1 ELSE (SELECT COUNT(Spread) FROM tmpResults WHERE Spread = 1) END;
				IF EXISTS (SELECT * FROM tmpResults WHERE Spread = 1 AND WeekNum = CWeekNum - 1) THEN
					INSERT INTO tmpResults (WeekNum, 
											DistrictID,
											TotalPopulation,
											TotalInfected,
											Speed,
											Multiplier,
											Spread) 
						SELECT		CWeekNum,
									C.ToID,
									E.Employed+E.Unemployed,
									20,
									D.StartSpeed,
									D.Multiplier,
									0
						FROM 		Commute C
									LEFT OUTER JOIN District D ON C.ToID = D.ID
									LEFT OUTER JOIN Employment E on E.DistrictID = D.ID
						WHERE		NOT EXISTS (SELECT * FROM tmpResults WHERE DistrictID = D.ID)   
						ORDER BY 	C.Number DESC
						LIMIT 		5;
				END IF;
     
				
				INSERT INTO tmpResults (WeekNum, 
											DistrictID,
											TotalPopulation,
											TotalInfected,
											Speed,
											Multiplier,
											Spread) 
					SELECT 	CWeekNum, 
							t.DistrictID,
							t.TotalPopulation,
							t.TotalInfected * (t.Multiplier * 0.989),
							CEILING(D.StartSpeed * (t.Multiplier * 0.989)),
							(t.Multiplier * 0.989),
							CASE ((t.TotalPopulation/4) <= t.TotalInfected) 
									WHEN TRUE
										THEN 1 
									ELSE 0 
							END
					FROM 	District D
							LEFT OUTER JOIN tmpResults t ON t.DistrictID = D.ID
					WHERE	t.WeekNum = (SELECT MAX(WeekNum))
                    AND		(
								SELECT 	t2.DistrictID 
								FROM 	tmpResults t2 
								WHERE 	t2.DistrictID = D.ID 
								AND 	t2.WeekNum = CWeekNum
                                LIMIT	1
							) IS NULL
					ORDER BY	WeekNum DESC
					LIMIT	 SpreadCount;
               

				-- UPDATE tmpResults Set TotalInfected = -- (SELECT a.TotalInfected * b.Multiplier FROM tmpResults a LEFT OUTER JOIN tmpResults b ON a.DistrictID = b.DistrictID WHERE a.WeekNum = (SELECT MAX(a.WeekNum)) AND b.WeekNum = CWeekNum);
		END IF;
		SET CWeekNum = CWeekNum + 1;
    END WHILE;
				
	SELECT	t.*,
			D.Name,
			D.Longitude,
            D.Latitude
    FROM	tmpResults t
    LEFT OUTER JOIN District D on D.ID = t.DistrictID;

    DROP TABLE tmpResults;
    
END$$

CALL spInfection("Gloucester");