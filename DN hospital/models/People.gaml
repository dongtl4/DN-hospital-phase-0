model people_in_hospital

import "Parameters.gaml"
import "Boundary.gaml"
import "Hidden_Static.gaml"
import "Main.gaml"

//Species people which move to the evacuation point using the skill moving
species people skills: [moving] {
	admin_boundary myb;
	room cur_room;
	point target_loc <- nil;
	bool in_room <- false;
	float speed <- (0.5 + rnd(1000) / 1000)*15;
	point velocity <- {0, 0};
	float heading max: heading + maximal_turn min: heading - maximal_turn;
	bool infected <- false;
	float size <- people_size;
	bool out <- false;
	//	rgb color <- rgb(rnd(255), rnd(255), rnd(255));
	rgb color <- hsb(240 / 360, 0.5 + (rnd(5) / 10), 1);
	rgb mycolor <- #red;
	
	// 
	int come_in_hour;
	int come_in_minute;
	
	int counter <- 0;
	int max_counter <- 20;
	int current_status <- 0; //(0 = S, 1 = E, 2 = I, 3 = R, 4 = D)
	float exposed_time;
	
	//appear in the hospital
	reflex come_in when: out = true and current_date.hour = come_in_hour and current_date.minute = come_in_minute{
		do go_in;
	}
	reflex move when: target_loc != nil and out = false{
		do goto target: target_loc speed: speed;
//		do goto on: hidden_road target: target_loc speed: speed;
	}
	reflex target_come when: target_loc != nil and location distance_to target_loc <= people_size*0.6 and out = false{
		counter <- counter + 1;
		if(counter >= max_counter){
			target_loc <- nil;
			counter <- 0;
		}
	}
	
	reflex infect when: out = false and infected = true and current_status = 2{
		do infection;
	}
	reflex exposes when: current_status = 1{
		exposed_time <- exposed_time - 1;
		if(exposed_time = 0){
			current_status <- 2;
		}
	}
	
	aspect default {
		if(out = false){
			draw pple_walk size: size  at: location + {0, 0, 1 + 35} rotate: heading - 90 color: color;
			if(infected){draw circle(radius_check/3)  at: location + {0, 0, 1 + 36} color:  mycolor;}
		}
		else{ draw pple_walk size: 0  at: location + {0, 0, 1 + 35};}
	}
	action infection{
		list pp <- [];
		add agents where(species(each) in [doctor, nurse, staff, inpatient, outpatient, family, interns]) at_distance(radius_check) to: pp all: true;
		//I don't know why I must list all subspecies of people there but can't using people.subspecies...
		write(pp);
		ask pp{
			if flip(rate){
				infected <- true;
				current_status <- 1;
				exposed_time <- gauss(3*5760, 1*5760);
				nb_infected <- nb_infected + 1;
			}
		}
	}
	action go_out{
		out <- true;
	}
	action go_in{
		out <- false;
	}
}

species doctor parent: people{
	rgb color <- #green;
	int come_in_hour <- 5;
	int come_in_minute <- rnd(30, 59);
	bool seeout <- false;
	int max_counter <- 40;
	
	//this will change to using map<activity, date> as input data of daily routine later
	reflex daily_routine when: out = false{
		if(current_date.hour = 5 and target_loc = nil){
			do relax;
		}
		if(current_date.hour in [6] and target_loc = nil){
			do meeting;
		}
		else if(current_date.hour = 7 and target_loc = nil){
			inpatient i <- any(inpatient);
			do see_inpatient(i);
		}
		else if(current_date.hour in [8,9,10,11] and target_loc = nil and seeout = false){
			do see_outpatient;
			seeout <- true;
		}
		else if(current_date.hour = 12 and target_loc = nil){
			do relax;
			seeout <- false;
		}
		else if(current_date.hour in [13,14,15,16] and target_loc = nil and seeout = false){
			do see_outpatient;
			seeout <- true;
		}
		else if(current_date.hour in [17,18,19,20,21,22,23,0,1,2,3,4] and target_loc = nil){
			do go_out;
		}
	}
	
	action meeting{
		target_loc <- any_location_in(first(room where (each.type = 'meeting')));
		cur_room <- first(room where (each.type = 'meeting'));
	}
	action see_inpatient(inpatient i){
		target_loc <- i.mybed.location;
		cur_room <- i.cur_room;
	}
	action see_outpatient{
		cur_room <- any(room where (each.type = 'outpatient'));
		target_loc <- any_location_in(cur_room);
	}
	action relax{
		cur_room <- first(room where (each.type = 'doctor'));
		target_loc <- any_location_in(cur_room);
	}
}

