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

		create Doctor number: 5;
		create Nurse number: 20;
		create Inpatient number: 40;
	}
	
	reflex create_visitor when: every(1#mn) and current_date.hour > 7 {
//		create Visitor {}
	}
}