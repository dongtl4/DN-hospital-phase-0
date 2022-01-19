/******************************************************************
* This file is part of COMOKIT, the GAMA CoVid19 Modeling Kit
* Relase 1.0, May 2020. See http://comokit.org for support and updates
* 
* Uitilities to create Building Individual agents.
* 
* Authors:Patrick Taillandier, Arnaud Grignard and Tri Huu Nguyen
* Tags: covid19,epidemiology,proxymix
******************************************************************/

model BuildingSyntheticPopulation

import "Entities/BuildingActivity.gaml"
import "Entities/Building Spatial Entities.gaml" 
import "Constants.gaml"
import "Entities/BuildingIndividual.gaml"
import "Entities/Hospital Individuals.gaml"

global {
		
	action create_people(int nb) {
		map<Room,list<date>> to_restaurant;
		map<Room,list<date>> to_multi_act;
		map<Room,date> end_school;
		
		if (agenda_scenario = "school day") {
			list<Room> classes <- Room where (each.type = classe);
			loop c over: classes {
				date lunch_time <- date(current_date.year,current_date.month,current_date.day,11, 10) add_seconds rnd(0, 10 #mn);
				date lunch_time_end <- lunch_time add_seconds rnd(40 #mn, 50 #mn);
				to_restaurant[c] <- [lunch_time, lunch_time_end];
				
				end_school[c] <- date(current_date.year,current_date.month,current_date.day,14, rnd(10)) ;
	
			}
			
			list<int> available_hour <- [8,9,10,12,13];
			loop while: not empty(classes) and not empty(available_hour) {
				int nb <- length(classes) = 3 ? 3 : rnd(2,3);
				list<Room> sc <- nb among classes;
				classes <- classes - sc;
				int h <- one_of(available_hour);
				available_hour >> h;
				date beg <-  date(current_date.year,current_date.month,current_date.day,h) ;
				date end <- beg add_hours 1;
				loop c over: sc {
					to_multi_act[c] <- [beg,end];
				}
			} 
		}

		
		create BuildingIndividual number: 0 {
			age <- rnd(3, 6);
			is_outside <- true;
			
			pedestrian_species <- [BuildingIndividual];
			//obstacle_species<-[Wall];
			
			do initialise_epidemio;
			
			map<date,BuildingActivity> agenda_day;
			
			location <- any_location_in (one_of(BuildingEntrance).init_place);
			working_place <- one_of (available_offices);
			
//			if (working_place = nil) {do die;}
//			working_place.nb_affected <- working_place.nb_affected + 1;
//			if not(working_place.is_available()) {
//				available_offices >> working_place;
//			}
			working_desk <- working_place.get_target(self,false);
		
			date cd <- current_date + rnd(arrival_time_interval);
			if (use_sanitation and not empty(sanitation_rooms) and flip(proba_using_before_work)) {
				agenda_day[cd] <- first(BuildingSanitation);
				agenda_day[cd + 10] <- first(BuildingWorking);
			} else {
				agenda_day[cd] <- first(BuildingWorking);
			}
			
			switch agenda_scenario {
				match "school day" {
					list<date> lunch_time <- to_restaurant[working_place];
					list<date> act_time <- to_multi_act[working_place];
					date end_day <- end_school[working_place];
					if (act_time[0] < lunch_time[0]) {
						agenda_day[act_time[0]] <-first(BuildingMultiActivity); 
						agenda_day[act_time[1]] <-first(BuildingWorking); 
					}
				
					agenda_day[lunch_time[0]] <-first(ActivityEatOutside) ;
					agenda_day[lunch_time[1]] <- first(BuildingWorking);
					
					if (act_time[0] > lunch_time[0]) {
						agenda_day[act_time[0]] <-first(BuildingMultiActivity); 
						agenda_day[act_time[1]] <-first(BuildingWorking); 
					}
					agenda_day[end_day] <- first(ActivityGoHome);
	
				} 
			}
			loop i from: 0 to: 5 {
				loop d over: agenda_day.keys {
					agenda_week[d add_days i] <- agenda_day[d];
				}
			}
			current_agenda_week <- copy(agenda_week);
		}	
		
				
		create Doctor number: 5;
		create Nurse number: 20;
		create Inpatient number: 40;
	}
	
	reflex create_outpatient when: every(10#mn) and current_date.hour > 7 {
		create Outpatient {}
	}
}