species nurse parent: people{
	rgb color <- #blue;
	int come_in_hour <- 5;
	int come_in_minute <- rnd(30, 59);
	int max_counter <- 40;
	reflex daily_routine when: out = false{
		if(current_date.hour = 5 and target_loc = nil){
			do relax;
		}
		if(current_date.hour in [6] and target_loc = nil){
			do meeting;
		}
		else if(current_date.hour = 7 and target_loc = nil){
			inpatient i <- any(inpatient);
			do see_inpatient(i);
		}
		else if(current_date.hour in [8, 9] and target_loc = nil){
			room r <- any(room where (each.type = 'inpatient'));
			do pass_medicine(r);
		}
		else if(current_date.hour in [10, 11] and target_loc = nil){
			do execute_medical_command;
		}
		else if(current_date.hour = 12 and target_loc = nil){
			do relax;
		}
		else if(current_date.hour = 13 and target_loc = nil){
			room r <- any(room where (each.type = 'inpatient'));
			do pass_medicine(r);
		}
		else if(current_date.hour in [14,15,16] and target_loc = nil){
			do execute_medical_command;
		}
		else if(current_date.hour in [17,18,19,20,21,22,23,0,1,2,3,4] and target_loc = nil){
			do go_out;
		}
	}	
	
	action meeting{
		target_loc <- any_location_in(first(room where (each.type = 'meeting')));
		cur_room <- first(room where (each.type = 'meeting'));
	}
	action see_inpatient(inpatient i){
		target_loc <- i.mybed.location;
		cur_room <- i.cur_room;
	}
	action pass_medicine(room r){
		target_loc <- any_location_in(r);
		cur_room <- r;
	}
	action relax{
		cur_room <- first(room where (each.type = 'nurse'));
		target_loc <- any_location_in(cur_room);
	}
	action execute_medical_command{
		cur_room <- any(room);
		target_loc <- any_location_in(cur_room);
	}
}

species staff parent: people{
	rgb color <- #blue;
	int max_counter <- 60;
	int come_in_hour <- 7;
	int come_in_minute <- rnd(30, 59);
	reflex daily_routine when: out = false{
		if (current_date.hour in [7,8,9,10,11] and target_loc = nil){
			do clean;
		}
		else if (current_date.hour in [12] and target_loc = nil){
			cur_room <- any(room where (each.type = nil));
			target_loc <- any_location_in(cur_room);
		}
		else if(current_date.hour in [13,14,15,16] and target_loc = nil){
			do clean;
		}
		else if(current_date.hour in [17,18,19,20,21,22,23,0,1,2,3,4,5,6] and target_loc = nil){
			do go_out;
		}
	}
	
	action clean{
		cur_room <- any(room);
		target_loc <- any_location_in(cur_room);
	}
}

species inpatient parent: people {
	rgb color <- #yellow;
	beds mybed;
	bool liedown <- true;
	reflex daily_routine when: out = false{
		if(current_date.hour in [9, 10, 14, 15, 16, 17, 20, 21] and target_loc = nil){
			do wander_in_room;
		}
		else if(not(current_date.hour in [9, 10, 14, 15, 16, 17, 20, 21]) and target_loc = nil){
			do lie_in_bed;
		}
	}
	
	action lie_in_bed{
		target_loc <- mybed.location;
		liedown <- true;
	}
	action wander_in_room{
		target_loc <- any_location_in(cur_room);
		liedown <- false;
	}
	aspect lay_down {
		if(liedown){
			draw pple_lie size: size  at: location + {0, 0, 1 + 35} rotate: 0 color: color;
			if(infected){draw circle(20)  at: location + {0, 0, 1 + 36} color:  mycolor;}
		}
		else{ draw pple_walk size: size  at: location + {0, 0, 1 + 35};}
		//draw sphere(size / 3) at: {location.x, location.y, size * 0.75} color: color;
	}
}

