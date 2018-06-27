import React from "react"
import PropTypes from "prop-types"
import TimeSlot from './TimeSlot'

export default class LineDaySchedule extends React.Component {

	constructor (props) {
    super(props)
    this.state = {
      day: props.day,
      slots: props.time_slots,
      is_admin: props.is_admin,
      children: []
    }

    this.closeAll = this.closeAll.bind(this);
  }

  closeAll() {
    const that = this;
    const children = this.refs;
    for (var i in children) {
      children[i].closeBox();
    }
  }

  render () {
    const data = this.state.slots;
  	const isAdmin = this.state.is_admin;
    const that = this;
    return (
      <div>
      {data.map(function(time, idx){
        return ( 
          <TimeSlot key={time.id} time={time.time} people={time.people} id={time.id} authenticity_token={time.authenticity_token} is_admin={isAdmin} notes={time.notes} has_current={time.has_current} people_hash={time.people_hash} ref={time.id} onChange={that.closeAll} />
          );
       })}
      </div>
    );
  }
}


