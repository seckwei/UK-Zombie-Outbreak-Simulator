var mysql      = require('mysql');

var connection = mysql.createConnection({
  host     : '188.121.44.185',
  user     : 'hacksheffield',
  password : '123456789',
  database : 'HackSheffield'
});


var DistrictPopulation = {};
var DistrictStart = {};
 
connection.connect();
connection.query('select d.Name, e.Employed + e.Unemployed as Population, e.Unemployed,e.RankIncome, d.StartSpeed, d.Multiplier from Employment e inner join District d on d.id = e.DistrictID' , function(err, rows, fields) {
	if (err) throw err;
	 	for (var i = rows.length - 1; i >= 0; i--) {
		 	
		 	var name = rows[i].Name;
		 	//console.log(name);

		 	DistrictPopulation[name] = 
			 							{
											Population: rows[i].Population,
										  	Unemployed: rows[i].Unemployed,
										  	Multiplier: rows[i].Multiplier
										};

			DistrictStart[name] = 
									{
									  	RankIncome: rows[i].RankIncome,
									  	StartSpeed: rows[i].StartSpeed,
									  	currentSpeed: 0,
									  	currentMultiplier: 0			  	
									};
	 	}

	 	var input = 'Gloucester'
	 	var total = 0;
	 	var percent = 0.989;
	 	DistrictStart[input].currentSpeed = DistrictStart[input].StartSpeed


	 	DistrictStart[input].currentMultiplier = DistrictPopulation[input].Multiplier
	 	DistrictStart[input].currentSpeed = DistrictStart[input].StartSpeed

	 	
	 	console.log();
	 	console.log(input);
	 	console.log(DistrictPopulation[input]);
	 	console.log(DistrictStart[input]);
	 	console.log();



	 	for (var i = 1; i <= 52; i++) {
	 		
		 	if(total < DistrictPopulation[input].Population)
		 	{
		 		//for (var t = 1; t <= 7; t++) {
		 		if(i<26)
		 			DistrictStart[input].currentSpeed = Math.ceil(DistrictStart[input].currentSpeed*(DistrictStart[input].currentMultiplier+0.185))
		 		else
		 			DistrictStart[input].currentSpeed = Math.ceil(DistrictStart[input].currentSpeed*DistrictStart[input].currentMultiplier)
		 		//}

				total += DistrictStart[input].currentSpeed
		 		
		 		
		 		DistrictStart[input].currentMultiplier = DistrictStart[input].currentMultiplier*percent
		 	}

		 	if(total > DistrictPopulation[input].Population)
		 	{
		 		total = DistrictPopulation[input].Population;
		 	}

		 	console.log('Week: ' + i + ' Speed: ' + DistrictStart[input].currentSpeed + ' Multiplier: ' + DistrictStart[input].currentMultiplier + ' Total: ' + total);
	 	}
	 	

	 	//if over so many move to next city
	 	//
	 	//
	 	//
	 	//

});


 
connection.end();



//(((((((start*Multiplier)*Multiplier)*Multiplier)*Multiplier)*Multiplier)*Multiplier)*Multiplier)



		