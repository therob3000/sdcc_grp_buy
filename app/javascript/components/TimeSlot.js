import React from "react"
import PropTypes from "prop-types"

export default class TimeSlot extends React.Component {

	constructor (props) {
    super(props)
    this.state = {
    	id: props.id,
    	time: props.time,
    	people: props.people,
    	is_admin: props.is_admin,
    	authenticity_token: props.authenticity_token
    }
  }

  render () {
  	const time = this.state;
    return (
    	<div key={time.id}>
      	<a href="#" data-id={time.id} className='expand-slot btn btn-lg btn-primary time_slot centered'>
					<b>
				     {time.time}:  
					</b>
					    ({time.people})
				</a>

				<div className="list-grp-detail" id={"info-" + time.id}>
					<div className="contact-list">
						{ time.description }
						<form className="new_holder" id="new_holder" action="/holders" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="✓" /><input type="hidden" name="authenticity_token" value={time.authenticity_token} />

						  <div className="field form-group">
						    <label for="holder_line_day_time_slot_id">Line day time slot</label>
						    <input value="21" type="hidden" name="holder[line_day_time_slot_id]" id="holder_line_day_time_slot_id" />
						  </div>

						  <div className="actions">
						    <input type="submit" name="commit" value="Sign up for this wait shift" className="btn btn-md btn-primary" data-disable-with="Create Holder" />
						  </div>
						</form>
						<a href="#" className='broadcast-message btn btn-lg btn-primary' data-toggle="modal" data-target="#timeSlotContactModal">Broadcast a message to this group</a>
					</div>

					{ this.props.is_admin ? 
						<div>
							<a href="#" data-id={time.id} className='modal-pop edit-slot centered btn btn-lg btn-warning'>Edit</a>
							<a href={"/line_day/time_slots/" + time.id} data-id={time.id} className='modal-pop delete-slot centered btn btn-lg btn-danger'>Delete</a>
						</div>
						:
						<div></div>
					}
				

				</div>
    	</div>
    );
  }
}

