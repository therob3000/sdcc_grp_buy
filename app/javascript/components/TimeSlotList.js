import React from "react"
import PropTypes from "prop-types"
import TimeSlot from './TimeSlot'


export const TimeSlotList = ({times}) => 
  <div id='time_slots'>
    {times.map(function(time) {
      return (
        <TimeSlot time={time.time} people={time.people} />
      )
    })}		
  </div>

