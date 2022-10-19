import { ComponentFixture, TestBed } from '@angular/core/testing';

import { RacedataComponent } from './racedata.component';

describe('RacedataComponent', () => {
  let component: RacedataComponent;
  let fixture: ComponentFixture<RacedataComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ RacedataComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(RacedataComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
