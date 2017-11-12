$(document).ready(function() {
	if (group_id == 'undefined' && group_id != 'master_tab') {
		return;
	}
  $('body').on('click', '.form-check-stacked', function(event) {
    var checkBox = $(this).find('input[type="checkbox"]');
    checkBox.trigger('click');
    if (checkBox.is(':checked')) {
      $(this).css('background-color','#fd7777');
      $(this).css('color','white');
    } else { 
      $(this).css('background-color','#3c8dbc');
      $(this).css('color','black');
    }
  });

	$('body').on('submit', '#create-member-form', function(event) {
		event.preventDefault();
		// create the member.
		$.ajax({
			url: '/members/register_member',
			type: 'POST',
			data: $(this).serialize(),
		})
		.done(function(data) {
			if (data.success) {
				// register the member to the group.
				$('#new-member-form').slideUp(500);
				$('#create-member-form').trigger('reset');
				regMember($('#reg-member').serialize());
				$(this).trigger('reset');
				$('.add-member-footer .btn').trigger('click');
			} else {
				populateErrors(data.message);
			}
		})		
	});
	$("body").on('click', '.cancel-this', function(event) {
		event.preventDefault();
		dispatcher.trigger('deactivate_member', { member_id: $(this).attr('member-id'), connection: connectionID });
		// switch out buttons
		$('.active-button-' + $(this).attr('member-id')).fadeOut(500, function() {
			$('.activate-button-for' + $(this).attr('member-id')).fadeIn(1000);
		});

		$(".member_groups_marker_" + $(this).attr('member-id')).removeClass('member_active');
	});
	$("body").on('click', '.confirm-this', function(event) {
		event.preventDefault();
		$.ajax({
			url: '/members/present_confirmation_partial',
			data: {member_id: $(this).attr('member-id'), mem_group_id: $(this).attr('data-id')},
		})
		.done(function(data) {
			$('#confirmation-body').html(data);
		})
	});

	$('body').on('click', '.iam', function(event) {
		event.preventDefault();
		$.ajax({
			url: '/members/find_me',
			data: {email: $(this).attr('my_email')},
		})
		.done(function(data) {
			$('input[name="conf[covering_id]"]').val(data.member_id);
		})
		
		updateCoveredName();
	});

	$('body').on('click', '.another', function(event) {
		event.preventDefault();
		$('#cover_member_box').slideDown(1000, function() {});
	});


	$('body').on('click', '#browse-for-members', function(event) {
		event.preventDefault();
		toggleDis($('.browse-control'),500);
	});

	var toggleDis = function(element, speed){
		if (element.css('display') == 'none') {
			element.slideDown(speed, function() {});
		} else {
			element.slideUp(speed, function() {});
		}

	}

	$('body').on('click', '.member-list-results .list-member .smaller_member_item', function(event) {
		// debugger
		event.preventDefault();
		var member_id = $(this).attr('data-id');
		$('input[name="conf[covering_id]"]').val(member_id);
		updateCoveredName();
	});

	$('body').on('click', '.member-list-results-add-member .list-member .smaller_member_item', function(event) {
		event.preventDefault();
		var member_id = $(this).attr('data-sdcc-id');
		$('input[name="sdcc_member_id"]').val(member_id);
		// registermember
		regMember($('#reg-member').serialize());
		// click close
		$('.browse-control').slideUp(500);
		$('.add-member-footer .btn').trigger('click');
	});

	$('body').on('submit', '.member-coverage-form', function(event) {
		event.preventDefault();
		var data = $(this).serialize();

		$('.conf-modal-footer').fadeOut(500, function() {
			$('.working-message-conf').fadeIn(500);
		});

		$.ajax({
			url: $(this).attr('action'),
			type: 'POST',
			data: data,
		})
		.done(function(data) {
			getGroupCount();
			$('.working-message-conf').fadeOut(500, function() {
				$('.conf-modal-footer').fadeIn(500);
			});
			if (data.success) {
				dispatcher.trigger('cover_member', { 
					member_id: data.member_id,
					member_group_id:data.member_group_id,
					group_id:data.group_id,
					groups:data.groups, 
					connection: connectionID
				});
				$('.member-coverage-form').trigger('reset');
				$('.close-this-modal').trigger('click');
			} else {
				if (data.email_status == 'failed') {
					$('.member-coverage-form').trigger('reset');

					dispatcher.trigger('cover_member', { 
						member_id: data.member_id,
						member_group_id:data.member_group_id,
						group_id:data.group_id,
						groups:data.groups, 
						connection: connectionID
					});
					$('.close-this-modal').trigger('click');
				} else {
					alert(data.message)
				}
			}
		})
	});

	$('body').on('click', '#confirm-trigger', function(event) {
		event.preventDefault();
		$('.member-coverage-form').trigger('submit');
	});

	function updateCoveredName(){
		var val = $('input[name="conf[covering_id]"]').val();
		if (val == '') {
			$('#cover_name').html('<b>You</b> are Covering this user');
		} else {
			$.ajax({
				url: '/members/find_member_name',
				data: {id: val},
			})
			.done(function(data) {
				$('#cover_name').html('<b>' + data.name + '</b> will cover this member');
			})
		}
	}

  $('body').on('keyup', '#m_modal_search', function(event) {
    event.preventDefault();
    var phrase = $(this).val();
    performSearchInModal('cover',phrase);
  });

  $('body').on('keyup', '#am_modal_search', function(event) {
    event.preventDefault();
    var phrase = $(this).val();
    performSearchInModal('add',phrase);
  });

	function performSearchInModal(type_search,search_phrase){
    // var phrase = $("#m_modal_search").val();
    var phrase = search_phrase;

    $.ajax({
      url: '/members/search_smaller',
      data: {search: phrase, type_search: type_search, group: group_id},
    })
    .done(function(data) {
      $('.member-list-results').html(data);
      $('.member-list-results-add-member').html(data);
    })    
  }


	$("body").on('click', '.activate', function(event) {
		event.preventDefault();
		dispatcher.trigger('activate_member', { member_id: $(this).attr('member-id'), connection: connectionID});
		$(this).fadeOut(1000, function() {
			$(this).parent('').find('.active-button').fadeIn(1000);
		});

		$(".member_groups_marker_" + $(this).attr('member-id')).addClass('member_active');
	});


	$("body").on('submit', '#reg-member', function(event) {
		event.preventDefault();
		regMember($(this).serialize());

	});

	$("body").on('click', '.remove-this-user', function(event) {
		event.preventDefault();
		$(this).text('removing');
		$(this).attr('disabled', true);
		var mb_id = $(this).attr('data-id');
		removeMemberFromDom(mb_id);		
	});

	$('body').on('click', '.buy-ticket', function(event) {
		event.preventDefault();
		var mem_id = $(this).attr('data-id');
		var need_id = $(this).attr('need-id');
		var member_group_id = $(this).attr('member_group_id');
		
		coverMember(mem_id, need_id, member_group_id, group_id);
	});

	function regMember(dataSend){
		$.ajax({
			url: '/members/register_member_to_group',
			method: 'POST',
			data: dataSend,
		})
		.done(function(data) {
			if (data.success == true) {
				$("#reg-member").trigger('reset');
				var obj = {connection: connectionID, room: group_id, member_id: data.member_id, member_group_id: data.member_group_id}
				$('.add-member-footer .btn').trigger('click');
				dispatcher.trigger('register_member', obj);
			} else {
				if (data.new_member) {
					$('#new-member-form').slideDown('500', function() {
						var sdcc_num = $('#sdcc_member_id_holder').val();
						$('#sdcc_member_id_holder_create').val(sdcc_num);
					});
				} else {
					populateErrors(data.message);
				}
			}
		})
	}

	var coverMember = function(member_id, need_id, member_group_id, group_id){
		$.ajax({
			url: '/members/cover_member',
			data: {member_id: member_id, need_id: need_id, member_group_id: member_group_id, group_id: group_id},
		})
		.done(function(data) {
			getGroupCount();
			if (data.success) {
				var obj = {connection: connectionID, member_group_id: data.member_group_id, groups: data.groups, group_id: data.group_id};
				dispatcher.trigger('cover_member', obj);
			} else {
				// populateErrors(data.message);
			}
		})
		
	}

  var removeMemberFromDom = function(member_group_id) {
    $.ajax({
    	url: '/members/remove_member',
    	method: 'DELETE',
    	data: {mem_grp_id: member_group_id, grp_id: group_id},
    })
    .done(function(data) {
    	if (data.success) {
			  	var obj = {connection: connectionID, room: group_id, member_group_id: data.message}
					dispatcher.trigger('unregister', obj);
					setTimeout(function(){
						getGroupCount();
					},1000)
			
    	}
    })
  }

  var getGroupCount = function (){
		setTimeout(function(){
	  	$.ajax({
	  		url: '/groups/get_count',
	  		data: {group_id: group_id},
	  	})
	  	.done(function(data) {
				dispatcher.trigger('group_updated', {count: data.count, room: group_id});
	  	})
		},500);
  }

  var addMemberToDom = function(message) {
    var member_group_id = message.member_group_id;
    $.ajax({
    	url: '/groups/present_member',
    	data: {mem_grp_id: member_group_id, grp_id: group_id},
    })
    .done(function(data) {
    	$("#member-list").append(data);
    	if (dispatcher.state == 'connected') {
    		$('.web_socket_loading').fadeIn(500);
    	}
    	getGroupCount();
    })
  }

  var success = function(response) {
	  console.log("Wow it worked: ", response);
	}

	var failure = function(response) {
		  console.log("That just totally failed: ", response);
	}


	function startDispatch(){
	  dispatcher = new WebSocketRails(server_location + "/" + "websocket");
	  dispatcher.on_open = function(data) {
	  	$('.loading').fadeOut(500, function() {
	  		$('.web_socket_loading').fadeIn(500, function() {
	  		});
	  	});
	  	if (!activeDispatcher) {
	  		// return;
		    console.log('Connection has been established: ', data);
		    connectionID = data.connection_id;
		    connection = group_id;
		    group_room_conn = 'group_'+ connection;
		    channel = dispatcher.subscribe(group_room_conn);
		    channel_global = dispatcher.subscribe('global');
		    var room_create_success = group_room_conn + '_created';
		    activeDispatcher = true;

		    // BINDING EVENTS

		    // listen for newly registered members
		    channel.bind("member_registered", function(mes) {
		    	var number = mes.num_of_ppl;
		    	if (number == 1) {
			    	$(".number-of-members").text(number + ' Member in this buying group')
		    	} else if (number == 0) {
			    	$(".number-of-members").text('This buying group is empty')
		    	} else {
			    	$(".number-of-members").text(number + ' Members in this buying group')
		    	}
		    	addMemberToDom(mes);
		    });

		    // listen for any dropped members
		    channel.bind("unregister_member",function(mes) {
		    	var number = mes.num_of_ppl;

		    	if (number == 1) {
			    	$(".number-of-members").text(number + ' Member in this buying group')
		    	} else if (number == 0) {
			    	$(".number-of-members").text('This buying group is empty')
		    	} else {
			    	$(".number-of-members").text(number + ' Members in this buying group')
		    	}
		    	$("#member_row_" + mes.member_group_id).fadeOut('500', function() {
				    $("#member_row_" + mes.member_group_id).remove();
		    	});
		    })

  		    // listen for any checked in members
		    channel_global.bind("check_in_member",function(mes) {
		    	// checkInMember(mes);
		    	member_id = mes.member_id
		    	$(".check-in-button-for" + member_id).fadeOut(300, function() {
		    		$(".activate-button-for" + member_id).fadeIn(300, function() {
		    			$(this).parents('.member-item').removeClass('member_not_checked_in')
		    			$(this).parents('.member-item').addClass('member_checked_in')
		    		});
		    	});
		    })

		    // listen for any covered members across all groups in this group
		    channel_global.bind("member_covered",function(mes) {
			    $("#member_row_" + mes.member_group_id).addClass('member_covered');
			    $('.active-button-' + mes.member_id).hide(500);

			    member_id = mes.member_id
			    $.ajax({
			    	url: '/groups/present_day_container',
			    	data: {member_id: mes.member_id},
			    })
			    .done(function(html) {
			    	$('.day-holder-for' + member_id).html(html);
			    })
			    

			    $("#action-holder-for" + mes.member_group_id).html("This member has been covered");
		    })



		    channel_global.bind("group_updated",function(mes) {
		    	var group_id_specific = mes.group_id
		    	var newCount = mes.count
		    	var oldCount = $("#side-item-count-for-group-" + group_id_specific).text();


			    if (group_id == 'master_tab') {
			    	// find the row and update the percent
			    	$.ajax({
			    		url: '/groups/present_master_partial',
			    		data: {group_id: group_id_specific}
			    	})
			    	.done(function(html) {
				    	$("#master_tab_group_" + group_id_specific).html(html);
			    	})
			    }

		    	if (mes.group_id != group_id) {
				  	$("#side-item-group-" + group_id_specific).css("border-left", "10px solid red");
		    	}
			  	if (mes.complete) {
				  	$("#side-item-group-" + group_id_specific).css('background-color', '#6dff94');
				  	if (group_id == group_id_specific) {
				  		$(".content").css('background-color', '#6dff94');
				  	} 
			  	} else {
				  	$("#side-item-group-" + group_id_specific).css('background-color', '#ecf0f5');
			  		$(".content").css('background-color', 'transparent');

			  	}

		  		$("#side-item-count-for-group-" + group_id_specific).text(newCount);
			  	if (newCount != oldCount) {
			  		$("#side-item-count-for-group-" + group_id_specific).css('background-color', 'yellow');
			  		setTimeout(function(){
				  		$("#side-item-count-for-group-" + group_id_specific).css('background-color', 'transparent');
			  		},1000)
			  	}
		    })

		    // listen for active members
		    channel_global.bind("activate_member",function(mes) {
		    	if (mes.connection_id != connectionID) {
			    	$(".activate-button-for" + mes.member_id).fadeOut(1000, function() {
				    	$("#action-message-for" + mes.member_id).fadeIn(1000, function() {});
			    	});
				    $(".member_groups_marker_" + mes.member_id).addClass('member_active');
		    	}
		    })

		    channel_global.bind("deactivate_member",function(mes) {
		    	if (mes.connection_id != connectionID) {
			    	$("#action-message-for" + mes.member_id).fadeOut(1000, function() {
				    	$(".activate-button-for" + mes.member_id).fadeIn(1000, function() {});
			    	});
				    $(".member_groups_marker_" + mes.member_id).removeClass('member_active');
		    	}
		    })

		    // chatroom listeners
		    channel_global.bind('add_global_message', function(message) {
		    	console.log('global:' + message);
		    	if ($('.chat-box-global').css('display') == "none") {
			    	$('.expand-chat-log-global').css('background-color', 'red');
		    	}
		    	if (typeof message.connection_id != 'undefined' ) {
			    	addCommentToDomGlobal(message);
		    	}
		    });

		    channel.bind('add_room_message', function(message) {
		    	if ($('.chat-box-group').css('display') == "none") {
			    	$('.expand-chat-log-group').css('background-color', 'red');
		    	}
		    	if (typeof message.connection_id != 'undefined' ) {
			    	addCommentToDom(message);
		    	}
		    });

		    // someone_typing
		    channel.bind('someone_typing', function(message) {
		    	someoneTyping();
		    });

		    dispatcher.bind('connection_closed', function() {
					setTimeout(function(){
						takeOffline();
					}, 500);
				});

	    console.log(room_create_success);
	  	}
	  }
	}

	setTimeout(function(){
	  startDispatch();
	}, 500);


	// This will restart to dispatcher everytime you switch back on

  var someoneTyping = function(){
  	$('.someone_typing').css('display', 'block');
  	$('.someone_typing').fadeOut(2000, function() {
  		
  	});

  }

// check in funcitonality
$('body').on('click', '.check-in', function(event) {
	event.preventDefault();
	var member_id = $(this).attr('member-id');
	var obj = { room: group_id, member_id: member_id, connection: connectionID };
	dispatcher.trigger('check_in_member', obj);
});

// chat rooom functionality
 $('body').on('keydown', '.chat-message-input', function(event) {
 	var type = $(this).attr('scope');
		if (event.which == 13) {
		 	event.preventDefault();
		 	var message = $(this).val();
		 	$(this).val('');
		 	$.ajax({
		 		url: '/groups/process_message',
		 		type: 'POST',
		 		data: {message: {message: message, group_id: group_id}, type: type},
		 	})
		 	.done(function(data) {
		 		if (data.success) {
			 		var obj = { message: data.message, room: group_id, user_id: data.user_id, connection: connectionID, type: data.type};
			 		dispatcher.trigger('send_chat_message', obj);
		 		} else {
		 			populateErrors(data.message);
		 		}
		 	})

		} else {
			// notify users that someone is typing
			dispatcher.trigger('someone_typing', {room: group_id}, success, failure);
		}
 });

 $('body').on('click', '#non-covered-toggle', function(event) {
 	event.preventDefault();
 	if ($('.member_covered').css('display') == 'none') {
	 	$('.member_covered').slideDown(500);
 	} else {
	 	$('.member_covered').slideUp(500);
 	}
 });

$('body').on('click', '.expand-chat-log-group', function(event) {
	event.preventDefault();
		// $(this).addClass('selected-chat-log');
		// debugger
		$(this).css('background-color', '#efeacc');
		$(this).css('color', 'black');
		$('.expand-chat-log-global').css('background-color', 'rgb(193, 188, 158)');
		$('.expand-chat-log-global').css('color', 'white');
		$('.chat-box-global').fadeOut(500, function() {
			$('.chat-box-group').fadeIn(500, function() {});
			
		});
});

$('body').on('click', '.expand-chat-log-global', function(event) {
	event.preventDefault();
		// debugger
		$(this).css('background-color', '#efeacc');
		$(this).css('color', 'black');
		$('.expand-chat-log-group').css('background-color', 'rgb(193, 188, 158)');
		$('.expand-chat-log-group').css('color', 'white');
		// $(this).addClass('selected-chat-log');
		// $('.expand-chat-log-group').removeClass('selected-chat-log');
		$('.chat-box-group').fadeOut(500, function() {
			$('.chat-box-global').fadeIn(500, function() {});
		});
});

  var addCommentToDomGlobal = function(message) {
  	var message_id = message.message_id;
    // if (message.connection_id == connectionID) {
    	$.ajax({
    		url: '/groups/add_comment',
    		data: {message_id: message_id, from: 'dom'},
    	})
    	.done(function(data) {
		      $("#chat_log_global").prepend(data);
		      shakeLastMessageGrp('global');
    	})
    	
    var elem = $('#chat_log_global');
    elem.scrollTop = 0;
    console.log('just received new message: ' + message);
  }

  var checkInMember = function(message) {
  	// "check-in-button-for" + message.member_id
  }


  var addCommentToDom = function(message) {
  	var message_id = message.message_id;
    	$.ajax({
    		url: '/groups/add_comment',
    		data: {message_id: message_id, from: 'dom'},
    	})
    	.done(function(data) {
		      $("#chat_log").prepend(data);
		      shakeLastMessageGrp('group');
    	});


    	getGroupCount();
    var elem = $('#chat_log');
    elem.scrollTop = 0;
    console.log('just received new message: ' + message);
  }

  setInterval(function(){
  	if (dispatcher.state != 'connected') {
  		takeOffline();
  	}
  },3000);

  var takeOffline = function(){
			$('.info_top').fadeIn(500, function() {
					$(".web_socket_loading").fadeOut(500, function() {});
			});
  }

  var shakeLastMessageGrp = function(type){
  	if (type == 'group') {
	  	var shakeSub = $('#chat_log .chat-line-group')[0];
  	} else {
	  	var shakeSub = $('#chat_log_global .chat-line')[0];
  	}
	  var initial=0
	  var incre=0
		quibble()
    function quibble(){
	      if(incre<10)
	      {
	        if(incre%2==0)
	          {
	            initial+=25
	          }
	        else
	          {
	            initial-=25
	          }
	        shakeSub.style.marginRight=initial+"px"
	        incre+=1
	        setTimeout(quibble,20)
	      } else {
	        shakeSub.style.marginRight="25px"

	      }
	    }

  }

  var shake = function(shakeSub){
	  var initial=0
	  var incre=0
		quibble()
    function quibble(){
	      if(incre<10)
	      {
	        if(incre%2==0)
	          {
	            initial+=15
	          }
	        else
	          {
	            initial-=15
	          }
	        shakeSub.style.marginRight=initial+"px"
	        incre+=1
	        setTimeout(quibble,20)
	      } else {
	        shakeSub.style.marginRight="25px"

	      }
	    }

  }

});



