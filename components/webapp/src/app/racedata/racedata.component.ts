import { Component, OnInit } from '@angular/core';

interface LapTimes {
	driver: string;
	interval: number;
	sector1: number;
  sector2: number;
  sector3: number;
  lap: number;
  tyre: string;
  lap_delta: number;
}

const LAPTIMES: LapTimes[] = [
	{
		driver: 'Some Driver',
		interval: -5,
		sector1: 30,
		sector2: 40,
    sector3: 50,
    lap: 120,
    tyre: 'H',
    lap_delta: -3
	},
	{
		driver: 'Some Other Driver',
		interval: -5,
		sector1: 30,
		sector2: 40,
    sector3: 50,
    lap: 120,
    tyre: 'H',
    lap_delta: -3
	}
];

interface MyLaps {
	type: string;
	sector1: number;
  sector2: number;
  sector3: number;
  lap: number;
}

const MY_LAPS: MyLaps[] = [
	{
		type: 'Best',
		sector1: 30,
		sector2: 40,
    sector3: 50,
    lap: 120
	},
	{
		type: 'Last',
		sector1: 30,
		sector2: 40,
    sector3: 50,
    lap: 120
	}
];

@Component({
  selector: 'app-racedata',
  templateUrl: './racedata.component.html',
  styleUrls: ['./racedata.component.css']
})
export class RacedataComponent implements OnInit {
  title = 'Race Data';
  
  laptimes = LAPTIMES;
  my_laps = MY_LAPS;

  constructor() { }

  ngOnInit(): void {
  }

}
