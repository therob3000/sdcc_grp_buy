import React from "react"
import PropTypes from "prop-types"
import TimeSlot from './TimeSlot'

export default class LineDaySchedule extends React.Component {

	constructor (props) {
    super(props)
    this.state = {
      day: props.day,
      slots: props.time_slots,
      is_admin: props.is_admin
    }
  }


  render () {
  	const data = this.state.slots;
  	const isAdmin = this.state.is_admin;
    return (
      <div>
      {data.map(function(time, idx){
         return (<TimeSlot time={time.time} people={time.people} id={time.id} authenticity_token={time.authenticity_token} is_admin={isAdmin} />)
       })}
      </div>
    );
  }
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <LineDaySchedule name="LineDaySchedule" />,
    document.body.appendChild(document.createElement('div')),
  )
})