species family parent: people{
	bool wait <- false;
	rgb color <- #violet;
	reflex daily_routine when: out = false{
		if (current_date.hour = 7 and target_loc = nil and wait = false){
			do wait_out_side;
			wait <- true;
		}
		else if(current_date.hour = 8 and target_loc = nil){
			max_counter <- 40;
			wait <- false;
			do take_care;
		}
		else if(current_date.hour in [9, 10] and target_loc = nil){
			max_counter <- 40;
			do wander_in_room;
		}
		else if(current_date.hour = 11 and target_loc = nil){
			do go_out;
			come_in_hour <- 12;
			come_in_minute <- rnd(0, 20);
		}
		else if(current_date.hour in [12, 13] and target_loc = nil){
			max_counter <- 240;
			do take_care;
		}
		else if(current_date.hour in [14,15,16] and target_loc = nil){
			max_counter <- 40;
			do wander_in_room;
		}
		else if(current_date.hour = 17 and target_loc = nil){
			do go_out;
			come_in_hour <- 18;
			come_in_minute<- rnd(0,20);
		}
		else if(current_date.hour in [18,19] and target_loc = nil){
			max_counter <- 240;
			do take_care;
		}
		else if(current_date.hour in [20,21] and target_loc = nil){
			max_counter <- 40;
			do wander_in_room;
		}
		else if(current_date.hour in [22,23,24,0,1,2,3,4] and target_loc =nil){
			max_counter <- 240;
			do take_care;
		}
		else if(current_date.hour = 5  and current_date.minute = 30 and target_loc = nil){
			do go_out;
			come_in_hour <- 6;
			come_in_minute<- rnd(0,10);
		}
		else if(current_date.hour = 6 and target_loc = nil){
			max_counter <- 40;
			do take_care;
		}
	}
	
	
	inpatient pple_sicked;
	benches bench;
	action wait_out_side{
		bench <- one_of(benches where(each.occupied = false));
		bench.occupied <- true;
		target_loc <- bench.location;
		cur_room <- nil;
	}
	action take_care{
		bench.occupied <- false;
		target_loc <- pple_sicked.mybed.location + {20,20,0};
		cur_room <- pple_sicked.cur_room;		
	}
	action wander_in_room{
		target_loc <- any_location_in(pple_sicked.cur_room);
	}
}

species outpatient parent: people{
	rgb color <- #orange;
	bool waited <- false;
	bool saw <- false;
	reflex daily_routine when: out = false{
		if(waited = false and target_loc = nil){
			do wait;
			waited <- true;
		}		
		else if(waited = true and saw = false and target_loc = nil and not(current_date.hour in [12,17])){
			bench.occupied <- false;
			do see_doctor;
			saw <- true;
		}
		if(saw and target_loc = nil){
			do die;
		}
	}	
	
	benches bench;
	doctor doc;
	action see_doctor{
		target_loc <- doc.location + {30,30};
		cur_room <- doc.cur_room;
	}
	action wait{
		bench <- one_of(benches where(each.occupied = false));
		bench.occupied <- true;
		target_loc <- bench.location;
	}
}

species interns parent: people{
	int come_in_hour <- 7;
	int come_in_minute <- rnd(30, 59);
	rgb color <- #blue;
	reflex daily_routine when: out = false{
		
	}
	
	
	action wandering{
		cur_room <- one_of(room where (each.type = 'inpatient'));
		target_loc <- any_location_in(cur_room);
	}
}