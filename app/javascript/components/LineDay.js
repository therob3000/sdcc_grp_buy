import React from "react"
import PropTypes from "prop-types"
export default class LineDay extends React.Component {
	constructor (props) {
    super(props)
    this.state = {
    	user_id: props.user_id,
    	day: props.day,
    	description: props.description,
    	link: props.link
    }
  }
  render () {
    return (
    	<div>
				<a href={this.state.link} className='btn line-day btn-primary'>
					{this.state.day}
					<br/>
					{this.state.description}
				</a>
    	</div>
    );
  }
}
