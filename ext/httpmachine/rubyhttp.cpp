/*****************************************************************************

$Id: rubyhttp.cpp 2374 2006-04-24 02:51:49Z francis $

File:     libmain.cpp
Date:     06Apr06

Copyright (C) 2006 by Francis Cianfrocca. All Rights Reserved.
Gmail: garbagecat10

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*****************************************************************************/

#include <iostream>
#include <string>
#include <stdexcept>

using namespace std;

#include <ruby.h>
#include "http.h"



/**************************
class RubyHttpConnection_t
**************************/

class RubyHttpConnection_t: public HttpConnection_t
{
	public:
		RubyHttpConnection_t (VALUE v): Myself(v) {}
		virtual ~RubyHttpConnection_t() {}

		virtual void SendData (const char*, int);
		virtual void CloseConnection (bool after_writing);
		virtual void ProcessRequest();

	private:
		VALUE Myself;
};


/******************************
RubyHttpConnection_t::SendData
******************************/

void RubyHttpConnection_t::SendData (const char *data, int length)
{
	rb_funcall (Myself, rb_intern ("send_data"), 1, rb_str_new (data, length));
}


/*************************************
RubyHttpConnection_t::CloseConnection
*************************************/

void RubyHttpConnection_t::CloseConnection (bool after_writing)
{
	VALUE v = rb_intern (after_writing ? "close_connection_after_writing" : "close_connection");
	rb_funcall (Myself, v, 0);
}


/************************************
RubyHttpConnection_t::ProcessRequest
************************************/

void RubyHttpConnection_t::ProcessRequest()
{
	rb_funcall (Myself, rb_intern ("process_http_request"), 0);
}


/*******
Statics
*******/



/***********
t_post_init
***********/

static VALUE t_post_init (VALUE self)
{
	RubyHttpConnection_t *hc = new RubyHttpConnection_t (self);
	if (!hc)
		throw std::runtime_error ("no http-connection object");

	rb_ivar_set (self, rb_intern ("@http______conn"), INT2NUM ((int)hc));
	return Qnil;
}


/**************
t_receive_data
**************/

static VALUE t_receive_data (VALUE self, VALUE data)
{
	int length = NUM2INT (rb_funcall (data, rb_intern ("length"), 0));
	RubyHttpConnection_t *hc = (RubyHttpConnection_t*)(NUM2INT (rb_ivar_get (self, rb_intern ("@http______conn"))));
	if (hc)
		hc->ConsumeData (StringValuePtr (data), length);
	return Qnil;
}


/********
t_unbind
********/

static VALUE t_unbind (VALUE self)
{
	RubyHttpConnection_t *hc = (RubyHttpConnection_t*)(NUM2INT (rb_ivar_get (self, rb_intern ("@http______conn"))));
	if (hc)
		delete hc;
	return Qnil;
}


/**********************
t_process_http_request
**********************/

static VALUE t_process_http_request (VALUE self)
{
	// This is a stub in case the caller doesn't define it.
	rb_funcall (self, rb_intern ("send_data"), 1, rb_str_new2 ("HTTP/1.1 200 ...\r\nContent-type: text/plain\r\nContent-length: 8\r\n\r\nIOWA/HttpEventMachine"));
	return Qnil;
}



/********************
Init_rubyhttpmachine
********************/

extern "C" void Init_rubyhttpmachine()
{
	// INCOMPLETE, we need to define class Connectons inside module EventMachine
  
  VALUE Monorail = rb_define_module ("Iowa");
	VALUE EmModule = rb_define_module_under (Monorail, "HttpEventMachine");
	rb_define_method (EmModule, "post_init", (VALUE(*)(...))t_post_init, 0);
	rb_define_method (EmModule, "receive_data", (VALUE(*)(...))t_receive_data, 1);
	rb_define_method (EmModule, "unbind", (VALUE(*)(...))t_unbind, 0);
	rb_define_method (EmModule, "process_http_request", (VALUE(*)(...))t_process_http_request, 0);
}


