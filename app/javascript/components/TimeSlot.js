import React from "react"
import PropTypes from "prop-types"
import PersonContact from "./PersonContact"

export default class TimeSlot extends React.Component {

	constructor (props) {
    super(props)
    this.state = {
    	id: props.id,
    	time: props.time,
    	people: props.people,
    	people_hash: props.people_hash,
    	is_admin: props.is_admin,
    	notes: props.notes,
    	authenticity_token: props.authenticity_token,
    	has_current: props.has_current
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
					<span className="ppl_list">
					   __({time.people})__
					</span>
				</a>

				<div className="list-grp-detail" id={"info-" + time.id}>
					<div className="contact-list">
					<span id={"notes_for" + time.id}>
						{ time.notes }
					</span>
						<div className="verbose_list">
							<div>
								{time.people_hash.map(function(elem, idx) {
										return (
												<div key={"contact_" + idx}>
													<PersonContact user_id={elem.id} name={elem.name} />
									    	</div>
											)
								})}
							</div>

							<a href="#" className='broadcast-message btn-wide btn btn-lg btn-primary btn-contact-grp' data-id={time.id} end-pt='/line_day/time_slots/broadcast_to_slot' data-identifier={"Wait shift: " + time.time} data-toggle="modal" data-target="#timeSlotContactModal">Broadcast a message to this group</a>
						</div>
						{time.has_current ? 
								<form className="new_holder" id="new_holder" action="/holders/erase" acceptCharset="UTF-8"><input name="utf8" type="hidden" value="✓" /><input type="hidden" name="authenticity_token" value={time.authenticity_token} />

								  <div className="field form-group">
								    <input value={time.id} type="hidden" name="holder[line_day_time_slot_id]" id="holder_line_day_time_slot_id" />
								  </div>

								  <div className="actions">

								    <input type="submit" name="commit" value="Unassign youself" className="btn btn-md btn-wide btn-spec btn-primary" data-disable-with="un assigning You" />

								  </div>
								</form> 
							: 
							<form className="new_holder" id="new_holder" action="/holders" acceptCharset="UTF-8" method="post"><input name="utf8" type="hidden" value="✓" /><input type="hidden" name="authenticity_token" value={time.authenticity_token} />

							  <div className="field form-group">
							    <input value={time.id} type="hidden" name="holder[line_day_time_slot_id]" id="holder_line_day_time_slot_id" />
							  </div>

							  <div className="actions">

							    <input type="submit" name="commit" value="Sign up for this wait shift" className="btn btn-md btn-wide btn-spec btn-primary" data-disable-with="Assigning You" />

							  </div>
							</form>
						}
					</div>

					<div>
					<a href="#" data-id={time.id} end-pt={"/line_day/time_slots/" + time.id} data-toggle="modal" data-target="#timeSlotEdit" className='modal-pop edit-slot btn-wide centered btn btn-lg btn-warning'>Edit</a>
					{ this.props.is_admin ? 
							<a href={"/line_day/time_slots/" + time.id} data-id={time.id} className='modal-pop btn-wide delete-slot centered btn btn-lg btn-danger'>Delete</a>
						:
						<div></div>
					}
					</div>
				

				</div>
    	</div>
    );
  }
}

