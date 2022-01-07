@ no_experiment model CoVid19

import "Constants.gaml"

global {
	//geometry parameters
	file bound_shapefile <- file("../includes/department.shp");
	obj_file pple_walk<- obj_file("../includes/people.obj", 90::{-1, 0, 0});
	obj_file pple_lie <- obj_file("../includes/people.obj", 0::{-1, 0, 0});
	geometry shape <- envelope(bound_shapefile);
	float people_size <- 65.0;
	//quantity parameters
	int nb_people <- 100;
	int nb_doc <- 5;
	int nb_nurse <- 12;
	int nb_inpat <- 48;
	int nb_staff <- 10;
	int nb_intern <- 10;
	int nb_outpat <- 50;
	
	//daily routine parameters
	map<date, string> doctor_routine;
	map<date, string> nurse_routine;
	map<date, string> staff_routine;
	map<date, string> inpatient_routine;
	map<date, string> outpatient_routine;
	map<date, string> family_routine;
	map<date, string> intern_routine;
	int maximal_turn <- 90; //in degree
	int cohesion_factor <- 10;
	//	geometry free_space; 
	//	point target_point <- {shape.width, 0};
	//	geometry source <- circle(30) at_location {0, shape.height};
	float radius_check <- people_size*1.2;
	
	float rate <- 0.05/60;

	//simulation step
		float step <- 15 #seconds;
		date starting_date <- date([2020, 7, 1, 5, 0]);
	geometry free_space;
}