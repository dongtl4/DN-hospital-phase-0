@ no_experiment model CoVid19

import "Constants.gaml"

global {
	//geometry parameters
	file bound_shapefile <- file("../includes/department.shp");
	obj_file pple_walk<- obj_file("../includes/people.obj", 90::{-1, 0, 0});
	obj_file pple_lie <- obj_file("../includes/people.obj", 0::{-1, 0, 0});
	geometry shape <- envelope(bound_shapefile);
	float people_size <- 65.0; //asume that people size is 1.7m
	//quantity parameters
	int nb_people <- 100;
	int nb_doc <- 5;
	int nb_nurse <- 12;
	int nb_inpat <- 48;
	int nb_staff <- 10;
	int nb_intern <- 10;
	int nb_outpat <- 50;
	
	//daily routine parameters
	//it map list (hour, minute) with name of action
	map<list, string> doctor_routine <- [[5, 20]::'relax', [6, 0]::'meeting', [7, 0]::'see_intpatient', [8, 0]::'main work', [11,30]::'relax', [13,30]::'main work', [17, 0]::'end work'];
	map<list, string> nurse_routine <- [[5, 20]::'relax', [6, 0]::'meeting', [7, 0]::'see_intpatient', [8, 0]::'main work', [11,30]::'relax', [13,30]::'main work', [17, 0]::'end work'];
	map<list, string> staff_routine <- [[7, 20]::'see_intpatient', [8, 0]::'main work', [11,30]::'relax', [13,30]::'main work', [16, 30]::'end work'];
	map<list, string> inpatient_routine <- [[9,0]::'wander', [11,0]::'lay down', [14,0]::'wander', [18,0]:: 'lay down', [20, 0]:: 'wander', [22,0]:: 'lay down'];
	map<list, string> outpatient_routine; //special species, appear randomly and not have daily routine
	map<list, string> family_routine <- [[6,10]:: 'go out', [6, 30]:: 'take care', [7, 0]:: 'wait outside', [8,0]:: 'take care', [9, 0]::'own stuff', [11,10]::'go out', [11, 40]:: 'take care', [13,0]::'own, stuff', [18, 10]:: 'go out', [18, 40]:: 'take care', [20,0]:: 'own stuff', [22,0]:: 'take care'];
	map<list, string> intern_routine; //not yet
	
	//display parameters
	int maximal_turn <- 90; //in degree
	int cohesion_factor <- 10;
	
	//epidemiology parameters
	float radius_check <- people_size*1.2;// about 2m
	float rate <- 0.2/60;

	//simulation step
	float step <- 15 #seconds;
	date starting_date <- date([2020, 7, 1, 5, 0]);
	geometry free_space;
}