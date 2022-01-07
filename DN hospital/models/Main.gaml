model hospital

import "Parameters.gaml"
import "Boundary.gaml"
//import "Road.gaml"
import "People.gaml"
//import "Detected.gaml"
global {

	reflex start_game when: cycle = 0{
		create doctor number: nb_doc {
			cur_room <- any(room where (each.type ='doctor'));
			location <- any_location_in(cur_room);
			out <- true;
		}
		create nurse number: nb_nurse {
			cur_room <- any(room where (each.type = 'nurse'));
			location <- any_location_in(cur_room);
			out <- true;
		}
		create staff number: nb_staff {
			location <- any_location_in(world);
			out <- true;
		}
		create inpatient number: nb_inpat {
			mybed <- any(beds where (each.occupied = false));
			mybed.occupied <- true;
			cur_room <- first(room where (overlaps(each, mybed) = true));
			location <- mybed.location;
		}
				//create interns number: nb_intern {}
		ask inpatient{
			create family number: 1{
				pple_sicked <- myself;
				location <- myself.location + {0,50,0};
				target_loc <- nil;
			}
		}
		ask any(family){
			infected <- true;
			current_status <- 2;
		}
//		ask any(inpatient){
//			infected <- true;
//		}

		//ask any(people) {
			//infected <- true;
		//}
	}
	
//	reflex outpatients_come when: current_date.hour in [8,9,10,11,13,14,15,16]{
//		if(flip(1/20)){
//			create outpatient number: 1{
//				doc <- any(doctor);
//				cur_room <- doc.cur_room;
//				max_counter <- rnd(60,120);
//				location <- any(door_point).location;
//			}
//		}
//	}
}

experiment main type: gui {
	float minimum_cycle_duration <- 0.01;
	output {
	//		layout #split toolbars: true tray: false navigator: false consoles: false tabs: false editors: false;
		display map type: opengl background: #black {
			image file: "../images/department.png" refresh: false;
//			image file: "../images/ee.jpg" refresh: false;
//			species walk_path;
			species people;
			species inpatient aspect: lay_down;
			species doctor;
			species nurse;
			species staff;
			species family;
			species outpatient;
			species beds;
			species room transparency: 0.7;
			//species benches;
		}

	}

}

